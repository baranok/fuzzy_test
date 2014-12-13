require 'init'



local world_days = 365
local world_day_actual = 99

world_timestep = function()
	local t = world_day_actual

	t = t + 1
	if t>365 then t = 1 end

	world_day_actual = t
end



weather_season = object(function (name, temp_min, temp_max, hum_min, hum_max)
	local obj = {}

	obj.name = name or 'Default season'
	temperature_min = temp_min or 10
	temperature_max = temp_max or 25
	humidity_min = hum_min or 0.05
	humidity_max = hum_max or 0.4
	wind_min = 0
	wind_max = 5

	return obj
end)



weather = object(function (name)
	local obj = {}

	obj.name = name or 'Default climate' 		-- climate name
	local seasons = {}							-- array of seasons' names
	season_actual = nil--'evergreen'

	--pressure = 0		-- (0.0 - 1.0)
	humidity = 0.24		-- (0.0 - 1.0) %
	wind = 20			-- mph
	temperature = 25.2	-- degree Celsius
	condition = 'sunny' -- sky conditions
	sin = 0

	local wind_active = false
	local wind_power = 0
	local wind_length = 0
	local wind_length_max = 0
	local wind_spike_chance = 0.15
	local wind_spike_temp = -5
	local wind_spike_power = 20
	local wind_spike_length = 0

	local microWeather = {
		humidity_ = 0,
		humidity_ratio = 0.03,
	}

	obj.info = function()
		local y = table.getn(seasons)
--		print('------------------------------------------------------------------------------------------------------------------------------------------------------------')
	   	
--	   	print(("Climate: %s\tSeason: %s\t\tDay: %1d / %1d\t\t\tHum: %s\tTemp: %0.1f\tWind: %0.f mph\tCond: %s"):format(
--   		name,season_actual.name,world_day_actual,world_days,   tostring(math.floor(humidity*100))..'%',temperature,wind,condition))
	   	print(("Climate: %s\tSeason: %s\t\tDay: %1d / %1d\t\t\tHum: %0.2f\tTemp: %0.1f\tWind: %0.f mph\tCond: %s"):format(
   		name,season_actual.name,world_day_actual,world_days, humidity,temperature,wind,condition))
   		
   		print('')
   		
   		local x = ''
   		for i=1, y do
   			x = x .. seasons[i].name
   			if i < y then
   				x = x .. ' , '
   			end
   		end
   		--print(("Seasons: %s"):format(x))
   		--print(("Sinus: %0.1f"):format(sin))

   		if wind_active then
   			x = 'Wind'
   			if wind_spike_length>0 then x = x..' | Spike' end
   			print(x..' !')
   			print(wind_length)
   		end

		print('------------------------------------------------------------------------------------------------------------------------------------------------------------')
		--tostring(resist[damage_type]*100)..'%'
	end

	obj.addSeason = function(season)
		table.insert(seasons,season)
	end

	obj.setSeason = function()
		local index = table.getn(seasons)
		local y = world_days / index					-- kolko dni ma season
		local x = math.floor(world_day_actual / y + 1)
		if x>index then x=index end						-- zly algorytmus, ale toto to rychlo fixne :D 
		season_actual = seasons[x]
		--print(season_actual)

		sin = math.sin(math.rad(360/world_days * world_day_actual - 60))

		return season_actual
	end



	obj.addWind = function(power,length)
		if wind_active then return end

		wind_active = true
		wind_length = length
		wind_length_max = length
		wind_power = power
	end

	obj.WindStep = function()
		if wind_active then
			--local x = math.random(wind_power)
			local x = (math.random(wind_power)+math.random(wind_power)+math.random(wind_power))/3
			local y = wind_length / wind_length_max
			local pow = 1

			if y<=1 and y>=0.8 then
				pow = (1-y)*5
			end
			if y<=0.2 and y>=0 then
				pow = y*5
			end

			if wind_spike_length > 0 then
				x = x + math.random(wind_spike_power)
				temperature = temperature + wind_spike_temp
				wind = wind + wind_spike_power*pow
				wind_spike_length = wind_spike_length - 1
			else
				if math.chance(wind_spike_chance) then
					wind_spike_length = math.random(3,10)
				end
			end

			wind = wind + x*pow

			wind_length = wind_length - 1	

			if wind_length<1 then wind_active = false end
		end
	end

	obj.microWeatherStep = function()
		local u = season_actual
		local x = sin*20
		local y = 0
		--temperature = math.randomReal(u.temperature_min, u.temperature_max)
		--temperature = temperature + temperature * (sin+1)*0.2
		for i=1, 2 do
			y = y + math.randomReal(u.temperature_min, u.temperature_max)
			--y = y + math.randomReal(-5, 5)
		end
		y = y / 2
		temperature = x + y
		humidity = math.randomReal(u.humidity_min, u.humidity_max)
		wind = math.randomReal(u.wind_min, u.wind_max)

		if math.chance(0.1) then obj.addWind(50,60) end
	end

	obj.step = function()
		world_timestep()
		obj.setSeason()
		obj.microWeatherStep()
		obj.WindStep()
	end

	return obj
end)

local weather1 = weather('moderate')
weather1.addSeason(weather_season('spring',-2,5,0,1))
weather1.addSeason(weather_season('summer',3,10,0,1))
weather1.addSeason(weather_season('autumn',-4,3,0,1))
weather1.addSeason(weather_season('winter',-5,5,0,1))
--weather1.setSeason()
--weather1.step()
--weather1.info()

--local weather2 = weather('tropical',{'dry','wet'})
--weather2.setSeason()
--weather2.info()

local clock = os.clock
function sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end

for i=1, 3000 do
	sleep(0.5)
	weather1.step()
	weather1.info()
end