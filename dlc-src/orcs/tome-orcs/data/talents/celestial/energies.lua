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

local damDesc = Talents.main_env.damDesc

newTalent{
	name = "Celestial Acceleration",
	type = {"celestial/energies", 1},
	require = divi_req1,
	mode = "passive",
	points = 5,
	getPosFactor = function(self, t) return (self:combatTalentScale(t, 0.05, 0.3)) / 80 end,
	getNegFactor = function(self, t) return t.getPosFactor(self, t) end,
	getCap = function(self, t) return math.max(t.getPosFactor(self, t), t.getNegFactor(self, t)) * 80 end,
	do_accelerate = function(self, t)
		--use the base maxes, sustains will cut off the upper bound, but the upper 20% is a buffer
		local cap = t.getCap(self, t)
		local move = math.min(100 * t.getPosFactor(self, t) * self:getPositive() / (50 + self.positive_negative_rating * self.level), cap)
		local cast = math.min(100 * t.getNegFactor(self, t) * self:getNegative() / (50 + self.positive_negative_rating * self.level), cap)
		self:setEffect(self.EFF_CELESTIAL_ACCELERATION, 1, {move=move, cast=cast})
	end,
	on_learn = function(self, t)
		t.do_accelerate(self, t)
	end,
	on_unlearn = function(self, t)
		self:removeEffect(self.EFF_CELESTIAL_ACCELERATION, true, true)
	end,
	info = function(self, t)
		local posFactor = t.getPosFactor(self, t)
		local negFactor = t.getNegFactor(self, t)
		local cap = t.getCap(self, t)
		return ([[Increases your movement speed by %0.2f%% per percent of positive energy and your casting speed by %0.2f%% per percent of negative energy, up to a maximum of %0.2f%% at 80%%. Sustained energy still counts toward the maximum.]]):
		tformat(posFactor * 100, negFactor * 100, cap * 100)
	end,
}

newTalent{
	name = "Polarization",
	type = {"celestial/energies", 2},
	require = divi_req2,
	mode = "passive",
	points = 5,
	getRegen = function(self, t) return math.max(0.2, self:combatTalentScale(t, 0.25, 1, 0.75)) end,
	-- this is a bit messy and probably should be rewritten to use temp values
	do_polarize = function(self, t)
		--this runs after twilight, so the higher one should always have a positive regen, while the other will follow whatever the at rest regen does
		--regen is run after twilight and before this, so we'll have to correct it
		if (self:getPositive() / self:getMaxPositive()) >= (self:getNegative() / self:getMaxNegative()) then
			if self.positive_regen < 0 then
				--regen runs before this method, correct it
				self:incPositive(-self.positive_regen * 2)
			end
			self.positive_regen = self.positive_regen_ref
			if not self:attr("negative_at_rest") then
				self.negative_regen = -self.negative_regen_ref
			end
		else 
			if self.negative_regen < 0 then
				--regen runs before this method, correct it
				self:incNegative(-self.negative_regen * 2)
			end
			self.negative_regen = self.negative_regen_ref
			if not self:attr("positive_at_rest") then
				self.positive_regen = -self.positive_regen_ref
			end
		end
	end,
	update_regen = function(self, t)
		local regen = t.getRegen(self, t)
		if self:attr("positive_at_rest") then
			local v = self.positive_at_rest * self.max_positive / 100
			if self:getPositive() > v or self:attr("positive_at_rest_disable") then self.positive_regen = -self.positive_regen_ref
			elseif self:getPositive() < v then self.positive_regen = self.positive_regen_ref
			end
		end
		if self:attr("negative_at_rest") then
			local v = self.negative_at_rest * self.max_negative / 100
			if self:getNegative() > v or self:attr("negative_at_rest_disable")  then self.negative_regen = -self.negative_regen_ref
			elseif self:getNegative() < v then self.negative_regen = self.negative_regen_ref
			end
		end
		t.do_polarize(self, t)
	end,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) >= 1 then
			self.negative_regen_ref = t.getRegen(self, t)
			self.positive_regen_ref = t.getRegen(self, t)
			t.update_regen(self, t)
		end
	end,
 	on_unlearn = function(self, t)
		if self:getTalentLevelRaw(t) < 1 then
			if not self:attr("negative_at_rest") then
				self.negative_regen = -self.negative_regen_ref
			end
			if not self:attr("positive_at_rest") then
				self.positive_regen = -self.positive_regen_ref
			end
		end
		self.negative_regen_ref = t.getRegen(self, t)
		self.positive_regen_ref = t.getRegen(self, t)
		t.update_regen(self, t)
 	end,
	info = function(self, t)
		local regeneration = t.getRegen(self, t)
		local positive_rest = (self:attr("positive_at_rest") or 0)/100*self:getMaxPositive()
		local negative_rest = (self:attr("negative_at_rest") or 0)/100*self:getMaxNegative()
		return ([[Whichever of your positive and negative energies is a higher percentage regenerates towards its max instead of its normal resting value (%d positive, %d negative). Your negative and positive regeneration/degeneration rates are increased to %0.2f.]]):
		tformat(positive_rest, negative_rest, regeneration)
	end,
}

