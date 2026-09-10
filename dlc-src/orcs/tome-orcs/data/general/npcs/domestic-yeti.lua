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

-- last updated:  5:11 PM 1/29/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_YETI_TAME",
	type = "giant", subtype = "yeti",
	display = "Y", color=colors.WHITE,
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },

	max_stamina = 150,
	rank = 2,
	size_category = 4,
	infravision = 10,
	
	resists={[DamageType.COLD] = 50,},

	resolvers.racial(),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },
	stats = { str=16, dex=10, mag=3, con=12, wil=12 },
	combat = { dammod={str=1}},
	combat_armor = 2, combat_def = 12,
	not_power_source = {arcane=true, technique_ranged=true},
}


newEntity{ base = "BASE_NPC_YETI_TAME",
	name = "pet yeti", color=colors.LIGHT_GREY,
	desc = _t[[This yeti is somewhat smaller than the average yeti, and its fur seems well groomed. Nonetheless, it looks quite unhappy to see its master's home invaded.]],
	resolvers.nice_tile{tall=true},
	level_range = {1, 12}, exp_worth = 1,
	rarity = 3,
	rank = 1,
	max_life = resolvers.rngavg(40,70), life_rating = 8,
	combat_armor = 2, combat_def = 4,
	combat = { dam=resolvers.levelup(5, 1, 0.8), atk=0, apr=3 },
	
	resolvers.talents{
		[Talents.T_HOWL]=2,
	},
}

newEntity{ base = "BASE_NPC_YETI_TAME",
	name = "guard yeti", color=colors.LIGHT_GREY,
	desc = _t[[This yeti is large and angry, with claws far more sharply honed than those found in nature.]],
	resolvers.nice_tile{tall=true},
	level_range = {3, nil}, exp_worth = 1,
	rarity = 2,
	rank = 2,
	max_life = resolvers.rngavg(45,75), life_rating = 10,
	combat_armor = 2, combat_def = 9,
	combat = { dam=resolvers.levelup(8, 1, 0.9), atk=10, apr=8 },
	
	resolvers.talents{
		[Talents.T_HOWL]=4,
		[Talents.T_CRIPPLE]={base=1, every=10, max=5},
	},
}

newEntity{ base = "BASE_NPC_YETI_TAME",
	name = "attack yeti", color=colors.LIGHT_GREY,
	desc = _t[[This yeti's claws are coated in sharply carved iron. It glares at you with a long trained anger.]],
	resolvers.nice_tile{tall=true},
	level_range = {3, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	max_life = resolvers.rngavg(50,80), life_rating = 13,
	combat_armor = 5, combat_def = 12,
	combat = { dam=resolvers.levelup(10, 1, 0.8), atk=15, apr=10 },
	
	resolvers.talents{
		[Talents.T_HOWL]=5,
		[Talents.T_CRIPPLE]={base=2, every=10, max=5},
		[Talents.T_RUSHING_CLAWS]={base=1, every=10, max=5},
	},
}
