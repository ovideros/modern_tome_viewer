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
	name = _t"Primal Forest",
	level_range = {25, 35},
	level_scheme = "player",
	max_level = 2,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 70, height = 70,
	-- all_remembered = true,
	all_lited = true,
	day_night = true,
	persistent = "zone",
	color_shown = {0.7, 0.7, 0.7, 1},
	color_obscure = {0.7*0.6, 0.7*0.6, 0.7*0.6, 0.6},
	ambient_music = {"Woods of Eremae.ogg", "weather/rain.ogg"},
	min_material_level = 3,
	max_material_level = 3,
	nicer_tiler_overlay = "DungeonWallsGrass",
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 16,
			rooms = {"forest_clearing", {"lesser_vault",8}},
			rooms_config = {forest_clearing={pit_chance=5, filters={{type="insect", subtype="ant"}, {type="insect"}, {type="animal", subtype="snake"}, {type="animal", subtype="canine"}}}},
			lesser_vaults_list = {"honey_glade", "plantlife", "mold-path", },
			['.'] = "GRASS",
			['#'] = "TREE",
			up = "GRASS_UP4",
			down = "GRASS_DOWN6",
			door = "GRASS",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			guardian = "",
		},
		object = {
			class = "engine.generator.object.Random",
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
			filters = { {} }
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
				edge_entrances = {2,8},
				up = "GRASS_UP_WILDERNESS",
				down = "GRASS",
				required_rooms = {"!bigtrunk"},
			}, },
		},
		[2] = {
			generator = { map = {
				class = "engine.generator.map.Octopus", zoneclass=true,
				main_radius = {0.2, 0.3},
				arms_radius = {0.1, 0.2},
				arms_range = {0.5, 0.6},
				nb_rooms = {5, 5},
				['.'] = "PRIMAL_TRUNK",
				['#'] = "EMPTY",
				up = "DOWN_TO_GROUND",
			}, },
		},
	},

	post_process = function(level)
		if level.level == 1 then
			for _, c in pairs(util.adjacentCoords(level.default_up.x, level.default_up.y)) do
				if level.map:isBound(c[1], c[2]) and not level.map:checkEntity(c[1], c[2], level.map.TERRAIN, "block_move") then
					local o = game.zone:makeEntityByName(level, "object", "NOTE1")
					game.zone:addEntity(level, o, "object", c[1], c[2])
					break
				end
			end
			game:placeRandomLoreObject("NOTE2")
			game:placeRandomLoreObject("NOTE3")
			game:placeRandomLoreObject("NOTE4")
		end

		if level.level == 2 then
			local level1 = game.zone.memory_levels and game.zone.memory_levels[1]
			if level1 then level1.map:rememberAll(0, 0, level1.map.w, level1.map.h) end

			game:placeRandomLoreObject("LIFE_SUPPORT_SCHEMATIC") -- Not lore but it's useful
		end

		if not config.settings.tome.weather_effects then return end

		local Map = require "engine.Map"
		-- HEAVY rain
		level.foreground_particle = require("engine.Particles").new("raindrops", 1, {width=Map.viewport.width, height=Map.viewport.height, intensity=40})

		if level.level == 1 then game.state:makeWeather(level, 7, {max_nb=3, speed={0.5, 1.6}, shadow=true, alpha={0.35, 0.45}, particle_name="weather/grey_cloud_%02d"}) end

		game.state:makeAmbientSounds(level, {
			wind={ chance=120, volume_mod=1.9, pitch=2, random_pos={rad=10}, files={"ambient/forest/wind1","ambient/forest/wind2","ambient/forest/wind3","ambient/forest/wind4"}},
			bird={ chance=1500, volume_mod=0.6, pitch=0.4, random_pos={rad=10}, files={"ambient/forest/bird1","ambient/forest/bird2","ambient/forest/bird3","ambient/forest/bird4","ambient/forest/bird5","ambient/forest/bird6","ambient/forest/bird7"}},
		})
	end,

	spawn_chance_max = 50,
	spawn_chance = 1,
	dangerlevel = 1,
	on_turn = function()
		if game.level.level ~= 1 then return end
		if game.turn % 10 ~= 0 then return end
		if not rng.percent(game.level.data.spawn_chance) then game.level.data.spawn_chance = math.min(game.level.data.spawn_chance + 1, game.level.data.spawn_chance_max) return end

		local grids = core.fov.circle_grids(game.player.x, game.player.y, 10, true)
		local gs = {}
		for x, yy in pairs(grids) do for y, _ in pairs(yy) do
			if game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "is_tree") then
				gs[#gs+1] = {x=x,y=y}
			end
		end end
		if #gs == 0 then return end

		local spot = rng.table(gs)
		local g = game.zone:makeEntityByName(game.level, "terrain", "GRASS")
		local filter = {properties={"is_treant"}}

		local dl = game.level.data.dangerlevel
		local add_level = 0
		local randelite = 10 + (dl / 20) ^ 1.6
		local randboss = (dl / 20) ^ 1.2 - 1

		if randboss > 0 and rng.percent(randboss) then filter = {properties={"is_treant"}, random_boss = {power_source = {nature=true, psionic=true, technique=true}}}
		elseif randelite > 0 and rng.percent(randelite) then filter = {properties={"is_treant"}, random_elite = {power_source = {nature=true, psionic=true, technique=true}}} end
		filter.add_levels = (filter.add_levels or 0) + math.floor(dl / 10)

		local m = game.zone:makeEntity(game.level, "actor", filter, nil, true)
		if g and m then
			m.exp_worth = 0
			game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
			game.zone:addEntity(game.level, m, "actor", spot.x, spot.y)
			game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
			m:setTarget(game.player)
			game.logSeen(m, "#YELLOW_GREEN#One of the trees shakes for a moment and awakens!")

			game.level.data.dangerlevel = game.level.data.dangerlevel + 1
		end

		game.level.data.spawn_chance = 1
		game.level.data.spawn_chance_max = math.max(5, game.level.data.spawn_chance_max - 3)
	end,

	-----------------------------------------------------------------------------------------------------
	-- Display code, mostly for sublevel
	-----------------------------------------------------------------------------------------------------

	-- Display weather
	foreground = function(level, x, y, nb_keyframes)
		if not config.settings.tome.weather_effects or not level.foreground_particle then return end
		level.foreground_particle.ps:toScreen(x, y, true, 1)
	end,

	-- Draw the sublevel, shaded to grey
	background = function(level, x, y, nb_keyframes)
		if not level.prepared_sublevel_display then return end
		game.fbo2:toScreen(0, 0, level.map.viewport.width, level.map.viewport.height)
		core.display.drawQuad(0, 0, level.map.viewport.width, level.map.viewport.height, 128, 128, 128, 128)
	end,

	-- Called before the display method enters any fbo state, so we can prepare any texture we wish
	-- Use fbo2 to make a texture of the sublevel
	display_prepare = function(level, x, y, nb_keyframes)
		level.prepared_sublevel_display = false
		if level.level ~= 2 then return end
		if not game.fbo2 then return end
		local level1 = game.zone.memory_levels and game.zone.memory_levels[1]
		if not level1 then return end

		if game.zone.just_loaded then
			game.nicer_tiles:postProcessLevelTiles(level1) level1.map:recreate()
			game.zone.just_loaded = nil
		else
			game.fbo2:use(true)
			level1.map:setScroll(level.map.mx, level.map.my)
			level1.map:display(0, 0, nb_keyframes, config.settings.tome.smooth_fov, game.fbo2)
			if level1.data.weather_particle then game.state:displayWeather(level1, level1.data.weather_particle, nb_keyframes) end
			game.fbo2:use(false)
			level.prepared_sublevel_display = true
		end
	end,

	-- Tell display_prepare to force a gfx regeneration of the sublevel
	on_loaded = function(self)
		game.zone.just_loaded = true
	end,
}
