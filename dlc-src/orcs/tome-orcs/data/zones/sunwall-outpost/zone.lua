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
	name = _t"Sunwall Outpost",
	level_range = {8, 12},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	day_night = true,
	persistent = "zone",
	ambient_music = {"orcs/sun.ogg"},
	min_material_level = 2,
	max_material_level = 2,
	generator =  {
		map = {
			class = "engine.generator.map.Town", zoneclass=true,
			building_chance = 80,
			max_building_w = 10, max_building_h = 10,
			edge_entrances = {4,6},
			barricade = "GRASS_WOODEN_BARRICADE",
			floor = "BAMBOO_HUT_FLOOR",
			external_floor = {"GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","GRASS","TREE"},
			wall = "BAMBOO_HUT_WALL",
			up = "GRASS_UP4",
			down = "GRASS_DOWN6",
			door = "BAMBOO_HUT_DOOR",
			['#'] = "BAMBOO_HUT_WALL",
			['.'] = "BAMBOO_HUT_FLOOR",
			['+'] = "BAMBOO_HUT_DOOR",

			nb_rooms = {0,1,1,2},
			rooms = {"lesser_vault", "random_room"}, --Add more vaults at some point
			lesser_vaults_list = {"circle"},
			lite_room_chance = 100,
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {20, 30},
			filters = { {max_ood=5}, },
			guardian = "LEADER_JOHN",
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
				up = "GRASS_UP_WILDERNESS",
			}, },
		},
	},
	
	post_process = function(level)
		-- Place a lore note on each level
		game:placeRandomLoreObjectScale("NOTE", {{1}, {2,3}, {4,5}}, level.level)
	end,

	on_enter = function(lev, old_lev, newzone)
		if game.level.data['gave-help'..lev] then return end
		game.level.data['gave-help'..lev] = true

		local m = game.zone:makeEntityByName(game.level, "actor", (rng.table{"ORC_RETALIATOR", "ORC_GUNSLINGER"}))
		local x, y = util.findFreeGrid(game.player.x, game.player.y, 10, true, {[engine.Map.ACTOR]=true})
		if x and m then
			game.zone:addEntity(game.level, m, "actor", x, y)
			game.party:addMember(m, {
				temporary_level = true,
				control="order", type="assault team", title=m.name,
				orders = {leash=true, anchor=true}, -- behavior=true},
			})
			require("engine.ui.Dialog"):simplePopup(_t"Reinforcements!", ("An %s has managed to join forces with you!"):tformat(m.getName and m:getName() or m.name))
		end
	end,
}
