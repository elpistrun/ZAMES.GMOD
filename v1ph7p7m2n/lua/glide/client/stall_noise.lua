--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/lua/glide/client/stall_noise.lua <
    > Callstack: lua/autorun/sh_glide.lua:343
lua/autorun/sh_glide.lua:400 <
]]

local IsValid = IsValid
local GetVolume = Glide.Config.GetVolume
local stallSound = Glide.stallSound

local function ProcessStallSound()
    local vehicle = Glide.currentVehicle
    if not IsValid( vehicle ) then return end

    if vehicle:GetIsStalling() then
        stallSound:SetVolume( GetVolume( "warningVolume" ) * vehicle.StallHornVolume )
    else
        stallSound:SetVolume( 0.0 )
    end
end

hook.Add( "Glide_OnLocalEnterVehicle", "Glide.StallNoise", function( vehicle, _ )
    if vehicle.VehicleType ~= Glide.VEHICLE_TYPE.PLANE then return end
    if not vehicle.StallHornSound or vehicle.StallHornSound == "" then return end

    sound.PlayFile( "sound/" .. vehicle.StallHornSound, "noplay noblock", function( snd )
        if not IsValid( snd ) then return end

        if not IsValid( vehicle ) then
            snd:Stop()
            return
        end

        stallSound = snd
        Glide.stallSound = snd

        snd:EnableLooping( true )
        snd:SetVolume( 0.0 )
        snd:Play()

        timer.Create( "Glide.StallNoise", 0.1, 0, ProcessStallSound )
    end )
end )

hook.Add( "Glide_OnLocalExitVehicle", "Glide.StallNoise", function()
    timer.Remove( "Glide.StallNoise" )

    if IsValid( stallSound ) then
        stallSound:Stop()
    end

    stallSound = nil
    Glide.stallSound = nil
end )

