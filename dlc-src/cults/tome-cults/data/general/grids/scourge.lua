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
	define_as = "SCOURGE_FLOOR",
	type = "floor", subtype = "scourge",
	name = "floor", image = "terrain/scourge/scourge_pits_floor.png",
	display = '.', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	grow = "SCOURGE_TREE",
	nice_tiler = { method="replace", base={"SCOURGE_FLOOR", 50, 1, 20}},
}
for i = 1, 20 do
local add = nil
if rng.percent(40) then add = {{image="terrain/scourge/deco_floor_scourge_pits_0"..rng.range(1,6)..".png"}} end
newEntity{base = "SCOURGE_FLOOR", define_as = "SCOURGE_FLOOR"..i, image = "terrain/scourge/scourge_pits_floor"..(1 + i % 8)..".png", add_mos=add}
end

local creep_editer = { method="borders_def", def="scourge_creep"}
newEntity{
	define_as = "SCOURGE_CREEP",
	type = "floor", subtype = "creep",
	name = "creep", image = "terrain/scourge/creep_scourge_pits_main_01.png",
	display = '.', color=colors.GREY, back_color={r=44,g=95,b=43},
	grow = "TREE",
	nice_tiler = { method="replace", base={"SCOURGE_CREEP", 100, 1, 3}},
	nice_editer = creep_editer,
}
for i = 1, 3 do newEntity{ base = "SCOURGE_CREEP", define_as = "SCOURGE_CREEP"..i, image = ("terrain/scourge/creep_scourge_pits_main_%02d.png"):format(i) } end

--[[
local treesdef = {
	{"tentacles_tree_01", {alltall=-1, "shadow", "trunk", "head"}},
	{"tentacles_tree_02", {alltall=-1, "shadow", "trunk", "head"}},
	{"tentacles_tree_03", {alltall=-1, "shadow", "trunk", "head"}},
	{"tentacles_tree_04", {alltall=-1, "shadow", "trunk", "head"}},
	{"tentacles_tree_05", {alltall=-1, "shadow", "trunk", "head"}},
	{"tentacles_tree_06", {alltall=-1, "shadow", "trunk", "head"}},
}

newEntity{
	define_as = "SCOURGE_TREE",
	type = "wall", subtype = "scourge",
	name = "tentacle 'tree'",
	image = "terrain/tree.png",
	display = '#', color=colors.PURPLE, back_color=colors.UMBER,
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	nice_tiler = { method="replace", base={"SCOURGE_TREE", 100, 1, 30}},
	dig = "SCOURGE_FLOOR",
}
for i = 1, 30 do
	newEntity(class:makeNewTrees({base="SCOURGE_TREE", define_as = "SCOURGE_TREE"..i, image = "terrain/scourge/scourge_pits_floor.png"}, treesdef, nil, "terrain/scourge/"))
end

newEntity{
	define_as = "SCOURGE_HARDTREE",
	type = "wall", subtype = "scourge",
	name = "tentacle 'tree'",
	image = "terrain/tree.png",
	display = '#', color=colors.PURPLE, back_color=colors.UMBER,
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_esp = true,
	block_sense = true,
	nice_tiler = { method="replace", base={"SCOURGE_HARDTREE", 100, 1, 30}},
}
for i = 1, 30 do
	newEntity(class:makeNewTrees({base="SCOURGE_HARDTREE", define_as = "SCOURGE_HARDTREE"..i, image = "terrain/scourge/scourge_pits_floor.png"}, treesdef, nil, "terrain/scourge/"))
end
]]

