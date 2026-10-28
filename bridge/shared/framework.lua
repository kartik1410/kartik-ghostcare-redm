Bridge = Bridge or {}

Bridge.FrameworkOrder = {
    { name = 'rsg', resource = 'rsg-core' },
    { name = 'vorp', resource = 'vorp_core' },
}

function Bridge.DetectFramework()
    if Config.Framework ~= 'auto' then return Config.Framework end
    for _, core in ipairs(Bridge.FrameworkOrder) do
        local state = GetResourceState(core.resource)
        if state == 'started' or state == 'starting' then return core.name end
    end
end

function Bridge.Notify(message)
    print(('[kartik-ghostscare] %s'):format(message))
end
