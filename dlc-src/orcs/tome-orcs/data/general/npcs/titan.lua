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

-- last updated: 9:25 AM 2/5/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_TITAN",
	type = "giant", subtype = "titan",
	display = "P", color=colors.GREY,
	faction = "horrors",

	combat = { dam=1 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, FEET=1, CLOAK=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	infravision = 10,
	lite = 1,

	steam_regen = 30,

	life_rating = 15,
	rank = 3,
	size_category = 5,

	open_door = true,

	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]=3,
		[Talents.T_WEAPON_COMBAT]={base=5, every=5, max=15},
		[Talents.T_WEAPONS_MASTERY]={base=5, every=5, max=15}
	},

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	stats = { str=30, dex=30, mag=30, con=30 },
}

newEntity{ base = "BASE_TITAN",
	name = "titan battlesmasher", color=colors.UMBER,
	desc = _t[[This creature looks like one of the steam giants, but nastier, bigger and somehow corrupted by unknown forces. Oh and it is wielding a huge maul too!]],
	resolvers.nice_tile{tall=1},
	level_range = {50, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(200,400), life_rating = 19,
	resolvers.auto_equip_filters("Berserker"),
	resolvers.equip{
		{type="weapon", subtype="greatmaul", autoreq=true},
		{type="armor", subtype="massive", autoreq=true},
	},
	combat_armor = 0, combat_def = 6,
	resolvers.talents{
		[Talents.T_IRRESISTIBLE_SUN]=1,
		[Talents.T_PAIN_ENHANCEMENT_SYSTEM]=1,
		[Talents.T_STUNNING_BLOW_ASSAULT]={base=5, every=5, max=15},
		[Talents.T_EXECUTION]={base=5, every=5, max=15},
		[Talents.T_WARSHOUT_BERSERKER]={base=5, every=5, max=15},
		[Talents.T_BATTLE_CALL]={base=5, every=5, max=15},
	},
}

newEntity{ base = "BASE_TITAN",
	name = "titanic horror", color=colors.BLUE,
	desc = _t[[While a titan usually look like a corrupted steam giant, this one looks more like a giant-sized horrific mass of living flesh.]],
	resolvers.nice_tile{tall=1},
	level_range = {50, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(200,400), life_rating = 16,
	resolvers.equip{
	},
	combat_armor = 0, combat_def = 6,
	resolvers.talents{
		[Talents.T_SUBCUTANEOUS_METALLISATION]=1,
		[Talents.T_BLINDSIDE]={base=5, every=5, max=15},
		[Talents.T_CALL_SHADOWS]={base=5, every=5, max=15},
		[Talents.T_SHADOW_MAGES]={base=5, every=5, max=15},
		[Talents.T_FOCUS_SHADOWS]={base=5, every=5, max=15},
		[Talents.T_GLOOM]={base=5, every=5, max=15},
		[Talents.T_INVOKE_DARKNESS]={base=5, every=5, max=15},
		[Talents.T_CURSE_OF_DEATH]={base=5, every=5, max=15},
	},
}

newEntity{ base = "BASE_TITAN",
	name = "titan searing seer", color=colors.RED,
	desc = _t[[Wreathed in arcane flames you can feel the intense psionic forces ripping at your mind emanating from this titan.]],
	resolvers.nice_tile{tall=1},
	level_range = {50, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(200,400), life_rating = 16,
	resolvers.auto_equip_filters("Archmage"),
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
	},
	combat_armor = 0, combat_def = 6,
	autolevel = "caster",
	resolvers.talents{
		[Talents.T_METEORIC_CRASH]=1,
		[Talents.T_FIREFLASH]={base=5, every=5, max=15},
		[Talents.T_BODY_OF_FIRE]={base=5, every=5, max=15},
		[Talents.T_PSY_WORM]={base=5, every=5, max=15},
		[Talents.T_NO_HOPE]={base=5, every=5, max=15},
		[Talents.T_WAKING_NIGHTMARE]={base=5, every=5, max=15},
	},
}

newEntity{ base = "BASE_TITAN",
	name = "titan vile spewer", color=colors.LIGHT_GREEN,
	desc = _t[[The wretched titan's skin is of a sickly green, full of ever-oozing wounds, cracks and pustules. Worms and all kind of vile things crawl over it.]],
	resolvers.nice_tile{tall=1},
	level_range = {50, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(200,400), life_rating = 16,
	resolvers.auto_equip_filters("Sawbutcher"),
	resolvers.equip{
		{type="weapon", subtype="steamsaw", autoreq=true},
		{type="weapon", subtype="steamsaw", autoreq=true},
	},
	resolvers.attachtinker{ id=true,
		{defined="TINKER_VIRAL_INJECTOR1"},
		{defined="TINKER_POISON_GROOVE"},
	},
	combat_armor = 0, combat_def = 6,
	resolvers.talents{
		[Talents.T_GIANT_LEAP]=1,
		[Talents.T_CONTINUOUS_BUTCHERY]={base=5, every=5, max=15},
		[Talents.T_PUNISHMENT]={base=5, every=5, max=15},
		[Talents.T_STEAMSAW_MASTERY]={base=5, every=5, max=15},
		[Talents.T_CORRUPTED_STRENGTH]={base=5, every=5, max=15},
		[Talents.T_INFECTIOUS_BITE]={base=5, every=5, max=15},
		[Talents.T_INFESTATION]={base=5, every=5, max=15},
	},
}

newEntity{ base = "BASE_TITAN",
	name = "titan dreadnought", color=colors.WHITE,
	desc = _t[[One of the biggest titans you have seen yet, it is fully clad in deep black stralite full plate, charging menacingly towards you at a terrible pace.]],
	resolvers.nice_tile{tall=1},
	level_range = {50, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(200,400), life_rating = 16,
	resolvers.equip{
		{type="weapon", subtype="battleaxe", autoreq=true},
		{type="armor", subtype="massive", autoreq=true},
	},
	combat_armor = 0, combat_def = 6,
	resolvers.talents{
		[Talents.T_BLOODSPRING]=1,
		[Talents.T_GREATER_WEAPON_FOCUS]={base=5, every=5, max=15},
		[Talents.T_BLEEDING_EDGE]={base=5, every=5, max=15},
		[Talents.T_TRUE_GRIT]={base=5, every=5, max=15},
		[Talents.T_UNSTOPPABLE]={base=5, every=5, max=15},
		[Talents.T_SHATTERING_SHOUT]={base=5, every=5, max=15},
		[Talents.T_BATTLE_CRY]={base=5, every=5, max=15},
		[Talents.T_BATTLE_SHOUT]={base=5, every=5, max=15},
		[Talents.T_RUSH]={base=5, every=5, max=15},
		[Talents.T_BLINDING_SPEED]={base=5, every=5, max=15},
	},
}

newEntity{ base = "BASE_TITAN",
	name = "sher'tan", color=colors.ORANGE,
	desc = _t[[This abomination has the height of any other titan but its features definitively remind you of the few Sher'Tul images you have seen. Your very being rebels to the thought and sheer terror takes hold of your mind.]],
	resolvers.nice_tile{tall=1},
	level_range = {50, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(200,400), life_rating = 20,
	combat = { dam=resolvers.levelup(resolvers.rngavg(16,22), 1, 1.5), atk=resolvers.levelup(18, 1, 1), apr=45, dammod={str=1.1}, damtype=engine.DamageType.BLIGHT, },
	combat_armor = 0, combat_def = 6,
	resolvers.talents{
		[Talents.T_CALL_OF_AMAKTHEL]=1,
		[Talents.T_FURNACE]={base=5, every=5, max=15},
		[Talents.T_MOLTEN_METAL]={base=5, every=5, max=15},
		[Talents.T_FURNACE_VENT]={base=5, every=5, max=15},
		[Talents.T_MELTING_POINT]={base=5, every=5, max=15},
		[Talents.T_KINETIC_AURA]={base=5, every=5, max=15},
		[Talents.T_TENTACLE_GRAB]={base=5, every=5, max=15},
	},
}

newEntity{ base = "BASE_TITAN", define_as = "GARGANTUAN_SHERTAN",
	name = "gargantuan sher'tan", color=colors.YELLOW,
	desc = _t[[This abomination has the height of any other titan but its feature definitively remind you of the few Sher'Tul images you have seen. Your very being rebels to the thought and sheer terror takes hold of your mind.]],
	resolvers.nice_tile{tall=1},
	level_range = {50, nil}, exp_worth = 1,
	rarity = 3,
	size_category = 6,
	max_life = resolvers.rngavg(200,400), life_rating = 25,
	combat = { dam=resolvers.levelup(resolvers.rngavg(16,22), 1, 1.5), atk=resolvers.levelup(18, 1, 1), apr=45, dammod={str=1.1}, damtype=engine.DamageType.BLIGHT, },
	combat_armor = 0, combat_def = 6,
	resolvers.talents{
		[Talents.T_CALL_OF_AMAKTHEL]=1,
		[Talents.T_FURNACE]={base=5, every=5, max=15},
		[Talents.T_MOLTEN_METAL]={base=5, every=5, max=15},
		[Talents.T_FURNACE_VENT]={base=5, every=5, max=15},
		[Talents.T_MELTING_POINT]={base=5, every=5, max=15},
		[Talents.T_KINETIC_AURA]={base=5, every=5, max=15},
		[Talents.T_KINETIC_SHIELD]={base=5, every=5, max=15},
		[Talents.T_KINETIC_LEECH]={base=5, every=5, max=15},
		[Talents.T_TENTACLE_GRAB]={base=5, every=5, max=15},
		[Talents.T_MANA_CLASH]={base=1, every=6, max=7},
	},
}
