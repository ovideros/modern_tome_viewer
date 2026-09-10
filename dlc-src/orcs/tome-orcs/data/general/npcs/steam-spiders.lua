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
	define_as = "BASE_STEAM_SPIDER",
	type = "mechanical", subtype = "arachnid",
	display = "S", color=colors.GREY,
	faction = "atmos-tribe",
	repairable = 1,

	combat = { dam=resolvers.levelup(5, 1, 0.9), atk=7, apr=15 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, CLOAK=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {type="gem"} },
	resolvers.drops{chance=2, nb=1, {type="scroll", subtype="schematic"} },
	infravision = 10,

	resolvers.inscription("IMPLANT:_STEAM_GENERATOR", {cooldown=32, power=10}),

	life_rating = 13,
	rank = 2,
	size_category = 2,

	resolvers.talents{ [Talents.T_ARMOUR_TRAINING]=3, [Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5}, [Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=5} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },
	stats = { str=15, dex=15, con=16 },
	power_source = {steamtech=true},
}

newEntity{ base = "BASE_STEAM_SPIDER",
	name = "mecharachnid warrior", color=colors.LIGHT_UMBER,
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

newEntity{ base = "BASE_STEAM_SPIDER",
	name = "mecharachnid flame thrower", color=colors.RED,
	desc = _t[[This eight legged mechanical construct looks suspiciously like a spider. The huge flame thrower mounted on its back however is definitively un-spider-like.]],
	level_range = {20, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(80,90), life_rating = 12,
	resolvers.equip{
		{type="armor", subtype="cloak", autoreq=true},
	},
	combat_armor = 0, combat_def = 6,
	autolevel = "rogue",
	resolvers.talents{
		[Talents.T_EMBEDDED_RESTORATION_SYSTEMS]={base=2, every=5, max=10}, 
		[Talents.T_FLAMETHROWER]={base=3, every=5, max=10}, 
	},
	on_die = function(self, src)
		if profile.mod.allow_build.tinker_annihilator then return end
		if src.resolveSource then src = src:resolveSource() end
		if not src.player then return end
		if not src:knowTalent(src.T_CREATE_TINKER) then return end

		src:grantQuest("orcs+annihilator")
		src:setQuestStatus("orcs+annihilator", engine.Quest.COMPLETED, "mecharachnid-flamethrower")
	end,
}

newEntity{ base = "BASE_STEAM_SPIDER",
	name = "mecharachnid destroyer", color=colors.BLUE,
	desc = _t[[This eight legged mechanical construct looks suspiciously like a spider. An armed to the teeth, well, mandibles, spider.]],
	level_range = {25, nil}, exp_worth = 1,
	rarity = 4, rank = 3, size = 3,
	max_life = 200, life_rating = 19,
	resolvers.auto_equip_filters("Sawbutcher"),
	resolvers.equip{
		{type="weapon", subtype="steamsaw", autoreq=true},
		{type="weapon", subtype="steamsaw", autoreq=true},
		{type="armor", subtype="cloak", autoreq=true},
	},
	combat_armor = 10, combat_def = 0,
	resolvers.talents{
		[Talents.T_STEAMSAW_MASTERY]={base=2, every=6, max=10}, 
		[Talents.T_EMBEDDED_RESTORATION_SYSTEMS]={base=2, every=5, max=10}, 
		[Talents.T_AUTOMATED_CLOAK_TESSELLATION]={base=2, every=5, max=10}, 
		[Talents.T_TO_THE_ARMS]={base=2, every=5, max=10}, 
		[Talents.T_BLOODSTREAM]={base=2, every=5, max=10}, 
		[Talents.T_TINKER_VIRAL_NEEDLEGUN]={base=2, every=5, max=10}, 
		[Talents.T_RUSH]={base=2, every=5, max=10}, 
		[Talents.T_TINKER_SPRING_GRAPPLE]={base=2, every=5, max=10}, 
	},
}

newEntity{ base = "BASE_STEAM_SPIDER",
	name = "mecharachnid repairbot", color=colors.LIGHT_GREEN,
	desc = _t[[This eight legged mechanical construct looks suspiciously like a spider. It seems to be more concerned by its fellow arachnids than by you.]],
	level_range = {30, nil}, exp_worth = 1,
	rarity = 8, rank = 3,
	max_life = 400, life_rating = 25,
	resolvers.equip{
		{type="armor", subtype="shield", autoreq=true},
	},
	combat_armor = 0, combat_def = 15,
	resists = { all = 50 },
	resolvers.talents{
		[Talents.T_MASS_REPAIR]={base=2, every=5, max=10},
	},

	make_escort = {
		{type="mechanical", number=5, no_subescort=true},
	},
}
