--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/1rg9gd2wb6xh5xr8fw2wb4kx6xh2vt_9vn4kx6ql5xr1rg/1rgx7h7m1/cl_l55dcx3q8r8fs82wbp7w8q_1rgx7h7m1.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

net.Receive("SyncInventory", function(len)
    local invTable = net.ReadTable()
    
    if IsValid(LocalPlayer()) then
        LocalPlayer().Inventory = invTable
    else
        hook.Add("InitPostEntity", "SetDelayedInventory", function()
            LocalPlayer().Inventory = invTable
        end)
    end
end)

local matCFC = mh("zames/c_fc.png")
local matGFC = mh("zames/g_fc.png")

local flyAnims = {}
local displayCFC = -1
local displayGFC = -1
local nextTickCFC, nextTickGFC = 0, 0
local balanceSlideOffset = 500 
local balanceActiveUntil = 0

net.Receive("CurrencyAddedAnim", function()
    local curType = net.ReadString()
    local amount = net.ReadInt(32)

    surface.PlaySound("zames/vgui/coin.wav")

    table.insert(flyAnims, {
        type = curType,
        amount = amount,
        startTime = SysTime(),
        done = false
    })
end)

local function FormatMoney(n)
    if not n then return "0" end
    local left, num, right = string.match(tostring(n), '^([^%d]*%d)(%d*)(.-)$')
    return left .. (num:reverse():gsub('(%d%d%d)', '%1.'):reverse()) .. right
end

