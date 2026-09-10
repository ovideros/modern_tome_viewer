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
	name = _t"Dremshor Tunnels",
	display_name = function(x, y)
		if game.level.level == 1 then return _t"Dremshor Tunnels" end
		return _t"Strange Machine"
	end,
	level_range = {15, 30},
	level_scheme = "player",
	max_level = 2,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	persistent = "zone",
	ambient_music = {"cults/maggot.ogg"},
	min_material_level = 2,
	max_material_level = 3,
	generator =  {
	},
	levels =
	{
		[1] = {
			width = 150, height = 24,
			generator =  {
				map = {
					class = "engine.generator.map.Static",
					map = "!end-tunnel",
				},
				actor = {
					class = "mod.class.generator.actor.Random",
					nb_npc = {60, 60},
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
			width = 50, height = 50,
			all_lited = true,
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "!machine",
				},
				actor = {
					nb_npc = {12, 15},
				},
			},
		},
	},

	post_process = function(level)
		if level.level == 1 then
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
			place(1, level.map.w / 2, "NOTE1")
			place(level.map.w / 2, level.map.w - 1, "NOTE2")
		end
	end,
}
