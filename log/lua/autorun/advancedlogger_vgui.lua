--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/log/lua/autorun/advancedlogger_vgui.lua <
    > Callstack:  <
]]

local meta = FindMetaTable("Player");
LogFilterData = LogFilterData or {}

local ListAmount = 70
local AvailableGroups = {}
AvailableGroups["superadmin"] = true
AvailableGroups["owner"] = true
AvailableGroups["admin"] = true
AvailableGroups["operator"] = true

if CLIENT then 
	concommand.Add("zs_logs",function(ply,cmd,args)
		MsgN(ply:GetNWString("usergroup"))
		if !AvailableGroups[ply:GetNWString("usergroup")] then return end
		
		AdvLogger_Open()
	end)
	
	net.Receive( "ADVLOG_LogList_S2C", function( len,ply )
		local DATA = net.ReadTable()
		LogFilterData = DATA.HookList
		
		if AdvLoggerPanel and AdvLoggerPanel:IsValid() then
			AdvLoggerPanel:UpdateLogFileList(DATA.Data)
		end
	end)
	
	net.Receive( "ADVLOG_Log_S2C", function( len,ply )
		local DATA = net.ReadTable()
		if AdvLoggerPanel and AdvLoggerPanel:IsValid() then
			AdvLoggerPanel:UpdateLog(DATA)
		end
	end)
	
	
	function RequestLogList()
		net.Start( "ADVLOG_RequestLogList_C2S" )
		net.SendToServer()
	end
	
	function RequestLog(day, page, searchStr)
		net.Start( "ADVLOG_RequestLog_C2S" )
			net.WriteTable({Page = page, Day = day, Filter = LogFilterData, Search = searchStr or ""})
		net.SendToServer()
	end

end

if SERVER then
	util.AddNetworkString( "ADVLOG_RequestLog_C2S" )
	util.AddNetworkString( "ADVLOG_RequestLogList_C2S" )
	util.AddNetworkString( "ADVLOG_LogList_S2C" )
	util.AddNetworkString( "ADVLOG_Log_S2C" )

	net.Receive( "ADVLOG_RequestLog_C2S", function( len,ply )
		local DATA = net.ReadTable()
		local Filter = DATA.Filter
		local SearchStr = DATA.Search or ""
		
		local FilterQuery = ""
		local typeFilters = {}
		
		for k,v in pairs(Filter) do
			if v then
				table.insert(typeFilters, sql.SQLStr(k))
			end
		end
		
		if #typeFilters > 0 then
			FilterQuery = "WHERE TYPE IN (" .. table.concat(typeFilters, ",") .. ")"
		end

		if SearchStr != "" then
			local searchEscaped = sql.SQLStr("%" .. SearchStr .. "%")
			if FilterQuery == "" then
				FilterQuery = "WHERE Message LIKE " .. searchEscaped
			else
				FilterQuery = FilterQuery .. " AND Message LIKE " .. searchEscaped
			end
		end

		local page = DATA.Page
		local Data = sql.Query( "SELECT * FROM ADV_Logger_"..DATA.Day.." "..FilterQuery.." ORDER BY ID DESC LIMIT "..ListAmount.." OFFSET " .. (page-1)*ListAmount )

		local FullData = sql.Query( "SELECT * FROM ADV_Logger_"..DATA.Day.." "..FilterQuery.." ORDER BY ID DESC")
		local Amount = FullData and #FullData or 0
		
		local TB2Send = {}
		TB2Send.Log = Data or {}
		TB2Send.Amount = Amount
		
		net.Start( "ADVLOG_Log_S2C" )
			net.WriteTable(TB2Send)
		net.Send(ply)
	end)
	
	
	net.Receive( "ADVLOG_RequestLogList_C2S", function( len,ply )
		
		local TB2Send = {}
		
		local HookList = {}
		for k,v in pairs(AdvLoger.Hooks) do
			if v.Enable then
				HookList[k] = true
			end
		end
		TB2Send.HookList = HookList
		TB2Send.Data = sql.Query( "SELECT * FROM ADVLogger_List")
		
		
		net.Start( "ADVLOG_LogList_S2C" )
			net.WriteTable(TB2Send)
		net.Send(ply)
	end)
	
end

