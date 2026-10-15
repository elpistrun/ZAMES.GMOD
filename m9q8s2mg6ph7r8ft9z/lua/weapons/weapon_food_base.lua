--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/weapon_food_base.lua <
    > Callstack:  <
]]

AddCSLuaFile()

SWEP.PrintName = "foodswep_base"
SWEP.Category = "Weapons - Food"
SWEP.Spawnable = false
SWEP.IsFoodBase = true

SWEP.Slot = 1
SWEP.SlotPos = 3

SWEP.ViewModel = Model("models/weapons/c_bugbait.mdl")
SWEP.WorldModel = Model("models/unconid/cupcake/cupcake.mdl")
SWEP.ViewModelFOV = 60
SWEP.UseHands = true

SWEP.DrawWeaponInfoBox = false
SWEP.DrawCrosshair = false

SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Config = nil

if CLIENT then
	function SWEP:ClearCliensideModels()
		if IsValid(self.ClientViewModel) then
			self.ClientViewModel:Remove()
		end

		if IsValid(self.ClientWorldModel) then
			self.ClientWorldModel:Remove()
		end
	end

	function SWEP:OnCreateCliendsideModels() end

	function SWEP:CreateCliensideModels()
		self:ClearCliensideModels()
		local config = self.Config

		if config.viewModel and config.viewModel.model then
			self.ClientViewModel = ents.CreateClientProp()
			self.ClientViewModel:SetModel(config.viewModel.model)
			self.ClientViewModel:SetNoDraw(true)
			self.ClientViewModel:SetModelScale( config.viewModel.scale)
		end

		if config.worldModel and config.worldModel.model then
			self.ClientWorldModel = ents.CreateClientProp()
			self.ClientWorldModel:SetModel(config.worldModel.model)
			self.ClientWorldModel:SetNoDraw(true)
			self.ClientWorldModel:SetModelScale(config.worldModel.scale)
		end
		self:OnCreateCliendsideModels()
	end

	function SWEP:DrawClientsideModel(ent, owner, config)
		if IsValid(ent) then
			local boneID = owner:LookupBone(config.bone)

			local pos = Vector(0, 0, 0)
			local ang = Angle(0, 0, 0)

			local mat = owner:GetBoneMatrix(boneID)

			if (mat) then
				pos, ang = mat:GetTranslation(), mat:GetAngles()
			end

			ang:RotateAroundAxis(ang:Up(), config.angle.y)
			ang:RotateAroundAxis(ang:Right(), config.angle.p)
			ang:RotateAroundAxis(ang:Forward(), config.angle.r)

			pos = pos + (ang:Up() * config.offset.y)
			pos = pos + (ang:Right() * config.offset.x)
			pos = pos + (ang:Forward() * config.offset.z)

			ent:SetPos(pos)
			ent:SetAngles(ang)
			ent:DrawModel()
		end
	end

	function SWEP:PostDrawViewModel(viewModel)
		if not IsValid(self.ClientViewModel) then
			self:CreateCliensideModels()
		end

		self.ClientViewModel:SetParent(viewModel)
		self:DrawClientsideModel(self.ClientViewModel, viewModel, self.Config.viewModel)
	end

	function SWEP:DrawWorldModel()
		if not IsValid(self.ClientWorldModel) then
			self:CreateCliensideModels()
		end

		if IsValid(self.Owner) then
			self:DrawClientsideModel(self.ClientWorldModel, self.Owner, self.Config.worldModel)
		else
			self:DrawModel()
		end
	end

	function SWEP:SetupPose()
		if not IsValid(self.Owner) then return end

		FoodSwep:SetBones(self.Owner, self.Config.Animations["default"][0].world)

		local viewModel = self.Owner:GetViewModel()

		if not IsValid(viewModel) then return end

		FoodSwep:SetBones(viewModel, self.Config.Animations["default"][0].view)
	end

	function SWEP:ResetPose()
		if not IsValid(self.Owner) then return end

		FoodSwep:ResetBones(self.Owner)

		local viewModel = self.Owner:GetViewModel()

		if not IsValid(viewModel) then return end

		FoodSwep:ResetBones(viewModel)
	end

	function SWEP:AnimationEvent(id)
		self:OnAnimationEvent(id)

		if self.Owner == LocalPlayer() then
			net.Start("FoodSwep_AnimationEvent")
			net.WriteInt(id, 32)
			net.SendToServer()
		end
	end

	function SWEP:UpdateAnimation()
		if (self.AnimationTimeStart + self.AnimationDuration) > CurTime() then
			self.AnimationTime = ((CurTime() - self.AnimationTimeStart) / self.AnimationDuration) * 1

			local easeFunction = self.AnimationEasing

			if easeFunction == FoodSwep.ANIMATION_EASE_DRINK then
				if self.AnimationTime > 0.3 and not self.IsAnimationHalf then
					self:AnimationEvent(FoodSwep.ANIMATION_EVENT_HALF)
					self.IsAnimationHalf = true
				end
			else
				if self.AnimationTime > 0.5 and not self.IsAnimationHalf then
					self:AnimationEvent(FoodSwep.ANIMATION_EVENT_HALF)
					self.IsAnimationHalf = true
				end
			end

			local fraction = FoodSwep.EasingFunctions[easeFunction](self.AnimationTime)

			if not IsValid(self.Owner) then return end

			FoodSwep:InterpolateBones(self.Owner, fraction, self.Config.Animations["default"][self.AnimationFrame - 1].world, self.Config.Animations["default"][self.AnimationFrame].world)

			local viewModel = self.Owner:GetViewModel()

			if not IsValid(viewModel) then return end

			FoodSwep:InterpolateBones(viewModel, fraction, self.Config.Animations["default"][self.AnimationFrame - 1].view, self.Config.Animations["default"][self.AnimationFrame].view)
		else
			if not self.IsAnimationHalf then
				self:AnimationEvent(FoodSwep.ANIMATION_EVENT_HALF)
				self.IsAnimationHalf = true
			end

			if self.Config.Animations["default"][self.AnimationFrame + 1] then
				self.AnimationTime = 0
				self.AnimationTimeStart = CurTime()
				self:SetAnimationFrame(self.AnimationFrame + 1)
			else
				self:ResetAnimaton()
				self:AnimationEvent(FoodSwep.ANIMATION_EVENT_COMPLETE)
			end
		end
	end

	function SWEP:SetAnimationFrame(frame)
		if self.Config.Animations["default"][frame] then
			self.AnimationFrame = frame
			self.AnimationDuration = self.Config.Animations["default"][frame].duration
			self.AnimationEasing = self.Config.Animations["default"][frame].easing
		end
	end

	function SWEP:PlayAnimation()
		self:SetAnimationFrame(1)

		if self.AnimationFrame == 1 then
			self:SetupPose()
			self.AnimationTimeStart = CurTime()
			self.AnimationPlaying = true
		end
	end

	function SWEP:ResetAnimaton()
		self.AnimationTimeStart = 0
		self.AnimationTime = 0
		self.AnimationDuration = 0
		self.AnimationFrame = 0
		self.AnimationPlaying = false
		self.AnimationName = ""

		self.IsAnimationHalf = false
	end
	
	function SWEP:CustomAmmoDisplay()
		self.AmmoDisplay = self.AmmoDisplay or {}
		self.AmmoDisplay.Draw = true
		self.AmmoDisplay.PrimaryClip = self:Clip1()

		return self.AmmoDisplay
	end

	function SWEP:OnRemove()
		self:ClearCliensideModels()
		self:ResetAnimaton()
		self:ResetPose()
	end
