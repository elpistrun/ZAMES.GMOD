--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_eventspeaker/shared.lua <
    > Callstack: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_eventspeaker/cl_init.lua:1 <
]]

SWEP.Base = "weapon_base"

SWEP.PrintName = "Event Speaker"
SWEP.Category = "Weapons - Other"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.WorldModel = "models/radio/w_radio.mdl"
SWEP.WorldModelReal = "models/radio/c_radio.mdl"
SWEP.HoldType = "slam"
SWEP.Slot = 2

SWEP.DrawCrosshair = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.SupportTPIK = true
SWEP.DeploySound = ""

SWEP.IconPos = Vector(45,-6,3)
SWEP.IconAng = Angle(0,45,0)

SWEP.Animations = {
    ["idle"] = "draw",
    ["turn_on"] = "fire",
    ["turn_off"] = "fire",
}

function SWEP:SetupDataTables()
    self:NetworkVar("String", 0, "TPIK_Anim")
    self:NetworkVar("Float", 1, "TPIK_AnimTime")
    self:NetworkVar("Bool", 0, "EventSpeakerOn")
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
    self:DoAnimation("idle")
    return true
end

function SWEP:PrimaryAttack()
end

function SWEP:Think()
    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    local isAttacking = ply:KeyDown(IN_ATTACK)
    local isOn = self:GetEventSpeakerOn() --
    
    local timerNameOn = "RadioTurnOn_" .. self:EntIndex()
    local timerNameOff = "RadioTurnOff_" .. self:EntIndex()

    if isAttacking and not isOn then
        self:SetEventSpeakerOn(true)
        self:DoAnimation("turn_on")
        
        timer.Remove(timerNameOff)
        
        timer.Create(timerNameOn, 0.5, 1, function()
            if IsValid(self) and IsValid(ply) and self:GetEventSpeakerOn() then
                if SERVER then
                    ply:EmitSound("npc/metropolice/vo/on1.wav", 65, 100, 1, CHAN_WEAPON)
                end
            end
        end)
        
    elseif not isAttacking and isOn then
        self:SetEventSpeakerOn(false)
        self:DoAnimation("turn_off")
        
        timer.Remove(timerNameOn)
        
        
        timer.Create(timerNameOff, 0.5, 1, function()
            if IsValid(self) and IsValid(ply) and not self:GetEventSpeakerOn() then
                if SERVER then
                    ply:EmitSound("npc/metropolice/vo/off1.wav", 65, 100, 1, CHAN_WEAPON)
                end
            end
        end)
    end
end

function SWEP:Holster()
    timer.Remove("RadioTurnOn_" .. self:EntIndex())
    timer.Remove("RadioTurnOff_" .. self:EntIndex())
    return true
end

function SWEP:OnRemove()
    timer.Remove("RadioTurnOn_" .. self:EntIndex())
    timer.Remove("RadioTurnOff_" .. self:EntIndex())
end

function SWEP:SecondaryAttack()
    return false
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
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_eventspeaker/sh_wm.lua <
    > Callstack: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_eventspeaker/cl_init.lua:2 <
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


SWEP.WorldPos = Vector(0, 0, 6) 
SWEP.WorldAng = Angle(0, 0, 0)

SWEP.LWorldPos = Vector(-5, 0, 0) 
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

