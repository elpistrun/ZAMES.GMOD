--[[
    Консольная команда respawn.

        respawn          — реснуть себя
        respawn ^        — реснуть себя
        respawn <ник>    — реснуть игрока: сначала ищется точное совпадение ника,
                           если такого нет — по части ника
        respawn *        — реснуть всех

    Себя может реснуть любой игрок, на других и на * нужны права администратора
    (те же группы, что пускает sh_p99gdm3q81rgt9z.lua).

    ply.JustUseCommandRespawn читает PlayerSelectSpawn из тула orp_spawnpoint.lua:
    с этим флагом игрок не занимает раундовый спавнпоинт, а встаёт на обычную
    точку карты — то, что и ожидается от реснута командой.
]]

local ADMIN_GROUPS = {
	["superadmin"] = true,
	["dsuperadmin"] = true,
	["admin"] = true,
	["dadmin"] = true,
	["operator"] = true,
	["doperator"] = true,
	["mpiar"] = true,
	["piar"] = true,
}

local function IsAdmin(ply)
	if not IsValid(ply) then return false end

	return ply:IsAdmin() or ADMIN_GROUPS[ply:GetUserGroup()] == true
end

local function Notify(ply, text)
	if IsValid(ply) then
		ply:PrintMessage(HUD_PRINTCONSOLE, text)
	else
		print(text)
	end
end

