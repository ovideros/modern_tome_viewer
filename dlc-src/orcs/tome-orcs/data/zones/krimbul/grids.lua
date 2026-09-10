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

load("/data-orcs/general/grids/manacave.lua")
load("/data-orcs/general/grids/mechwall.lua")
load("/data/general/grids/water.lua")

newEntity{
	define_as = "AIRSHIP_MAIN",
	name = "airship hull", image = "terrain/underwater/subsea_floor_02.png",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	does_block_move = true,
}

newEntity{
	define_as = "AIRSHIP_ENTRANCE",
	name = "breach into the airship hull", image = "terrain/underwater/subsea_floor_02.png", add_displays = {class.new{z=4, image="terrain/crashed_airship.png", display_w=4, display_h=4, display_x=-1.5, display_y=-2.5}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

newEntity{
	define_as = "WATER_DOOR_SHUT",
	type = "trigger", subtype = "trigger",
	on_door_opened = function(self, x, y, who)
		if not who or not who.player then return end
		game:onTickEnd(function()
			if game.level.map.attrs(x, y, "dry_side") then
				local g = game.level.map(x, y+2, engine.Map.TERRAIN)
				if g and g.door_closed then
					local ng = game.zone:makeEntityByName(game.level, "terrain", g.door_closed)
					game.zone:addEntity(game.level, ng, "terrain", x, y+2)
					game.nicer_tiles:updateAround(game.level, x, y+2)
				end
			elseif game.level.map.attrs(x, y, "water_side") then
				local g = game.level.map(x, y-2, engine.Map.TERRAIN)
				if g and g.door_closed then
					local ng = game.zone:makeEntityByName(game.level, "terrain", g.door_closed)
					game.zone:addEntity(game.level, ng, "terrain", x, y-2)
					game.nicer_tiles:updateAround(game.level, x, y-2)
				end
			end
		end)
	end,
}

newEntity{
	define_as = "WATER_FLOOR_ALGAE",
	type = "floor", subtype = "water",
	name = "underwater luminous algae", image = "terrain/underwater/subsea_floor_02.png", add_mos={{image = resolvers.rngtable{"terrain/luminous_algae_01.png", "terrain/luminous_algae_02.png"}}},
	display = ':', color=colors.LIGHT_BLUE, back_color=colors.DARK_BLUE,
	air_level = -5,
	air_condition = "water",
	force_clone = true,
}
