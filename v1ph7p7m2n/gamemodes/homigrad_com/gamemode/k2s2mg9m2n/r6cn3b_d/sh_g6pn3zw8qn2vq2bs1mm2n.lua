--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/r6cn3b_d/sh_g6pn3zw8qn2vq2bs1mm2n.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:26
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]


local meta = FindMetaTable("Player")

function meta:GetPlayTimeSeconds()
    local sessionStart = self:GetNWFloat("SessionStartTime", 0)
    if sessionStart == 0 then return self:GetNWInt("TotalPlaytime", 0) end
    
    return math.floor(self:GetNWInt("TotalPlaytime", 0) + (CurTime() - sessionStart))
end

function meta:GetPlayTimeHours()
    return math.Round(self:GetPlayTimeSeconds() / 3600, 2)
end

function meta:GetFirstJoinDate()
    local date = self:GetNWString("FirstJoinDate", "")
    return date ~= "" and date or "Неизвестно"
end

if SERVER then
    file.CreateDir("zs_players")

    local function GetPlayerFilePath(ply)
        local sid64 = ply:SteamID64()
        if not sid64 then return nil end
        return "zs_players/" .. sid64 .. ".json"
    end

    local function LoadPlayerData(ply)
        local path = GetPlayerFilePath(ply)
        if not path then return end

        local data = {}
        if file.Exists(path, "DATA") then
            local raw = file.Read(path, "DATA")
            data = util.JSONToTable(raw) or {}
        end

        local totalPlaytime = tonumber(data.playtime) or 0
        local firstJoin = data.firstjoin or os.date("%d.%m.%Y %H:%M")
        local cfc = tonumber(data.cfc) or 0
        local gfc = tonumber(data.gfc) or 0

        ply:SetNWInt("TotalPlaytime", totalPlaytime)
        ply:SetNWFloat("SessionStartTime", CurTime())
        ply:SetNWString("FirstJoinDate", firstJoin)
        ply:SetNWInt("CFC", cfc)
        ply:SetNWInt("GFC", gfc)

        ply.Inventory = data.inventory or {}
        if ply.SyncInventory then
            ply:SyncInventory()
        end

        local equip = data.equip or {}
        if equip.voice_figure and equip.voice_figure ~= "" then
            ply:SetNWString("VoiceFigure", equip.voice_figure)
            ply.EquippedVoiceFigure = equip.voice_figure_item
        end
        if equip.voice_bg and equip.voice_bg ~= "" then
            ply:SetNWString("VoiceBG", equip.voice_bg)
            ply.EquippedVoiceBG = equip.voice_bg_item
        end
        if equip.tab_bg and equip.tab_bg ~= "" then
            ply:SetNWString("TabBG", equip.tab_bg)
            ply.EquippedTabBG = equip.tab_bg_item
        end
        if equip.custom_skin and equip.custom_skin ~= "" and util.IsValidModel(equip.custom_skin) then
            ply:SetNWString("CustomPlayerModel", equip.custom_skin)
            ply.EquipCustomSkin = equip.custom_skin
            ply.EquipCustomSkinName = equip.custom_skin_name
        end

        ply.ZS_PlaytimeData = data
        ply.ZS_PlaytimeData.playtime = totalPlaytime
        ply.ZS_PlaytimeData.firstjoin = firstJoin
        ply.ZS_PlaytimeData.name = ply:Nick()
        ply.ZS_PlaytimeData.cfc = cfc
        ply.ZS_PlaytimeData.gfc = gfc
        ply.ZS_PlaytimeData.inventory = ply.Inventory
        ply.ZS_PlaytimeData.equip = equip
    end

    local function SavePlayerData(ply)
        if not IsValid(ply) or ply:IsBot() then return end
        local path = GetPlayerFilePath(ply)
        if not path then return end

        local curSeconds = ply:GetPlayTimeSeconds()
        local data = ply.ZS_PlaytimeData or {}

        data.playtime = curSeconds
        data.firstjoin = ply:GetFirstJoinDate()
        data.name = ply:Nick()
        data.cfc = ply:GetNWInt("CFC", 0)
        data.gfc = ply:GetNWInt("GFC", 0)
        data.inventory = ply:GetInventory()
        data.equip = data.equip or {}
        data.equip.voice_figure = ply:GetNWString("VoiceFigure", "")
        data.equip.voice_figure_item = ply.EquippedVoiceFigure or ""
        data.equip.voice_bg = ply:GetNWString("VoiceBG", "")
        data.equip.voice_bg_item = ply.EquippedVoiceBG or ""
        data.equip.tab_bg = ply:GetNWString("TabBG", "")
        data.equip.tab_bg_item = ply.EquippedTabBG or ""
        data.equip.custom_skin = ply:GetNWString("CustomPlayerModel", "")
        data.equip.custom_skin_name = ply.EquipCustomSkinName or ""

        ply.ZS_PlaytimeData = data
        file.Write(path, util.TableToJSON(data, true))
    end

    _G.SavePlayerData = SavePlayerData
    _G.SavePlayerInventory = SavePlayerData

    hook.Add("PlayerInitialSpawn", "ZS_TrackPlayTime_Init", function(ply)
        LoadPlayerData(ply)

        -- Если игрок не прописан в ULib как админ, строго выставляем user вместо superadmin
        timer.Simple(0.5, function()
            if not IsValid(ply) then return end
            local sid = ply:SteamID()
            local sid64 = ply:SteamID64()
            local ulibUsers = (ULib and ULib.ucl and ULib.ucl.users) or {}
            local hasULibGroup = ulibUsers[sid] or (sid64 and ulibUsers[sid64]) or ulibUsers[ply:UniqueID()]
            if not hasULibGroup then
                ply:SetUserGroup("user")
            end
        end)
    end)

    hook.Add("PlayerDisconnected", "ZS_TrackPlayTime_Disconnect", function(ply)
        SavePlayerData(ply)
    end)

    timer.Create("ZS_SaveAllPlaytime", 60, 0, function()
        for _, ply in player.Iterator() do
            if IsValid(ply) and not ply:IsBot() then
                SavePlayerData(ply)
            end
        end
    end)

    hook.Add("ShutDown", "ZS_SavePlaytime_Shutdown", function()
        for _, ply in player.Iterator() do
            if IsValid(ply) and not ply:IsBot() then
                SavePlayerData(ply)
            end
        end
    end)

    -- Обработчик запроса Топа Сервера
    net.Receive("RequestTopList", function(len, ply)
        if not IsValid(ply) then return end
        local categoryName = net.ReadString() or "Топ по часам"

        -- Сохраняем текущих игроков перед генерацией топа
        for _, p in player.Iterator() do
            if IsValid(p) and not p:IsBot() then
                SavePlayerData(p)
            end
        end

        local files = file.Find("zs_players/*.json", "DATA")
        local allPlayers = {}

        for _, f in ipairs(files) do
            local sid64 = string.StripExtension(f)
            local content = file.Read("zs_players/" .. f, "DATA")
            if content then
                local data = util.JSONToTable(content)
                if data then
                    local onlinePly = player.GetBySteamID64(sid64)
                    local curPlaytime = (onlinePly and onlinePly.GetPlayTimeSeconds and onlinePly:GetPlayTimeSeconds()) or tonumber(data.playtime) or 0
                    local curCFC = (onlinePly and onlinePly:GetCFC()) or tonumber(data.cfc) or 0
                    local curGFC = (onlinePly and onlinePly:GetGFC()) or tonumber(data.gfc) or 0
                    local curNick = (onlinePly and onlinePly:Nick()) or data.name or "Неизвестно"
                    local curGroup = (onlinePly and onlinePly:GetUserGroup()) or "user"
                    local curSteamID = (onlinePly and onlinePly:SteamID()) or util.SteamIDFrom64(sid64)

                    table.insert(allPlayers, {
                        Nick = curNick,
                        SteamID = curSteamID,
                        SteamID64 = sid64,
                        Playtime = curPlaytime,
                        FirstJoin = data.firstjoin or "Неизвестно",
                        UserGroup = curGroup,
                        CFC = curCFC,
                        GFC = curGFC
                    })
                end
            end
        end

        -- Сортировка по выбранной категории
        if categoryName == "Топ по GHC" then
            table.sort(allPlayers, function(a, b)
                return (a.GFC or 0) > (b.GFC or 0)
            end)
        elseif categoryName == "Топ по CHC" then
            table.sort(allPlayers, function(a, b)
                return (a.CFC or 0) > (b.CFC or 0)
            end)
        else
            -- Топ по часам (по умолчанию)
            table.sort(allPlayers, function(a, b)
                return (a.Playtime or 0) > (b.Playtime or 0)
            end)
        end

        -- Берем топ-50
        local topList = {}
        for i = 1, math.min(#allPlayers, 50) do
            table.insert(topList, allPlayers[i])
        end

        net.Start("ReceiveTopList")
        net.WriteTable(topList)
        net.WriteString(categoryName)
        net.Send(ply)
    end)
end
