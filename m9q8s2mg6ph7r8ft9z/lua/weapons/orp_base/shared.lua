--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_base/shared.lua <
    > Callstack: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_base/cl_init.lua:1 <
]]

game.AddParticles("particles/arc9_muzzleflashes_test_b.pcf")
PrecacheParticleSystem("muzzleflash_ak74")


SWEP.Base = "weapon_base"

SWEP.PrintName = "База Оружий"
SWEP.Category = "Weapons - Secondary"

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/arccw_go/v_rif_ak47.mdl"

SWEP.HoldType = "rpg"

SWEP.DrawWeaponInfoBox = false

SWEP.Slot = 2

SWEP.DrawCrosshair = false

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true

SWEP.Secondary.Ammo = -1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false

SWEP.Primary.Damage = 15
SWEP.Primary.Delay = 0.1

SWEP.SupportTPIK = true

SWEP.DeploySound = ""

SWEP.FireSound = {}

SWEP.ReloadSound = {
    --["out"] = {sound = "arccw_go/nova/nova_insertshell.wav", time = 0.8},
    --["in"] = {sound = "arccw_go/nova/nova_insertshell.wav", time = 0.6},
    --["reload"] = {sound = "arccw_go/sawedoff/sawedoff_pump.wav", time = 0.6}
}

SWEP.Animations = {
    --["draw"] = "idle",
    --["fire"] = { anim = "shoot", mult = 1.3 },
    --["insert"] = { anim = "insert", mult = 1 },
    --["pump"] = { anim = "end_reload_empty", mult = 1.4 }
}

function SWEP:SetupDataTables()
    self:NetworkVar("String", 0, "TPIK_Anim")
    self:NetworkVar("Float", 1, "TPIK_AnimTime")
end

function SWEP:PlayTPIKSound(snd, isTimer)
    if not snd or snd == "" then return end
    
    if CLIENT then
        if self:GetOwner() == LocalPlayer() then
            if isTimer or IsFirstTimePredicted() then
                self:EmitSound(snd)
            end
        end
    else
        net.Start("TPIK_NetworkSound")
        net.WriteString(snd)
        
        local owner = self:GetOwner()
        
        if IsValid(owner) and owner:IsPlayer() then
            net.WriteVector(owner:EyePos())
            net.WriteEntity(owner)
        else
            net.WriteVector(self:GetPos())
            net.WriteEntity(self)
        end
        
        if IsValid(owner) and owner:IsPlayer() then
            net.SendOmit(owner)
        else
            net.Broadcast()
        end
    end
end

function SWEP:Deploy()

    if IsValid(self.Owner) and (self.Owner:GetNWBool("Otrub") or self.Owner:GetNWBool("TazerFake") or self.Owner:GetNWBool("InvalidNeck")) then
        return false
    end

    self.Reloading = false
    self:DoAnimation("draw")
    self:PlayTPIKSound(self.DeploySound)
    return true
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


local function get_shoot(self)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if CLIENT then
        local wm = self:GetWM()

        if not IsValid(wm) then return end

        local att_id = wm:LookupAttachment("1")

        if att_id <= 0 then 
            att_id = wm:LookupAttachment("muzzle") 
        end

        if att_id > 0 then
            local att = wm:GetAttachment(att_id)
            if att then
                return att.Pos
            end
        end
    end
end

function SWEP:GetTracerOrigin()
    if CLIENT then
        local wm = self:GetWM()
        
        if IsValid(wm) then
            local att_id = wm:LookupAttachment("1")
            if att_id <= 0 then 
                att_id = wm:LookupAttachment("muzzle") 
            end

            if att_id > 0 then
                ParticleEffectAttach("muzzleflash_ak74", PATTACH_POINT_FOLLOW, wm, att_id)
            else
                local pos = get_shoot(self)
                if pos then
                    ParticleEffect("muzzleflash_ak74", pos, self:GetAngles())
                end
            end
        end
        
        local pos = get_shoot(self)
        if pos then
            local dlight = DynamicLight(self:EntIndex())
            if dlight then
                dlight.pos = pos
                dlight.r = 255
                dlight.g = 150
                dlight.b = 50
                dlight.brightness = 6
                dlight.Decay = 100
                dlight.Size = 100
                dlight.DieTime = CurTime() + 0.01
            end
        end
    end

    return get_shoot(self)
