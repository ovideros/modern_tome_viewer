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

name = _t"Research. Tinker. Annihilate."
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t"Inside some of your foes you have found some intact pieces that give you new ideas."
	desc[#desc+1] = _t"Keep on killing mechanical contraptions or steam-related foes..."
	if self:isStatus(self.COMPLETED, "mecharachnid-flamethrower") then desc[#desc+1] = _t"#LIGHT_GREEN#* You destroyed a mecharachnid equiped with a flamethrower. Both those things could prove very useful.#WHITE#" end
	if self:isStatus(self.COMPLETED, "greater-hethugoroth") then desc[#desc+1] = _t"#LIGHT_GREEN#* You have studied the 'remains' of an greater or ultimate hethugoroth, providing new ideas for ways to annihilate with heat.#WHITE#" end
	if self:isStatus(self.COMPLETED, "ads") then desc[#desc+1] = _t"#LIGHT_GREEN#* The impressive Automated Defense System remains will prove very useful to create automated and self-deploying constructs.#WHITE#" end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted("mecharachnid-flamethrower") and self:isCompleted("greater-hethugoroth") and self:isCompleted("ads") then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		game:setAllowedBuild("tinker_annihilator", true)
	end
end
