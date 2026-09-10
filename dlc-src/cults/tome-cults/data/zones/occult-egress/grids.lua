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

load("/data/general/grids/cave.lua")

newEntity{base="CAVEFLOOR", define_as = "EGRESS_BASE",
	nice_tiler = false,
	display = '~', color = colors.PURPLE,
	name = "Occult Egress",
	show_tooltip = true,
	occult_egress = 1,
}

newEntity{base="EGRESS_BASE", define_as = "EGRESS_SIDES",
}

newEntity{base="EGRESS_BASE", define_as = "EGRESS_INACTIVE",
	desc = _t[[The strange device looks inactive.]],
	add_displays = {
		class.new{
			image="terrain/occult_egress/occult_egress_inactive.png", display_w=4, display_h=4, display_x=-1.5, display_y=-1.5,
		},
	},
	occult_egress_center = true,
}

newEntity{base="EGRESS_BASE", define_as = "EGRESS_ACTIVE",
	desc = _t[[The strange device looks active.]],
	add_displays = {
		class.new{
			image="terrain/occult_egress/occult_egress_activated_base.png", display_w=4, display_h=4, display_x=-1.5, display_y=-1.5,
		},
		class.new{
			z = 18,
			image="invis.png",
			embed_particles = {
				{name="occult_egress_rings", rad=5, args={inner=1}},
				{name="occult_egress_rings", rad=5, args={}},
			},
		},
	},
	occult_egress_center = true,
}

for i = 1, 4 do
newEntity{base="CAVEFLOOR", define_as = "GLYPH"..i,
	nice_tiler = false,
	display = 'B', color = colors.GREEN,
	add_mos = {{image="terrain/cults_glyphs/center_circle_big_glyph_bright.png"}},
	add_displays = {class.new{z=17, image="invis.png"}}, -- Dont remove this is used by "laser" links
	name = "Strange Glyph",
	current_glyph = "center_circle_big_glyph",
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then
			local CultsDLC = require "mod.class.CultsDLC"
			local list = CultsDLC.getGlyphsList()
			for i = 1, #list do if list[i] == self.current_glyph then
				local ni = i
				if e.x < x then ni = ni + 1
				elseif e.x > x then ni = ni - 1
				elseif e.y < y then ni = ni + 1
				else ni = ni - 1 end

				if ni <= 0 then ni = #list
				elseif ni > #list then ni = 1 end
				local ng = list[ni]
				self.current_glyph = ng
				self.display = CultsDLC.glyphToASCII(ng)
				self.add_mos[1].image = "terrain/cults_glyphs/"..ng.."_bright.png"
				self:removeAllMOs()
				game.level.map:updateMap(x, y)
				break
			end end

			local seq = {}
			local seq_spots = {}
			local portal = nil
			for i = 0, game.level.map.w - 1 do for j = 0, game.level.map.h - 1 do
				local g = game.level.map:checkEntity(i, j, engine.Map.TERRAIN, "current_glyph")
				if g then seq[#seq+1] = g seq_spots[#seq_spots+1] = {x=i, y=j} end
				local o = game.level.map:checkEntity(i, j, engine.Map.TERRAIN, "occult_egress_center")
				if o then portal = {x=i, y=j} end
			end end
			game.zone.toggle_egress(seq, seq_spots, portal)
		end
		return true
	end
}
end
