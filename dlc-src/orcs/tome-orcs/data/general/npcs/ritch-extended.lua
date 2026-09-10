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

newEntity{
	define_as = "BASE_NPC_RITCH",
	type = "insect", subtype = "ritch",
	display = "I", color=colors.RED,
	blood_color = colors.GREEN,
	desc = _t[[Ritches are giant insects native to the arid wastes of the southern parts of the Far East.
Vicious predators, they inject corrupting diseases into their foes, and their sharp claws cut through most armours.]],

	combat = { dam=resolvers.levelup(resolvers.rngavg(15,22), 1, 0.7), atk=16, apr=7, damtype=DamageType.BLIGHT, dammod={dex=1} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	infravision = 10,
	size_category = 1,
	rank = 2,

	autolevel = "slinger",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	global_speed_base = 1.2,
	stats = { str=15, dex=15, mag=8, con=10 },

	poison_immune = 0.5,
	disease_immune = 0.5,
	resists = { [DamageType.BLIGHT] = 20, [DamageType.FIRE] = 55 },
	ingredient_on_death = "RITCH_STINGER",
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_RITCH", define_as = "RITCH_LARVA",
	name = "ritch larva", color=colors.DARK_RED,
	level_range = {12, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 30,
	life_rating = 4,

	rank = 1,
	combat_armor = 5, combat_def = 5,

	resolvers.talents{
		[Talents.T_ROTTING_DISEASE]={base=1, every=8, max=6},
		[Talents.T_SHRIEK]=1,
	},
}

newEntity{ base = "BASE_NPC_RITCH",
	name = "ritch hunter", color=colors.RED,
	level_range = {12, nil}, exp_worth = 1,
	rarity = 2,
	max_life = 120,
	life_rating = 10,

	rank = 2,
	combat_armor = 12, combat_def = 5,

	resolvers.talents{
		[Talents.T_ROTTING_DISEASE]={base=1, every=8, max=8},
		[Talents.T_RUSH]=5,
		[Talents.T_FLAME]={base=5, every=7, max=9},
		-- [Talents.T_SHRIEK]=3,
	},
}

newEntity{ base = "BASE_NPC_RITCH",
	name = "ritch hive mother", color=colors.LIGHT_RED,
	level_range = {13, nil}, exp_worth = 1,
	rarity = 4,
	max_life = 250,
	life_rating = 12,

	rank = 3,
	size_category = 2,
	combat_armor = 20, combat_def = 20,

	ai = "tactical",
	ai_tactic = resolvers.tactic"ranged",

	make_escort = {
		{type="insect", subtype="ritch", number=3, no_subescort=true},
	},
	summon = {
		{type="insect", subtype="ritch", name="ritch larva", number=1, hasxp=false},
		{type="insect", subtype="ritch", name="ritch hunter", number=1, hasxp=false},
		{type="insect", subtype="ritch", name="ritch centipede", number=1, hasxp=false},
		{type="insect", subtype="ritch", name="larvae bloated ritch mother", number=1, hasxp=false},
	},

	resolvers.talents{
		[Talents.T_ROTTING_DISEASE]={base=1, every=8, max=9},
		[Talents.T_FLAME]={base=2, every=7, max=9},
		[Talents.T_SUMMON]=1,
		-- [Talents.T_SHRIEK]=4,
	},

}

newEntity{ base = "BASE_NPC_RITCH",
	name = "ritch centipede", color=colors.LIGHT_RED,
	resolvers.nice_tile{tall=1},
	desc = _t[[This strange creature looks like a ritch hunter but with more legs. So many legs.]],
	level_range = {13, nil}, exp_worth = 1,
	rarity = 4,
	max_life = 200,
	life_rating = 12,

	rank = 2,
	size_category = 2,
	combat_armor = 9, combat_def = 10,
	combat = { dam=resolvers.levelup(resolvers.rngavg(30,35), 1, 1), atk=16, apr=9, damtype=DamageType.BLIGHT, dammod={dex=1.2} },

	ai_tactic = resolvers.tactic"melee",

	make_escort = {
		{type="insect", subtype="ritch", name="ritch centipede", number=1, no_subescort=true},
	},

	resolvers.talents{
		[Talents.T_SANDRUSH]={base=1, every=5, max=9},
	},

}

newEntity{ base = "BASE_NPC_RITCH",
	name = "larvae bloated ritch mother", color=colors.LIGHT_BLUE,
	resolvers.nice_tile{tall=1},
	desc = _t[[The skin of this creature is literally crawling with larvae, yet she seems to be moving toward you very fast.]],
	level_range = {13, nil}, exp_worth = 1,
	rarity = 3,
	max_life = 70,
	life_rating = 10,

	global_speed_base = 1,
	movement_speed = 3,

	rank = 3,
	size_category = 2,
	combat_armor = 9, combat_def = 10,

	ai_state = { talent_in=1, },

	resolvers.talents{
		[Talents.T_RITCH_LARVA_INFECT]={base=1, every=5, max=9},
	},
}
