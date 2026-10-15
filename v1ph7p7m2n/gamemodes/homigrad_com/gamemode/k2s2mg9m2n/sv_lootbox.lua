--[[
    Серверная логика лутбоксов.

    Спавн и наполнение сделаны на хуках, а не методами ENT: производные сущности
    (ent_lootbox_food, ent_lootbox_melee) наследуют ent_lootbox_base мимо её sv/cl
    файлов, поэтому методы, объявленные на базе, до них не доходят.

    Открытие — через ENT:Use (см. файлы сущностей) и запасной хук PlayerUse;
    обе дороги ведут в ORP_Lootbox_Use.

    Наполнение берётся из LootboxConfig (gamemode/shared):
        LootboxConfig[класс] = { MAX_SLOTS = N, Items = { {class = "...", chance = N}, ... } }
    chance — процент из 100. Предметы, которых нет в билде (нет ни в JMod.ArmorTable,
    ни среди SWEP-ов), отбрасываются с предупреждением в консоль.

    Модель и скин лежат в таблице сущности:
        ent_lootbox_food  -> models/sarma_crates/static_crate_40.mdl, скин 2
        ent_lootbox_melee -> models/sarma_crates/supply_crate02.mdl,  скин 0
--]]

util.AddNetworkString("LootInventory_OpenUI")
util.AddNetworkString("LootInventory_TakeItem")

local LOOTBOX_CLASSES = {
    ["ent_lootbox_base"] = true,
    ["ent_lootbox_food"] = true,
    ["ent_lootbox_melee"] = true,
    ["ent_lootbox_armed"] = true,
    ["ent_lootbox_random"] = true,
}

local MAX_USE_DISTANCE = 150 -- юнитов
local USE_COOLDOWN = 0.5

local function IsLootbox(ent)
    return IsValid(ent) and LOOTBOX_CLASSES[ent:GetClass()] == true
end

local function GetConfig(box)
    return LootboxConfig and LootboxConfig[box:GetClass()]
end

local function GetSlots(box)
    local cfg = GetConfig(box)

    return (cfg and cfg.MAX_SLOTS) or MAX_SLOTS or 4
end

-- Предмет можно выдать, только если он существует в этом билде:
-- броня — запись в JMod.ArmorTable, остальное — зарегистрированный SWEP.
-- Классы, которых нет, отбрасываются с предупреждением: иначе слот рисуется,
-- а выдать из него нечего.
local function ArmorNameOf(class)
    return string.gsub(class, "^ent_jack_gmod_ezarmor_", "")
end

local function IsGiveable(class)
    if string.StartWith(class, "ent_jack_gmod_ezarmor_") then
        -- JMod ещё не загрузился — не режем список, разберёмся при открытии
        if not (JMod and JMod.ArmorTable) then return true end

        return JMod.ArmorTable[ArmorNameOf(class)] ~= nil
    end

    return weapons.Get(class) ~= nil or weapons.GetStored(class) ~= nil
end

local warnedClasses = {}
local warnedSkipped = {}

-- Наполнение контейнера. Возвращает false, если список сформировать нельзя
-- (конфига ещё нет или SWEP-ы не зарегистрированы) — тогда попробуем позже.
-- Сколько предметов осталось. Считаем через pairs: забранные ячейки оставляют
-- «дыры», на которых ipairs обрывается.
local function CountLoot(box)
    local n = 0

    for _ in pairs(box.LootItems or {}) do
        n = n + 1
    end

    return n
end

