--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
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

DeriveGamemode("sandbox")

GM.Name = "ZAMES.РФ"
GM.Author = "Asyan"

include("loader.lua")

--zs = zs or {}

IncludeDir("homigrad_com/gamemode/k2s2mg9m2n")

IncludeDir("homigrad_com/gamemode/n3zl5n3b")

function GM:PlayerDeathThink(ply) return false end
function GM:PlayerDeathSound(ply) return true end
function GM:HUDDrawTargetID() return false end
function GM:PlayerDeath(ply,ent,att) return false end
function GM:HUDWeaponPickedUp(wpn) return false end

-- Блокируем дефолтный труп Garry's Mod (ply:CreateRagdoll), чтобы оставался только Fake
function GM:DoPlayerDeath(ply, attacker, dmginfo)
	ply:AddDeaths(1)
	if IsValid(attacker) and attacker:IsPlayer() then
		if attacker == ply then
			attacker:AddFrags(-1)
		else
			attacker:AddFrags(1)
		end
	end
end

-- Блокируем выдачу дефолтного оружия из Sandbox (пистолеты, дробовики, рпг, монтировки и т.д.)
function GM:PlayerLoadout(ply)
	return true
end
