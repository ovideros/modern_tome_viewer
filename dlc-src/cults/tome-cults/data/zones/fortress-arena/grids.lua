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
load("/data/general/grids/cave.lua")

newEntity{
	define_as = "ORB_MULTIVERSE",
	name = "Arena Control Orb", image = "terrain/cave/cave_floor_1_01.png", add_displays = {class.new{z=18, image="terrain/pedestal_orb_05.png", display_y=-1, display_h=2}},
	display = '*', color=colors.LIGHT_BLUE,
	notice = true,
	always_remember = true,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then
			local Dialog = require("engine.ui.Dialog")
			Dialog:yesnoPopup(_t"S.M.A.C.K", _t"Do you want to flee the fight?", function(ret) if ret then
				require("mod.class.CultsDLC").backFromSMACK(_t"S.M.A.C.K", _t[[With but a thought you enact Yiilkgur's safety protocols and pull yourself out of the arena.
You have fled your fight.]])
			end end)
		end
		return true
	end,
}