newTalent{
	name = "Magnetic Inversion",
	type = {"celestial/energies", 3},
	require = divi_req3,
	points = 5,
	no_energy = true,					--linear so that mastery has more of an effect
	cooldown = function(self, t) return math.max(3, math.floor(75 - 10 * self:getTalentLevel(t))) end,
	action = function(self, t)
		local pos = self:getPositive()
		self.positive = 0
		self:incPositive(self:getNegative())
		self.negative = 0
		self:incNegative(pos)
		--update this immediately since this is instant
		if self:knowTalent(self.T_CELESTIAL_ACCELERATION) then
			local t = self:getTalentFromId(self.T_CELESTIAL_ACCELERATION)
			t.do_accelerate(self, t)
		end
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return (_t[[Swap your current positive and negative energy levels. This spell takes no time to cast.]])
	end,
}

newTalent{
	name = "Plasma Bolt",
	type = {"celestial/energies", 4},
	require = divi_req4,
	points = 5,
	cooldown = 12,
	proj_speed = 5,
	radius = 1,
	range = 8,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), stop_block = true, talent=t} end,
	tactical = {ATTACKAREA = {DARKNESS = 1, LIGHT = 1}, DISABLE = 1},
	raw_cost = 25, --this is only used to easily edit the costs myself
	--truncate these to two digits, both floored to avoid cases where you should have enough but can't cast it
	positive = function(self, t) return math.floor(t.raw_cost * (1 - t.getNegPart(self, t)) * 100) / 100 end,
	negative = function(self, t) return math.floor(t.raw_cost * t.getNegPart(self, t) * 100) / 100 end,
	getRawDam = function(self, t) return self:combatTalentSpellDamage(t, 50, 270) end,
	getSlow = function(self, t) return math.min(self:combatTalentSpellDamage(t, 0.15, 0.95), 0.5) end, --the effective global slow is only half this, actually 0.4 times this since the attack slow is reduced
	getNegPart = function(self, t)
		local base_cost = t.raw_cost * (100 + self:combatFatigue()) / 100 
		--avoid calling this constantly and neaten the code
		local pos = self:getPositive()
		local neg = self:getNegative()
		if neg <= 0 then
			return 0
		end
		if self:getMaxPositive() <= 0 then
			return 1
		end
		if pos + neg <= base_cost then
			return 1 / (1 + pos / neg)
		end
		--in short, as the energies approach the base cost total, they compare the ratio
		--as they approach their caps, they compare their percents (so they approach 50/50)
		local blend = math.cos(math.pi / 2 * (pos + neg - base_cost) / (self:getMaxPositive() + self:getMaxNegative() - base_cost))
		local tmp2 = 1 / (1 + pos * self:getMaxNegative() / neg / self:getMaxPositive())
		return blend * blend * (1 / (1 + pos / neg) - tmp2) + tmp2
		--the cos needs to be squared so 1 - f(x) = f(1 - x) and they add up to the total part
	end,
	action = function(self, t)
		local neg = t.getNegPart(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		
		tg.display={particle="plasma_bolt", particle_args={light = 1 - neg}}
		tg.light_part = 1 - neg
		local damage = self:spellCrit(t.getRawDam(self, t))
		local slow = t.getSlow(self, t)
		self:projectile(tg, x, y, DamageType.LIGHT_DARK, {dam = damage, light_part = 1 - neg, slow = slow}, function(self, tg, x, y, grids)
			game.level.map:particleEmitter(x, y, tg.radius, "ball_plasma", {radius=tg.radius, tx=x, ty=y, light = tg.light_part})
		end)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	
	info = function(self, t)
		local dam = t.getRawDam(self, t)
		local negpart = t.getNegPart(self, t)
		local radius = self:getTalentRadius(t)
		local slow = 100 * t.getSlow(self, t)
		return ([[Fires out a bolt of pure energy, dealing %0.2f light and %0.2f darkness damage in a radius of %d, and slowing targets hit. Their movement is reduced by %d%% and attacking, casting and mind attacks by %d%%. The bolt will attune to your current positive and negative energy amounts.]]):
		tformat(damDesc(self, DamageType.LIGHT, dam * (1 - negpart)), damDesc(self, DamageType.DARKNESS, dam * negpart), radius, slow * negpart, slow * 0.6 * (1 - negpart))
	end,
}