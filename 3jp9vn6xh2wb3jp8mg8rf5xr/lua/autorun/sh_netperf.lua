--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/3jp9vn6xh2wb3jp8mg8rf5xr/lua/autorun/sh_netperf.lua <
    > Callstack:  <
]]

local perfTable = {}
local bitTable = {}
local countTable = {}
local umsgTable = {}
local umsgBitTable = {}
local umsgCountTable = {}
local totalStartTime = 0
local running = false

local function applyWrap()
    netperf_net_Incoming = netperf_net_Incoming or net.Incoming
    local net_Incoming = netperf_net_Incoming

    netperf_usermessage_IncomingMessage = netperf_usermessage_IncomingMessage or usermessage.IncomingMessage
    local um_IncomingMessage = netperf_usermessage_IncomingMessage

    usermessage.IncomingMessage = function( name, msg )
        if not running then return um_IncomingMessage( name, msg ) end
        local bits = msg:GetNumBitsLeft()
        local start = SysTime()
        um_IncomingMessage( name, msg )
        local elapsed = SysTime() - start
        umsgTable[name] = ( umsgTable[name] or 0 ) + elapsed
        umsgBitTable[name] = ( umsgBitTable[name] or 0 ) + bits
        umsgCountTable[name] = ( umsgCountTable[name] or 0 ) + 1
    end

    function net.Incoming( len, client )
        local headerNum = net.ReadHeader()
        local strName = util.NetworkIDToString( headerNum )

        net_ReadHeader = net_ReadHeader or net.ReadHeader
        net.ReadHeader = function()
            return headerNum
        end

        bitTable[strName] = ( bitTable[strName] or 0 ) + len
        countTable[strName] = ( countTable[strName] or 0 ) + 1
        local start = SysTime()

        net_Incoming( len, client )

        local endtime = SysTime()
        perfTable[strName] = ( perfTable[strName] or 0 ) + ( endtime - start )

        net.ReadHeader = net_ReadHeader
    end
end

local nw2Table = {}
hook.Add( "EntityNetworkedVarChanged", "NetPerf", function( _ent, name, _oldval, _newval )
    if not running then return end

    nw2Table[name] = ( nw2Table[name] or 0 ) + 1
end )

concommand.Add( SERVER and "red_sv_netperf_start" or "red_cl_netperf_start", function( ply )
    if SERVER and IsValid( ply ) and not ply:IsSuperAdmin() then
        return ply:ChatPrint( "No permission." )
    end

    totalStartTime = SysTime()
    table.Empty( perfTable )
    table.Empty( bitTable )
    table.Empty( countTable )
    table.Empty( umsgTable )
    table.Empty( umsgBitTable )
    table.Empty( umsgCountTable )
    table.Empty( nw2Table )

    applyWrap()
    running = true
    print( "Netperf started" )
end )

