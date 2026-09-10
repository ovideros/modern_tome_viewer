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
	name = "Prophecy",
	type = {"demented/doom", 1},
	require = dementedreq1,
	points = 5,
	mode = "passive",
	getMadnessCooldown = function(self, t) return self:combatTalentScale(t, 0.15, 0.4) end,
	--getMadnessNb = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2.5)) end,
	--getMadnessDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 3.6)) end,
	getRuinDamage = function(self, t) return self:combatTalentSpellDamage(t, 1, 120) end,
	getTreasonChance = function(self, t) return self:combatTalentScale(t, 10, 25) end,
	on_learn = function(self, t)
		if self:getTalentLevel(t) >= 1 and not self:knowTalent(self.T_PROPHECY_OF_RUIN) then
			self:learnTalent(self.T_PROPHECY_OF_RUIN, true)
		end
		if self:getTalentLevel(t) >= 3 and not self:knowTalent(self.T_PROPHECY_OF_TREASON) then
			self:learnTalent(self.T_PROPHECY_OF_TREASON, true)
		end
		if self:getTalentLevel(t) >= 5 and not self:knowTalent(self.T_PROPHECY_OF_MADNESS) then
			self:learnTalent(self.T_PROPHECY_OF_MADNESS, true)
		end
	end,	
	on_unlearn = function(self, t)
		if self:getTalentLevel(t) < 1 and self:knowTalent(self.T_PROPHECY_OF_RUIN) then
			self:unlearnTalent(self.T_PROPHECY_OF_RUIN)
		end
		if self:getTalentLevel(t) < 3 and self:knowTalent(self.T_PROPHECY_OF_TREASON) then
			self:unlearnTalent(self.T_PROPHECY_OF_TREASON)
		end
		if self:getTalentLevel(t) < 5 and self:knowTalent(self.T_PROPHECY_OF_MADNESS) then
			self:unlearnTalent(self.T_PROPHECY_OF_MADNESS)
		end
	end,
	info = function(self, t)
		local mcd = t.getMadnessCooldown(self,t)*100
		local rdam = t.getRuinDamage(self,t)
		local tchance = t.getTreasonChance(self,t)
		--local tdam = t.getTreasonDamage(self,t)
		return ([[By bringing the forces of entropy to bear on a target, you prophesize their inevitable doom. Each point in this talent unlocks additional prophecies. A target can only be affected by a single prophecy at a time.
Level 1: Prophecy of Ruin. Deals %0.2f damage on falling below 75%%, 50%% or 25%% of maximum life.
Level 3: Prophecy of Treason. %d%% chance each turn to attack an ally or themselves.
Level 5: Prophecy of Madness. Increases talent cooldowns by %d%%.]]):
		tformat(rdam, tchance, mcd)
	end,
}

