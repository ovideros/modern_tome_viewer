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

-- last updated:  5:11 PM 1/29/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_YETI",
	type = "giant", subtype = "yeti",
	display = "Y", color=colors.WHITE,
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },

	max_stamina = 150,
	rank = 2,
	size_category = 4,
	infravision = 10,
	
	resists={[DamageType.COLD] = 50,},

	resolvers.racial(),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },
	stats = { str=16, dex=10, mag=3, con=12 },
	combat = { dammod={str=1}},
	combat_armor = 2, combat_def = 12,
	not_power_source = {arcane=true, technique_ranged=true},

	wild_yeti = true,
}

newEntity{ base = "BASE_NPC_YETI",
	name = "yeti cub", color=colors.LIGHT_GREY,
	desc = _t[[This humanoid form is coated with a thick white fur.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 2,
	rank = 1,
	max_life = resolvers.rngavg(40,70), life_rating = 8,
	combat_armor = 1, combat_def = 3,
	combat = { dam=resolvers.levelup(5, 1, 0.7), atk=0, apr=3 },
}

newEntity{ base = "BASE_NPC_YETI",
	name = "yeti",
	desc = _t[[This large humanoid form is coated with a thick white fur.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_yeti_yeti.png", display_h=2, display_y=-1}}},
	level_range = {3, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(70,100),
	combat_armor = 2, combat_def = 10,
	combat = { dam=resolvers.levelup(7, 1, 0.8), atk=10, apr=6 },
	
	resolvers.talents{
		[Talents.T_ICE_CLAW]={base=1, every=6, max=5},
	},
}

newEntity{ base = "BASE_NPC_YETI",
	name = "yeti warrior", color=colors.GREY,
	desc = _t[[This huge humanoid form is coated with a thick white fur, with large, vicious claws. It looks angry.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_yeti_yeti_warrior.png", display_h=2, display_y=-1}}},
	level_range = {4, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(70,100),
	combat_armor = 2, combat_def = 14,
	combat = { dam=resolvers.levelup(8, 1, 0.8), atk=10, apr=6 },
	stats = { str=22 },
	
	resolvers.talents{
		[Talents.T_ICE_CLAW]={base=2, every=5, max=8},
		
		[Talents.T_RUSH]={base=1, every=8, max=5},
	},
}

newEntity{ base = "BASE_NPC_YETI", define_as = "YETI_DEMOLISHER",
	name = "yeti demolisher", color=colors.GREY,
	desc = _t[[This huge humanoid form is coated with a thick white fur, with large, vicious claws. Will you welcome the embrace of its large muscular arms?]],
	resolvers.nice_tile{tall=1},
	level_range = {30, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	max_life = resolvers.rngavg(370,400), life_rating = 20,
	combat_armor = 30, combat_def = 30,
	combat = { dam=resolvers.levelup(20, 1, 1), atk=10, apr=6 },
	stats = { str=22, dex=30 },
	
	resolvers.talents{
		[Talents.T_ICE_CLAW]={base=4, every=6, max=9},
		[Talents.T_RUSH]={base=3, every=8, max=9},
		[Talents.T_UNARMED_MASTERY]={base=3, every=8, max=9},
		[Talents.T_HEIGHTENED_REFLEXES]={base=3, every=8, max=9},
		[Talents.T_REFLEX_DEFENSE]={base=3, every=8, max=9},
		[Talents.T_SHATTERING_SHOUT]={base=3, every=8, max=9},
		[Talents.T_CLINCH]={base=3, every=8, max=9},
		[Talents.T_CRUSHING_HOLD]={base=3, every=8, max=9},
	},
}