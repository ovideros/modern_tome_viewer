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

return {
	name = _t"--not done--",
	level_range = {20, 50},
	level_scheme = "player",
	is_cults_book = true, no_worldport = true,
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 35, height = 35,
--	all_remembered = true,
--	all_lited = true,
--	day_night = true,
	persistent = "zone",
	ambient_music = {"cults/maggot.ogg"},
	min_material_level = 3,
	max_material_level = 5,
	generator =  {
		map = {
			class = "engine.generator.map.Octopus",
			main_radius = {0.3, 0.4},
			arms_radius = {0.1, 0.2},
			arms_range = {0.7, 0.8},
			nb_rooms = {7, 7},
			['#'] = "UNDERGROUND_TREE",
			['.'] = {
				"UNDERGROUND_FLOOR",
				"UNDERGROUND_FLOOR",
				"UNDERGROUND_FLOOR",
				"UNDERGROUND_FLOOR",
				"UNDERGROUND_FLOOR",
				"UNDERGROUND_FLOOR",
				"UNDERGROUND_FLOOR",
				"UNDERGROUND_CREEP",
			},
			up = "UNDERGROUND_LADDER_UP",
			down = "UNDERGROUND_LADDER_DOWN",
			door = "UNDERGROUND_FLOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {15, 20},
			guardian = "THE_ONE_THAT_WRITES",
			randelite = 4,
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {6, 9},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "BOOK_OUT",
			}, },
		},
		[3] = {
			generator = { map = {
				zoneclass = true,
			}, },
		},
	},
}
