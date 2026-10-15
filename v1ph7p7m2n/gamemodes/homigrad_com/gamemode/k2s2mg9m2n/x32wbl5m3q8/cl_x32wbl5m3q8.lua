--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/x32wbl5m3q8/cl_x32wbl5m3q8.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

local VOICE_PANEL = {}

function VOICE_PANEL:Init()
    local panelW = 250
    local panelH = 50
    self:SetSize(panelW, panelH)

    local avSize = 50
    local avX = 0
    local avY = (panelH - avSize) / 2

    self.Avatar = vgui.Create("AvatarImagePlus", self)
    self.Avatar:SetSize(avSize, avSize)
    self.Avatar:SetPos(avX, avY)
    self.Avatar:SetMouseInputEnabled(false)

    self.AvCenterX = avX + (avSize / 2)
    self.AvCenterY = avY + (avSize / 2)

    self.Alpha = 0
    self.TargetAlpha = 0
    self.Volume = 0

    self:SetAlpha(0)
end

function VOICE_PANEL:Setup(ply)
    self.Player = ply
    self.TargetAlpha = 255
    self:UpdateAvatar()
end

function VOICE_PANEL:Paint(w, h)
    if not IsValid(self.Player) then return end

    local bgMatPath = self.Player:GetNWString("VoiceBG", "")
    local bgColor
    if self.Player:Alive() then
        bgColor = Color(68, 68, 68, (self.Alpha / 255) * 170)
    else
        bgColor = Color(136, 2, 2, (self.Alpha / 255) * 170)
    end
    draw.RoundedBox(0, 0, 0, w, h, bgColor)

    if bgMatPath != "" then
        surface.SetMaterial(Material(bgMatPath))
        surface.SetDrawColor(255, 255, 255, 225)
        surface.DrawTexturedRect(0, 0, w, h)
    end


    surface.SetDrawColor(255, 255, 255, (self.Alpha / 255) * 10)
    surface.DrawLine(0, 0, w, 0)
    surface.DrawLine(0, 0, 0, h)

    surface.SetDrawColor(0, 0, 0, (self.Alpha / 255) * 200)
    surface.DrawLine(0, h - 1, w, h - 1)
    surface.DrawLine(w - 1, 0, w - 1, h)

    local modeName = (zs and zs.RD and zs.RD.name)
    
    if modeName == "tdm" or modeName == "hl2dm" or modeName == "riot" or modeName == "hunter" then
        local ply = self.Player
        local plyTeam = ply:Team()
        
        if plyTeam ~= 1002 then
            local teamData = _G[modeName].Teams[plyTeam]
            
            if teamData and teamData.Color then
                local teamColor = teamData.Color
                local indicatorSize = 64
                local padding = 0
                
                surface.SetDrawColor(teamColor.r, teamColor.g, teamColor.b, self.Alpha)
                
                surface.SetMaterial(mh("zames/gr.png")) 
                surface.DrawTexturedRect(w - 40, 0, 64, 64)
            end
        end
    end

    if self.Volume > 0.01 then
        DisableClipping(true)

        local baseSize = 32
        local imgSize = baseSize + (self.Volume * 700)
        local iconAlpha = math.Clamp(self.Volume * 200 * 5, 0, self.Alpha)

        local figMatPath = self.Player:GetNWString("VoiceFigure", "zames/models/circle.png")
        local figColVec = self.Player:GetNWVector("FigColor", Vector(255, 255, 255))
        
        surface.SetMaterial(Material(figMatPath))
        surface.SetDrawColor(figColVec.x, figColVec.y, figColVec.z, iconAlpha)
        surface.DrawTexturedRect(self.AvCenterX - (imgSize / 2), self.AvCenterY - (imgSize / 2), imgSize, imgSize)

        DisableClipping(false)
    end

    local isClone = self.Player:GetNW2Bool("HMCD_Clone", false)
    local isAnonim = self.Player:GetNW2Bool("IsAnonim", false)
    local displayName = isClone and self.Player:GetNW2String("CloneNick", self.Player:Nick()) 
        or (isAnonim and self.Player:GetNW2String("AnonimName", "Неизвестный") or self.Player:Nick())

    draw.SimpleText(displayName, "PT.3", w * 0.5, h * 0.5, Color(255, 255, 255, self.Alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function VOICE_PANEL:UpdateAvatar()
    if not IsValid(self.Player) then return end
    
    local isClone = self.Player:GetNW2Bool("HMCD_Clone", false)
    local isAnonim = self.Player:GetNW2Bool("IsAnonim", false)
    local showPlayer = self.Player
    local useFakeSteamID = false
    
    if isClone then
        local clonePly = self.Player:GetNW2Entity("CloneAvatar")
        if IsValid(clonePly) and clonePly:IsPlayer() then
            showPlayer = clonePly
        end
    elseif isAnonim then
        local fakePly = self.Player:GetNW2Entity("AnonimAvatar")
        
        if IsValid(fakePly) and fakePly:IsPlayer() and fakePly ~= self.Player then
            showPlayer = fakePly
        else
            useFakeSteamID = true
            showPlayer = NULL
        end
    end
    
    local stateKey = tostring(isClone) .. "_" .. tostring(isAnonim)
    if self.CurrentAvatarPly ~= showPlayer or self.WasStateKey ~= stateKey then
        self.CurrentAvatarPly = showPlayer
        self.WasStateKey = stateKey
        
        if useFakeSteamID then
            self.Avatar:SetSteamID("0", 128)
        else
            self.Avatar:SetPlayer(showPlayer, 128)
        end
    end
end

function VOICE_PANEL:Think()
    if not IsValid(self.Player) or not self.Player:IsSpeaking() then
        self.TargetAlpha = 0
    else
        self.TargetAlpha = 255
    end

    self:UpdateAvatar()

    self.Alpha = Lerp(FrameTime() * 10, self.Alpha, self.TargetAlpha)
    self:SetAlpha(self.Alpha)

    if IsValid(self.Player) then
        self.Volume = Lerp(FrameTime() * 15, self.Volume, self.Player:VoiceVolume())
    end

    if self.TargetAlpha == 0 and math.Round(self.Alpha) <= 1 then
        self:Remove()
        g_VoicePanels[self.Player] = nil
        GAMEMODE:VoicePanelsLayout()
    end
end

vgui.Register("CustomVoicePanel", VOICE_PANEL, "DPanel")

g_VoicePanels = g_VoicePanels or {}

local function VoicePanelsLayout()
    local marginRight = 90
    local marginBottom = 120
    local spacing = -20
    local panelW = 250
    local panelH = 80

    local index = 0
    for ply, pnl in pairs(g_VoicePanels) do
        if IsValid(pnl) then
            local targetX = ScrW() - marginRight - panelW
            local targetY = ScrH() - marginBottom - panelH - (index * (panelH + spacing))

            pnl:SetPos(targetX, targetY)
            index = index + 1
        end
    end
end

GM.VoicePanelsLayout = VoicePanelsLayout

hook.Add("PlayerStartVoice", "CustomVoiceStart", function(ply)
    if not IsValid(ply) then return end

    if not IsValid(g_VoicePanels[ply]) then
        local pnl = vgui.Create("CustomVoicePanel")
        pnl:Setup(ply)
        g_VoicePanels[ply] = pnl
    end

    VoicePanelsLayout()

    return true
end)

hook.Add("PlayerEndVoice", "CustomVoiceEnd", function(ply)
    if IsValid(g_VoicePanels[ply]) then
        g_VoicePanels[ply].TargetAlpha = 0
    end

    return true
end)

hook.Add("HUDShouldDraw", "HideStandardVoiceHUD", function(name)
    if name == "GModVoiceNotify" then
        return false
    end
end)

function CreateVoicePlayerBar(parent, ply, rootPanel)
    if not IsValid(ply) then return end

    local pnl = vgui.Create("DPanel", parent)
    pnl:SetSize(250, 50) 
    
    local showPly = ply
    if ply:GetNW2Bool("HMCD_Clone", false) then
        local cPly = ply:GetNW2Entity("CloneAvatar")
        if IsValid(cPly) and cPly:IsPlayer() then showPly = cPly end
    elseif ply:GetNW2Bool("IsAnonim", false) then
        local aPly = ply:GetNW2Entity("AnonimAvatar")
        if IsValid(aPly) and aPly:IsPlayer() then showPly = aPly end
    end

    local avSize = 50
    local avatar = vgui.Create("AvatarImage", pnl)
    avatar:SetSize(avSize, avSize)
    avatar:SetPos(0, 0)
    avatar:SetPlayer(showPly, 64)
    avatar:SetMouseInputEnabled(false)

    pnl.Paint = function(self, w, h)
        if not IsValid(ply) then return end
        
        draw.RoundedBox(0, 0, 0, w, h, Color(68, 68, 68, 170))
        
        local bgMatPath = ply:GetNWString("VoiceBG", "")
        if bgMatPath != "" then
            surface.SetMaterial(Material(bgMatPath))
            surface.SetDrawColor(255, 255, 255, 225)
            surface.DrawTexturedRect(0, 0, w, h)
        end

        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawLine(0, 0, w, 0)
        surface.DrawLine(0, 0, 0, h)
        
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawLine(0, h - 1, w, h - 1)
        surface.DrawLine(w - 1, 0, w - 1, h)
        
        local fakeVolume = (math.sin(CurTime() * 4) + 1) / 2 * 0.3 
        
        DisableClipping(true)
        
        local baseSize = 32
        local imgSize = baseSize + (fakeVolume * 200)
        local iconAlpha = math.Clamp(fakeVolume * 200 * 5, 0, 255)
        
        local figMatPath = ply:GetNWString("VoiceFigure", "zames/models/circle.png")
        local figColVec = ply:GetNWVector("FigColor", Vector(255, 255, 255))
        
        surface.SetMaterial(Material(figMatPath))
        surface.SetDrawColor(figColVec.x, figColVec.y, figColVec.z, iconAlpha)
        
        surface.DrawTexturedRect(25 - (imgSize / 2), 25 - (imgSize / 2), imgSize, imgSize)
        
        DisableClipping(false)

        local isClone = ply:GetNW2Bool("HMCD_Clone", false)
        local isAnonim = ply:GetNW2Bool("IsAnonim", false)
        local displayName = isClone and ply:GetNW2String("CloneNick", ply:Nick()) 
            or (isAnonim and ply:GetNW2String("AnonimName", "Неизвестный") or ply:Nick())

        draw.SimpleText(displayName, "PT.3", w * 0.5, h * 0.5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    return pnl
end
