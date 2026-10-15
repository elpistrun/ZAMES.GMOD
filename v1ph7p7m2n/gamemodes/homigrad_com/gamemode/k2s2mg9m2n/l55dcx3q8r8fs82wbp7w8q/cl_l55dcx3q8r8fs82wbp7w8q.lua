--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/l55dcx3q8r8fs82wbp7w8q/cl_l55dcx3q8r8fs82wbp7w8q.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

local CFG_SLOT_SIZE = 80   -- Размер одного слота (квадрат: ширина и высота)
local CFG_SPACING = 0      -- Расстояние между слотами
local CFG_PADDING = 10     -- Отступы от краев рамки до слотов

function draw.CircleProgress(x, y, radius, progress, color)
    local segments = 60
    local poly = {}
    table.insert(poly, {x = x, y = y})
    
    local fullSegments = math.floor(segments * progress)
    for i = 0, fullSegments do
        local a = math.rad((i / segments) * 360 - 90)
        table.insert(poly, {x = x + math.cos(a) * radius, y = y + math.sin(a) * radius})
    end
    
    if progress > 0 and progress < 1 then
        local a = math.rad(progress * 360 - 90)
        table.insert(poly, {x = x + math.cos(a) * radius, y = y + math.sin(a) * radius})
    end
    
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    draw.NoTexture()
    if #poly > 2 then
        surface.DrawPoly(poly)
    end
end

local gradientMat = Material("vgui/gradient-d")
local blurMat = Material("pp/blurscreen")

if IsValid(InventoryFrame) then InventoryFrame:Remove() end

if not IsValid(LootInventory_DrawModel) then
    LootInventory_DrawModel = ClientsideModel("models/error.mdl", RENDER_GROUP_OPAQUE_ENTITY)
    LootInventory_DrawModel:SetNoDraw(true)
end

