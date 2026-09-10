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


newEntity{
	name = "Tinker Cave", define_as = "TINKER_CAVE",
	type = "harmless", subtype = "special", unique = true,
	immediate = {force_spot={x=18, y=2}},
	on_encounter = function(self, who)
		local player = game:getPlayer(true)
		if not player:knowTalentType("steamtech/physics") and not player:knowTalentType("steamtech/chemistry") then return end -- Only for non tinkers
		if not game:isCampaign("Maj'Eyal") then return end -- Only main campaign

		return self:on_encounter_execute(who)
	end,
	on_encounter_execute = function(self, who)
		if game.state.tinker_cave_done then return end
		local x, y = self:findSpot(who)
		if not x then return end

		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g:removeAllMOs()
		g.name = _t"Entrance the tinker's master cave"
		g.display='>' g.color_r=colors.RED.r g.color_g=colors.RED.g g.color_b=colors.RED.b g.notice = true
		g.change_level=1 g.change_zone="orcs+tinker-master" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/crystal_ladder_down.png", z=4}
		g:altered()
		g:initGlow()
		game.state:locationRevealAround(x, y)
		game.zone:addEntity(game.level, g, "terrain", x, y)
		game.state.tinker_cave_done = true
		print("[WORLDMAP] Tinkers Cave at", x, y)
		return true
	end,
}