concommand.Add( SERVER and "red_sv_netperf_stop" or "red_cl_netperf_stop", function( ply )
    if SERVER and IsValid( ply ) and not ply:IsSuperAdmin() then
        return ply:ChatPrint( "No permission." )
    end

    if not running then
        print( "Netperf isn't running." )
        return
    end

    running = false

    local colWhite   = Color( 255, 255, 255 )
    local colGray    = Color( 160, 160, 160 )
    local colCyan    = Color( 100, 220, 255 )
    local colYellow  = Color( 255, 220, 80  )
    local colGreen   = Color( 100, 220, 120 )
    local colHeader  = Color( 220, 180, 255 )
    local tab = "\t"

    MsgC( colYellow, "Netperf ran for " .. math.Round( SysTime() - totalStartTime, 2 ) .. " seconds.\n" )

    if next( perfTable ) then
        MsgC( colHeader, "Netmessages sorted by time:\n" )
        MsgC( colHeader, "Name", tab, "Time (s)", tab, "Bits", tab, "Count", "\n" )
        for k, v in SortedPairsByValue( perfTable, true ) do
            MsgC( colCyan, k, colGray, tab, colGreen, tostring( math.Round( v, 6 ) ), colGray, tab, colYellow, tostring( bitTable[k] ), colGray, tab, colWhite, tostring( countTable[k] or 0 ), colWhite, "\n" )
        end

        MsgC( colHeader, "\nNetmessages sorted by bits:\n" )
        MsgC( colHeader, "Name", tab, "Bits", tab, "Time (s)", tab, "Count", "\n" )
        for k, v in SortedPairsByValue( bitTable, true ) do
            MsgC( colCyan, k, colGray, tab, colYellow, tostring( v ), colGray, tab, colGreen, tostring( math.Round( perfTable[k], 6 ) ), colGray, tab, colWhite, tostring( countTable[k] or 0 ), colWhite, "\n" )
        end

        local totalCount, totalTime = 0, 0
        for name, time in pairs( perfTable ) do
            totalCount = totalCount + ( countTable[name] or 0 )
            totalTime = totalTime + time
        end

        local totalBitCount = 0
        for _, bits in pairs( bitTable ) do
            totalBitCount = totalBitCount + bits
        end

        MsgC( colHeader, "\nTotal netmessages: ", colWhite, tostring( totalCount ), colHeader, ", total time: ", colGreen, tostring( math.Round( totalTime, 6 ) ) .. "s", colHeader, ", total bits: ", colYellow, tostring( totalBitCount ), colWhite, "\n\n" )
    end

    if next( nw2Table ) then
        MsgC( colHeader, "NW2 sorted by count:\n" )
        MsgC( colHeader, "Name", tab, "Count", "\n" )
        for k, v in SortedPairsByValue( nw2Table, true ) do
            MsgC( colCyan, k, colGray, tab, colWhite, tostring( v ), colWhite, "\n" )
        end
        MsgC( colWhite, "\n" )
    end

    if next( umsgTable ) then
        MsgC( colHeader, "Usermessages sorted by time:\n" )
        MsgC( colHeader, "Name", tab, "Time (s)", tab, "Bits", tab, "Count", "\n" )
        for k, v in SortedPairsByValue( umsgTable, true ) do
            MsgC( colCyan, k, colGray, tab, colGreen, tostring( math.Round( v, 6 ) ), colGray, tab, colYellow, tostring( umsgBitTable[k] or 0 ), colGray, tab, colWhite, tostring( umsgCountTable[k] or 0 ), colWhite, "\n" )
        end

        MsgC( colHeader, "\nUsermessages sorted by bits:\n" )
        MsgC( colHeader, "Name", tab, "Bits", tab, "Time (s)", tab, "Count", "\n" )
        for k, v in SortedPairsByValue( umsgBitTable, true ) do
            MsgC( colCyan, k, colGray, tab, colYellow, tostring( v ), colGray, tab, colGreen, tostring( math.Round( umsgTable[k] or 0, 6 ) ), colGray, tab, colWhite, tostring( umsgCountTable[k] or 0 ), colWhite, "\n" )
        end

        local totalUmsgCount, totalUmsgTime = 0, 0
        for name, time in pairs( umsgTable ) do
            totalUmsgCount = totalUmsgCount + ( umsgCountTable[name] or 0 )
            totalUmsgTime = totalUmsgTime + time
        end
        local totalUmsgBitCount = 0
        for _, bits in pairs( umsgBitTable ) do
            totalUmsgBitCount = totalUmsgBitCount + bits
        end

        MsgC( colHeader, "\nTotal usermessages: ", colWhite, tostring( totalUmsgCount ), colHeader, ", total time: ", colGreen, tostring( math.Round( totalUmsgTime, 6 ) ) .. "s", colHeader, ", total bits: ", colYellow, tostring( totalUmsgBitCount ), colWhite, "\n" )
    end

    net.Incoming = netperf_net_Incoming
    net.ReadHeader = net_ReadHeader
    usermessage.IncomingMessage = netperf_usermessage_IncomingMessage
end )

