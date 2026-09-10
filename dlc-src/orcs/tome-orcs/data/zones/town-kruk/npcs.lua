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

local alter = function(e) e.attack_rarity, e.rarity = e.rarity, nil e.inc_damage = {all=-65} end
load("/data-orcs/general/npcs/steam-giant-warrior.lua", alter)
load("/data-orcs/general/npcs/steam-giant-gunner.lua", alter)
load("/data-orcs/general/npcs/whitehooves.lua", function(e) e.rarity = nil e.faction = "free-whitehooves" end)

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_KRUK_TOWN",
	type = "humanoid", subtype = "orc",
	display = "p", color=colors.WHITE,
	faction = "kruk-pride",
	anger_emote = "Catch @himher@!",

	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 3,

	life_rating = 10,
	rank = 2,
	size_category = 3,

	open_door = true,
	never_anger = 1,
	resolvers.racial(),
	resolvers.inscriptions(1, "infusion"),

	resolvers.talents{ [Talents.T_STEAM_POOL]=1 },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=12, dex=8, mag=6, con=10 },
}

newEntity{ base = "BASE_NPC_KRUK_TOWN",
	name = "orc guard", color=colors.LIGHT_UMBER,
	desc = _t[[A stern-looking guard, he will not let you disturb the town.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING] = {base=2, every=10, max=5},
		[Talents.T_RUSH]={base=1, every=7, max=5},
		[Talents.T_PERFECT_STRIKE]={base=1, every=10, max=5}
	},
}

newEntity{ base = "BASE_NPC_KRUK_TOWN",
	name = "orc gunslinger", color=colors.UMBER,
	desc = _t[[A nasty looking orc armed with double steamguns.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(50,60),
--	resolvers.talents{ [Talents.T_SHOOT]=1, },
	ai_state = { talent_in=2, },
	autolevel = "slinger",
	resolvers.equip{ {type="weapon", subtype="steamgun", autoreq=true},
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="ammo", subtype="shot", autoreq=true} 
	},
	resolvers.talents{
		[Talents.T_SHOOT] = 1,
		[Talents.T_STEAMGUN_MASTERY] = {base=0, every=8, max=5},
	},
}

newEntity{ define_as = "FRALOR",
	allow_infinite_dungeon = true,
	base = "BASE_STEAM_GIANT_WARRIOR",
	name = "Commander Fralor", color=colors.PURPLE, unique = true,
	resolvers.nice_tile{tall=1},
	desc = _t[[This heavily armored steam giant carries a huge battleaxe, swinging it menacingly towards you.]],
	level_range = {6, nil}, exp_worth = 1,
	rarity = false, rank = 4,
	max_life = 200, life_rating = 16, fixed_rating = true,

	resolvers.drops{chance=100, nb=1, {defined="YETI_MIND_CONTROLLER", random_art_replace={chance=70}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	
	resolvers.equip{
		{type="weapon", subtype="battleaxe", autoreq=true},
	},
	combat_armor = 8, combat_def = 0,
	ai = "tactical", ai_state = { talent_in=3, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	inc_damage = {all=-30},
	
	resolvers.talents{
		[Talents.T_WEAPON_COMBAT]={base=1, every=5, max=5},
		[Talents.T_WEAPONS_MASTERY]={base=0, every=7, max=5},
		[Talents.T_BATTLE_SHOUT]={base=2, every=8, max=5},
		[Talents.T_UNSTOPPABLE]={base=1, every=9, max=5}, 
		[Talents.T_TINKER_SPRING_GRAPPLE]={base=1, every=9, max=5}, 
	},
	
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_MINOTAUR_UNDEAD", define_as = "METASH",
	name = "Metash the Maulotaur", color=colors.SLATE,
	desc = _t[[This big undead minotaur is carrying a nasty looking hammer, imbued with lightning.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_minotaur_whitehoof_maulotaur.png", display_h=2, display_y=-1}}},
	level_range = {12, nil}, exp_worth = 1,
	rarity = false,
	combat_armor = 10, combat_def = 7,
	resolvers.equip{ {type="weapon", subtype="greatmaul", forbid_power_source={antimagic=true}, autoreq=true} },

	autolevel = "warriormage",
	resolvers.talents{
		[Talents.T_SHOCK_HANDS]={base=3, every=8, max=6},
		[Talents.T_LIGHTNING]={base=2, every=10, max=6},
		[Talents.T_ARCANE_COMBAT]={base=2, every=10, max=6},
	},

	can_talk = "orcs+metash",
}
