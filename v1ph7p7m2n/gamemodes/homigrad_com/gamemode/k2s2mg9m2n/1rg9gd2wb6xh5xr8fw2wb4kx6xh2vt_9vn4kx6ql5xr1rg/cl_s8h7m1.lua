--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/1rg9gd2wb6xh5xr8fw2wb4kx6xh2vt_9vn4kx6ql5xr1rg/cl_s8h7m1.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

local matCFC = Material("zames/c_fc.png")
local matGFC = Material("zames/g_fc.png")

local function FormatMoney(n)
    if not n then return "0" end
    local left, num, right = string.match(tostring(n), '^([^%d]*%d)(%d*)(.-)$')
    return left .. (num:reverse():gsub('(%d%d%d)', '%1.'):reverse()) .. right
end

local function DrawDynamicBalance(rightX, y)
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local valCFC = FormatMoney(ply:GetCFC())
    local valGFC = FormatMoney(ply:GetGFC())

    local iconSize = 32
    local padding = 12
    local spacing = 5

    surface.SetFont("PT.2")
    
    local wCFC, hText = surface.GetTextSize(valCFC)
    local wGFC, _ = surface.GetTextSize(valGFC)

    local totalWidth = padding + iconSize + spacing + wCFC + (spacing * 2) + iconSize + spacing + wGFC + padding
    local totalHeight = math.max(iconSize, hText) + (padding * 1.5)

    local startX = rightX - totalWidth

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

