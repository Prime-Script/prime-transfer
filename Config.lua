Config = {}

Config.FuelSystem = 'lj-fuel' -- Change this to the fuel system you are using (e.g. LegacyFuel, lj-fuel)

Config.UseLanguage = "en"

Config.Language = {
    ["en"] = {
        -- Client QBCore Notify
        giveCar = 'You can\'t store this vehicle in your garage!',

        transferCarInVehicle = 'You must be in a vehicle to transfer!',

        transferCarWrongID = 'This person is not around!',

        transferCarNoOneNear = 'No one is around!',

        -- Server QBCore Notify

        givecarAdmin = 'You Gave A Vehicle To '..tPlayer.PlayerData.charinfo.firstname..' '..tPlayer.PlayerData.charinfo.lastname..' Vehicle: '..veh..' With Plate : '..plate,

        givecarFormat = 'Incorrect Format!',

        transferCarNoID = 'Please Provide ID',

        saveCarNowBelong = 'This Vehicle Now Belongs To You...',

        saveCarAlreadyBelong = 'This Vehicle Already Belongs To You...',

        sellCarSelling = 'You Gave The Registration Paper To '..tPlayer.PlayerData.charinfo.firstname.." "..tPlayer.PlayerData.charinfo.lastname,

        sellCarBuying = 'You Have Been Given The Registration Paper From '..xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname,

        sellCarNotOwned = 'You Don\'t Own This Vehicle...',


        Config.Language[Config.UseLanguage].givecarFormat
    },
}