--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/lua/weapons/gmod_tool/stools/orp_spawnpoint.lua <
    > Callstack: gamemodes/sandbox/entities/weapons/gmod_tool/stool.lua:159
[C]:-1
gamemodes/sandbox/entities/weapons/gmod_tool/shared.lua:389
[C]:-1
gamemodes/sandbox/entities/weapons/gmod_tool/cl_init.lua:11 <
]]

TOOL.Category = "Режимы"
TOOL.PrintName = "Spawn Point"
TOOL.Author = "Admin"

TOOL.ClientConVar["type"] = "hmcd"

ORP_Spawnpoints = ORP_Spawnpoints or {}

local function GetDir()
    return "zs_spawnpoint/" .. game.GetMap()
end

local function GetFilePath()
    return GetDir() .. "/spawns.json"
end

if SERVER then
    util.AddNetworkString("orp_sync_spawns")
    util.AddNetworkString("orp_create_zona_point")

    function TOOL:SavePoints()
        if table.IsEmpty(ORP_Spawnpoints) then
            if file.Exists(GetFilePath(), "DATA") then
                file.Delete(GetFilePath())
            end
            file.Delete(GetDir()) 
        else
            if not file.Exists(GetDir(), "DATA") then
                file.CreateDir(GetDir())
            end
            file.Write(GetFilePath(), util.TableToJSON(ORP_Spawnpoints, true))
        end
        
        self:SyncPoints()
    end

    function TOOL:LoadPoints()
        if file.Exists(GetFilePath(), "DATA") then
            ORP_Spawnpoints = util.JSONToTable(file.Read(GetFilePath(), "DATA")) or {}
        else
            ORP_Spawnpoints = {}
        end
        self:SyncPoints()
    end

    function TOOL:SyncPoints(ply)
        net.Start("orp_sync_spawns")
        net.WriteTable(ORP_Spawnpoints)
        if ply then 
            net.Send(ply) 
        else 
            net.Broadcast() 
        end
    end

    hook.Add("Initialize", "ORP_InitSpawns", function()
        if file.Exists(GetFilePath(), "DATA") then
            ORP_Spawnpoints = util.JSONToTable(file.Read(GetFilePath(), "DATA")) or {}
        end
    end)

    hook.Add("PlayerInitialSpawn", "ORP_SendSpawnsToClient", function(ply)
        timer.Simple(1, function()
            if IsValid(ply) then
                net.Start("orp_sync_spawns")
                net.WriteTable(ORP_Spawnpoints)
                net.Send(ply)
            end
        end)
    end)

    local function IsSpawnOccupied(pos)
        local mins, maxs = Vector(-16, -16, 0), Vector(16, 16, 72)
        for _, ent in ipairs(ents.FindInBox(pos + mins, pos + maxs)) do
            if ent:IsPlayer() and ent:Alive() then
                return true
            end
        end
        return false
    end

    local ORP_DummySpawn = NULL

    hook.Add("PlayerSelectSpawn", "ORP_CustomSpawnLogic", function(ply)
        if ply.IsExitingFake then return end 
        
        if ply.JustUseCommandRespawn then 
            return
        end
        
        local round = zs.current_round
        local pTeam = ply:Team()
        
        local valid_spawns = {}
        
        for _, pt in ipairs(ORP_Spawnpoints) do
            local is_valid = false
            
            if round == "hmcd" then 
                if (pTeam == 1 or pTeam == 3) and (pt.type == "hmcd" or pt.type == "default") then 
                    is_valid = true
                end
            elseif round == "dm" then
                if pt.type == "dm" or pt.type == "hmcd" or pt.type == "default" then
                    is_valid = true
                end
            elseif round == "tdm" then
                if (pTeam == 1 or pTeam == 3) and (pt.type == "tdm_blue" or pt.type == "blue" or pt.type == "tdm") then 
                    is_valid = true
                elseif pTeam == 2 and (pt.type == "tdm_red" or pt.type == "red" or pt.type == "tdm") then 
                    is_valid = true
                end
            elseif round == "riot" then
                if (pTeam == 1 or pTeam == 3) and (pt.type == "riot_blue" or pt.type == "blue" or pt.type == "riot") then 
                    is_valid = true
                elseif pTeam == 2 and (pt.type == "riot_red" or pt.type == "red" or pt.type == "riot") then 
                    is_valid = true
                end
            elseif round == "hunter" then
                if (pTeam == 1 or pTeam == 3) and (pt.type == "hunter_blue" or pt.type == "blue" or pt.type == "hunter") then 
                    is_valid = true
                elseif pTeam == 2 and (pt.type == "hunter_red" or pt.type == "red" or pt.type == "hunter") then 
                    is_valid = true
                end
            elseif round == "hl2dm" then
                if (pTeam == 1 or pTeam == 3) and (pt.type == "hl2dm_blue" or pt.type == "blue" or pt.type == "hl2dm") then 
                    is_valid = true
                elseif pTeam == 2 and (pt.type == "hl2dm_red" or pt.type == "red" or pt.type == "hl2dm") then 
                    is_valid = true
                end
            else
                if pt.type == "hmcd" or pt.type == "default" then
                    is_valid = true
                end
            end
            
            if is_valid then 
                table.insert(valid_spawns, pt) 
            end
        end
        
        if #valid_spawns > 0 then
            local free_spawns = {}
            
            for _, pt in ipairs(valid_spawns) do
                if not IsSpawnOccupied(pt.pos) then
                    table.insert(free_spawns, pt)
                end
            end
            
            local chosen = #free_spawns > 0 and free_spawns[math.random(#free_spawns)] or valid_spawns[math.random(#valid_spawns)]
            
            if not IsValid(ORP_DummySpawn) then
                ORP_DummySpawn = ents.Create("info_target")
                ORP_DummySpawn:Spawn()
            end
            
            ORP_DummySpawn:SetPos(chosen.pos)
            return ORP_DummySpawn
        end
    end)

    net.Receive("orp_create_zona_point", function(len, ply)
        if not ply:IsSuperAdmin() then return end
        
        local pos = net.ReadVector()
        local radius = net.ReadFloat()
        
        table.insert(ORP_Spawnpoints, { pos = pos, type = "zona", radius = radius })
        
        local tool = ply:GetWeapon("gmod_tool")
        if IsValid(tool) and tool.GetToolObject then
            local orp_tool = tool:GetToolObject("orp_spawnpoint")
            if orp_tool then
                orp_tool:SavePoints()
                ply:ChatPrint("Зона (Радиус: " .. radius .. ") успешно сохранена.")
            end
        end
    end)
