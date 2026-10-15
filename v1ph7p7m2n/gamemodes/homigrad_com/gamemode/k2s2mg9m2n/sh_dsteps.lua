--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/sh_dsteps.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:26
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

if !((game.SinglePlayer() and SERVER) or (!game.SinglePlayer() and CLIENT)) then return end

local dir = ")^dsteps/"
local chan = CHAN_AUTO
local lvl = 75

---------------------------------- GRASS
sound.Add({
    name = "dsteps_grass_walk",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "grass/grass_walk1.ogg",
        dir .. "grass/grass_walk2.ogg",
        dir .. "grass/grass_walk3.ogg",
        dir .. "grass/grass_walk4.ogg",
        dir .. "grass/grass_walk5.ogg",
        dir .. "grass/grass_walk6.ogg",
        dir .. "grass/grass_walk7.ogg",
        dir .. "grass/grass_walk8.ogg",
        dir .. "grass/grass_walk9.ogg",
        dir .. "grass/grass_walk10.ogg",
    }
})
sound.Add({
    name = "dsteps_grass_run",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "grass/grass_run1.ogg",
        dir .. "grass/grass_run2.ogg",
        dir .. "grass/grass_run3.ogg",
        dir .. "grass/grass_run4.ogg",
    }
})
sound.Add({
    name = "dsteps_grass_wander",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "grass/grass_wander1.ogg",
        dir .. "grass/grass_wander2.ogg",
        dir .. "grass/grass_wander3.ogg",
        dir .. "grass/grass_wander4.ogg",
        dir .. "grass/grass_wander5.ogg",
        dir .. "grass/grass_wander6.ogg",
    }
})
---------------------------------- CONCRETE
sound.Add({
    name = "dsteps_concrete_walk",
    channel = chan,
    level = lvl,
    pitch = 75,
    sound = {
        dir .. "stone/stone_walk1.ogg",
        dir .. "stone/stone_walk2.ogg",
        dir .. "stone/stone_walk3.ogg",
        dir .. "stone/stone_walk4.ogg",
        dir .. "stone/stone_walk5.ogg",
        dir .. "stone/stone_walk6.ogg",
        dir .. "stone/stone_walk7.ogg",
        dir .. "stone/stone_walk8.ogg",
        dir .. "stone/stone_walk9.ogg",
        dir .. "stone/stone_walk10.ogg",
        dir .. "stone/stone_walk11.ogg",
    }
})
sound.Add({
    name = "dsteps_concrete_run",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "concrete/concrete_run1.ogg",
        dir .. "concrete/concrete_run2.ogg",
        dir .. "concrete/concrete_run3.ogg",
        dir .. "concrete/concrete_run4.ogg",
        dir .. "concrete/concrete_run5.ogg",
        dir .. "concrete/concrete_run6.ogg",
        dir .. "concrete/concrete_run7.ogg",
        dir .. "concrete/concrete_run8.ogg",
        dir .. "concrete/concrete_run9.ogg",
        dir .. "concrete/concrete_run10.ogg",
        dir .. "concrete/concrete_run11.ogg",
    }
})
sound.Add({
    name = "dsteps_concrete_wander",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "concrete/concrete_wander1.ogg",
        dir .. "concrete/concrete_wander2.ogg",
        dir .. "concrete/concrete_wander3.ogg",
        dir .. "concrete/concrete_wander4.ogg",
        dir .. "concrete/concrete_wander5.ogg",
    }
})
---------------------------------- MARBLE (tile)
sound.Add({
    name = "dsteps_marble_walk",
    channel = chan,
    level = lvl,
    pitch = 85,
    sound = {
        dir .. "marble/marble_walk1.ogg",
        dir .. "marble/marble_walk2.ogg",
        dir .. "marble/marble_walk3.ogg",
        dir .. "marble/marble_walk4.ogg",
        dir .. "marble/marble_walk5.ogg",
        dir .. "marble/marble_walk6.ogg",
        dir .. "marble/marble_walk7.ogg",
        dir .. "marble/marble_walk8.ogg",
        dir .. "marble/marble_walk9.ogg",
        dir .. "marble/marble_walk10.ogg",
        dir .. "marble/marble_walk11.ogg",
    }
})
sound.Add({
    name = "dsteps_marble_run",
    channel = chan,
    level = lvl,
    pitch = 85,
    sound = {
        dir .. "marble/marble_run1.ogg",
        dir .. "marble/marble_run2.ogg",
        dir .. "marble/marble_run3.ogg",
        dir .. "marble/marble_run4.ogg",
        dir .. "marble/marble_run5.ogg",
        dir .. "marble/marble_run6.ogg",
        dir .. "marble/marble_run7.ogg",
        dir .. "marble/marble_run8.ogg",
        dir .. "marble/marble_run9.ogg",
        dir .. "marble/marble_run10.ogg",
        dir .. "marble/marble_run11.ogg",
    }
})
sound.Add({
    name = "dsteps_marble_wander",
    channel = chan,
    level = lvl,
    pitch = 85,
    sound = {
        dir .. "marble/marble_wander1.ogg",
        dir .. "marble/marble_wander2.ogg",
        dir .. "marble/marble_wander3.ogg",
        dir .. "marble/marble_wander4.ogg",
        dir .. "marble/marble_wander5.ogg",
        dir .. "marble/marble_wander6.ogg",
    }
})
---------------------------------- DIRT
sound.Add({
    name = "dsteps_dirt_walk",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "dirt/dirt_walk1.ogg",
        dir .. "dirt/dirt_walk2.ogg",
        dir .. "dirt/dirt_walk3.ogg",
        dir .. "dirt/dirt_walk4.ogg",
        dir .. "dirt/dirt_walk5.ogg",
        dir .. "dirt/dirt_walk6.ogg",
        dir .. "dirt/dirt_walk7.ogg",
        dir .. "dirt/dirt_walk8.ogg",
        dir .. "dirt/dirt_walk9.ogg",
        dir .. "dirt/dirt_walk10.ogg",
        dir .. "dirt/dirt_walk11.ogg",
    }
})
sound.Add({
    name = "dsteps_dirt_run",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "dirt/dirt_run1.ogg",
        dir .. "dirt/dirt_run2.ogg",
        dir .. "dirt/dirt_run3.ogg",
        dir .. "dirt/dirt_run4.ogg",
        dir .. "dirt/dirt_run5.ogg",
        dir .. "dirt/dirt_run6.ogg",
        dir .. "dirt/dirt_run7.ogg",
        dir .. "dirt/dirt_run8.ogg",
        dir .. "dirt/dirt_run9.ogg",
        dir .. "dirt/dirt_run10.ogg",
        dir .. "dirt/dirt_run11.ogg",
    }
})
sound.Add({
    name = "dsteps_dirt_wander",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "dirt/dirt_wander1.ogg",
        dir .. "dirt/dirt_wander2.ogg",
        dir .. "dirt/dirt_wander3.ogg",
        dir .. "dirt/dirt_wander4.ogg",
        dir .. "dirt/dirt_wander5.ogg",
    }
})
---------------------------------- SAND
sound.Add({
    name = "dsteps_sand_walk",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "sand/sand_walk1.ogg",
        dir .. "sand/sand_walk2.ogg",
        dir .. "sand/sand_walk3.ogg",
        dir .. "sand/sand_walk4.ogg",
        dir .. "sand/sand_walk5.ogg",
        dir .. "sand/sand_walk6.ogg",
        dir .. "sand/sand_walk7.ogg",
        dir .. "sand/sand_walk8.ogg",
        dir .. "sand/sand_walk9.ogg",
        dir .. "sand/sand_walk10.ogg",
        dir .. "sand/sand_walk11.ogg",
    }
})
sound.Add({
    name = "dsteps_sand_run",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "sand/sand_run1.ogg",
        dir .. "sand/sand_run2.ogg",
        dir .. "sand/sand_run3.ogg",
        dir .. "sand/sand_run4.ogg",
        dir .. "sand/sand_run5.ogg",
        dir .. "sand/sand_run6.ogg",
        dir .. "sand/sand_run7.ogg",
        dir .. "sand/sand_run8.ogg",
        dir .. "sand/sand_run9.ogg",
        dir .. "sand/sand_run10.ogg",
        dir .. "sand/sand_run11.ogg",
    }
})
sound.Add({
    name = "dsteps_sand_wander",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "dirt/dirt_wander1.ogg",
        dir .. "dirt/dirt_wander2.ogg",
        dir .. "dirt/dirt_wander3.ogg",
        dir .. "dirt/dirt_wander4.ogg",
        dir .. "dirt/dirt_wander5.ogg",
    }
})
---------------------------------- SNOW
sound.Add({
    name = "dsteps_snow_walk",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "snow/snow_walk1.ogg",
        dir .. "snow/snow_walk2.ogg",
        dir .. "snow/snow_walk3.ogg",
        dir .. "snow/snow_walk4.ogg",
        dir .. "snow/snow_walk5.ogg",
        dir .. "snow/snow_walk6.ogg",
        dir .. "snow/snow_walk7.ogg",
        dir .. "snow/snow_walk8.ogg",
        dir .. "snow/snow_walk9.ogg",
        dir .. "snow/snow_walk10.ogg",
        dir .. "snow/snow_walk11.ogg",
    }
})
sound.Add({
    name = "dsteps_snow_run",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "snow/snow_run1.ogg",
        dir .. "snow/snow_run2.ogg",
        dir .. "snow/snow_run3.ogg",
        dir .. "snow/snow_run4.ogg",
        dir .. "snow/snow_run5.ogg",
        dir .. "snow/snow_run6.ogg",
        dir .. "snow/snow_run7.ogg",
        dir .. "snow/snow_run8.ogg",
        dir .. "snow/snow_run9.ogg",
        dir .. "snow/snow_run10.ogg",
        dir .. "snow/snow_run11.ogg",
    }
})
sound.Add({
    name = "dsteps_snow_wander",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "snow/snow_wander1.ogg",
        dir .. "snow/snow_wander2.ogg",
        dir .. "snow/snow_wander3.ogg",
        dir .. "snow/snow_wander4.ogg",
        dir .. "snow/snow_wander5.ogg",
    }
})
---------------------------------- METAL BAR
sound.Add({
    name = "dsteps_metalbar_walk",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "metalbar/metalbar_walk1.ogg",
        dir .. "metalbar/metalbar_walk2.ogg",
        dir .. "metalbar/metalbar_walk3.ogg",
        dir .. "metalbar/metalbar_walk4.ogg",
        dir .. "metalbar/metalbar_walk5.ogg",
        dir .. "metalbar/metalbar_walk6.ogg",
        dir .. "metalbar/metalbar_walk7.ogg",
        dir .. "metalbar/metalbar_walk8.ogg",
        dir .. "metalbar/metalbar_walk9.ogg",
        dir .. "metalbar/metalbar_walk10.ogg",
        dir .. "metalbar/metalbar_walk11.ogg",
    }
})
sound.Add({
    name = "dsteps_metalbar_run",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "metalbar/metalbar_run1.ogg",
        dir .. "metalbar/metalbar_run2.ogg",
        dir .. "metalbar/metalbar_run3.ogg",
        dir .. "metalbar/metalbar_run4.ogg",
        dir .. "metalbar/metalbar_run5.ogg",
        dir .. "metalbar/metalbar_run6.ogg",
        dir .. "metalbar/metalbar_run7.ogg",
        dir .. "metalbar/metalbar_run8.ogg",
        dir .. "metalbar/metalbar_run9.ogg",
        dir .. "metalbar/metalbar_run10.ogg",
        dir .. "metalbar/metalbar_run11.ogg",
    }
})
sound.Add({
    name = "dsteps_metalbar_wander",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "metalbar/metalbar_wander1.ogg",
        dir .. "metalbar/metalbar_wander2.ogg",
        dir .. "metalbar/metalbar_wander3.ogg",
        dir .. "metalbar/metalbar_wander4.ogg",
        dir .. "metalbar/metalbar_wander5.ogg",
        dir .. "metalbar/metalbar_wander6.ogg",
    }
})
---------------------------------- METAL BOX (grates)
sound.Add({
    name = "dsteps_metalbox_walk",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "metalbox/metalbox_walk1.ogg",
        dir .. "metalbox/metalbox_walk2.ogg",
        dir .. "metalbox/metalbox_walk3.ogg",
        dir .. "metalbox/metalbox_walk4.ogg",
        dir .. "metalbox/metalbox_walk5.ogg",
        dir .. "metalbox/metalbox_walk6.ogg",
        dir .. "metalbox/metalbox_walk7.ogg",
        dir .. "metalbox/metalbox_walk8.ogg",
        dir .. "metalbox/metalbox_walk9.ogg",
    }
})
sound.Add({
    name = "dsteps_metalbox_run",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "metalbox/metalbox_run1.ogg",
        dir .. "metalbox/metalbox_run2.ogg",
        dir .. "metalbox/metalbox_run3.ogg",
        dir .. "metalbox/metalbox_run4.ogg",
        dir .. "metalbox/metalbox_run5.ogg",
        dir .. "metalbox/metalbox_run6.ogg",
        dir .. "metalbox/metalbox_run7.ogg",
        dir .. "metalbox/metalbox_run8.ogg",
        dir .. "metalbox/metalbox_run9.ogg",
        dir .. "metalbox/metalbox_run10.ogg",
    }
})
sound.Add({
    name = "dsteps_metalbox_wander",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "metalbox/metalbox_wander1.ogg",
        dir .. "metalbox/metalbox_wander2.ogg",
        dir .. "metalbox/metalbox_wander3.ogg",
        dir .. "metalbox/metalbox_wander4.ogg",
    }
})
---------------------------------- GLASS
sound.Add({
    name = "dsteps_glass_walk",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "glass/glass_hard1.ogg",
        dir .. "glass/glass_hit1.ogg",
        dir .. "glass/glass_hit2.ogg",
    }
})
sound.Add({
    name = "dsteps_glass_run",
    channel = chan,
    level = lvl * 1.5,
    sound = {
        dir .. "glass/glass_hard1.ogg",
        dir .. "glass/glass_hit1.ogg",
        dir .. "glass/glass_hit2.ogg",
    }
})
sound.Add({
    name = "dsteps_glass_wander",
    channel = chan,
    level = lvl,
    sound = {
        
    }
})
---------------------------------- MUD
sound.Add({
    name = "dsteps_mud_walk",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "mud/mud_walk1.ogg",
        dir .. "mud/mud_walk2.ogg",
        dir .. "mud/mud_walk3.ogg",
        dir .. "mud/mud_walk4.ogg",
        dir .. "mud/mud_walk5.ogg",
        dir .. "mud/mud_walk6.ogg",
    }
})
sound.Add({
    name = "dsteps_mud_run",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "mud/mud_walk1.ogg",
        dir .. "mud/mud_walk2.ogg",
        dir .. "mud/mud_walk3.ogg",
        dir .. "mud/mud_walk4.ogg",
        dir .. "mud/mud_walk5.ogg",
        dir .. "mud/mud_walk6.ogg",
    }
})
sound.Add({
    name = "dsteps_mud_wander",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "mud/mud_wander1.ogg",
        dir .. "mud/mud_wander2.ogg",
        dir .. "mud/mud_wander3.ogg",
        dir .. "mud/mud_wander4.ogg",
    }
})
---------------------------------- GRAVEL
sound.Add({
    name = "dsteps_gravel_walk",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "gravel/gravel_walk1.ogg",
        dir .. "gravel/gravel_walk2.ogg",
        dir .. "gravel/gravel_walk3.ogg",
        dir .. "gravel/gravel_walk4.ogg",
        dir .. "gravel/gravel_walk5.ogg",
        dir .. "gravel/gravel_walk6.ogg",
        dir .. "gravel/gravel_walk7.ogg",
        dir .. "gravel/gravel_walk8.ogg",
        dir .. "gravel/gravel_walk9.ogg",
    }
})
sound.Add({
    name = "dsteps_gravel_run",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "gravel/gravel_run1.ogg",
        dir .. "gravel/gravel_run2.ogg",
        dir .. "gravel/gravel_run3.ogg",
        dir .. "gravel/gravel_run4.ogg",
        dir .. "gravel/gravel_run5.ogg",
        dir .. "gravel/gravel_run6.ogg",
        dir .. "gravel/gravel_run7.ogg",
        dir .. "gravel/gravel_run8.ogg",
        dir .. "gravel/gravel_run9.ogg",
        dir .. "gravel/gravel_run10.ogg",
    }
})
sound.Add({
    name = "dsteps_gravel_wander",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "gravel/gravel_wander1.ogg",
        dir .. "gravel/gravel_wander2.ogg",
        dir .. "gravel/gravel_wander3.ogg",
    }
})
---------------------------------- WOOD
sound.Add({
    name = "dsteps_wood_walk",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "wood/wood_walk1.ogg",
        dir .. "wood/wood_walk2.ogg",
        dir .. "wood/wood_walk3.ogg",
        dir .. "wood/wood_walk4.ogg",
        dir .. "wood/wood_walk5.ogg",
        dir .. "wood/wood_walk6.ogg",
        dir .. "wood/wood_walk7.ogg",
        dir .. "wood/wood_walk8.ogg",
        dir .. "wood/wood_walk9.ogg",
        dir .. "wood/wood_walk10.ogg",
        dir .. "wood/wood_walk11.ogg",
    }
})
sound.Add({
    name = "dsteps_wood_run",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "wood/wood_walk1.ogg",
        dir .. "wood/wood_walk2.ogg",
        dir .. "wood/wood_walk3.ogg",
        dir .. "wood/wood_walk4.ogg",
        dir .. "wood/wood_walk5.ogg",
        dir .. "wood/wood_walk6.ogg",
        dir .. "wood/wood_walk7.ogg",
        dir .. "wood/wood_walk8.ogg",
        dir .. "wood/wood_walk9.ogg",
        dir .. "wood/wood_walk10.ogg",
        dir .. "wood/wood_walk11.ogg",
    }
})
sound.Add({
    name = "dsteps_wood_wander",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "squeakywood/squeakywood_wander1.ogg",
        dir .. "squeakywood/squeakywood_wander2.ogg",
        -- dir .. "squeakywood/squeakywood_wander3.ogg",
        -- dir .. "squeakywood/squeakywood_wander4.ogg",
        -- dir .. "squeakywood/squeakywood_wander5.ogg",
        dir .. "squeakywood/squeakywood_wander6.ogg",
        dir .. "squeakywood/squeakywood_wander7.ogg",
    }
})
---------------------------------- SQUEAKY WOOD
sound.Add({
    name = "dsteps_squeakywood_walk",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "squeakywood/squeakywood_walk1.ogg",
        dir .. "squeakywood/squeakywood_walk2.ogg",
        dir .. "squeakywood/squeakywood_walk3.ogg",
        dir .. "squeakywood/squeakywood_walk4.ogg",
        dir .. "squeakywood/squeakywood_walk5.ogg",
        dir .. "squeakywood/squeakywood_walk6.ogg",
        dir .. "squeakywood/squeakywood_walk7.ogg",
        dir .. "squeakywood/squeakywood_walk8.ogg",
        dir .. "squeakywood/squeakywood_walk9.ogg",
        dir .. "squeakywood/squeakywood_walk10.ogg",
        dir .. "squeakywood/squeakywood_walk11.ogg",
    }
})
sound.Add({
    name = "dsteps_squeakywood_run",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "squeakywood/squeakywood_walk1.ogg",
        dir .. "squeakywood/squeakywood_walk2.ogg",
        dir .. "squeakywood/squeakywood_walk3.ogg",
        dir .. "squeakywood/squeakywood_walk4.ogg",
        dir .. "squeakywood/squeakywood_walk5.ogg",
        dir .. "squeakywood/squeakywood_walk6.ogg",
        dir .. "squeakywood/squeakywood_walk7.ogg",
        dir .. "squeakywood/squeakywood_walk8.ogg",
        dir .. "squeakywood/squeakywood_walk9.ogg",
        dir .. "squeakywood/squeakywood_walk10.ogg",
        dir .. "squeakywood/squeakywood_walk11.ogg",
    }
})
sound.Add({
    name = "dsteps_squeakywood_wander",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "squeakywood/squeakywood_wander1.ogg",
        dir .. "squeakywood/squeakywood_wander2.ogg",
        dir .. "squeakywood/squeakywood_wander3.ogg",
        dir .. "squeakywood/squeakywood_wander4.ogg",
        dir .. "squeakywood/squeakywood_wander5.ogg",
        dir .. "squeakywood/squeakywood_wander6.ogg",
        dir .. "squeakywood/squeakywood_wander7.ogg",
    }
})
---------------------------------- WATER
sound.Add({
    name = "dsteps_water_walk",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "water/water_through1.ogg",
        dir .. "water/water_through2.ogg",
        dir .. "water/water_through3.ogg",
        dir .. "water/water_through4.ogg",
        dir .. "water/water_through5.ogg",
        dir .. "water/water_through6.ogg",
        dir .. "water/water_through7.ogg",
        dir .. "water/water_through8.ogg",
        dir .. "water/water_through9.ogg",
        dir .. "water/water_through10.ogg",
        dir .. "water/water_through11.ogg",
    }
})
sound.Add({
    name = "dsteps_water_run",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "water/water_through1.ogg",
        dir .. "water/water_through2.ogg",
        dir .. "water/water_through3.ogg",
        dir .. "water/water_through4.ogg",
        dir .. "water/water_through5.ogg",
        dir .. "water/water_through6.ogg",
        dir .. "water/water_through7.ogg",
        dir .. "water/water_through8.ogg",
        dir .. "water/water_through9.ogg",
        dir .. "water/water_through10.ogg",
        dir .. "water/water_through11.ogg",
    }
})
sound.Add({
    name = "dsteps_water_wander",
    channel = chan,
    level = lvl,
    sound = {
        dir .. "water/water_wander1.ogg",
        dir .. "water/water_wander2.ogg",
        dir .. "water/water_wander3.ogg",
        dir .. "water/water_wander4.ogg",
        dir .. "water/water_wander5.ogg",
    }
})



