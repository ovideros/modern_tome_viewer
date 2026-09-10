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

name = _t"I've a feeling we're not on Eyal anymore"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t[[Somehow you did not recall out as usual but instead ended up on a sadly familiar area.
You are back in the Fearscape. Back and with a welcome committee.

You must find a way to escape, again.

]]
	if self:isCompleted("ambush") then
		desc[#desc+1] = _t[[#LIGHT_GREEN#* You have found your way out of the primary ambush.#WHITE#]]
	end
	if self:isCompleted("boss") then
		desc[#desc+1] = _t[[#LIGHT_GREEN#* You have destroyed Rogroth the Eater of Souls and made your escape possible. Flee!#WHITE#]]
	else
		desc[#desc+1] = _t[[#SLATE#* Find a way back to Eyal.#WHITE#]]
	end
	if self:isCompleted() then
		desc[#desc+1] = _t[[#LIGHT_GREEN#* You have escaped the Anteroom of Agony.#WHITE#]]
		desc[#desc+1] = _t[[#LIGHT_GREEN#* #WHITE#]]
	end

	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
	end
end
