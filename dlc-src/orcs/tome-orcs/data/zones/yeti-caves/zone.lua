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
	name = _t"Yetis Cave",
	level_range = {1, 7},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + level.level-1 + e:getRankLevelAdjust() + 1 end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
--	day_night = true,
	tier1 = true,
	tier1_escort = 2,
	persistent = "zone",
	ambient_music = {"orcs/yeti.ogg"},
	min_material_level = 1,
	max_material_level = 2,
	generator =  {
		map = {
			class = "engine.generator.map.Cavern", zoneclass = true,
			zoom = 19,
			lacunarity = 20,
			min_floor = 800,
			floor = "ICECAVEFLOOR",
			wall = "ICECAVEWALL",
			up = "ICECAVE_LADDER_UP",
			down = "ICECAVE_LADDER_DOWN",
			door = "ICECAVE_DOOR",
			door_chance = 50,
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {35, 40},
			filters = { {max_ood=2}, },
			guardian = "YETI_PATRIARCH",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "ICECAVE_LADDER_UP_WILDERNESS",
			}, },
		},
	},
}