end

if CLIENT then
    net.Receive("orp_sync_spawns", function()
        ORP_Spawnpoints = net.ReadTable()
    end)

    language.Add("tool.orp_spawnpoint.name", "Точки спавна")
    language.Add("tool.orp_spawnpoint.desc", "Установка спавнов для режимов")
    language.Add("tool.orp_spawnpoint.0", "ЛКМ: Создать | ПКМ: Удалить ближайшую | R: Перезагрузить")

    local type_colors = {
        hmcd = Color(255, 255, 255),
        dm = Color(255, 165, 0),
        tdm = Color(100, 149, 237),
        tdm_red = Color(255, 50, 50),
        tdm_blue = Color(50, 100, 255),
        riot = Color(220, 20, 60),
        riot_red = Color(255, 50, 50),
        riot_blue = Color(50, 100, 255),
        hunter = Color(50, 205, 50),
        hunter_red = Color(255, 50, 50),
        hunter_blue = Color(50, 100, 255),
        hl2dm = Color(255, 215, 0),
        hl2dm_red = Color(255, 50, 50),
        hl2dm_blue = Color(50, 100, 255),
        red = Color(255, 0, 0),
        blue = Color(0, 0, 255),
        zona = Color(0, 255, 0)
    }

    hook.Add("PostDrawOpaqueRenderables", "ORP_DrawSpawnpoints", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "gmod_tool" then return end
        if ply:GetInfo("gmod_toolmode") ~= "orp_spawnpoint" then return end

        local counters = {}
        local mins = Vector(-16, -16, 0)
        local maxs = Vector(16, 16, 72)

        for _, pt in ipairs(ORP_Spawnpoints) do
            local pType = pt.type or "hmcd"
            local col = type_colors[pType] or color_white
            counters[pType] = (counters[pType] or 0) + 1
            local text = string.upper(pType) .. " - #" .. counters[pType]

            if pType == "zona" and pt.radius then
                text = text .. " (R: " .. pt.radius .. ")"
                render.DrawWireframeSphere(pt.pos, pt.radius, 16, 16, col, true)
            else
                render.DrawWireframeBox(pt.pos, Angle(0,0,0), mins, maxs, col, true)
            end
            
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
            Description = "Настройка точки возрождения (Spawn Point) по режимам." 
        })
        
        local combo = panel:ComboBox("Режим / Тип точки", "orp_spawnpoint_type")
        combo:AddChoice("Homicide (HMCD)", "hmcd")
        combo:AddChoice("Deathmatch (DM)", "dm")
        combo:AddChoice("TDM - Синие (Blue)", "tdm_blue")
        combo:AddChoice("TDM - Красные (Red)", "tdm_red")
        combo:AddChoice("RIOT - Спецназ (Blue)", "riot_blue")
        combo:AddChoice("RIOT - Бунтовщики (Red)", "riot_red")
        combo:AddChoice("Hunter - Охотники (Blue)", "hunter_blue")
        combo:AddChoice("Hunter - Жертвы (Red)", "hunter_red")
        combo:AddChoice("HL2DM - Сопротивление (Blue)", "hl2dm_blue")
        combo:AddChoice("HL2DM - Альянс (Red)", "hl2dm_red")
        combo:AddChoice("Зона (Радиус)", "zona")
    end
