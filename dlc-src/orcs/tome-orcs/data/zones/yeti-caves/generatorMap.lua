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

function _M:generate(lev, old_lev)
	local ux, uy, dx, dy, spots = baseGenerator.generate(self, lev, old_lev)

	-- Locate all possible walls
	if not self.level.lore_set then
		local spots = {}
		local map = self.map
		for i = 1, map.w - 2 do for j = 0, map.h - 2 do 
			if
			  map:checkEntity(i, j, map.TERRAIN, "type") == "wall" and
			  map:checkEntity(i - 1, j, map.TERRAIN, "type") == "wall" and
			  map:checkEntity(i + 1, j, map.TERRAIN, "type") == "wall" and
			  map:checkEntity(i, j + 1, map.TERRAIN, "type") == "floor" and
			  map:checkEntity(i - 1, j + 1, map.TERRAIN, "type") == "floor" and
			  map:checkEntity(i + 1, j + 1, map.TERRAIN, "type") == "floor" then
			  	spots[#spots+1] = {x=i, y=j}
			end
		end end

		if #spots > 0 then
			local spot = rng.table(spots)
			local g = self:resolve("MURAL_PAINTING"..lev, nil, true)
			if g then
				map(spot.x, spot.y, map.TERRAIN, g)
				self.level.lore_set = true -- this is to prevent it being added multiple times because Cavern generator calls its own :generate recursively
			end
		end
	end

	return ux, uy, dx, dy, spots
end