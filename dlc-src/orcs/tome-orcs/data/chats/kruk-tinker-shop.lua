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
	text = _t[[Welcome @playername@ to my shop.]],
	answers = {
		{_t"Let me see your wares.", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player)
		end},
		{_t"I am looking for special training.", jump="training"},
		{_t("Sorry, I have to go!", "chat_kruk-tinker-shop")},
	}
}

newChat{ id="training",
	text = _t[[I can indeed offer some training (talent category Steamtech/Physics and Steamtech/Chemistry) for a fee of 100 gold pieces each.]],
	answers = {
		{_t"Please train me in physics.", action=function(npc, player)
			game.logPlayer(player, "The tinker spends some time with you, teaching you the basics of smithing.")
			player:incMoney(-100)
			player:learnTalentType("steamtech/physics", true)
			player:learnTalent(player.T_SMITH, true)
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 100 then return end
			if player:knowTalentType("steamtech/physics") then return end
			return true
		end},
		{_t"Please train me in chemistry.", action=function(npc, player)
			game.logPlayer(player, "The tinker spends some time with you, teaching you the basics of therapeutics.")
			player:incMoney(-100)
			player:learnTalentType("steamtech/chemistry", true)
			player:learnTalent(player.T_THERAPEUTICS, true)
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 100 then return end
			if player:knowTalentType("steamtech/chemistry") then return end
			return true
		end},
		{_t"No thanks."},
	}
}

return "welcome"
