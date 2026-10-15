local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")
util.AddNetworkString("fake")
util.AddNetworkString("RemoveRag")
util.AddNetworkString("DeadBodies")
util.AddNetworkString("unload")

//Краткий гайд каким нужно делать рагдолл
/*
	Тянется к руке - Spine4 
    На е двигаются - (Spine4,Spine2) (МЕНЬШЕ СКОРОСТЬ У Spine2)

    Назад - 80 MaxSpeed
    Вперёд - 80 MaxSpeed
*/

local BlackListWep = {
	["weapon_hands"] = true,
	["weapon_zombie"] = true,
	["weapon_zombie_ghoul"] = true,
	["weapon_zombie_wraith"] = true,
	["weapon_zombie_fast"] = true,
}

hg.ragdollFake = {}

net.Receive("fake",function(len,ply)
	if !ply:Alive() then return end
	if ply._fakeCooldown and ply._fakeCooldown > CurTime() then return end
	ply._fakeCooldown = CurTime() + 0.5
    Faking(ply)
end)

net.Receive("unload",function(l,ply)
	local ent = net.ReadEntity()
	if ent:GetOwner() != ply then
		ply:Kick("Unloads your game.")
		return
	end

	if !ent.Clip1 then
		return
	end

	if ent:Clip1() == 0 then
		return
	end

	sound.Play("snd_jack_hmcd_ammotake.wav",hg.GetCurrentCharacter(ply):GetPos(),75,100,1)

	ply:GiveAmmo(ent:Clip1(),ent:GetPrimaryAmmoType(),true)
	ent:SetClip1(0)
end)

function PlayerMeta:RagView()
	local ply = self
	ply:Spectate(OBS_MODE_CHASE)
	ply:SpectateEntity(ply:GetNWEntity("FakeRagdoll"))
	ply:UnSpectate()

	ply:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	ply:SetMoveType(MOVETYPE_OBSERVER)
end

function PlayerMeta:Notify(string)
	self:ChatPrint(tostring(string))
end

function PlayerMeta:ChatPrintLocalized(string)
	net.Start("localized_chat")
    net.WriteString(tostring(string))
    net.Send(self)
end

local weights = {
	["models/css_seb_swat/css_swat.mdl"] = {[1] = 10},
	["models/css_seb_swat/css_seb.mdl"] ={[1] = 10},

	["models/gang_groove/gang_1.mdl"] =		   {[1] = 40},
	["models/gang_groove/gang_2.mdl"] =		   {[1] = 40},
	["models/gang_ballas/gang_ballas_1.mdl"] = {[1] = 40},
	["models/gang_ballas/gang_ballas_2.mdl"] = {[1] = 40},
}

