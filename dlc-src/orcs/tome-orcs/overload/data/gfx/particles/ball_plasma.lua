-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2019 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

local nb = 0
return { generator = function()
	local light = light or 1/2 --0 at 100% neg, 1 at 100% pos
	local radius = radius
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local ad = rng.float(0, 360)
	local a = math.rad(ad)
	local r = rng.float(0, sradius / 2)
	local x = r * math.cos(a)
	local y = r * math.sin(a)
	local bx = math.floor(x / engine.Map.tile_w)
	local by = math.floor(y / engine.Map.tile_h)
	local static = rng.percent(40)
	
	local clight = {55 + 180, 1, 0.7}
	local cdark = {225 - 180, 0.75, 0.15}
	--interpolate the values, and lower the saturation at values near the middle
	local col = {cdark[1] - light * (cdark[1] - clight[1]), cdark[2] - light * (cdark[2] - clight[2]) - 0.4 * math.cos(math.pi * (light - 1 / 2) / 2), cdark[3] - light * (cdark[3] - clight[3])}
	col[1] = col[1] + rng.range(-20, 20)
	col[1] = (col[1] + 180) % 360
	col[2] = col[2] + rng.range(-0.1, 0.1)
	col[2] = math.max(0, col[2])
	
	--this code is pretty much copied from wikipedia, doing it on a circle instead of a hexagon later could probably reduce the costs a bit
	local chroma = col[2] * (1 - math.abs(2 * col[3] - 1))
	local hue2 = (col[1] % 360) / 60
	local chrom2 = chroma * (1 - math.abs(hue2 % 2 - 1))
	local m = col[3] - chroma / 2
	local r, g, b = 0, 0, 0
	if 		(hue2 < 1) then r, g, b = chroma, chrom2, 0
	elseif	(hue2 < 2) then r, g, b = chrom2, chroma, 0
	elseif	(hue2 < 3) then r, g, b = 0, 	  chroma, chrom2
	elseif	(hue2 < 4) then r, g, b = 0,	  chrom2, chroma
	elseif	(hue2 < 5) then r, g, b = chrom2, 0,	  chroma
	elseif 	(hue2 < 6) then r, g, b = chroma, 0,	  chrom2
	end
	r = r + m
	g = g + m
	b = b + m

	return {
		trail = 1,
		life = 10,
		size = 3, sizev = 0, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = a, dirv = 0, dira = 0,
		vel = sradius / 2 / 10, velv = 0, vela = 0,

		r = r,  rv = 3/255, ra = 0,
		g = g,  gv = 3/255, ga = 0,
		b = b, 	bv = 3/255, ba = 0,
		a = rng.range(40, 255)/255, 		av = 0, aa = 0,
	}
end, },
function(self)
	if nb < 5 then
		self.ps:emit(radius*266)
		nb = nb + 1
		self.ps:emit(radius*266)
		nb = nb + 1
		self.ps:emit(radius*266)
		nb = nb + 1
		self.ps:emit(radius*266)
		nb = nb + 1
		self.ps:emit(radius*266)
		nb = nb + 1
	end
end,
5*radius*266
