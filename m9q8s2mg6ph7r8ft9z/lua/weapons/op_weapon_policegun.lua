--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/op_weapon_policegun.lua <
    > Callstack:  <
]]

SWEP.Base = "orp_base"

SWEP.PrintName = "Police ShotGun"
SWEP.Category = "Weapons - ShotGuns"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/arccw_go/v_shot_870.mdl"

SWEP.HoldType = "rpg"

SWEP.Primary.Ammo = "12 Gauge12"

SWEP.WorldPos = Vector(0, 0, 0) 
SWEP.WorldAng = Angle(0, 0, 0)

SWEP.LWorldPos = Vector(-10, 1, 0) 
SWEP.LWorldAng = Angle(0, 0, 0)

SWEP.LSuicidePos = Vector(2, 4, -42) 
SWEP.LSuicideAng = Angle(-90, 0, 0)

SWEP.SuicidePos = Vector(2, 0, -40) 
SWEP.SuicideAng = Angle(-90, 0, -0)

SWEP.IconPos = Vector(120, 20, 7) -- (X, Y, Z)
SWEP.IconAng = Angle(0, -90, 0)   -- (Pitch, Yaw, Roll)

SWEP.LSightPos = Vector(-5, 4.3, 1.7)
SWEP.LSightAng = Angle(-0.2, 0, 0)

SWEP.TPIKPoseHand = {
    ["right_hand"] = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) },
    ["left_hand"]  = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) }
}

SWEP.AttPos = Vector(0, 0, 0)
SWEP.AttAng = Angle(0, 0, 0)

SWEP.VisualKick = 0.6

SWEP.RealKick = 1
SWEP.RealSpray = 0.9

SWEP.BulletShot = 1
SWEP.SprayBullet = 0

SWEP.IsShotgun = true

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = false

SWEP.Primary.Damage = 10
SWEP.Primary.Delay = 0.8

SWEP.DeploySound = "arccw_go/sawedoff/sawedoff_draw.wav"

SWEP.FireSound = {
    "arccw_go/m590_suppressed_fp.wav",
}

SWEP.ReloadSound = {
    ["out"] = {sound = "arccw_go/nova/nova_insertshell.wav", time = 0.8},
    ["in"] = {sound = "arccw_go/nova/nova_insertshell.wav", time = 0.6},
    ["reload"] = {sound = "arccw_go/sawedoff/sawedoff_pump.wav", time = 0.6}
}

SWEP.Animations = {
    ["draw"] = "idle",
    ["fire"] = { anim = "shoot", mult = 1.3 },
    ["insert"] = { anim = "insert", mult = 1 }, -- Анимация вставки одного патрона
    ["pump"] = { anim = "end_reload_empty", mult = 1.4 }      -- Замени "pump" на название твоей финальной анимации
}
