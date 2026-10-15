--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/m1t6s2mh3q8d3m/cl_m3s2mg9q8p74kx.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

CFG = {
    cb_enabled = true,
    cb_impulse_scale = 15,
    cb_spring = 255,
    cb_damping = 15.0,
    cb_jitter = 0.20,
    cb_shoulder_tilt = 0.0,
    
    cb_en_slow = true,       cb_mult_slow = 0.6,
    cb_en_normal = true,     cb_mult_normal = 0.5,
    cb_en_run = true,        cb_mult_run = 0.4,
    cb_en_jump = true,       cb_mult_jump = 2.2,
    cb_en_land = true,       cb_mult_land = 2.2,
    cb_en_dmg = true,        cb_mult_dmg = 2.5,
    cb_en_crouch = true,     cb_mult_crouch = 0.7,
    cb_en_uncrouch = true,   cb_mult_uncrouch = 0.8,
}

local PUNCH_DAMPING = 9
local PUNCH_SPRING_CONSTANT = 65
local vp_punch_angle = Angle()
local vp_punch_angle_velocity = Angle()
local vp_punch_angle_last = vp_punch_angle

hook.Add("Think", "bodycam_viewpunch_think", function()
	local lp = LocalPlayer()

	if not vp_punch_angle:IsZero() or not vp_punch_angle_velocity:IsZero() then
		vp_punch_angle = vp_punch_angle + vp_punch_angle_velocity * FrameTime()
		local damping = 1 - (PUNCH_DAMPING * FrameTime())
		if damping < 0 then damping = 0 end
		vp_punch_angle_velocity = vp_punch_angle_velocity * damping

		local spring_force_magnitude = math.Clamp(PUNCH_SPRING_CONSTANT * FrameTime(), 0, 0.2 / FrameTime())
		vp_punch_angle_velocity = vp_punch_angle_velocity - vp_punch_angle * spring_force_magnitude

		vp_punch_angle.x = math.Clamp(vp_punch_angle.x, -89, 89)
		vp_punch_angle.y = math.Clamp(vp_punch_angle.y, -179, 179)
		vp_punch_angle.z = math.Clamp(vp_punch_angle.z, -89, 89)
	else
		vp_punch_angle:Zero()
		vp_punch_angle_velocity:Zero()
	end

	if vp_punch_angle:IsZero() and vp_punch_angle_velocity:IsZero() then return end

	lp:SetEyeAngles(lp:EyeAngles() + vp_punch_angle - vp_punch_angle_last)
	vp_punch_angle_last = vp_punch_angle
end)

function Viewpunch(angle)
	if not angle or LocalPlayer():InVehicle() then return end
	vp_punch_angle_velocity = vp_punch_angle_velocity + angle * 20
end


local function is_cb_enabled(typee, ply)
	if not CFG.cb_enabled then return false end
	if not CFG["cb_en_" .. typee] then return false end
	if ply:GetMoveType() == MOVETYPE_NOCLIP then return false end
	if IsValid(ply:GetNWEntity("FakeRagdoll")) then return false end
	return true
end
local fb_ang, fb_ang_vel, fb_ang_last = Angle(), Angle(), Angle()
local fb_bounce_timer = 0
local fb_bounce_pending = Angle()
local fb_bouncing = false

local function footstep_impulse(ang)
	fb_ang_vel = fb_ang_vel + ang * CFG.cb_impulse_scale
end

local function camerabob_spring_think()
	local lp = LocalPlayer()
	if not IsValid(lp) then return end
	local dt = FrameTime()

	if fb_bouncing then
		fb_bounce_timer = fb_bounce_timer - dt
		if fb_bounce_timer <= 0 then
			fb_ang_vel = fb_ang_vel + fb_bounce_pending * CFG.cb_impulse_scale
			fb_bouncing = false
		end
	end

	if not fb_ang:IsZero() or not fb_ang_vel:IsZero() then
		fb_ang = fb_ang + fb_ang_vel * dt

		local d = 1 - (CFG.cb_damping * dt)
		if d < 0 then d = 0 end
		fb_ang_vel = fb_ang_vel * d

		local sf = math.Clamp(CFG.cb_spring * dt, 0, 0.5 / dt)
		fb_ang_vel = fb_ang_vel - fb_ang * sf

		fb_ang.p = math.Clamp(fb_ang.p, -25, 25)
		fb_ang.y = math.Clamp(fb_ang.y, -20, 20)
		fb_ang.r = math.Clamp(fb_ang.r, -25, 25)

		lp:SetEyeAngles(lp:EyeAngles() + fb_ang - fb_ang_last)
	else
		fb_ang:Zero()
		fb_ang_vel:Zero()
	end
	fb_ang_last = Angle(fb_ang.p, fb_ang.y, fb_ang.r)
