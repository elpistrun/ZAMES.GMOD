local math_hand1 = Material("icon32/hand_point_180.png")
local math_hand2 = Material("icon32/hand_point_090.png")

local Clamp = math.Clamp

local casual_nigger = (ConVarExists("hg_casual") and GetConVar("hg_casual") or CreateClientConVar("hg_casual","0",true,false,"казуал плееры идут нахуй!",0,1))

hook.Add("HUDPaint","Fake",function()
    local ply = LocalPlayer()
    if not ply.Fake then return end
    if !casual_nigger:GetBool() then 
        return
    end

    surface.SetDrawColor(255,255,255,255)

    local rag = ply.FakeRagdoll
    if not IsValid(rag) then return end
    
    local w,h = ScrW(),ScrH()

    if ply:GetNWBool("LeftArm") then
        local hand = rag:GetBonePosition(rag:LookupBone("ValveBiped.Bip01_L_Hand"))
        local pos = hand:ToScreen()
        pos.x = Clamp(pos.x,w / 2 - w / 4,w / 2 + w / 4)
        pos.y = Clamp(pos.y,h / 2 - h / 4,h / 2 + h / 4)

        surface.SetMaterial(math_hand2)
        surface.DrawTexturedRectRotated(pos.x,pos.y,64,64,-90 + 25)
    end

    if ply:GetNWBool("RightArm") then
        local hand = rag:GetBonePosition(rag:LookupBone("ValveBiped.Bip01_R_Hand"))
        local pos = hand:ToScreen()
        pos.x = Clamp(pos.x,w / 2 - w / 4,w / 2 + w / 4)
        pos.y = Clamp(pos.y,h / 2 - h / 4,h / 2 + h / 4)

        surface.SetMaterial(math_hand1)
        surface.DrawTexturedRectRotated(pos.x,pos.y,-64,-64,180 - 25)
    end

    local wep = ply:GetActiveWeapon()

    local pos = EyePos() + ply:EyeAngles():Forward() * 8000
    pos = pos:ToScreen()

    pos.x = Clamp(pos.x,w / 2 - w / 3,w / 2 + w / 3)
    pos.y = Clamp(pos.y,h / 2 - h / 3,h / 2 + h / 3)
    
    local dis = math.Distance(pos.x,pos.y,w / 2,h / 2) / (h / 2)

    local a = 25 + dis * 255

    local size = math.max(dis * 32,6)

    if IsValid(wep) and wep:GetClass() != "weapon_hands" then a = a * 0.35 end
end)