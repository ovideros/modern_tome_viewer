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

local Talents = require "engine.interface.ActorTalents"

newEntity{
	define_as = "BASE_STEAMSAW",
	slot = "MAINHAND", offslot = "OFFHAND", dual_wieldable = true,
	type = "weapon", subtype="steamsaw",
	power_source = {steam=true},
	add_name = " (#COMBAT#)",
	display = "/", color=colors.SLATE, image = resolvers.image_material("steamsaw", "metal"),
	moddable_tile = resolvers.orcs_moddable_tile("steamsaw"),
	encumber = 3,
	rarity = 3,
	metallic = true,
	require = { talent = {Talents.T_STEAM_POOL}},
	fixed_randart_damage_type = true,
	shield_normal_combat = true,
	combat = { talented = "steamsaw", accuracy_effect="axe", damtype=DamageType.PHYSICALBLEED, damrange = 1.5, physspeed = 1, sound = {"actions/saw", pitch=1, vol=1}, sound_miss = {"actions/saw", pitch=1, vol=1}, use_resources={steam = 1}},
	desc = _t[[Steamsaws use steam pressure to rotate a serrated metal blade at high speed.
Those struck suffer severe lacerations and bleed for 10% of the damage done per turn for 5 turns (stacking).
They can be wielded in the main or off hand.
Vrmmmmm!]],
	randart_able = "/data-orcs/general/objects/random-artifacts/steamsaw.lua",
	egos = "/data-orcs/general/objects/egos/steamsaw.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_STEAMSAW", define_as = "STEAMSAW_BASE1",
	name = "iron steamsaw", short_name = "iron",
	level_range = {1, 10},
	require = { stat = { str=11 }, },
	cost = 5,
	material_level = 1,
	combat = {
		dam = resolvers.rngavg(9,12),
		physcrit = 1.5,
		dammod = {str=1},
		block = resolvers.rngavg(7, 15),
	},
	wielder = {
		combat_armor = 2,
		combat_def = 2,
		fatigue = 4,
		learn_talent = { [Talents.T_BLOCK] = 1, },
	},
}

newEntity{ base = "BASE_STEAMSAW", define_as = "STEAMSAW_BASE2",
	name = "steel steamsaw", short_name = "steel",
	level_range = {10, 20},
	require = { stat = { str=16 }, },
	cost = 10,
	material_level = 2,
	combat = {
		dam = resolvers.rngavg(11,17),
		physcrit = 2,
		dammod = {str=1},
		block = resolvers.rngavg(19, 27),
	},
	wielder = {
		combat_armor = 3,
		combat_def = 4,
		fatigue = 6,
		learn_talent = { [Talents.T_BLOCK] = 1, },
	},
}

newEntity{ base = "BASE_STEAMSAW", define_as = "STEAMSAW_BASE3",
	name = "dwarven-steel steamsaw", short_name = "d.steel",
	level_range = {20, 30},
	require = { stat = { str=24 }, },
	cost = 15,
	material_level = 3,
	combat = {
		dam = resolvers.rngavg(17,26),
		physcrit = 3,
		dammod = {str=1},
		block = resolvers.rngavg(40, 55),
	},
	wielder = {
		combat_armor = 4,
		combat_def = 6,
		fatigue = 8,
		learn_talent = { [Talents.T_BLOCK] = 2, },
	},
}

newEntity{ base = "BASE_STEAMSAW", define_as = "STEAMSAW_BASE4",
	name = "stralite steamsaw", short_name = "stralite",
	level_range = {30, 40},
	require = { stat = { str=35 }, },
	cost = 25,
	material_level = 4,
	combat = {
		dam = resolvers.rngavg(28,35),
		physcrit = 4,
		dammod = {str=1},
		block = resolvers.rngavg(60, 80),
	},
	wielder = {
		combat_armor = 5,
		combat_def = 8,
		fatigue = 10,
		learn_talent = { [Talents.T_BLOCK] = 2, },
	},
}

newEntity{ base = "BASE_STEAMSAW", define_as = "STEAMSAW_BASE5",
	name = "voratun steamsaw", short_name = "voratun",
	level_range = {40, 50},
	require = { stat = { str=48 }, },
	cost = 35,
	material_level = 5,
	combat = {
		dam = resolvers.rngavg(38,42),
		physcrit = 5,
		dammod = {str=1},
		block = resolvers.rngavg(85, 115),
	},
	wielder = {
		combat_armor = 6,
		combat_def = 10,
		fatigue = 12,
		learn_talent = { [Talents.T_BLOCK] = 3, },
	},
}
