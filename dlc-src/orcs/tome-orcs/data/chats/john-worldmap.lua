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

local jump = function(npc, player)
	npc:disappear()
	game:changeLevel(1, "orcs+cave-hatred")
end

newChat{ id="welcome",
	text = _t[[#LIGHT_GREEN#*As you approach you recognize Outpost Leader John. But there is a kind of terrible darkness, you can feel his hatred crystallize the air.*#WHITE#
@playername@. You malevolent creature! #{bold}#YOU KILLED HER! YOU MURDEROUS DOG!#{normal}#
You #{italic}#dare#{normal}# carry her ring around like a trophy! I can feel it on you. Give it back! DIE!]],
	answers = {
		{_t"Oh you liked that paladin lady? I loved killing her!", action=jump},
		{_t"She left me no choice; I had to protect #{bold}#my#{normal}# people.", action=jump},
		{_t("Whatever.", "chat_john-worldmap"), action=jump},
		{_t"What?", action=jump},
	}
}

return "welcome"
