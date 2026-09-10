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

local is_orc = function(npc, player) return player.type == "humanoid" and player.subtype == "orc" end
local is_yeti = function(npc, player) return player.type == "giant" and player.subtype == "yeti" end
local is_whitehoof = function(npc, player) return player.type == "undead" and player.subtype == "minotaur" end

local on_end = function(npc, player)
	if player:hasQuest("orcs+voyage") then
		player:setQuestStatus("orcs+voyage", engine.Quest.COMPLETED)
	else
		player:grantQuest("orcs+amakthel")
	end
end

newChat{ id="welcome",
	text = _t[[#LIGHT_GREEN#*Before you stands a tentaculous horror which you recognize for what it truly is. A living #{bold}#Sher'Tul#{normal}#!.*#WHITE#
Who are you, young creature, to stand up to a High Priest of Amakthel? Do you not know that you are before a servant of the Almighty Creator, the Sunfather, the God of Gods, Lord of all Eyal? In the millenia I have lived I have killed whole races like yourself. I have even wrenched the spirits of immortal gods from this world. So who are you, little one, who dare defy me?]],
	answers = {
		{("I... am %s, of the seed of Garkul the Devourer. Garkul taught us to fight legends, and to flinch not from even the most desperate deed. Here and now I face you without fear or hesitation, for the spirit of Garkul burns within me. And in his name I will #{bold}#break#{normal}# you!"):tformat(player.name), cond=is_orc, action=on_end},
		{("I... am %s, though I lack my original body my mind is bound to Garkul the Devourer. Garkul taught us to fight legends, and to flinch not from even the most desperate deed. Here and now I face you without fear or hesitation, for the spirit of Garkul burns within me. And in his name I will #{bold}#break#{normal}# you!"):tformat(player.name), cond=is_yeti, action=on_end},
		{("I... am %s and I am not mortal! Garkul taught the orcs to fight legends, and to flinch not from even the most desperate deed. We learned that from them! Here and now I face you without fear or hesitation, for cold touch of undeath is within me. And I will #{bold}#break#{normal}# you!"):tformat(player.name), cond=is_whitehoof, action=on_end},
		{("I... am %s. Here and now I face you without fear or hesitation, for the utter determination burns within me. And I will #{bold}#break#{normal}# you!"):tformat(player.name), cond=function(npc, player) return not is_orc(npc, player) and not is_yeti(npc, player) and not is_whitehoof(npc, player) end, action=on_end},
	}
}

return "welcome"
