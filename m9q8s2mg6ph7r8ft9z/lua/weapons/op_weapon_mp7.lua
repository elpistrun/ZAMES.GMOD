--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/op_weapon_mp7.lua <
    > Callstack:  <
]]

SWEP.Base = "orp_base"

SWEP.PrintName = "MP7"
SWEP.Category = "Weapons - Secondary"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.IsRif = true

SWEP.WorldModel = "models/weapons/arccw_go/v_smg_mp7.mdl"

SWEP.HoldType = "rpg"

SWEP.Primary.Ammo = "4.6x30mm"

SWEP.WorldPos = Vector(2, -2, 5) 
SWEP.WorldAng = Angle(0, 0, 0)

SWEP.LWorldPos = Vector(-6, 1, 0) 
SWEP.LWorldAng = Angle(0, 0, 0)

SWEP.LSuicidePos = Vector(3, 5, -30) 
SWEP.LSuicideAng = Angle(-90, 0, 0)

SWEP.SuicidePos = Vector(5, 2, -30) 
SWEP.SuicideAng = Angle(-90, 0, -0)

SWEP.IconPos = Vector(100, 18, 7) -- (X, Y, Z)
SWEP.IconAng = Angle(0, -90, 0)   -- (Pitch, Yaw, Roll)

SWEP.LSightPos = Vector(-5, 5.3, 0.9)
SWEP.LSightAng = Angle(-0.2, 0, 0)

SWEP.TPIKPoseHand = {
    ["right_hand"] = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) },
    ["left_hand"]  = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) }
}

SWEP.AttPos = Vector(0, 0, 0)
SWEP.AttAng = Angle(0, 0, 0)

SWEP.VisualKick = 0.6

SWEP.RealKick = 2
SWEP.RealSpray = 2

SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = true

SWEP.Primary.Damage = 30
SWEP.Primary.Delay = 0.08

SWEP.DeploySound = "arccw_go/mp7/mp7_draw.wav"

SWEP.FireSound = {
    "arccw_go/mp7/mp7_01.wav",
    "arccw_go/mp7/mp7_02.wav",
    "arccw_go/mp7/mp7_03.wav",
    "arccw_go/mp7/mp7_04.wav"
}

SWEP.ReloadSound = {
    ["out"] = {sound = "arccw_go/mp7/mp7_clipout.wav", time = 0.1},
    ["in"] = {sound = "arccw_go/mp7/mp7_clipin.wav", time = 0.9},
    ["reload"] = {sound = "arccw_go/mp7/mp7_slideforward.wav", time = 1.5}
}

SWEP.Animations = {
    ["draw"] = "draw",
    ["fire"] = "shoot",
    ["reload_empty"] = { anim = "reload_empty", mult = 1.3 }
}
