--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/lua/entities/ent_lootbox_base/cl_init.lua <
    > Callstack:  <
]]

include("shared.lua")

-- Запасная модель для клиентов без контента аддона: базовые HL2-ящики есть всегда.
-- Проверка один раз на сущность, а не каждый кадр.
local FALLBACK_MODELS = {
    "models/props_junk/wood_crate001a.mdl",
    "models/props_junk/wood_crate002a.mdl",
}

function ENT:Draw()
    if not self.DrawModelChecked then
        self.DrawModelChecked = true

        if not util.IsValidModel(self:GetModel()) then
            for _, mdl in ipairs(FALLBACK_MODELS) do
                if util.IsValidModel(mdl) then
                    self:SetModel(mdl)
                    break
                end
            end
        end
    end

    -- Skin сам по себе не реплицируется с сервера, поэтому берём его из NetworkVar
    -- NetworkVar доступен только через GetLootSkin(): поля self.LootSkin не существует
    local skin = self:GetLootSkin()
    if skin and self:GetSkin() ~= skin then
        self:SetSkin(skin)
    end

    self:DrawModel()
end
