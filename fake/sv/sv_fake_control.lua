local weights = {
	["models/css_seb_swat/css_swat.mdl"] = {[1] = 1},
	["models/css_seb_swat/css_seb.mdl"] ={[1] = 1},
	["models/gang_groove/gang_1.mdl"] =		   {[1] = 3},
	["models/gang_groove/gang_2.mdl"] =		   {[1] = 3},
	["models/gang_ballas/gang_ballas_1.mdl"] = {[1] = 3},
	["models/gang_ballas/gang_ballas_2.mdl"] = {[1] = 3},
}

hook.Add("FakeControl","PlayerControl",function(ply,rag)
	local Head = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_Head1" )) )
	local Neck = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_Neck1" )) )
	local Spine4 = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_Spine4" )) )
	local Spine2 = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_Spine2" )) )
	local Spine1 = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_Spine1" )) )
	local Spine = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_Spine" )) )
	local Penis = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_Pelvis" )) )
	local CalfR = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Calf" )) )
	local CalfL = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Calf" )) )
	local FArmL = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Forearm" )) )
	local FArmR = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Forearm" )) )
	local HandL = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" )) )
	local HandR = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" )) )
    local eyeangs = ply:EyeAngles()

	if ply.otrub then return end

	local ismoving = (ply:KeyDown(IN_FORWARD) and IsValid(rag.ZacConsRH)) or (ply:KeyDown(IN_FORWARD) and IsValid(rag.ZacConsLH))

	//Управление

	if ply:KeyDown(IN_USE) or ply:GetActiveWeapon().SupportTPIK and ply:GetActiveWeapon():GetClass() != "weapon_hands" then
		local angs = ply:EyeAngles()
		angs:RotateAroundAxis(angs:Forward(),0)
		angs:RotateAroundAxis(angs:Up(),-90)
		angs:RotateAroundAxis(angs:Right(),90)

		local sp = {
			secondstoarrive = 0.3,
			pos = Spine4:GetPos() + ((ply:KeyDown(IN_ATTACK) and ply:KeyDown(IN_ATTACK2)) and ply:EyeAngles():Forward() * 0.5 or Vector()),
			angle = angs,
			maxangular = 360 * 3,
			maxangulardamp = 35,
			dampfactor = 1,
			maxspeeddamp = 5,
			maxspeed = 400,
			teleportdistance = 0,
			deltatime=deltatime,	
		}

		local angs = ply:EyeAngles()
		angs:RotateAroundAxis(angs:Forward(),0)
		angs:RotateAroundAxis(angs:Up(),-90)
		angs:RotateAroundAxis(angs:Right(),90)

		local sp2 = {
			secondstoarrive = 0.7,
			pos = Spine2:GetPos() + ((ply:KeyDown(IN_ATTACK) and ply:KeyDown(IN_ATTACK2)) and ply:EyeAngles():Forward() * 0.5 or Vector()),
			angle = angs,
			maxangular = 360 * 3,
			maxangulardamp = 60,
			dampfactor = 1,
			maxspeeddamp = 10,
			maxspeed = 200,
			teleportdistance = 0,
			deltatime=deltatime,
		}

		Spine4:Wake()
		Spine4:ComputeShadowControl(sp)

		Spine2:Wake()
		Spine2:ComputeShadowControl(sp2)
	end

	local weight = weights[rag:GetModel()] and weights[rag:GetModel()][1] or 1

	if ply:KeyDown(IN_FORWARD) and IsValid(rag.ZacConsLH) then
		local angs = ply:EyeAngles()
		angs:RotateAroundAxis(angs:Forward(),0)
		angs:RotateAroundAxis(angs:Up(),-90)
		angs:RotateAroundAxis(angs:Right(),90)

		local dist = HandR:GetPos():Distance(Spine4:GetPos())

		local velo = rag:GetVelocity():Length() / 400

		if rag.ZacConsLH.Ent2:GetVelocity():LengthSqr() < 750 then
			local sp = {
				secondstoarrive = 0.5,
				pos = HandL:GetPos() + ply:EyeAngles():Forward() * 13 + ply:EyeAngles():Up() * 15 + (IsValid(rag.ZacConsRH) and vector_up * 4 or Vector()),
				angle = Spine2:GetAngles(),
				maxangular = 360 * 3,
				maxangulardamp = 3,
				dampfactor = 1,
				maxspeeddamp = 20,
				maxspeed = 300,
				teleportdistance = 0,
				deltatime=deltatime,
			}

			Spine2:Wake()
			Spine2:ComputeShadowControl(sp)

			//sp.angle = Spine:GetAngles()
			//sp.secondstoarrive = 0.35
			//Spine:Wake()
			//Spine:ComputeShadowControl(sp)
		end
	end

	if ply:KeyDown(IN_FORWARD) and IsValid(rag.ZacConsRH) then
		local angs = ply:EyeAngles()
		angs:RotateAroundAxis(angs:Forward(),0)
		angs:RotateAroundAxis(angs:Up(),-90)
		angs:RotateAroundAxis(angs:Right(),90)

		local dist = HandL:GetPos():Distance(Spine4:GetPos())

		local mul = math.Clamp(1 - dist / 30,0,0.6)

		local velo = rag:GetVelocity():Length() / 400

		if rag.ZacConsRH.Ent2:GetVelocity():LengthSqr() < 750 then
			local sp = {
				secondstoarrive = 0.5,
				pos = HandR:GetPos() + ply:EyeAngles():Forward() * 13 + ply:EyeAngles():Up() * 15 + (IsValid(rag.ZacConsLH) and vector_up * 4 or Vector()),
				angle = Spine2:GetAngles(),
				maxangular = 360 * 3,
				maxangulardamp = 3,
				dampfactor = 1,
				maxspeeddamp = 20,
				maxspeed = 300,
				teleportdistance = 0,
				deltatime=deltatime,
			}

			Spine2:Wake()
			Spine2:ComputeShadowControl(sp)

			//sp.angle = Spine:GetAngles()
			//sp.secondstoarrive = (0.35 * (1.25 + velo)) * weight
			//Spine:Wake()
			//Spine:ComputeShadowControl(sp)
		end
	end

	//Руки

	if ply:KeyDown(IN_ATTACK2) and !ply:GetActiveWeapon().SupportTPIK then
		local angs = ply:EyeAngles()
		angs:RotateAroundAxis(angs:Forward(),90)
		angs:RotateAroundAxis(angs:Right(),0)
		angs:RotateAroundAxis(angs:Up(),50)
		local sp = {
			secondstoarrive = 0.12,
				pos = Head:GetPos() + ply:EyeAngles():Forward() * 30 + ply:EyeAngles():Right() * 9,
				angle = angs,
				maxangular = 360,
				maxangulardamp = 15,
				maxspeeddamp = 350,
				maxspeed = 500,
				dampfactor = 1,
				teleportdistance = 0,
				deltatime=deltatime,
		}

		HandR:Wake()
		HandR:ComputeShadowControl(sp)
	end

	if ply:KeyDown(IN_ATTACK) and !ply:GetActiveWeapon().SupportTPIK then
		local angs = ply:EyeAngles()
		angs:RotateAroundAxis(angs:Forward(),90)
		angs:RotateAroundAxis(angs:Right(),0)
		angs:RotateAroundAxis(angs:Up(),50)
		local sp = {
			secondstoarrive = 0.12,
				pos = Head:GetPos() + ply:EyeAngles():Forward() * 30 + ply:EyeAngles():Right() * -9,
				angle = angs,
				maxangular = 360,
				maxangulardamp = 15,
				maxspeeddamp = 350,
				maxspeed = 500,
				dampfactor = 1,
				teleportdistance = 0,
				deltatime=deltatime,
		}

		HandL:Wake()
		HandL:ComputeShadowControl(sp)
	end

    if ply:KeyDown(IN_SPEED) and !ply:GetActiveWeapon().reload then
		local bone = rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_L_Hand"))
		local phys = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_L_Hand")))
		if not IsValid(rag.ZacConsLH) and (not rag.ZacNextGrLH or rag.ZacNextGrLH <= CurTime()) then
			rag.ZacNextGrLH = CurTime() + 0.01
			for i = 1, 3 do
				local offset = phys:GetAngles():Up() * 5
				if i == 2 then
					offset = phys:GetAngles():Right() * 5
				end
				if i == 3 then
					offset = phys:GetAngles():Right() * -5
				end
				local traceinfo = {
					start = phys:GetPos(),
					endpos = phys:GetPos() + offset,
					filter = rag,
					output = trace,
				}
				local trace = util.TraceLine(traceinfo)
				if trace.Hit and not trace.HitSky then
					local cons = constraint.Weld(rag, trace.Entity, bone, trace.PhysicsBone, 0, false, false)
					if trace.Entity:IsPlayer() and !trace.Entity.Fake then
						Faking(trace.Entity)
					end
					if trace.Entity:IsWeapon() then
						ply:PickupWeapon(trace.Entity)
						ply:SetActiveWeapon(trace.Entity)
					end
					if IsValid(cons) then
						rag.ZacConsLH = cons
					end
					break
				end
			end
		end
	else
		if IsValid(rag.ZacConsLH) then
			rag.ZacConsLH:Remove()
			rag.ZacConsLH = nil
		end
	end
	if ply:KeyDown(IN_WALK) and !ply:GetActiveWeapon().SupportTPIK then
		local bone = rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_R_Hand"))
		local phys = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_R_Hand")))
		if not IsValid(rag.ZacConsRH) and (not rag.ZacNextGrRH or rag.ZacNextGrRH <= CurTime()) then
			rag.ZacNextGrRH = CurTime() + 0.01
			for i = 1, 3 do
				local offset = phys:GetAngles():Up() * 5
				if i == 2 then
					offset = phys:GetAngles():Right() * 5
                end
				if i == 3 then
					offset = phys:GetAngles():Right() * -5
				end
				local traceinfo = {
					start = phys:GetPos(),
					endpos = phys:GetPos() + offset,
					filter = rag,
					output = trace,
				}
				local trace = util.TraceLine(traceinfo)
				if trace.Hit and not trace.HitSky then
					local cons = constraint.Weld(rag, trace.Entity, bone, trace.PhysicsBone, 0, false, false)
					if trace.Entity:IsPlayer() and !trace.Entity.Fake then
						Faking(trace.Entity)
					end
					if trace.Entity:IsWeapon() then
						ply:PickupWeapon(trace.Entity)
						ply:SetActiveWeapon(trace.Entity)
					end
					if IsValid(cons) then
						rag.ZacConsRH = cons
					end
					break
				end
			end
		end
	else
		if IsValid(rag.ZacConsRH) then
			rag.ZacConsRH:Remove()
			rag.ZacConsRH = nil
		end
	end
end)