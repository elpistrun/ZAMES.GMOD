--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/op_weapon_p90.lua <
    > Callstack:  <
]]

SWEP.Base = "orp_base"

SWEP.PrintName = "P90"
SWEP.Category = "Weapons - Secondary"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.IsRif = true

SWEP.WorldModel = "models/weapons/arccw_go/v_smg_p90.mdl"

SWEP.HoldType = "rpg"

SWEP.Primary.Ammo = "5.7x28mm"

SWEP.WorldPos = Vector(2, -2, 5) 
SWEP.WorldAng = Angle(0, 0, 0)

SWEP.LWorldPos = Vector(-6, 1, 0) 
SWEP.LWorldAng = Angle(0, 0, 0)

SWEP.LSuicidePos = Vector(3, 5, -28) 
SWEP.LSuicideAng = Angle(-90, 0, 0)

SWEP.SuicidePos = Vector(5, 2, -20) 
SWEP.SuicideAng = Angle(-90, 0, -0)

SWEP.IconPos = Vector(100, 14, 5) -- (X, Y, Z)
SWEP.IconAng = Angle(0, -90, 0)   -- (Pitch, Yaw, Roll)

SWEP.LSightPos = Vector(-5, 5.2, -0.4)
SWEP.LSightAng = Angle(-0.2, 0, 0)

SWEP.TPIKPoseHand = {
    ["right_hand"] = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) },
    ["left_hand"]  = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) }
}

SWEP.AttPos = Vector(0, 0, 0)
SWEP.AttAng = Angle(0, 0, 0)

SWEP.VisualKick = 0.6

SWEP.RealKick = 3
SWEP.RealSpray = 0.9

SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Automatic = true

SWEP.Primary.Damage = 20
SWEP.Primary.Delay = 0.07

SWEP.DeploySound = "arccw_go/p90/p90_draw.wav"

SWEP.FireSound = {
    "arccw_go/p90/p90_01.wav",
    "arccw_go/p90/p90_02.wav",
    "arccw_go/p90/p90_03.wav",
}

SWEP.ReloadSound = {
    ["out"] = {sound = "arccw_go/p90/p90_clipout.wav", time = 0.1},
    ["in"] = {sound = "arccw_go/p90/p90_clipin.wav", time = 0.9},
    ["reload"] = {sound = "arccw_go/p90/p90_cliphit.wav", time = 1.5}
}

SWEP.Animations = {
    ["draw"] = "ready",
    ["fire"] = "shoot",
    ["reload_empty"] = { anim = "reload_empty", mult = 1.3 }
}