-- These may need to be implemented differently to avoid talent level scaling bugs
newTalent{
	name = "Prophecy of Madness",
	type = {"demented/prophecy", 1},
	require = dementedreq1,
	points = 5,
	cooldown = 20,
	insanity = -10,
	range = 10,
	radius = function(self, t)
		local t2 = self:isTalentActive(self.T_GRAND_ORATION)
		if t2 and t2.talent == t.id then
			local t3 = self:getTalentFromId(self.T_GRAND_ORATION)
			return self:getTalentRadius(t3)
		end
		return 0
	end,
	tactical = { DISABLE = 3 },
	direct_hit = true,
	requires_target = true,
	getCooldown = function(self, t) return self:callTalent(self.T_PROPHECY, "getMadnessCooldown") end,
	--getNb = function(self, t) return self:callTalent(self.T_PROPHECY, "getMadnessNb") end,
	--getDuration = function(self, t) return self:callTalent(self.T_PROPHECY, "getMadnessDuration") end,
	twofold_curse = function(self, t, target)
		local t = self:getTalentFromId(self.T_TWOFOLD_CURSE)
		-- power should be getCooldown?
		target:setEffect(target.EFF_PROPHECY_OF_MADNESS, 6, {src=self, power=t.getMadnessCooldown(self,t), cd = 0, twofold=1, apply_power=self:combatSpellpower()})
		return true
	end,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
		local x, y = self:getTargetLimited(tg)
		if not x or not y then return nil end

		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end

		local cd = 0
		local t2 = self:isTalentActive(self.T_REVELATION) 		
		if t2 and t2.talent == t.id then
			cd = self:callTalent(self.T_REVELATION, "getMadness")
		end
		game.level.map:particleEmitter(target.x, target.y, 1, "circle", {base_rot=0, oversize=1.7, a=230, limit_life=8, appear=8, speed=0, img="prophecy_cast_aura", radius=0, shader=true})
		target:setEffect(target.EFF_PROPHECY_OF_MADNESS, 6, {src=self, power=t.getCooldown(self,t), cd = cd, apply_power=self:combatSpellpower()})
		local t3 = self:isTalentActive(self.T_TWOFOLD_CURSE) 
		if t3 and t3.talent ~= t.id then
			t3 = self:getTalentFromId(t3.talent)
			t3.twofold_curse(self, t3, target)
		end
		local t4 = self:isTalentActive(self.T_GRAND_ORATION)
		if t4 and t4.talent == t.id then
			local tg = {type="ball", radius=self:callTalent(self.T_GRAND_ORATION, "radius"), act_exclude={[target.uid]=true}, selffire=false, x=target.x, y=target.y}
			self:project(tg, x, y, function(tx, ty)
				local target = game.level.map(tx, ty, Map.ACTOR)
				if not target then return end
				target:setEffect(target.EFF_PROPHECY_OF_MADNESS, 6, {src=self, power=t.getCooldown(self,t), apply_power=self:combatSpellpower()})		
				game.level.map:particleEmitter(tx, ty, 1, "circle", {base_rot=0, oversize=0.7, a=130, limit_life=8, appear=8, speed=0, img="curse_gfx", radius=0})
			end)		
		end
		game:playSoundNear(self, "talents/prophecy")
		return true
	end,
	info = function(self, t)
		local cd = t.getCooldown(self,t)*100
		return ([[Utter a prophecy of the impending madness of your target, increasing the cooldown of all their talents by %d%% for 6 turns.
		A target can only be affected by a single prophecy at a time.]]):tformat(cd)
	end,
}

