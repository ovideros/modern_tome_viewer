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

name = _t"The Grumpy Shopowner"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t"Kaltor's shop seems to be nearby in the mountain. Maybe it could be interesting to pay him a visit?"
	desc[#desc+1] = _t"He does sound well armed, though, so be prepared as it is likely very dangerous."
	desc[#desc+1] = _t"So maybe take some time to plan the raid."
	if self:isStatus(self.DONE) then desc[#desc+1] = _t"#LIGHT_GREEN#* You have disposed of Kaltor, the loot is yours!#WHITE#" end
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	-- Reveal entrances
	game:onLevelLoad("wilderness-1", function(zone, level)
		local g = game.zone:makeEntityByName(level, "terrain", "KALTOR_SHOP")
		local spot = level:pickSpot{type="questpop", subtype="kaltor-shop"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
		game.state:locationRevealAround(spot.x, spot.y)
	end)
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
	end
end

attacked = function(self)
	if game.zone.attack_poped then return end
	game.zone.attack_poped = true

	local g = game.zone:makeEntityByName(game.level, "terrain", "FLOOR")
	while true do
		local spot = game.level:pickSpotRemove{type="event", subtype="superguard"}
		if not spot then break end
		game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
	end

	game.bignews:saySimple(60, "#PURPLE#You heard a loud noise!")
end
