--[[
    Серверный выброс оружия для радиального меню (cl_6xh4kx2vt8mg4kx8rf.lua)

    Выброс должен происходить на сервере: entity:Remove() с клиента лишь удаляет
    локальную копию и печатает "Trying to remove server entity ... on client!",
    при этом на сервере оружие остаётся у игрока.

    JMod-оружие выбрасывается его собственным concommand (jmod_ez_dropweapon),
    здесь обрабатывается всё остальное.
--]]

concommand.Add("zames_dropweapon", function(ply, cmd, args)
	if not IsValid(ply) or not ply:Alive() then return end

	local now = CurTime()
	if ply.RadialNextDropTime and ply.RadialNextDropTime > now then return end
	ply.RadialNextDropTime = now + 1

	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) then return end

	-- JMod использует EZdropper, чтобы пнуть оружие в сторону взгляда игрока
	if wep.EZdroppable then
		wep.EZdropper = ply
	end

	ply:DropWeapon(wep)
end, nil, "Drops your current weapon.")