-- Local Functions ---------------------------
local matDir = {
    [MAT_GRASS] = "grass",
    [MAT_CONCRETE] = "concrete",
    [MAT_TILE] = "marble",
    [MAT_DIRT] = "dirt",
    [MAT_SAND] = "sand",
    [MAT_SNOW] = "snow",
    [MAT_METAL] = "metalbar",
    [MAT_GRATE] = "metalbox",
    [MAT_WOOD] = "wood",
    [MAT_GLASS] = "glass",
    [MAT_SLOSH] = "mud",

    [MAT_PLASTIC] = "concrete",
    [MAT_COMPUTER] = "metalbox",
    [MAT_VENT] = "metalbox",

    -- There isn't a material for every footstep noise, here's how we work around it
    [91] = "gravel",
    [92] = "squeakywood"
}

local soundIndex = {
    ["concrete"] = MAT_CONCRETE,
    ["metal"] = MAT_METAL,
    ["metalgrate"] = MAT_GRATE,
    ["duct"] = MAT_GRATE,
    ["grass"] = MAT_GRASS,
    ["dirt"] = MAT_DIRT,
    ["sand"] = MAT_SAND,
    ["mud"] = MAT_SLOSH,
    ["tile"] = MAT_TILE,

    ["gravel"] = 91,
    ["woodpanel"] = 92,
}

