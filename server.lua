local QBCore = exports['qb-core']:GetCoreObject()
local NumberCharset = {}
local Charset = {}

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end
for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

------ / Functions

function GeneratePlate()
	local plate = tostring(GetRandomNumber(1)) .. GetRandomLetter(2) .. tostring(GetRandomNumber(3)) .. GetRandomLetter(2)
	local result = MySQL.Sync.fetchScalar('SELECT plate FROM player_vehicles WHERE plate=@plate', {['@plate'] = plate})
	if result then
		plate = tostring(GetRandomNumber(1)) .. GetRandomLetter(2) .. tostring(GetRandomNumber(3)) .. GetRandomLetter(2)
	end
	return plate:upper()
end
  
function GetRandomNumber(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
	  return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
	else
	  return ''
	end
end

function GetRandomLetter(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
	  return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
	else
	  return ''
	end
end

------ / Commands

QBCore.Commands.Add("givecar", "Give Vehicle to Players (Admin Only)", {{name="id", help="Player ID"}, {name="model", help="Vehicle Model, for example: t20"}, {name="plate", help="Custom Number Plate (Leave to assign random) , for example: ABC123"}}, false, function(source, args)
    local ply = QBCore.Functions.GetPlayer(source)
    local veh = args[2]
    local plate = args[3]
    local tPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if plate == nil or plate == "" then plate = GeneratePlate() end
    if veh ~= nil and args[1] ~= nil then
        TriggerClientEvent('qb-transfer:giveCar', args[1], veh, plate)
        TriggerClientEvent("QBCore:Notify", source, 'You Gave A Vehicle To '..tPlayer.PlayerData.charinfo.firstname..' '..tPlayer.PlayerData.charinfo.lastname..' Vehicle: '..veh..' With Plate : '..plate, 'success', 8000)
    else 
        TriggerClientEvent('QBCore:Notify', source, Config.Language[Config.UseLanguage].givecarFormat, 'error')
    end
end, "god")

QBCore.Commands.Add("transfercar", "Transfer Vehicle to Other Player (Must Be in Vehicle)", {{name="id", help="Player ID"}}, false, function(source, args)
    local id = args[1]
    local plate = args[2]
    if id ~= nil then
        TriggerClientEvent('qb-transfer:transferCar', source, id)
    else 
        TriggerClientEvent('QBCore:Notify', source, Config.Language[Config.UseLanguage].transferCarNoID, 'error')
    end
end)

------ / Register

RegisterServerEvent('qb-transfer:saveCar')
AddEventHandler('qb-transfer:saveCar', function(mods, vehicle, hash, plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local result = MySQL.Sync.fetchAll('SELECT plate FROM player_vehicles WHERE plate=@plate', {['@plate'] = plate})
    if result[1] == nil then
        MySQL.Async.execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @state)', {
            ['@license'] = Player.PlayerData.license,
            ['@citizenid'] = Player.PlayerData.citizenid,
            ['@vehicle'] = vehicle.model,
            ['@hash'] = vehicle.hash,
            ['@mods'] = json.encode(mods),
            ['@plate'] = plate,
            ['@state'] = 0
        })
        TriggerClientEvent('QBCore:Notify', src, Config.Language[Config.UseLanguage].saveCarNowBelong, 'success', 5000)
    else
        TriggerClientEvent('QBCore:Notify', src, Config.Language[Config.UseLanguage].saveCarAlreadyBelong, 'error', 5000)
    end
end)

RegisterServerEvent('qb-transfer:sellCar')
AddEventHandler('qb-transfer:sellCar', function(player, target, plate)
    local src = source
	local xPlayer = QBCore.Functions.GetPlayer(player)
	local tPlayer = QBCore.Functions.GetPlayer(target)
    
    MySQL.Sync.fetchAll("SELECT * FROM `player_vehicles` WHERE `plate` = '"..plate.."' AND `citizenid` = '"..xPlayer.PlayerData.citizenid.."'", function(result)
        if result[1] ~= nil and next(result[1]) ~= nil then
            if plate == result[1].plate then
                MySQL.Async.execute('DELETE FROM player_vehicles WHERE plate=@plate AND vehicle=@vehicle', {['@plate'] = plate, ['@vehicle'] = result[1].vehicle})
                MySQL.Async.execute('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @state)', {
                    ['@steam'] = tPlayer.PlayerData.license,
                    ['@citizenid'] = tPlayer.PlayerData.citizenid,
                    ['@vehicle'] = result[1].vehicle,
                    ['@hash'] = GetHashKey(result[1].vehicle),
                    ['@mods'] = json.encode(result[1].mods),
                    ['@plate'] = result[1].plate,
                    ['@state'] = 0
                })
                TriggerClientEvent('QBCore:Notify', player, 'You Gave The Registration Paper To '..tPlayer.PlayerData.charinfo.firstname.." "..tPlayer.PlayerData.charinfo.lastname, 'success', 8000)
                TriggerClientEvent('QBCore:Notify', target, 'You Have Been Given The Registration Paper From '..xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname, 'success', 8000) 
            else
                TriggerClientEvent('QBCore:Notify', src, Config.Language[Config.UseLanguage].sellCarNotOwned, 'error', 5000)
            end
        else
            TriggerClientEvent('QBCore:Notify', src, Config.Language[Config.UseLanguage].sellCarNotOwned, 'error', 5000)
        end
    end)
end)

------ / Call Backs

QBCore.Functions.CreateCallback('qb-transfer:Finance', function(source, cb, plate)
    local result = MySQL.Sync.fetchAll('SELECT * FROM player_vehicles WHERE plate = ?', {plate})
    for k,v in pairs(result) do
        if v.balance > 1 then
            cb(true)
        else
            cb(false)
        end
    end
end)