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

--------------------------------------------------------------------------------------
-- Advanced shaders
--------------------------------------------------------------------------------------
if core.shader.active(4) then
use_shader = {type="fireflash", explosion_time_factor=800}
base_size = 64

local nb = 0

local dir = 0
if proj_x and src_x then
	dir = math.deg(math.atan2(proj_y-src_y, proj_x-src_x))
end

return {
	system_rotation = dir, system_rotationv = 0,
	generator = function()
	return {
		life = 42,
		--size = 30, sizev = 2.1*64*radius/16, sizea = 0,
		size = 3.5*64*radius, sizev = 0, sizea = 0,

		x = 0, xv = 0, xa = 0,
		y = 0, yv = 0, ya = 0,
		dir = 0, dirv = dirv, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = 1, rv = 0, ra = 0,
		g = 1, gv = 0, ga = 0,
		b = 1, bv = 0, ba = 0,
		a = 0.35, av = 0, aa = 0,
	}
end, },
function(self)
	if nb < 1 then
		self.ps:emit(1)
	end
	nb = nb + 1
end,
1, "particles_images/tale_of_destruction"


--------------------------------------------------------------------------------------
-- Default
--------------------------------------------------------------------------------------
else
rm, rM = rm or 0.8, rM or 1
gm, gM = gm or 0.8, gM or 1
bm, bM = bm or 0, bM or 0
am, aM = am or 1, aM or 1
size=4
distorion_factor=2.8
life=15
nb_circles=8
rm=0.8 rM=1
gm=0 gM=0
bm=0.1 bM=0.2
am=0.6 aM=0.8

-- Make the 2 main forks
local distortion_factor = 1 + (distortion_factor or 0.1)
local life = life or 30
local fullradius = (radius or 5) * engine.Map.tile_w
local basespeed = fullradius / life
local points = {}

for fork_i = 1, nb_circles or 5 do
	local size = size or 2
	local r = 10
	local a = 0
	local firstspeed = rng.float(basespeed, basespeed * distortion_factor)
	points[#points+1] = {size=size, dir = a + math.rad(90), vel = firstspeed, x=math.cos(a) * r, y=math.sin(a) * r, prev=-1}

	for i = 1, 35 do
		local a = math.rad(i * 10)
		points[#points+1] = {
			size=size,
			dir = a + math.rad(90),
			vel = rng.float(basespeed, basespeed * distortion_factor),
			x=math.cos(a) * r,
			y=math.sin(a) * r,
			prev=#points-1
		}
	end

	points[#points+1] = {size=size, dir = a + math.rad(90), vel = firstspeed, x=math.cos(a) * r, y=math.sin(a) * r, prev=#points-1}
end
local nbp = #points

-- Populate the lightning based on the forks
return { 
blend_mode=additive and core.particles.BLEND_SHINY or nil,
engine=core.particles.ENGINE_LINES,
generator = function()
	local p = table.remove(points, 1)

	return {
		life = life, trail=p.prev,
		size = p.size, sizev = 0, sizea = 0,

		x = p.x, xv = 0, xa = 0,
		y = p.y, yv = 0, ya = 0,
		dir = p.dir, dirv = 0, dira = 0,
		vel = p.vel, velv = 0, vela = 0,

		r = rng.float(rm, rM), rv = 0, ra = 0,
		g = rng.float(gm, gM), gv = 0, ga = 0,
		b = rng.float(bm, bM), bv = 0, ba = 0,
		a = rng.float(am, aM), av = 0, aa = -0.001,
	}
end, },
function(self)
	if nbp > 0 then
		self.ps:emit(36)
		nbp = nbp - 36
	end
end,
nbp, "particles_images/beam"

end
