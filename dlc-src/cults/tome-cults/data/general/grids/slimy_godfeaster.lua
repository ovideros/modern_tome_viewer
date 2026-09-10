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

local slimy_godfeaster_wall_editer = {method="sandWalls_def", def="slimy_godfeaster"}

-----------------------------------------
-- Dungeony exits
-----------------------------------------
newEntity{
	define_as = "SLIMY_GODFEASTER_UP_WILDERNESS",
	type = "floor", subtype = "floor",
	name = "exit to the worldmap", image = "terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_mos = {{image="terrain/slimy_godfeaster/slimy_godfeaster_stairs_exit.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	shader = "godfeaster",
	change_level = 1,
	change_zone = "wilderness",
}

newEntity{
	define_as = "SLIMY_GODFEASTER_UP", image = "terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_mos = {{image="terrain/slimy_godfeaster/slimy_godfeaster_stairs_up_1_01.png"}},
	type = "floor", subtype = "floor",
	name = "previous level",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	shader = "godfeaster",
	change_level = -1,
}

newEntity{
	define_as = "SLIMY_GODFEASTER_DOWN", image = "terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_mos = {{image="terrain/slimy_godfeaster/slimy_godfeaster_stairs_down_1_01.png"}},
	type = "floor", subtype = "floor",
	name = "next level",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	shader = "godfeaster",
	change_level = 1,
}

-----------------------------------------
-- Basic floors
-----------------------------------------
newEntity{
	define_as = "SLIMY_GODFEASTER_FLOOR",
	type = "floor", subtype = "slimy_godfeaster",
	name = "floor", image = "terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png",
	display = '.', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY,
	grow = "SLIMY_GODFEASTER_WALL",
	nice_tiler = { method="replace", base={"SLIMY_GODFEASTER_FLOOR", 100, 1, 11} },
	shader = "godfeaster",
}
for i = 1, 11 do newEntity{ base="SLIMY_GODFEASTER_FLOOR", define_as = "SLIMY_GODFEASTER_FLOOR"..i, image = "terrain/slimy_godfeaster/slimy_godfeaster_floor_"..i.."_01.png"} end

newEntity{
	define_as = "SLIMY_GODFEASTER_WALL",
	type = "wall", subtype = "slimy_godfeaster",
	name = "slimy_godfeaster wall", image = "terrain/slimy_godfeaster/slimy_godfeasterwall_5_1.png",
	display = '#', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	always_remember = true,
	does_block_move = true,
	can_pass = {pass_wall=1},
	block_sight = true,
	air_level = -20,
	nice_editer = slimy_godfeaster_wall_editer,
	nice_tiler = { method="replace", base={"SLIMY_GODFEASTER_WALL", 100, 1, 9} },
	shader = "godfeaster",
}
for i = 1, 9 do newEntity{ base="SLIMY_GODFEASTER_WALL", define_as = "SLIMY_GODFEASTER_WALL"..i, image = "terrain/slimy_godfeaster/slimy_godfeasterwall_5_"..i..".png"} end


