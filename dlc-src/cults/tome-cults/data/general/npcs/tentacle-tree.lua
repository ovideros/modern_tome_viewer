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

local Talents = require("engine.interface.ActorTalents")
load("/data/general/npcs/horror.lua")

newEntity{ base = "BASE_NPC_HORROR",
	name = "awoken tentacle tree", color=colors.DARK_GREEN,
	desc = _t"The tentacle tree has awakened!",
	image = "invis.png",
	level_range = {1, nil},
	is_tentacle_tree = 1,
	rank = 3,
	autolevel = "warriormage",
	max_life = 300, life_rating = 17,
	insanity_regen = 25,
	combat_armor = resolvers.levelup(30, 1, 1.5), combat_def = 0,
	combat = { dam=resolvers.levelup(resolvers.mbonus(100, 15), 1, 2.2), atk=500, apr=10 },

	never_move = 1,

	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },

	body = { MAINHAND=1, OFFHAND=1, INVEN = 10 },

	resists = { [DamageType.FIRE] = -20, [DamageType.LIGHT] = -45 },

	see_invisible = 20,

	force_tentacle_hand = 1,
	resolvers.talents{
		[Talents.T_MUTATED_HAND] = {base=3, every=6},
		[Talents.T_TENDRILS_ERUPTION] = {base=3, every=6},
		[Talents.T_LASH_OUT] = {base=3, every=6},
		[Talents.T_TENTACLE_CONSTRICT] = {base=3, every=6},
	},
}
