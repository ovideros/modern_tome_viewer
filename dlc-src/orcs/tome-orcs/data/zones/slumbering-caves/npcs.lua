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

load("/data/general/npcs/horror.lua", rarity(0))
-- load("/data/general/npcs/horror-corrupted.lua", rarity(0))
load("/data/general/npcs/horror-undead.lua", rarity(0))
load("/data-orcs/general/npcs/titan.lua", rarity(0))

--load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_HORROR", define_as = "BASE_NPC_AMAKTHEL",
	color = colors.GREY,
	level_range = {75, nil}, exp_worth = 0.2,
	resolvers.nice_tile{tall=1},
	max_life = 1000000000, life_rating = 0, fixed_rating = true,
	faction = "amakthel",
	infravision = 20,
	rank = 10,
	rarity = false,
	no_breath = 1,
	size_category = 4,
	knockback_immune = 1,
	teleport_immune = 1,
	never_move = 1,
	never_anger = true,
	perma_slumber = true,
	resolvers.talents{
		[Talents.T_AMAKTHEL_SLUMBER] = 1,
		[Talents.T_AMAKTHEL_TENTACLE_SPAWN] = 1,
	},
	resolvers.sustains_at_birth(),
	on_targeted = function(self, act)
		-- avoid summons targeting amakthel body parts 
		if game.party:hasMember(act) then
			local m = game.level:findEntity{define_as="SHERTUL_PRIEST"}
			if m then act:setTarget(m) end
		end
	end,
}

