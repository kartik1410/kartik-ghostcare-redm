Scares.glimpse = {
    canRun = function()
        return true
    end,

    run = function()
        local side = math.random(2) == 1 and 1 or -1
        local spot = Ghost.PointFromCam(side * math.random(35, 45), math.random(25, 40))
        if not spot then return false end

        local ghost = Ghost.Spawn(spot)
        if not ghost then return false end

        Ghost.Stare(ghost)
        Ghost.Fade(ghost, 0, math.floor(Config.GhostAlpha * 0.7), 400)
        Effects.PlayFile('whisper', spot)

        local timeout = GetGameTimer() + 5000
        while GetGameTimer() < timeout and DoesEntityExist(ghost) do
            if Ghost.LookDot(GetEntityCoords(ghost)) > 0.97 then break end
            Wait(50)
        end

        Ghost.Fade(ghost, GetEntityAlpha(ghost), 0, 200)
        Ghost.Remove(ghost)
        return true
    end,
}
