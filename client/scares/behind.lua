Scares.behind = {
    canRun = function()
        return not Ghost.GetMount()
    end,

    run = function()
        local spot = Ghost.PointBehind(math.random(40, 60) / 10)
        if not spot then return false end

        local ghost = Ghost.Spawn(spot)
        if not ghost then return false end

        Ghost.Stare(ghost)
        Ghost.Show(ghost, 800)
        Effects.Sound('sting')
        Effects.PlayFile('whisper', spot)

        local timeout = GetGameTimer() + 20000
        while GetGameTimer() < timeout and DoesEntityExist(ghost) do
            local coords = GetEntityCoords(ghost)
            if #(coords - GetEntityCoords(PlayerPedId())) > 25.0 then break end

            Ghost.Face(ghost)

            if Ghost.LookDot(coords) > 0.9 then
                Effects.Chill()
                Wait(1500)
                if #(coords - GetEntityCoords(PlayerPedId())) < 4.0 then Effects.Jumpscare(ghost) end
                Ghost.Vanish(ghost)
                return true
            end

            Wait(100)
        end

        Ghost.FadeOut(ghost)
        return true
    end,
}
