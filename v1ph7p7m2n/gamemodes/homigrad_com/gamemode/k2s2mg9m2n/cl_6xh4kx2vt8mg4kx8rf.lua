--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/cl_6xh4kx2vt8mg4kx8rf.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

local MENU_MAX_SIZE = 490    -- Итоговый диаметр окружности
local CENTER_DEADZONE = 50   -- Радиус центра круга (мертвая зона)
local ANIM_TIME = 0.1        -- Время анимации появления
local FADE_TIME = 0.1        -- Время для анимации прозрачности секторов

local BUTTON_SIZE = 80          
local BUTTON_HOVER_SCALE = 1.3  
local BUTTON_ANIM_SPEED = 15    

local RadialPanel = nil
local fontBold = "PT.2"

local blacklist_weps = {
	["weapon_hands"] = true,
	["wep_jack_gmod_hands"] = true,
	["weapon_physgun"] = true,
	["gmod_tool"] = true,
	["weapon_physcannon"] = true,
}


if not IsValid(LootInventory_DrawModel) then
    LootInventory_DrawModel = ClientsideModel("models/error.mdl", RENDER_GROUP_OPAQUE_ENTITY)
    LootInventory_DrawModel:SetNoDraw(true)
end

-- Возвращает валидный путь к модели оружия. У части оружий (EZ melee, кастомные базы)
-- WorldModelReal/WorldModel бывают nil или пустой строкой, поэтому нужен набор запасных вариантов
local function GetWeaponModel(wepClass, wep)
    local mdl = nil

    if IsValid(wep) then
        mdl = wep.WorldModelReal or wep.WorldModel or wep:GetModel()
    end

    if not mdl or mdl == "" then
        local wepTbl = wepClass and (weapons.Get(wepClass) or weapons.GetStored(wepClass))
        mdl = wepTbl and (wepTbl.WorldModel or wepTbl.Model or wepTbl.ViewModel) or nil
    end

    if type(mdl) ~= "string" or mdl == "" then
        mdl = "models/error.mdl"
    end

    return mdl
end

-- Выброс оружия. Выбрасывать можно только с сервера: Remove() на клиенте не убирает
-- оружие у игрока на сервере ("Trying to remove server entity ... on client!")
-- У JMod-оружия есть свой concommand, остальное обрабатывает sv_radial_drop.lua
local function DropActiveWeapon()
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()

    if not IsValid(wep) then return end

    local now = CurTime()
    if ply.RadialNextDropTime and ply.RadialNextDropTime > now then return end
    ply.RadialNextDropTime = now + 1

    if wep.EZdroppable then
        RunConsoleCommand("jmod_ez_dropweapon")
    else
        RunConsoleCommand("zames_dropweapon")
    end
end

local function CloseRadialMenu()
    if not IsValid(RadialPanel) or RadialPanel.IsClosing then return end
    RadialPanel.IsClosing = true
end

local GetMainActions

local function GetArmorActions()
    local actions = {}
    local ply = LocalPlayer()
    
    if ply.EZarmor and ply.EZarmor.items then
        for id, itemData in pairs(ply.EZarmor.items) do
            local armorInfo = JMod.ArmorTable[itemData.name]
            
            table.insert(actions, {
                name = itemData.name,
                icon = armorInfo and ("materials/entities/" .. armorInfo.ent .. ".png") or "icon16/shield.png",
                action = function(panel)
                    net.Start("JMod_Inventory")
                    net.WriteInt(JMod.NETWORK_INDEX.ARMOR_INVENTORY.DROP, 8)
                    net.WriteString(id)
                    net.SendToServer()
                    
                    ply.EZarmor.items[id] = nil
                    
                    local armorLeft = false
                    for k, v in pairs(ply.EZarmor.items) do
                        armorLeft = true
                        break
                    end
                    
                    if armorLeft then
                        panel:LoadActions(GetArmorActions())
                    else
                        panel:LoadActions(GetArmorActions())
                    end
                end
            })
        end
    end

    table.insert(actions, {
        name = "Назад",
        icon = "zames/back.png",
        action = function(panel)
            panel.Sticky = false
            panel:LoadActions(GetMainActions())
        end
    })

    return actions
