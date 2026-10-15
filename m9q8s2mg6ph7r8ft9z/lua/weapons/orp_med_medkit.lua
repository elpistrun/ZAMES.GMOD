--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_med_medkit.lua <
    > Callstack:  <
]]

SWEP.Base = "orp_med_base"

SWEP.PrintName = "Аптечка"
SWEP.Category = "Weapons - Medkit"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.WorldModel = "models/weapons/sweps/eft/automedkit/w_meds_automedkit.mdl"
SWEP.WorldModelReal = "models/weapons/sweps/eft/automedkit/v_meds_automedkit.mdl"
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

SWEP.IconPos = Vector(30,1,6)
SWEP.IconAng = Angle(0,90,280)

SWEP.Animations = {
    ["idle"] = "idle"
}

SWEP.HealVariants = {
    [1] = { -- Блистер (Таблетки)
        anim_phase1 = "in_blister", time1 = 2.2,
        sounds_phase1 = {
            {time = 0.5, sound = "zames/weapons/eft/grizzly/item_medkit_grizzly_01_open.wav"}, -- Достаем из кармана
            {time = 1.5, sound = "zames/weapons/eft/pills/item_pillsblister_00_draw.wav"}, -- Шуршим фольгой
        },
        
        anim_phase2 = "use_blister", time2 = 1.6,
        sounds_phase2 = {
            {time = 0.3, sound = "zames/weapons/eft/pills/item_pillsblister_01_open.wav"},        -- Глотаем 1
            {time = 0.8, sound = "zames/weapons/eft/pills/item_pillsbottle_03_use.wav"}         -- Глотаем 2
        },
        
        anim_phase3 = "out_blister", time3 = 0.5,
        sounds_phase3 = {
            --{time = 0.0, sound = "npc/combine_soldier/gear1.wav"}  -- Убираем
        },
        
        heal_amount = 40
    },
    
    [2] = { -- Шприц
        anim_phase1 = "in_syringe", time1 = 3,
        sounds_phase1 = {
            {time = 0.5, sound = "zames/weapons/eft/grizzly/item_medkit_grizzly_01_open.wav"},
            {time = 1.5, sound = "zames/weapons/eft/medkit/item_medkit_ai_02_takesyringe.wav"}
        },
        
        anim_phase2 = "use_syringe", time2 = 0.6,
        sounds_phase2 = {
            {time = 0.1, sound = "zames/weapons/eft/medkit/item_medkit_ai_04_injection.wav"},
        },
        
        anim_phase3 = "out_syringe", time3 = 0.4,
        sounds_phase3 = {
            --{time = 0.0, sound = "npc/combine_soldier/gear3.wav"}
        },
        
        heal_amount = 40
    },
    
    [3] = { -- Бинт
        anim_phase1 = "in_bandage", time1 = 2,
        sounds_phase1 = {
            {time = 0.5, sound = "zames/weapons/eft/grizzly/item_medkit_grizzly_01_open.wav"},
            {time = 1.3, sound = "zames/weapons/eft/bandage/item_bandage_02_bandagetake.wav"},
            {time = 1.9, sound = "zames/weapons/eft/bandage/item_bandage_01_open.wav"},

        },
        
        anim_phase2 = "use_bandage", time2 = 0.9,
        sounds_phase2 = {
            --{time = 0.01, sound = "zames/weapons/eft/bandage/item_bandage_03_use.wav"},
            {time = 0.5, sound = "zames/weapons/eft/bandage/item_bandage_04_end.wav"}
        },
        
        anim_phase3 = "out_bandage", time3 = 0.4,
        sounds_phase3 = {
            --{time = 0.0, sound = "npc/combine_soldier/gear6.wav"}
        },
        
        heal_amount = 40
    },
}
