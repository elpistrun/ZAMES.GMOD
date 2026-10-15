--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/lua/wos/dynabase/registers/zames_breath.lua <
    > Callstack: lua/wos/dynabase/loader/loader.lua:40
lua/wos/dynabase/loader/loader.lua:76
lua/wos/dynabase/loader/loader.lua:81
[C]:-1
lua/autorun/wiltos_dynabase_loader.lua:29 <
]]

wOS.DynaBase:RegisterSource({
    Name = "ZAMES Breath",
    Type = WOS_DYNABASE.EXTENSION,

    -- model paths per gender:
    Shared = "models/xdreanims/m_anm_slot_001.mdl",      -- default or neutral model
    Female = "models/xdreanims/f_anm_slot_001.mdl",    -- female-specific model (optional)
    Male   = "models/xdreanims/z_anm_slot_001.mdl"     -- optional if you have a male version
})

hook.Add("PreLoadAnimations", "wOS.DynaBase.ZamesBreath", function(gender)
    if gender == WOS_DYNABASE.SHARED then
        IncludeModel("models/xdreanims/m_anm_slot_001.mdl")
    elseif gender == WOS_DYNABASE.FEMALE then
        IncludeModel("models/xdreanims/f_anm_slot_001.mdl")
    elseif gender == WOS_DYNABASE.MALE then
        IncludeModel("models/xdreanims/m_anm_slot_001.mdl")
    end
end)

