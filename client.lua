local QBCore = exports['qb-core']:GetCoreObject() 

-- Functions

function GetClosestPlayer()
    local closestPlayers = QBCore.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(GetPlayerPed(-1))

    for i=1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, coords.x, coords.y, coords.z, true)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
	end

	return closestPlayer, closestDistance
end

-- Register

RegisterNetEvent('nc-veh:client:givecar')
AddEventHandler('nc-veh:client:givecar', function(model, plate)
    QBCore.Functions.SpawnVehicle(model, function(veh)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        exports['lj-fuel']:SetFuel(veh, 100)
        SetVehicleNumberPlateText(veh, plate)
        SetEntityAsMissionEntity(veh, true, true)
        local props = QBCore.Functions.GetVehicleProperties(veh)
        local hash = props.model
        local vehname = GetDisplayNameFromVehicleModel(hash):lower()
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
        if QBCore.Shared.Vehicles[vehname] ~= nil and next(QBCore.Shared.Vehicles[vehname]) ~= nil then
            TriggerServerEvent('nc-veh:server:SaveCar', props, QBCore.Shared.Vehicles[vehname], veh, GetVehicleNumberPlateText(veh))
        else
            QBCore.Functions.Notify('You cant store this vehicle in your garage..', 'error')
        end     
    end)
end)

RegisterNetEvent('nc-veh:client:transferrc')
AddEventHandler('nc-veh:client:transferrc', function(id)
    local me = PlayerPedId()
    if not IsPedSittingInAnyVehicle(me) then
        QBCore.Functions.Notify("You must be in a Vehicle to Transfer", "error")
        return
    end
    local vehicle = GetVehiclePedIsIn(me, false)	
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        if playerId == tonumber(id) then
            TriggerServerEvent("nc-veh:GiveRC", GetPlayerServerId(PlayerId()), playerId, GetVehicleNumberPlateText(vehicle))
        else
            QBCore.Functions.Notify("Person not Near!", "error")
        end
    else
        QBCore.Functions.Notify("No one around!", "error")
    end
end)
