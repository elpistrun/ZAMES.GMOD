--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/weapon_hands/shared.lua <
    > Callstack: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/weapon_hands/cl_init.lua:1 <
]]

SWEP.Base = "weapon_base"

SWEP.PrintName = "Руки"
SWEP.Category = "Weapons - Other"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.WorldModel = "models/weapons/c_arms.mdl"
SWEP.WorldModelReal = "models/weapons/c_arms.mdl"
SWEP.HoldType = "rpg"
SWEP.Slot = 0

SWEP.DrawCrosshair = false

SWEP.DrawWeaponInfoBox = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.SupportTPIK = true
SWEP.DeploySound = ""

SWEP.IconPos = Vector(30,-18,3)
SWEP.IconAng = Angle(0,90,0)
SWEP.ReachDistance = 75

SWEP.Animations = {
    ["idle"] = "fists_draw",
    ["hit1"] = "fists_right",
    ["hit2"] = "fists_left",
    ["hit3"] = "fists_uppercut",
}

function SWEP:SetupDataTables()
    self:NetworkVar("String", 0, "TPIK_Anim")
    self:NetworkVar("Float", 1, "TPIK_AnimTime")
    self:NetworkVar("Bool", 0, "FistsRaised") 

    self:NetworkVar("Entity", 0, "SyncCarryEnt")
    self:NetworkVar("Vector", 0, "SyncCarryPos")
    self:NetworkVar("Float", 2, "SyncCarryMass") 
    
    self:NetworkVar("Int", 0, "SyncCarryBone") 
end

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:DoAnimation(key)
    local data = self.Animations[key]
    if not data then return end
    
    if istable(data) then
        self:PlayAnimation(data.anim, data.mult or 1)
    elseif isstring(data) then
        self:PlayAnimation(data, 1)
    end
end

function SWEP:Deploy()
    self:SetFistsRaised(false)
    self:SetHoldType("normal")
    return true
end

function SWEP:CanPickup(ent)
    local ply = self:GetOwner()
    if IsValid(ply:GetNWEntity("FakeRagdoll")) then return end
    if ent:IsNPC() then return false end
    if ent:IsPlayer() then return false end
    if ent:IsWorld() then return false end
    if CLIENT then return true end
    if ent:IsPlayerHolding() then return false end
    if IsValid(ent:GetPhysicsObject()) and ent:GetPhysicsObject():IsMotionEnabled() then return true end
    return false
end

function SWEP:GetCarrying()
    return self.CarryEnt
end

function SWEP:SetCarrying(ent, bone, pos, dist)
    if not SERVER then return end
    
    if IsValid(ent) then
        self.CarryEnt = ent
        self.CarryBone = bone or 0
        self.CarryDist = dist
        
        self:SetSyncCarryEnt(ent)
        self:SetSyncCarryBone(self.CarryBone)

        local phys = ent:GetPhysicsObjectNum(self.CarryBone)
        if IsValid(phys) then
            self:SetSyncCarryMass(phys:GetMass())
        else
            self:SetSyncCarryMass(0)
        end

        if ent:GetClass() ~= "prop_ragdoll" then
            self.CarryPos = ent:WorldToLocal(pos)
            self:SetSyncCarryPos(self.CarryPos)
        else
            if IsValid(phys) then
                self.CarryPos = WorldToLocal(pos, angle_zero, phys:GetPos(), phys:GetAngles())
                self:SetSyncCarryPos(self.CarryPos)
            else
                self.CarryPos = nil
                self:SetSyncCarryPos(Vector(0,0,0))
            end
        end
    else
        self.CarryEnt = nil
        self.CarryBone = nil
        self.CarryPos = nil
        self.CarryDist = nil
        
        self:SetSyncCarryEnt(NULL)
        self:SetSyncCarryMass(0)
        self:SetSyncCarryBone(0)
    end
end

