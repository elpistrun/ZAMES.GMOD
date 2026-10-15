--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/cl_s8m1q2bw5x.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

TPIK = TPIK or {}

TPIK.Bones = {
    "ValveBiped.Bip01_L_Hand", "ValveBiped.Bip01_L_Finger4", "ValveBiped.Bip01_L_Finger41", "ValveBiped.Bip01_L_Finger42",
    "ValveBiped.Bip01_L_Finger3", "ValveBiped.Bip01_L_Finger31", "ValveBiped.Bip01_L_Finger32", "ValveBiped.Bip01_L_Finger2",
    "ValveBiped.Bip01_L_Finger21", "ValveBiped.Bip01_L_Finger22", "ValveBiped.Bip01_L_Finger1", "ValveBiped.Bip01_L_Finger11",
    "ValveBiped.Bip01_L_Finger12", "ValveBiped.Bip01_L_Finger0", "ValveBiped.Bip01_L_Finger01", "ValveBiped.Bip01_L_Finger02",
    "ValveBiped.Bip01_R_Hand", "ValveBiped.Bip01_R_Finger4", "ValveBiped.Bip01_R_Finger41", "ValveBiped.Bip01_R_Finger42",
    "ValveBiped.Bip01_R_Finger3", "ValveBiped.Bip01_R_Finger31", "ValveBiped.Bip01_R_Finger32", "ValveBiped.Bip01_R_Finger2",
    "ValveBiped.Bip01_R_Finger21", "ValveBiped.Bip01_R_Finger22", "ValveBiped.Bip01_R_Finger1", "ValveBiped.Bip01_R_Finger11",
    "ValveBiped.Bip01_R_Finger12", "ValveBiped.Bip01_R_Finger0", "ValveBiped.Bip01_R_Finger01", "ValveBiped.Bip01_R_Finger02"
}

TPIK.cached_children = TPIK.cached_children or {}
local huytimer = CurTime()

hook.Add("PostCleanupMap", "just_in_case_children", function()
    TPIK.cached_children = {}
    huytimer = CurTime()
end)

local entmeta = FindMetaTable("Entity")

TPIK.SetModel = TPIK.SetModel or entmeta.SetModel

function entmeta:SetModel(mdl)
    self.setmodeltimer = CurTime()
    return TPIK.SetModel(self, mdl)
end

