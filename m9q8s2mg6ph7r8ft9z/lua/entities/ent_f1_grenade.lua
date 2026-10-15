--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/entities/ent_f1_grenade.lua <
    > Callstack:  <
]]

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "F1 Grenade"
ENT.Spawnable = false

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/weapons/arc9/darsu_eft/w_f1.mdl")
        
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()

            phys:SetMass(1)
            phys:SetDamping(0.1, 2)
        end

        timer.Simple(3.5, function()
            if IsValid(self) then
                self:Explosion()
            end
        end)
    end

    function ENT:PhysicsCollide(data, phys)
        if data.Speed > 50 then
            self:EmitSound("zames/weapons/darsu_eft/grenades/grenade_collision_concrete2.ogg", 75, math.random(95, 105))
        end
    end

    function ENT:Explosion()
        local pos = self:GetPos()
        local radius = 300
        local explosionForce = 1400

        local effectdata = EffectData()
        effectdata:SetOrigin(pos)
        util.Effect("Explosion", effectdata)

        util.BlastDamage(self, self:GetOwner() or self, pos, radius, 450)

        for _, ent in ipairs(ents.FindInSphere(pos, radius)) do
        
            local targetPos = ent.WorldSpaceCenter and ent:WorldSpaceCenter() or (ent:GetPos() + Vector(0, 0, 32))
            
            local tr = util.TraceLine({
                start = pos,
                endpos = targetPos,
                filter = {self, ent},
                mask = MASK_SOLID
            })

            if tr.Fraction < 1.0 then
                continue
            end

            if ent:IsPlayer() and ent:Alive() then
                if not IsValid(ent.FakeRagdoll) then
                    if isfunction(Faking) then
                        Faking(ent)
                    elseif isfunction(ent.Faking) then
                        ent:Faking()
                    end
                end
            end

            local rag = nil
            if ent:IsPlayer() then
                rag = ent.FakeRagdoll or ent:GetNWEntity("DeathFakeRagdoll")
            elseif ent:GetClass() == "prop_ragdoll" then
                rag = ent
            end

            if IsValid(rag) then
                timer.Simple(0, function()
                    if IsValid(rag) then
                        for i = 0, rag:GetPhysicsObjectCount() - 1 do
                            local phys = rag:GetPhysicsObjectNum(i)
                            
                            if IsValid(phys) then
                                local dir = (phys:GetPos() - pos):GetNormalized()
                                local dist = phys:GetPos():Distance(pos)
                                local distMult = math.Clamp(1 - (dist / radius), 0.1, 1)
                                
                                local pushForce = dir * explosionForce * distMult * phys:GetMass()
                                phys:ApplyForceCenter(pushForce)
                            end
                        end
                    end
                end)
            end
        end

        ParticleEffect("pcf_jack_groundsplode_large", pos, vector_up:Angle())
        sound.Play("zames/weapons/darsu_eft/grenades/gren_expl3_indoor_close.ogg", pos, 100, 100, 1)

        local shrapnelCount = 40

        for i = 1, shrapnelCount do
            local dir = VectorRand()
            
            local bullet = {
                Num = 1,
                Src = pos,
                Dir = dir,
                Spread = Vector(0, 0, 0), 
                Tracer = 1,
                TracerName = "Tracer",
                Force = 15,
                Damage = 75,
                Attacker = attacker
            }
            
            self:FireBullets(bullet)
        end

        self:Remove()
    end
end
