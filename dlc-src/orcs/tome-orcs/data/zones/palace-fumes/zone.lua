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
	name = _t"Palace of Fumes",
	level_range = {40, 45},
	level_scheme = "player",
	max_level = 6,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	-- day_night = true,
	persistent = "zone",
	ambient_music = {"orcs/palace.ogg"},
	min_material_level = 5,
	max_material_level = 5,
	generator = {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			rooms = {"random_room", {"pit",3}, {"lesser_vault",2}, {"greater_vault",3}},
			rooms_config = {pit={filters={{type="giant", subtype="steam"}, {type="giant", subtype="yeti"}, {type="mechanical"}}}},
			lesser_vaults_list = {"circle"},
			lite_room_chance = 10,
			['+'] = "MECHSTONE_DOOR",
			['.'] = "MECHSTONE_FLOOR",
			['#'] = "MECHSTONE_WALL",
			up = "MECHSTONE_UP",
			down = "MECHSTONE_DOWN",
			door = "MECHSTONE_DOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {25, 35},
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
			generator =  {
				map = { up = "MECHSTONE_UP_WILDERNESS", },
				actor = { zoneclass=true, },
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
				map = { required_rooms = {"!phonograph"}, },
				actor = { zoneclass=true, },
			},
		},
		[6] = {
			all_lited = true,
			no_level_connectivity = true,
			generator = { map = {
				class = "engine.generator.map.Static",
				map = "!final",
			}, actor = {
				nb_npc = {0, 0},
			}, object = {
				nb_object = {0, 0},
			}},
		},
	},

	post_process = function(level)
		game.player:grantQuest("orcs+palace")

		if level.level == 1 then
			game:placeRandomLoreObject("NOTE1")
			game:placeRandomLoreObject("NOTE2")
			game:placeRandomLoreObject("NOTE3")
		elseif level.level == 2 then
			game:placeRandomLoreObject("DESTRUCTICUS_LORE")
		elseif level.level == 3 then
			game:placeRandomLoreObject("NOTE4")
			game:placeRandomLoreObject("NOTE5")
		elseif level.level == 4 then
			game:placeRandomLoreObject("NOTE6")
			game:placeRandomLoreObject("NOTE7")
		end

		if level.level == 6 then
			for _, z in ipairs(level.custom_zones) do
				if z.type == "no-teleport" then
					for x = z.x1, z.x2 do for y = z.y1, z.y2 do
						game.level.map.attrs(x, y, "no_teleport", true)
					end end
				end
			end
		end
	end,
}
