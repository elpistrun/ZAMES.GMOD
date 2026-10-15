--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/orp_base/cl_init.lua <
    > Callstack:  <
]]

include("shared.lua")
include("sh_wm.lua")


-- no server

net.Receive("TPIK_NetworkSound", function()
    local snd = net.ReadString()
    local endPos = net.ReadVector()
    local sourceEnt = net.ReadEntity()
    
    if not snd or snd == "" then return end

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local startPos = ply:EyePos()
    
    local tr = util.TraceLine({
        start = startPos,
        endpos = endPos,
        filter = function(traceEnt)
            if traceEnt:IsPlayer() or traceEnt:IsNPC() or traceEnt:IsWeapon() or traceEnt:IsVehicle() then return false end
            if traceEnt:GetClass() == "prop_ragdoll" then return false end
            return true
        end,
        mask = MASK_OPAQUE
    })

    local targetDSP = tr.Hit and 14 or 0
    
    local entIndex = IsValid(sourceEnt) and sourceEnt:EntIndex() or 0
    
    EmitSound(snd, endPos, entIndex, CHAN_AUTO, 1, 75, 0, 100, targetDSP)
end)
