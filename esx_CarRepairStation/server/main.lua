ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('carfixstation:costRepair')
AddEventHandler('carfixstation:costRepair', function(cost)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	if xPlayer.getMoney() >= cost then		
		xPlayer.removeMoney(cost)
		TriggerClientEvent('carfixstation:fixCar', _source)
		TriggerClientEvent('esx:showNotification', _source, _U('cost_repair', cost))
	else
		TriggerClientEvent('esx:showNotification', _source, _U('not_enough_money'))
	end
end)