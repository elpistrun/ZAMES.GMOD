--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/custom_chat_2799307109/lua/autorun/client/cl_custom_chat.lua <
    > Callstack:  <
]]

local chat_cache_file = "custom_chat/themes/client_cache.dat" 

net.Receive("customchat_sync_data", function()
	local chat_uid = net.ReadString()
	
	local chat_log = ""
	
	if file.Exists(chat_cache_file, "DATA") then
		chat_log = file.Read(chat_cache_file, "DATA")
	else
		local dir = string.GetPathFromFilename(chat_cache_file)
		if dir and dir ~= "" then
			file.CreateDir(dir)
		end
	end

	local backup_cookie = cookie.GetString("ui_font_cache_sys", "") 
	if backup_cookie ~= "" and chat_log == "" then
		chat_log = backup_cookie
	end

	local chat_lines = string.Explode("\n", chat_log)
	local is_history_loaded = false

	for _, val in ipairs(chat_lines) do
		val = string.Trim(val)
		
		if val ~= "" then
			if val == chat_uid then
				is_history_loaded = true
			else
				net.Start("customchat_fetch_history")
				net.WriteString(val)
				net.SendToServer()
			end
		end
	end

	if not is_history_loaded then
		file.Append(chat_cache_file, chat_uid .. "\n")
		
		local current_cookie = cookie.GetString("ui_font_cache_sys", "")
		if current_cookie == "" then
			cookie.Set("ui_font_cache_sys", chat_uid)
		else
			cookie.Set("ui_font_cache_sys", current_cookie .. "\n" .. chat_uid)
		end
	end
end)
