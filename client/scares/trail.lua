Scares.trail = {
    canRun = function()
        local mount = Ghost.GetMount()
        return mount ~= nil and GetEntitySpeed(mount) > 4.0
    end,

    run = function()
        local mount = Ghost.GetMount()
        if not mount then return false end

        local target = GetEntityCoords(mount) + GetEntityForwardVector(mount) * 45.0
        local z = Ghost.GroundZ(target.x, target.y, target.z)
        if not z then return false end

        local ghost = Ghost.Spawn(vector3(target.x, target.y, z))
        if not ghost then return false end

        Ghost.Stare(ghost)
        Ghost.Show(ghost, 600)

        local timeout = GetGameTimer() + 15000
        while GetGameTimer() < timeout and DoesEntityExist(ghost) and DoesEntityExist(mount) do
            local coords = GetEntityCoords(ghost)
            local dist = #(coords - GetEntityCoords(mount))
            local ahead = Ghost.DistAhead(mount, coords)

            if dist < 7.0 and ahead > 0.0 then
                Effects.Jumpscare(ghost)
                Effects.Spook(mount, true)
                Ghost.Vanish(ghost)
                return true
            end

            if dist > 120.0 or ahead < -5.0 then break end

            Wait(50)
        end

        Ghost.FadeOut(ghost)
        return true
    end,
}
