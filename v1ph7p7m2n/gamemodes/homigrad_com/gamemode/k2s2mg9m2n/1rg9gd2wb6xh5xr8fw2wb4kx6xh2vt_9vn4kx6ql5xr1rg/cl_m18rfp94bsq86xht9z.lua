--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/1rg9gd2wb6xh5xr8fw2wb4kx6xh2vt_9vn4kx6ql5xr1rg/cl_m18rfp94bsq86xht9z.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

local mWheelMat = Material("gui/mwheel.png")

local Volume_mat_mute = mh("zames/speaker/voice_mute.png")
local Volume_mat_0 = mh("zames/speaker/voice_0.png")
local Volume_mat_1 = mh("zames/speaker/voice_1.png")
local Volume_mat_2 = mh("zames/speaker/voice_2.png")
local Volume_mat_3 = mh("zames/speaker/voice_3.png")

local valid = {
    ["superadmin"]  = {name = "SUPERADMIN!!!", color = Color(255,0,0)},
    ["dsuperadmin"] = {name = "DSUPERADMIN", color = Color(255,0,0)},
    ["admin"]       = {name = "ADMIN", color = Color(15,100,4)},
    ["dadmin"]      = {name = "DADMIN", color = Color(33,187,13)},
    ["operator"]    = {name = "OPERATOR", color = Color(15,100,4)},
    ["doperator"]   = {name = "DOPERATOR", color = Color(0,183,255)},
    ["megasponsor"] = {name = "MEGASPONSOR", color = Color(255,153,0)},

    ["mpiar"] = {name = "М.ПИАР-АГЕНТ", color = Color(211,36,123)},
    ["piar"] = {name = "ПИАР-АГЕНТ", color = Color(255,98,111)},
}

-- Репутация всегда 1000: значение больше не пересчитывается из вины (Guilt)
local function GetGuiltNumber(ply)
    return 1000
end

