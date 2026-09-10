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

name = _t"Of Steamwork and Pain"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t"To win the war you must help the Pride by striking a blow to the giant's morale and supply lines.\n"
	if self:isCompleted("vaporous-emporium") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* You have assaulted the Vaporous Emporium, crushing the morale of the Atmos tribe.#WHITE#"
	else
		desc[#desc+1] = _t"#SLATE#* You must assault the Vaporous Emporium to crush the morale of the Atmos tribe!#WHITE#"
	end
	if self:isCompleted("yeti-cave") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* You have explored the yeti cave and vanquished the Yeti Patriarch.#WHITE#"
	else
		desc[#desc+1] = _t"#SLATE#* You must explore the Yeti Cave and destroy the patriarch!#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("yeti-cave") and self:isCompleted("vaporous-emporium") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			who:grantQuest("orcs+to-mainland")
		end
	end
end