local function CreateTopPlayerBar(parent, plyData, rank, category, rootPanel)
    if not plyData then return end

    local origTall = 80
    local hoverTall = 100
    local clickTall = 70
    local sideMargin = 200

    local container = vgui.Create("DPanel", parent)
    container:SetTall(origTall)
    container:Dock(TOP)
    container:DockMargin(0, 0, 0, 8)

    container:SetAlpha(0)

    container:AlphaTo(255, 0.3, rank * 0.05)
    
    container.Paint = function(self, w, h)
        local textY = h / 2
        draw.SimpleText("#" .. rank, "PT.3", sideMargin - 35, textY, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local plyBar = vgui.Create("DButton", container)
    plyBar:SetText("")

    local avatar = vgui.Create("AvatarImage", plyBar)
    local origAvSize = 64
    local hoverAvSize = 80
    local clickAvSize = 55
    
    avatar:SetSize(origAvSize, origAvSize)
    avatar:SetPos(15, (origTall - origAvSize) / 2)
    avatar:SetSteamID(plyData.SteamID64, 128)
    avatar:SetMouseInputEnabled(false) 

    container.PerformLayout = function(self, w, h)
        if IsValid(plyBar) then
            plyBar:SetSize(w - (sideMargin * 2), h)
            plyBar:SetPos(sideMargin, 0)
        end
    end

    plyBar.CurrentTextOffset = 0

    plyBar.Paint = function(self, w, h)
        local bgColor = self:IsHovered() and Color(88, 88, 88, 170) or Color(68, 68, 68, 170)
        draw.RoundedBox(0, 0, 0, w, h, bgColor)

        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawLine(0, 0, w, 0)
        surface.DrawLine(0, 0, 0, h)
        
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawLine(0, h-1, w, h-1)
        surface.DrawLine(w-1, 0, w-1, h)

        local targetOffset = 0
        if self:IsHovered() and not self.IsClickAnimating then
            targetOffset = 20 
        end
        
        self.CurrentTextOffset = Lerp(FrameTime() * 12, self.CurrentTextOffset, targetOffset)

        local textY = h / 2

        draw.SimpleText(plyData.Nick, "PT.3", 160 + self.CurrentTextOffset, textY, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        if category == "GHC" or category == "CHC" then
            local valStr, col, mat
            if category == "GHC" then
                valStr = FormatMoney(plyData.GFC)
                col = Color(255, 215, 0)
                mat = matGFC
            else
                valStr = FormatMoney(plyData.CFC)
                col = Color(192, 192, 192)
                mat = matCFC
            end
            
            surface.SetFont("PT.3")
            local tw, th = surface.GetTextSize(valStr)
            local iconSize = 24
            local spacing = 6
            local totalW = tw + spacing + iconSize
            
            local sectionCenterX = (w * 0.5) + self.CurrentTextOffset
            local startX = sectionCenterX - (totalW / 2)
            
            draw.SimpleText(valStr, "PT.3", startX, textY, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(startX + tw + spacing, textY - (iconSize / 2), iconSize, iconSize)
        end

        local hoursText = string.format("%.1fh", plyData.Playtime / 3600)
        draw.SimpleText(hoursText, "PT.3", (w * 0.75) + self.CurrentTextOffset, textY, Color(248, 248, 248), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    plyBar.OnCursorEntered = function(self)
        if self.IsClickAnimating then return end 
        surface.PlaySound("zames/vgui/roller_02.wav")
        self:Stop(); avatar:Stop(); container:Stop()
        
        container:SetAlpha(255)

        container:SizeTo(-1, hoverTall, 0.15, 0, -1)
        avatar:SizeTo(hoverAvSize, hoverAvSize, 0.15, 0, -1)
        avatar:MoveTo(15, (hoverTall - hoverAvSize) / 2, 0.15, 0, -1)
    end

    plyBar.OnCursorExited = function(self)
        if self.IsClickAnimating then return end 
        self:Stop(); avatar:Stop(); container:Stop()

        container:SetAlpha(255)

        container:SizeTo(-1, origTall, 0.15, 0, -1)
        avatar:SizeTo(origAvSize, origAvSize, 0.15, 0, -1)
        avatar:MoveTo(15, (origTall - origAvSize) / 2, 0.15, 0, -1)
    end

    plyBar.DoClick = function(self)
        surface.PlaySound("zames/vgui/click.wav")
        
        self.IsClickAnimating = true 
        self:Stop()
        avatar:Stop()
        container:Stop()

        container:SetAlpha(255)

        container:SizeTo(-1, clickTall, 0.05, 0, -1, function()
            if IsValid(container) then
                container:SizeTo(-1, origTall, 0.15, 0, -1, function()
                    if IsValid(self) then self.IsClickAnimating = false end
                end)
            end
        end)
        
        avatar:SizeTo(clickAvSize, clickAvSize, 0.05, 0, -1, function()
            if IsValid(avatar) then avatar:SizeTo(origAvSize, origAvSize, 0.15, 0, -1) end
        end)
        
        avatar:MoveTo(15, (clickTall - clickAvSize) / 2, 0.05, 0, -1, function()
            if IsValid(avatar) then avatar:MoveTo(15, (origTall - origAvSize) / 2, 0.15, 0, -1) end
        end)

        -- ВАЖНО: Принудительно цепляем окно к экрану, а не к скорборду, чтобы оно не обрезалось
        local overlayParent = vgui.GetWorldPanel() 
        
        if IsValid(overlayParent.ActiveProfileOverlay) then
            overlayParent.ActiveProfileOverlay:Remove()
        end

        if CreateProfileWindow then
            local profWindow = CreateProfileWindow(overlayParent, plyData, true)
            if IsValid(profWindow) then
                profWindow:MakePopup() -- Заставляем окно быть поверх всего и перехватывать мышь
                overlayParent.ActiveProfileOverlay = profWindow
            end
        else
            print("[Топ] ОШИБКА: Функция CreateProfileWindow не найдена!")
        end
    end

    return container
end

local CurrentTopScroll = nil

net.Receive("ReceiveTopList", function()
    local dataList = net.ReadTable()
    local categoryName = net.ReadString()

    if IsValid(CurrentTopScroll) then
        CurrentTopScroll:Clear()
        
        for rank, plyData in ipairs(dataList) do
            local catType = "TIME"
            if categoryName == "Топ по GHC" then catType = "GHC" end
            if categoryName == "Топ по CHC" then catType = "CHC" end

            CreateTopPlayerBar(CurrentTopScroll, plyData, rank, catType, CurrentTopScroll.RootPanel)
        end
    end
end)

local function PopulateContent(parentPanel, categoryName, rootPanel)
    parentPanel:Clear()
    parentPanel.HasContent = true

    -- 1. Создаем шапку отдельно на parentPanel (над скроллом)
    local header = vgui.Create("DPanel", parentPanel)
    header:Dock(TOP)
    header:SetTall(20)
    header:DockMargin(15, 15, 15, 5) -- Отступы по бокам такие же, как у контента

    header.Paint = function(self, w, h)
        local sideMargin = 200
        local barX = sideMargin
        local barW = w - (sideMargin * 2)
        local textY = h / 2
        
        draw.SimpleText("МЕСТО", "PT.3", sideMargin - 35, textY, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("НИКНЕЙМ", "PT.3", barX + 160, textY, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        if categoryName == "Топ по GHC" or categoryName == "Топ по CHC" then
            draw.SimpleText("БАЛАНС", "PT.3", barX + (barW * 0.5), textY, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        draw.SimpleText("ЧАСЫ", "PT.3", barX + (barW * 0.75), textY, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- 2. Создаем сам скролл под шапкой
    local scroll = vgui.Create("DScrollPanel", parentPanel)
    scroll:Dock(FILL)
    scroll:DockMargin(15, 5, 15, 15)
    scroll.RootPanel = rootPanel
    CurrentTopScroll = scroll
    
    local sbar = scroll:GetVBar()
    function sbar:Paint(w, h) end
    function sbar.btnUp:Paint(w, h) end
    function sbar.btnDown:Paint(w, h) end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(4, 4, 0, w - 8, h, Color(255, 255, 255, 50))
    end

    -- 3. Запрашиваем данные с сервера
    net.Start("RequestTopList")
    net.WriteString(categoryName)
    net.SendToServer()
end

RegisterScoreboardPage("Top_Page", function(parentPanel)
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
            draw.SimpleText("ВЫБЕРИТЕ КАТЕГОРИЮ ИЗ МЕНЮ", "PT.1", w / 2, h / 2, Color(255, 255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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

                draw.RoundedBox(0, margin, margin, w - (margin * 2), h - (margin * 2), Color(75, 75, 75, bgAlpha))
                
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
                PopulateContent(contentPanel, sub.name, parentPanel)
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

    CreateNavCategory("По часам", {
        {name = "Топ по часам"}, 
    })

    CreateNavCategory("По коинам", {
        {name = "Топ по GHC"}, 
        {name = "Топ по CHC"}
    })

    return panel 
end)
