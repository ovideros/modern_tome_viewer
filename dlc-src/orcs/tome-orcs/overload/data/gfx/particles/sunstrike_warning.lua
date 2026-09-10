
return { blend_mode=core.particles.BLEND_ADDITIVE, generator = function()
	local radius = radius or 3
	local sradius = radius * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local a = math.rad(rng.float(0, 360))
	local rvariance = math.cos(rng.float(-math.pi, math.pi))
	local r = (1 + rvariance * 0.05) * sradius
	local x = r * math.cos(a)
	local y = r * math.sin(a)
	local v = 0.03

	return {
		trail = 2,
		life = 12,
		size = 12, sizev = 0, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = a + math.rad(90), dirv = v, 	dira = 0,
		vel = v * r, 			velv = 0, 		vela = 0,

		r = rng.float(220, 255)/255,  rv = 0, ra = 0,
		g = rng.float(170, 240)/255,  gv = 0, ga = 0,
		b = 0,  bv = 0, ba = 0,
		a = 0.06 * math.sqrt(1 - math.abs(rvariance)),  av = 0, aa = 0,
	}
end, },
function(self)
	self.ps:emit(60)
end,
600