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

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_PLANT", define_as = "SAWTREE",
	name = "Sawtree", color=colors.UMBER, unique = true,
	resolvers.nice_tile{tall=1},
	desc = _t[[#{italic}##ANTIQUE_WHITE#Is that... a tree that cuts down trees?
Oh no don't worry. Only adventurers!#LAST##{normal}#]],
	level_range = {12, nil}, exp_worth = 2,
	rank = 3.5,
	rarity = 60,
	max_life = 150, life_rating = 25,
	combat_armor = 20, combat_def = 0,

	autolevel = "butcher",
	ai = "tactical", ai_state = { talent_in=1 },

	size_category = 3,
	infravision = 10,
	steam_regen = 20,
	never_move = table.NIL_MERGE,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1},
	resolvers.auto_equip_filters{
		MAINHAND={type="weapon", subtype="steamsaw", autoreq=true},
		OFFHAND={type="weapon", subtype="steamsaw", autoreq=true},
	},
	-- resolvers.equip{ {type="weapon", subtype="steamsaw", defined="THE_LUMBERATOR", random_art_replace={chance=50}, base_list="mod.class.Object:/data-orcs/general/objects/objects.lua", autoreq=true}, },
	resolvers.equip{ {type="weapon", subtype="steamsaw", base_list="mod.class.Object:/data-orcs/general/objects/steamsaw.lua", autoreq=true}, },
	resolvers.equip{ {type="weapon", subtype="steamsaw", base_list="mod.class.Object:/data-orcs/general/objects/steamsaw.lua", autoreq=true}, },

	resolvers.sustains_at_birth(),

	leaves_tide_no_mindstar = 1,
	resolvers.talents{
		[Talents.T_WEAPON_COMBAT] = {base=2, every=5},
		[Talents.T_STEAMSAW_MASTERY] = {base=3, every=5},
		[Talents.T_OVERHEAT_SAWS] = {base=3, every=5},
		[Talents.T_TEMPEST_OF_METAL] = {base=3, every=5},
		[Talents.T_TO_THE_ARMS] = {base=3, every=5},
		[Talents.T_SPINAL_BREAK] = {base=3, every=5},
		[Talents.T_SAWWHEELS] = {base=3, every=5},
		[Talents.T_LEAVES_TIDE] = {base=4, every=5},
		[Talents.T_CONTINUOUS_BUTCHERY] = {base=3, every=5},
		[Talents.T_FROST_GRAB] = {base=2, every=5},
		[Talents.T_SUBCUTANEOUS_METALLISATION] = 1,
	},
	talent_cd_reduction = {
		[Talents.T_FROST_GRAB] = 2,
	},

	on_die = function()
		game:setAllowedBuild("cosmetic_sawtree", false)
	end,
}
