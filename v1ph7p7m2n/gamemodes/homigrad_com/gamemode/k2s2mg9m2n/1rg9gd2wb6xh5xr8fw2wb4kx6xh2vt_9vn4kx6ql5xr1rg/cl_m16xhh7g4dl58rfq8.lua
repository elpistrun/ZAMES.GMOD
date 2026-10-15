--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/1rg9gd2wb6xh5xr8fw2wb4kx6xh2vt_9vn4kx6ql5xr1rg/cl_m16xhh7g4dl58rfq8.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

surface.CreateFont("Profile_Nick", { font = "Roboto", size = 42, weight = 1000 })
surface.CreateFont("Profile_Title", { font = "Roboto", size = 22, weight = 500 })
surface.CreateFont("Profile_Text", { font = "Roboto", size = 22, weight = 200 })
surface.CreateFont("Profile_Label", { font = "Roboto", size = 22, weight = 500 })

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

local function CreateNavCategory(parent, title, subCats, categoryColor) -- добавили categoryColor
    local categoryContainer = vgui.Create("DPanel", parent)
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

        -- Если передан цвет категории, используем его с учетом прозрачности hover, иначе стандартный серый
        local btnBgColor = categoryColor and Color(categoryColor.r, categoryColor.g, categoryColor.b, bgAlpha) or Color(165, 164, 164, bgAlpha)
        draw.RoundedBox(0, margin, margin, w - (margin * 2), h - (margin * 2), btnBgColor) 
        
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
            if sub.action then
                sub.action()
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

local function OpenProfileCustomization(parent, ply)
    local title = vgui.Create("DLabel", parent)
    title:SetText("Кастомизация")
    title:SetFont("Profile_Title")
    title:SizeToContents()
    title:SetPos(50, 40)

    local voicePreview = CreateVoicePlayerBar(parent, ply, parent)
    voicePreview:SetPos(50, 70)

    local tabPreview = CreatePlayerBar(parent, ply, parent, true)
    tabPreview:SetPos(320, 70) 
    tabPreview:SetSize(560, 80) 

    local colorMixer = vgui.Create("DColorMixer", parent)
    colorMixer:SetSize(200, 150)
    colorMixer:SetPos(925, 70) 
    colorMixer:SetPalette(false)
    colorMixer:SetAlphaBar(false) 
    colorMixer:SetWangs(true)
    
    local curColorVec = ply:GetNWVector("FigColor", Vector(255, 255, 255))
    colorMixer:SetColor(Color(curColorVec.x, curColorVec.y, curColorVec.z))

    colorMixer.ValueChanged = function(self, col)
        timer.Create("UpdateFigColorSpamCheck", 0.3, 1, function()
            net.Start("ApplyFigureColor")
            net.WriteColor(col)
            net.SendToServer()
        end)
    end

    local navContainer = vgui.Create("DScrollPanel", parent)
    navContainer:SetSize(250, parent:GetTall() - 170)
    navContainer:SetPos(50, 160)

    local sbar = navContainer:GetVBar()
    function sbar:Paint(w, h) end
    function sbar.btnUp:Paint(w, h) end
    function sbar.btnDown:Paint(w, h) end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(4, 4, 0, w - 8, h, Color(255, 255, 255, 50))
    end

    local inv = ply.Inventory or {}

    -- ФИГУРЫ ВОЙСА
    local figureItems = {
        { name = "По умолчанию", action = function()
            net.Start("ApplyCustomization")
            net.WriteString("reset")
            net.WriteString("figure") 
            net.SendToServer()
        end }
    }
    for itemName, amount in pairs(inv) do
        if figura and figura.ShopItems and figura.ShopItems[itemName] then
            table.insert(figureItems, {
                name = itemName .. " (x" .. amount .. ")",
                action = function()
                    net.Start("ApplyCustomization")
                    net.WriteString(itemName)
                    net.WriteString("figure") 
                    net.SendToServer()
                end
            })
        end
    end

    -- ФОНЫ ВОЙСА
    local bgItems = {
        { name = "По умолчанию", action = function()
            net.Start("ApplyCustomization")
            net.WriteString("reset")
            net.WriteString("bg") 
            net.SendToServer()
        end }
    }
    for itemName, amount in pairs(inv) do
        if ramka and ramka.ShopItems and ramka.ShopItems[itemName] then
            table.insert(bgItems, {
                name = itemName .. " (x" .. amount .. ")",
                action = function()
                    net.Start("ApplyCustomization")
                    net.WriteString(itemName)
                    net.WriteString("bg") 
                    net.SendToServer()
                end
            })
        end
    end

    -- ФОНЫ ТАБ ПАНЕЛИ
    local tabItems = {
        { name = "По умолчанию", action = function()
            net.Start("ApplyCustomization")
            net.WriteString("reset")
            net.WriteString("tab") 
            net.SendToServer()
        end }
    }
    for itemName, amount in pairs(inv) do
        if ramka_tab and ramka_tab.ShopItems and ramka_tab.ShopItems[itemName] then
            table.insert(tabItems, {
                name = itemName .. " (x" .. amount .. ")",
                action = function()
                    net.Start("ApplyCustomization")
                    net.WriteString(itemName)
                    net.WriteString("tab") 
                    net.SendToServer()
                end
            })
        end
    end

    CreateNavCategory(navContainer, "Выбрать фигуру", figureItems)
    CreateNavCategory(navContainer, "Фон войса", bgItems)
    CreateNavCategory(navContainer, "Фон таба", tabItems)
