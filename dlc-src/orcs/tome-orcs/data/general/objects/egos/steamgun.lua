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
local Stats = require("engine.interface.ActorStats")
local DamageType = require "engine.DamageType"

load("/data/general/objects/egos/ranged.lua")

newEntity{
	power_source = {technique=true},
	name = " of tinkering (#STATBONUS#)", suffix=true, instant_resolve=true,
	keywords = {tinker=true},
	level_range = {20, 50},
	rarity = 7,
	cost = 7,
	wielder = {
		combat_steampower = resolvers.mbonus_material(10, 5),
		inc_stats = { [Stats.STAT_CUN] = resolvers.mbonus_material(6, 2) },
	},
}

newEntity{
	power_source = {technique=true},
	name = "gunslinger's ", prefix=true, instant_resolve=true,
	keywords = {gunslinger=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 24,
	cost = 40,
	wielder = {
		talent_cd_reduction={
			[Talents.T_STRAFE]=2,
			[Talents.T_TRICK_SHOT]=2,
			[Talents.T_DOUBLE_SHOTS]=2,
		},
		combat_steampower = resolvers.mbonus_material(10, 5),
		inc_damage={ [DamageType.PHYSICAL] = resolvers.mbonus_material(14, 8), },
	},
}

newEntity{
	power_source = {technique=true},
	name = "strafer's ", prefix=true, instant_resolve=true,
	keywords = {strafer=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 15,
	wielder={
		combat_atk = resolvers.mbonus_material(10, 5),
		talent_cd_reduction={[Talents.T_STRAFE]=2},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of life draining", suffix=true, instant_resolve=true,
	keywords = {draining=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	combat = {
		ranged_project={[DamageType.DRAINLIFE] = resolvers.mbonus_material(20, 5)},
	},
}

newEntity{
	power_source = {nature=true},
	name = "overgrown ", prefix=true, instant_resolve=true,
	keywords = {overgrown=true},
	level_range = {1, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		life_regen = resolvers.mbonus_material(20, 5, function(e, v) v=v/10 return 0, v end),
	},
	combat = {
		talent_on_hit = { [Talents.T_OVERGROWTH] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=10} },
	},
}


