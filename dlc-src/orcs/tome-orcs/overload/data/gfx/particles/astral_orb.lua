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

return { generator = function()
	local radius = 0
	local sradius = 1.2 * (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local ad = rng.float(0, 360)
	local a = math.rad(ad)
	local r = rng.float(0, sradius / 4)
	local rf = r / sradius
	local density = math.cos(rf * math.pi / 2)
	local ndensity = math.sin(rf * math.pi / 2)
	local x = r * math.cos(a)
	local y = r * math.sin(a)
	local bx = math.floor(x / engine.Map.tile_w)
	local by = math.floor(y / engine.Map.tile_h)
	local star = rng.percent(4)

	return {
		trail = 5,
		life = 6,
		size = star and 4 or 6, sizev = 0, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = a, dirv = math.rad(-12), dira = math.rad(30),
		vel = sradius / 2 / 6, velv = 0, vela = -sradius / 6 / 36,

		r = (star and rng.range(130, 255) or rng.range(5,15))/255,  					rv = -1/255, ra = 0,
		g = (star and rng.range(80, 255) or rng.range(5,15))/255,  						gv = -1/255, ga = 0,
		b = (star and rng.range(130, 255) or rng.range(25,35))/255, 					bv = -1/255, ba = 0,
		a = star and (110 + 110*density)/255 or rng.range(110, 220)/255 * density, 		av = 0, aa = 0,
	}
end, },
function(self)
	self.ps:emit(24)
end,
30*6
