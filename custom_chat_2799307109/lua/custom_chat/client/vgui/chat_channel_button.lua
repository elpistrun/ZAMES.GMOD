--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/custom_chat_2799307109/lua/custom_chat/client/vgui/chat_channel_button.lua <
    > Callstack: addons/custom_chat_2799307109/lua/autorun/sh_custom_chat.lua:275 <
]]

local PANEL = {}

PANEL.colorSelected = Color( 34, 52, 142 )
PANEL.colorHover = Color( 255, 255, 255, 30 )
PANEL.colorIndicator = Color( 200, 0, 0, 255 )
PANEL.colorText = Color( 255, 255, 255, 255 )
PANEL.hoverFunc = function() return false end

function PANEL:Init()
    self:SetCursor( "hand" )
    self.icon = vgui.Create( "DImage", self )

    self.isSelected = false
    self.notificationCount = 0
end

function PANEL:SetIcon( path )
    self.icon:Remove()

    if isentity( path ) and IsValid( path ) and path:IsPlayer() then
        self.icon = vgui.Create( "AvatarImage", self )
        self.icon:SetPlayer( path, 64 )
        self.icon:SetZPos( self:GetZPos() + 10 )
        self.icon.TestHover = self.hoverFunc

        return
    end

    self.icon = vgui.Create( "DImage", self )

    if type( path ) == "string" then
        self.icon:SetImage( path )
    end
end

function PANEL:PerformLayout( w, h )
    local size = math.max( w, h ) * 0.6

    self.icon:SetSize( size, size )
    self.icon:Center()
end

function PANEL:Paint( w, h )
    if self.isSelected then
        draw.RoundedBox( 4, 0, 0, w, h, self.colorSelected )
    end

    if self:IsHovered() then
        surface.SetDrawColor( self.colorHover:Unpack() )
        surface.DrawRect( 0, 0, w, h )
    end
end

function PANEL:PaintOver( w, h )
    if self.notificationCount > 0 then
        local size = 14
        local x = w - size
        local y = h - size

        local label = self.notificationCount < 99 and self.notificationCount or "99+"

        DisableClipping( true )
        draw.RoundedBox( size * 0.5, x, y, size, size, self.colorIndicator )
        draw.SimpleText( label, "DebugOverlay", x + size * 0.5, y + size * 0.5, self.colorText, 1, 1 )
        DisableClipping( false )
    end
end

function PANEL:OnMousePressed( keyCode )
    -- self -> channel list -> chat frame
    local frame = self:GetParent():GetParent()

    if keyCode == MOUSE_LEFT then
        frame:SetActiveChannel( self.channelId )
    end
end

vgui.Register( "CustomChat_ChannelButton", PANEL, "DPanel" )

