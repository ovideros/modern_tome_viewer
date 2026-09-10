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

load("/data-orcs/general/npcs/steam-giant-gunner.lua", rarity(0))
load("/data-orcs/general/npcs/steam-giant-warrior.lua", rarity(0))
load("/data/zones/shertul-fortress/npcs.lua", function(e) e.rarity = nil end)

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "KALTOR",
	allow_infinite_dungeon = true,
	base = "BASE_STEAM_GIANT_GUNNER", unique = true,
	name = "Arch-Merchant Kaltor", color=colors.PURPLE,
	desc = _t[[A well dressed giant, covered in gold, gems and fineries. Also wielding nasty looking guns at his sides. He seems to look strangely friendly while eyeing your gold purse.]],
	resolvers.nice_tile{tall=1},
	level_range = {17, nil}, exp_worth = 2,
	rarity = false, rank = 3.5,
	max_life = 300, life_rating = 16, fixed_rating = true,
	resolvers.auto_equip_filters("Gunslinger"),
	resolvers.equip{
		{type="weapon", subtype="steamgun", defined="ORC_EXPELLER", random_art_replace={chance=75}, autoreq=true},
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="ammo", subtype="shot", autoreq=true},
		{type="armor", subtype="light", defined="PRESSURE_COMBAT_SUIT", random_art_replace={chance=75}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=7, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=20, {type="money"} },
	combat_armor = 5, combat_def = 20,
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	
	resolvers.talents{ 
		[Talents.T_SHOOT] = 1,
		[Talents.T_WEAPON_COMBAT] = {base=1, every=5, max=5},
		[Talents.T_STRAFE]={base=2, every=8, max=5},
		[Talents.T_EVASIVE_SHOTS]={base=2, every=8, max=5},
		[Talents.T_STEAMGUN_MASTERY]={base=2, every=9, max=6}, 
		[Talents.T_FURNACE]={base=2, every=9, max=6}, 
		[Talents.T_MOLTEN_METAL]={base=2, every=9, max=6}, 
		[Talents.T_PERCUSSIVE_BULLETS]={base=2, every=9, max=6}, 
	},
	
	resolvers.sustains_at_birth(),

	on_die = function(self, who)
		require("engine.ui.Dialog"):simplePopup(_t"Kaltor", _t"As Kaltor falls you quickly grab a big golden key from his waist. Surely this opens the chests.")
		game.player:resolveSource():setQuestStatus("orcs+kaltor-shop", engine.Quest.COMPLETED)
	end,

	resolvers.genericlast(function(e)
		e.store = game:getStore("KALTOR_SHOP")
		e.store.faction = e.faction
	end),

	can_talk = "orcs+kaltor-shop",
}
