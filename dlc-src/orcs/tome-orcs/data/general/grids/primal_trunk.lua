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

local primal_trunk_editer = { method="borders_def", def="primal_trunk"}

newEntity{
	define_as = "PRIMAL_TRUNK",
	type = "floor", subtype = "primal trunk",
	name = "primal trunk", image = "terrain/primal_trunk/primal_forest_main_01.png",
	display = '.', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	nice_tiler = { method="replace", base={"PRIMAL_TRUNK_PATCH", 100, 1, 14}},
	nice_editer = primal_trunk_editer,
}
for i = 1, 6 do newEntity{ base = "PRIMAL_TRUNK", define_as = "PRIMAL_TRUNK_PATCH"..i, image = ("terrain/primal_trunk/primal_forest_main_%02d.png"):format(i) } end
