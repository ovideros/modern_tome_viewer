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
load("/data/general/grids/cave.lua")
load("/data/general/grids/forest.lua", function(e) e.nice_editer = nil if e.image == "terrain/grass.png" then e.image = "terrain/mushrooms/gloomy_underground_floor.png" end end)
load("/data/general/grids/underground_gloomy.lua")

newEntity{
	define_as = "WAY_HOME",
	type = "floor", subtype = "underground",
	name = "return home", image = "terrain/mushrooms/gloomy_underground_floor.png", add_displays = {class.new{image="terrain/book_of_transition_exit.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	change_level_check = function(self)
		if not game.player:isQuestStatus("cults+grung", engine.Quest.COMPLETED, "food") then
			require("engine.ui.Dialog"):simplePopup(_t"Grung", _t"Grung story does not end yet, find more food and bring it here.")
			return true
		end
		if game.zone.book_source then game.zone.book_source.book_ended = true end
		require("engine.ui.Dialog"):simplePopup(_t"Grung", _t"Grung story ends there, he manages to gather enough food to survive some more days.")
	end,
	change_level = 1,
	change_level_shift_back = true,
}

local bodies_list = {
	"terrain/dead_tentacly_beings/dead_blade_horror.png",
	"terrain/dead_tentacly_beings/dead_horror_01.png",
	"terrain/dead_tentacly_beings/dead_horror_02.png",
	"terrain/dead_tentacly_beings/dead_horror_03.png",
	"terrain/dead_tentacly_beings/dead_luminous_horror.png",
	"terrain/dead_tentacly_beings/dead_shertul_01.png",
	"terrain/dead_tentacly_beings/dead_shertul_02.png",
	"terrain/dead_tentacly_beings/dead_shertul_03.png",
	"terrain/dead_tentacly_beings/dead_shertul_04.png",
	"terrain/dead_tentacly_beings/dead_wtw.png",
}

newEntity{
	define_as = "DEAD_BODY",
	type = "floor", subtype = "cave",
	name = "dead creature", image = "terrain/cave/cave_floor_1_01.png",
	display = '*', color_r=255, color_g=0, color_b=0,
	notice = true,
	nice_tiler = { method="replace", base={"DEAD_BODY", 100, 1, #bodies_list}},
	on_move = function(self, x, y, who)
		if who and who.player then game.zone.grung_emote(who, "dead_tentacles") end
	end,
}

for i, file in ipairs(bodies_list) do
	newEntity{ base = "DEAD_BODY", define_as = "DEAD_BODY"..i, add_mos={{image=file}}}
end

newEntity{
	define_as = "UNDERGROUND_DEAD_BODY",
	type = "floor", subtype = "underground",
	name = "dead creature", image = "terrain/mushrooms/gloomy_underground_floor.png",
	display = '*', color_r=255, color_g=0, color_b=0,
	notice = true,
	nice_tiler = { method="replace", base={"UNDERGROUND_DEAD_BODY", 100, 1, #bodies_list}},
	on_move = function(self, x, y, who)
		if who and who.player then game.zone.grung_emote(who, "dead_tentacles") end
	end,
}

for i, file in ipairs(bodies_list) do
	newEntity{ base = "UNDERGROUND_DEAD_BODY", define_as = "UNDERGROUND_DEAD_BODY"..i, add_mos={{image=file}}}
end

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
