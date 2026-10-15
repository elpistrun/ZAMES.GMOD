--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/1rg9gd2wb6xh5xr8fw2wb4kx6xh2vt_9vn4kx6ql5xr1rg/cl_1rg9gd2wb6xh5xr8fw2wb4kx6xh2vt.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

SCOREBOARD_PAGES = SCOREBOARD_PAGES or {}

function RegisterScoreboardPage(id, renderFunc)
    SCOREBOARD_PAGES[id] = renderFunc
end

local blurMat = Material("pp/blurscreen")
local glowMat = mh("zames/glow.png")

local current_pages = {
    [1] = {name = "Игроки", icon = "zames/users.png", page = "Players_Page"},
    [2] = {name = "Магазин", icon = "zames/shop.png", page = "Shop_Page"},
    [3] = {name = "Инвентарь", icon = "zames/inv_shop.png", page = "InvShop_Page"},
    [4] = {name = "Смена команды", icon = "zames/gamemodes.png", page = "Team_Page"},
    [5] = {name = "Топ сервера", icon = "zames/top.png", page = "Top_Page"},
    [6] = {name = "Профиль", icon = "zames/user.png", page = "Profile_Page"},

}

local LastActivePage = current_pages[1].page

if IsValid(ScoreboardPanel) then
    ScoreboardPanel:Remove()
    ScoreboardPanel = nil
end

local ActivePagePanel = nil

local function CloseScoreboard()
    if not IsValid(ScoreboardPanel) then return end
    if ScoreboardPanel.IsClosing then return end
    ScoreboardPanel.IsClosing = true

    if IsValid(ScoreboardPanel.TabContainer) then
        ScoreboardPanel.TabContainer:MoveTo(ScrW() + 100, ScrH() * 0.15, 0.4, 0, -1)
    end

    ScoreboardPanel:AlphaTo(0, 0.4, 0, function()
        if IsValid(ScoreboardPanel) then
            ScoreboardPanel:Remove()
            ScoreboardPanel = nil
        end
    end)

    if IsValid(Scoreboard_TimerLabel) then
        Scoreboard_TimerLabel:AlphaTo(0, 0.5, 2, function()
            if IsValid(Scoreboard_TimerLabel) then
                Scoreboard_TimerLabel:Remove()
            end
        end)
    end
end

