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

name = _t"The Deconstruction of Falling Stars"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t[[The people of the sunwall have lingered on this land for too long and now they are spreading their control to all the mainland. This must not be allowed!
With the help of their newfound allies in the west they keep a permanent guard over the farportal. The portal must be permanently destroyed to prevent reinforcements.
The leader of the Sunwall, High Sun Paladin Aeryn must be punished for her crimes against the Prides.]]
	if self:isStatus(self.DONE) then
		desc[#desc+1] = _t"#LIGHT_GREEN#* You have killed Aeryn, making sure no more troops will come from the west.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		who:grantQuest("orcs+quarry")
		world:gainAchievement("ORCS_DONE_SUNWALL", who)
		
		if not who:isQuestStatus("orcs+ritch-hive", engine.Quest.DONE) and not who:isQuestStatus("orcs+sunwall-observatory", engine.Quest.DONE) then world:gainAchievement("ORCS_GATES_RUSH", who) end

		game:onLevelLoad("wilderness-1", function(zone, level)
			local spot = level:pickSpot{type="questpop", subtype="orcs+gem"}
			local g = zone:makeEntityByName(level, "terrain", "GEM")
			if g and spot then
				zone:addEntity(level, g, "terrain", spot.x, spot.y)
				game.nicer_tiles:updateAround(level, spot.x, spot.y)
			end
		end)

		game.state:storesRestock()
	end
end
