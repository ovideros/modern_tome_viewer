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
	name = _t"Dominion Port",
	display_name = function(x, y)
		if game.level.level == 1 then return _t"Dominion Port: Sewers 1" end
		if game.level.level == 2 then return _t"Dominion Port: Sewers 2" end
		if game.level.level == 3 then return _t"Dominion Port" end
		if game.level.level == 4 then return _t"Dominion Port: Tower" end
		return _t"Dominion Port ???"
	end,
	variable_zone_name = true,
	level_range = {12, 18},
	level_scheme = "player",
	max_level = 4,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	persistent = "zone",
	ambient_music = "orcs/dominion.ogg",
	min_material_level = 2,
	max_material_level = 2,
	generator =  {
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {30, 40},
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
			all_lited = false,
			day_night = false,
			color_shown = {0.5, 0.7, 0.5, 1},
			color_obscure = {0.5*0.6, 0.7*0.6, 0.5*0.6, 0.6},
			width = 80, height = 80,
			generator = { 
				map = {
					class = "mod.class.generator.map.orc.Sewers",
					water = "SEWER_WATER",
					floor = "SAND",
					wall = "WALL",
					up = "UP_WILDERNESS",
					down = "DOWN",
				},
				actor = {
					class = "engine.generator.actor.Random",
					filters = { {type="reptile"}, {type="reptile"}, {type="reptile"}, {type="giant"}, },
				},
			},
		},
		[2] = {
			all_lited = false,
			day_night = false,
			color_shown = {0.5, 0.7, 0.5, 1},
			color_obscure = {0.5*0.6, 0.7*0.6, 0.5*0.6, 0.6},
			width = 80, height = 80,
			generator = { 
				map = {
					class = "mod.class.generator.map.orc.Sewers",
					water = "SEWER_WATER",
					floor = "SAND",
					wall = "WALL",
					up = "UP",
					down = "DOWN",
				},
				actor = {
					filters = { {type="reptile"}, {type="reptile"}, {type="reptile"}, {type="giant"}, },
				},
			},
		},
		[3] = {
			day_night = true,
			generator = {
				map = {
					class = "engine.generator.map.Town",
					building_chance = 100,
					max_building_w = 10, max_building_h = 10,
					edge_entrances = {4,6},
					floor = "FLOOR",
					external_floor = "FLOOR",
					wall = "WALL",
					up = "DOWN_SEWER",
					down = "UP_TOWER",
					door = "DOOR",
					['#'] = "WALL",
					['.'] = "FLOOR",
					['+'] = "DOOR",

					nb_rooms = {0,1,1,2},
					rooms = {"random_room"},
				},
				actor = {
					filters = { {type="giant"}, },
					nb_npc = {15, 25}, --Captains ensure large groups of enemies, no need to flood.
				},
				object = {
					zoneclass=true,
				},
			},
		},
		[4] = {
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "orcs+zones/dominion-port",
				},
				actor = {
					class = "engine.generator.actor.Random",
					filters = { {type="giant"}, },
					nb_npc = {12, 15},
				},
			},
		},
	},


	on_enter = function(lev, old_lev, newzone)
		local Dialog = require("engine.ui.Dialog")
		if lev == 4 and not game.level.shown_warning then
			Dialog:simplePopup(_t"Dominion's Port Tower", _t"As you enter you see the door lock behind you. It's a trap!")
			game.level.shown_warning = true
		end
	end,

	on_turn = function(self)
		if not game.level.turn_counter then return end

		game.level.turn_counter = game.level.turn_counter - 1
		game.player.changed = true
		if game.level.turn_counter < 0 then
			game.level.turn_counter = nil
			local q = game:getPlayer(true):hasQuest("orcs+kill-dominion")
			if q then q:do_destruction() end
		end
	end,

	post_process = function(level)
		if level.level == 3 then game:placeRandomLoreObject("NOTE1")
		elseif level.level == 4 then game:placeRandomLoreObject("NOTE2") end
	end,
}
