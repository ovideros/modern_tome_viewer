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

-- Extreme endurance fight. Some key points:
-- - Very high life and damage resistance/mitigating debuffs
-- - Fight includes a stacking debuff that increases debuff durations and deals damage, moving to a ground effect can remove this but causes a temporary "berserk" on the boss
-- - Shadows can be repeatedly killed until eventually they respawn rarely, they also represent most of the DPS in the fight
-- - An extremely dangerous Entropic Gift is cast pretty often with other cover debuffs disrupting cleansing of it
-- - Damage output is high, but most of his non-shadow attacks are Darkness/Temporal and his penetration is low
newEntity{ base = "BASE_NPC_HORROR", define_as = "HYPOSTASIS",
	unique = true,
	name = "Hypostasis of Entropy",
	color=colors.VIOLET,
	desc = _t[[The twisting mass of limbs and maws that floats in front of you is no less than inevitability personified. All civilisation, all life, all matter, all energy and all light will one day succumb to entropy. You feel terribly cold as a horrifying realisation comes to the forefront of your mind. The heat death of the universe itself is coming for you.]],
	image="invis.png",
	z = 16,
	embed_particles = {
		{name="hypostasis_entropy", rad=1, args={}},
	},
	no_difficulty_random_class = true,

	level_range = {100, nil}, exp_worth = 3,
	max_life = 900, life_rating = 100, fixed_rating = true,
	hate_regen = 1.9,
	stats = { str=100, dex=100, con=100, mag=100, wil=100, cun=100 },
	inc_stats = { str=80, dex=80, con=80, mag=80, wil=80, cun=80 },
	combat_spellpower = resolvers.levelup(1, 1, 2.5),
	combat_mindpower = resolvers.levelup(1, 1, 2.5),

	-- Putting the fixed in fixed boss
	no_auto_saves = true,
	no_auto_resists = true,

	resists = { all = 80, },

	resists_pen = {all = 50},

	-- This comes out to about 90, paired with Whispers this makes him quite hard to debuff but still possible to interact with
	combat_physresist = 160,
	combat_mentalresist = 130,  -- Lower to avoid screwing Mind damage unreasonably
	combat_spellresist = 160,
	combat_def = 120,

	combat_armor_hardiness = 100,
	combat_armor = 50,

	rank = 5,
	size_category = 4,
	infravision = 10,

	see_invisible = 150,

	instakill_immune = 1,
	stun_immune = 0.7,
	confusion_immune = 0.7,
	silence_immune = 0.7,

	body = { INVEN = 10 },  -- Feels more thematic if it isn't wearing gear

	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_ENTROPIC_GIFT] = {base=8, every=5},
		[Talents.T_NETHERBLAST] = {base=8, every=5},

		[Talents.T_DARK_WHISPERS] = {base=8, every=15},
		[Talents.T_HIDEOUS_VISIONS] = 2,
		[Talents.T_SANITY_WARP] = {base=8, every=5},

		[Talents.T_SWITCH] = 2,  -- This puts a surprising amount of pressure on misc buffs
		[Talents.T_TEMPORAL_BOLT] = {base=8, every=5},
		[Talents.T_CALL_SHADOWS] = {base=8, every=5},
		[Talents.T_SHADOW_WARRIORS] = {base=1, every=5},
		[Talents.T_SHADOW_MAGES] = {base=8, every=5},

		[Talents.T_SUMMON] = 1,

		[Talents.T_METEORIC_CRASH] = 1,
	},
	resolvers.sustains_at_birth(),

	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",

	resolvers.inscriptions(2, {"healing infusion", "healing infusion"}),  -- Eentropy gain

	on_act = function(self)
		local p = game:getPlayer(true)
		if p.x and not p:hasEffect(p.EFF_TOTAL_COLLAPSE) and self:hasLOS(p.x, p.y) then
			p:setEffect(p.EFF_TOTAL_COLLAPSE, 1, {src=self})
			if not self.shown_lore then
				game.party:learnLore("cults-entropic-void-seen")
				self.shown_lore = true
			end
		end
		self:setEffect(self.EFF_ENTROPIC_WASTING, 8, {src=self, power= 30 / 8})  -- Gain entropy every turn
	end,

	awakenAntropic = function(self)
		self:doEmote(_t"These energies are not for you!", 90, colors.RED)
		self:setEffect(self.EFF_HYPOSTASIS_AWAKEN, 8, {})
	end,

	summon = {
		{type="horror", number=2, hasxp=false},
	},

	on_die = function(self, who)
		world:gainAchievement("CULTS_ENTROPY_END", who)
		game.level.data.no_worldport = nil
		game.zone.no_worldport = nil
	end,
}
