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
load("/data-orcs/general/npcs/steam-giant-arcane.lua", rarity(0))
load("/data-orcs/general/npcs/steam-spiders.lua", rarity(0))

load("/data-orcs/general/npcs/titan.lua", function(e) e.rarity = nil end)

--load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

local on_die_council = function(self, who)
	game.player:setQuestStatus("orcs+palace", engine.Quest.COMPLETED, self.define_as)
end

newEntity{ define_as = "COUNCIL_BASE",
	type = "giant", subtype = "steam",
	display = 'P', color = colors.VIOLET,
	level_range = {50, nil}, exp_worth = 1,
	rarity = false, rank = 5,
	max_life = 100, life_rating = 18, fixed_rating = true,
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"}},
	combat_armor = 0, combat_def = 5,
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	steam_regen = 60,
	resolvers.sustains_at_birth(),
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, FEET=1, QUIVER=1, CLOAK=1 },
	is_council_member = true,
	size_category = 4,

	on_die = on_die_council,	
}

newEntity{ define_as = "COUNCIL1", base = "COUNCIL_BASE", female = true,
	name = "Council Member Nashal", color=colors.PURPLE, unique = true,
	resolvers.nice_tile{tall=1},
	desc = _t[[The noble features on the face of this giantess contrast heavily with the evil grin she carries and the huge rotating saws on her arms.]],
	resolvers.auto_equip_filters("Sawbutcher"),
	resolvers.equip{
		{type="weapon", subtype="steamsaw", autoreq=true},
		{type="weapon", subtype="steamsaw", autoreq=true},
		{type="armor", subtype="massive", autoreq=true},
		{type="armor", subtype="cloak", autoreq=true},
	},
	-- resolvers.drops{chance=100, nb=1, {defined="POWER_ARMOUR_SCHEMATIC"}},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"}},

	autolevel = "warrior",
	resolvers.talents{ 
		[Talents.T_ARMOUR_TRAINING]={base=5, every=6, max=8},
		[Talents.T_WEAPON_COMBAT]={base=7, every=4}, 
		[Talents.T_STEAMSAW_MASTERY]={base=7, every=4}, 
		[Talents.T_TO_THE_ARMS]={base=7, every=4}, 
		[Talents.T_CONTINUOUS_BUTCHERY]={base=7, every=4}, 
		[Talents.T_EXPLOSIVE_SAW]={base=7, every=4}, 
		[Talents.T_MOW_DOWN]={base=7, every=4}, 
		[Talents.T_AUTOMATED_CLOAK_TESSELLATION]={base=7, every=4}, 
		[Talents.T_EXPLOSIVE_STEAM_ENGINE]={base=7, every=4}, 
		[Talents.T_LINGERING_CLOUD]={base=7, every=4}, 
		[Talents.T_TREMOR_ENGINE]={base=7, every=4}, 
		[Talents.T_SEISMIC_ACTIVITY]={base=7, every=4}, 
		[Talents.T_GRINDING_SHIELD]={base=7, every=4}, 
		[Talents.T_SAWWHEELS]={base=7, every=4}, 
		[Talents.T_BATTLEFIELD_VETERAN]={base=7, every=4}, 
		[Talents.T_OVERHEAT_SAWS]={base=5, every=4, max=10}, 

		[Talents.T_SPINAL_BREAK]=1, 
		[Talents.T_PAIN_ENHANCEMENT_SYSTEM]=1, 
	},
}

