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
load("/data/general/grids/icecave.lua")
load("/data/general/grids/water.lua")


for i = 1, 3 do
newEntity{ define_as = "MURAL_PAINTING"..i,
	type = "wall", subtype = "icecave",
	name="a crude mural painting", lore = "yeti-cave-"..i,
	display='#', color=colors.LIGHT_RED,
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -10,
	special_minimap = colors.PURPLE,
	image="terrain/icecave/icecave_V3_8_yeti_carving_0"..i..".png",
	block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then game.party:learnLore(self.lore) end return true end
}
end
