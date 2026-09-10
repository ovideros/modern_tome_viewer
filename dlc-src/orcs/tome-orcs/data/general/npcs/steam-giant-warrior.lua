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
	define_as = "BASE_STEAM_GIANT_WARRIOR",
	type = "giant", subtype = "steam",
	display = "P", color=colors.GREY,
	faction = "atmos-tribe",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, FEET=1, CLOAK=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 10,
	lite = 1,

	resolvers.inscription("IMPLANT:_STEAM_GENERATOR", {cooldown=32, power=8}),

	life_rating = 15,
	rank = 2,
	size_category = 4,

	open_door = true,

	resolvers.talents{ [Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5}, [Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=5} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=20, dex=8, mag=6, con=16 },
	power_source = {steamtech=true},
}

newEntity{ base = "BASE_STEAM_GIANT_WARRIOR",
	name = "steam giant guard", color=colors.LIGHT_UMBER,
	desc = _t[[This titanic figure walks towards you, a massive sword and shield in each hand.]],
	resolvers.nice_tile{tall=1},
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(80,90), life_rating = 12,
	resolvers.auto_equip_filters("Bulwark"),
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
		{type="armor", subtype="massive", autoreq=true},
	},
	combat_armor = 0, combat_def = 6,
	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]={base=1, every=4, max=7},
		[Talents.T_SHIELD_PUMMEL]={base=1, every=10, max=5}, 
	},
}

newEntity{ base = "BASE_STEAM_GIANT_WARRIOR",
	name = "steam giant berserker", color=colors.LIGHT_UMBER,
	desc = _t[[This steam giant carries a massive greatsword with both hands, and you see a cloud of thick steam enveloping the blade.]],
	resolvers.nice_tile{tall=1},
	level_range = {3, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(100,120),
	resolvers.auto_equip_filters("Berserker"),
	resolvers.equip{
		{type="weapon", subtype="greatsword", autoreq=true},
		{type="armor", subtype="heavy", autoreq=true},
	},
	combat_armor = 3, combat_def = 6,
	melee_project={[DamageType.FIRE] = resolvers.levelup(resolvers.mbonus(12, 8), 1, 0.8)}, --Blade is superheated by steam
	inc_damage_level_penalty = {start_at=-30, end_level=15},
	resolvers.talents{ 
		[Talents.T_RUSH]={base=1, every=10, max=5}, 
		[Talents.T_DEATH_DANCE]={base=1, every=10, max=5}, 
	},
}

newEntity{ base = "BASE_STEAM_GIANT_WARRIOR",
	name = "steam giant yeti rider", color=colors.LIGHT_BLUE,
	desc = _t[[Riding atop a massive armored yeti, this steam giant wields a huge greatsword.]],
	resolvers.nice_tile{tall=1},
	level_range = {3, nil}, exp_worth = 1,
	rarity = 5,
	max_life = resolvers.rngavg(150,180),
	resolvers.equip{
		{type="weapon", subtype="greatsword", autoreq=true},
		{type="armor", subtype="heavy", autoreq=true},
	},
	combat_armor = 4, combat_def = 8,
	melee_project={[DamageType.FIRE] = resolvers.levelup(resolvers.mbonus(12, 8), 1, 0.8)}, --Blade is superheated by steam
	resolvers.talents{ 
		[Talents.T_HOWL]=5,
		[Talents.T_ARMOUR_TRAINING]={base=1, every=4, max=7},
		[Talents.T_CRIPPLE]={base=2, every=10, max=5},
		[Talents.T_RUSH]={base=1, every=10, max=5}, 
		[Talents.T_ICE_CLAW]={base=1, every=6, max=5},
	},
}
