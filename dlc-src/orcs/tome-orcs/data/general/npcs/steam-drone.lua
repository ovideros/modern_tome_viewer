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

-- last updated: 9:25 AM 2/5/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_STEAM_DRONE",
	type = "mechanical", subtype = "drone",
	display = "I", color=colors.GREY,
	faction = "atmos-tribe",
	repairable = 1,

	combat = { dam=resolvers.levelup(5, 1, 0.7), atk=7, apr=1 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, CLOAK=1, QUIVER=1 },
	resolvers.drops{chance=10, nb=1, {type="gem"} },
	resolvers.drops{chance=1, nb=1, {type="scroll", subtype="schematic"} },
	infravision = 10,

	resolvers.inscription("IMPLANT:_STEAM_GENERATOR", {cooldown=32, power=10}),

	life_rating = 16,
	rank = 2,
	size_category = 2,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },
	stats = { str=15, dex=15, con=16 },
	power_source = {steamtech=true},
}

newEntity{ base = "BASE_STEAM_DRONE",
	name = "steam drone", color=colors.LIGHT_UMBER,
	desc = _t[[This eight legged mechanical construct looks suspiciously like a spider. A huge clonking spider that runs to you at great speed ready to cut you to pieces with its two rotating saws in place of mandibles.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 2,
	movement_speed = 2,
	max_life = 150, life_rating = 16,
	resolvers.auto_equip_filters("Sawbutcher"),
	resolvers.equip{
		{type="weapon", subtype="steamsaw", autoreq=true},
		{type="weapon", subtype="steamsaw", autoreq=true},
		{type="armor", subtype="cloak", autoreq=true},
	},
	combat_armor = 10, combat_def = 0,
	resolvers.talents{
		[Talents.T_STEAMSAW_MASTERY]={base=2, every=6, max=10}, 
		[Talents.T_AUTOMATED_CLOAK_TESSELLATION]={base=2, every=5, max=10}, 
		[Talents.T_TO_THE_ARMS]={base=2, every=5, max=10}, 
	},
}
