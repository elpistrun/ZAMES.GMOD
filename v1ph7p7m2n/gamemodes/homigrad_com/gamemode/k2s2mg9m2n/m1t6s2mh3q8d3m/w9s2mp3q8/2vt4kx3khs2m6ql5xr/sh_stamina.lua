--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/m1t6s2mh3q8d3m/w9s2mp3q8/2vt4kx3khs2m6ql5xr/sh_stamina.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:26
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

--[[hook.Add("SetupMove", "PlayerInertia_Momentum", function(ply, mv, cmd)
    if not IsValid(ply) or not ply:Alive() or ply:InVehicle() or ply:GetMoveType() == MOVETYPE_NOCLIP then return end
    
    if not ply:IsOnGround() then return end

    local buttons = mv:GetButtons()
    local pressingKeys = bit.band(buttons, IN_FORWARD) ~= 0 or 
                         bit.band(buttons, IN_BACK) ~= 0 or 
                         bit.band(buttons, IN_MOVELEFT) ~= 0 or 
                         bit.band(buttons, IN_MOVERIGHT) ~= 0

    ply.SmoothForward = ply.SmoothForward or 0
    ply.SmoothSide = ply.SmoothSide or 0

    if pressingKeys then
        ply.SmoothForward = mv:GetForwardSpeed()
        ply.SmoothSide = mv:GetSideSpeed()

        print(ply:GetVelocity():Length2D())
        
        ply.AllowInertia = ply:GetVelocity():Length2D() > 330
    else
        if not ply.AllowInertia then
            ply.SmoothForward = 0
            ply.SmoothSide = 0
            mv:SetForwardSpeed(0)
            mv:SetSideSpeed(0)
            return
        end

        local decay = 390

        if ply.SmoothForward > 0 then
            ply.SmoothForward = math.max(0, ply.SmoothForward - decay)
        elseif ply.SmoothForward < 0 then
            ply.SmoothForward = math.min(0, ply.SmoothForward + decay)
        end

        if ply.SmoothSide > 0 then
            ply.SmoothSide = math.max(0, ply.SmoothSide - decay)
        elseif ply.SmoothSide < 0 then
            ply.SmoothSide = math.min(0, ply.SmoothSide + decay)
        end

        mv:SetForwardSpeed(ply.SmoothForward)
        mv:SetSideSpeed(ply.SmoothSide)
    end
end)--]]
