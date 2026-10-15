--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/sh_broadcast.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:26
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

local cv_podskaski = CreateClientConVar("zs_podskaski", "1", true, false, "Подсказки в игре")


if CLIENT then

    local hintMessages = {
        "Чтобы залутать контейнер/игрока то возьмите руки и нажмите ПКМ+E",
        "Чтобы пинать надо все волишь прописать в консоли - bind b zs_kick",
        "Если у вас есть аптечка, то вы можете зажать ПКМ чтобы начать лечить себя",
        "Следите за своим здоровьем и вовремя используйте аптечки.",
        "Если вы купите привелегию OPERATOR то у вас откроется множество возможностей.",
        "Если вы у трупа нашли оружие такое-же как и у вас в инвентаре, то при взятии возьмутся только его патроны.",
        "Если вы найдете в контейнере похожий предмет , который сейчас у вас есть то вы не сможете его подобрать.",
        "Чтобы выключить подсказки ESC-Настройки-Подсказки",
        "Чтобы заработать коины и приобрести что-то в магазине, играй за трейтора , победи в режиме dm , победи в режиме trasher",
        "Чтобы получить рамку ZAMES нужно стать трейтором 50 раз! (1500 / 30 = 50!)",
        "Чтобы начать зарабатывать коины на сервере должно быть минимум 15 игроков.",
        "При растяге регдоллов в макаронины требуется отключить все аддоны и перезайти на сервер!",
        "Зажав SHIFT и зажав ЛКМ , и провести по всем слотам то если там был предмет то они все постепенно заберутся.",
    }

    timer.Create("ZS_RandomHintsTimer", 120, 0, function()
        if cv_podskaski:GetBool() then
            local randomHint = table.Random(hintMessages)
            
            chat.AddText(Color(255, 166, 0), "[Подсказка] ", Color(255, 255, 255), randomHint)
        end
    end)
end


if SERVER then
    util.AddNetworkString("ReklamaTextMsg")

    function reklamatext(id, interval, text)
        local timerName = "ReklamaTimer_" .. tostring(id)
        
        timer.Create(timerName, interval, 0, function()
            net.Start("ReklamaTextMsg")
            net.WriteString(text)
            net.Broadcast()
        end)
    end

    reklamatext("main_promo", 700, 
    [[
    ** -------------------------------------------------- **
    ** Добро пожаловать на сервер**clr(255,0,0)** Z**clr(255,255,255)**AMES **
    ** Правила сервера - ** https://clck.ru/3VeYt8
    $$ -------------------------------------------------- $$
    :uhh: ** Наши соц.сети: **
    ** Наш сайт - ** https://clck.ru/3VeYoQ
    ** Discord - ** https://discord.gg/qqtvS5jfRs

    ** -------------------------------------------------- **
    ]]
    )


    reklamatext("piar_promo", 400, 
    [[
    ** -------------------------------------------------- **
    ** 👤- Хочу снимать видео и получать 1000 CFC  **
    ** очень быстро и получить **clr(0,183,255)**OPERATOR**clr(255,255,255) **бесплатно! **
    clr(255,0,0)** Z**clr(255,255,255)**AMES ** **- Стань нашим**clr(247,98,98)** ПИАР-АГЕНТОМ** clr(255,0,0)**!!! **clr(255,255,255)**Инфа в**
    ** Discord, в канале - "💖 | заявка-на-пиар-агента"**

    ** -------------------------------------------------- **
    ]]
    )
    
end


if CLIENT then
    net.Receive("ReklamaTextMsg", function()
        local rawText = net.ReadString()
        
        local lines = string.Explode("\n", rawText)
        
        for _, line in ipairs(lines) do
            line = string.TrimRight(line, "\r")
            if line == "" then continue end
            
            local chatArgs = {}
            table.insert(chatArgs, Color(255, 255, 255))
            
            local parts = string.Explode("clr(", line)
            
            if parts[1] and parts[1] ~= "" then
                table.insert(chatArgs, parts[1])
            end
            
            for i = 2, #parts do
                local part = parts[i]
                local endPos = string.find(part, ")")
                
                if endPos then
                    local rgbStr = string.sub(part, 1, endPos - 1)
                    local textStr = string.sub(part, endPos + 1)
                    
                    local rgb = string.Explode(",", rgbStr)
                    local r = tonumber(rgb[1]) or 255
                    local g = tonumber(rgb[2]) or 255
                    local b = tonumber(rgb[3]) or 255
                    
                    table.insert(chatArgs, Color(r, g, b))
                    
                    if textStr ~= "" then
                        table.insert(chatArgs, textStr)
                    end
                else
                    table.insert(chatArgs, "clr(" .. part)
                end
            end
            
            chat.AddText(unpack(chatArgs))
        end
    end)
end
