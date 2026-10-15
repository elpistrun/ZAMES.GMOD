--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/lua/weapons/weapon_hidebomb.lua <
    > Callstack:  <
]]

AddCSLuaFile()

SWEP.PrintName = "Коробка-Взрывчатка"
SWEP.Author = "Developer"
SWEP.DrawWeaponInfoBox = false
SWEP.Instructions = "ЛКМ - поставить коробку. ПКМ - взорвать."
SWEP.Category = "Weapons - Grenades"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.UseHands = true

SWEP.WorldModel = "models/props_junk/cardboard_box004a.mdl"

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "BombsPlanted")
end

function SWEP:Initialize()
    self:SetHoldType("slam")
    if SERVER then
        self.SpawnedBoxes = {}
    end
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.5)
    
    if self:GetBombsPlanted() >= 1 then return end
    
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    local tr = util.TraceLine({
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * 75,
        filter = owner
    })
    
    if CLIENT then return end
    
    local target = tr.Entity
    local box
    
    if tr.Hit and IsValid(target) then
        box = ents.Create("info_target")
        box:SetPos(tr.HitPos)
        box:Spawn()
        
        box:SetParent(target)
        owner:EmitSound("weapons/c4/c4_plant.wav")
    else
        box = ents.Create("prop_physics")
        if not IsValid(box) then return end
        
        box:SetModel("models/props_junk/cardboard_box004a.mdl")
        
        if tr.Hit then
            box:SetPos(tr.HitPos + tr.HitNormal * 15)
        else
            box:SetPos(tr.HitPos)
        end
        
        box:SetAngles(Angle(0, owner:EyeAngles().y, 0))
        box:Spawn()
        
        local phys = box:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
    end
    
    table.insert(self.SpawnedBoxes, box)
    self:SetBombsPlanted(self:GetBombsPlanted() + 1)
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 1)

    self:EmitSound("zames/vgui/detonator.wav")
    
    if self:GetBombsPlanted() == 0 then return end
    
    if CLIENT then return end
    
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local boxesToExplode = self.SpawnedBoxes
    self.SpawnedBoxes = {}
    
    self:SetBombsPlanted(0)

    timer.Simple(0.3, function()
        for i, box in ipairs(boxesToExplode) do
            if IsValid(box) then
                local pos = box:GetPos()
                local parent = box:GetParent()
                
                local inflictor = IsValid(self) and self or owner
                
                util.BlastDamage(inflictor, owner, pos, 550, 450)

                if IsValid(parent) then
                    local dmg = DamageInfo()
                    dmg:SetDamage(450)
                    dmg:SetAttacker(owner)
                    dmg:SetInflictor(inflictor)
                    dmg:SetDamageType(DMG_CRUSH)
                    parent:TakeDamageInfo(dmg)
                end

                sound.Play("zames/weapons/darsu_eft/grenades/gren_expl3_indoor_close.ogg", pos, 90, 100, 1)
                ParticleEffect("pcf_jack_groundsplode_large", pos, vector_up:Angle())
                
                box:Remove()
            end
        end
    end)

    if IsValid(owner) and IsValid(self) then
        owner:StripWeapon(self:GetClass())
    end
end

function SWEP:OnRemove()
    if CLIENT then return end
    if self.SpawnedBoxes then
        for _, box in ipairs(self.SpawnedBoxes) do
            if IsValid(box) then
                box:Remove()
            end
        end
    end
end

if CLIENT then
    function SWEP:DrawHUD()
        local owner = self:GetOwner()
        if not IsValid(owner) then return end

        local bombs = self:GetBombsPlanted()
        
        local mainText = "ЛКМ - поставить коробку."
        local textX = ScrW() / 2
        local textY = ScrH() / 2 + 90
        
        if bombs > 0 then
            mainText = "ПКМ - Взорвать бомбу!"
            textX = textX + math.random(-1, 1)
            textY = textY + math.random(-1, 1)
        end
        
        draw.SimpleText(mainText, "PT.3", textX, textY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        local tr = util.TraceLine({
            start = owner:GetShootPos(),
            endpos = owner:GetShootPos() + owner:GetAimVector() * 120,
            filter = owner
        })

        if IsValid(tr.Entity) then
            local targetName = "объект"
            
            if tr.Entity:IsPlayer() then
                targetName = tr.Entity:Nick()
            elseif tr.Entity:IsNPC() then
                targetName = "NPC"
            end
            
            draw.SimpleText("Заложить бомбу в " .. targetName, "PT.3", ScrW() / 2, ScrH() / 2 + 50, Color(255, 50, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end

if CLIENT then
    SWEP.IconPos = Vector(100,0,0)
    SWEP.IconAng = Angle(0,90,90)

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

    function SWEP:DrawWorldModel()
        local owner = self:GetOwner()
        if not IsValid(owner) then self:DrawModel() return end

        if not IsValid(self.mdl) then
            self.mdl = ClientsideModel("models/props_junk/cardboard_box004a.mdl")
            if IsValid(self.mdl) then
                self.mdl:SetNoDraw(true)
                self.mdl:SetModelScale(0.5)
            end
            self:CallOnRemove("RemoveHidebombWM", function() if IsValid(self.mdl) then self.mdl:Remove() end end)
        end
        local matrix = owner:GetBoneMatrix(11)
        if not matrix then return end

        self.mdl:SetRenderOrigin(matrix:GetTranslation() + matrix:GetAngles():Forward() * 3 + matrix:GetAngles():Right() * 3)
        self.mdl:SetRenderAngles(matrix:GetAngles())
        self.mdl:DrawModel()
    end
end
