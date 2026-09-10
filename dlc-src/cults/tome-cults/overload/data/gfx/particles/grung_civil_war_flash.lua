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



local first = true
return { generator = function()
	local a = rng.float(0.5, 1)
	return {
		life = 8,
		size = 2200, sizev = 0, sizea = -1200 / 8 / 8,

		x = rng.range(-width / 2.5, width / 2.5), xv = 0, xa = 0,
		y = rng.range(-height / 2.5, height / 2.5), yv = 0, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = rng.float(0.4, 1), rv = 0, ra = 0,
		g = rng.float(0.4, 1), gv = 0, ga = 0,
		b = rng.float(0.4, 1), bv = 0, ba = 0,
		a = a, av = 0, aa = -a / 8 / 8,
	}
end, },
function(self)
	if first then self.ps:emit(1) end
	first = false
end,
1
