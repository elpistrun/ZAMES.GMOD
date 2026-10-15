--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/fdf21fasdj2/lua/freline_opt/cl_opt.lua <
    > Callstack: addons/fdf21fasdj2/lua/autorun/freline_opt_init.lua:9
addons/h9k8rfq2bt5/lua/ulib/shared/hook.lua:109 <
]]

RunConsoleCommand("gmod_mcore_test", "1")
RunConsoleCommand("mat_queue_mode", "2")
RunConsoleCommand("cl_threaded_bone_setup", "0") -- 1 ,из-за нее пропадает wpn select

RunConsoleCommand("r_threaded_particles", "1")

RunConsoleCommand("studio_queue_mode", "1")

RunConsoleCommand("r_queued_ropes", "1")
RunConsoleCommand("r_occludermincount", "1")

hook.Add( "PreGamemodeLoaded", "widgets_disabler_cpu_client", function()
    function widgets.PlayerTick()
        -- empty
    end

    hook.Remove("PreventScreenClicks", "SuperDOFPreventClicks")
    hook.Remove("PostRender", "RenderFrameBlend")
    hook.Remove("PreRender", "PreRenderFrameBlend")
    hook.Remove("Think", "DOFThink")
    hook.Remove("RenderScreenspaceEffects", "RenderBokeh")
    hook.Remove("NeedsDepthPass", "NeedsDepthPass_Bokeh")
    hook.Remove("PostDrawEffects", "RenderWidgets")
    hook.Remove("Think", "RenderHalos")
    hook.Remove( "PlayerTick", "TickWidgets" )
end )


--[[function render.SupportsHDR()
    return false
end

function render.SupportsPixelShaders_2_0()
    return false
end

function render.SupportsPixelShaders_1_4()
    return false
end

function render.SupportsVertexShaders_2_0()
    return false
end--]]

function render.GetDXLevel()
    return 80
end

timer.Create( 'OptimizationCleanBodys', 60, 0, function()
    --RunConsoleCommand( 'r_cleardecals' )

    for k, v in ipairs( ents.FindByClass( 'class C_ClientRagdoll' ) ) do
        if ( IsValid( v ) ) then
            v:Remove()
        end
    end

    for k, v in ipairs( ents.FindByClass( 'class C_PhysPropClientside' ) ) do
        if ( IsValid( v ) ) then
            v:Remove()
        end
    end
end )

local eyepos = Vector()
local eyeangles = Angle()
local eyefov = 90
local eyevector = Vector()

hook.Add( 'RenderScene', 'Eye', function( origin, angles, fov )
	eyepos = origin
	eyeangles = angles
	eyefov = fov
	eyevector = angles:Forward()
end )

function EyePos()
    return eyepos
end

function EyeAngles()
    return eyeangles
end

function EyeFov()
    return eyefov
end

function EyeVector()
    return eyevector
end

local GM = GAMEMODE
local CalcMainActivity = GM.CalcMainActivity
local UpdateAnimation = GM.UpdateAnimation
local PrePlayerDraw = GM.PrePlayerDraw
local DoAnimationEvent = GM.DoAnimationEvent
local PlayerFootstep = GM.PlayerFootstep
local PlayerStepSoundTime = GM.PlayerStepSoundTime
local TranslateActivity = GM.TranslateActivity

local meta = FindMetaTable( 'Entity' )

function meta:ShouldHide()
	local pos = self:GetPos()

	return self != LocalPlayer() and ( eyevector:Dot( pos - eyepos ) < 1.5 or pos:DistToSqr( eyepos ) > 3000000 )
end

function meta:NotInRange()
	local pos = self:GetPos()

	return pos:DistToSqr( eyepos ) > 3000000
end

function GM:CalcMainActivity( pl, ... )
	if ( pl:ShouldHide() ) then
        return pl.CalcIdeal, pl.CalcSeqOverride
    end

	return CalcMainActivity( self, pl, ... )
end

function GM:UpdateAnimation( pl, ... )
	if ( pl:ShouldHide() ) then
        return
    end

	return UpdateAnimation( self, pl, ... )
end

function GM:PrePlayerDraw( pl, ... )
	if ( pl:ShouldHide() ) then
        return true
    end

	return PrePlayerDraw( self, pl, ... )
end

function GM:DoAnimationEvent( pl, ... )
	if ( pl:ShouldHide() ) then
        return pl.CalcIdeal
    end

	return DoAnimationEvent( self, pl, ... )
end

function GM:PlayerFootstep( pl, ... )
	if ( pl:NotInRange() ) then
        return true
    end

	PlayerFootstep( self, pl, ... )
end

function GM:PlayerStepSoundTime( pl, ... )
	if ( pl:NotInRange() ) then
        return 350
    end

	return PlayerStepSoundTime( self, pl, ... )
end

function GM:TranslateActivity( pl, ... )
	if ( pl:ShouldHide() ) then
        return ACT_HL2MP_IDLE
    end

	return TranslateActivity( self, pl, ... )
end

