--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/n3zm2nr1wm2nn3zt9z/2vt3kh/cl_2vt3kh.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

riot = riot or {}

local riot_materials = {
    main = SetupMat(
        "zames/rounds/riot_police.png",
        "team_anim",
        1.0,
        1450,
        0,
        50,
        "zames/rounds/riot_riots.png",
        -1450,
        0
    )
}

function riot.StartSound()
    surface.PlaySound("zames/round/riot.wav")
end

function riot.HUDPaint(round_start_time)
    local w, h = ScrW(), ScrH()
    local proshlo = CurTime() - round_start_time

    local alpha = math.Clamp(1 - ((proshlo - 5 ) / 3), 0, 1)

    local role = LocalPlayer():Team()
    local team_data = riot.Teams[role] or { Name = "Неизвестно", Color = color_white, Desc = "Нет задачи" }

    surface.SetDrawColor(0, 0, 0, 255 * alpha)
    surface.DrawRect(0, 0, w, h)

    if alpha > 0 then
        surface.SetDrawColor(70,70,70, 255 * alpha)
        DrawBackgroundAnim(riot_materials.main, proshlo)
    end

    local bg = ColorAlpha(riot.NameColor, 255 * alpha)
    local tc = ColorAlpha(team_data.Color, 255 * alpha)

    draw.SimpleText(riot.Name, "PT.1", w / 2, h / 8, bg, 1, 4)
    draw.SimpleText("Вы - " .. team_data.Name, "PT.2", w / 2, h / 2, tc, 1, 3)
    draw.SimpleText(team_data.Desc, "PT.3", w / 2, h / 1.2, tc, 1, 1)
end
