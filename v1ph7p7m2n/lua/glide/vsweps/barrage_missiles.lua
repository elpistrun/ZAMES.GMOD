--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/lua/glide/vsweps/barrage_missiles.lua <
    > Callstack: addons/v1ph7p7m2n/lua/glide/sh_vsweps.lua:35
[C]:-1
addons/v1ph7p7m2n/lua/glide/sh_vsweps.lua:120
addons/v1ph7p7m2n/lua/glide/sh_vsweps.lua:136
lua/autorun/sh_glide.lua:408 <
]]

VSWEP.Base = "missile_launcher"
VSWEP.Name = "#glide.weapons.barrage_missiles"
VSWEP.Icon = "glide/icons/rocket.png"

if SERVER then
    VSWEP.FireDelay = 0.3
end