end

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    if self.Owner:IsSprinting() and not IsValid(self.Owner:GetNWEntity("FakeRagdoll")) then return end
    if self.Owner:GetNWBool("Otrub") or self.Owner:GetNWBool("TazerFake") or self.Owner:GetNWBool("InvalidNeck") then return end

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay) 

    self:DoAnimation("fire")
    self:TakePrimaryAmmo(1)

    if self.FireSound and #self.FireSound > 0 then
        local fire_sounds = self.FireSound[math.random(#self.FireSound)]
        self:PlayTPIKSound(fire_sounds)
    end

    if IsFirstTimePredicted() then
        local punchPitch = -(self.VisualKick or 0.6) * 1.5
        local punchYaw = math.Rand(-0.5, 0.5)
        self.Owner:ViewPunch(Angle(punchPitch, punchYaw, 0))

        if (game.SinglePlayer() and SERVER) or (not game.SinglePlayer() and CLIENT) then
            local eyeAng = self.Owner:EyeAngles()
            eyeAng.pitch = eyeAng.pitch - (self.RealKick or 1.2)
            local randomSpray = math.Rand(-(self.RealSpray or 0.5), (self.RealSpray or 0.5))
            eyeAng.yaw = eyeAng.yaw + randomSpray
            self.Owner:SetEyeAngles(eyeAng)
        end
    end

    if CLIENT then
        if not IsFirstTimePredicted() then return end 
        if not TPIK_CamPos or not TPIK_CamAng then return end
        
        local bullet = {}
        bullet.Num = self.BulletShot or 1
        bullet.Src = TPIK_CamPos
        bullet.Dir = TPIK_CamAng:Forward()
        bullet.Spread = Vector(self.SprayBullet or 0, self.SprayBullet or 0, 0)
        bullet.Tracer = 1
        bullet.Force = 1
        bullet.Damage = 0
        
        local fakeRagdoll = self.Owner:GetNWEntity("FakeRagdoll")
        local isSuiciding = self.Owner:GetNWBool("SuicideMode", false)

        if IsValid(fakeRagdoll) then
            bullet.IgnoreEntity = fakeRagdoll
        else
            bullet.IgnoreEntity = self.Owner 
        end

        if isSuiciding then
            local headBone = self.Owner:LookupBone("ValveBiped.Bip01_Head1")
            local headPos = self.Owner:EyePos()
            
            if headBone then
                headPos = self.Owner:GetBonePosition(headBone)
            end
            
            local startPos = headPos + self.Owner:EyeAngles():Forward() * 15
            bullet.Src = startPos
            bullet.Dir = (headPos - startPos):GetNormalized()
            
            bullet.Spread = Vector(0, 0, 0)

            local numBullets = self.BulletShot or 1
            for i = 1, numBullets do
                net.Start("TPIK_SendDamage")
                    net.WriteEntity(self.Owner)
                    net.WriteVector(bullet.Dir * 3000)
                    net.WriteVector(headPos)
                    net.WriteInt(HITGROUP_HEAD, 8)
                net.SendToServer()
            end
        end

        bullet.Callback = function(attacker, tr, dmginfo)
            if isSuiciding then return end

            if IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:GetClass() == "prop_ragdoll" or tr.Entity:GetClass() == "prop_physics" or tr.Entity:GetClass() == "func_breakable" or tr.Entity:GetClass() == "func_breakable_surf" ) then

                if not isSuiciding then
                    if tr.Entity == self.Owner or tr.Entity:GetNWEntity("RagdollOwner") == self.Owner then
                        return
                    end
                end
                
                local ent = tr.Entity
                local rayDir = (tr.HitPos - tr.StartPos):GetNormalized()
                local customHitGroup = HITGROUP_GENERIC
                
                ent:SetupBones() 
                
                local headBone = ent:LookupBone("ValveBiped.Bip01_Head1")
                local spineBone = ent:LookupBone("ValveBiped.Bip01_Spine2")
                
                local hitHead, hitChest = false, false
                
                if headBone then
                    local hPos, hAng = ent:GetBonePosition(headBone)
                    if hPos and util.IntersectRayWithOBB(tr.StartPos, rayDir * 99999, hPos, hAng, Vector(-5, -5, -5), Vector(5, 5, 5)) then
                        hitHead = true
                    end
                end
                
                if not hitHead and spineBone then
                    local sPos, sAng = ent:GetBonePosition(spineBone)
                    if sPos and util.IntersectRayWithOBB(tr.StartPos, rayDir * 99999, sPos, sAng, Vector(-8, -8, -8), Vector(8, 8, 8)) then
                        hitChest = true
                    end
                end
                
                if hitHead then
                    customHitGroup = HITGROUP_HEAD
                elseif hitChest then
                    customHitGroup = HITGROUP_CHEST
                else
                    customHitGroup = tr.HitGroup 
                end

                net.Start("TPIK_SendDamage")
                    net.WriteEntity(ent)
                    net.WriteVector(dmginfo:GetDamageForce())
                    net.WriteVector(tr.HitPos)
                    net.WriteInt(customHitGroup, 8)
                net.SendToServer()
            end
        end
        
        local isDebug = GetConVar("developer"):GetBool()
        if isDebug then
            local tr = util.TraceLine({
                start = TPIK_CamPos,
                endpos = TPIK_CamPos + (TPIK_CamAng:Forward() * 56756),
                filter = {self.Owner, fakeRagdoll}
            })
            debugoverlay.Line(TPIK_CamPos, tr.HitPos, 5, Color(0, 0, 255), true)
            debugoverlay.Cross(tr.HitPos, 5, 5, Color(0, 0, 255), true)
        end
        
        self.Owner:FireBullets(bullet)

        net.Start("TPIK_FireBullet")
            net.WriteVector(TPIK_CamPos)
            net.WriteAngle(TPIK_CamAng)
        net.SendToServer()
    end
end

function SWEP:SecondaryAttack()
    return false
end

function SWEP:Reload()
    if self.Reloading then 
        return 
    end

    local ammoType = self:GetPrimaryAmmoType()
    local needed = math.min(self.Primary.ClipSize - self:Clip1(), self.Owner:GetAmmoCount(ammoType))
    
    if needed <= 0 then return end

    self.Reloading = true

    if self.IsRif or self.IsPistol then
        self:DoAnimation("reload_empty")
        
        local maxAnimTime = 2.0 
        
        for _, snd in pairs(self.ReloadSound or {}) do
            local delay = tonumber(snd.time) or 0
            if delay > maxAnimTime then maxAnimTime = delay end
            
            timer.Simple(delay, function() 
                if IsValid(self) and snd.sound and self.Owner:GetActiveWeapon() == self then 
                    self:PlayTPIKSound(snd.sound, true)
                end 
            end)
        end

        self:SetNextPrimaryFire(CurTime() + maxAnimTime)

        timer.Simple(maxAnimTime, function()
            if IsValid(self) and IsValid(self.Owner) and self.Owner:GetActiveWeapon() == self then
                local current_needed = math.min(self.Primary.ClipSize - self:Clip1(), self.Owner:GetAmmoCount(ammoType))
                self:SetClip1(self:Clip1() + current_needed)
                self.Owner:RemoveAmmo(current_needed, ammoType)
                self.Reloading = false
            end
        end)

    elseif self.IsShotgun then
        local animTime = 0.6
        local totalTime = (needed * animTime) + 0.8
        
        self:SetNextPrimaryFire(CurTime() + totalTime)

        for i = 1, needed do
            timer.Simple((i - 1) * animTime, function() 
                if IsValid(self) and IsValid(self.Owner) and self.Owner:GetActiveWeapon() == self then 
                    self:DoAnimation("insert") 
                    
                    if self.Owner:GetAmmoCount(ammoType) > 0 and self:Clip1() < self.Primary.ClipSize then
                        self:SetClip1(self:Clip1() + 1)
                        self.Owner:RemoveAmmo(1, ammoType)
                    end

                    if self.ReloadSound and self.ReloadSound["in"] then
                        self:PlayTPIKSound(self.ReloadSound["in"].sound, true)
                    end
                end 
            end)
        end

        timer.Simple(needed * animTime, function()
            if IsValid(self) and IsValid(self.Owner) and self.Owner:GetActiveWeapon() == self then
                self:DoAnimation("pump")
                
                if self.ReloadSound and self.ReloadSound["reload"] then
                    self:PlayTPIKSound(self.ReloadSound["reload"].sound, true)
                end
            end
        end)

        timer.Simple(totalTime, function()
            if IsValid(self) then
                self.Reloading = false
            end
        end)
    end
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
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_base/sh_wm.lua <
    > Callstack: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_base/cl_init.lua:2 <
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


SWEP.WorldPos = Vector(2, -2, 5) 
SWEP.WorldAng = Angle(0, 0, 0)

SWEP.LWorldPos = Vector(-6, 1, 0) 
SWEP.LWorldAng = Angle(0, 0, 0)

SWEP.LSuicidePos = Vector(10, -2, 5) 
SWEP.LSuicideAng = Angle(-180, -45, 0)

SWEP.SuicidePos = Vector(5, -5, 20) 
SWEP.SuicideAng = Angle(0, 90, 180)

SWEP.LSightPos = Vector(-3, 5.05, 1.1)
SWEP.LSightAng = Angle(0, 0, 0)
SWEP.LSightFOV = 75

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

