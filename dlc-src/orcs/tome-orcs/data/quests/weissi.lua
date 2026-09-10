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

name = _t"Mystery of the Yetis"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t"You have found a bit of preserved yeti muscle, probably somebody somewhere will be interested."
	desc[#desc+1] = _t""
	if self:isCompleted("for") then
		desc[#desc+1] = _t"For each yeti muscle you return to the psy-machines in the ruins of a lost city you will gain a great reward."
		desc[#desc+1] = _t""
	end
	if self:isStatus(self.DONE) then
		desc[#desc+1] = _t"#LIGHT_GREEN#* You have helped the strange psionic machines and got rewards out of them. You still feel like somehow you did wrong..."
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
	end
end
