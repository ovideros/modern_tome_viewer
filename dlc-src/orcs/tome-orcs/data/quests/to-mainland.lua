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

name = _t"You Shall Pass!"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t"The Atmos tribe is not our sole problem. The Sunwall as grown in strength since the Scourge from the West came and murdered the other Prides leaders."
	desc[#desc+1] = _t"Our brothers on the mainland lay enslaved, but before we free them you must secure a way to the mainland."
	desc[#desc+1] = _t"Go to the sunwall outpost. Show them the wrath of Garkul, show no mercy for they have none for us.\n"
	if self:isStatus(self.DONE) then
		desc[#desc+1] = _t"#LIGHT_GREEN#* You have destroyed the sunwall outpost, and secured a way to the mainland.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		who:grantQuest("orcs+kill-dominion")
		who:grantQuest("orcs+ritch-hive")
		world:gainAchievement("ORCS_DONE_OUTPOST", who)
		require("engine.ui.Dialog"):simpleLongPopup(_t"To the mainland!", _t[[The way to the mainland is now clear.
Travel there using the bridge on the worldmap.]], 500)

		game:onLevelLoad("wilderness-1", function(zone, level)
			local g = game.zone:makeEntityByName(level, "terrain", "MAINLAND_BRIDGE")
			local spot = level:pickSpot{type="questpop", subtype="mainland-bridge"}
			game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
			game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
			game.state:locationRevealAround(spot.x, spot.y)
		end)

		game.state:storesRestock()
	end
end
