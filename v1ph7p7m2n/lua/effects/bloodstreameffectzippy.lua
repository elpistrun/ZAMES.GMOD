--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/lua/effects/bloodstreameffectzippy.lua <
    > Callstack:  <
]]

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    --чеча: ТАК АЛЕША АРЕСТОВЫВАЙТЕ ЕГО чик чик чик

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CreateConVar("nextgenblood4_blood_stream_reps_multiplier", "1", FCVAR_ARCHIVE)
-- гыгыгы
local particles = {
    "effects/droplets/drop13",

}

-- што ты сука думал чат жбт код?
local decals = {
    "effects/droplets/drop2",
    "effects/droplets/drop3",
	"effects/droplets/drop4",
    "effects/droplets/drop5",
    "effects/droplets/drop6",
	"effects/droplets/drop7",
	"effects/droplets/drop8",
	"effects/droplets/drop9",
	"effects/droplets/drop10",
	"effects/droplets/drop11",
	"effects/droplets/drop12"
}


-- партикл летящей крови
local particle_length_random = {min=20,max=60}
local particle_start_lengt_mult = 0.3
local particle_scale = 3
 
local particle_gravity = 1050
local particle_force = 70
local particle_pulsate_max_force = 90
local particle_pulsate_speed_mult = 10
 
local particle_reps_stream = 30000
local particle_reps_burst = 100000

 
local particle_fps = 25
local particle_lifetime = 3
 
local stream_particle_lifetime = 2.2
local burst_particle_lifetime = 0.4
 
 
-- ВЫ НЕ ПОВЕРИТЕ НО ЭТО ДЕКАЛИ!!!!!!!!!!!
local decal_scale = 4
 
 
-- ВЫ ТОЖЕ НЕ ПОВЕРИТЕ НО ЭТО ЗВУКИ КАПАЮЩЕЙ КРОВЯКИ!!!!!!!!!!
local drip_sounds = {
    "zames/organism/bloodsplashing/blooddrip1.wav",
    "zames/organism/bloodsplashing/blooddrip2.wav",
    "zames/organism/bloodsplashing/blooddrip3.wav",
    "zames/organism/bloodsplashing/blooddrip4.wav"    

}
local sound_volume = 1
local sound_level = 50
 
 local squrt_sounds = {
    "zames/organism/squirting/artery_squirt_1.wav",
    "zames/organism/squirting/artery_squirt_2.wav",
    "zames/organism/squirting/artery_squirt_3.wav",
    "zames/organism/squirting/artery_squirt_3.wav",
    "zames/organism/squirting/artery_squirt_2.wav",
    "zames/organism/squirting/artery_squirt_1.wav",
    "zames/organism/squirting/artery_squirt_2.wav",
    "zames/organism/squirting/artery_squirt_2.wav",
	"zames/organism/squirting/artery_squirt_3.wav",
	"zames/organism/squirting/artery_squirt_1.wav",
	"zames/organism/squirting/artery_squirt_3.wav",
	"zames/organism/squirting/artery_squirt_2.wav",
	
}
local sound_volume2 = 0
local sound_level2 = 0
 
-- бара дау...
local impact_chance = 1 -- 1 in x
 
 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
local function make_materials(tbl)
    local materials = {}
 
    for _,v in ipairs(tbl) do
        local imat = Material(v)
        table.insert(materials, imat)
    end
    
    return materials
end
 
local decal_mats = make_materials(decals)
local particle_mats = make_materials(particles)
 
local min_strenght = 0.25
 
function EFFECT:Init(data)
    local ent = data:GetEntity()
 
    if not IsValid(ent) then return end
 
    local flags = data:GetFlags()
    self.reps = (flags==1 && particle_reps_burst) or (flags==0 && particle_reps_stream) or 0
		
	
	
    self.StartTime = CurTime()
    self.CurrentPos = ent:GetPos()
    self.CurrentStrenght = 1
    self:UpdateExtraForce()
	
	
	
    self.timername = "NextGen4BloodStreamTimer"..ent:EntIndex()
    local emitter = ParticleEmitter(self.CurrentPos, false)
	
	sound.Play(table.Random(squrt_sounds), ent:GetPos(), sound_level2, math.Rand(95,105), sound_volume2)
    timer.Create(self.timername, math.Rand(0.5,5)/particle_fps, self.reps, function()
        if !IsValid(ent) or !IsValid(self) or !self then
            emitter:Finish()
            timer.Remove(self.timername)
            return
        end
		sound.Play(table.Random(squrt_sounds), ent:GetPos(), sound_level2, math.Rand(95,105), sound_volume2)
        ent.CurrentPos = ent:GetPos()
 
        local length = math.Rand(particle_length_random.min, particle_length_random.max)
 
        local particle = emitter:Add( table.Random(particle_mats), ent.CurrentPos )
        particle:SetDieTime( particle_lifetime*self.CurrentStrenght )
        particle:SetStartSize( math.Rand(1.9, 3.8)*particle_scale )
        particle:SetEndSize(0)
        particle:SetStartLength( length*particle_scale*particle_start_lengt_mult )
        particle:SetEndLength( length*particle_scale )
        particle:SetGravity( Vector(0,0,-particle_gravity) )
        particle:SetVelocity( ent:GetForward()*-(particle_force+self.ExtraForce)*self.CurrentStrenght )
        particle:SetCollide( true )
        particle:SetCollideCallback( function( _, pos, normal )
            if math.random(1, impact_chance) == 1 && (self.CurrentStrenght or min_strenght) > 0.2 then
                sound.Play(table.Random(drip_sounds), pos, sound_level, math.Rand(95,105), sound_volume)
                util.DecalEx(table.Random(decal_mats), Entity(0), pos, normal, Color(255,255,255), decal_scale, decal_scale)
                --НЫЭ НЫЭ НЫЭ НЫЭ
            end
        end)
 
        if timer.RepsLeft(self.timername) == 0 then emitter:Finish() end
    end)
end
 
function EFFECT:UpdateExtraForce() self.ExtraForce = particle_pulsate_max_force * (1+math.sin(CurTime()*particle_pulsate_speed_mult)) end
 
function EFFECT:Think()
    if self.timername and timer.Exists(self.timername) then
        local lifetime = CurTime()-self.StartTime
        local dietime = self.reps*(1/particle_fps)
        self.CurrentStrenght = math.Clamp( 1 - (lifetime/dietime)*(1-min_strenght), 0, 1 )
 
        self:UpdateExtraForce()
        return true
    else
        return false
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Render() end
