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



newEntity{
	define_as = "MANACAVE_GROUND",
	type = "floor", subtype = "floor",
	name = "manacave ground", image = "terrain/manacave/manacave_01.png",
	display = '.', color=colors.UMBER, back_color=colors.LIGHT_UMBER,
	grow = "MANACAVE",
}

-----------------------------------------
-- Stairs
-----------------------------------------

newEntity{
	define_as = "MANACAVE_UP_WILDERNESS", image = "terrain/manacave/manacave_01.png", add_mos = {{image="terrain/manacave/manacave_57.png"}},
	type = "floor", subtype = "floor",
	name = "previous level",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	change_zone = "wilderness",
}

newEntity{
	define_as = "MANACAVE_UP", image = "terrain/manacave/manacave_01.png", add_mos = {{image="terrain/manacave/manacave_57.png"}},
	type = "floor", subtype = "floor",
	name = "previous level",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "MANACAVE_DOWN", image = "terrain/manacave/manacave_01.png", add_mos = {{image="terrain/manacave/manacave_56.png"}},
	type = "floor", subtype = "floor",
	name = "next level",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

-----------------------------------------
-- Walls
-----------------------------------------
newEntity{
	define_as = "MANACAVE",
	type = "wall", subtype = "floor",
	name = "wall", image = "terrain/manacave/manacave_02_1.png",
	display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
	z = 3,
	nice_tiler = { method="Wall3dSus",  
		-- inner walls that form a corner:
		inner={"MANACAVE", 100, 1, 4},
		inner_cornl="MANACAVE_CORNL",
		inner_cornr="MANACAVE_CORNR",
		inner_cornl_cornr="MANACAVE_CORNL_CORNR",
		-- west-east walls (walls to north and south, open on west and east). The trailing direction underscores are where there are nearby walls:
		wewall="MANACAVE_WEWALL",  
		wewall_sw="MANACAVE_WEWALL_SW",  
		wewall_se="MANACAVE_WEWALL_SE", 
		wewall_sw_se="MANACAVE_WEWALL_SW_SE",
		-- west walls (walls to n, s, and e. Open on west)
		wwall="MANACAVE_WWALL", 
		wwall_cornr="MANACAVE_WWALL_CORNR", 
		wwall_sw="MANACAVE_WWALL_SW", 
		wwall_sw_cornr="MANACAVE_WWALL_SW_CORNR", 
		-- east walls (walls to n, s, and w. Open on east)
		ewall="MANACAVE_EWALL", 
		ewall_cornl="MANACAVE_EWALL_CORNL", 
		ewall_se="MANACAVE_EWALL_SE", 
		ewall_se_cornl="MANACAVE_EWALL_SE_CORNL", 
		-- north walls (not north-south):
		nwall_cap_lup_rup="MANACAVE_NWALL_CAP_LUP_RUP", 
		nwall_cap_lup_rup_cornl="MANACAVE_NWALL_CAP_LUP_RUP_CORNL", 
		nwall_cap_lup_rup_cornr="MANACAVE_NWALL_CAP_LUP_RUP_CORNR", 
		nwall_cap_lup_rup_cornl_cornr="MANACAVE_NWALL_CAP_LUP_RUP_CORNL_CORNR", 
		nwall_cap_lup="MANACAVE_NWALL_CAP_LUP", 
		nwall_cap_lup_cornl="MANACAVE_NWALL_CAP_LUP_CORNL", 
		nwall_cap_lup_cornr="MANACAVE_NWALL_CAP_LUP_CORNR", 
		nwall_cap_lup_cornl_cornr="MANACAVE_NWALL_CAP_LUP_CORNL_CORNR", 
		nwall_cap_lup_rdn="MANACAVE_NWALL_CAP_LUP_RDN", 
		nwall_cap_lup_rdn_cornl="MANACAVE_NWALL_CAP_LUP_RDN_CORNL", 
		nwall_cap_lup_rdn_se="MANACAVE_NWALL_CAP_LUP_RDN_SE", 
		nwall_cap_lup_rdn_se_cornl="MANACAVE_NWALL_CAP_LUP_RDN_SE_CORNL", 
		
		
		nwall_cap_rup="MANACAVE_NWALL_CAP_RUP", 
		nwall_cap_rup_cornl="MANACAVE_NWALL_CAP_RUP_CORNL", 
		nwall_cap_rup_cornr="MANACAVE_NWALL_CAP_RUP_CORNR", 
		nwall_cap_rup_cornl_cornr="MANACAVE_NWALL_CAP_RUP_CORNL_CORNR", 
		nwall="MANACAVE_NWALL", 
		nwall_cornl="MANACAVE_NWALL_CORNL", 
		nwall_cornr="MANACAVE_NWALL_CORNR", 
		nwall_cornl_cornr="MANACAVE_NWALL_CORNL_CORNR", 
		nwall_cap_rdn="MANACAVE_NWALL_CAP_RDN", 
		nwall_cap_rdn_cornl="MANACAVE_NWALL_CAP_RDN_CORNL", 
		nwall_cap_rdn_se="MANACAVE_NWALL_CAP_RDN_SE", 
		nwall_cap_rdn_se_cornl="MANACAVE_NWALL_CAP_RDN_SE_CORNL", 
		
		
		nwall_cap_ldn_rup="MANACAVE_NWALL_CAP_LDN_RUP",
		nwall_cap_ldn_rup_cornr="MANACAVE_NWALL_CAP_LDN_RUP_CORNR",
		nwall_cap_ldn_rup_sw="MANACAVE_NWALL_CAP_LDN_RUP_SW",
		nwall_cap_ldn_rup_sw_cornr="MANACAVE_NWALL_CAP_LDN_RUP_SW_CORNR",
		nwall_cap_ldn="MANACAVE_NWALL_CAP_LDN",
		nwall_cap_ldn_cornr="MANACAVE_NWALL_CAP_LDN_CORNR",
		nwall_cap_ldn_sw="MANACAVE_NWALL_CAP_LDN_SW",
		nwall_cap_ldn_sw_cornr="MANACAVE_NWALL_CAP_LDN_SW_CORNR",
		nwall_cap_ldn_rdn="MANACAVE_NWALL_CAP_LDN_RDN",
		nwall_cap_ldn_rdn_sw="MANACAVE_NWALL_CAP_LDN_RDN_SW",
		nwall_cap_ldn_rdn_se="MANACAVE_NWALL_CAP_LDN_RDN_SE",
		nwall_cap_ldn_rdn_sw_se="MANACAVE_NWALL_CAP_LDN_RDN_SW_SE",
		-- south walls (not north-south):
		swall_lup_rup="MANACAVE_SWALL_LUP_RUP", 
		swall_lup="MANACAVE_SWALL_LUP", 
		swall_lup_rdn="MANACAVE_SWALL_LUP_RDN", 
		swall_rup="MANACAVE_SWALL_RUP",  
		swall={"MANACAVE_SWALL", 100, 1, 4}, 
		swall_rdn="MANACAVE_SWALL_RDN", 
		swall_ldn_rup="MANACAVE_SWALL_LDN_RUP",
		swall_ldn="MANACAVE_SWALL_LDN",
		swall_ldn_rdn="MANACAVE_SWALL_LDN_RDN",
		-- north-south walls (standard cap):
		nswall_lup_rup="MANACAVE_NSWALL_LUP_RUP", 
		nswall_lup="MANACAVE_NSWALL_LUP", 
		nswall_lup_rdn="MANACAVE_NSWALL_LUP_RDN", 
		nswall_rup="MANACAVE_NSWALL_RUP", 
		nswall="MANACAVE_NSWALL", 
		nswall_rdn="MANACAVE_NSWALL_RDN", 
		nswall_ldn_rup="MANACAVE_NSWALL_LDN_RUP",
		nswall_ldn="MANACAVE_NSWALL_LDN",
		nswall_ldn_rdn="MANACAVE_NSWALL_LDN_RDN",
		-- north-south walls (up caps):
		nswall_lup_cap_rup="MANACAVE_NSWALL_LUP_CAP_RUP",
		
		nswall_lup_rdn_cap_rup="MANACAVE_NSWALL_LUP_RDN_CAP_RUP", 
		
		nswall_rup_cap_lup="MANACAVE_NSWALL_RUP_CAP_LUP",
		
		nswall_cap_lup="MANACAVE_NSWALL_CAP_LUP", 
		nswall_cap_rup="MANACAVE_NSWALL_CAP_RUP", 
		nswall_cap_lup_rup="MANACAVE_NSWALL_CAP_LUP_RUP", 
		
		nswall_rdn_cap_lup="MANACAVE_NSWALL_RDN_CAP_LUP", 
		nswall_rdn_cap_rup="MANACAVE_NSWALL_RDN_CAP_RUP", 
		nswall_rdn_cap_lup_rup="MANACAVE_NSWALL_RDN_CAP_LUP_RUP", 
		
		nswall_ldn_rup_cap_lup="MANACAVE_NSWALL_LDN_RUP_CAP_LUP",
		
		nswall_ldn_cap_lup="MANACAVE_NSWALL_LDN_CAP_LUP",
		nswall_ldn_cap_rup="MANACAVE_NSWALL_LDN_CAP_RUP",
		nswall_ldn_cap_lup_rup="MANACAVE_NSWALL_LDN_CAP_LUP_RUP",
		
		nswall_ldn_rdn_cap_lup="MANACAVE_NSWALL_LDN_RDN_CAP_LUP",
		nswall_ldn_rdn_cap_rup="MANACAVE_NSWALL_LDN_RDN_CAP_RUP",
		nswall_ldn_rdn_cap_lup_rup="MANACAVE_NSWALL_LDN_RDN_CAP_LUP_RUP",
		},
	always_remember = true,
	does_block_move = true,
	can_pass = {pass_wall=1},
	block_sight = true,
	air_level = -20,
	dig = "MANACAVE_GROUND",
}





-- inner corners:
for i = 1, 4 do	newEntity{ base = "MANACAVE", define_as = "MANACAVE"..i, image = "terrain/manacave/manacave_02_"..i..".png", z = 3} end
newEntity{ base = "MANACAVE", define_as = "MANACAVE_CORNL", image = "terrain/manacave/manacave_16.png", z = 3}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_CORNR", image = "terrain/manacave/manacave_17.png", z = 3}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_CORNL_CORNR", image = "terrain/manacave/manacave_23.png", z = 3}

