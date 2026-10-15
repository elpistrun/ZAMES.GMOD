--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/6ql7yc8mg8rf3pf/sh_6ql7yc8mg8rf3pf.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:26
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

AddCSLuaFile()

guilt = guilt or {}
guilt.Enable = true 

hook.Add("PlayerInitialSpawn", "GiveGuilt", function(ply)
    if IsValid(ply) then
        local savedGuilt = tonumber(ply:GetPData("Guilt_Level", 0))
        ply.guilt = savedGuilt
        ply.roundGuiltGained = 0
        ply:SetNWInt("Guilt", ply.guilt)
    end
end)

hook.Add("PlayerDisconnected", "SaveGuilt", function(ply)
    if IsValid(ply) then
        ply:SetPData("Guilt_Level", ply.guilt)
    end
end)

timer.Create("SaveGuilts", 60, 0, function()
    for _, ply in player.Iterator() do
        ply:SetPData("Guilt_Level", ply.guilt)
    end
end)

-- после рестарта либо выключения
hook.Add("ShutDown", "SaveGuiltOnShutdown", function()
    for _, ply in player.Iterator() do
        if IsValid(ply) and ply.guilt then
            ply:SetPData("Guilt_Level", ply.guilt)
        end
    end
end)

hook.Add("RenderScreenspaceEffects", "GuiltDrunkEffect", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    if not ply:Alive() then return end
    
    local guilt = ply:GetNWInt("Guilt", 0)
    local startThreshold = 150
    
    if guilt > startThreshold then 
        local intensity = math.Clamp((guilt - startThreshold) / (260 - startThreshold), 0, 1)
        DrawMotionBlur(0.1, intensity * 0.8, 0.05)
        DrawToyTown(3 * intensity, ScrH() * 0.5 * intensity)
        
        local wobble = math.sin(CurTime() * 2) * intensity * 0.02
        DrawMaterialOverlay("effects/water_warp01", wobble)
    end
end)
