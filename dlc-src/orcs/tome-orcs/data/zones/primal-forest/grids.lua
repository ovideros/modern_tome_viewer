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
load("/data/general/grids/water.lua")
load("/data/general/grids/underground.lua")
load("/data-orcs/general/grids/primal_trunk.lua")

newEntity{
	define_as = "EMPTY",
	type = "void", subtype = "void",
	name = "bottom of forest",
	display = ' ',
	_noalpha = false,
	always_remember = true,
	does_block_move = true,
	pass_projectile = true,
	can_pass = {levitation=1},
}

local grass_editer = { method="borders_def", def="grass"}

local treesdef = {
	{"oldforest_tree_03", {tall=-1, "shadow", "trunk_01", {"foliage_summer_%02d",1,2}}},
	{"oldforest_tree_03", {tall=-1, "shadow", "trunk_02", {"foliage_summer_%02d",3,3}}},
	{"oldforest_tree_03", {tall=-1, "shadow", "trunk_03", {"foliage_summer_%02d",4,4}}},
	{"small_oldforest_tree_03", {"shadow", "trunk_01", {"foliage_summer_%02d",1,2}}},
	{"small_oldforest_tree_03", {"shadow", "trunk_02", {"foliage_summer_%02d",3,3}}},
	{"small_oldforest_tree_03", {"shadow", "trunk_03", {"foliage_summer_%02d",4,4}}},

	{"small_willow", {"shadow", "trunk", "foliage_bare"}},
	{"small_willow_moss", {"shadow", "trunk", "foliage_bare"}},
	{"willow", {tall=-1, "shadow", "trunk", "foliage_bare"}},
	{"willow_moss", {tall=-1, "shadow", "trunk", "foliage_bare"}},
	{"small_willow", {"shadow", "trunk", "foliage_summer"}},
	{"small_willow_moss", {"shadow", "trunk", "foliage_summer"}},
	{"willow", {tall=-1, "shadow", "trunk", "foliage_summer"}},

	{"elventree", {tall=-1, "shadow", "trunk", "foliage_summer"}},
	{"elventree_03", {tall=-1, "shadow", "trunk", "foliage_summer"}},
	{"fat_elventree", {tall=-1, "shadow", "trunk", {"foliage_summer_%02d",1,2}}},
	{"oak", {tall=-1, "shadow", {"trunk_%02d",1,2}, {"foliage_summer_%02d",1,4}}},
}

newEntity{
	define_as = "TREE",
	type = "wall", subtype = "grass",
	name = "primal tree",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "GRASS",
	is_tree = true,
	nice_tiler = { method="replace", base={"TREE", 100, 1, 30}},
	nice_editer = grass_editer,
}
newEntity{
	define_as = "HARDTREE",
	type = "wall", subtype = "grass",
	name = "tall thick primal tree",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	nice_tiler = { method="replace", base={"HARDTREE", 100, 1, 30}},
	nice_editer = grass_editer,
}
for i = 1, 30 do
	newEntity(class:makeNewTrees({base="TREE", define_as = "TREE"..i, image = "terrain/grass.png"}, treesdef, 3))
end
for i = 1, 30 do
	newEntity(class:makeNewTrees({base="HARDTREE", define_as = "HARDTREE"..i, image = "terrain/grass.png"}, treesdef))
end

newEntity{ define_as = "BIG_TRUNK",
	type = "wall", subtype = "grass",
	name = "huge primal tree", special = true,
	display='#', color=colors.UMBER, image = "terrain/grass.png",
	add_displays={engine.Entity.new{
		z=18, image="terrain/primal_trunk/primal_forest_trunk_up.png", display_on_seen=true, display_on_remember=true, display_h=2, display_y=-0.5, display_w=2, display_x=-0.5,
	}},
	always_remember = true,
	block_sight = true,
	change_level = 1,
}

newEntity{ define_as = "BIG_TRUNK_BODY",
	type = "wall", subtype = "grass",
	name = "huge primal tree", special = true,
	display='#', color=colors.UMBER, image = "terrain/grass.png",
	always_remember = true,
	block_sight = true,
}

newEntity{
	define_as = "AUTOCLIMB",
	type = "trigger", subtype = "trigger",
	special = true,
	on_move = function(self, x, y, who)
		if not who or not who.player then return end
		if who.runStop then who:runStop(_t"climb") end
		require("engine.ui.Dialog"):yesnoPopup(_t"Huge Tree", _t"You think you can climb this tree if you want.", function(ret) if ret then
			game:changeLevel(2)
		end end, _t"Climb", _t"Stay")
	end,
}

newEntity{
	define_as = "DOWN_TO_GROUND",
	type = "floor", subtype = "primal trunk",
	name = "climb back to the ground", image="terrain/primal_trunk/primal_forest_trunk_down.png", z = 6,
	display_h=2, display_y=-0.5, display_w=2, display_x=-0.5,
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
