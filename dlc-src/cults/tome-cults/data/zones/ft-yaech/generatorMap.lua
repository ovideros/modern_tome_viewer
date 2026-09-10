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

function _M:generate(lev, old_lev)
	local ux, uy, dx, dy, rspots = baseGenerator.generate(self, lev, old_lev)

	local zone = self.zone
	local level = self.level
	local map = self.map
	local spots = table.clone(rspots, true)

	for i = 1, 3 do
		local room = level:pickSpotRemoveFrom({type="room", subtype="side"}, spots)
		if not room then level.force_recreate = true return ux, uy, dx, dy, rspots end
		map(room.x, room.y, map.TERRAIN, self:resolve('BOOK_OF_BINDING', nil, true))
	end

	return ux, uy, dx, dy, rspots
end
