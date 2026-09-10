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

rm, rM = rm or 0.8, rM or 1
gm, gM = gm or 0.8, gM or 1
bm, bM = bm or 0, bM or 0
am, aM = am or 1, aM or 1

-- Make the 2 main forks
local warpin = warpin or false
local distortion_factor = 1 + (distortion_factor or 0.1)
local life = life or 30
local fullradius = (radius or 5) * engine.Map.tile_w
local basespeed = fullradius / life
local points = {}

for fork_i = 1, nb_circles or 5 do
	local size = size or 2
	local r = warpin and fullradius or 10
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
blend_mode=additive and core.particles.BLEND_ADDITIVE or nil,
engine=core.particles.ENGINE_LINES,
generator = function()
	local p = table.remove(points, 1)
	local star = false
	local density = 1 --math.cos(1)

	return {
		life = life, trail=p.prev,
		size = p.size, sizev = 0, sizea = 0,

		x = p.x, xv = 0, xa = 0,
		y = p.y, yv = 0, ya = 0,
		dir = p.dir + (warpin and math.rad(90) or 0), dirv = 0, dira = 0,
		vel = p.vel, velv = 0, vela = 0,

		r = (star and rng.range(130, 255) or rng.range(5,15))/255,  					rv = -1/255, ra = 0,
		g = (star and rng.range(80, 255) or rng.range(5,15))/255,  						gv = -1/255, ga = 0,
		b = (star and rng.range(130, 255) or rng.range(25,35))/255, 					bv = -1/255, ba = 0,
		a = star and (110 + 110*density)/255 or rng.range(110, 220)/255 * density, 		av = 0, aa = 0,
	}
end, },
function(self)
	if nbp > 0 then
		self.ps:emit(36)
		nbp = nbp - 36
	end
end,
nbp, "particles_images/beam"


--[[

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

base_size = 32

return { generator = function()
	local ad = rng.float(0, 360)
	local dir = math.rad(ad)
	local star = rng.percent(4)
	local density = math.cos(1)

	return {
		x = math.cos(dir) * 5, y = math.sin(dir) * 5,
		dir = dir, vel = rng.float(2, 5),

		life = rng.range(20, 30),
		size = rng.range(3, 7), sizev = 0, sizea = 0,

		r = (star and rng.range(130, 255) or rng.range(5,15))/255,  					rv = -1/255, ra = 0,
		g = (star and rng.range(80, 255) or rng.range(5,15))/255,  						gv = -1/255, ga = 0,
		b = (star and rng.range(130, 255) or rng.range(25,35))/255, 					bv = -1/255, ba = 0,
		a = star and (110 + 110*density)/255 or rng.range(110, 220)/255 * density, 		av = 0, aa = 0,
	}
end, },
function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 6 then
		self.ps:emit(100)
	end
end,
600
]]