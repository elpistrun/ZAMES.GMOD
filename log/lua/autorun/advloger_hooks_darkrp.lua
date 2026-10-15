--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/log/lua/autorun/advloger_hooks_darkrp.lua <
    > Callstack:  <
]]

AdvLoger = AdvLoger or {}
AdvLoger.Hooks = AdvLoger.Hooks or {}


// ───────────────────────── Player TeamChange
local LHOOK = {}
LHOOK.Enable = true
LHOOK.Format = "Player ' #1 ' Changed team to #3"

/*
	#1 = Player Name
	#2 = Old Team Name
	#3 = New Team Name
*/
AdvLoger.Hooks["PlayerTeamChange"] = LHOOK

// ───────────────────────── Player Arrested
local LHOOK = {}
LHOOK.Enable = true
LHOOK.Format = "#1 is arrested by #2 for #3 sec"

/*
	#1 = Victim Name
	#2 = Police Name
	#3 = Time
*/
AdvLoger.Hooks["playerArrested"] = LHOOK

// ───────────────────────── Player UnArrested
local LHOOK = {}
LHOOK.Enable = true
LHOOK.Format = "#1 has released"

/*
	#1 = Victim Name
*/
AdvLoger.Hooks["playerUnArrested"] = LHOOK


