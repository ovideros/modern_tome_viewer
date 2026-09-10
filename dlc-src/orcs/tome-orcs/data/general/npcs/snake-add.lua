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

newEntity{ base = "BASE_NPC_SNAKE", define_as = "GUNSNAKE",
	name = "Gunsnake", color=colors.UMBER, unique = true,
	desc = _t[[#{italic}##ANTIQUE_WHITE#From a bygone era it slithers...#LAST##{normal}#]],
	level_range = {8, nil}, exp_worth = 2,
	rank = 3.5,
	rarity = 60,
	max_life = 150, life_rating = 12,
	combat_armor = 0, combat_def = 30,
	combat = { dam=resolvers.levelup(10, 1, 0.7), atk=10, apr=10 },
	combat = resolvers.easy_combat_table{
		dam = {10, 120}, -- First is at level 1, second at lvl 50
		atk = {10, 200}, -- First is at level 1, second at lvl 50
		apr = 10,
		dammod = {str=1},
		sound="creatures/snakes/snake_attack",
	},

	autolevel = "rogue",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_snake" },

	size_category = 3,
	infravision = 10,
	steam_regen = 20,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1, CLOAK=1},
	resolvers.auto_equip_filters{
		MAINHAND={type="weapon", subtype="steamgun", autoreq=true},
		OFFHAND={type="weapon", subtype="steamgun", autoreq=true},
		QUIVER={type="ammo", subtype="shot", autoreq=true},
		CLOAK={type="armor", subtype="cloak", autoreq=true},
	},
	resolvers.equip{ {type="weapon", subtype="steamgun", base_list="mod.class.Object:/data-orcs/general/objects/steamgun.lua", forbid_power_source={nature=true}, autoreq=true}, },
	resolvers.equip{ {type="weapon", subtype="steamgun", base_list="mod.class.Object:/data-orcs/general/objects/steamgun.lua", forbid_power_source={nature=true}, autoreq=true}, },
	resolvers.equip{ {type="ammo", subtype="shot", forbid_power_source={nature=true}, autoreq=true}, },
	resolvers.equip{ {type="armor", subtype="cloak", forbid_power_source={nature=true}, autoreq=true}, },

	resolvers.sustains_at_birth(),
	not_power_source = {nature=true},

	resolvers.talents{
		[Talents.T_STEAMGUN_MASTERY] = {base=3, every=5},
		[Talents.T_DOUBLE_SHOTS] = {base=3, every=5},
		[Talents.T_UNCANNY_RELOAD] = {base=2, every=5},
		[Talents.T_STARTLING_SHOT] = {base=3, every=5},
		[Talents.T_EVASIVE_SHOTS] = {base=3, every=5},
		[Talents.T_PERCUSSIVE_BULLETS] = {base=3, every=5},
		[Talents.T_CLOAK] = {base=3, every=5},
		[Talents.T_AUTOMATED_CLOAK_TESSELLATION] = {base=3, every=5},
	},
	on_die = function()
		game:setAllowedBuild("cosmetic_gunsnake", false)
	end,
}
