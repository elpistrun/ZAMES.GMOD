--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/k2s2mg9m2n/m1t6s2mh3q8d3m/w9s2mp3q8/2vt4kx3khs2m6ql5xr/cl_2vt4kx3khs2m6ql5xr.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:33
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:52
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:23
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

local wasOtrub = false
local otrubPanel = nil
local soundMuted = false

local function StopAllSounds()
    RunConsoleCommand("stopsound")
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) then
            ent:StopSound("*")
        end
    end
end

if IsValid(G_OtrubPanel) then 
    G_OtrubPanel:Remove() 
end

hook.Add("Think", "Otrub_ClientMonitor", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local isOtrub = ply:GetNWBool("Otrub")

    if isOtrub and not G_WasOtrub then
        G_WasOtrub = true
        
        G_SoundMuted = true
        timer.Simple(0.15, function() StopAllSounds() end)
        
        timer.Create("Otrub_SoundBlocker", 0.05, 0, function()
            if G_SoundMuted then
                StopAllSounds()
            else
                timer.Remove("Otrub_SoundBlocker")
            end
        end)

        if IsValid(G_OtrubPanel) then G_OtrubPanel:Remove() end

        G_OtrubPanel = vgui.Create("DPanel")
        G_OtrubPanel:SetSize(ScrW(), ScrH())
        G_OtrubPanel:SetPos(0, 0)
        G_OtrubPanel:SetMouseInputEnabled(false)
        G_OtrubPanel:SetKeyboardInputEnabled(false)
        
        G_OtrubPanel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 255))
        end

    elseif not isOtrub and G_WasOtrub then
        G_WasOtrub = false
        
        G_SoundMuted = false
        timer.Remove("Otrub_SoundBlocker")

        if IsValid(G_OtrubPanel) then
            G_OtrubPanel.wakeUpStartTime = CurTime()
            G_OtrubPanel.wakeUpAnimTime = 2.5
            
            G_OtrubPanel.Paint = function(self, w, h)
                local timePassed = CurTime() - self.wakeUpStartTime
                local progress = math.Clamp(timePassed / self.wakeUpAnimTime, 0, 1)

                if progress >= 1 then
                    self:Remove()
                    return
                end

                local eyelidMaxHeight = h / 2
                local openAmount = eyelidMaxHeight * math.pow(progress, 0.6) 
                local currentEyelidHeight = eyelidMaxHeight - openAmount

                draw.RoundedBox(0, 0, 0, w, currentEyelidHeight, Color(0, 0, 0))
                draw.RoundedBox(0, 0, h - currentEyelidHeight, w, currentEyelidHeight, Color(0, 0, 0))
            end
        end
    end
end)

local config = {
    stressPerBullet = 35,      -- Уровень стресса за одну пулю (макс 100)
    decayRate = 25,            -- Скорость спада в секунду
    muffleDSP = 32,            -- ID звукового эффекта оглушения
}

local currentStress = 0
local isMuffled = false

local m = Material("zames/vignette/vignette.png", "noclamp smooth")
local alphanew = 0

net.Receive("NearMiss_AddStress", function()
    local sup_point = net.ReadVector()
    local distance = net.ReadFloat()
    
    currentStress = math.Clamp(currentStress + config.stressPerBullet, 0, 100)
    
    local vol = 1
    
    if distance < 30 then
        sound.Play("zames/weapons/bul_snap/supersonic_snap_" .. math.random(1, 18) .. ".wav", sup_point, 75, 100, vol)
    end
    sound.Play("zames/weapons/bul_flyby/subsonic_" .. math.random(1, 27) .. ".wav", sup_point, 75, 100, vol)
end)

hook.Add("Think", "NearMiss_Logic", function()
    if currentStress > 0 then
        currentStress = math.Clamp(currentStress - (FrameTime() * config.decayRate), 0, 100)
    end
    
    local intensity = currentStress / 100
    
    if intensity > 0.4 and not isMuffled then
        LocalPlayer():SetDSP(config.muffleDSP, false)
        isMuffled = true
    elseif intensity <= 0.2 and isMuffled then
        LocalPlayer():SetDSP(0, false)
        isMuffled = false
    end
end)

hook.Add("RenderScreenspaceEffects", "NearMiss_Visuals", function()
    if not render.SupportsPixelShaders_2_0() then return end
    
    local targetAlpha = currentStress / 100
    alphanew = Lerp(6 * FrameTime(), alphanew, targetAlpha)
    
    if alphanew > 0.005 then
        
        if currentStress > 0 then
            local intensity = currentStress / 100
            DrawSharpen(1.2 * intensity, 1.5 * intensity)
            DrawMotionBlur(0.1, 0.6 * intensity, 0.05)
            
            local colMod = {
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = -0.15 * intensity,
                ["$pp_colour_contrast"] = 1 + (0.3 * intensity),
                ["$pp_colour_colour"] = 1 - (0.6 * intensity),
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0
            }
            DrawColorModify(colMod)
        end
        
        render.SetMaterial(m)
        m:SetFloat("$alpha", alphanew)
        
        for i = 1, 4 do 
            render.DrawScreenQuad()
        end
    end
end)

