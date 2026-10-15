--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/m9q8s2mg6ph7r8ft9z/lua/weapons/weapon_food_soda_breen.lua <
    > Callstack:  <
]]

AddCSLuaFile()

SWEP.Base = "weapon_food_base"
SWEP.PrintName = "Breen Soda"
SWEP.Category = "Weapons - Food"

SWEP.Slot = 1
SWEP.SlotPos = 3

SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/c_grenade.mdl")
SWEP.WorldModel = Model("models/weapons/food/popcan.mdl")
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


SWEP.IconPos = Vector(50,0,0)
SWEP.IconAng = Angle(0,0,0)

SWEP.Config = {
	holdType = "slam",
	viewModel = {
		model = "models/weapons/food/popcan.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		angle = Angle(0, 180, 165),
		offset = Vector(3.3, 0, -3.5),
		scale = 1
	},
	worldModel = {
		model = "models/weapons/food/popcan.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		angle = Angle(0, 0, 190),
		offset = Vector(-3.2, 0.5, 3.5),
		scale = 1
	},
	Animations = {
		["default"] = {
			[0] = {
				view = {
					["ValveBiped.Grenade_body"] = {
						scale = Vector(0.001, 0.001, 0.001)
					},
					["ValveBiped.Pin"] = {
						scale = Vector(0.001, 0.001, 0.001)
					}
				}
			},
			[1] = {
				easing = FoodSwep.ANIMATION_EASE_DRINK,
				duration = 1.7,
				view = {
					["ValveBiped.Bip01_R_UpperArm"] = {	
						angle = Angle(0, -50, 0),
						pos = Vector(0, 0, 0)
					},
					["ValveBiped.Bip01_R_Forearm"] = {	
						angle = Angle(-45, -20, 0),
						pos = Vector(0, 0, 0)
					},
					["ValveBiped.Bip01_R_Hand"] = {	
						angle = Angle(0, 45, 0)
					},
					["ValveBiped.Bip01_Spine4"] = {	
						pos = Vector(0, -8, -12)
					}
				},
				world = {
					["ValveBiped.Bip01_R_UpperArm"] = {	
						angle = Angle(0, -65, 0)
					},
					["ValveBiped.Bip01_R_Forearm"] = {	
						angle = Angle(5, -15, 0)
					}
				}
			}
		}
	}
}

function SWEP:Deploy()
	self:EmitSound("zames/weapons/food/can_open.wav")
end

function SWEP:OnAnimationEvent(id)
	if id == FoodSwep.ANIMATION_EVENT_HALF then 
		if SERVER then

			if (self:Clip1() == 1) then
				self:Remove()
			end

			self:EmitSound("zames/weapons/food/drink2.wav")
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