net.Receive("LootInventory_OpenUI", function()
    local owner = net.ReadEntity()
    local ragdoll = net.ReadEntity()
    local wepData = net.ReadTable()
    local uiSlots = net.ReadInt(8) 
    local isLootbox = net.ReadBool() 

    -- Контейнер уже открыт: переписываем содержимое слотов на месте.
    -- Раньше окно пересоздавалось на каждое взятие предмета: список уходил в ноль
    -- и собирался заново, окно мигало и теряло анимацию.
    if IsValid(InventoryFrame) and InventoryFrame.Owner == owner
        and InventoryFrame.SetItems and not InventoryFrame.IsClosing then
        InventoryFrame:SetItems(wepData)
        return
    end
    
    if IsValid(InventoryFrame) then InventoryFrame:Remove() end
    
    InventoryFrame = vgui.Create("DFrame")
    InventoryFrame.Owner = owner
    InventoryFrame:SetSize(ScrW(), ScrH())
    InventoryFrame:SetPos(0, 0)
    InventoryFrame:SetTitle("")
    InventoryFrame:ShowCloseButton(false)
    InventoryFrame:SetDraggable(false)
    InventoryFrame:MakePopup()
    InventoryFrame:SetKeyboardInputEnabled(false)
    InventoryFrame:SetMouseInputEnabled(true)

    -- MakePopup захватывает мышь только вместе с фокусом, а фокус теряется,
    -- когда на экране есть другие панели. Курсор включаем явно и так же явно
    -- возвращаем игре при закрытии.
    gui.EnableScreenClicker(true)

    InventoryFrame.OnRemove = function(self)
        -- если рамку уже сменила следующая (сервер переслал список), курсор не трогаем
        if InventoryFrame ~= self then return end

        gui.EnableScreenClicker(false)
    end
    
    InventoryFrame:SetAlpha(0)
    InventoryFrame:AlphaTo(255, 0.3, 0)
    InventoryFrame.IsClosing = false

    InventoryFrame.IsTakingItem = false
    InventoryFrame.TakeQueue = {}
    InventoryFrame.Slots = {}
    
    function InventoryFrame:QueueItem(slotBtn, itemData)
        if not itemData then return end
        
        if self.CurrentTakingSlot == slotBtn then return end
        
        for _, queued in ipairs(self.TakeQueue) do
            if queued.slot == slotBtn then return end
        end
        
        table.insert(self.TakeQueue, {slot = slotBtn, item = itemData})
    end

    -- Обновление списка без пересоздания окна: сервер — источник истины, он
    -- присылает актуальный состав контейнера после каждой попытки взять предмет.
    function InventoryFrame:SetItems(data)
        -- slots и data перебираем по индексам: забранный предмет оставляет пустое
        -- место на своём слоте, чтобы оставшиеся не сдвигались влево.
        for i, slot in ipairs(self.Slots) do
            slot.ItemData = data and data[i] or nil
            slot.IsTaking = false
        end

        -- из очереди убираем то, чего в контейнере больше нет
        local present = {}
        for _, it in pairs(data or {}) do present[it.class] = true end

        for i = #self.TakeQueue, 1, -1 do
            if not present[self.TakeQueue[i].item.class] then
                table.remove(self.TakeQueue, i)
            end
        end
    end

    function InventoryFrame:DoClose()
        if self.IsClosing then return end
        self.IsClosing = true
        self.IsTakingItem = false
        self.TakeQueue = {}
        
        self:AlphaTo(0, 0.3, 0, function()
            if IsValid(self) then self:Remove() end
        end)
    end
    
    InventoryFrame.Paint = function(self, w, h)
        local fraction = self:GetAlpha() / 255
        
        local x, y = self:LocalToScreen(0, 0)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(blurMat)
        for i = 1, 3 do 
            blurMat:SetFloat("$blur", (i / 3) * 6 * fraction)
            blurMat:Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
        end
    end
    
    InventoryFrame.Think = function(self)
        local ply = LocalPlayer()
        
        if ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) then
            self:DoClose()
            return
        end
        
        -- У трупа цель — ragdoll, у контейнера трупа нет и сервер присылает NULL,
        -- поэтому раньше здесь стояло IsValid(nil) и рамка закрывалась в тот же кадр
        -- (лут было не рассмотреть). Для контейнера считаем дистанцию до него самого.
        local ref = isLootbox and owner or ragdoll
        local maxDist = isLootbox and 200 or 100

        if IsValid(ref) then
            if ply:GetPos():DistToSqr(ref:GetPos()) > (maxDist ^ 2) then
                self:DoClose()
            end
        else
            self:DoClose()
        end

        if input.IsKeyDown(KEY_LSHIFT) and input.IsMouseDown(MOUSE_LEFT) then
            local mx, my = gui.MousePos()
            for _, slot in ipairs(self.Slots) do
                if IsValid(slot) and slot.ItemData then
                    local sx, sy = slot:LocalToScreen(0, 0)
                    local sw, sh = slot:GetSize()
                    -- Если курсор находится над слотом, добавляем в очередь
                    if mx >= sx and mx <= sx + sw and my >= sy and my <= sy + sh then
                        self:QueueItem(slot, slot.ItemData)
                    end
                end
            end
        end

        if self.IsTakingItem then
            if CurTime() >= self.TakeEndTime then
                self.IsTakingItem = false
                if self.OnTakeFinish then
                    self.OnTakeFinish()
                end
                self.OnTakeFinish = nil
                self.CurrentTakingSlot = nil
            end
        else
            if #self.TakeQueue > 0 then
                local nextTask = table.remove(self.TakeQueue, 1)
                local slot = nextTask.slot
                local itm = nextTask.item
                
                if IsValid(slot) and slot.ItemData then
                    self.IsTakingItem = true
                    self.TakeEndTime = CurTime() + 0.5
                    self.CurrentTakingSlot = slot
                    
                    slot.IsTaking = true
                    slot.TakeStartTime = CurTime()
                    
                    surface.PlaySound("zames/vgui/looting_0" .. math.random(1,3) .. ".wav")
                    
                    self.OnTakeFinish = function()
                        if not IsValid(slot) then return end
                        
                        net.Start("LootInventory_TakeItem")
                        net.WriteEntity(owner)
                        net.WriteString(itm.class)
                        net.WriteBool(isLootbox)
                        net.SendToServer()
                        
                        -- Предмет у нас — слот сразу пустеет, не ждём ответа сервера.
                        -- Список на сервере — источник истины: он присылает актуальный
                        -- состав и после успеха, и после отказа (тогда слот вернётся).
                        -- А если предмет уже есть — он и не берётся, слот не трогаем.
                        if not ply:HasWeapon(itm.class) then
                            slot.ItemData = nil
                        end
                        
                        slot.IsTaking = false
                    end
                end
            end
        end
    end

    local frameWidth = (CFG_SLOT_SIZE * uiSlots) + (CFG_SPACING * (uiSlots - 1)) + (CFG_PADDING * 2)
    local frameHeight = CFG_SLOT_SIZE + (CFG_PADDING * 5.5)
    
    local LootFrame = vgui.Create("DPanel", InventoryFrame)
    LootFrame:SetSize(frameWidth, frameHeight)
    LootFrame:Center()
    LootFrame.Paint = function(self, w, h) end
    
    local grid = vgui.Create("DIconLayout", LootFrame)
    grid:Dock(FILL)
    grid:SetSpaceX(CFG_SPACING) 
    grid:SetSpaceY(0)
    
    for i = 1, uiSlots do
        local slotBtn = grid:Add("DButton")
        slotBtn:SetSize(CFG_SLOT_SIZE, CFG_SLOT_SIZE)
        slotBtn:SetText("")
        
        slotBtn.ItemData = wepData[i]
        slotBtn.IsTaking = false
        slotBtn.TakeStartTime = 0
        
        table.insert(InventoryFrame.Slots, slotBtn)
        
        slotBtn.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(32, 32, 32, 100))

            surface.SetDrawColor(255, 255, 255, 20)
            surface.DrawLine(0, 0, w, 0)
            surface.DrawLine(0, 0, 0, h)
            
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawLine(0, h-1, w, h-1)
            surface.DrawLine(w-1, 0, w-1, h)
            
            local item = self.ItemData
            
            if item then
                local itemClass = item.class or ""
                local isArmor = string.StartWith(itemClass, "ent_jack_gmod_ezarmor_")
                
                local wepTbl = weapons.Get(itemClass) or weapons.GetStored(itemClass)
                local entTbl = scripted_ents.GetStored(itemClass)
                
                local dispName = itemClass
                if wepTbl and wepTbl.PrintName then
                    dispName = wepTbl.PrintName
                elseif entTbl and entTbl.t and entTbl.t.PrintName then
                    dispName = entTbl.t.PrintName
                end

                local rarity = (GetItemRarity and GetItemRarity(itemClass)) or 1
                local rColor = (rarity_colors and rarity_colors[rarity]) or Color(255, 255, 255)

                surface.SetMaterial(gradientMat)
                surface.SetDrawColor(rColor.r, rColor.g, rColor.b, 100)
                surface.DrawTexturedRect(0, 0, w, h)

                if isArmor then
                    local iconMat = Material("entities/" .. itemClass .. ".png", "noclamp smooth")
                    if iconMat:IsError() then
                        iconMat = Material("entities/" .. itemClass .. ".jpg", "noclamp smooth")
                    end
                    
                    if not iconMat:IsError() then
                        surface.SetMaterial(iconMat)
                        surface.SetDrawColor(255, 255, 255, 255)
                        local iconSize = math.min(w, h) - 20
                        surface.DrawTexturedRect((w - iconSize) / 2, (h - iconSize) / 2 - 5, iconSize, iconSize)
                    end
                else
                    local mdl = (wepTbl and (wepTbl.WorldModel or wepTbl.Model or wepTbl.ViewModel)) or nil
                    if type(mdl) ~= "string" or mdl == "" then mdl = "models/error.mdl" end
                    local iconPos = (wepTbl and wepTbl.IconPos) or Vector(15, -5, -3)
                    local iconAng = (wepTbl and wepTbl.IconAng) or Angle(0, 90, 0)

                    if IsValid(LootInventory_DrawModel) then
                        if self.CurrentModel ~= mdl then
                            LootInventory_DrawModel:SetModel(mdl)
                            self.CurrentModel = mdl
                        end
                        
                        local screenX, screenY = self:LocalToScreen(0, 0)
                        local vec = Vector(0,0,0)
                        local ang = Angle(0,0,0)

                        cam.Start3D(vec, ang, 15, screenX, screenY, w - 5, h - 10, 5, 4096)
                            cam.IgnoreZ(true)
                            render.SuppressEngineLighting(true)
                            
                            render.SetLightingOrigin(vec)
                            render.ResetModelLighting(1, 1, 1)
                            render.SetColorModulation(1, 1, 1)
                            
                            render.SetBlend(InventoryFrame:GetAlpha() / 255) 
                            render.SetModelLighting(4, 1, 1, 1)
                            
                            LootInventory_DrawModel:SetRenderOrigin(iconPos)
                            LootInventory_DrawModel:SetRenderAngles(iconAng)
                            LootInventory_DrawModel:DrawModel()
                            
                            LootInventory_DrawModel:SetRenderOrigin()
                            LootInventory_DrawModel:SetRenderAngles()
                            
                            render.SetColorModulation(1, 1, 1)
                            render.SetBlend(1)
                            render.SuppressEngineLighting(false)
                            cam.IgnoreZ(false)
                        cam.End3D()
                    end
                end
                
                local textBgHeight = 16
                
                surface.SetDrawColor(0, 0, 0, 200) 
                surface.DrawRect(0, h - textBgHeight, w, textBgHeight)
                
                surface.SetDrawColor(0, 0, 0, 255)
                surface.DrawLine(0, h - textBgHeight, w, h - textBgHeight)

                draw.SimpleText(dispName, "PT.5", w/2, h - (textBgHeight / 2), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            
            if self:IsHovered() then
                surface.SetDrawColor(255, 255, 255, 20)
                surface.DrawLine(0, 0, w, 0)
                surface.DrawLine(0, 0, 0, h)
                
                surface.SetDrawColor(0, 0, 0, 200)
                surface.DrawLine(0, h-1, w, h-1)
                surface.DrawLine(w-1, 0, w-1, h)
            end
        end

        slotBtn.PaintOver = function(self, w, h)
            local inQueue = false
            if InventoryFrame.TakeQueue then
                for _, q in ipairs(InventoryFrame.TakeQueue) do
                    if q.slot == self then inQueue = true break end
                end
            end

            if self.IsTaking then
                local progress = math.Clamp((CurTime() - self.TakeStartTime) / 0.5, 0, 1)
                
                draw.CircleProgress(w / 2, h / 2.3, 25, 1, Color(0, 0, 0, 150))
                draw.CircleProgress(w / 2, h / 2.3, 25, progress, Color(255, 255, 255, 255))
            elseif inQueue then
                draw.CircleProgress(w / 2, h / 2.3, 25, 1, Color(0, 0, 0, 150))
            end
        end
        
        slotBtn.DoClick = function(self)
            if self.ItemData then
                InventoryFrame:QueueItem(self, self.ItemData)
            end
        end
    end
end)