local function CreateScoreboard(defaultPage)
    if IsValid(ScoreboardPanel) then ScoreboardPanel:Remove() end

    ScoreboardPanel = vgui.Create("DFrame")
    ScoreboardPanel:SetSize(ScrW(), ScrH())
    ScoreboardPanel:SetTitle("")
    ScoreboardPanel:ShowCloseButton(false)
    ScoreboardPanel:SetDraggable(false)
    ScoreboardPanel:MakePopup() 
    ScoreboardPanel:SetKeyboardInputEnabled(false) 

    ScoreboardPanel:SetAlpha(0)
    ScoreboardPanel:AlphaTo(255, 0.3)

    ScoreboardPanel.BgAlpha = 1 

    ScoreboardPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150 * self.BgAlpha))

        if self.BgAlpha > 0.01 then
            local x, y = self:LocalToScreen(0, 0)
            
            surface.SetDrawColor(255, 255, 255, 255 * self.BgAlpha)
            surface.SetMaterial(blurMat)
            for i = 1, 3 do
                blurMat:SetFloat("$blur", (i / 3) * 6 * self.BgAlpha)
                blurMat:Recompute()
                render.UpdateScreenEffectTexture()
                surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
            end
        end
    end

   if IsValid(Scoreboard_TimerLabel) then 
        Scoreboard_TimerLabel:Remove() 
    end
    
    Scoreboard_TimerLabel = vgui.Create("DLabel")
    Scoreboard_TimerLabel:SetDrawOnTop(true)
    Scoreboard_TimerLabel:SetFont("PT.3")
    Scoreboard_TimerLabel:SetSize(ScrW(), 50)
    Scoreboard_TimerLabel:SetPos(0, ScrH() - 90) 
    Scoreboard_TimerLabel:SetContentAlignment(5)
    Scoreboard_TimerLabel:SetText("")
    
    Scoreboard_TimerLabel:SetAlpha(0)
    Scoreboard_TimerLabel:AlphaTo(255, 0.5, 0.2)

    Scoreboard_TimerLabel.Think = function(self)
        local endTime = GetGlobalFloat("RoundEndTime", 0)
        local timeLeft = math.max(0, endTime - CurTime())
        
        local timeStr = string.FormattedTime(timeLeft, "%02i:%02i")
        self:SetText("Раунд закончится через - " .. timeStr)
    end

    local tabContainer = vgui.Create("DPanel", ScoreboardPanel)
    tabContainer:SetSize(70, ScrH() * 0.6)
    tabContainer:SetPos(ScrW() + 100, ScrH() * 0.15) 
    tabContainer.Paint = function() end 
    
    ScoreboardPanel.TabContainer = tabContainer

    local function OpenPage(pageId)
        if IsValid(ActivePagePanel) then 
            ActivePagePanel:Hide() 
        end
        
        ScoreboardPanel.CachedPages = ScoreboardPanel.CachedPages or {}
        
        if IsValid(ScoreboardPanel.CachedPages[pageId]) then
            ActivePagePanel = ScoreboardPanel.CachedPages[pageId]
            ActivePagePanel:Show()
        elseif SCOREBOARD_PAGES[pageId] then
            ActivePagePanel = SCOREBOARD_PAGES[pageId](ScoreboardPanel) 
            ScoreboardPanel.CachedPages[pageId] = ActivePagePanel
        else
            print("Ошибка: Страница " .. pageId .. " не зарегистрирована!")
        end
    end

    local tabY = 0
    for i, pageData in ipairs(current_pages) do
        local btn = vgui.Create("DButton", tabContainer)
        btn:SetSize(64, 64)
        btn:SetPos(5, tabY)
        btn:SetText("")

        btn.OnCursorEntered = function(self)
            surface.PlaySound("zames/vgui/roller_02.wav") 
        end

        btn.HoverVal = 0
        btn.Paint = function(self, w, h)
            local isActive = (LastActivePage == pageData.page)
            
            self.HoverVal = Lerp(FrameTime() * 12, self.HoverVal, self:IsHovered() and 1 or 0)

            if self.HoverVal > 0.01 or isActive then
                DisableClipping(true)

                if isActive then
                    surface.SetMaterial(glowMat)
                    
                    local pulse = (math.sin(CurTime() * 4) + 1) / 2 
                    local alpha = 30 + (155 * pulse) 
                    
                    surface.SetDrawColor(255, 255, 255, alpha)
                    
                    local glowSize = 70
                    local offset = (glowSize - w) / 2
                    
                    surface.DrawTexturedRect(-offset, -offset, glowSize, glowSize)
                end

                -- Отрисовка текста при наведении
                if self.HoverVal > 0.01 then
                    surface.SetFont("Trebuchet24")
                    local txt = pageData.name
                    local tw, th = surface.GetTextSize(txt)
                    local boxW, boxH = tw + 20, th + 10
                    
                    local offsetText = 15 * (1 - self.HoverVal)
                    local boxX = -boxW - 10 + offsetText
                    
                    draw.SimpleText(txt, "PT.6", boxX + boxW / 2, h / 2, Color(255, 255, 255, 255 * self.HoverVal), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                
                DisableClipping(false)
            end
        end

        local icon = vgui.Create("DImage", btn)
        icon:SetSize(55, 55)
        icon:Center()
        icon:SetImage(pageData.icon)

        icon.PaintOver = function(self, w, h)
            if pageData.page == "Players_Page" then
                local plyCount = #player.GetAll() 
                DisableClipping(true)

                draw.SimpleText(plyCount, "PT.2", w - 5, 6, Color(12, 12, 12), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText(plyCount, "PT.2", w - 5, 4, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                DisableClipping(false)
            end
        end

        btn.DoClick = function(self)
            surface.PlaySound("zames/vgui/click.wav")
            local origSize = 55
            local shrinkSize = 45
            
            icon:SizeTo(shrinkSize, shrinkSize, 0.1, 0, -1, function()
                if IsValid(icon) then
                    icon:SizeTo(origSize, origSize, 0.1, 0, -1)
                    icon:MoveTo((self:GetWide() - origSize) / 2, (self:GetTall() - origSize) / 2, 0.1, 0, -1)
                end
            end)
            
            icon:MoveTo((self:GetWide() - shrinkSize) / 2, (self:GetTall() - shrinkSize) / 2, 0.1, 0, -1)

            LastActivePage = pageData.page 
            OpenPage(pageData.page)
        end

        tabY = tabY + 70 
    end

    tabContainer:MoveTo(ScrW() - 100, ScrH() * 0.15, 0.4, 0, -1)

    local targetPage = defaultPage or LastActivePage or "Players_Page"
    LastActivePage = targetPage
    OpenPage(targetPage)
end

hook.Add("ScoreboardShow", "CustomScoreboard_Show", function()
    if IsValid(ScoreboardPanel) then
        CloseScoreboard()
    else
        CreateScoreboard()
    end
    return true
end)

hook.Add("ScoreboardHide", "CustomScoreboard_Hide", function()
    return true
end)

-- Быстрое переключение команды по F2 (работает ТОЛЬКО у наблюдателей: 1002 -> 1)
local function ToggleTeamF2()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    if ply:Team() ~= 1002 then return end

    if IsValid(ScoreboardPanel) then
        CloseScoreboard()
    end

    net.Start("net_ch_team")
        net.WriteInt(1, 16)
    net.SendToServer()

    surface.PlaySound("zames/vgui/click1.wav")
end

function GM:ShowTeam()
    ToggleTeamF2()
    return true
end

hook.Add("ShowTeam", "CustomScoreboard_ShowTeam", function()
    ToggleTeamF2()
    return true
end)

hook.Add("PlayerBindPress", "CustomScoreboard_F2Bind", function(ply, bind, pressed)
    if not pressed then return end
    if string.find(string.lower(bind), "gm_showteam") then
        ToggleTeamF2()
        return true
    end
end)
