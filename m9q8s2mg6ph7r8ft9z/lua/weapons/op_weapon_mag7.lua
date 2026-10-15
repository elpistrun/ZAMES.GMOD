--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/op_weapon_mag7.lua <
    > Callstack:  <
]]

SWEP.Base = "orp_base"

SWEP.PrintName = "MAG-7"
SWEP.Category = "Weapons - ShotGuns"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/arccw_go/v_shot_mag7.mdl"

SWEP.HoldType = "rpg"

SWEP.Primary.Ammo = "12 Gauge124"

SWEP.WorldPos = Vector(-9, 0, 0) 
SWEP.WorldAng = Angle(0, 0, 0)

SWEP.LWorldPos = Vector(-10, 1, 0) 
SWEP.LWorldAng = Angle(0, 0, 0)

SWEP.LSuicidePos = Vector(3, 6, -45) 
SWEP.LSuicideAng = Angle(-90, 0, 0)

SWEP.SuicidePos = Vector(2, 4, -40) 
SWEP.SuicideAng = Angle(-90, 0, -0)

SWEP.IconPos = Vector(120, 25, 7) -- (X, Y, Z)
SWEP.IconAng = Angle(0, -90, 0)   -- (Pitch, Yaw, Roll)

SWEP.LSightPos = Vector(-5, 6.35, 3.1)
SWEP.LSightAng = Angle(-0.2, 0, 0)

SWEP.TPIKPoseHand = {
    ["right_hand"] = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) },
    ["left_hand"]  = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) }
}

SWEP.AttPos = Vector(0, 0, 0)
SWEP.AttAng = Angle(0, 0, 0)

SWEP.VisualKick = 0.6

SWEP.RealKick = 10
SWEP.RealSpray = 0.9

SWEP.BulletShot = 6
SWEP.SprayBullet = 0.04

SWEP.IsPistol = true
--SWEP.IsShotgun = true

SWEP.Primary.ClipSize = 4
SWEP.Primary.DefaultClip = 4
SWEP.Primary.Automatic = false

SWEP.Primary.Damage = 10
SWEP.Primary.Delay = 0.8

SWEP.DeploySound = "arccw_go/mag7/mag7_draw.wav"

SWEP.FireSound = {
    "arccw_go/mag7/mag7_01.wav",
    "arccw_go/mag7/mag7_02.wav",
}

SWEP.ReloadSound = {
    ["out"] = {sound = "arccw_go/mag7/mag7_clipin.wav", time = 0.1},
    ["in"] = {sound = "arccw_go/mag7/mag7_clipout.wav", time = 0.9},
    ["reload"] = {sound = "arccw_go/mag7/mag7_pump_forward.wav", time = 1.7}
}

SWEP.Animations = {
    ["draw"] = "idle",
    ["fire"] = { anim = "shoot", mult = 1.3 },
    ["reload_empty"] = { anim = "reload_longmag_empty", mult = 1 }, -- Анимация вставки одного патрона
}
