--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | |\ | |\ |__)
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___)

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/lua/entities/ent_lootbox_base/shared.lua <
    > Callstack: addons/v1ph7p7m2n/lua/entities/ent_lootbox_base/cl_init.lua:1 <
]]

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Обычный контейнер"
ENT.Spawnable = true
ENT.Category = "Lootboxes"

ENT.NameModel = "models/sarma_crates/supply_crate02.mdl"
ENT.NumberSkin = 0

-- Модель нужна в определении, чтобы её видел и клиент до первого SetModel.
ENT.Model = ENT.NameModel

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "LootSkin")
end

-- ВАЖНО: base_gmodentity наследуется от base_anim и НЕ обрабатывает ENT.Model.
-- Модель обязан поставить серверный Initialize, иначе движок рисует models/error.mdl.
if SERVER then
    -- Открытие контейнера. ENT:Use движок вызывает сам при нажатии Use —
    -- это надёжнее хука PlayerUse. Логика лежит в sv_lootbox.lua, чтобы не
    -- дублировать её в трёх файлах.
    function ENT:Use(activator, caller)
        if ORP_Lootbox_Use then
            return ORP_Lootbox_Use(self, activator)
        end

        return false
    end

    function ENT:Initialize()
        self:SetModel(self.Model)

        -- Контейнер статичный: не катается, не может толкнуть или зажать игрока.
        self:PhysicsInit(SOLID_NONE)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_BBOX)
        self:SetUseType(SIMPLE_USE)
        self:DrawShadow(true)

        -- Если точка спавна занята игроком, контейнер бы запер его внутри себя.
        -- Отодвигаем контейнер от игрока, а не наоборот.
        for _, ply in ipairs(player.GetAll()) do
            local pmin, pmax = ply:GetPos() + ply:OBBMins(), ply:GetPos() + ply:OBBMaxs()
            local cmin, cmax = self:GetPos() + self:OBBMins(), self:GetPos() + self:OBBMaxs()
            if cmax.x > pmin.x and cmin.x < pmax.x
                and cmax.y > pmin.y and cmin.y < pmax.y
                and cmax.z > pmin.z and cmin.z < pmax.z then
                local dir = ply:GetPos() - self:GetPos()
                dir.z = 0
                if dir:LengthSqr() < 1 then dir = Vector(1, 0, 0) end
                self:SetPos(self:GetPos() - dir:GetNormalized() * 48)
                break
            end
        end

        if self.NumberSkin then
            self:SetLootSkin(self.NumberSkin)
        end
    end
end
