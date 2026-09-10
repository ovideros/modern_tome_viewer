


return { generator = function()
	local radius = 0
	local sradius = (radius + 0.6) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local ad = rng.float(0, 360)
	local a = math.rad(ad)
	local r = rng.float(0, sradius / 4)
	local x = r * math.cos(a)
	local y = r * math.sin(a)
	local bx = math.floor(x / engine.Map.tile_w)
	local by = math.floor(y / engine.Map.tile_h)
	local static = rng.percent(40)

	return {
		trail = 1,
		life = 6,
		size = 5, sizev = 0, sizea = -6 / 36,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = a, dirv = math.rad(-8), dira = math.rad(20),
		vel = sradius / 2 / 6, velv = 0, vela = -sradius / 6 / 36,

		r = rng.range(230, 255)/255,  rv = 0, ra = (20/255),
		g = rng.range(160, 230)/255,  gv = -(2/255), ga = -(3/255),
		b = 20/255,                   bv = 0, ba = -(4/255),
		a = rng.range(80, 220)/255,   av = 0, aa = 0,
	}
end, },
function(self)
	self.ps:emit(60)
end,
600