--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_med_base/shared.lua <
    > Callstack: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_med_base/cl_init.lua:1 <
]]

SWEP.Base = "weapon_base"

SWEP.PrintName = "База медицины"
SWEP.Category = "Weapons - Medkit"
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.WorldModel = "models/weapons/sweps/eft/automedkit/v_meds_automedkit.mdl"
SWEP.HoldType = "slam"
SWEP.Slot = 5

SWEP.DrawCrosshair = false
SWEP.DrawWeaponInfoBox = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.SupportTPIK = true
SWEP.DeploySound = ""

SWEP.IconPos = Vector(30,1,6)
SWEP.IconAng = Angle(0,90,280)

SWEP.Animations = {}
SWEP.HealVariants = {}

function SWEP:SetupDataTables()
    self:NetworkVar("String", 0, "TPIK_Anim")
    self:NetworkVar("Float", 1, "TPIK_AnimTime")
    
    self:NetworkVar("Int", 0, "HealPhase") 
    self:NetworkVar("Float", 2, "PhaseEndTime")
    self:NetworkVar("Int", 1, "HealVariant") 
    
    self:NetworkVar("Float", 3, "PhaseStartTime") 
    self:NetworkVar("Int", 2, "SoundIndex")
    
    self:NetworkVar("Entity", 0, "HealTarget")
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end

function SWEP:DoAnimation(key)
    local data = self.Animations[key]
    if not data then return end
    
    if istable(data) then
        self:PlayAnimation(data.anim, data.mult or 1)
    elseif isstring(data) then
        self:PlayAnimation(data, 1)
    end
end

function SWEP:Deploy()
    if IsValid(self.Owner) and (self.Owner:GetNWBool("Otrub") or self.Owner:GetNWBool("TazerFake") or self.Owner:GetNWBool("InvalidNeck")) then return end
    self:SetHealPhase(0)
    self:SetSoundIndex(999)
    self:SetHealTarget(NULL)
    self:DoAnimation("idle")
    
    if self.DeploySound and self.DeploySound ~= "" then
        self:EmitSound(self.DeploySound)
    end
    return true
end

function SWEP:StartPhase(phaseNum, animName, duration)
    self:SetHealPhase(phaseNum)
    self:SetPhaseStartTime(CurTime())
    self:SetPhaseEndTime(CurTime() + duration)
    self:SetSoundIndex(1)
    
    if self:GetHealTarget() == self:GetOwner() then
        self:PlayAnimation(animName, 1)
    else
        self:DoAnimation("idle")
    end
end

function SWEP:StopAllVariantSounds(ply, variantData)
    if not SERVER then return end
    for i = 1, 3 do
        local sounds = variantData["sounds_phase" .. i]
        if sounds then
            for _, sndData in ipairs(sounds) do
                ply:StopSound(sndData.sound)
            end
        end
    end
end

function SWEP:GetHealableTarget()
    local ply = self:GetOwner()
    local tr = ply:GetEyeTrace()
    
    if tr.HitPos:Distance(ply:GetShootPos()) > 85 then return nil end
    
    local ent = tr.Entity
    if IsValid(ent) then
        if ent:IsPlayer() then 
            return ent 
        end
        
        if ent:GetClass() == "prop_ragdoll" then
            for _, p in ipairs(player.GetAll()) do
                if p:GetNWEntity("FakeRagdoll") == ent then
                    return p
                end
            end
        end
    end
    return nil
end

