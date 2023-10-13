QBCore = exports['qb-core']:GetCoreObject()
local info = {}

RegisterNetEvent('OBRP-Firearm:server:TheoryTestResult', function (success)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    info.firstname = Player.PlayerData.charinfo.firstname
    info.lastname = Player.PlayerData.charinfo.lastname
    info.birthdate = Player.PlayerData.charinfo.birthdate
    info.type = 'Firearm License'

    if not success then
        Player.Functions.RemoveMoney(Config.PaymentType, Config.Amount['theoritical']/2)
        TriggerClientEvent('QBCore:Notify', src, 'You failed the Test. Please Try again.', 'error', 3000)
    else
        if success then
            Player.PlayerData.metadata['licences']['weapon'] = true
            Player.Functions.SetMetaData('licences', Player.PlayerData.metadata['licences'])
            if Config.GiveItem then
                if Player.Functions.AddItem('weaponlicense', 1, nil, info) then
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['weaponlicense'], 'add')
                    TriggerClientEvent('QBCore:Notify', src, 'Congratulations! You passed the Theoritical Test.', 'success', 3000)
                end
            else
                TriggerClientEvent('QBCore:Notify', src, 'Congratulations! You passed!', 'success', 4500)
            end
        else
        end
        Player.Functions.RemoveMoney(Config.PaymentType, Config.Amount['theoritical'])
        TriggerClientEvent('QBCore:Notify', src, 'You paid $'..Config.Amount['theoritical'], 'success', 3000)
    end
end)




QBCore.Commands.Add(Config.CommandName, 'Reset A Players License', {{name = "id", help = 'Player ID'}, {name = "license", help = 'License Type'}}, false, function(source, args)
	local src = source
	if args[1] and args[2] then
        local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
        Player.PlayerData.metadata['licences'][args[2]] = false
        Player.Functions.SetMetaData('licences', Player.PlayerData.metadata['licences'])
    else
        TriggerClientEvent('QBCore:Notify', src, 'Must Input each Arguement.')
    end
end, "admin")