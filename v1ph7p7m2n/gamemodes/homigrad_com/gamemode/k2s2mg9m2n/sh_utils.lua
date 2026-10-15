--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/sh_utils.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:26
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

function SetupMat(path, anim, scale, custom_x, custom_y, custom_speed, mat2_path, custom_x2, custom_y2)
    return {
        mat = mh(path),
        mat2 = mat2_path and mh(mat2_path) or nil, -- Загружаем второй материал, если он указан
        anim = anim or "static",
        scale = scale or 1.0,
        x = custom_x,
        y = custom_y,
        x2 = custom_x2, -- Кастомный X для второго материала
        y2 = custom_y2, -- Кастомный Y для второго материала
        speed = custom_speed -- Сохраняем кастомную скорость
    }
end

function DrawBackgroundAnim(data, proshlo)
    if not data or not data.mat then return end

    local w, h = ScrW(), ScrH()
    local matW, matH = data.mat:Width(), data.mat:Height()
    local base_scale = math.max(w / matW, h / matH) * data.scale

    -- Переменные для первого материала
    local drawW, drawH = matW * base_scale, matH * base_scale
    local offset_x, offset_y = (w - drawW) / 2, (h - drawH) / 2
    
    -- Переменные для второго материала (если он есть)
    local drawW2, drawH2, offset_x2, offset_y2
    if data.mat2 then
        local matW2, matH2 = data.mat2:Width(), data.mat2:Height()
        drawW2, drawH2 = matW2 * base_scale, matH2 * base_scale
        offset_x2, offset_y2 = (w - drawW2) / 2, (h - drawH2) / 2
    end

    -- Обработка анимаций
    if data.anim == "anim_left" then
        local speed = data.speed or 25 
        offset_x = w + 450 - (proshlo * speed)

    elseif data.anim == "anim_right" then
        local speed = data.speed or 25 
        offset_x = -drawW + 450 + (proshlo * speed)

    elseif data.anim == "anim_zoom" then
        local scale_speed = data.speed or 0.03 
        local current_scale = base_scale * (1 + (proshlo * scale_speed))
        drawW, drawH = matW * current_scale, matH * current_scale
        offset_x = (w - drawW) / 2
        offset_y = (h - drawH) / 2

    elseif data.anim == "team_anim" and data.mat2 then
        local speed = data.speed or 150
        -- Первый материал выезжает слева в центр
        offset_x = -drawW + (proshlo * speed)
        
        -- Второй материал выезжает справа в центр
        offset_x2 = w - (proshlo * speed)

    elseif data.anim == "run_anim" and data.mat2 then
        local speed = data.speed or 25
        -- 1 материал стоит статичным по центру
        offset_x = (w - drawW) / 2
        
        -- 2 материал двигается в правую сторону
        offset_x2 = -drawW2 + 450 + (proshlo * speed)

    else 
        -- "static" или неизвестный режим (по центру)
        offset_x = (w - drawW) / 2
    end

    -- Вспомогательная функция для расчета Y
    local function CalculateOffsetY(custom_y, height)
        if custom_y then
            if custom_y == "bottom" then return h - height
            elseif custom_y == "top" then return 0
            else return ((h - height) / 2) + custom_y end
        end
        return (h - height) / 2
    end

    -- Применяем кастомные сдвиги для первого материала
    if data.x then offset_x = offset_x + data.x end
    offset_y = CalculateOffsetY(data.y, drawH)

    -- Отрисовка первого материала
    surface.SetMaterial(data.mat)
    surface.DrawTexturedRect(offset_x, offset_y, drawW, drawH)

    -- Отрисовка второго материала
    if data.mat2 then
        if data.x2 then offset_x2 = offset_x2 + data.x2 end
        offset_y2 = CalculateOffsetY(data.y2, drawH2)
        
        surface.SetMaterial(data.mat2)
        surface.DrawTexturedRect(offset_x2, offset_y2, drawW2, drawH2)
    end
end
