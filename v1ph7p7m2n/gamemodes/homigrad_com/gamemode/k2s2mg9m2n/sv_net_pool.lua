--[[
    Регистрация net-сообщений гмеймода и аддонов.

    GMod требует util.AddNetworkString() для КАЖДОГО имени сообщения, иначе
    net.Start() падает с "Calling net.Start with unpooled message name!".
    Часть сообщений приносилась при переносе стары сайлов была без регистрации.
]]

local net_messages = {
	"ApplyCustomization",
	"ApplyFigureColor",
	"ApplySkinBodygroup",
	"ApplySkinCustomization",
	"ApplySkinMaterial",
	"CurrencyAddedAnim",
	"FProfile_focusObj",
	"FProfile_fullModelUpdate",
	"FProfile_getSource",
	"FProfile_printFunction",
	"FProfile_startProfiling",
	"FProfile_stopProfiling",
	"FProfile_unsubscribe",
	"LootInventory_TakeItem",
	"RTV_SendVote",
	"ReceiveTopList",
	"RequestTopList",
	"Shop_BuyItem",
	"Shop_DeleteItem",
	"Shop_SellItem",
	"SyncInventory",
	"TPIK_NetworkSound",
	"XGUI.AddVotemaps",
	"XGUI.PreviewBanMessage",
	"XGUI.RemoveVotemaps",
	"XGUI.SaveBanMessage",
	"XGUI.SetMotdData",
	"XGUI.UpdateMotdData",
	"net_ch_team",
	"net_rd",
	"net_role",
	"hmcd_roleget",
	"RTV_StartVoting",
	"RTV_UpdateVotes",
	"RTV_EndVoting",
}

for _, name in ipairs(net_messages) do
	util.AddNetworkString(name)
end
