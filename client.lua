local QBCore = exports['qb-core']:GetCoreObject() 

------ / Functions

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

------ / Register

RegisterNetEvent('qb-transfer:giveCar', function(model, plate)
    QBCore.Functions.SpawnVehicle(model, function(veh)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        exports[Config.FuelSystem]:SetFuel(veh, 100)
        SetVehicleNumberPlateText(veh, plate)
        SetEntityAsMissionEntity(veh, true, true)
        local props = QBCore.Functions.GetVehicleProperties(veh)
        local hash = props.model
        local vehname = GetDisplayNameFromVehicleModel(hash):lower()
        TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
        if QBCore.Shared.Vehicles[vehname] ~= nil and next(QBCore.Shared.Vehicles[vehname]) ~= nil then
            TriggerServerEvent('qb-transfer:saveCar', props, QBCore.Shared.Vehicles[vehname], veh, GetVehicleNumberPlateText(veh))
        else
            QBCore.Functions.Notify(Config.Language[Config.UseLanguage].giveCar, 'error')
        end     
    end)
end)

RegisterNetEvent('qb-transfer:transferCar', function(id)
    local me = PlayerPedId()
    if not IsPedSittingInAnyVehicle(me) then
        QBCore.Functions.Notify(Config.Language[Config.UseLanguage].transferCarInVehicle, 'error')
        return
    end
    local vehicle = GetVehiclePedIsIn(me, false)	
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        if playerId == tonumber(id) then
            QBCore.Functions.TriggerCallback('qb-transfer:Finance', function(Finance)
                if not Finance then
                    TriggerServerEvent('qb-transfer:sellCar', GetPlayerServerId(PlayerId()), playerId, GetVehicleNumberPlateText(vehicle))
                else
                    QBCore.Functions.Notify(Config.Language[Config.UseLanguage].OwnMoney, 'error')
                end
            end, plate)
        else
            QBCore.Functions.Notify(Config.Language[Config.UseLanguage].transferCarWrongID, 'error')
        end
    else
        QBCore.Functions.Notify(Config.Language[Config.UseLanguage].transferCarNoOneNear, 'error')
    end
end)