function PlayerMeta:CreateFake(force)
    local rag = ents.Create("prop_ragdoll")
    rag:SetNWEntity("RagdollOwner", self)
    rag:SetModel(self:GetModel())
    rag:SetSkin(self:GetSkin())
    rag:Spawn()
    rag:SetNWEntity("RagdollOwner", self)
    rag:AddEFlags(EFL_NO_DAMAGE_FORCES)
	rag:SetNWVector("PlayerColor",self:GetPlayerColor())
    rag:Activate()

	rag.Inventory = self.Inventory
	rag.JModEntInv = self.JModEntInv
	rag:SetNWEntity("JModEntInv",self.JModEntInv)
	for i = 0,#self:GetBodyGroups() do
		//print(rag:GetBodygroup(i))
		rag:SetBodygroup(i,self:GetBodygroup(i))
	end
	if ROUND_NAME == "dr" then
		self.TimeToDeath = CurTime() + 7
		self:SetNWFloat("TimeToDeath",CurTime() + 7)
	end
	
	rag.Appearance = self.Appearance

	rag:SetNWString("PlayerName",self:Name())
	rag:GetPhysicsObject():SetMass(30)

	if weights[rag:GetModel()] then
		rag:GetPhysicsObject():SetMass(weights[rag:GetModel()][1])
	end

    self.FakeRagdoll = rag

    self:SetNWEntity("FakeRagdoll", rag)
	rag.armor = self.armor

	rag:SetNetVar("Armor",self.armor)

    force = force or Vector(0, 0, 0)
    local vel = self:GetVelocity() + force

    for i = 0, rag:GetPhysicsObjectCount() - 1 do
        local physobj = rag:GetPhysicsObjectNum(i)
        if IsValid(physobj) then
            local ragBoneName = rag:GetBoneName(rag:TranslatePhysBoneToBone(i))
            local bone = self:LookupBone(ragBoneName)

            if bone then
                local vmat = self:GetBoneMatrix(bone)
                if vmat then
                    physobj:SetPos(vmat:GetTranslation(), true)
                    physobj:SetAngles(vmat:GetAngles())
                    physobj:AddVelocity(vel)
                end
            end
        end
    end

    self:RagView()

	local ply = self

	rag.bull = ents.Create("npc_bullseye")
	rag:SetNWEntity("RagdollController", ply)

	local bull = rag.bull
	local eyeatt = rag:GetAttachment(rag:LookupAttachment("eyes"))
	local bodyphy = rag:GetPhysicsObjectNum(10)
	bull:SetPos(eyeatt.Pos)
	--bull:SetPos( eyeatt.Pos + eyeatt.Ang:Up() * 3.5 )
	bull:SetAngles( rag:GetAngles() )
	bull:SetMoveType(MOVETYPE_OBSERVER)
	bull:SetKeyValue( "targetname", "Bullseye" )
	--bull:SetParent(rag, rag:LookupAttachment("eyes"))
	bull:SetKeyValue( "health","9999" )
	bull:SetKeyValue( "spawnflags","256" )
	bull:Spawn()
	bull:Activate()
	bull:SetNotSolid(true)
	for i, ent in ipairs(ents.FindByClass("npc_*")) do
		if not IsValid(ent) or not ent.AddEntityRelationship then continue end
		ent:AddEntityRelationship(bull, ent:Disposition(ply),10000)
	end
	rag:AddFlags(FL_NOTARGET)
	bull.rag = rag
	bull.ply = ply

	-- Обработка урона от падения и жестких ударов о препятствия
	rag:AddCallback("PhysicsCollide", function(r, colData)
		if not IsValid(r) then return end
		local owner = r.RagdollOwner or r:GetNWEntity("RagdollOwner")
		if not IsValid(owner) or not owner:IsPlayer() or not owner:Alive() then return end

		-- Игнорируем столкновения с игроком и другими частями этого же рагдолла
		local hitEnt = colData.HitEntity
		if hitEnt == owner or hitEnt == r or (IsValid(hitEnt) and hitEnt.RagdollOwner == owner) then return end

		-- Вычисляем реальную силу удара (разницу скоростей до и после столкновения)
		local impactSpeed = 0
		if colData.OurOldVelocity and colData.OurNewVelocity then
			impactSpeed = (colData.OurOldVelocity - colData.OurNewVelocity):Length()
		elseif colData.Speed then
			impactSpeed = colData.Speed
		end

		-- Порог реального жесткого удара/падения (от 480 units/s)
		if impactSpeed > 480 then
			local damage = math.floor((impactSpeed - 480) * 0.15)
			if damage >= 2 then
				owner._nextFallDmgTime = owner._nextFallDmgTime or 0
				if CurTime() > owner._nextFallDmgTime then
					owner._nextFallDmgTime = CurTime() + 0.3

					-- Наносим урон напрямую в здоровье игрока
					local curHp = owner:Health()
					local newHp = curHp - damage

					if newHp <= 0 then
						owner:Kill()
					else
						owner:SetHealth(newHp)

						-- Создаем событие урона для хуков
						local dmgInfo = DamageInfo()
						dmgInfo:SetDamage(damage)
						dmgInfo:SetDamageType(DMG_FALL)
						dmgInfo:SetAttacker(game.GetWorld())
						dmgInfo:SetInflictor(game.GetWorld())
						dmgInfo:SetDamagePosition(colData.HitPos)
						hook.Run("EntityTakeDamage", owner, dmgInfo)
					end
				end
			end
		end
	end)

    return rag
end

