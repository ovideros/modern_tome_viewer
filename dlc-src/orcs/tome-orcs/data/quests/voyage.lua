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

name = _t"Voyage to the Center of Eyal"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t"In the Palace of Fumes you found a geothermal vent that digs deep into the planet's core."
	desc[#desc+1] = _t"Strange mutated giants came out. You must find the source of those titans!"
	if self:isStatus(self.DONE) then desc[#desc+1] = _t"#LIGHT_GREEN#* Travelling deep within Eyal you found the source of all corruptions: the dead god #{bold}##CRIMSON#Amakthel#LAST##{normal}#.#WHITE#" end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		who:grantQuest("orcs+amakthel")
	end
end
