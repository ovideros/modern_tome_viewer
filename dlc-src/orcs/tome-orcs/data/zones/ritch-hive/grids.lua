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
load("/data/general/grids/sand.lua")

newEntity{
	define_as = "SAND_RITCH_EGGS_FOR_DISPLAY",
	type = "floor", subtype = "sand",
	name = "pile of ritch eggs", image = "object/ritch_eggs.png",
	display = '*', color_r=255, color_g=100, color_b=50,
}

newEntity{
	define_as = "SAND_INCUBATOR",
	type = "floor", subtype = "sand",
	name = "comfy ritch nest", image = "terrain/sand.png", add_displays = {class.new{image="terrain/ritch_eggs_incubator_empty.png"}},
	display = '*', color=colors.GOLD,
	notice = true,
	eggs_set = false,
	on_move = function(self, x, y, who)
		if who == game:getPlayer(true) and game.zone.ritches_collected >= 30 and not self.eggs_set then
			who:gainExp(3000)
			self.eggs_set = true
			self.add_displays[1].image = "terrain/ritch_eggs_incubator_full.png"
			self:removeAllMOs()
			game.level.map:updateMap(x, y)
			game.zone.ritches_collected = 0
			who:setQuestStatus("orcs+ritch-hive", engine.Quest.COMPLETED, "place")
			who:setQuestStatus("orcs+ritch-hive", engine.Quest.COMPLETED)
		end
	end,
}


local cracks_editer = {method="borders_def", def="blackcracks"}

newEntity{
	define_as = "CRACKS",
	type = "wall", subtype = "cracks",
	name = "huge crack in the floor", image = "terrain/cracks/ground_9_01.png",
	display = '.', color=colors.BLACK, back_color=colors.BLACK,
	nice_editer = cracks_editer,
	pass_projectile = true,
	does_block_move = true,
}
