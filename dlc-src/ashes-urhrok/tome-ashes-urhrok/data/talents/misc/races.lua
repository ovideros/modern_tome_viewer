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

racial_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
racial_req2 = {
	level = function(level) return 8 + (level-1)  end,
}
racial_req3 = {
	level = function(level) return 16 + (level-1)  end,
}
racial_req4 = {
	level = function(level) return 24 + (level-1)  end,
}

newTalentType{ type="race/doomelf", name = _t("doomelf", "talent type"), generic = true, is_spell=true, description = _t"The various racial bonuses a character can have." }

newTalent{
	name = "Haste of the Doomed",
	type = {"race/doomelf", 1},
	require = racial_req1,
	points = 5,
	range = function(self, t) return self:attr("control_haste_doom") and 5 or 4 end, -- A fixedart sets this
	tactical = { ESCAPE = 2 },
	is_teleport = true,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 50, 22)) end,
	getPower = function(self, t) return self:combatStatScale("wil", 7, 25) end,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), nolock=true, talent=t}
	end,
	callbackOnAct = function(self, t)
		if not self.doomelf_teleported then return end
		self:startTalentCooldown(t)
		self.doomelf_teleported = false
		return
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return end
		if not self:canProject(tg, x, y) then return end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return end

		if target or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move", self) then
			game.logPlayer(self, "You must have an empty space to teleport to.")
			return false
		end

		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(x, y, 0)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		game:playSoundNear(self, "talents/teleport")

		local v = t.getPower(self, t)
		self:setEffect(self.EFF_OUT_OF_PHASE, 5, {
			defense = v,
			resists = v,
			effect_reduction = 0,
		})

		-- If we've already teleported once this turn then end turn
		-- Else set a flag and let callbackOnAct or another use set the cooldown
		if self.doomelf_teleported then
			self.energy.value = self.energy.value - game.energy_to_act -- This is better than making the base talent not instant for various reasons (confusion)
			return true
		else
			self.doomelf_teleported = true
			return false
		end
	end,
	info = function(self, t)
		local v = t.getPower(self, t)
		return ([[Hasten yourself out of phase, teleporting you to a specific location up to %d spaces away.
		You can activate this talent up to twice within the same turn, but the second activation will not be instant.
		Afterwards you stay out of phase for 5 turns. In this state your defense is increased by %d and all your resistances by %d%%.
		The bonus will increase with your Willpower.]]):
		tformat(self:getTalentRange(t), v, v, v)
	end,
}

newTalent{
	name = "Resilience of the Doomed",
	type = {"race/doomelf", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	effectsReduce = function(self, t) return self:combatTalentScale(t, 5, 20) end,
	critResist = function(self, t) return self:combatTalentScale(t, 10, 32, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "ignore_direct_crits", t.critResist(self, t))
		self:talentTemporaryValue(p, "reduce_detrimental_status_effects_time", t.effectsReduce(self, t))
	end,
	info = function(self, t)
		return ([[The tortures you had to endure on the Fearscape have increased your resilience.
		All detrimental status effects last %d%% less on you and all direct critical hits (physical, mental, spells) against you have a %d%% lower critical multiplier (but always do at least normal damage).]]):
		tformat(t.effectsReduce(self, t), t.critResist(self, t))
	end,
}

newTalent{
	name = "Corruption of the Doomed",
	type = {"race/doomelf", 3},
	require = racial_req3,
	points = 5,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 47, 35)) end,
	getChance = function(self, t) return self:combatTalentLimit(t, 100, 21, 45) end,
	getDarkness = function(self, t) return self:combatTalentLimit(t, 20, 5, 15) end,
	getStealth = function(self, t) return self:combatStatScale("mag" , 7, 25) end,
	getThreshold = function(self, t) return 1.4 * (self.level or 60) end;  -- Scale the minimum damage with level (1.4 to 84) so the once per turn doesn't get wasted easily
	mode = "sustained",
	no_energy = true,
	callbackOnHit = function(self, t, cb, src, death_note)
		if cb.value >= self.max_life * 0.10 and rng.percent(t.getChance(self, t)) then
			self:forceUseTalent(t.id, {ignore_energy=true})
			self:alterTalentCoolingdown(self.T_HASTE_OF_THE_DOOMED, -1000)
			self:alterTalentCoolingdown(self.T_PITILESS, -1000)
			self:setEffect(self.EFF_CORRUPTION_OF_THE_DOOMED, 5, {stealth=t.getStealth(self, t), darkness=t.getDarkness(self, t), threshold=t.getThreshold(self,t)})
		end
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
		}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Your original invisibility talent was corrupted and twisted.
		You have %d%% chance to turn into a dúathedlen for 5 turns, when hit by a blow doing at least 10%% of your total life.
		While in this form you gain the following effects:
		- you have permanent stealth (power %d)
		- your darkness damage is increased by %d%%
		- any non mind and non physical damage you deal above %d triggers a darkness explosion of radius 1 for half the damage (this can only happen once per turn)
		- when you transform the cooldowns of Haste of the Doomed and Pitiless are reset
		]]):
		tformat(t.getChance(self, t), t.getStealth(self, t), t.getDarkness(self, t), t.getThreshold(self, t))
	end,
}

newTalent{
	name = "Pitiless",
	type = {"race/doomelf", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 46, 30)) end, -- Limit to >10
	tactical = { DISABLE = 0.5 },
	range = 7,
	tactical = { ATTACKAREA = {BLIGHT = 1}, DISABLE = 2 },
	requires_target = true,
	getEffectGood = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	getEffectBad = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6, "log")) end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTargetLimited(tg)
		if not target then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end

			local todel = {}
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type ~= "other" then
					if e.status == "detrimental" then
						p.dur = math.min(p.dur*4, p.dur + t.getEffectBad(self, t))
					elseif e.status == "beneficial" then
						p.dur = p.dur - t.getEffectGood(self, t)
						if p.dur <= 0 then todel[#todel+1] = eff_id end
					end
				end
			end
			while #todel > 0 do
				target:removeEffect(table.remove(todel))
			end

			local tids = {}
			for tid, lev in pairs(target.talents) do
				local t = target:getTalentFromId(tid)
				if t and target.talents_cd[tid] and not t.fixed_cooldown then tids[#tids+1] = t end
			end
			while #tids > 0 do
				local tt = rng.tableRemove(tids)
				if not tt then break end
				target.talents_cd[tt.id] = target.talents_cd[tt.id] + t.getEffectGood(self, t)
			end
		end)
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "circle", {zdepth=6, oversize=1, a=130, appear=8, limit_life=8, speed=5, img="pitiless_circle", radius=1})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[You launch a mental assault on the target.
		The assult increases the cooldown of any already cooling down talents by %d, the duration of any magical, physical or mental detrimental effects by %d (max 4x duration) and decreases the duration of any magical, physical or mental beneficial effects by %d.]]):
		tformat(t.getEffectGood(self, t), t.getEffectBad(self, t), t.getEffectGood(self, t))
	end,
}
