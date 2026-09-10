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
load("/data/general/grids/mountain.lua")
load("/data/general/grids/lava.lua")
load("/data-orcs/general/grids/mechstone.lua")

newEntity{
	define_as = "TO_CENTER", image = "terrain/mechstone/mech_stone_floor_1_01.png", add_mos = {{image="terrain/mechstone/mech_stone_stairs_down.png"}},
	type = "floor", subtype = "floor",
	name = "stair descending into Eyal's depths",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	change_zone = "orcs+slumbering-caves",
}

newEntity{
	define_as = "LOCKED_DOOR",
	type = "wall", subtype = "mech",
	name = "locked mech door",
	display = '+', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	nice_tiler = { method="door3d", north_south="LOCKED_DOOR_VERT", west_east="LOCKED_DOOR_HORIZ", default="west_east" },
	notice = true,
	always_remember = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	does_block_move = true,
}
newEntity{
	define_as = "LOCKED_DOOR_OPEN",
	type = "wall", subtype = "mech",
	name = "open mech door",
	display = "'", color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	always_remember = true,
	nice_tiler = { method="door3d", north_south="LOCKED_DOOR_OPEN_VERT", west_east="LOCKED_DOOR_HORIZ_OPEN", default="west_east" },
}
newEntity{ base = "LOCKED_DOOR", define_as = "LOCKED_DOOR_HORIZ", image = "terrain/mechstone/mech_stone_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechstone/vault_mech_stone_door1.png", add_mos={{image="terrain/mechstone/mech_stonewall_8_1.png", display_y=-1}}}}}
newEntity{ base = "LOCKED_DOOR_OPEN", define_as = "LOCKED_DOOR_HORIZ_OPEN", image = "terrain/mechstone/mech_stone_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechstone/vault_mech_stone_door1_open.png", add_mos={{image="terrain/mechstone/mech_stonewall_8_1.png", display_y=-1}}}}}

newEntity{ base = "LOCKED_DOOR", define_as = "LOCKED_DOOR_VERT", image = "terrain/mechstone/mech_stone_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechstone/vault_mech_stone_door1_vert.png", add_mos={{image="terrain/mechstone/vault_mech_stone_door1_vert_north.png", display_y=-1}}}}}
newEntity{ base = "LOCKED_DOOR_OPEN", define_as = "LOCKED_DOOR_OPEN_VERT", image = "terrain/mechstone/mech_stone_floor_1_01.png", add_displays={class.new{z=17, image="terrain/mechstone/vault_mech_stone_door1_open_vert.png", add_mos={{image="terrain/mechstone/vault_mech_stone_door1_open_vert_north.png", display_y=-1}}}}}

newEntity{
	define_as = "VINYL_PLAYER",
	name = "Phonograph", image = "terrain/mechstone/mech_stone_floor_1_01.png",
	add_displays = {class.new{image="terrain/steamtech_vinyl_disc_player.png", z = 17 }},
	display = '*', color=colors.BLUE,
	notice = true,
	always_remember = true,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then
			local chat = require("engine.Chat").new("orcs+phonograph", self, e)
			chat:invoke()
		end
		return true
	end,
}

newEntity{ base = "MECHSTONE_FLOOR",
	define_as = "EMBLEM",
	add_displays = {class.new{z=4, image="terrain/mechstone/atmos_sygil.png", display_w=8, display_h=8, display_x=-3.5, display_y=-4}},
	nice_tiler = false,
}

newEntity{
	define_as = "THRONE_BASE",
	type = "throne", subtype = "mech",
	name = "throne", image = "terrain/mechstone/mech_stone_floor_1_01.png",
	display = '#', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	always_remember = true,
	does_block_move = true,
	can_pass = {pass_wall=1},
	block_sight = true,
	air_level = -20,
}

for _, n in ipairs{"throne_w", "throne_e", "throne_n", "throne_nw", "throne_ne"} do
	newEntity{ base = "THRONE_BASE", define_as = n:upper(),
		add_mos = {{image="terrain/mechstone/mech_stone_"..n.."_1.png"}},
		add_displays = {class.new{z=17, display_y=-1, image="terrain/mechstone/mech_stone_"..n.."_0.png"}},
	}
end
