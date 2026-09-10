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

name = _t"Hunter, Quarry"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t"The Steam Quarry is a strategic zone for the Atmos tribe, it provides them with much of their energy needs."
	desc[#desc+1] = _t"If you are to assault the Palace of Fumes you need to cut that supply off. Destroy the three giant steam valves to make the Palace vulnerable."
	if self:isStatus(self.COMPLETED, "valve1") then desc[#desc+1] = _t"#LIGHT_GREEN#* The first valve has been destroyed.#WHITE#" end
	if self:isStatus(self.COMPLETED, "valve2") then desc[#desc+1] = _t"#LIGHT_GREEN#* The second valve has been destroyed.#WHITE#" end
	if self:isStatus(self.COMPLETED, "valve3") then desc[#desc+1] = _t"#LIGHT_GREEN#* The third valve has been destroyed.#WHITE#" end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted("valve1") and self:isCompleted("valve2") and self:isCompleted("valve3") then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		who:grantQuest("orcs+palace")
		game.state:storesRestock()
	end
end
