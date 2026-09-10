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

load("/data/general/npcs/horror.lua")

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_HORROR", define_as = "HYPOSTASIS",
	unique = "Hypostasis of Entropy Forbidden Tome",
	name = "Unspeakable Thing",
	color=colors.VIOLET,
	desc = _t[[Through idiotic pride, one of the students has called this thing to your world. Thick, impenetrable darkness billows from its form, devouring all light around it. As the darkness touches you, you feel only one thing... Hunger. Bottomless, infinite hunger, as vast and unending as the void of space itself.]],
	image="invis.png",
	z = 16,
	embed_particles = {
		{name="hypostasis_entropy", rad=1, args={}},
	},
	level_range = {100, nil}, exp_worth = 3,
	max_life = 900, life_rating = 100, fixed_rating = true,
	life_regen = 70,
	stats = { str=100, dex=100, con=100, mag=100, wil=100, cun=100 },
	inc_stats = { str=80, dex=80, con=80, mag=80, wil=80, cun=80 },
	rank = 5,
	size_category = 4,
	infravision = 10,
	difficulty_boosted = 1,

	see_invisible = 150,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	resolvers.talents{
		[Talents.T_ENTROPIC_GIFT] = {base=8, every=5},
		[Talents.T_NETHERBLAST] = {base=8, every=5},
		[Talents.T_DARK_WHISPERS] = {base=8, every=5},
		[Talents.T_HIDEOUS_VISIONS] = {base=8, every=5},
		[Talents.T_ACCELERATE] = {base=8, every=5},
		[Talents.T_SWITCH] = {base=8, every=5},
		[Talents.T_TEMPORAL_BOLT] = {base=8, every=5},
		[Talents.T_ECHOES_FROM_THE_PAST] = {base=8, every=5},
		[Talents.T_CALL_SHADOWS] = {base=8, every=5},
		[Talents.T_SHADOW_WARRIORS] = {base=8, every=5},
		[Talents.T_SHADOW_MAGES] = {base=8, every=5},
		[Talents.T_FOCUS_SHADOWS] = {base=8, every=5},
		[Talents.T_SHADOW_EMPATHY] = {base=8, every=5},
		[Talents.T_SHADOW_DECOY] = {base=8, every=5},

		--[Talents.T_SUMMON] = 1,

		[Talents.T_CORRUPTED_SHELL] = 1,
		[Talents.T_LUCKY_DAY] = 1,
		[Talents.T_METEORIC_CRASH] = 1,
		[Talents.T_ARCANE_MIGHT] = 1,
	},
	resolvers.sustains_at_birth(),

	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
--	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(6, {"healing infusion", "regeneration infusion", "shielding rune", "invisibility rune", "movement infusion", "wild infusion"}),

	on_act = function(self)
		local p = game:getPlayer(true)
		if p.x and not p:hasEffect(p.EFF_TOTAL_COLLAPSE) and self:hasLOS(p.x, p.y) then
			p:setEffect(p.EFF_TOTAL_COLLAPSE, 1, {src=self})
		end
	end,
}

newEntity{
	define_as = "THE_TEACHER",
	type = "unknown", subtype = "unknown",
	blood_color = colors.BLUE,
	name = "The Teacher",
	resolvers.nice_tile{tall=1},
	display = "E", color=colors.BLUE,
	desc = _t[[A being from another world, or so it claims. Despite its wholly alien appearance, it is not particularly threatening nor does it appear to be malevolent. It will not say how it learned to manipulate the powers of entropy, merely stating that it has been to many different places and experienced many different things.]],
	faction = "sanctuary-of-horrors",
	never_anger = 1,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	infravision = 10,
	life_rating = 14, fixed_rating = 1,
	life_regen = 30,
	rank = 3.5,
	size_category = 3,
	levitation = 1,
	difficulty_boosted = 1,

	autolevel = "caster",
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },
	stats = { str=10, dex=10, mag=100, con=20 },

	resists = { [DamageType.ARCANE] = 30 },

	never_move = 1,
	no_breath = 1,
	poison_immune = 1,
	disease_immune = 1,
	cut_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	knockback_immune = 1,
	confusion_immune = 1,
	power_source = {unknown=true},

	level_range = {30, 30}, exp_worth = 1,
	combat_armor = 0, combat_def = 0,

	resolvers.talents{
		[Talents.T_ENTROPIC_GIFT] = {base=5, every=5},
		[Talents.T_NETHERBLAST] = {base=5, every=5},
		[Talents.T_VOID_BLAST]={base=5, every=7},
	},
}

newEntity{define_as="DUMMY",
	type = "training", subtype = "dummy",
	name = "Training Dummy", color=colors.GREY,
	desc = _t"Training dummy. Use it to train.", image = "npc/lure.png",
	display = 'T',
	level_range = {1, 1}, exp_worth = 0,
	rank = 3,
	max_life = 300000, life_rating = 0,
	life_regen = 300000,
	never_move = 1,
	training_dummy = 1,
	difficulty_boosted = 1,

	on_temporary_effect_added = function(self, eff_id, e, p)
		mod.class.NPC.on_temporary_effect_added(self, eff_id, e, p)

		if game.zone.current_lesson == 1 and eff_id == self.EFF_ENTROPIC_GIFT and p.src == game.player then
			game.zone.lesson1_effects = game.zone.lesson1_effects + 1
			game.zone.update_lesson = true
			game.zone:to_lesson2()
		end
	end,

	takeHit = function(self, value, src, death_note)
		if game.zone.current_lesson == 2 and death_note and death_note.source_talent and death_note.source_talent.id == "T_NETHERBLAST" and src == game.player and not self.turn_procs.netherblast_training then
			game.zone.lesson2_hits = game.zone.lesson2_hits + 1
			game.zone.update_lesson = true
			game.zone:to_lesson3()
			self.turn_procs.netherblast_training = true
		end
		return mod.class.NPC.takeHit(self, value, src, death_note)
	end,

	on_fatebreaker_call = function(self, src)
		if game.zone.current_lesson == 3 and src == game.player then
			game.zone.lesson3_cast = game.zone.lesson3_cast + 1
			game.zone.update_lesson = true
			game.zone:to_lesson4()
		end
	end
}
newEntity{base="DUMMY", define_as="CENTRAL_DUMMY", is_central_dummy=1}

