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
	name = _t"Pocket of Distorted Time",
	display_name = function(x, y)
		if game.level.level == 1 then return _t"Time-locked Vault" end
		if game.level.level == 2 then return _t"Pocket of Distorted Time" end
		return _t"Pocket of Distorted Time"
	end,
	variable_zone_name = true,
	level_range = {45, 50},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 40, height = 100,
	persistent = "zone",
	ambient_music = "orcs/pocket.ogg",
	min_material_level = 4,
	max_material_level = 5,
	generator =  {
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {40, 50},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {10, 15},
		},
	},
	levels =
	{
		[1] = {
			color_shown = {0.5, 0.7, 1, 1},
			color_obscure = {0.5*0.6, 0.7*0.6, 1*0.6, 0.6},
			width = 40, height = 40,
			generator = { 
				map = {
					class = "engine.generator.map.Roomer",
					nb_rooms = 5,
					rooms = {"random_room"},
					lite_room_chance = 10,
					['.'] = "FLOOR",
					['#'] = "WALL",
					['+'] = "DOOR",
					up = "POCKET_PORTAL_OUT",
					down = "POCKET_PORTAL",
					door = "DOOR",
					force_last_stair = true,
				},
				actor = {
					nb_npc = {15, 20},
				},
			},
		},
		[2] = {
			color_shown = {0.5, 0.7, 1, 1},
			color_obscure = {0.5*0.6, 0.7*0.6, 1*0.6, 0.6},
			width = 80, height = 80,
			generator = { 
				map = {
					class = "engine.generator.map.Roomer",
					nb_rooms = 10,
					rooms = {"random_room"},
					lite_room_chance = 10,
					['.'] = "FLOOR",
					['#'] = "WALL",
					['+'] = "DOOR",
					up = "FLOOR",
					down = "POCKET_PORTAL",
					door = "DOOR",
					force_last_stair = true,
				},
			},
		},
		[3] = {
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "!final",
				},
				actor = {
					nb_npc = {0, 0},
				},
				trap = {
					nb_trap = {5, 5},
				},
			},
		},
	},

	lored = {},
	on_enter = function(lev, old_lev, newzone)
		if game.level.data.lored[lev] then return end
		game.level.data.lored[lev] = true
		game.party:learnLore("pocket-time-"..lev)
		if lev == 2 then
			world:gainAchievement("ORCS_SCOURGE_STORY", game.player)
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
}
