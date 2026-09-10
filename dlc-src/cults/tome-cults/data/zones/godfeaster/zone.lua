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
	name = _t"The Godfeaster",
	display_name = function(x, y)
		if not game.level.map.attrs(x or game.player.x, y or game.player.y, "worm_body") then return _t"The Godfeaster (Alcove)"
		else return _t"The Godfeaster" end
	end,
	variable_zone_name = true,
	level_range = {30, 40},
	level_scheme = "player",
	max_level = 1,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 180, height = 50,
	-- all_remembered = true,
	-- all_lited = true,
	no_worldport = true,
	persistent = "zone",
	ambient_music = {"cults/maggot.ogg"},
	min_material_level = 4,
	max_material_level = 5,
	no_level_connectivity = true,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer", zoneclass=true,
			edge_entrances = {4,6},
			tunnel_h = 25,
			start = 25, stop = 25,
			min_h = 15, max_h = 35,
			['#'] = "GODFEASTER_WALL",
			['.'] = "GODFEASTER_FLOOR",
			up = "GODFEASTER_FLOOR",
			down = "GODFEASTER_FLOOR",
			spine_horiz = {"DEAD_GODFEASTER_SPINE_HORIZ1","DEAD_GODFEASTER_SPINE_HORIZ2","DEAD_GODFEASTER_SPINE_HORIZ3","DEAD_GODFEASTER_SPINE_HORIZ4","DEAD_GODFEASTER_SPINE_HORIZ5"},
			spine_diag_start_9 = "DEAD_GODFEASTER_SPINE_DIAG_START_9",
			spine_diag_start_3 = "DEAD_GODFEASTER_SPINE_DIAG_START_3",
			spine_diag_9 = {"DEAD_GODFEASTER_SPINE_DIAG_9_1", "DEAD_GODFEASTER_SPINE_DIAG_9_2"},
			spine_diag_3 = {"DEAD_GODFEASTER_SPINE_DIAG_3_1", "DEAD_GODFEASTER_SPINE_DIAG_3_2"},
			spine_diag_stop_9 = "DEAD_GODFEASTER_SPINE_DIAG_STOP_9",
			spine_diag_stop_3 = "DEAD_GODFEASTER_SPINE_DIAG_STOP_3",
			spine_start = "DEAD_GODFEASTER_SPINE_START",
			spine_stop = "DEAD_GODFEASTER_SPINE_STOP",
			nb_rooms = {12, 16},
			arms_range = {0.4, 0.6},
			arms_radius = {0.3, 0.5},
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {35, 40},
			filters = { {max_ood=2}, },
			guardian = "GODFEASTER",
			guardian_spot = {type="guardian", subtype="guardian"},
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
	foreground = function(level, dx, dx, nb_keyframes)
		local noise = level.tmpdata.noise
		if not noise then
			level.tmpdata.noise = core.noise.new(1)
			noise = level.tmpdata.noise
		end

		local tick = core.game.getTime()

		-- The lerping index between colors
		local x = (1 + noise:fbm_perlin(tick/10000, 4)) / 2

		local c = colors.lerp(colors.WHITE, colors.SANDY_BROWN, x)

		level.map:setShown(c[1], c[2], c[3], 1)
		level.map:setObscure(c[1] * 0.6, c[2] * 0.6, c[3] * 0.6, 1)
	end,

	post_process = function(level)
		local function place(x1, x2, define)
			if type(define) == "table" then define = rng.table(define) end
			local o = game.zone:makeEntityByName(level, "object", define)
			if not o then return end
			if o.checkFilter and not o:checkFilter({}) then return end

			local x, y = rng.range(x1, x2), rng.range(0, level.map.h-1)
			local tries = 0
			while (level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move") or level.map(x, y, engine.Map.OBJECT) or level.map.room_map[x][y].special) and tries < 100 do
				x, y = rng.range(x1, x2), rng.range(0, level.map.h-1)
				tries = tries + 1
			end
			if tries < 100 then
				game.zone:addEntity(level, o, "object", x, y)
				print("Placed lore", o.name, x, y)
				o:identify(true)
			end
		end
		place(1, level.map.w / 3, "NOTE")
	end,

	gastric_chance = 0,
	gastric_countdown = nil,
	on_turn = function(zone)
		if zone.is_dead then return end
		if game.turn % 10 ~= 0 then return end

		if not zone.malyu_triggered and game.player.x >= game.level.map.w * 3 / 4 then
			zone.malyu_triggered = true
			zone:trigger_malyu()
		end

		if not zone.gastric_countdown then
			if not rng.percent(zone.gastric_chance) then
				zone.gastric_chance = zone.gastric_chance + 0.5
				return
			end
			zone.gastric_countdown = rng.range(4, 6)
			game.bignews:say(120, "#OLIVE_DRAB#You can feel tremors in the worm.. A gastric wave is coming! Dodge to an alcove!")
			game:shakeScreen(20, 3)
		else
			zone.gastric_countdown = zone.gastric_countdown - 1
			if zone.gastric_countdown <= 0 then
				zone.gastric_countdown = nil
				zone.gastric_chance = 0
				game.bignews:say(120, "#OLIVE_DRAB#The gastric wave is upon you!")
				game:shakeScreen(30, 5)

				local map = game.level.map
				for i = math.max(map.mx, 0), math.min(map.mx + map.viewport.mwidth, map.w - 1) do for j = math.max(map.my, 0), math.min(map.my + map.viewport.mheight, map.h - 1) do
					if map.attrs(i, j, "worm_body") then
						map:particleEmitter(i, j, 1, "acid")
					end
				end end

				for uid, e in pairs(game.level.entities) do
					if e.x and e.y and e.setEffect and map.attrs(e.x, e.y, "worm_body") then
						if game:getPlayer(true):reactionToward(e) < 0 then
							e:setEffect(e.EFF_GASTRIC_WAVE_BUFF, 8, {})
						else
							e:setEffect(e.EFF_GASTRIC_WAVE_DEBUFF, 8, {})
						end
					end
				end
			end
		end
	end,

	trigger_malyu = function(zone)
		local malyu = zone:makeEntityByName(game.level, "actor", "MALYU")
		local x, y = util.findFreeGrid(game.player.x, game.player.y, 10, true, {[engine.Map.ACTOR]=true})
		if malyu and x then
			game.player:setEffect(game.player.EFF_GODFEASTER_EVENT_BLINDED, 1, {})
			local trap = require("engine.Entity").new{image="terrain/godfeaster/giant_digestive_sack_open.png", name=_t"digestive sack"}
			local chat = require("engine.Chat").new("cults+godfeaster-malyu", trap, game.player, {malyu=malyu, popx=x, popy=y})
			chat:invoke()
		end
	end,
}
