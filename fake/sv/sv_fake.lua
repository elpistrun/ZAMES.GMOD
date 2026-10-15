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
	if !hg.RateLimit(ply, "fake", 0.5) then return end
    Faking(ply,ply:GetVelocity())
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

    return rag
end

hook.Add("Think","VelocityFakeHitPlyCheck",function()
	for i,rag in pairs(ents.FindByClass("prop_ragdoll")) do
		if IsValid(rag) then
			if rag.JModEntInv != NULL and IsValid(rag.JModEntInv) then
				rag.JModEntInv:SetPos(rag:GetPos())
			end
			if rag:GetVelocity():Length() > 100 then
				rag:SetCollisionGroup(COLLISION_GROUP_NONE)
			else
				rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			end
		end
	end
end)

hook.Add("PlayerSpawn","ResetFake",function(ply) --обнуление регдолла после вставания
	ply:Give("weapon_hands")
	ply.Fake = false
	ply:AddEFlags(EFL_NO_DAMAGE_FORCES)

	ply:SetNWBool("Fake",false)

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
        ply:CreateFake((force or ply:GetVelocity() / 3))
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

		if not IsValid(ply) or not ply:Alive() or (ply and ply.brokenspine) then
		    return
		end

		if ply.pain>50 or ply.blood<3000 then return end

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

		ply.FakeRagdoll:Remove()

        ply.Fake = false
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

hg.Faking = Faking

hook.Add("PlayerDeath", "DeathRagdoll", function(ply, att, dmginfo)
	if hg.Gibbed[ply] then return end
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

hook.Add("PhysgunPickup", "DropPlayer2", function(ply,ent)
		if ent:IsPlayer() and !ent.Fake and ply:IsSuperAdmin() then

			ent.isheld=true

			Faking(ent)
			return false
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
	if !ply.otrub then rag:SetEyeTarget( LocalPos ) else rag:SetEyeTarget( Vector(0,0,0) ) end
	if ply.otrub then
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
	if (ent:GetVelocity():Length() > LIMIT_SPEED or ent:GetPhysicsObject():GetMass() > LIMIT_MASS and ent:GetVelocity():Length() > LIMIT_SPEED / 2) and ent != ply and !ply:IsStandingOn(ent) then
		//print(!ply:IsStandingOn(ent))
		timer.Simple(0,function()
			if not IsValid(ply) or ply.Fake then return end
			if ent:IsPlayerHolding() then
				return 
			end
			Faking(ply)
		end)
	end
end)