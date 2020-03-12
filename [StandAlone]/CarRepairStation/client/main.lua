local fixing, turn = false, false
local zcoords, mcolor = 0.0, 0
local position = 0

Citizen.CreateThread(function()	
    while true do
		Citizen.Wait(5)	
		local playerPed = GetPlayerPed(-1)
		local pos = GetEntityCoords(playerPed, true)		
		for k,v in pairs(Config.Stations) do
			if not fixing then
				if(Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z) < 100) then
					if IsPedInAnyVehicle(playerPed, false) then
						DrawMarker(36, v.x, v.y, v.z+1.1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.0, 5.0, 1.0, 255, 0, 0, 100, true, true, 2, true, false, false, false)
						DrawMarker(0, v.x, v.y, v.z-0.4, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 5.0, 5.0, 1.0, 255, 255, 0, 100, false, false, 2, false, false, false, false)
						if(Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z) < 2.5) then							
							position = k
							hintToDisplay('Press ~INPUT_PICKUP~ to repair vehicle for free')
							if IsControlJustPressed(0, 38) then	
								TriggerEvent('carfixstation:fixCar')						
								SetPedCoordsKeepVehicle(playerPed, v.x, v.y, v.z)
							end								
						end
					end
				end
			else		
				if position == k then
					DrawMarker(27, v.x, v.y, v.z + zcoords+0.6, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 5.0, 5.0, 1.0, 255, 0+mcolor, 0, 255, false, false, 2, true, false, false, false)
					DrawMarker(23, v.x, v.y, v.z + zcoords, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 5.0, 5.0, 1.0, 255, 0+mcolor, 0, 255, false, false, 2, true, false, false, false)
					DrawMarker(27, v.x, v.y, v.z + zcoords-0.6, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 5.0, 5.0, 1.0, 255, 0+mcolor, 0, 255, false, false, 2, true, false, false, false)
				else
					DrawMarker(36, v.x, v.y, v.z+1.1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.0, 5.0, 1.0, 255, 0, 0, 100, true, true, 2, true, false, false, false)
					DrawMarker(0, v.x, v.y, v.z-0.4, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 5.0, 5.0, 1.0, 255, 255, 0, 100, false, false, 2, false, false, false, false)							
				end
			end
		end
    end
end)

RegisterNetEvent('carfixstation:markAnimation')
AddEventHandler('carfixstation:markAnimation', function()
    while true do
		Citizen.Wait(25)	
		if fixing then
			if zcoords < 0.5 and not turn then
				zcoords = zcoords + 0.03
				mcolor = mcolor + 2
			else
				turn = true
				zcoords = zcoords - 0.051
				mcolor = mcolor + 2
				if zcoords <= -0.4 then
					turn = false
				end
			end
		else
			break
		end
	end
end)

RegisterNetEvent('carfixstation:fixCar')
AddEventHandler('carfixstation:fixCar', function()
	local playerPed = GetPlayerPed(-1)
	local vehicle = GetVehiclePedIsIn(playerPed, false)
	fixing = true
	TriggerEvent('carfixstation:markAnimation')	
	FreezeEntityPosition(vehicle, true)
	sendNotification('Repair in progress, please wait...', 'warning', Config.RepairTime-700)
	if Config.EnableSoundEffect == true then
		TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5.0, 'car_repair', 0.7)
	end
	Wait(Config.RepairTime)
	fixing = false
	SetVehicleFixed(vehicle)
	SetVehicleDeformationFixed(vehicle)
	FreezeEntityPosition(vehicle, false)
	zcoords, mcolor, turn = 0.0, 0, false
end)

if Config.Blips then
	Citizen.CreateThread(function()
		for i=1, #Config.Stations, 1 do
			local blip = AddBlipForCoord(Config.Stations[i].x, Config.Stations[i].y, Config.Stations[i].z)

			SetBlipSprite (blip, 72)
			SetBlipDisplay(blip, 4)
			SetBlipScale  (blip, 0.8)
			SetBlipColour (blip, 47)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentSubstringPlayerName('Car Repair Station')
			EndTextCommandSetBlipName(blip)
		end
	end)
end

function hintToDisplay(text)
	SetTextComponentFormat("STRING")
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

--notification
function sendNotification(message, messageType, messageTimeout)
	TriggerEvent("pNotify:SendNotification", {
		text = message,
		type = messageType,
		queue = "katalog",
		timeout = messageTimeout,
		layout = "bottomCenter"
	})
end