function SWEP:ApplyForce()
    local ply = self:GetOwner()
    self.CarryDist = Lerp(FrameTime() * 5, self.CarryDist, 20)

    local startPos = ply:GetShootPos()
    local aimVec = ply:GetAimVector()
    local ragdoll = ply:GetNWEntity("FakeRagdoll")

    if IsValid(ragdoll) then
        if CLIENT and TPIK_CamPos and TPIK_CamAng then
            startPos = TPIK_CamPos
            aimVec = TPIK_CamAng:Forward()
        else
            aimVec = ply:EyeAngles():Forward()
            
            local headBone = ragdoll:LookupBone("ValveBiped.Bip01_Head1")
            if headBone then
                local physId = ragdoll:TranslateBoneToPhysBone(headBone)
                local phys = ragdoll:GetPhysicsObjectNum(physId)
                
                if IsValid(phys) then
                    startPos = phys:GetPos()
                else
                    local att = ragdoll:LookupAttachment("eyes")
                    if att and att > 0 then
                        local eyes = ragdoll:GetAttachment(att)
                        if eyes then startPos = eyes.Pos end
                    end
                end
            end
        end
    end

    local target = aimVec * self.CarryDist + startPos + Vector(0, 0, 5)
    
    if not IsValid(self.CarryEnt) then return end
    local phys = self.CarryEnt:GetPhysicsObjectNum(self.CarryBone or 0)

    if IsValid(phys) then
        local TargetPos = phys:GetPos()

        if self.CarryPos then
            if self.CarryEnt:GetClass() == "prop_ragdoll" then
                TargetPos = LocalToWorld(self.CarryPos, angle_zero, phys:GetPos(), phys:GetAngles())
            else
                TargetPos = self.CarryEnt:LocalToWorld(self.CarryPos)
            end
        end

        local vec = target - TargetPos
        local len, mul = vec:Length(), self.CarryEnt:GetPhysicsObject():GetMass()

        local StandingEnt = ply:GetGroundEntity()
        local StandingOn = IsValid(StandingEnt) and ((StandingEnt == self.CarryEnt) or (StandingEnt:IsConstrained() and table.HasValue(constraint.GetAllConstrainedEntities(StandingEnt), self.CarryEnt)))
        local PlyIn = (self.CarryEnt == ply:GetVehicle())
        
        if len > self.ReachDistance or StandingOn or PlyIn then
            self:SetCarrying()
            return
        end

        if self.CarryEnt:GetClass() == "prop_ragdoll" then
            mul = mul * 10
        end

        vec:Normalize()
        
        local plyVel = ply:GetVelocity()
        if IsValid(ragdoll) then
            local ragPhys = ragdoll:GetPhysicsObject()
            if IsValid(ragPhys) then
                plyVel = ragPhys:GetVelocity()
            end
        end

        local avec, velo = vec * len^1.5, phys:GetVelocity() - (plyVel * 2)
        local Force = (avec - velo / 2) * mul
        local ForceNormal = Force:GetNormalized()
        local ForceMagnitude = Force:Length()
        
        local strengthMult = (JMod and JMod.GetPlayerStrength and JMod.GetPlayerStrength(ply)) or 1
        ForceMagnitude = math.Clamp(ForceMagnitude, 0, 2000 * strengthMult)
        Force = ForceNormal * ForceMagnitude

        if self.CarryPos then
            phys:ApplyForceOffset(Force, TargetPos)
        else
            phys:ApplyForceCenter(Force)
        end

        phys:ApplyForceCenter(Vector(0, 0, mul))
        phys:AddAngleVelocity(-phys:GetAngleVelocity() / 10)
    end
end

function SWEP:Think()
    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    if ply:KeyDown(IN_ATTACK2) and not self:GetFistsRaised() then
        if IsValid(self.CarryEnt) then
            self:ApplyForce()
        end
    elseif self.CarryEnt then
        self:SetCarrying()
    end

    if SERVER then
        if ply:KeyDown(IN_ATTACK2) and ply:KeyDown(IN_RELOAD) then
            local tr = ply:GetEyeTrace()
            
            if IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_ragdoll" and tr.HitPos:Distance(ply:EyePos()) < 85 then
                if not self.PulseCheckServerTime then
                    self.PulseCheckServerTime = CurTime()
                end
                
                if CurTime() - self.PulseCheckServerTime >= 2 then
                    self:SetCarrying()
                    self.PulseCheckServerTime = CurTime() + 999
                end
            else
                self.PulseCheckServerTime = nil
            end
        else
            self.PulseCheckServerTime = nil
        end
    end
end

