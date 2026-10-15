--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_melee_topor.lua <
    > Callstack:  <
]]

SWEP.Base = "orp_melee_base"

SWEP.PrintName = "Топор"
SWEP.Category = "Weapons - Melees"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.WorldModel = "models/weapons/arc9/darsu_eft/w_melee_voodoo.mdl"
SWEP.WorldModelReal = "models/weapons/arc9/darsu_eft/c_melee_voodoo.mdl"

SWEP.Slot = 0

SWEP.IconPos = Vector(85,5,18)
SWEP.IconAng = Angle(90,0,-90)


SWEP.DrawCrosshair = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false

SWEP.Secondary.Ammo = -1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false

SWEP.Primary.Damage = 18
SWEP.Primary.Delay = 1.8

SWEP.HitDistance = 50

SWEP.SupportTPIK = true

SWEP.DeploySound = "zames/weapons/darsu_eft/melee/hammer_charge2.ogg"

SWEP.CloudSound = {
    "zames/weapons/darsu_eft/melee/scythe_whoosh_01.ogg",
    "zames/weapons/darsu_eft/melee/scythe_whoosh_02.ogg",
    "zames/weapons/darsu_eft/melee/scythe_whoosh_03.ogg",
}

SWEP.HitSound = {
    "zames/weapons/darsu_eft/melee/hammer_hit_body1.ogg",
    "zames/weapons/darsu_eft/melee/hammer_hit_body2.ogg",
}

SWEP.Animations = {
    ["draw"] = "draw_wycc",

    ["hit1"] = {
        anim = "fire1",
        time_anim = 0.7, 
        time_hit = 0.3, 
        number_lines = 8,
        type_line = "diagonal_left",
        in_start = -30,
        in_out = 30,
        damage = 25,
    },

    ["hit2"] = {
        anim = "fire2",
        time_anim = 1,
        time_hit = 0.35,
        number_lines = 1,
        type_line = "pitch",
        in_start = 0,
        in_out = 0,
        damage = 30,
    }
}