newEntity{ define_as = "COUNCIL2", base = "COUNCIL_BASE",
	name = "Council Member Tormak", color=colors.PURPLE, unique = true,
	resolvers.nice_tile{tall=1},
	desc = _t[[A master in all things arcane, Tormak stands in your way, steadfast in his resolution to crush you under his mighty spells.]],
	negative_regen = 5,
	positive_regen = 5,
	mana_regen = 5,

	resolvers.auto_equip_filters("Archmage"),
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
		{type="armor", subtype="massive", autoreq=true},
		{type="armor", subtype="cloak", autoreq=true},
	},
	resolvers.attachtinkerbirth{ id=true,
		{defined="TINKER_MANA_COIL5"},
	},
	resolvers.drops{chance=100, nb=1, {unique=true} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"}},

	autolevel = "caster",
	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]={base=3, every=6, max=8},
		[Talents.T_STAFF_MASTERY]={base=7, every=4}, 
		[Talents.T_PHANTASMAL_SHIELD]={base=7, every=4}, 
		[Talents.T_BLUR_SIGHT]={base=7, every=4}, 
		[Talents.T_CIRCLE_OF_DEATH]={base=7, every=4}, 
		[Talents.T_EARTHEN_BARRIER]={base=7, every=4}, 
		[Talents.T_INNER_POWER]={base=7, every=4}, 
		[Talents.T_CURSE_OF_DEATH]={base=7, every=4}, 
		[Talents.T_LUNAR_ORB]={base=7, every=4}, 
		[Talents.T_GALACTIC_PULSE]={base=7, every=4}, 
		[Talents.T_SOLAR_WIND]={base=7, every=4}, 
		[Talents.T_LUCENT_WRATH]={base=7, every=4}, 
		[Talents.T_PLASMA_BOLT]={base=7, every=4}, 
		[Talents.T_PHASE_DOOR]={base=7, every=4}, 
		[Talents.T_CREPUSCULE]={base=7, every=4}, 
	},
}