local function getFootstepSound(mat,moveMode,ply)
    --[[
    moveModes:
    0. Walk
    1. Sprint
    2. Wander (fidget)
    ]]
    local postfix = (moveMode == 2 and "wander") or (moveMode == 1 and "run") or "walk"
    local material
    if ply:WaterLevel() % 3 > 0 then
        material = "water"
    else
        material = matDir[mat]
    end

    return "dsteps_" .. (material or "dirt") .. "_" .. postfix
end

local function footTrace(ply,startPos)
    return util.TraceLine({
        start = startPos,
        endpos = startPos + Vector(0,0,-60),
        filter = ply
    })
end
local function getUnderFoot(ply,startPos,footOffset,snd)
    local footTr = footTrace(ply,startPos)
    if !footTr.Hit then -- If the foot is dangling off, use the other foot instead
        startPos = ply:LocalToWorld(Vector(0, footOffset * -1, 50))
        footTr = footTrace(ply,startPos)
        if !footTr.Hit then -- If that still doesn't work (e.g. tightropes), scan under the player
            footTr = footTrace(ply,ply:GetPos() + Vector(0,0,40))
        end
    end

    if snd and footTr.Hit then
        if footTr.MatType == MAT_CONCRETE and string.find(snd,"gravel") then
            footTr.MatType = 91
        elseif footTr.MatType == MAT_WOOD and string.find(snd,"woodpanel") then
            footTr.MatType = 92
        elseif footTr.MatType == MAT_DIRT and string.find(snd,"mud") then
            footTr.MatType = MAT_SLOSH
        end
    end

    return footTr