function SWEP:PrimaryAttack()
    if IsValid(self.Owner) and (self.Owner:GetNWBool("Otrub") or self.Owner:GetNWBool("TazerFake") or self.Owner:GetNWBool("InvalidNeck")) then return end
    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    if not self:GetFistsRaised() then return end 
    
    local fakeRagdoll = ply:GetNWEntity("FakeRagdoll")
    
    if not IsValid(fakeRagdoll) and ply:IsSprinting() then return end

    self:SetNextPrimaryFire(CurTime() + 0.6)
    self:DoAnimation("hit" .. math.random(1, 3))

    if CLIENT and IsFirstTimePredicted() then
        Viewpunch(Angle(-5, math.random(-2, 2), math.random(-1, 1)))
    end

    if SERVER then
        local traceFilter = {ply}
        if IsValid(fakeRagdoll) then
            table.insert(traceFilter, fakeRagdoll)
        end

        local tr = util.TraceHull({
            start = ply:GetShootPos(),
            endpos = ply:GetShootPos() + (ply:GetAimVector() * 120),
            mins = Vector(-10, -10, -8),
            maxs = Vector(10, 10, 8),
            filter = traceFilter,
            mask = MASK_SHOT_HULL
        })

        if tr.Hit and IsValid(tr.Entity) then

    

            local dmginfo = DamageInfo()
            dmginfo:SetDamage(math.random(5, 6))
            dmginfo:SetAttacker(ply)
            dmginfo:SetInflictor(self)
            dmginfo:SetDamageType(DMG_CLUB)
            dmginfo:SetDamagePosition(tr.HitPos)
            dmginfo:SetDamageForce(ply:GetAimVector() * 5000)
            
            tr.Entity:TakeDamageInfo(dmginfo)
            ply:EmitSound("Flesh.ImpactHard")
        else
            ply:EmitSound("Weapon_Crowbar.Single")
        end
    end
end

function SWEP:SecondaryAttack()
    if IsValid(self.Owner) and (self.Owner:GetNWBool("Otrub") or self.Owner:GetNWBool("TazerFake") or self.Owner:GetNWBool("InvalidNeck")) then return end
    local ply = self:GetOwner()
    if IsValid(ply:GetNWEntity("FakeRagdoll")) then return end
    if not IsFirstTimePredicted() then return end
    
    if self:GetFistsRaised() then return false end

    if SERVER then
        self:SetCarrying()
        local tr = ply:GetEyeTraceNoCursor()

        if IsValid(tr.Entity) and self:CanPickup(tr.Entity) and not tr.Entity:IsPlayer() then
            local Dist = (ply:GetShootPos() - tr.HitPos):Length()

            if Dist < self.ReachDistance then
                sound.Play("Flesh.ImpactSoft", ply:GetShootPos(), 65, math.random(90, 110))
                self:SetCarrying(tr.Entity, tr.PhysicsBone, tr.HitPos, Dist)
                tr.Entity.Touched = true
                self:ApplyForce()
            end
        end
    end
end

function SWEP:Reload()
    if not IsFirstTimePredicted() then return end
    if self:GetNextPrimaryFire() > CurTime() then return end 

    local bRaised = not self:GetFistsRaised()
    self:SetFistsRaised(bRaised)

    if bRaised then
        self:SetCarrying()
        self:DoAnimation("idle")
        self:SetHoldType("slam")
    else
        self:SetHoldType("normal")
    end

    self:SetNextPrimaryFire(CurTime() + 0.5) 
end

function SWEP:Holster()
    self:SetCarrying()
    return true
end

