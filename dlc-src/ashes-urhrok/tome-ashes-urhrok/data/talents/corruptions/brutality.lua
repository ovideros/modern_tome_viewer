-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

local Map = require "engine.Map"

newTalent{
	name = "Draining Assault",
	type = {"corruption/brutality", 1},
	require = str_corrs_req1,
	points = 5,
	cooldown = function(self, t)
		if self:attr("is_destroyer") then
			return 6 - math.ceil(self.is_destroyer/2)
		else
			return 6
		end end,
	stamina = 20,
	vim=0,
	lifeSteal = function(self, t) return math.ceil(self:combatTalentScale(t, 12, 21, 0.75)) end,
	vimSteal = function(self, t) return math.ceil(self:combatTalentScale(t, 7, 20.5, 0.75)) end,
	tactical = { ATTACK = { weapon = 2, }, VIM = 2, HEAL = 2,},
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	requires_target = true,
	getHit = function (self, t) return self:combatTalentWeaponDamage(t, 0.60, 1.3) end,
	action = function(self, t)
		local tg = {type="hit", range=1}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target or target == self then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		
		local heal = t.lifeSteal(self,t)
		self:attr("lifesteal", heal)
		local hit1 = self:attackTarget(target, nil, t.getHit(self,t), true)
		local hit2 = self:attackTarget(target, nil, t.getHit(self,t), true)
		self:attr("lifesteal", -heal)
		local vimheal = 0
		if hit1 then vimheal = vimheal + 1 end
		if hit2 then vimheal = vimheal + 1 end
		self:incVim(vimheal * t.vimSteal(self,t))
		return true
	end,
	info = function(self, t)
		return ([[Hits the target twice, doing %d%% weapon damage each hit. You gain life equal to %d%% of the damage dealt, and you gain %d vim for each attack that hits.]]):tformat(100 * t.getHit(self, t), t.lifeSteal(self, t), t.vimSteal(self, t))
	end,
}

newTalent{
	name = "Fiery Grasp",
	type = {"corruption/brutality", 2},
	require = str_corrs_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 14,
	vim = 30,
	stamina = 15,
	tactical = { ATTACK = {FIRE = 2}, DISABLE = 1, },
	direct_hit = true,
	reflectable = true,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	requires_target = true,
	range = function(self, t) return math.ceil(self:combatTalentScale(t, 3, 5.5)) end,
	getDur = function(self, t) return math.ceil(self:combatTalentScale(t, 2, 4)) end,
	getHit = function (self, t) return self:combatTalentWeaponDamage(t, 0.65, 1.395) end,
	doSilence = function (self, t)
		if self:getTalentLevel(t) > 4 then
			return 1
		else
			return 0
		end
	end,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 8, 30) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		if not game.level.map.seens(x, y) or not self:hasLOS(x, y) then return nil end
		self:project(tg, x, y, DamageType.FIRE, self:spellCrit(t.getDamage(self, t)))
		local _ _, x, y = self:canProject(tg, x, y)
		self:attackTarget(target, DamageType.FIRE, t.getHit(self,t), true)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "flamebeam", {tx=x-self.x, ty=y-self.y})
		if target:canBe("pin") then
			local dur = t.getDur(self,t)
			local dam = t.getDamage(self, t)
			local silence = t.doSilence(self, t)
			if silence ~= 0 then
				if not target:canBe("silence") then
					silence = 0
					game.logSeen(target, "%s resists the silence!", target:getName():capitalize())
				end
			end
			target:setEffect(target.EFF_FIERY_GRASP, dur, {apply_power=self:combatSpellpower(),src=self, power=dam, no_ct_effect=true, silence = silence})
		else
			game.logSeen(target, "%s resists the grasp!", target:getName():capitalize())
		end
		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Send out a claw of fire, striking in a line doing %0.2f damage leading to a target. The target is caught in the claw's grasp, taking %d%% weapon damage as fire damage and becoming unable to move for %d turns, while also taking %0.2f damage per turn.
		Starting from talent level 4, it will also silence.
		The beam damage and damage over time will increase with your Spellpower.]]):
		tformat(damDesc(self, DamageType.FIRE, damage), 100 * t.getHit(self, t),t.getDur(self,t), damDesc(self, DamageType.FIRE, damage))
	end,
}

