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

newEntity{
	define_as = "MAP_FLOOR",
	type = "floor", subtype = "ancient",
	name = "floor",
	display = '.', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY,
}

newEntity{
	define_as = "MAP_WALL",
	type = "wall", subtype = "ancient",
	name = "wall",
	display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	air_level = -20,
}

newEntity{
	define_as = "MAP_DOOR",
	type = "wall", subtype = "ancient",
	name = "door",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	notice = true,
	always_remember = true,
	block_sight = true,
	is_door = true,
	door_opened = newEntity{
		define_as = "MAP_DOOR_OPEN",
		type = "wall", subtype = "ancient",
		name = "door",
		display = "'", color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
		always_remember = true,
		is_door = true,
		door_closed = "MAP_DOOR",
	},
}

newEntity{
	define_as = "MAP_STATUE",
	type = "wall", subtype = "ancient",
	name = "statue",
	display = '&', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	air_level = -20,
}

newEntity{
	define_as = "TELEPORT_WILDERNESS",
	type = "floor", subtype = "ancient",
	name = "teleporter to the surface",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_zone = "wilderness", change_level = 1, change_zone_catchall = true,
}

newEntity{
	define_as = "MAP_STAIR_UP",
	type = "floor", subtype = "ancient",
	name = "previous level",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "MAP_DOWN",
	type = "floor", subtype = "ancient",
	name = "next level",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

newEntity{
	define_as = "PORTAL_MAGGOT",
	type = "floor", subtype = "ancient",
	name = "portal to the Maggot",
	display = '>', color_r=0, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_zone = "cults+maggot", change_level = 1,
}
