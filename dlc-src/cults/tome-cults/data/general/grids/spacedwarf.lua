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

-----------------------------------------
-- Basic floors
-----------------------------------------
newEntity{
	define_as = "SPACEDWARF_FLOOR",
	type = "floor", subtype = "floor",
	name = "floor", image = "terrain/spacedwarf/spacedwarf_floor1.png",
	display = '.', color_r=128, color_g=128, color_b=255, back_color=colors.DARK_GREY,
	nice_tiler = { method="replaceSpaceDwarf", base="SPACEDWARF_FLOOR", octaves=4},
}
for i = 1, 8 do newEntity{ base = "SPACEDWARF_FLOOR", define_as = "SPACEDWARF_FLOOR"..i, image="terrain/spacedwarf/spacedwarf_floor"..i..".png"} end

-----------------------------------------
-- Walls
-----------------------------------------
newEntity{
	define_as = "SPACEDWARF_WALL",
	type = "wall", subtype = "floor",
	name = "wall", image = "terrain/spacedwarf/spacedwarf_wall_block1.png",
	display = '#', color_r=128, color_g=128, color_b=255, back_color=colors.GREY,
	z = 3,
	nice_tiler = { method="wall3d", inner={"SPACEDWARF_WALL", 100, 1, 2}, north={"SPACEDWARF_WALL_NORTH", 100, 1, 2}, south={"SPACEDWARF_WALL_SOUTH", 100, 1, 3}, north_south="SPACEDWARF_WALL_NORTH_SOUTH", pillar_8={"SPACEDWARF_WALL_PILLAR_8", 100, 1, 2}, pillar_2="SPACEDWARF_WALL_PILLAR_2", pillar_6="SPACEDWARF_WALL_NORTH_SOUTH", pillar_4="SPACEDWARF_WALL_NORTH_SOUTH", small_pillar={"SPACEDWARF_WALL_SMALL_PILLAR", 100, 1, 3} },
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	air_level = -20,
}
for i = 1, 2 do
	newEntity{ base = "SPACEDWARF_WALL", define_as = "SPACEDWARF_WALL"..i, image = "terrain/spacedwarf/spacedwarf_wall_block"..i..".png", z = 3, add_displays={class.new{image="terrain/spacedwarf/spacedwarf_ver_edge_left_01.png", z=16, display_x=-1}, class.new{image="terrain/spacedwarf/spacedwarf_ver_edge_right_01.png", z=17, display_x=1}}}
	newEntity{ base = "SPACEDWARF_WALL", define_as = "SPACEDWARF_WALL_NORTH"..i, image = "terrain/spacedwarf/spacedwarf_wall_block"..i..".png", z = 3, add_displays = {class.new{image="terrain/spacedwarf/spacedwarf_wall_top_block1.png", z=18, display_y=-1}, class.new{image="terrain/spacedwarf/spacedwarf_ver_edge_left_01.png", z=16, display_x=-1}, class.new{image="terrain/spacedwarf/spacedwarf_ver_edge_right_01.png", z=17, display_x=1}}}
	newEntity{ base = "SPACEDWARF_WALL", define_as = "SPACEDWARF_WALL_PILLAR_8"..i, image = "terrain/spacedwarf/spacedwarf_wall_block"..i..".png", z = 3, add_displays = {class.new{image="terrain/spacedwarf/spacedwarf_wall_top_block1.png", z=18, display_y=-1}, class.new{image="terrain/spacedwarf/spacedwarf_ver_edge_left_01.png", z=16, display_x=-1}, class.new{image="terrain/spacedwarf/spacedwarf_ver_edge_right_01.png", z=17, display_x=1}}}
end
newEntity{ base = "SPACEDWARF_WALL", define_as = "SPACEDWARF_WALL_PILLAR_2", image = "terrain/spacedwarf/spacedwarf_wall1.png", z = 3, add_displays={class.new{image="terrain/spacedwarf/spacedwarf_ver_edge_left_01.png", z=16, display_x=-1}, class.new{image="terrain/spacedwarf/spacedwarf_ver_edge_right_01.png", z=17, display_x=1}}}
newEntity{ base = "SPACEDWARF_WALL", define_as = "SPACEDWARF_WALL_NORTH_SOUTH", image = "terrain/spacedwarf/spacedwarf_wall1.png", z = 3, add_displays = {class.new{image="terrain/spacedwarf/spacedwarf_wall_top_block1.png", z=18, display_y=-1}, class.new{image="terrain/spacedwarf/spacedwarf_ver_edge_left_01.png", z=16, display_x=-1}, class.new{image="terrain/spacedwarf/spacedwarf_ver_edge_right_01.png", z=17, display_x=1}}}
for i = 1, 3 do
	newEntity{ base = "SPACEDWARF_WALL", define_as = "SPACEDWARF_WALL_SOUTH"..i, image = "terrain/spacedwarf/spacedwarf_wall"..i..".png", z = 3, add_displays={class.new{image="terrain/spacedwarf/spacedwarf_ver_edge_left_01.png", z=16, display_x=-1}, class.new{image="terrain/spacedwarf/spacedwarf_ver_edge_right_01.png", z=17, display_x=1}}}
	newEntity{ base = "SPACEDWARF_WALL", define_as = "SPACEDWARF_WALL_SMALL_PILLAR"..i, image = "terrain/spacedwarf/spacedwarf_wall"..i..".png", z = 3, add_displays={class.new{image="terrain/spacedwarf/spacedwarf_wall_top_block1.png", z=18, display_y=-1}, class.new{image="terrain/spacedwarf/spacedwarf_ver_edge_left_01.png", z=16, display_x=-1}, class.new{image="terrain/spacedwarf/spacedwarf_ver_edge_right_01.png", z=17, display_x=1}}}
