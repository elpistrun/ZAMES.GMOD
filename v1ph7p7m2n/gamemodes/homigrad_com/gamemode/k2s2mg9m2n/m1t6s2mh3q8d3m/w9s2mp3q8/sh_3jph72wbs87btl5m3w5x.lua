--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/m1t6s2mh3q8d3m/w9s2mp3q8/sh_3jph72wbs87btl5m3w5x.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:26
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

AddCSLuaFile()
-- Mighty Foot Engaged (cleaned + Charge Mechanics)
-- Removes all clientside leg model creation while preserving third-person animations and server logic.

-- Sounds (unchanged)
sound.Add({
    name = "mightyfoot.kickbody",
    channel = CHAN_AUTO,
    level = 70,
    volume = 1,
    pitch = {80, 110},
    sound = "zames/player/smod_kick/foot_kickbody.wav"
})

sound.Add({
    name = "mightyfoot.kickwall",
    channel = CHAN_AUTO,
    level = 70,
    volume = 1,
    pitch = {80, 110},
    sound = "zames/player/smod_kick/foot_kickwall.wav"
})

sound.Add({
    name = "mightyfoot.fire",
    channel = CHAN_AUTO,
    level = 65,
    volume = 1,
    pitch = {80, 110},
    sound = "zames/player/smod_kick/foot_fire.wav"
})

sound.Add({
    name = "mightyfoot.kickdoor",
    channel = CHAN_AUTO,
    level = 80,
    volume = 1,
    pitch = {90, 110},
    sound = {"physics/wood/wood_furniture_break1.wav", "physics/wood/wood_furniture_break2.wav", "physics/wood/wood_panel_break1.wav"}
})

util.PrecacheSound("mightyfoot.kickbody")
util.PrecacheSound("mightyfoot.kickwall")
util.PrecacheSound("mightyfoot.fire")

local cvarflags = FCVAR_REPLICATED+FCVAR_ARCHIVE
local cvarnotify = cvarflags+FCVAR_NOTIFY

local cvartable = {
    mf_powerscale = {"1", cvarflags, "Multiply EVERY value by this much.", 1.00} ,
    mf_simpletrace = {"0", cvarflags, "Use the player's eye position for the kick instead of the middle point.", 0, 1},
    mf_dropkickmult = {"2.00", cvarflags, "Kicking mid-air multiplies damage by this much.", 1.00},
    mf_kickrange = {"1.00", cvarflags, "Range multiplier for the kick. Relative to player hull height.", 0},
    mf_kickdelay = {"0.5", cvarflags, "Minimum delay between kicks.", 0},
    mf_kickspeed = {"1", cvarflags, "Kick speed multiplier.", 0.1, 5},
    mf_blowdoorlocked = {"0", cvarflags, "Allow blowing off locked doors.", 0, 1},
    mf_blowdoorsliding = {"0", cvarflags, "Allow blowing off sliding doors.", 0, 1},
    mf_blowdoorchance = {"20", cvarflags, "Chance, in %, to blow a door off its hinges. 0 to disable.", 0, 100},
    mf_blowdoorgib = {"0", cvarflags, "Instantly gib unhinged doors.", 0, 1},
    mf_blowdoorgibcount = {"10", cvarflags, "Amount of gibs to create.", 0, 32},
    mf_blowdoorforce = {"1", cvarflags, "Multiply the door blowing force by this much.", 0},
    mf_doorkick = {"1", cvarflags, "Enable opening doors by kicking.", 0, 1},
    mf_doorkickany = {"0", cvarflags, "Enable opening ANY door entity by kicking.", 0, 1},
    mf_slowdown = {"0", cvarflags, "Slow down players while kicking.", -1, 2},
    mf_effect = {"1", cvarflags, "The dust effect from kicking static stuff.", 0, 1},
    mf_maxdamage = {"30", cvarflags, "The maximum damage a kick will deal.", 0},
    mf_mindamage = {"20", cvarflags, "The minimum damage a kick will deal.", 0},
    mf_disarm_player = {"0", cvarflags, "Enable disarming kicked players.", 0, 1},
    mf_disarm_npc = {"0", cvarflags, "Enable disarming kicked NPCs.", 0, 1},
    mf_unlock = {"0", cvarflags, "Enable unlocking locked doors via kick.", 0, 1},
    mf_physforce = {"1", cvarflags, "Strength multiplier for most physics interactions.", 0},
    mf_hitshake = {"0", cvarflags, "The shake effect from kicking something.", 0, 1},
    mf_viewpunchscale = {"1", cvarflags, "The strength of the viewpunch effect."},
    mf_ragforce = {"1", cvarflags, "Strength multiplier for ragdoll interactions.", 0},
    mf_doorrespawntime = {"25", cvarflags, "The time it takes for a blown door to respawn.", 1},
    mf_doordamage = {"0", cvarflags, "Whether certain types of doors should deal damage when kicked open.", 0, 1},
    mf_damagebyspeed = {"0", cvarflags, "Enable bonus damage calculation by player velocity.", 0, 1},
    mf_damagebyspeedmult = {"1", cvarflags, "The amount by which the bonus damage is divided.", 0},
    mf_projectileparry = {"0", cvarflags, "Parry any projectiles with a kick.", 0, 1},
    mf_projectileparrymult = {"1", cvarflags, "Parry force multiplier.", 0},
    mf_propscaledforce = {"0", cvarflags, "Enable kicking any prop at strength relative to its mass.", 0, 1},
    mf_pushback = {"100", cvarflags, "The amount of knockback you get from kicking."},
    mf_heldpropkick = {"1", cvarflags, "Enable kicking entities being held by players.", 0, 1},
    mf_trollphysics = {"0", cvarflags, "Cover yourself in oil.", 0, 1},
    mf_kickholster = {"0", cvarflags, "Holster your weapon while kicking.", 0, 1},
    mf_kickfast = {"0", cvarflags, "Allows you to kick again as soon as it should land.", 0, 1},
}

