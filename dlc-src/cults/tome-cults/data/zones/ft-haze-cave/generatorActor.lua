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

function _M:generate()
	local nb_shertuls = 0
	local nb_food = 0
	if self.level.level == 1 then nb_shertuls = 0 nb_food = 10
	elseif self.level.level == 2 then nb_shertuls = 10 nb_food = 15
	elseif self.level.level == 3 then nb_shertuls = 2 nb_food = 20
	end
	for i = 1, nb_shertuls do self:generatePair() end
	for i = 1, nb_food do self:generateFood() end
end

function _M:generatePair()
	local m1 = self.zone:makeEntity(self.level, "actor", {special_rarity="civil_war_rarity"}, nil, true)
	local m2 = self.zone:makeEntity(self.level, "actor", {special_rarity="civil_war_rarity"}, nil, true)
	if m1 and m2 then
		local x1, y1 = rng.range(self.area.x1, self.area.x2), rng.range(self.area.y1, self.area.y2)
		local tries = 0
		while (not m1:canMove(x1, y1) or (self.map.room_map[x1][y1] and self.map.room_map[x1][y1].special)) and tries < 100 do
			x1, y1 = rng.range(self.area.x1, self.area.x2), rng.range(self.area.y1, self.area.y2)
			tries = tries + 1
		end
		if tries < 100 then
			self.zone:addEntity(self.level, m1, "actor", x1, y1)
			local x2, y2 = util.findFreeGrid(x1, y1, 5, true, {[Map.ACTOR]=true})
			if x2 then
				self.zone:addEntity(self.level, m2, "actor", x2, y2)
				m1.faction = "grung-neutral-1"
				m2.faction = "grung-neutral-2"
				m1.prime_target = m2
				m2.prime_target = m1
				if self.post_generation then self.post_generation(m1) end
			else
				m1:disappear(m1)
			end
		end
	end
end

function _M:generateFood()
	local m = self.zone:makeEntity(self.level, "actor", {special_rarity="grung_food_npc"}, nil, true)
	if m then
		local x, y = rng.range(self.area.x1, self.area.x2), rng.range(self.area.y1, self.area.y2)
		local tries = 0
		while (not m:canMove(x, y) or (self.map.room_map[x][y] and self.map.room_map[x][y].special)) and tries < 100 do
			x, y = rng.range(self.area.x1, self.area.x2), rng.range(self.area.y1, self.area.y2)
			tries = tries + 1
		end
		if tries < 100 then
			self.zone:addEntity(self.level, m, "actor", x, y)
		end
	end
end
