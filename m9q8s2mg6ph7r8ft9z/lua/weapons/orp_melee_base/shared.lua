--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_melee_base/shared.lua <
    > Callstack: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_melee_base/cl_init.lua:1 <
]]

SWEP.Base = "weapon_base"

SWEP.PrintName = "База ближнего боя"
SWEP.Category = "Weapons - Melees"

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/arc9/darsu_eft/w_melee_hultafors.mdl"
SWEP.WorldModelReal = "models/weapons/arc9/darsu_eft/c_melee_hultafors.mdl"

SWEP.HoldType = "slam"

SWEP.DrawWeaponInfoBox = false

SWEP.Slot = 0

SWEP.DrawCrosshair = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false

SWEP.Secondary.Ammo = -1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false

SWEP.Primary.Damage = 20
SWEP.Primary.Delay = 1.8

SWEP.HitDistance = 75 

SWEP.SupportTPIK = true

SWEP.DeploySound = ""

SWEP.CloudSound = {}

SWEP.HitSound = {}

SWEP.Animations = {}

function SWEP:SetupDataTables()
    self:NetworkVar("String", 0, "TPIK_Anim")
    self:NetworkVar("Float", 1, "TPIK_AnimTime")
end

function SWEP:Deploy()
    
    if IsValid(self.Owner) and (self.Owner:GetNWBool("Otrub") or self.Owner:GetNWBool("TazerFake") or self.Owner:GetNWBool("InvalidNeck")) then
        return false
    end

    self.Reloading = false
    self:DoAnimation("draw")
    self:EmitSound(self.DeploySound)
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

