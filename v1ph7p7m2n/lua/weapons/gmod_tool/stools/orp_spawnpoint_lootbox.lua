--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/lua/weapons/gmod_tool/stools/orp_spawnpoint_lootbox.lua <
    > Callstack: gamemodes/sandbox/entities/weapons/gmod_tool/stool.lua:159
[C]:-1
gamemodes/sandbox/entities/weapons/gmod_tool/shared.lua:389
[C]:-1
gamemodes/sandbox/entities/weapons/gmod_tool/cl_init.lua:11 <
]]

TOOL.Category = "Режимы"
TOOL.PrintName = "Loot Point"
TOOL.Author = "Admin"

TOOL.ClientConVar["type"] = "ent_lootbox_base"

-- Глобальная таблица для хранения точек спавна контейнеров
ORP_Lootbox_Spawnpoints = ORP_Lootbox_Spawnpoints or {}

local function GetDir()
    return "zs_spawnpoint_lootboxes/" .. game.GetMap()
end

local function GetFilePath()
    return GetDir() .. "/spawns.json"
end

if SERVER then
    util.AddNetworkString("orp_sync_lootbox_spawns")

    function TOOL:SavePoints()
        if table.IsEmpty(ORP_Lootbox_Spawnpoints) then
            if file.Exists(GetFilePath(), "DATA") then
                file.Delete(GetFilePath())
            end
            -- Удаляем папку карты, если точек нет
            file.Delete(GetDir()) 
        else
            if not file.Exists(GetDir(), "DATA") then
                file.CreateDir(GetDir())
            end
            file.Write(GetFilePath(), util.TableToJSON(ORP_Lootbox_Spawnpoints, true))
        end
        
        self:SyncPoints()
    end

    function TOOL:LoadPoints()
        if file.Exists(GetFilePath(), "DATA") then
            ORP_Lootbox_Spawnpoints = util.JSONToTable(file.Read(GetFilePath(), "DATA")) or {}
        else
            ORP_Lootbox_Spawnpoints = {}
        end
        self:SyncPoints()
    end

    function TOOL:SyncPoints(ply)
        net.Start("orp_sync_lootbox_spawns")
        net.WriteTable(ORP_Lootbox_Spawnpoints)
        if ply then 
            net.Send(ply) 
        else 
            net.Broadcast() 
        end
    end

    -- Загружаем точки при инициализации карты
    hook.Add("Initialize", "ORP_InitLootboxSpawns", function()
        if file.Exists(GetFilePath(), "DATA") then
            ORP_Lootbox_Spawnpoints = util.JSONToTable(file.Read(GetFilePath(), "DATA")) or {}
        end
    end)

    hook.Add("PlayerInitialSpawn", "ORP_SendLootboxSpawnsToClient", function(ply)
        timer.Simple(1, function()
            if IsValid(ply) then
                net.Start("orp_sync_lootbox_spawns")
                net.WriteTable(ORP_Lootbox_Spawnpoints)
                net.Send(ply)
            end
        end)
    end)

    -- Глобальная функция для вызова спавна контейнеров
    function lootboxes_spawn()
        if not ORP_Lootbox_Spawnpoints or table.IsEmpty(ORP_Lootbox_Spawnpoints) then return end
        
        local mins, maxs = Vector(-16, -16, 0), Vector(16, 16, 72)
        
        for _, pt in ipairs(ORP_Lootbox_Spawnpoints) do
            local is_occupied = false
            local box_class = pt.type or "ent_lootbox_base"
            
            -- Проверяем, есть ли уже контейнер НА ЭТОЙ ТОЧКЕ (любого типа)
            for _, ent in ipairs(ents.FindInBox(pt.pos + mins, pt.pos + maxs)) do
                if IsValid(ent) and string.match(ent:GetClass(), "ent_lootbox") then
                    is_occupied = true
                    break
                end
            end
            
            -- Если место свободно, создаем контейнер нужного типа
            if not is_occupied then
                local lootbox = ents.Create(box_class)
                if IsValid(lootbox) then
                    lootbox:SetPos(pt.pos)
                    lootbox:Spawn()
                end
            end
        end
        --print("[ORP] Спавн контейнеров завершен.")
    end
end

