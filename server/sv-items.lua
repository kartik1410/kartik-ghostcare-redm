if not Bridge.RegisterUsable then
    return print('^3[kartik-ghostscare] No framework found, use /spiritcompass for the compass^0')
end

Bridge.RegisterUsable(Config.CompassItem, function(source)
    TriggerClientEvent('kartik-ghostscare:client:toggleCompass', source)
end)
