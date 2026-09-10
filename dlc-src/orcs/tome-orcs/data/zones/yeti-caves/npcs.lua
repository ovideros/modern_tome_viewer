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

load("/data/general/npcs/rodent.lua", rarity(5))
load("/data/general/npcs/bear.lua", rarity(4))
load("/data/general/npcs/snake.lua", rarity(10))
load("/data/general/npcs/ant.lua", function(e) if e.name ~= "giant white ant" then e.rarity = nil else e.name = _t"immature ice ant"; e.desc = _t"An oversized white ant. It seems not yet fully developed."; e.ingredient_on_death = "FROST_ANT_STINGER"; e.rarity = 3 end end)
load("/data-orcs/general/npcs/yeti.lua", rarity(0))

--load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "YETI_PATRIARCH",
	allow_infinite_dungeon = true, unique=true, rank=4,
	base = "BASE_NPC_YETI", color=colors.PURPLE,
	name = "Yeti Patriarch", --Needs name?
	desc = _t[[This yeti towers over its comrades. You see a cunning in its eyes unmatched by the others.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_yeti_yeti_patriarch.png", display_h=2, display_y=-1}}},
	level_range = {7, nil}, exp_worth = 2,
	rarity = false,
	max_life = resolvers.rngavg(170,200), life_rating = 14, fixed_rating = true,
	combat_armor = 4, combat_def = 15,
	combat = { dam=resolvers.levelup(9, 1, 1), atk=15, apr=6 },
	stats = { str=22 },
	
	resolvers.talents{
		[Talents.T_ICE_CLAW]={base=3, every=5, max=8},
		[Talents.T_KNOCKBACK]={base=1, every=6, max=6},
		[Talents.T_RUSH]={base=2, every=8, max=5},
	},
	
	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=3, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	
	resolvers.drops{chance=100, nb=1, {defined="YETI_PATRIARCH_MUSCLE"} },
	resolvers.drops{chance=100, nb=1, {defined="YETI_CLOAK", random_art_replace={chance=50}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	-- Override the recalculated AI tactics to avoid problematic kiting in the early game
	low_level_tactics_override = {escape=0},

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("orcs+start-orc", engine.Quest.COMPLETED, "yeti-cave")
	end,
}
