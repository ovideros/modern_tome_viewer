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
load("/data/general/grids/underground.lua")

newEntity{
	define_as = "WOODEN_BARRICADE",
	type = "floor", subtype = "underground", barricade="wooden",
	name = "wooden barricade", image = "terrain/underground_floor.png",
	display = '#', color=colors.UMBER,
	always_remember = true,
	does_block_move = true,
	-- pass_projectile = true,
	nice_editer = { method="roads_def", def="wooden_barricade" },
}

newEntity{
	define_as = "BURNT_TREE",
	type = "wall", subtype = "underground",
	name = "burnt tree",
	image = "terrain/underground_floor.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "UNDERGROUND_FLOOR",
	nice_tiler = { method="replace", base={"BURNT_TREE", 100, 1, 20}},
}
for i = 1, 20 do newEntity{ base="BURNT_TREE", define_as = "BURNT_TREE"..i, image = "terrain/underground_floor.png", add_displays = class:makeTrees("terrain/burnttree_alpha", 8, 0)} end

newEntity{
	define_as = "TO_VOR",
	type = "floor", subtype = "underground",
	name = "way to the Vor section", image = "terrain/underground_floor.png", add_mos = {{image="terrain/way_next_8.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 2,
}
newEntity{
	define_as = "TO_GORBAT",
	type = "floor", subtype = "underground",
	name = "way to the Gorbat section", image = "terrain/underground_floor.png", add_mos = {{image="terrain/way_next_2.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 3,
}
newEntity{
	define_as = "TO_GRUSHNAK",
	type = "floor", subtype = "underground",
	name = "way to the Grushnak section", image = "terrain/underground_floor.png", add_mos = {{image="terrain/way_next_4.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 4,
}
newEntity{
	define_as = "TO_RAKSHOR",
	type = "floor", subtype = "underground",
	name = "way to the Rak'Shor section", image = "terrain/underground_floor.png", add_mos = {{image="terrain/way_next_6.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

newEntity{
	define_as = "TO_MAIN_FROM_VOR",
	type = "floor", subtype = "underground",
	name = "way back", image = "terrain/underground_floor.png", add_mos = {{image="terrain/way_next_2.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -2, change_level_auto_stairs=true,
}
newEntity{
	define_as = "TO_MAIN_FROM_GORBAT",
	type = "floor", subtype = "underground",
	name = "way back", image = "terrain/underground_floor.png", add_mos = {{image="terrain/way_next_8.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -3, change_level_auto_stairs=true,
}
newEntity{
	define_as = "TO_MAIN_FROM_GRUSHNAK",
	type = "floor", subtype = "underground",
	name = "way back", image = "terrain/underground_floor.png", add_mos = {{image="terrain/way_next_6.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -4, change_level_auto_stairs=true,
}
newEntity{
	define_as = "TO_MAIN_FROM_RAKSHOR",
	type = "floor", subtype = "underground",
	name = "way back", image = "terrain/underground_floor.png", add_mos = {{image="terrain/way_next_4.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1, change_level_auto_stairs=true,
}
newEntity{
	define_as = "PORTAL",
	type = "floor", subtype = "underground",
	name = "way back", image = "terrain/underground_floor.png", add_mos = {{image="terrain/demon_portal2.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	change_zone = "wilderness",
}
