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
	name = "searing horror", color=colors.GOLD,
	desc = _t"And you thought radiant horrors were bad.",
	resolvers.nice_tile{tall=1},
	level_range = {40, nil}, exp_worth = 2,
	rarity = 12,
	rank = 3.5,
	autolevel = "caster",
	max_life = 400, life_rating = 25,
	combat_armor = 20, combat_def = 10,
	combat = { dam=resolvers.levelup(resolvers.mbonus(100, 15), 1, 1), atk=500, apr=0, dammod={mag=1.2} },
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },
	lite = 5,

	resists = {all = 40, [DamageType.LIGHT] = 100, [DamageType.FIRE] = 100},
	damage_affinity = { [DamageType.LIGHT] = 50,  [DamageType.FIRE] = 50, },

	resolvers.drops{chance=10, nb=1, {defined="GLOWING_CORE"} },

	confusion_immune = 1,
	blind_immune = 1,
	see_invisible = 20,

	resolvers.talents{
		[Talents.T_CHANT_OF_FORTITUDE] = {base=10, every=6},
		[Talents.T_CIRCLE_OF_BLAZING_LIGHT] = {base=10, every=6},
		[Talents.T_SEARING_LIGHT] = {base=10, every=6},
		[Talents.T_FIREBEAM] = {base=10, every=6},
		[Talents.T_SUNBURST] = {base=10, every=6},
		[Talents.T_SUN_FLARE] = {base=10, every=6},
		[Talents.T_PROVIDENCE] = {base=10, every=6},
		[Talents.T_HEALING_LIGHT] = {base=10, every=6},
		[Talents.T_BARRIER] = {base=10, every=6},
		[Talents.T_BODY_OF_FIRE] = {base=10, every=6},
		[Talents.T_WILDFIRE] = {base=10, every=6},
		[Talents.T_IRRESISTIBLE_SUN]=1,
		[Talents.T_SUMMON]=1,
	},

	searing_horror_buff_friends_cd = 6,
	on_act = function(self)
		if not self.searing_horror_buff_friends_cd then return end
		self.searing_horror_buff_friends_cd = self.searing_horror_buff_friends_cd - 1
		if self.searing_horror_buff_friends_cd <= 0 then
			self.searing_horror_buff_friends_cd = rng.range(5, 10)
			local ok = false
			self:project({type="ball", radius=3}, self.x, self.y, function(px, py)
				local tgt = game.level.map(px, py, engine.Map.ACTOR)
				if not tgt or (tgt.name ~= "luminous horror" and tgt.name ~= "radiant horror") then return end
				tgt:setEffect(tgt.EFF_REFLECTIVE_SKIN, 2, {power=70})
				ok = true
			end)
			if ok then
				game.logSeen("#GOLD#%s emits a light pulse that strengthens its luminous and radiant friends!#LAST#", self:getName():capitalize())
				game.bignews:say(120, "#GOLD#The Searing Horror adds a reflective shield to its allies!#LAST#")
			end
		end
	end,

	resolvers.sustains_at_birth(),

	make_escort = {
		{type="horror", subtype="eldritch", name="radiant horror", number=2},
	},
	summon = {
		{type="horror", subtype="eldritch", name="luminous horror", number=1, hasxp=false},
	},
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "ravaging entropic rip", color=colors.VIOLET,
	desc = _t"A strange crystal/tear in the fabric of reality. You dare not think how it came to be.",
	level_range = {20, nil},
	rarity = 5,
	rank = 3,
	autolevel = "caster",
	max_life = 190, life_rating = 16,
	insanity_regen = 25,
	combat_armor = 25, combat_def = 0,
	combat = { damtype=DamageType.VOID, dam=resolvers.levelup(resolvers.mbonus(100, 15), 1, 1), atk=500, apr=0, dammod={mag=1.2} },
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },

	resists = {all = 25},
	damage_affinity = { [DamageType.TEMPORAL] = 20,  [DamageType.DARKNESS] = 20, },

	blind_immune = 1,
	see_invisible = 20,
	ignore_entropic_wasting = 1,

	combat_spellcrit = 50,
	inc_damage = {all=-50},

	talent_cd_reduction = {
		[Talents.T_NETHERBLAST] = 1,
	},
	resolvers.talents{
		[Talents.T_ENTROPIC_GIFT] = {base=3, every=6},
		[Talents.T_REALITY_FRACTURE] = {base=3, every=6},
		[Talents.T_ZERO_POINT_ENERGY] = {base=3, every=6},
		[Talents.T_QUANTUM_TUNNELLING] = {base=3, every=6},
		[Talents.T_NETHERBLAST] = {base=3, every=6},
	},
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "bursting entropic shard", color=colors.PURPLE,
	desc = _t"A strange tall crystal pusling with nether energies. It's broken. Tentacles come out of it to get you! #{bold}#RUN!#{normal}#",
	resolvers.nice_tile{tall=1},
	embed_particles = {
		{name="bursting_entropic_shader", rad=1, args={}},
	},
	level_range = {30, nil},
	rarity = 7,
	rank = 3,
	autolevel = "warriormage",
	max_life = 190, life_rating = 16,
	insanity_regen = 25,
	combat_armor = 25, combat_def = 0,
	combat = { damtype=DamageType.VOID, dam=resolvers.levelup(resolvers.mbonus(100, 15), 1, 1), atk=500, apr=0, dammod={mag=1.2} },
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },

	body = { MAINHAND=1, OFFHAND=1, INVEN = 10 },

	resists = {all = 25},
	damage_affinity = { [DamageType.TEMPORAL] = 20,  [DamageType.DARKNESS] = 20, },

	blind_immune = 1,
	see_invisible = 20,
	ignore_entropic_wasting = 1,

	combat_spellcrit = 70,
	inc_damage = {all=-35},

	resolvers.talents{
		[Talents.T_ENTROPIC_GIFT] = {base=3, every=6},
		[Talents.T_REALITY_FRACTURE] = {base=3, every=6},
		[Talents.T_ZERO_POINT_ENERGY] = {base=3, every=6},
		[Talents.T_QUANTUM_TUNNELLING] = {base=3, every=6},
		[Talents.T_PIERCE_THE_VEIL] = {base=3, every=6},
		[Talents.T_NETHERBLAST] = {base=3, every=6},
		[Talents.T_MUTATED_HAND] = {base=5, every=6},
		[Talents.T_TENDRILS_ERUPTION] = {base=5, every=6},
		[Talents.T_TENTACLE_CONSTRICT] = {base=5, every=6},
	},
	resolvers.sustains_at_birth(),

	make_escort = {
		{type="horror", subtype="eldritch", name="ravaging entropic rip", number=2},
	},
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "nethergate", color=colors.PURPLE,
	desc = _t"A strange portal of nether energies, it somehow feels alive itself.",
	image = "npc/horror_eldritch_nethergate_middle.png",
	resolvers.nice_tile{tall=1},
	embed_particles = {
		{name="nethergate_shader", rad=1, args={}},
	},
	level_range = {30, nil},
	rarity = 15,
	rank = 3,
	autolevel = "warriormage",
	max_life = 300, life_rating = 20,
	insanity_regen = 25, equilibrium_regen = -50,
	combat_armor = 0, combat_def = 0,
	combat = { damtype=DamageType.VOID, dam=resolvers.levelup(resolvers.mbonus(100, 15), 1, 1), atk=500, apr=0, dammod={mag=1.2} },
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },
	dont_pass_target = true,
	never_move = 1,

	body = { MAINHAND=1, OFFHAND=1, INVEN = 10 },

	resists = {all = 25},
	damage_affinity = { [DamageType.TEMPORAL] = 20,  [DamageType.DARKNESS] = 20, },

	blind_immune = 1,
	see_invisible = 20,
	ignore_entropic_wasting = 1,

	talent_cd_reduction = {
		[Talents.T_SUMMON] = 1000,
	},
	resolvers.talents{
		[Talents.T_ENTROPIC_GIFT] = {base=3, every=6},
		[Talents.T_NETHERBLAST] = {base=3, every=6},
		[Talents.T_DARK_WHISPERS] = {base=3, every=6},
		[Talents.T_HIDEOUS_VISIONS] = {base=3, every=6},
		[Talents.T_SUMMON] = 1,
	},
	resolvers.sustains_at_birth(),

	nethergate_inactive = true,
	custom_tooltip = function(self)
		if self.nethergate_inactive then
			return tstring{{"color", "LIGHT_BLUE"}, _t"It looks inactive and dormant for now. Maybe try to not wake it up."}
		else
			return tstring{{"color", "LIGHT_RED"}, _t"It looks active and you can feel dark energies coming out of it."}
		end
	end,
	become_nasty_gate = function(self)
		if not self.nethergate_inactive then return end
		self.nethergate_inactive = nil
		for _, ps in ipairs(self:getParticlesList("all")) do
			if ps.def == "nethergate_shader" then self:removeParticles(ps) break end
		end
		self:removeParticles(self.sleep_particle)
		local Particles = require "engine.Particles"
		self:addParticles(Particles.new("nethergate_shader", 1, {awaken=1}))
	end,
	on_act = function(self)
		if self.nethergate_inactive then
			local tgts = self:projectCollect({type="ball", radius=10}, self.x, self.y, engine.Map.ACTOR, "hostile")
			local power = 0
			for target, data in pairs(tgts) do
				power = power + 11 - data.dist
			end
			if power > 0 and rng.percent(power) then
				self:become_nasty_gate()
				game.logSeen(self, "#PURPLE#The nethergate feels a presence nearby and wakes up!")
			else
				self:useEnergy() -- Always use energy when in the sleep state
			end
		end
	end,
	on_takehit = function(self, value, src)
		if value > 0 and self.nethergate_inactive then
			self:become_nasty_gate()
			game.logSeen(self, "#PURPLE#The nethergate absorbs the attack and stirs, reactivating...")
			return 0 -- 'cause I'm evil
		end
		return value
	end,

	summon = {
		{type="horror", number=2, hasxp=false},
	},
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "netherworm mass", color=colors.PURPLE,
	desc = _t"A disgusting mass of distorted worms, slithering towards you.",
	level_range = {12, nil},
	rarity = 1,
	rank = 2,
	autolevel = "warrior",
	max_life = 150, life_rating = 11,
	insanity_regen = 25,
	combat_armor = 0, combat_def = 10,
	combat = { damtype=DamageType.VOID, dam=resolvers.levelup(resolvers.mbonus(100, 15), 1, 1), atk=500, apr=resolvers.levelup(resolvers.mbonus(50, 5), 1, 1) },
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },

	body = { MAINHAND=1, OFFHAND=1, INVEN = 10 },

	see_invisible = 20,

	can_multiply = 2,
	resolvers.talents{
		[Talents.T_MUTATED_HAND] = {base=1, every=6},
		[Talents.T_MULTIPLY] = 1,
	},
	resolvers.sustains_at_birth(),

	life_leech_chance = 100,
	life_leech_value = 100,
	heal = function(self, val, ...)
		if self.summoner then
			if self.summoner:attr("dead") or not game.level:hasEntity(self.summoner) then
				self.summoner = nil
			else
				game.logSeen(self, "%s duplicates the healing forces to %s!", self:getName():capitalize(), self.summoner:getName())
				self.summoner:heal(val, self)
			end
		end
		return mod.class.NPC.heal(self, val, ...)
	end,
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "giant netherworm", color=colors.VIOLET,
	desc = _t"A disgusting mass of distorted worms, slithering towards you.",
	resolvers.nice_tile{tall=1},
	level_range = {20, nil},
	rarity = 4,
	rank = 2,
	autolevel = "warrior",
	max_life = 150, life_rating = 11,
	insanity_regen = 25,
	combat_armor = 0, combat_def = 10,
	combat = { damtype=DamageType.VOID, dam=resolvers.levelup(resolvers.mbonus(100, 15), 1, 1), atk=500, apr=resolvers.levelup(resolvers.mbonus(50, 5), 1, 1) },
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },

	body = { MAINHAND=1, OFFHAND=1, INVEN = 10 },

	see_invisible = 20,

	resolvers.talents{
		[Talents.T_MUTATED_HAND] = {base=1, every=6},
		[Talents.T_ENTROPIC_GIFT] = {base=1, every=6},
		[Talents.T_NIHIL] = {base=1, every=6},
		[Talents.T_LASH_OUT] = {base=1, every=6},
		[Talents.T_TENDRILS_ERUPTION] = {base=1, every=6},
		[Talents.T_SUMMON] = 1,
	},
	resolvers.sustains_at_birth(),

	life_leech_chance = 100,
	life_leech_value = 100,

	make_escort = {
		{type="horror", subtype="eldritch", name="netherworm mass", number=3, post=function(self, m) m.summoner = self end},
	},
	summon = {
		{type="horror", subtype="eldritch", name="netherworm mass", number=3, hasxp=false},
	},
}

