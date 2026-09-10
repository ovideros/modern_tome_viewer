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

local snow_mountain_editer = {method="borders_def", def="snow_mountain"}

newEntity{
	define_as = "ROCKY_GROUND",
	type = "floor", subtype = "rock",
	name = "rocky ground", image = "terrain/rocky_ground.png",
	display = '.', color=colors.UMBER, back_color=colors.LIGHT_UMBER,
	grow = "SNOW_MOUNTAIN_WALL",
}

newEntity{
	define_as = "SNOW_MOUNTAIN_WALL",
	type = "rockwall", subtype = "rock",
	name = "snowy mountain", image = "terrain/snow_mountains/snow_mountain5.png",
	display = '#', color=colors.UMBER, back_color=colors.LIGHT_UMBER,
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -20,
	dig = "ROCKY_GROUND",
	nice_editer = snow_mountain_editer,
	nice_tiler = { method="replace", base={"SNOW_MOUNTAIN_WALL", 70, 1, 12} },
}
for i = 1, 12 do
	local add = nil
	if i >= 10 then
		add = {class.new{image="terrain/snow_mountains/snow_mountain5_"..i.."_up.png", display_y=-1, z=18}}
	end
	newEntity{ base="SNOW_MOUNTAIN_WALL", define_as = "SNOW_MOUNTAIN_WALL"..i, image = "terrain/snow_mountains/snow_mountain5_"..i..".png", add_displays=add}
end

newEntity{
	define_as = "ROCKY_SNOWY_TREE",
	type = "wall", subtype = "rock",
	name = "snowy tree", image = "terrain/rocky_snowy_tree.png",
	display = '#', color=colors.WHITE, back_color=colors.LIGHT_UMBER,
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "ROCKY_GROUND",
	nice_tiler = { method="replace", base={"ROCKY_SNOWY_TREE", 100, 1, 30} },
}
for i = 1, 30 do
newEntity{ base="ROCKY_SNOWY_TREE",
	define_as = "ROCKY_SNOWY_TREE"..i,
	image = "terrain/rocky_ground.png",
	add_displays = class:makeTrees("terrain/tree_dark_snow", 13, 10),
	nice_tiler = false,
}
end

newEntity{
	define_as = "ROCK_VAULT",
	type = "wall", subtype = "grass",
	name = "huge loose rock", image = "terrain/rocky_ground.png", add_mos = {{image="terrain/huge_rock.png"}},
	display = '+', color=colors.GREY, back_color={r=44,g=95,b=43},
	notice = true,
	always_remember = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	door_player_check = _t"This rock is loose, you think you can move it away.",
	door_opened = "ROCKY_GROUND",
	dig = "ROCKY_GROUND",
}

-----------------------------------------
-- Rocky exits
-----------------------------------------
newEntity{
	define_as = "ROCKY_UP_WILDERNESS",
	name = "exit to the worldmap", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/worldmap.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}

newEntity{
	define_as = "ROCKY_UP8",
	name = "way to the previous level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_8.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "ROCKY_UP2",
	name = "way to the previous level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_2.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "ROCKY_UP4",
	name = "way to the previous level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_4.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "ROCKY_UP6",
	name = "way to the previous level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_6.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "ROCKY_DOWN8",
	name = "way to the next level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_8.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "ROCKY_DOWN2",
	name = "way to the next level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_2.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "ROCKY_DOWN4",
	name = "way to the next level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_4.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "ROCKY_DOWN6",
	name = "way to the next level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_6.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
