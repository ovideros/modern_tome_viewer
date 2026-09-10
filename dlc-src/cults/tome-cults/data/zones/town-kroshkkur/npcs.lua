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
	define_as = "BASE_NPC_KROSHKKUR_TOWN",
	type = "horror", subtype = "eldritch",
	display = "h", color=colors.WHITE,
	faction = "sanctuary-of-horrors",
	anger_emote = _t"Destroy @himher@!",

	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 3,

	life_rating = 10,
	rank = 2,
	size_category = 3,

	open_door = true,
	no_difficulty_random_class = true,

	resolvers.racial(),
	resolvers.inscriptions(1, "rune"),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=12, dex=8, mag=6, con=10 },

	emote_random = resolvers.emote_random{allow_backup_guardian=true},
}

newEntity{ base = "BASE_NPC_KROSHKKUR_TOWN",
	name = "drem cultist", color=colors.LIGHT_BLUE,
	desc = _t[[A drem cultist.]],
	resolvers.nice_tile{tall=1},
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.talents{
		[Talents.T_NETHERBLAST]={base=1, every=10, max=5},
	},
	ai_state = { talent_in=1, },

	autolevel = "caster",
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
	},
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_KROSHKKUR_TOWN",
	name = "drem seeker of knowledge", color=colors.LIGHT_UMBER,
	desc = _t[[A drem in long red robes, minding its own business.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.talents{
		[Talents.T_NETHERBLAST]={base=1, every=10, max=5},
	},
	ai_state = { talent_in=1, },

	autolevel = "caster",
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
	},
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_KROSHKKUR_TOWN",
	name = "drem seeker of knowledge", color=colors.LIGHT_UMBER,
	desc = _t[[A drem in long red robes, minding its own business.]],
	image = "npc/horror_eldritch_drem_seeker_of_knowledge_female.png",
	level_range = {1, nil}, exp_worth = 1, female=1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.talents{
		[Talents.T_NETHERBLAST]={base=1, every=10, max=5},
	},
	ai_state = { talent_in=1, },

	autolevel = "caster",
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
	},
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_KROSHKKUR_TOWN",
	name = "disfigured creature", color=colors.LIGHT_RED,
	desc = _t[[A vaguely humanoid shape, wandering around to some unknown goals.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.talents{
		[Talents.T_NETHERBLAST]={base=1, every=10, max=5},
	},
	ai_state = { talent_in=1, },

	autolevel = "caster",
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
	},
	resolvers.racial(),
}

-------------------------------- Stores
newEntity{ base = "BASE_NPC_KROSHKKUR_TOWN", define_as = "KROSHKKUR_LIBRARY",
	name = "That Which Teaches History", color=colors.BLUE,
	desc = _t[[This creature manages the sanctuary's library.]],
	resolvers.nice_tile{tall=1},
	level_range = {50, nil}, exp_worth = 1,
	rank = 3.5,
	max_life = resolvers.rngavg(500,600),
	ai_state = { talent_in=1, },
	resolvers.talents{
		-- Yes, just for funz :)
		[Talents.T_ENTROPIC_GIFT] = {base=50, every=1},
		[Talents.T_REALITY_FRACTURE] = {base=50, every=1},
		[Talents.T_ZERO_POINT_ENERGY] = {base=50, every=1},
		[Talents.T_NETHERBLAST] = {base=50, every=1},
	},
	ai_state = { talent_in=1, },

	autolevel = "caster",
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
	},
	resolvers.store("KROSHKKUR_LIBRARY", "sanctuary-of-horrors"),
}

newEntity{ base = "BASE_NPC_KROSHKKUR_TOWN", define_as = "KROSHKKUR_WEAPONS",
	name = "The Sightless Acolyte", color=colors.RED,
	desc = _t[[This creature sells weapons for the sanctuary.]],
	resolvers.nice_tile{tall=1},
	level_range = {50, nil}, exp_worth = 1,
	rank = 3.5,
	max_life = resolvers.rngavg(500,600),
	ai_state = { talent_in=1, },
	resolvers.talents{
		-- Yes, just for funz :)
		[Talents.T_ENTROPIC_GIFT] = {base=50, every=1},
		[Talents.T_REALITY_FRACTURE] = {base=50, every=1},
		[Talents.T_ZERO_POINT_ENERGY] = {base=50, every=1},
		[Talents.T_NETHERBLAST] = {base=50, every=1},
	},
	ai_state = { talent_in=1, },

	autolevel = "caster",
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
	},
	resolvers.store("KROSHKKUR_WEAPONS", "sanctuary-of-horrors"),
}

