require 'init'

--[[

EXCEL OUTPUT TXT MAKER

--]]
local output_string
local path = 'weather_output.txt'
local file = io.open(path, 'w')
Output = function(s)
	file:write(s)
end
Output('"Day" "Hour" "Temperature" "Humidity" "Wind" "Clouds" "Precipitation" "Condition"\n')



local world_days = 365 -- constant
local world_hours = 24 -- constant
local world_day_actual = 0
local world_hour_actual = 24

world_timestep = function()
	local d = world_day_actual
	local h = world_hour_actual

	h = h + 1
	if h>world_hours then
		h = 1
		d = d + 1
		if d>world_days then d = 1 end
		world_day_actual = d
 	end
	world_hour_actual = h
end



weather_season = object(function (name, temp_min, temp_max, hum_min, hum_max, wind_min, wind_max, cloud_min, cloud_max, precip_chance)
	local obj = {}

	obj.name = name or 'Default season'
	obj.temperature_min = temp_min or 10	-- min random
	obj.temperature_max = temp_max or 25	-- max random
	--temperature_range = 18				-- (-range,range)
	--temperature_add = 2					-- add+range
	obj.humidity_min = hum_min or 0.05
	obj.humidity_max = hum_max or 0.4
	obj.wind_min = wind_min or 0
	obj.wind_max = wind_max or 5
	obj.cloud_min = cloud_min or 0
	obj.cloud_max = cloud_max or 1
	obj.precip_chance = precip_chance or 0

	return obj
end)