newTalent{
	name = "Prophecy of Ruin",
	type = {"demented/prophecy", 1},
	require = dementedreq1,
	points = 5,
	cooldown = 20,
	insanity = -10,
	range = 10,
	tactical = { ATTACK = {DARKNESS = 3 } },
	direct_hit = true,
	requires_target = true,
	radius = function(self, t)
		local t2 = self:isTalentActive(self.T_GRAND_ORATION)
		if t2 and t2.talent == t.id then
			local t3 = self:getTalentFromId(self.T_GRAND_ORATION)
			return self:getTalentRadius(t3)
		end
		return 0
	end,
	--getResists = function(self, t) return self:callTalent(self.T_PROPHECY, "getRuinResists") end,
	getDamage = function(self, t) return self:callTalent(self.T_PROPHECY, "getRuinDamage") end,
	twofold_curse = function(self, t, target)
		local t = self:getTalentFromId(self.T_TWOFOLD_CURSE)
		local dam = self:spellCrit(t.getRuinDamage(self, t))
		target:setEffect(target.EFF_PROPHECY_OF_RUIN, 6, {src=self, dam=dam, rad=0, twofold=1, heal=0, apply_power=self:combatSpellpower()})
		return true
	end,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
		local x, y = self:getTargetLimited(tg)
		if not x or not y then return nil end
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		local heal = 0		
		local t2 = self:isTalentActive(self.T_REVELATION) 		
		if t2 and t2.talent == t.id then
			heal = self:callTalent(self.T_REVELATION, "getRuin")
		end

		local dam = self:spellCrit(t.getDamage(self, t))
		game.level.map:particleEmitter(target.x, target.y, 1, "circle", {base_rot=0, oversize=1.7, a=230, limit_life=8, appear=8, speed=0, img="prophecy_cast_aura", radius=0, shader=true})
		target:setEffect(target.EFF_PROPHECY_OF_RUIN, 6, {src=self, dam=t.getDamage(self,t), rad=0, heal=heal, apply_power=self:combatSpellpower()})

		local t2 = self:isTalentActive(self.T_TWOFOLD_CURSE) 
		if t2 and t2.talent ~= t.id then
			t2 = self:getTalentFromId(t2.talent)
			t2.twofold_curse(self, t2, target)
		end
		local t3 = self:isTalentActive(self.T_GRAND_ORATION)
		if t3 and t3.talent == t.id then
			local tg = {type="ball", radius=self:callTalent(self.T_GRAND_ORATION, "radius"), friendlyfire=false, act_exclude={[target.uid]=true}, selffire=false, x=target.x, y=target.y}  -- talent?
			self:project(tg, x, y, function(tx, ty)
				local target = game.level.map(tx, ty, Map.ACTOR)
				if not target then return end
				target:setEffect(target.EFF_PROPHECY_OF_RUIN, 6, {src=self, dam=t.getDamage(self,t), rad=0, heal=heal, apply_power=self:combatSpellpower()})
				game.level.map:particleEmitter(tx, ty, 1, "circle", {base_rot=0, oversize=0.7, a=130, limit_life=8, appear=8, speed=0, img="curse_gfx", radius=0})
			end)		
		end
		game:playSoundNear(self, "talents/prophecy")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self,t)
		return ([[Utter a prophecy of the impending demise of your target that lasts 6 turns.
		Each time their life falls below 75%%, 50%% or 25%% of maximum the power of the prophecy will echo outwards, inflicting %0.2f darkness damage to them.
		A target can only be affected by a single prophecy at a time.
		The damage increase will increase with your Spellpower.]]):tformat(dam)
	end,
}

