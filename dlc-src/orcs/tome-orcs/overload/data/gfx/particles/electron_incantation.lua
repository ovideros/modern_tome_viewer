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

local radius = radius * base_size * 3.5
local max_life = 8
local life = max_life
local nb = 0

local r, g, b = 0.2, 0.5, 1
if type == "GALVANIC" then
	r, g, b = 1, 0.5, 0.2
elseif type == "TERRENE" then
	r, g, b = 0.2, 1, 0.5
end

-- Populate the beam based on the forks
return { blend_mode=core.particles.BLEND_SHINY, generator = function()
	return {
		life = life,
		size = 1, sizev = radius/life, sizea = 0,

		x = 0, xv = 0, xa = 0,
		y = 0, yv = 0, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = r, rv = 0, ra = 0,
		g = g, gv = 0, ga = 0,
		b = b, bv = 0, ba = 0,
		a = 1, av = -0.8/life, aa = 0,
	}
end, },
function(self)
	nb = nb + 1
	if nb <= max_life/2 then
		self.ps:emit(1)
		life = life - 1
	end
end,
10,
"particle_torus"