if CLIENT then

    SWEP.CustomWeaponIcon = mh("zames/weapons/weapon_hands.png")


    local vec1 = Vector(0, 2, 0)
    local vec2 = Vector(0, -2, 0)
    local ang1 = Angle(-30, 5, 70)
    local ang2 = Angle(-30, -5, 110)

    function SWEP:DoTPIK(isdepth)
        if self:GetFistsRaised() then 
            TPIK.DoTPIK(self, isdepth) 
            return
        end

        local carryEnt = self:GetSyncCarryEnt()
        local ply = self:GetOwner()
        if not IsValid(ply) or not ply:IsPlayer() then return end

        local ragdoll = ply:GetNWEntity("FakeRagdoll")
        local target_ent = IsValid(ragdoll) and ragdoll or ply
        target_ent:SetupBones()

        if ply.zsmanipstart then
            TPIK.DoZSManip(target_ent, ply, self)
        end

        local carryPos = self:GetSyncCarryPos()
        local carryBone = self:GetSyncCarryBone()
        local targetPos
        
        local mass = self:GetSyncCarryMass()
        local twohands = mass > 15

        if IsValid(carryEnt) then 
            ply.IKGrabLerp = math.Approach(ply.IKGrabLerp or 0, 1, FrameTime() * 5)
            
            -- ИСПРАВЛЕНО: Рассчитываем targetPos для рэгдолла на основе матрицы конкретной кости
            if carryEnt:GetClass() == "prop_ragdoll" then
                local bone = carryEnt:TranslatePhysBoneToBone(carryBone)
                local mat = bone and carryEnt:GetBoneMatrix(bone)
                if mat then
                    targetPos = LocalToWorld(carryPos, angle_zero, mat:GetTranslation(), mat:GetAngles())
                else
                    targetPos = carryEnt:LocalToWorld(carryPos or Vector(0,0,0))
                end
            else
                targetPos = carryEnt:LocalToWorld(carryPos or Vector(0,0,0))
            end
            
            ply.LastIKTargetPos = targetPos
        else
            ply.IKGrabLerp = math.Approach(ply.IKGrabLerp or 0, 0, FrameTime() * 5)
            if ply.IKGrabLerp <= 0.01 then return end
            targetPos = ply.LastIKTargetPos or (ply:GetShootPos() + ply:GetAimVector() * 30)
        end

        local spine_idx = target_ent:LookupBone("ValveBiped.Bip01_Spine4")
        if not spine_idx then return end
        local spine_matrix = target_ent:GetBoneMatrix(spine_idx)
        if not spine_matrix then return end
        local spine_pos = spine_matrix:GetTranslation()

        local rawFinalPos = targetPos
        local normAngle = (targetPos - ply:EyePos()):Angle()

        if IsValid(carryEnt) then
            local len = math.min((targetPos - spine_pos):Length(), 40)
            local tr = util.TraceLine({
                start = spine_pos,
                endpos = spine_pos + (targetPos - spine_pos):GetNormalized() * len,
                filter = {ply, target_ent}
            })
            
            if tr.Hit and tr.Entity == carryEnt then
                rawFinalPos = tr.HitPos - tr.Normal * 4
            else
                rawFinalPos = targetPos
            end
        else
            local tr = util.TraceLine({
                start = spine_pos,
                endpos = targetPos,
                filter = {ply, target_ent}
            })
            rawFinalPos = tr.HitPos
        end

        ply.SmoothedIKPos = LerpVector(FrameTime() * 12, ply.SmoothedIKPos or rawFinalPos, rawFinalPos)
        local finalPos = ply.SmoothedIKPos

        finalPos.x = math.Clamp(finalPos.x, spine_pos.x - 38, spine_pos.x + 38)
        finalPos.y = math.Clamp(finalPos.y, spine_pos.y - 38, spine_pos.y + 38)
        finalPos.z = math.Clamp(finalPos.z, spine_pos.z - 38, spine_pos.z + 38)

        local eyeang = ply:EyeAngles()

        local function ApplyIKToArm(upper_name, fore_name, hand_name, sign, is_active, offset_vec, offset_ang)
            local upper_idx = target_ent:LookupBone(upper_name)
            local fore_idx = target_ent:LookupBone(fore_name)
            local hand_idx = target_ent:LookupBone(hand_name)

            if upper_idx and fore_idx and hand_idx then
                local upper_mat = target_ent:GetBoneMatrix(upper_idx)
                local fore_mat = target_ent:GetBoneMatrix(fore_idx)
                local hand_mat = target_ent:GetBoneMatrix(hand_idx)

                if upper_mat and fore_mat and hand_mat then
                    local u_len = target_ent:BoneLength(fore_idx)
                    if not u_len or u_len == 0 then u_len = 12 end

                    local hand_target_pos = finalPos
                    local hand_target_ang = hand_mat:GetAngles()

                    if is_active then
                        hand_target_pos, hand_target_ang = LocalToWorld(offset_vec, offset_ang, finalPos, normAngle)
                    else
                        hand_target_pos = hand_mat:GetTranslation()
                    end

                    local current_hand_pos = LerpVector(ply.IKGrabLerp, hand_mat:GetTranslation(), hand_target_pos)
                    local current_hand_ang = LerpAngle(ply.IKGrabLerp, hand_mat:GetAngles(), hand_target_ang)

                    local upper_pos, fore_pos, upper_ang, fore_ang = TPIK.Solve2PartIK(
                        upper_mat:GetTranslation(), current_hand_pos, u_len, u_len, sign, eyeang
                    )

                    upper_mat:SetAngles(upper_ang)
                    fore_mat:SetTranslation(upper_pos)
                    fore_mat:SetAngles(fore_ang)
                    hand_mat:SetTranslation(fore_pos)
                    hand_mat:SetAngles(current_hand_ang)

                    TPIK.bone_apply_matrix(target_ent, upper_idx, upper_mat, fore_idx)
                    TPIK.bone_apply_matrix(target_ent, fore_idx, fore_mat, hand_idx)
                    TPIK.bone_apply_matrix(target_ent, hand_idx, hand_mat)
                end
            end
        end

        ApplyIKToArm("ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_R_Hand", -1.1, twohands, vec2, ang2)
        local l_vec = twohands and vec1 or Vector(0,0,0)
        ApplyIKToArm("ValveBiped.Bip01_L_UpperArm", "ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_L_Hand", 1.2, true, l_vec, ang1)
    end

    local checkPulseStartTime = 0
    local isCheckingPulse = false
    local hasCheckedPulse = false
    local pulseResultText = ""
    local pulseResultTime = 0

    hook.Add("Think", "CheckRagdollPulse", function()
        local ply = LocalPlayer()

        if ply:KeyDown(IN_ATTACK2) and ply:KeyDown(IN_RELOAD) then
            if hasCheckedPulse then return end 

            local tr = ply:GetEyeTrace()
            local ent = tr.Entity

            if IsValid(ent) and ent:GetClass() == "prop_ragdoll" and tr.HitPos:Distance(ply:EyePos()) < 85 then
                
                local owner = ent:GetNWEntity("RagdollOwner") 

                if IsValid(owner) and owner:IsPlayer() then
                    if not isCheckingPulse then
                        isCheckingPulse = true
                        checkPulseStartTime = CurTime()
                    end

                    if CurTime() - checkPulseStartTime >= 2 then
                        isCheckingPulse = false
                        hasCheckedPulse = true
                        pulseResultTime = CurTime() + 3

                        local hp = owner:Health()
                        
                        if not owner:Alive() or hp <= 0 then
                            pulseResultText = "Пульса нет"
                        elseif hp <= 5 then
                            pulseResultText = "Пульс еле ощутимый"
                        elseif hp <= 20 then
                            pulseResultText = "Пульс слабый"
                        elseif hp <= 50 then
                            pulseResultText = "Пульс более-менее"
                        else
                            pulseResultText = "Пульс в норме"
                        end
                    end
                    return
                end
            end
        else
            isCheckingPulse = false
            hasCheckedPulse = false
        end
    end)

    hook.Add("HUDPaint", "DrawPulseCheckHUD", function()
        local x = ScrW() / 2
        local y = ScrH() / 1.5
        local radius = 35 

        if isCheckingPulse then
            local progress = math.Clamp((CurTime() - checkPulseStartTime) / 2, 0, 1)

            draw.CircleProgress(x, y, radius, 1, Color(0, 0, 0, 150))
            draw.CircleProgress(x, y, radius, progress, Color(255, 255, 255, 255))

            draw.SimpleText(
                "Проверяем пульс...", 
                "PT.2",
                x, 
                y - radius - 15, 
                Color(255, 255, 255, 255), 
                TEXT_ALIGN_CENTER, 
                TEXT_ALIGN_BOTTOM
            )
            
        elseif pulseResultTime > CurTime() then
            local alpha = math.Clamp((pulseResultTime - CurTime()) * 255, 0, 255)
            
            draw.SimpleText(
                pulseResultText, 
                "PT.3",
                x, 
                y, 
                Color(255, 255, 255, alpha), 
                TEXT_ALIGN_CENTER, 
                TEXT_ALIGN_CENTER,
                2,
                Color(0, 0, 0, math.Clamp(alpha, 0, 100))
            )
        end
    end)
