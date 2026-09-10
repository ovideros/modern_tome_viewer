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

newEntity{
	define_as = "BASE_NPC_HETHUROTH", -- hethu goroth = foggy terror
	type = "elemental", subtype = "vapour",
	blood_color = colors.ANTIQUE_WHITE,
	display = "E", color=colors.ANTIQUE_WHITE,

	combat = { dam=resolvers.levelup(resolvers.mbonus(40, 15), 1, 1.2), atk=15, apr=15, dammod={cun=0.8}, damtype=DamageType.FIRE },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	steam_regen = 40,

	infravision = 10,
	life_rating = 8,
	rank = 2,
	size_category = 3,
	levitation = 1,


	autolevel = "rogue",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },
	stats = { mag=10, dex=16, cun=16, con=16 },

	resists = { [DamageType.PHYSICAL] = 10, [DamageType.FIRE] = 70, [DamageType.LIGHT] = 70, },

	no_breath = 1,
	poison_immune = 1,
	cut_immune = 1,
	disease_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	knockback_immune = 1,
	confusion_immune = 1,

	-- When killed, let the steam free!
	on_die = function(self)
		self:learnTalent(self.T_EMERGENCY_STEAM_PURGE, true, math.ceil(self.level / 10))
		self:forceUseTalent(self.T_EMERGENCY_STEAM_PURGE, {ignore_energy=true})
	end,
}

newEntity{ base = "BASE_NPC_HETHUROTH",
	name = "hethugoroth", color=colors.GREY,
	desc = _t[[A swirling mass of hot vapour animated into a semblance of life.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 0, combat_def = 20,
	on_melee_hit = { [DamageType.FIRE] = resolvers.mbonus(20, 10), },

	resolvers.talents{
		[Talents.T_FLAMETHROWER]={base=3, every=10, max=7},
	},
}

newEntity{ base = "BASE_NPC_HETHUROTH",
	name = "greater hethugoroth", color=colors.ANTIQUE_WHITE,
	desc = _t[[A swirling mass of hot vapour animated into a semblance of life.]],
	resolvers.nice_tile{tall=true},
	level_range = {12, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80), life_rating = 10,
	combat_armor = 0, combat_def = 20,
	on_melee_hit = { [DamageType.FIRE] = resolvers.mbonus(20, 10), },

	resolvers.talents{
		[Talents.T_FLAMETHROWER]={base=4, every=10, max=8},
		[Talents.T_BLASTWAVE]={base=3, every=10, max=7},
	},
	resolvers.sustains_at_birth(),
	on_die = function(self, src)
		if profile.mod.allow_build.tinker_annihilator then return end
		if src.resolveSource then src = src:resolveSource() end
		if not src.player then return end
		if not src:knowTalent(src.T_CREATE_TINKER) then return end

		src:grantQuest("orcs+annihilator")
		src:setQuestStatus("orcs+annihilator", engine.Quest.COMPLETED, "greater-hethugoroth")
	end,
}

newEntity{ base = "BASE_NPC_HETHUROTH",
	name = "ultimate hethugoroth", color=colors.WHITE,
	desc = _t[[A swirling mass of hot vapour animated into a semblance of life.]],
	resolvers.nice_tile{tall=true},
	level_range = {15, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 0, combat_def = 20,
	on_melee_hit = { [DamageType.FIRE] = resolvers.mbonus(20, 10), },

	ai = "tactical",
	autolevel = "dexmage",

	resolvers.talents{
		[Talents.T_FLAMETHROWER]={base=4, every=7},
		[Talents.T_BLASTWAVE]={base=4, every=7},
		[Talents.T_CLEANSING_FLAMES]={base=3, every=7},
		[Talents.T_BURNING_WAKE]={base=3, every=7},
		[Talents.T_CAUTERIZE]=1,
	},
	resolvers.sustains_at_birth(),
	on_die = function(self, src)
		if profile.mod.allow_build.tinker_annihilator then return end
		if src.resolveSource then src = src:resolveSource() end
		if not src.player then return end
		if not src:knowTalent(src.T_CREATE_TINKER) then return end

		src:grantQuest("orcs+annihilator")
		src:setQuestStatus("orcs+annihilator", engine.Quest.COMPLETED, "greater-hethugoroth")
	end,
}
