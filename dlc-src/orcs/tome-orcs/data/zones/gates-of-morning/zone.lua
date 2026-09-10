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
	name = _t"Gates of Morning",
	display_name = function(x, y)
		if game.level.level == 1 then return _t"Gates of Morning"
		else return ("Caves of Morning (%d)"):tformat(game.level.level-1) end
	end,
	variable_zone_name = true,
	level_range = {25, 35},
	level_scheme = "player",
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	update_base_level_on_enter = true,
	max_level = 5,
	width = 50, height = 50,
	decay = {300, 800, only={object=true}, no_respawn=true},
	persistent = "zone",
	ambient_music = {"For the king and the country!.ogg", "weather/town_large_base.ogg"},
	min_material_level = 3,
	max_material_level = 4,
	store_levels_by_restock = { 8, 40, 50 },
	
	generator =  {
		all_remembered = true,
		all_lited = true,
		day_night = true,
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			rooms = {"random_room", {"money_vault",5}, {"lesser_vault",8}},
			lesser_vaults_list = {"circle","amon-sul-crypt","rat-nest","skeleton-mage-cabal"},
			lite_room_chance = 100,
			['.'] = "FLOOR",
			['#'] = "WALL",
			up = "UP",
			down = "DOWN",
			door = "DOOR",
			['+'] = "DOOR",
		},
		actor = {
			class = "mod.class.generator.actor.OnSpots",
			nb_npc = {20, 30},
			randelite = 7,
			nb_spots = 2, on_spot_chance = 35,
		},
		object = {
			class = "engine.generator.object.OnSpots",
			nb_object = {6, 9},
			nb_spots = 2, on_spot_chance = 80,
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
	},

	levels = {
		[1] = {
			all_remembered = true, all_lited = true, day_night = true,
			nicer_tiler_overlay = "DungeonWallsGrass",
			width = 70, height = 50,
			no_level_connectivity = true,
			generator =  {
				map = {
					class = "engine.generator.map.Static",
					map = "!town",
				},
				actor = {
					class = "mod.class.generator.actor.Random",
					area = {x1=16, x2=56, y1=3, y2=47},
					nb_npc = {30, 30},
				},
				object = {
					class = "engine.generator.object.Random",
					nb_object = {0, 0},
				},
			},
		},
		[2] = {
			generator =  {
				actor = { zoneclass=true, },
			},
		},
		[3] = {
			generator =  {
				actor = { zoneclass=true, },
			},
		},
		[4] = {
			generator =  {
				actor = { zoneclass=true, },
			},
		},
		[5] = {
			generator =  {
				map = {
					required_rooms = {"!final"},
				},
			},
		},
	},

	post_process = function(level)
		if level.level == 1 then
			-- Farportal
			local g1 = game.zone:makeEntityByName(game.level, "terrain", "WEST_PORTAL")
			local g2 = game.zone:makeEntityByName(game.level, "terrain", "CWEST_PORTAL")

			local spot = game.level:pickSpot{type="pop-quest", subtype="farportal"}
			game.zone:addEntity(game.level, g1, "terrain", spot.x, spot.y)
			game.zone:addEntity(game.level, g1, "terrain", spot.x+1, spot.y)
			game.zone:addEntity(game.level, g1, "terrain", spot.x+2, spot.y)
			game.zone:addEntity(game.level, g1, "terrain", spot.x, spot.y+1)
			game.zone:addEntity(game.level, g2, "terrain", spot.x+1, spot.y+1)
			game.zone:addEntity(game.level, g1, "terrain", spot.x+2, spot.y+1)
			game.zone:addEntity(game.level, g1, "terrain", spot.x, spot.y+2)
			game.zone:addEntity(game.level, g1, "terrain", spot.x+1, spot.y+2)
			game.zone:addEntity(game.level, g1, "terrain", spot.x+2, spot.y+2)

			local note = game.zone:makeEntityByName(game.level, "object", "NOTE1")
			game.zone:addEntity(game.level, note, "object", spot.x, spot.y+3)
		elseif level.level == 2 then
			game:placeRandomLoreObject("NOTE2")
		end
	end
}
