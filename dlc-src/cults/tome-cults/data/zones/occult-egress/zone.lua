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
	name = _t"Occult Egress",
	level_range = {1, 1},
	level_scheme = "player",
	max_level = 1,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 30, height = 30,
--	all_remembered = true,
	all_lited = true,
	persistent = "zone",
	ambient_music = "Rainy Day.ogg",
	min_material_level = function() return game.state:isAdvanced() and 5 or 2 end,
	max_material_level = function() return game.state:isAdvanced() and 5 or 2 end,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "!egress",
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

	auto_zone_stair = true,
	egress_state = false,
	toggle_egress = function(seq, seq_spots, portal)
		local CultsDLC = require "mod.class.CultsDLC"
		local Particles = require "engine.Particles"

		for _, s in ipairs(seq_spots) do
			local g = game.level.map(s.x, s.y, engine.Map.TERRAIN)
			for _, ps in pairs(g.add_displays[1]:getParticlesList("all")) do g.add_displays[1]:removeParticles(ps) end
			game.level.map:updateMap(s.x, s.y)
		end

		local oldstate = game.zone.egress_state

		local res = CultsDLC.checkGlyphSequence(seq)
		game.zone.egress_state = res
		if game.zone.egress_state ~= oldstate then
			local ng
			if game.zone.egress_state then
				ng = game.zone.grid_list.EGRESS_ACTIVE:cloneFull()
				game.level.map:particleEmitter(portal.x, portal.y, 1, "shader_ring_rotating", {rotation=0, radius=3.5, life=30, img="coldgeneric"}, {type="firesurge"})
			else
				ng = game.zone.grid_list.EGRESS_INACTIVE:cloneFull()
				game.level.map:particleEmitter(portal.x, portal.y, 1, "shader_ring_rotating", {rotation=0, radius=3.5, life=30, img="icewings"}, {type="firesurge"})
			end
			game.level.map(portal.x, portal.y, engine.Map.TERRAIN, ng)
		end

		if res then
			game.bignews:say(120, "#CRIMSON#The ground shakes as you finish the glyph sequence %s%s%s%s!", CultsDLC.getGlyphEntityString(seq[1]), CultsDLC.getGlyphEntityString(seq[2]), CultsDLC.getGlyphEntityString(seq[3]), CultsDLC.getGlyphEntityString(seq[4]))
			game:shakeScreen(30, 5)
			CultsDLC.executeGlyphSequence(res, game.level.map(portal.x, portal.y, engine.Map.TERRAIN), portal.x, portal.y)

			for _, s in ipairs(seq_spots) do
				local g = game.level.map(s.x, s.y, engine.Map.TERRAIN)
				g.add_displays[1]:addParticles(Particles.new('occult_egress_activator', 8, {tx=portal.x - s.x, ty=portal.y - s.y}))
				game.level.map:updateMap(s.x, s.y)
			end
			game.level.map:updateMap(portal.x, portal.y)
		end
	end,
}
