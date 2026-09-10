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

local mechstone_wall_editer = {method="sandWalls_def", def="mechstone"}

-----------------------------------------
-- Dungeony exits
-----------------------------------------
newEntity{
	define_as = "MECHSTONE_UP_WILDERNESS",
	type = "floor", subtype = "floor",
	name = "exit to the worldmap", image = "terrain/mechstone/mech_stone_floor_1_01.png", add_mos = {{image="terrain/mechstone/mech_stone_stairs_exit_01.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}

newEntity{
	define_as = "MECHSTONE_UP", image = "terrain/mechstone/mech_stone_floor_1_01.png", add_mos = {{image="terrain/mechstone/mech_stone_stairs_up_big_lower.png"}}, add_displays={class.new{z=17, display_y=-1, image="terrain/mechstone/mech_stone_stairs_up_big_upper.png"}},
	type = "floor", subtype = "floor",
	name = "previous level",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "MECHSTONE_DOWN", image = "terrain/mechstone/mech_stone_floor_1_01.png", add_mos = {{image="terrain/mechstone/mech_stone_stairs_down.png"}},
	type = "floor", subtype = "floor",
	name = "next level",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

-----------------------------------------
-- Basic floors
-----------------------------------------
newEntity{
	define_as = "MECHSTONE_FLOOR",
	type = "floor", subtype = "mech",
	name = "floor", image = "terrain/mechstone/mech_stone_floor_1_01.png",
	display = '.', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY,
	grow = "MECHSTONE_WALL",
	nice_tiler = { method="replace", base={"MECHSTONE_FLOOR", 100, 1, 9} },
}
for i = 1, 9 do
	newEntity{ base="MECHSTONE_FLOOR", define_as = "MECHSTONE_FLOOR"..i, image = "terrain/mechstone/mech_stone_floor_"..i.."_01.png",}
end

-----------------------------------------
-- Basic walls
-----------------------------------------
newEntity{
	define_as = "MECHSTONE_WALL",
	type = "wall", subtype = "mech",
	name = "mech wall", image = "terrain/mechstone/mech_stonewall_5_1.png",
	display = '#', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	always_remember = true,
	does_block_move = true,
	can_pass = {pass_wall=1},
	block_sight = true,
	air_level = -20,
	dig = "MECHSTONE_FLOOR",
	nice_editer = mechstone_wall_editer,
	nice_tiler = { method="replace", base={"MECHSTONE_WALL", 100, 1, 8} },
}
for i = 1, 8 do newEntity{ base="MECHSTONE_WALL", define_as = "MECHSTONE_WALL"..i, image = "terrain/mechstone/mech_stonewall_5_"..i..".png"} end


-----------------------------------------
-- Doors
-----------------------------------------
newEntity{
	define_as = "MECHSTONE_DOOR",
	type = "wall", subtype = "mech",
	name = "mech door",
	display = '+', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	nice_tiler = { method="door3d", north_south="MECHSTONE_DOOR_VERT", west_east="MECHSTONE_DOOR_HORIZ", default="west_east" },
	notice = true,
	always_remember = true,
	block_sight = true,
	is_door = true,
	door_opened = "MECHSTONE_DOOR_OPEN",
	door_sound = "ambient/door_creaks/scifi_door",
	dig = "FLOOR",
}
newEntity{
	define_as = "MECHSTONE_DOOR_OPEN",
	type = "wall", subtype = "mech",
	name = "open mech door",
	display = "'", color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	always_remember = true,
	is_door = true,
	door_closed = "MECHSTONE_DOOR",
	door_sound = "ambient/door_creaks/scifi_door",
}
newEntity{ base = "MECHSTONE_DOOR", define_as = "MECHSTONE_DOOR_HORIZ", image = "terrain/mechstone/mech_stone_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechstone/mech_stone_door1.png", add_mos={{image="terrain/mechstone/mech_stonewall_8_1.png", display_y=-1}}}}, door_opened = "MECHSTONE_DOOR_HORIZ_OPEN"}
newEntity{ base = "MECHSTONE_DOOR_OPEN", define_as = "MECHSTONE_DOOR_HORIZ_OPEN", image = "terrain/mechstone/mech_stone_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechstone/mech_stone_door1_open.png", add_mos={{image="terrain/mechstone/mech_stonewall_8_1.png", display_y=-1}}}}, door_closed = "MECHSTONE_DOOR_HORIZ"}

