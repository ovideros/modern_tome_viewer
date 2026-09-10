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

newTalent{
	name = "Decayed Devourers",
	type = {"demented/controlled-horrors", 1},
	require = dementedreq1,
	points = 5,
	insanity = -20,
	cooldown = 15,
	tactical = { ATTACK = 3 },
	requires_target = true,
	range = 7,
	radius = 2,
	direct_hit = true,
	getStats = function(self, t) return self:getMag() end,
	getDur = function(self, t) return math.floor(self:combatTalentLimit(t, 11, 4, 8)) end,
	getLifeRating = function(self, t) return self:combatTalentScale(t, 1, 6) end,
	target = function(self, t) return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), nolock=true, can_autoaccept=true} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local bx, by, target = self:getTargetLimited(tg)
		if not bx or not by then return nil end
		local x, y = util.findFreeGrid(bx, by, 3, true, {[Map.ACTOR]=true})
		if not x then game.logPlayer(self, "Not enough space to invoke your horror!") return end

		local function makeDevourer()
			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				type = "horror", subtype = "eldritch",
				display = "h", blood_color = colors.BLUE,
				faction = "horrors",
				stats = { str=t.getStats(self, t), dex=t.getStats(self, t), wil=t.getStats(self, t), mag=t.getStats(self, t), con=t.getStats(self, t), cun=t.getStats(self, t) },
				infravision = 10,
				no_breath = 1,
				fear_immune = 1,
				never_move = 1,
				difficulty_boosted = 1,  -- Avoid difficulty boosting, adding to party probably also works but I'm positive this always does
				max_life = 1,
				name = _t"decaying devourer", color=colors.CRIMSON,
				desc = _t"A headless, round creature with stubby legs and arms.  Its body seems to be all teeth.",
				image = "npc/horror_eldritch_devourer.png",
				level_range = {self.level, self.level}, exp_worth = 0,
				rank = 2,
				size_category = 2,
				autolevel = "zerker",
				life_rating = 7 + t.getLifeRating(self, t),
				life_regen = 4,
				combat_armor = self.level, combat_def = 15,
				combat_armor_hardiness = 60,
				resists = {all = math.min(50, self.level)},
				combat = { dam=self.level, atk=10 + self.level*3, apr=self.level, dammod={str=1}, physcrit = 10 },

				on_act = function(self)
					-- Clear target if it isn't adjacent to force a retarget and avoid skipping turns
					if not self.ai_target or not self.ai_target.actor then return end
					if core.fov.distance(self.x, self.y, self.ai_target.actor.x, self.ai_target.actor.y) >= 1 then 
						self:setTarget(nil) 
					end
				end,

				inc_damage = table.clone(self.inc_damage, true),
				resists_pen = table.clone(self.resists_pen, true),
				combat_critical_power = self.combat_critical_power,
				combat_spellcrit = self.combat_spellcrit,
				combat_physcrit = self.combat_physcrit,
				combat_mindcrit = self.combat_mindcrit,

				resolvers.talents{
					[Talents.T_BLOODBATH]=math.floor(self:getTalentLevel(t)),
					[Talents.T_GNASHING_TEETH]=math.floor(self:getTalentLevel(t)),
					[Talents.T_FRENZIED_BITE]=math.floor(self:getTalentLevel(t)),
				},

				ai = "summoned", ai_real = "tactical", ai_state = { ai_target="target_simple", ai_move="move_complex", talent_in=1, ally_compassion=0 },
				no_drops = true, keep_inven_on_death = false,
				faction = self.faction,
				summoner = self, summoner_gain_exp=true,
				summon_time = t.getDur(self, t),
				remove_from_party_on_death = true,
			}
			if self:knowTalent(self.T_DEMENTED_CALL_AMAKTHEL) then
				m.inc_damage.all = (m.inc_damage.all or 0) + self:callTalent(self.T_DEMENTED_CALL_AMAKTHEL, "getDam")
			end
			m:resolve()
			m:resolve(nil, true)
			return m
		end

		for i = 1, 3 do
			local m = makeDevourer()
			game.zone:addEntity(game.level, m, "actor", x, y)
			if target then m:setTarget(target) end

			x, y = util.findFreeGrid(bx, by, 3, true, {[Map.ACTOR]=true})
			if not x then return true end
			if game.party:hasMember(self) then
				game.party:addMember(m, {
					control=false,
					temporary_level = true,
					type="summon",
					title=_t"Summon",
				})
			end
		end

		if self:knowTalent(self.T_DEMENTED_CALL_AMAKTHEL) and self:getTalentLevel(self.T_DEMENTED_CALL_AMAKTHEL) >= 3 then
			local tgts = {}
			local grids = core.fov.circle_grids(self.x, self.y, 10, true)
			
			for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, engine.Map.ACTOR)
				if a and self:reactionToward(a) < 0 and core.fov.distance(x, y, bx, by) > 1 then tgts[#tgts+1] = a end
			end end

			for i = 1,4 do
				local actor = rng.tableRemove(tgts)
				if actor and actor.x and actor.y then
					local m = makeDevourer()
					x, y = util.findFreeGrid(actor.x, actor.y, 3, true, {[Map.ACTOR]=true})
					if not x then return true end

					game.zone:addEntity(game.level, m, "actor", x, y)
					if target then m:setTarget(target) end
					if game.party:hasMember(self) then
						game.party:addMember(m, {
							control=false,
							temporary_level = true,
							type="summon",
							title=_t"Summon",
						})
					end
				end
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[You use your bond with horrors to summon three decaying devourers for %d turns.
The decaying horrors cannot move and will attack all hostile creatures around them. They possess the talents Bloodbath, Gnashing Teeth and Frenzied Bite.
All its primary stats will be set to %d (based on your Magic stat), life rating increased by %d, and all talent levels set to %d.  Many other stats will scale with level.
Your increased damage, damage penetration, critical strike chance, and critical strike multiplier stats will all be inherited.]]):
		tformat(t.getDur(self, t), t.getStats(self, t), t.getLifeRating(self, t), math.floor(self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Decayed Bloated Horror",
	short_name = "DECAYED_BLADE_HORROR",
	type = {"demented/controlled-horrors", 2},
	require = dementedreq2,
	points = 5,
	insanity = -20,
	cooldown = 15,
	tactical = { ATTACKAREA = 3 },
	requires_target = true,
	range = 7,
	direct_hit = true,
	getStats = function(self, t) return self:getMag() end,
	getDur = function(self, t) return math.floor(self:combatTalentLimit(t, 11, 4, 8)) end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), nolock=true, can_autoaccept=true} end,
	getLifeRating = function(self, t) return self:combatTalentScale(t, 1, 6) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTargetLimited(tg)
		if not x or not y then return nil end
		x, y = util.findFreeGrid(x, y, 3, true, {[Map.ACTOR]=true})
		if not x then game.logPlayer(self, "Not enough space to invoke your horror!") return end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "horror", subtype = "eldritch",
			display = "h", blood_color = colors.BLUE,
			faction = "horrors",
			stats = { str=t.getStats(self, t), dex=t.getStats(self, t), wil=t.getStats(self, t), mag=t.getStats(self, t), con=t.getStats(self, t), cun=t.getStats(self, t) },
			infravision = 10,
			no_breath = 1,
			fear_immune = 1,
			never_move = 1,
			difficulty_boosted = 1,  -- Avoid difficulty boosting, adding to party probably also works but I'm positive this always does
			max_life = 1,
			name = _t"bloated horror", color=colors.WHITE,
			desc =_t"A bulbous humanoid form floats here. Its bald, child-like head is disproportionately large compared to its body, and its skin is pock-marked with nasty red sores.",
			image = "npc/horror_eldritch_bloated_horror.png",
			level_range = {self.level, self.level}, exp_worth = 0,
			rarity = 1,
			rank = 2,
			size_category = 4,
			life_rating = 8 + t.getLifeRating(self, t),
			autolevel = "wildcaster",
			combat_armor = self.level / 2, combat_def = self.level, combat_def_ranged = resolvers.mbonus(30, 15),
			combat = {dam=25+self.level, apr=10+self.level, atk=10+self.level*2, dammod={mag=0.6}},
			combat_spellpower = self.level*3,  -- 100 power at L50/150 mag, realistically in the 90 range for PCs endgame
			combat_mindpower = self.level*3,
			never_move = 1,
			levitation = 1,

			resists = {all = 35, [DamageType.LIGHT] = -30},

			inc_damage = table.clone(self.inc_damage, true),
			resists_pen = table.clone(self.resists_pen, true),
			combat_critical_power = self.combat_critical_power,
			combat_spellcrit = self.combat_spellcrit,
			combat_physcrit = self.combat_physcrit,
			combat_mindcrit = self.combat_mindcrit,
			
			resolvers.talents{
				[Talents.T_MIND_DISRUPTION]= math.floor(self:getTalentLevel(t)),
				[Talents.T_MIND_SEAR]=math.floor(self:getTalentLevel(t)),
			},

			talents_types_mastery = {
				["psionic/psychic-assault"] = -0.3,
			},

			ai = "summoned", ai_real = "tactical", ai_state = { ai_move="move_complex", talent_in=1, ally_compassion=0 },
			ai_talents = {[Talents.T_MIND_SEAR] = 20, [Talents.T_AGONY] = 10},  -- Optimize talent rotation
			global_speed_base = 1.2,  -- We need just a bit more global speed for Mind Disruption to not get cut from Sear->Agony->Confuse rotation, this also gets 4 spells in at 3 duration
			
			no_drops = true, keep_inven_on_death = false,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = t.getDur(self, t),
			remove_from_party_on_death = true,
		}
		if self:knowTalent(self.T_DEMENTED_CALL_AMAKTHEL) then
			m.inc_damage.all = (m.inc_damage.all or 0) + self:callTalent(self.T_DEMENTED_CALL_AMAKTHEL, "getDam")
			if self:getTalentLevel(self.T_DEMENTED_CALL_AMAKTHEL) >= 3 then m:learnTalent(m.T_AGONY, true, math.floor(self:getTalentLevel(t))) end
		end
		m:resolve()
		m:resolve(nil, true)
		game.zone:addEntity(game.level, m, "actor", x, y)

		if game.party:hasMember(self) then
			game.party:addMember(m, {
				control=false,
				temporary_level = true,
				type="summon",
				title=_t"Summon",
			})
		end

		if target then m:setTarget(target) end

		return true
	end,
	info = function(self, t)
		return ([[You use your bond with horrors to summon a decaying bloated horror for %d turns.
The decaying horror cannot move and will attack all hostile creatures in range of it. It possesses the talents Mind Disruption and Mind Sear.
All its primary stats will be set to %d (based on your Magic stat), life rating increased by %d, and all talent levels set to %d.  Many other stats will scale with level.
Your increased damage, damage penetration, critical strike chance, and critical strike multiplier stats will all be inherited.
		]]):
		tformat(t.getDur(self, t), t.getStats(self, t), t.getLifeRating(self, t), math.floor(self:getTalentLevel(t)))
	end,
}

