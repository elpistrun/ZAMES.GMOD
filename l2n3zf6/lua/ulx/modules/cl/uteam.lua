--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/l2n3zf6/lua/ulx/modules/cl/uteam.lua <
    > Callstack: addons/l2n3zf6/lua/ulx/cl_init.lua:12
[C]:-1
addons/l2n3zf6/lua/ulib/modules/ulx_init.lua:4
[C]:-1
addons/h9k8rfq2bt5/lua/ulib/cl_init.lua:24
[C]:-1
addons/h9k8rfq2bt5/lua/autorun/ulib_init.lua:5 <
]]

ulx.teams = ulx.teams or {}

function ulx.populateClTeams( teams )
	ulx.teams = teams

	for i=1, #teams do
		local team_data = teams[ i ]
		team.SetUp( team_data.index, team_data.name, team_data.color )
	end
end