end
hook.Add("Think", "bodycam_camerabob_spring", camerabob_spring_think)

local STEP_PROFILES = {
	slow   = { pitch = 2.8, roll = 1.6, shoulder = 0.5, bounce_f = 0.18, bounce_t = 0.06 },
	normal = { pitch = 5.0, roll = 2.6, shoulder = 0.9, bounce_f = 0.22, bounce_t = 0.05 },
	run    = { pitch = 8.5, roll = 4.2, shoulder = 1.6, bounce_f = 0.28, bounce_t = 0.04 },
}

hook.Add("PlayerFootstep", "bodycam_camerabob_step", function(ply, pos, foot, sound, volume, rf, jumped)
	if ply != LocalPlayer() then return end

	local typee = "normal"
	if ply:KeyDown(IN_WALK) then typee = "slow" end
	if ply:KeyDown(IN_SPEED) then typee = "run" end

	if not is_cb_enabled(typee, ply) then return end

	local profile = STEP_PROFILES[typee]
	local mult = CFG["cb_mult_" .. typee]
	local jitter = CFG.cb_jitter
	local side = (foot == 0) and 1 or -1

	local j_pitch = 1 + math.Rand(-jitter * 0.4, jitter * 0.6)
	local j_roll  = 1 + math.Rand(-jitter * 0.4, jitter)
	local j_yaw   = 1 + math.Rand(-jitter * 0.8, jitter * 0.8)

	local stumble = 1.0
	if math.Rand(0, 1) < 0.15 then stumble = math.Rand(1.2, 1.5) end

	local pitch = profile.pitch * mult * j_pitch * stumble
	local roll  = profile.roll  * side * mult * j_roll * stumble
	local yaw   = 0

	local shoulder_mult = CFG.cb_shoulder_tilt
	if shoulder_mult > 0 then
		yaw  = profile.shoulder * side * mult * shoulder_mult * j_yaw * stumble
		roll = roll + (profile.shoulder * 0.35 * side * mult * shoulder_mult * j_yaw)
	end

	if ply:KeyDown(IN_MOVELEFT)  then roll = roll - 0.5 * mult end
	if ply:KeyDown(IN_MOVERIGHT) then roll = roll + 0.5 * mult end
	if ply:KeyDown(IN_BACK) and not ply:KeyDown(IN_FORWARD) then pitch = pitch * -0.4 end

	footstep_impulse(Angle(pitch, yaw, roll))
	fb_bounce_pending = Angle(-pitch * profile.bounce_f, 0, -roll * profile.bounce_f)
	fb_bounce_timer = profile.bounce_t
	fb_bouncing = true

	if (ply:KeyPressed(IN_JUMP) or jumped) and is_cb_enabled("jump", ply) then
		Viewpunch(Angle(-4.5 * CFG.cb_mult_jump, 0, 0))
	end
end)

hook.Add("OnPlayerHitGround", "bodycam_camerabob_land", function(ply, inWater, onFloater, speed)
	if ply != LocalPlayer() then return end
	if not is_cb_enabled("land", ply) then return end

	local mult = CFG.cb_mult_land
	local intensity = math.Clamp(speed / 38, 0.6, 18) * mult

	if ply:KeyDown(IN_DUCK) then intensity = intensity * 0.5 end

	footstep_impulse(Angle(intensity, math.Rand(-0.8, 0.8) * mult, math.Rand(-2.2, 2.2) * mult))
	fb_bounce_pending = Angle(-intensity * 0.35, 0, 0)
	fb_bounce_timer = 0.07
	fb_bouncing = true
end)

hook.Add("EntityTakeDamage", "bodycam_camerabob_dmg", function(target, dmginfo)
	if target != LocalPlayer() then return end
	if not is_cb_enabled("dmg", target) then return end
	local mult = CFG.cb_mult_dmg * 0.5
	Viewpunch(Angle(math.random(-3, 3) * mult, math.random(-3, 3) * mult, math.random(-3, 3) * mult))
end)