function SWEP:PrimaryAttack()
    if IsValid(self.Owner) and (self.Owner:GetNWBool("Otrub") or self.Owner:GetNWBool("TazerFake") or self.Owner:GetNWBool("InvalidNeck")) then return end
    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    if self:GetHealPhase() > 0 then return end
    if not IsValid(ply:GetNWEntity("FakeRagdoll")) and ply:IsSprinting() then return end
    if ply:Health() >= ply:GetMaxHealth() then return end

    self:SetHealTarget(ply) -- Лечим себя

    local randomVariant = math.floor(util.SharedRandom("MedkitAnim", 1, #self.HealVariants + 0.99))
    self:SetHealVariant(randomVariant) 
    
    local variantData = self.HealVariants[randomVariant]

    self:StartPhase(1, variantData.anim_phase1, variantData.time1)

    local totalTime = variantData.time1 + variantData.time2 + variantData.time3
    self:SetNextPrimaryFire(CurTime() + totalTime)
    self:SetNextSecondaryFire(CurTime() + totalTime)
end

function SWEP:SecondaryAttack()
    if IsValid(self.Owner) and (self.Owner:GetNWBool("Otrub") or self.Owner:GetNWBool("TazerFake") or self.Owner:GetNWBool("InvalidNeck")) then return end
    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    if self:GetHealPhase() > 0 then return end
    if not IsValid(ply:GetNWEntity("FakeRagdoll")) and ply:IsSprinting() then return end
    
    local target = self:GetHealableTarget()
    if not IsValid(target) or target:Health() >= target:GetMaxHealth() then return end

    self:SetHealTarget(target)

    local randomVariant = math.floor(util.SharedRandom("MedkitAnim", 1, #self.HealVariants + 0.99))
    self:SetHealVariant(randomVariant) 
    
    local variantData = self.HealVariants[randomVariant]

    self:StartPhase(1, variantData.anim_phase1, variantData.time1)

    local totalTime = variantData.time1 + variantData.time2 + variantData.time3
    self:SetNextPrimaryFire(CurTime() + totalTime)
    self:SetNextSecondaryFire(CurTime() + totalTime)
end

function SWEP:Think()
    local phase = self:GetHealPhase()
    local ply = self:GetOwner()
    
    if phase > 0 then
        local currentVariantIndex = self:GetHealVariant()
        local variantData = self.HealVariants[currentVariantIndex]
        local healTarget = self:GetHealTarget()
        
        if not IsValid(healTarget) or not healTarget:Alive() then
            self:SetHealPhase(0)
            self:SetSoundIndex(999)
            self:DoAnimation("idle")
            self:StopAllVariantSounds(ply, variantData)
            self:SetNextPrimaryFire(CurTime() + 0.5)
            self:SetNextSecondaryFire(CurTime() + 0.5)
            return
        end

        local phaseSounds = variantData["sounds_phase" .. phase]
        if phaseSounds then
            local currentSndIdx = self:GetSoundIndex()
            
            if currentSndIdx <= #phaseSounds then
                local nextSoundData = phaseSounds[currentSndIdx]
                
                if CurTime() >= self:GetPhaseStartTime() + nextSoundData.time then
                    if SERVER then
                        ply:EmitSound(nextSoundData.sound)
                    end
                    self:SetSoundIndex(currentSndIdx + 1)
                end
            end
        end
        
        local requiredKey = (healTarget == ply) and IN_ATTACK or IN_ATTACK2
        
        if phase < 3 and not ply:KeyDown(requiredKey) then
            self:SetHealPhase(0)
            self:SetSoundIndex(999)
            self:DoAnimation("idle")
            
            self:StopAllVariantSounds(ply, variantData)
            
            self:SetNextPrimaryFire(CurTime() + 0.5)
            self:SetNextSecondaryFire(CurTime() + 0.5)
            return
        end

        if CurTime() >= self:GetPhaseEndTime() then
            
            if phase == 1 then
                self:StartPhase(2, variantData.anim_phase2, variantData.time2)
                
            elseif phase == 2 then
                if SERVER then
                    local newHealth = math.min(healTarget:GetMaxHealth(), healTarget:Health() + variantData.heal_amount)
                    healTarget:SetHealth(newHealth)

                    local ammoCount = ply:GetAmmoCount(self.Primary.Ammo)
                    if ammoCount > 0 then
                        ply:RemoveAmmo(1, self.Primary.Ammo)
                    else
                        ply:StripWeapon(self:GetClass())
                        return
                    end
                end
                
                self:StartPhase(3, variantData.anim_phase3, variantData.time3)
                
            elseif phase == 3 then
                self:SetHealPhase(0)
                self:SetSoundIndex(999)
                self:SetHealTarget(NULL)
                self:DoAnimation("idle")
                self:SetNextPrimaryFire(CurTime() + 0.2)
                self:SetNextSecondaryFire(CurTime() + 0.2)
            end
        end
    end
end

if CLIENT then
    function SWEP:DrawHUD()
        local phase = self:GetHealPhase()

        if phase == 1 or phase == 2 then
            local variantIndex = self:GetHealVariant()
            local variantData = self.HealVariants[variantIndex]

            if variantData then
                local curTime = CurTime()
                local startTime = self:GetPhaseStartTime()

                local time1 = variantData.time1
                local time2 = variantData.time2
                local totalHealTime = time1 + time2

                local elapsedTime = 0

                if phase == 1 then
                    elapsedTime = curTime - startTime
                elseif phase == 2 then
                    elapsedTime = time1 + (curTime - startTime)
                end

                local progress = math.Clamp(elapsedTime / totalHealTime, 0, 1)

                local x = ScrW() / 2
                local y = ScrH() / 1.5
                local radius = 35 

                draw.CircleProgress(x, y, radius, 1, Color(0, 0, 0, 150))
                draw.CircleProgress(x, y, radius, progress, Color(255, 255, 255, 255))

                local target = self:GetHealTarget()
                local text = "Лечимся..."
                
                if IsValid(target) and target ~= LocalPlayer() then
                    text = "Лечим " .. target:Nick()
                end

                draw.SimpleText(
                    text, 
                    "PT.2",
                    x, 
                    y - radius - 15, 
                    Color(255, 255, 255, 255), 
                    TEXT_ALIGN_CENTER, 
                    TEXT_ALIGN_BOTTOM
                )
            end
        end
    end
end

function SWEP:Reload()
end
-- Методы модели изобраны sh_wm.lua вклеплены сюда, чтобы наследуемые оружия
-- получали их наследовали. include() не сработал: они загружаются только для самого оружия, но не для наследуемых.
-- Код вместо силанеруедую встроки раньше, поэтому руки сработают без ошибки и на сервере быть не должно.

--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_med_base/sh_wm.lua <
    > Callstack: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_med_base/cl_init.lua:2 <
]]



function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
    if not IsValid(self.SelectDrawModel) then
        self.SelectDrawModel = ClientsideModel( (self.WorldModelReal or self.WorldModel), RENDER_GROUP_OPAQUE_ENTITY )
        self.SelectDrawModel:SetNoDraw( true )
        self.SelectDrawModelModel = nil
    else
        local selModel = self.WorldModelReal or self.WorldModel

        if self.SelectDrawModelModel ~= selModel then
            self.SelectDrawModel:SetModel( selModel )
            self.SelectDrawModelModel = selModel
        end

        local vec = Vector(0,0,0)
	    local ang = Angle(0,0,0)

        cam.Start3D( vec, ang, 20, x, y + 35, wide, tall, 5, 4096 )
            cam.IgnoreZ( true )
            render.SuppressEngineLighting( true )

            render.SetLightingOrigin( self:GetPos() )
            render.ResetModelLighting( 1 , 1 , 1 )
            render.SetColorModulation( 1, 1, 1 )
            render.SetBlend( 255 )
            render.SetModelLighting( 4, 1, 1, 1 )

            local modelPos = self.IconPos or Vector(0, 0, 0)
            local modelAng = self.IconAng or Angle(0, 0, 0)

            self.SelectDrawModel:SetRenderOrigin( modelPos )
            self.SelectDrawModel:SetRenderAngles( modelAng )
            
            self.SelectDrawModel:DrawModel()
            
            self.SelectDrawModel:SetRenderOrigin()
            self.SelectDrawModel:SetRenderAngles()

            render.SetColorModulation( 1, 1, 1 )
            render.SetBlend( 1 )
            render.SuppressEngineLighting( false )
            cam.IgnoreZ( false )
        cam.End3D()
    end

    self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
end


SWEP.WorldPos = Vector(0, 0, 0) 
SWEP.WorldAng = Angle(0, 0, 0)

SWEP.LWorldPos = Vector(0, 0, 0) 
SWEP.LWorldAng = Angle(0, 0, 0)

SWEP.TPIKPoseHand = {
    ["right_hand"] = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) },
    ["left_hand"]  = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) }
}