local function DrawDynamicBalance(rightX, y, offsetX)
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local valCFC = FormatMoney(displayCFC)
    local valGFC = FormatMoney(displayGFC)

    local iconSize = 32
    local padding = 12
    local spacing = 5

    surface.SetFont("PT.2")
    
    local wCFC, hText = surface.GetTextSize(valCFC)
    local wGFC, _ = surface.GetTextSize(valGFC)

    local totalWidth = padding + iconSize + spacing + wCFC + (spacing * 2) + iconSize + spacing + wGFC + padding
    local totalHeight = math.max(iconSize, hText) + (padding * 1.5)

    local startX = rightX - totalWidth + (offsetX or 0)

    draw.RoundedBox(0, startX, y, totalWidth, totalHeight, Color(75, 75, 75, 50))

    surface.SetDrawColor(243, 243, 243, 20)
    surface.DrawLine(startX, y, startX + totalWidth, y)
    surface.DrawLine(startX, y, startX, y + totalHeight)
    
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawLine(startX, y + totalHeight - 1, startX + totalWidth, y + totalHeight - 1)
    surface.DrawLine(startX + totalWidth - 1, y, startX + totalWidth - 1, y + totalHeight)  

    local currentX = startX + padding
    local centerY = y + (totalHeight / 2)

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(matCFC)
    surface.DrawTexturedRect(currentX, centerY - (iconSize / 2), iconSize, iconSize)
    currentX = currentX + iconSize + spacing

    draw.SimpleText(valCFC, "PT.2", currentX, centerY, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    currentX = currentX + wCFC + (spacing * 2)

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(matGFC)
    surface.DrawTexturedRect(currentX, centerY - (iconSize / 2), iconSize, iconSize)
    currentX = currentX + iconSize + spacing

    draw.SimpleText(valGFC, "PT.2", currentX, centerY, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

local coinCountSound
local isCountingSoundPlaying = false

hook.Add("HUDPaint", "DynamicCurrencyAnimations", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local targetCFC = ply:GetCFC()
    local targetGFC = ply:GetGFC()

    if displayCFC == -1 then displayCFC = targetCFC end
    if displayGFC == -1 then displayGFC = targetGFC end

    local curTime = SysTime()
    local sw, sh = ScrW(), ScrH()
    local drawX, drawY = sw - 20, 20
    
    local fadeTime = 1.0  
    local waitTime = 1.5  
    local flyTime = 1.2   
    local totalAnimTime = fadeTime + waitTime + flyTime
    
    local incomingCFC = 0
    local incomingGFC = 0
    
    for i = #flyAnims, 1, -1 do
        local anim = flyAnims[i]
        local t = curTime - anim.startTime
        
        local alpha = 0
        local x, y = sw / 2, sh / 2
        
        if t < fadeTime then
            alpha = (t / fadeTime) * 255
        elseif t < (fadeTime + waitTime) then
            alpha = 255
        elseif t < totalAnimTime then
            alpha = 255
            local flyProgress = (t - (fadeTime + waitTime)) / flyTime
            
            if flyProgress > 0.4 then
                balanceActiveUntil = curTime + 4 
            end
            
            local ease = flyProgress < 0.5 and 2 * flyProgress * flyProgress or 1 - math.pow(-2 * flyProgress + 2, 2) / 2
            x = Lerp(ease, sw / 2, drawX - 100)
            y = Lerp(ease, sh / 2, drawY + 20)
        else
            anim.done = true
            table.remove(flyAnims, i)
        end
        
        if not anim.done then
            if anim.type == "CFC" then incomingCFC = incomingCFC + anim.amount end
            if anim.type == "GFC" then incomingGFC = incomingGFC + anim.amount end
            
            alpha = math.Clamp(math.floor(alpha), 0, 255)
            
            surface.SetDrawColor(255, 255, 255, alpha)
            surface.SetMaterial(anim.type == "CFC" and matCFC or matGFC)
            surface.DrawTexturedRect(x - 40, y - 16, 32, 32)
            draw.SimpleText("+ " .. anim.amount, "PT.2", x, y, Color(255, 255, 255, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end

    local allowedCFC = targetCFC - incomingCFC
    local allowedGFC = targetGFC - incomingGFC
    
    local isAddingCoins = (displayCFC < allowedCFC) or (displayGFC < allowedGFC)

    if isAddingCoins then
        if not isCountingSoundPlaying then
            if not coinCountSound then
                coinCountSound = CreateSound(ply, "zames/vgui/up.wav")
            end
            coinCountSound:Play()
            isCountingSoundPlaying = true
        end
    else
        if isCountingSoundPlaying then
            if coinCountSound then
                coinCountSound:Stop()
            end
            isCountingSoundPlaying = false
        end
    end
    

    if displayCFC < allowedCFC and curTime > nextTickCFC then
        displayCFC = displayCFC + 1
        nextTickCFC = curTime + 0.01
        balanceActiveUntil = curTime + 2
    elseif displayCFC > targetCFC then 
        displayCFC = targetCFC 
    end

    if displayGFC < allowedGFC and curTime > nextTickGFC then
        displayGFC = displayGFC + 1
        nextTickGFC = curTime + 0.01
        balanceActiveUntil = curTime + 2
    elseif displayGFC > targetGFC then 
        displayGFC = targetGFC 
    end

    local targetOffset = (curTime < balanceActiveUntil) and 0 or 500
    balanceSlideOffset = Lerp(FrameTime() * 5, balanceSlideOffset, targetOffset)

    if balanceSlideOffset < 490 then
        DrawDynamicBalance(drawX, drawY, balanceSlideOffset)
    end
end)

local function OpenConfirmWindow(title, message, onConfirm)
    local frame = vgui.Create("DFrame")
    frame:SetSize(450, 150)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)

    frame.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(65, 65, 65,120))

        surface.SetDrawColor(255, 255, 255, 20)
        surface.DrawLine(0, 0, w, 0)
        surface.DrawLine(0, 0, 0, h)
        
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawLine(0, h-1, w, h-1)
        surface.DrawLine(w-1, 0, w-1, h)
        
        draw.SimpleText(title, "PT.2", w / 2, 25, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(message, "PT.3", w / 2, 65, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local btnYes = vgui.Create("DButton", frame)
    btnYes:SetSize(130, 35)
    btnYes:SetPos(70, 100)
    btnYes:SetText("Да")
    btnYes:SetFont("PT.2")
    btnYes:SetTextColor(color_white)
    btnYes.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(70, 130, 70, 150))
        if self:IsHovered() then draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 10)) end
    end
    btnYes.DoClick = function()
        frame:Close()
        if onConfirm then onConfirm() end
    end

    local btnNo = vgui.Create("DButton", frame)
    btnNo:SetSize(130, 35)
    btnNo:SetPos(250, 100)
    btnNo:SetText("Нет")
    btnNo:SetFont("PT.2")
    btnNo:SetTextColor(color_white)
    btnNo.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(150, 50, 50, 150))
        if self:IsHovered() then draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 10)) end
    end
    btnNo.DoClick = function() frame:Close() end
end