-- cl_zames_select.lua

local cfg = {
    active_w = 255,
    active_h = 200,
    inactive_w = 80,
    inactive_h = 50,
    font = "PT.2",
    textColor = color_white,
    boxColor = Color(82, 82, 82, 150),
    margin = 5,
    closeTime = 3,
    
    sound_scroll = "zames/vgui/roller_01.wav", 
    sound_select = "zames/vgui/select.wav",
    
    anim_speed = 15
}

local menuOpen = false
local closeTimer = 0
local selectedSlot = 1
local selectedIndex = 1
local weaponCache = {}
local animData = {}

hook.Add("HUDShouldDraw", "HideDefaultWeaponSelect", function(name)
    if name == "CHudWeaponSelection" then return false end
end)

local function UpdateWeaponCache()
    local weps = LocalPlayer():GetWeapons()
    weaponCache = {{}, {}, {}, {}, {}, {}}
    
    for _, wep in ipairs(weps) do
        local slot = wep:GetSlot() + 1
        if slot >= 1 and slot <= 6 then
            table.insert(weaponCache[slot], wep)
        end
    end

    for i = 1, 6 do
        table.sort(weaponCache[i], function(a, b) return a:GetSlotPos() < b:GetSlotPos() end)
    end
end

local function DrawZamesPanel(x, y, w, h)
    draw.RoundedBox(0, x, y, w, h, cfg.boxColor)

    surface.SetDrawColor(255, 255, 255, 20)
    surface.DrawLine(x, y, x + w, y)
    surface.DrawLine(x, y, x, y + h)
    
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawLine(x, y + h - 1, x + w, y + h - 1)
    surface.DrawLine(x + w - 1, y, x + w - 1, y + h)
