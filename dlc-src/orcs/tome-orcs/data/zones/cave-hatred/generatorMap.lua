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

--- Create the stairs inside the level
function _M:makeStairsInside(lev, old_lev, rspots)
	local zone = self.zone
	local level = self.level
	local map = self.map
	local spots = table.clone(rspots, true)

	-- Put up stairs always in the middle and the bosses around
	local main_room = level:pickSpotFrom({type="room", subtype="main"}, spots)
	local ux, uy = main_room.x, main_room.y
	local dx, dy = ux, uy

	-- If by some strange luck it's not carved out, rebuild
	if not ux or not uy or map:checkEntity(ux, uy, Map.TERRAIN, "block_move") or map.room_map[ux][uy].special then level.force_recreate = true return ux, uy, dx, dy, rspots end
	self.map(ux, uy, Map.TERRAIN, self:resolve("up"))
	self.map.room_map[ux][uy].special = "exit"

	local shadows = {}
	shadows[#shadows+1] = zone:makeEntityByName(level, "actor", "SHADOW_PAIN")
	shadows[#shadows+1] = zone:makeEntityByName(level, "actor", "SHADOW_HATE")
	shadows[#shadows+1] = zone:makeEntityByName(level, "actor", "SHADOW_DESPAIR")
	shadows[#shadows+1] = zone:makeEntityByName(level, "actor", "SHADOW_REMORSE")
	shadows[#shadows+1] = zone:makeEntityByName(level, "actor", "SHADOW_GUILT")
	shadows[#shadows+1] = zone:makeEntityByName(level, "actor", "SHADOW_ANGER")

	while #shadows > 0 do
		local room = level:pickSpotRemoveFrom({type="room", subtype="side"}, spots)
		if not room then level.force_recreate = true return ux, uy, dx, dy, rspots end
		local shadow = rng.tableRemove(shadows)
		self:roomMapAddEntity(room.x, room.y, "actor", shadow)
	end

	return ux, uy, dx, dy, rspots
end