hook.Add("Think","VelocityFakeHitPlyCheck",function()
	for i,rag in pairs(ents.FindByClass("prop_ragdoll")) do
		if IsValid(rag) then
			if rag.JModEntInv != NULL and IsValid(rag.JModEntInv) then
				rag.JModEntInv:SetPos(rag:GetPos())
			end
			if rag:GetVelocity():Length() > 100 then
				if rag:GetCollisionGroup() ~= COLLISION_GROUP_NONE then
					rag:SetCollisionGroup(COLLISION_GROUP_NONE)
				end
			else
				if rag:GetCollisionGroup() ~= COLLISION_GROUP_WEAPON then
					rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
				end
			end
		end
	end
end)

hook.Add("PlayerSpawn","ResetFake",function(ply) --обнуление регдолла после вставания
	ply:Give("weapon_hands")
	ply.Fake = false
	ply.CanMove = true
	ply:AddEFlags(EFL_NO_DAMAGE_FORCES)

	ply:SetNWBool("Fake",false)

	-- Если остался рагдолл фейка или рагдолл смерти, удаляем его
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
	ply:SetNWEntity("Ragdoll", NULL)

	ply:SetMoveType(MOVETYPE_WALK)
	ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)

	if ply.PLYSPAWN_OVERRIDE then return end
	
	ply.slots = {}
	ply:SetNWEntity("Ragdoll",nil)
end)

hook.Add("Player Think","VelocityPlayerFallOnPlayerCheck",function(ply,time)
	local speed = ply:GetVelocity():Length()
	if ROUND_NAME == "dr" then
		return
	end
	if ply:GetMoveType() != MOVETYPE_NOCLIP and not ply.Fake and not ply:HasGodMode() and ply:Alive() then
		if speed < 650 then return end

		Faking(ply)
	end
end)

hook.Add("WeaponEquip","Homigrad_Fake",function(wep,ply)
	return true
end)

hook.Add("PlayerSwitchWeapon","Homigrad_Fake_Guns",function(ply,oldwep,wep)
	if not IsValid(ply) then return end
	if not ply.Fake then return false end
	if ply.Fake and !weapons.Get(wep.ClassName) then
		return true
	end
	if ply.Fake then return !weapons.Get(wep.ClassName).SupportTPIK end
end)

function Faking(ply,force)
    if not IsValid(ply) then return end

	if ply:Alive() and !ply.CanMove then return end

    if ply.LastRagdollTime and ply.LastRagdollTime > CurTime() then
        return
    end

	if force then
		force = force / 1.25
		force.z = force.z / 2.5
	end

    ply.LastRagdollTime = CurTime() + 1.5

    if not ply.Fake then
		if GetGlobalBool("NoFake") then
			return
		end
		if ply.isZombie then
			return
		end
		--ply:SelectWeapon("weapon_hands")
		ply.FakeWeps = ply:GetWeapons()
		ply.CurWeapon = ply:GetActiveWeapon()
		ply.FakeWep = nil
        ply:CreateFake(force or Vector(0, 0, 0))
		ply:SetNWBool("Fake",ply.Fake)
		ply:SetNWEntity("FakeRagdoll",ply.FakeRagdoll)
		if !ply:GetActiveWeapon().SupportTPIK then
			ply:SetActiveWeapon(nil)
		end
        ply.Fake = true
		ply:SetNoTarget(true)
    else
		if ply:GetNWBool("Cuffed") or IsValid(ply.FakeRagdoll) and ply.FakeRagdoll:GetNWBool("Cuffed") then
			return
		end
		if IsValid(ply.FakeWep) then
			ply.FakeWep:Remove()
		end
		ply.FakeWep = nil
		if IsValid(ply.FakeRagdoll.bull) then
			ply.FakeRagdoll.bull:Remove()
		end

		if ply.FakeRagdoll and constraint.FindConstraints(ply.FakeRagdoll,"Weld") and ply.FakeRagdoll.DuctTape then
			return
		end

		if ply.FakeRagdoll.weld and !table.IsEmpty(ply.FakeRagdoll.weld) then
			return
		end

		if IsValid(ply.FakeRagdoll) and ply.FakeRagdoll:GetVelocity():Length() > 500 then
			return
		end

		local org = ply.organism
		local brokenspine = ply.brokenspine or (org and (org.brokenspine or org.spinebroken))
		if not IsValid(ply) or not ply:Alive() or brokenspine then
		    return
		end

		local pain = ply.pain or (org and org.pain) or 0
		local blood = ply.blood or (org and org.blood) or 5000
		if pain > 50 or blood < 3000 then return end

		ply:SetNoTarget(false)

        local health = ply:Health()
        local armor = ply:Armor()
        local eyeAngles = ply:EyeAngles()
        ply:UnSpectate()
        ply:SetVelocity(Vector(0, 0, 0))

        local spawnPos = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll:GetPos() or (ply:GetPos() + Vector(0, 0, 64))

		if JMod then
        JMod.Иди_Нахуй = true
		end
        ply.PLYSPAWN_OVERRIDE = true
        ply:Spawn()
        ply.CanMove = false
        ply:SetArmor(armor)
        ply:SetHealth(health)
        ply:SetEyeAngles(eyeAngles)
        if JMod then
		JMod.Иди_Нахуй = nil
		end
        ply:SetPos(spawnPos)
		ply.CurWeapon = nil
		ply.FakeShooting = false
        ply.PLYSPAWN_OVERRIDE = false

		if IsValid(ply.FakeRagdoll) then
			ply.FakeRagdoll:Remove()
		end
		local curFake = ply:GetNWEntity("FakeRagdoll")
		if IsValid(curFake) then
			curFake:Remove()
		end
		ply.FakeRagdoll = nil
		ply:SetNWEntity("FakeRagdoll", NULL)

        ply.Fake = false
		ply:SetNWBool("Fake", false)
		ply.CanMove = true
        hg.ragdollFake[ply] = NULL
    end
