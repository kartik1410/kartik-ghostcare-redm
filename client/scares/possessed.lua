local function findPeds()
    local player = PlayerPedId()
    local pos = GetEntityCoords(player)
    local found = {}

    for _, ped in ipairs(GetGamePool('CPed')) do
        if ped ~= player and not IsPedAPlayer(ped) and IsPedHuman(ped) and not IsEntityDead(ped)
            and not IsPedOnMount(ped) and not IsPedInAnyVehicle(ped, false) and not IsEntityAMissionEntity(ped) then
            local dist = #(GetEntityCoords(ped) - pos)
            if dist > 6.0 and dist < 35.0 then
                found[#found + 1] = { ped = ped, dist = dist, onScreen = IsEntityOnScreen(ped) }
            end
        end
    end

    table.sort(found, function(a, b) return a.dist < b.dist end)
    return found
end

local function pickLeader(found)
    for _, entry in ipairs(found) do
        if entry.onScreen then return entry.ped end
    end
end

local function takeControl(ped)
    if not NetworkGetEntityIsNetworked(ped) then return true end

    local timeout = GetGameTimer() + 1000
    while not NetworkHasControlOfEntity(ped) do
        if GetGameTimer() > timeout then return false end
        NetworkRequestControlOfEntity(ped)
        Wait(0)
    end

    return true
end

local function possess(ped)
    if not takeControl(ped) then return false end

    SetEntityAsMissionEntity(ped, true, true)
    ClearPedTasksImmediately(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    TaskStandStill(ped, -1)
    Ghost.Face(ped)
    FreezeEntityPosition(ped, true)
    TaskLookAtEntity(ped, PlayerPedId(), -1, 2048, 3, 0)
    return true
end

local function release(ped)
    if not DoesEntityExist(ped) then return end

    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, false)
    TaskWanderStandard(ped, 10.0, 10)
    SetPedAsNoLongerNeeded(ped)
end

Scares.possessed = {
    canRun = function()
        return not Ghost.GetMount() and pickLeader(findPeds()) ~= nil
    end,

    run = function()
        local found = findPeds()
        local leader = pickLeader(found)
        if not leader or not possess(leader) then return false end

        local watchers = { leader }
        for _, entry in ipairs(found) do
            if #watchers >= 4 then break end
            if entry.ped ~= leader and possess(entry.ped) then
                watchers[#watchers + 1] = entry.ped
            end
        end

        local timeout = GetGameTimer() + 90000
        local lastMove = GetGameTimer()
        local warned = false

        while GetGameTimer() < timeout and DoesEntityExist(leader) and not IsEntityDead(leader) do
            local now = GetGameTimer()
            local leaderPos = GetEntityCoords(leader)
            local dist = #(leaderPos - GetEntityCoords(PlayerPedId()))

            if dist > 60.0 or Ghost.GetMount() then break end

            for _, ped in ipairs(watchers) do
                if DoesEntityExist(ped) then Ghost.Face(ped) end
            end

            if dist < 2.5 then
                if not warned then
                    warned = true
                    Effects.Chill()
                    Effects.PlayFile('breath')
                end

                if IsEntityOnScreen(leader) and Ghost.LookDot(leaderPos) > 0.8 then
                    Effects.Jumpscare(leader)
                    Wait(1500)
                    break
                end
            elseif not IsEntityOnScreen(leader) and now - lastMove > 1500 then
                Ghost.MoveToward(leader, math.max(1.2, dist - 5.0))
                lastMove = now
            end

            Wait(100)
        end

        for _, ped in ipairs(watchers) do release(ped) end
        return true
    end,
}