end

GetMainActions = function()
    local actions = {}
    local ply = LocalPlayer()
    local activeWep = ply:GetActiveWeapon()

    if IsValid(activeWep) and not blacklist_weps[activeWep:GetClass()] then
        table.insert(actions, {
            name = "Выкинуть: " .. (activeWep:GetPrintName() or "Оружие"),
            isWeapon = true,
            wepClass = activeWep:GetClass(),
            wepModel = GetWeaponModel(activeWep:GetClass(), activeWep),
            action = function(panel)
                DropActiveWeapon()
                CloseRadialMenu()
            end
        })
    end

    table.insert(actions, {
        name = "Броня",
        icon = "materials/entities/ent_jack_gmod_ezarmor_mhead.png",
        action = function(panel)
            panel.Sticky = true
            panel:LoadActions(GetArmorActions())
        end
    })

    return actions
end

local function drawRingArc(cx, cy, innerRadius, outerRadius, startAngle, endAngle, color)
    surface.SetDrawColor(color)
    draw.NoTexture()
    
    local gradientSteps = 24 
    local startAngRad = math.rad(startAngle)
    local endAngRad = math.rad(endAngle)
    
    for s = 0, gradientSteps - 1 do
        local a1 = startAngRad + (endAngRad - startAngRad) / gradientSteps * s
        local a2 = startAngRad + (endAngRad - startAngRad) / gradientSteps * (s + 1)
        
        local poly = {
            { x = cx + math.cos(a1) * innerRadius, y = cy + math.sin(a1) * innerRadius },
            { x = cx + math.cos(a1) * outerRadius, y = cy + math.sin(a1) * outerRadius },
            { x = cx + math.cos(a2) * outerRadius, y = cy + math.sin(a2) * outerRadius },
            { x = cx + math.cos(a2) * innerRadius, y = cy + math.sin(a2) * innerRadius },
        }
        surface.DrawPoly(poly)
    end
end

