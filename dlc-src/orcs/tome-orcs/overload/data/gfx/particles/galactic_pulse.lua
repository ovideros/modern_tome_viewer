


return { generator = function()
	local radius = 0
	local sradius = (radius + 1.7) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local a = math.rad(rng.chance(2) and 180 or 0)
	local r = rng.float(0, sradius)
	local rf = r / sradius
	local density = math.cos(rf * math.pi / 2)
	local ndensity = math.sin(rf * math.pi / 2)
	local ad = a + math.rad(360 * math.sin(rf * math.pi / 2)) + math.rad(30 * math.cos(rng.float(-math.pi, math.pi)))
	
	local randx = rng.float(-0.99, 0.99)
	local randy = rng.float(-0.99, 0.99)
	local x = r * math.cos(ad) + (r + sradius) / 40 * randx / math.sqrt(1 - randx * randx)
	local y = r * math.sin(ad) + (r + sradius) / 40 * randy / math.sqrt(1 - randy * randy)
	local bx = math.floor(x / engine.Map.tile_w)
	local by = math.floor(y / engine.Map.tile_h)
	local static = rng.percent(40)
	local star = rng.percent(4)
	
	local life = 6
	local rate = -1 / 6
	

	return {
		trail = 1,
		life = life,
		size = (4 * (1 - ndensity + density) + 1) * (star and 2 / 3 or 1), sizev = 0, sizea = -6 / 36,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = ad + math.rad(90 * ndensity), dirv = math.rad(20) * density * rate, dira = math.rad(5) * density * rate * rate,
		vel = sradius / life / 2 * rate, velv = 0, vela = 0,

		r = (star and rng.range(130, 255) or rng.range(5,15))/255,  					rv = 0, ra = 0,
		g = (star and rng.range(80, 255) or rng.range(5,15))/255,  					gv = 0, ga = 0,
		b = (star and rng.range(130, 255) or rng.range(25,35))/255, 					bv = 0, ba = 0,
		a = star and (110 + 110*density)/255 or rng.range(110, 220)/255 * density, 		av = 0, aa = 0,
	}
end, },
function(self)
	self.ps:emit(100)
end,
600