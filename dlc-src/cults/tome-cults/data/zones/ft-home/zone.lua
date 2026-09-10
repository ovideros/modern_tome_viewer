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
	name = _t"The Home Which Is Not",
	is_cults_book = "book-texture-home", no_worldport = true,
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	level_range = {18, 25},
	max_level = 1,
	width = 60, height = 60,
	all_remembered = true,
	all_lited = true,
	persistent = "zone",
	ambient_music = "Dreaming of Flying.ogg",
	no_level_connectivity = true,
	no_worldport = true,
	underwater = true,
	generator =  {
		map = {
			class = "mod.class.generator.map.StaticPredrawn",
			map = "!home",
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

	on_enter = function()
		local p = game:getPlayer(true)
		if p.in_combat then
			p:setEffect(p.EFF_CULTS_BOOK_HOME_TIMEOUT, 15, {})
		end
	end,
	on_leave = function()
		-- Look for the book on the floor
		local map = game.level.map
		for x = 0, map.w - 1 do for y = 0, map.h - 1 do
			local tot = map:getObjectTotal(x, y)
			for i = 1, tot do
				local o = map:getObject(x, y, i)
				if o.define_as== "FORBIDDEN_TOME_HOME" then
					world:gainAchievement("CULTS_HOME_RECURSIVE", self)
					return
				end
			end
		end end
	end,

	post_process = function(level)
		-- Cosmetic stuff
		game.state:makeWeather(level, 6, {max_nb=12, chance=1, dir=120, speed={1.5, 5.9}, r=0.2, g=0.4, b=1, alpha={0.2, 0.4}, particle_name="weather/grey_cloud_%02d"})

		if not config.settings.tome.weather_effects then return end

		local Map = require "engine.Map"
		level.foreground_particle = require("engine.Particles").new("snowing", 1, {width=Map.viewport.width, height=Map.viewport.height, r=1, g=0.25, b=0.1, rv=-0.001, gv=0, bv=-0.001, factor=2, dir=math.rad(110+180)})
	end,
	foreground = function(level, x, y, nb_keyframes)
		if not config.settings.tome.weather_effects or not level.foreground_particle then return end
		level.foreground_particle.ps:toScreen(x, y, true, 1)
	end,
}
