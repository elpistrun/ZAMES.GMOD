--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/op_weapon_r8.lua <
    > Callstack:  <
]]

SWEP.Base = "orp_base"

SWEP.PrintName = "R8"
SWEP.Category = "Weapons - Pistols"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.IsPistol = true

SWEP.Slot = 1

SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.WorldModelReal = "models/weapons/arccw_go/v_pist_r8.mdl"

SWEP.HoldType = "rpg"

SWEP.Primary.Ammo = ".367 Magnum"

SWEP.WorldPos = Vector(2, -2, 5) 
SWEP.WorldAng = Angle(0, 0, 0)

SWEP.LWorldPos = Vector(-4, 1, 0) 
SWEP.LWorldAng = Angle(0, 0, 0)

SWEP.LSuicidePos = Vector(3, 3.5, -28) 
SWEP.LSuicideAng = Angle(-90, 0, 0)

SWEP.SuicidePos = Vector(6, 1, -23) 
SWEP.SuicideAng = Angle(-90, 0, -0)

SWEP.IconPos = Vector(70, 18, 4) -- (X, Y, Z)
SWEP.IconAng = Angle(0, -90, 0)   -- (Pitch, Yaw, Roll)

SWEP.LSightPos = Vector(-5, 3.65, 0.8)
SWEP.LSightAng = Angle(-0.2, 0, 0)

SWEP.TPIKPoseHand = {
    ["right_hand"] = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) },
    ["left_hand"]  = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) }
}

SWEP.AttPos = Vector(0, 0, 0)
SWEP.AttAng = Angle(0, 0, 0)

SWEP.VisualKick = 0.6

SWEP.RealKick = 0.9
SWEP.RealSpray = 0.9

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = false

SWEP.Primary.Damage = 35
SWEP.Primary.Delay = 0.7

SWEP.DeploySound = "arccw_go/revolver/revolver_draw.wav"

SWEP.FireSound = {
    --"arccw_go/glock18/glock_01.wav",
    --"arccw_go/glock18/glock_02.wav",
    "arccw_go/revolver/revolver-1_01.wav"
}

SWEP.ReloadSound = {
    ["out"] = {sound = "arccw_go/glock18/glock_clipout.wav", time = 0.4},
    ["in"] = {sound = "arccw_go/glock18/glock_clipin.wav", time = 1.1},
    ["reload"] = {sound = "arccw_go/glock18/glock_sliderelease.wav", time = 1.6}
}

SWEP.Animations = {
    ["draw"] = "draw_alt",
    ["fire"] = "fire",
    ["reload_empty"] = { anim = "reload", mult = 1 }
}
