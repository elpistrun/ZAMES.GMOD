--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/op_weapon_glock18.lua <
    > Callstack:  <
]]

SWEP.Base = "orp_base"

SWEP.PrintName = "Glock18"
SWEP.Category = "Weapons - Pistols"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.IsPistol = true

SWEP.Slot = 1

SWEP.WorldModel = "models/weapons/arccw_go/v_pist_glock.mdl"

SWEP.HoldType = "rpg"

SWEP.Primary.Ammo = "9x19mm Parabellum"

SWEP.WorldPos = Vector(2, -2, 5) 
SWEP.WorldAng = Angle(0, 0, 0)

SWEP.LWorldPos = Vector(-4, 1, 0) 
SWEP.LWorldAng = Angle(0, 0, 0)

SWEP.LSuicidePos = Vector(3, 2.5, -25) 
SWEP.LSuicideAng = Angle(-90, 0, 0)

SWEP.SuicidePos = Vector(6, 0, -20) 
SWEP.SuicideAng = Angle(-90, 0, -0)

SWEP.IconPos = Vector(60, 18, 4) -- (X, Y, Z)
SWEP.IconAng = Angle(0, -90, 0)   -- (Pitch, Yaw, Roll)

SWEP.LSightPos = Vector(-5, 2.8, 1.3)
SWEP.LSightAng = Angle(-0.2, 0, 0)

SWEP.TPIKPoseHand = {
    ["right_hand"] = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) },
    ["left_hand"]  = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) }
}

SWEP.AttPos = Vector(0, 0, 0)
SWEP.AttAng = Angle(0, 0, 0)

SWEP.VisualKick = 0.6

SWEP.RealKick = 2
SWEP.RealSpray = 0.9

SWEP.Primary.ClipSize = 19
SWEP.Primary.DefaultClip = 19
SWEP.Primary.Automatic = false

SWEP.Primary.Damage = 20
SWEP.Primary.Delay = 0.1

SWEP.DeploySound = "arccw_go/glock18/glock_draw.wav"

SWEP.FireSound = {
    --"arccw_go/glock18/glock_01.wav",
    --"arccw_go/glock18/glock_02.wav",
    "arccw_go/glock18/glock18-1.wav"
}

SWEP.ReloadSound = {
    ["out"] = {sound = "arccw_go/glock18/glock_clipout.wav", time = 0.15},
    ["in"] = {sound = "arccw_go/glock18/glock_clipin.wav", time = 0.9},
    ["reload"] = {sound = "arccw_go/glock18/glock_sliderelease.wav", time = 1.6}
}

SWEP.Animations = {
    ["draw"] = "ready",
    ["fire"] = "shoot",
    ["reload_empty"] = { anim = "reload_empty", mult = 1 }
}
