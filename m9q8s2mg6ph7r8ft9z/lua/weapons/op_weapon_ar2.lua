--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/op_weapon_ar2.lua <
    > Callstack:  <
]]

SWEP.Base = "orp_base"

SWEP.PrintName = "AR2"
SWEP.Category = "Weapons - Secondary"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.IsRif = true

SWEP.WorldModel = "models/weapons/w_irifle.mdl"
SWEP.WorldModelReal = "models/weapons/c_irifle.mdl"

SWEP.HoldType = "rpg"

SWEP.Primary.Ammo = "5.67x45mm NATO"

SWEP.DrawCrosshair = true

SWEP.WorldPos = Vector(2, -2, 5) 
SWEP.WorldAng = Angle(0, 0, 0)

SWEP.LWorldPos = Vector(-10, 0, 0) 
SWEP.LWorldAng = Angle(0, 0, 0)

SWEP.LSuicidePos = Vector(3, 5, -45) 
SWEP.LSuicideAng = Angle(-90, 0, 0)

SWEP.SuicidePos = Vector(5, 2, -30) 
SWEP.SuicideAng = Angle(-90, 0, -0)

SWEP.IconPos = Vector(120, 23, 7) -- (X, Y, Z)
SWEP.IconAng = Angle(0, -90, 0)   -- (Pitch, Yaw, Roll)

SWEP.LSightPos = Vector(-5, 5.13, 0.65)
SWEP.LSightAng = Angle(-0.2, 0, 0)

SWEP.TPIKPoseHand = {
    ["right_hand"] = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) },
    ["left_hand"]  = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) }
}

SWEP.AttPos = Vector(0, 0, 0)
SWEP.AttAng = Angle(0, 0, 0)

SWEP.VisualKick = 0.6

SWEP.RealKick = 2
SWEP.RealSpray = 1.2

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true

SWEP.Primary.Damage = 35
SWEP.Primary.Delay = 0.09

SWEP.DeploySound = "arccw_go/m4a1/m4a1_draw.wav"

SWEP.FireSound = {
    "weapons/ar2/fire1.wav",
}

SWEP.ReloadSound = {
    ["out"] = {sound = "weapons/ar2/ar2_reload_rotate.wav", time = 0.1},
    ["in"] = {sound = "weapons/ar2/ar2_reload_push.wav", time = 0.9},
    ["reload"] = {sound = "", time = 0.6},
}

SWEP.Animations = {
    ["draw"] = "IR_idle",
    ["fire"] = "IR_fire",
    ["reload_empty"] = { anim = "IR_reload", mult = 0.6 }
}
