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
load("/data/general/grids/bone.lua", function(e)
	if e.image == "terrain/sandfloor.png" or e.image == "terrain/bone/bone_floor_1_01.png" then
		e.image = "terrain/oldstone_floor.png"
	end
	if e.nice_editer and e.nice_editer.def == "sand" then
		e.nice_editer = nil
	end
end)

newEntity{
	define_as = "RITUAL_CIRCLE",
	name = "ritual circle", image = "terrain/oldstone_floor.png",
	force_clone = true,
	display = ';', color=colors.GOLD, back_color=colors.GREY,
	always_remember = true,
	nice_tiler = { method="replace", base={"RITUAL_CIRCLE", 100, 1, 2}},
}
for i = 1, 2 do
	newEntity{ base = "RITUAL_CIRCLE", define_as = "RITUAL_CIRCLE"..i,
		-- add_displays = {class.new{z=3, image="object/candle_dark"..i..".png"}},
		embed_particles = {
			{name="candle", rad=1, args={candle_id="dark"..i}},
		},
	}
end
