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

local _M = loadPrevious(...)

_M.generic_borders_defs.snow_mountain = { method="borders", type="snow_mountain", forbid={}, use_type=true,
	default8={z=3, copy_base=true, add_displays={{image="terrain/snow_mountains/snow_mountain8.png", display_y=-1, z=16}}, min=1, max=1},
	default2={z=3, copy_base=true, add_mos={{image="terrain/snow_mountains/snow_mountain2.png", display_y=1}}, min=1, max=1},
	default4={z=3, copy_base=true, add_mos={{image="terrain/snow_mountains/snow_mountain4.png", display_x=-1}}, min=1, max=1},
	default6={z=3, copy_base=true, add_mos={{image="terrain/snow_mountains/snow_mountain6.png", display_x=1}}, min=1, max=1},

	default1={z=3, copy_base=true, add_mos={{image="terrain/snow_mountains/snow_mountain9i.png", display_x=-1, display_y=1}}, min=1, max=1},
	default3={z=3, copy_base=true, add_mos={{image="terrain/snow_mountains/snow_mountain7i.png", display_x=1, display_y=1}}, min=1, max=1},
	default7={z=3, copy_base=true, add_mos={{image="terrain/snow_mountains/snow_mountain3i.png", display_x=-1, display_y=-1}}, min=1, max=1},
	default9={z=3, copy_base=true, add_mos={{image="terrain/snow_mountains/snow_mountain1i.png", display_x=1, display_y=-1}}, min=1, max=1},

	default1i={z=3, copy_base=true, add_mos={{image="terrain/snow_mountains/snow_mountain1.png", display_x=-1, display_y=1}}, min=1, max=1},
	default3i={z=3, copy_base=true, add_mos={{image="terrain/snow_mountains/snow_mountain3.png", display_x=1, display_y=1}}, min=1, max=1},
	default7i={z=3, copy_base=true, add_displays={{image="terrain/snow_mountains/snow_mountain7.png", display_x=-1, display_y=-1, z=17}}, min=1, max=1},
	default9i={z=3, copy_base=true, add_displays={{image="terrain/snow_mountains/snow_mountain9.png", display_x=1, display_y=-1, z=18}}, min=1, max=1},
}

_M.generic_borders_defs.mech = { method="walls", type="mech", forbid={}, use_type=true, extended=true,
	default8={add_displays={{image="terrain/mechwall/mechwall_8_1.png", display_y=-1, z=16}}, min=1, max=1},
	default8p={add_displays={{image="terrain/mechwall/mech_V3_pillar_top_%02d.png", display_y=-1, z=16}}, min=1, max=5},
	default7={add_displays={{image="terrain/mechwall/mech_V3_inner_7_01.png", display_y=-1, z=16}}, min=1, max=1},
	default9={add_displays={{image="terrain/mechwall/mech_V3_inner_9_01.png", display_y=-1, z=16}}, min=1, max=1},
	default7i={add_displays={{image="terrain/mechwall/mech_V3_3_01.png", display_y=-1, z=16}}, min=1, max=1},
	default8i={add_displays={{image="terrain/mechwall/mechwall_8h_1.png", display_y=-1, z=16}}, min=1, max=1},
	default9i={add_displays={{image="terrain/mechwall/mech_V3_1_01.png", display_y=-1, z=16}}, min=1, max=1},
	default73i={add_displays={{image="terrain/mechwall/mechwall_91d_1.png", display_y=-1, z=16}}, min=1, max=1},
	default91i={add_displays={{image="terrain/mechwall/mechwall_73d_1.png", display_y=-1, z=16}}, min=1, max=1},

	default2={image="terrain/mechwall/mech_V3_8_%02d.png", min=1, max=18},
	default2p={image="terrain/mechwall/mech_floor_1_01.png", add_mos={{image="terrain/mechwall/mech_V3_pillar_bottom_%02d.png"}}, min=1, max=9},
	default1={image="terrain/mechwall/mech_floor_1_01.png", add_mos={{image="terrain/mechwall/mech_V3_inner_1_01.png"}}, min=1, max=1},
	default3={image="terrain/mechwall/mech_floor_1_01.png", add_mos={{image="terrain/mechwall/mech_V3_inner_3_01.png"}}, min=1, max=1},
	default1i={image="terrain/mechwall/mech_V3_7_01.png", min=1, max=1},
	default2i={image="terrain/mechwall/mechwall_2h_1.png", min=1, max=1},
	default3i={image="terrain/mechwall/mech_V3_9_01.png", min=1, max=1},
	default19i={image="terrain/mechwall/mechwall_19d_1.png", min=1, max=1},
	default37i={image="terrain/mechwall/mechwall_37d_1.png", min=1, max=1},

	default4={add_displays={{image="terrain/mechwall/mech_ver_edge_left_01.png", display_x=-1}}, min=1, max=1},
	default6={add_displays={{image="terrain/mechwall/mech_ver_edge_right_01.png", display_x=1}}, min=1, max=1},
}

