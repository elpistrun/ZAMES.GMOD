--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/lua/weapons/tr_instinct.lua <
    > Callstack:  <
]]

SWEP.Base                   = "weapon_base"

SWEP.PrintName              = "Инстинкт"
SWEP.Author                 = "asyan"
SWEP.Instructions           = "Нажмите ПКМ чтобы предчувствовать свой дар трейтора"
SWEP.Category               = "Weapons - Other"

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.DrawWeaponInfoBox = false

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = "none"

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.Delay        = 150 -- Стандартный кулдаун

SWEP.Weight                 = 5
SWEP.AutoSwitchTo           = false
SWEP.AutoSwitchFrom         = false

SWEP.Slot                   = 4
SWEP.SlotPos                = 2
SWEP.DrawAmmo               = false
SWEP.DrawCrosshair          = false

SWEP.ViewModel              = "models/weapons/c_arms.mdl" 
SWEP.WorldModel             = "" 

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
    if CLIENT and IsFirstTimePredicted() then
        SWEP_ActivateInstinct()
    end
    
    -- Используем стандартную задержку
    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
end


if CLIENT then
    local PlaySound = CreateClientConVar("instinct_play_sound", "1", true, false, "Whether to play a sound when using Instinct")
    local ScreenShake = CreateClientConVar("instinct_screen_shake", "1", true, false, "Whether to shake the screen when using Instinct")

    local MaxRadius = CreateClientConVar("instinct_scan_maxradius", "10000", true, false, "The maximum radius of the Instinct scan")
    local TravelTime = CreateClientConVar("instinct_scan_traveltime", "5", true, false, "The time it takes for the Instinct scan to reach its maximum radius")

    local math_floor = math.floor
    local math_min = math.min
    local string_sub = string.sub
    local tonumber = tonumber

    local SPHERE_CONFIG = {
        COLOR = Color(255, 0, 0),
        RADIUS = 60,
        DETAIL = 32,
        THICKNESS = 16,
    }

    local SCAN_CONFIG = {
        CURRENT_RADIUS = 0,
        MAX_RADIUS = 10000,
        START_SPEED = 300,
        TIME_UNTIL_COMPLETION = 5,
        FADE_START = 0.8,
        LAST_TIME = 0,
        START_TIME = 0,
        START_DURATION = 0.5,
        MARK_DURATION = 5,
        MARK_FADE_TIME = 2,
        IS_SCANNING = false,
    }

    local markedEntities = {}

    local function calculateAlpha()
        local progressRatio = SCAN_CONFIG.CURRENT_RADIUS / MaxRadius:GetInt()
        
        local fadeAlpha = 255
        if progressRatio >= SCAN_CONFIG.FADE_START then
            local fadeProgress = (progressRatio - SCAN_CONFIG.FADE_START) / (1 - SCAN_CONFIG.FADE_START)
            fadeAlpha = math.max(0, math.floor((1 - fadeProgress) * 255))
        end
        
        return fadeAlpha
    end

    local function calculateSpeed(deltaTime)
        local currentTime = CurTime()
        local elapsedTime = currentTime - SCAN_CONFIG.START_TIME
        
        elapsedTime = math.min(elapsedTime, TravelTime:GetFloat())
        
        local startProgress = math.min(elapsedTime / SCAN_CONFIG.START_DURATION, 1)
        local startMultiplier = startProgress * startProgress
        
        if SCAN_CONFIG.CURRENT_RADIUS >= MaxRadius:GetInt() then
            return 0
        end
        
        local v0 = SCAN_CONFIG.START_SPEED
        local T = TravelTime:GetFloat()
        local a = 2 * (MaxRadius:GetInt() - v0 * T) / (T * T)
        local v = v0 + a * elapsedTime
        
        return math.max(0, v * startMultiplier)
    end

    local function MaskEntity(ent)
        if not markedEntities[ent] then return end
        
        local currentTime = CurTime()
        local markData = markedEntities[ent]
        local color = markData.color
        
        local alpha = 255
        local timeSinceMark = currentTime - markData.time
        
        if timeSinceMark > SCAN_CONFIG.MARK_DURATION then
            local fadeProgress = (timeSinceMark - SCAN_CONFIG.MARK_DURATION) / SCAN_CONFIG.MARK_FADE_TIME
            alpha = math.max(0, 255 * (1 - fadeProgress))
            
            if alpha == 0 then
                markedEntities[ent] = nil
                return
            end
        end

        render.SetBlend(1)
        render.SetColorModulation(1, 1, 1)
        
        render.SetStencilEnable(true)
        render.SetStencilReferenceValue(0)
        render.SetStencilPassOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        render.ClearStencil()

        render.SetStencilCompareFunction(STENCIL_NEVER)
        render.SetStencilFailOperation(STENCIL_REPLACE)
        render.SetStencilReferenceValue(0x1C)
        render.SetStencilWriteMask(0x55)

        ent:DrawModel()

        render.SetStencilTestMask(0xF3)
        render.SetStencilReferenceValue(0x10)
        render.SetStencilCompareFunction(STENCIL_EQUAL)

        local markColor = Color(color.r, color.g, color.b, alpha)
        render.ClearBuffersObeyStencil(markColor.r, markColor.g, markColor.b, markColor.a, false)

        render.SetStencilEnable(false)
    end

    local function isInSphere(ent, spherePos, radius)
        if not IsValid(ent) then return false end
        local entPos = ent:GetPos()
        return entPos:DistToSqr(spherePos) <= radius * radius
    end

    local SPHERE_NUMBER_RULES = {[0]=2,[1]=1,[3]=2,[5]=1,[7]=2,[9]=1}

    local function BorderSphereUnit(color, pos, radius, detail, thickness)
        radius = math_floor(radius)
        thickness = math_floor(thickness or 24)
        detail = math_min(math_floor(detail or 32), 100)
        
        if thickness >= radius then 
            thickness = radius 
        end
        
        local lastDigit = tonumber(string_sub(tostring(radius), -1))
        local rule = SPHERE_NUMBER_RULES[lastDigit]
        local ds = 1
        if rule == 1 then ds = 1 elseif rule == 2 then ds = 0.50 end

        local viewEntity = LocalPlayer():GetViewEntity()
        local cam_pos, cam_angle
        
        if viewEntity == LocalPlayer() then
            cam_pos = LocalPlayer():EyePos()
            cam_angle = LocalPlayer():GetAimVector():Angle()
        else
            cam_pos = viewEntity:GetPos()
            cam_angle = viewEntity:GetAngles()
        end
        
        local cam_normal = cam_angle:Forward()
        
        render.SetStencilEnable(true)
        render.SetStencilReferenceValue(0x55)
        render.SetStencilTestMask(0x1C)
        render.SetStencilWriteMask(0x1C)
        render.ClearStencil()
        
        render.SetColorMaterial()
        
        local detailWithDs = detail + ds
        local radiusMinusThickness = radius - thickness
        
        render.SetStencilReferenceValue(1)
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
        render.SetStencilZFailOperation(STENCILOPERATION_INVERT)
        
        local invisibleColor = Color(0, 0, 0, 0)
        render.DrawSphere(pos, -radius, detail, detail, invisibleColor)
        render.DrawSphere(pos, radius, detail, detail, invisibleColor)
        render.DrawSphere(pos, -radiusMinusThickness, detailWithDs, detailWithDs, invisibleColor)
        render.DrawSphere(pos, radiusMinusThickness, detailWithDs, detailWithDs, invisibleColor)
        
        render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
        render.DrawSphere(pos, radius + 0.25, detailWithDs, detailWithDs, invisibleColor)
        
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
        cam.IgnoreZ(true)
        render.SetStencilReferenceValue(1)
        render.DrawQuadEasy(cam_pos + cam_normal * 10, -cam_normal, 10000, 10000, color, cam_angle.roll)
        
        cam.IgnoreZ(false)
        render.SetStencilEnable(false)
    end

    function SWEP_ActivateInstinct()
        if PlaySound:GetBool() then
            surface.PlaySound("zames/vgui/ping3.mp3")
        end

        if ScreenShake:GetBool() then
            util.ScreenShake(Vector(0, 0, 0), 2, 3, 2, 1000)
        end
        
        SCAN_CONFIG.CURRENT_RADIUS = 0
        SCAN_CONFIG.LAST_TIME = CurTime()
        SCAN_CONFIG.START_TIME = CurTime()
        SCAN_CONFIG.IS_SCANNING = true
    end

    hook.Add("PostDrawTranslucentRenderables", "Instinct_SWEP", function()
        local currentTime = CurTime()
        
        for ent, markData in pairs(markedEntities) do
            if IsValid(ent) and ent:IsPlayer() and ent:Alive() then
                MaskEntity(ent)
            else
                markedEntities[ent] = nil
            end
        end

        if not SCAN_CONFIG.IS_SCANNING then return end

        local deltaTime = currentTime - SCAN_CONFIG.LAST_TIME
        SCAN_CONFIG.LAST_TIME = currentTime
       
        local speed = calculateSpeed(deltaTime)
        local newRadius = SCAN_CONFIG.CURRENT_RADIUS + speed * deltaTime
        
        SCAN_CONFIG.CURRENT_RADIUS = math.min(newRadius, MaxRadius:GetInt())
       
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
       
        local spherePos = ply:WorldSpaceCenter()
        
        for _, ent in pairs(player.GetAll()) do
            if ent != ply and ent:Alive() then
                if isInSphere(ent, spherePos, SCAN_CONFIG.CURRENT_RADIUS) and not markedEntities[ent] then
                    markedEntities[ent] = {
                        time = currentTime,
                        color = Color(255, 0, 0)
                    }
                end
            end
        end

        if SCAN_CONFIG.CURRENT_RADIUS < MaxRadius:GetInt() then
            local alpha = calculateAlpha()
            local sphereColor = Color(SPHERE_CONFIG.COLOR.r, SPHERE_CONFIG.COLOR.g, SPHERE_CONFIG.COLOR.b, alpha)
            BorderSphereUnit(sphereColor, spherePos, SCAN_CONFIG.CURRENT_RADIUS, SPHERE_CONFIG.DETAIL, SPHERE_CONFIG.THICKNESS)
        else
            SCAN_CONFIG.IS_SCANNING = false
            SCAN_CONFIG.CURRENT_RADIUS = 0
        end
    end)
end
