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

load("/data-cults/general/npcs/corrupted_blobs.lua", rarity(5))
--load("/data/general/npcs/all.lua", rarity(4, 35))

newEntity{ define_as = "GODFEASTER",
	unique=true, rank=4,
	base = "BASE_NPC_BLOB", color=colors.PURPLE,
	name = "The Divine Writhing Mass",
	desc = _t[[Once the nervous system of the Maggot, it transformed into something... else after the Maggot ate some remains of a long dead god. If severed the Godfeaster will surely wither and die.]],
	resolvers.nice_tile{tall=1},
	level_range = {30, nil}, exp_worth = 2,
	rarity = false,
	max_life = resolvers.rngavg(270,300), life_rating = 18, fixed_rating = true,
	combat_armor = 7, combat_def = 0,
	combat = { dam=resolvers.levelup(9, 1, 1), atk=15, apr=6 },
	stats = { str=22, wil=22, mag=22 },
	size_category = 4,
	infravision = 10,
	instakill_immune = 1,
	immune_possession = 1,
	vim_regen = 8,
	insanity_regen = 10,
	
	resolvers.talents{
		[Talents.T_BONE_SPEAR]={base=4, every=5},
		[Talents.T_DARK_WHISPERS]={base=4, every=6},
		[Talents.T_BONE_GRAB]={base=4, every=7},
		[Talents.T_MUTATED_HAND]={base=4, every=7},
		[Talents.T_ATROPHY]={base=4, every=7},
		[Talents.T_SEVERED_THREADS]={base=4, every=7},
		[Talents.T_TEMPORAL_FEAST]={base=4, every=7},
		[Talents.T_TERMINUS]={base=4, every=7},
		[Talents.T_SPINE_OF_THE_WORLD]=1,
	},
	talent_cd_reduction = {
		[Talents.T_BONE_GRAB] = 10, -- He cant move, so he can grab !
	},
	
	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1 },
	ai_tactic = resolvers.tactic"ranged",
	
	resolvers.drops{chance=100, nb=1, {defined="INFUSED_CEREBRUM", random_art_replace={chance=50}} },
	resolvers.drops{chance=100, nb=1, {defined="GODFLESH"} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	on_die = function(self, who)
		game.zone.is_dead = true

		game:onLevelLoad("cults+godfeaster-1", function(zone, level)
			local g = zone.grid_list.GODFEASTER_PORTAL:clone()
			local oe = game.level.map(level.default_down.x, level.default_down.y, engine.Map.TERRAIN)
			if oe:attr("temporary") and oe.old_feat then
				oe.old_feat = g
			else
				level.map(level.default_down.x, level.default_down.y, level.map.TERRAIN, g)
			end
		end)
	end,
}

newEntity{ define_as = "MALYU",
	name = "Malyu",
	type = "humanoid", subtype = "shalore", female=true,
	display = "@", color=colors.LIGHT_BLUE,
	resolvers.nice_tile{tall=1},
	desc = _t[[This gritty adventurer saved you.]],
	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1 },
	stats = { str=35, dex=35, mag=35, con=35 },
	never_anger = true,
	level_range = {25, nil},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 6,
	rank = 3,
	exp_worth = 0,

	max_life = 150, life_regen = 4,
	life_rating = 15,
	combat_armor = 40, combat_def = 30,
	inc_damage = {all=-40},

	resolvers.equip{
		{type="weapon", subtype="greatsword", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="heavy", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="feet", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.talents{
		[Talents.T_ARCANE_COMBAT]={base=4, every=3},
		[Talents.T_ARCANE_FEED]={base=4, every=3},
		[Talents.T_ARCANE_DESTRUCTION]={base=4, every=3},
		[Talents.T_FIERY_HANDS]={base=4, every=3},
		[Talents.T_EARTHEN_BARRIER]={base=4, every=3},
		[Talents.T_SHOCK_HANDS]={base=4, every=3},
		[Talents.T_INNER_POWER]={base=4, every=3},
		[Talents.T_FLAME]={base=4, every=3},
		[Talents.T_LIGHTNING]={base=4, every=3},
		[Talents.T_EARTHEN_MISSILES]={base=4, every=3},
		[Talents.T_ARMOUR_TRAINING] = {base=4, every=3},
		[Talents.T_WEAPON_COMBAT] = {base=4, every=3},
		[Talents.T_HEAL] = {base=4, every=3},
		[Talents.T_AEGIS] = {base=4, every=3},
	},
	resolvers.sustains_at_birth(),
	resolvers.inscriptions(4, "infusion"),
}