end

hook.Add("EntityTakeDamage", "CancelDamageFromCarryEnt", function(target, dmginfo)
    if target:IsPlayer() then 
        local Weppy = target:GetActiveWeapon() 
        if IsValid(Weppy) and IsValid(Weppy.CarryEnt) then
            if (dmginfo:GetInflictor() == Weppy.CarryEnt) and (dmginfo:GetDamageType() == DMG_CRUSH) then
                return true
            end
        end
    end
end)

if CLIENT then

    local HandTex, ClosedTex = surface.GetTextureID("vgui/hud/gmod_hand"), surface.GetTextureID("vgui/hud/gmod_closedhand")

    function SWEP:DrawHUD()
        if GetConVar("cl_drawhud"):GetBool() == false then return end
        if not (GetViewEntity() == LocalPlayer()) then return end
        if LocalPlayer():InVehicle() then return end
        local Ply = self.Owner
        local W, H, Build = ScrW(), ScrH()

        if not self:GetFistsRaised() then
            local Tr = util.QuickTrace(self.Owner:GetShootPos(), self.Owner:GetAimVector() * self.ReachDistance, {self.Owner})

            if Tr.Hit then
                if self:CanPickup(Tr.Entity) then
                    local Size = math.Clamp(1 - ((Tr.HitPos - self.Owner:GetShootPos()):Length() / self.ReachDistance) ^ 2, .2, 1)

                    if self.Owner:KeyDown(IN_ATTACK2) then
                        surface.SetTexture(ClosedTex)
                    else
                        surface.SetTexture(HandTex)
                    end

                    surface.SetDrawColor(Color(255, 255, 255, 255 * Size))
                    surface.DrawTexturedRect(ScrW() / 2 - (64 * Size), ScrH() / 2 - (64 * Size), 128 * Size, 128 * Size)
                end
            end
        end
        local ToolBox = Ply:GetWeapon("wep_jack_gmod_eztoolbox")
        if IsValid(ToolBox) and ToolBox:GetNW2Bool("EZoneHandedBuild", false) then
            draw.SimpleTextOutlined("ALT+LMB: use toolbox onehanded: "..ToolBox:GetSelectedBuild(), "Trebuchet24", W * .4, H * .7 + 60, Color(255, 255, 255, 30), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 10))
        end
    end
    
