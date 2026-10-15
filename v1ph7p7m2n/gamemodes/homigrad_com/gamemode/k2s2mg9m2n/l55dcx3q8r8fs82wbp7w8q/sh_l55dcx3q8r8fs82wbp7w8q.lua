--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/l55dcx3q8r8fs82wbp7w8q/sh_l55dcx3q8r8fs82wbp7w8q.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:26
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

AddCSLuaFile()

MAX_SLOTS = 8 

LootboxConfig = LootboxConfig or {}

LootboxConfig["ent_lootbox_base"] = {
    MAX_SLOTS = 4,
    -- ВАЖНО: классы брони — это имена сущностей из JMod.ArmorTable, а не названия
    -- моделей. Раньше тут стояли fastmtblack/ulach/deathknight/eaimbss/daypack и
    -- им подобные: таких записей в JMod.ArmorTable нет, поэтому предметы попадали
    -- в контейнер, но выдать их было нельзя. Список соответствий ниже —
    -- броня <- JMod.ArmorTable (Light-Helmet -> ent_jack_gmod_ezarmor_lhead и т.д.).
    Items = {
        -- Шлема
        {class = "ent_jack_gmod_ezarmor_ahead" , chance = 35},   -- Advanced-Helmet
        {class = "ent_jack_gmod_ezarmor_mhead" , chance = 35},   -- Medium-Helmet

        -- Маски
        {class = "ent_jack_gmod_ezarmor_balmask" , chance = 35},     -- BallisticMask
        {class = "ent_jack_gmod_ezarmor_respirator" , chance = 35},  -- Respirator
        {class = "ent_jack_gmod_ezarmor_gasmask" , chance = 35},     -- GasMask

        -- Бронежелеты
        {class = "ent_jack_gmod_ezarmor_mtorso", chance = 50},   -- Medium-Vest
        {class = "ent_jack_gmod_ezarmor_ltorso", chance = 50},   -- Light-Vest

        -- Рюкзаки
        {class = "ent_jack_gmod_ezarmor_backpack", chance = 50},            -- Backpack
        {class = "ent_jack_gmod_ezarmor_munitionbackpack", chance = 50},    -- Munition Backpack

        {class = "orp_flashlight", chance = 20},
        {class = "orp_med_medkit", chance = 25},
        {class = "orp_med_pills", chance = 25},
        {class = "orp_med_syringe", chance = 25},
        

        {class = "op_weapon_fiveseven", chance = 10},
        {class = "op_weapon_glock18", chance = 10},
        {class = "op_weapon_deagle", chance = 10},
        

        --{class = "op_weapon_ak74", chance = 20},
    }
}

LootboxConfig["ent_lootbox_food"] = {
    MAX_SLOTS = 3,
    Items = {
        { class = "weapon_food_apple", chance = 80 },
        { class = "weapon_food_beer", chance = 20 },
        { class = "weapon_food_soda_breen", chance = 30 },
        { class = "weapon_food_burger", chance = 30 },
        { class = "weapon_food_coffee", chance = 30 },
        { class = "weapon_food_cupcake", chance = 30 },
        { class = "weapon_food_hotdog", chance = 30 },
        { class = "weapon_food_soda_mac", chance = 30 },
    }
}

LootboxConfig["ent_lootbox_melee"] = {
    MAX_SLOTS = 2,
    Items = {
        { class = "orp_melee_bayonet", chance = 10 },
        { class = "orp_melee_bulava", chance = 5 },
        { class = "orp_melee_crowbar", chance = 50 },
        { class = "orp_melee_shovel", chance = 40 },
        { class = "orp_melee_policebat", chance = 25 },
        { class = "orp_melee_topor", chance = 50 },
        { class = "orp_melee_knife", chance = 15 },
    }
}

LootboxConfig["ent_lootbox_armed"] = {
    MAX_SLOTS = 4,
    Items = {
        { class = "op_weapon_glock18", chance = 60 },
        { class = "op_weapon_p250", chance = 50 },
        { class = "op_weapon_fiveseven", chance = 50 },
        { class = "op_weapon_deagle", chance = 35 },
        { class = "op_weapon_870", chance = 30 },
        { class = "op_weapon_nova", chance = 30 },
        { class = "op_weapon_mp5", chance = 25 },
        { class = "op_weapon_mp7", chance = 25 },
        { class = "op_weapon_ak74", chance = 15 },
        { class = "op_weapon_m4a1", chance = 15 },
        { class = "orp_gren_f1", chance = 20 },
        { class = "orp_gren_rgd5", chance = 20 },
        { class = "orp_gren_molotov", chance = 20 },
    }
}

LootboxConfig["ent_lootbox_random"] = {
    MAX_SLOTS = 5,
    Items = {
        -- Шлема и броня
        { class = "ent_jack_gmod_ezarmor_ahead", chance = 30 },
        { class = "ent_jack_gmod_ezarmor_mtorso", chance = 35 },
        { class = "ent_jack_gmod_ezarmor_backpack", chance = 40 },
        -- Медикаменты
        { class = "orp_med_medkit", chance = 35 },
        { class = "orp_med_pills", chance = 35 },
        { class = "orp_med_syringe", chance = 30 },
        -- Оружие
        { class = "op_weapon_glock18", chance = 35 },
        { class = "op_weapon_p250", chance = 30 },
        { class = "op_weapon_deagle", chance = 20 },
        { class = "op_weapon_870", chance = 20 },
        -- Ближний бой
        { class = "orp_melee_knife", chance = 35 },
        { class = "orp_melee_crowbar", chance = 40 },
        { class = "orp_melee_topor", chance = 35 },
        -- Еда
        { class = "weapon_food_burger", chance = 30 },
        { class = "weapon_food_soda_breen", chance = 30 },
    }
}
inventory_rarity_items = {
    ["orp_melee_bayonet"] = 4,
    ["orp_melee_bulava"] = 5,
}

rarity_colors = {
    [1] = Color(102, 102, 102), -- Обычная
    [2] = Color(120, 255, 79), -- Необычная
    [3] = Color(179, 53, 179), -- Редкая
    [4] = Color(204, 57, 57), -- Эпическая
    [5] = Color(255, 230, 0),  -- Легендарная
}

function GetItemRarity(class)
    if inventory_rarity_items[class] then
        return inventory_rarity_items[class]
    end

    if string.StartWith(class, "op_weapon_") then
        return 3
    elseif string.StartWith(class, "orp_melee_") or string.StartWith(class, "ent_jack_gmod_ezarmor") or string.StartWith(class, "weapon_food") then
        return 2
    elseif string.StartWith(class, "orp_med_") then
        return 4
        
    end

    return 1
end