local function PopulateInventoryContent(parentPanel, itemsTable, categoryName)
    parentPanel:Clear()

    local scroll = vgui.Create("DScrollPanel", parentPanel)
    scroll:Dock(FILL)
    scroll:DockMargin(15, 15, 15, 15)

    local sbar = scroll:GetVBar()
    function sbar:Paint(w, h) end
    function sbar.btnUp:Paint(w, h) end
    function sbar.btnDown:Paint(w, h) end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(4, 4, 0, w - 8, h, Color(255, 255, 255, 50))
    end

    local layout = vgui.Create("DIconLayout", scroll)
    layout:Dock(FILL)
    layout:SetSpaceX(15)
    layout:SetSpaceY(15)

    local isFrameCategory = (categoryName == "Рамки войса")
    local isTabFrameCategory = (categoryName == "Рамки таба")
    local isFigureCategory = (categoryName == "Фигура")
    local itemIndex = 0

    local myInventory = LocalPlayer():GetInventory()

    for itemName, amount in pairs(myInventory) do
        if amount <= 0 then continue end
        
        local data = itemsTable[itemName]
        if not data then continue end 
        
        local displayName = data.name or itemName

        itemIndex = itemIndex + 1
        
        local itemPnl = layout:Add("DPanel")
        
        itemPnl:SetAlpha(0)
        itemPnl:AlphaTo(255, 0.3, itemIndex * 0.05)

        local panelW = 300
        local frameW, frameH = 260, 60
        local frameX, frameY = 20, 50
        
        if isFrameCategory then
            frameW, frameH = 250, 50
            frameX, frameY = (300 - frameW) / 2, 50 
        elseif isTabFrameCategory then
            panelW = 600
            frameW, frameH = 560, 80
            frameX, frameY = (panelW - frameW) / 2, 40
        elseif isFigureCategory then
            frameW, frameH = 64, 64
            frameX, frameY = (300 - frameW) / 2, 45
        elseif data.model then
            frameW, frameH = 256, 256
            frameX, frameY = (300 - frameW) / 2, 30
        end

        local panelHeight = math.max(220, frameY + frameH + 90)
        itemPnl:SetSize(panelW, panelHeight)

        if isTabFrameCategory then
            itemPnl.PreviewBar = CreatePlayerBar(itemPnl, LocalPlayer(), parentPanel, true) 
            if IsValid(itemPnl.PreviewBar) then
                itemPnl.PreviewBar:SetSize(frameW, frameH)
                itemPnl.PreviewBar:SetPos(frameX, frameY)
            end
        elseif isFrameCategory then
            itemPnl.PreviewBar = CreateVoicePlayerBar(itemPnl, LocalPlayer(), parentPanel)
            if IsValid(itemPnl.PreviewBar) then
                itemPnl.PreviewBar:SetVisible(false)
                itemPnl.PreviewBar:SetPos(frameX, frameY)
            end
        elseif data.model and not isFigureCategory then
            itemPnl.ModelPreview = vgui.Create("DModelPanel", itemPnl)
            itemPnl.ModelPreview:SetSize(frameW, frameH)
            itemPnl.ModelPreview:SetPos(frameX, frameY)
            itemPnl.ModelPreview:SetModel(data.model)
            itemPnl.ModelPreview:SetFOV(30)
            
            local camHeight = data.camZ or 60 
            
            itemPnl.ModelPreview:SetCamPos(Vector(60, 0, camHeight)) 
            itemPnl.ModelPreview:SetLookAt(Vector(0, 0, camHeight)) 
            
            itemPnl.ModelPreview.LayoutEntity = function(self_pnl, ent) end
        end

        itemPnl.Think = function(self)
            local hovered = vgui.GetHoveredPanel()
            local isHovering = IsValid(hovered) and (hovered == self or hovered:HasParent(self))
            if self.IsHoveringForPreview ~= isHovering then
                self.IsHoveringForPreview = isHovering
                if IsValid(self.PreviewBar) then self.PreviewBar:SetVisible(isHovering) end
            end
        end

        itemPnl.Paint = function(self, w, h)
            draw.SimpleText(displayName, "PT.2", w / 2, 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            if not isFigureCategory and not data.model and not isTabFrameCategory and not isFrameCategory then 
                draw.RoundedBox(0, frameX, frameY, frameW, frameH, color_black) 
            end

            if data.icon and data.icon ~= "путь до иконки" then
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(Material(data.icon))
                surface.DrawTexturedRect(frameX, frameY, frameW, frameH)
            end
            
            if amount > 1 then
                draw.SimpleText(amount .. " шт.", "PT.3", w - 20, 20, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end

            if data.persona then
                local pW, pH = 180, 35
                local pX, pY = (w - pW) / 2, h - 55
                draw.RoundedBox(0, pX, pY, pW, pH, Color(112, 226, 255, 100)) 
                
                surface.SetDrawColor(255, 255, 255, 20)
                surface.DrawLine(pX, pY, pX + pW, pY)
                surface.DrawLine(pX, pY, pX, pY + pH)
                surface.SetDrawColor(0, 0, 0, 200)
                surface.DrawLine(pX, pY + pH - 1, pX + pW, pY + pH - 1)
                surface.DrawLine(pX + pW - 1, pY, pX + pW - 1, pY + pH)

                draw.SimpleText("Персональный", "PT.2", w / 2, pY + (pH / 2), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        if not data.persona then
            local sellPriceCFC = math.floor((tonumber(data.cfc) or 0) / 2)
            local btnSell = vgui.Create("DButton", itemPnl)
            btnSell:SetSize(110, 35)
            btnSell:SetPos((panelW / 2) - 110 - 10, panelHeight - 55)
            btnSell:SetText("")
            btnSell.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(255, 208, 0, 100)) 

                surface.SetDrawColor(255, 255, 255, 20)
                surface.DrawLine(0, 0, w, 0)
                surface.DrawLine(0, 0, 0, h)
                
                surface.SetDrawColor(0, 0, 0, 200)
                surface.DrawLine(0, h-1, w, h-1)
                surface.DrawLine(w-1, 0, w-1, h)

                draw.SimpleText("Продать", "PT.2", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            btnSell.DoClick = function()
                OpenConfirmWindow("Продажа", "Продать " .. displayName .. " за " .. sellPriceCFC .. " CFC?", function()
                    net.Start("Shop_SellItem")
                    net.WriteString(itemName)
                    net.WriteString("CFC")
                    net.WriteInt(sellPriceCFC, 32)
                    net.SendToServer()
                    itemPnl:Remove() 
                end)
            end

            local btnDelete = vgui.Create("DButton", itemPnl)
            btnDelete:SetSize(110, 35)
            btnDelete:SetPos((panelW / 2) + 10, panelHeight - 55)
            btnDelete:SetText("")
            btnDelete.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(221, 63, 42, 100)) 

                surface.SetDrawColor(255, 255, 255, 20)
                surface.DrawLine(0, 0, w, 0)
                surface.DrawLine(0, 0, 0, h)
                
                surface.SetDrawColor(0, 0, 0, 200)
                surface.DrawLine(0, h-1, w, h-1)
                surface.DrawLine(w-1, 0, w-1, h)

                draw.SimpleText("Удалить", "PT.2", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            btnDelete.DoClick = function()
                OpenConfirmWindow("Удаление", "Безвозвратно удалить " .. displayName .. "?", function()
                    net.Start("Shop_DeleteItem")
                    net.WriteString(itemName)
                    net.SendToServer()
                    itemPnl:Remove() 
                end)
            end
        end
    end
    
    if itemIndex == 0 then
        local emptyLbl = vgui.Create("DLabel", scroll)
        emptyLbl:SetText("В этой категории пусто")
        emptyLbl:SetFont("PT.2")
        emptyLbl:SizeToContents()
        emptyLbl:SetPos(20, 20)
    end
end

RegisterScoreboardPage("InvShop_Page", function(parentPanel)
    local panel = vgui.Create("DPanel", parentPanel)
    panel:SetSize(ScrW() * 0.9, ScrH() * 1) 
    panel:Center()

    panel.Paint = function(self, w, h)
        DrawDynamicBalance(w - 20, 20) 
    end

    local navPanel = vgui.Create("DPanel", panel)
    navPanel:SetPos(20, 80)
    navPanel:SetSize(200, ScrH() * 0.8)
    navPanel.Paint = function() end

    local contentPanel = vgui.Create("DPanel", panel)
    contentPanel:SetPos(240, 80)
    contentPanel:SetSize(ScrW() * 0.9 - 260, ScrH() * 0.8)
    
    contentPanel.HasContent = false 
    
    contentPanel.Paint = function(self, w, h)
        if not self.HasContent then
            draw.SimpleText("В РАЗРАБОТКЕ", "PT.1", w / 2, h / 2, Color(255, 255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    local function CreateNavCategory(title, subCats)
        local categoryContainer = vgui.Create("DPanel", navPanel)
        categoryContainer:Dock(TOP)
        categoryContainer:DockMargin(0, 0, 0, 10)
        categoryContainer.Paint = function() end
        
        local mainBtn = vgui.Create("DButton", categoryContainer)
        mainBtn:Dock(TOP)
        mainBtn:SetTall(40)
        mainBtn:SetText("")
        
        local isExpanded = false
        local subItemsHeight = #subCats * 35
        
        categoryContainer:SetTall(40) 

        mainBtn.HoverVal = 0

        mainBtn.OnCursorEntered = function(self)
            surface.PlaySound("zames/vgui/roller_01.wav")
        end

        mainBtn.Paint = function(self, w, h)
            if self:IsHovered() then
                self.HoverVal = Lerp(FrameTime() * 12, self.HoverVal, 1)
            else
                self.HoverVal = Lerp(FrameTime() * 12, self.HoverVal, 0)
            end

            local margin = Lerp(self.HoverVal, 3, 0) 
            local bgAlpha = Lerp(self.HoverVal, 50, 120)
            local textOffset = Lerp(self.HoverVal, 0, 3)

            draw.RoundedBox(0, margin, margin, w - (margin * 2), h - (margin * 2), Color(165, 164, 164, bgAlpha)) 
            
            surface.SetDrawColor(255, 255, 255, 20 + (30 * self.HoverVal))
            surface.DrawLine(margin, margin, w - margin, margin)
            surface.DrawLine(margin, margin, margin, h - margin)
            
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawLine(margin, h - 1 - margin, w - margin, h - 1 - margin)
            surface.DrawLine(w - 1 - margin, margin, w - 1 - margin, h - margin)
            
            draw.SimpleText(title, "PT.2", w / 2, (h / 2) - textOffset, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local subContainer = vgui.Create("DPanel", categoryContainer)
        subContainer:Dock(TOP)
        subContainer:SetTall(0)
        subContainer.Paint = function() end

        for _, sub in ipairs(subCats) do
            local subBtn = vgui.Create("DButton", subContainer)
            subBtn:Dock(TOP)
            subBtn:SetTall(35)
            subBtn:SetText("")
            
            subBtn.HoverVal = 0

            subBtn.OnCursorEntered = function(self)
                surface.PlaySound("zames/vgui/roller_02.wav")
            end

            subBtn.Paint = function(self, w, h)
                if self:IsHovered() then
                    self.HoverVal = Lerp(FrameTime() * 12, self.HoverVal, 1)
                else
                    self.HoverVal = Lerp(FrameTime() * 12, self.HoverVal, 0)
                end

                local margin = Lerp(self.HoverVal, 2, 0)
                local bgAlpha = Lerp(self.HoverVal, 50, 90)

                local btnColor = sub.color and Color(sub.color.r, sub.color.g, sub.color.b, bgAlpha) or Color(75, 75, 75, bgAlpha)
                draw.RoundedBox(0, margin, margin, w - (margin * 2), h - (margin * 2), btnColor)
                
                surface.SetDrawColor(255, 255, 255, 20 + (20 * self.HoverVal))
                surface.DrawLine(margin, margin, w - margin, margin)
                surface.DrawLine(margin, margin, margin, h - margin)
                
                surface.SetDrawColor(0, 0, 0, 200)
                surface.DrawLine(margin, h - 1 - margin, w - margin, h - 1 - margin)
                surface.DrawLine(w - 1 - margin, margin, w - 1 - margin, h - margin)

                draw.SimpleText(sub.name, "PT.3", (w / 2) + (self.HoverVal * 5), h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            
            subBtn.DoClick = function()
                surface.PlaySound("zames/vgui/click.wav")
                if sub.items and table.Count(sub.items) > 0 then
                    contentPanel.HasContent = true
                    PopulateInventoryContent(contentPanel, sub.items, sub.name) 
                else
                    contentPanel:Clear() 
                    contentPanel.HasContent = false 
                end
            end
        end

        mainBtn.DoClick = function()
            surface.PlaySound("zames/vgui/click.wav")
            isExpanded = not isExpanded
            local targetHeight = isExpanded and (40 + subItemsHeight) or 40
            local targetSubHeight = isExpanded and subItemsHeight or 0

            categoryContainer:SizeTo(categoryContainer:GetWide(), targetHeight, 0.25, 0, -1)
            subContainer:SizeTo(subContainer:GetWide(), targetSubHeight, 0.25, 0, -1)
        end
    end

    CreateNavCategory("Скины", {
        {name = "Персональные", items = personal.ShopItems, color = Color(112,226,255,100)},
        {name = "Из фильмов", items = film.ShopItems},
        {name = "Из игр", items = games.ShopItems},
        {name = "Из мультиков", items = anime.ShopItems}, 
        {name = "Из мемов", items = meme.ShopItems}, 
    })

    CreateNavCategory("Профиль", {
        {name = "Рамки войса", items = ramka.ShopItems},
        {name = "Рамки таба", items = ramka_tab.ShopItems},
        {name = "Фигура", items = figura.ShopItems}, 
    })

    CreateNavCategory("Аксессуары", {
        {name = "Шапки"}, 
        {name = "Маски"}
    })

    return panel 
end)