end

--[[local matCircle = mh("zames/models/circle.png") 

SWEP.SmoothX = 0
SWEP.SmoothY = 0
SWEP.SmoothRadius = 0

function SWEP:DrawHUD()
    if not (GetViewEntity() == LocalPlayer()) then return end
    if LocalPlayer():InVehicle() then return end
    
    local ply = self:GetOwner()
    local t = {}
    t.start = TPIK_CamPos
    t.endpos = t.start + ply:GetAngles():Forward() * 90
    t.filter = self:GetOwner()
    local Tr = util.TraceLine(t)

    if Tr.Hit then
        local TargetSize = math.Clamp(1 - ((Tr.HitPos - self:GetOwner():GetShootPos()):Length() / 30) ^ 2, .1, .3)
        local TargetRadius = 40 * TargetSize
        local TargetPos = Tr.HitPos:ToScreen()

        if self.SmoothX == 0 and self.SmoothY == 0 then
            self.SmoothX = TargetPos.x
            self.SmoothY = TargetPos.y
            self.SmoothRadius = TargetRadius
        end

        local speed = 15 * FrameTime()
        self.SmoothX = Lerp(speed, self.SmoothX, TargetPos.x)
        self.SmoothY = Lerp(speed, self.SmoothY, TargetPos.y)
        self.SmoothRadius = Lerp(speed, self.SmoothRadius, TargetRadius)

        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(matCircle)
        
        surface.DrawTexturedRect(
            self.SmoothX - self.SmoothRadius, 
            self.SmoothY - self.SmoothRadius, 
            self.SmoothRadius * 2, 
            self.SmoothRadius * 2
        )
    else
        self.SmoothX = 0
        self.SmoothY = 0
    end
end--]]
-- Методы модели изобраны sh_wm.lua вклеплены сюда, чтобы наследуемые оружия
-- получали их наследовали. include() не сработал: они загружаются только для самого оружия, но не для наследуемых.
-- Код вместо силанеруедую встроки раньше, поэтому руки сработают без ошибки и на сервере быть не должно.

