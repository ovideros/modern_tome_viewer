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

-- Make the ray
local ray = {}
local tx = tx * base_size
local ty = ty * base_size
ray.dir = math.atan2(tx, ty)
ray.size = math.sqrt(tx*tx+ty*ty)

local points = {}
for i = 64, ray.size, 64 do
	points[#points+1] = {
		x = 0,
		y = i,
	}
end

local life = 12

-- Populate the beam based on the forks
return { blend_mode=core.particles.BLEND_SHINY, system_rotation = -math.deg(ray.dir), generator = function()
	local p = table.remove(points, 1)

	return {
		life = life,
		size = 64, sizev = 0, sizea = 0,

		x = p.x, xv = 0, xa = 0,
		y = p.y, yv = 0, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = 0.2, rv = 0, ra = 0,
		g = 0.5, gv = 0, ga = 0,
		b = 1,   bv = 0, ba = 0,
		a = 1,   av = -1/life, aa = 0,
	}
end, },
function(self)
	if not self.done then
		self.done = true
		self.ps:emit(#points)
	end
end,
100,
"particles_images/beam"
