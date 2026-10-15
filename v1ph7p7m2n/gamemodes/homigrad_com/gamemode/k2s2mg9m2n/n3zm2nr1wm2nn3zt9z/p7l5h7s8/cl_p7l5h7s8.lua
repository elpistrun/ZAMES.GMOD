--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/n3zm2nr1wm2nn3zt9z/p7l5h7s8/cl_p7l5h7s8.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

dm = dm or {}

DM_StartTime = 0

net.Receive("net_dm_start_time", function()
    DM_StartTime = net.ReadFloat()
end)

function dm.StartSound()
    surface.PlaySound("zames/round/dm.mp3")
end

function dm.HUDPaint(round_start_time)

    local w, h = ScrW(), ScrH()
    local proshlo = CurTime() - round_start_time

    local alpha = math.Clamp(1 - ((proshlo - 5) / 3), 0, 1)

    local role = LocalPlayer():Team()
    local team_data = dm.Teams[role] or { Name = "Неизвестно", Color = color_white, Desc = "Нет задачи" }

    surface.SetDrawColor(0, 0, 0, 225 * alpha)
    surface.DrawRect(0, 0, w, h)

    local bg = ColorAlpha(dm.NameColor, 255 * alpha)
    local tc = ColorAlpha(team_data.Color, 255 * alpha)

    draw.SimpleText(dm.Name, "PT.1", w / 2, h / 8, bg, 1, 4)
    draw.SimpleText("Вы - " .. team_data.Name, "PT.2", w / 2, h / 2, tc, 1, 3)
    draw.SimpleText(team_data.Desc, "PT.3", w / 2, h / 1.2, tc, 1, 1)
end


astBeepTime = -1
battleSoundPlayed = false

hook.Add("HUDPaint", "startime", function()
    if DM_StartTime == 0 then 
        return 
    end

    local w, h = ScrW(), ScrH()
    local timeLeft = math.ceil(DM_StartTime - CurTime())

    if timeLeft > 0 then
        draw.SimpleText(tostring(timeLeft), "PT.1", w / 2, h / 2 + 150, color_white, 1, 1)

        if lastBeepTime ~= timeLeft then
            surface.PlaySound("zames/vgui/click1.wav")
            lastBeepTime = timeLeft
        end

        battleSoundPlayed = false

    elseif timeLeft > -2 then
        draw.SimpleText("В БОЙ!", "PT.1", w / 2, h / 2 + 150, Color(255, 50, 50), 1, 1)

        if not battleSoundPlayed then
            surface.PlaySound("buttons/button15.wav")
            battleSoundPlayed = true
        end
    else
        DM_StartTime = 0
        lastBeepTime = -1
        battleSoundPlayed = false
    end
end)
