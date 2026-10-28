Scares.lightsout = {
    canRun = function()
        return true
    end,

    run = function()
        Effects.Sound('sting')
        Effects.LightsOut()
        Effects.PlayFile('laugh', nil, 0.5)
        Wait(math.random(3000, 5000))
        Effects.LightsBack()
        return true
    end,
}
