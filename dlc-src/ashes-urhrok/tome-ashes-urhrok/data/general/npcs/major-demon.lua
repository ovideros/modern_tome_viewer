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

-- last updated:  10:46 AM 2/3/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_MAJOR_DEMON",
	type = "demon", subtype = "major",
	display = "U", color=colors.WHITE,
	blood_color = colors.GREEN,
	faction = "fearscape",
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	stats = { str=22, dex=10, mag=20, con=13 },
	combat_armor = 1, combat_def = 1,
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	combat = { dam=resolvers.mbonus(46, 20), atk=15, apr=7, dammod={str=0.7} },
	max_life = resolvers.rngavg(100,120),
	infravision = 10,
	open_door = true,
	rank = 2,
	size_category = 3,
	no_breath = 1,
	demon = 1,
	random_name_def = "demon",

	resolvers.inscriptions(1, "rune"),
	ingredient_on_death = "GREATER_DEMON_BILE",
}

newEntity{ base = "BASE_NPC_MAJOR_DEMON",
	name = "wretch titan", color=colors.GREEN,
	desc = _t"Many an adventurer has encounted the wretchling. Terrible things, wretchlings. Swarming, gnashing, burning. What those adventurers don't know is that those are just the children.",
	resolvers.nice_tile{tall=1},
	level_range = {35, nil}, exp_worth = 1,
	rarity = 9,
	life_rating = 21,
	rank = 3,
	size_category =4,
	autolevel = "warriormage",
	combat_armor = 45, combat_def = 25,
	combat = {dam=resolvers.mbonus(55, 15), apr=15, atk=resolvers.mbonus(50, 15), damtype=DamageType.ACID, dammod={mag=0.5, str=1}},

	resists={[DamageType.ACID] = 100, all = 25},
	resolvers.auto_equip_filters("Reaver"),
	resolvers.equip{ {type="weapon", subtype="longsword", forbid_power_source={antimagic=true}, autoreq=true}, },
	resolvers.equip{ {type="weapon", subtype="longsword", forbid_power_source={antimagic=true}, autoreq=true}, },

	resolvers.talents{
		[Talents.T_RUSH]=7,
		[Talents.T_ACID_BLOOD]={base=5, every=10, max=10},
		[Talents.T_CORROSIVE_VAPOUR]={base=5, every=7, max=9},
		[Talents.T_STUN]={base=5, every=5, max=8},
		[Talents.T_RUIN]={base=5, every=6, max=9},
		[Talents.T_CORRUPTED_STRENGTH]=6,
		[Talents.T_KNOCKBACK]={base=4, every=7, max=8},
		[Talents.T_ACID_STRIKE]={base=7, every=7, max=10},
	},
}