--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/sh_s8m1q2bw5x.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:26
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

TPIK = TPIK or {}

function TPIK.PlayAnimation(swep, anim, mult)
    mult = mult or 1

    if SERVER then
        swep:SetTPIK_Anim(anim)
        swep:SetTPIK_AnimTime(CurTime())
    end
    
    local mdl = CLIENT and (swep.GetWM and swep:GetWM()) or nil
    
    if not IsValid(mdl) then return end
    
    local seq = mdl:LookupSequence(anim)
    if seq == -1 then return end
    
    mdl:SetSequence(seq)
    mdl:SetCycle(0)
    mdl:SetPlaybackRate(mult)
end

function TPIK.Solve2PartIK(start_p, end_p, length0, length1, sign, angs)
    local length2 = (start_p - end_p):Length()
    local cosAngle0 = math.Clamp(((length2 * length2) + (length0 * length0) - (length1 * length1)) / (2 * length2 * length0), -1, 1)
    local angle0 = -math.deg(math.acos(cosAngle0))
    local cosAngle1 = math.Clamp(((length1 * length1) + (length0 * length0) - (length2 * length2)) / (2 * length1 * length0), -1, 1)
    local angle1 = -math.deg(math.acos(cosAngle1))

    local diff = end_p - start_p
    diff:Normalize()

    local angle2 = math.deg(math.atan2(-math.sqrt(diff.x * diff.x + diff.y * diff.y), diff.z)) - 90
    local angle3 = -math.deg(math.atan2(diff.x, diff.y)) - 90
    angle3 = math.NormalizeAngle(angle3)

    local axis = diff * 1
    axis:Normalize()
    
    local torsoang = vector_up:Angle()
    local Joint0 = Angle(angle0 + angle2, angle3, 0)

    local asdot = -vector_up:Dot(torsoang:Up())
    local diffa2 = 90 + (sign > 0 and -30 or 30)
    
    local tors = torsoang:Up()
    local torsoright = angs.y + 120 * sign
    
    Joint0:RotateAroundAxis(Joint0:Forward(), diffa2)
    Joint0:RotateAroundAxis(axis, angle3 - torsoright)
    local ang1 = -(-Joint0)

    local Joint0_vec = Joint0:Forward() * length0

    local Joint1 = Angle(angle0 + angle2 + 180 + angle1, angle3, 0)
    Joint1:RotateAroundAxis(Joint1:Forward(), diffa2)
    Joint1:RotateAroundAxis(axis, angle3 - torsoright)
    local ang2 = -(-Joint1)

    local Joint1_vec = Joint1:Forward() * length1

    local Joint0_F = start_p + Joint0_vec
    local Joint1_F = Joint0_F + Joint1_vec

    return Joint0_F, Joint1_F, ang1, ang2
end

TPIK.Gestures = {

    ["open_door"] = {
        mdl = "models/weapons/c_vmanipusedoor.mdl", 
        seq = "usedoor",       
        playTime = 1.5,

        lhand = false,
        rhand = true,

        LWorldPos = Vector(-10, 0, 0), 
        LWorldAng = Angle(0, 0, 0),

        WorldPos = Vector(0, 0, 8),
        WorldAng = Angle(0, 0, 0)
    },


    -- anim gestures
    ["hello"] = {
        mdl = "models/weapons/gcal/gcal_bocw_gesture.mdl", 
        seq = "hello",       
        playTime = 2,

        lhand = false,
        rhand = true,

        LWorldPos = Vector(-10, 0, 0), 
        LWorldAng = Angle(0, 0, 0),

        WorldPos = Vector(0, 0, 4),
        WorldAng = Angle(0, 0, 0)
    },
    ["fuckyou"] = {
        mdl = "models/weapons/gcal/gcal_bocw_gesture.mdl", 
        seq = "crank_finger",       
        playTime = 3.5,

        lhand = false,
        rhand = false,

        LWorldPos = Vector(-10, 0, 0), 
        LWorldAng = Angle(0, 0, 0),

        WorldPos = Vector(0, 0, 4),
        WorldAng = Angle(0, 0, 0)
    },
}
if SERVER then
    util.AddNetworkString("TPIK_RunGesture")

    for name, _ in pairs(TPIK.Gestures) do
        concommand.Add("act_gesture_" .. name, function(ply)
            if not IsValid(ply) or not ply:Alive() then return end
            
            net.Start("TPIK_RunGesture")
            net.WriteEntity(ply)
            net.WriteString(name)
            net.Broadcast()
        end)
    end
