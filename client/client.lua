Scares = {}

local busy = false
local nextScare = 0
local hauntLevel = 0

local function isNight()
    local hour = GetClockHours()
    local from, to = Config.NightHours.from, Config.NightHours.to

    if from <= to then return hour >= from and hour < to end
    return hour >= from or hour < to
end

local function isAlone(pos)
    local me = PlayerId()

    for _, player in ipairs(GetActivePlayers()) do
        if player ~= me and #(GetEntityCoords(GetPlayerPed(player)) - pos) < Config.AloneRadius then
            return false
        end
    end

    return true
end

local function canBeHaunted(ped)
    if not GlobalState.ghostscareActive or not isNight() then return false end
    if IsEntityDead(ped) or GetInteriorFromEntity(ped) ~= 0 then return false end

    return isAlone(GetEntityCoords(ped))
end

function GetHauntTier()
    local tier = 0

    for i, threshold in ipairs(Config.Haunting.tiers) do
        if hauntLevel >= threshold then tier = i end
    end

    return tier
end

local function pickScare(only, anyTier)
    local tier = anyTier and math.huge or GetHauntTier()
    local pool, total = {}, 0

    for name, scare in pairs(Scares) do
        local settings = Config.Scares[name] or {}
        local weight

        if only then
            weight = name == only and 1 or 0
        else
            weight = (settings.tier or 1) <= tier and (settings.weight or 0) or 0
        end

        if weight > 0 and scare.canRun() then
            pool[#pool + 1] = { name = name, weight = weight }
            total = total + weight
        end
    end

    if total == 0 then return end

    local roll = math.random() * total
    for _, entry in ipairs(pool) do
        roll = roll - entry.weight
        if roll <= 0 then return entry.name end
    end

    return pool[#pool].name
end

local function runScare(name)
    busy = true
    local ok, played = pcall(Scares[name].run)
    busy = false

    if not ok then
        if IsScreenFadedOut() or IsScreenFadingOut() then DoScreenFadeIn(250) end
        Effects.Hunted(false)
        print(('^1[kartik-ghostscare] %s scare errored: %s^0'):format(name, played))
        return
    end

    if not played then return end

    local minor = (Config.Scares[name] and Config.Scares[name].tier or 1) == 1
    local cooldown = minor and Config.MinorCooldown or Config.Cooldown
    nextScare = GetGameTimer() + math.random(cooldown.min, cooldown.max) * 60000

    if not minor then
        hauntLevel = math.max(0, hauntLevel - Config.Haunting.drop)
    end
end

CreateThread(function()
    while true do
        Wait(Config.CheckInterval * 1000)

        local ped = PlayerPedId()
        if canBeHaunted(ped) then
            hauntLevel = math.min(100, hauntLevel + Config.Haunting.gain)

            if not busy and GetGameTimer() >= nextScare and not IsPauseMenuActive() then
                local chance = Config.Chance + Compass.HotspotChance(GetEntityCoords(ped))
                if Compass.IsOn() then chance = chance + Config.CompassChance end

                if math.random(100) <= chance then
                    local name = pickScare()
                    if name then runScare(name) end
                end
            end
        else
            hauntLevel = math.max(0, hauntLevel - Config.Haunting.decay)
        end
    end
end)

RegisterNetEvent('kartik-ghostscare:client:haunt', function(only)
    if busy then
        return Bridge.Notify('A scare is already running', 'error')
    end

    if only and not Scares[only] then
        return Bridge.Notify(('Unknown scare: %s'):format(only), 'error')
    end

    local name = pickScare(only, true)
    if not name then
        return Bridge.Notify(('Can\'t run %s here'):format(only or 'a scare'), 'error')
    end

    CreateThread(function()
        runScare(name)
    end)
end)

RegisterNetEvent('kartik-ghostscare:client:testVoice', function(mode, value)
    local ped = PlayerPedId()

    if mode == 'pain' then
        local id = tonumber(value) or Config.ScreamPain
        Effects.Voice(ped, id)
        return Bridge.Notify(('Pain voice %d'):format(id))
    end

    local index = tonumber(mode)
    if not index then
        Effects.PlayFile('scream')
        Effects.Voice(ped)
        return Bridge.Notify('Playing the full scream chain')
    end

    local scream = Config.Screams[index]
    if not scream then
        return Bridge.Notify(('There are %d screams in Config.Screams'):format(#Config.Screams), 'error')
    end

    local played = Effects.PlayScream(ped, scream)
    Bridge.Notify(('%d: %s %s'):format(index, scream.speech or scream.sound, played and 'played' or 'did not play'), played and 'success' or 'error')
end)