------ Students
newEntity{
	define_as = "BASE_NPC_STUDENT",
	type = "humanoid", subtype = "human",
	display = "h", color=colors.WHITE,
	faction = "sanctuary-of-horrors",
	never_anger = 1,

	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 3,

	life_rating = 10,
	rank = 2,
	size_category = 3,
	is_student = 1,

	open_door = true,

	resolvers.racial(),

	autolevel = "warrior",
	ai = "none", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=12, dex=8, mag=6, con=10 },

	resolvers.talents{
		[Talents.T_ENTROPIC_GIFT]=1,
	},
	resolvers.inscription("INFUSION:_HEALING", {cooldown=10, heal=450}),
	ai_state = { talent_in=1, },

	autolevel = "caster",
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
	},

	get_dummy = function(self, central)
		local list = {}
		for uid, e in pairs(game.level.entities) do
			if e.training_dummy and central and e.is_central_dummy then return e end
			if e.training_dummy then list[#list+1] = {e=e, d=core.fov.distance(self.x, self.y, e.x, e.y)} end
		end
		if #list > 0 then
			table.sort(list, "d")
			return list[1].e
		end
		return self -- uhuh
	end,

	on_act = function(self)
		if game.zone.current_lesson == 1 then
			if rng.percent(50) then return end
			if not self:isTalentCoolingDown("T_INFUSION:_HEALING_1") then
				self:forceUseTalent("T_INFUSION:_HEALING_1", {ignore_energy=true})
				self:useEnergy()
			elseif not self:isTalentCoolingDown("T_ENTROPIC_GIFT") then
				self:setTarget(self:get_dummy())
				self:forceUseTalent("T_ENTROPIC_GIFT", {ignore_energy=true})
				self:useEnergy()
			end
		elseif game.zone.current_lesson == 2 then
			if rng.percent(50) then return end
			if not self:isTalentCoolingDown("T_NETHERBLAST") then
				self:setTarget(self:get_dummy())
				self:forceUseTalent("T_NETHERBLAST", {ignore_energy=true})
				self:useEnergy()
			elseif not self:isTalentCoolingDown("T_INFUSION:_HEALING_1") then
				self:forceUseTalent("T_INFUSION:_HEALING_1", {ignore_energy=true})
				self:useEnergy()
			elseif not self:isTalentCoolingDown("T_ENTROPIC_GIFT") then
				self:setTarget(self:get_dummy())
				self:forceUseTalent("T_ENTROPIC_GIFT", {ignore_energy=true})
				self:useEnergy()
			end
		elseif game.zone.current_lesson == 3 then
			if self.life < 10 and not self:isTalentCoolingDown("T_FATEBREAKER") and not self:isTalentCoolingDown("T_NETHERBLAST") then
				self:setTarget(self:get_dummy())
				self:forceUseTalent("T_FATEBREAKER", {ignore_energy=true})
				self:useEnergy()
			elseif self.life < 10 and not self:isTalentCoolingDown("T_NETHERBLAST") then
				self:setTarget(self)
				self:forceUseTalent("T_FATEBREAKER", {ignore_energy=true})
				self:useEnergy()
			elseif not self:isTalentCoolingDown("T_NETHERBLAST") then
				self:setTarget(self:get_dummy())
				self:forceUseTalent("T_NETHERBLAST", {ignore_energy=true})
				self:useEnergy()
			end
		elseif game.zone.current_lesson == 4 then
			if rng.percent(50) then return end
			if not self:isTalentCoolingDown("T_DARK_WHISPERS") then
				self:setTarget(self:get_dummy(true))
				self:forceUseTalent("T_DARK_WHISPERS", {ignore_energy=true})
				self:useEnergy()
			end
		end
	end,
}

newEntity{ base = "BASE_NPC_STUDENT", define_as = "HUMAN_STUDENT",
	name = "human student", color=colors.LIGHT_BLUE,
	desc = _t[[A human student.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	image = "player/cornac_male.png",
	max_life = resolvers.rngavg(70,80),
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_STUDENT", define_as = "SHALORE_STUDENT",
	subtype = "shalore",
	name = "shalore student", color=colors.LIGHT_BLUE,
	desc = _t[[A shalore student.]],
	image = "player/shalore_male.png",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.racial(),
}

newEntity{ base = "BASE_NPC_STUDENT", define_as = "HALFLING_STUDENT",
	subtype = "halfling",
	name = "halfling student", color=colors.LIGHT_BLUE,
	image = "player/halfling_female.png",
	desc = _t[[A halfling student.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.racial(),
}
