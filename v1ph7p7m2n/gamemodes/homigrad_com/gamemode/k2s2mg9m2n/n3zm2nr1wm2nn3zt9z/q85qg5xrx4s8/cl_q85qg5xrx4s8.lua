--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/n3zm2nr1wm2nn3zt9z/q85qg5xrx4s8/cl_q85qg5xrx4s8.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

event = event or {}


function event.StartSound()
    surface.PlaySound("zames/round/event.mp3")
end

function event.HUDPaint(round_start_time)

    local w, h = ScrW(), ScrH()
    local proshlo = CurTime() - round_start_time

    local alpha = math.Clamp(1 - ((proshlo - 3) / 3), 0, 1)

    local role = LocalPlayer():Team()
    local team_data = event.Teams[role] or { Name = "Неизвестно", Color = color_white, Desc = "Нет задачи" }

    surface.SetDrawColor(0, 0, 0, 220 * alpha)
    surface.DrawRect(0, 0, w, h)

    local bg = ColorAlpha(event.NameColor, 255 * alpha)
    local tc = ColorAlpha(team_data.Color, 255 * alpha)

    draw.SimpleText(event.Name, "PT.1", w / 2, h / 8, bg, 1, 4)
    draw.SimpleText("Вы - " .. team_data.Name, "PT.2", w / 2, h / 2, tc, 1, 3)
    draw.SimpleText(team_data.Desc, "PT.3", w / 2, h / 1.2, tc, 1, 1)
end
