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
	name = _t"Ruins of a lost city",
	level_range = {15, 25},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	persistent = "zone",
	ambient_music = {"Bazaar of Tal-Mashad.ogg", "weather/desert_base.ogg"},
	min_material_level = 2,
	max_material_level = 3,
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
			all_lited = true,
			day_night = true,
			width = 90, height = 90,
			generator = { 
				map = {
					class = "engine.generator.map.Forest",
					edge_entrances = {8,2},
					zoom = 6,
					sqrt_percent = 40,
					noise = "fbm_perlin",
					floor = "SAND",
					down = "SAND",
					wall = "PALMTREE",
					up = "SAND_UP_WILDERNESS",
					realdown = "TO_CAVE",
					-- do_ponds =  {
					-- 	nb = {0, 2},
					-- 	size = {w=25, h=25},
					-- 	pond = {{0.6, "DEEP_OCEAN_WATER"}, {0.8, "DEEP_OCEAN_WATER"}},
					-- },

					nb_rooms = {8+3, 8+5},
					required_rooms = {"!oasis1", "!oasis2", "!oasis3", "!oasis4", "!ruins1", "!ruins2", "!ruins3", "!ruins4", },
					rooms = {"!ruins3", "!ruins4", "!ruins3", "!ruins4", "greater_vault"},
					greater_vaults_list = {"dragon_lair"},
					lite_room_chance = 100,
				},
				actor = {
					filters = {  },
					nb_npc = {40, 45},
				},
			},
		},
		[2] = {
			color_shown = {0.6, 0.6, 0.6, 1},
			color_obscure = {0.6*0.6, 0.6*0.6, 0.6*0.6, 0.6},
			width = 40, height = 40,
			generator = { 
				map = {
					class = "engine.generator.map.Cavern",
					zoom = 19,
					lacunarity = 20,
					min_floor = 600,
					floor = "CAVEFLOOR",
					wall = "CAVEWALL",
					up = "CAVE_LADDER_UP",
					down = "CAVE_LADDER_DOWN",
				},
				actor = {
					filters = { {type="horror"}, },
					nb_npc = {12, 12},
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
				object = {
					nb_object = {0, 0},
				},
			},
		},
	},

	post_process = function(level)
		if level.level == 1 then
			-- Sand storms over Eruan
			game.state:makeWeather(level, 7, {max_nb=2, chance=1, dir=70, speed={24, 50}, alpha={0.2, 0.5}, particle_name="weather/sand_light_%02d"})

			game.state:makeAmbientSounds(level, {
				desert1={ chance=250, volume_mod=0.6, pitch=0.6, random_pos={rad=10}, files={"ambient/desert/desert1","ambient/desert/desert2","ambient/desert/desert3"}},
				desert2={ chance=250, volume_mod=1, pitch=1, random_pos={rad=10}, files={"ambient/desert/desert1","ambient/desert/desert2","ambient/desert/desert3"}},
				desert3={ chance=250, volume_mod=1.6, pitch=1.4, random_pos={rad=10}, files={"ambient/desert/desert1","ambient/desert/desert2","ambient/desert/desert3"}},
			})
		elseif level.level == 2 then
			game:placeRandomLoreObject("PAYLOAD_SCHEMATIC") -- Not lore but it's useful
		end
	end,

	on_enter = function(lev, old_lev, newzone)
		if lev == 3 and not game.level.data.gave_lore then
			game.party:learnLore("weissi-intro")
			game.level.data.gave_lore = true
		end
	end
}
