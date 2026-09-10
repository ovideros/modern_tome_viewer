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

-- can_shift = true
-- toback = true
base_size = 64

local nb = 10
local x, y = (x or 0) * engine.Map.tile_w, (y or 0) * engine.Map.tile_h

return { generator = function()
	local ad = rng.range(70+90, 110+90)
	local a = math.rad(ad)
	local dir = math.rad(ad + 90)
	local r = rng.range(1, 4)
	local dirv = math.rad(rng.float(-0.2,0.2))
	local life = rng.range(10,20)

	return {
		trail = 1,
		life = life,
		size = rng.range(3, 8), sizev = -0.06, sizea = 0,

		x = r * math.cos(a) + x, xv = 0, xa = 0,
		y = r * math.sin(a) + y, yv = 1, ya = -0.1,
		dir = dir, dirv = dirv, dira = -dirv/life,
		vel = rng.float(1.2, 1.8), velv = 0, vela = -0.005,

		r = 1, rv = 0, ra = 0,
		g = 1, gv = 0, ga = 0,
		b = 1, bv = 0, ba = 0,
		a = 0, av = 0.8 / (life/3), aa = -0.04,
	}
end, },
function(self)
	self.ps:emit(1)
end,
25, "particles_images/smoke_heavy_bright", true