newTalent{
	name = "Prophecy of Treason",
	type = {"demented/prophecy", 1},
	require = dementedreq1,
	points = 5,
	cooldown = 20,
	insanity = -10,
	range = 10,
	radius = function(self, t)
		local t2 = self:isTalentActive(self.T_GRAND_ORATION)
		if t2 and t2.talent == t.id then
			local t3 = self:getTalentFromId(self.T_GRAND_ORATION)
			return self:getTalentRadius(t3)
		end
		return 0
	end,
	tactical = { DISABLE = 3 },
	direct_hit = true,
	requires_target = true,
	getChance = function(self, t) return self:callTalent(self.T_PROPHECY, "getTreasonChance") end,
	--getDamage = function(self, t) return self:callTalent(self.T_PROPHECY, "getTreasonDamage") end,
	twofold_curse = function(self, t, target)
		local t = self:getTalentFromId(self.T_TWOFOLD_CURSE)
		target:setEffect(target.EFF_PROPHECY_OF_TREASON, 6, {src=self, power=t.getTreasonChance(self,t), twofold=1, apply_power=self:combatSpellpower()})
		return true
	end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, state)
		-- Displace Damage?
		local t2 = self:isTalentActive(self.T_REVELATION)
		if not (t2 and t2.talent == t.id) then return end
		if dam > 0 and src ~= self and not state.no_reflect then
		
			-- find available targets
			local tgts = {}
			local grids = core.fov.circle_grids(self.x, self.y, 10, true)
			for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, Map.ACTOR)
				if a and self:reactionToward(a) < 0 and a:hasEffect(a.EFF_PROPHECY_OF_TREASON) then
					tgts[#tgts+1] = a
				end
			end end

			-- Displace the damage
			local a = rng.table(tgts)
			if a then
				local displace = dam * self:callTalent(self.T_REVELATION, "getTreason")/100
				state.no_reflect = true
				a:takeHit(displace, self)
				game:delayedLogDamage(src, a, displace, ("%s(%d treason)#LAST#"):tformat("#CRIMSON#", displace), false)
				state.no_reflect = nil
				dam = dam - displace
				game:delayedLogDamage(src, self, 0, ("%s(%d treason)#LAST#"):tformat(DamageType:get(type).text_color or "#aaaaaa#", displace), false)
			end
		end
		
		return {dam=dam}
	end,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
		local x, y = self:getTargetLimited(tg)
		if not x or not y then return nil end
		local heal = 0
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		game.level.map:particleEmitter(target.x, target.y, 1, "circle", {base_rot=0, oversize=1.7, a=230, limit_life=8, appear=8, speed=0, img="prophecy_cast_aura", radius=0, shader=true})
		target:setEffect(target.EFF_PROPHECY_OF_TREASON, 6, {src=self, power=t.getChance(self,t), apply_power=self:combatSpellpower()})
		local t2 = self:isTalentActive(self.T_TWOFOLD_CURSE) 
		if t2 and t2.talent ~= t.id then
			t2 = self:getTalentFromId(t2.talent)
			t2.twofold_curse(self, t2, target)
		end
		local t3 = self:isTalentActive(self.T_GRAND_ORATION)
		if t3 and t3.talent == t.id then
			local tg = {type="ball", radius=self:callTalent(self.T_GRAND_ORATION, "radius"), act_exclude={[target.uid]=true}, selffire=false, x=target.x, y=target.y}
			self:project(tg, x, y, function(tx, ty)
				local target = game.level.map(tx, ty, Map.ACTOR)
				if not target then return end
				target:setEffect(target.EFF_PROPHECY_OF_TREASON, 6, {src=self, power=t.getChance(self,t), apply_power=self:combatSpellpower()})				
				game.level.map:particleEmitter(tx, ty, 1, "circle", {base_rot=0, oversize=0.7, a=130, limit_life=8, appear=8, speed=0, img="curse_gfx", radius=0})
			end)
		end
		game:playSoundNear(self, "talents/prophecy")
		return true
	end,
	info = function(self, t)
		local chance = t.getChance(self,t)
		return ([[Utter a prophecy of the impending treachery of your target. For the next 6 turns, they will have a %d%% each turn to waste their turn attempting to attack an adjacent creature for 10%% weapon damage, or even themself if no creature is present.
		A target can only be affected by a single prophecy at a time.]]):tformat(chance)
	end,
}

newTalent{
	name = "Grand Oration",
	type = {"demented/doom", 2},
	require = dementedreq2,
	points = 5,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = 10,
	no_npc_use = true,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2.6)) end,
	activate = function(self, t)
		local talent = self:talentDialog(require("mod.dialogs.ProphecyGrandOration").new(self))
		if not talent then return nil end
		
		game:playSoundNear(self, "talents/spell_generic")
				
		return {
			talent = talent, rest_count = 0
		}
	end,
	deactivate = function(self, t, p)
		-- Having these dispelled is very annoying as you have to remember and repick all your settings
		-- There is no good way to detect or prevent dispel currently, but checking for 10000 energy should reliably detect forceUseTalent which is good enough
		if self.energy.value == 10000 then 
			return false
		end
		return true
	end,
	info = function(self, t)
		local rad = self:getTalentRadius(t)
		local talent = self:isTalentActive(t.id) and self:getTalentFromId(self:isTalentActive(t.id).talent).name or _t"None"
		return ([[You speak a chosen prophecy to the masses. When applying this prophecy, it will spread to all targets in radius %d.
		A prophecy can only be affected by one of Grand Oration, Twofold Curse or Revelation.
		
		Current prophecy: %s]]):
		tformat(rad, talent)
	end,
}

