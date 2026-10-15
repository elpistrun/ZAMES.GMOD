--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/lua/glide/client/wind_noise.lua <
    > Callstack: lua/autorun/sh_glide.lua:343
lua/autorun/sh_glide.lua:400 <
]]

local IsValid = IsValid
local Clamp = math.Clamp
local GetVolume = Glide.Config.GetVolume
local windSound = Glide.windSound

local function ProcessWindSound()
    local vehicle = Glide.currentVehicle

    if IsValid( vehicle ) then
        local _, volume = vehicle:AllowWindSound( Glide.currentSeatIndex )
        local mult = vehicle:GetVelocity():LengthSqr() - 1000
        mult = Clamp( mult / 2500000, 0, 1 )

        windSound:SetVolume( GetVolume( "windVolume" ) * mult * Clamp( volume, 0, 1 ) )
        windSound:SetPlaybackRate( 0.7 + mult * 0.3 )
    end
end

hook.Add( "Glide_OnLocalEnterVehicle", "Glide.WindNoise", function( vehicle, seatIndex )
    local allow = vehicle:AllowWindSound( seatIndex )
    if not allow then return end
    if windSound then return end

    sound.PlayFile( "sound/glide/streams/wind.ogg", "noplay noblock", function( snd )
        if not IsValid( snd ) then return end

        if not IsValid( vehicle ) then
            snd:Stop()
            return
        end

        windSound = snd
        Glide.windSound = snd

        snd:EnableLooping( true )
        snd:SetVolume( 0.0 )
        snd:Play()

        hook.Add( "Tick", "Glide.WindNoise", ProcessWindSound )
    end )
end )

hook.Add( "Glide_OnLocalExitVehicle", "Glide.WindNoise", function()
    hook.Remove( "Tick", "Glide.WindNoise" )

    if IsValid( windSound ) then
        windSound:Stop()
    end

    windSound = nil
    Glide.windSound = nil
end )

