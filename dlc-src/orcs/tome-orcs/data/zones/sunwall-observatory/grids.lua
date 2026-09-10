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
load("/data/general/grids/forest.lua")
load("/data/general/grids/mountain.lua")
load("/data/general/grids/cave.lua")

newEntity{
	define_as = "EMPTY",
	type = "void", subtype = "void",
	name = "bottom of the mountain",
	display = ' ',
	_noalpha = false,
	always_remember = true,
	does_block_move = true,
	pass_projectile = true,
	can_pass = {levitation=1},
}

newEntity{
	define_as = "OBSERVATORY_ROCKS",
	type = "floor", subtype = "rocks",
	name = "rocks", image = "terrain/observatory_rocks05_01.png",
	display = '.', color_r=255, color_g=255, color_b=255,
	_noalpha = false,
	nice_tiler = { method="outerSpace",
		replace_wrong="EMPTY",
		rocks="OBSERVATORY_ROCKS_5",
		void8={"OBSERVATORY_ROCKS_8", 100, 1, 1}, void2={"OBSERVATORY_ROCKS_2", 100, 1, 1}, void4={"OBSERVATORY_ROCKS_4", 100, 1, 1}, void6={"OBSERVATORY_ROCKS_6", 100, 1, 1}, void1={"OBSERVATORY_ROCKS_1", 100, 1, 1}, void3={"OBSERVATORY_ROCKS_3", 100, 1, 1}, void7={"OBSERVATORY_ROCKS_7", 100, 1, 1}, void9={"OBSERVATORY_ROCKS_9", 100, 1, 1}, inner_void1="OBSERVATORY_ROCKS_1I", inner_void3="OBSERVATORY_ROCKS_3I", inner_void7="OBSERVATORY_ROCKS_7I", inner_void9="OBSERVATORY_ROCKS_9I",
	},
}

newEntity{base="OBSERVATORY_ROCKS", define_as = "OBSERVATORY_ROCKS_5", image="terrain/observatory_rocks05_01.png"}
for i = 1, 9 do for j = 1, 1 do
	if i ~= 5 then newEntity{base="OBSERVATORY_ROCKS", define_as = "OBSERVATORY_ROCKS_"..i..j, image="terrain/observatory_rocks0"..i.."_0"..j..".png"} end
end end
newEntity{base="OBSERVATORY_ROCKS", define_as = "OBSERVATORY_ROCKS_1I", image="terrain/observatory_rocks_inner01_01.png"}
newEntity{base="OBSERVATORY_ROCKS", define_as = "OBSERVATORY_ROCKS_3I", image="terrain/observatory_rocks_inner03_01.png"}
newEntity{base="OBSERVATORY_ROCKS", define_as = "OBSERVATORY_ROCKS_7I", image="terrain/observatory_rocks_inner07_01.png"}
newEntity{base="OBSERVATORY_ROCKS", define_as = "OBSERVATORY_ROCKS_9I", image="terrain/observatory_rocks_inner09_01.png"}


newEntity{
	define_as = "ITEMS_VAULT",
	name = "way into a strange cave", image = "terrain/observatory_rocks05_01.png", add_mos = {{image="terrain/stair_down.png"}},
	display = '<', color_r=0, color_g=255, color_b=255,
	notice = true,
	always_remember = true,
	change_level = 1,
	change_zone = "orcs+shertul-cave",
}

newEntity{
	define_as = "TO_CAVE",
	name = "stairs to the previous level", image = "terrain/observatory_rocks05_01.png", add_mos = {{image="terrain/stair_down.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "BACK_TO_CAVE",
	name = "stairs to the cavern", image = "terrain/observatory_rocks05_01.png", add_mos = {{image="terrain/stair_down.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "SUN_PILAR",
	name = "pillar of the sun", image = "terrain/observatory_rocks05_01.png", add_mos={{image="terrain/sun_pillar_1.png"}}, add_displays = {class.new{image="terrain/sun_pillar_0.png", z=17, display_y=-1}},
	display = '#', color_r=255, color_g=255, color_b=0,
	notice = true,
	does_block_move = true,
	block_sight = true,
}

newEntity{
	define_as = "MOON_PILAR",
	name = "pillar of the moons", image = "terrain/observatory_rocks05_01.png", add_mos={{image="terrain/moon_pillar_1.png"}}, add_displays = {class.new{image="terrain/moon_pillar_0.png", z=17, display_y=-1}},
	display = '#', color_r=255, color_g=255, color_b=0,
	notice = true,
	does_block_move = true,
	block_sight = true,
}
