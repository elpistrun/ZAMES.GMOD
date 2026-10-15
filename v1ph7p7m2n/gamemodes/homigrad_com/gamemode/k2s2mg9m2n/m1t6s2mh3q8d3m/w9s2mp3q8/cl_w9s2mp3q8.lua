--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/m1t6s2mh3q8d3m/w9s2mp3q8/cl_w9s2mp3q8.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

-- w9s2mp3q8

hook.Add("OnEntityCreated", "pfeu182u89u", function(ent)
    if ent:GetClass() == "prop_ragdoll" then
        ent.GetPlayerColor = function(self)
            return self:GetNWVector("PlayerColor", Vector(0, 0, 0))
        end
    end
end)

local mark_hands = CreateClientConVar("zs_fakehands", "1", true, false, "Марки фейка")

local matHandOpen = mh("zames/hand.png")
local matHandGrab = mh("zames/grab_hand.png")

local ICON_SIZE = 64

local function DrawHandMarker(rag, boneName, isGrabbed)
    local boneId = rag:LookupBone(boneName)
    if not boneId then return end

    local boneMat = rag:GetBoneMatrix(boneId)
    local worldPos = boneMat and boneMat:GetTranslation() or rag:GetBonePosition(boneId)
    if not worldPos then return end

    local screenData = worldPos:ToScreen()
    if not screenData.visible then return end

    local x, y = screenData.x, screenData.y
    local halfSize = ICON_SIZE * 0.5

    surface.SetDrawColor(255, 255, 255, 220)
    surface.SetMaterial(isGrabbed and matHandGrab or matHandOpen)
    surface.DrawTexturedRect(x - halfSize, y - halfSize, ICON_SIZE, ICON_SIZE)
end

hook.Add("HUDPaint", "DrawRagdollGrabMarkers", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    local rag = ply:GetNWEntity("FakeRagdoll")
    if not IsValid(rag) then return end

    if mark_hands:GetBool() then

        local leftGrabbed  = rag:GetNW2Bool("LH_Grabbed", false)
        local rightGrabbed = rag:GetNW2Bool("RH_Grabbed", false)

        DrawHandMarker(rag, "ValveBiped.Bip01_L_Hand", leftGrabbed)
        DrawHandMarker(rag, "ValveBiped.Bip01_R_Hand", rightGrabbed)

    end
end)
