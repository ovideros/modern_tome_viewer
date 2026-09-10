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
	name = _t"Sunwall Observatory",
	display_name = function(x, y)
		if game.level.level == 1 then return _t"Path into the mountain" end
		if game.level.level == 2 then return _t"Caverns below the Observatory" end
		return _t"Sunwall Observatory"
	end,
	level_range = {18, 22},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	day_night = true,
	persistent = "zone",
	ambient_music = "orcs/sunwallsky.ogg",
	min_material_level = 2,
	max_material_level = 3,
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
			width = 150, height = 24,
			generator =  {
				map = {
					class = "mod.class.generator.map.GenericTunnel", zoneclass=true,
					edge_entrances = {4,6},
					start = 12,
					stop = 12,
					min_h = 6,
					max_h = 18,
					['#'] = "MOUNTAIN_WALL",
					['.'] = "GRASS",
					up = "GRASS_UP_WILDERNESS",
					down = "GRASS_DOWN6",
					items_vault = 'ITEMS_VAULT',
				},
				actor = {
					class = "mod.class.generator.actor.Random",
					nb_npc = {60, 60},
					filters = {{special_rarity="mountainpass_rarity"}},
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
			width = 70, height = 70,
			generator = {
				map = {
					class = "engine.generator.map.Cavern",
					zoom = 12,
					min_floor = 1400,
					floor = "CAVEFLOOR",
					wall = "CAVEWALL",
					up = "CAVE_LADDER_UP",
					down = "CAVE_LADDER_DOWN",
					door = "CAVEFLOOR",
					['.'] = "CAVEFLOOR",
					['#'] = "HARDCAVEWALL",
					['+'] = "CAVE_ROCK_VAULT",
					nb_rooms = 0,
					required_rooms = {"!astral-yeti"},
				},
				actor = {
					nb_npc = {30, 30},
					filters = {{}, {}, {special_rarity="mountainpass_rarity"}},
				},
			},
		},
		[3] = {
			width = 50, height = 50,
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "!top",
				},
				actor = {
					nb_npc = {0, 0},
				},
			},
		},
	},

	post_process = function(level)
		if level.level ~= 3 then return end

		game:placeRandomLoreObject("NOTE1")

		local Map = require "engine.Map"
		local Particles = require "engine.Particles"
		level.data.background_particle2 = Particles.new("image", 1, {size=Map.viewport.mwidth * 1.2 * 64, image="shockbolt/terrain/observatory_bg_01"})

		local ps = {}
		for i = 1, 7 do
			local p = {max_nb=9, speed={0.5, 1.6}, alpha={0.4, 0.6}, particle_name="weather/grey_cloud_%02d", width = level.map.w*level.map.tile_w, height = level.map.h*level.map.tile_h}
			p.particle_name = p.particle_name:format(i)
			ps[#ps+1] = Particles.new("weather_storm", 1, p)
		end
		level.data.background_particle1 = ps
	end,

	background = function(level, x, y, nb_keyframes)
		if not level.data.background_particle1 then return end

		local Map = require "engine.Map"
		local parx, pary = level.map.mx / (level.map.w - Map.viewport.mwidth), level.map.my / (level.map.h - Map.viewport.mheight)
		level.data.background_particle2.ps:toScreen(x + Map.viewport.mwidth * Map.tile_w / 2 - parx * 40, y + Map.viewport.mheight * Map.tile_h / 2 - pary * 40, true, 1)

		local dx, dy = level.map:getScreenUpperCorner() -- Display at map border, always, so it scrolls with the map
		for j = 1, #level.data.background_particle1 do
			level.data.background_particle1[j].ps:toScreen(dx, dy, true, 1)
		end
	end,
}
