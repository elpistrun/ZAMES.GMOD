--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/3jp9vn6xh2wb3jp8mg8rf5xr/lua/autorun/fprofiler.lua <
    > Callstack:  <
]]

FProfiler = FProfiler or {}
FProfiler.Internal = {}
FProfiler.UI = {}

AddCSLuaFile()
AddCSLuaFile("fprofiler/cami.lua")
AddCSLuaFile("fprofiler/gather.lua")
AddCSLuaFile("fprofiler/report.lua")
AddCSLuaFile("fprofiler/util.lua")
AddCSLuaFile("fprofiler/prettyprint.lua")

AddCSLuaFile("fprofiler/ui/model.lua")
AddCSLuaFile("fprofiler/ui/frame.lua")
AddCSLuaFile("fprofiler/ui/clientcontrol.lua")
AddCSLuaFile("fprofiler/ui/servercontrol.lua")

include("fprofiler/cami.lua")

CAMI.RegisterPrivilege{
    Name = "FProfiler",
    MinAccess = "superadmin"
}


include("fprofiler/prettyprint.lua")
include("fprofiler/util.lua")
include("fprofiler/gather.lua")
include("fprofiler/report.lua")


if CLIENT then
    include("fprofiler/ui/model.lua")
    include("fprofiler/ui/frame.lua")
    include("fprofiler/ui/clientcontrol.lua")
    include("fprofiler/ui/servercontrol.lua")
else
    include("fprofiler/ui/server.lua")
end

