--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/fdf21fasdj2/lua/freline_opt/sh_opt.lua <
    > Callstack: addons/fdf21fasdj2/lua/autorun/freline_opt_init.lua:6
addons/h9k8rfq2bt5/lua/ulib/shared/hook.lua:109 <
]]


local GM = GAMEMODE

function GM:FindUseEntity( pl, ent )
	return ent
end 

hook.Add( 'PlayerSpawnedProp', 'Optimization', function( ply, model, ent )
    timer.Simple( 0, function()
        if ( IsValid( ent ) ) then
            ent:DrawShadow( false )
        end
    end )
end )

local function RemoveShittyHooks()
	-- hook.Remove( 'PreDrawHalos', 'PropertiesHover' )
	-- hook.Remove( 'PreDrawHalos', 'AddPhysgunHalos' )
	hook.Remove( 'PreRender', 'PreRenderFrameBlend' )

	hook.Remove( 'Think', 'DOFThink' )
	hook.Remove( 'Think', 'CheckSchedules' )

	hook.Remove( 'RenderScreenspaceEffects', 'RenderColorModify' )
	hook.Remove( 'RenderScreenspaceEffects', 'RenderBloom' )
	hook.Remove( 'RenderScreenspaceEffects', 'RenderToyTown' )
	hook.Remove( 'RenderScreenspaceEffects', 'RenderTexturize' )
	hook.Remove( 'RenderScreenspaceEffects', 'RenderSunbeams' )
	hook.Remove( 'RenderScreenspaceEffects', 'RenderSobel' )
	hook.Remove( 'RenderScreenspaceEffects', 'RenderSharpen' )
	hook.Remove( 'RenderScreenspaceEffects', 'RenderMaterialOverlay' )
	hook.Remove( 'RenderScreenspaceEffects', 'RenderMotionBlur' )
	hook.Remove( 'RenderScreenspaceEffects', 'RenderBokeh' )
	hook.Remove( 'RenderScene', 'RenderStereoscopy' )
	hook.Remove( 'RenderScene', 'RenderSuperDoF' )

	hook.Remove( 'GUIMousePressed', 'SuperDOFMouseDown' )
	hook.Remove( 'GUIMouseReleased', 'SuperDOFMouseUp' )
	-- hook.Remove( 'GUIMousePressed', 'SpawnMenuOpenGUIMousePressed' )
	-- hook.Remove( 'GUIMousePressed', 'PropertiesClick' )

	hook.Remove( 'PreventScreenClicks', 'SuperDOFPreventClicks' )
	-- hook.Remove( 'PreventScreenClicks', 'PropertiesPreventClicks' )

	hook.Remove( 'NeedsDepthPass', 'NeedsDepthPass_Bokeh' )

	-- hook.Remove( 'PostDrawEffects', 'RenderWidgets' )
	-- hook.Remove( 'PostDrawEffects', 'RenderHalos' )
	hook.Remove( 'PostRender', 'RenderFrameBlend' )

	-- hook.Remove( 'DrawOverlay', 'DrawNumberScratch' )
	-- hook.Remove( 'DrawOverlay', 'sandbox_search_progress' )
	-- hook.Remove( 'DrawOverlay', 'VGUIShowLayoutPaint' )

	hook.Remove( 'OnEntityCreated', 'WidgetInit' )

	hook.Remove( 'PlayerTick', 'TickWidgets' )

	hook.Remove( 'LoadGModSave', 'LoadGModSave' )
	
	timer.Remove( 'HostnameThink' )
	timer.Remove( 'CheckHookTimes' )

	hook.Remove( 'InitPostEntity', 'RemoveShittyHooks' )
end

hook.Add( 'InitPostEntity', 'RemoveShittyHooks', function()
	timer.Simple( 0, RemoveShittyHooks )

	local t = physenv.GetPerformanceSettings()

	t.LookAheadTimeObjectsVsObject = 0 --0.5
	t.LookAheadTimeObjectsVsWorld = 0.1 --1
	t.MaxAngularVelocity = 3600 --7272.7275390625
	t.MaxCollisionChecksPerTimestep = 100 --50000
	t.MaxCollisionsPerObjectPerTimestep = 1 --10
	t.MaxFrictionMass = 2500 --2500
	t.MaxVelocity = 3600 --4000
	t.MinFrictionMass = 100 --10

	physenv.SetPerformanceSettings( t )
end )