newEntity{ base="BASE_NPC_AMAKTHEL", define_as = "AMAKTHEL_HAND",
	name = "Amakthel's Hand", type = "god", subtype = "eyal", unique = true,
	color = colors.PURPLE,
	desc = _t[[You never thought this could even exist. You certainly never thought you'd encounter it. But this is true, in front of you stands a piece of Amakthel himself.
The god that myths say was slain by the Sher'tul, themselves nothing but a myth.
But there it is, half alive, half dead but you can feel his thoughts in your head, there is no mistake: #{bold}#The Dead God is here!#{normal}#]],

	tentacle_summon = "SPIKED_TENTACLE", tentacle_summon_nb = 5,

	combat = { dam=resolvers.mbonus(25, 15), atk=500, apr=500, dammod={str=1} },

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=1 },
	resolvers.talents{
		[Talents.T_CALL_OF_AMAKTHEL] = 1,
	},
	talent_cd_reduction={[Talents.T_CALL_OF_AMAKTHEL]=-3, },
}

newEntity{ base="BASE_NPC_AMAKTHEL", define_as = "AMAKTHEL_MOUTH",
	name = "Amakthel's Mouth", type = "god", subtype = "eyal", unique = true,
	color = colors.PURPLE,
	desc = _t[[You never thought this could even exist. You certainly never thought you'd encounter it. But this is true, in front of you stands a piece of Amakthel himself.
The god that myths say was slain by the Sher'tul, themselves nothing but a myth.
But there it is, half alive, half dead but you can feel his thoughts in your head, there is no mistake: #{bold}#The Dead God is here!#{normal}#]],

	combat = { dam=resolvers.mbonus(25, 15), atk=500, apr=500, dammod={str=1} },

	tentacle_summon = "OOZING_TENTACLE",

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1 },
	resolvers.talents{
		[Talents.T_CURSE_OF_AMAKTHEL] = 1,
	},

	on_act = function(self)
		if self.perma_slumber then return end
		local target = self:getTarget()
		if not target then return end
		local p = game:getPlayer(true)
		if self.x and p.x and core.fov.distance(self.x, self.y, p.x, p.y) > 15 then
			game.bignews:saySimple(60, "#PURPLE#%s shouts: 'YOU DO NOT GET AWAY!'", self:getName())
			game.log("#PURPLE#%s shouts: 'YOU DO NOT GET AWAY!'", self:getName())
			game.level.map:particleEmitter(p.x, p.y, 1, "teleport")
			p:teleportRandom(self.x, self.y, 8)
			game.level.map:particleEmitter(p.x, p.y, 1, "teleport")

			-- Grab the priest too
			for uid, e in pairs(game.level.entities) do if e.define_as == "SHERTUL_PRIEST" then
				game.level.map:particleEmitter(e.x, e.y, 1, "teleport")
				e:teleportRandom(self.x, self.y, 8)
				game.level.map:particleEmitter(e.x, e.y, 1, "teleport")
			end end
		end
	end,
}

newEntity{ base="BASE_NPC_AMAKTHEL", define_as = "AMAKTHEL_EYE",
	name = "Amakthel's Eye", type = "god", subtype = "eyal", unique = true,
	color = colors.PURPLE,
	desc = _t[[You never thought this could even exist. You certainly never thought you'd encounter it. But this is true, in front of you stands a piece of Amakthel himself.
The god that myths say was slain by the Sher'tul, themselves nothing but a myth.
But there it is, half alive, half dead but you can feel his thoughts in your head, there is no mistake: #{bold}#The Dead God is here!#{normal}#]],

	tentacle_summon = "EYED_TENTACLE",

	combat = { dam=resolvers.mbonus(25, 15), atk=500, apr=500, dammod={str=1} },

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1 },

	resolvers.talents{
		[Talents.T_TEMPORAL_RIPPLES] = 1,
	},
}

newEntity{ base="BASE_NPC_HORROR", define_as = "SPIKED_TENTACLE",
	name = "spiked tentacle",
	color = colors.GREY,
	desc = _t[[A huge tentacle, ready to crush you with its many spikes.]],
	resolvers.nice_tile{tall=1},
	level_range = {50, nil}, exp_worth = 0,
	max_life = 100, life_rating = 15, fixed_rating = true,
	rank = 3,
	no_breath = 1,
	size_category = 2,
	rarity = false,

	knockback_immune = 1,
	teleport_immune = 1,
	never_anger = true,

	combat = { dam=resolvers.mbonus(55, 110), atk=500, apr=500, dammod={str=1} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_astar" },

	resolvers.talents{
		[Talents.T_CONSTRICT] = {base=5, every=5},
	},
}

newEntity{ base="BASE_NPC_HORROR", define_as = "OOZING_TENTACLE",
	name = "oozing tentacle",
	color = colors.GREY,
	desc = _t[[Ooze pours out of this disgusting tentacle.]],
	resolvers.nice_tile{tall=1},
	level_range = {50, nil}, exp_worth = 0,
	max_life = 100, life_rating = 13, fixed_rating = true,
	rank = 3,
	no_breath = 1,
	size_category = 2,
	rarity = false,

	knockback_immune = 1,
	teleport_immune = 1,
	never_anger = true,

	combat = { dam=resolvers.mbonus(15, 5), atk=500, apr=500, dammod={str=1} },

	autolevel = "wildcaster",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_astar" },

	resolvers.talents{
		[Talents.T_GRASPING_MOSS] = {base=5, every=5},
		[Talents.T_SLIPPERY_MOSS] = {base=5, every=5},
	}
}

newEntity{ base="BASE_NPC_HORROR", define_as = "EYED_TENTACLE",
	name = "eyed tentacle",
	color = colors.GREY,
	desc = _t[[A single malevolent eye is set atop this tentacle. And it watches you.]],
	resolvers.nice_tile{tall=1},
	level_range = {50, nil}, exp_worth = 0,
	max_life = 100, life_rating = 13, fixed_rating = true,
	rank = 3,
	no_breath = 1,
	size_category = 2,
	rarity = false,

	knockback_immune = 1,
	teleport_immune = 1,
	never_anger = true,

	combat = { dam=resolvers.mbonus(15, 15), atk=500, apr=500, dammod={str=1} },

	autolevel = "wildcaster",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_astar" },

	resolvers.talents{
		[Talents.T_NEGATIVE_BIOFEEDBACK] = {base=5, every=5},
		[Talents.T_PSYCHIC_LOBOTOMY] = {base=5, every=5},
		[Talents.T_MIND_SEAR] = {base=5, every=5},
	},
}

newEntity{ base="BASE_NPC_HORROR", define_as = "SHERTUL_PRIEST",
	name = "Sher'Tul High Priest", subtype = "shertul", unique = true,
	color = colors.PURPLE,
	desc = _t[[So they do exist! Sher'Tul! The stuff of myth and legends. The stuff of terror. The stuff of nightmares. The stuff of unlimited power. The race that turned on the gods of old and actually won. This one seems intent on resurrecting Amakthel, the most powerful of all the gods. You do not know why but this cannot happen or all Orcs, and the world, will be doomed.]],
	resolvers.nice_tile{tall=1},
	level_range = {75, nil}, exp_worth = 3,
	max_life = 1000, life_rating = 40, fixed_rating = true,
	rank = 5,
	never_anger = true,
	see_invisible = 50,
	no_breath = 1,
	instakill_immune = 1,
	stun_immune = 0.5,
	confusion_immune = 0.5,
	blind_immune = 0.5,
	infravision = 10,
	size_category = 3,
	rarity = false,
	positive_regen = 5, negative_regen = 5, vim_regen = 5,
	
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, FEET=1, HEAD=1, HANDS=1 },
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"}},
	resolvers.drops{chance=100, nb=1, {defined="GARDANION"} },

	no_auto_resists = true,
	resists = { all = 40, },

	combat = { dam=resolvers.mbonus(25, 15), atk=500, apr=500, dammod={str=1} },
	stats = { str=80, dex=80, cun=80, mag=80, con=80, wil=80 },

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar" },
	
	resolvers.talents{
		[Talents.T_SUBCUTANEOUS_METALLISATION] = 1,
		[Talents.T_TEMPORAL_FORM] = 1,
		[Talents.T_LUCKY_DAY] = 1,
		[Talents.T_PLASMA_BOLT] = {base=7, every=5},
		[Talents.T_NEBULA_SPEAR] = {base=7, every=5},
		[Talents.T_SOLAR_WIND] = {base=5, every=5, max=8},
		[Talents.T_LUCENT_WRATH] = {base=7, every=5},
		[Talents.T_SUPERNOVA] = {base=7, every=5},
		[Talents.T_GALACTIC_PULSE] = {base=7, every=5},
		[Talents.T_MOONLIGHT_RAY] = {base=7, every=5},
		[Talents.T_STARFALL] = {base=7, every=5},
	},

	awaken_body_part = function(self, kind, m)
		m.perma_slumber = false
		m.silent_slumber = true
		m:forceUseTalent(m.T_AMAKTHEL_SLUMBER, {ignore_energy=true})
		m.silent_slumber = nil
		game.bignews:saySimple(150, "#CRIMSON#%s awakens and empowers %s!", m:getName(), self:getName())

		self:heal(self.max_life)

		local tlevel = self:getTalentLevelRaw(self.T_PLASMA_BOLT)

		if kind == "mouth" then
			if self.x and self.y and self.add_mos and self.add_mos[1] then self.add_mos[1].image = "npc/horror_shertul_shertul_high_priest_mouth_infused.png" self:removeAllMOs() game.level.map:updateMap(self.x, self.y) end

			self:learnTalent(self.T_FEED, true, tlevel)
			self:learnTalent(self.T_DEVOUR_LIFE, true, tlevel)
			self:learnTalent(self.T_FEED_POWER, true, tlevel)
			self:learnTalent(self.T_FEED_STRENGTHS, true, tlevel)
		elseif kind == "hand" then
			if self.x and self.y and self.add_mos and self.add_mos[1] then self.add_mos[1].image = "npc/horror_shertul_shertul_high_priest_hand_infused.png" self:removeAllMOs() game.level.map:updateMap(self.x, self.y) end

			self:learnTalent(self.T_BONE_SHIELD, true, tlevel)
			self:learnTalent(self.T_BONE_SPEAR, true, tlevel)
			self:learnTalent(self.T_CURSE_OF_DEATH, true, tlevel)
			self:learnTalent(self.T_BURNING_HEX, true, tlevel)

			self:forceUseTalent(self.T_BONE_SHIELD, {ignore_energy=true})

			self:attr("global_speed_base", 0.2)
			self:recomputeGlobalSpeed()
		elseif kind == "eye" then
			if self.x and self.y and self.add_mos and self.add_mos[1] then self.add_mos[1].image = "npc/horror_shertul_shertul_high_priest_eye_infused.png" self:removeAllMOs() game.level.map:updateMap(self.x, self.y) end

			self:learnTalent(self.T_DISINTEGRATION, true, tlevel)
			self:learnTalent(self.T_DUST_TO_DUST, true, tlevel)
			self:learnTalent(self.T_HASTE, true, tlevel)
			self:learnTalent(self.T_CHRONO_TIME_SHIELD, true, tlevel)

			self:forceUseTalent(self.T_DISINTEGRATION, {ignore_energy=true})

			self:attr("global_speed_base", 0.3)
			self:recomputeGlobalSpeed()
		end
	end,

	on_takehit = function(self, value, src)
		local perc = (self.life - value) / self.max_life
		if perc < 0.9 and not self.awakened_mouth then
			self.awakened_mouth = true
			local m = game.level:findEntity{define_as="AMAKTHEL_MOUTH"}
			if m then self:awaken_body_part("mouth", m) end
		end
		if perc < 0.7 and not self.awakened_hand then
			self.awakened_hand = true
			local m = game.level:findEntity{define_as="AMAKTHEL_HAND"}
			if m then self:awaken_body_part("hand", m) end
		end
		if perc < 0.35 and not self.awakened_eye then
			self.awakened_eye = true
			local m = game.level:findEntity{define_as="AMAKTHEL_EYE"}
			if m then self:awaken_body_part("eye", m) end
		end
		return value
	end,

	on_die = function(self)
		for _, name in ipairs{"AMAKTHEL_HAND", "AMAKTHEL_EYE", "AMAKTHEL_MOUTH"} do
			local m = game.level:findEntity{define_as=name}
			if m then
				m.perma_slumber = true
				m.life_regen = 100000
				if not m:isTalentActive(m.T_AMAKTHEL_SLUMBER) then m:forceUseTalent(m.T_AMAKTHEL_SLUMBER, {ignore_energy=true}) end
			end
		end
		game.player:resolveSource():grantQuest("orcs+amakthel")
		game.player:resolveSource():setQuestStatus("orcs+amakthel", engine.Quest.COMPLETED)
	end,

	on_acquire_target = function(self, who)
		if not who or not who.player then return end
		local chat = require("engine.Chat").new("orcs+shertul-priest", self, who)
		chat:invoke()
		self.on_acquire_target = nil
	end,
}
