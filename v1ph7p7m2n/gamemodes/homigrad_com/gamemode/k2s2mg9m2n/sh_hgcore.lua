--[[
	sh_hgcore.lua — шим ядра hg для нашего фейка (папка fake/).

	В этом геймоде нет нового ядра homigrad (hg = organism, netvars, рендер регдоллов и т.д.),
	из-за чего fake/* падал на загрузке (attempt to index global 'hg'), а дальше — на
	отсутствующих hg.*, ply.organism и Entity:GetNetVar.

	Что здесь есть:
	  * таблицы-состояния (hg.ragdolls, hg.override, hg.ragdollFake, hg.humans_cached);
	  * простые функции (hg.KeyDown, hg.IsChanged, hg.LightStunPlayer, hitgroup/ампутация);
	  * organism-lite: ply.organism с "здоровыми" значениями (без симуляции ран/стамины);
	  * netvars-lite: Entity/Player/Weapon:SetNetVar/GetNetVar/GetNetVars (локально, без синхронизации);
	  * куски ядра, которые зовёт сам fake: ishgweapon и методы оружия (IsPistolHoldType, IsResting),
	    PLAYER:GetRagdollEntity (он же HookGetRagdollEntity), ApplyAppearanceRagdoll,
	    Gib_RemoveBone, CreateVFire;
	  * заглушки рендер-хелперов (TODO) — фейк работает, но без фирменной отрисовки регдолла.

	Всё определяется только если ещё не определено: если принесёшь настоящее ядро
	(hg = ... в другом аддоне или файле), этот шим ничего не перезапишет.

	Файлы уровня k2s2mg9m2n грузятся раньше подпапок, поэтому hg существует к моменту
	include-ов папки fake/ — и на сервере, и на клиенте.
]]

hg = hg or {}

-- не перезатираем реальное ядро, если оно когда-нибудь появится
local function hgSetter(tbl, name, fn)
	if tbl[name] == nil then
		tbl[name] = fn
	end

	return tbl[name]
end

--// состояние, которое фейк ожидает от ядра
hg.ragdolls = hg.ragdolls or {}
hg.override = hg.override or {}
hg.ragdollFake = hg.ragdollFake or {}
hg.humans_cached = hg.humans_cached or {}

--// простые хелперы
hgSetter(hg, "KeyDown", function(ply, key)
	return IsValid(ply) and ply:KeyDown(key) or false
end)

hgSetter(hg, "IsChanged", function(val, idx, tbl)
	if tbl == nil or tbl[idx] ~= val then
		if tbl ~= nil then tbl[idx] = val end

		return true
	end

	return false
end)

hgSetter(hg, "InGame", function()
	-- TODO: в новом ядре это проверка активного раунда; здесь считаем, что игра всегда идёт
	return true
end)

hgSetter(hg, "NoCameraInCar", function(veh)
	return false
end)

hgSetter(hg, "NoFakeInCar", function(veh)
	return false
end)

hgSetter(hg, "RotateAroundPoint2", function(vec, ang, pivot, pivotAng, rotate)
	-- TODO: заглушка (в sv_tier_0 вызов закомментирован): крутим только вокруг оси pivot
	pivot = pivot or vector_origin

	local offset = (vec - pivot)
	offset:Rotate(rotate or angle_zero)

	return offset + pivot
end)

--// кость -> хитгруппа (1 голова, 2 грудь, 3 живот, 4 л.рука, 5 п.рука, 6 л.нога, 7 п.нога)
hg.bonetohitgroup = hg.bonetohitgroup or {
	["ValveBiped.Bip01_Head1"] = 1,
	["ValveBiped.Bip01_Neck1"] = 1,
	["ValveBiped.Bip01_Spine4"] = 1,
	["ValveBiped.Bip01_Spine2"] = 2,
	["ValveBiped.Bip01_Spine1"] = 3,
	["ValveBiped.Bip01_Spine"] = 3,
	["ValveBiped.Bip01_Pelvis"] = 3,
	["ValveBiped.Bip01_L_UpperArm"] = 4,
	["ValveBiped.Bip01_L_Forearm"] = 4,
	["ValveBiped.Bip01_L_Hand"] = 4,
	["ValveBiped.Bip01_R_UpperArm"] = 5,
	["ValveBiped.Bip01_R_Forearm"] = 5,
	["ValveBiped.Bip01_R_Hand"] = 5,
	["ValveBiped.Bip01_L_Thigh"] = 6,
	["ValveBiped.Bip01_L_Calf"] = 6,
	["ValveBiped.Bip01_L_Foot"] = 6,
	["ValveBiped.Bip01_R_Thigh"] = 7,
	["ValveBiped.Bip01_R_Calf"] = 7,
	["ValveBiped.Bip01_R_Foot"] = 7,
}

--// кость -> префикс поля в organism (проверяется ply.organism[prefix.."amputated"])
hg.amputeetable = hg.amputeetable or {
	["ValveBiped.Bip01_L_UpperArm"] = "larm",
	["ValveBiped.Bip01_R_UpperArm"] = "rarm",
	["ValveBiped.Bip01_L_Thigh"] = "lleg",
	["ValveBiped.Bip01_R_Thigh"] = "rleg",
}

hg.IdealMassPlayer = hg.IdealMassPlayer or {} -- TODO: идеальные массы по физ-костям

--// organism-lite: "здоровые" значения, чтобы фейк считал силу, стамину и т.п.
hg.organism = hg.organism or {}
hg.organism.fake_spine1 = hg.organism.fake_spine1 or 1 -- порог, ниже которого позвоночник считается сломанным

hgSetter(hg.organism, "New", function(ent)
	return {
		owner = ent,
		isPly = IsValid(ent) and ent:IsPlayer() or false,

		-- мобильность / состояния
		canmove = true,
		canmovehead = true,
		choking = false,
		otrub = false,
		holdingbreath = false,
		stun = 0,
		lightstun = 0,
		shock = 0,

		-- боль / сознание
		pain = 0,
		painadd = 0,
		consciousness = 1,

		-- кровь / кислород / стамина
		blood = 5000,
		o2 = {100, 100},
		stamina = {100, 100},

		-- конечности: 0 = целая, 1 = сломана
		larm = 0,
		rarm = 0,
		lleg = 0,
		rleg = 0,
		spine1 = 0,
		larmdislocation = false,
		rarmdislocation = false,
		larmamputated = false,
		rarmamputated = false,

		-- прочее
		wounds = {},
		LodgedEntities = {},
		assimilated = 0,
	}
end)

hgSetter(hg.organism, "Add", function(ent)
	if not IsValid(ent) then return end

	ent.organism = ent.organism or hg.organism.New(ent)

	return ent.organism
end)

hgSetter(hg.organism, "Remove", function(ent)
	if not IsValid(ent) then return end

	ent.organism = nil
end)

hgSetter(hg.organism, "Clear", function(org)
	-- TODO: в новом ядре тут сброс состояния после фейка/подъёма.
	-- Сбрасываем только "временное", чтобы не затирать кровь/раны/конечности.
	if not istable(org) then return end

	org.canmove = true
	org.canmovehead = true
	org.choking = false
	org.otrub = false
	org.holdingbreath = false
	org.stun = 0
	org.lightstun = 0
	org.painadd = 0

	return org
end)

--// netvars-lite: Entity:SetNetVar / GetNetVar / GetNetVars
-- Хранилище локальное для реалма (без отправки на клиент) — фейк использует netvars
-- в основном на сервере, а клиентские чтения идут с дефолтами.
do
	local store = setmetatable({}, {__mode = "k"})

	local function netvarStore(self)
		local tbl = store[self]

		if tbl == nil then
			tbl = {}
			store[self] = tbl
		end

		return tbl
	end

	local function NetVarGet(self, key, default)
		if self == nil or key == nil then return default end

		local value = netvarStore(self)[key]

		if value == nil then return default end

		return value
	end

	local function NetVarSet(self, key, value)
		if self == nil or key == nil then return end

		netvarStore(self)[key] = value
	end

	local function NetVarAll(self)
		if self == nil then return {} end

		return netvarStore(self)
	end

	-- Entity — общий метатейбл сущностей, но ставим и на Player/Weapon:
	-- клиенту нужен метод и у сущностей с более узким метатейблом
	for _, metaName in ipairs({"Entity", "Player", "Weapon"}) do
		local meta = FindMetaTable(metaName)

		if meta then
			hgSetter(meta, "GetNetVar", NetVarGet)
			hgSetter(meta, "SetNetVar", NetVarSet)
			hgSetter(meta, "GetNetVars", NetVarAll)
		end
	end
end

if SERVER then
	hgSetter(hg, "LightStunPlayer", function(ply, time)
		-- TODO: заглушка нового ядра: свето-оглушение через organism.lightstun
		if not IsValid(ply) or not ply.organism then return end

		ply.organism.lightstun = math.max(ply.organism.lightstun or 0, CurTime() + (time or 1))
	end)

	local function EnsureOrganism(ply)
		if IsValid(ply) and not ply.organism then
			ply.organism = hg.organism.New(ply)
		end
	end

	hook.Add("PlayerInitialSpawn", "hgcore_organism", EnsureOrganism)
	hook.Add("PlayerSpawn", "hgcore_organism", EnsureOrganism)

	hook.Add("InitPostEntity", "hgcore_organism", function()
		for _, ply in player.Iterator() do
			EnsureOrganism(ply)
		end
	end)
end

--// заглушки нового ядра: рендер регдоллов, камера смерти, viewpunch-хелперы и прочее
do
	local stubs = {
		"drop", "cam_things", "eye",
		"RenderWeapons", "RenderMelees", "RenderTPIKBase", "MainTPIKFunction",
		"GoreCalc", "CoolGloves", "ProjectilesDraw", "RenderBandages",
		"RenderTourniquets", "RenderHeadcrab", "CuffedAnim", "bone_apply_matrix",
		"DeathCam",
	}

	for _, name in ipairs(stubs) do
		hgSetter(hg, name, function() end) -- TODO: заглушка нового ядра
	end

	hgSetter(hg, "CalculateConsciousnessMul", function() return 0 end) -- 0 = без помутнения сознания
	hgSetter(hg, "DeathCamAvailable", function() return false end)
end

--// куски ядра, которые зовёт сам fake: оружие homigrad, регдолл игрока, ампутация, огонь

-- оружие homigrad: в новом ядре это огнестрел со своими методами хвата/упора.
-- На этом сервере огнестрел — пушки на базе orp_base (ближний бой и тазер сидят на weapon_base).
hgSetter(_G, "ishgweapon", function(wep)
	if not IsValid(wep) or wep.ismelee or wep.ismelee2 then return false end

	return wep.ishgweapon == true or wep.Base == "orp_base" -- TODO: добавить другие базы пушек, если появятся
end)

-- методы оружия из нового ядра (fake/sv_control.lua зовёт их при ishgweapon)
do
	local wepMeta = FindMetaTable("Weapon")

	hgSetter(wepMeta, "IsPistolHoldType", function(self)
		local hold = self:GetHoldType()

		return hold == "pistol" or hold == "revolver" or hold == "357"
	end)

	hgSetter(wepMeta, "IsResting", function(self)
		-- TODO: в новом ядре это упор оружия (сошки, край укрытия); у нас такого нет
		return false
	end)
end

-- регдолл игрока: fake/sv_tier_0.lua сохраняет эту функцию как HookGetRagdollEntity и зовёт
-- её, если NW "RagdollDeath" ещё не выставлен (иначе там вызов nil-функции).
do
	local plyMeta = FindMetaTable("Player")

	hgSetter(plyMeta, "GetRagdollEntity", function(self)
		local ragdoll = self.RagdollDeath

		if not IsValid(ragdoll) then ragdoll = self:GetNWEntity("RagdollDeath") end
		if not IsValid(ragdoll) then ragdoll = self.FakeRagdoll end
		if not IsValid(ragdoll) then ragdoll = self:GetNWEntity("FakeRagdoll") end

		return ragdoll
	end)
end

-- внешний вид игрока на регдолл (зовётся из hg.Ragdoll_Create)
hgSetter(_G, "ApplyAppearanceRagdoll", function(ragdoll, ply)
	if not IsValid(ragdoll) or not IsValid(ply) or not ply:IsPlayer() then return end

	-- TODO: в новом ядре сюда же входят аксессуары, броня и раны
	if ragdoll:GetModel() ~= ply:GetModel() then
		ragdoll:SetModel(ply:GetModel())
	end

	ragdoll:SetSkin(ply:GetSkin())
	ragdoll:SetColor(ply:GetColor())

	for i = 0, ply:GetNumBodyGroups() - 1 do
		ragdoll:SetBodygroup(i, ply:GetBodygroup(i))
	end

	ragdoll.Appearance = ply.Appearance

	if isfunction(ragdoll.SetPlayerColor) then
		ragdoll:SetPlayerColor(ply:GetPlayerColor())
	end
end)

-- "отрыв" конечности при ампутации (fake/sv_tier_0.lua)
hgSetter(_G, "Gib_RemoveBone", function(ragdoll, bone, physNum, full)
	if not IsValid(ragdoll) then return end

	-- TODO: заглушка: прячем кость масштабом 0, скелет и физику не трогаем
	if isnumber(bone) and bone >= 0 and bone < ragdoll:GetBoneCount() then
		ragdoll:ManipulateBoneScale(bone, Vector(0, 0, 0))
	end
end)

-- отрисовка регдолла: в новом ядре hg.renderOverride рисует модель сам (плюс оружие и руки
-- через TPIK), поэтому заглушка ломала вид: движок при наличии RenderOverride сам сущность
-- не рисует, и все регдоллы (и фейк, и трупы) оставались только тенью.
hgSetter(hg, "renderOverride", function(ply, ent, flags)
	if not IsValid(ent) then return end

	-- TODO: здесь же в новом ядре рисуются оружие в руках, TPIK-руки, декали и эффекты
	ent:DrawModel(flags) -- флаги STUDIO_ из RenderOverride прокидываем дальше, как в вики
end)

if SERVER then
	-- огонь из нового ядра (fake поджигает им игрока/регдолла)
	hgSetter(_G, "CreateVFire", function(ent, pos, dir, size, owner)
		-- TODO: заглушка: обычный огонь движка вместо VFire из нового ядра
		local fire = ents.Create("entity_fire")

		if not IsValid(fire) then return end

		fire:SetPos(pos or (IsValid(ent) and ent:GetPos()) or vector_origin)
		fire:SetOwner(owner or ent)
		fire:Spawn()

		return fire
	end)
end

-- глобалы нового ядра из выключенных у нас веток (камера fake, viewpunch, броня)
hgSetter(_G, "RenderArmors", function() end) -- TODO: отрисовка брони из нового ядра
hgSetter(_G, "IsAimingNoScope", function(ply) return false end)
hgSetter(_G, "GoProCam", function() end) -- TODO: камера GoPro (камера fake у нас выключена)
hgSetter(_G, "HGAddView", function() end) -- TODO: доп. смещение вида из нового ядра
hgSetter(_G, "GetViewPunchAngles2", function() return angle_zero end) -- TODO: viewpunch нового ядра
hgSetter(_G, "GetViewPunchAngles3", function() return angle_zero end)
hgSetter(_G, "GetViewPunchAngles4", function() return angle_zero end)

if CLIENT then
	-- в новом ядре lply — глобальный LocalPlayer, наш клиент фейка на него рассчитывает
	lply = lply or LocalPlayer()

	hook.Add("Think", "hgcore_lply", function()
		lply = LocalPlayer()
	end)
end
