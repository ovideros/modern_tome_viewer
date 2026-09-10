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
	name = _t"The Maggot",
	level_range = {1, 5},
	level_scheme = "player",
	max_level = 1,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 180, height = 50,
	-- all_remembered = true,
	-- all_lited = true,
	tier1 = true,
	persistent = "zone",
	ambient_music = {"cults/maggot.ogg"},
	min_material_level = 1,
	max_material_level = 1,
	no_level_connectivity = true,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer", zoneclass=true,
			edge_entrances = {4,6},
			tunnel_h = 25,
			start = 25, stop = 25,
			min_h = 15, max_h = 35,
			['#'] = "MAGGOT_WALL",
			['.'] = "MAGGOT_FLOOR",
			up = "MAGGOT_FLOOR",
			down = "MAGGOT_FLOOR",
			spine_horiz = {"MAGGOT_SPINE_HORIZ1","MAGGOT_SPINE_HORIZ2","MAGGOT_SPINE_HORIZ3","MAGGOT_SPINE_HORIZ4","MAGGOT_SPINE_HORIZ5"},
			spine_diag_start_9 = "MAGGOT_SPINE_DIAG_START_9",
			spine_diag_start_3 = "MAGGOT_SPINE_DIAG_START_3",
			spine_diag_9 = {"MAGGOT_SPINE_DIAG_9_1", "MAGGOT_SPINE_DIAG_9_2"},
			spine_diag_3 = {"MAGGOT_SPINE_DIAG_3_1", "MAGGOT_SPINE_DIAG_3_2"},
			spine_diag_stop_9 = "MAGGOT_SPINE_DIAG_STOP_9",
			spine_diag_stop_3 = "MAGGOT_SPINE_DIAG_STOP_3",
			spine_start = "MAGGOT_SPINE_START",
			nb_rooms = {12, 16},
			arms_range = {0.4, 0.6},
			arms_radius = {0.3, 0.5},
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {35, 40},
			filters = { {max_ood=2}, },
			guardian = "SPINAL_CORD",
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

	on_enter = function()
		local p = game:getPlayer(true)
		p:removeEffect(p.EFF_SAVE_KROSHKKUR, true, true)
	end,

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
		place(1, level.map.w / 3, "NOTE1")
		place(level.map.w / 3, 2 * level.map.w / 3, "NOTE2")
		place(2 * level.map.w / 3, level.map.w - 1, "NOTE3")
	end,
}
