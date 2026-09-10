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

dir = math.atan2(proj_y-src_y, proj_x-src_x)--math.atan2(ty, tx)
red = red or rng.normal(176, 64)
blue = blue or rng.normal(176, 48) / 2 + 128 - red / 2
green = green or rng.range(-30, 30) + (red + blue)/3
origred = red
origblue = blue

return { generator = function()
	local radius = 0
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local ad = rng.float(0, 360)
	local a = math.rad(ad)
	local ar = -dir + a
	local x0 = math.cos(ar)
	local y0 = math.sin(ar)
	local r = 3/2 * math.min(4*math.sqrt(17/16 - x0^2)/math.sqrt(17), 1/2/y0^2) * sradius * math.sqrt(rng.float(0,1)) * 0.8 --sradius / 2 * rng.float(0,1) * math.min(1/4 + math.cos(ar)/4 + 3/2*math.tan(ar)^2, 1/2/(math.abs(math.sin(ar))^3/2)) * (2 - math.cos(ar))/2  * math.sqrt(cos(ar)^2+1)
	local y1 = y0 * (1/2 + x0/4)
	r = r * math.sqrt(x0 ^ 2 + y1^2)
	a = dir + math.atan2(y1, x0) + math.pi
	local x = r * math.cos(a)
	local y = r * math.sin(a)
	local bx = math.floor(x / engine.Map.tile_w)
	local by = math.floor(y / engine.Map.tile_h)
	local static = rng.percent(40)
	
	--magic! changes new particles
	red = (red + rng.normal(0, 4)) * 0.99 + origred * 0.01
	blue = (blue + rng.normal(0, 4)) * 0.99 + origblue * 0.01
	
	return {
		trail = 1,
		life = 6,
		size = 4, sizev = 0, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = dir + math.pi, dirv = 0, dira = 0,
		vel = sradius / 4 / 6, velv = sradius / 6 / 6, vela = 0,

		-- additive doesn't apply alpha
		r = (red + rng.range(-30, 30))/255,   rv = 0, ra = 0,
		g = (green + rng.range(-30, 30))/255,   gv = 0, ga = 0,
		b = (blue + rng.range(-30, 30))/255,      bv = 0, ba = 0,
		a = rng.range(64, 96)/255,    av = 0, aa = 0.005,
	}
end, },
function(self)
	self.ps:emit(60)
end,
60*6,
"particle_cloud"
