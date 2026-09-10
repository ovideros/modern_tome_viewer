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
	text = _t[[#DARK_SEA_GREEN##{italic}#As you move you suddenly find yourself entrapped in a hidden digestive sack that seems to void all your abilities!#{normal}##LAST#]],
	answers = {
		{_t"[try to kick your way out]", jump="tryagain", switch_npc=malyu},
		{_t"[try to cut your way out]", jump="tryagain", switch_npc=malyu},
		{_t"[try to shout your way out]", jump="tryagain", switch_npc=malyu},
	}
}

newChat{ id="tryagain",
	text = _t[[#DARK_SEA_GREEN##{italic}#As were starting to lose hope you hear some kind of cutting.#{normal}##LAST#
There's someone else in here?]],
	answers = {
		{_t"Who..what.. YES!", jump="saved"},
	}
}

newChat{ id="saved",
	text = _t[[#DARK_SEA_GREEN##{italic}#As the sack gets cut and you regain your mobility you see your savior is some kind of adventurer, she was probably eaten by the Godfeaster too.#{normal}##LAST#
This thing ate you too? Hey, at least you've got company. Name's Malyu, I've been stuck in here for a few days now and had to tough it out alone. I was about to go for this thing's brain when you showed up. What say we team up and get out of here together?
]],
	answers = {
		{_t"I am glad for the help, you saved me. Let's kill this thing and get out!", action=function(npc, player)
			game.zone:addEntity(game.level, npc, "actor", popx, popy)
			player:removeEffect(player.EFF_GODFEASTER_EVENT_BLINDED)
			npc.ai_state.tactic_leash = 20
			npc.faction = player.faction
			npc:forceLevelup(player.level)
			game.party:addMember(npc, {
				control="order",
				type="adventurer",
				title=_t"Malyu",
				orders = {target=true, leash=true},
				leave_level = function(self, def) game:onTickEnd(function()
					if game.to_re_add_actors and game.to_re_add_actors[self] then game.to_re_add_actors[self] = nil end
					game.party:removeMember(self)
					if self:attr("dead") then return end
					local chat = require("engine.Chat").new("cults+godfeaster-malyu-escaped", self, game.player)
					chat:invoke()
				end) end,
			})
		end},
	}
}

return "welcome"