end

function PlayerMeta:DropWep(wep,pos,vel,suicide)
	local ply = self
	if not vel then
		vel = self:EyeAngles():Forward() * 320
	end
	/*if not pos then
		pos = self:EyePos() - vector_up * 8
	end*/

	if IsValid(ply:GetActiveWeapon()) and not BlackListWep[(wep and wep:GetClass() or ply:GetActiveWeapon():GetClass())] == true then
		if wep == nil then
			wep = ply:GetActiveWeapon()
		end
		ply:SetNWFloat("LastPickup",CurTime() + 0.3)
		wep.IsSpawned = true
		ply:DropWeapon(wep,pos,vel)
		if ply.Fake and ply:Alive() then
			local Mat = ply.FakeRagdoll:GetBoneMatrix(6)
			wep:SetPos(Mat:GetTranslation() + ply:EyeAngles():Forward() * 30)
			wep:SetVelocity(ply:EyeAngles():Forward() * 100)
		end
		return wep
	end
end

hook.Add("PlayerSay","DroppingFunction",function(ply,text)
	if ply:GetActiveWeapon() == NULL and ply:Alive() then return "" end
    if text == "*drop" then
		ply:DropWep(nil,nil,ply:EyeAngles():Forward() * 160)
        return ""
    end
end)

hook.Add("PreCleanupMap","CleanUpFake",function()
	for i, v in pairs(player.GetAll()) do
		v.LastRagdollTime = 0
		if v.Fake then Faking(v) end
	end
	BleedingEntities = {}
end)

RagdollOwner = hg.RagdollOwner

hg.Gibbed = hg.Gibbed or {}

hook.Add("PlayerDeath", "DeathRagdoll", function(ply, att, dmginfo)
	if hg.Gibbed and hg.Gibbed[ply] then return end
	ply.LastRagdollTime = 0
	if !ply.Fake then
		Faking(ply)
	end

	local rag = ply.FakeRagdoll

	timer.Simple(0,function()
		if IsValid(rag.bull) then
			rag.bull:Remove()
		end

		if IsValid(rag.ZacConsRH) then
			rag.ZacConsRH:Remove()
		end
	
		if IsValid(rag.ZacConsLH) then
			rag.ZacConsLH:Remove()
		end
	end)
end)

hook.Add("PlayerUse","KysUseInFake",function(ply)
	if ply.Fake then return false end
end)

hook.Add("PhysgunPickup", "DropPlayer2", function(ply, ent)
	if ent:IsPlayer() then
		-- Не роняем игрока в фейк при взятии физганом
		return true
	end
end)

