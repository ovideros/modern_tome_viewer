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

if core.shader.active() then
	use_shader = {type="lightning"}
end

base_size = 64

-- Make the ray
local ray = {}
local tx = tx * base_size
local ty = ty * base_size
ray.dir = math.atan2(tx, ty)
ray.size = math.sqrt(tx*tx+ty*ty)

local bpoints = {}
for i = 64, ray.size, 128 do
	bpoints[#bpoints+1] = {
		y = (i < ray.size / 2) and i - 64 or i + 64,
		yv = (i < ray.size / 2) and -1 or 1
	}
end


local points = {}

local function make_fork(xx)
	local sx, sy = xx, bpoints[1].y
	local tx, ty = 0, bpoints[#bpoints].y
	local basedir = math.atan2(ty, tx)
	local basesize = math.sqrt(ty*ty+tx*tx)

	local bc = temporary and 1 or rng.float(0.4, 0.7)
	local c = 1
	local a = 1 or rng.float(0.3, 0.6)
	local size = rng.range(2, 4) * (temporary and 2 or 1)
	points[#points+1] = {bc=bc, c=c, a=a, size=size, x=sx, y=sy, prev=-1}

	local nb = 20
	for i = 0, nb - 1 do
		-- Split point in the segment
		local split = rng.range(0, basesize / nb) + i * (basesize / nb)
		
		local dev = math.rad(rng.range(-3, 3))
		
		points[#points+1] = {bc=bc, c=c, a=a, movea=basedir+dev+math.pi/2, size=size + rng.range(-2, 2), x=sx+math.cos(basedir+dev) * split, y=sy+math.sin(basedir+dev) * split, prev=#points-1}
	end

	points[#points+1] = {bc=bc, c=c, a=a, size=size, x=sx+tx, y=sy+ty, prev=#points-1}
end

local life = 16

-- Populate the beam based on the forks
return { engine=core.particles.ENGINE_LINES, system_rotation = -math.deg(ray.dir), generator = function()
	local p = table.remove(points, 1)
	local a = p.a or rng.float(0.7, 1)

	return {
		life = life, trail=p.prev,
		size = p.size, sizev = -2 / life, sizea = 0,

		x = p.x, xv = 0, xa = 0,
		y = p.y, yv = 0, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = p.c, rv = 0, ra = 0,
		g = p.bc, gv = 0, ga = 0,
		b = p.bc, bv = 0, ba = 0,
		a = p.a, av = 0, aa = -0.06,
	}
end, },
function(self)
	if self.done then return end
	for i = 1, 5 do
		make_fork(-48)
		make_fork(0)
		make_fork(48)
	end
	self.ps:emit(#points)
	self.done = true
end,
800,
"particles_images/beam"
