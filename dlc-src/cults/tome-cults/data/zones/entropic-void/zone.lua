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
	name = _t"Entropic Void",
	level_range = {100, 100},
	level_scheme = "player",
	max_level = 1,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 20, height = 20,
	all_remembered = true,
	all_lited = true,
	-- zero_gravity = true, -- too annoying for melee for such a fight
	no_worldport = true,
	persistent = "zone",
	color_shown = {0.7, 0.6, 0.8, 1},
	color_obscure = {0.7*0.6, 0.6*0.6, 0.8*0.6, 0.6},
	ambient_music = "Through the Dark Portal.ogg",
	min_material_level = 5,
	generator = {
		map = {
			class = "engine.generator.map.Static",
			map = "!final",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {0, 0},
		},
	},

	last_antropy = 50,
	on_turn = function()
		game.level.data.last_antropy = game.level.data.last_antropy - 1
		if game.level.data.last_antropy > 0 then return end

		local _, _, gs = util.findFreeGrid(game.player.x, game.player.y, 10, true, {})
		if gs and #gs > 0 then
			local dur = rng.range(7, 11)
			game.level.data.last_antropy = dur * 10

			local DamageType = require "engine.DamageType"
			local MapEffect = require "engine.MapEffect"
			local x, y = gs[#gs][1], gs[#gs][2]
			game.level.map:addEffect(game.player, x, y, dur, DamageType.ENTROPIC_VOID_HELPER, 5, rng.range(1, 2), 5, nil, MapEffect.new{color_br=255, color_bg=249, color_bb=60, alpha=100, effect_shader="shader_images/sun_effect.png"}, nil, true)
			game.bignews:say(100, "#GOLD#An #{bold}#antropy#{normal}# zone appears, run to it!")
		end
	end,

	post_process = function(level)
		local Map = require "engine.Map"
		if core.shader.allow("volumetric") then
			level.starfield_shader = require("engine.Shader").new("entropic_starfield", {size={Map.viewport.width, Map.viewport.height}})
		else
			level.background_particle = require("engine.Particles").new("starfield", 1, {width=Map.viewport.width, height=Map.viewport.height})
		end
	end,

	on_enter = function()
		game.party:learnLore("cults-entropic-void")
	end,

	background = function(level, x, y, nb_keyframes)
		local Map = require "engine.Map"
		if level.starfield_shader and level.starfield_shader.shad then
			level.starfield_shader.shad:use(true)
			core.display.drawQuad(x, y, Map.viewport.width, Map.viewport.height, 1, 1, 1, 1)
			level.starfield_shader.shad:use(false)
		elseif level.background_particle then
			level.background_particle.ps:toScreen(x, y, true, 1)
		end
	end,
}
