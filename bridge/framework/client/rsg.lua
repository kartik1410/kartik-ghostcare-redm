if Bridge.DetectFramework() ~= 'rsg' then return end

local RSGCore = exports['rsg-core']:GetCoreObject()

function Bridge.Notify(message, kind)
    RSGCore.Functions.Notify({ description = message, type = kind or 'inform' })
end