hook.Add("Player Think","FakeThink",function(ply,time)
	if !ply.Fake then
		local ang = ply:EyeAngles()
		ang.p = 0

		ply:SetAngles(ang)
	end
	if !IsValid(ply:GetActiveWeapon()) and !ply.Fake and ply:Alive() then
		//ply:SelectWeapon("weapon_hands")
	end
	if ply:GetNWBool("Cuffed") then
		ply:SetActiveWeapon(nil)
	end
	ply:SetNWBool("Fake",ply.Fake)
	ply:SetNWEntity("FakeRagdoll",ply.FakeRagdoll)
    if not ply.Fake or not ply:Alive() then ply:SetNWBool("RightArm",false) ply:SetNWBool("LeftArm",false) return end
    local rag = ply.FakeRagdoll
	if not IsValid(rag) then ply:Kill() return end
	if rag == NULL then return end
	rag.Inventory = ply.Inventory
	rag.JModEntInv = ply.JModEntInv
	rag:SetNetVar("Armor",ply.armor)
	rag.armor = ply.armor
	rag:SetNWEntity("JModEntInv",ply.JModEntInv)
	rag:SetNWString("PlayerName",ply:Name())
	if ROUND_NAME == "dr" then
		if ply.TimeToDeath and ply.TimeToDeath < CurTime() then
			ply:Kill()
			rag:Dissolve(2,0,rag:GetPos())
		end
	end
	ply:SetNWBool("RightArm",IsValid(rag.ZacConsRH))
	ply:SetNWBool("LeftArm",IsValid(rag.ZacConsLH))
	local dist = (rag:GetAttachment(rag:LookupAttachment( "eyes" )).Ang:Forward()*10000):Distance(ply:GetAimVector()*10000)
	local distmod = math.Clamp(1-(dist/20000),0.1,1)
	local lookat = LerpVector(distmod,rag:GetAttachment(rag:LookupAttachment( "eyes" )).Ang:Forward()*100000,ply:GetAimVector()*100000)
	local attachment = rag:GetAttachment( rag:LookupAttachment( "eyes" ) )
	local LocalPos, LocalAng = WorldToLocal( lookat, Angle( 0, 0, 0 ), attachment.Pos, attachment.Ang )
	local AddVecRag = Vector(0,0,-64)
	if IsValid(rag.bull) then
		local eyeatt = rag:GetAttachment(rag:LookupAttachment("eyes"))

		rag.bull:SetPos(eyeatt.Pos + eyeatt.Ang:Forward() * 5  + eyeatt.Ang:Up() * -5)
	end
    local Head = rag:LookupBone("ValveBiped.Bip01_Head1")
	if not Head then return end
    local HeadPos = rag:GetBonePosition(Head) + AddVecRag
	if !ply.PrevAng then
		ply.PrevAng = ply:EyeAngles()
	end

	ply.PrevAng = LerpAngleFT(0.1,ply.PrevAng,ply:EyeAngles())

	local ydiff = math.AngleDifference(ply.PrevAng.y,ply:EyeAngles().y)
	local y_diff_round = math.Round(ydiff / 5,1)

	local pdiff = math.AngleDifference(ply.PrevAng.p,ply:EyeAngles().p)
	local p_diff_round = math.Round(pdiff / 5,1)
	ply:SetPos(HeadPos)
	//ply:SetNoDraw(false)
	ply:SetMaterial(rag:GetMaterial())
	local is_otrub = ply.otrub or (ply.organism and ply.organism.otrub)
	if !is_otrub then rag:SetEyeTarget( LocalPos ) else rag:SetEyeTarget( Vector(0,0,0) ) end
	if is_otrub then
		if IsValid(rag.ZacConsRH) then
			rag.ZacConsRH:Remove()
		end
	
		if IsValid(rag.ZacConsLH) then
			rag.ZacConsLH:Remove()
		end
	return
	end
	rag = ply.FakeRagdoll
	
	//ply:SetActiveWeapon(NULL)

	if ply:InVehicle() then
		ply:ExitVehicle()
	end
	ply:SetNWBool("Fake",ply.Fake)
    rag:SetFlexWeight(9,0)

	hook.Run("FakeControl",ply,rag)
end)