end

function TOOL:LeftClick(tr)
    local pType = self:GetClientInfo("type")

    if pType == "zona" then
        if CLIENT then
            local frame = vgui.Create("DFrame")
            frame:SetTitle("Настройка Зоны")
            frame:SetSize(300, 110)
            frame:Center()
            frame:MakePopup()

            local label = vgui.Create("DLabel", frame)
            label:SetPos(15, 35)
            label:SetText("Введите радиус зоны:")
            label:SizeToContents()

            local textEntry = vgui.Create("DTextEntry", frame)
            textEntry:SetPos(15, 55)
            textEntry:SetSize(270, 20)
            textEntry:SetNumeric(true)
            textEntry:SetValue("1000")

            local btn = vgui.Create("DButton", frame)
            btn:SetPos(15, 80)
            btn:SetSize(270, 20)
            btn:SetText("Установить точку")
            btn.DoClick = function()
                local radius = tonumber(textEntry:GetValue()) or 1000
                net.Start("orp_create_zona_point")
                    net.WriteVector(tr.HitPos)
                    net.WriteFloat(radius)
                net.SendToServer()
                frame:Close()
            end
        end
        return true 
    end

    if CLIENT then return true end

    if not self:GetOwner():IsSuperAdmin() then return end
    
    local pos = tr.HitPos
    
    table.insert(ORP_Spawnpoints, { pos = pos, type = pType })
    self:SavePoints()
    
    self:GetOwner():ChatPrint("Точка типа " .. pType .. " успешно установлена.")
    return true
end

function TOOL:RightClick(tr)
    if CLIENT then return true end

    if not self:GetOwner():IsSuperAdmin() then return end
    
    local pos = tr.HitPos
    local closest_idx = -1
    local min_dist = 10000
    
    for k, v in ipairs(ORP_Spawnpoints) do
        local dist = v.pos:Distance(pos)
        if dist < 100 and dist < min_dist then
            min_dist = dist
            closest_idx = k
        end
    end
    
    if closest_idx ~= -1 then
        table.remove(ORP_Spawnpoints, closest_idx)
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
    self:GetOwner():ChatPrint("Точки спавна принудительно загружены из файла .json.")
    
    return true
end