end

local function OpenSkinCustomization(parent, ply)
    local title = vgui.Create("DLabel", parent)
    title:SetText("Скины")
    title:SetFont("Profile_Title")
    title:SizeToContents()
    title:SetPos(50, 40)

    local navContainer = vgui.Create("DScrollPanel", parent)
    navContainer:SetSize(250, parent:GetTall() - 100)
    navContainer:SetPos(50, 80) 

    local sbar = navContainer:GetVBar()
    function sbar:Paint(w, h) end
    function sbar.btnUp:Paint(w, h) end
    function sbar.btnDown:Paint(w, h) end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(4, 4, 0, w - 8, h, Color(255, 255, 255, 50))
    end

    local preview = vgui.Create("DModelPanel", parent)
    preview:SetSize(parent:GetWide() - 320, parent:GetTall()) 
    preview:SetPos(530, 0)
    preview:SetModel(ply:GetModel())

    for i = 0, ply:GetNumBodyGroups() - 1 do
        preview.Entity:SetBodygroup(i, ply:GetBodygroup(i))
    end
    
    preview:SetFOV(45)
    preview:SetCamPos(Vector(110, 0, 36)) 
    preview:SetLookAt(Vector(0, 0, 36))   
    
    preview.LayoutEntity = function(self, ent)
        ent:SetAngles(Angle(0, 0, 0)) 
        self:RunAnimation()           
    end

    local bgContainer = vgui.Create("DScrollPanel", parent)
    bgContainer:SetSize(200, parent:GetTall() - 100)
    bgContainer:SetPos(500, 80)
    
    local sbarBG = bgContainer:GetVBar()
    function sbarBG:Paint(w, h) end
    function sbarBG.btnUp:Paint(w, h) end
    function sbarBG.btnDown:Paint(w, h) end
    function sbarBG.btnGrip:Paint(w, h)
        draw.RoundedBox(4, 4, 0, w - 8, h, Color(255, 255, 255, 50))
    end

    local function RefreshBodygroups()
        bgContainer:Clear()
        
        if not IsValid(preview.Entity) then return end
        
        local skinCount = preview.Entity:SkinCount()
        if skinCount > 1 then
            local skinSlider = vgui.Create("DNumSlider", bgContainer)
            skinSlider:Dock(TOP)
            skinSlider:DockMargin(0, 5, 0, 10)
            skinSlider:SetText("Скин")
            skinSlider:SetMin(0)
            skinSlider:SetMax(skinCount - 1)
            skinSlider:SetDecimals(0)
            skinSlider:SetValue(preview.Entity:GetSkin())
            
            skinSlider.Label:SetFont("Profile_Text") 
            skinSlider.Label:SetTextColor(Color(255, 255, 255))
            
            skinSlider.OnValueChanged = function(self, value)
                local val = math.Round(value)
                if IsValid(preview.Entity) then
                    preview.Entity:SetSkin(val)
                end
                
                net.Start("ApplySkinMaterial")
                net.WriteInt(val, 8)
                net.SendToServer()
            end
        end

        local numBG = preview.Entity:GetNumBodyGroups()
        
        for i = 0, numBG - 1 do
            local bgCount = preview.Entity:GetBodygroupCount(i)
            
            if bgCount <= 1 then continue end 
            
            local bgName = preview.Entity:GetBodygroupName(i)
            local formattedName = bgName and (bgName:sub(1,1):upper() .. bgName:sub(2)) or "Часть " .. i
            
            local bgSlider = vgui.Create("DNumSlider", bgContainer)
            bgSlider:Dock(TOP)
            bgSlider:DockMargin(0, 5, 0, 10)
            bgSlider:SetText(formattedName)
            bgSlider:SetMin(0)
            bgSlider:SetMax(bgCount - 1)
            bgSlider:SetDecimals(0)
            bgSlider:SetValue(preview.Entity:GetBodygroup(i))
            
            bgSlider.Label:SetFont("Profile_Text")
            bgSlider.Label:SetTextColor(Color(255, 255, 255))
            
            bgSlider.OnValueChanged = function(self, value)
                local val = math.Round(value)
                if IsValid(preview.Entity) then
                    preview.Entity:SetBodygroup(i, val)
                end
                
                net.Start("ApplySkinBodygroup")
                net.WriteInt(i, 8)
                net.WriteInt(val, 8)
                net.SendToServer()
            end
        end
    end

    timer.Simple(0.1, function()
        if IsValid(bgContainer) then RefreshBodygroups() end
    end)

    local inv = ply.Inventory or {}
    local personalList = {}
    local filmsList = {}
    local gamesList = {}
    local animeList = {}
    local memeList = {}

    local resetData = {
        name = "Снять скин",
        action = function()
            net.Start("ApplySkinCustomization")
            net.WriteString("reset")
            net.WriteString("")
            net.SendToServer()
            preview:SetModel("models/player/Group01/male_01.mdl") 
            RefreshBodygroups()
        end
    }
    table.insert(personalList, resetData)
    table.insert(filmsList, resetData)
    table.insert(gamesList, resetData)
    table.insert(animeList, resetData)
    table.insert(memeList, resetData)

    for itemName, amount in pairs(inv) do
        if amount <= 0 then continue end

        local function TryAddSkin(shopTable, targetList)
            if shopTable and shopTable[itemName] and shopTable[itemName].model then
                table.insert(targetList, {
                    name = itemName .. " (x" .. amount .. ")",
                    action = function()
                        local mdl = shopTable[itemName].model
                        preview:SetModel(mdl) 

                        if preview:GetModel() ~= mdl then
                            preview:SetModel(mdl)
                        end

                        RefreshBodygroups()
                        
                        net.Start("ApplySkinCustomization")
                        net.WriteString(itemName)
                        net.WriteString(mdl)
                        net.SendToServer()
                    end
                })
                return true
            end
            return false
        end

        if not TryAddSkin(personal.ShopItems, personalList) then
            if not TryAddSkin(film.ShopItems, filmsList) then
                if not TryAddSkin(games.ShopItems, gamesList) then
                    if not TryAddSkin(anime.ShopItems, animeList) then
                        TryAddSkin(meme.ShopItems, memeList)
                    end
                end
            end
        end
    end

    CreateNavCategory(navContainer, "Персональные", personalList, Color(112, 226, 255, 100))
    CreateNavCategory(navContainer, "Из фильмов", filmsList)
    CreateNavCategory(navContainer, "Из игр", gamesList)
    CreateNavCategory(navContainer, "Из мультиков", animeList)
    CreateNavCategory(navContainer, "Из мемов", memeList)