hook.Add("PlayerSpawn","collide",function(ply)
	ply:AddCallback("PhysicsCollide",function(ent,data) hook.Run("Player Collide",ply,ent,data) end)
end)

function PlayerMeta:IsStandingOn(ent)
	local tr = {
		start = self:EyePos(),
		endpos = self:EyePos() - vector_up * 82,
		filter = self
	}
	
	local zhopa = util.TraceLine(tr)

	//print(ent,zhopa.Entity)

	if zhopa.Entity == ent then
		return true
	else
		return false
	end

	return false
end

hook.Add("Player Collide","Ragdolling-Collide",function(ply,ent,data)
	local LIMIT_MASS = 100
	local LIMIT_SPEED = 280
	if ROUND_NAME == "dr" then
		return
	end
	-- Сбивание автомобилем
	if ent:IsVehicle() or (ent.Base and string.find(ent.Base, "glide")) or ent.IsGlideVehicle then
		local vehVel = ent:GetVelocity()
		local vehSpeed = vehVel:Length()
		if vehSpeed > 140 then
			HandlePedestrianHit(ent, ply, vehSpeed, vehVel:GetNormalized())
			return
		end
	end

	-- Столкновения с обычными проппами (стулья, коробки и т.д.) не роняют игрока в фейк
end)

-- =========================================================================
-- 1. ВЫЛЕТ ИЗ МАШИНЫ ПРИ СТОЛКНОВЕНИИ / АВАРИИ
-- =========================================================================

local function EjectPlayerFromVehicle(ply, veh, crashSpeed, crashNormal)
	if not IsValid(ply) or not ply:Alive() then return end
	if ply._justEjectedFromCar and ply._justEjectedFromCar > CurTime() then return end
	ply._justEjectedFromCar = CurTime() + 1.5

	local vehVel = veh:GetVelocity()
	local exitPos = veh:GetPos() + Vector(0, 0, 45) + (crashNormal or veh:GetForward()) * 25

	ply:ExitVehicle()
	ply:SetPos(exitPos)

	-- Сила выброса направлена по вектору движения машины с подъемом вверх
	local ejectForce = (vehVel * 1.2) + Vector(0, 0, 150)
	if ejectForce:Length() < 300 then
		ejectForce = (veh:GetForward() * crashSpeed * 1.2) + Vector(0, 0, 150)
	end

	-- Наносим первичный урон от удара машины
	local dmgAmount = math.Clamp((crashSpeed - 350) * 0.08, 5, 60)
	local dmg = DamageInfo()
	dmg:SetDamage(dmgAmount)
	dmg:SetDamageType(DMG_CRUSH)
	dmg:SetAttacker(veh)
	dmg:SetInflictor(veh)
	ply:TakeDamageInfo(dmg)

	-- Вызываем фейк с начальной скоростью выброса
	Faking(ply, ejectForce)

	ply:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", 80, 100)
end

local function HandleVehicleCrash(veh, hitEnt, speed, normal)
	if speed < 380 then return end -- Порог скорости столкновения

	local driver = veh:GetDriver()
	if IsValid(driver) and driver:IsPlayer() then
		EjectPlayerFromVehicle(driver, veh, speed, normal)
	end

	local plys = veh:GetPassengerSeat() and veh:GetPassengerSeat():GetDriver()
	if IsValid(plys) and plys:IsPlayer() then
		EjectPlayerFromVehicle(plys, veh, speed, normal)
	end

	for _, child in ipairs(veh:GetChildren()) do
		if child:IsVehicle() then
			local pass = child:GetDriver()
			if IsValid(pass) and pass:IsPlayer() then
				EjectPlayerFromVehicle(pass, veh, speed, normal)
			end
		end
	end
end