end

function SWEP:Initialize()
	self:SetHoldType(self.Config.holdType)

	if CLIENT then
		self.AnimationTimeStart = 0
		self.AnimationTime = 0
		self.AnimationDuration = 0
		self.AnimationFrame = 0
		self.AnimationPlaying = false
		self.AnimationName = ""

		self.IsAnimationHalf = false
		self:CreateCliensideModels()
	end
end

function SWEP:OnAnimationEvent(id) 
end

function SWEP:PrimaryAttack()	
	
	self:SetNextPrimaryFire(CurTime() + 1)

	if SERVER then
		net.Start("FoodSwep_PlayAnimation")
		net.WriteEntity(self.Owner)
		net.Broadcast()
	end
end

SWEP.ColorEffect = Color(255,255,255)

function SWEP:CreateCrumbs()
    if not CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local pos = owner:GetShootPos() + owner:GetAimVector() * 15 - owner:GetUp() * 5
    local emitter = ParticleEmitter(pos)

    for n = 1, 3 do
        local drop = emitter:Add("effects/splash1", pos)

        if drop then
            drop:SetVelocity(VectorRand() * 18 + owner:GetAimVector() * math.Rand(10, 20))
            drop:SetGravity(Vector(0, 0, -400))
            drop:SetAirResistance(math.Rand(5, 10))
            drop:SetDieTime(math.Rand(0.8, 0.9))
            drop:SetStartAlpha(math.Rand(150, 220))
            drop:SetEndAlpha(0)
            drop:SetStartSize(math.Rand(5, 9))
            drop:SetEndSize(0.3)
            drop:SetLighting(false)

            local col = self.ColorEffect or Color(255, 255, 255)
            drop:SetColor(col.r, col.g, col.b)

            drop:SetCollide(true)
            drop:SetBounce(0.1)
        end
    end

    emitter:Finish()
end

function SWEP:SecondaryAttack() end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
    if not IsValid(DrawModel) then
        DrawModel = ClientsideModel( (self.WorldModelReal or self.WorldModel), RENDER_GROUP_OPAQUE_ENTITY )
        DrawModel:SetNoDraw( true )
    else
        DrawModel:SetModel( self.WorldModelReal or self.WorldModel )

        local vec = Vector(0,0,0)
	    local ang = Angle(0,0,0)

        cam.Start3D( vec, ang, 20, x, y + 35, wide, tall, 5, 4096 )
            cam.IgnoreZ( true )
            render.SuppressEngineLighting( true )

            render.SetLightingOrigin( self:GetPos() )
            render.ResetModelLighting( 1 , 1 , 1 )
            render.SetColorModulation( 1, 1, 1 )
            render.SetBlend( 255 )
            render.SetModelLighting( 4, 1, 1, 1 )

            local modelPos = self.IconPos or Vector(0, 0, 0)
            local modelAng = self.IconAng or Angle(0, 0, 0)

            DrawModel:SetRenderOrigin( modelPos )
            DrawModel:SetRenderAngles( modelAng )
            
            DrawModel:DrawModel()
            
            DrawModel:SetRenderOrigin()
            DrawModel:SetRenderAngles()

            render.SetColorModulation( 1, 1, 1 )
            render.SetBlend( 1 )
            render.SuppressEngineLighting( false )
            cam.IgnoreZ( false )
        cam.End3D()
    end

    self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
end
