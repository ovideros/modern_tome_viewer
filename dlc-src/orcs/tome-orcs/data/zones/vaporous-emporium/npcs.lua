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

load("/data-orcs/general/npcs/steam-giant-warrior.lua", rarity(0))
load("/data-orcs/general/npcs/steam-giant-gunner.lua", rarity(0))
load("/data-orcs/general/npcs/domestic-yeti.lua", rarity(0))

--load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "BASE_STEAM_GIANT_CITIZEN",
	type = "giant", subtype = "steam",
	display = "P", color=colors.GREY,
	desc = _t[[An unarmed steam giant.]],
	resolvers.drops{chance=10, nb=1, {type="money"} },
	level_range = {1, 15}, exp_worth = 1,
	civilian = 1,
	max_life = 100,
	stats = { str=20 },
	life_rating = 15,
	rank = 2,
	size_category = 4,
	infravision = 10,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="flee_dmap", },

	emote_random = resolvers.emote_random{ chance=0.8,
		_t"Guards!", _t"Help!"
	},
}

newEntity{
	base = "BASE_STEAM_GIANT_CITIZEN",
	name = "steam giant commoner",
	resolvers.nice_tile{tall=1},
	rarity = 4,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_steam_steam_giant_commoner_worker_male.png", display_h=2, display_y=-1}}},
	desc = _t[[Pockets of gold jingle around the waist of this giant.]],
	emote_random = resolvers.emote_random{ chance=0.8,
		"You won't get my gold!"
	},
}

newEntity{
	base = "BASE_STEAM_GIANT_CITIZEN",
	name = "steam giant commoner", female = 1,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_steam_steam_giant_commoner_female.png", display_h=2, display_y=-1}}},
	rarity = 4,
	resolvers.drops{chance=100, nb=1, {type="money"} },
	desc = _t[[Pockets of gold jingle around the waist of this giant.]],
	emote_random = resolvers.emote_random{ chance=0.8,
		_t"You won't get my gold!"
	},
}

newEntity{
	base = "BASE_STEAM_GIANT_CITIZEN",
	name = "steam giant scribe",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_steam_steam_giant_shopkeeper.png", display_h=2, display_y=-1}}},
	rarity = 3,
	resolvers.drops{chance=100, nb=1, {type="money"} },
	desc = _t[[This well-dressed giant is is covered in ink smudges and looks somewhat alarmed.]],
	emote_random = resolvers.emote_random{ chance=0.8,
		_t"Stay back, I'm warning you!"
	},
	ingredient_on_death = "SQUID_INK"
}

-- newEntity{
-- 	base = "BASE_STEAM_GIANT_CITIZEN",
-- 	name = "steam giant shopkeeper",
-- 	resolvers.nice_tile{tall=1},
-- 	rarity = 3,
-- 	resolvers.drops{chance=100, nb=1, {type="money"} },
-- 	desc = _t[[Pockets of gold jingle around the waist of this giant.]],
-- 	emote_random = resolvers.emote_random{ chance=0.8,
-- 		"You won't get my gold!"
-- 	},
-- }

-- newEntity{
-- 	base = "BASE_STEAM_GIANT_CITIZEN",
-- 	name = "steam giant child",
-- 	resolvers.nice_tile{tall=1},
-- 	rarity = 2,
-- 	desc = _t[[This steam giant is much smaller than those around it, though still taller than yourself.]],
-- 	make_escort = {
-- 		{type="giant", subtype="steam", name="steam giant citizen", number=1, no_subescort=true}, --spawns with a parent
-- 	},
-- 	emote_random = resolvers.emote_random{ chance=0.8,
-- 		"*sobs*"
-- 	},
-- }

newEntity{ define_as = "TALOSIS",
	allow_infinite_dungeon = true,
	base = "BASE_STEAM_GIANT_GUNNER",
	name = "High Guard Talosis", color=colors.PURPLE, unique = true,
	resolvers.nice_tile{tall=1},
	desc = _t[[This heavily armored steam giant carries a gun in each hand. The gun in his right hand is ornate and well worn.]],
	level_range = {6, nil}, exp_worth = 1,
	rarity = false, rank =4,
	max_life = 200, life_rating = 16, fixed_rating = true,
	resolvers.auto_equip_filters("Gunslinger"),
	resolvers.equip{
		{type="weapon", subtype="steamgun", defined="TALOSIS_GUN", random_art_replace={chance=75}, autoreq=true},
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="ammo", subtype="shot", autoreq=true},
	},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	combat_armor = 12, combat_def = 8,
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",

	inc_damage = {all=-30},
	
	resolvers.talents{ 
		[Talents.T_SHOOT] = 1,
		[Talents.T_WEAPON_COMBAT] = {base=1, every=5, max=5},
		[Talents.T_STRAFE]={base=1, every=8, max=5},
		-- [Talents.T_EVASIVE_SHOTS]={base=1, every=8, max=5}, -- too hard for low levels probably
		[Talents.T_STEAMGUN_MASTERY]={base=1, every=9, max=6}, 
	},

	-- Override the recalculated AI tactics to avoid problematic kiting in the early game
	low_level_tactics_override = {escape=0},
	
	resolvers.sustains_at_birth(),

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("orcs+start-orc", engine.Quest.COMPLETED, "vaporous-emporium")
		if not game.zone.dead_civilian then
			world:gainAchievement("ORCS_MERCY", game.player)
		end
	end,
}
