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
load("/data-cults/general/grids/spacedwarf-creep.lua")

newEntity{
	define_as = "SPACEDWARF_FLOOR_TO_CAVE",
	type = "floor", subtype = "floor",
	name = "floor", image = "terrain/spacedwarf/spacedwarf_floor1.png", add_mos={{image="terrain/fortress-ancient/cavefloor_cracks_outer_6_1.png"}},
	display = '.', color_r=128, color_g=128, color_b=255, back_color=colors.DARK_GREY,
}

newEntity{
	define_as = "CAVE_LADDER_UP_EGRESS",
	type = "floor", subtype = "cave",
	name = "portal back to the occult egress", image = "terrain/cave/cave_floor_1_01.png", add_displays = {class.new{image="terrain/demon_portal.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	change_level = 1,
	change_zone = "cults+occult-egress",
}

newEntity{
	define_as = "TO_LAB",
	type = "floor", subtype = "floor",
	name = "stairs down", image = "terrain/spacedwarf/spacedwarf_floor1.png", add_displays = {class.new{image="terrain/spacedwarf/spacedwarf_stairs_down1.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	change_level = 1,
}

newEntity{
	define_as = "TO_TUNNELS",
	type = "floor", subtype = "floor",
	name = "back to the tunnels", image = "terrain/spacedwarf/spacedwarf_floor1.png", add_displays = {class.new{image="terrain/spacedwarf/spacedwarf_stairs_up_big_lower.png"}, class.new{image="terrain/spacedwarf/spacedwarf_stairs_up_big_upper.png", display_y=-1, z=16}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	change_level = -1,
}

newEntity{
	define_as = "VATS",
	type = "floor", subtype = "floor",
	name = "incubator", image = "terrain/spacedwarf/spacedwarf_floor1.png",
	desc = _t[[A strange kind of huge glass tube, something seems to be floating inside...]],
	display = '|', color_r=0, color_g=155, color_b=255,
	notice = true,
	is_vats = true,
	nice_tiler = { method="replace", base={"VATS", 100, 1, 4}},
}
for i = 1, 4 do
newEntity{ base = "VATS", define_as = "VATS"..i,
	add_displays = {class.new{image = "terrain/spacedwarf/spacedwarf_vat_l_0"..i..".png", display_h=2, display_y=-1, z=18}},
}
end

newEntity{
	define_as = "COMPUTER",
	type = "wall", subtype = "floor",
	name = "wheeing and buzzing thing",
	image = "terrain/spacedwarf/spacedwarf_floor1.png", add_mos={{image = "terrain/spacedwarf/spacedwarf_computer.png"}},
	display = '&', color_r=128, color_g=128, color_b=255, back_color=colors.GREY,
	z = 3,
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	air_level = -20,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then game.party:learnLore("cults-orbital-shipyard") end
		return true
	end	
}
