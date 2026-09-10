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

-- last updated:  9:54 AM 2/3/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_BLOB",
	type = "vermin", subtype = "blob",
	display = "j", color=colors.WHITE,
	desc = _t"Ewwww.",
	sound_moam = {"creatures/jelly/jelly_%d", 1, 3},
	sound_die = {"creatures/jelly/jelly_die_%d", 1, 2},
	sound_random = {"creatures/jelly/jelly_%d", 1, 3},
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	stats = { str=10, dex=15, mag=3, con=10 },
	combat = {sound="creatures/jelly/jelly_hit"},
	combat_armor = 1, combat_def = 1,
	rank = 2,
	size_category = 3,
	infravision = 5,
	cut_immune = 1,
	blind_immune = 1,

	resolvers.drops{chance=35, nb=1, {} },

	max_life = resolvers.rngavg(50,90),

	not_power_source = {technique_ranged=true},
}

newEntity{ base = "BASE_NPC_BLOB",
	name = "plasmic disruptor", color=colors.GREEN,
	blood_color = colors.GREEN,
	desc = _t"A green oozing defence cell of the Maggot.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.POISON },

	resolvers.talents{
		[Talents.T_MITOSIS]={base=1, every=6, max=10},
		[Talents.T_SLIME_SPIT]={base=1, every=6, max=10},
	},
}

newEntity{ base = "BASE_NPC_BLOB",
	name = "mastocytic feeder", color=colors.RED,
	blood_color = colors.RED,
	desc = _t"A reddish attack cell that will crawl to you to distract you while the rest of the organism attacks.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.FIRE },

	resolvers.talents{
		[Talents.T_MITOSIS]={base=1, every=6, max=10},
		[Talents.T_SLIME_ROOTS]={base=1, every=6, max=10},
	},
}

newEntity{ base = "BASE_NPC_BLOB",
	name = "protoplasmic controller", color=colors.BLUE,
	blood_color = colors.BLUE,
	desc = _t"Acid. Fire. Pain.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.ACID },

	resolvers.talents{
		[Talents.T_MITOSIS]={base=1, every=6, max=10},
		[Talents.T_ACIDFIRE]={base=1, every=6, max=10},
	},
}

newEntity{ base = "BASE_NPC_BLOB",
	name = "dendritic hemospinner", color=colors.WHITE,
	blood_color = colors.WHITE,
	desc = _t"This strange cell can somehow connect to Eyal itself.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.NATURE },

	resolvers.talents{
		[Talents.T_MITOSIS]={base=1, every=6, max=10},
		[Talents.T_EYAL_S_WRATH]={base=1, every=6, max=10},
	},
}

newEntity{ base = "BASE_NPC_BLOB",
	name = "acidic digestor", color=colors.YELLOW,
	blood_color = colors.YELLOW,
	desc = _t"You look like nutriments.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.LIGHTNING },

	resolvers.talents{
		[Talents.T_MITOSIS]={base=1, every=6, max=10},
		[Talents.T_CORROSIVE_VAPOUR]={base=1, every=6, max=10},
	},
}

newEntity{ base = "BASE_NPC_BLOB",
	name = "protosentient globula", color=colors.BLACK,
	blood_color = colors.BLACK,
	desc = _t"A huge globula of protoplasma. You can feel a kind of protosentience emanating from it, and you can tell it is hungry.",
	resolvers.nice_tile{tall=1},
	level_range = {2, 25}, exp_worth = 1,
	rarity = 1,
	rank = 3,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.ACID },

	resolvers.talents{
		[Talents.T_MITOSIS]={base=1, every=6, max=10},
		[Talents.T_CALL_OF_THE_OOZE]={base=1, every=6, max=10},
	},
}
