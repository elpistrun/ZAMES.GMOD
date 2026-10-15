--[[
    Серверная логика лутбоксов намеренно живёт не здесь, а в гмеймоде:
    gamemodes/homigrad_com/gamemode/k2s2mg9m2n/sv_lootbox.lua

    Причина: производные сущности (ent_lootbox_food, ent_lootbox_melee) наследуют
    эту базу мимо её sv/cl файлов, поэтому объявленные здесь методы до них не
    доходят. Логика сделана на хуках (EntityInitialized / PlayerUse), от класса
    сущности она не зависит.
--]]