_M.generic_borders_defs.mechstone = { method="walls", type="mechstone", forbid={}, use_type=true, extended=true,
	default8={add_displays={{image="terrain/mechstone/mech_stonewall_8_1.png", display_y=-1, z=16}}, min=1, max=1},
	default8p={add_displays={{image="terrain/mechstone/mech_stone_V3_pillar_top_%02d.png", display_y=-1, z=16}}, min=1, max=1},
	default7={add_displays={{image="terrain/mechstone/mech_stone_V3_inner_7_01.png", display_y=-1, z=16}}, min=1, max=1},
	default9={add_displays={{image="terrain/mechstone/mech_stone_V3_inner_9_01.png", display_y=-1, z=16}}, min=1, max=1},
	default7i={add_displays={{image="terrain/mechstone/mech_stone_V3_3_01.png", display_y=-1, z=16}}, min=1, max=1},
	default8i={add_displays={{image="terrain/mechstone/mech_stonewall_8h_1.png", display_y=-1, z=16}}, min=1, max=1},
	default9i={add_displays={{image="terrain/mechstone/mech_stone_V3_1_01.png", display_y=-1, z=16}}, min=1, max=1},
	default73i={add_displays={{image="terrain/mechstone/mech_stonewall_91d_1.png", display_y=-1, z=16}}, min=1, max=1},
	default91i={add_displays={{image="terrain/mechstone/mech_stonewall_73d_1.png", display_y=-1, z=16}}, min=1, max=1},

	default2={image="terrain/mechstone/mech_stone_V3_8_%02d.png", min=1, max=14},
	default2p={image="terrain/mechstone/mech_stone_floor_1_01.png", add_mos={{image="terrain/mechstone/mech_stone_V3_pillar_bottom_%02d.png"}}, min=1, max=7},
	default1={image="terrain/mechstone/mech_stone_floor_1_01.png", add_mos={{image="terrain/mechstone/mech_stone_V3_inner_1_01.png"}}, min=1, max=1},
	default3={image="terrain/mechstone/mech_stone_floor_1_01.png", add_mos={{image="terrain/mechstone/mech_stone_V3_inner_3_01.png"}}, min=1, max=1},
	default1i={image="terrain/mechstone/mech_stone_V3_7_01.png", min=1, max=1},
	default2i={image="terrain/mechstone/mech_stonewall_2h_1.png", min=1, max=1},
	default3i={image="terrain/mechstone/mech_stone_V3_9_01.png", min=1, max=1},
	default19i={image="terrain/mechstone/mech_stonewall_19d_1.png", min=1, max=1},
	default37i={image="terrain/mechstone/mech_stonewall_37d_1.png", min=1, max=1},

	default4={add_displays={{image="terrain/mechstone/mech_stone_ver_edge_left_01.png", display_x=-1}}, min=1, max=1},
	default6={add_displays={{image="terrain/mechstone/mech_stone_ver_edge_right_01.png", display_x=1}}, min=1, max=1},
}

_M.generic_borders_defs.primal_trunk = { method="borders", type="primal trunk", forbid={lava=true, rock=true},
	default8={add_mos={{image="terrain/primal_trunk/primal_forest_2_%02d.png", display_y=-1}}, min=1, max=4},
	default2={add_mos={{image="terrain/primal_trunk/primal_forest_8_%02d.png", display_y=1}}, min=1, max=4},
	default4={add_mos={{image="terrain/primal_trunk/primal_forest_6_%02d.png", display_x=-1}}, min=1, max=4},
	default6={add_mos={{image="terrain/primal_trunk/primal_forest_4_%02d.png", display_x=1}}, min=1, max=4},

	default1={add_mos={{image="terrain/primal_trunk/primal_forest_9_%02d.png", display_x=-1, display_y=1}}, min=1, max=1},
	default3={add_mos={{image="terrain/primal_trunk/primal_forest_7_%02d.png", display_x=1, display_y=1}}, min=1, max=1},
	default7={add_mos={{image="terrain/primal_trunk/primal_forest_3_%02d.png", display_x=-1, display_y=-1}}, min=1, max=1},
	default9={add_mos={{image="terrain/primal_trunk/primal_forest_1_%02d.png", display_x=1, display_y=-1}}, min=1, max=1},

	default1i={add_mos={{image="terrain/primal_trunk/primal_forest_inner_1_%02d.png", display_x=-1, display_y=1}}, min=1, max=4},
	default3i={add_mos={{image="terrain/primal_trunk/primal_forest_inner_3_%02d.png", display_x=1, display_y=1}}, min=1, max=4},
	default7i={add_mos={{image="terrain/primal_trunk/primal_forest_inner_7_%02d.png", display_x=-1, display_y=-1}}, min=1, max=4},
	default9i={add_mos={{image="terrain/primal_trunk/primal_forest_inner_9_%02d.png", display_x=1, display_y=-1}}, min=1, max=4},
}

