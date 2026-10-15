--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/lua/weapons/weapon_hg_t_syringepoison.lua <
    > Callstack:  <
]]

AddCSLuaFile()

SWEP.Base = "weapon_base"

SWEP.PrintName = "Тетродотоксин"
SWEP.Author = "homigrad"
SWEP.Instructions = "Вколоть в любую часть тела и ждать..."

SWEP.Spawnable = true
SWEP.Category = "Weapons - Medkit"

SWEP.DrawWeaponInfoBox = false

SWEP.Slot = 3
SWEP.SlotPos = 0

SWEP.WorldModel = "models/weapons/sweps/eft/injector/w_meds_injector.mdl"
SWEP.HoldType = "normal"

SWEP.dwmModeScale = 0.5
SWEP.dwmForward = 3
SWEP.dwmRight = 1
SWEP.dwmUp = 0

SWEP.DrawCrosshair = false 

SWEP.dwmAUp = 0
SWEP.dwmARight = 90
SWEP.dwmAForward = 0

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

local function eyeTrace(ply)
    local att1 = ply:LookupAttachment("eyes")
    if not att1 or att1 <= 0 then return end
    local att = ply:GetAttachment(att1)
    if not att then return end
    local tr = {}
    tr.start = att.Pos
    tr.endpos = tr.start + ply:EyeAngles():Forward() * 50
    tr.filter = ply
    return util.TraceLine(tr)
end

local function GetPlayerRagdoll(ply)
    if not IsValid(ply) then return end
    local rag = ply.FakeRagdoll
    if IsValid(rag) then return rag end
    rag = ply:GetNWEntity("FakeRagdoll")
    if IsValid(rag) then return rag end
    rag = ply:GetNWEntity("Ragdoll")
    if IsValid(rag) then return rag end
end

local function RagdollOwner(ent)
    if not IsValid(ent) then return end
    if ent:IsPlayer() then return ent end
    local owner = ent:GetNWEntity("RagdollOwner")
    return IsValid(owner) and owner or nil
end

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
    if CLIENT then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local trace = eyeTrace(owner)
    if not trace then return end
    local ent = trace.Entity
    if not IsValid(ent) then return end
    local ply = ent:IsPlayer() and ent or RagdollOwner(ent)
    if not ply then return end
    self:Poison(ply)
end

function SWEP:SecondaryAttack()
end

if SERVER then
    function SWEP:Poison(ent)
        -- Проверка на кости убрана, колем сразу
        ent.otravlen = true
        timer.Create("Cyanid" .. ent:EntIndex() .. "1", 30, 1, function()
            if ent:Alive() and ent.otravlen then
                ent:EmitSound("vo/npc/male01/moan0" .. math.random(1, 5) .. ".wav", 60)
            end

            timer.Create("Cyanid" .. ent:EntIndex() .. "2", 10, 1, function()
                if ent:Alive() and ent.otravlen then
                    ent:EmitSound("vo/npc/male01/moan0" .. math.random(1, 5) .. ".wav", 60)
                end
            end)

            timer.Create("Cyanid" .. ent:EntIndex() .. "3", 15, 1, function()
                if ent:Alive() and ent.otravlen then
                    ent.KillReason = "poison"
                    ent:Kill()
                end
            end)
        end)
        
        self:GetOwner():EmitSound("snd_jack_hmcd_needleprick.wav", 30)
        self:Remove()
        if self:GetOwner():HasWeapon("weapon_hands") then
            self:GetOwner():SelectWeapon("weapon_hands")
        end
        
        return false
    end

else

    SWEP.IconPos = Vector(40,3,0)
    SWEP.IconAng = Angle(0,45,90)

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

    function SWEP:DrawHUD()
        local owner = self:GetOwner()
        if not IsValid(owner) then return end
        local traceResult = eyeTrace(owner)
        if not traceResult then return end
        local ent = traceResult.Entity
        if not IsValid(ent) then return end

        local isTarget = ent:IsPlayer() or ent.FakeRagdoll
        
        if isTarget then
            surface.SetDrawColor(Color(255, 0, 0, 255))
            draw.NoTexture()
            draw.DrawText("Вколоть шприц", "TargetID", traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y - 40, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
        end
    end

    local model
    function SWEP:DrawWorldModel()
        local owner = self:GetOwner()
        if not IsValid(owner) then
            self:DrawModel()
            return
        end
        if not IsValid(model) then
            model = ClientsideModel(self.WorldModel, RENDER_GROUP_OPAQUE_ENTITY)
            if IsValid(model) then
                model:SetNoDraw(true)
            end
            self:CallOnRemove("RemoveWM_Syringe", function() if IsValid(model) then model:Remove() end end)
        end
        local Pos, Ang = owner:GetBonePosition(owner:LookupBone("ValveBiped.Bip01_R_Hand"))
        if not Pos then return end
        model:SetModel(self.WorldModel)
        Pos:Add(Ang:Forward() * self.dwmForward)
        Pos:Add(Ang:Right() * self.dwmRight)
        Pos:Add(Ang:Up() * self.dwmUp)
        model:SetPos(Pos)
        Ang:RotateAroundAxis(Ang:Up(), self.dwmAUp)
        Ang:RotateAroundAxis(Ang:Right(), self.dwmARight)
        Ang:RotateAroundAxis(Ang:Forward(), self.dwmAForward)
        model:SetAngles(Ang)
        model:SetModelScale(self.dwmModeScale)
        model:DrawModel()
    end
end
