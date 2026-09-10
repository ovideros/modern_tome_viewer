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

load("/data/general/npcs/sandworm.lua", rarity(0))
load("/data/general/npcs/ritch.lua", rarity(0))
load("/data/general/npcs/snake.lua", rarity(3))
load("/data/general/npcs/fire-drake.lua", rarity(6))
load("/data/general/npcs/multihued-drake.lua", rarity(8))
load("/data/general/npcs/horror.lua", function(e) rarity(12)(e) if e.name == "Ak'Gishil" then e.rarity = nil end end)
load("/data/general/npcs/ghost.lua", switchRarity("guardian_rarity"))

--load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_GHOST", define_as = "GUARDIAN_PSIGHOST",
	name = "guardian psi-ghost", color=colors.BLUE,
	desc = _t[[A strangely humanoid shaped-ghost, blurring in and out of existence as its form is shaken by psionic discharges.]],
	level_range = {32, nil}, exp_worth = 1,
	rank = 3.5,
	max_life = 2000, life_rating = 25,
	faction = "neutral",

	ai = "tactical",

	ai = "dumb_talented_simple", ai_state = { ai_target="target_simple", ai_move="move_complex", talent_in=2, },

	cant_be_moved = 1,

	emote_random = {chance=2, _t"Soon...", _t"The day is drawing near...", _t"They will come back...", _t"It is approaching..."},

	combat_armor = 0, combat_def = resolvers.mbonus(10, 50),
	stealth = resolvers.mbonus(30, 20),

	combat = { dam=resolvers.mbonus(65, 65), atk=resolvers.mbonus(25, 45), apr=100, dammod={str=0.5, mag=0.5} },

	resolvers.talents{
		[Talents.T_SILENCE]={base=2, every=10, max=6},
		[Talents.T_MIND_DISRUPTION]={base=3, every=7, max=8},
	},
}