weather = object(function (name, _temp_range_daily, _temp_range_hourly, _temp_range_add)
	local obj = {}

	obj.name = name or 'Default climate' 		-- climate name
	local seasons = {}							-- array of seasons' names
	season_actual = nil--'evergreen'

	--pressure = 0		-- (0.0 - 1.0)
	humidity = 0		-- (0.0 - 1.0) %
	wind = 20			-- km/h
	temperature = 20	-- degree Celsius
	cloud = 0 			-- (0.0 - 1.0) % oblakov, sky cond
	precipitation = 0	-- pocet zraziek
	condition = 'clear'	-- sky conditions
	sin_day = 0			-- sinus day, aby v zime bola zima a cez leto leto :D
	sin_hour = 0		-- sinus hour, aby vecer bola zima a cez den teplo :D

	local temp_daily = 0
	local temperature_range = _temp_range_daily or 18	-- daily (-range,range)
	local temperature_range2 = _temp_range_hourly or 8	-- hourly (-range,range)
	local temperature_add = _temp_range_add or 2		-- add+range

	local hum_daily = 0

	local wind_daily = 0
	local wind_active = false
	local wind_temp = 0 -- -1
	local wind_power = 0
	local wind_length = 0
	local wind_length_max = 0
	local wind_spike_chance = 0.15
	local wind_spike_temp = 0 -- -5
	local wind_spike_power = 5
	local wind_spike_length = 0

	local precip_active = false
	local precip_type = 'rain'
	local precip_power = 0
	local precip_length = 0
	local precip_length_max = 0

	--local microWeather = {
	--	humidity_ = 0,
	--	humidity_ratio = 0.03,
	--}

	obj.info = function()
		local y = table.getn(seasons)
--		print('------------------------------------------------------------------------------------------------------------------------------------------------------------')
	   	
--	   	print(("Climate: %s\tSeason: %s\t\tDay: %1d / %1d\t\t\tHum: %s\tTemp: %0.1f\tWind: %0.f mph\tCond: %s"):format(
--   		name,season_actual.name,world_day_actual,world_days,   tostring(math.floor(humidity*100))..'%',temperature,wind,condition))
	   	print(("Climate: %s\tSeason: %s\t\tDay: %1d / %1d\tHour: %2d\t\tHum: %0.2f\tTemp: %5.2f\tWind: %0.2f kmh\t\tCond: %0.2f %s+%s"):format(
   		name,season_actual.name,world_day_actual,world_days,world_hour_actual, humidity,temperature,wind,--[[condition--]] cloud,obj.getSky(),obj.getWind()))
   		
   		--[[
   		local x = ''
   		for i=1, y do
   			x = x .. seasons[i].name
   			if i < y then
   				x = x .. ' , '
   			end
   		end
   		print(("Seasons: %s"):format(x))
   		--]]
   		--print(("Sinus: %0.1f"):format(sin_hour))

   		if wind_active then
   			x = 'Wind'
   			if wind_spike_length>0 then x = x..' | Spike' end
   			print(x..' ! For '..wind_length..' hours')
   		end

		print('------------------------------------------------------------------------------------------------------------------------------------------------------------')
		--tostring(resist[damage_type]*100)..'%'


		--[[
	
		OUTPUT FOR EXCEL

		--]]
		-- output temperature -> hourly
		local x = 'Day:'..world_day_actual..' Hour:'..world_hour_actual..' Temp: '
		--local num = math.floor((temperature)*10000)*0.0001
		local num = math.round(temperature)
		--if num % 1 == 0 then num=num+0.01 end
		local str0 = world_hour_actual
		local str1 = tostring(num)
		local str2 = tostring(math.round(humidity*100))
		local str3 = tostring(math.round(wind))
		local str4 = tostring(math.round(cloud*100))
		local str5 = tostring(math.round(precipitation))
		local str9 = '"'..obj.getSky()..'+'..obj.getWind()
		if precip_active then str9 = str9..'+'..precip_type end
		str9 = str9..'"'
		--string.gsub(str1, '.', ',') -- nefunguje
		--str1:gsub(".", ",") 
		-- output temperature -> daily / hour 12
		--if world_hour_actual == 12 then
			x = world_day_actual
			Output(x..' '..str0..' '..str1..' '..str2..' '..str3..' '..str4..' '..str5..' '..str9..'\n')
		--end
	end

	--[[
	
	SEASONS

	--]]
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

		return season_actual
	end


	--[[
	
	SKY CONDITION

	--]]
	obj.getSky = function()
    	local x = cloud
    	if x>0.975 then
    		result = 'obscured'
    	elseif x>0.85 then
    		result = 'overcast'
    	elseif x>0.5 then
    		result = 'mostly cloudy'
    	elseif x>0.1 then
    		result = 'partly cloudy'
    	else
    		result = 'clear'
    	end

    	return result
	end

	--[[
	
	PRECIPITATION

	--]]
	obj.canThunderstorm = function()	-- storm + precipitation
		result = false
		if wind>50 and cloud>0.85 then
			result = true
		end
		return result
	end

	obj.canBlizzard = function()	-- storm + precipitation
		result = false
		if wind>70 and cloud>0.75 and temperature<-4 then
			result = true
		end
		return result
	end

	obj.canStorm = function()	-- storm viac v pozadi, iba zvuky hrmenia
		result = false
		if wind>50 or cloud>0.7 then
			result = true
		end
		return result
	end

	obj.getPrecip = function()
    	local x = precip_power
    	local t = temperature
    	if x>50 then
    		result = 'heavy '
    	elseif x>20 then
    		result = ''
    	elseif x>5 then
    		result = 'light '
    	else
    		result = 'drizzle'
    	end
    	if x>5 then
    		if t>-1 then
    			result = result..'rain'
    		else
    			result = result..'snow'
    		end
    	end

    	return result
	end

	obj.addPrecip = function(power,length)
		if precip_active then return end

		precip_active = true
		precip_length = length
		precip_length_max = length
		precip_power = power
		precip_type = obj.getPrecip()
	end

	obj.PrecipStep = function()
		if precip_active then
			--local x = math.random(wind_power)
			local x = math.random(precip_power)--(math.random(wind_power)+math.random(wind_power)+math.random(wind_power))/3
			local y = precip_length / precip_length_max
			local pow = 1 -- multiplier, pouzity pri fade

			-- FADE IN
			if y<=1 and y>=0.8 then
				pow = (1-y)*5
			end
			-- FADE OUT
			if y<=0.2 and y>=0 then
				pow = y*5
			end

			-- RAIN pri urcitych podmienkach znizuje vlhkost
			local hum = math.random()*0.13
			if math.chance(0.33) then hum = 0.25 end
				--if wind > 20 and (humidity > 0.4 or wind_temp > -1) then
			humidity = humidity + humidity * hum * pow
				--end
			--end
			if cloud <= 0.5 then
				precip_length = precip_length - 1
				precip_length_max = precip_length_max - 1
			end

			precipitation = precip_power * pow
			precip_length = precip_length - 1	

			if precip_length<1 then precip_active = false end
		end
	end
	
	--[[
	
	WIND

	--]]
	obj.getWind = function()
    	local x = wind
    	if x>118 then
    		result = 'hurricane'
    	elseif x>88 then
    		result = 'storm'
    	elseif x>50 then
    		result = 'gale'
    	elseif x>12 then
    		result = 'breeze'
    	else
    		result = 'calm'
    	end

    	return result
	end

	obj.addWind = function(power,length)
		if wind_active then return end
		-- if wind_power<power then -- mal to byt stacking ale neviem ako na to, napada ma nejak to nasobit ze length 4 a 4 bude 6

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
			local pow = 1 -- multiplier celeho vetra, pouzity pri fade

			-- FADE IN
			if y<=1 and y>=0.8 then
				pow = (1-y)*5
			end
			-- FADE OUT
			if y<=0.2 and y>=0 then
				pow = y*5
			end

			-- WIND_SPIKE je velmi kratke zosilnenie vetra, intenzivnejsie ale kratsie posobi aj na teplotu
			-- vo finalnej verzi by sa mali spustat niektore kratke one-hit wind soundy
			if wind_spike_length > 0 then
				x = x + math.random(wind_spike_power)
				temperature = temperature + math.randomReal(wind_spike_temp*0.33,wind_spike_temp)*pow
				wind = wind + wind_spike_power*pow
				wind_spike_length = wind_spike_length - 1
			else
				if math.chance(wind_spike_chance) then
					wind_spike_length = math.random(3,10)
				end
			end

			if cloud>0.5 and math.chance(0.18) then x = x + cloud * math.random(2,4) end

			temperature = temperature + math.randomReal(wind_temp*0.5,wind_temp)*pow
			wind = wind + x*pow

			-- WIND pri urcitych podmienkach znizuje vlhkost
			if math.chance(0.33) then
				if wind > 20 and (humidity > 0.4 or wind_temp > -1) then
					--humidity = humidity - wind*(0.0006+math.random()*0.001)
					humidity = humidity * 0.75
				end
			end

			wind_length = wind_length - 1	

			if wind_length<1 then wind_active = false end
		end
	end

	--[[
	
	LOOPS
	TEMPERATURE

	--]]
	obj.dayWeatherStep = function()
		local u = season_actual
		sin_day = math.sin(math.rad(360/world_days * world_day_actual - 60)) -- (-90 ak ma zacinat od januara ale potom to blbne s nazvami seasons) kalkulovane 1x per day
		local temp_add = temperature_add
		local temp_avg = temperature_range
		local temp = sin_day*0.5*temp_avg + temp_add
		local y = 0

		for i=1, 3 do
			y = y + math.randomReal(u.temperature_min, u.temperature_max)
		end
		y = y / 3

		temp_daily = temp + y
		--wind_daily = math.randomReal(u.wind_min, u.wind_max)
		hum_daily = math.randomReal(u.humidity_min, u.humidity_max)
		wind_daily = math.randomP(u.wind_min, u.wind_max, 3+math.random(0,12)) + (1-sin_day)*4
	end

	obj.hourWeatherStep = function()
		local u = season_actual
		sin_hour = math.sin(math.rad(360/world_hours * world_hour_actual - 90))*0.75 + sin_day*0.5 + 0.75
		local y = 0
		local old

		--temperature = math.randomReal(u.temperature_min, u.temperature_max)
		--temperature = temperature + temperature * (sin+1)*0.2
		for i=1, 3 do
			y = y + math.randomReal(u.temperature_min, u.temperature_max)*0.0417
		end
		y = y / 3

		-- TEMPERATURE
			temperature = temp_daily + y + sin_hour*temperature_range2 --range2 = 8
		-- HUMIDITY
			y = (math.randomReal(u.humidity_min, u.humidity_max)-0.5)*0.0417
			if math.chance(0.16) then
				y = 0
			else
			--	if math.chance(0.05) then y = y + math.random()*0.5 end
				if math.chance(0.48) then y = -y end
			--	if math.chance(0.2) then y = y*math.random()*0.25 end
			--	if math.chance(0.1) or (math.chance(0.5) and wind_active and wind>wind_power*0.95) then y = y - 0.15 end
			end
			-- ranna rosa
			if temperature>6 and world_hour_actual>5 and world_hour_actual<8 then
				y = y + math.randomReal(0.3,1)*0.163
			end                                     
			humidity = hum_daily + y --math.randomReal(u.humidity_min, u.humidity_max)
		-- WIND
			old = wind
			y = wind_daily
			if math.chance(0.15) then
				y = y - wind_daily * math.cos(math.rad(cloud*world_day_actual+90))*0.5
			end
			if math.chance(0.5) then
				if math.chance(0.3) then y = y*0.1417 end
				if math.chance(0.22) then y = y + wind*0.35*(math.random()-0.5) end
				if math.chance(0.4) then y = y - math.randomReal(math.random()*2,u.wind_max+u.temperature_max)*sin_day*0.44 end
			else
				if math.chance(0.07) then y = y + math.randomReal(u.wind_min, u.wind_max)*0.05 end
				if math.chance(0.1) and math.chance(0.12) then
					obj.addWind(math.random(10,35)+sin_day+2, math.random(15,60)) -- add wind
				elseif math.chance(0.25) or math.chance(0.28) then
					y = y - math.random(15,20)
				end
			end
			wind = y
			if wind-old>math.random(4,8) then wind = y*0.25 end -- ak je vietor silnejsi nez stary
			--if wind_daily - old > 3 then wind = wind - 2 end
 		-- CLOUD
			--cloud = math.randomReal(u.cloud_min, u.cloud_max)
			y = math.randomReal(u.cloud_min, u.cloud_max)*0.0417*(math.random()-0.5)*10
			if math.chance(0.25+math.random()*0.25) then
				y = 0
			else
				if math.chance(0.13) then
					y = y * -10
					--print("!!!")
				elseif math.chance(0.4) then
					y = y * math.dice(2,4)
				end
			end
			cloud = cloud + y
			if math.chance(u.precip_chance) and cloud>0.1 then
				if math.chance(0.25) or (math.chance(0.4) and cloud>0.85) then -- 25% na silnejsi dazd alebo 40% + Overcast
					obj.addPrecip(math.randomP(5,50,2), math.round(math.random(12,75) + cloud*15)) -- add rain/snow
				else
					obj.addPrecip(math.randomP(1,25,1.5), math.round(math.random(6,60) + cloud*5)) -- add smaller rain/snow
				end
			end
		-- PRECIPITATION
			precipitation = 0
 	end



	obj.errorCheck = function()
		cloud = 		math.clamp(cloud,0,1)
		humidity = 		math.clamp(humidity,0,1)
		temperature = 	math.clamp(temperature,-275,70)
		wind = 			math.clamp(wind,0,408) -- maximum bolo namerane 408 km/h
	end

	obj.step = function()
		world_timestep()
		if world_hour_actual==1 then
			obj.setSeason()
			obj.dayWeatherStep()
		end
		obj.hourWeatherStep()
		obj.WindStep()
		obj.PrecipStep()
		obj.errorCheck() -- staci to zavolat na konci? myslim ze nie
	end

	return obj
end)

