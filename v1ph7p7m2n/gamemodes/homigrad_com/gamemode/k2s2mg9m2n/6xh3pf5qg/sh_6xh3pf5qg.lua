--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/6xh3pf5qg/sh_6xh3pf5qg.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:26
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

AddCSLuaFile()

if CLIENT then
    if IsValid(RTV_Panel) then RTV_Panel:Remove() end

    local MapCards = {}
    local RTV_Maps = {}

    net.Receive("RTV_StartVoting", function()
        RTV_Maps = net.ReadTable()
        local num_maps = #RTV_Maps
        MapCards = {}

        if RTV_Music then RTV_Music:Stop() end
        RTV_Music = CreateSound(LocalPlayer(), "zames/vgui/golosovanie.wav")
        if RTV_Music then RTV_Music:Play() end

        if IsValid(RTV_Panel) then RTV_Panel:Remove() end

        RTV_Panel = vgui.Create("DPanel")
        RTV_Panel:SetSize(ScrW(), ScrH())
        RTV_Panel:SetPos(0, 0)
        RTV_Panel:SetAlpha(0)
        RTV_Panel:MakePopup()
        RTV_Panel:SetKeyboardInputEnabled(false)
        RTV_Panel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 230))
        end
        RTV_Panel:AlphaTo(255, 1, 0)

        local titleText = vgui.Create("DLabel", RTV_Panel)
        titleText:SetText("Смена карты")
        titleText:SetFont("PT.1")
        titleText:SetTextColor(Color(255, 255, 255))
        titleText:SizeToContents()
        
        local origX = ScrW() / 2 - titleText:GetWide() / 2
        local origY = ScrH() / 2 - titleText:GetTall() / 2
        titleText:SetPos(origX, origY)
        
        titleText:SetAlpha(0)
        titleText:AlphaTo(255, 1, 0)

        titleText.Think = function(self)
            self:SetPos(origX + math.random(-9, 1), origY + math.random(-9, 1))
        end

        timer.Simple(4, function()
            if IsValid(titleText) then
                titleText:AlphaTo(0, 1, 0, function()
                    if IsValid(titleText) then titleText:Remove() end
                end)
            end
        end)

        timer.Simple(5, function()
            if not IsValid(RTV_Panel) then return end

            local cardW, cardH = 220, 220 -- Уменьшенный размер карточки
            local cols = 5                -- Сетка: 5 колонок
            local rows = math.ceil(num_maps / cols) -- Автоматический расчет строк
            local gapX = 35               -- Расстояние между карточками по горизонтали
            local gapY = 35               -- Расстояние между карточками по вертикали
            
            local totalGridWidth = (cols * cardW) + ((cols - 1) * gapX)
            local totalGridHeight = (rows * cardH) + ((rows - 1) * gapY)
            
            local gridStartX = (ScrW() - totalGridWidth) / 2
            local gridStartY = (ScrH() - totalGridHeight) / 2 + 20

            local centerScrX = ScrW() / 2 - cardW / 2
            local centerScrY = ScrH() / 2 - cardH / 2
            local startDropY = -cardH - 200

            local gridPositions = {}
            for i = 1, num_maps do
                local col = (i - 1) % cols
                local row = math.floor((i - 1) / cols)
                table.insert(gridPositions, {
                    x = gridStartX + col * (cardW + gapX),
                    y = gridStartY + row * (cardH + gapY)
                })
            end
            
            for i = #gridPositions, 2, -1 do
                local j = math.random(i)
                gridPositions[i], gridPositions[j] = gridPositions[j], gridPositions[i]
            end

            for i = 1, num_maps do
                local card = vgui.Create("DButton", RTV_Panel)
                card:SetSize(cardW, cardH)
                card:SetPos(centerScrX, startDropY)
                card:SetText("")
                card:SetVisible(false)
                card:SetMouseInputEnabled(false) 
                
                card.Percent = 0
                card.MapIndex = i
                card.IsAtTarget = false 
                card.IsSpinning = false
                card.RotAngle = 0 
                
                local mat = mh("zames/thumb/" .. RTV_Maps[i] .. ".png")
                if mat:IsError() then mat = Material("vgui/avatar_default") end
                card.MapMat = mat

                card.Think = function(self)
                    if self.IsSpinning then
                        self.RotAngle = self.RotAngle + FrameTime() * 800
                    end
                end

                card.Paint = function(self, w, h)
                    local x, y = self:LocalToScreen(0, 0)
                    local cx, cy = x + w/2, y + h/2

                    local m = Matrix()
                    m:Translate(Vector(cx, cy))
                    m:Rotate(Angle(0, self.RotAngle, 0))
                    m:Translate(Vector(-cx, -cy))

                    cam.PushModelMatrix(m)
                        surface.SetDrawColor(255, 255, 255, 255)
                        surface.SetMaterial(self.MapMat)
                        surface.DrawTexturedRect(0, 0, w, h)

                        draw.RoundedBox(0, 0, h - 35, w, 35, Color(0, 0, 0, 220))
                        draw.SimpleText(RTV_Maps[self.MapIndex] or "Unknown", "PT.3", w/2, h - 17, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                        local borderColor = Color(0, 0, 0, 255)
                        if self.IsAtTarget and self:IsHovered() then borderColor = Color(255, 255, 255) end
                        if self.IsWinner then borderColor = Color(255, 255, 255) end 

                        surface.SetDrawColor(borderColor)
                        surface.DrawOutlinedRect(0, 0, w, h, self.IsWinner and 4 or 2)
                        
                        if self.IsAtTarget and self.Percent > 0 then
                            draw.SimpleText(self.Percent .. "%", "PT.4", w/2, h/2 - 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        end
                    cam.PopModelMatrix()
                end

                card.DoClick = function(self)
                    if not self.IsAtTarget then return end 
                    net.Start("RTV_SendVote")
                    net.WriteUInt(self.MapIndex, 5) -- Изменено на 5 бит
                    net.SendToServer()
                    surface.PlaySound("zames/vgui/click1.wav")

                    local shrinkW, shrinkH = cardW - 20, cardH - 20 -- Динамическое уменьшение
                    local origX, origY = self:GetPos()
                    local offset = (cardW - shrinkW) / 2

                    self:SizeTo(shrinkW, shrinkH, 0.1, 0, -1, function()
                        if IsValid(self) then
                            self:SizeTo(cardW, cardH, 0.1, 0, -1)
                        end
                    end)
                    self:MoveTo(origX + offset, origY + offset, 0.1, 0, -1, function()
                        if IsValid(self) then
                            self:MoveTo(origX, origY, 0.1, 0, -1)
                        end
                    end)
                end

                MapCards[i] = card
            end

            for i = 1, num_maps do
                local card = MapCards[i]
                if IsValid(card) then
                    card:SetVisible(true)
                    card:MoveTo(centerScrX, centerScrY, 0.8, (i - 1) * 0.02, 0.5, function()
                        card.IsSpinning = true
                    end)
                end
            end

            timer.Simple(0.8, function()
                surface.PlaySound("ambient/machines/thumper_dust.wav")
            end)

            timer.Simple(2.8, function()
                for i = 1, num_maps do
                    local card = MapCards[i]
                    if not IsValid(card) or not IsValid(RTV_Panel) then return end

                    local targetX = gridPositions[i].x
                    local targetY = gridPositions[i].y

                    timer.Simple((i - 1) * 0.1, function()
                        if not IsValid(card) then return end
                        card:MoveTo(targetX, targetY, 0.6, 0, -1, function()
                            if IsValid(card) then
                                card.IsAtTarget = true
                                card.IsSpinning = false
                                card.RotAngle = 0
                                card:SetMouseInputEnabled(true)
                                surface.PlaySound("zames/vgui/cards_draw_one_0" .. math.random(1,4) .. ".wav")
                            end
                        end)
                    end)
                end
            end)

            timer.Simple(4.5, function() 
                if not IsValid(RTV_Panel) then return end

                local voteText = vgui.Create("DLabel", RTV_Panel)
                voteText:SetText("Начинаем голосование, время пошло!")
                voteText:SetFont("PT.2")
                voteText:SetTextColor(Color(255,255,255,255))
                voteText:SizeToContents()
                voteText:SetPos(ScrW() / 2 - voteText:GetWide() / 2, ScrH() * 0.08)
                voteText:SetAlpha(0)
                voteText:AlphaTo(255, 1, 0)
                
                RTV_Panel.TitleLabel = voteText
                surface.PlaySound("buttons/blip1.wav")

                local dropPanel = vgui.Create("DPanel", RTV_Panel)
                dropPanel:SetSize(ScrW(), ScrH())
                dropPanel:SetPos(0, 0)
                dropPanel:SetMouseInputEnabled(false) 

                local startTime = SysTime()
                local dropDur = 0.5 

                dropPanel.Paint = function(self, w, h)
                    local frac = math.Clamp((SysTime() - startTime) / dropDur, 0, 1)
                    local ease = math.ease.OutBack(frac) 
                    
                    local scale = Lerp(ease, 6, 1) 
                    local yPos = Lerp(ease, -ScrH() * 0.3, h / 2) 
                    local alpha = self:GetAlpha()

                    local m = Matrix()
                    local cx, cy = w / 2, yPos
                    m:Translate(Vector(cx, cy))
                    m:Scale(Vector(scale, scale, 1))
                    m:Translate(Vector(-cx, -cy))

                    cam.PushModelMatrix(m)
                    draw.SimpleText("ГОЛОСОВАНИЕ!", "PT.1", w / 2, yPos, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    cam.PopModelMatrix()
                end

                timer.Simple(dropDur + 1, function()
                    if IsValid(dropPanel) then
                        dropPanel:AlphaTo(0, 0.5, 0, function() 
                            if IsValid(dropPanel) then dropPanel:Remove() end 
                        end)
                    end
                end)
            end)
        end)
    end)

    net.Receive("RTV_UpdateVotes", function()
        local voteData = net.ReadTable()
        
        for i, card in pairs(MapCards) do
            if IsValid(card) then
                local data = voteData[i] or {percent = 0, players = {}}
                card.Percent = data.percent

                if card.Avatars then
                    for _, av in ipairs(card.Avatars) do
                        if IsValid(av) then av:Remove() end
                    end
                end
                card.Avatars = {}

                local avatarSize = 28 -- Уменьшенные аватарки
                local padding = 5
                local cardW, cardH = 220, 220 -- Согласованные размеры

                local maxCols = math.floor((cardW - padding * 2) / (avatarSize + padding))

                for idx, ply in ipairs(data.players) do
                    if not IsValid(ply) then continue end

                    local av = vgui.Create("AvatarImage", card)
                    av:SetSize(avatarSize, avatarSize)
                    av:SetPlayer(ply, avatarSize)
                    av:SetMouseInputEnabled(false) 

                    local gridIdx = idx - 1
                    local col = gridIdx % maxCols
                    local row = math.floor(gridIdx / maxCols)

                    local x = padding + col * (avatarSize + padding)
                    local y = cardH - 35 - padding - avatarSize - row * (avatarSize + padding)

                    av:SetPos(x, y)
                    table.insert(card.Avatars, av)
                end
            end
        end
    end)

    net.Receive("RTV_EndVoting", function()
        local winnerIndex = net.ReadUInt(5)

        if RTV_Music then
            RTV_Music:FadeOut(3)
        end

        if winnerIndex == 0 then
            if IsValid(RTV_Panel.TitleLabel) then
                RTV_Panel.TitleLabel:SetText("Голосование отменено (нет голосов)")
                RTV_Panel.TitleLabel:SetTextColor(Color(255, 176, 176, 255))
                RTV_Panel.TitleLabel:SizeToContents()
                RTV_Panel.TitleLabel:SetPos(ScrW() / 2 - RTV_Panel.TitleLabel:GetWide() / 2, ScrH() * 0.08)
            end
            surface.PlaySound("buttons/button10.wav")
            timer.Simple(3, function()
                if IsValid(RTV_Panel) then
                    RTV_Panel:AlphaTo(0, 1, 0, function() RTV_Panel:Remove() end)
                end
            end)
            return
        end

        if IsValid(RTV_Panel.TitleLabel) then
            local winnerMap = RTV_Maps[winnerIndex]
            
            if winnerMap == game.GetMap() then
                RTV_Panel.TitleLabel:SetText("Победила текущая карта! Продолжаем.")
                RTV_Panel.TitleLabel:SetTextColor(Color(176, 255, 176, 255))
            else
                RTV_Panel.TitleLabel:SetText("Голосование завершено!")
            end
            
            RTV_Panel.TitleLabel:SizeToContents()
            RTV_Panel.TitleLabel:SetPos(ScrW() / 2 - RTV_Panel.TitleLabel:GetWide() / 2, ScrH() * 0.08)
        end

        surface.PlaySound("zames/vgui/xp_milestone_0" .. math.random(1,5) .. ".wav")

        for i, card in pairs(MapCards) do
            if not IsValid(card) then continue end
            
            card:SetMouseInputEnabled(false)
            card.IsAtTarget = false 
            
            if i ~= winnerIndex then
                card:AlphaTo(0, 1, 0, function()
                    if IsValid(card) then card:Remove() end
                end)
            else
                card.IsWinner = true
                card:MoveTo(ScrW() / 2 - card:GetWide() / 2, ScrH() / 2 - card:GetTall() / 2, 1, 0.5, -1)
                timer.Simple(0.5, function() surface.PlaySound("garrysmod/save_load1.wav") end)
            end
        end

        timer.Simple(4.5, function()
            if IsValid(RTV_Panel) then
                RTV_Panel:AlphaTo(0, 1, 0, function() RTV_Panel:Remove() end)
            end
        end)
    end)
end

if SERVER then
    RTV = RTV or {}
    RTV.Votes = RTV.Votes or {}
    RTV.IsVoteInProgress = false
    RTV.PlayerVotes = RTV.PlayerVotes or {}
    RTV.Maps = RTV.Maps or {}
    RTV.VoteCounts = RTV.VoteCounts or {}

    local VOTE_DURATION = 20 -- Длительность активного голосования
    local RTV_TRIGGER_PERCENT = 0.5 -- 50% голосов для запуска

    local function GetMapsForVote()
        local rawFiles = file.Find("maps/*.bsp", "GAME")
        local curMap = game.GetMap()
        local mapList = {}

        for _, f in ipairs(rawFiles) do
            local mapName = string.StripExtension(f)
            if mapName ~= curMap then
                table.insert(mapList, mapName)
            end
        end

        if #mapList == 0 then
            table.insert(mapList, curMap)
        end

        table.Shuffle(mapList)

        -- Выбираем до 10 карт (сетка 5x2)
        local count = math.min(10, #mapList)
        local selected = {}
        for i = 1, count do
            table.insert(selected, mapList[i])
        end

        return selected
    end

    function RTV.SendVoteUpdate()
        local totalVotes = 0
        local counts = {}
        local playersByMap = {}

        for i = 1, #RTV.Maps do
            counts[i] = 0
            playersByMap[i] = {}
        end

        for ply, mapIdx in pairs(RTV.PlayerVotes) do
            if IsValid(ply) and counts[mapIdx] then
                counts[mapIdx] = counts[mapIdx] + 1
                totalVotes = totalVotes + 1
                table.insert(playersByMap[mapIdx], ply)
            end
        end

        local voteData = {}
        for i = 1, #RTV.Maps do
            local pct = (totalVotes > 0) and math.Round((counts[i] / totalVotes) * 100) or 0
            voteData[i] = {
                percent = pct,
                players = playersByMap[i]
            }
        end

        net.Start("RTV_UpdateVotes")
        net.WriteTable(voteData)
        net.Broadcast()
    end

    function RTV.StartMapVote()
        if RTV.IsVoteInProgress then return end

        RTV.IsVoteInProgress = true
        RTV.PlayerVotes = {}
        RTV.Maps = GetMapsForVote()

        net.Start("RTV_StartVoting")
        net.WriteTable(RTV.Maps)
        net.Broadcast()

        -- Через 5 сек (после анимации титров) открывается активная фаза
        timer.Simple(5, function()
            if not RTV.IsVoteInProgress then return end
            RTV.SendVoteUpdate()
        end)

        timer.Create("RTV_Server_EndVoteTimer", 5 + VOTE_DURATION, 1, function()
            RTV.FinishVote()
        end)
    end

    function RTV.FinishVote()
        if not RTV.IsVoteInProgress then return end
        RTV.IsVoteInProgress = false

        local counts = {}
        local totalVotes = 0
        for i = 1, #RTV.Maps do counts[i] = 0 end

        for ply, mapIdx in pairs(RTV.PlayerVotes) do
            if IsValid(ply) and counts[mapIdx] then
                counts[mapIdx] = counts[mapIdx] + 1
                totalVotes = totalVotes + 1
            end
        end

        local winnerIndex = 1
        local maxVotes = -1

        for i = 1, #RTV.Maps do
            if counts[i] > maxVotes then
                maxVotes = counts[i]
                winnerIndex = i
            end
        end

        if totalVotes == 0 then
            winnerIndex = 0
        end

        net.Start("RTV_EndVoting")
        net.WriteUInt(winnerIndex, 5)
        net.Broadcast()

        if winnerIndex > 0 then
            local nextMap = RTV.Maps[winnerIndex]
            timer.Simple(5.5, function()
                RunConsoleCommand("changelevel", nextMap)
            end)
        end
    end

    net.Receive("RTV_SendVote", function(len, ply)
        if not IsValid(ply) or not RTV.IsVoteInProgress then return end

        local mapIndex = net.ReadUInt(5)
        if mapIndex < 1 or mapIndex > #RTV.Maps then return end

        RTV.PlayerVotes[ply] = mapIndex
        RTV.SendVoteUpdate()
    end)

    hook.Add("PlayerSay", "RTV_ChatTrigger", function(ply, text)
        local t = string.lower(string.Trim(text))
        if t == "rtv" or t == "!rtv" or t == "/rtv" or t == "ртв" then
            if RTV.IsVoteInProgress then
                ply:ChatPrint("[RTV] Голосование уже идёт!")
                return ""
            end

            if RTV.Votes[ply] then
                ply:ChatPrint("[RTV] Вы уже проголосовали за смену карты!")
                return ""
            end

            -- Очищаем таблицу от вышедших игроков
            for p, _ in pairs(RTV.Votes) do
                if not IsValid(p) then
                    RTV.Votes[p] = nil
                end
            end

            RTV.Votes[ply] = true

            -- Считаем только реальных валидных игроков
            local validPlayers = 0
            for _, p in player.Iterator() do
                if IsValid(p) and not p:IsBot() then
                    validPlayers = validPlayers + 1
                end
            end
            if validPlayers < 1 then validPlayers = player.GetCount() end

            local voteCount = 0
            for p, _ in pairs(RTV.Votes) do
                if IsValid(p) then voteCount = voteCount + 1 end
            end

            local needed = math.max(1, math.ceil(validPlayers * RTV_TRIGGER_PERCENT))

            if voteCount >= needed then
                for _, p in player.Iterator() do
                    p:ChatPrint("[RTV] " .. ply:Nick() .. " хочет сменить карту (" .. voteCount .. "/" .. needed .. ")")
                end
                RTV.Votes = {}
                RTV.StartMapVote()
            else
                for _, p in player.Iterator() do
                    p:ChatPrint("[RTV] " .. ply:Nick() .. " хочет сменить карту (" .. voteCount .. "/" .. needed .. ")")
                end
            end

            return ""
        end
    end)

    hook.Add("PlayerDisconnected", "RTV_DisconnectCleanup", function(ply)
        if RTV.Votes[ply] then RTV.Votes[ply] = nil end
        if RTV.PlayerVotes[ply] then
            RTV.PlayerVotes[ply] = nil
            if RTV.IsVoteInProgress then RTV.SendVoteUpdate() end
        end
    end)
end