end

-- Hooks ---------------------------

function DSteps(ply,pos,foot,snd,vol)
    if string.find(snd,"ladder") or string.find(snd,"chainlink") then return end
    if !ply:OnGround() then return end

    if IsValid(ply:GetNWEntity("FakeRagdoll")) then return end

    if string.lower(ply:GetModel() or "") == "models/metrocopc14/metrocopc14base.mdl" then
        local gearSound = "npc/combine_soldier/gear" .. math.random(1, 6) .. ".wav"
        
        sound.Play(gearSound, pos, 75, math.random(90, 110), (vol or 1) * 0.8)
    end

    local footOffset = (foot - .5) * 15
    local startPos = ply:LocalToWorld(Vector(0, footOffset, 50))
    local footTr = getUnderFoot(ply,startPos,footOffset,snd)
    if footTr.MatType == nil then
        local ftSnd = string.Replace(snd,"player/footsteps/","")
        local catch = false
        
        for i,v in pairs(soundIndex) do
            if string.StartWith(ftSnd,i) then
                footTr.MatType = v
                catch = true
                break
            end
        end
        if !catch then return nil end
    end

    
    if ply.DStep_Fidget then
        sound.Play(getFootstepSound(footTr.MatType, 2,ply,snd),ply:GetPos(), lvl, 100, 1)
        ply.DStep_Fidget = nil
    elseif ply.DStep_HitGround ~= nil then
        for i = 1,2 do
            timer.Simple((i - 1) * math.Clamp(ply.DStep_HitGround - 70, 20, 70) / 1000,function()
                if !IsValid(ply) or ply.DStep_HitGround == nil then return end
    
                local footOffset = (i - .5) * 15
                local startPos = ply:LocalToWorld(Vector(0, footOffset, 50))
                local footTr = getUnderFoot(ply,startPos,footOffset,snd)
        
                sound.Play(getFootstepSound(footTr.MatType, 1,ply),ply:GetPos(), lvl, 125, 1)

                if i == 2 then
                    ply.DStep_HitGround = nil
                end
            end)
        end
    else
        sound.Play(getFootstepSound(footTr.MatType, ply:IsSprinting() and 1 or 0,ply),pos, (ply:Crouching() and lvl * .25) or lvl, 100, vol)
    end
