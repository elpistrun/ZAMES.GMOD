--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/n3zm2nr1wm2nn3zt9z/x78rf2h83kh/sh_x78rf2h83kh.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:26
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

CreateBa("hl2dm")

hl2dm = hl2dm or {}

hl2dm.Name = "hl2dm"
hl2dm.NameColor = Color(255,255,255)

hl2dm.Teams = {
    [1] = {
        Name = "Повстанцы",
        Color = Color(161,91,0),
        Desc = "За повстанцев, за победу!"
    },
    [2] = {
        Name = "Альянс",
        Color = Color(60,89,255),
        Desc = "За альянс! Здесь будет много крови!"
    },
}

hl2dm.Models = {
    "models/player/Group03/male_01.mdl",
    "models/player/Group03/male_02.mdl",
    "models/player/Group03/male_03.mdl",
    "models/player/Group03/male_04.mdl",
    "models/player/Group03/male_05.mdl",
    "models/player/Group03/male_06.mdl",
}
