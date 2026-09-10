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

require "engine.class"
local Map = require "engine.Map"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level, data)
	engine.Generator.init(self, zone, map, level)
	self.data = data
	self.grid_list = zone.grid_list
end

function _M:generate(lev, old_lev)
	for i = 0, self.map.w - 1 do
		for j = 0, self.map.h - 1 do
			self.map(i, j, Map.TERRAIN, self:resolve("wall"))
		end
	end

	local waters = self:makeGridList()
	local sands = self:makeGridList()
	local data = self.data
	local spread = data.spread or {10, 15}
	local stop_chance = data.stop_chance or 50

	local i = rng.range(spread[1], spread[2])
	while i < self.map.w - 3 do
		local start, stop, step = 0, self.map.h - 1, 1
		if rng.percent(50) then start, stop, step = self.map.h - 1, 0, -1 end
		for j = start, stop, step do
			if not waters:has(i-1, j) then self.map(i-1, j, Map.TERRAIN, self:resolve("floor")) end
			self.map(i, j, Map.TERRAIN, self:resolve("water"))
			self.map(i+1, j, Map.TERRAIN, self:resolve("water"))
			if not waters:has(i+2, j) then self.map(i+2, j, Map.TERRAIN, self:resolve("floor")) end
			waters:add(i, j) waters:add(i+1, j)
			sands:add(i-1, j) sands:add(i+2, j)
			if rng.chance(stop_chance) then break end
		end

		i = i + rng.range(spread[1], spread[2])
	end

	local j = rng.range(spread[1], spread[2])
	while j < self.map.h - 3 do
		local start, stop, step = 0, self.map.w - 1, 1
		if rng.percent(50) then start, stop, step = self.map.w - 1, 0, -1 end
		for i = start, stop, step do
			if not waters:has(i, j-1) then self.map(i, j-1, Map.TERRAIN, self:resolve("floor")) end
			self.map(i, j, Map.TERRAIN, self:resolve("water"))
			self.map(i, j+1, Map.TERRAIN, self:resolve("water"))
			if not waters:has(i, j+2) then self.map(i, j+2, Map.TERRAIN, self:resolve("floor")) end
			waters:add(i, j) waters:add(i, j+1)
			sands:add(i, j-1) sands:add(i, j+2)
			if rng.chance(stop_chance) then break end
		end

		j = j + rng.range(spread[1], spread[2])
	end

	return self:makeStairsInside(lev, old_lev, {}, sands)
end

--- Create the stairs inside the level
function _M:makeStairsInside(lev, old_lev, spots, sands)
	local list = sands:toList()

	-- Put down stairs
	local dx, dy
	if lev < self.zone.max_level or self.data.force_last_stair then
		local spot
		while true do
			spot = rng.tableRemove(list)
			dx, dy = spot.x, spot.y
			if not self.map:checkEntity(dx, dy, Map.TERRAIN, "block_move") and not self.map.room_map[dx][dy].special then
				self.map(dx, dy, Map.TERRAIN, self:resolve("down"))
				self.map.room_map[dx][dy].special = "exit"
				break
			end
		end
	end

	-- Put up stairs
	local spot
	local ux, uy
	while true do
		spot = rng.tableRemove(list)
		ux, uy = spot.x, spot.y
		if not self.map:checkEntity(ux, uy, Map.TERRAIN, "block_move") and not self.map.room_map[ux][uy].special then
			self.map(ux, uy, Map.TERRAIN, self:resolve("up"))
			self.map.room_map[ux][uy].special = "exit"
			break
		end
	end

	return ux, uy, dx, dy, spots
end