local function GenerateLoot(box)
    local cfg = GetConfig(box)
    if not cfg or not istable(cfg.Items) then return false end

    local candidates, skipped = {}, 0

    for _, entry in ipairs(cfg.Items) do
        if entry.class then
            if IsGiveable(entry.class) then
                table.insert(candidates, entry)
            else
                skipped = skipped + 1
                if not warnedClasses[entry.class] then
                    warnedClasses[entry.class] = true
                    print("[Lootbox] Класс " .. entry.class ..
                        " пропущен: нет ни в JMod.ArmorTable, ни в списке SWEP-ов")
                end
            end
        end
    end

    if #candidates == 0 then return false end

    if skipped > 0 and not warnedSkipped[box:GetClass()] then
        warnedSkipped[box:GetClass()] = true
        print("[Lootbox] " .. box:GetClass() .. ": пропущено предметов без реализации — " .. skipped)
    end

    local maxSlots = GetSlots(box)
    local items = {}

    for _, entry in ipairs(candidates) do
        if #items >= maxSlots then break end
        if math.random(1, 100) <= (entry.chance or 0) then
            table.insert(items, { class = entry.class })
        end
    end

    -- Пустых контейнеров быть не должно: если шанс не выпал ни на одном
    -- предмете, кладём один случайный.
    if #items == 0 then
        table.insert(items, { class = candidates[math.random(#candidates)].class })
    end

    box.LootItems = items
    box.LootGenerated = true

    return true
end

local function OpenLootbox(ply, box)
    -- Список мог не сформироваться при спавне (порядок загрузки аддонов).
    -- Открытие — последний шанс заполнить контейнер.
    if not box.LootGenerated then GenerateLoot(box) end

    box.LootOpener = ply

    net.Start("LootInventory_OpenUI")
        net.WriteEntity(box)                 -- owner: контейнер, с него потом берут предмет
        net.WriteEntity(NULL)                -- ragdoll: у лутбокса трупа нет
        net.WriteTable(box.LootItems or {})
        net.WriteInt(GetSlots(box), 8)
        net.WriteBool(true)                  -- isLootbox
    net.Send(ply)
end

-- Модель/скин/наполнение. Вызывается при создании сущности и повторно при
-- открытии: хуки создания не гарантируют порядок загрузки аддонов.
-- Модели лутбоксов живут в workshop-контенте. Путь к модели реплицируется строкой,
-- поэтому клиент отрисует модель, даже если сервер её не видит: подменять путь на
-- сервере нельзя, только предупредить в консоли.
local warnedAboutModel = false

local function EnsureLootbox(ent)
    if not IsLootbox(ent) then return end

    local tbl = scripted_ents.GetStored(ent:GetClass()) or {}

    if not ent.LootModelDone and tbl.NameModel then
        if not util.IsValidModel(tbl.NameModel) and not warnedAboutModel then
            warnedAboutModel = true
            print("[Lootbox] Сервер не видит модель " .. tbl.NameModel ..
                " (workshop-контент не смонтирован на сервере). Путь всё равно уходит клиенту," ..
                " модель отрисуется у игроков, у кого контент есть.")
        end

        ent:SetModel(tbl.NameModel)
        ent.LootModelDone = true
    end

    -- NetworkVar даёт доступ через Get/Set, прямого поля ent.LootSkin не существует
    if not ent.LootSkinDone and tbl.NumberSkin then
        ent.LootSkinDone = true
        if ent.SetLootSkin then ent:SetLootSkin(tbl.NumberSkin) end
        ent:SetSkin(tbl.NumberSkin)
    end

    if ent.LootNextUse == nil then ent.LootNextUse = 0 end

    if not ent.LootGenerated then GenerateLoot(ent) end
end

-- OnEntityCreated — единственный хук создания сущности, который движок реально
-- вызывает: строк OnEntityCreatedPostInit и EntityInitialized нет в lua_shared.dll,
-- поэтому хук на них не срабатывал ни разу. Отложен на кадр, чтобы SetupDataTables
-- успел создать аксессоры SetLootSkin.
hook.Add("OnEntityCreated", "Lootbox_Created", function(ent)
    if not IsLootbox(ent) then return end

    timer.Simple(0, function()
        if IsValid(ent) then EnsureLootbox(ent) end
    end)
end)

-- Единая точка открытия. Её вызывают ENT:Use (движок зовёт его сам — надёжнее
-- хука) и хук PlayerUse.
function ORP_Lootbox_Use(box, ply)
    if not IsLootbox(box) then return false end
    if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return false end

    local now = CurTime()
    if box.LootNextUse and now < box.LootNextUse then return false end
    box.LootNextUse = now + USE_COOLDOWN

    if ply:GetPos():DistToSqr(box:GetPos()) > (MAX_USE_DISTANCE ^ 2) then return false end

    EnsureLootbox(box)
    OpenLootbox(ply, box)

    return true
end

-- PlayerUse передаёт сущность, но в части сборок вторым аргументом идёт трейс —
-- поддерживаем оба варианта.
hook.Add("PlayerUse", "Lootbox_PlayerUse", function(ply, ent)
    local box = IsEntity(ent) and ent or (istable(ent) and ent.Entity) or nil
    if not IsLootbox(box) then return end

    ORP_Lootbox_Use(box, ply)
end)

-- Раздача предмета. Возвращает true либо false и причину отказа: молчаливый
-- отказ выглядел для игрока как «кнопка не работает».
local function GiveLootItem(ply, class)
    -- Броня JMod
    if string.StartWith(class, "ent_jack_gmod_ezarmor_") then
        if not (JMod and JMod.ArmorTable and JMod.EZ_Equip_Armor) then
            return false, "JMod с бронёй не загружен"
        end

        local armorName = ArmorNameOf(class)
        local armorInfo = JMod.ArmorTable[armorName]
        if not armorInfo then
            return false, "брони " .. armorName .. " нет в JMod.ArmorTable"
        end

        local ok, err = pcall(JMod.EZ_Equip_Armor, ply, armorName)
        if not ok then
            print("[Lootbox] EZ_Equip_Armor(" .. armorName .. ") упал: " .. tostring(err))
            return false, "JMod не смог надеть " .. armorName
        end

        return true
    end

    -- Оружие и еда (еда в этом пакете — тоже SWEP-ы)
    local wep = weapons.Get(class) or weapons.GetStored(class)
    if not wep then return false, "SWEP " .. class .. " не зарегистрирован" end

    -- Уже есть — просто не берётся, без сообщений в чат.
    if ply:HasWeapon(class) then return false, "уже есть", true end
    if not ply:Give(class) then return false, "движок не смог выдать " .. class end

    -- ВАЖНО: всё после выдачи — в pcall. У еды и медицины Primary.Ammo = "none",
    -- а AddAmmo("none", N) валит обработчик; раньше это обрывало выдачу уже
    -- ПОСЛЕ ply:Give: предмет был у игрока, но из контейнера не исчезал, а
    -- повторная попытка отвечала «уже есть».
    local ammo = wep.Primary and wep.Primary.Ammo
    if ammo and ammo ~= -1 and string.lower(tostring(ammo)) ~= "none" then
        local okAmmo, errAmmo = pcall(ply.AddAmmo, ply, ammo, wep.Primary.DefaultClip or 30)
        if not okAmmo then
            print("[Lootbox] AddAmmo(" .. tostring(ammo) .. ") упал: " .. tostring(errAmmo))
        end
    end

    return true
end

-- Забрать предмет из контейнера. Вынесено в глобальную функцию, чтобы вызов не
-- был зашит в сетевой обработчик: иначе путь выдачи нельзя ни переиспользовать,
-- ни проверить без живого клиента.
function ORP_Lootbox_Take(ply, box, class, isLootbox)
    -- трупы обрабатываются отдельно, тут только контейнеры
    if not isLootbox then return false, "это не контейнер" end
    if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return false, "игрок не готов" end
    if not IsLootbox(box) then return false, "контейнер не найден" end

    if ply:GetPos():DistToSqr(box:GetPos()) > (MAX_USE_DISTANCE ^ 2) then
        return false, "слишком далеко от контейнера"
    end

    local index
    for i, item in pairs(box.LootItems or {}) do
        if item.class == class then index = i break end
    end

    if not index then return false, "предмета уже нет в контейнере" end

    local callOk, ok, why, silent = pcall(GiveLootItem, ply, class)

    if not callOk then
        print("[Lootbox] выдача " .. tostring(class) .. " упала: " .. tostring(ok))

        -- Ошибка могла случиться уже после ply:Give. Если предмет у игрока —
        -- убираем его из контейнера, иначе его «возьмут» повторно.
        local gotIt = not string.StartWith(class, "ent_jack_gmod_ezarmor_") and ply:HasWeapon(class)
        if not gotIt then
            return false, "ошибка выдачи " .. tostring(class)
        end
    elseif not ok then
        return false, why, silent
    end

    -- Ячейки не сдвигаем: забранный предмет оставляет пустое место на своём слоте.
    -- table.remove() двигал бы оставшиеся предметы влево, и окно перестраивалось.
    box.LootItems[index] = nil

    -- Контейнер опустел — убираем его с карты. Окно у игрока закроется само:
    -- owner перестанет быть валидным.
    if CountLoot(box) == 0 then
        box:Remove()
        return true
    end

    -- список на сервере — источник истины, клиенту уходит актуальный
    if IsValid(box.LootOpener) then
        OpenLootbox(box.LootOpener, box)
    end

    return true
end

net.Receive("LootInventory_TakeItem", function(_, ply)
    local box = net.ReadEntity()
    local class = net.ReadString()
    local isLootbox = net.ReadBool()

    local ok, why, silent = ORP_Lootbox_Take(ply, box, class, isLootbox)
    if ok then return end

    print("[Lootbox] отказ (" .. tostring(class) .. "): " .. tostring(why))

    -- «уже есть» — ожидаемый случай, игроку текст ни к чему: предмет просто
    -- остаётся в контейнере. Остальные причины показываем, иначе отказ выглядит
    -- как сломанная кнопка.
    if IsValid(ply) and not silent then
        ply:PrintMessage(HUD_PRINTTALK, "[Контейнер] " .. tostring(why))
    end

    -- после отказа тоже синхронизируем список, чтобы слоты не разъезжались
    if IsLootbox(box) and IsValid(box.LootOpener) then
        OpenLootbox(box.LootOpener, box)
    end
end)