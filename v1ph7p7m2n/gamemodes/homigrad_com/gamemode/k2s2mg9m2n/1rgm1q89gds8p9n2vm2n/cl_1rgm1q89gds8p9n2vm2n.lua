--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/1rgm1q89gds8p9n2vm2n/cl_1rgm1q89gds8p9n2vm2n.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

if IsValid(SpectatorBarPanel) then 
    SpectatorBarPanel:Remove() 
    SpectatorBarPanel = nil
end

local CurrentSpectateTarget = nil

hook.Add("Think", "CustomSpectatorHUD_Manager", function()
    local ply = LocalPlayer()
    
    if ply:Alive() or ply:GetObserverMode() == OBS_MODE_NONE or ply:GetObserverMode() == OBS_MODE_ROAMING then 
        if IsValid(SpectatorBarPanel) then 
            SpectatorBarPanel:Remove() 
            SpectatorBarPanel = nil
        end
        CurrentSpectateTarget = nil
        return 
    end

    local mode = ply:GetObserverMode()
    local target = ply:GetObserverTarget()

    if (mode == OBS_MODE_IN_EYE or mode == OBS_MODE_CHASE) and IsValid(target) and target:IsPlayer() then
        if CurrentSpectateTarget ~= target then
            if IsValid(SpectatorBarPanel) then SpectatorBarPanel:Remove() end
            
            SpectatorBarPanel = CreatePlayerBar(vgui.GetWorldPanel(), target, nil)
            
            local barWidth = ScrW() * 0.57
            SpectatorBarPanel:SetSize(barWidth, 80)
            SpectatorBarPanel:SetPos((ScrW() - barWidth) / 2, ScrH() - 100)
            
            CurrentSpectateTarget = target
        end
    else
        CurrentSpectateTarget = nil
    end
end)

-- Отрисовка

local flashlight = flashlight or nil
local flashlightOn = flashlightOn or false
local gradient_d = Material("vgui/gradient-d")

local function DrawWHEnt(ent, pos)
    if not ent:IsPlayer() then return end

    local pos2 = pos:ToScreen()
    local x, y = pos2.x, pos2.y

    local teamColor = ent.GetPlayerColor and ent:GetPlayerColor():ToColor() or ent:GetColor()
    local distance = EyePos():Distance(pos)

    local factor = 1 - math.Clamp(distance / 1024, 0, 1)
    local size = math.max(10, 32 * factor)
    local alpha = math.max(255 * factor, 80)

    local text = ent:Nick() or "Player"
    if ent:GetNW2Bool("IsAnonim", false) then
        text = ent:GetNW2String("AnonimName", "Неизвестный")
    end
    
    surface.SetFont("PT.3")
    local tw, th = surface.GetTextSize(text)
    
    surface.SetDrawColor(teamColor.r, teamColor.g, teamColor.b, alpha * 0.5)
    surface.SetMaterial(gradient_d)
    surface.DrawTexturedRect(x - size / 2 - tw / 2, y - th / 2, size + tw, th)
    
    surface.SetTextColor(255, 255, 255, alpha)
    surface.SetTextPos(x - tw / 2, y - th / 2)
    surface.DrawText(text)
    
    local hp = ent:Health()
    local hr, hg, hb
    
    if hp > 70 then
        hr, hg, hb = 0, 255, 0       -- Зеленый
    elseif hp >= 20 then
        hr, hg, hb = 255, 165, 0     -- Оранжевый
    else
        hr, hg, hb = 255, 0, 0       -- Красный
    end

    local hpText = tostring(hp) .. " HP"
    local htw, hth = surface.GetTextSize(hpText)
    
    surface.SetTextColor(hr, hg, hb, alpha)
    surface.SetTextPos(x - htw / 2, y + th / 1.5)
    surface.DrawText(hpText)
end

hook.Add("HUDPaint", "spectate", function()
    local lply = LocalPlayer()

    if lply:Alive() and lply:GetMoveType() ~= MOVETYPE_NOCLIP then
        if IsValid(flashlight) then
            flashlight:Remove()
            flashlight = nil
        end
        if lply:Team() ~= 1002 then
            return
        end
    end
    
    if lply:Team() != 1002 and IsValid(lply:GetVehicle()) then return end

    local key = lply:KeyDown(IN_WALK)
    if keyOld ~= key and key then
        SpectateHideNick = not SpectateHideNick
    --    chat.AddText("Ники игроков: " .. tostring(not SpectateHideNick))
    end
    keyOld = key
    local key = input.IsButtonDown(KEY_F)
    if not lply:Alive() and keyOld2 ~= key and key then
        flashlightOn = not flashlightOn
        if flashlightOn then
            if not IsValid(flashlight) then
                flashlight = ProjectedTexture()
                flashlight:SetTexture("effects/flashlight001")
                flashlight:SetFarZ(900)
                flashlight:SetFOV(150)
                flashlight:SetBrightness(0.35)
                flashlight:SetEnableShadows(false)
            end
        else
            if IsValid(flashlight) then
                flashlight:Remove()
                flashlight = nil
            end
        end
    end
    keyOld2 = key
    if IsValid(flashlight) then
        flashlight:SetPos(EyePos())
        flashlight:SetAngles(EyeAngles())
        flashlight:Update()
    end

    if not SpectateHideNick then
        for _, v in player.Iterator() do
            if not v:Alive() or v == lply or v == spect then continue end
            local ent = IsValid(v:GetNWEntity("FakeRagdoll")) and v:GetNWEntity("FakeRagdoll")
            ent = IsValid(ent) and ent or v
            DrawWHEnt(v, ent:GetPos())
        end
    end
end)

hook.Add("HUDPaint","Spectator_Locate",function()
	for _, ply in player.Iterator() do
		if !ply:Alive() then
			continue 
		end
		if ply:Team() != 1002 then
			continue 
		end

		if ply == LocalPlayer() then
			continue 
		end
        
        if ply:GetMoveType() == MOVETYPE_NOCLIP then return end
        
		local dist = ply:GetPos():Distance((LocalPlayer():GetPos()))

		local pos = (ply:GetPos() + ply:OBBCenter()):ToScreen()

		if dist < 600 then

			draw.SimpleText("Спектатор","PT.2",pos.x,pos.y,Color(255,255,255,255 * (100 / dist)),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end
end)


hook.Add("HUDPaint", "DebugDrawPlayerHP", function()
    local isDebug = GetConVar("developer"):GetBool()
    local localPly = LocalPlayer()
    
    if not isDebug or not localPly:IsSuperAdmin() then return end
    
    for _, ply in player.Iterator() do
        if ply ~= localPly and ply:Alive() then
            local pos = ply:GetPos() + Vector(0, 0, 80)
            local screenPos = pos:ToScreen()
            
            if screenPos.visible then
                local hp = ply:Health()
                draw.SimpleText("HP: " .. hp, "PT.2", screenPos.x, screenPos.y, Color(255, 50, 50, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end
end)


local www = Color(255,255,255,150)

hook.Add("HUDPaint", "DrawSpectatorF2Text", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or ply:Alive() then return end
    if ply:Team() ~= 1002 then return end

    local mode = ply:GetObserverMode()
    if mode == OBS_MODE_NONE then return end

    local text = "Вы в режиме наблюдателя (F2 Для смены команды)"
    draw.SimpleText(text, "PT.2", ScrW() / 2, ScrH() - 8, www, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end)
