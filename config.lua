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

        givecarFormat = 'Incorrect Format!',

        transferCarNoID = 'Please Provide ID',

        saveCarNowBelong = 'This Vehicle Now Belongs To You...',

        saveCarAlreadyBelong = 'This Vehicle Already Belongs To You...',

        sellCarNotOwned = 'You Don\'t Own This Vehicle...',
    },
}