local drip_sounds = {
    "zames/organism/bloodsplashing/blooddrip1.wav",
    "zames/organism/bloodsplashing/blooddrip2.wav",
    "zames/organism/bloodsplashing/blooddrip3.wav",
    "zames/organism/bloodsplashing/blooddrip4.wav"    
}

local function CreateDynamicGibEffects(pos, scaleMult)
    local emitter = ParticleEmitter(pos, false)
    if not IsValid(emitter) then return end

    local smoke = emitter:Add("particle/particle_smokegrenade", pos)
    if smoke then
        smoke:SetDieTime(math.Rand(1.5, 2.5))
        smoke:SetStartAlpha(200)
        smoke:SetEndAlpha(0)
        smoke:SetStartSize(math.Rand(80, 120) * scaleMult)
        smoke:SetEndSize(math.Rand(150, 250) * scaleMult)
        smoke:SetColor(130, 10, 10)
        smoke:SetRoll(math.Rand(0, 360))
        smoke:SetGravity(Vector(0, 0, 20))
        smoke:SetVelocity(VectorRand() * 25)
    end

    local dropsCount = math.floor(15 * scaleMult)
    for i = 1, dropsCount do
        local blood = emitter:Add("effects/droplets/drop13", pos)
        if blood then
            blood:SetDieTime(math.Rand(1, 2.5))
            blood:SetStartSize(math.Rand(6, 12))
            blood:SetEndSize(0)
            blood:SetStartLength(math.Rand(20, 40))
            blood:SetEndLength(math.Rand(30, 60))
            blood:SetColor(150, 0, 0)
            blood:SetGravity(Vector(0, 0, -1050)) 
            blood:SetVelocity(VectorRand() * math.Rand(200, 450) + Vector(0, 0, math.Rand(100, 300)))
            
            blood:SetCollide(true)
            blood:SetBounce(0.1)
            blood:SetCollideCallback(function(prt, hitPos, normal)
                util.Decal("Blood", hitPos + normal, hitPos - normal)
                sound.Play(table.Random(drip_sounds), hitPos, 65, math.random(140, 200), 1)
            end)
        end
    end
    
    emitter:Finish()
end


net.Receive("body_gib", function()
    local hitPos = net.ReadVector()
    local plyEnt = net.ReadEntity()

    CreateDynamicGibEffects(hitPos, 3)

    local effectdata = EffectData()
    effectdata:SetOrigin(hitPos)
    effectdata:SetScale(2)
    effectdata:SetMagnitude(2)
    util.Effect("BloodImpact", effectdata)

    local effectdata2 = EffectData()
    effectdata2:SetOrigin(hitPos)
    effectdata2:SetScale(9)
    effectdata2:SetMagnitude(3)
    effectdata2:SetColor(0)
    effectdata2:SetFlags(3)
    util.Effect("bloodspray", effectdata2)

    for i = 1, 255 do 
        local randomEnd = hitPos + (VectorRand() * 250) 
        local randomStart = hitPos + (VectorRand() * 20) 
        util.Decal("Blood", randomStart, randomEnd, {plyEnt, LocalPlayer()})
    end

    sound.Play("zames/organism/headshot_01.wav", hitPos, 75, 100, 1)
end)

net.Receive("headshot_gib", function()
    local headPos = net.ReadVector()

    CreateDynamicGibEffects(headPos, 0.6)

    local effectdata = EffectData()
    effectdata:SetOrigin(headPos)
    effectdata:SetScale(9)     
    effectdata:SetMagnitude(2) 
    effectdata:SetColor(0)     
    effectdata:SetFlags(3)
    util.Effect("bloodspray", effectdata)

    local effectdata2 = EffectData()
    effectdata2:SetOrigin(headPos)
    util.Effect("BloodImpact", effectdata2)

    sound.Play("zames/organism/headshot_01.wav", headPos, 75, 100, 1)
end)

net.Receive("neck_gib", function()
    local headPos = net.ReadVector()
    
    CreateDynamicGibEffects(headPos, 0.4)

    sound.Play("zames/organism/neck_snap_01.wav", headPos, 75, 100, 1)
end)

net.Receive("leg_gib", function()
    local hitPos = net.ReadVector()

    -- Частицы для оторванной ноги
    CreateDynamicGibEffects(hitPos, 0.5)

    local effectdata = EffectData()
    effectdata:SetOrigin(hitPos)
    effectdata:SetScale(9)     
    effectdata:SetMagnitude(2) 
    effectdata:SetColor(0)     
    effectdata:SetFlags(3)
    util.Effect("bloodspray", effectdata)

    local effectdata2 = EffectData()
    effectdata2:SetOrigin(hitPos)
    util.Effect("BloodImpact", effectdata2)

    sound.Play("zames/organism/headshot_01.wav", hitPos, 75, 100, 1)
end)
