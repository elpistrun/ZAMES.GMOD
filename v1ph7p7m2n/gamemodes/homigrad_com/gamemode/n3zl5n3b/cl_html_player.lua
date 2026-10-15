--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/n3zl5n3b/cl_html_player.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:25
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

local PANEL = {}

AvatarImagePlus_DataCache = AvatarImagePlus_DataCache or {}
AvatarImagePlus_HTMLPool = AvatarImagePlus_HTMLPool or {}

if not IsValid(AvatarImagePlus_HiddenContainer) then
    AvatarImagePlus_HiddenContainer = vgui.Create("DPanel")
    AvatarImagePlus_HiddenContainer:SetVisible(false)
end

function PANEL:Init()
    self:SetPaintBackground(false)
    
    self.Avatar = vgui.Create("AvatarImage", self)
    
    self.HTMLTemplate = [[
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {
                    margin: 0;
                    padding: 0;
                    overflow: hidden;
                    background-color: transparent;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 100vh;
                    width: 100vw;
                }
                .frame {
                    position: absolute;
                    width: 100%%;
                    height: 100%%;
                    z-index: 2;
                    pointer-events: none; 
                }
            </style>
        </head>
        <body>
            %s
        </body>
        </html>
    ]]
end

local function CreateMediaTag(url, className)
    if not url or url == "" then return "" end
    
    local cleanUrl = url 

    if string.EndsWith(url, ".mp4") or string.EndsWith(url, ".webm") then
        return string.format([[<video class="%s" src="%s" autoplay loop muted playsinline></video>]], className, cleanUrl)
    else
        return string.format([[<img class="%s" src="%s">]], className, cleanUrl)
    end
end

local function GetAccountIDFrom64(steamID64)
    local steamID = util.SteamIDFrom64(steamID64)
    if not steamID then return nil end
    local split = string.Explode(":", steamID)
    if #split == 3 then
        local y = tonumber(split[2]) or 0
        local z = tonumber(split[3]) or 0
        return tostring(z * 2 + y)
    end
    return nil
end

function PANEL:SetPlayer(ply, size)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    self.Avatar:SetPlayer(ply, size or 64)
    self:SetSteamID64(ply:SteamID64())
end

function PANEL:SetSteamID(steamID64, size)
    self.Avatar:SetSteamID(steamID64, size or 64)
    self:SetSteamID64(steamID64)
end

function PANEL:SetSteamID64(steamID64)
    if self.CurrentSteamID == steamID64 then return end
    self.CurrentSteamID = steamID64

    self:ReturnHTMLToPool()

    if AvatarImagePlus_DataCache[steamID64] then
        self:ProcessMiniprofileData(AvatarImagePlus_DataCache[steamID64].data, steamID64)
        return
    end

    local accountID = GetAccountIDFrom64(steamID64)
    self:FetchSteamData(steamID64, accountID)
end

function PANEL:SetupHTMLPanel()
    if IsValid(self.InnerHTML) then return self.InnerHTML end

    local steamID64 = self.CurrentSteamID
    AvatarImagePlus_HTMLPool[steamID64] = AvatarImagePlus_HTMLPool[steamID64] or {}
    
    local htmlPanel = nil

    for _, pnl in ipairs(AvatarImagePlus_HTMLPool[steamID64]) do
        if not pnl.InUse and IsValid(pnl) then
            pnl.InUse = true
            htmlPanel = pnl
            break
        end
    end

    if not IsValid(htmlPanel) then
        htmlPanel = vgui.Create("DHTML", AvatarImagePlus_HiddenContainer)
        htmlPanel:SetAllowLua(false)
        htmlPanel:SetScrollbars(false)
        htmlPanel.InUse = true
        table.insert(AvatarImagePlus_HTMLPool[steamID64], htmlPanel)
    end

    self.InnerHTML = htmlPanel
    htmlPanel:SetParent(self)
    htmlPanel:MoveToFront()
    htmlPanel:SetVisible(true)
    
    self:InvalidateLayout()

    return htmlPanel
end

function PANEL:ReturnHTMLToPool()
    if IsValid(self.InnerHTML) then
        self.InnerHTML.InUse = false
        self.InnerHTML:SetParent(AvatarImagePlus_HiddenContainer)
        self.InnerHTML = nil
    end
end

function PANEL:OnRemove()
    self:ReturnHTMLToPool()
end

function PANEL:ProcessMiniprofileData(data, steamID64)
    local frameURL = ""
    if data and data.avatar_frame then
        if type(data.avatar_frame) == "string" then
            frameURL = data.avatar_frame
        elseif type(data.avatar_frame) == "table" then
            frameURL = data.avatar_frame.image_large or data.avatar_frame.image_small or ""
        end
    end

    if frameURL == "" then
        self:ReturnHTMLToPool()
        return
    end

    local htmlPanel = self:SetupHTMLPanel()
    local frameHTML = CreateMediaTag(frameURL, "frame")

    if IsValid(htmlPanel) then
        htmlPanel:SetHTML(string.format(self.HTMLTemplate, frameHTML))
    end
end

function PANEL:FetchSteamData(steamID64, accountID)
    if not accountID then return end
    
    local miniprofileURL = "https://steamcommunity.com/miniprofile/" .. accountID .. "/json?t=" .. os.time()
    
    http.Fetch(miniprofileURL, function(body, size, headers, code)
        if not IsValid(self) then return end

        if code == 200 then
            local data = util.JSONToTable(body)
            if data then
                AvatarImagePlus_DataCache[steamID64] = { data = data }
                self:ProcessMiniprofileData(data, steamID64)
                return
            end
        end
        
        AvatarImagePlus_DataCache[steamID64] = { data = {} }
        self:ProcessMiniprofileData({}, steamID64)
    end, function(err)
        if not IsValid(self) then return end
        AvatarImagePlus_DataCache[steamID64] = { data = {} }
        self:ProcessMiniprofileData({}, steamID64)
    end)
end

function PANEL:SetHTMLAlpha(alpha)
    local opacity = alpha / 255
    if IsValid(self.InnerHTML) then
        self.InnerHTML:RunJavascript(string.format("if (document.body) { document.body.style.opacity = '%f'; }", opacity))
    end
    
    if IsValid(self.Avatar) then
        self.Avatar:SetAlpha(alpha)
    end
end

function PANEL:Think()
    local currentAlpha = self:GetAlpha()
    local parent = self:GetParent()

    while IsValid(parent) do
        if type(parent.GetAlpha) == "function" then
            local parentAlpha = parent:GetAlpha()
            if parentAlpha < currentAlpha then
                currentAlpha = parentAlpha
            end
        end
        parent = parent:GetParent()
    end

    if self.LastSyncAlpha ~= currentAlpha then
        self.LastSyncAlpha = currentAlpha
        self:SetHTMLAlpha(currentAlpha)
    end
end

function PANEL:PerformLayout(w, h)
    if IsValid(self.Avatar) then
        local aW, aH = w * 0.82, h * 0.82
        self.Avatar:SetSize(aW, aH)
        self.Avatar:SetPos((w - aW) / 2, (h - aH) / 2)
    end

    if IsValid(self.InnerHTML) then
        self.InnerHTML:SetSize(w, h)
        self.InnerHTML:SetPos(0, 0)
    end
end

vgui.Register("AvatarImagePlus", PANEL, "DPanel")
