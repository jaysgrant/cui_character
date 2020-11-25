Camera = {}

Camera.entity       = nil
Camera.active       = false
Camera.update       = false
Camera.radius       = 1.25

Camera.angleX       = 0.0
Camera.angleY       = 0.0
Camera.mouseX       = 0
Camera.mouseY       = 0

Camera.Activate = function()
    if not DoesCamExist(Camera.entity) then
        Camera.entity = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    end

    local playerPed = PlayerPedId()
    local pedCoords = GetEntityCoords(playerPed)

    local pos = Camera.CalculatePosition()
    SetCamCoord(Camera.entity, pos.x, pos.y, pos.z)
    PointCamAtCoord(Camera.entity, pedCoords.x, pedCoords.y, pedCoords.z + 0.5)

    SetCamActive(Camera.entity, true)
    RenderScriptCams(true, true, 500, true, true)

    Camera.active = true
end

Camera.Deactivate = function()
    SetCamActive(Camera.entity, false)
    RenderScriptCams(false, true, 500, true, true)

    Camera.active = false
end

Camera.CalculateMaxRadius = function()
    local result = Camera.radius

    local playerPed = PlayerPedId()
    local pedCoords = GetEntityCoords(playerPed)

    local behindX = pedCoords.x + ((Cos(Camera.angleX) * Cos(Camera.angleY)) + (Cos(Camera.angleY) * Cos(Camera.angleX))) / 2 * (Camera.radius + 0.5)
    local behindY = pedCoords.x + ((Sin(Camera.angleX) * Cos(Camera.angleY)) + (Cos(Camera.angleY) * Sin(Camera.angleX))) / 2 * (Camera.radius + 0.5)
    local behindZ = ((Sin(Camera.angleY))) * (Camera.radius + 0.5)

    local testRay = StartShapeTestRay(pedCoords.x, pedCoords.y, pedCoords.z + 0.5, behindX, behindY, behindZ, -1, playerPed, 0)
    local _, hit, hitCoords = GetShapeTestResult(testRay)
    local hitDist = Vdist(pedCoords.x, pedCoords.y, pedCoords.z + 0.5, hitCoords)

    if hit and hitDist < Camera.radius + 0.5 then
        result = hitDist
    end

    return result
end

Camera.CalculatePosition = function()
    Camera.angleX = Camera.angleX - Camera.mouseX * 0.1
    Camera.angleY = Camera.angleY + Camera.mouseY * 0.1

    if Camera.angleY > 80.0 then
        Camera.angleY = 80.0
    elseif Camera.angleY < -50.0 then
        Camera.angleY = -50.0
    end

    local radiusMax = Camera.CalculateMaxRadius()
    
    local offsetX = ((Cos(Camera.angleX) * Cos(Camera.angleY)) + (Cos(Camera.angleY) * Cos(Camera.angleX))) / 2 * radiusMax
    local offsetY = ((Sin(Camera.angleX) * Cos(Camera.angleY)) + (Cos(Camera.angleY) * Sin(Camera.angleX))) / 2 * radiusMax
    local offsetZ = ((Sin(Camera.angleY))) * radiusMax

    local pedCoords = GetEntityCoords(PlayerPedId())

    return vector3(pedCoords.x + offsetX, pedCoords.y + offsetY, pedCoords.z + offsetZ)
end

Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(1)

        if Camera.active then
            local playerPed = PlayerPedId()
            local pedCoords = GetEntityCoords(playerPed)

            DisableFirstPersonCamThisFrame()

            if Camera.update then
                local pos = Camera.CalculatePosition()
                SetCamCoord(Camera.entity, pos.x, pos.y, pos.z)
                PointCamAtCoord(Camera.entity, pedCoords.x, pedCoords.y, pedCoords.z + 0.5)
                Camera.update = false
            end
        end
    end
end)