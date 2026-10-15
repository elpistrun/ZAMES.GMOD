--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/sh_p99gdm3q81rgt9z.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:26
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

local valid = {
    ["superadmin"] = true,
    ["dsuperadmin"] = true,
    ["admin"] = true,
    ["dadmin"] = true,
    ["operator"] = true,
    ["doperator"] = true,

    ["mpiar"] = true,
    ["piar"] = true,

}

local function IsAdmin(ply)
    if not IsValid(ply) then return false end
    return ply:IsAdmin() or valid[ply:GetUserGroup()] == true
end

if CLIENT then
    hook.Add("SpawnMenuOpen", "RestrictSpawnMenu", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end

        if IsAdmin(ply) then
            return true
        end

        return false
    end)

    hook.Add("ContextMenuOpen", "RestrictContextMenu", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end

        if not IsAdmin(ply) then
            return false
        end

        return true
    end)
end

hook.Add("CanProperty", "RestrictProperties", function(ply, property, ent)
    if not IsAdmin(ply) then
        return false
    end

    return true
end)

local disabledd = {
    "PlayerSpawnEffect",
    "PlayerSpawnNPC",
    "PlayerSpawnObject",
    "PlayerSpawnProp",
    "PlayerSpawnRagdoll",
    "PlayerSpawnSENT",
    "PlayerSpawnSWEP",
    "PlayerSpawnVehicle",
    "PlayerGiveSWEP"
}

for _, hookName in ipairs(disabledd) do
    hook.Add(hookName, "RestrictSpawn_" .. hookName, function(ply)
        if IsValid(ply) and not IsAdmin(ply) then
            return false
        end
        return true
    end)
end

