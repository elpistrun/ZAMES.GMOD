--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/weapon_food_coffee.lua <
    > Callstack:  <
]]

AddCSLuaFile()

SWEP.Base = "weapon_food_base"
SWEP.PrintName = "Coffee"
SWEP.Category = "Weapons - Food"

SWEP.Slot = 1
SWEP.SlotPos = 3

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/c_bugbait.mdl")
SWEP.WorldModel = Model("models/weapons/food/coffee.mdl")
SWEP.ViewModelFOV = 60
SWEP.UseHands = true

SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 3
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.ColorEffect = Color(136,85,8)

SWEP.IconPos = Vector(60,-0.5,1)
SWEP.IconAng = Angle(0,250,0)

SWEP.Config = {
	holdType = "slam",
	viewModel = {
		model = "models/weapons/food/coffee.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		angle = Angle(0, 130, 180),
		offset = Vector(-1.5, 2, -4),
		scale = 0.9
	},
	worldModel = {
		model = "models/weapons/food/coffee.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		angle = Angle(0, 130, 180),
		offset = Vector(-1.5, 2, -4),
		scale = 0.9
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
					["ValveBiped.Bip01_R_Hand"] = {	
						angle = Angle(0, -15, -65)
					}
				}
			},
			[1] = {
				easing = FoodSwep.ANIMATION_EASE_DRINK,
				duration = 2.5,
				view = {
					["ValveBiped.Bip01_R_UpperArm"] = {	
						angle = Angle(0, -50, 0),
						pos = Vector(0, 0, 0)
					},
					["ValveBiped.Bip01_R_Forearm"] = {	
						angle = Angle( -45, -20, 0),
						pos = Vector(0, 0, 0)
					},
					["ValveBiped.Bip01_R_Hand"] = {	
						angle = Angle(30, -25, -90)
					},
					["ValveBiped.Bip01_Spine4"] = {	
						pos = Vector(0, -8, -12)
					}
				},
				world = {
					["ValveBiped.Bip01_R_UpperArm"] = {	
						angle = Angle(0, -85, 0)
					},
					["ValveBiped.Bip01_R_Forearm"] = {	
						angle = Angle(5, 25, 0)
					},
					["ValveBiped.Bip01_R_Hand"] = {	
						angle = Angle(35, 20, 16)
					}
				}
			}
		}
	}
}

function SWEP:OnAnimationEvent(id)
	if id == FoodSwep.ANIMATION_EVENT_HALF then 
		if SERVER then

			if (self:Clip1() == 1) then
				self:Remove()
			end

			self:EmitSound("zames/weapons/food/drink1.wav")
			FoodSwep:AddHealth(self.Owner, 25)
		end

		self:SetClip1(self:Clip1() - 1)

		if self.CreateCrumbs then
			self:CreateCrumbs()
		end

		local stamina = self.Owner:GetNWFloat("Stamina", 100)
        
        stamina = math.max(0, stamina + 15)
        self.Owner:SetNWFloat("Stamina", stamina)
	end
end
