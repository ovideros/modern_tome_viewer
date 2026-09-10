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
load("/data/general/grids/mountain.lua")
load("/data/general/grids/cave.lua")
load("/data-orcs/general/grids/mechwall.lua")

newEntity{
	define_as = "GRASS_UP_WILDERNESS",
	type = "floor", subtype = "grass",
	name = "exit to the worldmap", image = "terrain/grass.png", add_mos = {{image="terrain/worldmap.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
	nice_editer = grass_editer,
	change_level_check = function()
		local p = game.party:findMember{main=true}
		if not p:hasQuest("orcs+kruk-invasion") or p:isQuestStatus("orcs+kruk-invasion", engine.Quest.DONE) then return end
		require("engine.ui.Dialog"):simplePopup(_t"Coward!", _t"You are not coward enough to leave your home unprotected!")
		return true
	end,

}

newEntity{
	define_as = "FLOOR_ROAD_STONE",
	type = "floor", subtype = "floor", road="oldstone",
	name = "old road", image = "terrain/marble_floor.png",
	display = '=', color=colors.DARK_GREY,
	always_remember = true,
	nice_editer2 = { method="roads_def", def="oldstone" },
}

newEntity{
	define_as = "GRASS_WOODEN_BARRICADE",
	type = "floor", subtype = "grass", barricade="wooden",
	name = "wooden barricade", image = "terrain/grass.png",
	display = '#', color=colors.UMBER,
	always_remember = true,
	does_block_move = true,
	-- pass_projectile = true,
	nice_editer = { method="borders_def", def="grass" },
	nice_editer2 = { method="roads_def", def="wooden_barricade" },
}

newEntity{
	define_as = "FLOOR_WOODEN_BARRICADE",
	type = "floor", subtype = "floor", barricade="wooden",
	name = "wooden barricade", image = "terrain/marble_floor.png",
	display = '#', color=colors.UMBER,
	always_remember = true,
	does_block_move = true,
	-- pass_projectile = true,
	nice_editer = { method="borders_def", def="grass" },
	nice_editer2 = { method="roads_def", def="wooden_barricade" },
}

-----------------------------------------
-- Walls
-----------------------------------------
newEntity{
	define_as = "BAMBOO_HUT_WALL",
	type = "wall", subtype = "bamboo hut",
	name = "bamboo wall", image = "terrain/grass.png",
	display = '#', color=colors.LIGHT_UMBER, back_color=colors.DARK_UMBER,
	always_remember = true,
	does_block_move = true,
	can_pass = {pass_wall=1},
	block_sight = true,
	air_level = -5,
	dig = "BAMBOO_HUT_FLOOR",
	nice_tiler = { method="singleWall",  use_subtype=true, type="bamboo hut",
		v_full={"BHW_V_FULL", 100, 1, 1},
		h_full={"BHW_H_FULL", 20, 1, 8},
		n_cross={"BHW_N_CROSS", 100, 1, 1},
		s_cross={"BHW_S_CROSS", 100, 1, 1},
		e_cross={"BHW_E_CROSS", 100, 1, 1},
		w_cross={"BHW_W_CROSS", 100, 1, 1},
		cross={"BHW_CROSS", 100, 1, 1},
		ne={"BHW_NE", 100, 1, 1},
		nw={"BHW_NW", 100, 1, 1},
		se={"BHW_SE", 100, 1, 1},
		sw={"BHW_SW", 100, 1, 1},
	},
	nice_editer = { method="borders_def", def="grass"},
}

newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_V_FULL1", add_displays={class.new{z=16, image="terrain/bamboo/hut_wall_full_hor_01.png"}}}

newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_H_FULL", add_displays={class.new{z=16, image="terrain/bamboo/hut_wall_bottom_hor_01.png"}, class.new{image="terrain/bamboo/hut_wall_top_hor_01.png", display_y=-1, z=17}}}
local decors = {"wall_decor_skin_b_01","wall_decor_skin_a_01","wall_decor_spears_01","wall_decor_sticks_01","wall_decor_mask_c_01","wall_decor_mask_b_01","wall_decor_mask_a_01","wall_decor_3_masks_01"}
for i = 1, 8 do
	newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_H_FULL"..i, add_displays={class.new{z=16, image="terrain/bamboo/hut_wall_bottom_hor_01.png", add_mos={{image="terrain/bamboo/"..decors[i]..".png"}}}, class.new{image="terrain/bamboo/hut_wall_top_hor_01.png", display_y=-1, z=17}}}
end

newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_N_CROSS1", add_displays={class.new{z=16, image="terrain/bamboo/hut_wall_bottom_hor_01.png"}, class.new{z=17, image="terrain/bamboo/hut_corner_vert_south_4_1_2_top_01.png", display_y=-1, add_mos={{image="terrain/bamboo/hut_wall_top_hor_01.png", display_y=-1}}}}}
newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_S_CROSS1", add_displays={class.new{z=16, image="terrain/bamboo/hut_wall_bottom_hor_01.png"}, class.new{z=17, image="terrain/bamboo/hut_wall_full_hor_01.png", add_mos={{image="terrain/bamboo/hut_wall_top_hor_01.png", display_y=-1},{image="terrain/bamboo/hut_corner_vert_4_7_8_top_01.png", display_y=-1}}}}}
newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_E_CROSS1", add_displays={class.new{z=17, image="terrain/bamboo/hut_wall_full_hor_01.png"}, class.new{image="terrain/bamboo/wall_hor_divider_left_bottom_01.png", z=16, add_mos={{image="terrain/bamboo/wall_hor_divider_left_top_01.png", display_y=-1}}}}}
newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_W_CROSS1", add_displays={class.new{z=17, image="terrain/bamboo/hut_wall_full_hor_01.png"}, class.new{image="terrain/bamboo/wall_hor_divider_right_bottom_01.png", z=16, add_mos={{image="terrain/bamboo/wall_hor_divider_right_top_01.png", display_y=-1}}}}}

newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_CROSS1", add_displays={class.new{z=17, image="terrain/bamboo/hut_wall_bottom_hor_01.png"}, class.new{image="terrain/bamboo/hut_wall_top_hor_01.png", z=16, display_y=-1, add_mos={{image="terrain/bamboo/hut_wall_full_hor_01.png"},{image="terrain/bamboo/hut_corner_vert_4_7_8_top_01.png", display_y=-1}}}}}

newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_NE1", add_displays={class.new{z=17, image="terrain/bamboo/hut_corner_4_1_2_bottom_01.png"}, class.new{image="terrain/bamboo/hut_corner_4_1_2_top_01.png", display_y=-1, z=16}}}
newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_NW1", add_displays={class.new{z=17, image="terrain/bamboo/hut_corner_6_3_2_bottom_01.png"}, class.new{image="terrain/bamboo/hut_corner_6_3_2_top_01.png", display_y=-1, z=16}}}
newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_SE1", add_displays={class.new{z=17, image="terrain/bamboo/hut_corner_4_7_8_bottom_01.png"}, class.new{image="terrain/bamboo/hut_corner_4_7_8_top_01.png", display_y=-1, z=16}}}
newEntity{base="BAMBOO_HUT_WALL", define_as="BHW_SW1", add_displays={class.new{z=17, image="terrain/bamboo/hut_corner_8_9_6_bottom_01.png"}, class.new{image="terrain/bamboo/hut_corner_8_9_6_top_01.png", display_y=-1, z=16}}}

-----------------------------------------
-- Doors
-----------------------------------------
newEntity{
	define_as = "BAMBOO_HUT_DOOR",
	type = "wall", subtype = "bamboo hut",
	name = "door", image = "terrain/grass.png",
	display = '+', color=colors.LIGHT_UMBER, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="BAMBOO_HUT_DOOR_VERT", west_east="BAMBOO_HUT_DOOR_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	is_door = true,
	door_opened = "BAMBOO_HUT_DOOR_OPEN",
	dig = "FLOOR",
	nice_editer = { method="borders_def", def="grass"},
}
newEntity{
	define_as = "BAMBOO_HUT_DOOR_OPEN",
	type = "wall", subtype = "bamboo hut",
	name = "open door", image = "terrain/grass.png",
	display = "'", color=colors.LIGHT_UMBER, back_color=colors.DARK_UMBER,
	always_remember = true,
	is_door = true,
	door_closed = "BAMBOO_HUT_DOOR",
	nice_editer = { method="borders_def", def="grass"},
}
newEntity{ base = "BAMBOO_HUT_DOOR", define_as = "BAMBOO_HUT_DOOR_HORIZ", add_displays = {class.new{image="terrain/bamboo/hut_wall_door_closed_hor_01.png", z=17}, class.new{image="terrain/bamboo/hut_wall_top_hor_01.png", z=18, display_y=-1}}, door_opened = "BAMBOO_HUT_DOOR_HORIZ_OPEN"}
newEntity{ base = "BAMBOO_HUT_DOOR_OPEN", define_as = "BAMBOO_HUT_DOOR_HORIZ_OPEN", add_displays = {class.new{image="terrain/bamboo/hut_door_hor_open_door_palm_leaves_01.png"}, class.new{image="terrain/bamboo/hut_door_hor_open_door_01.png", z=17}, class.new{image="terrain/bamboo/hut_wall_top_hor_01.png", z=18, display_y=-1}}, door_closed = "BAMBOO_HUT_DOOR_HORIZ"}
newEntity{ base = "BAMBOO_HUT_DOOR", define_as = "BAMBOO_HUT_DOOR_VERT", add_displays = {class.new{image="terrain/bamboo/palm_door_closed_ver_01.png"}, class.new{image="terrain/bamboo/hut_wall_full_hor_01.png", z=18}}, door_opened = "BAMBOO_HUT_DOOR_OPEN_VERT", dig = "BAMBOO_HUT_DOOR_OPEN_VERT"}
newEntity{ base = "BAMBOO_HUT_DOOR_OPEN", define_as = "BAMBOO_HUT_DOOR_OPEN_VERT", add_displays = {class.new{image="terrain/bamboo/palm_door_open_bottom_ver_01.png"}, class.new{image="terrain/bamboo/palm_door_open_top_ver_01.png", z=18, display_y=-1, add_mos={{image="terrain/bamboo/hut_wall_full_hor_01.png"}, {image="terrain/bamboo/palm_door_open_bottom_ver_door_01.png"}}}}, door_closed = "BAMBOO_HUT_DOOR_VERT"}


newEntity{
	define_as = "CAVE_IN",
	type = "floor", subtype = "rock",
	name = "ladder to the next level", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/cave/cave_stairs_down_3_01.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

newEntity{
	define_as = "WEAKNESS",
	type = "floor", subtype = "cave",
	name = "tunnel weakness", image = "terrain/cave/cave_floor_1_01.png", add_mos = {{image = "terrain/floor_cave_structural_weakness.png"}},
	display = '&', color=colors.SANDY_BROWN, back_color=colors.DARK_UMBER,
	always_remember = true,
	notice = true,
	cave_structural_weakness = 1,
	embed_particles = {
		{name="structural_tower_weakness", rad=1, args={}},
	},
	on_move = function(self, x, y, who)
  		if who ~= game:getPlayer(true) then return end
  		local o, item_id, inven_id = who:findInAllInventoriesBy("define_as", "KRUK_INVASION_BOMB")
  		if not o then return end
		local q = game:getPlayer(true):hasQuest("orcs+kruk-invasion")
		if q then
			who:removeObject(inven_id, item_id)
			q:invasion_ends()
		end
	end,
}
