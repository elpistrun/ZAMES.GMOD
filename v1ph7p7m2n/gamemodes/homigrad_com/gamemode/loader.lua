--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:19
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

--[[

███████╗░█████╗░███╗░░░███╗███████╗░██████╗
╚════██║██╔══██╗████╗░████║██╔════╝██╔════╝
░░███╔═╝███████║██╔████╔██║█████╗░░╚█████╗░
██╔══╝░░██╔══██║██║╚██╔╝██║██╔══╝░░░╚═══██╗
███████╗██║░░██║██║░╚═╝░██║███████╗██████╔╝
╚══════╝╚═╝░░╚═╝╚═╝░░░░░╚═╝╚══════╝╚═════╝░

--]]


AddCSLuaFile()

local function AddFile( File, directory )
	local prefix = string.lower( string.Left( File, 3 ) )

	if SERVER and prefix == "sv_" then
		include( directory .. File )
		--print( "+ SERVER INCLUDE: " .. File )
	elseif prefix == "sh_" then
		if SERVER then
			AddCSLuaFile( directory .. File )
			--print( "+ SHARED ADDCS: " .. File )
		end
		include( directory .. File )
		--print( "+ SHARED INCLUDE: " .. File )
	elseif prefix == "cl_" then
		if SERVER then
			AddCSLuaFile( directory .. File )
			--print( "+ CLIENT ADDCS: " .. File )
		elseif CLIENT then
			include( directory .. File )
			--print( "+ CLIENT INCLUDE: " .. File )
		end
	end
end

function IncludeDir( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "LUA" )

	for _, v in ipairs( files ) do
		if string.EndsWith( v, ".lua" ) then
			AddFile( v, directory )
		end
	end

	for _, v in ipairs( directories ) do
		--print( "+ Directory: " .. v )
		IncludeDir( directory .. v )
	end
end
