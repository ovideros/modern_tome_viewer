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
	name = _t"Ruined Cave",
	level_range = {13, 25},
	level_scheme = "player",
	max_level = 1,
	-- decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	day_night = true,
	persistent = "zone",
	ambient_music = "orcs/cave_hatred.ogg",
	min_material_level = 3,
	max_material_level = 3,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "!vault",
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

	on_enter = function(lev, old_lev, newzone)
		local Dialog = require("engine.ui.Dialog")
		if not game.level.shown_warning then
			Dialog:simplePopup(_t"Ruined Cave", _t"This cave looks very solid and stable. You can probably leave items here for later.")
			game.level.shown_warning = true
		end
	end,
}