local powerscale = CreateConVar("mf_powerscale", "1", cvarflags, "Multiply EVERY value by this much.", 1.00)
local simpletrace = CreateConVar("mf_simpletrace", "0", cvarflags, "Use the player's eye position for the kick instead of the middle point.", 0, 1)
local dropkickmult = CreateConVar("mf_dropkickmult", "2.00", cvarflags, "Kicking mid-air multiplies damage by this much.", 1.00)
local kickrange = CreateConVar("mf_kickrange", "1.00", cvarflags, "Range multiplier for the kick. Relative to player hull height.", 0.1)
local kickdelay = CreateConVar("mf_kickdelay", "0.5", cvarflags, "Minimum delay between kicks.", 0)
local kickspeed = CreateConVar("mf_kickspeed", "1", cvarflags, "Kick speed multiplier.", 0.1, 5)
local blowdoorlocked = CreateConVar("mf_blowdoorlocked", "0", cvarflags, "Allow blowing off locked doors.", 0, 1)
local blowdoorsliding = CreateConVar("mf_blowdoorsliding", "0", cvarflags, "Allow blowing off sliding doors.", 0, 1)
local blowdoorchance = CreateConVar("mf_blowdoorchance", "20", cvarflags, "Chance, in %, to blow a door off its hinges. 0 to disable.", 0, 100)
local doorgib = CreateConVar("mf_blowdoorgib", "0", cvarflags, "Instantly gib unhinged doors.", 0, 1)
local doorgibcount = CreateConVar("mf_blowdoorgibcount", "10", cvarflags, "Amount of gibs to create.", 0, 32)
local blowdoorforce = CreateConVar("mf_blowdoorforce", "1", cvarflags, "Multiply the door blowing force by this much.", 0)
local doorkick = CreateConVar("mf_doorkick", "1", cvarflags, "Enable opening doors by kicking.", 0, 1)
local doorkickany = CreateConVar("mf_doorkickany", "0", cvarflags, "Enable opening ANY door entity by kicking.", 0, 1)
local slowdown = CreateConVar("mf_slowdown", "0", cvarflags, "Slow down players while kicking.", -1, 2)
local effect = CreateConVar("mf_effect", "1", cvarflags, "The dust effect from kicking static stuff.", 0, 1)
local maxdamage = CreateConVar("mf_maxdamage", "30", cvarflags, "The maximum damage a kick will deal.", 0)
local mindamage = CreateConVar("mf_mindamage", "20", cvarflags, "The minimum damage a kick will deal.", 0)
local disarmply = CreateConVar("mf_disarm_player", "0", cvarflags, "Enable disarming kicked players.", 0, 1)
local disarmnpc = CreateConVar("mf_disarm_npc", "0", cvarflags, "Enable disarming kicked NPCs.", 0, 1)
local unlock = CreateConVar("mf_unlock", "0", cvarflags, "Enable unlocking locked doors via kick.", 0, 1)
local physforce = CreateConVar("mf_physforce", "1", cvarflags, "Strength multiplier for most physics interactions.", 0)
local hitshake = CreateConVar("mf_hitshake", "0", cvarflags, "The shake effect from kicking something.", 0, 1)
local viewpunchscale = CreateConVar("mf_viewpunchscale", "1", cvarflags, "The strength of the viewpunch effect.")
local ragforce = CreateConVar("mf_ragforce", "1", cvarflags, "Strength multiplier for ragdoll interactions.", 0)
local doorrespawntime = CreateConVar("mf_doorrespawntime", "25", cvarflags, "The time it takes for a blown door to respawn.", 1)
local doordamage = CreateConVar("mf_doordamage", "0", cvarflags, "Whether certain types of doors should deal damage when kicked open.", 0, 1)
local damagebyspeed = CreateConVar("mf_damagebyspeed", "0", cvarflags, "Enable bonus damage calculation by player velocity.", 0, 1)
local damagebyspeedmult = CreateConVar("mf_damagebyspeedmult", "1", cvarflags, "The amount by which the bonus damage is divided.", 0)
local parry = CreateConVar("mf_projectileparry", "0", cvarflags, "Parry any projectiles with a kick.", 0, 1)
local parrymult = CreateConVar("mf_projectileparrymult", "1", cvarflags, "Parry force multiplier.", 0)
local propscaledforce = CreateConVar("mf_propscaledforce", "0", cvarflags, "Enable kicking any prop at strength relative to its mass.", 0, 1)
local pushback = CreateConVar("mf_pushback", "100", cvarflags, "The amount of knockback you get from kicking.")
local heldpropkick = CreateConVar("mf_heldpropkick", "1", cvarflags, "Enable kicking entities being held by players.", 0, 1)
local trollphysics = CreateConVar("mf_trollphysics", "0", cvarflags, "Cover yourself in oil.", 0, 1)
local kickholster = CreateConVar("mf_kickholster", "0", cvarflags, "Holster your weapon while kicking.", 0, 1)
local kickfast = CreateConVar("mf_kickfast", "0", cvarflags, "Allows you to kick again as soon as it should land.", 0, 1)

