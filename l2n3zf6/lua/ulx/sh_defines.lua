--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/l2n3zf6/lua/ulx/sh_defines.lua <
    > Callstack: addons/l2n3zf6/lua/ulx/cl_init.lua:3
[C]:-1
addons/l2n3zf6/lua/ulib/modules/ulx_init.lua:4
[C]:-1
addons/h9k8rfq2bt5/lua/ulib/cl_init.lua:24
[C]:-1
addons/h9k8rfq2bt5/lua/autorun/ulib_init.lua:5 <
]]

ulx.LOW_ARGS = "You did not specify enough arguments for this command. Type 'ulx help' in console for help."

ulx.version = 3.81 -- Current release version. Don't access directly, use ULib.pluginVersionStr( "ULX" ) instead.
ulx.release = true -- Is this the release?

ulx.ID_ORIGINAL = 1
ulx.ID_PLAYER_HELP = 2
ulx.ID_HELP = 3

ulx.ID_MMAIN = 1
ulx.ID_MCLIENT = 2
ulx.ID_MADMIN = 3

ulx.HOOK_ULXDONELOADING = "ULXLoaded"
ulx.HOOK_VETO = "ULXVetoChanged"

