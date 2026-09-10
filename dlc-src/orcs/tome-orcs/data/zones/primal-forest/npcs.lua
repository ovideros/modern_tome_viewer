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

load("/data/general/npcs/crystal.lua", rarity(0))
load("/data/general/npcs/bear.lua", rarity(1))
-- load("/data/general/npcs/vermin.lua", rarity(3))
load("/data/general/npcs/swarm.lua", rarity(1))
load("/data/general/npcs/ant.lua", rarity(2))
load("/data/general/npcs/plant.lua", function(e)
	if e.name == "treant" then
		e.on_die = function(self) game.zone.killed_treant = true end
	end
end)

-- load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_PLANT",
	name = "crystalbark", color=colors.GREEN,
	desc = _t"A very strong near-sentient tree, which has become infected with crystalline structures.",
	resolvers.nice_tile{tall=1},
	sound_moam = "creatures/treants/treeant_2",
	sound_die = {"creatures/treants/treeant_death_%d", 1, 2},
	sound_random = {"creatures/treants/treeant_%d", 1, 3},
	level_range = {20, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(100,130),
	life_rating = 15,
	combat = { dam=resolvers.levelup(resolvers.rngavg(8,13), 1, 1.2), atk=15, apr=5, sound="actions/melee_thud" },
	never_move = 0,
	rank = 2,
	size_category = 5,
	is_treant = true,
	combat_spellresist = 20,
	resolvers.talents{
		[Talents.T_FROST_GRAB]={base=2, every=6, max=10},
		[Talents.T_PHANTASMAL_SHIELD]={base=2, every=6, max=10},
	},
}


newEntity{ define_as = "PRIMAL_ROOT",
	allow_infinite_dungeon = true,
	type = "giant", subtype = "treant",
	name = "Crystallized Primal Root",
	display = "#", color=VIOLET,
	resolvers.nice_tile{tall=1},
	sound_moam = "creatures/treants/treeant_2",
	sound_die = {"creatures/treants/treeant_death_%d", 1, 2},
	sound_random = {"creatures/treants/treeant_%d", 1, 3},
	desc = _t[[This once great primal tree has been infused and corrupted by crystals growing wildly all over it. Such a terrible end.]],
	level_range = {30, nil}, exp_worth = 3 / 5,

	max_life = 300, life_rating = 20, fixed_rating = true,
	max_stamina = 200,

	combat = { dam=100, atk=10, apr=0, dammod={str=1.2}, sound="actions/melee_thud" },

	stats = { str=40, dex=10, cun=15, mag=20, wil=38, con=45 },

	rank = 4,
	size_category = 5,
	infravision = 10,
	instakill_immune = 1,
	stun_immune = 1,
	bleed_immune = 1,
	knockback_immune = 1,
	move_others = true,

	resists = { [DamageType.PHYSICAL] = 50, [DamageType.COLD] = 50, [DamageType.NATURE] = 25 },
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.auto_equip_filters("Brawler"),
	resolvers.drops{chance=100, nb=1, {tome_drops="boss"} },

	summon = {
		{type="immovable", subtype="crystal", number=3, hasxp=false},
		{properties={"is_treant"}, number=3, hasxp=false},
	},

	resolvers.talents{
		[Talents.T_STUN]={base=3, every=10},
		[Talents.T_GRAB]={base=3, every=10},
		[Talents.T_CLINCH]={base=3, every=10},
		[Talents.T_FROST_GRAB]={base=2, every=6, max=10},
		[Talents.T_PHANTASMAL_SHIELD]={base=2, every=6, max=10},
		[Talents.T_SUMMON]=1,
		[Talents.T_SUBCUTANEOUS_METALLISATION] = 1, 
		[Talents.T_SPINE_OF_THE_WORLD] = 1, 
		[Talents.T_MASSIVE_BLOW] = 1,
	},
	autolevel = "warriorwill",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(6, "infusion"),

	ingredient_on_death = "PRIMAL_CORE",

	on_die = function(self)
		game.zone.killed_roots = (game.zone.killed_roots or 0) + 1
		if game.zone.killed_roots >= 5 and not game.zone.killed_treant then
			world:gainAchievement("ORCS_MENDER", game.player)
		end
	end,
}
