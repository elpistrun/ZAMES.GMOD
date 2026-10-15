--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/n3zm2nr1wm2nn3zt9z/1fz7yc5dc3pf5xr6xh/sh_1fz7yc5dc3pf5xr6xh.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:26
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

CreateBa("hunter")

hunter = hunter or {}

hunter.Name = "Hunter"
hunter.NameColor = Color(255,255,255)

hunter.Teams = {
    [1] = {
        Name = "Прячущиеся",
        Color = Color(93,253,93),
        Desc = "Спрачься от искателя."
    },
    [2] = {
        Name = "Искатели",
        Color = Color(255,0,0),
        Desc = "Убей всех прячущихся"
    },
    [3] = {
        Name = "Полицейские",
        Color = Color(0,60,255),
        Desc = "Найди искателя и убей."
    },
}
