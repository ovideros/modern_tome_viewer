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

local creep_editer = { method="borders_def", def="gloomy_creep"}

newEntity{
	define_as = "FONT_KNOWLEDGE", image = "terrain/mushrooms/creep_gloomy_mushrooms_main_01.png",
	add_displays = {
		mod.class.Grid.new{is_demon_statue=true, image="terrain/font_of_knowledge.png", z=18},
	},
	type = "floor", subtype = "creep",
	name = "font of knowledge",
	display = '&', color_r=255, color_g=0, color_b=0,
	special_minimap = colors.BLUE,
	notice = true,
	always_remember = true,
	nice_editer = creep_editer,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act and not self.cults_font_active then
			require("engine.ui.Dialog"):yesnoPopup(_t"Font of Knowledge", _t"Do you want to touch it?", function(ret) if not ret then
				self.block_move_activated(self, x, y, e, act, couldpass)
			end end, _t"No", _t"Yes", nil, true)
		end
		return true
	end,
	block_move_activated = function(self, x, y, e, act, couldpass)
		game:chronoCancel(_t"#CRIMSON#Your timetravel has no effect on pre-determined outcomes such as this.")
		self.nice_editer = nil
		self:altered()
		if core.shader.active(4) and not self.cults_font_active then
			local Particles = require("engine.Particles")
			for i, ad in ipairs(self.add_displays) do if ad.is_demon_statue then
				self.add_displays[#self.add_displays+1] = self.new{image="invis.png", z=ad.z-1, add_mos={{_isshaderaura=true, image_alter="sdm", sdm_double=false, image=ad.image, shader="awesomeaura", shader_args={time_factor=3500, alpha=0.6, flame_scale=0.6}, textures={{"image", "particles_images/icewings.png"}}, display_y=ad.display_y}}}
			end end
			self:removeAllMOs()
			game.level.map:updateMap(x, y)
		end
		if not self.cults_font_active then
			-- There are 3 of these per floor in Forbidden Tome, first two floors not terribly dangerous, so 50% chance of talent point seems about right
			local r = rng.range(1, 1000)
			if r <= 1 then
				e.unused_prodigies = e.unused_prodigies + 1
				game.log("#PURPLE#The %s glows as you touch it. Your knowledge grows (+1 prodigy point).", self:getName())
			elseif r <= 5 then
				e.unused_talents_types = e.unused_talents_types + 1
				game.log("#VIOLET#The %s glows as you touch it. Your knowledge grows (+1 category point).", self:getName())
			elseif r <= 200 then
				e.unused_talents = e.unused_talents + 1
				game.log("#YELLOW#The %s glows as you touch it. Your knowledge grows (+1 class talent point).", self:getName())
			elseif r <= 300 then
				e.unused_generics = e.unused_generics + 1
				game.log("#ORANGE#The %s glows as you touch it. Your knowledge grows (+1 generic talent point).", self:getName())
			else
				e.unused_stats = e.unused_stats + 3
				game.log("#AQUAMARINE#The %s glows as you touch it. Your knowledge grows (+3 stat points).", self:getName())
			end
		end
		self.cults_font_active = true
	end
}

newEntity{
	define_as = "FONT_SACRIFICE", image = "terrain/cave/cave_floor_1_01.png",
	add_displays = {
		mod.class.Grid.new{is_demon_statue=true, image="terrain/font_of_sacrifice.png", z=18},
	},
	type = "floor", subtype = "cave",
	name = "font of sacrifice",
	display = '&', color_r=255, color_g=159, color_b=0,
	special_minimap = colors.YELLOW,
	notice = true,
	always_remember = true,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then
			package.loaded["mod.dialogs.FontSacrifice"] = nil
			local d = require("mod.dialogs.FontSacrifice").new()
			game:registerDialog(d)
		end
		return true
	end,
}
