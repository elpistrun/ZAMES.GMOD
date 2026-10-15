--[[
    Система раундов Homicide (ZAMES.РФ)
    - Состояния: 0 = Ожидание игроков, 1 = Раунд идёт, 2 = Конец раунда / Победитель
    - Роли: Предатель (Traitor / roleT), Невиновный с оружием (Detective / roleCT), Невиновные (Innocents)
    - Выдача экипировки и патронов для каждой роли
    - Анимации начала раунда, баннеры, роли, звуки
    - Спавн на точках карты / orp_spawnpoint (type = "hmcd")
    - Проверка условий победы и перезапуск раунда
]]

zs = zs or {}
zs.RD = zs.RD or { state = 0, name = "hmcd", winner = nil }
zs.current_round = "hmcd"

local ROUND_TIME = 360 -- Длительность раунда в секундах (6 минут)
local POST_ROUND_TIME = 8 -- Время показа экрана победы (секунд)
local MIN_PLAYERS = 2 -- Минимальное количество игроков для старта раунда

local roundEndTime = 0
local roundCheckTimer = "HMCD_RoundLoopCheck"

-- Синхронизация состояния раунда с клиентами
function zs.SyncRound(ply)
	net.Start("net_rd")
	net.WriteTable(zs.RD)
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

-- Получить подходящих игроков (Team 1 — Игроки, не в Team 1002 — Наблюдатели)
local function GetEligiblePlayers()
	local plys = {}
	local hasBot = false

	for _, p in player.Iterator() do
		if IsValid(p) then
			-- Бот считается полноценным игроком: выставляем Team 1
			if p:IsBot() then
				hasBot = true
				if p:Team() ~= 1 then
					p:SetTeam(1)
				end
				if zs.RD.state == 0 and not p:Alive() then
					p:Spawn()
				end
			end
			if p:Team() == 1 then
				table.insert(plys, p)
			end
		end
	end

	-- Если на сервере есть бот, гарантируем, что бот и реальный игрок оба в пуле для 2 игроков
	if hasBot and #plys < 2 then
		for _, p in player.Iterator() do
			if IsValid(p) and not table.HasValue(plys, p) then
				p:SetTeam(1)
				table.insert(plys, p)
				if #plys >= 2 then break end
			end
		end
	end

	return plys, hasBot
end

-- Очистка фейка и рагдолла игрока перед спавном
local function CleanPlayerRagdoll(ply)
	if not IsValid(ply) then return end

	ply.Fake = false
	ply:SetNWBool("Fake", false)

	if IsValid(ply.FakeRagdoll) then
		if IsValid(ply.FakeRagdoll.bull) then
			ply.FakeRagdoll.bull:Remove()
		end
		ply.FakeRagdoll:Remove()
		ply.FakeRagdoll = nil
	end

	local curFakeRag = ply:GetNWEntity("FakeRagdoll")
	if IsValid(curFakeRag) then
		if IsValid(curFakeRag.bull) then
			curFakeRag.bull:Remove()
		end
		curFakeRag:Remove()
	end

	ply:SetNWEntity("FakeRagdoll", NULL)
	ply:SetNWEntity("RagdollDeath", NULL)
	ply:SetMoveType(MOVETYPE_WALK)
	ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
end

-- Сбор всех возможных спавнпоинтов на карте
local function GetAvailableSpawns()
	local spawns = {}

	-- 1. Точки из orp_spawnpoint
	if ORP_Spawnpoints and #ORP_Spawnpoints > 0 then
		for _, pt in ipairs(ORP_Spawnpoints) do
			if pt.type == "hmcd" and pt.pos then
				table.insert(spawns, pt.pos)
			end
		end
	end

	-- 2. Если кастомных точек нет — используем стандартные точки карты
	if #spawns == 0 then
		local mapSpawnClasses = {
			"info_player_deathmatch",
			"info_player_start",
			"info_player_terrorist",
			"info_player_counterterrorist"
		}
		for _, class in ipairs(mapSpawnClasses) do
			for _, ent in ipairs(ents.FindByClass(class)) do
				if IsValid(ent) then
					table.insert(spawns, ent:GetPos())
				end
			end
		end
	end

	return spawns
end

-- Спавн и экипировка игрока в зависимости от роли
local function SetupRoundPlayer(ply, spawnPos)
	if not IsValid(ply) then return end

	-- Выход из спектатора
	if ply:GetObserverMode() ~= OBS_MODE_NONE then
		ply:UnSpectate()
	end

	CleanPlayerRagdoll(ply)

	ply.RoundSpawning = true
	ply:Spawn()
	ply.RoundSpawning = nil

	if spawnPos then
		ply:SetPos(spawnPos + Vector(0, 0, 5))
	end

	ply:StripWeapons()
	ply:StripAmmo()

	-- Базовые руки
	ply:Give("weapon_hands")

	if ply.roleT then
		-- Экипировка Предателя (Homicide Traitor)
		local pistol = (math.random(1, 2) == 1) and "op_weapon_glock18" or "op_weapon_r8"
		ply:Give(pistol)
		if pistol == "op_weapon_glock18" then
			ply:GiveAmmo(34, "9x19mm Parabellum", true)
		else
			ply:GiveAmmo(16, ".367 Magnum", true)
			ply:GiveAmmo(16, ".357 Magnum", true)
		end

		ply:Give("orp_melee_bayonet")
		ply:Give("weapon_hidebomb")
		ply:Give("tr_instinct")
		ply:Give("weapon_hg_t_syringepoison")

		ply:SelectWeapon("weapon_hands")
	elseif ply.roleCT then
		-- Невиновный с оружием (Detective)
		ply:Give("op_weapon_870")
		ply:GiveAmmo(18, "12 Gauge12", true)
		ply:SelectWeapon("weapon_hands")
	else
		-- Обычный невиновный (Innocent)
		ply:SelectWeapon("weapon_hands")
	end
