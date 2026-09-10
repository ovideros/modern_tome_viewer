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

load("/data-orcs/general/objects/objects.lua")

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

newEntity{ base = "BASE_LIGHT_ARMOR", define_as = "PRESSURE_COMBAT_SUIT",
	power_source = {steam=true, technique=true},
	unique = true,
	name = "Pressure-enhanced Slashproof Combat Suit", color = colors.GREY, image = "object/artifact/p_e_s_c_suit.png",
	moddable_tile = "special/upper_p_e_s_c_suit", moddable_tile2 = "special/lower_p_e_s_c_suit", moddable_tile_big = true,
	unided_name = _t"steam-enhanced leather coat",
	desc = _t[[A simple leather armour of excellent facture that has been craftily enhanced with hidden miniature steam engines to enhance reflexes and provide safety features.]],
	level_range = {10, 30},
	rarity = 50,
	cost = 350,
	require = { stat = { str=16 }, },
	material_level = 3,
	wielder = {
		combat_def=14,
		combat_armor=12,
		inc_stats = { [Stats.STAT_DEX] = 8, },
		combat_crit_reduction = 7,
	},
	special_desc = function(self) return _t"When you take a hit of more than 10% of your total life the suit's motors activate for the next turn, displacing you before any blow could hit you." end,
	callbackOnHit = function(self, who, cb, src)
		if src == who or cb.value < who.max_life / 10 then return cb.value end
		game:onTickEnd(function() who:setEffect(who.EFF_PRESSURE_SUIT, 1, {}) end)
		return cb.value
	end,
}

newEntity{ base = "BASE_STEAMGUN", define_as = "ORC_EXPELLER",
	power_source = {steam=true},
	name = "Brilliant Auto-loading Orc Expeller", image = "object/artifact/b_a_l_o_expeller.png",
	unided_name = _t"expensive gun", unique = true,
	level_range = {10, 30},
	desc = _t[[A finely crafted gun, designed specifically to kill orcs. And giants somehow!]],
	require = { stat = { dex=28 }, },
	cost = 250,
	material_level = 3,
	combat = {
		range = 6,
		apr = 12,
	},
	wielder = {
		ammo_reload_speed = 1,
		inc_damage_actor_type = {humanoid = 15, giant = 15},
		talent_cd_reduction={
			[Talents.T_OVERHEAT_BULLETS] = 3,
			[Talents.T_SUPERCHARGE_BULLETS] = 3,
			[Talents.T_PERCUSSIVE_BULLETS] = 3,
			[Talents.T_COMBUSTIVE_BULLETS] = 3,
		},
	},
}
