--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/weapon_food_apple.lua <
    > Callstack:  <
]]

AddCSLuaFile()

SWEP.Base = "weapon_food_base"
SWEP.PrintName = "Apple"
SWEP.Category = "Weapons - Food"

SWEP.Slot = 1
SWEP.SlotPos = 3

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/c_bugbait.mdl")
SWEP.WorldModel = Model("models/weapons/food/apple.mdl")
SWEP.ViewModelFOV = 60
SWEP.UseHands = true

SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.ColorEffect = Color(252, 231, 113)

SWEP.IconPos = Vector(50,0,-3)
SWEP.IconAng = Angle(0,0,0)


SWEP.Config = {
	holdType = "slam",
	viewModel = {
		model = "models/weapons/food/apple.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		angle = Angle( 0, 0, 165 ),
		offset = Vector( -2.9, -0.9, 4.5 ),
		scale = 0.7
	},
	worldModel = {
		model = "models/weapons/food/apple.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		angle = Angle( 0, 0, 165 ),
		offset = Vector( -3.2, -1.9, 3.5 ),
		scale = 0.7
	},
	Animations = {
		["default"] = {
			[0] = {
				view = {
					["ValveBiped.cube"] = {	
						scale = Vector(0.001, 0.001, 0.001) 
					},
					["ValveBiped.cube1"] = { 
						scale = Vector(0.001, 0.001, 0.001) 
					},
					["ValveBiped.cube2"] = { 
						scale = Vector(0.001, 0.001, 0.001) 
					},
					["ValveBiped.cube3"] = { 
						scale = Vector(0.001, 0.001, 0.001) 
					},
				}
			},
			[1] = {
				easing = FoodSwep.ANIMATION_EASE_IN_EASE_OUT,
				duration = 1.2,
				view = {
					["ValveBiped.Bip01_R_Forearm"] = {	
						angle = Angle(-95, -160, 20),
						pos = Vector(0, 0, -6)
					},
					["ValveBiped.Bip01_R_Hand"] = {	
						angle = Angle(0, 0, 90)
					}
				},
				world = {
					["ValveBiped.Bip01_R_UpperArm"] = {	
						angle = Angle(0, -70, -6)
					},
					["ValveBiped.Bip01_R_Forearm"] = {	
						angle = Angle(0, -15, 0)
					},
					["ValveBiped.Bip01_R_Hand"] = {	
						angle = Angle(0, 0, 90)
					}
				}
			}
		}
	}
}

function SWEP:UpdateBodyGroups()
    if not IsValid(self) then return end

    local clip = self:Clip1()
    local targetBodyGroup = nil

    if clip == 2 then
        targetBodyGroup = "010"
    elseif clip == 1 then
        targetBodyGroup = "020"
    end

    if not targetBodyGroup then return end

    if IsValid(self.ClientViewModel) then
        self.ClientViewModel:SetBodyGroups(targetBodyGroup)
    end

    if IsValid(self.ClientWorldModel) then
        self.ClientWorldModel:SetBodyGroups(targetBodyGroup)
    end
end

function SWEP:OnCreateCliendsideModels()
	self:UpdateBodyGroups()
end

function SWEP:OnAnimationEvent(id)
	if id == FoodSwep.ANIMATION_EVENT_HALF then 
		if SERVER then
			if (self:Clip1() == 1) then
				self:Remove()
			end

			FoodSwep:AddHealth(self.Owner, 15)
			self:EmitSound("zames/weapons/food/eat2.wav")
		end
		
		self:SetClip1(self:Clip1() - 1)

		if CLIENT then
			self:UpdateBodyGroups()
		end

		if self.CreateCrumbs then
            self:CreateCrumbs()
        end

		local stamina = self.Owner:GetNWFloat("Stamina", 100)
        
        stamina = math.max(0, stamina + 10)
        self.Owner:SetNWFloat("Stamina", stamina)
	end	
end
