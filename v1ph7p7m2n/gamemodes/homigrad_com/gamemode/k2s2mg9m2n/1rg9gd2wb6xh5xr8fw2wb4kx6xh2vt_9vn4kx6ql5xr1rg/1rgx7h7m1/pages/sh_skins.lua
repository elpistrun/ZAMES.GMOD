--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/1rg9gd2wb6xh5xr8fw2wb4kx6xh2vt_9vn4kx6ql5xr1rg/1rgx7h7m1/pages/sh_skins.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:26
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

film = film or {}
anime = anime or {}
meme = meme or {}
games = games or {}
personal = personal or {}

personal.ShopItems = {
    ["personal_furry"] = {name = "Фурри", model = "models/lightshoro_workshop/goofycat/boykisser_v2o.mdl", persona = true},
    ["personal_gra"] = {name = "Gra-gra", model = "models/jeff/swag/jeff_pm.mdl", persona = true},
    ["personal_bear"] = {name = "Медведь", model = "models/player/open season/boog.mdl", persona = true, camZ = 90},
    ["personal_gosuslug"] = {name = "Райан Госуслуг", model = "models/player/joe/k_pm.mdl", persona = true},
    ["personal_sevun"] = {name = "Севун", model = "models/xinus22/sevyn.mdl", persona = true, camZ = 55},
    ["personal_ino"] = {name = "Инопрошелإينا", model = "models/electric/alien_pm.mdl", persona = true, camZ = 45},
    ["personal_skuf"] = {name = "Скуф", model = "models/dawson/obese_male_deluxe_edition/obese_male_gregory_01.mdl", persona = true},
    ["personal_val"] = {name = "Валакас", model = "models/yariktriplesix/valakas/valakas.mdl", persona = true},
    ["personal_nico"] = {name = "Нико Арк", model = "models/player/neco_arc_pm.mdl", persona = true},
    ["personal_fish"] = {name = "Карась", model = "models/player/karasik.mdl", persona = true},
    ["personal_general"] = {name = "Генерал Яйца", model = "models/player/aarmy/saxton_vannacci_v4.mdl", persona = true},
    ["personal_mike"] = {name = "Майк", model = "models/player/dewobedil/mike_myers/default_p.mdl", persona = true},
}

film.ShopItems = {
    ["film_homelander"] = {name = "Хом Лендер", model = "models/bread/cod/characters/the_boys/homelander.mdl", cfc = 7500, gfc = 350},
    ["film_gofman"] = {name = "Игорь Гуфман", model = "models/panman/igor_gofman_pm.mdl", cfc = 1850, gfc = 200},
    ["film_jessev"] = {name = "Джессеф", model = "models/player/jessev2.mdl", cfc = 1500, gfc = 200},
    ["film_borat"] = {name = "Борат", model = "models/panman/borat_cosplayer_09.mdl", cfc = 1500, gfc = 200},
    ["film_thief"] = {name = "Вор", model = "models/humans/intruder/intruder_pm.mdl", cfc = 1400, gfc = 200},
    ["film_unknown"] = {name = "...", model = "models/dejtriyev/scaryblackman.mdl", cfc = 3400, gfc = 200},
    ["film_dexter"] = {name = "Декстер", model = "models/Dexter_Morgan.mdl", cfc = 4500, gfc = 200},
    ["film_steve"] = {name = "I`m a Steve", model = "models/player/purpl/filmsteve.mdl", cfc = 3800, gfc = 200},
    ["film_superman"] = {name = "Супер-мэн", model = "models/player/purpl/fortnite/superman2025.mdl", cfc = 6800, gfc = 350},
}

games.ShopItems = {
    ["game_gordon"] = {name = "Горден Фриман", model = "models/gfreakman/gordonf_highpoly.mdl", cfc = 2850, gfc = 200},
    ["game_hazmat"] = {name = "Хазмат", model = "models/ppt/player/pt_worker_hazmat.mdl", cfc = 4500, gfc = 200},
    ["game_runner"] = {name = "Runner", model = "models/runner/playerm/runnerM.mdl", cfc = 4500, gfc = 200},
    ["game_worker04"] = {name = "Рабочий 04", model = "models/worker_04/worker_04.mdl", cfc = 4500, gfc = 200},
}

anime.ShopItems = {
    ["anime_joker"] = {name = "Джокер", model = "models/persona_nk/joker/joker_p5.mdl", cfc = 6500, gfc = 200},
    ["anime_compa"] = {name = "Компушечка", model = "models/player_compa.mdl", cfc = 4500, gfc = 200},
    ["anime_cat"] = {name = "Дуся", model = "models/konnie/asapgaming/meowscles.mdl", cfc = 3800, gfc = 200},

    ["anime_teto"] = {name = "Чурекенсио", model = "models/blop/mymy/mymy.mdl", cfc = 5800, gfc = 300},
}

meme.ShopItems = {
    ["meme_joker67"] = {name = "Джокер 67", model = "models/player/jonkler.mdl", cfc = 3500, gfc = 200},
    ["meme_billy"] = {name = "Гачи Муччи", model = "models/vinrax/player/Billy_Herrington.mdl", cfc = 2000, gfc = 200},
    
    ["meme_dosya"] = {name = "Дося", model = "models/nseven/citizen/feline_the_human-cat.mdl", cfc = 4000, gfc = 200},
    ["meme_orangutan"] = {name = "Орангутан", model = "models/vedatys/orangutan.mdl", cfc = 5500, gfc = 300, camZ = 50},
    ["meme_dr_tuff"] = {name = "Доктор Туфф", model = "models/Fozer/Memes/TuffDoctorPigeon.mdl", cfc = 1750, gfc = 200},
    ["meme_wapple"] = {name = "Человек-Яблоко", model = "models/panman/wapple_citizen.mdl", cfc = 2300, gfc = 200},
    ["meme_miyagi"] = {name = "Сын Мияги", model = "models/player/norrland/oogachakaBaby_pm.mdl", cfc = 6000, gfc = 300, camZ = 45},
    ["meme_stickman"] = {name = "Палочник", model = "models/player/pissbaby.mdl", cfc = 4750, gfc = 475},
    ["meme_wheelchair"] = {name = "Колясочник", model = "models/player/group02/wheelchair_man.mdl", cfc = 5800, gfc = 300, camZ = 45},

    ["meme_verity"] = {name = "Верити", model = "models/drm/the_pink_valley/tilin_drm.mdl", cfc = 5800, gfc = 300},

    ["meme_zelen"] = {name = "Зелениум", model = "models/player/zelenium.mdl", cfc = 6600, gfc = 350, camZ = 50},
}
