--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/cl_q8t9zm3g95xrx4h9k.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

if IsValid(customMenuPanel) then
    customMenuPanel:Remove()
    customMenuPanel = nil
    gui.HideGameUI()
end

local skipNextCustomMenu = false
local gradientMat = mh("zames/gu.png")
local gr = mh("zames/gr.png")
local blurMat = Material("pp/blurscreen")

local SETTINGS_FILE = "zames_settings.json"
local saved_settings = {}

local meme_text = {
    "GOMIGRAD1LOVE Навсегда с нами в сердце",
    "Именно из-за тебя он закрылся!",
    "Заходи, не бойся. Выходи, не плачь.",
    "GOMIGRAD RU SERVER #1 Homicide 30/30...",
    "Не выходи постой малыха, играй ДАЛЬШЕ!",
    "Baranjio - крутой чувак на сервере",
    "Всем привет с вами команда HOMIBURG",
    "Вот знаещь что с тобой будет, а ничего!",
    "Я чувствую на этом сервере казахскую жопу чьюту...",
    "COCAINE MODULE Loaded!",
    "Когда скины вернешь сука из гомиграда!",
    "Ты абдуроз?",
    "Asyan - Я считаю этим проектом новым сезоном гомиграда того самого..",
    "А я девочку маленькую сжег в печке (Квинси)"
}

local function LoadSettings()
    if file.Exists(SETTINGS_FILE, "DATA") then
        local data = file.Read(SETTINGS_FILE, "DATA")
        saved_settings = util.JSONToTable(data) or {}
    end
end
LoadSettings()

local function SaveSettings()
    file.Write(SETTINGS_FILE, util.TableToJSON(saved_settings, true))
end

local settings_categories = {
    {
        name = "Графика",
        icon = "zames/gamemodes.png",
        items = {
            { name = "Насыщенность", desc = "Делает игру более насыщенной", convar = "nasichenostb", type = "checkbox", warn = false},
        }
    },
    {
        name = "Геймплей",
        icon = "zames/season.png",
        items = {
            { name = "FOV Камеры", desc = "Меняет обзор камеры", convar = "zs_fov", type = "slider", min = 75, max = 120 },

            { name = "Марки в фейке", desc = "Включает во время фейка иконки рук", convar = "zs_fakehands", type = "checkbox"},

            { name = "Подсказки в игре", desc = "Включает случайные советы в чате каждые 120 секунд", convar = "zs_podskaski", type = "checkbox"}
        }
    }
}

local function CloseCustomMenu(callback)
    if IsValid(customMenuPanel) and not customMenuPanel.isClosing then
        customMenuPanel.isClosing = true
        
        if customMenuPanel.settingsOpen and IsValid(customMenuPanel.settingsPanel) then
            customMenuPanel.settingsPanel:MoveTo(ScrW(), 0, 0.2, 0, -1)
        end
        
        customMenuPanel:AlphaTo(0, 0.2, 0, function()
            if IsValid(customMenuPanel) then
                customMenuPanel:Remove()
                customMenuPanel = nil
            end
            if callback then callback() end
        end)
    else
        gui.HideGameUI()
        if callback then callback() end
    end
end

