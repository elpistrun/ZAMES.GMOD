--[[
    Gamemode server initialization
]]

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

if file.Exists("homigrad_com/gamemode/loader.lua", "LUA") then
	AddCSLuaFile("homigrad_com/gamemode/loader.lua")
elseif file.Exists("loader.lua", "LUA") then
	pcall(AddCSLuaFile, "loader.lua")
end

include("shared.lua")
