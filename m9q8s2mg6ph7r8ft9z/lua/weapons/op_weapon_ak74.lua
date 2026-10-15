--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/op_weapon_ak74.lua <
    > Callstack:  <
]]

SWEP.Base = "orp_base"

SWEP.PrintName = "AK47"
SWEP.Category = "Weapons - Secondary"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.IsRif = true

SWEP.WorldModel = "models/weapons/arccw_go/v_rif_ak47.mdl"

SWEP.HoldType = "rpg"

SWEP.WorldPos = Vector(2, -2, 5) 
SWEP.WorldAng = Angle(0, 0, 0)

SWEP.LWorldPos = Vector(-6, 1, 0) 
SWEP.LWorldAng = Angle(0, 0, 0)

SWEP.LSuicidePos = Vector(3, 5, -40) 
SWEP.LSuicideAng = Angle(-90, 0, 0)

SWEP.SuicidePos = Vector(5, 2, -30) 
SWEP.SuicideAng = Angle(-90, 0, -0)

SWEP.IconPos = Vector(120, 18, 7) -- (X, Y, Z)
SWEP.IconAng = Angle(0, -90, 0)   -- (Pitch, Yaw, Roll)

SWEP.LSightPos = Vector(-3, 5.05, 1.1)
SWEP.LSightAng = Angle(0, 0, 0)

SWEP.TPIKPoseHand = {
    ["right_hand"] = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) },
    ["left_hand"]  = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) }
}

SWEP.AttPos = Vector(0, 0, 0)
SWEP.AttAng = Angle(0, 0, 0)

SWEP.VisualKick = 0.6

SWEP.RealKick = 3
SWEP.RealSpray = 1.2

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true

SWEP.Primary.Ammo = "7.62x39mm"

SWEP.Primary.Damage = 35
SWEP.Primary.Delay = 0.09

SWEP.DeploySound = "arccw_go/ak47/ak47_draw.wav"

SWEP.FireSound = {
    "arccw_go/ak47/ak47_01.wav",
}

SWEP.ReloadSound = {
    ["out"] = {sound = "arccw_go/ak47/ak47_clipout.wav", time = 0.1},
    ["in"] = {sound = "arccw_go/ak47/ak47_clipin.wav", time = 0.9},
    ["reload"] = {sound = "arccw_go/ak47/ak47_boltpull.wav", time = 1.5}
}

SWEP.Animations = {
    ["draw"] = "ak47_draw",
    ["fire"] = "ak47_fire2",
    ["reload_empty"] = "ak47_reload_empty",
}