newTalent{
	name = "Reckless Strike",
	type = {"corruption/brutality", 3},
	require = str_corrs_req3,
	points = 5,
	cooldown = 10,
	stamina = 44,
	no_npc_use = true, --Not opening that can of worms. Far too... wormy.
	vim = 18,
	tactical = { ATTACK = { weapon=2 }, },
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	requires_target = true,
	getMainhit = function (self, t) return self:combatTalentWeaponDamage(t, 1, 3) end,
	getBacklash = function (self, t) return 25 end,
	callbackOnDealDamage = function(self, t, value, target, dead, death_note)
		if self.turn_procs.is_reckless_striking and target and target.turn_procs and target.turn_procs.is_reckless_strike_target then
			local backlashMult = t.getBacklash(self,t)*0.01
			self.turn_procs.reckless_strike_backlash_amount = self.turn_procs.reckless_strike_backlash_amount+value*backlashMult
		end
	end,
	action = function(self, t)
		local tg = {type="hit", range=1}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		self.turn_procs.auto_melee_hit = true
		self.turn_procs.is_reckless_striking = true
		self.turn_procs.reckless_strike_backlash_amount = 0
		self:attr("combat_apr", 1000)
		self:attr("ignore_enemy_resist", 1)
		local storeeva = target.evasion
		target.evasion=0
		target:attr("no_evasion", 1)
		target.turn_procs.is_reckless_strike_target = true
		
		local ok,err = pcall(self.attackTarget,self,target, nil, t.getMainhit(self,t), true)
		
		self:attr("combat_apr", -1000)
		self:attr("ignore_enemy_resist", -1)
		self.turn_procs.auto_melee_hit = nil
		self.turn_procs.is_reckless_striking = nil
		target.turn_procs.is_reckless_strike_target = nil
		target.evasion = storeeva
		if not ok then error(err) end

		if self.turn_procs.reckless_strike_backlash_amount > 0 and self.life > 0 then
			local amount = math.min(self.life * 0.3, self.turn_procs.reckless_strike_backlash_amount)
			self:takeHit(amount, self)
			game:delayedLogDamage(self, self, 0, ("#CRIMSON#(%d reckless backlash)#LAST#"):tformat(amount), false)
		end
		self.turn_procs.reckless_strike_backlash_amount = nil

		game.level.map:particleEmitter(target.x, target.y, 1, "circle", {oversize=1, a=210, limit_life=18, appear=2, base_rot=0, speed=0, img="reckless_strike", radius=0})
		
		if self:attr("is_destroyer") then
			self:setEffect(self.EFF_RECKLESS_PEN, 3 + math.ceil(self.is_destroyer/2), {power=10 * self.is_destroyer})
		end
		return true
	end,
	info = function(self, t)
		return ([[Hits the target doing %d%% weapon damage. This attack cannot miss, and ignores all armor and resistances on the target. However, you take damage equal to %d%% of the damage dealt, or 30%% of your current HP, whichever is lower.]]):tformat(100 * t.getMainhit(self, t), t.getBacklash(self,t))
	end,
}

newTalent{
	name = "Share the Pain",
	type = {"corruption/brutality", 4},
	require = str_corrs_req4,
	points = 5,
	sustain_vim = 35,
	cooldown = 20,
	mode = "sustained",
	range = 0,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	getChance = function(self, t) return math.ceil(self:combatTalentScale(t, 16, 40)) end,
	getHit = function (self, t) return self:combatTalentWeaponDamage(t, 0.4, 0.75) end,
	activate = function(self, t)
		return true
	end,
	deactivate = function(self, t, p)
		return true
	end,
	callbackOnHit = function(self, t, cb, target) --Target=attacker
		local tt = self:isTalentActive(t.id)
		if not tt then return end
		if not target then return end
		if not target or target==self or target:attr("dead") or self:reactionToward(target) >= 0 then return end
		if target:getEntityKind(target) ~= "actor" then return end -- Don't try to hit traps and such
		if target.turn_procs.share_the_pain then return end
		if not target.x or not target.y then return end
		if core.fov.distance(self.x, self.y, target.x, target.y) > 1 then return end
		target.turn_procs.share_the_pain = 1
		if not rng.percent(t.getChance(self,t)) then return end
		self:attackTarget(target, nil, t.getHit(self,t), true)	
		return true
	end,
	info = function(self, t)
		return ([[You revel in the heat of battle. Whenever an enemy damages you within melee range, you have a %d%% chance to counter with an attack for %d%% weapon damage.
		You get once chance to deal this damage to a particular target each turn.]]):tformat(math.min(100, t.getChance(self,t)), t.getHit(self,t)*100)
	end,
}