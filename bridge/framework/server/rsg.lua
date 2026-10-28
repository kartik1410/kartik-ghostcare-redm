if Bridge.DetectFramework() ~= 'rsg' then return end

local RSGCore = exports['rsg-core']:GetCoreObject()

function Bridge.RegisterUsable(item, fn)
    RSGCore.Functions.CreateUseableItem(item, function(source)
        fn(source)
    end)
end
