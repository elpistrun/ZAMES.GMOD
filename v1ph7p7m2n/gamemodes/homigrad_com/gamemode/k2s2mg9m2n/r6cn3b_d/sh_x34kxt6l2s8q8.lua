--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/r6cn3b_d/sh_x34kxt6l2s8q8.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:26
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

local meta = FindMetaTable("Player")

-- get valute
function meta:GetCFC()
    return self:GetNWInt("CFC", 0)
end

function meta:GetGFC()
    return self:GetNWInt("GFC", 0)
end

-- set
function meta:SetCFC(amount)
    self:SetNWInt("CFC", math.floor(tonumber(amount) or 0))
    if SERVER then SavePlayerCurrency(self) end
end

function meta:SetGFC(amount)
    self:SetNWInt("GFC", math.floor(tonumber(amount) or 0))
    if SERVER then SavePlayerCurrency(self) end
end

-- add
function meta:AddCFC(amount)
    local amt = math.floor(tonumber(amount) or 0)
    self:SetCFC(self:GetCFC() + amt)
    
    if SERVER then
        net.Start("CurrencyAddedAnim")
        net.WriteString("CFC")
        net.WriteInt(amt, 32)
        net.Send(self)
    end
end

function meta:AddGFC(amount)
    local amt = math.floor(tonumber(amount) or 0)
    self:SetGFC(self:GetGFC() + amt)
    
    if SERVER then
        net.Start("CurrencyAddedAnim")
        net.WriteString("GFC")
        net.WriteInt(amt, 32)
        net.Send(self)
    end
end

if SERVER then
    _G.SavePlayerCurrency = function(ply)
        if SavePlayerData then
            SavePlayerData(ply)
        end
    end

    local function FindTargetPlayers(callingPly, targetStr)
        if not targetStr or targetStr == "" then return {} end
        targetStr = string.Trim(targetStr)

        if targetStr == "*" then
            return player.GetAll()
        elseif targetStr == "^" then
            return (IsValid(callingPly) and {callingPly}) or {}
        end

        local lowerTarget = string.lower(targetStr)
        local found = {}

        for _, ply in player.Iterator() do
            if string.find(string.lower(ply:Nick()), lowerTarget, 1, true)
                or ply:SteamID() == targetStr
                or ply:SteamID64() == targetStr then
                table.insert(found, ply)
            end
        end

        return found
    end

    local function HandleGiveCurrency(callingPly, cmd, args, curType)
        if IsValid(callingPly) and not callingPly:IsSuperAdmin() then
            callingPly:ChatPrint("[Валюта] У вас нет прав для выполнения этой команды!")
            return
        end

        local targetStr = args[1]
        local amount = tonumber(args[2])

        if not targetStr or not amount then
            local usage = "Использование: " .. cmd .. " <имя / * / ^> <кол-во>"
            if IsValid(callingPly) then
                callingPly:ChatPrint(usage)
            else
                print(usage)
            end
            return
        end

        amount = math.floor(amount)
        if amount <= 0 then
            local msg = "[Валюта] Количество должно быть больше 0!"
            if IsValid(callingPly) then callingPly:ChatPrint(msg) else print(msg) end
            return
        end

        local targets = FindTargetPlayers(callingPly, targetStr)

        if #targets == 0 then
            local msg = "[Валюта] Игрок не найден: " .. targetStr
            if IsValid(callingPly) then callingPly:ChatPrint(msg) else print(msg) end
            return
        end

        for _, ply in ipairs(targets) do
            if curType == "CFC" then
                ply:AddCFC(amount)
            elseif curType == "GFC" then
                ply:AddGFC(amount)
            end
        end
    end

    concommand.Add("give_chc", function(ply, cmd, args)
        HandleGiveCurrency(ply, cmd, args, "CFC")
    end)

    concommand.Add("give_ghc", function(ply, cmd, args)
        HandleGiveCurrency(ply, cmd, args, "GFC")
    end)

    -- Алиасы для совместимости
    concommand.Add("give_cfc", function(ply, cmd, args)
        HandleGiveCurrency(ply, cmd, args, "CFC")
    end)

    concommand.Add("give_gfc", function(ply, cmd, args)
        HandleGiveCurrency(ply, cmd, args, "GFC")
    end)
end
