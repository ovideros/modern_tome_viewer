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
	name = _t"Krimbul Territory",
	level_range = {15, 22},
	level_scheme = "player",
	max_level = 4,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	persistent = "zone",
	ambient_music = {"orcs/ureslak.ogg","weather/dungeon_base.ogg"},
	min_material_level = 2,
	max_material_level = 2,
	generator =  {
		actor = {
			class = "mod.class.generator.actor.Random",
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
			generator = { 
				map = {
					class = "engine.generator.map.Roomer",
					nb_rooms = 10,
					rooms = {"random_room", {"money_vault",5}},
					lite_room_chance = 70,
					['.'] = "MANACAVE_GROUND",
					['#'] = "MANACAVE",
					up = "MANACAVE_UP_WILDERNESS",
					down = "MANACAVE_DOWN",
					door = "MANACAVE_DOOR",
				},
				actor = {
					class = "engine.generator.actor.Random",
					nb_npc = {20, 30},
				},
			},
		},
		[2] = {
			color_shown = {0.6, 0.6, 0.6, 1},
			color_obscure = {0.6*0.6, 0.6*0.6, 0.6*0.6, 0.6},
			generator = { 
				map = {
					class = "engine.generator.map.Roomer",
					edge_entrances = {2,8},
					nb_rooms = 10,
					rooms = {"random_room", {"money_vault",5}},
					lite_room_chance = 70,
					['.'] = "MANACAVE_GROUND",
					['#'] = "MANACAVE",
					up = "MANACAVE_UP_WILDERNESS",
					down = "MANACAVE_DOWN",
					door = "MANACAVE_DOOR",
				},
				actor = {
					nb_npc = {20, 30},
				},
			},
		},
		[3] = {
			underwater = true,
			effects = {"EFF_ZONE_AURA_UNDERWATER"},
			generator = {
				map = {
					class = "engine.generator.map.Roomer",
					nb_rooms = 10,
					rooms = {"random_room"},
					lite_room_chance = 0,
					['.'] = function() local i = rng.range(1, 100)
						if i < 85 then return "WATER_FLOOR"
						elseif i < 98 then return "WATER_FLOOR_BUBBLE"
						else return "WATER_FLOOR_ALGAE" end
					end,
					['#'] = "WATER_WALL",
					up = "WATER_UP",
					down = "WATER_FLOOR",
					door = "WATER_DOOR",
					required_rooms = {"!airship"},
				},
				actor = {
					filters = {{special_rarity="water_rarity"}, {special_rarity="water_rarity"}, {special_rarity="water_rarity"}, {type="undead", subtype="minotaur"}},
					nb_npc = {25, 35},
				},
			},
		},
		[4] = {
			width = 20, height = 20,
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "!final",
				},
				actor = {
					nb_npc = {0, 0},
				},
				object = {
					nb_object = {0, 0},
				},
			},
		},
	},

	post_process = function(level)
		for uid, e in pairs(level.entities) do e.faction = e.hard_faction or "whitehooves" end

		if level.level == 1 then game:placeRandomLoreObject("NOTE1")
		elseif level.level == 2 then game:placeRandomLoreObject("NOTE2")
		end
	end,
}
