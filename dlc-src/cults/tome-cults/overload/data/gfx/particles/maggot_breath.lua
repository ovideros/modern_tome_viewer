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

local life = 12
local aa = -1 / life / life

local spread = spread or 55/2
local radius = radius or 6

local dir = math.deg(math.atan2(ty, tx))

local nb = 0
return { generator = function()
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local ad = rng.float(dir - spread, dir + spread)
	local a = math.rad(ad)
	local r = rng.range(64, sradius)
	local x = r * math.cos(a)
	local y = r * math.sin(a)
	
	return {
		life = life,
		size = rng.range(100, 256), sizev = 0, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = 1, rv = 0, ra = 0,
		g = 1, gv = 0, ga = 0,
		b = 1, bv = 0, ba = 0,
		a = 1, av = 0, aa = aa,
	}
end, },
function(self)
	nb = nb + 1
	if nb <= 5 then
		self.ps:emit(5)
	end
end,
25, "particles_images/maggot_breath", true