local function Respawn(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return false end

	-- Spawn сам не вытащит игрока из режима наблюдения
	if ply:GetObserverMode() ~= OBS_MODE_NONE then
		ply:UnSpectate()
	end

	-- Снимаем фейк и убираем старый рагдолл, если игрок был в фейке/мертв
	if ply.Fake or IsValid(ply.FakeRagdoll) or IsValid(ply:GetNWEntity("FakeRagdoll")) then
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

	-- реснуть за рулём нельзя, сначала выходим из машины
	if ply:InVehicle() then
		ply:ExitVehicle()
	end

	ply.JustUseCommandRespawn = true
	ply:Spawn()

	-- снимаем флаг следующим тиком: PlayerSelectSpawn обязан успеть его увидеть
	timer.Simple(0, function()
		if IsValid(ply) then
			ply.JustUseCommandRespawn = nil
		end
	end)

	return true
end

-- Точное совпадение ника важнее частичного, регистр не учитываем (латиница)
local function FindPlayersByNick(nick)
	if nick == "" then return {} end

	local exact, partial = {}, {}
	local needle = string.lower(nick)

	for _, ply in player.Iterator() do
		local pnick = ply:Nick()

		if pnick == nick then
			exact[#exact + 1] = ply
		elseif string.find(string.lower(pnick), needle, 1, true) then
			partial[#partial + 1] = ply
		end
	end

	return #exact > 0 and exact or partial
end

-- Антиспам только для себя: админ должен иметь возможность реснуть несколько целей подряд
local function RespawnSelf(ply)
	local now = CurTime()

	if ply.NextSelfRespawn and ply.NextSelfRespawn > now then return end
	ply.NextSelfRespawn = now + 1

	if Respawn(ply) then
		Notify(ply, "[respawn] Реснул себя")
	end
end

concommand.Add("respawn", function(ply, cmd, args)
	local caller = IsValid(ply) and ply or nil
	local target = args[1]

	if not target or target == "^" then
		if not caller then
			Notify(nil, "[respawn] Из консоли сервера укажи цель: respawn <ник> или respawn *")
			return
		end

		RespawnSelf(caller)
		return
	end

	local targets

	if target == "*" then
		targets = {}

		for _, v in player.Iterator() do
			targets[#targets + 1] = v
		end
	else
		targets = FindPlayersByNick(target)

		if #targets == 0 then
			Notify(caller, "[respawn] Игрок не найден: " .. target)
			return
		end
	end

	-- не админ может реснуть только себя
	if caller and not IsAdmin(caller) then
		for _, v in ipairs(targets) do
			if v ~= caller then
				Notify(caller, "[respawn] Нет прав на других игроков (доступно: respawn)")
				return
			end
		end

		RespawnSelf(caller)
		return
	end

	local done = 0

	for _, v in ipairs(targets) do
		if Respawn(v) then
			done = done + 1
		end
	end

	if target == "*" then
		Notify(caller, "[respawn] Реснул всех игроков (" .. done .. ")")
	else
		Notify(caller, "[respawn] Реснул: " .. target .. " (" .. done .. ")")
	end
end, function()
	local out = { "*", "^" }

	for _, v in player.Iterator() do
		out[#out + 1] = v:Nick()
	end

	return out
end, "respawn — себя, respawn <ник> — игрока, respawn * — всех (нужен админ)")

-- =========================================================================
-- СИСТЕМА СПЕКТАТОРА ПРИ СМЕРТИ (Свободный полет + переключение по игрокам)
-- =========================================================================
-- СИСТЕМА СПЕКТАТОРА (Смерть, смена команды, вход во время активного раунда)
-- =========================================================================

local function IsRoundActive()
	if zs and zs.RD and zs.RD.state == 1 then
		return true
	end
	return false
end

local function GetAlivePlayers(excludePly)
	local alive = {}
	for _, p in player.Iterator() do
		if IsValid(p) and p:Alive() and p ~= excludePly and p:Team() ~= 1002 then
			table.insert(alive, p)
		end
	end
	return alive
end

local function MakePlayerSpectator(ply, preferFirstAlive)
	if not IsValid(ply) then return end

	local targets = GetAlivePlayers(ply)
	if preferFirstAlive and #targets > 0 then
		ply:Spectate(OBS_MODE_CHASE)
		ply:SpectateEntity(targets[1])
	else
		ply:Spectate(OBS_MODE_ROAMING)
		ply:SpectateEntity(NULL)
	end
end

local function CycleSpectatorTarget(ply, forward)
	local targets = GetAlivePlayers(ply)
	if #targets == 0 then
		ply:Spectate(OBS_MODE_ROAMING)
		ply:SpectateEntity(NULL)
		return
	end

	local curTarget = ply:GetObserverTarget()
	local curIndex = 0

	for i, t in ipairs(targets) do
		if t == curTarget then
			curIndex = i
			break
		end
	end

	local nextIndex = 1
	if forward then
		nextIndex = (curIndex % #targets) + 1
	else
		nextIndex = (curIndex - 2 + #targets) % #targets + 1
	end

	local newTarget = targets[nextIndex]
	if IsValid(newTarget) then
		ply:Spectate(OBS_MODE_CHASE)
		ply:SpectateEntity(newTarget)
	end
end


-- Переход в режим свободной камеры (Roaming)
local function ToggleFreeRoam(ply)
	local curMode = ply:GetObserverMode()
	if curMode == OBS_MODE_ROAMING then
		-- Возвращаемся к наблюдению за игроком
		CycleSpectatorTarget(ply, true)
	else
		local target = ply:GetObserverTarget()
		if IsValid(target) then
			ply:SetPos(target:EyePos())
		end
		ply:Spectate(OBS_MODE_ROAMING)
		ply:SpectateEntity(NULL)
	end
end

-- 1. Спектатор при смерти
hook.Add("PostPlayerDeath", "ZS_Spectator_OnDeath", function(ply)
	timer.Simple(2.5, function()
		if not IsValid(ply) or ply:Alive() then return end
		MakePlayerSpectator(ply, true)
	end)
end)

-- Управление спектатором (ЛКМ / ПКМ / Пробел) — вид всегда от 3-го лица
hook.Add("KeyPress", "ZS_Spectator_Controls", function(ply, key)
	if ply:Alive() then return end
	if ply:GetObserverMode() == OBS_MODE_NONE then return end

	-- ЛКМ: следующий игрок
	if key == IN_ATTACK then
		CycleSpectatorTarget(ply, true)
	-- ПКМ: предыдущий игрок
	elseif key == IN_ATTACK2 then
		CycleSpectatorTarget(ply, false)
	-- ПРОБЕЛ / ПРЫЖОК: переключение свободной камеры
	elseif key == IN_JUMP then
		ToggleFreeRoam(ply)
	end
end)

-- Сброс спектатора при спавне
hook.Add("PlayerSpawn", "ZS_Spectator_ResetOnSpawn", function(ply)
	-- Если игрок встаёт из фейка, игнорируем
	if ply.PLYSPAWN_OVERRIDE or ply.IsExitingFake then return end

	-- Если раунд активен и это не спавн через админ-команду respawn или раундовый спавн, спавниться живым нельзя
	if IsRoundActive() and not ply.JustUseCommandRespawn and not ply.RoundSpawning and ply:Team() ~= 1002 then
		-- Не даём реснуться во время активного раунда
		timer.Simple(0, function()
			if not IsValid(ply) then return end
			if ply.PLYSPAWN_OVERRIDE or ply.IsExitingFake or ply.RoundSpawning then return end
			if ply:Alive() then
				ply:KillSilent()
			end
			MakePlayerSpectator(ply, true)
			ply:ChatPrint("[Раунд] Раунд уже идёт! Вы возродитесь в следующем раунде.")
		end)
		return
	end

	if ply:GetObserverMode() ~= OBS_MODE_NONE then
		ply:UnSpectate()
	end
end)

-- 2. Вход на сервер: когда игрок полностью загрузился и зашёл, он сразу мёртв / в наблюдении
hook.Add("PlayerInitialSpawn", "ZS_Spectator_OnInitialSpawn", function(ply)
	-- Выставляем команду игроков по умолчанию
	ply:SetTeam(1)

	timer.Simple(0.1, function()
		if not IsValid(ply) then return end

		if ply:Alive() then
			ply:KillSilent()
		end

		MakePlayerSpectator(ply, true)
	end)
end)

-- 3. Обработка смены команды (F2 меню)
net.Receive("net_ch_team", function(len, ply)
	if not IsValid(ply) then return end
	local teamId = net.ReadInt(16)

	if teamId == 1002 then
		-- Переход в режим чистого наблюдателя
		ply:SetTeam(1002)
		if ply:Alive() then
			ply:KillSilent()
		end
		ply:Spectate(OBS_MODE_ROAMING)
		ply:SpectateEntity(NULL)
	elseif teamId == 1 then
		-- Смена команды на игровую (Team 1)
		ply:SetTeam(1)

		-- Игрок не должен возрождаться при смене команды (ждёт следующий раунд или respawn)
		if ply:Alive() then
			ply:KillSilent()
		end
		MakePlayerSpectator(ply, true)
	end
end)

function GM:ShowTeam(ply)
	if not IsValid(ply) then return end
	if ply:Team() == 1002 then
		ply:SetTeam(1)
		if ply:Alive() then
			ply:KillSilent()
		end
		MakePlayerSpectator(ply, true)
	end
end

concommand.Add("gm_showteam", function(ply)
	if not IsValid(ply) then return end
	if ply:Team() == 1002 then
		ply:SetTeam(1)
		if ply:Alive() then
			ply:KillSilent()
		end
		MakePlayerSpectator(ply, true)
	end
end)

-- =========================================================================
-- РАЗДАЧА МОДЕЛЕЙ (Случайные горожане вместо Кляйнера)
-- =========================================================================

local DEFAULT_CITIZEN_MODELS = {
	"models/player/Group01/male_01.mdl",
	"models/player/Group01/male_02.mdl",
	"models/player/Group01/male_03.mdl",
	"models/player/Group01/male_04.mdl",
	"models/player/Group01/male_05.mdl",
	"models/player/Group01/male_06.mdl",
	"models/player/Group01/male_07.mdl",
	"models/player/Group01/male_08.mdl",
	"models/player/Group01/male_09.mdl",
	"models/player/Group01/female_01.mdl",
	"models/player/Group01/female_02.mdl",
	"models/player/Group01/female_03.mdl",
	"models/player/Group01/female_04.mdl",
	"models/player/Group01/female_06.mdl",
}

hook.Add("PlayerSetModel", "ZS_SetCitizenModelOnSpawn", function(ply)
	if not IsValid(ply) then return end

	-- Если у игрока уже сохранён купленный скин из кастомизации, даём ему сохраниться
	local customModel = ply:GetNWString("CustomPlayerModel", "")
	if customModel ~= "" and util.IsValidModel(customModel) then
		ply:SetModel(customModel)
		return true
	end

	-- Если есть список моделей текущего раунда (например hmcd.Models)
	local roundModels = hmcd and hmcd.Models
	local chosenModel
	if roundModels and #roundModels > 0 then
		chosenModel = table.Random(roundModels)
	else
		chosenModel = table.Random(DEFAULT_CITIZEN_MODELS)
	end

	util.PrecacheModel(chosenModel)
	ply:SetModel(chosenModel)
	return true
end)