local tick = engine.TickInterval()

if SERVER then
    util.AddNetworkString("MF_ChargeStart")
    util.AddNetworkString("MF_ChargeRelease")

    net.Receive("MF_ChargeStart", function(len, ply)
        ply.MFChargeStartTime = CurTime()
    end)

    net.Receive("MF_ChargeRelease", function(_, ply)
        if not IsValid(ply) or not ply:IsPlayer() then return end
        
        local start = ply.MFChargeStartTime or CurTime()
        local charge = math.Clamp((CurTime() - start) / 1.0, 0, 1)
        ply.MFChargeStartTime = nil
        
        MightyFootEngaged(ply, charge)
    end)
end

if CLIENT then
    local notify = CreateClientConVar("mf_notify", "1", true, true, "Notifications about the convar menu.", 0, 1)

    hook.Add("PopulateToolMenu", "AddMightyFootOptions", function()
        spawnmenu.AddToolMenuOption("Options", "Chen's Addons", "mf_options", "Mighty Foot", "", "", function(panel)
            local cl, sv, anim, phys, door = vgui.Create("DForm"), vgui.Create("DForm"), vgui.Create("DForm"), vgui.Create("DForm"), vgui.Create("DForm")
            cl:SetName("Client Options")
            sv:SetName("Server Options")
            anim:SetName("Animation")
            phys:SetName("Physics")
            door:SetName("Door Interaction")

            panel:AddItem(cl)
            panel:AddItem(sv)

            cl:Help("Basic client configuration for Mighty Foot.")
            cl:CheckBox("Show configuration notifications", "mf_notify")
            cl:Button("Reset client settings", "mf_reset_cl")

            anim:Help("Third-person animation support only. First-person leg models are disabled in this build.")
            anim:Help("Requires either xdReanims, DynaBase, or WiltOS Extended Animations for advanced gestures.")
            anim:ControlHelp("Animations automatically switch based on crouch, jump, and pitch angles.")

            sv:CheckBox("Enable dust effect", "mf_effect")
            sv:CheckBox("Enable screen shake on hit", "mf_hitshake")
            sv:NumSlider("Viewpunch Scale", "mf_viewpunchscale", 0, 2, 1)
            sv:NumSlider("Kick Delay", "mf_kickdelay", 0, 10, 2)
            sv:NumSlider("Kick Speed", "mf_kickspeed", 0.1, 5, 2)
            sv:NumSlider("Min Damage", "mf_mindamage", 0, 1000, 0)
            sv:NumSlider("Max Damage", "mf_maxdamage", 0, 1000, 0)
            sv:NumSlider("Kick Range", "mf_kickrange", 0.1, 5, 2)
            sv:NumSlider("Dropkick Multiplier", "mf_dropkickmult", 1, 5, 2)
            sv:CheckBox("Quick Kick (KickFast)", "mf_kickfast")
            sv:CheckBox("Holster weapon during kick", "mf_kickholster")
			
            local slowdown = sv:ComboBox("Player Slowdown During Kick", "mf_slowdown")
            slowdown:SetSortItems(false)
            slowdown:AddChoice("No Slowdown", -1)
            slowdown:AddChoice("Jog Speed", 0)
            slowdown:AddChoice("Walk Speed", 1)
            slowdown:AddChoice("Full Stop", 2)

            phys:NumSlider("Kick Force Multiplier", "mf_physforce", 0, 25, 2)
            phys:NumSlider("Ragdoll Force", "mf_ragforce", 0, 25, 2)
            phys:NumSlider("Player Pushback", "mf_pushback", 0, 1000, 0)
            phys:CheckBox("Mass-scaled Prop Kicks", "mf_propscaledforce")
            phys:CheckBox("Allow kicking held props", "mf_heldpropkick")

            door:CheckBox("Enable Door Kicking", "mf_doorkick")
            door:CheckBox("Allow Unlocking Doors", "mf_unlock")
            door:NumSlider("Door Blow Chance (%)", "mf_blowdoorchance", 0, 100, 0)
            door:NumSlider("Door Respawn Time (s)", "mf_doorrespawntime", 1, 600, 0)
            door:NumSlider("Door Blow Force", "mf_blowdoorforce", 0, 25, 2)
            door:CheckBox("Enable Door Gibbing", "mf_blowdoorgib")
            door:NumSlider("Door Gib Count", "mf_blowdoorgibcount", 0, 32, 0)
            door:CheckBox("Enable Door Damage", "mf_doordamage")
            door:CheckBox("Allow Blowing Locked Doors", "mf_blowdoorlocked")
            door:CheckBox("Allow Blowing Sliding Doors", "mf_blowdoorsliding")
            door:CheckBox("Kick Any Door Entity", "mf_doorkickany")

            panel:AddItem(anim)
            panel:AddItem(phys)
            panel:AddItem(door)

            sv:Button("Reset Server Settings", "mf_reset_sv")
        end)
    end)
	
    function MFResetCL()
        if legmodel then legmodel:Revert() end
        notify:Revert()
        print("Clientside kicking variables have been reset!")
    end
    concommand.Add("mf_reset_cl", MFResetCL, nil, "Reset all clientside values to default. This is irreversible!", {FCVAR_SERVER_CANNOT_QUERY})

	-- CLIENTSIDE STANCE LOCK
	if CLIENT then
		local mfLockUntil = 0
		local mfForceStance = nil

		net.Receive("MF_StanceLock", function()
			mfForceStance = net.ReadString()
			local speed = math.max(kickspeed:GetFloat(), 0.01)
			local duration = 0.9 / speed
			mfLockUntil = CurTime() + duration
		end)

		hook.Add("CreateMove", "MF_ForceClientStance", function(cmd)
			if CurTime() > mfLockUntil then return end
			if not mfForceStance then return end

			local ply = LocalPlayer()
			if not IsValid(ply) then return end

			if mfForceStance == "crouch" then
				cmd:AddKey(IN_DUCK)
			elseif mfForceStance == "stand" then
				cmd:RemoveKey(IN_DUCK)
			elseif mfForceStance == "air" then
				cmd:RemoveKey(IN_JUMP)
			end
		end)
	end

	if CLIENT then
        local MF_MaxChargeTime = 2.0
        local MF_IsCharging = false
        local MF_ChargeStart = 0

		concommand.Add("+zs_kick", function()
            local ply = LocalPlayer()
            local rag = ply:GetNWEntity("FakeRagdoll")
            if not ply:Alive() then return end
            if IsValid(rag) then return end

            local ct = CurTime()
            if ply.MFNextKick and ply.MFNextKick > ct then return end

            MF_IsCharging = true
            MF_ChargeStart = CurTime()
			net.Start("MF_ChargeStart")
			net.SendToServer()
		end)

        concommand.Add("-zs_kick", function()
            if not MF_IsCharging then return end
            MF_IsCharging = false
            net.Start("MF_ChargeRelease")
            net.SendToServer()
        end)

        hook.Add("HUDPaint", "MF_DrawChargeBar", function()
            if not MF_IsCharging then return end
            
            local frac = math.Clamp((CurTime() - MF_ChargeStart) / MF_MaxChargeTime, 0, 1)
            local w, h = 200, 15
            local x, y = ScrW() / 2 - w / 2, ScrH() / 1.3

            if frac >= 1 then
                x = x + math.random(-3, 3)
                y = y + math.random(-3, 3)
            end

            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(x, y, w, h)

            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawRect(x + 2, y + 2, (w - 4) * frac, h - 4)
        end)
	end

    local function MFInitStateClient()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        local time = 0.3 / math.max(kickspeed:GetFloat(), 0.0001)
        ply.MFKickTime = 0
        ply.MFNextKick = (ply.MFKickTime or 0) + time
        ply.MFDrawTime = 0
    end
    hook.Add("InitPostEntity", "MFInitStateClient", MFInitStateClient)
    hook.Add("PlayerSpawn", "MFInitStateClientSpawn", MFInitStateClient)

    hook.Add("StartCommand", "MFMoveHook_Client", function(ply, cmd)
        if ply ~= LocalPlayer() then return end
        local stopmove = slowdown:GetInt()
        local time = (ply.MFKickTime or 0) + (0.6 / math.max(kickspeed:GetFloat(), 0.0001))
        if time > CurTime() then
            if kickholster:GetBool() then
                cmd:ClearButtons()
            end
            local mt = ply:GetMoveType()
            if stopmove >= 0 and mt ~= MOVETYPE_NOCLIP then
                if stopmove == 2 then
                    cmd:ClearMovement()
                elseif stopmove == 1 then
                    cmd:AddKey(IN_WALK)
                end
                cmd:RemoveKey(IN_SPEED)
            end
        end
    end)