-- west-east walls :
newEntity{ base = "MANACAVE", define_as = "MANACAVE_WEWALL", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_19.png",z=3}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_WEWALL_SW", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_53.png",z=3}}} 
newEntity{ base = "MANACAVE", define_as = "MANACAVE_WEWALL_SE", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_52.png",z=3}}} 
newEntity{ base = "MANACAVE", define_as = "MANACAVE_WEWALL_SW_SE", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_22.png",z=3}}} 


-- west walls :
newEntity{ base = "MANACAVE", define_as = "MANACAVE_WWALL", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_05.png",z=3}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_WWALL_CORNR", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_50.png",z=3}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_WWALL_SW", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_12.png",z=3}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_WWALL_SW_CORNR", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_55.png",z=3}}}

-- east walls :
newEntity{ base = "MANACAVE", define_as = "MANACAVE_EWALL", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_06.png",z=3}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_EWALL_CORNL", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_51.png",z=3}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_EWALL_SE", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_13.png",z=3}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_EWALL_SE_CORNL", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_54.png",z=3}}}


-- north walls :
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LUP_RUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_02_1.png",z=3}, class.new{image="terrain/manacave/manacave_29.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LUP_RUP_CORNL", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_16.png",z=3}, class.new{image="terrain/manacave/manacave_29.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LUP_RUP_CORNR", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_17.png",z=3}, class.new{image="terrain/manacave/manacave_29.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LUP_RUP_CORNL_CORNR", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_23.png",z=3}, class.new{image="terrain/manacave/manacave_29.png", z=18, display_y=-1}}}

newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_02_1.png",z=3}, class.new{image="terrain/manacave/manacave_14.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LUP_CORNL", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_16.png",z=3}, class.new{image="terrain/manacave/manacave_14.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LUP_CORNR", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_17.png",z=3}, class.new{image="terrain/manacave/manacave_14.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LUP_CORNL_CORNR", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_23.png",z=3}, class.new{image="terrain/manacave/manacave_14.png", z=18, display_y=-1}}}

newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LUP_RDN", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_06.png",z=3}, class.new{image="terrain/manacave/manacave_25.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LUP_RDN_CORNL", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_51.png",z=3}, class.new{image="terrain/manacave/manacave_25.png", z=18, display_y=-1}}} 
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LUP_RDN_SE", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_13.png",z=3}, class.new{image="terrain/manacave/manacave_25.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LUP_RDN_SE_CORNL", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_54.png",z=3}, class.new{image="terrain/manacave/manacave_25.png", z=18, display_y=-1}}} 



newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_RUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_02_1.png",z=3}, class.new{image="terrain/manacave/manacave_11.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_RUP_CORNL", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_16.png",z=3}, class.new{image="terrain/manacave/manacave_11.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_RUP_CORNR", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_17.png",z=3}, class.new{image="terrain/manacave/manacave_11.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_RUP_CORNL_CORNR", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_23.png",z=3}, class.new{image="terrain/manacave/manacave_11.png", z=18, display_y=-1}}}

newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_02_1.png",z=3}, class.new{image="terrain/manacave/manacave_03.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CORNL", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_16.png",z=3}, class.new{image="terrain/manacave/manacave_03.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CORNR", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_17.png",z=3}, class.new{image="terrain/manacave/manacave_03.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CORNL_CORNR", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_23.png",z=3}, class.new{image="terrain/manacave/manacave_03.png", z=18, display_y=-1}}}

newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_RDN", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_06.png",z=3}, class.new{image="terrain/manacave/manacave_08.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_RDN_CORNL", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_51.png",z=3}, class.new{image="terrain/manacave/manacave_08.png", z=18, display_y=-1}}} 
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_RDN_SE", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_13.png",z=3}, class.new{image="terrain/manacave/manacave_08.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_RDN_SE_CORNL", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_54.png",z=3}, class.new{image="terrain/manacave/manacave_08.png", z=18, display_y=-1}}} 



newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LDN_RUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_05.png",z=3}, class.new{image="terrain/manacave/manacave_24.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LDN_RUP_CORNR", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_50.png",z=3}, class.new{image="terrain/manacave/manacave_24.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LDN_RUP_SW", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_12.png",z=3}, class.new{image="terrain/manacave/manacave_24.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LDN_RUP_SW_CORNR", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_55.png",z=3}, class.new{image="terrain/manacave/manacave_24.png", z=18, display_y=-1}}} 

newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LDN", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_05.png",z=3}, class.new{image="terrain/manacave/manacave_07.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LDN_CORNR", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_50.png",z=3}, class.new{image="terrain/manacave/manacave_07.png", z=18, display_y=-1}}} 
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LDN_SW", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_12.png",z=3}, class.new{image="terrain/manacave/manacave_07.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LDN_SW_CORNR", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_55.png",z=3}, class.new{image="terrain/manacave/manacave_07.png", z=18, display_y=-1}}} 

newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LDN_RDN", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_19.png",z=3}, class.new{image="terrain/manacave/manacave_20.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LDN_RDN_SW", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_53.png",z=3}, class.new{image="terrain/manacave/manacave_20.png", z=18, display_y=-1}}} 
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LDN_RDN_SE", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_52.png",z=3}, class.new{image="terrain/manacave/manacave_20.png", z=18, display_y=-1}}} 
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NWALL_CAP_LDN_RDN_SW_SE", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_22.png",z=3}, class.new{image="terrain/manacave/manacave_20.png", z=18, display_y=-1}}} 


-- south walls (not north-south):
newEntity{ base = "MANACAVE", define_as = "MANACAVE_SWALL_LUP_RUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_21.png",z=3}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_SWALL_LUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_09.png",z=3}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_SWALL_LUP_RDN", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_26.png",z=3}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_SWALL_RUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_10.png",z=3}}}
for i = 1, 4 do newEntity{ base = "MANACAVE", define_as = "MANACAVE_SWALL"..i, image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_04_"..i..".png",z=3}}} end
newEntity{ base = "MANACAVE", define_as = "MANACAVE_SWALL_RDN", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_15.png",z=3}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_SWALL_LDN_RUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_27.png",z=3}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_SWALL_LDN", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_18.png",z=3}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_SWALL_LDN_RDN", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_28.png",z=3}}}


-- north-south walls (standard cap):
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_LUP_RUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_48.png",z=3}, class.new{image="terrain/manacave/manacave_49.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_LUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_09.png",z=3}, class.new{image="terrain/manacave/manacave_07.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_LUP_RDN", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_26.png",z=3}, class.new{image="terrain/manacave/manacave_07.png", z=18, display_y=-1}}}

newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_RUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_10.png",z=3}, class.new{image="terrain/manacave/manacave_08.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_04_1.png",z=3}, class.new{image="terrain/manacave/manacave_03.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_RDN", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_15.png",z=3}, class.new{image="terrain/manacave/manacave_03.png", z=18, display_y=-1}}}

newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_LDN_RUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_27.png",z=3}, class.new{image="terrain/manacave/manacave_08.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_LDN", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_18.png",z=3}, class.new{image="terrain/manacave/manacave_03.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_LDN_RDN", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_28.png",z=3}, class.new{image="terrain/manacave/manacave_03.png", z=18, display_y=-1}}}

-- north-south walls (up caps):
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_LUP_CAP_RUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_09.png",z=3}, class.new{image="terrain/manacave/manacave_24.png", z=18, display_y=-1}}}

newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_LUP_RDN_CAP_RUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_26.png",z=3}, class.new{image="terrain/manacave/manacave_24.png", z=18, display_y=-1}}}

newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_RUP_CAP_LUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_10.png",z=3}, class.new{image="terrain/manacave/manacave_25.png", z=18, display_y=-1}}}

newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_CAP_LUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_04_1.png",z=3}, class.new{image="terrain/manacave/manacave_14.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_CAP_RUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_04_1.png",z=3}, class.new{image="terrain/manacave/manacave_11.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_CAP_LUP_RUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_04_1.png",z=3}, class.new{image="terrain/manacave/manacave_29.png", z=18, display_y=-1}}}


newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_RDN_CAP_LUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_15.png",z=3}, class.new{image="terrain/manacave/manacave_14.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_RDN_CAP_RUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_15.png",z=3}, class.new{image="terrain/manacave/manacave_11.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_RDN_CAP_LUP_RUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_15.png",z=3}, class.new{image="terrain/manacave/manacave_29.png", z=18, display_y=-1}}}


newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_LDN_RUP_CAP_LUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_27.png",z=3}, class.new{image="terrain/manacave/manacave_25.png", z=18, display_y=-1}}}


newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_LDN_CAP_LUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_18.png",z=3}, class.new{image="terrain/manacave/manacave_14.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_LDN_CAP_RUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_18.png",z=3}, class.new{image="terrain/manacave/manacave_11.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_LDN_CAP_LUP_RUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_18.png",z=3}, class.new{image="terrain/manacave/manacave_29.png", z=18, display_y=-1}}}

newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_LDN_RDN_CAP_LUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_28.png",z=3}, class.new{image="terrain/manacave/manacave_14.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_LDN_RDN_CAP_RUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_28.png",z=3}, class.new{image="terrain/manacave/manacave_11.png", z=18, display_y=-1}}}
newEntity{ base = "MANACAVE", define_as = "MANACAVE_NSWALL_LDN_RDN_CAP_LUP_RUP", image = "terrain/manacave/manacave_01.png", z=1, add_displays = {class.new{image="terrain/manacave/manacave_28.png",z=3}, class.new{image="terrain/manacave/manacave_29.png", z=18, display_y=-1}}}

-----------------------------------------
-- Doors
-----------------------------------------
newEntity{
	define_as = "MANACAVE_DOOR",
	type = "wall", subtype = "floor",
	name = "door", image = "terrain/manacave/manacave_30.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	nice_tiler = { method="Door3dSus", 
		vert="MANACAVE_DOOR_VERT", 
		vert_cap_lup="MANACAVE_DOOR_VERT_CAP_LUP", 
		vert_cap_rup="MANACAVE_DOOR_VERT_CAP_RUP", 
		vert_cap_lup_rup="MANACAVE_DOOR_VERT_CAP_LUP_RUP", 
		
		vert_ldn="MANACAVE_DOOR_VERT_LDN", 
		vert_ldn_cap_lup="MANACAVE_DOOR_VERT_LDN_CAP_LUP", 
		vert_ldn_cap_rup="MANACAVE_DOOR_VERT_LDN_CAP_RUP", 
		vert_ldn_cap_lup_rup="MANACAVE_DOOR_VERT_LDN_CAP_LUP_RUP", 
		
		vert_rdn="MANACAVE_DOOR_VERT_RDN", 
		vert_rdn_cap_lup="MANACAVE_DOOR_VERT_RDN_CAP_LUP", 
		vert_rdn_cap_rup="MANACAVE_DOOR_VERT_RDN_CAP_RUP", 
		vert_rdn_cap_lup_rup="MANACAVE_DOOR_VERT_RDN_CAP_LUP_RUP", 
		
		vert_ldn_rdn="MANACAVE_DOOR_VERT_LDN_RDN", 
		vert_ldn_rdn_cap_lup="MANACAVE_DOOR_VERT_LDN_RDN_CAP_LUP", 
		vert_ldn_rdn_cap_rup="MANACAVE_DOOR_VERT_LDN_RDN_CAP_RUP", 
		vert_ldn_rdn_cap_lup_rup="MANACAVE_DOOR_VERT_LDN_RDN_CAP_LUP_RUP", 
	
	
	
		horiz="MANACAVE_DOOR_HORIZ",
		horiz_ldn="MANACAVE_DOOR_HORIZ_LDN",
		horiz_rdn="MANACAVE_DOOR_HORIZ_RDN",
		horiz_ldn_rdn="MANACAVE_DOOR_HORIZ_LDN_RDN",
		
		horiz_cap_lup="MANACAVE_DOOR_HORIZ_CAP_LUP", 
		horiz_ldn_cap_lup="MANACAVE_DOOR_HORIZ_LDN_CAP_LUP", 
		horiz_rdn_cap_lup="MANACAVE_DOOR_HORIZ_RDN_CAP_LUP", 
		horiz_ldn_rdn_cap_lup="MANACAVE_DOOR_HORIZ_LDN_RDN_CAP_LUP", 
		
		horiz_cap_rup="MANACAVE_DOOR_HORIZ_CAP_RUP", 
		horiz_ldn_cap_rup="MANACAVE_DOOR_HORIZ_LDN_CAP_RUP", 
		horiz_rdn_cap_rup="MANACAVE_DOOR_HORIZ_RDN_CAP_RUP", 
		horiz_ldn_rdn_cap_rup="MANACAVE_DOOR_HORIZ_LDN_RDN_CAP_RUP", 
		
		horiz_cap_lup_rup="MANACAVE_DOOR_HORIZ_CAP_LUP_RUP", 
		horiz_ldn_cap_lup_rup="MANACAVE_DOOR_HORIZ_LDN_CAP_LUP_RUP", 
		horiz_rdn_cap_lup_rup="MANACAVE_DOOR_HORIZ_RDN_CAP_LUP_RUP", 
		horiz_ldn_rdn_cap_lup_rup="MANACAVE_DOOR_HORIZ_LDN_RDN_CAP_LUP_RUP", 
	},
	notice = true,
	always_remember = true,
	block_sight = true,
	is_door = true,
	door_opened = "MANACAVE_DOOR_OPEN",
	dig = "MANACAVE_GROUND",
}

