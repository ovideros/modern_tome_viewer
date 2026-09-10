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
load("/data-orcs/general/grids/snow_mountains.lua")

newEntity{ base = "ROCKY_GROUND",
	define_as = "MERCHANT_STALL",
	name = "merchant stall", image = "terrain/rocky_ground.png", add_mos={{image="terrain/steam_giant_merchant_stall.png"}},
	display = '_', color=colors.PINK,
	grow = table.NIL_MERGE,
}