_M.generic_borders_defs.corruptedcavewall = { method="walls", type="corruptedcavewall", forbid={}, use_type=true, extended=true, consider_diagonal_doors=true,
	default8={add_displays={{image="terrain/slumbering_cave/slumbering_cavewall_8_%d.png", display_y=-1, z=16}}, min=1, max=1},
	default8p={add_displays={{image="terrain/slumbering_cave/slumbering_cave_V3_pillar_top_0%d.png", display_y=-1, z=16}}, min=1, max=1},
	default7={add_displays={{image="terrain/slumbering_cave/slumbering_cave_V3_inner_7_01.png", display_y=-1, z=16}}, min=1, max=1},
	default9={add_displays={{image="terrain/slumbering_cave/slumbering_cave_V3_inner_9_01.png", display_y=-1, z=16}}, min=1, max=1},
	default7i={add_displays={{image="terrain/slumbering_cave/slumbering_cave_V3_3_01.png", display_y=-1, z=16}}, min=1, max=1},
	default8i={add_displays={{image="terrain/slumbering_cave/slumbering_cavewall_8h_1.png", display_y=-1, z=16}}, min=1, max=1},
	default9i={add_displays={{image="terrain/slumbering_cave/slumbering_cave_V3_1_01.png", display_y=-1, z=16}}, min=1, max=1},
	default73i={add_displays={{image="terrain/slumbering_cave/slumbering_cavewall_91d_1.png", display_y=-1, z=16}}, min=1, max=1},
	default91i={add_displays={{image="terrain/slumbering_cave/slumbering_cavewall_73d_1.png", display_y=-1, z=16}}, min=1, max=1},

	default2={image="terrain/slumbering_cave/slumbering_cave_floor_1_01.png", add_mos={{image="terrain/slumbering_cave/slumbering_cave_V3_8_0%d.png"}}, min=1, max=7},
	default2p={image="terrain/slumbering_cave/slumbering_cave_floor_1_01.png", add_mos={{image="terrain/slumbering_cave/slumbering_cave_V3_pillar_bottom_0%d.png"}}, min=1, max=2},
	default1={image="terrain/slumbering_cave/slumbering_cave_floor_1_01.png", add_mos={{image="terrain/slumbering_cave/slumbering_cave_V3_inner_1_01.png"}}, min=1, max=1},
	default3={image="terrain/slumbering_cave/slumbering_cave_floor_1_01.png", add_mos={{image="terrain/slumbering_cave/slumbering_cave_V3_inner_3_01.png"}}, min=1, max=1},
	default1i={image="terrain/slumbering_cave/slumbering_cave_floor_1_01.png", add_mos={{image="terrain/slumbering_cave/slumbering_cave_V3_7_01.png"}}, min=1, max=1},
	default2i={image="terrain/slumbering_cave/slumbering_cave_floor_1_01.png", add_mos={{image="terrain/slumbering_cave/slumbering_cavewall_2h_1.png"}}, min=1, max=1},
	default3i={image="terrain/slumbering_cave/slumbering_cave_floor_1_01.png", add_mos={{image="terrain/slumbering_cave/slumbering_cave_V3_9_01.png"}}, min=1, max=1},
	default19i={image="terrain/slumbering_cave/slumbering_cave_floor_1_01.png", add_mos={{image="terrain/slumbering_cave/slumbering_cavewall_19d_1.png"}}, min=1, max=1},
	default37i={image="terrain/slumbering_cave/slumbering_cave_floor_1_01.png", add_mos={{image="terrain/slumbering_cave/slumbering_cavewall_37d_1.png"}}, min=1, max=1},

	default4={add_displays={{image="terrain/slumbering_cave/slumbering_cave_ver_edge_left_01.png", display_x=-1}}, min=1, max=1},
	default6={add_displays={{image="terrain/slumbering_cave/slumbering_cave_ver_edge_right_01.png", display_x=1}}, min=1, max=1},
}

return _M
