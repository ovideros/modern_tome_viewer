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
	name = _t"Necromancers' Ruins",
	level_range = {18, 30},
	level_scheme = "player",
	max_level = 2,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 30, height = 30,
	all_remembered = true,
	-- all_lited = true,
	persistent = "zone",
	ambient_music = "Remembrance.ogg",
	min_material_level = 4,
	max_material_level = 4,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 7,
			rooms = {"random_room"},
			lite_room_chance = 20,
			['.'] = "FLOOR",
			['#'] = "WALL",
			up = "UP",
			down = "DOWN",
			door = "DOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {25, 30},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {10, 10},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "UP_WILDERNESS",
			}, },
		},
		[2] = {
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "!final",
				},
				actor = {
					class = "mod.class.generator.actor.Random",
					nb_npc = {0, 0},
				},
				object = {
					class = "engine.generator.object.Random",
					nb_object = {0, 0},
				},
				trap = {
					class = "engine.generator.trap.Random",
					nb_trap = {0, 0},
				},
			},
		},
	},
	on_enter = function(lev)
		if lev == 2 and not game.level.data.seen_warning then
			game.level.data.seen_warning = true
			game.level.turn_counter = 40 * 10
			game.level.max_turn_counter = 40 * 10
			game.level.turn_counter_desc = _t"The cultists are about to sacrifice the woman. Stop them!"
			require("engine.ui.Dialog"):simpleLongPopup(_t"Chanting", _t"The foul stench of rotten ichor and undeath hangs over this place. There is necromancy at work here. As you listen more closely, you can hear anguished bellows coming from further inside the lair. There's a certain rough and deep timbre to the voice, sounding like a mix of a dragon's roar and a giant's rumblings. That could be none other than the Krogs you came to rescue. You do not know what experiments the necromancers are performing on them, but you're certain that you need to stop them before they succeed.", 600)
		end
	end,
	on_turn = function(self)
		if game.level.turn_counter then
			game.level.turn_counter = game.level.turn_counter - 1
			game.player.changed = true
			if game.level.turn_counter < 0 then
				game.level.turn_counter = nil
				require("engine.ui.Dialog"):simplePopup(_t"Captive Krogs", _t"The captive krogs are no longer protected in their time prisons are very vulnerable!")
			end
		end
	end,
}