newEntity{
	define_as = "MANACAVE_DOOR_OPEN",
	type = "wall", subtype = "floor",
	name = "open door", image="terrain/manacave/manacave_31.png",
	display = "'", color_r=238, color_g=154, color_b=77, back_color=colors.DARK_GREY,
	always_remember = true,
	is_door = true,
	door_closed = "MANACAVE_DOOR",
}

-- HORIZONTAL DOORS
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_HORIZ", z=3, image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_30.png", z=17}, class.new{image="terrain/manacave/manacave_03.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_HORIZ_OPEN"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_HORIZ_LDN", z=3, image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_61.png", z=17}, class.new{image="terrain/manacave/manacave_03.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_HORIZ_OPEN_LDN"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_HORIZ_RDN", z=3, image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_63.png", z=17}, class.new{image="terrain/manacave/manacave_03.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_HORIZ_OPEN_RDN"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_HORIZ_LDN_RDN", z=3, image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_59.png", z=17}, class.new{image="terrain/manacave/manacave_03.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_HORIZ_OPEN_LDN_RDN"}

newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_HORIZ_CAP_LUP", z=3, image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_30.png", z=17}, class.new{image="terrain/manacave/manacave_14.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_HORIZ_OPEN_CAP_LUP"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_HORIZ_LDN_CAP_LUP", z=3, image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_61.png", z=17}, class.new{image="terrain/manacave/manacave_14.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_HORIZ_OPEN_LDN_CAP_LUP"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_HORIZ_RDN_CAP_LUP", z=3, image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_63.png", z=17}, class.new{image="terrain/manacave/manacave_14.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_HORIZ_OPEN_RDN_CAP_LUP"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_HORIZ_LDN_RDN_CAP_LUP", z=3, image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_59.png", z=17}, class.new{image="terrain/manacave/manacave_14.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_HORIZ_OPEN_LDN_RDN_CAP_LUP"}

newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_HORIZ_CAP_RUP", z=3, image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_30.png", z=17}, class.new{image="terrain/manacave/manacave_11.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_HORIZ_OPEN_CAP_RUP"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_HORIZ_LDN_CAP_RUP", z=3, image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_61.png", z=17}, class.new{image="terrain/manacave/manacave_11.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_HORIZ_OPEN_LDN_CAP_RUP"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_HORIZ_RDN_CAP_RUP", z=3, image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_63.png", z=17}, class.new{image="terrain/manacave/manacave_11.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_HORIZ_OPEN_RDN_CAP_RUP"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_HORIZ_LDN_RDN_CAP_RUP", z=3, image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_59.png", z=17}, class.new{image="terrain/manacave/manacave_11.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_HORIZ_OPEN_LDN_RDN_CAP_RUP"}

newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_HORIZ_CAP_LUP_RUP", z=3, image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_30.png", z=17}, class.new{image="terrain/manacave/manacave_29.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_HORIZ_OPEN_CAP_LUP_RUP"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_HORIZ_LDN_CAP_LUP_RUP", z=3, image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_61.png", z=17}, class.new{image="terrain/manacave/manacave_29.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_HORIZ_OPEN_LDN_CAP_LUP_RUP"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_HORIZ_RDN_CAP_LUP_RUP", z=3, image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_63.png", z=17}, class.new{image="terrain/manacave/manacave_29.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_HORIZ_OPEN_RDN_CAP_LUP_RUP"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_HORIZ_LDN_RDN_CAP_LUP_RUP", z=3, image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_59.png", z=17}, class.new{image="terrain/manacave/manacave_29.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_HORIZ_OPEN_LDN_RDN_CAP_LUP_RUP"}


