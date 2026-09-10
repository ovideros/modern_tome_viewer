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

load("/data/general/grids/basic.lua")
load("/data/general/grids/underground_gloomy.lua")

newEntity{
	define_as = "BOOK_OUT",
	type = "floor", subtype = "underground",
	name = "exit to reality", image = "terrain/mushrooms/gloomy_underground_floor.png", add_displays = {class.new{image="terrain/temporal_instability_nether.png", z=3}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	change_level = 1,
	change_level_shift_back = true,
	change_level_check = function(self, player)
		require("engine.ui.Dialog"):yesnoPopup(_t"Forbidden Tome", _t"Do you really want to exit the tome? You will not be able to come back.", function(ret) if not ret then
			game:changeLevelReal(1, "useless", {temporary_zone_shift_back=true})
		end end, _t"Stay", _t"Exit", nil, true)
		return true
	end,
}

newEntity{
	define_as = "BOOK_PREV",
	type = "floor", subtype = "underground",
	name = "previous chapter", image = "terrain/mushrooms/gloomy_underground_floor.png", add_displays = {class.new{image="terrain/book_of_transition_back.png", z=3}},
	display = '<', color_r=255, color_g=255, color_b=255,
	notice = true,
	change_level = -1,
}

newEntity{
	define_as = "BOOK_NEXT",
	type = "floor", subtype = "underground",
	name = "next chapter", image = "terrain/mushrooms/gloomy_underground_floor.png", add_displays = {class.new{image="terrain/book_of_transition_forth.png", z=3}},
	display = '>', color_r=255, color_g=255, color_b=255,
	notice = true,
	change_level = 1,
}

newEntity{
	define_as = "BOOK_OF_BINDING",
	type = "book", subtype = "underground",
	name = "book of binding", image = "terrain/mushrooms/gloomy_underground_floor.png", add_displays = {class.new{image="terrain/book_of_binding_lower.png", display_y=-1, display_h=2}, class.new{is_base_d=true, image="terrain/book_of_binding_upper.png", is_top_d=true, z=18, display_y=-1, display_h=2}},
	display = '&', color=colors.CRIMSON,
	notice = true, force_clone = true,
	special = true,
	on_move = function(self, x, y, who)
		if not who or not who.player then return end
		self.on_move = false
		for i, ad in ipairs(self.add_displays) do if ad.is_top_d then
			ad.image = "terrain/book_of_binding_upper_glow.png"
		end end
		self:removeAllMOs()
		game.level.map:updateMap(x, y)

		local m = game.level:findEntity{define_as="THE_ONE_THAT_WRITES"}
		if m and m:attr("invulnerable") then
			m:attr("invulnerable", -1)

			if m:attr("invulnerable") then
				game.bignews:say(120, "#YELLOW#You hear a terrible shriek!")
			else
				game.bignews:say(120, "#CRIMSON#You hear a terrible shriek, followed by the rustling of pen and papers.  You feel the guardian of this place grow in power.")
				m.movement_speed = m.movement_speed + 0.5  -- Very fast once vulnerable
			end
		end
	end,
}
