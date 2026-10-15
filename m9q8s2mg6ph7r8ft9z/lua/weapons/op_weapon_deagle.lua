--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/op_weapon_deagle.lua <
    > Callstack:  <
]]

SWEP.Base = "orp_base"

SWEP.PrintName = "Deagle"
SWEP.Category = "Weapons - Pistols"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.IsPistol = true

SWEP.Slot = 1

SWEP.WorldModel = "models/weapons/arccw_go/v_pist_deagle.mdl"

SWEP.HoldType = "rpg"

SWEP.Primary.Ammo = ".50 AE"

SWEP.WorldPos = Vector(2, -2, 5) 
SWEP.WorldAng = Angle(0, 0, 0)

SWEP.LWorldPos = Vector(-4, 1, 0) 
SWEP.LWorldAng = Angle(0, 0, 0)

SWEP.LSuicidePos = Vector(3, 4, -27) 
SWEP.LSuicideAng = Angle(-90, 0, 0)

SWEP.SuicidePos = Vector(6, 2, -23) 
SWEP.SuicideAng = Angle(-90, 0, -0)

SWEP.IconPos = Vector(60, 18, 4) -- (X, Y, Z)
SWEP.IconAng = Angle(0, -90, 0)   -- (Pitch, Yaw, Roll)

SWEP.LSightPos = Vector(-5, 3.85, 0.45)
SWEP.LSightAng = Angle(-0.2, 0, 0)

SWEP.TPIKPoseHand = {
    ["right_hand"] = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) },
    ["left_hand"]  = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) }
}

SWEP.AttPos = Vector(0, 0, 0)
SWEP.AttAng = Angle(0, 0, 0)

SWEP.VisualKick = 0.6

SWEP.RealKick = 4
SWEP.RealSpray = 0.9

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = false

SWEP.Primary.Damage = 25
SWEP.Primary.Delay = 0.3

SWEP.DeploySound = "arccw_go/deagle/de_draw.wav"

SWEP.FireSound = {
    --"arccw_go/glock18/glock_01.wav",
    --"arccw_go/glock18/glock_02.wav",
    "arccw_go/deagle/deagle_01.wav",
    "arccw_go/deagle/deagle_02.wav",
}

SWEP.ReloadSound = {
    ["out"] = {sound = "arccw_go/deagle/de_clipout.wav", time = 0.1},
    ["in"] = {sound = "arccw_go/deagle/de_clipin.wav", time = 0.9},
    ["reload"] = {sound = "arccw_go/deagle/de_slideforward.wav", time = 1.6}
}

SWEP.Animations = {
    ["draw"] = "draw",
    ["fire"] = "shoot3",
    ["reload_empty"] = { anim = "reload_empty", mult = 0.9 }
}
