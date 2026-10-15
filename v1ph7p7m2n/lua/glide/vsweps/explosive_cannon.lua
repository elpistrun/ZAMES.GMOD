--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/lua/glide/vsweps/explosive_cannon.lua <
    > Callstack: addons/v1ph7p7m2n/lua/glide/sh_vsweps.lua:35
[C]:-1
addons/v1ph7p7m2n/lua/glide/sh_vsweps.lua:120
addons/v1ph7p7m2n/lua/glide/sh_vsweps.lua:136
lua/autorun/sh_glide.lua:408 <
]]

VSWEP.Base = "base"
VSWEP.Name = "#glide.weapons.explosive_cannon"

if SERVER then
    function VSWEP:PrimaryAttack()
        self:TakePrimaryAmmo( 1 )
        self:SetNextPrimaryFire( CurTime() + self.FireDelay )
        self:IncrementProjectileIndex()
        self:ShootEffects()

        local vehicle = self.Vehicle

        vehicle:FireBullet( {
            pos = vehicle:LocalToWorld( self.ProjectileOffsets[self.projectileOffsetIndex] ),
            ang = vehicle:GetAngles(),
            attacker = vehicle:GetSeatDriver( 1 ),
            isExplosive = true,
            spread = self.Spread,
            damage = self.Damage,
            scale = self.TracerScale
        } )
    end
end