-- Check for permanently changing target and possible general overpoweredness
newTalent{
	name = "Horrific Display",
	type = {"demented/controlled-horrors", 3},
	require = dementedreq3,
	points = 5,
	insanity = -10,
	cooldown = 15,
	tactical = { ATTACK = 3 },
	requires_target = true,
	range = 10,
	direct_hit = true,
	getDur = function(self, t) return self:combatTalentScale(t, 5, 10) end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTargetLimited(tg)
		if not target then return nil end

		if target.type ~= "horror" and target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) then
			target:setEffect(target.EFF_HORRIFIC_DISPLAY, t.getDur(self, t), {src=self})
		else
			game.logSeen(target, "%s resists the horrific assault!", target:getName():capitalize())
		end

		game:playSoundNear(self, "talents/horrific_display")
		return true
	end,
	info = function(self, t)
		return ([[You forcefully try to turn a creature into an horror.
If the target fails a magical save against your Spellpower, its appearance turns into that of a horror for %d turns, making all other creatures hostile to it.
Enemies near the target will have their target cleared on application.
This spell does not work on horrors.]])
		:tformat(t.getDur(self, t))
	end,
}

newTalent{
	name = "Call of Amakthel", short_name = "DEMENTED_CALL_AMAKTHEL",
	type = {"demented/controlled-horrors", 4},
	require = dementedreq4,
	points = 5,
	mode = "passive",
	getDam = function(self, t) return self:combatTalentSpellDamage(t, 10, 40) end,
	info = function(self, t)
		return ([[You attune your horrors to the dead god Amakthel, increasing your summoned horrors damage by %d%%.
At talent level 3, your Decaying Devourers spell will summon 4 additional Devourers adjacent to random enemies nearby and your Bloated Horror will learn the Agony talent.
At talent level 5, victims of your Horrific Display spell will pull enemies in radius 10 1 space towards them each turn.
The damage increase is based on your Spellpower.]]):
		tformat(t.getDam(self, t))
	end,
}
