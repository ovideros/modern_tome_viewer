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

load("/data/general/npcs/horror-corrupted.lua", rarity(0))
load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_CORRUPTED_HORROR", define_as = "HALF_FORMED_DREM",
	dredge = 1,
	name = "half formed drem", color=colors.SLATE,
	resolvers.nice_tile{tall=1},
	desc = _t"A small faceless humanoid with vaguely Dwarven features.  Its waraxe and shield look battered, rusted, and generally in ill repair.",
	level_range = {1, nil}, exp_worth = 1,
	bad_drem_rarity = 1,

	combat = { atk=6, dammod={str=0.6} },
	max_life = resolvers.rngavg(30, 50),

	rank = 2,
	size_category = 2,
	autolevel = "warrior",

	open_door = true,

	resists = { [DamageType.BLIGHT] = 20, [DamageType.DARKNESS] = 20,  [DamageType.LIGHT] = - 20 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },

	resolvers.talents{
		[Talents.T_DREM_FRENZY]={base=1, every=5, max=5},
	},

	resolvers.sustains_at_birth(),
}

newEntity{ base="BASE_NPC_CORRUPTED_HORROR", define_as = "THE_DREMS",
	unique = true,
	name = "The Amalgamation", tint=colors.PURPLE,
	resolvers.nice_tile{tall=1},
	is_amalgamation = true,
	color=colors.VIOLET,
	desc = _t[[Creating a living being from scratch is not an easy process. There are plenty of things which can go wrong, including multiple eyes, surplus limbs, too few brains and multiple bodies being fused into a single, raging mass of flesh and bone. Despite how bulky the creature is, it moves with supple ease, quickly closing the gap between you and it.]],
	killer_message = _t"and absorbed into the foul thing",
	level_range = {20, nil}, exp_worth = 2,
	max_life = 250, life_rating = 25, fixed_rating = true,
	stats = { str=10, dex=10, cun=12, mag=20, con=10 },
	rank = 3.5,
	size_category = 4,
	infravision = 10,
	instakill_immune = 1,
	immune_possession = 1,
	no_difficulty_random_class = true,
	resists = {all = 25},
	combat_armor = 15, combat_def = 10,
	combat = { dam=resolvers.mbonus(45, 10), atk=2, apr=6, physspeed=2, dammod={str=1.2} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, TOOL=1 },
	resolvers.equip{{defined="CUT_DREM_ARM", random_art_replace={chance=35}, autoreq = true}},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="NOTE3"} },

	resolvers.talents{
		[Talents.T_DRAIN]={base=1, every=10},
		[Talents.T_MUTATED_HAND]={base=3, every=10},
		[Talents.T_SHED_SKIN]={base=3, every=10},
		[Talents.T_PUSTULENT_GROWTH]={base=3, every=10},
		[Talents.T_DECAYING_GROUNDS]={base=1, every=10},
		[Talents.T_AUGMENT_DESPAIR]={base=1, every=10},
	},

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1 },

	total_spawns = 0,
	drem_splits = 9.9,
	on_takehit = function(self, value)
		local p = math.floor((self.life - value) / self.max_life * 10)
		if p < self.drem_splits and self.drem_splits > 0 then
			for i = p, self.drem_splits do
				if self.total_spawns > 10 then break end -- Safety
				local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[engine.Map.ACTOR]=true})
				local npc = game.zone:makeEntity(game.level, "actor", {special_rarity="bad_drem_rarity", random_elite={no_loot_randart=true}}, nil, true)
				if npc and x then
					npc.make_escort = nil
					game.zone:addEntity(game.level, npc, "actor", x, y)
					game.logSeen(self, "#CRIMSON#As %s takes an other blow you see part of it split into a drem!", self:getName():capitalize())
					self.total_spawns = self.total_spawns + 1
					npc.energy.value = -2000
					npc.inc_damage.all = -50
				end
			end
			self.drem_splits = p - 0.1
		end
		return value
	end,
	resolvers.genericlast(function(e)
		-- Bonus loot due to zone difficulty
		for i = 1,1 do
			local CultsDLC = require "mod.class.CultsDLC"
			local art = CultsDLC.generateCorruptedItem()
			if art then e:addObject(e.INVEN_INVEN, art) end
		end
	end),
}
