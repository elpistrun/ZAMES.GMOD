--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/weapon_food_burger.lua <
    > Callstack:  <
]]

AddCSLuaFile()

SWEP.Base = "weapon_food_base"
SWEP.PrintName = "Burger"
SWEP.Category = "Weapons - Food"

SWEP.Slot = 1
SWEP.SlotPos = 3

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/c_bugbait.mdl")
SWEP.WorldModel = Model("models/food/burger.mdl")
SWEP.ViewModelFOV = 60
SWEP.UseHands = true

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.ColorEffect = Color(211,177,23)

SWEP.IconPos = Vector(40,0,-14)
SWEP.IconAng = Angle(0,0,0)

SWEP.Config = {
	holdType = "slam",
	viewModel = {
		model = "models/food/burger.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		angle = Angle(90, 0, 180),
		offset = Vector(-3, -7.6, -0.2),
		scale = 0.8
	},
	worldModel = {
		model = "models/food/burger.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		angle = Angle(90, 0, 180),
		offset = Vector(-3, -7.5, -0.2),
		scale = 0.8
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
						angle = Angle(20, 0, 0)
					}
				}
			},
			[1] = {
				easing = FoodSwep.ANIMATION_EASE_IN_EASE_OUT,
				duration = 1.7,
				view = {
					["ValveBiped.Bip01_R_UpperArm"] = {	
						angle = Angle(0, -50, 0),
						pos = Vector(0, 0, 0 )
					},
					["ValveBiped.Bip01_R_Forearm"] = {	
						angle = Angle(-45, -20, 0),
						pos = Vector(0, 0, 0 )
					},
					["ValveBiped.Bip01_R_Hand"] = {	
						angle = Angle(70, -25, -90)
					},
					["ValveBiped.Bip01_Spine4"] = {	
						pos = Vector(0, -8, -15)
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
						angle = Angle(25, 20, 40)
					}
				}
			}
		}
	}
}

function SWEP:OnAnimationEvent(id)
	if id == FoodSwep.ANIMATION_EVENT_HALF then
		if SERVER then
			self:Remove()
			self:EmitSound("zames/weapons/food/eat1.wav")
			FoodSwep:AddHealth(self.Owner, 10)
		end

		if self.CreateCrumbs then
			self:CreateCrumbs()
		end

		local stamina = self.Owner:GetNWFloat("Stamina", 100)
        
        stamina = math.max(0, stamina + 20)
        self.Owner:SetNWFloat("Stamina", stamina)
	end
end
