--[[
    > File stolen by <
     __   ___      __  __                  ___ ___                ___  __   __   __               ___
    |__) |__  |\ |  / /  \ \ / |     |\/| |__   |  |__| \ / |    |__  /  ` / _` /  \ |\ | | |\ | |__
    |__) |___ | \| /_ \__/  |  |___  |  | |___  |  |  |  |  |___ |___ \__, \__> \__/ | \| | | \| |___

    > Server: ZAMES RU SERVER #1 Homicide | Быстрая загрузка (5.42.211.79:24215) <
    > File: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/n3zl5n3b/sh_gcal_bocw_gestures.lua <
    > Callstack: addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:26
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/loader.lua:46
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/shared.lua:25
[C]:-1
addons/v1ph7p7m2n/gamemodes/homigrad_com/gamemode/cl_init.lua:1 <
]]

AddCSLuaFile() --// v2026.7.26

if SERVER then
    util.PrecacheModel("weapons/gcal/gcal_bocw_gesture.mdl")
end

if not CLIENT then return end
if not GCAL then return end

local gestures = {
    "hello",       "needhelp",     "thanks",       "acknowledge",  "cancel", 
    "celebration", "rallyup",      "needaride",    "negative",     "sorry", 
    "taunt",       "goodjob",      "checkwatch",   "blowakiss",    "chefskiss", 
    "comeatme",    "knucklecrack", "crankjob",     "tightsqueeze", "rockon", 
    "framed",      "doubleguns",   "loveya",       "payme",        "getcrushed",
    "quiet",       "scheming",     "cutthroat",    "slowclap",     "ohsnap",
    "thinkaboutit","tiniestviolin","watchingyou",  "yawn"
}

for _,v in pairs(gestures) do
    concommand.Add("g" .. v, function()
        if not GCAL:IsTrackActive("left_arm") and not GCAL:IsTrackActive("both_arms") then
            GCAL:Play("bocw_gesture_" .. v)
        end
    end)
end

