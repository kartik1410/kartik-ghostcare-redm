Effects = {}

local SMOKE_DICT = 'scr_odd_fellows'
local SMOKE_FX = 'scr_river5_magician_smoke'

local function frontendSound(name, ref)
    Citizen.InvokeNative(0x0F2A2175734926D8, name, ref)
    Citizen.InvokeNative(0x67C540AA08E4A6F5, name, ref, true, 0)
end

function Effects.Sound(kind)
    if kind == 'hit' then
        frontendSound('DEATH_SCREEN_ENTER', 'DEATH_FAIL_RESPAWN_SOUNDS')
    elseif kind == 'sting' then
        frontendSound('sudden_death', 'RDR_Shard_Central_Message_Sounds')
    elseif kind == 'tick' then
        frontendSound('round_start_countdown_tick', 'RDRO_Poker_Sounds')
    end
end

function Effects.PlayFile(name, coords, volume)
    local vol = (volume or 1.0) * Config.SoundVolume

    if coords then
        local dist = #(coords - GetEntityCoords(PlayerPedId()))
        if dist > Config.SoundRange then return end
        vol = vol * (1.0 - dist / Config.SoundRange)
    end

    SendNUIMessage({ action = 'play', name = name, volume = vol })
end

local function varString(text)
    return Citizen.InvokeNative(0xFA925AC00EB830B9, 10, 'LITERAL_STRING', text, Citizen.ResultAsLong())
end

local function speak(ped, line, voice, variation)
    local params = string.pack('<i8i8i8i8i8i8i8i8',
        varString(line), varString(voice), variation, GetHashKey('SPEECH_PARAMS_BEAT_SHOUTED_CLEAR'), 0, 1, 1, 1)
    return Citizen.InvokeNative(0x8E04FEDD28D42462, ped, params, Citizen.ResultAsInteger()) == 1
end

local function soundAt(coords, name, soundset)
    local timeout = GetGameTimer() + 1000
    while not Citizen.InvokeNative(0xD9130842D7226045, soundset, false) do
        if GetGameTimer() > timeout then return false end
        Wait(0)
    end

    Citizen.InvokeNative(0xCCE219C922737BFA, name, coords.x, coords.y, coords.z, soundset, false, 0, true, 0)
    return true
end

function Effects.PlayScream(ped, scream)
    if scream.sound then
        return soundAt(GetEntityCoords(ped), scream.sound, scream.soundset)
    end
    return speak(ped, scream.speech, scream.voice, math.random(scream.variations or 1))
end

function Effects.Voice(ped, painId)
    if not ped or not DoesEntityExist(ped) then return end

    DisablePedPainAudio(ped, false)
    StopPedSpeaking(ped, false)

    if painId then return PlayPain(ped, painId, 0.0, false, false) end

    for _, scream in ipairs(Config.Screams) do
        if Effects.PlayScream(ped, scream) then return end
    end

    PlayPain(ped, Config.ScreamPain, 0.0, false, false)
end

function Effects.Jumpscare(ped)
    Effects.PlayFile('scream')
    Effects.Voice(ped)
    Effects.Sound('hit')
    ShakeGameplayCam('LARGE_EXPLOSION_SHAKE', 0.25)
    AnimpostfxPlay('CameraTransitionFlash')

    SetTimeout(900, function()
        AnimpostfxStop('CameraTransitionFlash')
    end)
end

function Effects.Chill()
    Effects.Sound('sting')
    ShakeGameplayCam('HAND_SHAKE', 0.6)

    SetTimeout(2500, function()
        StopGameplayCamShaking(false)
    end)
end

function Effects.Smoke(coords)
    local dict = GetHashKey(SMOKE_DICT)
    RequestNamedPtfxAsset(dict)

    local timeout = GetGameTimer() + 2000
    while not HasNamedPtfxAssetLoaded(dict) do
        if GetGameTimer() > timeout then return end
        Wait(0)
    end

    UseParticleFxAsset(SMOKE_DICT)
    StartParticleFxNonLoopedAtCoord(SMOKE_FX, coords.x, coords.y, coords.z - 0.5, 0.0, 0.0, 0.0, 1.0, false, false, false)
end

function Effects.LightsOut()
    SetArtificialLightsState(true)
end

function Effects.LightsBack()
    SetArtificialLightsState(GlobalState.blackout == true or GlobalState.blackOut == true)
end

function Effects.Spook(mount, throwRider)
    if not mount or not DoesEntityExist(mount) then return end
    Citizen.InvokeNative(0xBAE08F00021BFFB2, mount, throwRider == true)
end

function Effects.Hunted(on)
    if on then
        AnimpostfxPlay('mp_predatorproximity')
    else
        AnimpostfxStop('mp_predatorproximity')
    end
end

local HEAD_BONE = 21030

local function faceCoords(ped)
    local head = GetPedBoneCoords(ped, HEAD_BONE, 0.0, 0.0, 0.0)
    if #(head - GetEntityCoords(ped)) > 2.0 then
        head = GetEntityCoords(ped) + vector3(0.0, 0.0, 0.65)
    end
    return head + vector3(0.0, 0.0, 0.06)
end

local function makeCam(pos, target, fov)
    local cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, fov, false, 0)
    PointCamAtCoord(cam, target.x, target.y, target.z)
    return cam
end

local function closeUp(ped, cams)
    local camPos = GetGameplayCamCoord()
    local pedPos = GetEntityCoords(ped)
    SetEntityHeading(ped, GetHeadingFromVector_2d(camPos.x - pedPos.x, camPos.y - pedPos.y))
    Wait(0)

    local face = faceCoords(ped)
    local dir = vector3(camPos.x - face.x, camPos.y - face.y, 0.0)
    local len = #dir
    dir = len > 0.01 and dir / len or GetEntityForwardVector(ped)

    local far = makeCam(face + dir * 1.3, face, 45.0)
    local near = makeCam(face + dir * 0.55, face, 40.0)
    cams[1], cams[2] = far, near

    SetCamActive(far, true)
    RenderScriptCams(true, false, 0, true, true, 0)
    SetCamActiveWithInterp(near, far, 120, 1, 1)
    ShakeCam(near, 'HAND_SHAKE', 0.5)

    Effects.PlayFile('scream')
    Effects.Voice(ped)
    Effects.Sound('hit')
    AnimpostfxPlay('CameraTransitionFlash')

    local light = face + dir * 0.4
    local untilTime = GetGameTimer() + 1300
    while GetGameTimer() < untilTime do
        HideHudAndRadarThisFrame()
        DrawLightWithRange(light.x, light.y, light.z, 190, 205, 255, 2.5, 8.0)
        Wait(0)
    end
end

function Effects.FaceCloseUp(ped)
    Wait(50)

    local cams = {}
    local ok = pcall(closeUp, ped, cams)

    RenderScriptCams(false, false, 0, true, true, 0)
    for _, cam in pairs(cams) do DestroyCam(cam, false) end
    AnimpostfxStop('CameraTransitionFlash')

    return ok
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    AnimpostfxStop('mp_predatorproximity')
    AnimpostfxStop('CameraTransitionFlash')
    Effects.LightsBack()
end)
