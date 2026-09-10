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
load("/data/general/grids/burntland.lua")
load("/data/general/grids/cave.lua")
load("/data-orcs/general/grids/mechwall.lua")

newEntity{
	define_as = "MOLE_MAIN",
	name = "giant mole hull", image = "terrain/grass_burnt1.png",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	does_block_move = true,
}

newEntity{
	define_as = "GEM_ENTRANCE",
	name = "breach into the giant mole hull", image = "terrain/grass_burnt1.png", add_displays = {class.new{z=4, image="terrain/G_E_M_entrance.png", display_w=4, display_h=4, display_x=-1.5, display_y=-2.5}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

newEntity{
	define_as = "RUBBLE",
	name = "dug rubble", image = "terrain/grass_burnt1.png", add_mos = {{image="trap/trap_random_rubble_01.png"}},
	display = '*', color=colors.GREY,
}

local cracks_editer = {method="borders_def", def="blackcracks"}

newEntity{
	define_as = "CRACKS",
	type = "wall", subtype = "cracks",
	name = "huge crack in the floor", image = "terrain/cracks/ground_9_01.png",
	display = '.', color=colors.BLACK, back_color=colors.BLACK,
	nice_editer = cracks_editer,
	pass_projectile = true,
	does_block_move = true,
}
