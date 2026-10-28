local function isSeason()
    if #Config.Months == 0 then return true end

    local month = tonumber(os.date('%m'))
    for _, m in ipairs(Config.Months) do
        if m == month then return true end
    end

    return false
end

CreateThread(function()
    while true do
        GlobalState.ghostscareActive = isSeason()
        Wait(30 * 60000)
    end
end)

RegisterCommand('haunt', function(source, args)
    local target = tonumber(args[1]) or source
    if target == 0 or not GetPlayerName(target) then
        return print('usage: haunt <id> [glimpse|footsteps|lightsout|spooked|behind|trail|rider|screamer|follow|angel|possessed|stalker]')
    end

    TriggerClientEvent('kartik-ghostscare:client:haunt', target, args[2])
end, true)

RegisterCommand('spiritcompass', function(source)
    if source == 0 then return end
    TriggerClientEvent('kartik-ghostscare:client:toggleCompass', source)
end, true)

RegisterCommand('hauntvoice', function(source, args)
    if source == 0 then return end
    TriggerClientEvent('kartik-ghostscare:client:testVoice', source, args[1], args[2])
end, true)
