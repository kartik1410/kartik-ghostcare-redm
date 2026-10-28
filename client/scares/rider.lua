Scares.rider = {
    canRun = function()
        return Ghost.GetMount() ~= nil
    end,

    run = function()
        local mount = Ghost.GetMount()
        if not mount then return false end

        local ghost = Ghost.Spawn(GetEntityCoords(mount), 0.0, true)
        if not ghost then return false end

        SetPedOntoMount(ghost, mount, 0, true)
        TaskLookAtEntity(ghost, PlayerPedId(), -1, 2048, 3, 0)
        Ghost.Show(ghost, 2500)

        local timeout = GetGameTimer() + 12000
        while GetGameTimer() < timeout and DoesEntityExist(ghost) do
            if Ghost.GetMount() ~= mount then break end

            if Ghost.LookDot(GetEntityCoords(ghost)) > 0.85 then
                Wait(600)
                Effects.Jumpscare(ghost)
                Effects.Spook(mount, false)
                Ghost.Vanish(ghost)
                return true
            end

            Wait(100)
        end

        Ghost.FadeOut(ghost)
        return true
    end,
}
