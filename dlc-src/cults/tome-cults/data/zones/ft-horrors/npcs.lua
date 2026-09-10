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

-- Load all possible horrors except aquatic as those need water and set them to no drops
-- The whole zone should feature 0 items
load("/data/general/npcs/horror.lua", function(e) e.no_drops = 1 end)
load("/data/general/npcs/horror-corrupted.lua", function(e) e.no_drops = 1 end)
load("/data/general/npcs/horror-undead.lua", function(e) 
	e.no_drops = 1
	e.never_anger = true
	if e.never_move then e.rarity = nil end  -- Avoid the boss getting blocked
	end)
load("/data/general/npcs/horror_temporal.lua", function(e) e.no_drops = 1 end)

-- Notable Countrs:  Darkness/temporal resist, heavy magic penetration, mobility, projectile disruption, debuffs (bad saves)
newEntity{ base = "BASE_NPC_HORROR", define_as = "THE_ONE_THAT_WRITES",
	unique = true, color=colors.VIOLET,
	name = "The One That Writes",
	desc = _t[[Even as this creature focuses its attention on you, many of its tentacles are preoccupied with writing letters onto sheets of strange, wispy parchment. With every word it finishes, the environment around you changes its shape, objects become more defined and patches of ground appear to be more detailed. You don't want to know the ending it has planned for your story.]],
	killer_message = _t"and written off the story",
	resolvers.nice_tile{tall=1},
	level_range = {20, nil}, exp_worth = 2,
	max_life = 330, life_rating = 25, fixed_rating = true,
	insanity_regen = 50,
	stats = { str=5, dex=20, cun=8, mag=30, wil=30, con=20 },
	rank = 5,
	size_category = 3,
	infravision = 20,
	instakill_immune = 1,
	stun_immune = 0.5,
	confusion_immune = 0.5,
	life_regen = 1,
	never_anger = true,

	no_difficulty_random_class = true,
	move_others = true,
	--not_power_source = {technique=true, technique_ranged=true, nature=true, antimagic=true},  -- Just caster/mindcaster

	combat_spellpower = resolvers.levelup(resolvers.rngavg(25, 110), 1, 2),

	invulnerable = 3,
	resists = {all = 40},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	no_drops = table.NIL_MERGE,
	resolvers.drops{chance=100, nb=1, {defined="FORBIDDEN_TOME_HOME"}, },

	resolvers.talents{
		[Talents.T_FROZEN_GROUND]={base=5, every=6},
		[Talents.T_NETHERFORCE]={base=5, every=6},

		[Talents.T_POWER_OVERWHELMING]={base=1, every=10},
		[Talents.T_ENTROPIC_GIFT]={base=5, every=6},  -- No friendlyfire/not blockable, CD10, low cast priority
		[Talents.T_REVERSE_ENTROPY]={base=5, every=6},

		[Talents.T_JINXED_TOUCH]={base=5, every=6},
		[Talents.T_PREORDAIN]={base=5, every=6},
		[Talents.T_LUCKDRINKER]={base=5, every=6},

		[Talents.T_REALITY_FRACTURE]={base=5, every=6},
		[Talents.T_QUANTUM_TUNNELLING]={base=5, every=6},
		[Talents.T_ZERO_POINT_ENERGY]={base=5, every=6},
		[Talents.T_PIERCE_THE_VEIL]={base=5, every=6},
		
		[Talents.T_SWITCH]={base=5, every=6},

		[Talents.T_VOID_STARS]={base=5, every=6},
		[Talents.T_ESSENCE_REAVE]={base=5, every=6},  -- No friendlyfire/not blockable, CD6

		[Talents.T_NETHERBLAST]={base=5, every=6},  -- No friendlyfire/not blockable, CD3
		[Talents.T_HALO_OF_RUIN]={base=5, every=6},
	},

	-- Sync priority with Power Overwhelming and Entropic Gift
	ai_talents = {
		[Talents.T_NETHERBLAST] = 20,
		[Talents.T_ESSENCE_REAVE] = 20,
		[Talents.T_ATTACK] = 0,
	},
	resolvers.sustains_at_birth(),

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", sense_radius=50, ai_target="target_simple_or_player_radius", ally_compassion = 0 },
	resolvers.inscriptions(4, "rune"),
}
