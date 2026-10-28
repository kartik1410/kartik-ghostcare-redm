Scares.footsteps = {
    canRun = function()
        return not Ghost.GetMount()
    end,

    run = function()
        local spot = Ghost.PointBehind(12.0)
        if not spot then return false end

        local ghost = Ghost.Spawn(spot, 0.0, true)
        if not ghost then return false end

        local ped = PlayerPedId()
        Ghost.Face(ghost)
        TaskGoToEntity(ghost, ped, -1, 2.5, 1.0, 0.0, 0)

        local timeout = GetGameTimer() + 15000
        while GetGameTimer() < timeout and DoesEntityExist(ghost) do
            if #(GetEntityCoords(ghost) - GetEntityCoords(ped)) < 3.0 then
                Effects.PlayFile('breath')
                ShakeGameplayCam('HAND_SHAKE', 0.4)
                SetTimeout(1500, function() StopGameplayCamShaking(false) end)
                break
            end
            Wait(100)
        end

        Ghost.Remove(ghost)
        return true
    end,
}
