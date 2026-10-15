--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/g5nq5jr8fs2m/sh_g5nq5jr8fs2m.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:26
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

ZONA_ACTIVE = false
ZONA_CENTER = Vector(0, 0, 0)
ZONA_RADIUS = 1000
ZONA_SHRINK_SPEED = 0

if CLIENT then
    local zoneSound = nil
    local soundName = "ambient/energy/force_field_loop1.wav"

    net.Receive("RedZone_Update", function()
        ZONA_ACTIVE = net.ReadBool()
        
        if ZONA_ACTIVE then
            ZONA_CENTER = net.ReadVector()
            ZONA_RADIUS = net.ReadFloat()
            ZONA_SHRINK_SPEED = net.ReadFloat() -- Читаем скорость от сервера

            if not zoneSound then
                zoneSound = CreateSound(LocalPlayer(), soundName)
            end
            zoneSound:Play()
        else
            if zoneSound then
                zoneSound:Stop()
                zoneSound = nil
            end
        end
    end)

    hook.Add("Think", "RedZone_ShrinkLogic_Client", function()
        if not ZONA_ACTIVE then return end
        
        if ZONA_RADIUS > 0 then
            ZONA_RADIUS = math.max(0, ZONA_RADIUS - (ZONA_SHRINK_SPEED * FrameTime()))
        end
    end)

    hook.Add("PostDrawTranslucentRenderables", "zona_draw", function(_, isSkybox)
        if not ZONA_ACTIVE then return end
        if isSkybox then return end

        render.SetColorMaterial()
        render.SuppressEngineLighting(true)

        render.CullMode(MATERIAL_CULLMODE_CW)
        render.DrawSphere(ZONA_CENTER, ZONA_RADIUS, 48, 48, Color(255, 0, 0, 30), true)

        render.CullMode(MATERIAL_CULLMODE_CCW)
        render.DrawSphere(ZONA_CENTER, ZONA_RADIUS, 48, 48, Color(255, 0, 0, 70), true)

        render.CullMode(MATERIAL_CULLMODE_CCW)
        render.SuppressEngineLighting(false)
    end)

    hook.Add("Think", "zona_sound_logic", function()
        if not ZONA_ACTIVE or not zoneSound then return end
        
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local distToCenter = ply:GetPos():Distance(ZONA_CENTER)
        local distToBorder = math.abs(distToCenter - ZONA_RADIUS)
        local hearingDistance = 500

        if distToBorder < hearingDistance then
            local intensity = 1 - (distToBorder / hearingDistance)
            local vol = math.Clamp(intensity, 0, 1)
            local pitch = math.Clamp(100 + (intensity * 60), 100, 160)

            zoneSound:ChangeVolume(vol, 0.1)
            zoneSound:ChangePitch(pitch, 0.1)
        else
            zoneSound:ChangeVolume(0, 0.1)
        end
    end)
    
    hook.Add("ShutDown", "zona_sound_stop", function()
        if zoneSound then zoneSound:Stop() end
    end)
end
