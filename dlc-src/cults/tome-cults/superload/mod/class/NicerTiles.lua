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

local Map = require "engine.Map"
local NB_VARIATIONS = 30

local _M = loadPrevious(...)

_M.generic_borders_defs.scourge_creep = { method="borders", type="scourge_creep", forbid={lava=true, rock=true, grass=true},
	default8={add_mos={{image="terrain/scourge/creep_scourge_pits_2_%02d.png", display_y=-1}}, min=1, max=3},
	default2={add_mos={{image="terrain/scourge/creep_scourge_pits_8_%02d.png", display_y=1}}, min=1, max=3},
	default4={add_mos={{image="terrain/scourge/creep_scourge_pits_6_%02d.png", display_x=-1}}, min=1, max=3},
	default6={add_mos={{image="terrain/scourge/creep_scourge_pits_4_%02d.png", display_x=1}}, min=1, max=3},

	-- default1={add_mos={{image="terrain/scourge/creep_scourge_pits_9_%02d.png", display_x=-1, display_y=1}}, min=1, max=1},
	-- default3={add_mos={{image="terrain/scourge/creep_scourge_pits_7_%02d.png", display_x=1, display_y=1}}, min=1, max=1},
	-- default7={add_mos={{image="terrain/scourge/creep_scourge_pits_3_%02d.png", display_x=-1, display_y=-1}}, min=1, max=1},
	-- default9={add_mos={{image="terrain/scourge/creep_scourge_pits_1_%02d.png", display_x=1, display_y=-1}}, min=1, max=1},

	default1i={add_mos={{image="terrain/scourge/creep_scourge_pits_inner_1_%02d.png", display_x=-1, display_y=1}}, min=1, max=3},
	default3i={add_mos={{image="terrain/scourge/creep_scourge_pits_inner_3_%02d.png", display_x=1, display_y=1}}, min=1, max=3},
	default7i={add_mos={{image="terrain/scourge/creep_scourge_pits_inner_7_%02d.png", display_x=-1, display_y=-1}}, min=1, max=3},
	default9i={add_mos={{image="terrain/scourge/creep_scourge_pits_inner_9_%02d.png", display_x=1, display_y=-1}}, min=1, max=3},
}

_M.generic_borders_defs.spacedwarf_creep = { method="borders", type="spacedwarf_creep", forbid={lava=true, rock=true, grass=true},
	default8={add_mos={{image="terrain/spacedwarf/creep_spacedwarf_2_%02d.png", display_y=-1}}, min=1, max=1},
	default2={add_mos={{image="terrain/spacedwarf/creep_spacedwarf_8_%02d.png", display_y=1}}, min=1, max=1},
	default4={add_mos={{image="terrain/spacedwarf/creep_spacedwarf_6_%02d.png", display_x=-1}}, min=1, max=1},
	default6={add_mos={{image="terrain/spacedwarf/creep_spacedwarf_4_%02d.png", display_x=1}}, min=1, max=1},

	-- default1={add_mos={{image="terrain/spacedwarf/creep_spacedwarf_9_%02d.png", display_x=-1, display_y=1}}, min=1, max=1},
	-- default3={add_mos={{image="terrain/spacedwarf/creep_spacedwarf_7_%02d.png", display_x=1, display_y=1}}, min=1, max=1},
	-- default7={add_mos={{image="terrain/spacedwarf/creep_spacedwarf_3_%02d.png", display_x=-1, display_y=-1}}, min=1, max=1},
	-- default9={add_mos={{image="terrain/spacedwarf/creep_spacedwarf_1_%02d.png", display_x=1, display_y=-1}}, min=1, max=1},

	default1i={add_mos={{image="terrain/spacedwarf/creep_spacedwarf_inner_1_%02d.png", display_x=-1, display_y=1}}, min=1, max=1},
	default3i={add_mos={{image="terrain/spacedwarf/creep_spacedwarf_inner_3_%02d.png", display_x=1, display_y=1}}, min=1, max=1},
	default7i={add_mos={{image="terrain/spacedwarf/creep_spacedwarf_inner_7_%02d.png", display_x=-1, display_y=-1}}, min=1, max=1},
	default9i={add_mos={{image="terrain/spacedwarf/creep_spacedwarf_inner_9_%02d.png", display_x=1, display_y=-1}}, min=1, max=1},
}

