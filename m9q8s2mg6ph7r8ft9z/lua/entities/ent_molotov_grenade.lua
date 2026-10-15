--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/entities/ent_molotov_grenade.lua <
    > Callstack:  <
]]

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Molotov"
ENT.Spawnable = false

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/weapons/arccw_go/w_eq_molotov_thrown.mdl")
        
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
    end

    function ENT:PhysicsCollide(data, phys)
        if self.HasExploded then return end
        self.HasExploded = true

        if data.Speed > 50 then
            self:EmitSound("zames/weapons/darsu_eft/grenades/grenade_collision_concrete2.ogg", 75, math.random(95, 105))
        end

        self:Explosion(data.OurOldVelocity)
    end

    local function IgniteEntitiesInRadius(pos, radius, duration)
        for _, ent in ipairs(ents.FindInSphere(pos, radius)) do
            if IsValid(ent) and not ent:IsWorld() then
                local class = ent:GetClass()
                
                if class == "prop_physics" or class == "prop_ragdoll" or ent:IsPlayer() or ent:IsNPC() then
                    ent:Ignite(duration)
                    
                    if ent:IsPlayer() and not IsValid(ent.FakeRagdoll) then
                        if isfunction(Faking) then
                            Faking(ent)
                        elseif isfunction(ent.Faking) then
                            ent:Faking()
                        end
                    end
                end
            end
        end
    end

    function ENT:Explosion(hitVel)
        local pos = self:GetPos()
        local owner = self:GetOwner()
        
        hitVel = hitVel or Vector(0, 0, 0)

        local effectdata = EffectData()
        effectdata:SetOrigin(pos)
        util.Effect("Explosion", effectdata)

        util.BlastDamage(self, owner or self, pos, 300, 10)
        sound.Play("zames/weapons/darsu_eft/grenades/gren_expl3_indoor_close.ogg", pos, 100, 100, 1)

        local fireCount = 10 
        local firesPerTick = 5 
        local ticks = math.ceil(fireCount / firesPerTick)
        
        local timerName = "MolotovSpread_" .. tostring(math.random(100000, 999999))

        --timer.Simple(0.01, function()
        IgniteEntitiesInRadius(pos, 80, 12)

        --timer.Create(timerName, 0.1, ticks, function()
        for i = 1, firesPerTick do
            -- Больше не нужны сложные просчеты TraceLine, огонь сам полетит по инерции
            local fire = ents.Create("ent_jack_gmod_eznapalm")
            if IsValid(fire) then
                -- Спавним огонь в центре взрыва (чуть выше, чтобы не застрял)
                fire:SetPos(pos + Vector(0, 0, 10))
                
                -- Вычисляем конус разброса на основе вектора полета гранаты
                local spread = hitVel:Angle()
                spread:Add(Angle(math.Rand(-35, 35), math.Rand(-35, 35), 0))
                
                -- Берем 40-80% от начальной скорости гранаты + добавляем случайный подскок
                local velocityForward = spread:Forward() * (hitVel:Length() * math.Rand(0.4, 0.8))
                
                fire.DefaultSpeed = 0
                fire.InitialVel = velocityForward + Vector(0, 0, math.random(50, 150))

                fire:SetKeyValue("health", "10")
                fire:SetKeyValue("firesize", tostring(math.random(90, 130)))
                fire:SetKeyValue("fireattack", "1") 
                fire:SetKeyValue("damagescale", "3")
                fire:SetKeyValue("spawnflags", "5") 
                if IsValid(owner) then fire:SetOwner(owner) end
                
                fire:Spawn()
                fire:Activate()
                
                fire:Fire("StartFire")
                fire:Fire("Kill", "", 10) 
            end
            
            IgniteEntitiesInRadius(pos, 70, 10)
        end
        --end)
        --end)

        self:Remove()
    end
end
