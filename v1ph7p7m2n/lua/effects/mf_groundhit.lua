--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/lua/effects/mf_groundhit.lua <
    > Callstack:  <
]]

function EFFECT:Init( data )

    local Pos = data:GetOrigin()
	local Norm = data:GetNormal()
	local vOffset = data:GetOrigin()
	local emitter = ParticleEmitter( vOffset )
    local SurfaceColor = render.GetSurfaceColor( Pos + Norm, Pos - Norm * 60 ) * 255
	
	SurfaceColor.r = math.Clamp( SurfaceColor.r + 100, 0, 255 )
	SurfaceColor.g = math.Clamp( SurfaceColor.g + 100, 0, 255 )
	SurfaceColor.b = math.Clamp( SurfaceColor.b + 100, 0, 255 )

	for i = 1,10 do
		local particle = emitter:Add( "particle/particle_smokegrenade", Pos + Norm * 3 )
		particle:SetVelocity( math.Rand( 30, 45 ) * VectorRand() + 2 * VectorRand())
		particle:SetAirResistance( 140 )
		particle:SetGravity( Vector(0, 0, 0) )
		particle:SetDieTime( math.Rand( 1, 5 ) )
		particle:SetStartAlpha( math.Rand( 200, 255 ) )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( math.random( 5, 10 ) )
		particle:SetEndSize( math.Rand( 20, 30 ) )
		particle:SetRoll( math.Rand( 180, 480 ) )
		particle:SetRollDelta( math.Rand( -1, 1 ) )
		particle:SetColor( SurfaceColor.r, SurfaceColor.g, SurfaceColor.b )
		particle:SetCollide(true)
		particle:SetBounce(0.45)
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end


function EFFECT:Render()
end
