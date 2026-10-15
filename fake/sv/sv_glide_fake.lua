local IsValid = IsValid

--- Stores necessary data to respawn a player later,
--- and to restore the health, armor and inventory.
function Glide.StoreSpawnInfo( ply )
    local data = {
        health = ply:Health(),
        armor = ply:Armor(),
        god = ply:HasGodMode()
    }

    -- Store inventory
    data.weapons = {}

    for _, weapon in ipairs( ply:GetWeapons() ) do
        data.weapons[weapon:GetClass()] = {
            clip1 = weapon:Clip1(),
            clip2 = weapon:Clip2(),
            ammo1 = ply:GetAmmoCount( weapon:GetPrimaryAmmoType() ),
            ammo2 = ply:GetAmmoCount( weapon:GetSecondaryAmmoType() )
        }
    end

    -- Store current held weapon class
    local weapon = ply:GetActiveWeapon()

    if IsValid( weapon ) then
        data.weaponClass = weapon:GetClass()
    end

    ply.GlideSpawnData = data
end

do
    local function RestoreWeapons( ply, spawnData )
        ply:StripWeapons()
        ply:RemoveAllAmmo()

        for class, data in pairs( spawnData.weapons ) do
            local weapon = ply:Give( class )

            if IsValid( weapon ) then
                if weapon.SetClip1 then
                    weapon:SetClip1( data.clip1 )
                end

                if weapon.SetClip2 then
                    weapon:SetClip2( data.clip2 )
                end

                ply:SetAmmo( data.ammo1, weapon:GetPrimaryAmmoType() )
                ply:SetAmmo( data.ammo2, weapon:GetSecondaryAmmoType() )
            end
        end

        if spawnData.weaponClass then
            ply:SelectWeapon( spawnData.weaponClass )
        end
    end

    --- Retores health, armor and inventory previously stored on
    --- `Glide.StoreSpawnInfo`. Does nothing if there is no data from that function.
    function Glide.RestoreSpawnInfo( ply, restoreCallback )
        ply:Spawn()

        local spawnData = ply.GlideSpawnData
        if not spawnData then return end

        ply.GlideSpawnData = nil
        ply:SetHealth( spawnData.health )
        ply:SetArmor( spawnData.armor )

        if spawnData.god then
            ply:GodEnable()
        end

        timer.Simple( 0.1, function()
            if not IsValid( ply ) then return end
            if not ply:Alive() then return end

            if spawnData.health > 0 then
                RestoreWeapons( ply, spawnData )
            end

            if restoreCallback then
                restoreCallback( ply )
            end
        end )
    end
end

--- Returns a list of all bone positions/rotations from a player,
--- while making sure those are relative to the world even while inside a vehicle.
local function GetAllBones( ply )
    local veh = ply:GetVehicle()
    local rotation, upAxis

    if IsValid( veh ) then
        rotation = Angle( 0, 270, 0 )
        upAxis = veh:GetUp()
    end

    local max = ply:GetBoneCount() - 1
    local bones = {}
    local pos, ang

    for i = 0, max do
        pos, ang = ply:GetBonePosition( i )

        if pos then
            if rotation then
                pos = veh:WorldToLocal( pos )
                ang = veh:WorldToLocalAngles( ang )

                pos:Rotate( rotation )
                ang:RotateAroundAxis( upAxis, rotation[2] )

                pos = veh:LocalToWorld( pos )
                ang = veh:LocalToWorldAngles( ang )
            end

            bones[i] = { pos, ang }
        end
    end

    return bones
end

--- Apply bone positions obtained from the function above to a ragdoll.
local function PoseRagdollBones( ragdoll, bones, velocity )
    local max = ragdoll:GetPhysicsObjectCount() - 1
    local boneId, bone

    for i = 0, max do
        local phys = ragdoll:GetPhysicsObjectNum( i )

        if IsValid( phys ) then
            phys:SetDamping( 0.3, 10 )
            phys:Wake()

            boneId = ragdoll:TranslatePhysBoneToBone( i )

            if boneId and bones[boneId] then
                bone = bones[boneId]

                phys:SetPos( bone[1], true )
                phys:SetAngles( bone[2] )
            end

            phys:SetVelocity( velocity )
        end
    end
end

function Glide.RagdollPlayer( ply, velocity, unragdollTime )
    local success, velocityOverride, unragdollTimeOverride = hook.Run( "Glide_CanRagdollPlayer", ply, velocity, unragdollTime )
    if success == false then return end

    local vehicle = ply:GetVehicle()

    if ply:InVehicle() then
        ply:ExitVehicle()
    end

    velocity = velocity * 4

    if not ply.Fake then
    Faking(ply,velocity + Vector(0,0,200))
    end

    velocity = velocityOverride or velocity
    unragdollTime = unragdollTimeOverride or unragdollTime

    if ply.GlideRagdoll then return end

    local bones = GetAllBones( ply )

    hook.Run( "Glide_PrePlayerRagdoll", ply )
    -- Create ragdoll
    local ragdoll = ply.FakeRagdoll
    if not IsValid(ragdoll) then return end

    ragdoll:SetVelocity(velocity + Vector(0,0,200))

    ply.GlideRagdollStartPos = ply:GetPos()

    --hook.Run( "Glide_PostPlayerRagdoll", ply )