hook.Add("Tick", "bodycam_camerabob_crouch", function()
	local ply = LocalPlayer()
	if not ply.KeyDown then return end
	if not ply.vb_crouching then ply.vb_crouching = false end
	ply.vb_crouched_before = ply.vb_crouching
	ply.vb_crouching = ply:KeyDown(IN_DUCK)

	if ply.vb_crouched_before != ply.vb_crouching and ply.vb_crouching then
		if not is_cb_enabled("crouch", ply) then return end
		local mult = CFG.cb_mult_crouch
		Viewpunch(Angle(4 * mult, math.random(-1, 1) * mult, math.random(-1, 1) * mult))
	end

	if ply.vb_crouched_before != ply.vb_crouching and not ply.vb_crouching then
		if not is_cb_enabled("uncrouch", ply) then return end
		local mult = CFG.cb_mult_uncrouch
		Viewpunch(Angle(-4 * mult, math.random(-1, 1) * mult, math.random(-1, 1) * mult))
	end
end)

--------------------------------------------------------------------------------
local vecZ = Vector(0,0,0)
local vecN = Vector(1,1,1)
local sangles

CreateClientConVar("zs_fov", "100", true, false, "FOV Камеры")

local current_fov = 100 

local change_cam = {
    ["models/player_compa.mdl"] = Vector(4, 0, 0),
    ["models/lightshoro_workshop/goofycat/boykisser_v2o.mdl"] = Vector(4,0,0),
}

hook.Add("CalcView", "MyCalcView123", function(ply, pos, angles, fov)
    local rag = ply:GetNWEntity("FakeRagdoll")
    local target = IsValid(rag) and rag or ply
    
    local get_eyes = target:LookupAttachment("eyes")
    local bone = target:LookupBone("ValveBiped.Bip01_Head1")

    if not get_eyes or get_eyes == 0 or not ply:Alive() then return end

    if bone then
        if ply == GetViewEntity() then
            target:ManipulateBoneScale(bone, vecZ)
        else
            target:ManipulateBoneScale(bone, vecN)
        end
    end

    local blacklist_weps = {
        ["weapon_physgun"] = true,
        ["gmod_camera"] = true,
        ["gmod_tool"] = true,
    }

    local active_wep = ply:GetActiveWeapon()

    if IsValid(ply) and IsValid(active_wep) and blacklist_weps[active_wep:GetClass()] then 
        return 
    end

    if ply != GetViewEntity() then
        return 
    end

    local eyes = target:GetAttachment(get_eyes)

    if not sangles then sangles = angles end
    
    local target_fov = GetConVar("zs_fov"):GetFloat() or 100

    if IsValid(active_wep) and (active_wep.Base == "orp_base" or active_wep:GetClass() == "orp_tazer") and (not ply:IsSprinting() or IsValid(rag)) then
        if ply:KeyDown(IN_ATTACK2) and active_wep.LSightFOV then
            target_fov = active_wep.LSightFOV
        end
    end
    
    current_fov = Lerp(10 * FrameTime(), current_fov, target_fov)
    sangles = LerpAngleFT(0.5, sangles, angles)

    local finalPos = eyes.Pos

    if IsValid(rag) then
        local headBone = target:LookupBone("ValveBiped.Bip01_Head1")
        if headBone then
            local physId = target:TranslateBoneToPhysBone(headBone)
            local phys = target:GetPhysicsObjectNum(physId)
            
            if IsValid(phys) then
                finalPos = phys:GetPos()
            end
        end
    else
        local tr = util.TraceHull({
            start = pos,
            endpos = eyes.Pos,
            mins = Vector(-4, -4, -4),
            maxs = Vector(4, 4, 4),
            filter = {ply, target},
            mask = MASK_SOLID
        })
        finalPos = tr.HitPos
    end

    local mdl = target:GetModel()
    if change_cam[mdl] then
        local offset = change_cam[mdl]
        finalPos = finalPos 
            + sangles:Forward() * offset.x 
            + sangles:Right() * offset.y 
            + sangles:Up() * offset.z
    end

    local view = {
        origin = finalPos, 
        angles = sangles,
        fov = current_fov, 
        drawviewer = true,
        znear = 1
    }

    TPIK_CamPos = view.origin
    TPIK_CamAng = view.angles
    
    return view
end)

