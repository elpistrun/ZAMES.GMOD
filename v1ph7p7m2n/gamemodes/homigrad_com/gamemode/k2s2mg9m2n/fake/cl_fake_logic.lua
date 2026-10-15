local lply = LocalPlayer()

hook.Add("Player Think","Player_Fake",function(ply,time)
	ply.Fake = ply:GetNWBool("Fake")
	ply.FakeRagdoll = ply:GetNWEntity("FakeRagdoll")

	local ent = hg.GetCurrentCharacter(ply)

	if ent:IsRagdoll() then
		if ply:GetNWBool("LeftArm") then
			hg.bone.Set(ent,"l_finger0",Vector(0,0,0),Angle(0,20,0),1,0.2)
			hg.bone.Set(ent,"l_finger01",Vector(0,0,0),Angle(0,20,0),1,0.2)
			hg.bone.Set(ent,"l_finger1",Vector(0,0,0),Angle(0,-40,0),1,0.2)
			hg.bone.Set(ent,"l_finger11",Vector(0,0,0),Angle(0,-80,0),1,0.2)
			hg.bone.Set(ent,"l_finger2",Vector(0,0,0),Angle(0,-40,0),1,0.2)
			hg.bone.Set(ent,"l_finger21",Vector(0,0,0),Angle(0,-80,0),1,0.2)
		else
			hg.bone.Set(ent,"l_finger0",Vector(0,0,0),Angle(0,0,0),1,0.1)
			hg.bone.Set(ent,"l_finger01",Vector(0,0,0),Angle(0,0,0),1,0.1)
			hg.bone.Set(ent,"l_finger1",Vector(0,0,0),Angle(0,0,0),1,0.1)
			hg.bone.Set(ent,"l_finger11",Vector(0,0,0),Angle(0,0,0),1,0.1)
			hg.bone.Set(ent,"l_finger2",Vector(0,0,0),Angle(0,0,0),1,0.1)
			hg.bone.Set(ent,"l_finger21",Vector(0,0,0),Angle(0,0,0),1,0.1)
		end

		if ply:GetNWBool("RightArm") then
			hg.bone.Set(ent,"r_finger0",Vector(0,0,0),Angle(0,20,0),1,0.2)
			hg.bone.Set(ent,"r_finger01",Vector(0,0,0),Angle(0,20,0),1,0.2)
			hg.bone.Set(ent,"r_finger1",Vector(0,0,0),Angle(0,-40,0),1,0.2)
			hg.bone.Set(ent,"r_finger11",Vector(0,0,0),Angle(0,-80,0),1,0.2)
			hg.bone.Set(ent,"r_finger2",Vector(0,0,0),Angle(0,-40,0),1,0.2)
			hg.bone.Set(ent,"r_finger21",Vector(0,0,0),Angle(0,-80,0),1,0.2)
		else
			hg.bone.Set(ent,"r_finger0",Vector(0,0,0),Angle(0,0,0),1,0.1)
			hg.bone.Set(ent,"r_finger01",Vector(0,0,0),Angle(0,0,0),1,0.1)
			hg.bone.Set(ent,"r_finger1",Vector(0,0,0),Angle(0,0,0),1,0.1)
			hg.bone.Set(ent,"r_finger11",Vector(0,0,0),Angle(0,0,0),1,0.1)
			hg.bone.Set(ent,"r_finger2",Vector(0,0,0),Angle(0,0,0),1,0.1)
			hg.bone.Set(ent,"r_finger21",Vector(0,0,0),Angle(0,0,0),1,0.1)
		end
	end
end)



hook.Add("HUDPaint","Shit123",function()
	if ROUND_NAME == "dr" and lply:GetNWBool("Fake") and lply:Alive() then
		draw.SimpleText(string.format(hg.GetPhrase("dr_youwilldiein"),math.Clamp(math.Round(lply:GetNWFloat("TimeToDeath") - CurTime(),1),0,100000)),"H.25",ScrW()/2,ScrH()/1.5,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
end)

concommand.Add("fake",function()
	net.Start("fake")
	net.SendToServer()
end)
