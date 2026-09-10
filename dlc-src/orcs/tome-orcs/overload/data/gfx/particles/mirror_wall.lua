

return {  blend_mode=core.particles.BLEND_ADDITIVE, generator = function()
	local radius = radius or 1
	local sradius = radius * (engine.Map.tile_w + engine.Map.tile_h) / 2 * 0.5
	local a = math.rad(rng.float(0, 360))
	local varangle = rng.float(-math.pi, math.pi)
	local rvariance = (math.sqrt(math.cos(math.abs(varangle))) - 1) * varangle / math.abs(varangle)
	local r = sradius * (1 - math.pow(math.abs(rvariance), 2))
	local rf = r / sradius or 1
	local density = math.cos(rf * math.pi / 2)
	local ndensity = math.sin(rf * math.pi / 2)
	local x0 = math.cos(a)
	local y0 = math.sin(a)
	local z0 = math.cos(rng.float(0, math.pi))
	--the sqrt of the trig functions makes them more squarelike, and there's a weird offset for some reason
	local x = r * math.sqrt(math.abs(x0)) * x0 / math.abs(x0) - 0.0875 * sradius
	local y = r * math.sqrt(math.abs(y0)) * y0 / math.abs(y0) - 0.0875 * sradius
	local z = r * math.sqrt(math.abs(z0)) * z0 / math.abs(z0) / 2
	y = y + z

	--how math.sin can get me a value over 1 is beyond me but remove that and you will have pure pure white
	--and yes it used to literally just be sin(angle) and would still need that
	local aval = 0.125 * math.min(math.abs(ndensity) * (1.3 - z / r * 2) / 1.3, 1)
	
	return {
		trail = 2,
		life = 12,
		size = 9, sizev = 0, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = a, dirv = 0, 	dira = 0,
		vel = 0, velv = 0, vela = 0,

		
		--alpha doesn't work when switched to additive, so multiply the rgbs
		r = aval * rng.float(140, 240)/255,  rv = 0, ra = 0,
		g = aval * rng.float(70, 160)/255,  gv = 0, ga = 0,
		b = aval * rng.float(160, 255)/255,  bv = 0, ba = 0,
		a = 1, av = 0, aa = 0,--rng.float(0.5, 0.8) * ndensity,  av = 0, aa = 0,
	}
end, },
function(self)
	self.ps:emit(60)
end,
1200