newTalent{
	name = "Twofold Curse",
	type = {"demented/doom", 3},
	require = dementedreq3,
	points = 5,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = 10,
	no_npc_use = true,
	getMadnessCooldown = function(self, t) return self:combatTalentScale(t, 0.15, 0.4) end,
	--getMadnessNb = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2.5)) end,
	--getMadnessDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 3.6)) end,
	--getRuinResists = function(self, t) return self:combatTalentSpellDamage(t, 10, 35) end,
	getRuinDamage = function(self, t) return self:combatTalentSpellDamage(t, 1, 120) end,
	--getRuinRadius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2)) end,
	getTreasonChance = function(self, t) return self:combatTalentScale(t, 10, 25) end,
	--getTreasonDamage = function(self, t) return self:combatTalentScale(t, 15, 40) end,
	activate = function(self, t)
		local talent = self:talentDialog(require("mod.dialogs.ProphecyTwofoldCurse").new(self))
		if not talent then return nil end
		
		game:playSoundNear(self, "talents/spell_generic")
				
		return {
			talent = talent, rest_count = 0
		}
	end,
	deactivate = function(self, t, p)
		-- Having these dispelled is very annoying as you have to remember and repick all your settings
		-- There is no good way to detect or prevent dispel currently, but checking for 10000 energy should reliably detect forceUseTalent which is good enough
		if self.energy.value == 10000 then 
			return false
		end
		return true
	end,
	info = function(self, t)
		local talent = self:isTalentActive(t.id) and self:getTalentFromId(self:isTalentActive(t.id).talent).name or _t"None"
		return ([[Weave your chosen prophecy into your speech, dooming your foe twice over. The chosen prophecy will apply instantly to your primary target whenever you cast any other prophecy at talent level %d.
		A prophecy can only be affected by one of Grand Oration, Twofold Curse or Revelation.
		
		Current prophecy: %s]]):
		tformat(self:getTalentLevel(t), talent)
	end,
}

newTalent{
	name = "Revelation",
	type = {"demented/doom", 4},
	require = dementedreq4,
	points = 5,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = 10,
	no_npc_use = true,
	getMadness = function(self, t) return math.floor(self:combatTalentScale(t, 1, 4.5)) end,
	getRuin = function(self, t) return self:combatTalentScale(t, 5, 15) end,
	getTreason = function(self, t) return self:combatTalentScale(t, 5, 20) end,
	activate = function(self, t)
		local talent = self:talentDialog(require("mod.dialogs.ProphecyRevelation").new(self))
		if not talent then return nil end
		
		game:playSoundNear(self, "talents/spell_generic")
				
		return {
			talent = talent, rest_count = 0
		}
	end,
	deactivate = function(self, t, p)
		-- Having these dispelled is very annoying as you have to remember and repick all your settings
		-- There is no good way to detect or prevent dispel currently, but checking for 10000 energy should reliably detect forceUseTalent which is good enough
		if self.energy.value == 10000 then 
			return false
		end
		return true
	end,
	info = function(self, t)
		local madness = t.getMadness(self,t)
		local ruin = t.getRuin(self,t)
		local treason = t.getTreason(self,t)
		local talent = self:isTalentActive(t.id) and self:getTalentFromId(self:isTalentActive(t.id).talent).name or _t"None"
		return ([[As you speak the chosen prophecy whispers from the void guide you in how to bring about the downfall of your foe. The chosen prophecy will grant one of the following effects.
		Prophecy of Madness. Each time the target uses a talent one of your talents on cooldown has its cooldown reduced by %d turns.
		Prophecy of Ruin. Each time the target takes damage you are healed for %d%% of the damage dealt.
		Prophecy of Treason: %d%% of all damage you take is redirected to a random target affected by Prophecy of Treason.
		A prophecy can only be affected by one of Grand Oration, Twofold Curse or Revelation.
	
		Current prophecy: %s]]):
		tformat(madness, ruin, treason, talent)
	end,
}
