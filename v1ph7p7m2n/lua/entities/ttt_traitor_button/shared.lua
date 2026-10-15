--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/lua/entities/ttt_traitor_button/shared.lua <
    > Callstack:  <
]]

--- Special button only for traitors and usable from range

ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:SetupDataTables()
   self:NetworkVar("Float", 0, "Delay")
   self:NetworkVar("Float", 1, "NextUseTime")
   self:NetworkVar("Bool", 0, "Locked")
   self:NetworkVar("String", 0, "Description")
   self:NetworkVar("Int", 0, "UsableRange", {KeyName = "UsableRange"})
end

function ENT:IsUsable()
   return (not self:GetLocked()) and self:GetNextUseTime() < CurTime()
end

