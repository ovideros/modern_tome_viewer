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

load("/data/general/npcs/horror.lua", function(e) e.hide_level_tooltip = 1 end)

---------------------------------------------------------------------
-- The civil war fighters
---------------------------------------------------------------------

newEntity{ base="BASE_NPC_HORROR", define_as = "STORY_NPC_BASE",
	desc = _t[[You can not comprehend what you're seeing.
#{bold}##CRIMSON#These beings would squash you like a bug if you even tried to interfere in their combat.#{normal}#]],
	hide_level_tooltip = 1,
	level_range = {1000, 1000}, exp_worth = 0,
	max_life = 100000, life_rating = 90, fixed_rating = true,
	life_regen = 100000, -- They are here for the show, not really meant to die
	rank = 5,
	see_invisible = 50,
	no_breath = 1,
	instakill_immune = 1,
	stun_immune = 0.5,
	confusion_immune = 0.5,
	blind_immune = 0.5,
	infravision = 10,
	size_category = 3,
	rarity = false,
	faction = "neutral",
	difficulty_boosted = 1,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, FEET=1, HEAD=1, HANDS=1 },
	no_drops = 1,

	-- We do NOT want tactical AI, this is only for show and tactical would make stuff to obviously in sync
	ai = "dumb_talented_simple", ai_state = { talent_in=1, ai_move="move_astar", ai_target="grung_civil_war_target" },
	
	talent_max_range = resolvers.rngrange(2, 3),
	getTalentRadius = function(self, t) return math.min(mod.class.NPC.getTalentRadius(self, t), self.talent_max_range) end,

	on_takehit = function(self, value, src)
		if src.is_grung then
			self.grung_disturbed = true
			self:setTarget(nil)
			game.bignews:saySimple(120, "Grung made great being angry!")
		end
		return value
	end,

	postUseTalent = function(self, ...)
		if game.player:hasLOS(self.x, self.y) and game.player:canSee(self) and game.zone.grung_emote then
			game.zone.grung_emote(game.player, "watch_fight")
		end
		return mod.class.NPC.postUseTalent(self, ...)
	end,
}

newEntity{ base="STORY_NPC_BASE", define_as = "SHERTUL1",
	name = "Great Tentacly Being", subtype = "shertul",
	color = colors.RED,
	image = "npc/ancient_shertul_mage.png",
	resolvers.nice_tile{tall=1},
	civil_war_rarity = 1,
	mana_regen = 50,
	
	combat = { dam=resolvers.mbonus(25, 15), atk=500, apr=500, dammod={str=1} },
	stats = { str=80, dex=80, cun=80, mag=80, con=80, wil=80 },

	resolvers.talents{
		[Talents.T_SPINE_OF_THE_WORLD] = 1,
		[Talents.T_LUCKY_DAY] = 1,
		[Talents.T_INFERNO] = 100,
		[Talents.T_FIREFLASH] = 100,
		[Talents.T_MANATHRUST] = 100,
		[Talents.T_WILDFIRE] = 100,
		[Talents.T_SPELLCRAFT] = 100,
	},
}

newEntity{ base="STORY_NPC_BASE", define_as = "SHERTUL2",
	name = "Great Tentacly Being", subtype = "shertul",
	color = colors.YELLOW,
	image = "npc/ancient_shertul_psion.png",
	resolvers.nice_tile{tall=1},
	civil_war_rarity = 1,
	mana_regen = 50,
	
	combat = { dam=resolvers.mbonus(25, 15), atk=500, apr=500, dammod={str=1} },
	stats = { str=80, dex=80, cun=80, mag=80, con=80, wil=80 },

	resolvers.talents{
		[Talents.T_SPINE_OF_THE_WORLD] = 1,
		[Talents.T_LUCKY_DAY] = 1,
		[Talents.T_KINETIC_SHIELD] = 100,
		[Talents.T_THERMAL_SHIELD] = 100,
		[Talents.T_FORCEFIELD] = 100,
		[Talents.T_MIND_SEAR] = 100,
		[Talents.T_SYNAPTIC_STATIC] = 100,
		[Talents.T_MIND_STORM] = 100,
	},
}

newEntity{ base="STORY_NPC_BASE", define_as = "SHERTUL3",
	name = "Great Tentacly Being", subtype = "shertul",
	color = colors.GREY,
	image = "npc/ancient_shertul_bulwark.png",
	resolvers.nice_tile{tall=1},
	civil_war_rarity = 1,
	mana_regen = 50,
	
	combat = { dam=resolvers.mbonus(25, 15), atk=500, apr=500, dammod={str=1} },
	stats = { str=80, dex=80, cun=80, mag=80, con=80, wil=80 },

	resolvers.equip{
		{type="weapon", subtype="dagger", not_properties={"unique"}, ego_chance=-1000, autoreq=true},
		{type="weapon", subtype="dagger", not_properties={"unique"}, ego_chance=-1000, autoreq=true},
	},

	resolvers.talents{
		[Talents.T_SPINE_OF_THE_WORLD] = 1,
		[Talents.T_LUCKY_DAY] = 1,
		[Talents.T_RUSH] = 100,
		[Talents.T_WHIRLWIND] = 100,
		[Talents.T_GIANT_LEAP] = 100,
		[Talents.T_HEARTSEEKER] = 100,
	},
}

newEntity{ base="STORY_NPC_BASE", define_as = "SHERTUL4",
	name = "Great Tentacly Being", subtype = "shertul",
	color = colors.UMBER,
	image = "npc/ancient_shertul_berserker.png",
	resolvers.nice_tile{tall=1},
	civil_war_rarity = 1,
	mana_regen = 50,
	
	combat = { dam=resolvers.mbonus(25, 15), atk=500, apr=500, dammod={str=1} },
	stats = { str=80, dex=80, cun=80, mag=80, con=80, wil=80 },

	resolvers.equip{
		{type="weapon", subtype="greatmaul", not_properties={"unique"}, ego_chance=-1000, autoreq=true},
	},

	resolvers.talents{
		[Talents.T_SPINE_OF_THE_WORLD] = 1,
		[Talents.T_LUCKY_DAY] = 1,
		[Talents.T_RUSH] = 100,
		[Talents.T_DEATH_DANCE] = 100,
		[Talents.T_GIANT_LEAP] = 100,
		[Talents.T_STUNNING_BLOW] = 100,
	},
}

---------------------------------------------------------------------
-- The food
---------------------------------------------------------------------

newEntity{ --rodent base
	define_as = "BASE_NPC_RODENT",
	type = "vermin", subtype = "rodent",
	display = "r", color=colors.WHITE,
	can_multiply = 2,
	body = { INVEN = 10 },
	infravision = 10,
	sound_moam = {"creatures/rats/rat_hurt_%d", 1, 2},
	sound_die = {"creatures/rats/rat_die_%d", 1, 2},
	sound_random = {"creatures/rats/rat_%d", 1, 3},

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="flee_dmap", talent_in=3, },
	stats = { str=8, dex=15, mag=3, con=5 },
	combat = {sound="creatures/rats/rat_attack"},
	combat_armor = 1, combat_def = 1,
	rank = 1,
	size_category = 1,
	not_power_source = {arcane=true, technique_ranged=true},
	faction = "grung-food",
	difficulty_boosted = 1,

	resolvers.drops{chance=100, nb=1, {special_rarity="grung_food"} },	
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant brown rat", color=colors.UMBER,
	level_range = {1, 4}, exp_worth = 1,
	grung_food_npc = 1,
	max_life = resolvers.rngavg(15,20),
	combat = { dam=7, atk=0, apr=10 },
	resolvers.talents{
		[Talents.T_NIMBLE_MOVEMENTS]={base=0, every=3, max=5},
		[Talents.T_LACERATING_STRIKES]={base=0, every=3, max=5},
	},
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant rabbit", color=colors.UMBER,
	desc = _t[[Kill the wabbit, kill the wabbit, kill the wabbbbbiiiiiit.]],
	level_range = {1, 4}, exp_worth = 1,
	grung_food_npc = 1,
	max_life = resolvers.rngavg(20,30),
	combat = { dam=8, atk=0, apr=10 },
	resolvers.talents{
		[Talents.T_EVASION]={base=1, every=3, max=5},
		[Talents.T_DISENGAGE]={base=1, every=3, max=5},
	},
}
