Scares.screamer = {
    canRun = function()
        return true
    end,

    run = function()
        Effects.LightsOut()
        Wait(math.random(1200, 2200))

        local ok = false
        local spot = Ghost.PointFromCam(0, 1.6)
        local ghost = spot and Ghost.Spawn(spot)

        if ghost then
            Ghost.Face(ghost)
            ResetEntityAlpha(ghost)
            ok = Effects.FaceCloseUp(ghost)
            Ghost.Remove(ghost)
        end

        Effects.LightsBack()
        return ghost ~= nil and ok
    end,
}
