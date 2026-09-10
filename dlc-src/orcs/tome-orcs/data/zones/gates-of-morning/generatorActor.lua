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

function _M:ritchInvade(lev)
	local level = self.level
	local spots = {}
	for i = 1, 30 + level.level * 2 do
		local x = rng.range(6, level.map.w - 7)
		local y = rng.range(6, level.map.w - 7)
		local range = rng.range(4, 6)
		local ok = true

		core.fov.calc_circle(x, y, level.map.w, level.map.h, range, function() end, function(_, px, py)
			if level.map:checkAllEntities(px, py, "change_level") or level.map:checkAllEntities(px, py, "special") or level.map.attrs(px, py, "no_teleport") then
				ok = false
			end
		end, nil)

		if ok then
			self.zone:doQuake(range, x, y, function(tx, ty)
				return not level.map.attrs(tx, ty, "no_teleport") and not level.map:checkAllEntities(tx, ty, "change_level") and level.map(tx, ty, engine.Map.TERRAIN)
			end)

			local ok = not level.map.attrs(x, y, "no_teleport")
			for _, coord in pairs(util.adjacentCoords(x, y)) do
				if level.map.attrs(coord[1], coord[2], "no_teleport") then ok = false break end
			end

			if ok then
				spots[#spots+1] = {x=x,y=y}
			end
		end
	end
	for _, spot in ipairs(spots) do
		local x, y = spot.x, spot.y
		local gc = self.zone.grid_list.CRACKS
		local gf = self.zone.grid_list.FLOOR
		level.map(x, y, level.map.TERRAIN, gc)
		level.map(x-1, y-1, level.map.TERRAIN, gf)
		level.map(x-1, y, level.map.TERRAIN, gf)
		level.map(x-1, y+1, level.map.TERRAIN, gf)
		level.map(x+1, y-1, level.map.TERRAIN, gf)
		level.map(x+1, y, level.map.TERRAIN, gf)
		level.map(x+1, y+1, level.map.TERRAIN, gf)
		level.map(x, y-1, level.map.TERRAIN, gf)
		level.map(x, y+1, level.map.TERRAIN, gf)

		for i = 1, 3 do
			local mx, my = util.findFreeGrid(x, y, 3, true, {[Map.ACTOR]=true})
			local m = self.zone:makeEntity(self.level, "actor", {special_rarity="ritch_rarity"}, nil, true)
			if m and mx then
				self.zone:addEntity(self.level, m, "actor", mx, my)
			end

		end
	end
end

function _M:placeElite()
	local f = nil
	local m = self.zone:makeEntity(self.level, "actor", {random_boss=true}, nil, true)
	if m then
		local x, y = rng.range(0, self.level.map.w-1), rng.range(0, self.level.map.h-1)
		local tries = 0
		while (not m:canMove(x, y) or (self.map.room_map[x][y] and self.map.room_map[x][y].special)) and tries < 100 do
			x, y = rng.range(0, self.level.map.w-1), rng.range(0, self.level.map.h-1)
			tries = tries + 1
		end
		if tries < 100 then
			self.zone:addEntity(self.level, m, "actor", x, y)
		end
	end
end

function _M:defenseOrbs(lev)
	for i = 1, 8 + self.level.level * 3 do
		local f = nil
		local m = self.zone:makeEntity(self.level, "actor", {special_rarity="orb_rarity"}, nil, true)
		if m then
			local x, y = rng.range(0, self.level.map.w-1), rng.range(0, self.level.map.h-1)
			local tries = 0
			while (not m:canMove(x, y) or (self.map.room_map[x][y] and self.map.room_map[x][y].special)) and tries < 100 do
				x, y = rng.range(0, self.level.map.w-1), rng.range(0, self.level.map.h-1)
				tries = tries + 1
			end
			if tries < 100 then
				self.zone:addEntity(self.level, m, "actor", x, y)
			end
		end
	end
end

function _M:ritchNotInvade(lev)
	for i = 1, 10 do self:placeElite() end
end

function _M:generate()
	baseGenerator.generate(self)

	local p = game:getPlayer(true)
	if self.level.level >= 2 and self.level.level <= 4 then
		if p:isQuestStatus("orcs+ritch-hive", engine.Quest.DONE) then self:ritchInvade(lev) end

		if not p:isQuestStatus("orcs+ritch-hive", engine.Quest.DONE) then self:ritchNotInvade(self.level.level) end

		if not p:isQuestStatus("orcs+sunwall-observatory", engine.Quest.DONE) then self:defenseOrbs(self.level.level) end
	end
end
