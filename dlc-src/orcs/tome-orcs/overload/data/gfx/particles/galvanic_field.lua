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

local do_edges = do_edges
local temporary = temporary

base_size = 64

local ad1 = {}
local ad2 = {}
local ad3 = {}
ad1.x, ad1.y = (r1.x or 1) * base_size, (r1.y or 1) * base_size
ad2.x, ad2.y = (r2.x or 1) * base_size, (r2.y or 2) * base_size
ad3.x, ad3.y = (r3.x or 2) * base_size, (r3.y or 2) * base_size

-- Make the triangle. Math powa!

-- Find two of the three tirangle vectors and use those to define a new coordinate system
-- Our triangle will be of size 1x1 in this system
local u = {x=ad2.x - ad1.x, y=ad2.y - ad1.y}
local v = {x=ad3.x - ad1.x, y=ad3.y - ad1.y}
local w = {x=ad3.x - ad2.x, y=ad3.y - ad2.y}

local points = {}

local function rnd_point(sides)
	if do_edges then
		local s = rng.tableRemove(sides)
		if s == 1 then
			return 0, 0
		elseif s == 2 then
			return u.x, u.y
		else
			return v.x, v.y
		end
	else
		local p = rng.float(0, 1)
		local s = rng.tableRemove(sides)
		if s == 1 then
			return p*u.x, p*u.y
		elseif s == 2 then
			return p*v.x, p*v.y
		else
			return u.x+p*w.x, u.y+p*w.y
		end
	end
end

local function make_fork()
	local sides = {1,2,3}
	local sx, sy = rnd_point(sides)
	local tx, ty = rnd_point(sides)
	-- local sx, sy = u.x, u.y
	-- local tx, ty = v.x, v.y
	tx, ty = tx - sx, ty - sy
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
		
		local dev = math.rad(rng.range(-8, 8))
		
		points[#points+1] = {bc=bc, c=c, a=a, movea=basedir+dev+math.pi/2, size=size + rng.range(-2, 2), x=sx+math.cos(basedir+dev) * split, y=sy+math.sin(basedir+dev) * split, prev=#points-1}
	end

	points[#points+1] = {bc=bc, c=c, a=a, size=size, x=sx+tx, y=sy+ty, prev=#points-1}
end

local life = life or rng.range(5, 10)

-- Populate the beam based on the forks
return { engine=core.particles.ENGINE_LINES, generator = function()
	local p = table.remove(points, 1)
	local a = p.a or rng.float(0.7, 1)

	return {
		life = life, trail=p.prev,
		size = p.size, sizev = -2 / life, sizea = 0,

		x = p.x + ad1.x, xv = 0, xa = 0,
		y = p.y + ad1.y, yv = 0, ya = 0,
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
	self.nb = self.nb or 0
	if self.nb % life == 0 then
		make_fork()
		make_fork()
		make_fork()
		self.ps:emit(#points)
		if temporary then self.done = true end
	end
	self.nb = self.nb + 1
end,
500,
"particles_images/beam"