end

if SERVER then
    hook.Add("SetupMove", "MF_SlowdownHandler", function(ply, mv, cmd)
        if not IsValid(ply) or not ply:IsPlayer() then return end
        local stopmove = slowdown:GetInt()
        if stopmove < 0 then return end 
        local speedMult = 1
        local kickspeed = kickspeed:GetFloat()
        local activeWindow = (ply.MFKickTime or 0) + (0.6 / math.max(kickspeed, 0.0001))
        if CurTime() < activeWindow then
            if stopmove == 2 then
                mv:SetForwardSpeed(0)
                mv:SetSideSpeed(0)
                return
            elseif stopmove == 1 then
                speedMult = ply:GetWalkSpeed() / ply:GetRunSpeed()
            elseif stopmove == 0 then
                speedMult = 0.6
            end
            mv:SetMaxClientSpeed(ply:GetRunSpeed() * speedMult)
            mv:SetMaxSpeed(ply:GetRunSpeed() * speedMult)
        end
    end)
end


local function MFEffect(tr, sf)
    if effect:GetBool() then
        local fx = EffectData()
        fx:SetStart(tr.HitPos)
        fx:SetOrigin(tr.HitPos)
        fx:SetNormal(tr.HitNormal)
        util.Effect(string.find(sf.name, "glass") and "GlassImpact" or "mf_groundhit", fx)
    end
end