GCAL:RegisterSecondHandAnim("bocw_gesture_hello", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "hello",
    speed = 1,
    lerp_peak = 0.75,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterSecondHandAnim("bocw_gesture_needhelp", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "need_help",
    speed = 0.5,
    lerp_peak = 1.5,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterSecondHandAnim("bocw_gesture_thanks", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "thanks",
    speed = 0.5,
    lerp_peak = 1.6,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterSecondHandAnim("bocw_gesture_acknowledge", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "acknowledge",
    speed = 0.5,
    lerp_peak = 1.3,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterSecondHandAnim("bocw_gesture_cancel", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "cancel",
    speed = 0.5,
    lerp_peak = 1.6,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterSecondHandAnim("bocw_gesture_celebration", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "celebration",
    speed = 0.5,
    lerp_peak = 1.6,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterSecondHandAnim("bocw_gesture_rallyup", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "group_up",
    speed = 0.5,
    lerp_peak = 1.7,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterSecondHandAnim("bocw_gesture_needaride", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "need_ride",
    speed = 0.5,
    lerp_peak = 1.6,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterSecondHandAnim("bocw_gesture_negative", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "negative",
    speed = 0.5,
    lerp_peak = 1.5,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterSecondHandAnim("bocw_gesture_sorry", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "sorry",
    speed = 0.5,
    lerp_peak = 1.45,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterSecondHandAnim("bocw_gesture_taunt", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "taunt",
    speed = 0.5,
    lerp_peak = 1.6,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterSecondHandAnim("bocw_gesture_goodjob", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "good_job",
    speed = 0.5,
    lerp_peak = 1.6,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterSecondHandAnim("bocw_gesture_checkwatch", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "check_watch",
    speed = 0.33,
    lerp_peak = 2.5,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

--=============================================================================
--=============================================================================
--=============================================================================
--=============================================================================
--=============================================================================

GCAL:RegisterSecondHandAnim("bocw_gesture_blowakiss", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "blow_kiss",
    sounds = {
        ["weapons/gcal/bocw/gesture_blow_kiss_kiss.wav"] = 0.7,
        ["weapons/gcal/bocw/gesture_blow_kiss_blow.wav"] = 1.1
    },
    speed = 0.5,
    lerp_peak = 1.8,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterSecondHandAnim("bocw_gesture_chefskiss", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "chefs_kiss",
    sounds = {["weapons/gcal/bocw/gesture_chefs_kiss.wav"] = 0},
    speed = 0.4,
    lerp_peak = 2.2,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterSecondHandAnim("bocw_gesture_comeatme", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "come_here",
    --sounds = {["weapons/gcal/bocw/gesture_comeatme.wav"] = 0},
    speed = 0.5,
    lerp_peak = 1.6,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterBothHandsAnim("bocw_gesture_knucklecrack", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "crack_knuckles",
    sounds = {["weapons/gcal/bocw/gesture_crack_knuckles.wav"] = 0},
    speed = 0.19,
    lerp_peak = 5,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})
GCAL:RegisterTPIKOptions("bocw_gesture_knucklecrack", {
    offset_y = -4,
    offset_z = -1
})

GCAL:RegisterBothHandsAnim("bocw_gesture_crankjob", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "crank_finger",
    sounds = {["weapons/gcal/bocw/gesture_crank_finger.wav"] = 0},
    speed = 0.19,
    lerp_peak = 4.6,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})
GCAL:RegisterTPIKOptions("bocw_gesture_crankjob", {
    offset_y = -2,
    offset_z = -2
})

GCAL:RegisterSecondHandAnim("bocw_gesture_tightsqueeze", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "death_grip",
    --sounds = {["weapons/gcal/bocw/gesture_tightsqueeze.wav"] = 0},
    speed = 0.25,
    lerp_peak = 3.8,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})
GCAL:RegisterTPIKOptions("bocw_gesture_tightsqueeze", {
    offset_x = 1,
    offset_y = -2
})

GCAL:RegisterSecondHandAnim("bocw_gesture_rockon", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "devil_horns",
    --sounds = {["weapons/gcal/bocw/gesture_rockon.wav"] = 0},
    speed = 0.25,
    lerp_peak = 3.7,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterBothHandsAnim("bocw_gesture_framed", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "finger_frame",
    --sounds = {["weapons/gcal/bocw/gesture_framed.wav"] = 0},
    speed = 0.33,
    lerp_peak = 2.6,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})
GCAL:RegisterTPIKOptions("bocw_gesture_framed", {
    offset_y = -3,
})

GCAL:RegisterBothHandsAnim("bocw_gesture_doubleguns", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "finger_guns",
    --sounds = {["weapons/gcal/bocw/gesture_doubleguns.wav"] = 0},
    speed = 0.4,
    lerp_peak = 2,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterBothHandsAnim("bocw_gesture_loveya", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "heart",
    --sounds = {["weapons/gcal/bocw/gesture_loveya.wav"] = 0},
    speed = 0.2,
    lerp_peak = 4.6,
    locktoply = true,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})
GCAL:RegisterTPIKOptions("bocw_gesture_loveya", {
    offset_y = -6,
})

GCAL:RegisterBothHandsAnim("bocw_gesture_payme", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "money_fingers",
    sounds = {["weapons/gcal/bocw/gesture_money_fingers.wav"] = 1},
    speed = 0.2,
    lerp_peak = 4.7,
    locktoply = true,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterBothHandsAnim("bocw_gesture_getcrushed", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    --camModel = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "point_down",
    sounds = {["weapons/gcal/bocw/gesture_point_down.wav"] = 0},
    speed = 0.22,
    lerp_peak = 4.3,
    locktoply = true,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})
GCAL:RegisterTPIKOptions("bocw_gesture_getcrushed", {
    offset_y = -2,
})

GCAL:RegisterSecondHandAnim("bocw_gesture_quiet", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "quiet",
    --sounds = {["weapons/gcal/bocw/gesture_quiet.wav"] = 0},
    speed = 0.33,
    lerp_peak = 2.3,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})
GCAL:RegisterTPIKOptions("bocw_gesture_quiet", {
    offset_x = 3,
    offset_y = -4.5,
    offset_z = -1,
})

GCAL:RegisterBothHandsAnim("bocw_gesture_scheming", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "scheming_hands",
    sounds = {["weapons/gcal/bocw/gesture_scheming_hands.wav"] = 0},
    speed = 0.2,
    lerp_peak = 4.3,
    locktoply = true,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})
GCAL:RegisterTPIKOptions("bocw_gesture_scheming", {
    offset_y = -3,
    offset_z = -4,
})

GCAL:RegisterSecondHandAnim("bocw_gesture_cutthroat", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "slit_throat",
    --sounds = {["weapons/gcal/bocw/gesture_ohsnap.wav"] = 0},
    speed = 0.25,
    lerp_peak = 3.5,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterBothHandsAnim("bocw_gesture_slowclap", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "slow_clap",
    sounds = {
        ["weapons/gcal/bocw/gesture_slowclap_1.wav"] = 1,
        ["weapons/gcal/bocw/gesture_slowclap_2.wav"] = 2.2,
        ["weapons/gcal/bocw/gesture_slowclap_3.wav"] = 3.4
    },
    speed = 0.2,
    lerp_peak = 4.7,
    locktoply = true,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})
GCAL:RegisterTPIKOptions("bocw_gesture_slowclap", {
    offset_y = -3,
    offset_z = -3,
})

GCAL:RegisterSecondHandAnim("bocw_gesture_ohsnap", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "snap",
    sounds = {["weapons/gcal/bocw/gesture_snap.wav"] = 0.7},
    speed = 0.5,
    lerp_peak = 1.6,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterSecondHandAnim("bocw_gesture_thinkaboutit", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "think_about_it",
    --sounds = {["weapons/gcal/bocw/gesture_thinkaboutit.wav"] = 0},
    speed = 0.5,
    lerp_peak = 1.8,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})
GCAL:RegisterTPIKOptions("bocw_gesture_thinkaboutit", {
    offset_z = -4,
})

GCAL:RegisterSecondHandAnim("bocw_gesture_tiniestviolin", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "tiniest_violin",
    sounds = {["weapons/gcal/bocw/gesture_tiniest_violin.wav"] = 0.6},
    speed = 0.3,
    lerp_peak = 3,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})

GCAL:RegisterSecondHandAnim("bocw_gesture_watchingyou", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "watching_you",
    --sounds = {["weapons/gcal/bocw/gesture_watchingyou.wav"] = 0},
    speed = 0.28,
    lerp_peak = 3.1,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})
GCAL:RegisterTPIKOptions("bocw_gesture_watchingyou", {
    offset_x = 5,
    offset_y = -2,
})

GCAL:RegisterSecondHandAnim("bocw_gesture_yawn", {
    addon_name = "BOCW Gestures",
    model = "weapons/gcal/gcal_bocw_gesture.mdl",
    sequence = "yawn",
    --sounds = {["weapons/gcal/bocw/gesture_yawn.wav"] = 0},
    speed = 0.3,
    lerp_peak = 3,
    thirdperson = true,
    cambone = true,
    cam_ang = Angle(0,0,0)
})
