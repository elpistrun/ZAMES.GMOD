--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/r6cn3b_d/sh_8mg5dc5qg.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:26
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

local meta = FindMetaTable("Player")

function meta:SyncInventory()
    if SERVER then
        net.Start("SyncInventory")
        net.WriteTable(self:GetInventory())
        net.Send(self)
    end
end

function meta:GetInventory()
    self.Inventory = self.Inventory or {}
    return self.Inventory
end

function meta:SetInventory(items_tbl)
    self.Inventory = items_tbl or {}
    if SERVER then 
        SavePlayerInventory(self) 
        self:SyncInventory()
    end
end

function meta:AddItem(item_class, amount)
    amount = math.floor(tonumber(amount) or 1)
    if amount <= 0 then return end

    local inv = self:GetInventory()
    inv[item_class] = (inv[item_class] or 0) + amount
    
    if SERVER then 
        SavePlayerInventory(self) 
        self:SyncInventory()
    end
end

function meta:RemoveItem(item_class, amount)
    amount = math.floor(tonumber(amount) or 1)
    if amount <= 0 then return end

    local inv = self:GetInventory()
    if inv[item_class] then
        inv[item_class] = inv[item_class] - amount
        
        if inv[item_class] <= 0 then
            inv[item_class] = nil 

            -- для магаза
            if SERVER then
                if self.EquippedVoiceFigure == item_class then
                    self:SetNWString("VoiceFigure", "zames/models/circle.png")
                    self.EquippedVoiceFigure = nil
                    self:RemovePData("EquippedVoiceFigure")
                end
                
                if self.EquippedVoiceBG == item_class then
                    self:SetNWString("VoiceBG", "")
                    self.EquippedVoiceBG = nil
                    self:RemovePData("EquippedVoiceBG")
                end
                
                if self.EquipCustomSkinName == item_class then
                    self.EquipCustomSkinName = nil
                    self.EquipCustomSkin = nil
                    self:RemovePData("EquippedCustomSkinName")
                    self:RemovePData("EquippedCustomSkin")
                end
            end
            -- все
        end
        
        if SERVER then 
            SavePlayerInventory(self) 
            self:SyncInventory()
        end
    end
end

function meta:HasItem(item_class, amount)
    amount = math.floor(tonumber(amount) or 1)
    local inv = self:GetInventory()
    
    return (inv[item_class] or 0) >= amount
end

