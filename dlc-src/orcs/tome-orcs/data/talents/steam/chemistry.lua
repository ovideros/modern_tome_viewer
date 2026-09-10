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

newTalent{
	name = "Therapeutics",
	type = {"steamtech/chemistry",1},
	require = steamreq1,
	points = 5,
	steam = 0,
	mode = "passive",
	no_unlearn_last = true,
	no_npc_use = true,
	on_levelup_close = craft_levelup,
	autolearn_talent = "T_CREATE_TINKER",
	info = function(self, t)
		return ([[Allows you to create therapeutic tinkers of level %d.
		You will learn a new schematic at level 1.
		Each other talent level, you have a 20%% chance to learn one more random schematic, if you have not gained it by level 5 you are guaranteed it (unless all are known).
		%s]])
		:tformat(math.floor(self:getTalentLevel(t)), tinkers_list_for_craft(self, t))
	end,
}

newTalent{
	name = "Chemistry",
	type = {"steamtech/chemistry",2},
	require = steamreq2,
	points = 5,
	steam = 0,
	mode = "passive",
	no_unlearn_last = true,
	no_npc_use = true,
	on_levelup_close = craft_levelup,
	autolearn_talent = "T_CREATE_TINKER",
	info = function(self, t)
		return ([[Allows you to create chemical tinkers of level %d.
		You will learn a new schematic at level 1.
		Each other talent level, you have a 20%% chance to learn one more random schematic, if you have not gained it by level 5 you are guaranteed it (unless all are known).
		%s]])
		:tformat(math.floor(self:getTalentLevel(t)), tinkers_list_for_craft(self, t))
	end,
}

newTalent{
	name = "Explosives",
	type = {"steamtech/chemistry",3},
	require = steamreq3,
	points = 5,
	steam = 0,
	mode = "passive",
	no_unlearn_last = true,
	no_npc_use = true,
	on_levelup_close = craft_levelup,
	autolearn_talent = "T_CREATE_TINKER",
	info = function(self, t)
		return ([[Allows you to create explosive tinkers of level %d.
		You will learn a new schematic at level 1.
		Each other talent level, you have a 20%% chance to learn one more random schematic, if you have not gained it by level 5 you are guaranteed it (unless all are known).
		%s]])
		:tformat(math.floor(self:getTalentLevel(t)), tinkers_list_for_craft(self, t))
	end,
}

newTalent{
	name = "Steam Power",
	type = {"steamtech/chemistry",4},
	require = steamreq4,
	points = 5,
	steam = 0,
	mode = "passive",
	getPower = function(self, t)
		return self:combatTalentScale(t, 15, 60)
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_steampower", t.getPower(self, t))
	end,
	info = function(self, t)
		return ([[Increases the efficiency of all steamtech you operate, granting %d steampower.]])
		:tformat(t.getPower(self, t))
	end,
}
