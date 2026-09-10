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

local mech_wall_editer = {method="sandWalls_def", def="mech"}

-----------------------------------------
-- Dungeony exits
-----------------------------------------
newEntity{
	define_as = "MECH_UP_WILDERNESS",
	type = "floor", subtype = "floor",
	name = "exit to the worldmap", image = "terrain/mechwall/mech_floor_1_01.png", add_mos = {{image="terrain/mechwall/mech_stairs_exit.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}

newEntity{
	define_as = "MECH_UP", image = "terrain/mechwall/mech_floor_1_01.png", add_mos = {{image="terrain/mechwall/dark_mech_stairs_up_big_lower.png"}}, add_displays={class.new{z=17, display_y=-1, image="terrain/mechwall/dark_mech_stairs_up_big_upper.png"}},
	type = "floor", subtype = "floor",
	name = "previous level",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "MECH_DOWN", image = "terrain/mechwall/mech_floor_1_01.png", add_mos = {{image="terrain/mechwall/mech_stairs_down.png"}},
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
	define_as = "MECH_FLOOR",
	type = "floor", subtype = "mech",
	name = "floor", image = "terrain/mechwall/mech_floor_1_01.png",
	display = '.', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY,
	grow = "MECH_WALL",
	nice_tiler = { method="replace", base={"MECH_FLOOR", 14, 1, 11*10+12} },
}
local i = 1
for a = 1, 12 do
	if a < 12 then
		for b = 1, 10 do
			newEntity{ base="MECH_FLOOR", define_as = "MECH_FLOOR"..i, image = "terrain/mechwall/mech_floor_"..a.."_01.png",} i = i + 1
		end
	else
		for b = 1, 12 do
			newEntity{ base="MECH_FLOOR", define_as = "MECH_FLOOR"..i, add_mos={{image = ("terrain/mechwall/steamtech_deco_%02d.png"):format(b)}}}
		end
	end
end

-----------------------------------------
-- Basic walls
-----------------------------------------
newEntity{
	define_as = "MECH_WALL",
	type = "wall", subtype = "mech",
	name = "mech wall", image = "terrain/mechwall/mechwall_5_1.png",
	display = '#', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	always_remember = true,
	does_block_move = true,
	can_pass = {pass_wall=1},
	block_sight = true,
	air_level = -20,
	dig = "MECH_FLOOR",
	nice_editer = mech_wall_editer,
	nice_tiler = { method="replace", base={"MECH_WALL", 15, 1, 10} },
}
for i = 1, 10 do newEntity{ base="MECH_WALL", define_as = "MECH_WALL"..i, image = "terrain/mechwall/mechwall_5_"..i..".png"} end


-----------------------------------------
-- Doors
-----------------------------------------
newEntity{
	define_as = "MECH_DOOR",
	type = "wall", subtype = "mech",
	name = "mech door",
	display = '+', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	nice_tiler = { method="door3d", north_south="MECH_DOOR_VERT", west_east="MECH_DOOR_HORIZ", default="west_east" },
	notice = true,
	always_remember = true,
	block_sight = true,
	is_door = true,
	door_opened = "MECH_DOOR_OPEN",
	door_sound = "ambient/door_creaks/scifi_door",
	dig = "FLOOR",
}
newEntity{
	define_as = "MECH_DOOR_OPEN",
	type = "wall", subtype = "mech",
	name = "open mech door",
	display = "'", color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	always_remember = true,
	is_door = true,
	door_closed = "MECH_DOOR",
	door_sound = "ambient/door_creaks/scifi_door",
}
newEntity{ base = "MECH_DOOR", define_as = "MECH_DOOR_HORIZ", image = "terrain/mechwall/mech_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechwall/mech_door1.png", add_mos={{image="terrain/mechwall/mechwall_8_1.png", display_y=-1}}}}, door_opened = "MECH_DOOR_HORIZ_OPEN"}
newEntity{ base = "MECH_DOOR_OPEN", define_as = "MECH_DOOR_HORIZ_OPEN", image = "terrain/mechwall/mech_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechwall/mech_door1_open.png", add_mos={{image="terrain/mechwall/mechwall_8_1.png", display_y=-1}}}}, door_closed = "MECH_DOOR_HORIZ"}

newEntity{ base = "MECH_DOOR", define_as = "MECH_DOOR_VERT", image = "terrain/mechwall/mech_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechwall/mech_door1_vert.png", add_mos={{image="terrain/mechwall/mech_door1_vert_north.png", display_y=-1}}}}, door_opened = "MECH_DOOR_OPEN_VERT", dig = "MECH_DOOR_OPEN_VERT"}
newEntity{ base = "MECH_DOOR_OPEN", define_as = "MECH_DOOR_OPEN_VERT", image = "terrain/mechwall/mech_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechwall/mech_door1_open_vert.png", add_mos={{image="terrain/mechwall/mech_door1_open_vert_north.png", display_y=-1}}}}, door_closed = "MECH_DOOR_VERT"}

newEntity{
	define_as = "MECH_VAULT_DOOR",
	type = "wall", subtype = "mech",
	name = "mech door",
	display = '+', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	nice_tiler = { method="door3d", north_south="MECH_VAULT_DOOR_VERT", west_east="MECH_VAULT_DOOR_HORIZ", default="west_east" },
	notice = true,
	always_remember = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	is_door = true,
	door_player_check = _t"This door seems to have been sealed off. You think you can open it.",
	door_opened = "MECH_VAULT_DOOR_OPEN",
	door_sound = "ambient/door_creaks/scifi_door",
	dig = "FLOOR",
}
newEntity{
	define_as = "MECH_VAULT_DOOR_OPEN",
	type = "wall", subtype = "mech",
	name = "open mech door",
	display = "'", color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	always_remember = true,
	is_door = true,
	door_closed = "MECH_VAULT_DOOR",
	door_sound = "ambient/door_creaks/scifi_door",
}
newEntity{ base = "MECH_VAULT_DOOR", define_as = "MECH_VAULT_DOOR_HORIZ", image = "terrain/mechwall/mech_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechwall/lamp_mech_door1.png", add_mos={{image="terrain/mechwall/mechwall_8_1.png", display_y=-1}}}}, door_opened = "MECH_VAULT_DOOR_HORIZ_OPEN"}
newEntity{ base = "MECH_VAULT_DOOR_OPEN", define_as = "MECH_VAULT_DOOR_HORIZ_OPEN", image = "terrain/mechwall/mech_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechwall/lamp_mech_door1_open.png", add_mos={{image="terrain/mechwall/mechwall_8_1.png", display_y=-1}}}}, door_closed = "MECH_VAULT_DOOR_HORIZ"}

newEntity{ base = "MECH_VAULT_DOOR", define_as = "MECH_VAULT_DOOR_VERT", image = "terrain/mechwall/mech_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechwall/lamp_mech_door1_vert.png", add_mos={{image="terrain/mechwall/lamp_mech_door1_vert_north.png", display_y=-1}}}}, door_opened = "MECH_VAULT_DOOR_OPEN_VERT", dig = "MECH_VAULT_DOOR_OPEN_VERT"}
newEntity{ base = "MECH_VAULT_DOOR_OPEN", define_as = "MECH_VAULT_DOOR_OPEN_VERT", image = "terrain/mechwall/mech_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechwall/lamp_mech_door1_open_vert.png", add_mos={{image="terrain/mechwall/lamp_mech_door1_open_vert_north.png", display_y=-1}}}}, door_closed = "MECH_VAULT_DOOR_VERT"}
