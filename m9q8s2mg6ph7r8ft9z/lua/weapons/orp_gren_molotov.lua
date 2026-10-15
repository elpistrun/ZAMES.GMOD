--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_gren_molotov.lua <
    > Callstack:  <
]]

SWEP.Base = "orp_gren_base"

SWEP.PrintName = "Molotov"
SWEP.Category = "Weapons - Grenades"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.WorldModel = "models/weapons/arccw_go/w_eq_molotov_thrown.mdl"
SWEP.WorldModelReal = "models/weapons/arccw_go/v_eq_molotov.mdl"
SWEP.HoldType = "slam"
SWEP.Slot = 3

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.SupportTPIK = true
SWEP.DeploySound = ""

SWEP.EntGrenade = "ent_molotov_grenade"

SWEP.WorldPos = Vector(-14, 0, 0) 
SWEP.WorldAng = Angle(0, 0, 0)

SWEP.LWorldPos = Vector(-14, 0, 0) 
SWEP.LWorldAng = Angle(0, 0, 0)

SWEP.TPIKPoseHand = {
    ["right_hand"] = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) },
    ["left_hand"]  = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) }
}

SWEP.IconPos = Vector(70,-27,4)
SWEP.IconAng = Angle(0,90,0)

SWEP.Animations = {
    ["idle1"] = { anim = "draw" },
    ["idle2"] = { anim = "draw" },
    ["start"] = {
        anim = "pullpin",
        sounds = {
            {time = 0.2, sound = "zames/weapons/darsu_eft/grenades/rgd_throw.ogg"}
        }
    },
    ["fire1"] = {
        anim = "throw",
        sounds = {
            {time = 0.1, sound = "zames/weapons/darsu_eft/grenades/rgd_holster.ogg"}
        }
    },
    ["fire2"] = { anim = "fire2" }
}