if SERVER then
    local function GetShopItemData(itemName)
        if figura and figura.ShopItems and figura.ShopItems[itemName] then
            return figura.ShopItems[itemName], "figure"
        end
        if ramka and ramka.ShopItems and ramka.ShopItems[itemName] then
            return ramka.ShopItems[itemName], "voice_bg"
        end
        if ramka_tab and ramka_tab.ShopItems and ramka_tab.ShopItems[itemName] then
            return ramka_tab.ShopItems[itemName], "tab_bg"
        end
        if personal and personal.ShopItems and personal.ShopItems[itemName] then
            return personal.ShopItems[itemName], "skin"
        end
        if film and film.ShopItems and film.ShopItems[itemName] then
            return film.ShopItems[itemName], "skin"
        end
        if games and games.ShopItems and games.ShopItems[itemName] then
            return games.ShopItems[itemName], "skin"
        end
        if anime and anime.ShopItems and anime.ShopItems[itemName] then
            return anime.ShopItems[itemName], "skin"
        end
        if meme and meme.ShopItems and meme.ShopItems[itemName] then
            return meme.ShopItems[itemName], "skin"
        end
        return nil, nil
    end

    net.Receive("Shop_BuyItem", function(len, ply)
        if not IsValid(ply) then return end

        local itemName = net.ReadString()
        local curType = net.ReadString()

        if not itemName or itemName == "" then return end
        if curType ~= "CFC" and curType ~= "GFC" then return end

        local itemData, cat = GetShopItemData(itemName)
        if not itemData then
            ply:ChatPrint("[Магазин] Товар не найден!")
            return
        end

        if ply:HasItem(itemName) then
            ply:ChatPrint("[Магазин] У вас уже есть этот предмет!")
            return
        end

        local cost = (curType == "CFC" and tonumber(itemData.cfc)) or (curType == "GFC" and tonumber(itemData.gfc)) or 0
        if cost <= 0 then
            ply:ChatPrint("[Магазин] Этот предмет недоступен для покупки за " .. curType .. "!")
            return
        end

        local currentMoney = (curType == "CFC" and ply:GetCFC()) or ply:GetGFC()
        if currentMoney < cost then
            ply:ChatPrint("[Магазин] Недостаточно средств (" .. curType .. ")!")
            return
        end

        if curType == "CFC" then
            ply:SetCFC(currentMoney - cost)
        else
            ply:SetGFC(currentMoney - cost)
        end

        ply:AddItem(itemName, 1)
    end)

    net.Receive("ApplyCustomization", function(len, ply)
        if not IsValid(ply) then return end

        local itemName = net.ReadString()
        local customType = net.ReadString()

        if customType == "figure" then
            if itemName == "reset" then
                ply:SetNWString("VoiceFigure", "zames/models/circle.png")
                ply.EquippedVoiceFigure = nil
            else
                if not ply:HasItem(itemName) then return end
                local itemData = figura and figura.ShopItems and figura.ShopItems[itemName]
                if itemData and itemData.icon then
                    ply:SetNWString("VoiceFigure", itemData.icon)
                    ply.EquippedVoiceFigure = itemName
                end
            end
        elseif customType == "bg" then
            if itemName == "reset" then
                ply:SetNWString("VoiceBG", "")
                ply.EquippedVoiceBG = nil
            else
                if not ply:HasItem(itemName) then return end
                local itemData = ramka and ramka.ShopItems and ramka.ShopItems[itemName]
                if itemData and itemData.icon then
                    ply:SetNWString("VoiceBG", itemData.icon)
                    ply.EquippedVoiceBG = itemName
                end
            end
        elseif customType == "tab" then
            if itemName == "reset" then
                ply:SetNWString("TabBG", "")
                ply.EquippedTabBG = nil
            else
                if not ply:HasItem(itemName) then return end
                local itemData = ramka_tab and ramka_tab.ShopItems and ramka_tab.ShopItems[itemName]
                if itemData and itemData.icon then
                    ply:SetNWString("TabBG", itemData.icon)
                    ply.EquippedTabBG = itemName
                end
            end
        end

        if SavePlayerData then
            SavePlayerData(ply)
        end
    end)

    net.Receive("ApplySkinCustomization", function(len, ply)
        if not IsValid(ply) then return end

        local itemName = net.ReadString()
        local modelPath = net.ReadString()

        if itemName == "reset" then
            ply.EquipCustomSkinName = nil
            ply.EquipCustomSkin = nil
            ply:SetNWString("CustomPlayerModel", "")

            -- Сбрасываем модель на обычную
            hook.Run("PlayerSetModel", ply)
        else
            if not ply:HasItem(itemName) then return end
            local itemData, _ = GetShopItemData(itemName)
            if itemData and itemData.model and util.IsValidModel(itemData.model) then
                ply.EquipCustomSkinName = itemName
                ply.EquipCustomSkin = itemData.model
                ply:SetNWString("CustomPlayerModel", itemData.model)
                ply:SetModel(itemData.model)
            end
        end

        if SavePlayerData then
            SavePlayerData(ply)
        end
    end)

    net.Receive("ApplySkinMaterial", function(len, ply)
        if not IsValid(ply) then return end
        local skinIndex = net.ReadInt(8)
        if skinIndex and skinIndex >= 0 then
            ply:SetSkin(skinIndex)
        end
    end)

    net.Receive("ApplySkinBodygroup", function(len, ply)
        if not IsValid(ply) then return end
        local bgIndex = net.ReadInt(8)
        local bgValue = net.ReadInt(8)
        if bgIndex and bgValue and bgIndex >= 0 and bgValue >= 0 then
            ply:SetBodygroup(bgIndex, bgValue)
        end
    end)
end

