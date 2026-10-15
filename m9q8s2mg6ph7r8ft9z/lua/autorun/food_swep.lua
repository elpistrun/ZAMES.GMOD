--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/autorun/food_swep.lua <
    > Callstack:  <
]]

AddCSLuaFile()

FoodSwep = {}
FoodSwep.ANIMATION_EVENT_COMPLETE = 0
FoodSwep.ANIMATION_EVENT_HALF = 1
FoodSwep.ANIMATION_LINEAR = 0
FoodSwep.ANIMATION_EASE_IN = 1
FoodSwep.ANIMATION_EASE_OUT = 2
FoodSwep.ANIMATION_EASE_IN_EASE_OUT = 3
FoodSwep.ANIMATION_EASE_OUT_EASE_IN = 4
FoodSwep.ANIMATION_EASE_IN_EASE_IN = 5
FoodSwep.ANIMATION_EASE_OUT_EASE_OUT = 6
FoodSwep.ANIMATION_EASE_DRINK = 7

if SERVER then
	util.AddNetworkString("FoodSwep_PlayAnimation")
	util.AddNetworkString("FoodSwep_AnimationEvent")

	net.Receive("FoodSwep_AnimationEvent", function(len, player) 
		if not IsValid(player) then return end

		local id = net.ReadInt( 32 )
		local weapon = player:GetActiveWeapon()

		if not IsValid(weapon) or not weapon.IsFoodBase then return end

		weapon:OnAnimationEvent(id)
	end)
end

if CLIENT then
	net.Receive("FoodSwep_PlayAnimation", function() 
		local player = net.ReadEntity()

		if not IsValid(player) then return end

		local weapon = player:GetActiveWeapon()

		if not IsValid(weapon) or not weapon.IsFoodBase or weapon.AnimationPlaying then return end
		weapon:PlayAnimation()
	end)
end

FoodSwep.EasingFunctions = {}

FoodSwep.EasingFunctions[FoodSwep.ANIMATION_LINEAR] = function(animationTime)
    return animationTime
end

FoodSwep.EasingFunctions[FoodSwep.ANIMATION_EASE_IN] = function(animationTime)
    return animationTime * animationTime
end

FoodSwep.EasingFunctions[FoodSwep.ANIMATION_EASE_OUT] = function(animationTime)
    return animationTime * (2 - animationTime)
end

FoodSwep.EasingFunctions[FoodSwep.ANIMATION_EASE_IN_EASE_OUT] = function(animationTime)
    local frac = 0

    if animationTime > 0.5 then
        frac = (1 - animationTime) * 2
        frac = frac * frac
    else
        frac = (animationTime * 2)
        frac = frac * (2 - frac)
    end
    return frac
end

FoodSwep.EasingFunctions[FoodSwep.ANIMATION_EASE_DRINK] = function(animationTime)
    local idleFactor = 0.05
    local frac = 0

    if animationTime < 0.3 then
        frac = animationTime / 0.3 -- 0 to 1 real 0.3
        frac = frac * (2 - frac)
    else
        if animationTime < 0.8 then
            frac = 1 + (((animationTime - 0.3) / 0.5) * idleFactor) -- 0 to 1.5 real 0.7-0.8
        else
            frac = (1 + idleFactor) - (((animationTime - 0.8) / 0.2) * (1 + idleFactor))
            frac = frac * frac
        end
    end
    return frac
end

function FoodSwep:InterpolateBones(entity, fraction, startData, endData)
	if not IsValid(entity) then return end

	for k, v in pairs(endData) do
		local boneID = entity:LookupBone(k)

		if (boneID > -1) then
			if v.pos then
				if startData and startData[k] and startData[k].pos then
					entity:ManipulateBonePosition(boneID, LerpVector(fraction, startData[k].pos, v.pos))
				else
					entity:ManipulateBonePosition(boneID, LerpVector(fraction, Vector(0, 0, 0), v.pos))
				end
			end

			if v.angle then
				if startData and startData[k] and startData[k].angle then
					entity:ManipulateBoneAngles(boneID, LerpAngle(fraction, startData[k].angle, v.angle))
				else
					entity:ManipulateBoneAngles(boneID, LerpAngle(fraction, Angle(0, 0, 0), v.angle))
				end
			end
		end
	end
end

function FoodSwep:SetBones(entity, bonesData)

	if bonesData then
		for k, v in pairs(bonesData) do
			local boneID = entity:LookupBone(k)
			if not boneID then return end

			if (boneID > -1) then
				if v.pos then
					entity:ManipulateBonePosition(boneID, v.pos)
				end

				if v.angle then
					entity:ManipulateBoneAngles(boneID, v.angle)
				end

				if v.scale then
					entity:ManipulateBoneScale(boneID, v.scale)
				end
			end
		end
	end
end

function FoodSwep:ResetBones(entity)
	if not IsValid(entity) then return end
	if not entity:GetBoneCount() then return end

	for i = 0, entity:GetBoneCount() do
		entity:ManipulateBoneScale(i, Vector(1, 1, 1))
		entity:ManipulateBoneAngles(i, Angle(0, 0, 0))
		entity:ManipulateBonePosition(i, Vector(0, 0, 0))
	end
end

function FoodSwep:AddHealth(player, value)
    if (player:Health() < 100) then
        player:SetHealth(math.Clamp(player:Health() + value, 0, 100))
    end
end

hook.Add("UpdateAnimation", "FoodSwep_UpdateAnimation", function(player, vel, maxSeqGroundSpeed)
	if not IsValid(player) then return end

	local weapon = player:GetActiveWeapon()

	if not IsValid(weapon) then return end

	if IsValid(player.ActiveFoodWepoon) then
		if weapon:GetClass() ~= player.ActiveFoodWepoon:GetClass() then
			if IsValid(player.ActiveFoodWepoon) then
				if CLIENT then
					player.ActiveFoodWepoon:ResetAnimaton()
					player.ActiveFoodWepoon:ResetPose()
				end
			end
			player.ActiveFoodWepoon = nil
		else
			if weapon.AnimationPlaying then
				weapon:UpdateAnimation()
			end
		end
	else
		if weapon.IsFoodBase then
			if CLIENT then
				weapon:SetupPose()
			end
			player.ActiveFoodWepoon = weapon
		end
	end
end)
