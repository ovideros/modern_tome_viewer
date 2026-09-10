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

name = _t"Children of Garkul, Unite!"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t"All the few remaining orcs of the mainland have been captured by Sunwall and their western allies."
	desc[#desc+1] = _t"To ensure a future, any future, for our race they must be freed."
	desc[#desc+1] = _t""
	desc[#desc+1] = _t"The internment camp is located somewhere to the north. The orcs are subdued into obedience by a powerful #{halfling}# psionic, Mindwall, and guarded by elite Sunwall troops."
	desc[#desc+1] = _t"Mindwall must be taken care of and the prides set free."
	desc[#desc+1] = _t""
	desc[#desc+1] = _t"But #{bold}#BEFORE#{normal}# that you should go and destroy the Sunwall Observatory to the east, as our spies have found a way to resist Mindwall's psionic powers which requries #{italic}#ingredients#{normal}# from there."
	desc[#desc+1] = _t""
	if self:isStatus(self.COMPLETED, "mindwall") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* You have destroyed Mindwall body but he managed to split his mind into many pieces and taken direct control of the subdued orcs. Destroy the pillars in each level four other levels.#WHITE#"
	end
	if self:isStatus(self.COMPLETED, "vor-pride") then desc[#desc+1] = _t"#LIGHT_GREEN#* You have freed all the Vor Pride orcs.#WHITE#"
	else desc[#desc+1] = _t"#GREY#* You need to have free the Vor Pride orcs.#WHITE#" end
	if self:isStatus(self.COMPLETED, "rak-shor-pride") then desc[#desc+1] = _t"#LIGHT_GREEN#* You have freed all the Rak'Shor Pride orcs.#WHITE#"
	else desc[#desc+1] = _t"#GREY#* You need to have free the Rak'Shor Pride orcs.#WHITE#" end
	if self:isStatus(self.COMPLETED, "gorbat-pride") then desc[#desc+1] = _t"#LIGHT_GREEN#* You have freed all the Gorbat Pride orcs.#WHITE#"
	else desc[#desc+1] = _t"#GREY#* You need to have free the Gorbat Pride orcs.#WHITE#" end
	if self:isStatus(self.COMPLETED, "grushnak-pride") then desc[#desc+1] = _t"#LIGHT_GREEN#* You have freed all the Grushnak Pride orcs.#WHITE#"
	else desc[#desc+1] = _t"#GREY#* You need to have free the Grushnak Pride orcs.#WHITE#" end
	if self:isStatus(self.DONE) then
		desc[#desc+1] = _t"#LIGHT_GREEN#* The Pride is once again free and united.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	who:grantQuest("orcs+sunwall-observatory")
end

on_status_change = function(self, who, status, sub)
	if not self:isStatus(self.DONE) and self:isCompleted("mindwall") and self:isCompleted("vor-pride") and self:isCompleted("rak-shor-pride") and self:isCompleted("gorbat-pride") and self:isCompleted("grushnak-pride") then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		who:grantQuest("orcs+destroy-sunwall")
		world:gainAchievement("ORCS_DONE_FREED_PRIDES", who)

		if not game.zone.orcs_killed_by_player then
			world:gainAchievement("ORCS_FREE_ORCS_SAFE", who)
		end

		local ud = {}
		if not profile.mod.allow_build.orcs_campaign_mage then ud[#ud+1] = "orcs_campaign_mage" end
		if not profile.mod.allow_build.orcs_campaign_rogue then ud[#ud+1] = "orcs_campaign_rogue" end
		if #ud == 0 then
			game:setAllowedBuild("orcs_campaign_all_classes", true)
		else
			game:setAllowedBuild(rng.table(ud), true)
		end
	end
end