local function recursive_get_children(ent, bone, bones, endbone)
    local children = ent:GetChildBones(bone)

    if #children > 0 then
        local id
        for i = 1, #children do
            id = children[i]
            if id == endbone then continue end
            recursive_get_children(ent, id, bones, endbone)
            bones[#bones + 1] = id
        end
    end
end

TPIK.recursive_get_children = recursive_get_children

local cached_children = TPIK.cached_children
local mdl

function TPIK.get_children(ent, bone, endbone)
    bone = isstring(bone) and ent:LookupBone(bone) or bone

    if not bone or isstring(bone) or bone == -1 then return end
    local bones = {}

    mdl = ent:GetModel()
    local idx = ent:EntIndex()
    cached_children[idx] = cached_children[idx] or {}
    cached_children[idx][mdl] = cached_children[idx][mdl] or {}

    if (huytimer > (ent.setmodeltimer or 0)) then
        cached_children[idx][mdl] = {}
        ent.setmodeltimer = CurTime()
    end

    if not cached_children[idx][mdl][bone] then
        recursive_get_children(ent, bone, bones, endbone)
        cached_children[idx][mdl][bone] = bones
    end

    return cached_children[idx][mdl][bone]
end

function TPIK.bone_apply_matrix(ent, bone, mat, endbone)
    local oldmat = ent:GetBoneMatrix(bone)
    
    ent:SetBoneMatrix(bone, mat)

    local children = TPIK.get_children(ent, bone, endbone)
    if not children then return end

    local inv_oldmat = oldmat:GetInverse()
    if not inv_oldmat then return end

    for i, child in pairs(children) do
        local childmat = ent:GetBoneMatrix(child)
        if childmat then
            local localmat = inv_oldmat * childmat
            ent:SetBoneMatrix(child, mat * localmat)
        end
    end
end

function TPIK.UpdateWMPosition(swep, wm, ply)
    if not IsValid(wm) or not IsValid(ply) then return end

    local ragdoll = ply:GetNWEntity("FakeRagdoll")
    local target_ent = IsValid(ragdoll) and ragdoll or ply

    local velocity = ply:GetVelocity():Length2D()
    local isRunning = false

    

    if not IsValid(ragdoll) then
        if ply == LocalPlayer() then
            isRunning = ply:KeyDown(IN_SPEED) and velocity > ply:GetWalkSpeed() and ply:OnGround()
        else
            local walkSpeed = ply:GetWalkSpeed() or 200
            isRunning = (velocity > walkSpeed * 1.1) and ply:OnGround()
        end
    end
    
    swep.RunFraction = swep.RunFraction or 0
    swep.RunFraction = Lerp(FrameTime() * 6, swep.RunFraction, isRunning and 1 or 0)

    local isSuiciding = ply:GetNWBool("SuicideMode", false) and swep.Base == "orp_base"
    swep.SuicideFraction = swep.SuicideFraction or 0
    swep.SuicideFraction = math.Approach(swep.SuicideFraction, isSuiciding and 1 or 0, FrameTime() * 4)

    local runPos = Vector(0, 0, 0)
    local runAng = Angle(0, 0, 0)

    if swep.RunFraction > 0.01 then
        local t = CurTime() * 11 
        local swayX = math.sin(t) 
        local swayY = math.abs(math.cos(t)) 
        
        local tremorAng = math.sin(CurTime() * 35) * 0.4
        local tremorPos = math.cos(CurTime() * 40) * 0.15
        
        if swep.IsPistol then
            runAng = Angle(-45 + swayY * 2, (swayX * 8) + tremorAng, swayX * -6)
            runPos = Vector(-2 + (swayX * 0.5), tremorPos, -19 + (swayY * 1.5))
        elseif swep.IsRif then
            runAng = Angle(-35 + swayY * 1.5, (swayX * 6) + tremorAng, -10 + (swayX * -4)) 
            runPos = Vector(-2 + (swayX * 0.5), 2 + tremorPos, -12 + (swayY * 1.5))
        elseif swep.IsShotgun then
            runAng = Angle(-35 + swayY * 1.5, (swayX * 6) + tremorAng, -10 + (swayX * -4)) 
            runPos = Vector(-2 + (swayX * 0.5), 2 + tremorPos, -12 + (swayY * 1.5))
        end
    end

    if ply == LocalPlayer() and GetViewEntity() == ply then
        local eyePos = TPIK_CamPos or EyePos()
        local eyeAng = TPIK_CamAng or EyeAngles()

        local tightness = 15
        local float_alpha = 1 - math.exp(-tightness * FrameTime())
        
        swep.TPIK_LerpedDir = swep.TPIK_LerpedDir or eyeAng:Forward()
        swep.TPIK_LerpedDir = LerpVector(float_alpha, swep.TPIK_LerpedDir, eyeAng:Forward())
        
        local floatAng = swep.TPIK_LerpedDir:Angle()
        floatAng.r = eyeAng.r

        local weaponLength = 35
        local wallPushbackSpeed = 10

        local tr = util.TraceLine({
            start = eyePos,
            endpos = eyePos + (eyeAng:Forward() * weaponLength),
            filter = {ply, target_ent, wm},
            mask = MASK_SOLID
        })

        local targetPushback = 0
        if tr.Hit then
            targetPushback = weaponLength * (1 - tr.Fraction)
        end

        swep.WallPushback = swep.WallPushback or 0
        swep.WallPushback = Lerp(FrameTime() * wallPushbackSpeed, swep.WallPushback, targetPushback)

        local isAiming = ply:KeyDown(IN_ATTACK2)
        if tr.Hit or swep.WallPushback > 1 then
            isAiming = false
        end
        
        swep.SightFraction = swep.SightFraction or 0
        swep.SightFraction = math.Approach(swep.SightFraction, isAiming and 1 or 0, FrameTime() * 3)

        local basePos = swep.LWorldPos or Vector(0, 0, 0)
        local baseAng = swep.LWorldAng or Angle(0, 0, 0)
        
        local sightPos = basePos
        local sightAng = baseAng
        
        if swep.Base == "orp_base" or swep:GetClass() == "orp_tazer" then
            sightPos = swep.LSightPos or Vector(0, 0, 0)
            sightAng = swep.LSightAng or Angle(0, 0, 0)
        end
        
        local offsetPos = LerpVector(swep.SightFraction, basePos, sightPos)
        local offsetAng = LerpAngle(swep.SightFraction, baseAng, sightAng)

        offsetPos = LerpVector(swep.RunFraction, offsetPos, offsetPos + runPos)
        offsetAng = LerpAngle(swep.RunFraction, offsetAng, offsetAng + runAng)

        offsetPos.x = offsetPos.x - swep.WallPushback

        local lSuicPos = swep.LSuicidePos or Vector(0, 0, 0)
        local lSuicAng = swep.LSuicideAng or Angle(0, 0, 0)
        
        offsetPos = LerpVector(swep.SuicideFraction, offsetPos, lSuicPos)
        offsetAng = LerpAngle(swep.SuicideFraction, offsetAng, lSuicAng)

        local newPos, newAng = LocalToWorld(offsetPos, offsetAng, eyePos, floatAng)

        wm:SetPos(newPos)
        wm:SetAngles(newAng)
    else
        local bone = target_ent:LookupBone("ValveBiped.Bip01_Spine4")
        if bone then
            local matrix = target_ent:GetBoneMatrix(bone)
            if matrix then
                local offsetPos = swep.WorldPos or Vector(0, 0, 0)
                local offsetAng = swep.WorldAng or Angle(0, 0, 0)
                
                offsetPos = LerpVector(swep.RunFraction, offsetPos, offsetPos + runPos)
                offsetAng = LerpAngle(swep.RunFraction, offsetAng, offsetAng + runAng)

                local wSuicPos = swep.SuicidePos or Vector(0, 0, 0)
                local wSuicAng = swep.SuicideAng or Angle(0, 0, 0)
                
                offsetPos = LerpVector(swep.SuicideFraction, offsetPos, wSuicPos)
                offsetAng = LerpAngle(swep.SuicideFraction, offsetAng, wSuicAng)

                local newPos, newAng = LocalToWorld(offsetPos, offsetAng, matrix:GetTranslation(), ply:EyeAngles())

                wm:SetPos(newPos)
                wm:SetAngles(newAng)
            end
        end
    end
end

function TPIK.DoTPIK(swep, isdepth)
    local wm = swep:GetWM()
    if not IsValid(wm) then return end

    local ply = swep:GetOwner()
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local ragdoll = ply:GetNWEntity("FakeRagdoll")
    local target_ent = IsValid(ragdoll) and ragdoll or ply

    if ply ~= LocalPlayer() then
        local net_anim = swep:GetTPIK_Anim()
        local net_time = swep:GetTPIK_AnimTime()

        if net_anim and net_anim ~= "" and swep.LastTPIK_AnimTime ~= net_time then
            swep.LastTPIK_AnimTime = net_time
            local seq = wm:LookupSequence(net_anim)
            if seq ~= -1 then
                wm:SetSequence(seq)
                wm:SetCycle(0)
            end
        end
    end

    TPIK.UpdateWMPosition(swep, wm, ply)

    wm:FrameAdvance(FrameTime())
    wm:InvalidateBoneCache()
    wm:SetupBones() 
    target_ent:SetupBones()

    local target_spine_index = target_ent:LookupBone("ValveBiped.Bip01_Spine4")
    if not target_spine_index then return end
    local target_spine_matrix = target_ent:GetBoneMatrix(target_spine_index)
    if not target_spine_matrix then return end
    local wmpos = target_spine_matrix:GetTranslation()

    local r_offset = (swep.TPIKPoseHand and swep.TPIKPoseHand["right_hand"]) or { Pos = Vector(0,0,0), Ang = Angle(0,0,0) }
    local l_offset = (swep.TPIKPoseHand and swep.TPIKPoseHand["left_hand"])  or { Pos = Vector(0,0,0), Ang = Angle(0,0,0) }

    local isLeftHandGrabbed = IsValid(ragdoll) and ragdoll:GetNW2Bool("LH_Grabbed", false) or false

    for _, bone in ipairs(TPIK.Bones) do
        if isLeftHandGrabbed and string.find(bone, "_L_") then continue end

        local wm_boneindex = wm:LookupBone(bone)
        local target_boneindex = target_ent:LookupBone(bone)

        if not wm_boneindex or not target_boneindex then continue end

        local wm_bonematrix = wm:GetBoneMatrix(wm_boneindex)
        local target_bonematrix = target_ent:GetBoneMatrix(target_boneindex)

        if not wm_bonematrix or not target_bonematrix then continue end

        local bonepos = wm_bonematrix:GetTranslation()
        local boneang = wm_bonematrix:GetAngles()

        if string.find(bone, "_R_") then
            bonepos, boneang = LocalToWorld(r_offset.Pos, r_offset.Ang, bonepos, boneang)
        elseif string.find(bone, "_L_") then
            bonepos, boneang = LocalToWorld(l_offset.Pos, l_offset.Ang, bonepos, boneang)
        end

        bonepos.x = math.Clamp(bonepos.x, wmpos.x - 38, wmpos.x + 38)
        bonepos.y = math.Clamp(bonepos.y, wmpos.y - 38, wmpos.y + 38)
        bonepos.z = math.Clamp(bonepos.z, wmpos.z - 38, wmpos.z + 38)

        target_bonematrix:SetTranslation(bonepos)
        target_bonematrix:SetAngles(boneang)

        target_ent:SetBoneMatrix(target_boneindex, target_bonematrix)
        target_ent:SetBonePosition(target_boneindex, bonepos, boneang)
    end

    if ply.zsmanipstart then
        TPIK.DoZSManip(target_ent, ply, swep)
    end

    local eyeang = ply:EyeAngles()

    local r_upperarm_idx = target_ent:LookupBone("ValveBiped.Bip01_R_UpperArm")
    local r_forearm_idx = target_ent:LookupBone("ValveBiped.Bip01_R_Forearm")
    local r_hand_idx = target_ent:LookupBone("ValveBiped.Bip01_R_Hand")

    if r_upperarm_idx and r_forearm_idx and r_hand_idx then
        local upper_mat = target_ent:GetBoneMatrix(r_upperarm_idx)
        local fore_mat = target_ent:GetBoneMatrix(r_forearm_idx)
        local hand_mat = target_ent:GetBoneMatrix(r_hand_idx)

        if upper_mat and fore_mat and hand_mat then
            local u_len = target_ent:BoneLength(r_forearm_idx)
            if not u_len or u_len == 0 then u_len = 12 end

            local upper_pos, fore_pos, upper_ang, fore_ang = TPIK.Solve2PartIK(
                upper_mat:GetTranslation(), hand_mat:GetTranslation(), u_len, u_len, -1.1, eyeang
            )

            upper_mat:SetAngles(upper_ang)
            fore_mat:SetTranslation(upper_pos)
            fore_mat:SetAngles(fore_ang)
            hand_mat:SetTranslation(fore_pos)

            TPIK.bone_apply_matrix(target_ent, r_upperarm_idx, upper_mat, r_forearm_idx)
            TPIK.bone_apply_matrix(target_ent, r_forearm_idx, fore_mat, r_hand_idx)
            TPIK.bone_apply_matrix(target_ent, r_hand_idx, hand_mat)
        end
    end

    -- 4. IK Левой руки
    local l_upperarm_idx = target_ent:LookupBone("ValveBiped.Bip01_L_UpperArm")
    local l_forearm_idx = target_ent:LookupBone("ValveBiped.Bip01_L_Forearm")
    local l_hand_idx = target_ent:LookupBone("ValveBiped.Bip01_L_Hand")

    if l_upperarm_idx and l_forearm_idx and l_hand_idx and not isLeftHandGrabbed then
        local upper_mat = target_ent:GetBoneMatrix(l_upperarm_idx)
        local fore_mat = target_ent:GetBoneMatrix(l_forearm_idx)
        local hand_mat = target_ent:GetBoneMatrix(l_hand_idx)

        if upper_mat and fore_mat and hand_mat then
            local u_len = target_ent:BoneLength(l_forearm_idx)
            if not u_len or u_len == 0 then u_len = 12 end

            local upper_pos, fore_pos, upper_ang, fore_ang = TPIK.Solve2PartIK(
                upper_mat:GetTranslation(), hand_mat:GetTranslation(), u_len, u_len, 1.2, eyeang
            )

            upper_mat:SetAngles(upper_ang)
            fore_mat:SetTranslation(upper_pos)
            fore_mat:SetAngles(fore_ang)
            hand_mat:SetTranslation(fore_pos)

            TPIK.bone_apply_matrix(target_ent, l_upperarm_idx, upper_mat, l_forearm_idx)
            TPIK.bone_apply_matrix(target_ent, l_forearm_idx, fore_mat, l_hand_idx)
            TPIK.bone_apply_matrix(target_ent, l_hand_idx, hand_mat)
        end
    end
end

-- Глобальные хуки
hook.Add("PrePlayerDraw", "ARC9_TPIK_Draw", function(ply, flags)
    if ply then
        local tick = FrameNumber()
        if ply.ARC9LastTPIKTick ~= tick or flags ~= 0 then
            ply.ARC9LastTPIKTick = tick
            local wpn = ply:GetActiveWeapon()
            if IsValid(wpn) and wpn.DoTPIK then
                wpn:DoTPIK(flags == 134217729)
            end
        end
    end
end)

hook.Add("PreDrawOpaqueRenderables", "TPIKRagdoll_Draw", function()
    for _, ply in player.Iterator() do
        local wpn = ply:GetActiveWeapon()

        if ply:GetNWBool("Otrub") or ply:GetNWBool("TazerFake") or ply:GetNWBool("InvalidNeck") then
            if IsValid(wpn) then wpn:SetNoDraw(true) end
            continue
        else
            if IsValid(wpn) and wpn:GetNoDraw() then 
                wpn:SetNoDraw(false) 
            end
        end
        local ragdoll = ply:GetNWEntity("FakeRagdoll")
        if IsValid(ragdoll) and ply:GetNoDraw() then
            local wpn = ply:GetActiveWeapon()
            if IsValid(wpn) and wpn.DoTPIK and wpn.SupportTPIK then
                wpn:DoTPIK(false)
                local wm = wpn:GetWM()
                if IsValid(wm) then
                    wm:DrawModel()
                end
            end
        end
    end
end)