if CLIENT then
    net.Receive("orp_sync_lootbox_spawns", function()
        ORP_Lootbox_Spawnpoints = net.ReadTable()
    end)

    language.Add("tool.orp_spawnpoint_lootbox.name", "Точки контейнеров")
    language.Add("tool.orp_spawnpoint_lootbox.desc", "Установка точек для спавна контейнеров")
    language.Add("tool.orp_spawnpoint_lootbox.0", "ЛКМ: Создать | ПКМ: Удалить ближайшую | R: Перезагрузить")

    local type_colors = {
        ent_lootbox_base = Color(139, 69, 19),
        ent_lootbox_armed = Color(255, 69, 0),
        ent_lootbox_random = Color(148, 0, 211),
        ent_lootbox_food = Color(255, 105, 242),
        ent_lootbox_melee = Color(253, 1, 1),
    }

    local type_names = {
        ent_lootbox_base = "Обычный",
        ent_lootbox_armed = "Вооруженный",
        ent_lootbox_random = "Random",
        ent_lootbox_food = "Еда",
        ent_lootbox_melee = "Холодное оружие",
    }

    hook.Add("PostDrawOpaqueRenderables", "ORP_DrawLootboxSpawnpoints", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "gmod_tool" then return end
        if ply:GetInfo("gmod_toolmode") ~= "orp_spawnpoint_lootbox" then return end

        local counters = {}
        local mins = Vector(-16, -16, 0)
        local maxs = Vector(16, 16, 72)

        for _, pt in ipairs(ORP_Lootbox_Spawnpoints) do
            local class_name = pt.type or "ent_lootbox_base"
            local col = type_colors[class_name] or color_white
            local readable_name = type_names[class_name] or class_name
            
            counters[class_name] = (counters[class_name] or 0) + 1
            local text = readable_name .. " - #" .. counters[class_name]

            render.DrawWireframeBox(pt.pos, Angle(0,0,0), mins, maxs, col, true)
            
            -- Отрисовка текста, который всегда поворачивается лицом к игроку
            local ang = ply:EyeAngles()
            ang:RotateAroundAxis(ang:Forward(), 90)
            ang:RotateAroundAxis(ang:Right(), 90)
            
            cam.Start3D2D(pt.pos + Vector(0, 0, 80), ang, 0.2)
                draw.SimpleText(text, "DermaLarge", 0, 0, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            cam.End3D2D()
        end
    end)

    function TOOL.BuildCPanel(panel)
        panel:AddControl("Header", { 
            Description = "Настройка типа точки лута (Loot Point)." 
        })
        
        local combo = panel:ComboBox("Тип лута", "orp_spawnpoint_lootbox_type")
        combo:AddChoice("Random (Случайный)", "ent_lootbox_random")
        combo:AddChoice("Обычный", "ent_lootbox_base")
        combo:AddChoice("Вооруженный", "ent_lootbox_armed")
        combo:AddChoice("Еда", "ent_lootbox_food")
        combo:AddChoice("Холодное оружие", "ent_lootbox_melee")
    end
end

function TOOL:LeftClick(tr)
    if CLIENT then return true end

    if not self:GetOwner():IsSuperAdmin() then return end
    
    local pos = tr.HitPos
    local pType = self:GetClientInfo("type")
    
    table.insert(ORP_Lootbox_Spawnpoints, { pos = pos, type = pType })
    self:SavePoints()
    
    self:GetOwner():ChatPrint("Точка для контейнера [" .. pType .. "] успешно установлена.")
    return true
end

function TOOL:RightClick(tr)
    if CLIENT then return true end

    if not self:GetOwner():IsSuperAdmin() then return end
    
    local pos = tr.HitPos
    local closest_idx = -1
    local min_dist = 10000
    
    for k, v in ipairs(ORP_Lootbox_Spawnpoints) do
        local dist = v.pos:Distance(pos)
        if dist < 100 and dist < min_dist then
            min_dist = dist
            closest_idx = k
        end
    end
    
    if closest_idx ~= -1 then
        table.remove(ORP_Lootbox_Spawnpoints, closest_idx)
        self:SavePoints()
        self:GetOwner():ChatPrint("Ближайшая точка удалена.")
    else
        self:GetOwner():ChatPrint("Рядом нет точек для удаления.")
    end
    
    return true
end

function TOOL:Reload(tr)
    if CLIENT then return true end
    
    self:LoadPoints()
    self:GetOwner():ChatPrint("Точки спавна контейнеров принудительно загружены из файла .json.")
    
    return true
end
