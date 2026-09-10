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

local Map = require "engine.Map"

-- Pop some booty matey !
function _M:generate()
	-- Put down chests, they are technically terrains and not items but it's logical to place them here I think
	for _, spot in ipairs(self.level.spots) do
		local og = self.level.map(spot.x, spot.y, Map.TERRAIN)
		if og.define_as == "FLOOR" and spot.type == "building" and spot.subtype == "building" and rng.percent(100) then
			local g = self.zone:makeEntityByName(self.level, "terrain", "CHEST")
			if g then
				self.zone:addEntity(self.level, g, "terrain", spot.x, spot.y)
			end
		end
	end

	return baseGenerator.generate(self)
end