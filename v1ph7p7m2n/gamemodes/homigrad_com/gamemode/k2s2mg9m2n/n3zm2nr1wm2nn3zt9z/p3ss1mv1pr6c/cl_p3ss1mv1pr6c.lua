--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/n3zm2nr1wm2nn3zt9z/p3ss1mv1pr6c/cl_p3ss1mv1pr6c.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

hmcd = hmcd or {}

net.Receive("hmcd_roleget", function()
    local roles = net.ReadTable()
    
    for _, ply in player.Iterator() do
        ply.roleT = false
        ply.roleCT = false
    end
    
    for _, ply in ipairs(roles[1]) do ply.roleT = true end
    for _, ply in ipairs(roles[2]) do ply.roleCT = true end
end)

function hmcd.StartSound()
    timer.Simple(0.1, function()
        if not IsValid(LocalPlayer()) then return end
        
        local subtype = GetGlobalString("HMCD_SubType", "classic")
        --print("Текущий подтип звука: " .. subtype)
        
        local isT = LocalPlayer().roleT or false

        if subtype == "wildwest" then
            if isT then
                surface.PlaySound("zames/round/shining.mp3")
            else
                surface.PlaySound("zames/round/wildwest.mp3")
            end
        elseif subtype == "clones" then
            if isT then
                surface.PlaySound("zames/round/clones.wav")
            else
                surface.PlaySound("zames/round/clones.wav")
            end
        elseif subtype == "unarmed" then
            if isT then
                surface.PlaySound("zames/round/shining.mp3")
            else
                surface.PlaySound("zames/round/panic.mp3")
            end
        else
            if isT then
                surface.PlaySound("zames/round/shining.mp3")
            else
                surface.PlaySound("zames/round/panic.mp3")
            end
        end
    end)
end

local hmcd_materials = {
    ["classic"] = {
        innocent = SetupMat("zames/rounds/hmcd_in.png", "anim_right", 0.6 , 350 , 0 , 60),
        ino = SetupMat("zames/rounds/hmcd_inp.png", "anim_right", 1 , 550 , 0 , 60),
        traitor  = SetupMat("zames/rounds/hmcd_tr.png", "anim_right", 1, 570, 0 , 50)
    },
    ["wildwest"] = {
        innocent = SetupMat("zames/rounds/hmcd_in.png", "anim_right", 0.6 , 350 , 0 , 60),
        ino = SetupMat("zames/rounds/hmcd_inp.png", "anim_right", 1 , 550 , 0 , 60),
        traitor  = SetupMat("zames/rounds/hmcd_tr.png", "anim_right", 1, 570, 0 , 50)
    },
    ["clones"] = {
        innocent = SetupMat("zames/rounds/hmcd_clons.png", "anim_zoom", 1 , nil , nil , 0.04),
        ino = SetupMat("zames/rounds/hmcd_inp.png", "anim_right", 1 , 550 , 0 , 60),
        traitor  = SetupMat("zames/rounds/hmcd_tr.png", "anim_right", 1, 570, 0 , 50)
    },
    ["unarmed"] = {
        innocent = SetupMat("zames/rounds/hmcd_in.png", "anim_right", 0.6 , 350 , 0 , 60),
        ino = SetupMat("zames/rounds/hmcd_inp.png", "anim_right", 1 , 550 , 0 , 60),
        traitor  = SetupMat("zames/rounds/hmcd_tr.png", "anim_right", 1, 570, 0 , 50)
    }
}

function hmcd.HUDPaint(round_start_time)
    local w, h = ScrW(), ScrH()
    local proshlo = CurTime() - round_start_time
    
    local lp = LocalPlayer()
    local is_traitor = lp.roleT or false
    local is_ino = lp.roleCT or false

    local alpha = math.Clamp(1 - ((proshlo - 5 ) / 3), 0, 1)

    surface.SetDrawColor(0, 0, 0, 255 * alpha)
    surface.DrawRect(0, 0, w, h)

    if alpha > 0 then
        local subtype = GetGlobalString("HMCD_SubType", "classic")
        local mats = hmcd_materials[subtype] or hmcd_materials["classic"]
        
        local bg_data = mats.innocent -- Значение по умолчанию

        if mats then
            if is_traitor then
                bg_data = mats.traitor
            elseif is_ino then
                bg_data = mats.ino
            end
        end

        surface.SetDrawColor(70,70,70, 255 * alpha)
        
        DrawBackgroundAnim(bg_data, proshlo)
    end

    local role = is_traitor and 2 or lp.roleCT and 3 or 1
    local team_data = hmcd.Teams[role] or { Name = "Неизвестно", Color = color_white, Desc = "Нет задачи" }

    local bg = ColorAlpha(hmcd.NameColor, 255 * alpha)
    local tc = ColorAlpha(team_data.Color, 255 * alpha)

    local currentName = GetGlobalString("HMCD_CurrentName", hmcd.Name)
    draw.SimpleText(currentName, "PT.1", w / 2, h / 8, bg, 1, 4)

    draw.SimpleText("Вы - " .. team_data.Name, "PT.2", w / 2, h / 2, tc, 1, 3)
    
    if is_traitor then
        local teammates = {}
        for _, ply in player.Iterator() do
            if ply ~= lp and ply.roleT then
                table.insert(teammates, ply:Nick())
            end
        end

        if #teammates > 0 then
            local mates_text = "Ваши напарники: " .. table.concat(teammates, ", ")
            draw.SimpleText(mates_text, "PT.3", w / 2, (h / 1.7) + 5, tc, 1, 4) 
        end
    end

    draw.SimpleText(team_data.Desc, "PT.3", w / 2, h / 1.2, tc, 1, 1)
