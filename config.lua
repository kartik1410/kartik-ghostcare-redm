Config = {}

Config.Framework = 'auto' -- 'auto', 'vorp' or 'rsg'

Config.Months = { 10 } -- months it runs in, {} for all year
Config.NightHours = { from = 21, to = 5 }

Config.CheckInterval = 45 -- seconds
Config.Chance = 25 -- % per check, once the haunting level allows a scare
Config.Cooldown = { min = 10, max = 25 } -- minutes after a ghost
Config.MinorCooldown = { min = 1, max = 3 } -- minutes after a small scare
Config.AloneRadius = 50.0

-- haunting level goes 0 - 100, up while alone outside at night and down otherwise
Config.Haunting = {
    gain = 5, -- per check
    decay = 15, -- per check
    drop = 50, -- after a ghost scare
    tiers = { 20, 50, 80 }, -- level needed for tier 1, 2 and 3
}

Config.GhostAlpha = 150 -- 0 - 255
Config.GhostModels = {
    'u_f_m_story_nightfolk_01',
    'cs_swampfreak',
    'cs_creepyoldlady',
    'a_m_m_unicorpse_01',
    'a_f_m_unicorpse_01',
    'a_m_m_armcholeracorpse_01',
    'a_f_m_armcholeracorpse_01',
}

-- tier 1 are the small scares, weight 0 disables a scare
Config.Scares = {
    glimpse = { tier = 1, weight = 25 },
    footsteps = { tier = 1, weight = 30 },
    lightsout = { tier = 1, weight = 20 },
    spooked = { tier = 1, weight = 25 },

    behind = { tier = 2, weight = 30 },
    trail = { tier = 2, weight = 25 },
    rider = { tier = 2, weight = 20 },
    screamer = { tier = 2, weight = 15 },

    follow = { tier = 3, weight = 50 },
    angel = { tier = 3, weight = 50 },
    possessed = { tier = 3, weight = 50 },
    stalker = { tier = 3, weight = 50 },
}

-- map zones with a higher chance, added on top of Config.Chance
Config.Hotspots = {
    { zone = 'BayouNwa', chance = 30 },
    { zone = 'lagras', chance = 30 },
    { zone = 'BluewaterMarsh', chance = 20 },
    { zone = 'Braithwaite', chance = 20 },
    { zone = 'TallTrees', chance = 10 },
    { zone = 'roanoke', chance = 10 },
}

Config.SoundVolume = 0.8 -- 0.0 - 1.0, for the files in html/sounds
Config.SoundRange = 30.0 -- how far a ghost can be heard

-- in-game screams, tried in order until one plays. Test each with /hauntvoice 1, /hauntvoice 2 ...
Config.Screams = {
    { sound = 'creature_scream', soundset = 'RESSH_sounds' },
    { speech = 'SCREAM_SHOCKED', voice = 'VOCALIZATIONS_BANKLOADED_FEMALE_01', variations = 6 },
    { speech = 'SCREAM_SHOCKED', voice = 'VOCALIZATIONS_BANKLOADED_MALE_01', variations = 4 },
    { speech = 'GENERIC_FRIGHTENED_HIGH', voice = '0053_A_F_M_BLWTOWNFOLK_01_WHITE_01', variations = 3 },
}
Config.ScreamPain = 8 -- 0 - 12, last fallback, test with /hauntvoice pain 8

Config.CompassItem = 'spirit_compass'
Config.CompassRange = 60.0
Config.CompassChance = 10 -- extra % while the compass is out
