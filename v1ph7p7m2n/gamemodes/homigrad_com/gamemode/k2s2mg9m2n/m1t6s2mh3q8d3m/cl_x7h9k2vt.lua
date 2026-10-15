--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/m1t6s2mh3q8d3m/cl_x7h9k2vt.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

hook.Add("HUDPaint", "DrawTargetID123", function()
    -- Данные пишет наш фейк (fake/sv_tier_0.lua): PlayerName (NWString) и владелец в NW "ply"
    local ply = LocalPlayer()
    local tr = ply:GetEyeTrace()
    local target = tr.Entity

    if IsValid(target) then
        local isPlayer = target:IsPlayer() and target:Alive()
        local isRagdoll = target:GetClass() == "prop_ragdoll" and target:GetNWString("PlayerName") ~= ""

        if (isPlayer or isRagdoll) and ply:GetShootPos():Distance(target:GetPos()) <= 150 then

            if isPlayer and target == ply then
                return
            end
            
            if isRagdoll then
                local owner = target:GetNWEntity("ply")
                if IsValid(owner) and owner == ply then
                    return
                end
            end
            
            local bone = target:LookupBone("ValveBiped.Bip01_Spine2")
            local chestPos
            
            if bone then
                local matrix = target:GetBoneMatrix(bone)
                if matrix then
                    chestPos = matrix:GetTranslation()
                end
            end
            
            if not chestPos then
                chestPos = target:LocalToWorld(target:OBBCenter())
            end

            local screenData = chestPos:ToScreen()

            if screenData.visible then
                local pColor
                local nickName

                if isPlayer then
                    if target:GetNW2Bool("HMCD_Clone", false) then
                        nickName = target:GetNW2String("CloneNick", target:Nick())
                        pColor = target:GetPlayerColor() or Vector(1, 1, 1)
                    elseif target:GetNW2Bool("IsAnonim", false) then
                        nickName = target:GetNW2String("AnonimName", "Неизвестный")
                        pColor = target:GetPlayerColor() or Vector(1, 1, 1)
                    else
                        nickName = target:Nick()
                        pColor = target:GetPlayerColor() or Vector(1, 1, 1)
                    end
                else
                    local owner = target:GetNWEntity("ply")
                    if IsValid(owner) and owner:IsPlayer() then
                        if owner:GetNW2Bool("HMCD_Clone", false) then
                            nickName = owner:GetNW2String("CloneNick", target:GetNWString("PlayerName"))
                            pColor = target:GetPlayerColor() or Vector(1, 1, 1)
                        elseif owner:GetNW2Bool("IsAnonim", false) then
                            nickName = owner:GetNW2String("AnonimName", "Неизвестный")
                            pColor = target:GetPlayerColor() or Vector(1, 1, 1)
                        else
                            nickName = target:GetNWString("PlayerName")
                            pColor = owner:GetPlayerColor() or Vector(1, 1, 1)
                        end
                    else
                        nickName = target:GetNWString("PlayerName")
                        pColor = target:GetNWVector("PlayerColor") or Vector(1, 1, 1)
                    end
                end

                local rawColor = Color(pColor.x * 255, pColor.y * 255, pColor.z * 255)
                local h, s, v = ColorToHSV(rawColor)
                
                v = math.max(v, 0.4) 
                s = math.min(s, 1)
                
                local textColor = HSVToColor(h, s, v)

                draw.SimpleTextOutlined(nickName, "PT.2", screenData.x, screenData.y, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
            end
        end
    end
end)
