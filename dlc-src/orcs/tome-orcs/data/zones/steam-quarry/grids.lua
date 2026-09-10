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
	define_as = "STEAM_VALVE",
	name = "giant steam valve", image = "terrain/rocky_ground.png", add_displays={class.new{z=6, image="terrain/steam_valve_intact.png"}},
	display = '+', color=colors.RED,
	grow = table.NIL_MERGE,
	force_clone = true,
	always_remember = true,
	notice = true,
	special = true,
	special_minimap = colors.CRIMSON,
	block_move = function(self, x, y, who, act, couldpass)
		if not who or not who.player or not act then return false end
		self.add_displays[1] = self.add_displays[1]:cloneFull()
		self.add_displays[1].image = "terrain/steam_valve_destroyed.png"
		self:removeAllMOs()
		game.level.map:updateMap(x, y)
		game.player:resolveSource():setQuestStatus("orcs+quarry", engine.Quest.COMPLETED, self.valve_name)
		game.log("#PURPLE#You kick and destroy the valve!")
	end,
}

newEntity{ base = "STEAM_VALVE",
	define_as = "STEAM_VALVE1",
	valve_name = "valve1",
}
newEntity{ base = "STEAM_VALVE",
	define_as = "STEAM_VALVE2",
	valve_name = "valve2",
}
newEntity{ base = "STEAM_VALVE",
	define_as = "STEAM_VALVE3",
	valve_name = "valve3",
}
