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
load("/data/general/grids/water.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/lava.lua")
load("/data/general/grids/sand.lua")
load("/data/general/grids/mountain.lua")
load("/data/general/grids/psicave.lua")
load("/data/general/grids/cave.lua")


newEntity{
	define_as = "TO_CAVE", image = "terrain/sandfloor.png", add_mos = {{image="terrain/stair_down.png"}},
	type = "floor", subtype = "sand",
	name = "Stair to the ruins",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

newEntity{
	define_as = "UP_CAVE", image = "terrain/psicave/psitech_floor_1_01.png", add_mos = {{image="terrain/psicave/psitech_stairs_exit_1_01.png"}},
	type = "floor", subtype = "sand",
	name = "Stair to the cave",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "PSITECH_MACHINE",
	name = "Old Psi-Machine", image = "terrain/psicave/psitech_floor_1_01.png",
	add_displays = {class.new{image="terrain/psitech_machine.png", z = 17, }},
	display = '*', color=colors.PURPLE,
	notice = true,
	always_remember = true,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then
			local chat = require("engine.Chat").new("orcs+weissi-machine", self, e)
			chat:invoke()
		end
		return true
	end,
}
