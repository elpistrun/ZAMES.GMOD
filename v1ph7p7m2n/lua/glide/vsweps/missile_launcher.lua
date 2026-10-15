--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/lua/glide/vsweps/missile_launcher.lua <
    > Callstack: addons/v1ph7p7m2n/lua/glide/sh_vsweps.lua:35
[C]:-1
addons/v1ph7p7m2n/lua/glide/sh_vsweps.lua:120
addons/v1ph7p7m2n/lua/glide/sh_vsweps.lua:136
lua/autorun/sh_glide.lua:408 <
]]

VSWEP.Base = "base"
VSWEP.Name = "#glide.weapons.missiles"
VSWEP.Icon = "glide/icons/rocket.png"

if SERVER then
    VSWEP.FireDelay = 1
    VSWEP.EnableLockOn = false

    -- If not empty, use this as the missile model
    VSWEP.MissileModel = ""

    -- Missile model scale
    VSWEP.MissileModelScale = 1.0
end

if CLIENT then
    VSWEP.CrosshairImage = "glide/aim_square.png"
end

if SERVER then
    function VSWEP:PrimaryAttack()
        self:TakePrimaryAmmo( 1 )
        self:SetNextPrimaryFire( CurTime() + self.FireDelay )
        self:IncrementProjectileIndex()
        self:ShootEffects()

        local vehicle = self.Vehicle
        local target

        -- Only make the missile follow the target when
        -- using the homing missiles and with a "hard" lock-on
        if self.EnableLockOn and vehicle:GetLockOnState() == 2 then
            target = vehicle:GetLockOnTarget()
        end

        local pos = vehicle:LocalToWorld( self.ProjectileOffsets[self.projectileOffsetIndex] )
        local missile = vehicle:FireMissile( pos, vehicle:GetAngles(), vehicle:GetSeatDriver( 1 ), target )
        missile:SetModelScale( self.MissileModelScale )

        if self.MissileModel ~= "" then
            missile:SetModel( self.MissileModel )
        end
    end
end