newEntity{ base = "BASE_NPC_KROSHKKUR_TOWN", define_as = "KROSHKKUR_STAVES",
	name = "The Crawler", color=colors.LIGHT_RED,
	desc = _t[[This creature sells staves and wands for the sanctuary.]],
	resolvers.nice_tile{tall=1},
	level_range = {50, nil}, exp_worth = 1,
	rank = 3.5,
	max_life = resolvers.rngavg(500,600),
	ai_state = { talent_in=1, },
	resolvers.talents{
		-- Yes, just for funz :)
		[Talents.T_ENTROPIC_GIFT] = {base=50, every=1},
		[Talents.T_REALITY_FRACTURE] = {base=50, every=1},
		[Talents.T_ZERO_POINT_ENERGY] = {base=50, every=1},
		[Talents.T_NETHERBLAST] = {base=50, every=1},
	},
	ai_state = { talent_in=1, },

	autolevel = "caster",
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
	},
	resolvers.store("KROSHKKUR_STAVES", "sanctuary-of-horrors"),
}

newEntity{ base = "BASE_NPC_KROSHKKUR_TOWN", define_as = "KROSHKKUR_ARMORS",
	name = "The One That Defends", color=colors.GREEN,
	desc = _t[[This creature sells armours for the sanctuary.]],
	resolvers.nice_tile{tall=1},
	level_range = {50, nil}, exp_worth = 1,
	rank = 3.5,
	max_life = resolvers.rngavg(500,600),
	ai_state = { talent_in=1, },
	resolvers.talents{
		-- Yes, just for funz :)
		[Talents.T_ENTROPIC_GIFT] = {base=50, every=1},
		[Talents.T_REALITY_FRACTURE] = {base=50, every=1},
		[Talents.T_ZERO_POINT_ENERGY] = {base=50, every=1},
		[Talents.T_NETHERBLAST] = {base=50, every=1},
	},
	ai_state = { talent_in=1, },

	autolevel = "caster",
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
	},
	resolvers.store("KROSHKKUR_ARMORS", "sanctuary-of-horrors"),
}

newEntity{ base = "BASE_NPC_KROSHKKUR_TOWN", define_as = "KROSHKKUR_RUNES",
	name = "The Face of the Deep", color=colors.BLUE,
	desc = _t[[This creature sells runes and infusions for the sanctuary.]],
	resolvers.nice_tile{tall=1},
	level_range = {50, nil}, exp_worth = 1,
	rank = 3.5,
	max_life = resolvers.rngavg(500,600),
	ai_state = { talent_in=1, },
	resolvers.talents{
		-- Yes, just for funz :)
		[Talents.T_ENTROPIC_GIFT] = {base=50, every=1},
		[Talents.T_REALITY_FRACTURE] = {base=50, every=1},
		[Talents.T_ZERO_POINT_ENERGY] = {base=50, every=1},
		[Talents.T_NETHERBLAST] = {base=50, every=1},
	},
	ai_state = { talent_in=1, },

	autolevel = "caster",
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
	},
	resolvers.store("KROSHKKUR_RUNES", "sanctuary-of-horrors"),
}

newEntity{ base = "BASE_NPC_KROSHKKUR_TOWN", define_as = "KROSHKKUR_TOOLS",
	name = "The Conjointed", color=colors.UMBER,
	desc = _t[[This creature sells tools for the sanctuary.]],
	resolvers.nice_tile{tall=1},
	level_range = {50, nil}, exp_worth = 1,
	rank = 3.5,
	max_life = resolvers.rngavg(500,600),
	ai_state = { talent_in=1, },
	resolvers.talents{
		-- Yes, just for funz :)
		[Talents.T_ENTROPIC_GIFT] = {base=50, every=1},
		[Talents.T_REALITY_FRACTURE] = {base=50, every=1},
		[Talents.T_ZERO_POINT_ENERGY] = {base=50, every=1},
		[Talents.T_NETHERBLAST] = {base=50, every=1},
	},
	ai_state = { talent_in=1, },

	autolevel = "caster",
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
	},
	resolvers.store("KROSHKKUR_TOOLS", "sanctuary-of-horrors"),
}