_M.generic_borders_defs.maggot = { method="walls", type="maggot", forbid={}, use_type=true, extended=true, consider_diagonal_doors=true,
	default8={add_displays={{shader = "maggot", image="terrain/maggot/maggotwall_8_%d.png", display_y=-1, z=16}}, min=1, max=2},
	default8p={add_displays={{shader = "maggot", image="terrain/maggot/maggot_V3_pillar_top_01.png", display_y=-1, z=16}}, min=1, max=1},
	default7={add_displays={{shader = "maggot", image="terrain/maggot/maggot_V3_inner_7_01.png", display_y=-1, z=16}}, min=1, max=1},
	default9={add_displays={{shader = "maggot", image="terrain/maggot/maggot_V3_inner_9_01.png", display_y=-1, z=16}}, min=1, max=1},
	default7i={add_displays={{shader = "maggot", image="terrain/maggot/maggot_V3_3_01.png", display_y=-1, z=16}}, min=1, max=1},
	default8i={add_displays={{shader = "maggot", image="terrain/maggot/maggotwall_8h_1.png", display_y=-1, z=16}}, min=1, max=1},
	default9i={add_displays={{shader = "maggot", image="terrain/maggot/maggot_V3_1_01.png", display_y=-1, z=16}}, min=1, max=1},
	default73i={add_displays={{shader = "maggot", image="terrain/maggot/maggotwall_91d_1.png", display_y=-1, z=16}}, min=1, max=1},
	default91i={add_displays={{shader = "maggot", image="terrain/maggot/maggotwall_73d_1.png", display_y=-1, z=16}}, min=1, max=1},

	default2={image="terrain/maggot/maggot_floor_1_01.png", add_mos={{shader = "maggot", image="terrain/maggot/maggot_V3_8_0%d.png"}}, min=1, max=5},
	default2p={image="terrain/maggot/maggot_floor_1_01.png", add_mos={{shader = "maggot", image="terrain/maggot/maggot_V3_pillar_bottom_01.png"}}, min=1, max=1},
	default1={image="terrain/maggot/maggot_floor_1_01.png", add_mos={{shader = "maggot", image="terrain/maggot/maggot_V3_inner_1_01.png"}}, min=1, max=1},
	default3={image="terrain/maggot/maggot_floor_1_01.png", add_mos={{shader = "maggot", image="terrain/maggot/maggot_V3_inner_3_01.png"}}, min=1, max=1},
	default1i={image="terrain/maggot/maggot_floor_1_01.png", add_mos={{shader = "maggot", image="terrain/maggot/maggot_V3_7_01.png"}}, min=1, max=1},
	default2i={image="terrain/maggot/maggot_floor_1_01.png", add_mos={{shader = "maggot", image="terrain/maggot/maggotwall_2h_1.png"}}, min=1, max=1},
	default3i={image="terrain/maggot/maggot_floor_1_01.png", add_mos={{shader = "maggot", image="terrain/maggot/maggot_V3_9_01.png"}}, min=1, max=1},
	default19i={image="terrain/maggot/maggot_floor_1_01.png", add_mos={{shader = "maggot", image="terrain/maggot/maggotwall_19d_1.png"}}, min=1, max=1},
	default37i={image="terrain/maggot/maggot_floor_1_01.png", add_mos={{shader = "maggot", image="terrain/maggot/maggotwall_37d_1.png"}}, min=1, max=1},

	default4={add_displays={{shader = "maggot", image="terrain/maggot/maggot_ver_edge_left_01.png", display_x=-1}}, min=1, max=1},
	default6={add_displays={{shader = "maggot", image="terrain/maggot/maggot_ver_edge_right_01.png", display_x=1}}, min=1, max=1},
}

