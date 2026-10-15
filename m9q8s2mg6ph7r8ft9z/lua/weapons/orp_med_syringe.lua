--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_med_syringe.lua <
    > Callstack:  <
]]

SWEP.Base = "orp_med_base"

SWEP.PrintName = "Шприц"
SWEP.Category = "Weapons - Medkit"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.WorldModel = "models/weapons/sweps/eft/injector/w_meds_injector.mdl"
SWEP.WorldModelReal = "models/weapons/sweps/eft/injector/v_meds_injector.mdl"
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

SWEP.IconPos = Vector(15,11,-2)
SWEP.IconAng = Angle(0,90,280)

SWEP.Animations = {
    ["idle"] = "idle"
}

SWEP.HealVariants = {
    [1] = { -- Блистер (Таблетки)
        anim_phase1 = "use", time1 = 2.2,
        sounds_phase1 = {
            {time = 0.5, sound = "zames/weapons/eft/injector/item_injector_01_kolpachok.wav"}, -- Достаем из кармана
            {time = 1, sound = "zames/weapons/eft/injector/item_injector_02_injection.wav"}, -- Шуршим фольгой
            {time = 1.3, sound = "zames/weapons/eft/medkit/item_medkit_ai_04_injection.wav"},
        },
        
        anim_phase2 = "", time2 = 0.1,
        sounds_phase2 = {
            --{time = 0.1, sound = "zames/weapons/eft/medkit/item_medkit_ai_04_injection.wav"},        -- Глотаем 1
            --{time = 0.8, sound = "zames/weapons/eft/pills/item_pillsbottle_03_use.wav"}         -- Глотаем 2
        },
        
        anim_phase3 = "out_blister", time3 = 0.1,
        sounds_phase3 = {
            --{time = 0.0, sound = "npc/combine_soldier/gear1.wav"}  -- Убираем
        },
        
        heal_amount = 30
    },
}
