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
load("/data/general/grids/jungle_hut.lua")

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
