if Bridge.DetectFramework() ~= 'vorp' then return end

function Bridge.Notify(message)
    TriggerEvent('vorp:TipRight', message, 4000)
end