hook.Add("OnPauseMenuShow", "MyCustomPauseMenu", function()

    if skipNextCustomMenu then
        skipNextCustomMenu = false
        return 
    end

    if IsValid(customMenuPanel) then
        CloseCustomMenu()
        return false
    end

    customMenuPanel = vgui.Create("EditablePanel")
    customMenuPanel:SetSize(ScrW(), ScrH())
    customMenuPanel:MakePopup()
    customMenuPanel:SetKeyboardInputEnabled(true)

    customMenuPanel:SetAlpha(0)
    customMenuPanel:AlphaTo(255, 0.3)
    
    customMenuPanel.settingsOpen = false

    customMenuPanel.OnKeyCodePressed = function(self, key)
        if key == KEY_ESCAPE then
            CloseCustomMenu()
        end
    end

    customMenuPanel.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 220)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(156, 0, 0, 50)
        surface.SetMaterial(gradientMat)
        surface.DrawTexturedRect(0, 0, w, h)

        local x, y = self:LocalToScreen(0, 0)
            
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(blurMat)
        for i = 1, 2 do
            blurMat:SetFloat("$blur", (i / 3) * 6)
            blurMat:Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
        end
    end

    local settingsWidth = 700 
    local settingsPanel = vgui.Create("DPanel", customMenuPanel)
    settingsPanel:SetSize(settingsWidth, ScrH())
    settingsPanel:SetPos(ScrW(), 0) 
    settingsPanel.Paint = function(self, w, h)
        DisableClipping(true)
        
        surface.SetDrawColor(156, 0, 0, 190)
        surface.SetMaterial(gr)
        
        local leakWidth = 200
        surface.DrawTexturedRect(-leakWidth, 0, w + leakWidth, h)
        
        DisableClipping(false)
    end
    
    local settingsTitle = vgui.Create("DLabel", settingsPanel)
    settingsTitle:SetText("Настройки")
    settingsTitle:SetFont("PT.4")
    settingsTitle:SetTextColor(color_white)
    settingsTitle:SetPos(30, 30)
    settingsTitle:SizeToContents()

    customMenuPanel.settingsPanel = settingsPanel

    local scrollPanel = vgui.Create("DScrollPanel", settingsPanel)
    scrollPanel:SetPos(30, 100)
    scrollPanel:SetSize(settingsWidth - 60, ScrH() - 150)
    
    local sbar = scrollPanel:GetVBar()
    sbar.Paint = function() end
    sbar.btnUp.Paint = function() end
    sbar.btnDown.Paint = function() end
    sbar.btnGrip.Paint = function(self, w, h)
        surface.SetDrawColor(100, 100, 100, 150)
        surface.DrawRect(0, 0, w, h)
    end

    for _, catData in ipairs(settings_categories) do
        local catHeaderPnl = scrollPanel:Add("DPanel")
        catHeaderPnl:Dock(TOP)
        catHeaderPnl:DockMargin(0, 10, 0, 10)
        catHeaderPnl:SetTall(32)
        catHeaderPnl.Paint = function() end
        
        local catHeader = vgui.Create("DLabel", catHeaderPnl)
        catHeader:SetText(catData.name)
        catHeader:SetFont("PT.2")
        catHeader:SetTextColor(Color(255, 86, 86, 150))
        catHeader:SizeToContents()
        catHeader:SetPos(0, 16 - catHeader:GetTall() / 2)
        
        if catData.icon then
            local catIcon = vgui.Create("DImage", catHeaderPnl)
            catIcon:SetSize(32, 32)
            catIcon:SetPos(catHeader:GetWide() + 10, -2)
            catIcon:SetImage(catData.icon)
        end
        
        for _, setting in ipairs(catData.items) do
            local itemPnl = scrollPanel:Add("DButton")
            itemPnl:SetText("") 
            itemPnl:Dock(TOP)
            itemPnl:DockMargin(0, 0, 0, 5)
            itemPnl:SetTall(50)

            itemPnl.curTopMargin = 0
            itemPnl.curBottomMargin = 5

            itemPnl.OnCursorEntered = function(self)
                surface.PlaySound("zames/vgui/roller_02.wav")
                self:SizeTo(self:GetWide(), 65, 0.2, 0, -1)
            end

            itemPnl.OnCursorExited = function(self)
                self:SizeTo(self:GetWide(), 50, 0.2, 0, -1)
            end

            itemPnl.Think = function(self)
                local hov = vgui.GetHoveredPanel()
                local isHovered = self:IsHovered() or (IsValid(hov) and hov:HasParent(self))

                local targetTop = isHovered and 8 or 0
                local targetBottom = isHovered and 13 or 5

                self.curTopMargin = Lerp(FrameTime() * 12, self.curTopMargin, targetTop)
                self.curBottomMargin = Lerp(FrameTime() * 12, self.curBottomMargin, targetBottom)

                self:DockMargin(0, self.curTopMargin, 0, self.curBottomMargin)
            end

            itemPnl.Paint = function(self, w, h)
                local hov = vgui.GetHoveredPanel()
                local isHovered = self:IsHovered() or (IsValid(hov) and hov:HasParent(self))
                local alpha = isHovered and 150 or 100

                surface.SetDrawColor(82, 39, 39, alpha)
                surface.DrawRect(0, 0, w, h)

                surface.SetDrawColor(255, 255, 255, 20)
                surface.DrawLine(0, 0, w, 0)
                surface.DrawLine(0, 0, 0, h)
                
                surface.SetDrawColor(0, 0, 0, 200)
                surface.DrawLine(0, h-1, w, h-1)
                surface.DrawLine(w-1, 0, w-1, h)
            end

            local lbl = vgui.Create("DLabel", itemPnl)
            lbl:SetText(setting.name)
            lbl:SetFont("PT.3")
            lbl:SetPos(10, 8)
            lbl:SetTextColor(color_white)
            lbl:SizeToContents()

            local desc = vgui.Create("DLabel", itemPnl)
            desc:SetText(setting.desc)
            desc:SetPos(10, 25)
            desc:SetTextColor(Color(150, 150, 150))
            desc:SizeToContents()

            local dataKey = setting.command or setting.convar

            local controlX = 0
            if setting.type == "checkbox" then
                controlX = settingsWidth - 120
            elseif setting.type == "slider" then
                controlX = settingsWidth - 360
            end

            if setting.warn then
                local warnIcon = vgui.Create("DImage", itemPnl)
                warnIcon:SetPos(controlX - 42, 9) 
                warnIcon:SetSize(32, 32)
                warnIcon:SetImage("zames/warning.png") 

                warnIcon:SetMouseInputEnabled(true) 

                warnIcon:SetTooltip("Осторожно: изменение этого параметра может привести к зависанию игры!")
            end

            if setting.type == "checkbox" then
                local cb = vgui.Create("DCheckBox", itemPnl)
                cb:SetPos(controlX, 13)
                cb:SetSize(46, 24)
                
                if saved_settings[dataKey] ~= nil then
                    cb:SetValue(saved_settings[dataKey])
                else
                    local cv = GetConVar(dataKey)
                    cb:SetValue(cv and cv:GetBool() or false)
                end
                
                cb.animRatio = cb:GetChecked() and 1 or 0
                
                cb.Paint = function(self, w, h)
                    local target = self:GetChecked() and 1 or 0
                    self.animRatio = Lerp(FrameTime() * 15, self.animRatio, target)
                    
                    local r = Lerp(self.animRatio, 180, 20)
                    local g = Lerp(self.animRatio, 180, 220)
                    local b = Lerp(self.animRatio, 180, 20)
                    
                    draw.RoundedBox(h/2, 0, 0, w, h, Color(r, g, b))
                    
                    local knobSize = h - 4
                    local curX = Lerp(self.animRatio, 2, w - knobSize - 2)
                    draw.RoundedBox(knobSize/2, curX, 2, knobSize, knobSize, color_white)
                end

                cb.OnChange = function(self, bVal)
                    saved_settings[dataKey] = bVal
                    SaveSettings()
                    RunConsoleCommand(dataKey, bVal and "1" or "0")
                end

            elseif setting.type == "slider" then
                local sl = vgui.Create("DNumSlider", itemPnl)
                sl:SetPos(controlX, 5)
                sl:SetSize(300, 40)
                sl:SetText("") 
                sl:SetMinMax(setting.min or 0, setting.max or 100)
                sl:SetDecimals(0)
                
                if saved_settings[dataKey] ~= nil then
                    sl:SetValue(saved_settings[dataKey])
                else
                    local cv = GetConVar(dataKey)
                    sl:SetValue(cv and cv:GetFloat() or setting.min or 0)
                end
                
                sl.Slider.Paint = function(self, w, h)
                    local trackHeight = 10
                    local trackY = h / 2 - trackHeight / 2
                    draw.RoundedBox(trackHeight/2, 0, trackY, w, trackHeight, Color(235, 60, 30))
                end
                
                sl.Slider.Knob:SetSize(22, 22)
                
                sl.Slider.Knob.Paint = function(self, w, h)
                    draw.RoundedBox(w/2, 0, 0, w, h, Color(255, 220, 215))
                    draw.RoundedBox((w-8)/2, 4, 4, w-8, h-8, Color(235, 60, 30))
                end

                sl.OnValueChanged = function(self, val)
                    local finalVal = math.Round(val)
                    saved_settings[dataKey] = finalVal
                    SaveSettings()
                    RunConsoleCommand(dataKey, tostring(finalVal))
                end
            end
        end
    end

    local leftMargin = 50
    local centerY = ScrH() / 2

    local logo = vgui.Create("DImage", customMenuPanel)
    logo:SetSize(656, 256)
    logo:SetPos(leftMargin, centerY - 320)
    logo:SetMaterial(Material("zames/logo.png"))

    local randomMemeLabel = vgui.Create("DLabel", customMenuPanel)
    randomMemeLabel:SetText(meme_text[math.random(#meme_text)])
    randomMemeLabel:SetFont("PT.2")
    randomMemeLabel:SetTextColor(Color(255, 255, 255, 100))
    randomMemeLabel:SizeToContents()
    randomMemeLabel:SetPos(leftMargin + 20, centerY - 40)

    --[[local authorsLabel = vgui.Create("DLabel", customMenuPanel)
    authorsLabel:SetText("Авторы сборки - Asyan , Mr.Snake , Pantetoza , Homiburg , Homston , Gomigrad , Noriatako Twitch , QtuZOV , MKedonskie , Qtubezz, Maikrof")
    authorsLabel:SetFont("PT.2")
    authorsLabel:SetTextColor(Color(180, 180, 180, 150))
    authorsLabel:SizeToContents()
    authorsLabel:SetPos(leftMargin, ScrH() - authorsLabel:GetTall() - 20)--]]

    local function CreateMenuButton(textNormal, textUpper, yPos, onClick)
        local btn = vgui.Create("DButton", customMenuPanel)
        btn:SetText(textNormal)
        btn:SetFont("PT.4")
        btn:SetTextColor(color_white)
        btn:SetSize(450, 60)
        btn:SetPos(leftMargin, yPos)
        
        btn:SetContentAlignment(4)
        btn:SetTextInset(20, 0)
        
        btn.textLen = utf8.len(textNormal)
        btn.animIndex = 0
        btn.lastIndex = 0

        btn.Think = function(self)
            if self:IsHovered() then
                self.animIndex = math.Approach(self.animIndex, self.textLen, FrameTime() * 30)
                self:SetTextColor(Color(255, 50, 50))
            else
                self.animIndex = math.Approach(self.animIndex, 0, FrameTime() * 40)
                self:SetTextColor(color_white)
            end
            
            local i = math.floor(self.animIndex)
            
            if i ~= self.lastIndex then
                if self:IsHovered() and i > 0 then
                    surface.PlaySound("zames/vgui/roller_02.wav")
                end
                self.lastIndex = i
            end

            if i == 0 then
                self:SetText(textNormal)
            elseif i == self.textLen then
                self:SetText(textUpper)
            else
                local part1 = utf8.sub(textUpper, 1, i)
                local part2 = utf8.sub(textNormal, i + 1, self.textLen)
                self:SetText(part1 .. part2)
            end
        end

        btn.Paint = function(self, w, h)
            if self:IsHovered() then
                surface.SetDrawColor(70, 70, 70, 200)
            else
                surface.SetDrawColor(20, 20, 20, 200)
            end
        end
        btn.DoClick = onClick
        return btn
    end

    local server_list = {
        {
            ip = "5.42.211.79:24215",
            api_url = "https://api.gamemonitoring.ru/servers/13655683",
            name = "Загрузка данных...",
            map = "...",
            players = 0,
            maxplayers = 0
        }
        --[[
        ,{
            ip = "5.42.211.79:27015",
            api_url = "https://api.gamemonitoring.ru/servers/ТУТ_ID_ВТОРОГО_СЕРВЕРА",
            name = "Загрузка данных...",
            map = "...",
            players = 0,
            maxplayers = 0
        }
        ]]
    }

    local sl_width = 500
    local sl_height = 400
    local sl_x = ScrW() - sl_width - 100 
    local sl_y = (ScrH() / 2) - (sl_height / 2)

    local serverListContainer = vgui.Create("DPanel", customMenuPanel)
    serverListContainer:SetSize(sl_width, sl_height)
    serverListContainer:SetPos(sl_x, sl_y)
    serverListContainer.Paint = function(self, w, h)
        draw.SimpleText("By ElPistrun / Fire Angel", "PT.4", w/2, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end
    
    customMenuPanel.serverListContainer = serverListContainer

    local serverScroll = vgui.Create("DScrollPanel", serverListContainer)
    serverScroll:SetPos(0, 50)
    serverScroll:SetSize(sl_width, sl_height - 50)
    
    local sbar = serverScroll:GetVBar()
    sbar:SetWide(0) 

    local serverPanels = {}

    for _, srv in ipairs(server_list) do
        local pnl = serverScroll:Add("DPanel")
        pnl:Dock(TOP)
        pnl:DockMargin(0, 0, 0, 15)
        pnl:SetTall(70)

        pnl.srvName = srv.name
        pnl.srvMap = srv.map
        pnl.srvPlayers = srv.players
        pnl.srvMaxPlayers = srv.maxplayers

        pnl.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(63, 63, 63,150))

            surface.SetDrawColor(255, 255, 255, 20)
            surface.DrawLine(0, 0, w, 0)
            surface.DrawLine(0, 0, 0, h)
            
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawLine(0, h-1, w, h-1)
            surface.DrawLine(w-1, 0, w-1, h)
            
            draw.SimpleText(self.srvName, "PT.7", 15, 10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            
            surface.SetDrawColor(255, 255, 255, 200)
            surface.SetMaterial(mh("zames/mission.png"))
            surface.DrawTexturedRect(15, 40, 16, 16)
            draw.SimpleText(self.srvMap, "PT.3", 35, 40, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            
            surface.SetMaterial(mh("zames/users.png"))
            surface.DrawTexturedRect(w - 210, 40, 16, 16)
            draw.SimpleText(self.srvPlayers .. "/" .. self.srvMaxPlayers, "PT.3", w - 190, 40, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        local joinBtn = vgui.Create("DButton", pnl)
        joinBtn:SetSize(120, 70)
        joinBtn:SetPos(sl_width - 120, 0)
        joinBtn:SetText("Зайти")
        joinBtn:SetFont("PT.4")
        joinBtn:SetTextColor(color_white)
        joinBtn.Paint = function(self, w, h)
            if self:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, h, Color(170, 30, 30))
                surface.SetDrawColor(255, 255, 255, 20)
                surface.DrawLine(0, 0, w, 0)
                surface.DrawLine(0, 0, 0, h)
                
                surface.SetDrawColor(0, 0, 0, 200)
                surface.DrawLine(0, h-1, w, h-1)
                surface.DrawLine(w-1, 0, w-1, h)
            else
                draw.RoundedBox(0, 0, 0, w, h, Color(139, 26, 26))
                surface.SetDrawColor(255, 255, 255, 20)
                surface.DrawLine(0, 0, w, 0)
                surface.DrawLine(0, 0, 0, h)
                
                surface.SetDrawColor(0, 0, 0, 200)
                surface.DrawLine(0, h-1, w, h-1)
                surface.DrawLine(w-1, 0, w-1, h)
            end
        end
        joinBtn.DoClick = function()
            surface.PlaySound("zames/vgui/roller_02.wav")
            RunConsoleCommand("connect", srv.ip)
        end

        serverPanels[srv.ip] = pnl
    end

    for _, srv in ipairs(server_list) do
        if srv.api_url and srv.api_url ~= "" then
            http.Fetch(srv.api_url, function(body, len, headers, code)
                if code == 200 then
                    local data = util.JSONToTable(body)
                    if data and IsValid(customMenuPanel) then
                        local targetPanel = serverPanels[srv.ip]
                        
                        if IsValid(targetPanel) then
                            local sData = data.response or data

                            targetPanel.srvName = sData.name or srv.ip
                            targetPanel.srvMap = sData.map or "Unknown"
                            targetPanel.srvPlayers = sData.numplayers or 0
                            targetPanel.srvMaxPlayers = sData.maxplayers or 0
                        end
                    end
                end
            end, function(errorMsg)
                print("Ошибка загрузки данных API сервера " .. srv.ip .. ": " .. errorMsg)
                local targetPanel = serverPanels[srv.ip]
                if IsValid(targetPanel) then
                    targetPanel.srvName = "Ошибка загрузки (API)"
                end
            end)
        end
    end

    local buttonSpacing = 50

    CreateMenuButton("Продолжить", "ПРОДОЛЖИТЬ", centerY, function()
        surface.PlaySound("zames/vgui/roller_02.wav")
        CloseCustomMenu()
    end)

    CreateMenuButton("Настройки", "НАСТРОЙКИ", centerY + buttonSpacing, function()
        surface.PlaySound("zames/vgui/roller_02.wav")
        
        if customMenuPanel.settingsOpen then
            settingsPanel:MoveTo(ScrW(), 0, 0.3, 0, -1)
            if IsValid(customMenuPanel.serverListContainer) then
                customMenuPanel.serverListContainer:MoveTo(sl_x, sl_y, 0.3, 0, -1)
            end
            customMenuPanel.settingsOpen = false
        else
            settingsPanel:MoveTo(ScrW() - settingsWidth, 0, 0.3, 0, -1)
            if IsValid(customMenuPanel.serverListContainer) then
                customMenuPanel.serverListContainer:MoveTo(ScrW(), sl_y, 0.3, 0, -1)
            end
            customMenuPanel.settingsOpen = true
        end
    end)

    CreateMenuButton("Правила сервера", "ПРАВИЛА СЕРВЕРА", centerY + (buttonSpacing * 2), function()
        surface.PlaySound("zames/vgui/roller_02.wav")
        gui.OpenURL("https://clck.ru/3VeYt8")
    end)

    CreateMenuButton("Cтарое меню", "СТАРОЕ МЕНЮ", centerY + (buttonSpacing * 4), function()
        surface.PlaySound("zames/vgui/roller_02.wav")
        CloseCustomMenu()
        skipNextCustomMenu = true 
        gui.ActivateGameUI()
    end)

    CreateMenuButton("Выйти", "ВЫЙТИ", centerY + (buttonSpacing * 5), function()
        surface.PlaySound("zames/vgui/roller_02.wav")
        RunConsoleCommand("disconnect")
    end)

    local iconSize = 128
    local iconSpacing = 20
    
    local startX = leftMargin 
    local startY = ScrH() - iconSize - 40

    local function CreateSocialIconButton(matPath, url, xPos)
        local btn = vgui.Create("DButton", customMenuPanel)
        btn:SetSize(iconSize, iconSize)
        btn:SetPos(xPos, startY)
        btn:SetText("")
        
        local iconMat = Material(matPath, "noclamp smooth") 

        btn.Paint = function(self, w, h)
            if self:IsHovered() then
                surface.SetDrawColor(255, 255, 255, 255)
            else
                surface.SetDrawColor(200, 200, 200, 180)
            end
            
            surface.SetMaterial(iconMat)
            surface.DrawTexturedRect(0, 0, w, h)
        end
        
        btn.DoClick = function()
            surface.PlaySound("zames/vgui/roller_02.wav") 
            gui.OpenURL(url)
        end
    end

    CreateSocialIconButton("zames/yt.png", "https://www.youtube.com/@zamesrf", startX)
    CreateSocialIconButton("zames/tk.png", "https://tiktok.com/@zamesrf", startX + iconSize + iconSpacing)
    CreateSocialIconButton("zames/ds.png", "https://discord.gg/qqtvS5jfRs", startX + (iconSize + iconSpacing) * 2)

    return false
end)