if CLIENT then

	function AdvLogger_Open()
		if AdvLoggerPanel and AdvLoggerPanel:IsValid() then
			AdvLoggerPanel:Remove()
			AdvLoggerPanel = nil
		end
			AdvLoggerPanel = vgui.Create("AdvLogger")
			AdvLoggerPanel:SetPos(0,0)
			AdvLoggerPanel:SetSize(ScrW(),ScrH())
			AdvLoggerPanel.SellerNPC = SellerNPC
			AdvLoggerPanel:Install()
			AdvLoggerPanel:MakePopup()
			AdvLoggerPanel.NearMyCars = NearMyCars or {}
			
			return AdvLoggerPanel
	end
end

if CLIENT then

local PANEL = {}
function PANEL:Init()
	self:ShowCloseButton(false)
	self:SetTitle(" ")
	self:SetDraggable(false)
	
	self.LogPage = 1
	self.LogMaxPage = 1
	
	self.CarList = {}
	self.CarColor = Color(255,255,255,255)
end

function PANEL:UpdateLog(DATA)
	self.LogDataLister:Clear()
	
	self.CurLogFullAmount = DATA.Amount
	self.LogMaxPage = math.ceil(DATA.Amount/ListAmount)
	-- Защита от нулевого количества логов, чтобы показывалась 1 страница
	if self.LogMaxPage == 0 then self.LogMaxPage = 1 end 
	
	for k,v in pairs(DATA.Log) do
		local BT = vgui.Create("DButton")
		BT:SetSize(self.LogDataLister:GetWide(),20)
		BT:SetText(" ")
		BT.OnCursorEntered = function(slf) slf.Hover = true end
		BT.OnCursorExited = function(slf) slf.Hover = false end
		BT:SetToolTip(v.Message)
		BT.Paint = function(slf)
			local ColoJ = 25+(k%2)*10
			if slf.Hover then
				surface.SetDrawColor( Color(100,100,100,255) )
			else
				surface.SetDrawColor( Color(ColoJ,ColoJ,ColoJ,255) )
			end
			surface.DrawRect( 0, 0, slf:GetWide(), slf:GetTall() )
			draw.SimpleText(v.ID, "SansationOut_S20", 10,0, color_white)
			draw.SimpleText("[ " .. v.Time .. " ]", "SansationOut_S20", 100,0, Color(0,200,255,255))
			draw.SimpleText(v.Type, "SansationOut_S20", 250,0, Color(0,120,255,255))
			draw.SimpleText(v.Message, "SansationOut_S20", 480,0, Color(220,220,220,255))
		end
		BT.DoClick = function(slf)
			SetClipboardText(v.ID .. "   [ " .. v.Time .. " ]   " .. v.Type .. "  " .. v.Message);
		end
		self.LogDataLister:AddItem(BT)
	end
end

function PANEL:UpdateLogFileList(DATA)
	self.LogFileListLT:Clear()
	
	for k,v in pairs(DATA) do
		local BT = vgui.Create("DButton")
		BT:SetSize(self.LogFileListLT:GetWide(),20)
		BT:SetText(" ")
		BT.OnCursorEntered = function(slf) slf.Hover = true end
		BT.OnCursorExited = function(slf) slf.Hover = false end
		BT.Paint = function(slf)
			local ColoJ = 25+(k%2)*10
			if self.CurLogDay == v.Name then
				surface.SetDrawColor( Color(100,100,100,255) )
			else
				if slf.Hover then
					surface.SetDrawColor( Color(100,100,100,255) )
				else
					surface.SetDrawColor( Color(ColoJ,ColoJ,ColoJ,255) )
				end
			end
			surface.DrawRect( 0, 0, slf:GetWide(), slf:GetTall() )
			draw.SimpleText(v.Name, "PT.2", 10,0, color_white)
		end
		BT.DoClick = function(slf)
			self.LogPage = 1
			self.CurLogDay = v.Name
			local searchVal = (self.SearchBar and self.SearchBar:IsValid()) and self.SearchBar:GetValue() or ""
			RequestLog(v.Name, self.LogPage, searchVal)
		end
		self.LogFileListLT:AddItem(BT)
	end
	
	self.ControlPanelLister:Clear()
	
		local FilterBG = vgui.Create("DPanel")
		FilterBG:SetSize(self.ControlPanelLister:GetWide(),math.ceil(table.Count(LogFilterData)/2)*20)
		FilterBG.Paint = function(slf) end
		
		local Count = 0
		for k,v in pairs(LogFilterData) do
			Count = Count + 1
			
			local CheckBoxThing = vgui.Create( "DCheckBoxLabel", FilterBG )
			CheckBoxThing:SetPos( 10 + (Count%2)*(FilterBG:GetWide()/2),math.ceil(Count/2)*20 - 19 )
			CheckBoxThing:SetText( k )
			if v then
				CheckBoxThing:SetChecked(true)
			end
			CheckBoxThing.OnChange = function(pSelf, fValue)
			   if fValue then
					LogFilterData[k] = true
			   else
					LogFilterData[k] = false
			   end
			end
			CheckBoxThing:SizeToContents()
		end
		
		self.ControlPanelLister:AddItem(FilterBG)
		
	
