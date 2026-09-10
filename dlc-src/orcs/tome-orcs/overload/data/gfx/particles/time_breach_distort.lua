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

use_shader = {type="distort", power=0.06, power_time=1000000, blacken=30} alterscreen = true
base_size = 64

-- Make the ray
local ray = {}
local tx = tx * base_size
local ty = ty * base_size
ray.dir = math.atan2(tx, ty)
ray.size = math.sqrt(tx*tx+ty*ty)

local points = {}
for i = 64, ray.size, 128 do
	points[#points+1] = {
		y = (i < ray.size / 2) and i - 64 or i + 64,
		yv = (i < ray.size / 2) and -1 or 1
	}
end

local life = 16

-- Populate the beam based on the forks
return { system_rotation = -math.deg(ray.dir)+90, generator = function()
	local p1 = points[1] or points[#points]
	local p2 = points[#points]

	return {
		life = life,
		size = 200, sizev = 0, sizea = 0,

		x = p1.y, xv = (p2.y-p1.y)/life, xa = 0,
		y = 0, yv = 0, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = 1, rv = 0, ra = 0,
		g = 1, gv = 0, ga = 0,
		b = 1, bv = 0, ba = 0,
		a = 1, av = 0, aa = 0,
	}
end, },
function(self)
	if life >= 6 then
		self.ps:emit(1)
		life = life - 1
	end
end,
10, "particles_images/distort_wave_directional"
