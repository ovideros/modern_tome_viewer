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

-- Normal campaign
newEntity{
	name = "Occult Egress",
	type = "harmless", subtype = "special", unique = true,
	immediate = {"world-encounter", "maj-eyal"},
	on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g.name = _t"Way to a strange portal"
		g.display='>' g.color_r=0 g.color_g=255 g.color_b=0 g.notice = true
		g.change_level=1 g.change_zone="cults+occult-egress" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/cave_entrance01.png", z=5}
		g:altered()
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		print("[WORLDMAP] Occult Egress at", x, y)
		return true
	end,
}

newEntity{
	name = "Godfeaster",
	type = "hostile", subtype = "special", unique = true,
	level_range = {24, 35},
	rarity = 50,
	min_level = 30,
	coords = {{ x=0, y=0, w=100, h=100}},
	on_encounter = function(self, who)
		who.energy.value = game.energy_to_act
		game.paused = true
		who:runStop()
		engine.ui.Dialog:yesnoLongPopup(_t"Encounter", _t"The ground suddenly shakes under your feet and a giant worm appears to gobble you up!\nYou could try to escape using the Rod of Recall or accept your fate.", 500, function(ret)
			if ret then
				game:changeLevel(1, "cults+godfeaster")
			else
				game.log("You manage in extremis to activate the rod in emergency. As you keep on falling towards the maw of the worm the rod finishes charging up and you re-appear nearby, safe from the monstrosity.")
			end
		end, _t"Accept your fate", _t"Use the rod", true)
		game.party:learnLore("cults-godfeaster-popup")
		return true
	end,
}