function SWEP:GetWM()
    if CLIENT then
        if not IsValid(self.WM_Model) and self.InitializeClient then
            self:InitializeClient()
        end
        
        if IsValid(self.WM_Model) then
            return self.WM_Model
        end
    end
    return NULL
end

function SWEP:PlayAnimation(anim, mult)
    TPIK.PlayAnimation(self, anim, mult)
end

if CLIENT then
    function SWEP:InitializeClient()
        if IsValid(self.WM_Model) then return end
        self.WM_Model = ClientsideModel(self.WorldModelReal or self.WorldModel)
        self.WM_Model:SetNoDraw(true)
        self.WM_Model:SetRenderBounds( Vector(-10000,-10000,-10000), Vector(10000,10000,10000) )
    end

    function SWEP:OnRemove()
        if IsValid(self.WM_Model) then
            self.WM_Model:Remove()
        end

        if IsValid(self.SelectDrawModel) then
            self.SelectDrawModel:Remove()
        end
    end

    function SWEP:DrawWorldModel()
        local ply = self:GetOwner()
        
        if not IsValid(ply) then
            self:DrawModel()
            return
        end

        self:InitializeClient()
        
        local wm = self:GetWM()
        if not IsValid(wm) then return end

        TPIK.UpdateWMPosition(self, wm, ply)
        
        wm:SetupBones()
        wm:DrawModel()
    end

    function SWEP:DoTPIK(isdepth)
        TPIK.DoTPIK(self, isdepth)
    end
end

