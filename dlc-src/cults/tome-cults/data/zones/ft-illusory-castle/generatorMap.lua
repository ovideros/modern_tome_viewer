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

function _M:init(zone, map, level, data)
	baseGenerator.init(self, zone, map, level)
	self.data = data
	self.grid_list = zone.grid_list
end

function _M:getRandomPosition(rspots, kind)
	local spots = {}
	for _, spot in ipairs(rspots) do if spot.type == "book" and spot.subtype == kind and not spot.level_used then spots[#spots+1] = spot end end

	if #spots > 0 then
		local spot = rng.table(spots)
		spot.level_used = true
		return {spot.x, spot.y}
	end

	local dx, dy
	local tries = 1000
	while tries > 0 do
		dx, dy = rng.range(1, self.map.w - 1), rng.range(1, self.map.h - 1)

		if not self.map:checkEntity(dx, dy, Map.TERRAIN, "block_move") and
				not self.map:checkEntity(dx, dy, Map.TERRAIN, "change_level") and
				not self.map.room_map[dx][dy].special and
				not (self.map(dx, dy, Map.TERRAIN).type == "book") then
			return {dx, dy}
		end

		tries = tries - 1
	end
end

function _M:generate(lev, old_lev)
	local zone = self.zone
	local level = self.level
	local map = self.map

	for i = 0, map.w - 1 do for j = 0, map.h - 1 do
		map(i, j, map.TERRAIN, self:resolve("exterior_wall"))
	end end

	local generator = require
	local innermap = self.zone.map_class.new(level.data.inner_width, level.data.inner_height)
	local innergen = require(self.data.realclass).new(zone, innermap, level, self.data)
	self.map = innermap
	local ux, uy, dx, dy, rspots = innergen:generate(lev, old_lev)
	rspots = rspots or {}
	self.map = map

	local offx, offy = math.floor((level.data.width - level.data.inner_width) / 2), math.floor((level.data.height - level.data.inner_height) / 2)
	map:import(innermap, offx, offy)
	ux, uy = ux + offx, uy + offy
	dx, dy = dx + offx, dy + offy
	for _, spot in ipairs(rspots) do spot.x, spot.y = spot.x + offx, spot.y + offy end

	-- Place books of binding
	if self.data.last_branch_level then
		local spot = self:getRandomPosition(rspots, "binding")
		if not spot then level.force_recreate = true return ux, uy, dx, dy, rspots end
		rspots[#rspots+1] = {x=spot[1], y=spot[2], check_connectivity=not level.data.no_level_connectivity and "entrance" or nil}

		local book = self:resolve("book_binding")
		map(spot[1], spot[2], map.TERRAIN, book)
	end

	-- Put no teleports
	if self.data.last_main_level then
		for i = 0, map.w - 1 do for j = 0, map.h - 1 do
			local g = map(i, j, map.TERRAIN)
			if g.define_as ~= "SOLID_FLOOR" then
				game.level.map.attrs(i, j, "no_teleport", true)
			end
		end end
	end

	local stairs = zone.stairs_defs[lev]
	for i, stair_to in ipairs(stairs) do
		local spot = self:getRandomPosition(rspots, "chapter")
		if not spot then level.force_recreate = true return ux, uy, dx, dy, rspots end
		rspots[#rspots+1] = {x=spot[1], y=spot[2], check_connectivity=not level.data.no_level_connectivity and "entrance" or nil}

		local stair = self:resolve("base_stair")
		stair.name = ('shortcut to chapter "%s"'):tformat(zone.levels_names[stair_to])
		if config.settings.cheat then
			stair.name = stair.name..("[actual level %d, on branch %s]"):tformat(stair_to, _t(zone.paths_rev[stair_to], "ft-illusory-castle branch name"))
		end
		stair.change_level = stair_to - lev

		if self.data.guard_path_to == stair_to then
			stair.change_level_check = function(self)
				if game.zone.disabled_sidebranch < 2 then
					require("engine.ui.Dialog"):simplePopup(_t"Illusory Castle", _t"Something blocks the way to this chapter...")
					return true
				end
			end
		end

		map(spot[1], spot[2], map.TERRAIN, stair)
	end

	return ux, uy, dx, dy, rspots
end