end

-----------------------------------------
-- Doors
-----------------------------------------
newEntity{
	define_as = "SPACEDWARF_DOOR",
	type = "wall", subtype = "floor",
	name = "door", image = "terrain/spacedwarf/granite_door1.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="SPACEDWARF_DOOR_VERT", west_east="SPACEDWARF_DOOR_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	is_door = true,
	door_opened = "SPACEDWARF_DOOR_OPEN",
	door_sound = "ambient/door_creaks/scifi_door",
	dig = "FLOOR",
}
newEntity{
	define_as = "SPACEDWARF_DOOR_OPEN",
	type = "wall", subtype = "floor",
	name = "open door", image="terrain/spacedwarf/granite_door1_open.png",
	display = "'", color_r=238, color_g=154, color_b=77, back_color=colors.DARK_GREY,
	always_remember = true,
	door_closed = "SPACEDWARF_DOOR",
	door_sound = "ambient/door_creaks/scifi_door",
}
newEntity{ base = "SPACEDWARF_DOOR", define_as = "SPACEDWARF_DOOR_HORIZ", image = "terrain/spacedwarf/spacedwarf_floor1.png", add_mos={{image = "terrain/spacedwarf/spacedwarf_wall_closed_doors1.png"}}, add_displays = {class.new{image="terrain/spacedwarf/spacedwarf_wall_top_block1.png", z=18, display_y=-1}}, door_opened = "SPACEDWARF_DOOR_HORIZ_OPEN"}
newEntity{ base = "SPACEDWARF_DOOR_OPEN", define_as = "SPACEDWARF_DOOR_HORIZ_OPEN", image = "terrain/spacedwarf/spacedwarf_floor1.png", add_displays = {class.new{image = "terrain/spacedwarf/spacedwarf_wall_open_doors1.png", z=17}, class.new{image="terrain/spacedwarf/spacedwarf_wall_top_block1.png", z=18, display_y=-1}}, door_closed = "SPACEDWARF_DOOR_HORIZ"}
newEntity{ base = "SPACEDWARF_DOOR", define_as = "SPACEDWARF_DOOR_VERT", image = "terrain/spacedwarf/spacedwarf_floor1.png", add_displays = {class.new{image="terrain/spacedwarf/solid_door1_vert.png", z=17}, class.new{image="terrain/spacedwarf/solid_door1_vert_north.png", z=18, display_y=-1}}, door_opened = "SPACEDWARF_DOOR_OPEN_VERT"}
newEntity{ base = "SPACEDWARF_DOOR_OPEN", define_as = "SPACEDWARF_DOOR_OPEN_VERT", image = "terrain/spacedwarf/spacedwarf_floor1.png", add_displays = {class.new{image="terrain/spacedwarf/solid_door1_open_vert.png", z=17}, class.new{image="terrain/spacedwarf/solid_door1_open_vert_north.png", z=18, display_y=-1}}, door_closed = "SPACEDWARF_DOOR_VERT"}

newEntity{
	define_as = "SPACEDWARF_DOOR_SEALED",
	type = "wall", subtype = "floor",
	name = "sealed door", image = "terrain/spacedwarf/spacedwarf_wall_closed_doors1.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="SPACEDWARF_DOOR_SEALED_VERT", west_east="SPACEDWARF_DOOR_SEALED_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	door_player_stop = "This door seems to be sealed.",
	is_door = true,
	door_opened = "SPACEDWARF_DOOR_OPEN",
	door_sound = "ambient/door_creaks/scifi_door",
}
newEntity{ base = "SPACEDWARF_DOOR_SEALED", define_as = "SPACEDWARF_DOOR_SEALED_HORIZ", image = "terrain/spacedwarf/spacedwarf_floor1.png", add_mos={{image = "terrain/spacedwarf/spacedwarf_wall_closed_doors1.png"}}, add_displays = {class.new{image="terrain/spacedwarf/spacedwarf_wall_top_block1.png", z=18, display_y=-1, add_mos={{image="terrain/padlock2.png", display_y=0.1}}}}, door_opened = "SPACEDWARF_DOOR_HORIZ_OPEN"}
newEntity{ base = "SPACEDWARF_DOOR_SEALED", define_as = "SPACEDWARF_DOOR_SEALED_VERT", image = "terrain/spacedwarf/spacedwarf_floor1.png", add_displays = {class.new{image="terrain/spacedwarf/solid_door1_vert.png", z=17}, class.new{image="terrain/spacedwarf/solid_door1_vert_north.png", z=18, display_y=-1, add_mos={{image="terrain/padlock2.png", display_x=0.2, display_y=-0.4}}}}, door_opened = "SPACEDWARF_DOOR_OPEN_VERT"}