_M.generic_borders_defs.godfeaster = { method="walls", type="godfeaster", forbid={}, use_type=true, extended=true, consider_diagonal_doors=true,
	default8={add_displays={{shader = "godfeaster", image="terrain/godfeaster/godfeasterwall_8_%d.png", display_y=-1, z=16}}, min=1, max=2},
	default8p={add_displays={{shader = "godfeaster", image="terrain/godfeaster/godfeaster_V3_pillar_top_01.png", display_y=-1, z=16}}, min=1, max=1},
	default7={add_displays={{shader = "godfeaster", image="terrain/godfeaster/godfeaster_V3_inner_7_01.png", display_y=-1, z=16}}, min=1, max=1},
	default9={add_displays={{shader = "godfeaster", image="terrain/godfeaster/godfeaster_V3_inner_9_01.png", display_y=-1, z=16}}, min=1, max=1},
	default7i={add_displays={{shader = "godfeaster", image="terrain/godfeaster/godfeaster_V3_3_01.png", display_y=-1, z=16}}, min=1, max=1},
	default8i={add_displays={{shader = "godfeaster", image="terrain/godfeaster/godfeasterwall_8h_1.png", display_y=-1, z=16}}, min=1, max=1},
	default9i={add_displays={{shader = "godfeaster", image="terrain/godfeaster/godfeaster_V3_1_01.png", display_y=-1, z=16}}, min=1, max=1},
	default73i={add_displays={{shader = "godfeaster", image="terrain/godfeaster/godfeasterwall_91d_1.png", display_y=-1, z=16}}, min=1, max=1},
	default91i={add_displays={{shader = "godfeaster", image="terrain/godfeaster/godfeasterwall_73d_1.png", display_y=-1, z=16}}, min=1, max=1},

	default2={image="terrain/godfeaster/godfeaster_floor_1_01.png", add_mos={{shader = "godfeaster", image="terrain/godfeaster/godfeaster_V3_8_0%d.png"}}, min=1, max=5},
	default2p={image="terrain/godfeaster/godfeaster_floor_1_01.png", add_mos={{shader = "godfeaster", image="terrain/godfeaster/godfeaster_V3_pillar_bottom_01.png"}}, min=1, max=1},
	default1={image="terrain/godfeaster/godfeaster_floor_1_01.png", add_mos={{shader = "godfeaster", image="terrain/godfeaster/godfeaster_V3_inner_1_01.png"}}, min=1, max=1},
	default3={image="terrain/godfeaster/godfeaster_floor_1_01.png", add_mos={{shader = "godfeaster", image="terrain/godfeaster/godfeaster_V3_inner_3_01.png"}}, min=1, max=1},
	default1i={image="terrain/godfeaster/godfeaster_floor_1_01.png", add_mos={{shader = "godfeaster", image="terrain/godfeaster/godfeaster_V3_7_01.png"}}, min=1, max=1},
	default2i={image="terrain/godfeaster/godfeaster_floor_1_01.png", add_mos={{shader = "godfeaster", image="terrain/godfeaster/godfeasterwall_2h_1.png"}}, min=1, max=1},
	default3i={image="terrain/godfeaster/godfeaster_floor_1_01.png", add_mos={{shader = "godfeaster", image="terrain/godfeaster/godfeaster_V3_9_01.png"}}, min=1, max=1},
	default19i={image="terrain/godfeaster/godfeaster_floor_1_01.png", add_mos={{shader = "godfeaster", image="terrain/godfeaster/godfeasterwall_19d_1.png"}}, min=1, max=1},
	default37i={image="terrain/godfeaster/godfeaster_floor_1_01.png", add_mos={{shader = "godfeaster", image="terrain/godfeaster/godfeasterwall_37d_1.png"}}, min=1, max=1},

	default4={add_displays={{shader = "godfeaster", image="terrain/godfeaster/godfeaster_ver_edge_left_01.png", display_x=-1}}, min=1, max=1},
	default6={add_displays={{shader = "godfeaster", image="terrain/godfeaster/godfeaster_ver_edge_right_01.png", display_x=1}}, min=1, max=1},
}

