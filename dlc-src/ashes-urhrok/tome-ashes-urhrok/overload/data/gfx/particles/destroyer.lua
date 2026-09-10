-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
	local ad = rng.range(0, 360)
	local a = math.rad(ad)
	local dir = math.rad(90)
	local r = rng.range(18, 22)
	local dirchance = rng.chance(2)
	local x = rng.range(-22, 10)
	local y = 16 - math.abs(math.sin(x / 16) * 8)

	return {
		trail = 1,
		life = rng.range(12, 22),
		size = rng.range(4, 12), sizev = -0.2, sizea = 0,

		x = x, xv = rng.float(-0.5,0.5), xa = 0,
		y = y, yv = rng.float(-2,-3), ya = 0,
		dir = dir, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = rng.float(0.5, 0.7),   rv = 0, ra = 0,
		g = rng.float(0.3, 0.5),   gv = 0, ga = 0,
		b = rng.float(0, 1),      bv = 0, ba = 0,
		a = rng.float(am or 0.4, aM or 1),    av = 0, aa = 0,
	}
end, },
function(self)
	self.ps:emit(4)
end,
40, "particles_images/fearscape_aura"
