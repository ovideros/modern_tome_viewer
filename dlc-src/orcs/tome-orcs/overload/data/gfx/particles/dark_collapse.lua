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
	local radius = radius
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local ad = rng.float(0, 360)
	local a = math.rad(ad)
	local r = rng.float(0, sradius)
	local rf = r / sradius
	local density = math.cos(rf * math.pi / 2)
	local ndensity = math.sin(rf * math.pi / 2)
	local x = r * math.cos(a)
	local y = r * math.sin(a)
	
	local rate = 2

	return {
		trail = 3,
		life = 65 / math.abs(rate),
		size = 10, sizev = 0, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = a, dirv = 0, dira = 0,
		vel = -1.5 * ndensity * rate * radius, velv = 0.325 * density * rate * rate * radius, vela = -0.0175 * density * rate * rate * rate * radius,

		r = rng.range(0, 80)/255,  rv = -0.1, ra = 0,
		g = rng.range(0, 80)/255,  gv = -0.1, ga = 0,
		b = rng.range(0, 80)/255,  bv = -0.1, ba = 0,
		a = rng.range(10, 20)/255 * density ,    av = 4/255 * density * rate, aa = -0.14/255 * density * rate * rate,
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
