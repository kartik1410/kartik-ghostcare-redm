Ghost = {}

local ghosts = {}

local function loadModel(name)
    local hash = GetHashKey(name)
    if not IsModelInCdimage(hash) then return end

    RequestModel(hash, false)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        if GetGameTimer() > timeout then return end
        Wait(0)
    end

    return hash
end

local function camForward()
    local rot = GetGameplayCamRot(2)
    local pitch, yaw = math.rad(rot.x), math.rad(rot.z)
    local c = math.abs(math.cos(pitch))
    return vector3(-math.sin(yaw) * c, math.cos(yaw) * c, math.sin(pitch))
end

function Ghost.GroundZ(x, y, z)
    local found, groundZ = GetGroundZFor_3dCoord(x, y, z + 10.0, false)
    if found then return groundZ end
end

function Ghost.LookDot(coords)
    local dir = coords - GetGameplayCamCoord()
    local len = #dir
    if len < 0.01 then return 1.0 end

    local fwd = camForward()
    return (dir.x * fwd.x + dir.y * fwd.y + dir.z * fwd.z) / len
end

function Ghost.PointFromCam(angle, dist)
    local pos = GetEntityCoords(PlayerPedId())
    local fwd = camForward()
    local len = math.sqrt(fwd.x * fwd.x + fwd.y * fwd.y)
    if len < 0.01 then return end

    local fx, fy = fwd.x / len, fwd.y / len
    local rad = math.rad(angle)
    local dx = fx * math.cos(rad) - fy * math.sin(rad)
    local dy = fx * math.sin(rad) + fy * math.cos(rad)

    local x, y = pos.x + dx * dist, pos.y + dy * dist
    local z = Ghost.GroundZ(x, y, pos.z)
    if not z or math.abs(z - (pos.z - 1.0)) > 3.0 then return end

    return vector3(x, y, z)
end

function Ghost.PointBehind(dist)
    return Ghost.PointFromCam(180, dist)
end

function Ghost.GetMount()
    local ped = PlayerPedId()
    if not IsPedOnMount(ped) then return end

    local mount = GetMount(ped)
    if mount and mount ~= 0 and DoesEntityExist(mount) then return mount end
end

function Ghost.DistAhead(entity, coords)
    local fwd = GetEntityForwardVector(entity)
    local diff = coords - GetEntityCoords(entity)
    return diff.x * fwd.x + diff.y * fwd.y
end

function Ghost.MoveToward(ped, dist)
    local playerPos = GetEntityCoords(PlayerPedId())
    local ghostPos = GetEntityCoords(ped)
    local diff = ghostPos - playerPos
    local len = #diff
    if len < 0.01 then return false end

    local x, y = playerPos.x + diff.x / len * dist, playerPos.y + diff.y / len * dist
    local z = Ghost.GroundZ(x, y, playerPos.z)
    if not z then return false end

    SetEntityCoords(ped, x, y, z, false, false, false, false)
    Ghost.Face(ped)
    return true
end

function Ghost.Spawn(coords, heading, keepPhysics)
    local hash = loadModel(Config.GhostModels[math.random(#Config.GhostModels)])
    if not hash then return end

    local ped = CreatePed(hash, coords.x, coords.y, coords.z, heading or 0.0, false, false, false, false)
    SetModelAsNoLongerNeeded(hash)
    if not DoesEntityExist(ped) then return end

    ghosts[ped] = true

    Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
    SetEntityAlpha(ped, 0, false)
    SetEntityInvincible(ped, true)
    SetEntityCanBeDamaged(ped, false)
    SetPedCanBeTargetted(ped, false)
    SetPedCanRagdoll(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    DisablePedPainAudio(ped, true)
    StopPedSpeaking(ped, true)

    if not keepPhysics then
        FreezeEntityPosition(ped, true)
        SetEntityCollision(ped, false, false)
    end

    return ped
end

function Ghost.Fade(ped, from, to, ms)
    local start = GetGameTimer()

    while DoesEntityExist(ped) do
        local t = math.min((GetGameTimer() - start) / ms, 1.0)
        SetEntityAlpha(ped, math.floor(from + (to - from) * t), false)
        if t >= 1.0 then return end
        Wait(0)
    end
end

function Ghost.Show(ped, ms)
    Ghost.Fade(ped, 0, Config.GhostAlpha, ms or 1500)
end

function Ghost.Face(ped)
    local from, to = GetEntityCoords(ped), GetEntityCoords(PlayerPedId())
    SetEntityHeading(ped, GetHeadingFromVector_2d(to.x - from.x, to.y - from.y))
end

function Ghost.Stare(ped)
    Ghost.Face(ped)
    TaskLookAtEntity(ped, PlayerPedId(), -1, 2048, 3, 0)
end

function Ghost.Remove(ped)
    if DoesEntityExist(ped) then DeleteEntity(ped) end
    ghosts[ped] = nil
end

function Ghost.FadeOut(ped)
    Ghost.Fade(ped, GetEntityAlpha(ped), 0, 1200)
    Ghost.Remove(ped)
end

function Ghost.Vanish(ped)
    if not DoesEntityExist(ped) then return Ghost.Remove(ped) end

    Effects.Smoke(GetEntityCoords(ped))
    Ghost.Fade(ped, GetEntityAlpha(ped), 0, 250)
    Ghost.Remove(ped)
end

function Ghost.NearestDistance()
    local pos = GetEntityCoords(PlayerPedId())
    local nearest

    for ped in pairs(ghosts) do
        if DoesEntityExist(ped) then
            local dist = #(GetEntityCoords(ped) - pos)
            if not nearest or dist < nearest then nearest = dist end
        else
            ghosts[ped] = nil
        end
    end

    return nearest
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    for ped in pairs(ghosts) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
end)
