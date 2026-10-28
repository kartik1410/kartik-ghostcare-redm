Scares.spooked = {
    canRun = function()
        return Ghost.GetMount() ~= nil
    end,

    run = function()
        local mount = Ghost.GetMount()
        if not mount then return false end

        Effects.Chill()
        Effects.PlayFile('whisper', nil, 0.6)
        Effects.Spook(mount, false)
        return true
    end,
}