end

hook.Add("HUDPaint", "DrawZamesWeaponSelect", function()
    if not menuOpen or closeTimer < CurTime() then 
        menuOpen = false 
        return 
    end

    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    UpdateWeaponCache()

    local startX = ScrW() / 2 - 300
    local startY = 50
    local curX = startX

    for slot = 1, 6 do
        local wepsInSlot = weaponCache[slot]
        
        animData[slot] = animData[slot] or { width = cfg.inactive_w, items = {} }
        
        if #wepsInSlot > 0 then
            local curY = startY
            
            local targetWidth = (slot == selectedSlot) and cfg.active_w or cfg.inactive_w
            animData[slot].width = Lerp(FrameTime() * cfg.anim_speed, animData[slot].width, targetWidth)
            local colWidth = animData[slot].width

            if slot == selectedSlot then
                for index, wep in ipairs(wepsInSlot) do
                    local isWepActive = (index == selectedIndex)
                    
                    animData[slot].items[index] = animData[slot].items[index] or { height = cfg.inactive_h }
                    local targetHeight = isWepActive and cfg.active_h or cfg.inactive_h
                    animData[slot].items[index].height = Lerp(FrameTime() * cfg.anim_speed, animData[slot].items[index].height, targetHeight)
                    
                    local h = animData[slot].items[index].height
                    
                    DrawZamesPanel(curX, curY, colWidth, h)
                    
                    if isWepActive then
                        if index == 1 then
                            draw.SimpleText(slot, cfg.font, curX + 10, curY + 10, cfg.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        end

                        if wep.CustomWeaponIcon then
                            surface.SetDrawColor(255, 255, 255, 255)
                            surface.SetMaterial(wep.CustomWeaponIcon)
                            
                            local boxW = colWidth - 20
                            local boxH = h - 20
                            local size = math.min(boxW, boxH)
                            
                            local iconX = curX + 10 + (boxW - size) / 2
                            local iconY = curY - 10 + (boxH - size) / 2
                            
                            surface.DrawTexturedRect(iconX, iconY, size, size)
                        elseif type(wep.DrawWeaponSelection) == "function" then
                            wep:DrawWeaponSelection(curX + 10, curY - 10, colWidth - 20, h - 40, 255)
                        end
                        
                        if h > cfg.inactive_h + 20 then
                            draw.SimpleText(wep:GetPrintName(), cfg.font, curX + colWidth/2, curY + h - 20, cfg.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        end
                    else
                        if index == 1 then
                            draw.SimpleText(slot, cfg.font, curX + 10, curY + 10, cfg.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        end
                        
                        if h < cfg.active_h - 20 then
                            draw.SimpleText(wep:GetPrintName(), cfg.font, curX + colWidth/2, curY + h/2, cfg.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        end
                    end
                    
                    curY = curY + h + cfg.margin
                end
            else
                DrawZamesPanel(curX, curY, colWidth, 80)
                draw.SimpleText(slot, cfg.font, curX + 10, curY + 10, cfg.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end
            
            curX = curX + colWidth + cfg.margin
        end
    end
end)

hook.Add("PlayerBindPress", "ZamesWeaponSelectInput", function(ply, bind, pressed)
    if not IsValid(ply) or not ply:Alive() then return end
    if #ply:GetWeapons() == 0 then return end
    
    if not pressed then return end

    local function OpenMenu()
        menuOpen = true
        closeTimer = CurTime() + cfg.closeTime
        UpdateWeaponCache()
    end

    if string.find(bind, "invnext") then
        OpenMenu()
        surface.PlaySound(cfg.sound_scroll)
        
        if weaponCache[selectedSlot] and selectedIndex < #weaponCache[selectedSlot] then
            selectedIndex = selectedIndex + 1
        else
            repeat
                selectedSlot = selectedSlot + 1
                if selectedSlot > 6 then selectedSlot = 1 end
            until #weaponCache[selectedSlot] > 0
            selectedIndex = 1
        end
        return true
        
    elseif string.find(bind, "invprev") then
        OpenMenu()
        surface.PlaySound(cfg.sound_scroll)
        
        if selectedIndex > 1 then
            selectedIndex = selectedIndex - 1
        else
            repeat
                selectedSlot = selectedSlot - 1
                if selectedSlot < 1 then selectedSlot = 6 end
            until #weaponCache[selectedSlot] > 0
            selectedIndex = #weaponCache[selectedSlot]
        end
        return true
    end

    for i = 1, 6 do
        if string.find(bind, "slot" .. i) then
            OpenMenu()
            
            if #weaponCache[i] > 0 then
                surface.PlaySound(cfg.sound_scroll)
                if selectedSlot == i then
                    selectedIndex = selectedIndex + 1
                    if selectedIndex > #weaponCache[i] then selectedIndex = 1 end
                else
                    selectedSlot = i
                    selectedIndex = 1
                end
            end
            return true
        end
    end

    if string.find(bind, "+attack") and menuOpen then
        local wep = weaponCache[selectedSlot][selectedIndex]
        if IsValid(wep) then
            surface.PlaySound(cfg.sound_select)
            input.SelectWeapon(wep)
        end
        menuOpen = false
        closeTimer = 0
        return true
    end
end)
