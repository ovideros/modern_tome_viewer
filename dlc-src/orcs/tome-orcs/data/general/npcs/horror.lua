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

newEntity{ base = "BASE_NPC_HORROR",
	name = "saw horror", color=colors.GREY,
	desc = _t"Oh. Oh no. Where did it get those?",
	resolvers.nice_tile{tall=true},
	level_range = {25, nil}, exp_worth = 1,
	rarity = 2,
	rank = 3,
	levitate=1,
	max_psi= 300,
	psi_regen= 4,
	size_category = 3,
	autolevel = "wildcaster",
	max_life = resolvers.rngavg(70, 95),
	life_rating = 14,
	life_regen = 0.25,
	combat_armor = 15, combat_def = 24,

	rnd_boss_init = function(self, data)
		self.combat_physspeed = math.max(1, self.combat_physspeed - 2.5)  -- A bit more sanity when randbossed
	end,
	
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, ally_compassion=0 },

	on_melee_hit = {[DamageType.PHYSICALBLEED]=resolvers.mbonus(32, 10)},
	combat = { dam=resolvers.levelup(resolvers.rngavg(16,22), 1, 1.5), atk=resolvers.levelup(18, 1, 1), apr=4, dammod={wil=0.25, cun=0.1}, damtype=engine.DamageType.PHYSICALBLEED, },
	combat_physspeed = 5, --Crazy fast attack rate

	resists = {[DamageType.PHYSICAL] = 15, [DamageType.MIND] = 50, [DamageType.ARCANE] = -20},

	resolvers.talents{
		[Talents.T_SAW_STORM]={base=4, every=5, max=10}, --Need saw particle
		[Talents.T_IMPLODE]={base=2, every=5, max=5},
		[Talents.T_RAZOR_SAW]={base=3, every=4, max=7},
		[Talents.T_PSIONIC_PULL]={base=3, every=6, max=7},
		[Talents.T_KINETIC_AURA]={base=3, every=4, max=9},
		[Talents.T_KINETIC_SHIELD]={base=3, every=3, max=9},
		[Talents.T_KINETIC_LEECH]={base=3, every=5, max=9},
	},
	resolvers.sustains_at_birth(),
}