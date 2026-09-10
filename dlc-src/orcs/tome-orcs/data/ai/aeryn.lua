-- TE4 - T-Engine 4
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

local Astar = require "engine.Astar"

newAI("orcs+move_aeryn_sun_flee", function(self, add_check)
	if not self.ai_state.aeryn_flee then
		-- Lets hook onto slazish fens pop since it's not used anyway
		local spot = game.level:pickSpot{type="pop-birth", subtype="slazish-fens"}
		local g = game.zone:makeEntityByName(game.level, "terrain", "TO_CAVES")
		game.level.map(spot.x, spot.y, engine.Map.TERRAIN, g)
		self.ai_state.aeryn_flee = spot
	end
	if self.ai_state.aeryn_flee then
		local a = Astar.new(game.level.map, self)
		local path = a:calc(self.x, self.y, self.ai_state.aeryn_flee.x, self.ai_state.aeryn_flee.y, nil, nil, add_check)
		if path then
			local moved = self:move(path[1].x, path[1].y)
			if self.x == self.ai_state.aeryn_flee.x and self.y == self.ai_state.aeryn_flee.y then
				self:removeEffect(self.EFF_AERYN_SUN_SHIELD, true, true)
				self:setTarget(nil)
				game:onTickEnd(function()
					game.level:removeEntity(self, true)
					game.zone.aeryn_repop = self
				end)
			end
			return moved
		end
	end
end)
