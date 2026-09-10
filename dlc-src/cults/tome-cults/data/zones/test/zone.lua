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
	name = _t"test",
	level_range = {1, 15},
	level_scheme = "player",
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	update_base_level_on_enter = true,
	max_level = 1,
	width = 10, height = 10,
	decay = {300, 800, only={object=true}, no_respawn=true},
	persistent = "zone",
	-- all_remembered = true,
	all_lited = true,
	ambient_music = {"World of Ice.ogg", "weather/town_small_base.ogg"},
	allow_respec = "limited",
	max_material_level = 2,
	store_levels_by_restock = { 8, 25, 40 },

	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "!test",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {0, 0},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
	},
	-- post_process = function(level)
	-- 	game.state:makeAmbientSounds(level, {
	-- 		town_small={ chance=250, volume_mod=1, pitch=1, random_pos={rad=10}, files={"ambient/town/town_small1","ambient/town/town_small2"}},
	-- 	})
	-- end,

	post_process = function(level)
		-- -- Setup zones
		-- for _, z in ipairs(level.custom_zones) do
		-- 	if z.type == "no-teleport" then
		-- 		for x = z.x1, z.x2 do for y = z.y1, z.y2 do
		-- 			game.level.map.attrs(x, y, "no_teleport", true)
		-- 		end end
		-- 	elseif z.type == "zonename" then
		-- 		for x = z.x1, z.x2 do for y = z.y1, z.y2 do
		-- 			game.level.map.attrs(x, y, "zonename", z.subtype)
		-- 		end end
		-- 	elseif z.type == "particle" then
		-- 		if z.reverse then z.x1, z.x2, z.y1, z.y2 = z.x2, z.x1, z.y2, z.y1 end
		-- 		level.map:particleEmitter(z.x1, z.y1, math.max(z.x2-z.x1, z.y2-z.y1) + 1, z.subtype, {
		-- 			tx = z.x2 - z.x1,
		-- 			ty = z.y2 - z.y1,
		-- 		})
		-- 	end
		-- 	if z.sort_drops then
		-- 		level.data.drop_zone = z
		-- 		for x = z.x1, z.x2 do for y = z.y1, z.y2 do
		-- 			game.level.map.attrs(x, y, "on_drop", function(...) game.level.data.process_drops(...) end)
		-- 		end end
		-- 	end
		-- end
	end,
}