if SERVER then
    local hullvec, offvec = Vector(4, 4, 4), Vector(0,0,16)
    local movetypo = { false, false, false, true, true, true}
    local DoorClasses = {
        prop_door_rotating = true,
        func_door = true,
        func_door_rotating = true
    }

    util.AddNetworkString("MFDoorBust")
	util.AddNetworkString("MF_StanceLock")

    function MFHit(ply, charge)
        charge = charge or 1
        ply:LagCompensation(true)
        local dropkicking = (!ply:OnGround() and ply:WaterLevel() < 2) and ply:GetMoveType() ~= MOVETYPE_LADDER and ply:GetMoveType() ~= MOVETYPE_NOCLIP
        
        -- Урон масштабируется от заряда (минимум 10% урона при клике)
        local damage = string.find(engine.ActiveGamemode(), "nzombies") and (30 + (45 / nzRound:GetNumber()) or 75) or math.random(mindamage:GetFloat(), maxdamage:GetFloat()) * powerscale:GetFloat() * (dropkicking and dropkickmult:GetFloat() or 1)
        damage = damage * math.max(0.1, charge)

        local _, b = ply:GetHull()
        local pos = simpletrace:GetBool() and ply:EyePos() or ply:WorldSpaceCenter()
        local dist = (ply:GetEyeTraceNoCursor().HitPos - pos):GetNormalized() * (b.z * kickrange:GetFloat())
		local aimvector = ply:GetAimVector() * powerscale:GetFloat() * (dropkicking and dropkickmult:GetFloat() or 1)
		local pitch = ply:EyeAngles().pitch

		if pitch < -1 then
			dist = ply:GetForward() * (b.z * kickrange:GetFloat())
		else
			dist = (ply:GetEyeTraceNoCursor().HitPos - pos):GetNormalized() * (b.z * kickrange:GetFloat())
		end

        local trable = {
            start = pos,
            endpos = pos + dist,
            filter = {ply},
            mins = -hullvec,
            maxs = hullvec,
            mask = 1174421515
        }
        local trace = util.TraceLine(trable)
        if not trace.Hit then trace = util.TraceHull(trable) end

        local velocity = ply:GetVelocity():Length()

        if trace.Hit and not trace.HitSky then
            local ent, dir = trace.Entity, LerpVector(0.5, trace.Normal, aimvector)
            local entclass = ent:GetClass()
            local phys = IsValid(ent:GetPhysicsObjectNum(trace.PhysicsBone)) and ent:GetPhysicsObjectNum(trace.PhysicsBone) or IsValid(ent:GetPhysicsObject()) and ent:GetPhysicsObject()
            local isliving = (ent:IsPlayer() or ent:IsNextBot() or ent:IsNPC())
            local physcalc = dir * (propscaledforce:GetBool() and phys and phys:GetMass() or ply:GetPhysicsObject():GetMass()) ^ 2
            
            local force = physcalc * physforce:GetFloat() * charge
            local ragf = physcalc * ragforce:GetFloat() * charge

            if damagebyspeed:GetBool() then
                local speed1, speed2 = ent:GetVelocity():Length() > 0 and ent:GetVelocity():Length(), velocity > 0 and velocity
                local formula, formula2, formula3 = damage * (ent:GetVelocity():GetNormalized() - trace.Normal):Length() , damage * (ply:GetVelocity():GetNormalized() + trace.Normal):Length(), speed1 and speed2 and speed2 / speed1 or 0.5
                damage = (formula + formula2) * 0.5 * damagebyspeedmult:GetFloat()
            end

            local kickinfo = DamageInfo()
            kickinfo:SetDamage(damage)
            kickinfo:SetDamageForce((ent:IsRagdoll() or isliving) and ragf or force)
            kickinfo:SetAttacker(ply)
            kickinfo:SetInflictor(ply)
            kickinfo:SetDamagePosition(trace.HitPos)
            kickinfo:SetReportedPosition(trace.StartPos)
            kickinfo:SetDamageType(DMG_CLUB)
            kickinfo:SetDamageCustom(67)

            if hitshake:GetBool() then
                util.ScreenShake(trace.HitPos, 5, 100, 0.5, 100)
            end

            local surfprop = util.GetSurfaceData(trace.SurfaceProps) or util.GetSurfaceData(0)
            local sndpos = trace.HitPos + trace.HitNormal * 4
            if string.find(surfprop.name, "flesh") or string.find(surfprop.name, "antlion") then
                sound.Play("mightyfoot.kickbody", sndpos, 65, math.random(90, 110), 1)
            else
                MFEffect(trace, surfprop)
                sound.Play("mightyfoot.kickwall", sndpos, 65, math.random(90, 110), 1)
            end

            sound.Play(surfprop.impactSoftSound, sndpos, 65, math.random(90, 110), 1)

            if string.find(engine.ActiveGamemode(), "nzombies") then
                if ent:IsNextBot() or ent:IsNPC() then
                    kickinfo:SetDamageForce(ragf)
                    ent:TakeDamageInfo(kickinfo)
                elseif entclass == "func_breakable_surf" then
                    ent:Fire("Shatter", "0.5 0.5 256")
                end
            end

            local pushbackamt = aimvector * -pushback:GetFloat()

            if movetypo[ent:GetMoveType()] then
                ent:SetPhysicsAttacker(ply, 3)
                if ent:IsPlayerHolding() then
                    if heldpropkick:GetBool() then
                        ent:ForcePlayerDrop()
                    end
                    if ent:GetPhysicsAttacker() == ply and not trollphysics:GetBool() then
                        pushbackamt = vector_origin
                    end
                elseif parry:GetBool() and (ent:GetVelocity() + ent:GetBaseVelocity()):LengthSqr() >= 10000 then
                    kickinfo:SetDamage(0)
                    dir = ply:GetAimVector()
                    if phys then
                        if ent:GetInternalVariable("m_bLaunched") then
                            phys:ClearGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG)
                            phys:AddGameFlag(FVPHYSICS_DMG_DISSOLVE+FVPHYSICS_HEAVY_OBJECT)
                        end
                        phys:SetVelocity(dir * phys:GetVelocity():Length() * parrymult:GetFloat())
                        phys:SetAngleVelocity(-phys:GetAngleVelocity())
                    else
                        ent:SetVelocity(dir * (ent:GetVelocity():Length() + ent:GetBaseVelocity():Length()))
                    end
                    if not isliving then ent:SetOwner(ply) end
                end
            end

            if not ent:IsWorld() then
                local is_valid_target = false
                if isliving then
                    is_valid_target = not (ent:IsPlayer() and ent:HasGodMode())
                elseif ent:GetClass() == "prop_ragdoll" then
                    is_valid_target = true
                end

                if is_valid_target then
                    local dmginfo = DamageInfo()
                    dmginfo:SetDamage(5 * charge)
                    
                    dmginfo:SetAttacker(ply) 
                    dmginfo:SetInflictor(ply)
                    dmginfo:SetDamageType(DMG_CLUB)
                    
                    ent:TakeDamageInfo(dmginfo)

                    if isliving and charge >= 0.99 and ent.Faking then
                        ent:Faking(0) 

                        local victim = ent
                        timer.Simple(0, function()
                            if IsValid(victim) and IsValid(victim.FakeRagdoll) then
                                local rag = victim.FakeRagdoll
                                local physObj = rag:GetPhysicsObject()
                                
                                if IsValid(physObj) then
                                    physObj:AddVelocity(ragf * 0.3)
                                end
                            end
                        end)
                    end
                end
            end

            ply:SetVelocity(pushbackamt)

            if string.find(entclass, "button") then
                ent:Use(ply)
            elseif entclass == "func_breakable_surf" then
                ent:Fire("Shatter", "0.5 0.5 256")
            elseif doorkick:GetBool() and DoorClasses[(IsValid(ent:GetMoveParent()) and ent:GetMoveParent():GetClass()) or entclass] then
                
                -- Требуем хотя бы 50% заряда чтобы взаимодействовать с дверью
                if charge < 0.5 then return end 

                local door = IsValid(ent:GetMoveParent()) and ent:GetMoveParent() or ent
                local class = door:GetClass()
                local slider = class == "func_door"
                if not ( (string.find(class, "func") and door:HasSpawnFlags(256+1024)) or (string.find(class, "prop") and not door:HasSpawnFlags(32768)) or doorkickany:GetBool() ) then return end
                ply.oldname = ply:GetName()
                ply:SetName("kickingpl" .. ply:EntIndex())

                if unlock:GetBool() and door:GetInternalVariable("m_bLocked") then
                    door:SetSaveValue("m_bLocked", false)
                end

                if (blowdoorlocked:GetBool() or not door:GetInternalVariable("m_bLocked")) and (not slider or blowdoorsliding:GetBool()) and (blowdoorchance:GetBool() and math.Rand(0, 100) <= blowdoorchance:GetInt()) then
                    -- Ломаем дверь только при 100% заряде
                    if charge >= 0.99 then 
                        local prop = MFDoorBust(door, ent)
                        if prop then
                            prop:SetPhysicsAttacker(ply, 3)
                            prop:GetPhysicsObject():ApplyForceOffset(physcalc * blowdoorforce:GetFloat(), LerpVector(0.75,pos,prop:WorldSpaceCenter())+offvec)
                        end
                    end
                end

                local oldSpeed, oldDist = door:GetInternalVariable("m_flSpeed") or 100, door:GetInternalVariable("m_flDistance") and door:GetInternalVariable("m_flDistance") or 90
                local oldDirection = door:GetInternalVariable("opendir")
                local oldDmg = door:GetInternalVariable("dmg")
                local flags = door:GetSpawnFlags()

                if not (door:GetInternalVariable("m_toggle_state") == 0 or door:GetInternalVariable("m_eDoorState") == 2) and not door:GetInternalVariable("m_bLocked") then
                    sound.Play("MetalVent.ImpactHard", door:WorldSpaceCenter(), 80, math.random(90, 110), 1)
                    local snd = CreateSound(door, "mightyfoot.kickdoor")
                    snd:Play()
                    snd:FadeOut(not slider and 1 or 0)
                    door:SetKeyValue("speed", oldSpeed*5)
                    door:Fire("close", "kickingpl" .. ply:EntIndex())
                    if string.find(class, "func") then
                        if not door:GetNWBool("dooropened") then
                            door:Use(ply)
                            door:SetNWBool("dooropened", true)
                        end
                        if door:HasSpawnFlags(18) then
                            door:SetSaveValue("m_vecAngle2", door:HasSpawnFlags(2) and -door:GetInternalVariable("m_vecAngle2") or door:GetInternalVariable("m_vecAngle2"))
                            door:SetKeyValue("spawnflags", flags - (door:HasSpawnFlags(16) and 16 or 0))
                            timer.Simple(0.015, function()
                                door:SetKeyValue("spawnflags", flags)
                                door:SetSaveValue("m_vecAngle2", door:HasSpawnFlags(2) and -door:GetInternalVariable("m_vecAngle2") or door:GetInternalVariable("m_vecAngle2"))
                            end)
                        end
                        door:Fire("open", "kickingpl" .. ply:EntIndex())
                        door:SetKeyValue("speed", oldSpeed)
                    else
                        door:SetKeyValue("opendir", 0)
                        door:Fire("openawayfrom", "kickingpl" .. ply:EntIndex())
                        timer.Simple(((oldDist / oldSpeed)), function()
                            if not IsValid(door) then return end
                            door:SetKeyValue("spawnflags", flags)
                            door:SetKeyValue("speed", oldSpeed)
                            door:SetKeyValue("opendir", oldDirection)
                            if timer.Exists("MFDoorTimer"..door:EntIndex()) then return end
                            door.MFKickedDown = false
                        end)
                    end
                    door.MFKickedDown = true
                end

                if doordamage:GetBool() then
                    door:SetKeyValue("dmg", oldSpeed * 0.5)
                    timer.Simple(0.25, function()
                        if not IsValid(door) then return end
                        door:SetKeyValue("dmg", oldDmg or 0)
                    end)
                end
            end
        end
        ply:LagCompensation(false)
    end

    hook.Add( "AcceptInput", "MFBlockInput", function( ent, name, activator, caller, data )
        if DoorClasses[ent:GetClass()] and (activator:IsPlayer() or activator:IsNPC() or activator:IsNextBot()) and ent.MFKickedDown then
            return true
        end
    end )

    function MFDoorBust(door, ent)
        local rety = door:GetClass() == "prop_door_rotating" and "returndelay" or "m_flWait"
        local object = door == ent and door or ent
        if IsValid(object:GetPhysicsObject()) then
            local pos = object:GetPos()
            local ang = object:GetAngles()
            local model = object:GetModel()
            local skin = object:GetSkin()
            local bg = object:GetBodygroup(1)
            local rendermode = object:GetRenderMode()
            local renderfx = object:GetRenderFX()
            local color = object:GetColor()
            local resettime = door:GetInternalVariable(rety)
            if resettime != -1 then
                door:SetSaveValue(rety, resettime + doorrespawntime:GetInt())
            end
            door:SetNotSolid(true)
            door:SetNoDraw(true)

            local prop = ents.Create("prop_physics_multiplayer")
            prop:SetPos(pos)
            prop:SetAngles(ang)
            prop:SetModel(model)
            prop:SetSkin(skin or 0)
            prop:SetBodygroup(1,bg or 0)
            prop:SetRenderMode(rendermode)
            prop:SetRenderFX(renderfx)
            prop:SetColor(color)
            prop:SetHealth(door:Health())
            if doorgib:GetBool() then
                prop:SetSaveValue("m_takedamage", 1)
                prop:SetMaxHealth(1)
                prop:SetHealth(1)
                if prop:GetInternalVariable("m_iszBreakableModel") != nil then
                    prop:SetSaveValue("m_iBreakableCount", doorgibcount:GetInt())
                    prop:SetSaveValue("m_iNumBreakableChunks", doorgibcount:GetInt())
                    prop:SetSaveValue("m_iszBreakableModel", "WoodChunks")
                end
                prop:PrecacheGibs()
                prop:Spawn()
                prop:Fire("SetHealth", 0)
            else
                for k, v in ipairs(door:GetChildren()) do
                    if not IsValid(v:GetModel()) then continue end
                    v:SetNotSolid(true)
                    v:SetNoDraw(true)
                    local extra = ents.Create("prop_dynamic")
                    extra:SetPos(v:GetPos())
                    extra:SetAngles(v:GetAngles())
                    extra:SetModel(v:GetModel())
                    extra:SetSkin(v:GetSkin() or 0)
                    extra:SetBodygroup(1,v:GetBodygroup(1) or 0)
                    extra:SetRenderMode(v:GetRenderMode())
                    extra:SetRenderFX(v:GetRenderFX())
                    extra:SetColor(v:GetColor())
                    extra:SetHealth(v:Health())
                    extra:Spawn()
                    extra:SetParent(prop)
                    extra:SetCollisionGroup(10)
                    extra:SetCollisionGroup(COLLISION_GROUP_WEAPON)
                    extra:PhysicsInit(SOLID_NONE)
                end
            end
            prop:PhysicsInit(SOLID_VPHYSICS)
            prop:SetModelScale(0.95, 0.1)
            prop:Activate()
            prop:SetModelScale(1, 1)
            local snd = CreateSound(prop, "Wood_Box.Break")
            snd:Play()
            snd:FadeOut(1)

            timer.Simple(0, function()
                if not IsValid(prop) then return end
                net.Start("MFDoorBust")
                net.WriteEntity(prop)
                net.Broadcast()
            end)

            timer.Create("MFDoorBust" .. door:EntIndex(), 2, 1, function()
                if not IsValid(prop) or not IsValid(prop:GetPhysicsObject()) then return end
                local phys = prop:GetPhysicsObject()
                prop:SetCollisionGroup(COLLISION_GROUP_WEAPON)
                phys:RecheckCollisionFilter()
            end)

            timer.Create("MFDoorTimer" .. door:EntIndex(), doorrespawntime:GetInt(), 1, function()
                if door:IsValid() then
                    door:SetSaveValue(rety, resettime)
                    for k, v in ipairs(table.Add({[1] = door}, door:GetChildren())) do
                        v:SetNoDraw(false)
                        v:SetRenderMode(2)
                        v:SetRenderFX(24)
                        timer.Simple(1, function()
                            if not v:IsValid() then return end
                            v:SetNotSolid(false)
                            v:SetRenderMode(rendermode)
                            v:SetColor(color)
                            v:SetRenderFX(renderfx)
                        end)
                    end
                    timer.Simple(1, function()
                        door.MFKickedDown = false
                    end)
                end
                if prop:IsValid() then
                    for k, v in ipairs(table.Add({[1] = prop}, prop:GetChildren())) do
                        v:SetRenderMode(2)
                        v:SetRenderFX(24)
                    end
                end

                SafeRemoveEntityDelayed(prop, 1)
            end)
            return IsValid(prop:GetPhysicsObject()) and prop
        end
    end

	local vt = file.Exists("wos/dynabase/registers/zames_footkick.lua", "LUA")

	local anims = file.Exists("wos/dynabase/registers/zames_footkick.lua", "LUA")
	local anim1, anim2, anim3, anim4, anim5, anim6, anim7, anim8, anim9, anim10 = 1, 1, 1, 1, 1, 1, 1, 1, 1, 1

	if vt then
		anim1, anim2, anim3, anim4, anim5, anim6, anim7, anim8, anim9, anim10 = 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
	end

	function MightyFootEngaged(ply, charge)
		if ply:GetObserverMode() ~= 0 then return end
		local mt = ply:GetMoveType()
		if mt == 10 or not ply:Alive() or ply:IsFrozen() or ply:InVehicle() then return false end
		local speed, delay, fast = kickspeed:GetFloat(), kickdelay:GetFloat(), kickfast:GetBool()
		local rate = (fast and 0.3 or 0.75) / speed
		local ct, time = CurTime(), rate + delay
		local dropkicking = (not ply:OnGround() and ply:WaterLevel() < 2) and mt ~= MOVETYPE_LADDER and mt ~= MOVETYPE_NOCLIP
		local anim = anim1

		if anims then
			local pitch = ply:EyeAngles().x
			if dropkicking then
				if pitch > 75 then anim = anim6
				elseif pitch > 45 then anim = anim10
				elseif pitch > 25 then anim = anim8
				else anim = anim2 end
			elseif ply:Crouching() then
				if pitch > 65 then anim = anim5
				else anim = anim4 end
			else
				if pitch > 75 then anim = anim3
				elseif pitch > 45 then anim = anim9
				elseif pitch > 25 then anim = anim7
				else anim = anim1 end
			end
		end

        if ply.MFNextKick and ply.MFNextKick <= ct then
            ply.MFKickTime = ct
            ply.MFNextKick = ply.MFKickTime + time
            local wep = ply:GetActiveWeapon()
			local stance = "stand"

			if dropkicking then
				stance = "air"
			elseif ply:Crouching() then
				stance = "crouch"
			end

			net.Start("MF_StanceLock")
			net.WriteString(stance)
			net.Send(ply)

            ply:DoCustomAnimEvent(PLAYERANIMEVENT_ATTACK_GRENADE, 670 + anim)
            if kickholster:GetBool() then
                ply:SetActiveWeapon(NULL)
            end

            timer.Simple(0.2 / speed, function()
                if not IsValid(ply) or not ply:Alive() then return end
                ply:ViewPunch(Angle(-10, math.Rand(-2, 2), 0) * viewpunchscale:GetFloat())
                ply:EmitSound("mightyfoot.fire")
            end)

            timer.Simple(0.3 / speed, function()
                if not IsValid(ply) or not ply:Alive() then return end
                MFHit(ply, charge) -- ПЕРЕДАЕМ ЗАРЯД СЮДА
                if kickholster:GetBool() and IsValid(wep) then
                    ply:SelectWeapon(wep)
                end
            end, ply)
        end
    end

    function MFInitState(ply)
        local time = 0.3 / math.max(kickspeed:GetFloat(), 0.0001)
        ply.MFKickTime = 0
        ply.MFNextKick = ply.MFKickTime + time
    end

    hook.Add("PlayerSpawn", "MFInitState", MFInitState)
    hook.Add("PlayerDeath", "MFInitState", MFInitState)

    hook.Add("PostEntityTakeDamage", "CATMFDamageModifiers", function(ent, dinfo, took)
        if not (IsValid(ent) and ((!took and dinfo:GetDamage() == 0) or took) and dinfo:GetDamageCustom() == 67 and ent.GetActiveWeapon) then return end
        if (ent:IsPlayer() and disarmply:GetBool() or (ent:IsNPC() or ent:IsNextBot()) and disarmnpc:GetBool()) and IsValid(ent:GetActiveWeapon()) then
            ent:DropWeapon()
        end
    end)
