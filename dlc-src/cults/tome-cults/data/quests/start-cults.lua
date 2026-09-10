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

name = _t"The Worm That Devours"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t[[A huge mindless and corrupted worm is heading toward Kroshkkur!
It has to be stopped or the Sanctuary will fall, digested in the bowels of giant worm, its forbidden knowledge lost forever.]]
	if self:isCompleted("worm") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* You have destroyed the Worm's neural spine, preventing the doom of the Sanctuary.#WHITE#"
	elseif self:isFailed() then
		desc[#desc+1] = _t"#LIGHT_RED#* You have failed to destroy the Worm in time, the Sanctuary has been destroyed.#WHITE#"
	else
		desc[#desc+1] = _t"#SLATE#* You have to destroy the Worm's neural spine.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("worm") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			who:grantQuest(who.cults_race_start_quest)
		end
	else
		if status == engine.Quest.FAILED then
			local p = game:getPlayer(true)
			if p then
				p:unlearnTalent(p.T_TELEPORT_KROSHKKUR, 99)
			end
		end
	end
end
