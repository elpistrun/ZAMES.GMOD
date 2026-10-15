--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/op_weapon_m4a1.lua <
    > Callstack:  <
]]

SWEP.Base = "orp_base"

SWEP.PrintName = "M4A1"
SWEP.Category = "Weapons - Secondary"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.IsRif = true

SWEP.WorldModel = "models/weapons/arccw_go/v_rif_m4a1.mdl"

SWEP.HoldType = "rpg"

SWEP.Primary.Ammo = "5.67x45mm NATO"

SWEP.WorldPos = Vector(2, -2, 5) 
SWEP.WorldAng = Angle(0, 0, 0)

SWEP.LWorldPos = Vector(-10, 1, 0) 
SWEP.LWorldAng = Angle(0, 0, 0)

SWEP.LSuicidePos = Vector(3, 5, -35) 
SWEP.LSuicideAng = Angle(-90, 0, 0)

SWEP.SuicidePos = Vector(5, 2, -30) 
SWEP.SuicideAng = Angle(-90, 0, -0)

SWEP.IconPos = Vector(120, 17, 7) -- (X, Y, Z)
SWEP.IconAng = Angle(0, -90, 0)   -- (Pitch, Yaw, Roll)

SWEP.LSightPos = Vector(-3,5.15,0.680)
SWEP.LSightAng = Angle(0, 0, 0)

SWEP.TPIKPoseHand = {
    ["right_hand"] = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) },
    ["left_hand"]  = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) }
}

SWEP.AttPos = Vector(0, 0, 0)
SWEP.AttAng = Angle(0, 0, 0)

SWEP.VisualKick = 0.6

SWEP.RealKick = 3
SWEP.RealSpray = 1.3

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true

SWEP.Primary.Damage = 35
SWEP.Primary.Delay = 0.09

SWEP.DeploySound = "arccw_go/m4a1/m4a1_draw.wav"

SWEP.FireSound = {
    "arccw_go/m4a1/m4a1_01.wav",
    "arccw_go/m4a1/m4a1_02.wav",
    "arccw_go/m4a1/m4a1_03.wav",
    "arccw_go/m4a1/m4a1_04.wav"
}

SWEP.ReloadSound = {
    ["out"] = {sound = "arccw_go/m4a1/m4a1_clipout.wav", time = 0.2},
    ["in"] = {sound = "arccw_go/m4a1/m4a1_clipin.wav", time = 1},
    ["reload"] = {sound = "arccw_go/m4a1/m4a1_cliphit.wav", time = 1.5}
}

SWEP.Animations = {
    ["draw"] = "ready",
    ["fire"] = "shoot3",
    ["reload_empty"] = { anim = "reload_empty", mult = 1.3 }
}