end

local anims_table = {
    ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND,
    ACT_MP_STAND_MELEE,
    ACT_MP_JUMP_MELEE,
    ACT_MP_ATTACK_STAND_MELEE_SECONDARY,
    ACT_MP_CROUCH_MELEE,
	ACT_MP_ATTACK_CROUCH_MELEE_SECONDARY,
	ACT_MP_ATTACK_SWIM_MELEE,
	ACT_MP_RUN_MELEE,
	ACT_MP_JUMP_LAND_MELEE,
	ACT_MP_WALK_MELEE,
	ACT_MP_AIRWALK_SECONDARY
}

hook.Add("PlayerSwitchWeapon", "MFEngaged_SwitchBlock", function(ply, old, new)
    if not kickholster:GetBool() then return end
    local ct, speed = CurTime(), 0.3 / math.max(kickspeed:GetFloat(), 0.0001)
    if ply.MFKickTime and ply.MFKickTime + speed > ct then
        return true
    end
end)

hook.Add("DoAnimationEvent", "MFEngaged_DoAnim", function(ply, event, data)
    if event == PLAYERANIMEVENT_ATTACK_GRENADE and (data >= 671 and data <= 681) then
        local anim = anims_table[data-670]
        ply:AnimRestartGesture(GESTURE_SLOT_GRENADE, anim, true)
        ply:SetLayerDuration(GESTURE_SLOT_GRENADE, 1 / math.max(kickspeed:GetFloat(), 0.0001))
        return ACT_INVALID
    end
end)
