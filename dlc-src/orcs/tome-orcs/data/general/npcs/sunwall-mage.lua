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
	define_as = "BASE_SUNWALL_MAGE",
	type = "humanoid", subtype = "elf",
	display = "p", color=colors.UMBER,
	faction = "sunwall",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.auto_equip_filters("Archmage"),
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 10,
	lite = 2,

	life_rating = 11,
	rank = 2,
	size_category = 3,
	never_anger = true,

	open_door = true,
	silence_immune = 0.5,

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	stats = { str=20, dex=8, mag=6, con=16 },
	power_source = {arcane=true},
	
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_SUNWALL_MAGE",
	name = "sun-mage recruit", color=colors.ORANGE,
	desc = _t[[A mage dressed in glowing robes.]],
	level_range = {2, 20}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70, 80), life_rating = 10,
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
	},
	combat_armor = 0, combat_def = 0,
	resolvers.talents{
		[Talents.T_SEARING_LIGHT]={base=1, every=10, max=18}, 
		[Talents.T_CHANT_OF_LIGHT]={base=2, every=10, max=5},
		[Talents.T_FIREBEAM]={base=1, every=10, max=18},
	},
}

newEntity{ base = "BASE_SUNWALL_MAGE",
	name = "sun-mage", color=colors.ORANGE,
	image = "npc/humanoid_elf_elven_sun_mage.png",
	desc = _t[[A mage dressed in shining robes.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(70, 80), life_rating = 11,
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
	},
	combat_armor = 0, combat_def = 0,
	resolvers.talents{
		[Talents.T_SEARING_LIGHT]={base=2, every=5, max=18}, 
		[Talents.T_CHANT_OF_LIGHT]={base=3, every=10, max=5},
		[Talents.T_FIREBEAM]={base=1, every=5, max=18},
		[Talents.T_SUN_FLARE]={base=2, every=7, max=18},
	},
}

newEntity{ base = "BASE_SUNWALL_MAGE",
	name = "anorithil", color=colors.LIGHT_DARK,
	desc = _t[[A mage dressed in ornate robes depicting both light and darkness.]],
	level_range = {18, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(70, 80), life_rating = 11,
	negative_regen=1,
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
	},
	combat_armor = 0, combat_def = 0,
	resolvers.talents{
		[Talents.T_SEARING_LIGHT]={base=1, every=5, max=18}, 
		[Talents.T_CHANT_OF_LIGHT]={base=1, every=8, max=5},
		[Talents.T_HYMN_OF_SHADOWS]={base=3, every=10, max=5},
		[Talents.T_MOONLIGHT_RAY]={base=1, every=5, max=18},
		[Talents.T_TWILIGHT_SURGE]={base=1, every=10, max=18},
	},
}

newEntity{ base = "BASE_SUNWALL_MAGE",
	name = "astral conjurer", color=colors.LIGHT_DARK, subtype = "human",
	desc = _t[[A mage dressed in ornate robes depicting both light and darkness.]],
	level_range = {22, nil}, exp_worth = 1,
	rarity = 5,
	max_life = resolvers.rngavg(100, 120), life_rating = 12,
	negative_regen=1,
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
	},
	combat_armor = 0, combat_def = 0,
	resolvers.talents{
		[Talents.T_LUNAR_ORB]={base=2, every=4, max=18}, 
		[Talents.T_SOLAR_ORB]={base=2, every=4, max=18}, 
		[Talents.T_GALACTIC_PULSE]={base=2, every=5, max=18},
		[Talents.T_SUPERNOVA]={last=32, base=0, every=1, max=0},
		[Talents.T_DIFFRACTION_PULSE]={base=2, every=6, max=18},
	},
}

newEntity{ base = "BASE_SUNWALL_MAGE",
	name = "elven astromancer", color=colors.GOLD,
	resolvers.nice_tile{tall=1},
	desc = _t[[A mage who has studied all there is to know about the stars and their working.]],
	level_range = {30, nil}, exp_worth = 1,
	rarity = 8,
	rank = 3,
	max_life = resolvers.rngavg(170, 200), life_rating = 12,
	negative_regen=4, positive_regen=4,
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
	},
	ai = "tactical",
	combat_armor = 0, combat_def = 0,
	resolvers.talents{
		[Talents.T_LUNAR_ORB]={base=2, every=4, max=18}, 
		[Talents.T_SOLAR_ORB]={base=2, every=4, max=18}, 
		[Talents.T_PLASMA_BOLT]={base=2, every=4, max=18}, 
		[Talents.T_GALACTIC_PULSE]={base=2, every=5, max=18},
		[Talents.T_GRAVITY_SPIKE]={base=2, every=5, max=18},
		[Talents.T_GRAVITY_LOCUS]={base=2, every=6, max=18},
		[Talents.T_REPULSION_BLAST]={base=2, every=6, max=18},
	},
}
