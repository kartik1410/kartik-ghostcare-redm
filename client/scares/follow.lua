Scares.follow = {
    canRun = function()
        return not Ghost.GetMount()
    end,

    run = function()
        local spot = Ghost.PointBehind(25.0)
        if not spot then return false end

        local ghost = Ghost.Spawn(spot)
        if not ghost then return false end

        Ghost.Stare(ghost)
        Ghost.Show(ghost, 2000)

        local timeout = GetGameTimer() + 90000
        local lastMove = GetGameTimer()
        local closeSince

        while GetGameTimer() < timeout and DoesEntityExist(ghost) do
            local now = GetGameTimer()
            local ghostPos = GetEntityCoords(ghost)
            local dist = #(ghostPos - GetEntityCoords(PlayerPedId()))

            if dist > 80.0 or Ghost.GetMount() then break end

            if dist < 2.5 then
                closeSince = closeSince or now
                if Ghost.LookDot(ghostPos) > 0.5 or now - closeSince > 8000 then
                    Effects.Jumpscare(ghost)
                    Ghost.Vanish(ghost)
                    return true
                end
            elseif Ghost.LookDot(ghostPos) < 0.3 and now - lastMove > 2500 then
                Ghost.MoveToward(ghost, math.max(1.5, dist - 5.0))
                if dist < 10.0 then Effects.PlayFile('breath', GetEntityCoords(ghost)) end
                lastMove = now
            end

            Wait(200)
        end

        Ghost.FadeOut(ghost)
        return true
    end,
}
