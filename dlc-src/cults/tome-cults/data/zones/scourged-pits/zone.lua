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
	name = _t"Scourged Pits",
	level_range = {20, 40},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	-- all_lited = true,
--	day_night = true,
	persistent = "zone",
	ambient_music = {"cults/scourged_pits.ogg"},
	min_material_level = 1,
	max_material_level = 2,
	generator =  {
		map = {
			class = "engine.generator.map.Octopus",
			main_radius = {0.3, 0.4},
			arms_radius = {0.1, 0.2},
			arms_range = {0.7, 0.8},
			nb_rooms = {5, 9},
			['#'] = "SCOURGE_TREE",
			['.'] = {
				"SCOURGE_FLOOR",
				"SCOURGE_FLOOR",
				"SCOURGE_FLOOR",
				"SCOURGE_FLOOR",
				"SCOURGE_FLOOR",
				"SCOURGE_FLOOR",
				"SCOURGE_FLOOR",
				"SCOURGE_CREEP",
			},
			up = "SCOURGE_LADDER_UP",
			down = "SCOURGE_LADDER_DOWN",
			door = "SCOURGE_FLOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			guardian = "KROLTAR_THE_SCOURGE",
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
				up = "SCOURGE_LADDER_UP_WILDERNESS",
			}, },
		},
	},
	post_process = function(level)
		game:placeRandomLoreObject("NOTE"..level.level)

		game.state:makeWeatherShader(level, "weather_vapours", {move_factor=80000, evolve_factor=20000, color={1, 0.5, 0, 0.5}, zoom=3})
	end,

	spawn_chance_max = 10,
	spawn_chance = 1,
	dangerlevel = 1,
	on_turn = function()
		if game.level.level ~= 1 then return end
		if game.turn % 10 ~= 0 then return end
		if not rng.percent(game.level.data.spawn_chance) then game.level.data.spawn_chance = math.min(game.level.data.spawn_chance + 0.2, game.level.data.spawn_chance_max) return end

		local grids = core.fov.circle_grids(game.player.x, game.player.y, 10, true)
		local gs = {}
		for x, yy in pairs(grids) do for y, _ in pairs(yy) do
			if game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "is_tentacle_tree") then
				gs[#gs+1] = {x=x,y=y}
			end
		end end
		if #gs == 0 then return end

		local spot = rng.table(gs)
		local oldg = game.level.map(spot.x, spot.y, engine.Map.TERRAIN)
		local g = game.zone:makeEntityByName(game.level, "terrain", "SCOURGE_FLOOR")
		local filter = {special_rarity="is_tentacle_tree"}

		local dl = game.level.data.dangerlevel
		local add_level = 0
		local randelite = 10 + (dl / 20) ^ 1.6
		local randboss = (dl / 20) ^ 1.2 - 1

		if randboss > 0 and rng.percent(randboss) then filter = {special_rarity="is_tentacle_tree", random_boss = {power_source = {nature=true, psionic=true, technique=true}}}
		elseif randelite > 0 and rng.percent(randelite) then filter = {special_rarity="is_tentacle_tree", random_elite = {power_source = {nature=true, psionic=true, technique=true}}} end
		filter.add_levels = (filter.add_levels or 0) + math.floor(dl / 10)

		local m = game.zone:makeEntity(game.level, "actor", filter, nil, true)
		if g and m then
			m.image=("terrain/scourge/tentacles_tree_%02d_base.png"):format(oldg.tentacle_id or 1)
			m:addParticles(require("engine.Particles").new("tentacle_tree", 1, {tentacle_id=oldg.tentacle_id or 1, force_tf=250}))
			m.exp_worth = 0
			m.no_drops = true
			game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
			game.zone:addEntity(game.level, m, "actor", spot.x, spot.y)
			-- game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
			m:setTarget(game.player)
			game.logSeen(m, "#YELLOW_GREEN#One of the trees shakes for a moment and awakens!")

			game.level.data.dangerlevel = game.level.data.dangerlevel + 1
		end

		game.level.data.spawn_chance = 1
	end,
}
