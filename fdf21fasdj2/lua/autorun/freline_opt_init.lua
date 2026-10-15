--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/fdf21fasdj2/lua/autorun/freline_opt_init.lua <
    > Callstack:  <
]]

AddCSLuaFile()
AddCSLuaFile( 'freline_opt/cl_opt.lua' )
AddCSLuaFile( 'freline_opt/sh_opt.lua' )

local function init()
	include( 'freline_opt/sh_opt.lua' )

	if CLIENT then
		include( 'freline_opt/cl_opt.lua' )
	else
		include( 'freline_opt/sv_opt.lua' )
	end
end

if ( GAMEMODE ) then
    init()
else
    hook.Add( 'InitPostEntity', 'PerformanceLuaTweaks', init )
end

