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

function _M:defenseTurrets(lev)
	for i = 1, 8 + self.level.level * 2 do
		local f = nil
		local m = self.zone:makeEntity(self.level, "actor", {special_rarity="turret_rarity"}, nil, true)
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
function _M:generate()
	baseGenerator.generate(self)

	local p = game:getPlayer(true)
	if self.level.level >= 1 and self.level.level <= 5 then
		if not p:isQuestStatus("orcs+quarry", engine.Quest.DONE) then self:defenseTurrets(self.level.level) end
	end
end
