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

load("/data-orcs/general/npcs/steam-giant-warrior.lua")
load("/data-orcs/general/npcs/steam-giant-gunner.lua")
load("/data-orcs/general/npcs/steam-spiders.lua")
load("/data/general/npcs/horror.lua")
load("/data/general/npcs/plant.lua", switchRarity("ground_rarity"))
load("/data-orcs/general/npcs/yeti.lua", switchRarity"unused")

--load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "PARMOR",
	base = "BASE_STEAM_GIANT_WARRIOR", female = true,
	name = "Haze Commander Parmor", color=colors.PURPLE, unique = true,
	desc = _t[[The Commander of the G.E.M. this noble looking giant looks down upon you in contempt. She wields two huge rotating saws still covered in various horror entrails.]],
	resolvers.nice_tile{tall=1},
	level_range = {36, nil}, exp_worth = 2,
	rarity = false, rank = 5,
	max_life = 500, life_rating = 19, fixed_rating = true,
	resolvers.auto_equip_filters("Sawbutcher"),
	resolvers.equip{
		{type="weapon", subtype="steamsaw", autoreq=true},
		{type="weapon", subtype="steamsaw", autoreq=true},
		{type="armor", subtype="massive", defined="TINKER_POWER_ARMOUR5", never_drop=true, autoreq=true},
		{type="armor", subtype="cloak", autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {defined="POWER_ARMOUR_SCHEMATIC"}},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"}},

	combat_armor = 0, combat_def = 5,
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },

	steam_regen = 60,
	
	resolvers.talents{ 
		[Talents.T_ARMOUR_TRAINING] = {base=3, every=5, max=8},
		[Talents.T_WEAPON_COMBAT]={base=4, every=4, max=10}, 
		[Talents.T_STEAMSAW_MASTERY]={base=4, every=4, max=10}, 
		[Talents.T_TO_THE_ARMS]={base=4, every=4, max=10}, 
		[Talents.T_CONTINUOUS_BUTCHERY]={base=4, every=4, max=10}, 
		[Talents.T_EXPLOSIVE_SAW]={base=4, every=4, max=10}, 
		[Talents.T_MOW_DOWN]={base=4, every=4, max=10}, 
		[Talents.T_AUTOMATED_CLOAK_TESSELLATION]={base=4, every=4, max=10}, 
		[Talents.T_EXPLOSIVE_STEAM_ENGINE]={base=4, every=4, max=10}, 
		[Talents.T_LINGERING_CLOUD]={base=4, every=4, max=10}, 
		[Talents.T_TREMOR_ENGINE]={base=4, every=4, max=10}, 
		[Talents.T_SEISMIC_ACTIVITY]={base=4, every=4, max=10}, 
		[Talents.T_SUBCUTANEOUS_METALLISATION]={base=4, every=4, max=10}, 
		[Talents.T_GRINDING_SHIELD]={base=4, every=4, max=10}, 
		[Talents.T_SAWWHEELS]={base=4, every=4, max=10}, 
		[Talents.T_BATTLEFIELD_VETERAN]={base=4, every=4, max=10}, 
		[Talents.T_OVERHEAT_SAWS]={base=4, every=4, max=10}, 
		[Talents.T_SPINAL_BREAK]={base=4, every=4, max=10}, 
	},
	resolvers.sustains_at_birth(),
	
	on_die = function(self, who)
		game.player:setQuestStatus("orcs+gem", engine.Quest.COMPLETED)
	end,
}

--
-- ideas:
-- Mole Defense Drone: a mechanical spider that jumps to your face
-- 
--
--
--

newEntity{ define_as = "MECH_YETI",
	allow_infinite_dungeon = true, unique=true, rank=3.5,
	base = "BASE_NPC_YETI", color=colors.PURPLE,
	name = "Half-Mechanized Yeti",
	resolvers.nice_tile{tall=1},
	desc = _t[[Whoever tortured and tormented this yeti did an amazing job of pain and destruction. As you gaze upon its fur you notice several vital spots reinforced with stralite plating. One of its arms has been replaced with a steamsaw.]],
	level_range = {40, nil}, exp_worth = 2,
	rarity = false,
	max_life = 500, life_rating = 20, fixed_rating = true,
	combat_armor = 35, combat_def = 15, combat_armor_hardiness = 70,
	combat = { dam=resolvers.levelup(50, 1, 1.5), atk=resolvers.levelup(30, 1, 1), apr=3 },
	stats = { str=40, dex=25, con=20 },
	faction = "neutral",
	cant_be_moved = 1,
	
	resolvers.inscription("IMPLANT:_STEAM_GENERATOR", {cooldown=32, power=8}),
	resolvers.auto_equip_filters("Sawbutcher"),
	resolvers.equip{
		{type="weapon", subtype="steamsaw", autoreq=true},
		{type="weapon", subtype="steamsaw", autoreq=true},
	},

	resolvers.talents{
		[Talents.T_WEAPON_COMBAT]={base=4, every=10, max=5},
		[Talents.T_STEAMSAW_MASTERY]={base=4, every=10, max=5},
		[Talents.T_ICE_CLAW]={base=3, every=5, max=10},
		[Talents.T_RUSH]={base=2, every=8, max=10},
		[Talents.T_ALGID_RAGE]={base=3, every=8, max=10},
		[Talents.T_THICK_FUR]={base=3, every=8, max=10},
		[Talents.T_RESILIENT_BODY]={base=3, every=8, max=10},
		[Talents.T_CONTINUOUS_BUTCHERY]={base=3, every=8, max=10},
		[Talents.T_GRINDING_SHIELD]={base=3, every=8, max=10},
		[Talents.T_PUNISHMENT]={base=3, every=8, max=10},
		[Talents.T_BATTLEFIELD_VETERAN]={base=3, every=8, max=10},
		[Talents.T_OVERHEAT_SAWS]={base=3, every=8, max=10},
	},
	
	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	
	resolvers.drops{chance=100, nb=1, {defined="YETI_MECH_MUSCLE"} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
}
