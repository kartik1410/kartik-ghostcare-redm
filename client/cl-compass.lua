Compass = {}

local isOn = false
local level = 0
local hotspotHashes = {}

local tickDelay = { 1600, 1000, 600, 320, 140 }
local barColours = {
    { 196, 176, 132 },
    { 196, 176, 132 },
    { 214, 150, 72 },
    { 200, 96, 48 },
    { 170, 28, 28 },
}

CreateThread(function()
    for i, spot in ipairs(Config.Hotspots) do
        hotspotHashes[i] = GetHashKey(spot.zone)
    end
end)

local function zoneAt(pos, kind)
    return Citizen.InvokeNative(0x43AD8FC02B429D33, pos.x, pos.y, pos.z, kind, Citizen.ResultAsInteger())
end

function Compass.HotspotChance(pos)
    local town, district, swamp = zoneAt(pos, 1), zoneAt(pos, 10), zoneAt(pos, 5)
    local chance = 0

    for i, spot in ipairs(Config.Hotspots) do
        local hash = hotspotHashes[i]
        if hash == town or hash == district or hash == swamp then
            chance = math.max(chance, spot.chance)
        end
    end

    return chance
end

local function readLevel()
    local dist = Ghost.NearestDistance()
    if dist and dist < Config.CompassRange then
        return math.max(1, math.ceil(5 * (1.0 - dist / Config.CompassRange)))
    end

    local base = GetHauntTier()
    if Compass.HotspotChance(GetEntityCoords(PlayerPedId())) > 0 then base = base + 1 end

    if base == 0 then return 0 end
    return math.min(4, base + math.random(0, 1))
end

local function drawMeter()
    local x, y = 0.5, 0.94
    DrawRect(x, y, 0.13, 0.045, 18, 12, 8, 190, false, false)

    for i = 1, 5 do
        local c = barColours[i]
        DrawRect(x - 0.048 + (i - 1) * 0.024, y, 0.018, 0.022, c[1], c[2], c[3], i <= level and 255 or 50, false, false)
    end
end

function Compass.IsOn()
    return isOn
end

function Compass.Toggle()
    isOn = not isOn
    Bridge.Notify(isOn and 'You take out the spirit compass' or 'You put the spirit compass away', isOn and 'success' or 'inform')
    if not isOn then return end

    CreateThread(function()
        while isOn do
            level = readLevel()
            Wait(300)
        end
        level = 0
    end)

    CreateThread(function()
        local nextTick = 0

        while isOn do
            if IsEntityDead(PlayerPedId()) then
                isOn = false
                break
            end

            drawMeter()

            if level > 0 and GetGameTimer() >= nextTick then
                Effects.Sound('tick')
                nextTick = GetGameTimer() + tickDelay[level]
            end

            Wait(0)
        end
    end)
end

RegisterNetEvent('kartik-ghostscare:client:toggleCompass', Compass.Toggle)
