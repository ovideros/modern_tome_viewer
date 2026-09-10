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

uberTalent{
	name = "Automated Reflex System",
	mode = "passive",
	no_npc_use = true,
	cooldown = 4,
	require = { special={desc=_t"Have gained the #{italic}#Matrix Style#{normal}# achievement with this or any previous character for the current difficulty & permadeath settings.", fct=function(self)
		local id = world:getCurrentAchievementDifficultyId(game, "ABASHED_EXPANSE_NO_BLAST")
		return world:hasAchievement(id)
	end} },
	info = function(self, t)
		return ([[A small automatic detection system is always looking for incoming projectiles, when one is about to hit you it injects drugs into your system to boost your reactivity, granting you a free turn.
		This effect can not happen more than once every 5 turns.]])
		:tformat()
	end,
}
