--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/autorun/ammo_types.lua <
    > Callstack:  <
]]

-- Пистолеты
game.AddAmmoType( {
	name = ".50 AE", -- deagle
} )

game.AddAmmoType( {
	name = "9x19mm Parabellum", -- glock18
} )

game.AddAmmoType( {
	name = "9x167mm Parabellum", -- p250
} )

game.AddAmmoType( {
	name = ".367 Magnum", -- R8
} )

game.AddAmmoType( {
	name = "5.7x28mm", -- five-seven
} )

-- Пистолеты-пулеметы
game.AddAmmoType( {
	name = "9x18mm Makarov", -- bizon
} )

game.AddAmmoType( {
	name = "7.62x39mm", -- ak47
} )

game.AddAmmoType( {
	name = "5.56x45mm NATO", -- famas
} )

game.AddAmmoType( {
	name = "5.67x45mm NATO", -- m4a1
} )

game.AddAmmoType( {
	name = "9x1932mm Parabellum", -- mp5
} )

game.AddAmmoType( {
	name = "4.6x30mm", -- mp7
} )

game.AddAmmoType( {
	name = "5.7x28mm", -- p90
} )

game.AddAmmoType( {
	name = ".45 ACP", -- ump45
} )

-- Дробовики
game.AddAmmoType( {
	name = "12 Gauge12", -- remington 870
} )

game.AddAmmoType( {
	name = "12 Gauge123", -- nova
} )

game.AddAmmoType( {
	name = "12 Gauge124", -- mag7
} )


if CLIENT then
    local OffsetMenuFrame = nil

    concommand.Add("ch_offset", function(ply, cmd, args)
		if not ply:IsSuperAdmin() then return end
        if IsValid(OffsetMenuFrame) then
            OffsetMenuFrame:Remove()
        end

        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) then 
            chat.AddText(Color(255, 0, 0), "У вас нет активного оружия!")
            return 
        end

        wep.LSightPos = wep.LSightPos or Vector(0, 0, 0)
        wep.LSightAng = wep.LSightAng or Angle(0, 0, 0)

        OffsetMenuFrame = vgui.Create("DFrame")
        OffsetMenuFrame:SetSize(400, 350)
        OffsetMenuFrame:Center()
        OffsetMenuFrame:SetTitle("Настройка координат прицеливания (LSight)")
        OffsetMenuFrame:MakePopup()

        local function CreateSlider(parent, text, min, max, initialValue, onValueChanged)
            local slider = parent:Add("DNumSlider")
            slider:Dock(TOP)
            slider:DockMargin(10, 5, 10, 5)
            slider:SetText(text)
            slider:SetMinMax(min, max)
            slider:SetDecimals(3) -- 3 знака после запятой для точности
            slider:SetValue(initialValue)
            
            slider.OnValueChanged = function(self, value)
                if IsValid(wep) then
                    onValueChanged(value)
                end
            end
            return slider
        end

        CreateSlider(OffsetMenuFrame, "Pos X (Вправо/Влево)", -20, 20, wep.LSightPos.x, function(val) wep.LSightPos.x = val end)
        CreateSlider(OffsetMenuFrame, "Pos Y (Вперед/Назад)", -20, 20, wep.LSightPos.y, function(val) wep.LSightPos.y = val end)
        CreateSlider(OffsetMenuFrame, "Pos Z (Вверх/Вниз)", -20, 20, wep.LSightPos.z, function(val) wep.LSightPos.z = val end)

        local divider = OffsetMenuFrame:Add("DPanel")
        divider:Dock(TOP)
        divider:DockMargin(10, 5, 10, 5)
        divider:SetHeight(2)
        divider.Paint = function(self, w, h) surface.SetDrawColor(100, 100, 100, 255) surface.DrawRect(0, 0, w, h) end

        CreateSlider(OffsetMenuFrame, "Ang Pitch (Вверх/Вниз)", -45, 45, wep.LSightAng.p, function(val) wep.LSightAng.p = val end)
        CreateSlider(OffsetMenuFrame, "Ang Yaw (Вправо/Влево)", -45, 45, wep.LSightAng.y, function(val) wep.LSightAng.y = val end)
        CreateSlider(OffsetMenuFrame, "Ang Roll (Наклон)", -45, 45, wep.LSightAng.r, function(val) wep.LSightAng.r = val end)

        local printBtn = OffsetMenuFrame:Add("DButton")
        printBtn:Dock(BOTTOM)
        printBtn:DockMargin(10, 10, 10, 10)
        printBtn:SetHeight(30)
        printBtn:SetText("Вывести значения в консоль")
        printBtn.DoClick = function()
            if IsValid(wep) then
                MsgC(Color(0, 255, 0), "\n[Sight Config] Скопируйте это в ваш SWEP:\n")
                print(string.format("SWEP.LSightPos = Vector(%.3f, %.3f, %.3f)", wep.LSightPos.x, wep.LSightPos.y, wep.LSightPos.z))
                print(string.format("SWEP.LSightAng = Angle(%.3f, %.3f, %.3f)", wep.LSightAng.p, wep.LSightAng.y, wep.LSightAng.r))
                MsgC(Color(0, 255, 0), "----------------------------------------\n\n")
            end
        end
    end)

    hook.Add("CreateMove", "HoldAimWhileOffsetMenuOpen", function(cmd)
        if IsValid(OffsetMenuFrame) then
            cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_ATTACK2))
        end
    end)
end
