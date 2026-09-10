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
	define_as = "BASE_STEAMGUN",
	slot = "MAINHAND", offslot = "OFFHAND",
	power_source = {steam=true},
	type = "weapon", subtype="steamgun",
	display = "}", color=colors.UMBER, image = resolvers.image_material("steamgun", "metal"),
	moddable_tile = resolvers.orcs_moddable_tile("steamgun"),
	encumber = 4,
	rarity = 7,
	metallic = true,
	combat = { talented = "steamgun", travel_speed=6, physspeed = 1, accuracy_effect="mace", sound = "actions/dual-steamgun", sound_miss = "actions/dual-steamgun", use_resources={steam = 2} },
	archery_kind = "steamgun",
	archery = "sling", -- Same ammunition as slings
	require = { talent = { Talents.T_SHOOT, Talents.T_STEAM_POOL}, },
	proj_image = resolvers.image_material("shot_s", "metal"),
	desc = _t[[Steamguns use bursts of steam directly injected in the barrel to propel metal shots with great force.]],
	randart_able = "/data/general/objects/random-artifacts/ranged.lua",
	egos = "/data-orcs/general/objects/egos/steamgun.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_STEAMGUN", define_as = "STEAMGUN_BASE1",
	name = "iron steamgun", short_name = "iron",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	cost = 5,
	material_level = 1,
	combat = {
		range = 6,
		apr = 3,
	},
}

newEntity{ base = "BASE_STEAMGUN", define_as = "STEAMGUN_BASE2",
	name = "steel steamgun", short_name = "steel",
	level_range = {10, 20},
	require = { stat = { dex=16 }, },
	cost = 10,
	material_level = 2,
	combat = {
		range = 7,
		apr = 6,
	},
}

newEntity{ base = "BASE_STEAMGUN", define_as = "STEAMGUN_BASE3",
	name = "dwarven-steel steamgun", short_name = "d.steel",
	level_range = {20, 30},
	require = { stat = { dex=24 }, },
	cost = 15,
	material_level = 3,
	combat = {
		range = 8,
		apr = 9,
	},
}

newEntity{ base = "BASE_STEAMGUN", define_as = "STEAMGUN_BASE4",
	name = "stralite steamgun", short_name = "stralite",
	level_range = {30, 40},
	require = { stat = { dex=35 }, },
	cost = 25,
	material_level = 4,
	combat = {
		range = 9,
		apr = 12,
	},
}

newEntity{ base = "BASE_STEAMGUN", define_as = "STEAMGUN_BASE5",
	name = "voratun steamgun", short_name = "voratun",
	level_range = {40, 50},
	require = { stat = { dex=48 }, },
	cost = 35,
	material_level = 5,
	combat = {
		range = 10,
		apr = 15,
	},
}
