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

newChat{ id="welcome",
	text = _t[[#LIGHT_GREEN#*As you open the door to the shop, you are greeted by a pair of Steam Giant guards, staring at you and holding their steamguns tightly, at the ready but not aimed at you.*#WHITE#
No sudden moves, @playername@. Kaltor's orders are to consider you a customer for now. Try anything foolish, and you'll be a live demonstration for his newest guns instead.  Understand?]],
	answers = {
		{_t"I have gold, you have equipment. This doesn't need to be any more complicated than that.", jump="ok"},
		{_t"Those are some pretty fancy guns. Think it'll be hard to get your blood out of the gears?", jump="fight"},
	}
}

newChat{ id="ok",
	text = _t[[#LIGHT_GREEN#*She smiles, relieved but also slightly disappointed.*#WHITE#
Couldn't have said it better myself. Come on in - and try not to scare the other patrons.]],
	answers = {
		{_t"[enter]"},
	}
}

newChat{ id="fight",
	text = _t[[Good luck with that, savage.
#LIGHT_GREEN#*She smirks, and pulls a cord on the wall beside her as her and her partner duck behind cover; a loud bell rings, and you hear a commotion from further inside the shop.*#WHITE#]],
	answers = {
		{_t"[fight]", action=function(npc, player)
			engine.Faction:setFactionReaction("kaltor-shop", player.faction, -100, true)
		end},
	}
}

return "welcome"
