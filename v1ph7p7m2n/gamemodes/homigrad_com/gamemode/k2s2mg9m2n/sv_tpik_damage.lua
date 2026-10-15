--[[
    Серверная обработка попаданий системы TPIK (пакет m9q8s2mg6ph7r8ft9z).

    Оружие TPIK стреляет из позиции камеры, а не из EyePos, поэтому штатный
    FireBullets на сервере не попадает. Клиент сам отправляет точку попадания и
    хитгруппу (TPIK_SendDamage), а трассеры для остальных игроков (TPIK_FireBullet).
    Обработчиков этих сообщений в гмеймоде не было: оружие наносило 0 урона.

    Клиенту не доверяем — проверяем дистанцию и направление, режем частоту,
    а базовый урон берём из оружия, а не из присланного значения.

    Хитгруппа в GMod не хранится в CTakeDamageInfo (SetHitGroup/SetDamageGroup у него
    нет), она приходит вместе с трассой. Поэтому урон отправляем не через
    TakeDamageInfo, а через DispatchTraceAttack: получаем штатный путь пули —
    GM:PlayerTraceAttack / GM:ScalePlayerDamage (броня JMod) с настоящей хитгруппой,
    Player:LastHitGroup (хитмаркеры, кровь, декали) и корректный урон по func_breakable_surf.
    Множители зон остаются своими (см. hitgroup_mult), чтобы урон не считался дважды.
]]

util.AddNetworkString("TPIK_SendDamage")
util.AddNetworkString("TPIK_SendDamage123")
util.AddNetworkString("TPIK_SendDamage321")
util.AddNetworkString("TPIK_FireBullet")
util.AddNetworkString("TPIK_FireBullet123")
util.AddNetworkString("TPIK_FireBullet321")

local MAX_RANGE = 6000        -- максимальная дистанция засчитываемого попадания
local MAX_HIT_EVENTS = 45     -- событий урона в секунду с одного игрока
local MAX_TRACER_EVENTS = 30  -- трассеров в секунду с одного игрока
local MAX_DAMAGE_MULT = 5     -- потолок урона относительно Primary.Damage оружия

local hitgroup_mult = {
	[HITGROUP_GENERIC] = 1,
	[HITGROUP_HEAD] = 4,
	[HITGROUP_CHEST] = 1,
	[HITGROUP_STOMACH] = 1.25,
	[HITGROUP_LEFTARM] = 0.75,
	[HITGROUP_RIGHTARM] = 0.75,
	[HITGROUP_LEFTLEG] = 0.75,
	[HITGROUP_RIGHTLEG] = 0.75,
	[HITGROUP_GEAR] = 0.9,
}

-- Простейший антифлуд: сколько событий игрок уже отправил за текущую секунду
local function RateLimited(ply, key, maxPerSec)
	local now = CurTime()
	local bucket = ply[key]

	if not bucket or (now - bucket.start) >= 1 then
		bucket = { start = now, count = 0 }
		ply[key] = bucket
	end

	bucket.count = bucket.count + 1

	return bucket.count > maxPerSec
end

-- Активное оружие обязано поддерживать TPIK: иначе игрок мог бы стрелять из
-- пистолета и получать урон от rifle, просто взяв его в руки
local function GetTPIKWeapon(ply)
	local wep = ply:GetActiveWeapon()

	if not IsValid(wep) or not wep.SupportTPIK then return end
	if not wep.Primary or not wep.Primary.Damage or wep.Primary.Damage <= 0 then return end

	return wep
end

local function IsValidTarget(ent)
	if not IsValid(ent) then return false end

	if ent:IsPlayer() or ent:IsNPC() then return true end

	local cls = ent:GetClass()

	return (cls == "prop_ragdoll" or cls == "prop_physics"
		or cls == "func_breakable" or cls == "func_breakable_surf")
end

-- Точка попадания должна быть достижима из глаз игрока и лежать в секторе обзора
local function IsPlausibleHit(ply, hitPos)
	local delta = hitPos - ply:EyePos()
	local dist = delta:Length()

	if dist < 1 or dist > MAX_RANGE then return false end
	if ply:EyeAngles():Forward():Dot(delta:GetNormalized()) < 0.25 then return false end

	return true
end