end

if CLIENT then
    function TPIK.PlayGesture(ply, gestureName)
        local data = TPIK.Gestures[gestureName]
        if not data or not data.mdl then return end

        if not IsValid(ply.zsmodel) then
            ply.zsmodel = ClientsideModel(data.mdl)
            ply.zsmodel:SetNoDraw(true)
        end

        local zmdl = ply.zsmodel
        zmdl:SetModel(data.mdl)
        
        ply.zsmanipstart = CurTime()
        ply.zsmaniptime = data.playTime or 1
        ply.zsmanipseq = data.seq
        ply.zsmanipname = gestureName
        
        local seqID = zmdl:LookupSequence(data.seq)
        if seqID ~= -1 then
            zmdl:SetSequence(seqID)
            zmdl:SetCycle(0)
        end
    end

    net.Receive("TPIK_RunGesture", function()
        local ply = net.ReadEntity()
        local name = net.ReadString()
        
        if IsValid(ply) then
            TPIK.PlayGesture(ply, name)
        end
    end)

    local IgnoredRightHandBases = {
        ["orp_base"] = true,
        ["orp_melee_base"] = true,
    }

    local function IsWeaponIgnoredForRightHand(wep)
        if not IsValid(wep) then return false end

        if wep.Base and IgnoredRightHandBases[wep.Base] then
            return true
        end

        local class = wep:GetClass()
        for baseName, _ in pairs(IgnoredRightHandBases) do
            if weapons.IsBasedOn(class, baseName) then
                return true
            end
        end

        return false
    end

    local IgnoredRightHandBases = {
        ["orp_base"] = true,
        ["orp_melee_base"] = true,
    }

    local function IsWeaponIgnoredForRightHand(wep)
        if not IsValid(wep) then return false end

        if wep.Base and IgnoredRightHandBases[wep.Base] then
            return true
        end

        local class = wep:GetClass()
        for baseName, _ in pairs(IgnoredRightHandBases) do
            if weapons.IsBasedOn(class, baseName) then
                return true
            end
        end

        return false
    end

    function TPIK.DoZSManip(ent, ply, swep)
        if not IsValid(ply.zsmodel) or not ply.zsmanipstart or not ply.zsmanipname then return end
        
        local gestureData = TPIK.Gestures[ply.zsmanipname]
        if not gestureData then return end

        local progress = (CurTime() - ply.zsmanipstart) / ply.zsmaniptime

        if progress >= 1 then
            ply.zsmanipstart = nil
            ply.zsmanipname = nil
            return
        end

        local blendIn = 0.2
        local blendOut = 0.25
        local weight = 1

        if progress < blendIn then
            weight = math.ease.InOutSine(progress / blendIn)
        elseif progress > (1 - blendOut) then
            weight = math.ease.InOutSine((1 - progress) / blendOut)
        end

        local WorldModel = ply.zsmodel
        local newPos, newAng

        if ply == LocalPlayer() and GetViewEntity() == ply then
            local eyePos = TPIK_CamPos or EyePos()
            local eyeAng = TPIK_CamAng or EyeAngles()
            
            local basePos = gestureData.LWorldPos or Vector(0, 0, 0)
            local baseAng = gestureData.LWorldAng or Angle(0, 0, 0)
            
            newPos, newAng = LocalToWorld(basePos, baseAng, eyePos, eyeAng)
        else
            local bone = ent:LookupBone("ValveBiped.Bip01_Spine4")
            if bone then
                local matrix = ent:GetBoneMatrix(bone)
                if matrix then
                    local basePos = gestureData.WorldPos or Vector(0, 0, 0)
                    local baseAng = gestureData.WorldAng or Angle(0, 0, 0)
                    
                    newPos, newAng = LocalToWorld(basePos, baseAng, matrix:GetTranslation(), ply:EyeAngles())
                end
            end
            
            if not newPos or not newAng then
                newPos, newAng = ply:GetPos(), ply:GetAngles()
            end
        end

        WorldModel:SetPos(newPos)
        WorldModel:SetAngles(newAng)
        
        WorldModel:SetCycle(progress)
        WorldModel:InvalidateBoneCache()
        WorldModel:SetupBones() 

        local gesture_bones = {
            "ValveBiped.Bip01_L_Hand",
            "ValveBiped.Bip01_L_Finger4", "ValveBiped.Bip01_L_Finger41", "ValveBiped.Bip01_L_Finger42",
            "ValveBiped.Bip01_L_Finger3", "ValveBiped.Bip01_L_Finger31", "ValveBiped.Bip01_L_Finger32",
            "ValveBiped.Bip01_L_Finger2", "ValveBiped.Bip01_L_Finger21", "ValveBiped.Bip01_L_Finger22",
            "ValveBiped.Bip01_L_Finger1", "ValveBiped.Bip01_L_Finger11", "ValveBiped.Bip01_L_Finger12",
            "ValveBiped.Bip01_L_Finger0", "ValveBiped.Bip01_L_Finger01", "ValveBiped.Bip01_L_Finger02",

            "ValveBiped.Bip01_R_Hand",
            "ValveBiped.Bip01_R_Finger4", "ValveBiped.Bip01_R_Finger41", "ValveBiped.Bip01_R_Finger42",
            "ValveBiped.Bip01_R_Finger3", "ValveBiped.Bip01_R_Finger31", "ValveBiped.Bip01_R_Finger32",
            "ValveBiped.Bip01_R_Finger2", "ValveBiped.Bip01_R_Finger21", "ValveBiped.Bip01_R_Finger22",
            "ValveBiped.Bip01_R_Finger1", "ValveBiped.Bip01_R_Finger11", "ValveBiped.Bip01_R_Finger12",
            "ValveBiped.Bip01_R_Finger0", "ValveBiped.Bip01_R_Finger01", "ValveBiped.Bip01_R_Finger02"
        }

        local rag = ply:GetNWEntity("FakeRagdoll")
        local isLeftHandGrabbed = IsValid(rag) and rag:GetNW2Bool("LH_Grabbed", false) or false
        
        local disableLeftHand = (gestureData.lhand == true) or isLeftHandGrabbed
        local disableRightHand = (gestureData.rhand == true) or IsWeaponIgnoredForRightHand(swep)

        for _, boneName in ipairs(gesture_bones) do
            if disableLeftHand and string.find(boneName, "_L_") then continue end
            if disableRightHand and string.find(boneName, "_R_") then continue end

            local wm_bone = WorldModel:LookupBone(boneName)
            local ply_bone = ent:LookupBone(boneName)

            if wm_bone and ply_bone then
                local wmb_mat = WorldModel:GetBoneMatrix(wm_bone)
                local ply_mat = ent:GetBoneMatrix(ply_bone)

                if wmb_mat and ply_mat then
                    local gPos = wmb_mat:GetTranslation()
                    local gAng = wmb_mat:GetAngles()

                    gPos.x = math.Clamp(gPos.x, newPos.x - 38, newPos.x + 38)
                    gPos.y = math.Clamp(gPos.y, newPos.y - 38, newPos.y + 38)
                    gPos.z = math.Clamp(gPos.z, newPos.z - 38, newPos.z + 38)

                    local finalPos = LerpVector(weight, ply_mat:GetTranslation(), gPos)
                    local finalAng = LerpAngle(weight, ply_mat:GetAngles(), gAng)

                    ply_mat:SetTranslation(finalPos)
                    ply_mat:SetAngles(finalAng)

                    ent:SetBoneMatrix(ply_bone, ply_mat)
                    ent:SetBonePosition(ply_bone, finalPos, finalAng)
                end
            end
        end

        local eyeang = ply:EyeAngles()

        if not disableRightHand then
            local r_upperarm_idx = ent:LookupBone("ValveBiped.Bip01_R_UpperArm")
            local r_forearm_idx = ent:LookupBone("ValveBiped.Bip01_R_Forearm")
            local r_hand_idx = ent:LookupBone("ValveBiped.Bip01_R_Hand")

            if r_upperarm_idx and r_forearm_idx and r_hand_idx then
                local upper_mat = ent:GetBoneMatrix(r_upperarm_idx)
                local fore_mat = ent:GetBoneMatrix(r_forearm_idx)
                local hand_mat = ent:GetBoneMatrix(r_hand_idx)

                if upper_mat and fore_mat and hand_mat then
                    local u_len = ent:BoneLength(r_forearm_idx)
                    if not u_len or u_len == 0 then u_len = 12 end

                    local upper_pos, fore_pos, upper_ang, fore_ang = TPIK.Solve2PartIK(
                        upper_mat:GetTranslation(), hand_mat:GetTranslation(), u_len, u_len, -1.1, eyeang
                    )

                    upper_mat:SetAngles(upper_ang)
                    fore_mat:SetTranslation(upper_pos)
                    fore_mat:SetAngles(fore_ang)
                    hand_mat:SetTranslation(fore_pos)

                    TPIK.bone_apply_matrix(ent, r_upperarm_idx, upper_mat, r_forearm_idx)
                    TPIK.bone_apply_matrix(ent, r_forearm_idx, fore_mat, r_hand_idx)
                    TPIK.bone_apply_matrix(ent, r_hand_idx, hand_mat)
                end
            end
        end

        if not disableLeftHand then
            local l_upperarm_idx = ent:LookupBone("ValveBiped.Bip01_L_UpperArm")
            local l_forearm_idx = ent:LookupBone("ValveBiped.Bip01_L_Forearm")
            local l_hand_idx = ent:LookupBone("ValveBiped.Bip01_L_Hand")

            if l_upperarm_idx and l_forearm_idx and l_hand_idx then
                local upper_mat = ent:GetBoneMatrix(l_upperarm_idx)
                local fore_mat = ent:GetBoneMatrix(l_forearm_idx)
                local hand_mat = ent:GetBoneMatrix(l_hand_idx)

                if upper_mat and fore_mat and hand_mat then
                    local u_len = ent:BoneLength(l_forearm_idx)
                    if not u_len or u_len == 0 then u_len = 12 end

                    local upper_pos, fore_pos, upper_ang, fore_ang = TPIK.Solve2PartIK(
                        upper_mat:GetTranslation(), hand_mat:GetTranslation(), u_len, u_len, 1.2, eyeang
                    )

                    upper_mat:SetAngles(upper_ang)
                    fore_mat:SetTranslation(upper_pos)
                    fore_mat:SetAngles(fore_ang)
                    hand_mat:SetTranslation(fore_pos)

                    TPIK.bone_apply_matrix(ent, l_upperarm_idx, upper_mat, l_forearm_idx)
                    TPIK.bone_apply_matrix(ent, l_forearm_idx, fore_mat, l_hand_idx)
                    TPIK.bone_apply_matrix(ent, l_hand_idx, hand_mat)
                end
            end
        end
    end
end
