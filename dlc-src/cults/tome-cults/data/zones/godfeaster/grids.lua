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
load("/data-cults/general/grids/godfeaster.lua")

newEntity{
	define_as = "GODFEASTER_PORTAL",
	type = "floor", subtype = "maggot",
	name = "portal to outside", image = "terrain/godfeaster/godfeaster_floor_1_01.png", add_mos={{image = "terrain/demon_portal.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	shader = "maggot",
	change_level = 1,
	change_zone = "wilderness",
}

newEntity{
	define_as = "GODFEASTER_SPINE",
	type = "floor", subtype = "maggot", is_maggot_spine = true,
	name = "maggot's nerval spine", image = "terrain/godfeaster/godfeaster_floor_1_01.png",
	display = '=', color=colors.WHITE,
	always_remember = true, special = true, autoexplore_ignore = true,
	shader = "maggot",
}

for i = 1, 5 do
	newEntity{ base = "GODFEASTER_SPINE", define_as = "GODFEASTER_SPINE_HORIZ"..i,
		add_mos = {{image="terrain/spinal_cord/spinal_cord_horizontal_top_a_0"..i..".png"}},
	}
end
newEntity{ base = "GODFEASTER_SPINE", define_as = "GODFEASTER_SPINE_DIAG_START_3",
	add_mos = {{image="terrain/spinal_cord/spinal_cord_diagonal_start_a_03.png"}},
	add_displays = {class.new{image="terrain/spinal_cord/spinal_cord_diagonal_line_tiny_d_02.png", display_y=1, z=2, add_mos={{image="terrain/spinal_cord/spinal_cord_diagonal_line_tiny_c_01.png", display_x=1}}}},
}
newEntity{ base = "GODFEASTER_SPINE", define_as = "GODFEASTER_SPINE_DIAG_START_9",
	add_mos = {{image="terrain/spinal_cord/spinal_cord_diagonal_start_a_06.png"}},
	add_displays = {class.new{image="terrain/spinal_cord/spinal_cord_diagonal_line_tiny_a_02.png", display_y=-1, z=2, add_mos={{image="terrain/spinal_cord/spinal_cord_diagonal_line_tiny_e_01.png", display_x=1}}}},
}
for i = 1, 2 do
	newEntity{ base = "GODFEASTER_SPINE", define_as = "GODFEASTER_SPINE_DIAG_3_"..i,
		add_mos = {{image="terrain/spinal_cord/spinal_cord_diagonal_line_b_0"..i..".png"}},
		add_displays = {class.new{image="terrain/spinal_cord/spinal_cord_diagonal_line_tiny_d_02.png", display_y=1, z=2, add_mos={{image="terrain/spinal_cord/spinal_cord_diagonal_line_tiny_c_01.png", display_x=1}}}},
	}
	newEntity{ base = "GODFEASTER_SPINE", define_as = "GODFEASTER_SPINE_DIAG_9_"..i,
		add_mos = {{image="terrain/spinal_cord/spinal_cord_diagonal_line_a_0"..i..".png"}},
		add_displays = {class.new{image="terrain/spinal_cord/spinal_cord_diagonal_line_tiny_a_02.png", display_y=-1, z=2, add_mos={{image="terrain/spinal_cord/spinal_cord_diagonal_line_tiny_e_01.png", display_x=1}}}},
	}
end
newEntity{ base = "GODFEASTER_SPINE", define_as = "GODFEASTER_SPINE_DIAG_STOP_3",
	add_mos = {{image="terrain/spinal_cord/spinal_cord_diagonal_start_a_07.png"}},
}
newEntity{ base = "GODFEASTER_SPINE", define_as = "GODFEASTER_SPINE_DIAG_STOP_9",
	add_mos = {{image="terrain/spinal_cord/spinal_cord_diagonal_start_a_02.png"}},
}
newEntity{ base = "GODFEASTER_SPINE", define_as = "GODFEASTER_SPINE_START",
	add_mos = {{image="terrain/spinal_cord/spinal_cord_end_top_a_1_01.png"}},
}
newEntity{ base = "GODFEASTER_SPINE", define_as = "GODFEASTER_SPINE_STOP",
	add_mos = {{image="terrain/spinal_cord/spinal_cord_end_top_a_1_02.png"}},
}

-- Auto generate all dead grids
for _, e in ipairs(loading_list) do if e.is_maggot_spine then
	local ne = e:cloneFull()
	ne.define_as = "DEAD_"..ne.define_as
	ne.name = ("%s (corrupted)"):tformat(_t(ne.name))
	for i, mo in ipairs(ne.add_mos or {}) do mo.image = mo.image:gsub("^terrain/spinal_cord/", "terrain/spinal_cord_dead/") end
	for i, d in ipairs(ne.add_displays or {}) do
		d.image = d.image:gsub("^terrain/spinal_cord/", "terrain/spinal_cord_dead/")
		for i, mo in ipairs(d.add_mos or {}) do mo.image = mo.image:gsub("^terrain/spinal_cord/", "terrain/spinal_cord_dead/") end
	end
	loading_list[ne.define_as] = ne
end end

-- Dead head is manually defined since the alive one is in npc
newEntity{ base = "GODFEASTER_SPINE", define_as = "DEAD_MAGGOT_SPINE_HEAD",
	add_mos = {{image="terrain/spinal_cord_dead/spinal_cord_head_top_a_02.png"}},
}