--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/weapon_hands/sh_wm.lua <
    > Callstack: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/weapon_hands/cl_init.lua:2 <
]]

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
    if not IsValid(self.SelectDrawModel) then
        self.SelectDrawModel = ClientsideModel( (self.WorldModelReal or self.WorldModel), RENDER_GROUP_OPAQUE_ENTITY )
        self.SelectDrawModel:SetNoDraw( true )
        self.SelectDrawModelModel = nil
    else
        local selModel = self.WorldModelReal or self.WorldModel

        if self.SelectDrawModelModel ~= selModel then
            self.SelectDrawModel:SetModel( selModel )
            self.SelectDrawModelModel = selModel
        end

        local vec = Vector(0,0,0)
	    local ang = Angle(0,0,0)

        cam.Start3D( vec, ang, 20, x, y + 35, wide, tall, 5, 4096 )
            cam.IgnoreZ( true )
            render.SuppressEngineLighting( true )

            render.SetLightingOrigin( self:GetPos() )
            render.ResetModelLighting( 1 , 1 , 1 )
            render.SetColorModulation( 1, 1, 1 )
            render.SetBlend( 255 )
            render.SetModelLighting( 4, 1, 1, 1 )

            local modelPos = self.IconPos or Vector(0, 0, 0)
            local modelAng = self.IconAng or Angle(0, 0, 0)

            self.SelectDrawModel:SetRenderOrigin( modelPos )
            self.SelectDrawModel:SetRenderAngles( modelAng )
            
            self.SelectDrawModel:DrawModel()
            
            self.SelectDrawModel:SetRenderOrigin()
            self.SelectDrawModel:SetRenderAngles()

            render.SetColorModulation( 1, 1, 1 )
            render.SetBlend( 1 )
            render.SuppressEngineLighting( false )
            cam.IgnoreZ( false )
        cam.End3D()
    end

    self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
end


SWEP.WorldPos = Vector(0, 0, 6) 
SWEP.WorldAng = Angle(0, 0, 0)

SWEP.LWorldPos = Vector(-12, 0, 0) 
SWEP.LWorldAng = Angle(0, 0, 0)

SWEP.TPIKPoseHand = {
    ["right_hand"] = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) },
    ["left_hand"]  = { Pos = Vector(0, 0, 0), Ang = Angle(0, 0, 0) }
}

function SWEP:GetWM()
    if CLIENT then
        if not IsValid(self.WM_Model) and self.InitializeClient then
            self:InitializeClient()
        end
        
        if IsValid(self.WM_Model) then
            return self.WM_Model
        end
    end
    return NULL
end

function SWEP:PlayAnimation(anim, mult)
    TPIK.PlayAnimation(self, anim, mult)
end

if CLIENT then
    function SWEP:InitializeClient()
        if IsValid(self.WM_Model) then return end
        self.WM_Model = ClientsideModel(self.WorldModelReal or self.WorldModel)
        self.WM_Model:SetNoDraw(true)
        self.WM_Model:SetRenderBounds( Vector(-10000,-10000,-10000), Vector(10000,10000,10000) )
    end

    function SWEP:OnRemove()
        if IsValid(self.WM_Model) then
            self.WM_Model:Remove()
        end

        if IsValid(self.SelectDrawModel) then
            self.SelectDrawModel:Remove()
        end
    end

    function SWEP:DrawWorldModel()
        local ply = self:GetOwner()
        
        if not IsValid(ply) then
            self:DrawModel()
            return
        end

        self:InitializeClient()
        
        local wm = self:GetWM()
        if not IsValid(wm) then return end

        TPIK.UpdateWMPosition(self, wm, ply)
        
        wm:SetupBones()
        wm:DrawModel()
    end

    --[[function SWEP:DoTPIK(isdepth)

        if self.GetFistsRaised and not self:GetFistsRaised() then 
            return 
        end

        TPIK.DoTPIK(self, isdepth)
    end--]]
end

