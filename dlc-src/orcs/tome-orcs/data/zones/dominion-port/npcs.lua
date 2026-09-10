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

load("/data-orcs/general/npcs/troll-pirates.lua", rarity(0))
load("/data-orcs/general/npcs/alligator.lua", rarity(0))
load("/data/general/npcs/rodent.lua", rarity(5))
load("/data/general/npcs/vermin.lua", rarity(2))
load("/data/general/npcs/snake.lua", rarity(3))
load("/data-orcs/general/npcs/yeti.lua", switchRarity"unused")

--load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_TROLL_PIRATE", define_as="KORBEK",
	name = "Admiral Korbek", color=colors.PURPLE, unique = true,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_troll_admiral_korbek.png", display_h=2, display_y=-1}}},
	desc = _t[[This old troll stands tall and proud in somewhat ornate clothing; it's clear he is an important figure. He holds in his right hand a wicked looking blade, and in his left hand what seems to be an antique handgun.]],
	level_range = {15, nil}, exp_worth = 1,
	allow_any_dual_weapons = 1, can_offshoot = 1, can_solo_dual_archery = 1,
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, TOOL=1, QUIVER=1 },
	resolvers.auto_equip_filters{ MAINHAND={type="weapon", not_properties={"twohanded"}},
		OFFHAND={type="weapon", subtype="steamgun"},
		QUIVER={type="ammo", subtype="shot"}
	},
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="ammo", subtype="shot", autoreq=true},
	},
	stamina_regen = 100, -- Infinite true grit
	resolvers.drops{chance=100, nb=1, {unique=true, not_properties={"lore"}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="KORBEK_GLASS", random_art_replace={chance=65}} },
	resolvers.drops{chance=100, nb=1, {defined="NOTE3"} },
	resolvers.inscriptions(1, {"wild infusion"}),
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",

	make_escort = {
		{type="giant", subtype="troll", name="troll pirate", number=4},
	},
	rank = 4,
	max_life = 250, life_rating = 15, fixed_rating = true,
	combat_armor = 10, combat_def = 15,
	steam_regen = 8,
	talent_cd_reduction={[Talents.T_SHOOT]=-2},
	resolvers.talents{
		[Talents.T_STEAM_POOL]=1,
		[Talents.T_SHOOT]=1,
		[Talents.T_RELOAD]=1,
		[Talents.T_DIRTY_FIGHTING]={base=1, every=6, max=7},
		[Talents.T_RUSH]={base=1, every=6, max=6},
		[Talents.T_STRAFE]={base=2, every=7, max=6},
		[Talents.T_STEAMGUN_MASTERY]={base=1, every=5, max=6},
		[Talents.T_WEAPONS_MASTERY]={base=1, every=5, max=6},
		[Talents.T_WEAPON_COMBAT]={base=1, every=5, max=6},
		[Talents.T_TRUE_GRIT]={base=1, every=5, max=6},
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_SNAKE",
	type = "reptile",
	name = "mutant snake", color=colors.GREEN, image="npc/green-snake.png",
	desc = _t[[This snake seems to... thrive... in the polluted water of the sewers.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(40,70),
	combat_armor = 3, combat_def = 11,
	combat = { dam=resolvers.levelup(7, 1, 0.7), atk=2, apr=10 },
	melee_project={[DamageType.CORRUPTED_BLOOD] = resolvers.levelup(resolvers.mbonus(12, 8), 1, 0.8)},

--	resolvers.talents{ {base=1, every=5, max=3} },
}

newEntity{ define_as = "YETI_BEHEMOTH",
	allow_infinite_dungeon = true, unique=true, rank=3.5,
	base = "BASE_NPC_YETI", color=colors.PURPLE,
	name = "Captured Yeti Behemoth",
	resolvers.nice_tile{tall=1},
	desc = _t[[This yeti towers over even the trolls. Blind rage maddens its eyes.]],
	level_range = {25, nil}, exp_worth = 2,
	rarity = false,
	max_life = 350, life_rating = 20, fixed_rating = true,
	combat_armor = 15, combat_def = 15, combat_armor_hardiness = 100,
	combat = { dam=resolvers.levelup(50, 1, 1.5), atk=resolvers.levelup(30, 1, 1), apr=3 },
	stats = { str=40, dex=25, con=20 },
	
	resolvers.talents{
		[Talents.T_ICE_CLAW]={base=3, every=5, max=10},
		[Talents.T_RUSH]={base=2, every=8, max=10},
		[Talents.T_AURA_OF_SILENCE]={base=3, every=8, max=10},
		[Talents.T_ANTIMAGIC_SHIELD]={base=3, every=8, max=10},
		[Talents.T_ALGID_RAGE]={base=3, every=8, max=10},
		[Talents.T_THICK_FUR]={base=3, every=8, max=10},
		[Talents.T_RESILIENT_BODY]={base=3, every=8, max=10},
	},
	
	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	
	resolvers.drops{chance=100, nb=1, {defined="YETI_BEHEMOTH_MUSCLE"} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
}