end

function PANEL:Paint()
		surface.SetDrawColor( Color(221,65,65) )
		surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
		
		surface.SetDrawColor( Color(46,46,46) )
		surface.DrawRect( 2, 2, self:GetWide()-4, self:GetTall()-4 )
end

function PANEL:Install()
	RequestLogList()
	
	local BGP = vgui.Create("DPanel",self)
	BGP:SetPos(10,15)
	BGP:SetSize(200,30)
	BGP.Paint = function(slf)
		surface.SetDrawColor( 221,65,65 )
		surface.DrawRect( 0, 0, slf:GetWide(), slf:GetTall() )
		surface.SetDrawColor( 46,46,46)
		surface.DrawRect( 1, 1, slf:GetWide()-2, slf:GetTall()-2 )
		
		draw.SimpleText("Лист логов", "PT.2", 50,5, color_white)
	end
	
	local ControlPanel = vgui.Create("DPanel",self)
	ControlPanel:SetPos(220,15)
	ControlPanel:SetSize(self:GetWide()-230,30)
	ControlPanel.Paint = function(slf)
		surface.SetDrawColor( 221,65,65)
		surface.DrawRect( 0, 0, slf:GetWide(), slf:GetTall() )
		surface.SetDrawColor( 46,46,46 )
		surface.DrawRect( 1, 1, slf:GetWide()-2, slf:GetTall()-2 )
		
		if self.CurLogDay then
			draw.SimpleText("Cur List : " .. self.CurLogDay .. " ( total: " .. (self.CurLogFullAmount or 0) .. " )", "PT.2", 10,5, color_white)
		else
			draw.SimpleText("Параметры логов", "PT.2", 10,5, color_white)
		end
	end
	
	local ControlPanelLister = vgui.Create("DPanelList",self)
	ControlPanelLister:SetPos(220,50)
	ControlPanelLister:SetSize(self:GetWide()-400,100)
	ControlPanelLister.Paint = function(slf)
		surface.SetDrawColor( 221,65,65 )
		surface.DrawRect( 0, 0, slf:GetWide(), slf:GetTall() )
		surface.SetDrawColor( 46,46,46 )
		surface.DrawRect( 1, 1, slf:GetWide()-2, slf:GetTall()-2 )
	end
	ControlPanelLister:EnableVerticalScrollbar(true);
	ControlPanelLister:EnableHorizontal(false)
	self.ControlPanelLister = ControlPanelLister

	
	local PageMain = vgui.Create("DPanel",self)
	PageMain:SetPos(self:GetWide()-175,50)
	PageMain:SetSize(165,100)
	PageMain.Paint = function(slf)
		surface.SetDrawColor( 221,65,65 )
		surface.DrawRect( 0, 0, slf:GetWide(), slf:GetTall() )
		surface.SetDrawColor( 46,46,46 )
		surface.DrawRect( 1, 1, slf:GetWide()-2, slf:GetTall()-2 )

		draw.SimpleText("Page", "SansationOut_S20", 82,5, color_white,TEXT_ALIGN_CENTER)
		draw.SimpleText(self.LogPage .. " / " .. self.LogMaxPage, "SansationOut_S20", 85,25, color_white,TEXT_ALIGN_CENTER)
	end
	
	
		local Page = vgui.Create("ADVLG_DSWButton",PageMain)
		Page:SetPos(25,50)
		Page:SetSize(30,30)
		Page:SetTexts("<")
		Page.Click = function(slf)
			if self.CurLogDay and self.LogPage > 1 then
				self.LogPage = self.LogPage - 1
				local searchVal = (self.SearchBar and self.SearchBar:IsValid()) and self.SearchBar:GetValue() or ""
				RequestLog(self.CurLogDay, self.LogPage, searchVal)
			end
		end
		
		local Page = vgui.Create("ADVLG_DSWButton",PageMain)
		Page:SetPos(110,50)
		Page:SetSize(30,30)
		Page:SetTexts(">")
		Page.Click = function(slf)
			if self.CurLogDay and self.LogPage < self.LogMaxPage then
				self.LogPage = self.LogPage + 1
				local searchVal = (self.SearchBar and self.SearchBar:IsValid()) and self.SearchBar:GetValue() or ""
				RequestLog(self.CurLogDay, self.LogPage, searchVal)
			end
		end
		
		-- Строка поиска
		self.SearchBar = vgui.Create("DTextEntry", ControlPanel)
		self.SearchBar:SetPos(900, 5)
		self.SearchBar:SetSize(200, 20)
		self.SearchBar:SetPlaceholderText("Поиск...")
		
		self.SearchBar.OnChange = function(slf)
			local searchVal = slf:GetValue()
			
			timer.Create("AdvLogSearch_Debounce", 0.5, 1, function()
				if IsValid(self) and self.CurLogDay then
					self.LogPage = 1
					RequestLog(self.CurLogDay, self.LogPage, searchVal)
				end
			end)
		end
		
		self.SearchBar.OnEnter = function(slf)
			timer.Remove("AdvLogSearch_Debounce")
			if self.CurLogDay then
				self.LogPage = 1
				RequestLog(self.CurLogDay, self.LogPage, slf:GetValue())
			end
		end

		-- Кнопка обновления
		local RefreshBT = vgui.Create("ADVLG_DSWButton", ControlPanel)
		RefreshBT:SetPos(ControlPanel:GetWide()-260, 0)
		RefreshBT:SetSize(100, 30)
		RefreshBT:SetTexts("Обновить")
		RefreshBT.Click = function(slf)
			if self.CurLogDay then
				local searchVal = (self.SearchBar and self.SearchBar:IsValid()) and self.SearchBar:GetValue() or ""
				RequestLog(self.CurLogDay, self.LogPage, searchVal)
			end
		end

		local BT = vgui.Create("ADVLG_DSWButton",ControlPanel)
		BT:SetPos(ControlPanel:GetWide()-150,0)
		BT:SetSize(150,30)
		BT:SetTexts("Close")
		BT.Click = function(slf)
			self:Remove()
		end
	
	self.LogFileListLT = vgui.Create("DPanelList", self)
		self.LogFileListLT:SetPos(10,50)
		self.LogFileListLT:SetSize(200,self:GetTall() - 60)
		self.LogFileListLT:SetSpacing(3);
		self.LogFileListLT:SetPadding(0);
		self.LogFileListLT:EnableVerticalScrollbar(true);
		self.LogFileListLT:EnableHorizontal(false)
		self.LogFileListLT.Paint = function(slf)
			surface.SetDrawColor( 0,10,20,255 )
			surface.DrawRect( 1, 1, slf:GetWide()-2, slf:GetTall()-2 )
		end
		
	self.LogDataLister = vgui.Create("DPanelList", self)
		self.LogDataLister:SetPos(220,160)
		self.LogDataLister:SetSize(self:GetWide()-230,self:GetTall() - 170)
		self.LogDataLister:SetSpacing(3);
		self.LogDataLister:SetPadding(0);
		self.LogDataLister:EnableVerticalScrollbar(true);
		self.LogDataLister:EnableHorizontal(false)
		self.LogDataLister.Paint = function(slf)
			surface.SetDrawColor( 0,10,20,255 )
			surface.DrawRect( 1, 1, slf:GetWide()-2, slf:GetTall()-2 )
		end
		
	
end

vgui.Register("AdvLogger",PANEL,"DFrame")

end
