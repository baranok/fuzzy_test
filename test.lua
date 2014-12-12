local fuzzy = require 'fuzzy'

do
    local f1 = fuzzy.solver()
    local L = f1.L
    local F = f1.F
    local R = f1.R

    local service = F {'service', {0, 10}}
    service['poor'] = L {fuzzy.gauss, {1.5, 0}}
    service['good'] = L {fuzzy.gauss, {1.5, 5}}
    service['excelent'] = L {fuzzy.gauss, {1.5, 10}}

    local food = F {'food', {0, 10}}
    food['rancid'] = L {fuzzy.trapezoid, {0, 0, 1, 3}}
    food['delicious'] = L {fuzzy.trapezoid, {7, 9, 10, 10}}

    local tip = F {'tip', {0, 30}}
    tip['cheap'] = L {fuzzy.triangle, {0, 5, 10}}
    tip['average'] = L {fuzzy.triangle, {10, 15, 20}}
    tip['generous'] = L {fuzzy.triangle, {20, 25, 30}}

    local r1 = R(1)
    r1.premise = service['poor'] * food['rancid']
    r1.implication = tip['cheap']

    local r2 = R(1)
    r2.premise = service['good']
    r2.implication = tip['average']

    local r3 = R(1)
    r3.premise = service['excelent'] * food['delicious']
    r3.implication = tip['generous']

    local values = {
        service = 6.0,
        food = 2.9,
    }

    -- @22.2115
    local result = f1(values)

    print(result)

end
--[[
    local precipitation = F {'precipitation', {0, 12}}
    precipitation['none'] = L {fuzzy.gauss, {1.5, 0}}
    precipitation['drizzle'] = L {fuzzy.gauss, {1.5, 1}}
    precipitation['light rain'] = L {fuzzy.gauss, {1.5, 2}}
    precipitation['rain'] = L {fuzzy.gauss, {1.5, 3}}
    precipitation['storm'] = L {fuzzy.gauss, {1.5, 4}}
    precipitation['thunderstorm'] = L {fuzzy.gauss, {1.5, 5}}
    precipitation['hailstorm'] = L {fuzzy.gauss, {1.5, 6}}
    precipitation['light snow'] = L {fuzzy.gauss, {1.5, 7}}
    precipitation['snow'] = L {fuzzy.gauss, {1.5, 8}}
    precipitation['blizzard'] = L {fuzzy.gauss, {1.5, 9}}
    precipitation['sandstorm'] = L {fuzzy.gauss, {1.5, 10}}
    precipitation['ash'] = L {fuzzy.gauss, {1.5, 11}}
    precipitation['fallout ash'] = L {fuzzy.gauss, {1.5, 12}}

    local wind = F {'wind', {0, 10}}
    wind['none'] = L {fuzzy.trapezoid, {0, 0, 1, 3}}
    wind['mild'] = L {fuzzy.trapezoid, {7, 9, 10, 10}}
    wind['normal'] = L {fuzzy.trapezoid, {7, 9, 10, 10}}
    wind['strong'] = L {fuzzy.trapezoid, {7, 9, 10, 10}}
    wind['hurricane'] = L {fuzzy.trapezoid, {7, 9, 10, 10}}

    local hum = F {'hum', {0, 10}}
    hum['dry'] = L {fuzzy.triangle, {0, 5, 10}}
    hum['medium'] = L {fuzzy.triangle, {10, 15, 20}}
    hum['wet'] = L {fuzzy.triangle, {20, 25, 30}}

    local temp = F {'temp', {0, 10}}
    temp['absolute zero'] = L {fuzzy.triangle, {0, 5, 10}}
    temp['chilly'] = L {fuzzy.triangle, {10, 15, 20}}
    temp['cool'] = L {fuzzy.triangle, {20, 25, 30}}
    temp['so so'] = L {fuzzy.triangle, {20, 25, 30}}
    temp['warm'] = L {fuzzy.triangle, {20, 25, 30}}
    temp['hot'] = L {fuzzy.triangle, {20, 25, 30}}
    temp['burning'] = L {fuzzy.triangle, {20, 25, 30}}

    local sky = F {'sky', {0, 10}}
   	sky['clear'] = L {fuzzy.triangle, {0, 5, 10}}
   	sky['partly cloudy'] = L {fuzzy.triangle, {0, 5, 10}}
   	sky['mostly cloudy'] = L {fuzzy.triangle, {0, 5, 10}}
   	sky['overcast'] = L {fuzzy.triangle, {0, 5, 10}}
   	sky['obscured'] = L {fuzzy.triangle, {0, 5, 10}}

   	local normal_temp = -(temp['absolute zero'] + temp['chilly'] + temp['cool'] + temp['burning'])

    local r1 = R(1)
    r1.premise = hum['wet'] * normal_temp * -(sky['clear'])
    r1.implication = precipitation['drizzle']

--]]