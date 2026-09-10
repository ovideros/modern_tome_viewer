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

base_size = 64

local jetdir = jetdir or -1

local nb = 10
local first = false

return { generator = function()
	if first then
		first = false

		return {
			life = 15,
			size = 8, sizev = 0, sizea = 0,

			x = 0, xv = 0, xa = 0,
			y = 0, yv = 0, ya = 0,
			dir = 0, dirv = 0, dira = 0,
			vel = 0, velv = 0, vela = 0,

			r = 1, rv = 0, ra = 0,
			g = 0, gv = 0, ga = 0,
			b = 0, bv = 0, ba = 0,
			a = 1, av = 0, aa = 0,
		}
	end
	

	local ad = rng.range(20+90, 160+90)
	local a = math.rad(ad)
	local dir = math.rad(ad + 90)
	local r = rng.range(1, 10)
	local dirv = math.rad(rng.float(-1,1))
	local life = rng.range(30,50)

	return {
		trail = 1,
		life = life,
		size = rng.range(8, 20), sizev = -0.2, sizea = 0,

		x = r * math.cos(a), xv = jetdir * 2, xa = -jetdir * 2 / life,
		y = r * math.sin(a), yv = 1, ya = -0.1,
		dir = dir, dirv = dirv, dira = -dirv/life,
		vel = rng.float(0.7, 2.9), velv = 0, vela = -0.01,

		r = 1, rv = 0, ra = 0,
		g = 1, gv = 0, ga = 0,
		b = 1, bv = 0, ba = 0,
		a = 0, av = 0.5 / (life/3), aa = -0.006,
	}
end, },
function(self)
	if nb > 0 then
		self.ps:emit(3)
		nb = nb - 1
	end
end,
30, smoke
