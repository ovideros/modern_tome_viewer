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

-- last updated: 11:56 AM 2/5/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_MINOTAUR_UNDEAD",
	type = "undead", subtype = "minotaur",
	display = "H", color=colors.WHITE,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=40, nb=1, {type="money"} },

	infravision = 10,
	lite = 1,
	max_stamina = 100,
	life_rating = 14,
	max_life = resolvers.rngavg(100,120),
	rank = 2,
	size_category = 4,
	no_breath = 1,
	poison_immune = 1,
	cut_immune = 1,
	silence_immune = 0.5,

	resolvers.racial("undead_minotaur"),

	open_door = true,

	resolvers.inscriptions(2, "rune"),
	resolvers.talents{
		[Talents.T_WEAPON_COMBAT]={base=1, every=10, max=6},
		[Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=6}
	},

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=5, },
	global_speed_base = 1.2,
	stats = { str=15, dex=12, mag=16, cun=12, con=15 },

	ingredient_on_death = {"MINOTAUR_NOSE", "GHOUL_FLESH"},
	not_power_source = {nature=true},
}

newEntity{ base = "BASE_NPC_MINOTAUR_UNDEAD",
	name = "whitehoof ghoul", color=colors.UMBER,
	resolvers.nice_tile{tall=1},
	desc = _t[[It is a cross between a human and a bull, but more ... dead.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 1,
	combat_armor = 8, combat_def = 8,
	resolvers.auto_equip_filters("Berserker"),
	resolvers.equip{ {type="weapon", subtype="battleaxe", autoreq=true}, },
	resolvers.talents{
		[Talents.T_BITE_POISON]={base=3, every=10, max=6},
		[Talents.T_STUNNING_BLOW]={base=3, every=10, max=6},
		[Talents.T_SUNDER_ARMOUR]={base=2, every=10, max=5},
		[Talents.T_SUNDER_ARMS]={base=2, every=10, max=5},
	},
}

newEntity{ base = "BASE_NPC_MINOTAUR_UNDEAD",
	name = "whitehoof maulotaur", color=colors.SLATE,
	resolvers.nice_tile{tall=1},
	desc = _t[[This big undead minotaur is carrying a nasty looking hammer, imbued with lightning.]],
	level_range = {12, nil}, exp_worth = 1,
	rarity = 3,
	combat_armor = 10, combat_def = 7,
	resolvers.equip{ {type="weapon", subtype="greatmaul", forbid_power_source={antimagic=true}, autoreq=true} },

	autolevel = "warriormage",
	resolvers.talents{
		[Talents.T_SHOCK_HANDS]={base=3, every=8, max=6},
		[Talents.T_LIGHTNING]={base=2, every=10, max=6},
		[Talents.T_ARCANE_COMBAT]={base=2, every=10, max=6},
	},
}

newEntity{ base = "BASE_NPC_MINOTAUR_UNDEAD",
	name = "whitehoof invoker", color=colors.GREY,
	resolvers.nice_tile{tall=1},
	desc = _t[[Vortexes of sickly arcane energies circle this great undead frame.]],
	level_range = {14, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	combat_armor = 5, combat_def = 8,
	resolvers.auto_equip_filters("Necromancer"),
	resolvers.equip{ {type="weapon", subtype="staff", autoreq=true}, },
	resolvers.talents{
		[Talents.T_CALL_OF_THE_MAUSOLEUM]={base=1, every=10, max=6},
		[Talents.T_BLURRED_MORTALITY]={base=2, every=10, max=6},
		[Talents.T_SURGE_OF_UNDEATH]={base=2, every=10, max=5},
		[Talents.T_ICE_SHARDS]={base=1, every=10, max=5},
		[Talents.T_FROZEN_GROUND]={base=2, every=10, max=5},
	},
}

newEntity{ base = "BASE_NPC_MINOTAUR_UNDEAD",
	name = "whitehoof hailstorm", color=colors.BLUE,
	resolvers.nice_tile{tall=1},
	desc = _t[[The air seems to freeze and wither around this terrible undead.]],
	level_range = {14, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	combat_armor = 0, combat_def = 8,
	resolvers.auto_equip_filters("Necromancer"),
	resolvers.equip{ {type="weapon", subtype="staff", autoreq=true}, },
	resolvers.talents{
		[Talents.T_ICE_SHARDS]={base=1, every=10, max=5},
		[Talents.T_FROZEN_GROUND]={base=2, every=10, max=5},
		[Talents.T_BLACK_ICE]={base=2, every=10, max=5},
		[Talents.T_ETERNAL_NIGHT]={base=2, every=10, max=5},
		[Talents.T_BODY_OF_ICE]={base=2, every=10, max=5},
	},
}
