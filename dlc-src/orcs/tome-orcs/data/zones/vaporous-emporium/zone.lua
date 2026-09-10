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
	name = _t"Vaporous Emporium",
	level_range = {1, 7},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + level.level-1 + e:getRankLevelAdjust() + 1 end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	day_night = true,
	tier1 = true,
	--tier1_escort = 2,
	persistent = "zone",
	ambient_music = "orcs/Vaporous Emporium.ogg",
	min_material_level = 1,
	max_material_level = 2,
	generator = {
		map = {
			class = "engine.generator.map.Octopus", zoneclass=true,
			main_radius = {0.3, 0.4},
			arms_radius = {0.1, 0.2},
			arms_range = {0.7, 0.8},
			nb_rooms = {5, 9},
			edge_entrances = {6,4},
			['.'] = "ROCKY_GROUND",
			['#'] = "SNOW_MOUNTAIN_WALL",
			up = "ROCKY_UP6",
			down = "ROCKY_DOWN4",
			door = "ROCKY_GROUND",
		},
		actor = {
			class = "engine.generator.actor.Random",
			--class = "mod.class.generator.actor.Random",
			filters = {{max_ood=2}},
			nb_npc = {20, 30},
			guardian = "TALOSIS",
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
				up = "ROCKY_UP_WILDERNESS",
			}, },
		},
	},

	post_process = function(level)
		-- Place a lore note on each level
		game:placeRandomLoreObjectScale("NOTE", {{1}, {2,3}, {4,5}}, level.level)
	end,
}
