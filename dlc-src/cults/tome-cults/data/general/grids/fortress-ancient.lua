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
	define_as = "ANCIENT_FLOOR",
	type = "floor", subtype = "ancient",
	name = "floor", image = "terrain/fortress-ancient/kroshkkur_solid_floor1.png",
	display = '.', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY,
}

-----------------------------------------
-- Walls
-----------------------------------------
newEntity{
	define_as = "ANCIENT_WALL",
	type = "wall", subtype = "ancient",
	name = "wall", image = "terrain/fortress-ancient/kroshkkur_solid_wall_block1.png",
	display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
	z = 3,
	nice_tiler = { method="wall3dKroshkkur", inner={"ANCIENT_WALL", 100, 1, 10}, north={"ANCIENT_WALL_NORTH", 100, 1, 1}, south={"ANCIENT_WALL_SOUTH", 10, 1, 7}, north_south="ANCIENT_WALL_NORTH_SOUTH",  },
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	air_level = -20,
}
for i = 1, 10 do
	newEntity{ base = "ANCIENT_WALL", define_as = "ANCIENT_WALL"..i, image = "terrain/fortress-ancient/kroshkkur_solid_wall_block"..i..".png", z = 3}
	newEntity{ base = "ANCIENT_WALL", define_as = "ANCIENT_WALL_NORTH"..i, image = "terrain/fortress-ancient/kroshkkur_solid_wall_block"..i..".png", z = 3, add_displays = {class.new{image="terrain/fortress-ancient/kroshkkur_solid_wall_top_block1.png", z=18, display_y=-1}}}
end
newEntity{ base = "ANCIENT_WALL", define_as = "ANCIENT_WALL_NORTH_SOUTH", image = "terrain/fortress-ancient/kroshkkur_solid_wall1.png", z = 3, add_displays = {class.new{image="terrain/fortress-ancient/kroshkkur_solid_wall_top_block1.png", z=18, display_y=-1}}}
newEntity{ base = "ANCIENT_WALL", define_as = "ANCIENT_WALL_SOUTH", image = "terrain/fortress-ancient/kroshkkur_solid_wall1.png", z = 3}
for i = 1, 7 do newEntity{ base = "ANCIENT_WALL", define_as = "ANCIENT_WALL_SOUTH"..i, image = "terrain/fortress-ancient/kroshkkur_solid_wall"..i..".png", z = 3} end

-----------------------------------------
-- Doors
-----------------------------------------
newEntity{
	define_as = "ANCIENT_DOOR",
	type = "wall", subtype = "ancient",
	name = "door", image = "terrain/fortress-ancient/kroshkkur_granite_door1.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="ANCIENT_DOOR_VERT", west_east="ANCIENT_DOOR_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	is_door = true,
	door_opened = "ANCIENT_DOOR_OPEN",
	dig = "FLOOR",
}
newEntity{
	define_as = "ANCIENT_DOOR_OPEN",
	type = "wall", subtype = "ancient",
	name = "open door", image="terrain/fortress-ancient/kroshkkur_granite_door1_open.png",
	display = "'", color_r=238, color_g=154, color_b=77, back_color=colors.DARK_GREY,
	always_remember = true,
	door_closed = "ANCIENT_DOOR",
}
newEntity{ base = "ANCIENT_DOOR", define_as = "ANCIENT_DOOR_HORIZ", image = "terrain/fortress-ancient/kroshkkur_solid_floor1.png", add_mos={{image = "terrain/fortress-ancient/kroshkkur_solid_wall_closed_doors1.png"}}, add_displays = {class.new{image="terrain/fortress-ancient/kroshkkur_solid_wall_top_block1.png", z=18, display_y=-1}}, door_opened = "ANCIENT_DOOR_HORIZ_OPEN"}
newEntity{ base = "ANCIENT_DOOR_OPEN", define_as = "ANCIENT_DOOR_HORIZ_OPEN", image = "terrain/fortress-ancient/kroshkkur_solid_floor1.png", add_mos={{image = "terrain/fortress-ancient/kroshkkur_solid_wall_open_doors1.png"}}, add_displays = {class.new{image="terrain/fortress-ancient/kroshkkur_solid_wall_top_block1.png", z=18, display_y=-1}}, door_closed = "ANCIENT_DOOR_HORIZ"}
newEntity{ base = "ANCIENT_DOOR", define_as = "ANCIENT_DOOR_VERT", image = "terrain/fortress-ancient/kroshkkur_solid_floor1.png", add_displays = {class.new{image="terrain/fortress-ancient/kroshkkur_solid_door1_vert.png", z=17}, class.new{image="terrain/fortress-ancient/kroshkkur_solid_door1_vert_north.png", z=18, display_y=-1}}, door_opened = "ANCIENT_DOOR_OPEN_VERT"}
newEntity{ base = "ANCIENT_DOOR_OPEN", define_as = "ANCIENT_DOOR_OPEN_VERT", image = "terrain/fortress-ancient/kroshkkur_solid_floor1.png", add_displays = {class.new{image="terrain/fortress-ancient/kroshkkur_solid_door1_open_vert.png", z=17}, class.new{image="terrain/fortress-ancient/kroshkkur_solid_door1_open_vert_north.png", z=18, display_y=-1}}, door_closed = "ANCIENT_DOOR_VERT"}

newEntity{
	define_as = "ANCIENT_DOOR_SEALED",
	type = "wall", subtype = "ancient",
	name = "sealed door", image = "terrain/fortress-ancient/kroshkkur_solid_wall_closed_doors1.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="ANCIENT_DOOR_SEALED_VERT", west_east="ANCIENT_DOOR_SEALED_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	door_player_stop = "This door seems to be sealed.",
	is_door = true,
	door_opened = "ANCIENT_DOOR_OPEN",
}
newEntity{ base = "ANCIENT_DOOR_SEALED", define_as = "ANCIENT_DOOR_SEALED_HORIZ", image = "terrain/fortress-ancient/kroshkkur_solid_floor1.png", add_mos={{image = "terrain/fortress-ancient/kroshkkur_solid_wall_closed_doors1.png"}}, add_displays = {class.new{image="terrain/fortress-ancient/kroshkkur_solid_wall_top_block1.png", z=18, display_y=-1, add_mos={{image="terrain/padlock2.png", display_y=0.1}}}}, door_opened = "ANCIENT_DOOR_HORIZ_OPEN"}
newEntity{ base = "ANCIENT_DOOR_SEALED", define_as = "ANCIENT_DOOR_SEALED_VERT", image = "terrain/fortress-ancient/kroshkkur_solid_floor1.png", add_displays = {class.new{image="terrain/fortress-ancient/kroshkkur_solid_door1_vert.png", z=17}, class.new{image="terrain/fortress-ancient/kroshkkur_solid_door1_vert_north.png", z=18, display_y=-1, add_mos={{image="terrain/padlock2.png", display_x=0.2, display_y=-0.4}}}}, door_opened = "ANCIENT_DOOR_OPEN_VERT"}
