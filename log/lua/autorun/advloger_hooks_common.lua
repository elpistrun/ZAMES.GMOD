--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/log/lua/autorun/advloger_hooks_common.lua <
    > Callstack:  <
]]

AdvLoger = AdvLoger or {}
AdvLoger.Hooks = AdvLoger.Hooks or {}

// ───────────────────────── Server Started ( this hook will be activated when you even change map to something )
local LHOOK = {}
LHOOK.Enable = true
LHOOK.Format = "Map Started."

AdvLoger.Hooks["ServerStart"] = LHOOK

// ───────────────────────── Server Shutdown ( this hook will be activated when you even change map to something )
local LHOOK = {}
LHOOK.Enable = true
LHOOK.Format = "Server Down"

AdvLoger.Hooks["ShutDown"] = LHOOK


// ───────────────────────── Player FirstJoin
local LHOOK = {}
LHOOK.Enable = true
LHOOK.Format = "Player, #1  Joined to server!"

/*
	#1 = Player Name
*/
AdvLoger.Hooks["PlayerFirstJoin"] = LHOOK

// ───────────────────────── Player Spawn
local LHOOK = {}
LHOOK.Enable = true
LHOOK.Format = "Player, #1  spawned"

/*
	#1 = Player Name
*/
AdvLoger.Hooks["PlayerSpawn"] = LHOOK

// ───────────────────────── Player Disconnect
local LHOOK = {}
LHOOK.Enable = true
LHOOK.Format = "Player, #1  has left"

/*
	#1 = Player Name
*/
AdvLoger.Hooks["PlayerDisconnect"] = LHOOK


// ───────────────────────── Player Death
local LHOOK = {}
LHOOK.Enable = true
LHOOK.Format = "Player #1 Killed #2"

/*
	#1 = Killer Name
	#2 = Victim Name
*/
AdvLoger.Hooks["PlayerDeath"] = LHOOK



// ───────────────────────── Player Take Damage
local LHOOK = {}
LHOOK.Enable = true
LHOOK.Format = "#2 -> #1 ( #4 / #3 )"

/*
	#1 = Victim Name
	#2 = attacker Name
	#3 = attacker weapon Name ( equipping weapon )
	#4 = Damage Amount
*/
AdvLoger.Hooks["PlayerTakeDamage"] = LHOOK


// ───────────────────────── Player Say
local LHOOK = {}
LHOOK.Enable = true
LHOOK.Format = "#1 : #2"

/*
	#1 = Player Name
	#2 = Chat Text
*/
AdvLoger.Hooks["PlayerSay"] = LHOOK



// ───────────────────────── Player Spawn Prop
local LHOOK = {}
LHOOK.Enable = true
LHOOK.Format = "#1 Spawned #2"

/*
	#1 = Player Name
	#2 = Model mdl name
*/
AdvLoger.Hooks["PlayerSpawnProp"] = LHOOK

