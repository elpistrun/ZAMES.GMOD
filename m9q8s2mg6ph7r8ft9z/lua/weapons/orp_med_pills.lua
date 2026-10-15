--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_med_pills.lua <
    > Callstack:  <
]]

SWEP.Base = "orp_med_base"

SWEP.PrintName = "Таблетки"
SWEP.Category = "Weapons - Medkit"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.WorldModel = "models/weapons/sweps/eft/augmentin/w_meds_augmentin.mdl"
SWEP.WorldModelReal = "models/weapons/sweps/eft/augmentin/v_meds_augmentin.mdl"
SWEP.HoldType = "slam"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.SupportTPIK = true
SWEP.DeploySound = ""

SWEP.IconPos = Vector(30,2,12)
SWEP.IconAng = Angle(0,90,280)

SWEP.Animations = {
    ["idle"] = "idle"
}

SWEP.HealVariants = {
    [1] = {
        anim_phase1 = "use", time1 = 2.4,
        sounds_phase1 = {
            {time = 0.8, sound = "zames/weapons/eft/pills/item_pillsbottle_01_open.wav"},
        },
        -- надо потом сделать все одной
        anim_phase2 = "", time2 = 1.3,
        sounds_phase2 = {
            {time = 0.1, sound = "zames/weapons/eft/pills/item_pillsbottle_02_pilltake.wav"},
            {time = 0.8, sound = "zames/weapons/eft/pills/item_pillsbottle_03_use.wav"}
        },
        
        anim_phase3 = "", time3 = 0.3,
        sounds_phase3 = {},
        
        heal_amount = 25
    },
}