newEntity{
	define_as = "SCOURGE_TREE",
	type = "wall", subtype = "scourge",
	name = "tentacle 'tree'",
	image = "terrain/scourge/scourge_pits_floor.png",
	display = '#', color=colors.PURPLE, back_color=colors.UMBER,
	always_remember = true,
	can_pass = {pass_tree=1},
	is_tentacle_tree = 1,
	does_block_move = true,
	block_sight = true,
	nice_tiler = { method="replaceVisible", base={{"SCOURGE_TREE_STATIC", "SCOURGE_TREE"}, 100, 1, 1}},
	dig = "SCOURGE_FLOOR",
}
for i = 1, 40 do
	local id = rng.range(1, 6)
	newEntity{ base = "SCOURGE_TREE", define_as = "SCOURGE_TREE"..i,
		-- nice_tiler = false, -- We dont use that so the visibility replacer will update correctly when dug
		tentacle_id = id,
		add_displays={class.new{
			z = 16,
			image=("terrain/scourge/tentacles_tree_%02d_base.png"):format(id),
			embed_particles = {
				{name="tentacle_tree", rad=1, args={tentacle_id=id, force_tf=0}},
			},
		}},
		force_clone = true,
	}
	newEntity{ base = "SCOURGE_TREE", define_as = "SCOURGE_TREE_STATIC"..i,
		-- nice_tiler = false, -- We dont use that so the visibility replacer will update correctly when dug
		tentacle_id = id,
		add_displays={class.new{
			z = 16,
			image=("terrain/scourge/tentacles_tree_%02d_base.png"):format(id),
			add_mos = {{image=("terrain/scourge/tentacles_tree_%02d_front.png"):format(id), display_h=2, display_y=-1, display_w=2, display_x=-0.5}}
		}},
	}
end

newEntity{
	define_as = "SCOURGE_HARDTREE",
	type = "wall", subtype = "scourge",
	name = "tentacle 'tree'",
	image = "terrain/scourge/scourge_pits_floor.png",
	display = '#', color=colors.PURPLE, back_color=colors.UMBER,
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	block_esp = true,
	block_sense = true,
	nice_tiler = { method="replaceVisible", base={{"SCOURGE_HARDTREE_STATIC","SCOURGE_HARDTREE"}, 100, 1, 40}},
}
for i = 1, 40 do
	local id = rng.range(1, 6)
	newEntity{ base = "SCOURGE_HARDTREE", define_as = "SCOURGE_HARDTREE"..i,
		-- nice_tiler = false, -- We dont use that so the visibility replacer will update correctly when dug
		tentacle_id = id,
		add_displays={class.new{
			z = 16,
			image=("terrain/scourge/tentacles_tree_%02d_base.png"):format(id),
			embed_particles = {
				{name="tentacle_tree", rad=1, args={tentacle_id=id, force_tf=0}},
			},
		}},
	}
	newEntity{ base = "SCOURGE_HARDTREE", define_as = "SCOURGE_HARDTREE_STATIC"..i,
		-- nice_tiler = false, -- We dont use that so the visibility replacer will update correctly when dug
		tentacle_id = id,
		add_displays={class.new{
			z = 16,
			image=("terrain/scourge/tentacles_tree_%02d_base.png"):format(id),
			add_mos = {{image=("terrain/scourge/tentacles_tree_%02d_front.png"):format(id), display_h=2, display_y=-1, display_w=2, display_x=-0.5}}
		}},
	}
end

newEntity{
	define_as = "SCOURGE_VAULT",
	type = "wall", subtype = "scourge",
	name = "huge loose rock", image = "terrain/scourge/scourge_pits_floor.png", add_mos = {{image="terrain/huge_rock.png"}},
	display = '+', color=colors.GREY, back_color={r=44,g=95,b=43},
	notice = true,
	always_remember = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	is_door = true,
	door_player_check = _t"This rock is loose, you think you can move it away.",
	door_opened = "SCOURGE_FLOOR",
}

newEntity{
	define_as = "SCOURGE_LADDER_DOWN",
	type = "floor", subtype = "scourge",
	name = "ladder to the next level", image = "terrain/scourge/scourge_pits_floor.png", add_displays = {class.new{image="terrain/scourge/scourge_pits_ladder_down.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "SCOURGE_LADDER_UP",
	type = "floor", subtype = "scourge",
	name = "ladder to the previous level", image = "terrain/scourge/scourge_pits_floor.png", add_displays = {class.new{image="terrain/scourge/scourge_pits_ladder_up.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "SCOURGE_LADDER_UP_WILDERNESS",
	type = "floor", subtype = "scourge",
	name = "ladder to worldmap", image = "terrain/scourge/scourge_pits_floor.png", add_displays = {class.new{image="terrain/scourge/scourge_pits_ladder_exit.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}