end

hook.Add("HUDPaint","Whoisss",function()
    if zs.RD.name != "hmcd" then return end
    
    local lp = LocalPlayer()
    local canSeeTraitors = lp.roleT or lp:Team() == 1002
    
    for _, ply in player.Iterator() do

        if !ply:Alive() then
            continue 
        end

        if ply == lp then
            continue 
        end
        
        if ply:GetMoveType() == MOVETYPE_NOCLIP then continue end
        
        local dist = ply:GetPos():Distance(lp:GetPos())

        local pos = (ply:GetPos() + ply:OBBCenter()):ToScreen()

        if dist < 600 then
            if ply.roleCT then
                draw.SimpleText("Доверенное лицо","PT.3",pos.x,pos.y,Color(255,174,0,255 * (100 / dist)),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end
            
            if canSeeTraitors and ply.roleT then
                draw.SimpleText("Напарник", "PT.3", pos.x, pos.y, Color(255, 0, 0, 255 * (100 / dist)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end
end)

hook.Add("PreDrawHalos", "DrawTraitorHalos", function()
    if zs.RD.name != "hmcd" then return end 
    
    local lp = LocalPlayer()
    
    local canSeeTraitors = lp.roleT or (lp:Team() == 1002 and lp:Alive())
    
    if not canSeeTraitors then return end 

    local traitor_ents = {}
    local myPos = lp:GetPos()

    for _, ply in player.Iterator() do
        if not ply:Alive() or ply == lp or ply:GetMoveType() == MOVETYPE_NOCLIP then
            continue 
        end
        
        if ply.roleT then
            local rag = ply:GetNWEntity("FakeRagdoll")
            
            local targetEnt = IsValid(rag) and rag or ply
            
            local dist = targetEnt:GetPos():Distance(myPos)
            if dist < 600 then
                table.insert(traitor_ents, targetEnt)
            end
        end
    end

    if #traitor_ents > 0 then
        halo.Add(traitor_ents, Color(255, 0, 0), 2, 2, 1, true, true)
    end
end)


-- TRAITOR BUTTONS

local TraitorButtons = {}
local focus_ent = nil
local focus_stick = 0

timer.Create("HMCD_TraitorButtonCache", 1, 0, function()
    local ply = LocalPlayer()
    if IsValid(ply) and ply.roleT then
        TraitorButtons = ents.FindByClass("ttt_traitor_button")
    else
        TraitorButtons = {}
    end
end)

hook.Add("HUDPaint", "ButtonTratiors", function()
    if zs.RD.name != "hmcd" then return end

    local ply = LocalPlayer()
    if not ply.roleT then return end
    if #TraitorButtons == 0 then return end

    local plypos = ply:GetPos()
    local midscreen_x = ScrW() / 2
    local midscreen_y = ScrH() / 2
    
    local focus_range = 35
    local focus_d = 0
    local size = 32
    local mid = size / 2

    local new_focus_ent = nil

    for _, but in ipairs(TraitorButtons) do
        if not IsValid(but) or not but.IsUsable or not but:IsUsable() then continue end

        local pos = but:GetPos()
        local scrpos = pos:ToScreen()

        if not scrpos.visible then continue end

        local d = pos - plypos
        d = d:Dot(d) / (but:GetUsableRange() ^ 2)

        if d >= 1 then continue end

        local is_focused = false

        if d > focus_d and (focus_stick < CurTime() or but == focus_ent) then
            local x = math.abs(scrpos.x - midscreen_x)
            local y = math.abs(scrpos.y - midscreen_y)

            if (x < focus_range and y < focus_range) then
                new_focus_ent = but
                focus_stick = CurTime() + 0.1
                is_focused = true
            end
        end

        if is_focused then
            surface.SetMaterial(mh("zames/warning.png"))
            surface.SetDrawColor(255, 255, 255, 200)
            surface.DrawTexturedRect(scrpos.x - mid, scrpos.y - mid, size, size)

            surface.SetTextColor(255, 50, 50, 255)
            surface.SetFont("PT.2")

            local txt_x = scrpos.x + size + 10
            local txt_y = scrpos.y - size - 3
            
            surface.SetTextPos(txt_x, txt_y)
            surface.DrawText(but:GetDescription() or "Ловушка")

            txt_y = txt_y + 15
            surface.SetTextPos(txt_x, txt_y)

            local delay = but:GetDelay() or 0
            if delay < 0 then
                surface.DrawText("Одноразовое использование.")
            elseif delay == 0 then
                surface.DrawText("Многоразовое использование.")
            else
                surface.DrawText("Перезарядка: " .. tostring(delay) .. " сек.")
            end

            txt_y = txt_y + 15
            surface.SetTextPos(txt_x, txt_y)
            local use_key = input.LookupBinding("+use") or "E"
            surface.DrawText("Нажмите [" .. use_key:upper() .. "], чтобы активировать.")
        else
            surface.SetMaterial(mh("zames/warning.png"))
            surface.SetDrawColor(255, 255, 255, 200 * (1 - d))
            surface.DrawTexturedRect(scrpos.x - mid, scrpos.y - mid, size, size)
        end
    end
    
    focus_ent = new_focus_ent
end)

hook.Add("KeyPress", "ButtonTraitorsPress", function(ply, key)
    if zs.RD.name != "hmcd" then return end
    
    if key == IN_USE and ply.roleT and IsValid(focus_ent) then
        RunConsoleCommand("ttt_use_tbutton", focus_ent:EntIndex())
    end
end)
