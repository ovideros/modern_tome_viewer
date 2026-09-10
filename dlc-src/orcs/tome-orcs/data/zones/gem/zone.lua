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
	name = _t"G.E.M.",
	display_name = function(x, y)
		if game.level.level == 1 then return _t"G.E.M. Exterior" end
		if game.level.level == 2 then return _t"G.E.M. Crew Deck" end
		if game.level.level == 3 then return _t"G.E.M. Command Deck" end
		return _t"G.E.M."
	end,
	level_range = {30, 40},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	persistent = "zone",
	ambient_music = "orcs/gem.ogg",
	min_material_level = 4,
	max_material_level = 4,
	generator =  {
		map = {
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
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
	levels = {
		[1] = {
			day_night = true,
			width = 40, height = 25,
			generator =  {
				map = {
					class = "engine.generator.map.Static",
					map = "!outer",
				},
				actor = {
					class = "mod.class.generator.actor.Random",
					nb_npc = {10, 10},
					filters = {{special_rarity="ground_rarity"}},
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
		},
		[2] = {
			width = 60, height = 60,
			generator = {
				map = { zoneclass=true,
					class = "engine.generator.map.Building",
					margin_w = 1, margin_h = 1,
					max_block_w = 15, max_block_h = 15,
					max_building_w = 5, max_building_h = 5,
					floor = "MECH_FLOOR",
					external_floor = "MECH_FLOOR",
					wall = "MECH_WALL",
					up = "MECH_UP_WILDERNESS",
					down = "MECH_DOWN",
					door = "MECH_DOOR",
					crack_border = 'MECH_FLOOR',
					crack_center = 'CRACKS',
					lite_room_chance = 50,
					edge_entrances = {4,6},
				},
				actor = {
					nb_npc = {60, 60},
					filters = {{type="giant"}, {type="mechanical"}},
				},
			},
		},
		[3] = {
			width = 30, height = 30,
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "!command-deck",
				},
				actor = {
					nb_npc = {0, 0},
				},
			},
		},
	},

	on_enter = function(lev, old_lev, newzone)
		if newzone then
			game.player:grantQuest("orcs+gem")
		end
	end,

	post_process = function(level)
		-- Place a lore note on each level
		game:placeRandomLoreObjectScale("NOTE", {{}, {1,2,3,4}, {5,6}}, level.level)
		game:placeRandomLoreObjectScale("GEM_VINYL", {{}, {1,2}, {3}}, level.level)
	end,
}
