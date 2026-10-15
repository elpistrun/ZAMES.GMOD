--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/cl_0pre.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

cache_mat = cache_mat or {}
cache_mat.list = cache_mat.list or {}

local list = cache_mat.list

local material_cache = {}

function mh(path)
    if not material_cache[path] then
        material_cache[path] = Material(path)
    end
    
    return material_cache[path]
end

function cache_mat.Add(model_name)
    if table.HasValue(list, model_name) then return end
    list[#list+1] = model_name
    cache_mat.max = math.max(cache_mat.max or 0, #list)
end

function cache_mat.AddByTreeFolder(path) 
    local files, dirs = file.Find("materials/" .. path .. "*", "GAME")

    for i = 1, #files do
        if string.GetExtensionFromFilename(files[i]) == "png" then
            cache_mat.Add(path .. files[i])
        end
    end
    
    for i = 1, #dirs do
        cache_mat.AddByTreeFolder(path .. dirs[i] .. "/")
    end

end

local materials_fps = 10

local function ProcessMaterials()
    
    if #list == 0 then return end

    loadingActive = true
    

    local processed = 0
    while processed < materials_fps and #list > 0 do
        local path = list[1]
        if path then
            table.remove(list, 1)

            mh(path)

            processed = processed + 1
        end
    end
    
    if #list > 0 then
        timer.Simple(0.033, ProcessMaterials)
    else
        if finishLoading then
            loadingActive = false
            finishLoading()
        end
    end
end

cache_mat.AddByTreeFolder("zames/")

hook.Add("InitPostEntity", "CacheMaterials", function()
    timer.Simple(0.1, function()

        totalMaterials = #list
        loadedCount = 0
        
        if totalMaterials > 0 then
            ProcessMaterials()
        end
    end)
end)
