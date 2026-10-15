--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_gren_base/shared.lua <
    > Callstack: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_gren_base/cl_init.lua:1 <
]]

SWEP.Base = "weapon_base"

SWEP.PrintName = "База гранат"
SWEP.Category = "Weapons - Grenades"
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.WorldModel = "models/weapons/arc9/darsu_eft/w_rgd5.mdl"
SWEP.WorldModelReal = "models/weapons/arc9/darsu_eft/c_rgd5_2.mdl"
SWEP.HoldType = "slam"
SWEP.Slot = 2

SWEP.DrawCrosshair = false

SWEP.DrawWeaponInfoBox = false

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.SupportTPIK = true
SWEP.DeploySound = ""

SWEP.IconPos = Vector(30,-16,5)
SWEP.IconAng = Angle(0,90,0)

SWEP.Animations = {}

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

function SWEP:SetupDataTables()
    self:NetworkVar("String", 0, "TPIK_Anim")
    self:NetworkVar("Float", 1, "TPIK_AnimTime")

    self:NetworkVar("Bool", 0, "IsHoldingLMB")
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

    if istable(data) and data.sounds then
        for _, snd in ipairs(data.sounds) do
            timer.Simple(snd.time, function()
                if IsValid(self) then
                    self:EmitSound(snd.sound)
                end
            end)
        end
    end
end

function SWEP:Deploy()
    if IsValid(self.Owner) and (self.Owner:GetNWBool("Otrub") or self.Owner:GetNWBool("TazerFake") or self.Owner:GetNWBool("InvalidNeck")) then return end
    self:DoAnimation("idle1")
    self:SetIsHoldingLMB(false)
    --self:SetNextPrimaryFire(CurTime() + 1)
    
    if self.DeploySound and self.DeploySound ~= "" then
        self:EmitSound(self.DeploySound)
    end
    return true
end

function SWEP:PrimaryAttack()
    if IsValid(self.Owner) and (self.Owner:GetNWBool("Otrub") or self.Owner:GetNWBool("TazerFake") or self.Owner:GetNWBool("InvalidNeck")) then return end
    local ply = self:GetOwner()
    if not IsValid(ply) then return end
    if not IsValid(ply:GetNWEntity("FakeRagdoll")) and ply:IsSprinting() then return end

    if not self:GetIsHoldingLMB() then
        self:SetIsHoldingLMB(true)
        self:DoAnimation("start")
    end
end

function SWEP:SecondaryAttack()
    return false
end

function SWEP:Reload()
end

function SWEP:Think()
    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    if self:GetIsHoldingLMB() then
        if not ply:KeyDown(IN_ATTACK) then
            self:SetIsHoldingLMB(false)
            self:DoAnimation("fire1")

            if SERVER then
                timer.Simple(0.1, function()
                    if not IsValid(self) or not IsValid(ply) then return end

                    local grenade = ents.Create(self.EntGrenade or "ent_rgd5_grenade")
                    if not IsValid(grenade) then return end

                    grenade:SetModel(self.WorldModel)

                    local eyePos = ply:GetShootPos()
                    local aimVec = ply:GetAimVector()
                    
                    grenade:SetPos(eyePos + (aimVec * 20))
                    grenade:SetAngles(ply:EyeAngles())
                    grenade:SetOwner(ply)
                    grenade:Spawn()

                    local phys = grenade:GetPhysicsObject()
                    if IsValid(phys) then
                        phys:SetVelocity(aimVec * 1200 + ply:GetVelocity())
                        phys:AddAngleVelocity(Vector(math.random(-400, 400), math.random(-400, 400), math.random(-400, 400)))
                    end
                end)
            end

            timer.Simple(1, function()
                if SERVER then
                    if not IsValid(ply) then return end
                
                    ply:StripWeapon(self:GetClass())

                end
                if IsValid(self) then
                    self:DoAnimation("idle2")
                end
            end)
            
            self:SetNextPrimaryFire(CurTime() + 2)
        end
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
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_gren_base/sh_wm.lua <
    > Callstack: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_gren_base/cl_init.lua:2 <
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

