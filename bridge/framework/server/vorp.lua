if Bridge.DetectFramework() ~= 'vorp' then return end

local Inv = exports.vorp_inventory

function Bridge.RegisterUsable(item, fn)
    CreateThread(function()
        while GetResourceState('vorp_inventory') ~= 'started' do Wait(500) end
        Inv:registerUsableItem(item, function(data)
            pcall(function() Inv:closeInventory(data.source) end)
            fn(data.source)
        end, GetCurrentResourceName())
    end)
end
