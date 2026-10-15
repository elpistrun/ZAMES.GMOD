--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/3jp9vn6xh2wb3jp8mg8rf5xr/lua/autorun/sh_sentperf.lua <
    > Callstack:  <
]]

local cmd = SERVER and "red_sv_sentperf" or "red_cl_sentperf"
concommand.Add( cmd, function( ply, _, args )
    if SERVER and IsValid( ply ) and not ply:IsSuperAdmin() then
        return ply:ChatPrint( "No permission." )
    end

    if SENT_PERF_RUNNING then
        MsgC( softWhite, "Sent performance profiler is already running.\n" )
        return
    end

    SENT_PERF_RUNNING = true
    ENT_METHODS_ORIGINALS = ENT_METHODS_ORIGINALS or {}
    ENT_TABLE_ORIGINALS = ENT_TABLE_ORIGINALS or {}

    local lagTbl = {}

    local function wrapFunction( tbl, varName, original, className )
        local originInfo = debug.getinfo( original, "S" )
        local entOrigin = originInfo.short_src
        local linedefined = originInfo.linedefined
        local perfID = entOrigin .. ":" .. tostring( linedefined )

        local function wrapper( ... )
            local sysTime = SysTime()
            local a, b, c, d, e, f = original( ... )
            local elapsed = SysTime() - sysTime

            local info = lagTbl[perfID]
            if not info then
                local inCoroutine = coroutine.running()
                info = { class = className, varName = varName, count = 0, time = 0, origin = entOrigin, linedefined = linedefined, inCoroutine = inCoroutine }
                lagTbl[perfID] = info
            end

            info.count = info.count + 1
            info.time = info.time + elapsed

            return a, b, c, d, e, f
        end

        tbl[varName] = wrapper
    end

    for _, ent in ipairs( ents.GetAll() ) do
        if not ent:IsScripted() then continue end

        ENT_METHODS_ORIGINALS[ent] = ENT_METHODS_ORIGINALS[ent] or {}
        local entTable = ent:GetTable()
        for varName, var in pairs( entTable ) do
            if not isfunction( var ) then continue end
            ENT_METHODS_ORIGINALS[ent][varName] = var
            wrapFunction( entTable, varName, var, ent:GetClass() )
        end
    end

    for className, entry in pairs( scripted_ents.GetList() ) do
        local entTable = entry.t
        if not entTable then continue end

        ENT_TABLE_ORIGINALS[entTable] = ENT_TABLE_ORIGINALS[entTable] or {}
        for varName, var in pairs( entTable ) do
            if not isfunction( var ) then continue end
            ENT_TABLE_ORIGINALS[entTable][varName] = var
            wrapFunction( entTable, varName, var, className )
        end
    end

    local time = tonumber( args[1] ) or 10
    local startTime = SysTime()
    timer.Simple( time, function()
        if CLIENT then
            chat.AddText( "Sent performance profiler finished." )
        end

        for ent, methods in pairs( ENT_METHODS_ORIGINALS ) do
            if not IsValid( ent ) then continue end
            for methodName, originalFunc in pairs( methods ) do
                if isfunction( originalFunc ) then
                    ent[methodName] = originalFunc
                end
            end
        end

        for entTable, methods in pairs( ENT_TABLE_ORIGINALS ) do
            for methodName, originalFunc in pairs( methods ) do
                if isfunction( originalFunc ) then
                    entTable[methodName] = originalFunc
                end
            end
        end

        local sorted = {}
        for _, info in pairs( lagTbl ) do
            table.insert( sorted, info )
        end

        table.sort( sorted, function( a, b )
            return a.time > b.time
        end )

        local colWhite   = Color( 255, 255, 255 )
        local colGray    = Color( 160, 160, 160 )
        local colCyan    = Color( 100, 220, 255 )
        local colYellow  = Color( 255, 220, 80  )
        local colGreen   = Color( 100, 220, 120 )
        local colOrange  = Color( 255, 160, 60  )
        local colHeader  = Color( 220, 180, 255 )
        local tab = "\t"

        local endTime = SysTime()
        local runTime = math.Round( endTime - startTime, 2 )
        MsgC( colYellow, "Sent profiler ran for " .. runTime .. " seconds.\n" )
        MsgC( colHeader, "Class", tab, "Method", tab, "Count", tab, "Time (s)", tab, "Origin", tab, "Note", "\n" )
        for i = 1, 100 do
            local sort = sorted[i]
            if sort then
                MsgC(
                    colCyan,   sort.class,
                    colGray,   tab,
                    colWhite,  sort.varName,
                    colGray,   tab,
                    colYellow, tostring( sort.count ),
                    colGray,   tab,
                    colGreen,  tostring( math.Round( sort.time, 6 ) ),
                    colGray,   tab .. sort.origin .. ":" .. sort.linedefined .. tab,
                    colOrange, sort.inCoroutine and "in coroutine, result may be inaccurate" or "",
                    colWhite,  "\n"
                )
            end
        end

        local totalCount, totalTime = 0, 0
        for _, info in pairs( lagTbl ) do
            totalCount = totalCount + info.count
            totalTime = totalTime + info.time
        end

        MsgC( colHeader, "Total", colGray, tab, colYellow, tostring( totalCount ), colGray, tab, colGreen, tostring( math.Round( totalTime, 6 ) ), colWhite, "\n" )

        SENT_PERF_RUNNING = nil
        ENT_METHODS_ORIGINALS = nil
        ENT_TABLE_ORIGINALS = nil
    end )
end )

