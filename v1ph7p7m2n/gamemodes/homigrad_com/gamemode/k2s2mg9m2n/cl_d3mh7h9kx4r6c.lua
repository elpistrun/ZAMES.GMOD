--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/cl_d3mh7h9kx4r6c.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

local gd = mh("zames/gd.png")

local function ShowWinPanel(team_name, team_color)
    local w, h = ScrW(), ScrH()
    local pW, pH = w / 5, 50
    local pX = w / 2.505
    
    if IsValid(WinPanelD3M) then WinPanelD3M:Remove() end
    
    WinPanelD3M = vgui.Create("DPanel")
    WinPanelD3M:SetSize(pW, pH)
    WinPanelD3M:SetPos(pX, -pH)
    
    WinPanelD3M:MoveTo(pX, 0, 0.5, 0, -1) 
    
    WinPanelD3M.Paint = function(self, pw, ph)
        surface.SetDrawColor(team_color)
        surface.SetMaterial(gd)
        surface.DrawTexturedRect(0, 0, pw, ph)
    end
    
    local winText = vgui.Create("DLabel", WinPanelD3M)
    winText:SetText("Победили - " .. team_name)
    winText:SetFont("PT.3")
    winText:SetTextColor(color_white)
    winText:SetContentAlignment(5)
    winText:Dock(FILL)
    
    winText:SetAlpha(0)
    
    timer.Simple(0.5, function()
        if IsValid(winText) then
            winText:AlphaTo(255, 0.5) 
        end
    end)
    
    timer.Simple(5, function()
        if IsValid(WinPanelD3M) then
            if IsValid(winText) then
                winText:AlphaTo(0, 0.3)
            end
            
            timer.Simple(0.1, function()
                if IsValid(WinPanelD3M) then
                    WinPanelD3M:MoveTo(pX, -pH, 0.5, 0, -1, function()
                        if IsValid(WinPanelD3M) then WinPanelD3M:Remove() end
                    end)
                end
            end)
        end
    end)
end

net.Receive("net_rd",function()
    local previous_state = zs.RD and zs.RD.state or 0

    zs.RD = net.ReadTable()

    if zs.RD.name ~= "dm" then
        DM_StartTime = 0
        lastBeepTime = -1
        battleSoundPlayed = false
    end

    if previous_state ~= 2 and zs.RD.state == 2 then
        local winner_text = zs.RD.winner or "Ничья"
        local winner_color = color_white
        
        local mode = zs.RD.name 
        local is_local_player_winner = false 
        
        if mode and _G[mode] and _G[mode].Teams then
            for k, team_data in pairs(_G[mode].Teams) do

                if team_data.Name == winner_text then
                    winner_color = team_data.Color

                    if IsValid(LocalPlayer()) then
                        if LocalPlayer():Team() == k then
                            is_local_player_winner = true
                        end
                    end
                    
                    break
                end
            end
        end

        if winner_text == "Ничья" then
            surface.PlaySound("zames/vgui/lost.wav") 
        elseif is_local_player_winner then
            surface.PlaySound("zames/vgui/win.wav") 
        else
            surface.PlaySound("zames/vgui/lost.wav") 
        end
        
        ShowWinPanel(winner_text, winner_color)
    end
end)


hook.Add("HUDPaint","fdfdf",function()
    local w , h = ScrW() , ScrH()
    if zs.RD.state == 0 then

        surface.SetDrawColor(255,0,0)
        surface.SetMaterial(gd)
        surface.DrawTexturedRect(w / 2.505 , 0, w / 5 , 50)

        draw.SimpleText("Необходимо 2 игрока для начало игры.", "PT.3", w / 2 , 20 , color_white , TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER)
    end
end)

local current_round
local round_start_time = 0

net.Receive("net_role",function()
    current_round = net.ReadString()
    round_start_time = CurTime()

    hook.Remove("HUDPaint", "HUD_Role")
    hook.Remove("HUDPaint", "HUD_roadlevel")
    timer.Remove("HUD_Role_Remove")
    timer.Remove("HUD_roadlevel_Remove")

    if zs.RD.state == 1 then
        local ply = LocalPlayer()
        if IsValid(ply) and ply:Team() == 1002 then
            return
        end

        if _G[current_round] and _G[current_round].StartSound then
            _G[current_round].StartSound()
        end

        hook.Add("HUDPaint", "HUD_Role", function()
            if current_round and _G[current_round] and _G[current_round].HUDPaint then
                _G[current_round].HUDPaint(round_start_time)
            end
        end)

        timer.Create("HUD_Role_Remove", 9, 1, function()
            hook.Remove("HUDPaint", "HUD_Role")
        end)
        
        system.FlashWindow()
    end

    if zs.RD.state == 2 then
        timer.Simple(5, function()
            local fade_start = CurTime() 

            hook.Add("HUDPaint", "HUD_roadlevel", function()
                local w, h = ScrW(), ScrH()
                
                local elapsed = CurTime() - fade_start 

                local bg_alpha = math.Clamp(elapsed / 1, 0, 1) * 255
                
                local text_alpha = math.Clamp((elapsed - 1) / 1.5, 0, 1) * 255

                if current_round and _G[current_round] then
                    surface.SetDrawColor(0, 0, 0, bg_alpha)
                    surface.DrawRect(0, 0, w, h)

                    draw.SimpleText("Запускаю режим - " .. _G[current_round].Name, "PT.1", w / 2, h / 2, Color(255, 255, 255, text_alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end)

            timer.Create("HUD_roadlevel_Remove", 5.5, 1, function()
                hook.Remove("HUDPaint", "HUD_roadlevel")
            end)
        end)
    end
end)
