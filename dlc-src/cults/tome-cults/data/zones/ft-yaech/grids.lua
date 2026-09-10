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
	name = "exit to reality", image = "terrain/mushrooms/gloomy_underground_floor.png", add_displays = {class.new{image="terrain/ladder_up_wild.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	change_level = 1,
	change_level_shift_back = true,
}

newEntity{
	define_as = "BOOK_OF_BINDING",
	type = "book", subtype = "underground",
	name = "book of binding", image = "terrain/mushrooms/gloomy_underground_floor.png", add_displays = {class.new{is_base_d=true, image="terrain/pedestal_orb_02.png", z=18}},
	display = '&', color=colors.CRIMSON,
	notice = true, force_clone = true,
	on_move = function(self, x, y, who)
		if not who or not who.player then return end
		self.on_move = false
		if core.shader.active(4) then
			local Particles = require("engine.Particles")
			for i, ad in ipairs(self.add_displays) do if ad.is_base_d then
				self.add_displays[#self.add_displays+1] = self.new{image="invis.png", z=ad.z-1, add_mos={{_isshaderaura=true, image_alter="sdm", sdm_double=false, image=ad.image, shader="awesomeaura", shader_args={time_factor=3500, alpha=0.6, flame_scale=0.6}, textures={{"image", "particles_images/icewings.png"}}, display_y=ad.display_y}}}
			end end
			self:removeAllMOs()
			game.level.map:updateMap(x, y)
		end

		local m = game.level:findEntity{define_as="THE_ONE_THAT_WRITES"}
		if m and m:attr("invulnerable") then
			m:attr("invulnerable", -1)

			if m:attr("invulnerable") then game.bignews:say(120, "#YELLOW#You hear a terrible shriek.")
			else game.bignews:say(120, "#CRIMSON#You hear a terrible shriek, followed by the rustling of pen and papers.")
			end
		end
	end,
}
