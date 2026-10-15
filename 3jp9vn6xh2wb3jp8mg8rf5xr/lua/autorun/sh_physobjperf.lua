--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/3jp9vn6xh2wb3jp8mg8rf5xr/lua/autorun/sh_physobjperf.lua <
    > Callstack:  <
]]

local cmd = SERVER and "red_sv_physobjperf" or "red_cl_physobjperf"
concommand.Add( cmd, function( ply, _, args )
    if SERVER and IsValid( ply ) and not ply:IsSuperAdmin() then
        return ply:ChatPrint( "No permission." )
    end

    if PHYSOBJ_PERF_RUNNING then
        MsgC( softWhite, "PhysObj performance profiler is already running.\n" )
        return
    end

    local physMeta = FindMetaTable( "PhysObj" )
    if not physMeta then
        MsgC( Color( 255, 100, 100 ), "Could not find PhysObj metatable.\n" )
        return
    end

    PHYSOBJ_PERF_RUNNING = true
    PHYSOBJ_METHODS_ORIGINALS = PHYSOBJ_METHODS_ORIGINALS or {}

    local lagTbl = {}

    local function wrapFunction( tbl, varName, original )
        local function wrapper( ... )
            local sysTime = SysTime()
            local a, b, c, d, e, f = original( ... )
            local elapsed = SysTime() - sysTime

            -- level 2 is the code that called the PhysObj method
            local callerInfo = debug.getinfo( 2, "Sl" )
            local callerSrc, callerLine
            if callerInfo then
                callerSrc = callerInfo.short_src
                callerLine = callerInfo.currentline
            else
                callerSrc = "[C]"
                callerLine = -1
            end

            local perfID = varName .. "@" .. callerSrc .. ":" .. tostring( callerLine )

            local info = lagTbl[perfID]
            if not info then
                local inCoroutine = coroutine.running()
                info = { varName = varName, count = 0, time = 0, caller = callerSrc, callerLine = callerLine, inCoroutine = inCoroutine }
                lagTbl[perfID] = info
            end

            info.count = info.count + 1
            info.time = info.time + elapsed

            return a, b, c, d, e, f
        end

        tbl[varName] = wrapper
    end

    for varName, var in pairs( physMeta ) do
        if not isfunction( var ) then continue end
        PHYSOBJ_METHODS_ORIGINALS[varName] = var
        wrapFunction( physMeta, varName, var )
    end

    local time = tonumber( args[1] ) or 10
    local startTime = SysTime()
    timer.Simple( time, function()
        if CLIENT then
            chat.AddText( "PhysObj performance profiler finished." )
        end

        for methodName, originalFunc in pairs( PHYSOBJ_METHODS_ORIGINALS ) do
            if isfunction( originalFunc ) then
                physMeta[methodName] = originalFunc
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
        MsgC( colYellow, "PhysObj profiler ran for " .. runTime .. " seconds.\n" )
        MsgC( colHeader, "Method", tab, "Count", tab, "Time (s)", tab, "Caller", tab, "Note", "\n" )
        for i = 1, 100 do
            local sort = sorted[i]
            if sort then
                MsgC(
                    colCyan,   sort.varName,
                    colGray,   tab,
                    colYellow, tostring( sort.count ),
                    colGray,   tab,
                    colGreen,  tostring( math.Round( sort.time, 6 ) ),
                    colGray,   tab .. sort.caller .. ":" .. sort.callerLine .. tab,
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

        PHYSOBJ_PERF_RUNNING = nil
        PHYSOBJ_METHODS_ORIGINALS = nil
    end )
end )