end

hook.Add("PlayerFootstep","zzzzzz_dstep_main",function(ply,pos,foot,snd,vol)

    if IsValid(ply:GetNWEntity("FakeRagdoll")) then 
        return true -- Блокируем стандартные звуки шагов движка
    end

    if !ply.DStep_HitGround and !(string.find(snd,"ladder") or string.find(snd,"chainlink")) then
        DSteps(ply,pos,foot,snd,vol)
    end
end)

hook.Add("EntityEmitSound","zzzzz_dsteps_maskfootstep",function(data)
    local snd = data.SoundName
    if data.Entity:IsPlayer() and ((string.StartWith(snd,"player/footsteps/") and !(string.find(snd,"ladder") or string.find(snd,"chainlink"))) 
        or (string.StartWith(snd,"physics/") and !string.StartWith(snd,"physics/flesh/flesh_impact_bullet"))) then -- Hardcode for crowbar impact sounds
        return false -- Returning values in a hook is discouraged, but this case is specific enough for it not to cause conflicts
    end
end)

hook.Add("OnPlayerHitGround","dstep_fall",function(ply,inWater,onFloater,speed)
    if speed > 150 then
        ply.DStep_HitGround = speed
        DSteps(ply,ply:GetPos(),0,"")
    else
        ply.DStep_HitGround = nil
    end
end)

