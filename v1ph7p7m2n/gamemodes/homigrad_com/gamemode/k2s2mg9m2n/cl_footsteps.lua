--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/cl_footsteps.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

local FootSteps = FootStepsG or {}
FootStepsG = FootSteps

local footMat = Material( "thieves/footprint" )
local maxDistance = 500 ^ 2

local function CanSeeFootsteps()
    if zs.RD.name == "hmcd" then
        if LocalPlayer().roleT and LocalPlayer():Alive() then
            return true
        end
    end

    if zs.RD.name == "hunter" then
        if LocalPlayer():Team() == 2 and LocalPlayer():Alive() then
            return true
        end
    end

    return false
end

local function AddFootstep(ply, pos, ang)
    if ply == LocalPlayer() then return end -- Не путать самого себя

    ang.p = 0
    ang.r = 0
    local fpos = pos

    if ply.LastFoot then
        fpos = fpos + ang:Right() * 5
    else
        fpos = fpos + ang:Right() * -5
    end
    ply.LastFoot = not ply.LastFoot

    local trace = {
        start = fpos,
        endpos = fpos + Vector(0, 0, -10),
        filter = ply
    }
    local tr = util.TraceLine(trace)

    if tr.Hit then
        local tbl = {
            pos = tr.HitPos,
            plypos = fpos,
            foot = foot,
            curtime = CurTime(),
            angle = ang.y,
            normal = tr.HitNormal
        }
        
        local col = ply:GetPlayerColor()
        tbl.col = Color(col.x * 255, col.y * 255, col.z * 255)
        table.insert(FootSteps, tbl)
    end
end

local function ClearFootsteps()
    table.Empty(FootSteps)
end

local function RenderFootprints()
    cam.Start3D(EyePos(), EyeAngles())
    render.SetMaterial( footMat )
    
    local curTime = CurTime()
    local eyePos = EyePos()
    local lifeTime = 20
    
    for k, footstep in pairs(FootSteps) do
        if footstep.curtime + lifeTime > curTime then
            if (footstep.pos - eyePos):LengthSqr() < maxDistance then
                local FSCol = footstep.col
                local Ambient = render.GetLightColor(footstep.pos)
                
                FSCol = Color(FSCol.r * Ambient.x, FSCol.g * Ambient.y, FSCol.b * Ambient.z, 200)
                render.DrawQuadEasy(footstep.pos + footstep.normal * 0.01, footstep.normal, 10, 20, FSCol, footstep.angle) 
            end
        else
            FootSteps[k] = nil
        end
    end
    cam.End3D()
end

hook.Add("PostDrawTranslucentRenderables", "DrawPlayerFootsteps_Hook", function()
    local errored, retval = pcall(RenderFootprints)

    if not errored then
        ErrorNoHalt(retval)
    end
end)

hook.Add("PlayerFootstep", "Client_FootstepTracker", function(ply, pos, foot, snd, volume, filter)
    if ply ~= LocalPlayer() then return end
    if not CanSeeFootsteps() then return end

    AddFootstep(ply, pos, ply:GetAimVector():Angle())
end)

net.Receive("add_footstep", function()
    local ply = net.ReadEntity()
    local pos = net.ReadVector()
    local ang = net.ReadAngle()

    if not IsValid(ply) then return end
    if ply == LocalPlayer() then return end
    if not CanSeeFootsteps() then return end

    AddFootstep(ply, pos, ang)
end)

net.Receive("clear_footsteps", function()
    ClearFootsteps()
end)
