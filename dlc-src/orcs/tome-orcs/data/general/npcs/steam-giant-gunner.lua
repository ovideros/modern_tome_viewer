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
	define_as = "BASE_STEAM_GIANT_GUNNER",
	type = "giant", subtype = "steam",
	display = "P", color=colors.GREY,
	faction = "atmos-tribe",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 10,
	lite = 1,

	resolvers.talents{ [Talents.T_STEAM_POOL]=1,
		[Talents.T_WEAPON_COMBAT]={base=1, every=8, max=5},
	},
	resolvers.inscription("IMPLANT:_STEAM_GENERATOR", {cooldown=32, power=8}),

	life_rating = 15,
	rank = 2,
	size_category = 4,

	open_door = true,

	autolevel = "rogue",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },
	stats = { str=20, dex=8, mag=6, con=16 },
	power_source = {steamtech=true},
}

newEntity{ base = "BASE_STEAM_GIANT_GUNNER",
	name = "steam giant gunner", color=colors.LIGHT_BLUE,
	desc = _t[[This steam giant is carrying a powerful looking gun.]],
	resolvers.nice_tile{tall=1},
	level_range = {1, 10}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(80,90),
	resolvers.auto_equip_filters{
		MAINHAND={type="weapon", subtype="steamgun", autoreq=true},
		QUIVER={type="ammo", subtype="shot", autoreq=true},
	},
	resolvers.equip{
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="ammo", subtype="shot", autoreq=true},
	},
	combat_armor = 0, combat_def = 6,
	resolvers.talents{ [Talents.T_SHOOT]=1, [Talents.T_RELOAD]=1, [Talents.T_STEAMGUN_MASTERY]={base=1, every=10, max=5},},
}

newEntity{ base = "BASE_STEAM_GIANT_GUNNER",
	name = "steam giant gunslinger", color=colors.BLUE,
	resolvers.nice_tile{tall=1},
	desc = _t[[This steam giant carries a steamgun in each hand.]],
	level_range = {3, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(100,120),
	resolvers.auto_equip_filters("Gunslinger"),
	resolvers.equip{
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="ammo", subtype="shot", autoreq=true},
	},
	combat_armor = 12, combat_def = 6,
	resolvers.talents{ 
		[Talents.T_SHOOT]=1, [Talents.T_RELOAD]=1,
		[Talents.T_UNCANNY_RELOAD]={base=1, every=10, max=5},
		[Talents.T_STRAFE]={base=1, every=10, max=5},
		[Talents.T_STEAMGUN_MASTERY]={base=1, every=6, max=8}, 
	},
}

newEntity{ base = "BASE_STEAM_GIANT_GUNNER",
	name = "steam giant flameshot", color=colors.RED,
	desc = _t[[This steam giant carries a steamgun in each hand. The barrels appear to be flaming.]],
	resolvers.nice_tile{tall=1},
	level_range = {14, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(120,140),
	resolvers.auto_equip_filters("Gunslinger"),
	resolvers.equip{
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="ammo", subtype="shot", autoreq=true},
	},
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },
	ai_tactic = resolvers.tactic("ranged"),
	combat_armor = 12, combat_def = 6,
	ranged_project={[DamageType.FIRE] = resolvers.levelup(resolvers.mbonus(12, 8), 1, 0.8)},
	resolvers.talents{ 
		[Talents.T_SHOOT]=1, [Talents.T_RELOAD]=1,
		[Talents.T_WEAPON_COMBAT]={base=0, every=10, max=5},
		[Talents.T_STEAMGUN_MASTERY]={base=2, every=10, max=5},
		[Talents.T_COMBUSTIVE_BULLETS]={base=1, every=10, max=5}, 
	},
}

newEntity{ base = "BASE_STEAM_GIANT_GUNNER",
	name = "retaliator of Atmos", color=colors.LIGHT_RED,
	desc = _t[[This steam giant carries a steamgun in each hand. She is here to eliminate any and all aggression towards the Atmos tribe.]],
	resolvers.nice_tile{tall=1},
	level_range = {25, nil}, exp_worth = 1,
	female = true,
	rarity = 3,
	rank = 3,
	max_life = resolvers.rngavg(220,240), life_rating = 19,
	resolvers.auto_equip_filters("Gunslinger"),
	resolvers.equip{
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="ammo", subtype="shot", autoreq=true},
		{type="armor", subtype="heavy", autoreq=true},
	},
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },
	ai_tactic = resolvers.tactic("ranged"),
	
	combat_armor = 5, combat_def = 20,
	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]={base=2, every=8, max=5},
		[Talents.T_WEAPON_COMBAT]={base=3, every=8, max=5},
		[Talents.T_SHOOT]=1, [Talents.T_RELOAD]=1,
		[Talents.T_STEAMGUN_MASTERY]={base=4, every=7, max=9},
		[Talents.T_PERCUSSIVE_BULLETS]={base=3, every=10, max=8}, 
		[Talents.T_STATIC_SHOT]={base=3, every=10, max=8}, 
		[Talents.T_PINNING_SHOT]={base=3, every=10, max=8}, 
		[Talents.T_INTUITIVE_SHOTS]={base=3, every=10, max=8}, 
		[Talents.T_DISENGAGE]={base=3, every=10, max=8}, 
		[Talents.T_SLOW_MOTION]={base=3, every=10, max=8}, 
	},
}