-- HORIZONTAL DOORS (open)
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_HORIZ_OPEN", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_31.png", z=17}, class.new{image="terrain/manacave/manacave_03.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_HORIZ"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_HORIZ_OPEN_LDN", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_60.png", z=17}, class.new{image="terrain/manacave/manacave_03.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_HORIZ_LDN"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_HORIZ_OPEN_RDN", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_62.png", z=17}, class.new{image="terrain/manacave/manacave_03.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_HORIZ_RDN"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_HORIZ_OPEN_LDN_RDN", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_58.png", z=17}, class.new{image="terrain/manacave/manacave_03.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_HORIZ_LDN_RDN"}

newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_HORIZ_OPEN_CAP_LUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_31.png", z=17}, class.new{image="terrain/manacave/manacave_14.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_HORIZ_CAP_LUP"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_HORIZ_OPEN_LDN_CAP_LUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_60.png", z=17}, class.new{image="terrain/manacave/manacave_14.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_HORIZ_LDN_CAP_LUP"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_HORIZ_OPEN_RDN_CAP_LUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_62.png", z=17}, class.new{image="terrain/manacave/manacave_14.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_HORIZ_RDN_CAP_LUP"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_HORIZ_OPEN_LDN_RDN_CAP_LUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_58.png", z=17}, class.new{image="terrain/manacave/manacave_14.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_HORIZ_LDN_RDN_CAP_LUP"}

newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_HORIZ_OPEN_CAP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_31.png", z=17}, class.new{image="terrain/manacave/manacave_11.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_HORIZ_CAP_RUP"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_HORIZ_OPEN_LDN_CAP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_60.png", z=17}, class.new{image="terrain/manacave/manacave_11.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_HORIZ_lDN_CAP_RUP"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_HORIZ_OPEN_RDN_CAP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_62.png", z=17}, class.new{image="terrain/manacave/manacave_11.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_HORIZ_RDN_CAP_RUP"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_HORIZ_OPEN_LDN_RDN_CAP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_58.png", z=17}, class.new{image="terrain/manacave/manacave_11.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_HORIZ_LDN_RDN_CAP_RUP"}

newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_HORIZ_OPEN_CAP_LUP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_31.png", z=17}, class.new{image="terrain/manacave/manacave_29.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_HORIZ_CAP_LUP_RUP"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_HORIZ_OPEN_LDN_CAP_LUP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_60.png", z=17}, class.new{image="terrain/manacave/manacave_29.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_HORIZ_LDN_CAP_LUP_RUP"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_HORIZ_OPEN_RDN_CAP_LUP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_62.png", z=17}, class.new{image="terrain/manacave/manacave_29.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_HORIZ_RDN_CAP_LUP_RUP"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_HORIZ_OPEN_LDN_RDN_CAP_LUP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_58.png", z=17}, class.new{image="terrain/manacave/manacave_29.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_HORIZ_LDN_RDN_CAP_LUP_RUP"}


-- VERTICAL DOORS (CLOSED)
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_VERT", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_36.png", z=17}, class.new{image="terrain/manacave/manacave_37.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_OPEN_VERT", dig = "MANACAVE_GROUND"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_VERT_CAP_LUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_36.png", z=17}, class.new{image="terrain/manacave/manacave_45.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_OPEN_VERT_CAP_LUP", dig = "MANACAVE_GROUND"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_VERT_CAP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_36.png", z=17}, class.new{image="terrain/manacave/manacave_41.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_OPEN_VERT_CAP_RUP", dig = "MANACAVE_GROUND"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_VERT_CAP_LUP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_36.png", z=17}, class.new{image="terrain/manacave/manacave_33.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_OPEN_VERT_CAP_LUP_RUP", dig = "MANACAVE_GROUND"}

newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_VERT_LDN", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_44.png", z=17}, class.new{image="terrain/manacave/manacave_37.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_OPEN_VERT_LDN", dig = "MANACAVE_GROUND"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_VERT_LDN_CAP_LUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_44.png", z=17}, class.new{image="terrain/manacave/manacave_45.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_OPEN_VERT_LDN_CAP_LUP", dig = "MANACAVE_GROUND"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_VERT_LDN_CAP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_44.png", z=17}, class.new{image="terrain/manacave/manacave_41.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_OPEN_VERT_LDN_CAP_RUP", dig = "MANACAVE_GROUND"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_VERT_LDN_CAP_LUP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_44.png", z=17}, class.new{image="terrain/manacave/manacave_33.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_OPEN_VERT_LDN_CAP_LUP_RUP", dig = "MANACAVE_GROUND"}

newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_VERT_RDN", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_40.png", z=17}, class.new{image="terrain/manacave/manacave_37.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_OPEN_VERT_RDN", dig = "MANACAVE_GROUND"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_VERT_RDN_CAP_LUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_40.png", z=17}, class.new{image="terrain/manacave/manacave_45.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_OPEN_VERT_RDN_CAP_LUP", dig = "MANACAVE_GROUND"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_VERT_RDN_CAP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_40.png", z=17}, class.new{image="terrain/manacave/manacave_41.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_OPEN_VERT_RDN_CAP_RUP", dig = "MANACAVE_GROUND"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_VERT_RDN_CAP_LUP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_40.png", z=17}, class.new{image="terrain/manacave/manacave_33.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_OPEN_VERT_RDN_CAP_LUP_RUP", dig = "MANACAVE_GROUND"}

newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_VERT_LDN_RDN", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_32.png", z=17}, class.new{image="terrain/manacave/manacave_37.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_OPEN_VERT_LDN_RDN", dig = "MANACAVE_GROUND"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_VERT_LDN_RDN_CAP_LUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_32.png", z=17}, class.new{image="terrain/manacave/manacave_45.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_OPEN_VERT_LDN_RDN_CAP_LUP", dig = "MANACAVE_GROUND"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_VERT_LDN_RDN_CAP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_32.png", z=17}, class.new{image="terrain/manacave/manacave_41.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_OPEN_VERT_LDN_RDN_CAP_RUP", dig = "MANACAVE_GROUND"}
newEntity{ base = "MANACAVE_DOOR", define_as = "MANACAVE_DOOR_VERT_LDN_RDN_CAP_LUP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_32.png", z=17}, class.new{image="terrain/manacave/manacave_33.png", z=18, display_y=-1}}, door_opened = "MANACAVE_DOOR_OPEN_VERT_LDN_RDN_CAP_LUP_RUP", dig = "MANACAVE_GROUND"}


