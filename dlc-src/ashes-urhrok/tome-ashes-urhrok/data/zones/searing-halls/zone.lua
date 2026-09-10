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
	name = _t"Searing Halls",
	level_range = {1, 5},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 41, height = 41,
--	all_remembered = true,
	all_lited = true,
	day_night = true,
	tier1 = true,
	no_worldport = true,
	in_orbit = true,
	persistent = "zone",
	-- Apply a redish tint to all the map
	color_shown = {1, 0.6, 0.6, 1},
	color_obscure = {1*0.6, 0.6*0.6, 0.6*0.6, 0.6},
	ambient_music = "ashes-urhrok/demons1.ogg",
	min_material_level = function() return game.state:isAdvanced() and 3 or 1 end,
	max_material_level = function() return game.state:isAdvanced() and 4 or 2 end,
	demon_statues_only_one = true,
	generator =  {
		map = {
			class = "engine.generator.map.Building",
			margin_w = 1, margin_h = 1,
			max_block_w = 15, max_block_h = 15,
			max_building_w = 5, max_building_h = 5,
			floor = "FLOATING_ROCKS",
			external_floor = "FLOATING_ROCKS",
			wall = "MALROK_WALL",
			up = "UP",
			down = "DOWN",
			door = "MALROK_DOOR",
			void = "OUTERSPACE",
			force_last_stair = true,
			lite_room_chance = 100,
		},
		actor = {
			class = "engine.generator.actor.Random",
			-- class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			filters = { {max_ood=2}, },
			randelite = 0,
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
			width = 50, height = 50,
			generator =  {
				map = {
					class = "engine.generator.map.Static",
					map = "ashes-urhrok+searing-halls-start",
				},
				actor = {
					nb_npc = {9, 12},
					filters = { {special_rarity="crash_rarity"}, },
				},
			},
		},
		[2] = {
			generator =  {
				map = { zoneclass=true,
					up = "PORTAL_PREV",
					down = "PORTAL_NEXT",
				},
			},
		},
		[3] = {
			generator =  {
				map = {
					up = "PORTAL_PREV",
					down = "CONTROLLING_CRYSTAL",
				},
			},
		},
	},

	on_enter = function()
		game.player:attr("planetary_orbit", 1)

		if game.level.level == 2 and not game.level.data.seen_memory then game.party:learnLore("ashes-urhrok-training-recall1") game.level.data.seen_memory = true
		elseif game.level.level == 3 and not game.level.data.seen_memory then game.party:learnLore("ashes-urhrok-training-recall2") game.level.data.seen_memory = true
		end
	end,

	on_leave = function(lev, old_lev, newzone)
		if not newzone then return end
		world:gainAchievement("ASHES_ESCAPED", game.player)
	end,

	post_process = function(level)
		if level.level == 2 then game:placeRandomLoreObject("MISTRANSLATED_HISTORY_MALROK") end

		if core.renderer then
			local Map = require "engine.Map"
			level.background_particle = require("engine.Particles").new("starfield", 1, {width=Map.viewport.width, height=Map.viewport.height, speed=200000})
		else
			local Map = require "engine.Map"
			local Quadratic = require "engine.Quadratic"
			if core.shader.allow("volumetric") then
				level.starfield_shader = require("engine.Shader").new("starfield", {size={Map.viewport.width, Map.viewport.height}})
			else
				level.background_particle1 = require("engine.Particles").new("starfield_static", 1, {width=Map.viewport.width, height=Map.viewport.height, nb=300, a_min=0.5, a_max = 0.8, size_min = 1, size_max = 3})
				level.background_particle2 = require("engine.Particles").new("starfield_static", 1, {width=Map.viewport.width, height=Map.viewport.height, nb=300, a_min=0.5, a_max = 0.9, size_min = 4, size_max = 8})
			end
			level.world_sphere = Quadratic.new()
			game.zone.world_sphere_rot = (game.zone.world_sphere_rot or 0)
			game.zone.cloud_sphere_rot = (game.zone.world_cloud_rot or 0)
		end
	end,

	background = function(level, x, y, nb_keyframes)
		if core.renderer then
			local Map = require "engine.Map"
			local parx, pary = level.map.mx / (level.map.w - Map.viewport.mwidth), level.map.my / (level.map.h - Map.viewport.mheight)
			if level.background_particle then
				level.background_particle.ps:toScreen(x, y, true, 1)
			end

			if not level.tmpdata.planet_renderer then
				local StellarBody = require "mod.class.StellarBody"
				local planettex = core.loader.png("/data/gfx/shockbolt/stars/eyal.png")
				local cloudtex = core.loader.png("/data/gfx/shockbolt/stars/clouds.png")
				local planet = StellarBody.makePlanet(planettex, cloudtex, {160/255, 160/255, 200/255, 0.5}, 300, {planet_time_scale=900000, clouds_time_scale=700000, rotate_angle=math.rad(22), light_angle=math.pi})
				level.tmpdata.planet_renderer = core.renderer.renderer("static"):add(planet)
			end
			level.tmpdata.planet_renderer:toScreen():translate(x + 350 - parx * 60, y + 350 - pary * 60)
		else
			local Map = require "engine.Map"
			local parx, pary = level.map.mx / (level.map.w - Map.viewport.mwidth), level.map.my / (level.map.h - Map.viewport.mheight)
			if level.starfield_shader and level.starfield_shader.shad then
				level.starfield_shader.shad:use(true)
				core.display.drawQuad(x, y, Map.viewport.width, Map.viewport.height, 1, 1, 1, 1)
				level.starfield_shader.shad:use(false)
			elseif level.background_particle1 then
				level.background_particle1.ps:toScreen(x, y, true, 1)
				level.background_particle2.ps:toScreen(x - parx * 40, y - pary * 40, true, 1)
			end

			core.display.glDepthTest(true)
			core.display.glMatrix(true)
			core.display.glTranslate(x + 350 - parx * 60, y + 350 - pary * 60, 0)
			core.display.glRotate(120, 0, 1, 0)
			core.display.glRotate(300, 1, 0, 0)
			core.display.glRotate(game.zone.world_sphere_rot, 0, 0, 1)
			core.display.glColor(1, 1, 1, 1)

			local tex = Map.tiles:get('', 0, 0, 0, 0, 0, 0, "stars/eyal.png")
			tex:bind(0)
			level.world_sphere.q:sphere(300)

			local tex = Map.tiles:get('', 0, 0, 0, 0, 0, 0, "shockbolt/terrain/cloud-world.png")
			tex:bind(0)
			core.display.glRotate(game.zone.cloud_sphere_rot, 0, 0, 1)
			level.world_sphere.q:sphere(304)

			game.zone.world_sphere_rot = game.zone.world_sphere_rot + 0.01 * nb_keyframes
			game.zone.cloud_sphere_rot = game.zone.cloud_sphere_rot + rng.float(0.01, 0.02) * nb_keyframes

			core.display.glMatrix(false)
			core.display.glDepthTest(false)
		end
	end,
}
