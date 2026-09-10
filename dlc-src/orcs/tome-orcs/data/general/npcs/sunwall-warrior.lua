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
	define_as = "BASE_SUNWALL_WARRIOR",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.UMBER,
	faction = "sunwall",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 10,
	lite = 1,

	life_rating = 15,
	rank = 2,
	size_category = 3,
	never_anger = true,

	open_door = true,

	resolvers.talents{ [Talents.T_ARMOUR_TRAINING]=3, [Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5}, [Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=5} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=20, dex=8, mag=6, con=16 },
	power_source = {technique=true},
}

newEntity{ base = "BASE_SUNWALL_WARRIOR",
	name = "sunwall guard", color=colors.LIGHT_UMBER,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_human_sunwall_guard.png", display_h=2, display_y=-1}}},
	desc = _t[[This guard stands tall and proud, wearing the symbol of the Sunwall.]],
	level_range = {3, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(80,90), life_rating = 11,
	resolvers.auto_equip_filters("Sun Paladin"),
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
	},
	combat_armor = 0, combat_def = 6,
	resolvers.talents{ [Talents.T_SHIELD_PUMMEL]={base=1, every=10, max=9}, },
}

newEntity{ base = "BASE_SUNWALL_WARRIOR",
	name = "sunwall archer", color=colors.LIGHT_UMBER, subtype = "elf",
	image = "npc/humanoid_elf_elven_archer.png",
	desc = _t[[You see an archer with his bow drawn back, and a golden sun embossed on his armor.]],
	level_range = {9, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(80,90), life_rating = 11,
	resolvers.talents{ [Talents.T_BOW_MASTERY]={base=1, every=10, max=5}, [Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5}, [Talents.T_SHOOT]=1, },
	ai_state = { talent_in=1, },

	autolevel = "archer",
	resolvers.auto_equip_filters("Archer"),
	resolvers.equip{ 
		{type="weapon", subtype="longbow", forbid_power_source={antimagic=true}, autoreq=true}, 
		{type="ammo", subtype="arrow", forbid_power_source={antimagic=true}, autoreq=true} 
	},
	combat_armor = 0, combat_def = 6,
}

newEntity{ base = "BASE_SUNWALL_WARRIOR",
	name = "sun paladin recruit", color=colors.YELLOW,
	desc = _t[[The shield of this soldier glows with a bright light. You see a golden sun engraved in its center, and he carries a sword in his other hand.]],
	level_range = {4, 20}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(110,120), life_rating = 12,
	resolvers.auto_equip_filters("Sun Paladin"),
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true, forbid_power_source={antimagic=true}},
		{type="armor", subtype="shield", autoreq=true, forbid_power_source={antimagic=true}},
	},
	combat_armor = 0, combat_def = 6,
	resolvers.talents{ 
		[Talents.T_SHIELD_PUMMEL]={base=2, every=10, max=9}, 
		[Talents.T_CHANT_OF_FORTITUDE]=2,
	},
	
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_SUNWALL_WARRIOR",
	name = "sun paladin", color=colors.ORANGE,
	image = "npc/humanoid_human_human_sun_paladin.png",
	desc = _t[[The shield and sword of this soldier glow with a bright light. You see a golden sun engraved in the shield's center.]],
	level_range = {7, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(140,150), life_rating = 12,
	autolevel = "warriormage",
	resolvers.auto_equip_filters("Sun Paladin"),
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true, forbid_power_source={antimagic=true}},
		{type="armor", subtype="shield", autoreq=true, forbid_power_source={antimagic=true}},
	},
	combat_armor = 0, combat_def = 6,
	autolevel = "warriormage",
	resolvers.talents{ 
		[Talents.T_SHIELD_PUMMEL]={base=3, every=7, max=9}, 
		[Talents.T_CHANT_OF_FORTITUDE]={base=3, every=7, max=5},
		[Talents.T_WEAPON_OF_LIGHT]={base=2, every=10, max=9},
	},
	
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_SUNWALL_WARRIOR",
	name = "sunwall vindicator", color=colors.CRIMSON, subtype = "elf",
	desc = _t[[This mean looking soldier of the Sunwall holds steady his big two handed weapon, looking dangerously at you.]],
	level_range = {22, nil}, exp_worth = 1,
	rarity = 2,
	rank = 3,
	max_life = resolvers.rngavg(140,150), life_rating = 16,
	autolevel = "warriormage",
	resolvers.auto_equip_filters("Berserker"),
	resolvers.equip{
		{type="weapon", subtype="greatsword", autoreq=true, forbid_power_source={antimagic=true}},
		{type="armor", subtype="massive", autoreq=true, forbid_power_source={antimagic=true}},
	},
	combat_armor = 5, combat_def = 6,
	ai = "tactical",
	resolvers.talents{ 
		[Talents.T_WEAPON_COMBAT]={base=3, every=4, max=9}, 
		[Talents.T_WEAPONS_MASTERY]={base=3, every=4, max=9}, 
		[Talents.T_CHANT_OF_FORTRESS]={base=4, every=5, max=9},
		[Talents.T_SUNCLOAK]={base=3, every=4, max=9},
		[Talents.T_ABSORPTION_STRIKE]={base=3, every=4, max=9},
		[Talents.T_MARK_OF_LIGHT]={base=3, every=4, max=9},
		[Talents.T_FLASH_OF_THE_BLADE]={base=4, every=4, max=9},
		[Talents.T_PATH_OF_THE_SUN]={base=4, every=4, max=9},
	},
	
	resolvers.sustains_at_birth(),
}
