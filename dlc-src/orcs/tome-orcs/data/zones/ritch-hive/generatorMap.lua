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

function _M:placeEgg()
	local check = function(x, y) return self.map:checkEntity(x, y, Map.TERRAIN, "define_as") == "UNDERGROUND_SAND" end

	local x, y = rng.range(2, self.map.w - 3), rng.range(2, self.map.h - 3)
	local tries = 0
	while not check(x, y) and tries < 100 do
		x, y = rng.range(2, self.map.w - 3), rng.range(2, self.map.h - 3)
		tries = tries + 1
	end
	if tries < 100 then
		local o = self.zone:makeEntityByName(self.level, "object", "SAND_RITCH_EGGS")
		self.map:addObject(x, y, o)
	end
end

function _M:generate(lev, old_lev)
	local ux, uy, dx, dy, spots = baseGenerator.generate(self, lev, old_lev)
	for i = 1, 14 do -- make sure there are enough eggs
		self:placeEgg()
	end

	return ux, uy, dx, dy, spots
end