local function OpenRadialMenu()
    if not LocalPlayer():Alive() then return end

    if IsValid(RadialPanel) then 
        RadialPanel.IsClosing = false 
        return 
    end

    RadialPanel = vgui.Create("DPanel")
    RadialPanel:SetSize(MENU_MAX_SIZE, MENU_MAX_SIZE)
    RadialPanel:Center()
    RadialPanel:MakePopup()
    RadialPanel:SetKeyboardInputEnabled(false)
    
    RadialPanel.AnimProgress = 0
    RadialPanel.LastHovered = nil
    RadialPanel.Sticky = false
    
    RadialPanel.LoadActions = function(self, actionTable)
        self.AnimProgress = 0 
        self.CurrentActions = actionTable
        self.SegmentAngle = 360 / #actionTable
        
        if self.Buttons then
            for _, btn in ipairs(self.Buttons) do
                btn:Remove()
            end
        end
        
        self.Buttons = {}
        self.LastHovered = nil

        for i, item in ipairs(actionTable) do
            local btn = vgui.Create("DButton", self)
            btn:SetText("") 
            btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
            btn:SetPaintBackground(false) 
            btn:SetAlpha(0) 
            btn:SetMouseInputEnabled(false)
            
            btn.ActionData = item 
            btn.CurrentScale = 1  
            btn.TargetScale = 1   
            btn.SectorOpacity = 0
            btn.IsHoveredBySector = false 

            if item.icon then
                btn.IconMat = Material(item.icon, "smooth")
            end

            btn.DoClick = function(self_btn)
                self_btn.ActionData.action(self)
            end

            btn.Paint = function(self_btn, w, h)
                DisableClipping(true)
                local actionInfo = self_btn.ActionData
                local baseIconSize = w * 0.8
                local iconSize = baseIconSize
                
                if self_btn.IsHoveredBySector then
                    local pulse = (math.sin(CurTime() * 10) + 1) / 2 
                    iconSize = baseIconSize + (pulse * 15)
                end

                if actionInfo.isWeapon then
                    if IsValid(LootInventory_DrawModel) then
                        local wepTbl = weapons.Get(actionInfo.wepClass)
                        local mdl = actionInfo.wepModel or GetWeaponModel(actionInfo.wepClass)
                        local iconPos = (wepTbl and wepTbl.IconPos) or Vector(15, -5, -3)
                        local iconAng = (wepTbl and wepTbl.IconAng) or Angle(0, 90, 0)

                        if self_btn.CurrentModel ~= mdl then
                            LootInventory_DrawModel:SetModel(mdl)
                            self_btn.CurrentModel = mdl
                        end
                        
                        local padding = 120
                        local screenX, screenY = self_btn:LocalToScreen(-padding / 2, -padding / 2)
                        local vec = Vector(0,0,0)
                        local ang = Angle(0,0,0)

                        cam.Start3D(vec, ang, 20, screenX, screenY, w + padding, h + padding, 5, 4096)
                            cam.IgnoreZ(true)
                            render.SuppressEngineLighting(true)
                            
                            render.SetLightingOrigin(vec)
                            render.ResetModelLighting(1, 1, 1)
                            render.SetColorModulation(1, 1, 1)
                            render.SetBlend(self_btn:GetAlpha() / 255) 
                            render.SetModelLighting(4, 1, 1, 1)
                            
                            LootInventory_DrawModel:SetRenderOrigin(iconPos)
                            LootInventory_DrawModel:SetRenderAngles(iconAng)
                            LootInventory_DrawModel:DrawModel()
                            
                            LootInventory_DrawModel:SetRenderOrigin()
                            LootInventory_DrawModel:SetRenderAngles()
                            
                            render.SetColorModulation(1, 1, 1)
                            render.SetBlend(1)
                            render.SuppressEngineLighting(false)
                            cam.IgnoreZ(false)
                        cam.End3D()
                    end
                elseif self_btn.IconMat and not self_btn.IconMat:IsError() then
                    surface.SetMaterial(self_btn.IconMat)
                    surface.SetDrawColor(255, 255, 255, self_btn:GetAlpha())
                    surface.DrawTexturedRect(w / 2 - iconSize / 2, h / 2 - iconSize / 2, iconSize, iconSize)
                end
                
                DisableClipping(false)
            end

            table.insert(self.Buttons, btn)
        end
    end

    -- Загружаем динамическое меню
    RadialPanel:LoadActions(GetMainActions())

    RadialPanel.Think = function(self)
        local animSpeed = FrameTime() * (1 / ANIM_TIME)
        if self.IsClosing then
            self.AnimProgress = math.Approach(self.AnimProgress, 0, animSpeed)
            if self.AnimProgress == 0 then
                self:Remove()
                return
            end
        else
            self.AnimProgress = math.Approach(self.AnimProgress, 1, animSpeed)
        end

        local cx, cy = self:GetWide() / 2, self:GetTall() / 2
        local mx, my = self:CursorPos()
        local dist = math.Distance(mx, my, cx, cy)
        local currentRadius = (self:GetWide() / 2) * self.AnimProgress
        
        local hoveredIndex = nil
        if dist > CENTER_DEADZONE and dist <= currentRadius and not self.IsClosing then
            local angle = math.deg(math.atan2(my - cy, mx - cx))
            if angle < 0 then angle = angle + 360 end
            
            local adjustedAngle = (angle + 90) % 360
            local idxOffset = (adjustedAngle + self.SegmentAngle / 2) % 360
            hoveredIndex = math.floor(idxOffset / self.SegmentAngle) + 1
        end

        if hoveredIndex ~= self.LastHovered then
            if hoveredIndex ~= nil then
                surface.PlaySound("zames/vgui/click1.wav") 
            end
            self.LastHovered = hoveredIndex
        end

        local currentKeyQ = input.IsKeyDown(KEY_Q)
        local currentMouse1 = input.IsMouseDown(MOUSE_LEFT)

        if self.LastKeyQ == nil then self.LastKeyQ = currentKeyQ end
        if self.LastMouse1 == nil then self.LastMouse1 = currentMouse1 end

        if currentMouse1 and not self.LastMouse1 then
            if hoveredIndex and not self.IsClosing then
                self.Buttons[hoveredIndex]:DoClick()
            else
                CloseRadialMenu()
            end
        end

        if not currentKeyQ and self.LastKeyQ then
            if hoveredIndex and not self.IsClosing then
                self.Buttons[hoveredIndex]:DoClick()
            else
                CloseRadialMenu()
            end
        end

        if not currentKeyQ and not self.LastKeyQ and not self.Sticky then
        end

        self.LastKeyQ = currentKeyQ
        self.LastMouse1 = currentMouse1

        local radiusToButton = (MENU_MAX_SIZE / 2) * 0.7

        for i, btn in ipairs(self.Buttons) do
            btn:SetAlpha(255 * self.AnimProgress)
            btn.IsHoveredBySector = (hoveredIndex == i)

            if btn.IsHoveredBySector and not self.IsClosing then
                btn.TargetScale = BUTTON_HOVER_SCALE 
                btn.SectorOpacity = math.Approach(btn.SectorOpacity, 100, FrameTime() * 1/FADE_TIME * 100) 
            else
                btn.TargetScale = 1 
                btn.SectorOpacity = math.Approach(btn.SectorOpacity, 0, FrameTime() * 1/FADE_TIME * 100) 
            end

            btn.CurrentScale = math.Approach(btn.CurrentScale, btn.TargetScale, FrameTime() * BUTTON_ANIM_SPEED)

            local newSize = BUTTON_SIZE * btn.CurrentScale * math.max(0.01, self.AnimProgress)
            local currentRadiusToButton = radiusToButton * self.AnimProgress
            local angle = math.rad((i - 1) * self.SegmentAngle - 90)
            
            local currentX = cx + math.cos(angle) * currentRadiusToButton
            local currentY = cy + math.sin(angle) * currentRadiusToButton

            btn:SetSize(newSize, newSize)
            btn:SetPos(currentX - newSize / 2, currentY - newSize / 2)
        end
    end

    RadialPanel.Paint = function(self, w, h)
        local cx, cy = w / 2, h / 2
        local radiusToButton = (MENU_MAX_SIZE / 2) * 0.7
        local innerRadius = (radiusToButton - 35) * self.AnimProgress
        local outerRadius = (radiusToButton + 35) * self.AnimProgress

        DisableClipping(true)

        local centerText = "Cancel"
        local centerTextColor = Color(255, 255, 255, 255 * self.AnimProgress)

        if innerRadius > 10 then
            for i, btn in ipairs(self.Buttons) do
                local startAngle = (i - 1) * self.SegmentAngle - 90 - (self.SegmentAngle / 2)
                local endAngle = startAngle + self.SegmentAngle
                
                local drawInner = innerRadius
                local drawOuter = outerRadius
                local highlightAlpha = 50 * self.AnimProgress 

                if btn.TargetScale > 1 then
                    local pulse = (math.sin(CurTime() * 10) + 1) / 2 
                    drawOuter = outerRadius + (pulse * 8)
                    drawInner = innerRadius - (pulse * 8)
                    highlightAlpha = (btn.SectorOpacity + 50) * self.AnimProgress
                    
                    centerText = btn.ActionData.name
                    centerTextColor = Color(255, 255, 255, 255 * self.AnimProgress)
                elseif btn.SectorOpacity > 0 then
                    highlightAlpha = math.max(highlightAlpha, btn.SectorOpacity * self.AnimProgress)
                end

                drawRingArc(cx, cy, drawInner, drawOuter, startAngle, endAngle, Color(255, 255, 255, highlightAlpha))
            end
        end

        draw.SimpleTextOutlined(centerText, fontBold, cx, cy, centerTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 150 * self.AnimProgress))
        DisableClipping(false)
    end
end

hook.Add("Think", "RadialMenu_InputCheck", function()
    if input.IsKeyDown(KEY_Q) then
        OpenRadialMenu()
    end
end)

hook.Add("PlayerBindPress", "RadialMenu_BlockQ", function(ply, bind, pressed)
    if string.find(bind, "+menu") and not string.find(bind, "+menu_context") then
        return true
    end
end)