local hide = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudCrosshair"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
}

hook.Add("HUDShouldDraw", "HideHUD", function(name)
    if name == "CHudCrosshair" then
        local ply = LocalPlayer()
        
        if IsValid(ply) then
            local wep = ply:GetActiveWeapon()
            
            if IsValid(wep) and wep.DrawCrosshair then
                return
            end
        end
    end

    if hide[name] then 
        return false 
    end
end)

hook.Add("InputMouseApply", "asdasd2", function(cmd, x, y, angle)
    local ply = LocalPlayer()
    local follow = ply:GetNWEntity("FakeRagdoll")
    local IsDead = !ply:Alive()

    if ply:GetObserverMode() ~= OBS_MODE_NONE then return end

	if not IsValid(follow) and not IsDead then
        if angle.roll ~= 0 then
            angle.roll = 0
            cmd:SetViewAngles(angle)
        end
		return
	end

	local angRad = math.rad(angle[3])
	local newX = x * math.cos(angRad) - y * math.sin(angRad)
	local newY = x * math.sin(angRad) + y * math.cos(angRad)

	angle.pitch = math.Clamp(angle.pitch + newY / 50, -180, 180)
	angle.yaw = angle.yaw - newX / 50

	if math.abs(angle.pitch) > 89 then
		angle.roll = angle.roll + 180
		angle.yaw = angle.yaw + 180
		angle.pitch = 89 * angle.pitch / math.abs(angle.pitch)
	end

	cmd:SetViewAngles(angle)
	return true
end)

-- death

local deathPanel = nil
local wasAlive = nil
local soundMuted = false

local function StopAllSounds()
    RunConsoleCommand("stopsound")
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) then
            ent:StopSound("*")
        end
    end
end

local function StartDeathSequence()
    soundMuted = true
    
	timer.Simple(0.15,function()
		StopAllSounds()
	end)
    
    timer.Create("DP_SoundBlocker", 0.05, 40, function()
        if soundMuted then
            StopAllSounds()
        else
            timer.Remove("DP_SoundBlocker")
        end
    end)
    
    if IsValid(deathPanel) then
        deathPanel:Remove()
    end
    
    deathPanel = vgui.Create("DPanel")
    deathPanel:SetSize(ScrW(), ScrH())
    deathPanel:SetPos(0, 0)
    deathPanel:SetMouseInputEnabled(false)
    deathPanel:SetKeyboardInputEnabled(false)
    
    deathPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, self:GetAlpha()))
    end
    
    deathPanel:SetAlpha(255)
    
    timer.Simple(3, function()
        soundMuted = false 
        
        if IsValid(deathPanel) then
            deathPanel:AlphaTo(0, 1.5, 0, function()
                if IsValid(deathPanel) then
                    deathPanel:Remove()
                end
            end)
        end
    end)
end

local function ResetDeathSequence()
    soundMuted = false
    if IsValid(deathPanel) then
        deathPanel:Remove()
    end
    timer.Remove("DP_SoundBlocker")
end

hook.Add("Think", "DP_DeathMonitor", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local currentlyAlive = ply:Alive()
    
    if not currentlyAlive and wasAlive then
        wasAlive = false
        StartDeathSequence()
    elseif currentlyAlive and not wasAlive then
        wasAlive = true
        ResetDeathSequence()
    end
end)

hook.Add("EntityEmitSound", "DP_BlockSound", function(data)
    if soundMuted then
        if data.Entity and IsValid(data.Entity) then
            data.Entity:StopSound(data.SoundName)
        end
        return false
    end
end)

CreateClientConVar("nasichenostb", "1", true, false, "Насыщенность")

local tab2 = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}

hook.Add("RenderScreenspaceEffects","BloomEffect",function()
	local isEnabled = GetConVar("nasichenostb"):GetInt()
	local ply = LocalPlayer()

	tab2["$pp_colour_mulr"] = isEnabled
    tab2["$pp_colour_mulg"] = isEnabled
    tab2["$pp_colour_mulb"] = isEnabled

	local health = ply:Health()
	
	if ply:Alive() then
		tab2["$pp_colour_colour"] = health / 100
	else
		tab2["$pp_colour_colour"] = 1
	end

	DrawColorModify(tab2)
end)
