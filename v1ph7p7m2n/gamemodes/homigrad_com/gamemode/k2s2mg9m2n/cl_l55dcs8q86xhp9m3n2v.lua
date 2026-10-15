--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/cl_l55dcs8q86xhp9m3n2v.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

local ent_names = {
    ["func_door"] = "Открыть",
    ["func_door_rotating"] = "Открыть",
    ["prop_door_rotating"] = "Открыть",
}

local ent_blacklist = {
    ["prop_ragdoll"] = true,
    ["func_breakable_surf"] = true,
    ["func_breakable"] = true,
    ["func_brush"] = true,
    ["player"] = true,
    ["prop_dynamic"] = true,
}

local textAlpha = 0
local currentName = ""
local fadeSpeed = 800

hook.Add("PreDrawHalos", "HoverEntityHalo", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local tr = ply:GetEyeTrace()
    local ent = tr.Entity

    if IsValid(ent) and not ent:IsWorld() and tr.HitPos:Distance(ply:EyePos()) <= 150 and not ent_blacklist[ent:GetClass()] and not string.StartWith(ent:GetClass(), "npc_") and not string.StartWith(ent:GetClass(), "prop_physics") and not string.StartWith(ent:GetClass(), "prop_vehicle") and not string.StartWith(ent:GetClass(), "gtav_") and not string.StartWith(ent:GetClass(), "glide_") then
        halo.Add({ent}, Color(255, 255, 255), 2, 2, 1, true, true)
    end
end)

hook.Add("HUDPaint", "HoverEntityText", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local tr = ply:GetEyeTrace()
    local ent = tr.Entity
    local dist = tr.HitPos:Distance(ply:EyePos())

    if IsValid(ent) and not ent:IsWorld() and dist <= 75 and not ent_blacklist[ent:GetClass()] and not string.StartWith(ent:GetClass(), "npc_") and not string.StartWith(ent:GetClass(), "prop_physics") and not string.StartWith(ent:GetClass(), "prop_vehicle") and not string.StartWith(ent:GetClass(), "gtav_") and not string.StartWith(ent:GetClass(), "glide_") then
        local class = ent:GetClass()
        
        local name = ent_names[class] 
        if not name or name == "" then
            name = ent.PrintName or (ent.GetPrintName and ent:GetPrintName()) or class
        end
        
        currentName = name
        textAlpha = math.Approach(textAlpha, 255, FrameTime() * fadeSpeed)
    else
        textAlpha = math.Approach(textAlpha, 0, FrameTime() * fadeSpeed)
    end

    if textAlpha > 0 and currentName ~= "" then
        local x = ScrW() / 2
        local y = ScrH() / 2 + 50
        
        draw.SimpleText(currentName, "PT.3", x, y, Color(255, 255, 255, textAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end
end)