end

local traceData = {
    mins = Vector( -16, -16, 0 ),
    maxs = Vector( 16, 16, 64 )
}

local function GetFreeSpace( origin )
    local offset = Vector( 0, 0, 20 )
    local rad, tr

    for ang = 0, 360, 30 do
        rad = math.rad( ang )

        offset[1] = math.cos( rad ) * 20
        offset[2] = math.sin( rad ) * 20

        traceData.start = origin + offset
        traceData.endpos = origin

        tr = util.TraceHull( traceData )

        if tr.Hit and not tr.StartSolid then
            return tr.HitPos
        end
    end

    return origin
end

function Glide.UnRagdollPlayer( ply, restoreCallback )
    if not IsValid( ply ) then return end

    hook.Run( "Glide_PrePlayerUnRagdoll", ply )

    timer.Remove( "Glide_Ragdoll_" .. ply:EntIndex() )

    -- Make sure this player is still ragdolled
    local ragdoll = ply.GlideRagdoll
    if not ragdoll then return end

    local pos = ply.GlideRagdollStartPos
    local velocity = Vector()

    -- Get final position/velocity from the ragdoll
    if IsValid( ragdoll ) then
        velocity = ragdoll:GetVelocity()
        pos = ragdoll:GetPos()

        ragdoll:Remove()
    end

    -- Cleanup ragdoll data from the player
    ply.GlideRagdoll = nil
    ply.GlideRagdollStartPos = nil
    ply.GlideRagdollTimeout = nil
    ply:UnSpectate()

    if not ply:Alive() then return end

    local ang = Angle( 0, ply:GetAngles()[2], 0 )
    local bed = ply.SpawnBed

    ply.SpawnBed = nil -- Spawn Beds workaround
    ply.GlideBlockLoadout = true -- Custom Loadout workaround

    -- Restore health, armor and inventory
    Glide.RestoreSpawnInfo( ply, function( restoredPly )
        restoredPly:SetPos( GetFreeSpace( pos ) )
        restoredPly:SetEyeAngles( ang )
        restoredPly:SetVelocity( velocity )

        -- Reset Spawn Beds workaround
        if IsValid( bed ) then
            restoredPly.SpawnBed = bed
        end

        if restoreCallback then
            restoreCallback( restoredPly )
        end
    end )

    -- Immediately put the player close to where they will be
    -- after the callback on `RestoreSpawnInfo` runs.
    ply:SetPos( pos )
    ply:SetEyeAngles( ang )

    -- Reset Custom Loadout workaround
    ply.GlideBlockLoadout = nil

    hook.Run( "Glide_PostPlayerUnRagdoll", ply )
end

hook.Add( "CanTool", "Glide.BlockPlayerRagdolls", function( _, tr )
    if IsValid( tr.Entity ) and tr.Entity.IsGlideRagdoll then
        return false
    end
end )

hook.Add( "CanProperty", "Glide.BlockPlayerRagdolls", function( _, _, ent )
    if ent.IsGlideRagdoll then
        return false
    end
end )

hook.Add( "PlayerDeath", "Glide.CleanupPlayerRagdolls", function( victim )
    if victim.GlideRagdoll then
        Glide.UnRagdollPlayer( victim )
    end
end )

hook.Add( "PlayerDisconnected", "Glide.CleanupPlayerRagdolls", function( ply )
    if ply.GlideRagdoll then
        Glide.UnRagdollPlayer( ply )
    end
end )

hook.Add( "PreCleanupMap", "Glide.CleanupPlayerRagdolls", function()
    for _, ply in player.Iterator() do
        Glide.UnRagdollPlayer( ply )
    end
end )

hook.Add( "EntityTakeDamage", "Glide.RagdollDamage", function( ent, dmginfo )
    if not ent.IsGlideRagdoll then return end

    local ply = ent.GlideRagdollPlayer
    if not IsValid( ply ) then return end

    local spawnData = ply.GlideSpawnData
    if not spawnData then return end

    if spawnData.god then return end
    if spawnData.health < 1 then return end

    if dmginfo:IsDamageType( 1 ) then
        dmginfo:SetDamage( math.ceil( dmginfo:GetDamage() * 0.1 ) )
    end

    local ignore = hook.Run( "EntityTakeDamage", ply, dmginfo )
    if ignore then return end

    local damage = dmginfo:GetDamage()
    if damage < 1 then return end

    spawnData.health = spawnData.health - damage

    if spawnData.health < 1 then
        local attacker = dmginfo:GetAttacker()
        local inflictor = dmginfo:GetInflictor()
    end
end )

hook.Add( "CLoadoutCanGiveWeapons", "Glide.BlockRagdollLoadout", function( ply )
    if ply.GlideBlockLoadout then return false end
end )