local weather1 = weather('moderate')
--weather1.addSeason(weather_season('spring',-2,5,0.5,1))
--weather1.addSeason(weather_season('summer',0,4,0.3,0.7))
--weather1.addSeason(weather_season('autumn',-3,7,0.5,1))
--weather1.addSeason(weather_season('winter',-5,5,0.1,0.5))
--								 ( name, 	temp, 	hum, 		wind, 	cloud,		precip )
weather1.addSeason(weather_season('spring',	-2,3,	0.5,1,		0,12,	-0.2,0.65,	0.006))
weather1.addSeason(weather_season('summer',	-2,5,	0.3,0.7,	0,5,	-0.5,0.3,	0.0024))
weather1.addSeason(weather_season('autumn',	-2,2,	0.5,1,		0,25,	0.1,0.9,	0.0059))
weather1.addSeason(weather_season('winter',	-4,6,	0.25,0.8,	0,40,	0.05,0.81,	0.0074))

--local weather2 = weather('tropical',{'dry','wet'})

local clock = os.clock
function sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end

for i=1, 365 do
	for h=1, 24 do
		--if h % 12 == 1 then sleep(2.05) end
		weather1.step()
		weather1.info()
	end
	--sleep(0.01)
	--if i % 30 == 1 then sleep(2.5) end
		--weather1.step()
		--weather1.info()
end




io.close(file)
