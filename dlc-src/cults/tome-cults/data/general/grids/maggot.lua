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

local maggot_wall_editer = {method="sandWalls_def", def="maggot"}

-----------------------------------------
-- Dungeony exits
-----------------------------------------
newEntity{
	define_as = "MAGGOT_UP_WILDERNESS",
	type = "floor", subtype = "floor",
	name = "exit to the worldmap", image = "terrain/maggot/maggot_floor_1_01.png", add_mos = {{image="terrain/maggot/maggot_stairs_exit.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	shader = "maggot",
	change_level = 1,
	change_zone = "wilderness",
}

newEntity{
	define_as = "MAGGOT_UP", image = "terrain/maggot/maggot_floor_1_01.png", add_mos = {{image="terrain/maggot/maggot_stairs_up_1_01.png"}},
	type = "floor", subtype = "floor",
	name = "previous level",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	shader = "maggot",
	change_level = -1,
}

newEntity{
	define_as = "MAGGOT_DOWN", image = "terrain/maggot/maggot_floor_1_01.png", add_mos = {{image="terrain/maggot/maggot_stairs_down_1_01.png"}},
	type = "floor", subtype = "floor",
	name = "next level",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	shader = "maggot",
	change_level = 1,
}

-----------------------------------------
-- Basic floors
-----------------------------------------
newEntity{
	define_as = "MAGGOT_FLOOR",
	type = "floor", subtype = "maggot",
	name = "floor", image = "terrain/maggot/maggot_floor_1_01.png",
	display = '.', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY,
	grow = "MAGGOT_WALL",
	always_remember = true,
	nice_tiler = { method="replace", base={"MAGGOT_FLOOR", 100, 1, 11} },
	shader = "maggot",
}
for i = 1, 11 do newEntity{ base="MAGGOT_FLOOR", define_as = "MAGGOT_FLOOR"..i, image = "terrain/maggot/maggot_floor_"..i.."_01.png"} end

newEntity{
	define_as = "MAGGOT_WALL",
	type = "wall", subtype = "maggot",
	name = "maggot wall", image = "terrain/maggot/maggotwall_5_1.png",
	display = '#', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	always_remember = true,
	does_block_move = true,
	can_pass = {pass_wall=1},
	block_sight = true,
	air_level = -20,
	nice_editer = maggot_wall_editer,
	nice_tiler = { method="replace", base={"MAGGOT_WALL", 100, 1, 9} },
	shader = "maggot",
}
for i = 1, 9 do newEntity{ base="MAGGOT_WALL", define_as = "MAGGOT_WALL"..i, image = "terrain/maggot/maggotwall_5_"..i..".png"} end


-----------------------------------------
-- Doors
-----------------------------------------
newEntity{
	define_as = "MAGGOT_DOOR",
	type = "wall", subtype = "maggot",
	name = "maggot door",
	display = '+', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	nice_tiler = { method="door3d", north_south="MAGGOT_DOOR_VERT", west_east="MAGGOT_DOOR_HORIZ", default="west_east" },
	notice = true,
	always_remember = true,
	block_sight = true,
	is_door = true,
	door_opened = "MAGGOT_DOOR_OPEN",
	dig = "FLOOR",
	shader = "maggot",
}
newEntity{
	define_as = "MAGGOT_DOOR_OPEN",
	type = "wall", subtype = "maggot",
	name = "open maggot door",
	display = "'", color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	always_remember = true,
	is_door = true,
	door_closed = "MAGGOT_DOOR",
	shader = "maggot",
}
newEntity{ base = "MAGGOT_DOOR", define_as = "MAGGOT_DOOR_HORIZ", image = "terrain/maggot/maggot_floor_1_01.png", add_displays={class.new{z=17, shader = "maggot", image="terrain/maggot/maggot_door1.png", add_mos={{shader = "maggot", image="terrain/maggot/maggotwall_8_1.png", display_y=-1}}}}, door_opened = "MAGGOT_DOOR_HORIZ_OPEN"}
newEntity{ base = "MAGGOT_DOOR_OPEN", define_as = "MAGGOT_DOOR_HORIZ_OPEN", image = "terrain/maggot/maggot_floor_1_01.png", add_displays={class.new{z=17, shader = "maggot", image="terrain/maggot/maggot_door1_open.png", add_mos={{shader = "maggot", image="terrain/maggot/maggotwall_8_1.png", display_y=-1}}}}, door_closed = "MAGGOT_DOOR_HORIZ"}

newEntity{ base = "MAGGOT_DOOR", define_as = "MAGGOT_DOOR_VERT", image = "terrain/maggot/maggot_floor_1_01.png", add_displays={class.new{z=17, shader = "maggot", image="terrain/maggot/maggot_door1_vert.png", add_mos={{shader = "maggot", image="terrain/maggot/maggot_door1_vert_north.png", display_y=-1}}}}, door_opened = "MAGGOT_DOOR_OPEN_VERT", dig = "MAGGOT_DOOR_OPEN_VERT"}
newEntity{ base = "MAGGOT_DOOR_OPEN", define_as = "MAGGOT_DOOR_OPEN_VERT", image = "terrain/maggot/maggot_floor_1_01.png", add_displays={class.new{z=17, shader = "maggot", image="terrain/maggot/maggot_door1_open_vert.png", add_mos={{shader = "maggot", image="terrain/maggot/maggot_door1_open_vert_north.png", display_y=-1}}}}, door_closed = "MAGGOT_DOOR_VERT"}

newEntity{
	define_as = "MAGGOT_VAULT_DOOR",
	type = "wall", subtype = "maggot",
	name = "maggot door",
	display = '+', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	nice_tiler = { method="door3d", north_south="MAGGOT_VAULT_DOOR_VERT", west_east="MAGGOT_VAULT_DOOR_HORIZ", default="west_east" },
	notice = true,
	always_remember = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	is_door = true,
	door_player_check = _t"This door seems to have been sealed off. You think you can open it.",
	door_opened = "MAGGOT_VAULT_DOOR_OPEN",
	dig = "FLOOR",
	shader = "maggot",
}
newEntity{
	define_as = "MAGGOT_VAULT_DOOR_OPEN",
	type = "wall", subtype = "maggot",
	name = "open maggot door",
	display = "'", color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	always_remember = true,
	is_door = true,
	door_closed = "MAGGOT_VAULT_DOOR",
	shader = "maggot",
}
newEntity{ base = "MAGGOT_VAULT_DOOR", define_as = "MAGGOT_VAULT_DOOR_HORIZ", image = "terrain/maggot/maggot_floor_1_01.png", add_displays={class.new{z=17, shader = "maggot", image="terrain/maggot/lamp_maggot_door1.png", add_mos={{image="terrain/maggot/maggotwall_8_1.png", display_y=-1}}}}, door_opened = "MAGGOT_VAULT_DOOR_HORIZ_OPEN"}
newEntity{ base = "MAGGOT_VAULT_DOOR_OPEN", define_as = "MAGGOT_VAULT_DOOR_HORIZ_OPEN", image = "terrain/maggot/maggot_floor_1_01.png", add_displays={class.new{z=17, shader = "maggot", image="terrain/maggot/lamp_maggot_door1_open.png", add_mos={{image="terrain/maggot/maggotwall_8_1.png", display_y=-1}}}}, door_closed = "MAGGOT_VAULT_DOOR_HORIZ"}

newEntity{ base = "MAGGOT_VAULT_DOOR", define_as = "MAGGOT_VAULT_DOOR_VERT", image = "terrain/maggot/maggot_floor_1_01.png", add_displays={class.new{z=17, shader = "maggot", image="terrain/maggot/lamp_maggot_door1_vert.png", add_mos={{image="terrain/maggot/lamp_maggot_door1_vert_north.png", display_y=-1}}}}, door_opened = "MAGGOT_VAULT_DOOR_OPEN_VERT", dig = "MAGGOT_VAULT_DOOR_OPEN_VERT"}
newEntity{ base = "MAGGOT_VAULT_DOOR_OPEN", define_as = "MAGGOT_VAULT_DOOR_OPEN_VERT", image = "terrain/maggot/maggot_floor_1_01.png", add_displays={class.new{z=17, shader = "maggot", image="terrain/maggot/lamp_maggot_door1_open_vert.png", add_mos={{image="terrain/maggot/lamp_maggot_door1_open_vert_north.png", display_y=-1}}}}, door_closed = "MAGGOT_VAULT_DOOR_VERT"}