-----------------------------------------
-- Doors
-----------------------------------------
newEntity{
	define_as = "SLIMY_GODFEASTER_DOOR",
	type = "wall", subtype = "slimy_godfeaster",
	name = "slimy_godfeaster door",
	display = '+', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	nice_tiler = { method="door3d", north_south="SLIMY_GODFEASTER_DOOR_VERT", west_east="SLIMY_GODFEASTER_DOOR_HORIZ", default="west_east" },
	notice = true,
	always_remember = true,
	block_sight = true,
	is_door = true,
	door_opened = "SLIMY_GODFEASTER_DOOR_OPEN",
	dig = "FLOOR",
	shader = "godfeaster",
}
newEntity{
	define_as = "SLIMY_GODFEASTER_DOOR_OPEN",
	type = "wall", subtype = "slimy_godfeaster",
	name = "open slimy_godfeaster door",
	display = "'", color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	always_remember = true,
	is_door = true,
	door_closed = "SLIMY_GODFEASTER_DOOR",
	shader = "godfeaster",
}
newEntity{ base = "SLIMY_GODFEASTER_DOOR", define_as = "SLIMY_GODFEASTER_DOOR_HORIZ", image = "terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_displays={class.new{z=17, shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeaster_door1.png", add_mos={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeasterwall_8_1.png", display_y=-1}}}}, door_opened = "SLIMY_GODFEASTER_DOOR_HORIZ_OPEN"}
newEntity{ base = "SLIMY_GODFEASTER_DOOR_OPEN", define_as = "SLIMY_GODFEASTER_DOOR_HORIZ_OPEN", image = "terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_displays={class.new{z=17, shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeaster_door1_open.png", add_mos={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeasterwall_8_1.png", display_y=-1}}}}, door_closed = "SLIMY_GODFEASTER_DOOR_HORIZ"}

newEntity{ base = "SLIMY_GODFEASTER_DOOR", define_as = "SLIMY_GODFEASTER_DOOR_VERT", image = "terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_displays={class.new{z=17, shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeaster_door1_vert.png", add_mos={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeaster_door1_vert_north.png", display_y=-1}}}}, door_opened = "SLIMY_GODFEASTER_DOOR_OPEN_VERT", dig = "SLIMY_GODFEASTER_DOOR_OPEN_VERT"}
newEntity{ base = "SLIMY_GODFEASTER_DOOR_OPEN", define_as = "SLIMY_GODFEASTER_DOOR_OPEN_VERT", image = "terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_displays={class.new{z=17, shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeaster_door1_open_vert.png", add_mos={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeaster_door1_open_vert_north.png", display_y=-1}}}}, door_closed = "SLIMY_GODFEASTER_DOOR_VERT"}

newEntity{
	define_as = "SLIMY_GODFEASTER_VAULT_DOOR",
	type = "wall", subtype = "slimy_godfeaster",
	name = "slimy_godfeaster door",
	display = '+', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	nice_tiler = { method="door3d", north_south="SLIMY_GODFEASTER_VAULT_DOOR_VERT", west_east="SLIMY_GODFEASTER_VAULT_DOOR_HORIZ", default="west_east" },
	notice = true,
	always_remember = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	is_door = true,
	door_player_check = _t"This door seems to have been sealed off. You think you can open it.",
	door_opened = "SLIMY_GODFEASTER_VAULT_DOOR_OPEN",
	dig = "FLOOR",
	shader = "godfeaster",
}
newEntity{
	define_as = "SLIMY_GODFEASTER_VAULT_DOOR_OPEN",
	type = "wall", subtype = "slimy_godfeaster",
	name = "open slimy_godfeaster door",
	display = "'", color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	always_remember = true,
	is_door = true,
	door_closed = "SLIMY_GODFEASTER_VAULT_DOOR",
	shader = "godfeaster",
}
newEntity{ base = "SLIMY_GODFEASTER_VAULT_DOOR", define_as = "SLIMY_GODFEASTER_VAULT_DOOR_HORIZ", image = "terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_displays={class.new{z=17, shader = "godfeaster", image="terrain/slimy_godfeaster/lamp_slimy_godfeaster_door1.png", add_mos={{image="terrain/slimy_godfeaster/slimy_godfeasterwall_8_1.png", display_y=-1}}}}, door_opened = "SLIMY_GODFEASTER_VAULT_DOOR_HORIZ_OPEN"}
newEntity{ base = "SLIMY_GODFEASTER_VAULT_DOOR_OPEN", define_as = "SLIMY_GODFEASTER_VAULT_DOOR_HORIZ_OPEN", image = "terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_displays={class.new{z=17, shader = "godfeaster", image="terrain/slimy_godfeaster/lamp_slimy_godfeaster_door1_open.png", add_mos={{image="terrain/slimy_godfeaster/slimy_godfeasterwall_8_1.png", display_y=-1}}}}, door_closed = "SLIMY_GODFEASTER_VAULT_DOOR_HORIZ"}

newEntity{ base = "SLIMY_GODFEASTER_VAULT_DOOR", define_as = "SLIMY_GODFEASTER_VAULT_DOOR_VERT", image = "terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_displays={class.new{z=17, shader = "godfeaster", image="terrain/slimy_godfeaster/lamp_slimy_godfeaster_door1_vert.png", add_mos={{image="terrain/slimy_godfeaster/lamp_slimy_godfeaster_door1_vert_north.png", display_y=-1}}}}, door_opened = "SLIMY_GODFEASTER_VAULT_DOOR_OPEN_VERT", dig = "SLIMY_GODFEASTER_VAULT_DOOR_OPEN_VERT"}
newEntity{ base = "SLIMY_GODFEASTER_VAULT_DOOR_OPEN", define_as = "SLIMY_GODFEASTER_VAULT_DOOR_OPEN_VERT", image = "terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_displays={class.new{z=17, shader = "godfeaster", image="terrain/slimy_godfeaster/lamp_slimy_godfeaster_door1_open_vert.png", add_mos={{image="terrain/slimy_godfeaster/lamp_slimy_godfeaster_door1_open_vert_north.png", display_y=-1}}}}, door_closed = "SLIMY_GODFEASTER_VAULT_DOOR_VERT"}