newEntity{ base = "MECHSTONE_DOOR", define_as = "MECHSTONE_DOOR_VERT", image = "terrain/mechstone/mech_stone_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechstone/mech_stone_door1_vert.png", add_mos={{image="terrain/mechstone/mech_stone_door1_vert_north.png", display_y=-1}}}}, door_opened = "MECHSTONE_DOOR_OPEN_VERT", dig = "MECHSTONE_DOOR_OPEN_VERT"}
newEntity{ base = "MECHSTONE_DOOR_OPEN", define_as = "MECHSTONE_DOOR_OPEN_VERT", image = "terrain/mechstone/mech_stone_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechstone/mech_stone_door1_open_vert.png", add_mos={{image="terrain/mechstone/mech_stone_door1_open_vert_north.png", display_y=-1}}}}, door_closed = "MECHSTONE_DOOR_VERT"}

newEntity{
	define_as = "MECHSTONE_VAULT_DOOR",
	type = "wall", subtype = "mech",
	name = "mech door",
	display = '+', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	nice_tiler = { method="door3d", north_south="MECHSTONE_VAULT_DOOR_VERT", west_east="MECHSTONE_VAULT_DOOR_HORIZ", default="west_east" },
	notice = true,
	always_remember = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	is_door = true,
	door_player_check = _t"This door seems to have been sealed off. You think you can open it.",
	door_opened = "MECHSTONE_VAULT_DOOR_OPEN",
	door_sound = "ambient/door_creaks/scifi_door",
	dig = "FLOOR",
}
newEntity{
	define_as = "MECHSTONE_VAULT_DOOR_OPEN",
	type = "wall", subtype = "mech",
	name = "open mech door",
	display = "'", color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	always_remember = true,
	is_door = true,
	door_closed = "MECHSTONE_VAULT_DOOR",
	door_sound = "ambient/door_creaks/scifi_door",
}
newEntity{ base = "MECHSTONE_VAULT_DOOR", define_as = "MECHSTONE_VAULT_DOOR_HORIZ", image = "terrain/mechstone/mech_stone_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechstone/lamp_mech_stone_door1.png", add_mos={{image="terrain/mechstone/mech_stonewall_8_1.png", display_y=-1}}}}, door_opened = "MECHSTONE_VAULT_DOOR_HORIZ_OPEN"}
newEntity{ base = "MECHSTONE_VAULT_DOOR_OPEN", define_as = "MECHSTONE_VAULT_DOOR_HORIZ_OPEN", image = "terrain/mechstone/mech_stone_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechstone/lamp_mech_stone_door1_open.png", add_mos={{image="terrain/mechstone/mech_stonewall_8_1.png", display_y=-1}}}}, door_closed = "MECHSTONE_VAULT_DOOR_HORIZ"}

newEntity{ base = "MECHSTONE_VAULT_DOOR", define_as = "MECHSTONE_VAULT_DOOR_VERT", image = "terrain/mechstone/mech_stone_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechstone/lamp_mech_stone_door1_vert.png", add_mos={{image="terrain/mechstone/lamp_mech_stone_door1_vert_north.png", display_y=-1}}}}, door_opened = "MECHSTONE_VAULT_DOOR_OPEN_VERT", dig = "MECHSTONE_VAULT_DOOR_OPEN_VERT"}
newEntity{ base = "MECHSTONE_VAULT_DOOR_OPEN", define_as = "MECHSTONE_VAULT_DOOR_OPEN_VERT", image = "terrain/mechstone/mech_stone_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechstone/lamp_mech_stone_door1_open_vert.png", add_mos={{image="terrain/mechstone/lamp_mech_stone_door1_open_vert_north.png", display_y=-1}}}}, door_closed = "MECHSTONE_VAULT_DOOR_VERT"}
