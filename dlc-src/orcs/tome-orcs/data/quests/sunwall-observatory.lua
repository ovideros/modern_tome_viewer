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

name = _t"Stargazers"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t"Our ultimate goal on the mainland is to get rid of the Sunwall once and for all."
	desc[#desc+1] = _t"Our scouts have noticed the Gates of Morning is being reinforced with sun and moon orbs."
	desc[#desc+1] = _t""
	desc[#desc+1] = _t"Go to the Sunwall Observatory and destroy everything there to reduce their supplies."
	if self:isStatus(self.DONE) then
		desc[#desc+1] = _t"#LIGHT_GREEN#* You have destroyed the Observatory, the Gates of Morning defenses will be weakened.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		who:grantQuest("orcs+free-prides")
	end
end