function SWEP:MeleeAttack(anim_key)
    if IsValid(self.Owner) and (self.Owner:GetNWBool("Otrub") or self.Owner:GetNWBool("TazerFake") or self.Owner:GetNWBool("InvalidNeck")) then return end
    
    local data = self.Animations[anim_key] 
    if not data then return end

    local anim_time = istable(data) and (data.time_anim or self.Primary.Delay) or self.Primary.Delay
    local time_hit = istable(data) and (data.time_hit or 0.5) or 0.5
    
    self:SetNextPrimaryFire(CurTime() + anim_time) 
    self:SetNextSecondaryFire(CurTime() + anim_time) 

    self:DoAnimation(anim_key)
    if anim_key == "hit1" then self:TakePrimaryAmmo(1) end

    if CLIENT and IsFirstTimePredicted() then
        if anim_key == "hit1" then
            Viewpunch(Angle(2, -3, -1))
        else
            Viewpunch(Angle(2, 3, 1))
        end
    end

    self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav")

    if self.CloudSound and #self.CloudSound > 0 then
        self:EmitSound(self.CloudSound[math.random(#self.CloudSound)])
    end

    self.MeleeHitTime = CurTime() + time_hit
    self.MeleeHitData = data
    self.MeleeHitDone = false
end

function SWEP:PrimaryAttack()
    self:MeleeAttack("hit1")
end

function SWEP:SecondaryAttack()
    self:MeleeAttack("hit2")
end

function SWEP:Think()
    if self.MeleeHitTime and not self.MeleeHitDone and CurTime() >= self.MeleeHitTime then
        self.MeleeHitDone = true
        self.MeleeSoundPlayed = false
        self:PerformMeleeHit(self.MeleeHitData)
    end
end

function SWEP:PerformMeleeHit(data)
    if CLIENT then
        if not IsFirstTimePredicted() then return end 
        if not TPIK_CamPos or not TPIK_CamAng then return end
        
        local isDebug = GetConVar("developer"):GetBool() and LocalPlayer():IsSuperAdmin()
        local fakeRagdoll = self.Owner:GetNWEntity("FakeRagdoll")
        local num_lines = istable(data) and data.number_lines or 1

        local hitEntitiesThisSwing = {} 

        for i = 1, num_lines do
            local fraction = (num_lines > 1) and ((i - 1) / (num_lines - 1)) or 0.5
            
            local in_start = istable(data) and data.in_start or 0
            local in_out = istable(data) and data.in_out or 0
            local offset_deg = Lerp(fraction, in_start, in_out)
            
            local fire_ang = Angle(TPIK_CamAng)
            local type_line = istable(data) and data.type_line or "pitch"
            
            if type_line == "pitch" then
                fire_ang:RotateAroundAxis(fire_ang:Right(), offset_deg)
            elseif type_line == "yaw" then
                fire_ang:RotateAroundAxis(fire_ang:Up(), offset_deg)
            elseif type_line == "diagonal_right" then
                fire_ang:RotateAroundAxis(fire_ang:Right(), offset_deg)
                fire_ang:RotateAroundAxis(fire_ang:Up(), offset_deg)
            elseif type_line == "diagonal_left" then
                fire_ang:RotateAroundAxis(fire_ang:Right(), offset_deg)
                fire_ang:RotateAroundAxis(fire_ang:Up(), -offset_deg)
            end
            
            local dir = fire_ang:Forward()
            local end_pos = TPIK_CamPos + (dir * self.HitDistance)

            local tr = util.TraceLine({
                start = TPIK_CamPos,
                endpos = end_pos,
                filter = IsValid(fakeRagdoll) and fakeRagdoll or self.Owner,
                mask = MASK_SHOT_HULL
            })

            if not self.MeleeSoundPlayed and tr.Hit then
                self.MeleeSoundPlayed = true
                
                if CLIENT and IsFirstTimePredicted() then
                    Viewpunch(Angle(-5, math.random(-2, 2), math.random(-1, 1)))
                end
                
                if tr.HitWorld then
                    surface.PlaySound("zames/weapons/darsu_eft/melee/hammer_hit_wall1.ogg")
                    
                    local eff = EffectData()
                    eff:SetOrigin(tr.HitPos)
                    eff:SetNormal(tr.HitNormal)
                    util.Effect("MetalSpark", eff)

                elseif IsValid(tr.Entity) then
                    local cls = tr.Entity:GetClass()
                    if cls == "prop_ragdoll" or tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
                        if self.HitSound and #self.HitSound > 0 then
                            surface.PlaySound(self.HitSound[math.random(#self.HitSound)])
                        end
                        
                        local eff = EffectData()
                        eff:SetOrigin(tr.HitPos)
                        eff:SetNormal(tr.HitNormal)
                        eff:SetEntity(tr.Entity)
                        util.Effect("BloodImpact", eff)
                    end
                end
            end

            if IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:GetClass() == "prop_ragdoll" or tr.Entity:GetClass() == "prop_physics" or tr.Entity:GetClass() == "func_breakable" or tr.Entity:GetClass() == "func_breakable_surf" ) then

                if tr.Entity == self.Owner or tr.Entity:GetNWEntity("RagdollOwner") == self.Owner then
                    return
                end
                
                local ent = tr.Entity
                
                if not hitEntitiesThisSwing[ent] then 
                    hitEntitiesThisSwing[ent] = true 

                    local rayDir = dir
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

                    local attack_damage = istable(data) and data.damage or self.Primary.Damage

                    net.Start("TPIK_SendDamage123")
                        net.WriteEntity(ent)
                        net.WriteVector(dir * 5)
                        net.WriteVector(tr.HitPos)
                        net.WriteInt(customHitGroup, 8)
                        net.WriteInt(attack_damage, 16)
                    net.SendToServer()
                end
            end

            if isDebug then
                debugoverlay.Line(TPIK_CamPos, end_pos, 2, Color(255, 0, 0), true)
                debugoverlay.Cross(end_pos, 5, 2, Color(255, 0, 0), true)
            end
        end


    end
end

function SWEP:Reload()
end

--[[local matCircle = mh("zames/models/circle.png") 

SWEP.SmoothX = 0
SWEP.SmoothY = 0
SWEP.SmoothRadius = 0

function SWEP:DrawHUD()
    if not (GetViewEntity() == LocalPlayer()) then return end
    if LocalPlayer():InVehicle() then return end
    
    local ply = self:GetOwner()
    local t = {}
    t.start = TPIK_CamPos
    t.endpos = t.start + ply:GetAngles():Forward() * 90
    t.filter = self:GetOwner()
    local Tr = util.TraceLine(t)

    if Tr.Hit then
        local TargetSize = math.Clamp(1 - ((Tr.HitPos - self:GetOwner():GetShootPos()):Length() / 60) ^ 2, .1, .3)
        local TargetRadius = 40 * TargetSize
        local TargetPos = Tr.HitPos:ToScreen()

        if self.SmoothX == 0 and self.SmoothY == 0 then
            self.SmoothX = TargetPos.x
            self.SmoothY = TargetPos.y
            self.SmoothRadius = TargetRadius
        end

        local speed = 15 * FrameTime()
        self.SmoothX = Lerp(speed, self.SmoothX, TargetPos.x)
        self.SmoothY = Lerp(speed, self.SmoothY, TargetPos.y)
        self.SmoothRadius = Lerp(speed, self.SmoothRadius, TargetRadius)

        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(matCircle)
        
        surface.DrawTexturedRect(
            self.SmoothX - self.SmoothRadius, 
            self.SmoothY - self.SmoothRadius, 
            self.SmoothRadius * 2, 
            self.SmoothRadius * 2
        )
    else
        self.SmoothX = 0
        self.SmoothY = 0
    end
end--]]
-- Методы модели изобраны sh_wm.lua вклеплены сюда, чтобы наследуемые оружия
-- получали их наследовали. include() не сработал: они загружаются только для самого оружия, но не для наследуемых.
-- Код вместо силанеруедую встроки раньше, поэтому руки сработают без ошибки и на сервере быть не должно.

--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_melee_base/sh_wm.lua <
    > Callstack: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_melee_base/cl_init.lua:2 <
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