function CreatePlayerBar(parent, ply, rootPanel, isPreview)
    if not IsValid(ply) then return end

    if ply:GetNW2Bool("IsAnonim", false) then
        local fakePly = ply:GetNW2Entity("AnonimAvatar")
        if IsValid(fakePly) and fakePly:IsPlayer() then
            ply = fakePly
        end
    end

    local origTall = 80
    local hoverTall = 100
    local clickTall = 70
    
    local sideMargin = isPreview and 0 or 250

    local container = vgui.Create("DPanel", parent)
    container:SetTall(origTall)
    container.Paint = function(self, w, h)
        if not IsValid(ply) then return end
        
        if not isPreview then
            local textY = h / 2
            draw.SimpleText(ply:Ping(), "PT.3", sideMargin - 35, textY, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    local plyBar = vgui.Create("DButton", container)
    plyBar:SetText("")

    local avatar = vgui.Create("AvatarImagePlus", plyBar)
    local origAvSize = 64
    local hoverAvSize = 80
    local clickAvSize = 55
    
    avatar:SetSize(origAvSize, origAvSize)
    avatar:SetPos(15, (origTall - origAvSize) / 2)
    avatar:SetPlayer(ply, 128)
    avatar:SetMouseInputEnabled(false) 

    local muteBtn
    
    if not isPreview then
        muteBtn = vgui.Create("DButton", container)
        muteBtn:SetSize(64, 64)
        muteBtn:SetText("")
        muteBtn.IsDragging = false

        muteBtn.OnMousePressed = function(self, mouseCode)
            if not IsValid(ply) then return end
            
            if mouseCode == MOUSE_LEFT then
                self.IsDragging = true
                self:MouseCapture(true)
                local cx, _ = self:CursorPos()
                local pct = math.Clamp(cx / self:GetWide(), 0, 1)
                ply:SetVoiceVolumeScale(pct)
                if pct > 0 and ply:IsMuted() then ply:SetMuted(false) end
            elseif mouseCode == MOUSE_RIGHT then
                ply:SetMuted(not ply:IsMuted())
            end
        end

        muteBtn.OnMouseReleased = function(self, mouseCode)
            if mouseCode == MOUSE_LEFT then
                self.IsDragging = false
                self:MouseCapture(false)
            end
        end

        muteBtn.OnCursorMoved = function(self, cx, cy)
            if not IsValid(ply) then return end
            if self.IsDragging then
                local pct = math.Clamp(cx / self:GetWide(), 0, 1)
                ply:SetVoiceVolumeScale(pct)
                if pct > 0 and ply:IsMuted() then
                    ply:SetMuted(false)
                end
            end
        end

        muteBtn.OnMouseWheeled = function(self, delta)
            if not IsValid(ply) then return end
            local oldValue = math.floor(ply:GetVoiceVolumeScale() * 100)
            oldValue = math.Round(oldValue / 5) * 5
            local newVal = math.Clamp((oldValue + (delta * 5)) / 100, 0, 1)
            ply:SetVoiceVolumeScale(newVal)
            if newVal > 0 and ply:IsMuted() then ply:SetMuted(false) end
            self.LastWheelTick = CurTime()
        end

        muteBtn.Paint = function(self, w, h)
            if not IsValid(ply) then return end

            if self:IsHovered() or self.IsDragging then
                self.LastWheelTick = CurTime()
            end

            local vol = ply:GetVoiceVolumeScale()
            local isMuted = ply:IsMuted()
            local volPct = isMuted and 0 or math.Round(vol * 100)

            local mat = Volume_mat_3
            if isMuted or volPct == 0 then
                mat = Volume_mat_mute
            elseif volPct <= 15 then
                mat = Volume_mat_0
            elseif volPct <= 40 then
                mat = Volume_mat_1
            elseif volPct <= 60 then
                mat = Volume_mat_2
            else
                mat = Volume_mat_3
            end

            surface.SetMaterial(mat)
            surface.SetDrawColor(82, 82, 82, 100)
            surface.DrawTexturedRect(0, 0, w, h)

            local fillU = isMuted and 0 or vol
            if fillU > 0 then
                surface.SetDrawColor(175, 174, 174)
                surface.DrawTexturedRectUV(0, 0, w * fillU, h, 0, 0, fillU, 1)
            end

            local time = math.Clamp(CurTime() - (self.LastWheelTick or 0), 0, 0.75) / 0.75
            local bgAlpha = 255 - time * 255

            if bgAlpha > 0 then
                draw.SimpleText(volPct .. "%", "DermaDefault", w + 8, h + 8, Color(255, 255, 255, bgAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
        end
    end

    container.PerformLayout = function(self, w, h)
        if IsValid(plyBar) then
            plyBar:SetSize(w - (sideMargin * 2), h)
            plyBar:SetPos(sideMargin, 0)
        end
        if not isPreview and IsValid(muteBtn) then
            muteBtn:SetPos(w - sideMargin + 15, (h - 64) / 2)
        end
    end

    plyBar.CurrentTextOffset = 0

    plyBar.Paint = function(self, w, h)
        if not IsValid(ply) then return end

        local isSpec = ply:Team() == 1002
        local lp = LocalPlayer()
        local canSeeDead = (not lp:Alive()) or (lp:Team() == 1002)

        if IsValid(avatar) then
            avatar:SetAlpha(isSpec and 100 or 255)
        end

        local bgColor = (not isPreview and self:IsHovered()) and Color(88, 88, 88, 170) or Color(68, 68, 68, 170)
        
        if isSpec then
            bgColor = (not isPreview and self:IsHovered()) and Color(88, 88, 88, 50) or Color(68, 68, 68, 30)
        elseif not ply:Alive() and canSeeDead then
            bgColor = (not isPreview and self:IsHovered()) and Color(156, 22, 22, 170) or Color(136, 2, 2, 170)
        end

        draw.RoundedBox(0, 0, 0, w, h, bgColor)

        local tabBGPath = ply:GetNWString("TabBG", "")
        if tabBGPath ~= "" then
            surface.SetMaterial(mh(tabBGPath))
            local bgAlpha = isSpec and 80 or 255
            surface.SetDrawColor(255, 255, 255, bgAlpha)
            surface.DrawTexturedRect(0, 0, w, h)
        end

        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawLine(0, 0, w, 0)
        surface.DrawLine(0, 0, 0, h)
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawLine(0, h-1, w, h-1)
        surface.DrawLine(w-1, 0, w-1, h)

        local targetOffset = 0
        if not isPreview and self:IsHovered() and not self.IsClickAnimating then
            targetOffset = 20 
        end
        
        self.CurrentTextOffset = Lerp(FrameTime() * 12, self.CurrentTextOffset, targetOffset)

        local textY = h / 2
        local userGroup = ply:GetUserGroup()
        
        -- Центрирование элементов по процентам от ширины
        if userGroup ~= "user" then
            local groupData = valid[userGroup]
            local displayName = groupData and groupData.name or string.upper(userGroup)
            local groupColor = groupData and groupData.color or Color(255, 255, 255)
            draw.SimpleText(displayName, "PT.3", (w * 0.22) + self.CurrentTextOffset, textY, groupColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        local plyName = ply:Nick()
        -- Ник ровно под колонкой никнейма
        draw.SimpleText(plyName, "PT.3", (w * 0.52) + self.CurrentTextOffset, textY, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        local hoursText = ""
        local rawHours = ply.GetPlayTimeHours and ply:GetPlayTimeHours() or 0
        hoursText = string.format("%.1fh", rawHours)
        
        draw.SimpleText(hoursText, "PT.3", (w * 0.85) + self.CurrentTextOffset, textY, Color(248, 248, 248), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    plyBar.OnCursorEntered = function(self)
        if isPreview then return end 
        if self.IsClickAnimating then return end 
        surface.PlaySound("zames/vgui/roller_02.wav")
        self:Stop()
        avatar:Stop()
        container:Stop()
        container:SizeTo(-1, hoverTall, 0.15, 0, -1)
        avatar:SizeTo(hoverAvSize, hoverAvSize, 0.15, 0, -1)
        avatar:MoveTo(15, (hoverTall - hoverAvSize) / 2, 0.15, 0, -1)
    end

    plyBar.OnCursorExited = function(self)
        if isPreview then return end
        if self.IsClickAnimating then return end 
        self:Stop()
        avatar:Stop()
        container:Stop()
        container:SizeTo(-1, origTall, 0.15, 0, -1)
        avatar:SizeTo(origAvSize, origAvSize, 0.15, 0, -1)
        avatar:MoveTo(15, (origTall - origAvSize) / 2, 0.15, 0, -1)
    end

    plyBar.DoClick = function(self)
        if isPreview then return end
        surface.PlaySound("zames/vgui/click.wav")
        self.IsClickAnimating = true 
        self:Stop()
        avatar:Stop()
        container:Stop()
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

        local overlayParent = rootPanel or vgui.GetWorldPanel()
        if IsValid(overlayParent.ActiveProfileOverlay) then
            overlayParent.ActiveProfileOverlay:Remove()
        end

        if CreateProfileWindow then
            overlayParent.ActiveProfileOverlay = CreateProfileWindow(overlayParent, ply, true)
        end
    end

    return container
end

local MuteAllEnabled = false
local MuteDeadEnabled = false

timer.Create("AutoMuteScoreboardLogic", 1, 0, function()
    if MuteAllEnabled then
        for _, ply in player.Iterator() do
            if ply ~= LocalPlayer() and not ply:IsMuted() then
                ply:SetMuted(true)
            end
        end
    elseif MuteDeadEnabled then
        local lp = LocalPlayer()
        
        local shouldForceMuteDead = (not lp:Alive()) or (lp:Team() == 1002)

        for _, ply in player.Iterator() do
            if ply ~= lp then
                if shouldForceMuteDead and not ply:Alive() then
                    if not ply:IsMuted() then
                        ply:SetMuted(true)
                    end
                elseif ply:IsMuted() then
                    ply:SetMuted(false)
                end
            end
        end
    end
end)

RegisterScoreboardPage("Players_Page", function(parentPanel)
    local panel = vgui.Create("DPanel", parentPanel)
    panel:SetSize(ScrW() * 0.6, ScrH() * 1) 
    panel:Center()
    panel.Paint = function(self, w, h) end

    local bottomPanel = vgui.Create("DPanel", panel)
    bottomPanel:Dock(BOTTOM)
    bottomPanel:SetTall(40)
    bottomPanel:DockMargin(15, 0, 15, 15)
    bottomPanel.Paint = function(self, w, h) end

    bottomPanel.PerformLayout = function(self, w, h)
        local btnWidth = 220
        local spacing = 15
        local totalWidth = (btnWidth * 2) + spacing
        local startX = (w - totalWidth) / 2
        
        if IsValid(self.btnMuteDead) then
            self.btnMuteDead:SetPos(startX, 0)
            self.btnMuteDead:SetSize(btnWidth, h)
        end
        if IsValid(self.btnMuteAll) then
            self.btnMuteAll:SetPos(startX + btnWidth + spacing, 0)
            self.btnMuteAll:SetSize(btnWidth, h)
        end
    end

    local btnMuteDead = vgui.Create("DButton", bottomPanel)
    bottomPanel.btnMuteDead = btnMuteDead
    btnMuteDead:SetText("")
    btnMuteDead.DoClick = function(self)
        surface.PlaySound("zames/vgui/click.wav")
        MuteDeadEnabled = not MuteDeadEnabled
        if MuteDeadEnabled then 
            MuteAllEnabled = false 
        else
            for _, ply in player.Iterator() do
                if ply ~= LocalPlayer() then ply:SetMuted(false) end
            end
        end 
    end
    btnMuteDead.Paint = function(self, w, h)
        local bgColor = self:IsHovered() and Color(88, 88, 88, 170) or Color(68, 68, 68, 170)
        draw.RoundedBox(4, 0, 0, w, h, bgColor)
        local txtColor = MuteDeadEnabled and Color(0, 255, 0) or color_white
        draw.SimpleText("ЗАМУТИТЬ МЕРТВЫХ", "PT.3", w / 2, h / 2, txtColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local btnMuteAll = vgui.Create("DButton", bottomPanel)
    bottomPanel.btnMuteAll = btnMuteAll
    btnMuteAll:SetText("")
    btnMuteAll.DoClick = function(self)
        surface.PlaySound("zames/vgui/click.wav")
        MuteAllEnabled = not MuteAllEnabled
        if MuteAllEnabled then 
            MuteDeadEnabled = false 
        else
            for _, ply in player.Iterator() do
                if ply ~= LocalPlayer() then ply:SetMuted(false) end
            end
        end
    end

    btnMuteAll.Paint = function(self, w, h)
        local bgColor = self:IsHovered() and Color(88, 88, 88, 170) or Color(68, 68, 68, 170)
        draw.RoundedBox(4, 0, 0, w, h, bgColor)
        local txtColor = MuteAllEnabled and Color(0, 255, 0) or color_white
        draw.SimpleText("ЗАМУТИТЬ ВСЕХ", "PT.3", w / 2, h / 2, txtColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local scroll = vgui.Create("DScrollPanel", panel)
    scroll:Dock(FILL)
    scroll:DockMargin(15, 15, 15, 15)
    
    local sbar = scroll:GetVBar()
    function sbar:Paint(w, h) end
    function sbar.btnUp:Paint(w, h) end
    function sbar.btnDown:Paint(w, h) end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(4, 4, 0, w - 8, h, Color(255, 255, 255, 50))
    end

    local header = vgui.Create("DPanel", scroll)
    header:Dock(TOP)
    header:SetTall(20)
    header:DockMargin(0, 0, 0, 10)

    header.Paint = function(self, w, h)
        local sideMargin = 250
        local barX = sideMargin
        local barW = w - (sideMargin * 2)
        local textY = h / 2
        
        draw.SimpleText("ПИНГ", "PT.3", sideMargin - 35, textY, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        draw.SimpleText("ГРУППА", "PT.3", barX + (barW * 0.22), textY, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("НИКНЕЙМ", "PT.3", barX + (barW * 0.52), textY, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("ЧАСЫ", "PT.3", barX + (barW * 0.85), textY, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local playersList = {}
    for _, ply in player.Iterator() do
        if not ply:GetNW2Bool("IsAnonim", false) then 
            table.insert(playersList, ply)
        end
    end

    local lp = LocalPlayer()
    local canSeeDead = (not lp:Alive()) or (lp:Team() == 1002)

    table.sort(playersList, function(a, b)
        local aSpec = a:Team() == 1002
        local bSpec = b:Team() == 1002
        
        if aSpec ~= bSpec then
            return not aSpec
        end
        
        if canSeeDead then
            local aAlive = a:Alive()
            local bAlive = b:Alive()
            
            if aAlive ~= bAlive then
                return aAlive
            end
        end
        
        return a:Nick() < b:Nick() 
    end)

    for _, ply in ipairs(playersList) do
        local plyContainer = CreatePlayerBar(scroll, ply, panel)
        plyContainer:Dock(TOP)
        plyContainer:DockMargin(0, 0, 0, 8)
    end

    return panel 
end)