local function ApplyHit(attacker, wep, ent, hitPos, hitGroup, force, clientDamage)
	-- Самоубийство оружием в режиме SuicideMode — единственный легитимный
	-- случай, когда целью попадания является сам стрелок
	if ent == attacker then
		if not attacker:GetNWBool("SuicideMode", false) then return end
		if hitPos:Distance(attacker:GetPos()) > 100 then return end
	end

	-- Чужой труп стрелять тоже нельзя
	if ent:GetClass() == "prop_ragdoll" then
		local owner = ent.RagdollOwner or ent:GetNWEntity("RagdollOwner")

		local isTeammate = false
		if IsValid(owner) and owner:IsPlayer() and attacker:IsPlayer() then
			if isfunction(owner.IsTeammate) then
				isTeammate = owner:IsTeammate(attacker)
			elseif owner.roleT and attacker.roleT then
				isTeammate = true
			elseif owner:Team() ~= 1002 and owner:Team() == attacker:Team() and not owner.roleT and not attacker.roleT then
				isTeammate = true
			end
		end

		if IsValid(owner) and (owner == attacker or isTeammate) then
			return
		end
	end

	local mult = hitgroup_mult[hitGroup] or 1
	local base = clientDamage or wep.Primary.Damage

	if base <= 0 then return end

	local damage = math.Clamp(base * mult, 1, wep.Primary.Damage * MAX_DAMAGE_MULT)

	local dmgInfo = DamageInfo()
	dmgInfo:SetAttacker(attacker)
	dmgInfo:SetInflictor(wep)
	dmgInfo:SetDamage(damage)
	dmgInfo:SetDamageType(DMG_BULLET)
	dmgInfo:SetDamagePosition(hitPos)
	local finalForce = (isvector(force) and not force:IsZero()) and force or (dir * ((wep.Primary and wep.Primary.Damage) or 10) * 10)
	if finalForce:IsZero() then finalForce = Vector(0, 0, 0.001) end
	dmgInfo:SetDamageForce(finalForce)

	-- Хитгруппа едет с трассой, а не в DamageInfo
	local dir = (hitPos - attacker:EyePos()):GetNormalized()
	local tr = {
		Entity = ent,
		Fraction = 1,
		Hit = true,
		HitGroup = hitGroup,
		HitNonWorld = true,
		HitNormal = -dir,
		HitPos = hitPos,
		HitWorld = false,
		Normal = dir,
		StartPos = attacker:EyePos(),
	}

	-- Штатный путь пули: сам вызовет хуки гмеймода/античита и выставит LastHitGroup
	ent:DispatchTraceAttack(dmgInfo, tr, dir)
end

-- Общий обработчик. hasClientDamage = true только для ближнего боя (TPIK_SendDamage123),
-- там клиент присылает урон конкретного удара, но он всё равно ограничивается оружием.
local function ReceiveDamage(ply, hasClientDamage)
	if not IsValid(ply) or not ply:Alive() then return end
	if RateLimited(ply, "TPIK_HitEvents", MAX_HIT_EVENTS) then return end

	local ent = net.ReadEntity()
	local force = net.ReadVector()
	local hitPos = net.ReadVector()
	local hitGroup = net.ReadInt(8)
	local clientDamage = hasClientDamage and net.ReadInt(16) or nil

	local wep = GetTPIKWeapon(ply)
	if not wep then return end
	if not IsValidTarget(ent) then return end
	if not IsPlausibleHit(ply, hitPos) then return end

	-- hitgroup приходит с клиента: оставляем только реальные значения
	if hitgroup_mult[hitGroup] == nil then hitGroup = HITGROUP_GENERIC end

	ApplyHit(ply, wep, ent, hitPos, hitGroup, force, clientDamage)
end

-- Трассеры: урон по-прежнему приходит через TPIK_SendDamage, тут только визуал
local function ReceiveBullet(ply)
	if not IsValid(ply) or not ply:Alive() then return end
	if RateLimited(ply, "TPIK_TracerEvents", MAX_TRACER_EVENTS) then return end

	local campos = net.ReadVector()
	local camang = net.ReadAngle()

	local delta = campos - ply:EyePos()
	if delta:Length() > 200 or camang == nil then return end

	ply:FireBullets({
		Num = 1,
		Src = campos,
		Dir = camang:Forward(),
		Spread = Vector(0, 0, 0),
		Tracer = 1,
		Force = 0.001,
		Damage = 0,
		IgnoreEntity = ply,
	})
end

net.Receive("TPIK_SendDamage", function(_, ply) ReceiveDamage(ply, false) end)
net.Receive("TPIK_SendDamage123", function(_, ply) ReceiveDamage(ply, true) end)
net.Receive("TPIK_SendDamage321", function(_, ply) ReceiveDamage(ply, false) end)

net.Receive("TPIK_FireBullet", function(_, ply) ReceiveBullet(ply) end)
net.Receive("TPIK_FireBullet123", function(_, ply) ReceiveBullet(ply) end)
net.Receive("TPIK_FireBullet321", function(_, ply) ReceiveBullet(ply) end)

-- Глобальная защита от спама AddMultiDamage: g_MultiDamage.GetDamageForce() == vec3_origin
hook.Add("EntityTakeDamage", "FixZeroDamageForceSpam", function(target, dmginfo)
	local f = dmginfo:GetDamageForce()
	if isvector(f) and f:IsZero() then
		dmginfo:SetDamageForce(Vector(0, 0, 0.001))
	end
end)