end

-- Запуск нового раунда
function zs.StartRound()
	local eligible, hasBot = GetEligiblePlayers()
	if #eligible < MIN_PLAYERS and not (hasBot and #player.GetAll() >= 2) then
		zs.RD.state = 0
		zs.RD.name = "hmcd"
		zs.RD.winner = nil
		zs.SyncRound()
		return
	end

	-- Сброс ролей у всех игроков
	for _, p in player.Iterator() do
		p.roleT = false
		p.roleCT = false
		p:SetNWBool("roleT", false)
		p:SetNWBool("roleCT", false)
	end

	-- Перемешиваем игроков
	local pool = table.Copy(eligible)
	for i = #pool, 2, -1 do
		local j = math.random(i)
		pool[i], pool[j] = pool[j], pool[i]
	end

	-- Расчет количества ролей
	-- 1 предатель на каждые 6 игроков (минимум 1)
	local traitorCount = math.max(1, math.floor(#pool / 6))
	local traitors = {}
	local detectives = {}

	for i = 1, traitorCount do
		local ply = table.remove(pool, 1)
		if IsValid(ply) then
			ply.roleT = true
			ply:SetNWBool("roleT", true)
			table.insert(traitors, ply)
		end
	end

	-- 1 невиновный с оружием (если осталось игроков)
	if #pool > 0 then
		local ply = table.remove(pool, 1)
		if IsValid(ply) then
			ply.roleCT = true
			ply:SetNWBool("roleCT", true)
			table.insert(detectives, ply)
		end
	end

	-- Остальные в pool остаются невиновными (ply.roleT = false, ply.roleCT = false)

	-- Выставляем состояние раунда
	zs.RD.state = 1
	zs.RD.name = "hmcd"
	zs.RD.winner = nil
	roundEndTime = CurTime() + ROUND_TIME

	-- Синхронизируем состояние раунда
	zs.SyncRound()

	-- Отправляем список ролей клиентам для хуков и панелей
	net.Start("hmcd_roleget")
	net.WriteTable({ [1] = traitors, [2] = detectives })
	net.Broadcast()

	-- Отправляем net_role для анимации и звука роли
	net.Start("net_role")
	net.WriteString("hmcd")
	net.Broadcast()

	-- Спавним всех участников
	local spawnList = GetAvailableSpawns()
	if #spawnList > 0 then
		-- Перемешиваем точки спавна
		for i = #spawnList, 2, -1 do
			local j = math.random(i)
			spawnList[i], spawnList[j] = spawnList[j], spawnList[i]
		end
	end

	local spawnIndex = 1
	for _, ply in ipairs(eligible) do
		local pos = spawnList[spawnIndex] or ply:GetPos()
		spawnIndex = (spawnIndex % math.max(1, #spawnList)) + 1
		SetupRoundPlayer(ply, pos)
	end

	-- Спавн контейнеров с лутом
	if lootboxes_spawn then
		lootboxes_spawn()
	end
end

-- Завершение раунда
function zs.EndRound(winnerName)
	if zs.RD.state == 2 then return end

	zs.RD.state = 2
	zs.RD.name = "hmcd"
	zs.RD.winner = winnerName or "Ничья"
	zs.SyncRound()

	-- Отправляем net_role для анимации затемнения между раундами
	net.Start("net_role")
	net.WriteString("hmcd")
	net.Broadcast()

	-- Награда койнов (CHC/CFC): только от 15 игроков, множитель 1.0 + (игроки - 15) * 0.1
	local totalPlayers = player.GetCount()
	if totalPlayers >= 15 then
		local multiplier = 1 + (totalPlayers - 15) * 0.1
		local roundMode = zs.RD.name or "hmcd"

		for _, p in player.Iterator() do
			if IsValid(p) and p.AddCFC then
				local baseReward = 0

				if roundMode == "hmcd" then
					-- Homicide:
					-- Предатель выиграл: Трейдер = 100, остальным = 15
					-- Невиновные выиграли: Невиновные = 50, Трейдерам = 5
					if p:Team() == 1 then
						if winnerName == "Предатели" then
							baseReward = p.roleT and 100 or 15
						elseif winnerName == "Невиновные" then
							baseReward = p.roleT and 5 or 50
						else
							-- При ничьей
							baseReward = 15
						end
					end
				elseif roundMode == "tdm" or roundMode == "hl2dm" or roundMode == "riot" or roundMode == "hunter" then
					-- TDM, HL2DM, RIOT, Hunter:
					-- Выигравшая команда: 50, Проигравшая команда: 10
					local pTeamName = ""
					if _G[roundMode] and _G[roundMode].Teams and _G[roundMode].Teams[p:Team()] then
						pTeamName = _G[roundMode].Teams[p:Team()].Name
					end

					if pTeamName == winnerName then
						baseReward = 50
					else
						baseReward = 10
					end
				else
					-- Для остальных режимов
					if p:Team() ~= 1002 then
						baseReward = 25
					end
				end

				if baseReward > 0 then
					local finalReward = math.floor(baseReward * multiplier)
					p:AddCFC(finalReward)
				end
			end
		end
	end

	-- Переход к следующему раунду после тайм-аута показа победного экрана
	timer.Simple(POST_ROUND_TIME, function()
		local eligible, hasBot = GetEligiblePlayers()
		if #eligible >= MIN_PLAYERS or (hasBot and #player.GetAll() >= 2) then
			zs.StartRound()
		else
			zs.RD.state = 0
			zs.RD.name = "hmcd"
			zs.RD.winner = nil
			zs.SyncRound()
		end
	end)
end

-- Проверка условий победы
function zs.CheckRoundEnd()
	if zs.RD.state ~= 1 then return end

	local aliveTraitors = 0
	local aliveInnocents = 0

	for _, p in player.Iterator() do
		if IsValid(p) and p:Alive() and p:Team() == 1 then
			if p.roleT then
				aliveTraitors = aliveTraitors + 1
			else
				aliveInnocents = aliveInnocents + 1
			end
		end
	end

	-- Если время вышло — невиновные выжили
	if CurTime() >= roundEndTime then
		zs.EndRound("Невиновные")
		return
	end

	-- Если все предатели мертвы
	if aliveTraitors == 0 and aliveInnocents > 0 then
		zs.EndRound("Невиновные")
		return
	end

	-- Если все невиновные мертвы
	if aliveInnocents == 0 and aliveTraitors > 0 then
		zs.EndRound("Предатели")
		return
	end

	-- Если все игроки погибли
	if aliveTraitors == 0 and aliveInnocents == 0 then
		zs.EndRound("Ничья")
		return
	end
end

-- Периодический цикл проверки состояния раунда (каждую секунду)
timer.Create(roundCheckTimer, 1, 0, function()
	if zs.RD.state == 0 then
		-- Режим ожидания игроков
		local eligible, hasBot = GetEligiblePlayers()
		local canStart = (#eligible >= MIN_PLAYERS) or (hasBot and #player.GetAll() >= 2)
		if canStart then
			-- Запускаем отсчет на старт раунда (если есть бот - 2 секунды)
			local countdown = hasBot and 2 or 5
			if not timer.Exists("HMCD_StartCountdown") then
				timer.Create("HMCD_StartCountdown", countdown, 1, function()
					local curEligible, curHasBot = GetEligiblePlayers()
					if ((#curEligible >= MIN_PLAYERS) or (curHasBot and #player.GetAll() >= 2)) and zs.RD.state == 0 then
						zs.StartRound()
					end
				end)
			end
		else
			if timer.Exists("HMCD_StartCountdown") then
				timer.Remove("HMCD_StartCountdown")
			end
		end
	elseif zs.RD.state == 1 then
		zs.CheckRoundEnd()
	end
end)

-- Хуки при смерти и отключении игрока для моментальной проверки условий победы
hook.Add("PlayerDeath", "HMCD_RoundCheck_OnDeath", function(victim, inflictor, attacker)
	timer.Simple(0.5, function()
		if zs.RD.state == 1 then
			zs.CheckRoundEnd()
		end
	end)
end)

hook.Add("PlayerDisconnected", "HMCD_RoundCheck_OnDisconnect", function(ply)
	timer.Simple(0.5, function()
		if zs.RD.state == 1 then
			zs.CheckRoundEnd()
		elseif zs.RD.state == 0 then
			local eligible, hasBot = GetEligiblePlayers()
			if (#eligible < MIN_PLAYERS and not (hasBot and #player.GetAll() >= 2)) and timer.Exists("HMCD_StartCountdown") then
				timer.Remove("HMCD_StartCountdown")
			end
		end
	end)
end)

-- Синхронизация для только что зашедших игроков и регистрация ботов
hook.Add("PlayerInitialSpawn", "HMCD_RoundSync_OnInitialSpawn", function(ply)
	timer.Simple(0.2, function()
		if IsValid(ply) then
			if ply:IsBot() then
				ply:SetTeam(1)
				ply:Spawn()
			end
			zs.SyncRound(ply)

			local eligible, hasBot = GetEligiblePlayers()
			if (#eligible >= MIN_PLAYERS or (hasBot and #player.GetAll() >= 2)) and zs.RD.state == 0 then
				if not timer.Exists("HMCD_StartCountdown") then
					timer.Create("HMCD_StartCountdown", 2, 1, function()
						if zs.RD.state == 0 then
							zs.StartRound()
						end
					end)
				end
			end
		end
	end)
end)