end

function CreateProfileWindow(parentPanel, targetData, isOverlay)
    if not targetData then return end

    if type(targetData) ~= "table" and IsValid(targetData) and targetData:IsPlayer() then
        targetData = {
            Nick = targetData:Nick(),
            SteamID = targetData:SteamID(),
            SteamID64 = targetData:SteamID64(),
            Playtime = targetData.GetPlayTimeSeconds and targetData:GetPlayTimeSeconds() or 0,
            FirstJoin = targetData.GetFirstJoinDate and targetData:GetFirstJoinDate() or "Неизвестно",
            UserGroup = targetData:GetUserGroup(),
            Entity = targetData 
        }
    end

    targetData.Nick = targetData.Nick or "Неизвестно"
    targetData.SteamID = targetData.SteamID or "BOT"
    targetData.SteamID64 = targetData.SteamID64 or "0"
    targetData.UserGroup = targetData.UserGroup or "user"
    targetData.Playtime = tonumber(targetData.Playtime) or 0
    targetData.FirstJoin = targetData.FirstJoin or "Неизвестно"


    local panel = vgui.Create("DPanel", parentPanel)
    panel:SetSize(ScrW() * 0.6, ScrH() * 0.7) 
    panel:Center()
    panel.IsCustomizing = false

    local avatarX, avatarY = 50, 50
    local sectionY = avatarY + 128 + 40
    local lineY = sectionY + 30
    local infoY = lineY + 20
    local idsY = infoY + 120

    panel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(53, 53, 53, 160))

        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawLine(0, 0, w, 0)
        surface.DrawLine(0, 0, 0, h)
        
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawLine(0, h-1, w, h-1)
        surface.DrawLine(w-1, 0, w-1, h)

        if not self.IsCustomizing then
            draw.SimpleText(targetData.Nick, "PT.4", avatarX + 150, avatarY + 20, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText("ТЕКУЩАЯ ИНФОРМАЦИЯ О ИГРОКЕ:", "PT.2", 50, sectionY - 5, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.RoundedBox(0, 50, lineY, w - 100, 2, Color(150, 150, 150, 100))
            
            draw.SimpleText("Регистрация на сервере:", "PT.6", 50, infoY, Color(180, 180, 180), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(targetData.FirstJoin, "PT.2", 50 + 260, infoY - 1, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            
            draw.SimpleText("Сколько часов на сервере:", "PT.6", 50, infoY + 35, Color(180, 180, 180), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            local hoursText = string.format("%.1fh", targetData.Playtime / 3600)
            draw.SimpleText(hoursText, "PT.2", 50 + 260, infoY + 34, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            
            draw.SimpleText("Привилегия игрока:", "PT.6", 50, infoY + 70, Color(180, 180, 180), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            local groupData = valid[targetData.UserGroup]
            local displayName = groupData and groupData.name or string.upper(targetData.UserGroup)
            local groupColor = groupData and groupData.color or Color(255, 255, 255)
            
            draw.SimpleText(displayName, "PT.6", 50 + 260, infoY + 69, groupColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            draw.SimpleText("STEAMID", "PT.6", 50, idsY, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(targetData.SteamID, "PT.2", 50, idsY + 25, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            draw.SimpleText("STEAMID64", "PT.6", 50 + 260, idsY, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(targetData.SteamID64, "PT.2", 50 + 260, idsY + 25, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
    end

    local avatar = vgui.Create("AvatarImagePlus", panel)
    avatar:SetSize(128, 128)
    avatar:SetPos(50, 50)
    avatar:SetSteamID(targetData.SteamID64, 128)

    surface.SetFont("Profile_Nick")
    local nickWidth, nickHeight = surface.GetTextSize(targetData.Nick)
    local nickBtnY = avatarY + 15 + (nickHeight / 2) - 16
    local nickBtnX = avatarX + 150 + nickWidth + 15

    local copyNickBtn = vgui.Create("DImageButton", panel)
    copyNickBtn:SetSize(20, 20)
    copyNickBtn:SetPos(nickBtnX, nickBtnY + 10)
    copyNickBtn:SetImage("zames/window_halfopen.png")
    copyNickBtn.DoClick = function()
        surface.PlaySound("zames/vgui/click.wav")
        SetClipboardText(targetData.Nick)
    end

    local steamBtn = vgui.Create("DImageButton", panel)
    steamBtn:SetSize(32, 32)
    steamBtn:SetPos(nickBtnX + 32 + 10, nickBtnY)
    steamBtn:SetImage("zames/steam.png")
    steamBtn.DoClick = function()
        surface.PlaySound("zames/vgui/click.wav")
        gui.OpenURL("https://steamcommunity.com/profiles/" .. targetData.SteamID64)
    end

    surface.SetFont("Profile_Text")
    local steamIdWidth, steamIdHeight = surface.GetTextSize(targetData.SteamID)
    local steamId64Width, steamId64Height = surface.GetTextSize(targetData.SteamID64)
    local textY = idsY + 25 
    
    local copySidBtn = vgui.Create("DImageButton", panel)
    copySidBtn:SetSize(20, 20)
    copySidBtn:SetPos(50 + steamIdWidth + 30, textY + (steamIdHeight / 2) - 10)
    copySidBtn:SetImage("zames/window_halfopen.png")
    copySidBtn.DoClick = function()
        surface.PlaySound("zames/vgui/click.wav")
        SetClipboardText(targetData.SteamID)
    end

    local copySid64Btn = vgui.Create("DImageButton", panel)
    copySid64Btn:SetSize(20, 20)
    copySid64Btn:SetPos(50 + 260 + steamId64Width + 15, textY + (steamId64Height / 2) - 10)
    copySid64Btn:SetImage("zames/window_halfopen.png")
    copySid64Btn.DoClick = function()
        surface.PlaySound("zames/vgui/click.wav")
        SetClipboardText(targetData.SteamID64)
    end

    if not isOverlay and IsValid(targetData.Entity) then
        
        local skinBtn = vgui.Create("DImageButton", panel)
        skinBtn:SetSize(32, 32)
        skinBtn:SetPos(panel:GetWide() - (isOverlay and 150 or 90), 15) 
        skinBtn:SetImage("zames/shirt.png") 
        skinBtn.DoClick = function()
            surface.PlaySound("zames/vgui/click.wav")
            
            panel.IsCustomizing = true
            
            for _, child in ipairs(panel:GetChildren()) do
                if child.IsCloseBtn then continue end
                child:Remove()
            end
            
            OpenSkinCustomization(panel, targetData.Entity)
        end

        local settingsBtn = vgui.Create("DImageButton", panel)
        settingsBtn:SetSize(32, 32)
        settingsBtn:SetPos(panel:GetWide() - (isOverlay and 110 or 50), 15)
        settingsBtn:SetImage("zames/settings.png")
        settingsBtn.DoClick = function()
            surface.PlaySound("zames/vgui/click.wav")
            
            panel.IsCustomizing = true
            
            for _, child in ipairs(panel:GetChildren()) do
                if child.IsCloseBtn then continue end
                child:Remove()
            end
            
            OpenProfileCustomization(panel, targetData.Entity)
        end
    end

    if isOverlay then
        local closeBtn = vgui.Create("DImageButton", panel)
        closeBtn:SetSize(64, 64)
        closeBtn:SetPos(panel:GetWide() - 64 - 15, 15) 
        closeBtn.IsCloseBtn = true
        closeBtn.Paint = function(self, w, h)
            draw.SimpleText("X", "Profile_Title", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        closeBtn.DoClick = function()
            surface.PlaySound("zames/vgui/click.wav")
            panel:Remove()
        end
    end

    return panel 
end

RegisterScoreboardPage("Profile_Page", function(parentPanel)
    return CreateProfileWindow(parentPanel, LocalPlayer(), false)
end)