-- Функция удара/сбивания пешехода автомобилем
local function HandlePedestrianHit(veh, ply, hitSpeed, hitDir)
	if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
	if ply:InVehicle() then return end
	if ply._lastCarHitTime and ply._lastCarHitTime > CurTime() then return end
	ply._lastCarHitTime = CurTime() + 0.6

	-- Если скорость меньше 140 (легкий толчок), не сбиваем с ног
	if hitSpeed < 140 then return end

	local dir = hitDir
	if not dir or dir:LengthSqr() == 0 then
		dir = (ply:GetPos() - veh:GetPos()):GetNormalized()
	end
	dir.z = 0
	if dir:LengthSqr() == 0 then dir = veh:GetForward() end
	dir:Normalize()

	-- Сила отлета зависит от скорости машины
	local forwardForce = math.Clamp(hitSpeed * 1.5, 200, 1500)
	local upwardForce = math.Clamp(hitSpeed * 0.8, 120, 600)
	local launchImpulse = (dir * forwardForce) + Vector(0, 0, upwardForce)

	-- Урон от наезда в зависимости от скорости
	local dmgAmount = math.Clamp(math.floor((hitSpeed - 120) * 0.18), 5, 100)
	local dmg = DamageInfo()
	dmg:SetDamage(dmgAmount)
	dmg:SetDamageType(DMG_VEHICLE)
	dmg:SetAttacker(IsValid(veh:GetDriver()) and veh:GetDriver() or veh)
	dmg:SetInflictor(veh)
	dmg:SetDamagePosition(ply:GetPos() + Vector(0, 0, 35))
	dmg:SetDamageForce(launchImpulse * 20)
	ply:TakeDamageInfo(dmg)

	-- Падение в fake
	if not ply.Fake then
		Faking(ply, launchImpulse)
	else
		-- Если уже в фейке, придаем дополнительный импульс его рагдоллу
		local rag = ply.FakeRagdoll or ply:GetNWEntity("FakeRagdoll")
		if IsValid(rag) then
			for i = 0, rag:GetPhysicsObjectCount() - 1 do
				local phys = rag:GetPhysicsObjectNum(i)
				if IsValid(phys) then
					phys:ApplyForceCenter(launchImpulse * phys:GetMass() * 0.5)
				end
			end
		end
	end

	-- Звук глухого удара
	ply:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", 85, math.random(90, 105))
end

-- Отслеживание столкновений для всех транспортов через PhysicsCollide
hook.Add("OnEntityCreated", "ZS_Vehicle_CollisionSetup", function(ent)
	if ent:IsVehicle() or (ent.Base and string.find(ent.Base, "glide")) or ent.IsGlideVehicle then
		timer.Simple(0.2, function()
			if not IsValid(ent) then return end
			ent:AddCallback("PhysicsCollide", function(v, data)
				if not IsValid(v) then return end
				local hitEnt = data.HitEntity
				local speed = data.OurOldVelocity and data.OurOldVelocity:Length() or v:GetVelocity():Length()

				-- 1. Сбивание пешехода
				if IsValid(hitEnt) and hitEnt:IsPlayer() then
					local hitDir = data.OurOldVelocity and data.OurOldVelocity:GetNormalized() or v:GetVelocity():GetNormalized()
					HandlePedestrianHit(v, hitEnt, speed, hitDir)
				end

				-- 2. Авария самого транспорта (вылет водителя/пассажиров при сильном ударе)
				if speed > 380 and hitEnt ~= v then
					HandleVehicleCrash(v, hitEnt, speed, data.HitNormal)
				end
			end)
		end)
	end
end)

-- Дополнительная проверка на резкое торможение/удар транспорта в тике (на случай пропуска коллизий)
hook.Add("Think", "ZS_Vehicle_CrashMonitor", function()
	for _, ply in player.Iterator() do
		if IsValid(ply) and ply:Alive() and ply:InVehicle() and not ply.Fake then
			local veh = ply:GetVehicle()
			if IsValid(veh) then
				local curVel = veh:GetVelocity()
				local curSpeed = curVel:Length()

				veh._prevSpeed = veh._prevSpeed or curSpeed
				local speedDelta = veh._prevSpeed - curSpeed

				-- Резкое падение скорости больше чем на 350 за один тик (врезался в стену/препятствие)
				if speedDelta > 350 then
					HandleVehicleCrash(veh, NULL, veh._prevSpeed, curVel:GetNormalized())
				end

				veh._prevSpeed = curSpeed
			end
		end
	end
end)

-- =========================================================================
-- 2. УРОН В FAKE ПРИ ПАДЕНИИ И СИЛЬНЫХ УДАРАХ РАГДОЛЛА ОБ ЗЕМЛЮ / СТЕНЫ
-- =========================================================================
