--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/log/lua/autorun/client/advancedlogger_metafunc.lua <
    > Callstack:  <
]]

local meta = FindMetaTable("Panel")
function meta:DrawBoarder(width,col)
	width = width or 1
	col = col or Color(0,125,255,255)
	
	surface.SetDrawColor( col )
	surface.DrawRect( 0, 0, self:GetWide(), width )
	surface.DrawRect( 0, self:GetTall()-width, self:GetWide(), width )
	surface.DrawRect( 0, 0, width, self:GetTall() )
	surface.DrawRect( self:GetWide()-width, 0, width, self:GetTall() )
end
function meta:PaintListBarC(bCol,iCol)
	local bCol = bCol or Color(0,150,255,255)
	local iCol = iCol or Color(0,0,0,255)
	
	self.VBar.btnDown.Paint = function(selfk)
		surface.SetDrawColor( bCol.r,bCol.g,bCol.b,255 )
		surface.DrawRect( 0, 0, selfk:GetWide(), selfk:GetTall() )
		surface.SetDrawColor( iCol.r,iCol.g,iCol.b,255 )
		surface.DrawRect( 1, 1, selfk:GetWide()-2, selfk:GetTall()-2 )
	end
	self.VBar.btnUp.Paint = function(selfk)
		surface.SetDrawColor( bCol.r,bCol.g,bCol.b,255 )
		surface.DrawRect( 0, 0, selfk:GetWide(), selfk:GetTall() )
		surface.SetDrawColor( iCol.r,iCol.g,iCol.b,255 )
		surface.DrawRect( 1, 1, selfk:GetWide()-2, selfk:GetTall()-2 )
	end
	self.VBar.btnGrip.Paint = function(selfk)
		surface.SetDrawColor( bCol.r,bCol.g,bCol.b,255 )
		surface.DrawRect( 0, 0, selfk:GetWide(), selfk:GetTall() )
		surface.SetDrawColor( iCol.r,iCol.g,iCol.b,255 )
		surface.DrawRect( 1, 1, selfk:GetWide()-2, selfk:GetTall()-2 )
	end
	self.VBar.Paint = function(selfk)
	end
end

function meta:PaintListBar(Style)
	Style = Style or "BlueLineHUD"
	if Style == "BlueLineHUD" then
			local bCol = Color(0,150,255,255)
			local iCol = Color(0,0,0,255)
			
			self.VBar.btnDown.Paint = function(selfk)
			end
			self.VBar.btnUp.Paint = function(selfk)
			end
			self.VBar.btnGrip.Paint = function(selfk)
				Surface_DrawRect(3, 3, selfk:GetWide()-6, selfk:GetTall()-6, Color(bCol.r,bCol.g,bCol.b,255))
				Surface_DrawRect(4, 4, selfk:GetWide()-8, selfk:GetTall()-8, Color(iCol.r,iCol.g,iCol.b,255))
			end
			self.VBar.Paint = function(selfk)
				surface.SetMaterial(MAT_NEWUI_PNG_GRA_BODY_4_1W)
				surface.SetDrawColor(0,150,255,100) 
				surface.DrawTexturedRectRotated(selfk:GetWide()/2,selfk:GetTall()/2,selfk:GetTall(), 1,90)
			end
	end
	if Style == "WhiteLine" then
			local bCol = Color(200,200,200,255)
			local iCol = Color(0,0,0,255)
			
			self.VBar.btnDown.Paint = function(selfk)
			end
			self.VBar.btnUp.Paint = function(selfk)
			end
			self.VBar.btnGrip.Paint = function(selfk)
				Surface_DrawRect(3, 3, selfk:GetWide()-6, selfk:GetTall()-6, Color(bCol.r,bCol.g,bCol.b,255))
				Surface_DrawRect(4, 4, selfk:GetWide()-8, selfk:GetTall()-8, Color(iCol.r,iCol.g,iCol.b,255))
			end
			self.VBar.Paint = function(selfk)
				surface.SetMaterial(MAT_NEWUI_PNG_GRA_BODY_4_1W)
				surface.SetDrawColor(255,255,255,100) 
				surface.DrawTexturedRectRotated(selfk:GetWide()/2,selfk:GetTall()/2,selfk:GetTall(), 1,90)
			end
	end
	
end


