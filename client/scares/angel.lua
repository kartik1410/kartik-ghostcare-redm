local function blink(ms)
    DoScreenFadeOut(ms)
    Wait(ms + 30)
end

Scares.angel = {
    canRun = function()
        return not Ghost.GetMount()
    end,

    run = function()
        local spot = Ghost.PointFromCam(math.random(-15, 15), 25.0)
        if not spot then return false end

        local ghost = Ghost.Spawn(spot)
        if not ghost then return false end

        Ghost.Stare(ghost)
        Ghost.Show(ghost, 1500)

        local timeout = GetGameTimer() + 60000
        local nextBlink = GetGameTimer() + math.random(4000, 7000)

        while GetGameTimer() < timeout and DoesEntityExist(ghost) do
            local dist = #(GetEntityCoords(ghost) - GetEntityCoords(PlayerPedId()))
            if dist > 70.0 or Ghost.GetMount() then break end

            if GetGameTimer() >= nextBlink then
                blink(120)

                if dist < 4.0 then
                    Ghost.MoveToward(ghost, 1.0)
                    DoScreenFadeIn(60)
                    Effects.Jumpscare(ghost)
                    Wait(600)
                    Ghost.Vanish(ghost)
                    return true
                end

                Ghost.MoveToward(ghost, dist * 0.6)
                Effects.PlayFile('breath', GetEntityCoords(ghost))
                DoScreenFadeIn(120)
                nextBlink = GetGameTimer() + math.random(3000, 6000)
            end

            Wait(100)
        end

        if not IsScreenFadedIn() then DoScreenFadeIn(120) end
        Ghost.FadeOut(ghost)
        return true
    end,
}