_M.generic_borders_defs.slimy_godfeaster = { method="walls", type="slimy_godfeaster", forbid={}, use_type=true, extended=true, consider_diagonal_doors=true,
	default8={add_displays={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeasterwall_8_%d.png", display_y=-1, z=16}}, min=1, max=2},
	default8p={add_displays={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeaster_V3_pillar_top_01.png", display_y=-1, z=16}}, min=1, max=1},
	default7={add_displays={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeaster_V3_inner_7_01.png", display_y=-1, z=16}}, min=1, max=1},
	default9={add_displays={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeaster_V3_inner_9_01.png", display_y=-1, z=16}}, min=1, max=1},
	default7i={add_displays={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeaster_V3_3_01.png", display_y=-1, z=16}}, min=1, max=1},
	default8i={add_displays={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeasterwall_8h_1.png", display_y=-1, z=16}}, min=1, max=1},
	default9i={add_displays={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeaster_V3_1_01.png", display_y=-1, z=16}}, min=1, max=1},
	default73i={add_displays={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeasterwall_91d_1.png", display_y=-1, z=16}}, min=1, max=1},
	default91i={add_displays={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeasterwall_73d_1.png", display_y=-1, z=16}}, min=1, max=1},

	default2={image="terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_mos={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeaster_V3_8_0%d.png"}}, min=1, max=5},
	default2p={image="terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_mos={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeaster_V3_pillar_bottom_01.png"}}, min=1, max=1},
	default1={image="terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_mos={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeaster_V3_inner_1_01.png"}}, min=1, max=1},
	default3={image="terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_mos={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeaster_V3_inner_3_01.png"}}, min=1, max=1},
	default1i={image="terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_mos={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeaster_V3_7_01.png"}}, min=1, max=1},
	default2i={image="terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_mos={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeasterwall_2h_1.png"}}, min=1, max=1},
	default3i={image="terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_mos={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeaster_V3_9_01.png"}}, min=1, max=1},
	default19i={image="terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_mos={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeasterwall_19d_1.png"}}, min=1, max=1},
	default37i={image="terrain/slimy_godfeaster/slimy_godfeaster_floor_1_01.png", add_mos={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeasterwall_37d_1.png"}}, min=1, max=1},

	default4={add_displays={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeaster_ver_edge_left_01.png", display_x=-1}}, min=1, max=1},
	default6={add_displays={{shader = "godfeaster", image="terrain/slimy_godfeaster/slimy_godfeaster_ver_edge_right_01.png", display_x=1}}, min=1, max=1},
}

_M.generic_borders_defs.kroshkkurcavefloor = { method="borders", type="cave", forbid={lava=true, rock=true, dark_grass=true},
	default8={add_mos={{image="terrain/fortress-ancient/cavefloor_cracks_outer_8_%d.png", display_y=-1}}, min=1, max=3},
	default2={add_mos={{image="terrain/fortress-ancient/cavefloor_cracks_outer_2_%d.png", display_y=1}}, min=1, max=3},
	default4={add_mos={{image="terrain/fortress-ancient/cavefloor_cracks_outer_4_%d.png", display_x=-1}}, min=1, max=3},
	default6={add_mos={{image="terrain/fortress-ancient/cavefloor_cracks_outer_6_%d.png", display_x=1}}, min=1, max=3},

	default1={add_mos={{image="terrain/fortress-ancient/cavefloor_cracks_inner_1_%d.png", display_x=-1, display_y=1}}, min=1, max=3},
	default3={add_mos={{image="terrain/fortress-ancient/cavefloor_cracks_inner_3_%d.png", display_x=1, display_y=1}}, min=1, max=3},
	default7={add_mos={{image="terrain/fortress-ancient/cavefloor_cracks_inner_7_%d.png", display_x=-1, display_y=-1}}, min=1, max=3},
	default9={add_mos={{image="terrain/fortress-ancient/cavefloor_cracks_inner_9_%d.png", display_x=1, display_y=-1}}, min=1, max=3},

	default1i={add_mos={{image="terrain/fortress-ancient/cavefloor_cracks_outer_1_%d.png", display_x=-1, display_y=1}}, min=1, max=3},
	default3i={add_mos={{image="terrain/fortress-ancient/cavefloor_cracks_outer_3_%d.png", display_x=1, display_y=1}}, min=1, max=3},
	default7i={add_mos={{image="terrain/fortress-ancient/cavefloor_cracks_outer_7_%d.png", display_x=-1, display_y=-1}}, min=1, max=3},
	default9i={add_mos={{image="terrain/fortress-ancient/cavefloor_cracks_outer_9_%d.png", display_x=1, display_y=-1}}, min=1, max=3},
}

_M.generic_borders_defs.kroshkkurcavewall = { method="walls", type="kroshkkurcavewall", forbid={}, extended=true,
	default8={add_displays={{image="terrain/cave/cavewall_8_1.png", display_y=-1, z=16}}, min=1, max=1},
	default8p={add_displays={{image="terrain/cave/cave_V3_pillar_top_01.png", display_y=-1, z=16}}, min=1, max=1},
	default7={add_displays={{image="terrain/cave/cave_V3_inner_7_01.png", display_y=-1, z=16}}, min=1, max=1},
	default9={add_displays={{image="terrain/cave/cave_V3_inner_9_01.png", display_y=-1, z=16}}, min=1, max=1},
	default7i={add_displays={{image="terrain/cave/cave_V3_3_01.png", display_y=-1, z=16}}, min=1, max=1},
	default8i={add_displays={{image="terrain/cave/cavewall_8h_1.png", display_y=-1, z=16}}, min=1, max=1},
	default9i={add_displays={{image="terrain/cave/cave_V3_1_01.png", display_y=-1, z=16}}, min=1, max=1},
	default73i={add_displays={{image="terrain/cave/cavewall_91d_1.png", display_y=-1, z=16}}, min=1, max=1},
	default91i={add_displays={{image="terrain/cave/cavewall_73d_1.png", display_y=-1, z=16}}, min=1, max=1},

	default2={image="terrain/cave/cave_V3_8_0%d.png", min=1, max=3},
	default2p={image="terrain/cave/cave_floor_1_01.png", add_mos={{image="terrain/cave/cave_V3_pillar_bottom_01.png"}}, min=1, max=1},
	default1={image="terrain/cave/cave_floor_1_01.png", add_mos={{image="terrain/cave/cave_V3_inner_1_01.png"}}, min=1, max=1},
	default3={image="terrain/cave/cave_floor_1_01.png", add_mos={{image="terrain/cave/cave_V3_inner_3_01.png"}}, min=1, max=1},
	default1i={image="terrain/cave/cave_V3_7_01.png", min=1, max=1},
	default2i={image="terrain/cave/cavewall_2h_1.png", min=1, max=1},
	default3i={image="terrain/cave/cave_V3_9_01.png", min=1, max=1},
	default19i={image="terrain/cave/cavewall_19d_1.png", min=1, max=1},
	default37i={image="terrain/cave/cavewall_37d_1.png", min=1, max=1},

	default4={add_displays={{image="terrain/cave/cave_ver_edge_left_01.png", display_x=-1}}, min=1, max=1},
	default6={add_displays={{image="terrain/cave/cave_ver_edge_right_01.png", display_x=1}}, min=1, max=1},

	transit = { type = "cave", forbid={},
		default8={add_displays={{image="terrain/fortress-ancient/cavewall_cracks_outer_8_%d.png", display_y=-1, z=17}}, min=1, max=3},
		-- default8p={add_displays={{image="terrain/fortress-ancient/cavewall_cracks_cave_V3_pillar_top_01.png", display_y=-1, z=17}}, min=1, max=1},
		default7={add_displays={{image="terrain/fortress-ancient/cave_cracks_outer_V3_3_%d.png", display_y=-1, z=17}}, min=1, max=1},
		default9={add_displays={{image="terrain/fortress-ancient/cave_cracks_outer_V3_1_%d.png", display_y=-1, z=17}}, min=1, max=1},
		default7i={add_displays={{image="terrain/fortress-ancient/cave_cracks_outer_V3_7_01.png", display_y=-1, z=17}}, min=1, max=1},
		default8i={add_displays={{image="terrain/fortress-ancient/cavewall_cracks_cavewall_8h_1.png", display_y=-1, z=17}}, min=1, max=1},
		default9i={add_displays={{image="terrain/fortress-ancient/cavewall_cracks_cave_V3_1_01.png", display_y=-1, z=17}}, min=1, max=1},
		default73i={add_displays={{image="terrain/fortress-ancient/cavewall_cracks_cavewall_91d_1.png", display_y=-1, z=17}}, min=1, max=1},
		default91i={add_displays={{image="terrain/fortress-ancient/cavewall_cracks_cavewall_73d_1.png", display_y=-1, z=17}}, min=1, max=1},

		default2={add_displays={{image="terrain/fortress-ancient/cavewall_cracks_outer_2_%d.png", z=16}}, min=1, max=3},
		-- default2p={image="terrain/fortress-ancient/cavewall_cracks_cave_floor_1_01.png", add_mos={{image="terrain/cave/cave_V3_pillar_bottom_01.png"}}, min=1, max=1},
		default1={add_displays={{image="terrain/cave/cavewall_cracks_cave_V3_inner_9_%d", z=16}}, min=1, max=1},
		default3={add_displays={{image="terrain/cave/cavewall_cracks_cave_V3_inner_7_%d", z=16}}, min=1, max=1},
		default1i={add_displays={{image="terrain/fortress-ancient/cavewall_cracks_cave_V3_7_01.png", z=16}}, min=1, max=1},
		default2i={add_displays={{image="terrain/fortress-ancient/cavewall_cracks_cavewall_2h_1.png", z=16}}, min=1, max=1},
		default3i={add_displays={{image="terrain/fortress-ancient/cave_cracks_outer_V3_9_01.png", z=16}}, min=1, max=1},
		default19i={add_displays={{image="terrain/fortress-ancient/cavewall_cracks_cavewall_19d_1.png", z=16}}, min=1, max=1},
		default37i={add_displays={{image="terrain/fortress-ancient/cavewall_cracks_cavewall_37d_1.png", z=16}}, min=1, max=1},

		default4={add_displays={{image="terrain/fortress-ancient/cavewall_cracks_outer_4_%d.png", display_x=-1}}, min=1, max=3},
		default6={add_displays={{image="terrain/fortress-ancient/cavewall_cracks_outer_6_%d.png", display_x=1}}, min=1, max=3},
	},
}

_M.generic_roads_defs.maggot_spine = { method="road", marker="road",
	default82={add_mos={{image="terrain/spinal_cord/spinal_cord_vertical_top_a_%02d.png"}}, min=1, max=5},
	default46={add_mos={{image="terrain/spinal_cord/spinal_cord_horizontal_top_a_%02d.png"}}, min=1, max=5},

	-- default8246={add_mos={{image="terrain/spinal_cord/spinal_cord_cross_a_%02d.png"}}, min=1, max=1},

	-- default846={add_mos={{image="terrain/spinal_cord/spinal_cord_t_section_c_%02d.png"}}, min=1, max=1},
	-- default246={add_mos={{image="terrain/spinal_cord/spinal_cord_t_section_a_%02d.png"}}, min=1, max=1},
	-- default824={add_mos={{image="terrain/spinal_cord/spinal_cord_t_section_b_%02d.png"}}, min=1, max=1},
	-- default826={add_mos={{image="terrain/spinal_cord/spinal_cord_t_section_d_%02d.png"}}, min=1, max=1},

	default84={add_mos={{image="terrain/spinal_cord/spinal_cord_turn_c_%02d.png"}}, min=1, max=1},
	default86={add_mos={{image="terrain/spinal_cord/spinal_cord_turn_d_%02d.png"}}, min=1, max=1},
	default26={add_mos={{image="terrain/spinal_cord/spinal_cord_turn_a_%02d.png"}}, min=1, max=1},
	default24={add_mos={{image="terrain/spinal_cord/spinal_cord_turn_b_%02d.png"}}, min=1, max=1},

	default4={add_mos={{image="terrain/spinal_cord/spinal_cord_end_a_02.png"}}, min=1, max=1},
	default6={add_mos={{image="terrain/spinal_cord/spinal_cord_end_a_01.png"}}, min=1, max=1},
	default2={add_mos={{image="terrain/spinal_cord/spinal_cord_end_a_03.png"}}, min=1, max=1},
	default8={add_mos={{image="terrain/spinal_cord/spinal_cord_end_a_04.png"}}, min=1, max=1},
}

function _M:editTileKroshkkurCaveWalls(level, i, j, g, nt, type)
	local g5 = (level.map:checkEntity(i, j,   Map.TERRAIN, "type") or "wall").."/"..(level.map:checkEntity(i, j,   Map.TERRAIN, "subtype") or "cave")
	local g8 = (level.map:checkEntity(i, j-1, Map.TERRAIN, "type") or "wall").."/"..(level.map:checkEntity(i, j-1, Map.TERRAIN, "subtype") or "cave")
	local g2 = (level.map:checkEntity(i, j+1, Map.TERRAIN, "type") or "wall").."/"..(level.map:checkEntity(i, j+1, Map.TERRAIN, "subtype") or "cave")
	local g4 = (level.map:checkEntity(i-1, j, Map.TERRAIN, "type") or "wall").."/"..(level.map:checkEntity(i-1, j, Map.TERRAIN, "subtype") or "cave")
	local g6 = (level.map:checkEntity(i+1, j, Map.TERRAIN, "type") or "wall").."/"..(level.map:checkEntity(i+1, j, Map.TERRAIN, "subtype") or "cave")
	local g7 = (level.map:checkEntity(i-1, j-1, Map.TERRAIN, "type") or "wall").."/"..(level.map:checkEntity(i-1, j-1, Map.TERRAIN, "subtype") or "cave")
	local g9 = (level.map:checkEntity(i+1, j-1, Map.TERRAIN, "type") or "wall").."/"..(level.map:checkEntity(i+1, j-1, Map.TERRAIN, "subtype") or "cave")
	local g1 = (level.map:checkEntity(i-1, j+1, Map.TERRAIN, "type") or "wall").."/"..(level.map:checkEntity(i-1, j+1, Map.TERRAIN, "subtype") or "cave")
	local g3 = (level.map:checkEntity(i+1, j+1, Map.TERRAIN, "type") or "wall").."/"..(level.map:checkEntity(i+1, j+1, Map.TERRAIN, "subtype") or "cave")
	local og8, og2, og4, og6, og7, og9, og1, og3 = g8, g2, g4, g6, g7, g9, g1, g3
	local g2d = level.map:checkEntity(i, j+1, Map.TERRAIN, "is_door")
	local g7d = nil
	local g1d = nil
	local g3d = nil
	local g9d = nil
	if g2d then g2 = "floor" end
	if nt.consider_diagonal_doors then
		g7d = level.map:checkEntity(i-1, j-1, Map.TERRAIN, "is_door")
		g1d = level.map:checkEntity(i-1, j+1, Map.TERRAIN, "is_door")
		g3d = level.map:checkEntity(i+1, j+1, Map.TERRAIN, "is_door")
		g9d = level.map:checkEntity(i+1, j-1, Map.TERRAIN, "is_door")

		if g7d then g7 = "floor" end
		if g9d then g9 = "floor" end
		if g3d then g3 = "floor" end
		if g1d then g1 = "floor" end
	end
	if nt.forbid then
		if nt.forbid[g5] then g5 = type end
		if nt.forbid[g4] then g4 = type end
		if nt.forbid[g6] then g6 = type end
		if nt.forbid[g8] then g8 = type end
		if nt.forbid[g2] then g2 = type end
		if nt.forbid[g1] then g1 = type end
		if nt.forbid[g3] then g3 = type end
		if nt.forbid[g7] then g7 = type end
		if nt.forbid[g9] then g9 = type end
	end

	if g4 == "wall/ancient" then g4 = "wall/cave" end
	if g6 == "wall/ancient" then g6 = "wall/cave" end
	if g8 == "wall/ancient" then g8 = "wall/cave" end
	if g2 == "wall/ancient" then g2 = "wall/cave" end
	if g1 == "wall/ancient" then g1 = "wall/cave" end
	if g3 == "wall/ancient" then g3 = "wall/cave" end
	if g7 == "wall/ancient" then g7 = "wall/cave" end
	if g9 == "wall/ancient" then g9 = "wall/cave" end

	local id = rng.range(1,NB_VARIATIONS).."sandwall:"..table.concat({g.define_as or "--",type,tostring(g1==g5),tostring(g2==g5),tostring(g3==g5),tostring(g4==g5),tostring(g5==g5),tostring(g6==g5),tostring(g7==g5),tostring(g8==g5),tostring(g9==g5)}, ",")
	-- Sides
	if     g5 ~= g8 and g5 ~= g7 and g5 ~= g9 then
		if     g5 ~= g4 and g5 ~= g6 then self:edit(i, j, id, nt[g8.."8p"] or nt["default8p"])
		elseif g5 == g4 and g5 == g6 then self:edit(i, j, id, nt[g8.."8"] or nt["default8"])
		elseif g5 ~= g4 and g5 == g6 then self:edit(i, j, id, nt[g7.."7"] or nt["default7"])
		elseif g5 == g4 and g5 ~= g6 then self:edit(i, j, id, nt[g9.."9"] or nt["default9"])
		end
	elseif g5 ~= g8 and g5 ~= g7 and g5 == g9 then
		if     g5 == g4 then self:edit(i, j, id, nt[g7.."7i"] or nt["default7i"])
		elseif g5 ~= g4 then self:edit(i, j, id, nt[g7.."73i"] or nt["default73i"])
		end
	elseif g5 ~= g8 and g5 == g7 and g5 ~= g9 then
		if     g5 == g6 then self:edit(i, j, id, nt[g9.."9i"] or nt["default9i"])
		elseif g5 ~= g6 then self:edit(i, j, id, nt[g9.."91i"] or nt["default91i"])
		end
	elseif g5 ~= g8 and g5 == g7 and g5 == g9 then self:edit(i, j, id, nt[g8.."8i"] or nt["default8i"])
	end

	if     g5 ~= g2 and g5 ~= g1 and g5 ~= g3 then
		if     g5 ~= g4 and g5 ~= g6 then self:edit(i, j, id, nt[g2.."2p"] or nt["default2p"])
		elseif g5 == g4 and g5 == g6 then self:edit(i, j, id, nt[g2.."2"] or nt["default2"])
		elseif g5 ~= g4 and g5 == g6 then self:edit(i, j, id, nt[g1.."1"] or nt["default1"])
		elseif g5 == g4 and g5 ~= g6 then self:edit(i, j, id, nt[g3.."3"] or nt["default3"])
		end
	elseif g5 ~= g2 and g5 ~= g1 and g5 == g3 then
		if     g5 == g4 then self:edit(i, j, id, nt[g3.."3i"] or nt["default3i"])
		elseif g5 ~= g4 then self:edit(i, j, id, nt[g3.."37i"] or nt["default37i"])
		end
	elseif g5 ~= g2 and g5 == g1 and g5 ~= g3 then
		if     g5 == g6 then self:edit(i, j, id, nt[g1.."1i"] or nt["default1i"])
		elseif g5 ~= g6 then self:edit(i, j, id, nt[g1.."19i"] or nt["default19i"])
		end
	elseif g5 ~= g2 and g5 == g1 and g5 == g3 then self:edit(i, j, id, nt[g2.."2i"] or nt["default2i"])
	end

	if     g5 ~= g4 and g5 == g2 and g5 ~= g1 then self:edit(i, j, id, nt[g4.."4"] or nt["default4"]) end
	if     g5 ~= g6 and g5 == g2 and g5 ~= g3 then self:edit(i, j, id, nt[g6.."6"] or nt["default6"]) end

	g8, g2, g4, g6, g7, g9, g1, g3 = og8, og2, og4, og6, og7, og9, og1, og3
	if nt.transit then
		self:editTileGenericBorders(level, i, j, g, nt.transit, nt.transit.type)
	end
end

function _M:editTileKroshkkurCaveWalls_def(level, i, j, g, nt)
	self:editTileKroshkkurCaveWalls(level, i, j, g, _M.generic_borders_defs[nt.def], _M.generic_borders_defs[nt.def].type or "grass")
end

--- Make walls have a pseudo 3D effect
function _M:niceTileWall3dKroshkkur(level, i, j, g, nt)
	local s = (level.map:checkEntity(i, j, Map.TERRAIN, "type") or "wall").."/"..(level.map:checkEntity(i, j, Map.TERRAIN, "subtype") or "floor")
	local gn = (level.map:checkEntity(i, j-1, Map.TERRAIN, "type") or "wall").."/"..(level.map:checkEntity(i, j-1, Map.TERRAIN, "subtype") or "floor")
	local gs = (level.map:checkEntity(i, j+1, Map.TERRAIN, "type") or "wall").."/"..(level.map:checkEntity(i, j+1, Map.TERRAIN, "subtype") or "floor")
	local gw = (level.map:checkEntity(i-1, j, Map.TERRAIN, "type") or "wall").."/"..(level.map:checkEntity(i-1, j, Map.TERRAIN, "subtype") or "floor")
	local ge = (level.map:checkEntity(i+1, j, Map.TERRAIN, "type") or "wall").."/"..(level.map:checkEntity(i+1, j, Map.TERRAIN, "subtype") or "floor")
	local dn = level.map:checkEntity(i, j-1, Map.TERRAIN, "is_door")
	local ds = level.map:checkEntity(i, j+1, Map.TERRAIN, "is_door")

	if gn == "wall/cave" then gn = "wall/ancient" end
	if gs == "wall/cave" then gs = "wall/ancient" end
	if ge == "wall/cave" then ge = "wall/ancient" end
	if gw == "wall/cave" then gw = "wall/ancient" end

	if gs ~= s and gn ~= s and gw ~= s and ge ~= s then self:replace(i, j, self:getTile(nt.small_pillar))
	elseif gs ~= s and gn ~= s and gw ~= s and ge == s then self:replace(i, j, self:getTile(nt.pillar_4))
	elseif gs ~= s and gn ~= s and gw == s and ge ~= s then self:replace(i, j, self:getTile(nt.pillar_6))
	elseif gs == s and gn ~= s and gw ~= s and ge ~= s then self:replace(i, j, self:getTile(nt.pillar_8))
	elseif gs ~= s and gn == s and gw ~= s and ge ~= s then self:replace(i, j, self:getTile(nt.pillar_2))
	elseif gs ~= s and gn ~= s then self:replace(i, j, self:getTile(nt.north_south))
	elseif gs == s and ds and gn ~= s then self:replace(i, j, self:getTile(nt.north_south))
	elseif gs ~= s and gn == s and dn then self:replace(i, j, self:getTile(nt.north_south))
	elseif gs ~= s then self:replace(i, j, self:getTile(nt.south))
	elseif gs == s and ds then self:replace(i, j, self:getTile(nt.south))
	elseif gn ~= s then self:replace(i, j, self:getTile(nt.north))
	elseif gn == s and dn then self:replace(i, j, self:getTile(nt.north))
	elseif nt.inner then self:replace(i, j, self:getTile(nt.inner))
	end
end

--- Randomize tiles
function _M:niceTileReplaceSpaceDwarf(level, i, j, g, nt)
	local ii = i + math.floor(math.cos(j / 7 * math.pi))
	local jj = j + math.floor(math.sin(i / 7 * math.pi))
	local nb = ((jj+ii) % nt.octaves) + 1
	-- local jj = j + math.floor(math.sin(i / 7 * math.pi))
	-- local nb = (jj % nt.octaves) + 1
	self:replace(i, j, self:getTile(nt.base..nb))
end

return _M
