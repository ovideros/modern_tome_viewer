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

name = _t"A View From The Gallery"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t[[You are Grung, a halfling from the Age of Haze. You must gather food or die but outside there is a terrible war being fought.
A war between incomprehensible beings for incomprehensible reasons. All you can hope to do is gather food while avoiding to get crushed.]]
	if self:isCompleted("food") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* You have gathered enough food for a few day for your tribe, go back home now.#WHITE#"
	end
	if self:isCompleted() then
		desc[#desc+1] = _t"#LIGHT_GREEN#* You have came home with the food.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
	end
end
