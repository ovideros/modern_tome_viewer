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
	define_as = "BASE_NPC_ALLIGATOR",
	type = "reptile", subtype = "alligator",
	display = "A", color=colors.GREEN,
	body = { INVEN = 10, },

	max_stamina = 150,
	rank = 2,
	size_category = 3,
	infravision = 10,
	can_breath = {water=10},
	
	resists={[DamageType.COLD] = 50,},

	autolevel = "tank",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },
	stats = { str=16, dex=10, mag=3, con=12 },
	combat = { dammod={str=1}},
	combat_armor = 4, combat_def = 2,
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_ALLIGATOR",
	name = "sewer alligator", color=colors.GREEN,
	desc = _t[[How cliche!]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	max_life = resolvers.rngavg(60,80), life_rating = 10,
	combat = { dam=resolvers.levelup(resolvers.rngavg(5,15), 1, 0.7), atk=resolvers.rngavg(15,70), apr=10, dammod={str=1.1} },
	resolvers.talents{
		[Talents.T_GNASHING_MAW]={base=1, every=6, max=10},
	},
}

newEntity{ base = "BASE_NPC_ALLIGATOR",
	name = "giant alligator", color=colors.DARK_GREEN,
	resolvers.nice_tile{tall=1},
	desc = _t[[How cliche! Also, terrifying!]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	rank = 2,
	size_category = 4,
	max_life = resolvers.rngavg(60,80), life_rating = 13,
	combat_armor = 10, combat_def = 3,
	combat = { dam=resolvers.levelup(resolvers.rngavg(5,15), 1, 0.8), atk=resolvers.rngavg(15,70), apr=10, dammod={str=1.1} },
	resolvers.talents{
		[Talents.T_KNOCKBACK]={base=1, every=8},
		[Talents.T_RUSH]={base=1, every=8},
		[Talents.T_GNASHING_MAW]={base=1, every=6, max=10},
	},
}
newEntity{ base = "BASE_NPC_ALLIGATOR",
	name = "basaligator", color=colors.UMBER,
	desc = _t[[This thing looks like an alligator, but it has unnaturally large, grey eyes. It gazes at you with great intensity.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	size_category = 4,
	max_life = resolvers.rngavg(100,140), life_rating = 15,
	combat_armor = 20, combat_def = 0, armor_hardiness=50, --Scales of Stone
	combat = { dam=resolvers.levelup(resolvers.rngavg(15,30), 1, 1), atk=resolvers.rngavg(15,70), apr=10, dammod={str=1.1} },
	resolvers.talents{
		[Talents.T_PETRIFYING_GAZE]={base=1, every=6, max=10},
		[Talents.T_GNASHING_MAW]={base=1, every=6, max=10},
	},
}