-- VERTICAL DOORS (OPEN)
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_OPEN_VERT", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_38.png", z=17}, class.new{image="terrain/manacave/manacave_39.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_VERT"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_OPEN_VERT_CAP_LUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_38.png", z=17}, class.new{image="terrain/manacave/manacave_47.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_VERT_CAP_LUP"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_OPEN_VERT_CAP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_38.png", z=17}, class.new{image="terrain/manacave/manacave_43.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_VERT_CAP_RUP"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_OPEN_VERT_CAP_LUP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_38.png", z=17}, class.new{image="terrain/manacave/manacave_35.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_VERT_CAP_LUP_RUP"}

newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_OPEN_VERT_LDN", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_46.png", z=17}, class.new{image="terrain/manacave/manacave_39.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_VERT_LDN"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_OPEN_VERT_LDN_CAP_LUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_46.png", z=17}, class.new{image="terrain/manacave/manacave_47.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_VERT_LDN_CAP_LUP"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_OPEN_VERT_LDN_CAP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_46.png", z=17}, class.new{image="terrain/manacave/manacave_43.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_VERT_LDN_CAP_RUP"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_OPEN_VERT_LDN_CAP_LUP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_46.png", z=17}, class.new{image="terrain/manacave/manacave_45.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_VERT_LDN_CAP_LUP_RUP"}

newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_OPEN_VERT_RDN", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_42.png", z=17}, class.new{image="terrain/manacave/manacave_39.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_VERT_RDN"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_OPEN_VERT_RDN_CAP_LUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_42.png", z=17}, class.new{image="terrain/manacave/manacave_47.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_VERT_RDN_CAP_LUP"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_OPEN_VERT_RDN_CAP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_42.png", z=17}, class.new{image="terrain/manacave/manacave_43.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_VERT_RDN_CAP_RUP"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_OPEN_VERT_RDN_CAP_LUP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_42.png", z=17}, class.new{image="terrain/manacave/manacave_45.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_VERT_RDN_CAP_LUP_RUP"}

newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_OPEN_VERT_LDN_RDN", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_34.png", z=17}, class.new{image="terrain/manacave/manacave_39.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_VERT_LDN_RDN"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_OPEN_VERT_LDN_RDN_CAP_LUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_34.png", z=17}, class.new{image="terrain/manacave/manacave_47.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_VERT_LDN_RDN_CAP_LUP"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_OPEN_VERT_LDN_RDN_CAP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_34.png", z=17}, class.new{image="terrain/manacave/manacave_43.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_VERT_LDN_RDN_CAP_RUP"}
newEntity{ base = "MANACAVE_DOOR_OPEN", define_as = "MANACAVE_DOOR_OPEN_VERT_LDN_RDN_CAP_LUP_RUP", image = "terrain/manacave/manacave_01.png", add_displays = {class.new{image="terrain/manacave/manacave_34.png", z=17}, class.new{image="terrain/manacave/manacave_45.png", z=18, display_y=-1}}, door_closed = "MANACAVE_DOOR_VERT_LDN_RDN_CAP_LUP_RUP"}


