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

name = _t"The Impossible Castle"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t[[You have discovered the entrance to a strange castle inside a huge book. The place seems to eat at your sanity but you feel drawn to it somehow...]]
	if self:isCompleted("binding1") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* You have closed a book of binding, it seems the whole castle had stabilized a little, there may be more books to close.#WHITE#"
	end
	if self:isCompleted("binding2") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* You have closed two books of binding, the castle is now stable and you should probably be able to access the last chapter.#WHITE#"
	end
	if self:isCompleted("kill") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* You have killed the Glass Golem and claimed the castle treasures for yourself!#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("kill") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
		end
	end
end
