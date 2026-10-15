--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/1rg9gd2wb6xh5xr8fw2wb4kx6xh2vt_9vn4kx6ql5xr1rg/cl_s85xrp93kh_m1s2mz5tq8.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

RegisterScoreboardPage("Team_Page", function(parentPanel)
    local panel = vgui.Create("DPanel", parentPanel)
    panel:SetSize(ScrW() * 0.6, ScrH() * 1) 
    panel:Center()

    panel.Paint = function(self, w, h)
    end

    local btnW, btnH = 400, 900
    local gap = 30 
    local animTime = 0.1
    local shrinkAmount = 20
    local hoverAmount = 20

    local btnContainer = vgui.Create("DPanel", panel)
    btnContainer:SetSize(btnW * 2 + gap, btnH)
    btnContainer:Center()
    btnContainer.Paint = function() end 

    -- (Игроки)
    local button1 = vgui.Create("DButton", btnContainer)
    button1:SetPos(0, 0)
    button1:SetSize(btnW, btnH)
    button1:SetText("")

    local mdl1 = vgui.Create("DModelPanel", button1)
    mdl1:Dock(FILL)
    mdl1:SetModel(table.Random(hmcd.Models))
    mdl1:SetMouseInputEnabled(false) 
    mdl1:SetFOV(25)
    mdl1:SetCamPos(Vector(90, 0, 40))
    mdl1:SetLookAt(Vector(0, 0, 40))

    mdl1.NextUpdate = CurTime() + 0.3
    mdl1.Think = function(self)
        if CurTime() >= self.NextUpdate then
            self.NextUpdate = CurTime() + 0.3

            if hmcd and hmcd.Models then
                local randomMdl = table.Random(hmcd.Models)
                if randomMdl then
                    self:SetModel(randomMdl)
                end
            end

            local ent = self:GetEntity()
            if IsValid(ent) then
                local rColor = Vector(math.random(1,255) / 255, math.random(1,255) / 255, math.random(1,255) / 255)
                
                ent.GetPlayerColor = function() return rColor end 
                
                if ent.SetPlayerColor then
                    ent:SetPlayerColor(rColor)
                end
            end
        end
    end

    local oldMdl1Paint = mdl1.Paint
    mdl1.Paint = function(self, w, h)
        DisableClipping(true)
        oldMdl1Paint(self, w, h)
        DisableClipping(false)
    end

    button1.Paint = function(self, w, h)
        DisableClipping(true)

        draw.RoundedBox(0, 0, 0, w, h, Color(70, 70, 70, 100))

        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawLine(0, 0, w, 0)
        surface.DrawLine(0, 0, 0, h)
        
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawLine(0, h-1, w, h-1)
        surface.DrawLine(w-1, 0, w-1, h)
        draw.SimpleText("Игроки", "PT.6", w/2, 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        DisableClipping(false)
    end

    button1.OnCursorEntered = function(self)
        surface.PlaySound("zames/vgui/roller_02.wav")
        if self.IsAnimating then return end
        self:SizeTo(btnW + hoverAmount, btnH + hoverAmount, animTime, 0, -1)
        self:MoveTo(-(hoverAmount / 2), -(hoverAmount / 2), animTime, 0, -1)
    end

    button1.OnCursorExited = function(self)
        if self.IsAnimating then return end
        self:SizeTo(btnW, btnH, animTime, 0, -1)
        self:MoveTo(0, 0, animTime, 0, -1)
    end

    button1.DoClick = function(self)
        surface.PlaySound("zames/vgui/click1.wav")
        if self.IsAnimating then return end
        self.IsAnimating = true

        local origX, origY = 0, 0
        local shrinkW, shrinkH = btnW - shrinkAmount, btnH - shrinkAmount
        local shrinkX, shrinkY = origX + (shrinkAmount / 2), origY + (shrinkAmount / 2)

        net.Start("net_ch_team")
            net.WriteInt(1, 16)
        net.SendToServer()

        self:SizeTo(shrinkW, shrinkH, animTime, 0, -1, function()
            if IsValid(self) then
                self:SizeTo(btnW, btnH, animTime, 0, -1, function()
                    if IsValid(parentPanel) then parentPanel:Remove() end
                end)
                self:MoveTo(origX, origY, animTime, 0, -1)
            end
        end)
        self:MoveTo(shrinkX, shrinkY, animTime, 0, -1)
    end

    -- (Наблюдатель)
    local button2 = vgui.Create("DButton", btnContainer)
    button2:SetPos(btnW + gap, 0) 
    button2:SetSize(btnW, btnH)
    button2:SetText("")

    local mdl2 = vgui.Create("DModelPanel", button2)
    mdl2:Dock(FILL)
    mdl2:SetModel("models/player/gman_high.mdl")
    mdl2:SetMouseInputEnabled(false)
    mdl2:SetFOV(25)
    mdl2:SetCamPos(Vector(90, 0, 40))
    mdl2:SetLookAt(Vector(0, 0, 40))

    local oldMdl2Paint = mdl2.Paint
    mdl2.Paint = function(self, w, h)
        DisableClipping(true)
        oldMdl2Paint(self, w, h)
        DisableClipping(false)
    end

    button2.Paint = function(self, w, h)
        DisableClipping(true)

        draw.RoundedBox(0, 0, 0, w, h, Color(70, 70, 70, 100))

        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawLine(0, 0, w, 0)
        surface.DrawLine(0, 0, 0, h)
        
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawLine(0, h-1, w, h-1)
        surface.DrawLine(w-1, 0, w-1, h)
        draw.SimpleText("Наблюдатель", "PT.6", w/2, 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        DisableClipping(false)
    end

    button2.OnCursorEntered = function(self)
        surface.PlaySound("zames/vgui/roller_02.wav")
        if self.IsAnimating then return end
        self:SizeTo(btnW + hoverAmount, btnH + hoverAmount, animTime, 0, -1)
        self:MoveTo(btnW + gap - (hoverAmount / 2), -(hoverAmount / 2), animTime, 0, -1)
    end

    button2.OnCursorExited = function(self)
        if self.IsAnimating then return end
        self:SizeTo(btnW, btnH, animTime, 0, -1)
        self:MoveTo(btnW + gap, 0, animTime, 0, -1)
    end

    button2.DoClick = function(self)
        surface.PlaySound("zames/vgui/click1.wav")
        if self.IsAnimating then return end
        self.IsAnimating = true

        local origX, origY = btnW + gap, 0
        local shrinkW, shrinkH = btnW - shrinkAmount, btnH - shrinkAmount
        local shrinkX, shrinkY = origX + (shrinkAmount / 2), origY + (shrinkAmount / 2)

        net.Start("net_ch_team")
            net.WriteInt(1002, 16)
        net.SendToServer()

        self:SizeTo(shrinkW, shrinkH, animTime, 0, -1, function()
            if IsValid(self) then
                self:SizeTo(btnW, btnH, animTime, 0, -1, function()
                    if IsValid(parentPanel) then parentPanel:Remove() end
                end)
                self:MoveTo(origX, origY, animTime, 0, -1)
            end
        end)
        self:MoveTo(shrinkX, shrinkY, animTime, 0, -1)
    end

    return panel 
end)
