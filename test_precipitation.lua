local fuzzy = require 'fuzzy'

do
    local f1 = fuzzy.solver()
    local L = f1.L
    local F = f1.F
    local R = f1.R

    local precipitation = F {'precipitation', {0, 13}}
    precipitation['none'] = L {fuzzy.triangle, 			{0, 0.5, 1}}
    precipitation['drizzle'] = L {fuzzy.triangle, 		{1, 1.5, 2}}
    precipitation['light rain'] = L {fuzzy.triangle, 	{2, 2.5, 3}}
    precipitation['rain'] = L {fuzzy.triangle, 			{3, 3.5, 4}}
    precipitation['storm'] = L {fuzzy.triangle, 		{4, 4.5, 5}}
    precipitation['thunderstorm'] = L {fuzzy.triangle, 	{5, 5.5, 6}}
    precipitation['hailstorm'] = L {fuzzy.triangle, 	{6, 6.5, 7}}
    precipitation['light snow'] = L {fuzzy.triangle, 	{7, 7.5, 8}}
    precipitation['snow'] = L {fuzzy.triangle, 			{8, 8.5, 9}}
    precipitation['blizzard'] = L {fuzzy.triangle, 		{9, 9.5, 10}}
    precipitation['sandstorm'] = L {fuzzy.triangle, 	{10, 10.5, 11}}
    precipitation['ash'] = L {fuzzy.triangle, 			{11, 11.5, 12}}
    precipitation['fallout ash'] = L {fuzzy.triangle, 	{12, 12.5, 13}}

    local wind = F {'wind', {0, 10}}
    wind['none'] = L {fuzzy.gauss, 						{1, 0}}
    wind['mild'] = L {fuzzy.gauss, 						{1, 2}}
    wind['normal'] = L {fuzzy.gauss, 					{1, 5}}
    wind['strong'] = L {fuzzy.gauss, 					{1, 7}}
    wind['hurricane'] = L {fuzzy.gauss, 				{1, 10}}

    local hum = F {'humidity', {0, 10}}
    hum['dry'] = L {fuzzy.gauss, 						{1.5, 0}}
    hum['medium'] = L {fuzzy.gauss, 					{2, 5}}
    hum['wet'] = L {fuzzy.gauss, 						{1.5, 10}}

    local temp = F {'temperature', {-275, 70}}
    temp['absolute zero'] = L {fuzzy.gauss, 			{150, 0}}
    temp['chilly'] = L {fuzzy.gauss, 					{50, -30}}
    temp['cool'] = L {fuzzy.gauss, 						{20, 0}}
    temp['so so'] = L {fuzzy.gauss, 					{10, 20}}
    temp['warm'] = L {fuzzy.gauss, 						{10, 30}}
    temp['hot'] = L {fuzzy.gauss, 						{15, 40}}
    temp['burning'] = L {fuzzy.gauss, 					{30, 70}}

    local sky = F {'sky', {0, 10}}
   	sky['clear'] = L {fuzzy.gauss, 						{1, 0}}
   	sky['partly cloudy'] = L {fuzzy.gauss, 				{1, 1}}
   	sky['mostly cloudy'] = L {fuzzy.gauss, 				{3, 5}}
   	sky['overcast'] = L {fuzzy.gauss, 					{1, 9}}
   	sky['obscured'] = L {fuzzy.gauss, 					{1, 10}}

   	local normal_temp = -(temp['absolute zero'] + temp['chilly'] + temp['cool'] + temp['burning'])

    local r1 = R()
    r1.premise = hum['medium'] * normal_temp * -(sky['clear'])
    r1.implication = precipitation['drizzle']

    local r2 = R()
    r2.premise = hum['wet'] * normal_temp * -(sky['clear'] + sky['partly cloudy'])
    r2.implication = precipitation['light rain']

    local values = {
    	wind = 0,
    	humidity = 8,
    	temperature = 20,
    	sky = 4,
    }

    local result = f1(values)

    print(result)

end
