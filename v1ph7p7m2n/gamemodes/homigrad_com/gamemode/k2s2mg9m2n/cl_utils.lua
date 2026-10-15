--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/cl_utils.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

hook.Add("Think", "RagdollFaceExpressions", function()
    for _, ply in player.Iterator() do
        if not IsValid(ply) then continue end

        local rag = ply:GetNWEntity("FakeRagdoll")
        
        local ent = IsValid(rag) and rag or ply

        local blinkFlex = ent:GetFlexIDByName("blink")
        if blinkFlex then
            local isOtrub = ply:GetNWBool("Otrub")
            ent:SetFlexWeight(blinkFlex, isOtrub and 1 or 0)
        end

        local flexes = {
            ent:GetFlexIDByName("jaw_drop"),
            ent:GetFlexIDByName("left_part"),
            ent:GetFlexIDByName("right_part"),
            ent:GetFlexIDByName("left_mouth_drop"),
            ent:GetFlexIDByName("right_mouth_drop"),
            ent:GetFlexIDByName("lower_lip")
        }

        local weight = (ply:IsSpeaking() and math.Clamp(ply:VoiceVolume() * 40, 0, 2)) or 0

        for i = 1, #flexes do
            local flexID = flexes[i]
            if flexID then
                ent:SetFlexWeight(flexID, weight)
            end
        end
    end
end)