hook.Add("PlayerTick","dstep_fidget",function(ply,mv)
    if IsValid(ply:GetNWEntity("FakeRagdoll")) then return end

    local isStealthy = (mv:KeyDown(IN_WALK) or ply:Crouching())
    if mv:GetForwardSpeed() == 0 and mv:GetSideSpeed() == 0 then
        if ply.DStep_IsMoving and !isStealthy then
            if ply:OnGround() then
                ply.DStep_Fidget = true
                ply.DStep_HitGround = nil
                DSteps(ply,ply:GetPos(),0,"")
            end
            ply.DStep_IsMoving = nil
        end

        -- if !ply.DStep_IsMoving then
        --     if !ply.DStep_AngleSnap then
        --         ply.DStep_AngleSnap = ply:EyeAngles()
        --     elseif false then
        --         local footTr = getUnderFoot(ply,ply:GetPos(),Vector(0,0,0))
        --         sound.Play(getFootstepSound(footTr.MatType, 2,ply),footTr.HitPos, lvl, 100, 1)
        --         ply.DStep_AngleSnap = ply:EyeAngles()
        --     end
        -- end -- this shit's too complicated
    elseif !isStealthy then
        ply.DStep_IsMoving = true
    else
        ply.DStep_IsMoving = nil
    end

    if mv:KeyPressed(IN_JUMP) and ply:OnGround() and ply.DStep_IsMoving then
        ply.DStep_Fidget = true
        DSteps(ply,ply:GetPos(),0,"")
    end
end)