newEntity{ base = "BASE_NPC_HORROR",
	name = "fearful symmetry", color=colors.VIOLET,
	desc = _t"A strange vortex of malevolent triangles.",
	resolvers.nice_tile{tall=1},
	level_range = {20, nil},
	rarity = 8,
	rank = 3,
	autolevel = "wildcaster",
	max_life = 200, life_rating = 12,
	insanity_regen = 25,
	combat_armor = 0, combat_def = 10,
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },
	global_speed = 2,

	body = { MAINHAND=1, OFFHAND=1, INVEN = 10 },

	see_invisible = 20,

	resolvers.talents{
		[Talents.T_ENTROPIC_GIFT] = {base=3, every=6},
		[Talents.T_INSTILL_FEAR] = {base=4, every=6},
		[Talents.T_HEIGHTEN_FEAR] = {base=4, every=6},
		[Talents.T_PANIC] = {base=4, every=6},
		[Talents.T_DARK_WHISPERS] = {base=4, every=6},
		[Talents.T_SANITY_WARP] = {base=4, every=6},
		[Talents.T_HIDEOUS_VISIONS] = {base=4, every=6},
		[Talents.T_CACOPHONY] = {base=4, every=6},
	},
	resolvers.sustains_at_birth(),

	make_escort = {
		{type="horror", subtype="eldritch", number=2, post=function(self, m) m.summer = self end},
	},
}