newEntity{ define_as = "COUNCIL3", base = "COUNCIL_BASE",
	name = "Council Member Pendor", color=colors.PURPLE, unique = true,
	resolvers.nice_tile{tall=1},
	desc = _t[[Wielding two huge steamguns this giant is amazingly elusive and agile for his size. Oh and very deadly!]],
	resolvers.auto_equip_filters("Gunslinger"),
	resolvers.equip{
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="armor", subtype="light", autoreq=true},
		{type="armor", subtype="cloak", autoreq=true},
		{type="ammo", subtype="shot", autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {unique=true} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"}},

	autolevel = "slinger",
	resolvers.talents{ 
		[Talents.T_SHOOT]=1, 
		[Talents.T_WEAPON_COMBAT]={base=7, every=4}, 
		[Talents.T_STEAMGUN_MASTERY]={base=7, every=4}, 
		[Talents.T_AUTOMATED_CLOAK_TESSELLATION]={base=7, every=4}, 
		[Talents.T_CLOAK_GESTURE]={base=7, every=4}, 
		[Talents.T_CLOAK]={base=7, every=4}, 
		[Talents.T_SLIP_AWAY]={base=7, every=4}, 
		[Talents.T_AGILE_GUNNER]={base=7, every=4}, 
		[Talents.T_AWESOME_TOSS]={base=7, every=4}, 
		[Talents.T_UNCANNY_RELOAD]={base=7, every=4}, 
		[Talents.T_STATIC_SHOT]={base=7, every=4}, 
		[Talents.T_EVASIVE_SHOTS]={base=7, every=4}, 
		[Talents.T_PERCUSSIVE_BULLETS]={base=7, every=4}, 
	},
}

newEntity{ define_as = "COUNCIL4", base = "COUNCIL_BASE", female = true,
	name = "Council Member Palaquie", color=colors.PURPLE, unique = true,
	resolvers.nice_tile{tall=1},
	desc = _t[[Standing proud, the giantess wields both a steamgun and a mindstar, as the bullets fly you can feel a powerful mental pressure on your mind, numbing you.]],
	resolvers.auto_equip_filters("Psyshot"),
	resolvers.equip{
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="weapon", subtype="mindstar", autoreq=true},
		{type="armor", subtype="light", autoreq=true},
		{type="armor", subtype="cloak", autoreq=true},
		{type="ammo", subtype="shot", autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {unique=true} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"}},

	autolevel = "rogue",
	resolvers.talents{ 
		[Talents.T_SHOOT]=1, 
		[Talents.T_WEAPON_COMBAT]={base=6, every=4}, 
		[Talents.T_GESTALT]={base=7, every=4}, 
		[Talents.T_IMPROVED_GESTALT]={base=7, every=4}, 
		[Talents.T_FORCED_GESTALT]={base=7, every=4}, 
		[Talents.T_CONDENSATE]={base=7, every=4}, 
		[Talents.T_NEGATIVE_BIOFEEDBACK]={base=7, every=4}, 
		[Talents.T_MECHANICAL_ARMS]={base=7, every=4}, 
		[Talents.T_LUCID_SHOT]={base=7, every=4}, 
		[Talents.T_NO_HOPE]={base=7, every=4}, 
		[Talents.T_PSYSHOT]={base=7, every=4}, 
		[Talents.T_BOILING_SHOT]={base=7, every=4}, 
		[Talents.T_VACUUM_SHOT]={base=7, every=4}, 
		[Talents.T_MOLTEN_IRON_BLOOD]={base=7, every=4}, 
	},
}

newEntity{ define_as = "COUNCIL5", base = "GARGANTUAN_SHERTAN",
	name = "Council Member Tantalos", color=colors.PURPLE, unique = true,
	desc = _t[[It seems like a safe assumption that the highest elected official of the Atmos Tribe was not always a hideous, titanic abomination, reminiscent of the few images of Sher'Tul you have seen, with a combination of unnatural appearance and sickening gurgling noises that revulses you on every level from intellectual and moral disgust, all the way down to a primal instinct that roars wordlessly in your mind with a fear and hatred older than any language.  If he was, his campaign's gerrymandering talents must have been legendary.]],
	life_rating = 40, rank = 5,
	
	resolvers.drops{chance=100, nb=1, {defined="TWISTED_BLADE"} },

	on_die = on_die_council,	
}

newEntity{
	define_as = "DEFENSIVE_TURRET",
	type = "construct", subtype = "mechanical",
	name = "steam defence turret",
	resolvers.nice_tile{tall=1},
	display = "T", color=colors.RED,
	faction = "atmos-tribe",
	repairable = 1,
	level_range = {50, nil},
	desc = _t[[This appears to be mechanized pedestal.
Two steamguns mounted on its top constantly swivel back and forth, seeking enemies of the Atmos.]],
	combat = { dam=resolvers.levelup(5, 1, 0.7), atk=7, apr=1 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, CLOAK=1, QUIVER=1 },
	resolvers.equip{
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="ammo", subtype="shot", autoreq=true},
	},
	resolvers.drops{chance=10, nb=1, {type="gem"} },
	resolvers.drops{chance=1, nb=1, {type="scroll", subtype="schematic"} },
	infravision = 10,

	steam_regen = 30,

	max_life = 1000, life_rating = 20,
	rank = 3,
	size_category = 2,

	negative_status_effect_immune = 1,
	no_breath = 1,
	turret_rarity = 1,
	never_move = 1,
	infravision = 20,

	autolevel = "rogue",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
	stats = { str=15, dex=15, con=16 },
	power_source = {steamtech=true},

	resolvers.talents{ [Talents.T_STEAM_POOL]=1, [Talents.T_SHOOT]=1, [Talents.T_RELOAD]=1,
		[Talents.T_WEAPON_COMBAT]={base=5, every=5, max=15},
		[Talents.T_UNCANNY_RELOAD]={base=5, every=5, max=15},
		[Talents.T_STEAMGUN_MASTERY]={base=5, every=5, max=15}, 
		[Talents.T_COMBUSTIVE_BULLETS]={base=5, every=5, max=15}, 
		[Talents.T_PERCUSSIVE_BULLETS]={base=5, every=5, max=15}, 
		[Talents.T_NET_PROJECTOR]={base=5, every=5, max=15}, 
		[Talents.T_DOUBLE_SHOTS]={base=5, every=5, max=15}, 
	},
}
