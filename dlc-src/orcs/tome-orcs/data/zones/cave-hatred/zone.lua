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
	name = _t"Cave of Hatred",
	level_range = {30, 40},
	level_scheme = "player",
	max_level = 1,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	-- all_lited = true,
	persistent = "zone",
	ambient_music = "orcs/cave_hatred.ogg",
	min_material_level = 4,
	max_material_level = 4,
	generator =  {
		map = {
			class = "engine.generator.map.Octopus", zoneclass=true,
			main_radius = {0.3, 0.4},
			arms_radius = {0.1, 0.2},
			arms_range = {0.7, 0.8},
			nb_rooms = {6, 6},
			['#'] = "UNDERGROUND_TREE",
			['.'] = "UNDERGROUND_FLOOR",
			up = "UNDERGROUND_LADDER_UP",
			down = "UNDERGROUND_FLOOR",
			door = "UNDERGROUND_FLOOR",
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
	levels =
	{
		[1] = {
			generator = { map = {
				up = "UNDERGROUND_LADDER_UP_WILDERNESS",
			}, },
		},
	},

	post_process = function(level)
		game:placeRandomLoreObject("ROGUE_GALLERY_SCHEMATIC") -- Not lore but it's useful

		local Map = require "engine.Map"
		level.foreground_particle = require("engine.Particles").new(is_purified and "fulldream" or "fullgloom", 1, {radius=(Map.viewport.mwidth + Map.viewport.mheight) / 2})
	end,

	foreground = function(level, x, y, nb_keyframes)
		if not level.foreground_particle then return end
		level.foreground_particle.ps:toScreen(x + level.map.viewport.width / 2, y + level.map.viewport.height / 2, true, 1)
	end,

	shadows_killed = 0,
	on_shadow_kill = function(self)
		self.shadows_killed = self.shadows_killed + 1
		if self.shadows_killed < 6 then return end

		local john = self:makeEntityByName(game.level, "actor", "JOHN")
		local spot = game.level:pickSpot({type="room", subtype="main"})
		local x, y = util.findFreeGrid(spot.x, spot.y, 8, true, {[engine.Map.ACTOR]=true})
		self:addEntity(game.level, john, "actor", x, y)
		game.bignews:saySimple(180, "#CRIMSON#You feel a great power nearby!")
	end,
}
