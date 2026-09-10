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
	name = "Burning Sacrifice",
	type = {"corruption/heart-of-fire", 1},
	require = corrs_req1,
	points = 5,
	cooldown = 5,
	mode = "passive",
	getMult = function(self, t) return 1 + math.ceil(self:combatTalentScale(t, 25, 90, 0.75))/100 end,
	getDam = function(self, t) return math.ceil(self:combatTalentScale(t, 60, 110, 0.75))/100 end,
	callbackOnKill = function(self, t, target)
		if self:isTalentCoolingDown(t) then return end
		self:startTalentCooldown(t)
		local is_burning = false
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.subtype.fire and p.power and e.status == "detrimental" then is_burning = true	end
		end
		local tgts = {}
		if is_burning then
			self:setEffect(self.EFF_RAGING_FLAMES, 6, {power=t.getMult(self, t)})
			self:addParticles(Particles.new("meleestorm", 1, {radius=1, img="raging_flames"}))
			
			for _, c in pairs(util.adjacentCoords(self.x, self.y)) do
				local targ = game.level.map(c[1], c[2], engine.Map.ACTOR)
				if targ and targ ~= target and self:reactionToward(targ) < 0 then tgts[#tgts+1] = targ end
			end
			if #tgts > 0 then
				self:attackTarget(rng.table(tgts), nil, t.getDam(self, t),  true)
			end
		end
	end,
	info = function(self, t)
		local mult = t.getMult(self, t) * 100
		local dam = t.getDam(self, t) * 100
		return ([[Whenever you kill a burning enemy, you will instantly deal a melee attack against a random adjacant enemy at %d%% power. 
		Additionally, Incinerating Blows will always trigger on this attack (or your next attack), dealing %d%% of its normal damage to all enemies hit and stunning, ignoring the cooldown.
		This can only trigger once every 5 turns.]]):
		tformat(dam, mult)
	end,
}

newTalent{
	name = "Fiery Aegis", short_name="DEVOURING_FLAMES", image = "talents/fiery_aegis.png",--Change on major release
	type = {"corruption/heart-of-fire", 2},
	require = corrs_req2,
	points = 5,
	cooldown = 10,
	getBaseShield = function (self, t) return self:combatTalentSpellDamage(t, 75, 250) end,
	getRange = function(self, t) return math.ceil(self:combatTalentScale(t, 2, 4.5)) end,
	getDur = function(self, t) return math.ceil(self:combatTalentScale(t, 3, 5)) end,
	action = function(self, t)
		local tg = {type="ball", nolock=true, range=0, radius = 10, friendlyfire=false}
		local burncount = 0
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end
			local burns = {}
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.subtype.fire and p.power and e.status == "detrimental" then
					burns[#burns+1] = {id=eff_id, params=p}
					burncount = burncount + 1
				end
			end
			for i, d in ipairs(burns) do
				target:removeEffect(d.id)
			end
		end)
		local shieldboost = (1 + burncount * 0.15) * t.getBaseShield(self, t)
		self:setEffect(self.EFF_FIRE_SHIELD, t.getDur(self, t), {power=shieldboost, radius = t.getRange(self, t), src=self})
		return true
	end,
	info = function(self, t)
		return ([[Draw in the raging fires and envelop yourself in them. Remove all burns from enemies in a radius of 5 around you, and create a shield lasting %d turns with a power of %d, increased by 15%% for each burn removed.
		When the shield ends, it releases a burst of fire in a radius of %d around you, burning all enemies for 3 turns, doing damage equal to the initial power of the shield.]]):
		tformat(self:getShieldDuration(t.getDur(self, t)), self:getShieldAmount(t.getBaseShield(self, t)), t.getRange(self, t))
	end,
}

newTalent{
	name = "Devouring Flames", short_name="INFERNO_NEXUS", image = "talents/devouring_flames.png",--Change on major release
	type = {"corruption/heart-of-fire", 3},
	require = corrs_req3,
	points = 5,
	mode = "passive",
	getHeal = function (self, t) return self:combatTalentSpellDamage(t, 1, 5) end,
	getVim = function (self, t) return self:combatTalentSpellDamage(t, 1, 3) end,
	getDam = function (self, t) return self:combatTalentSpellDamage(t, 25, 70) end,
	getRange = function(self, t) return 1 end,
	callbackOnMeleeAttack = function(self, t, target, hitted)
		if not hitted then return end
		target:setEffect(self.EFF_CURSED_FLAMES, 100, {heal=t.getHeal(self, t), vim=t.getVim(self, t), src=self})
		return true
	end,
	callbackOnActBase = function(self, t)
		local tg = {type="ball", nolock=true, range=0, radius = 10, friendlyfire=false}
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end
			if target:hasEffect(target.EFF_CURSED_FLAMES) then
				if rng.percent(50) then
					self:project({type="ball", range=0, radius = 1, friendlyfire=false, x=target.x, y=target.y}, target.x, target.y, function(px, py)
						local target2 = game.level.map(px, py, engine.Map.ACTOR)
						if not target2 then return end
						local is_burning = false
						for eff_id, p in pairs(target.tmp) do
							local e = target2.tempeffect_def[eff_id]
							if e.subtype.fire and p.power and e.status == "detrimental" then is_burning = true	end
						end
						if target2.turn_procs.doombringer_burnt then return end
						if target2:hasEffect(target.EFF_CURSED_FLAMES) then return end
						target2.turn_procs.doombringer_burnt = true
						DamageType:get(DamageType.FIREBURN).projector(self, target2.x, target2.y, DamageType.FIRE, t.getDam(self,t))
						game:onTickEnd(function() target2:setEffect(self.EFF_CURSED_FLAMES, 100, {heal=t.getHeal(self, t), vim=t.getVim(self, t), src=self}) end)
					end)
				end
			end
		end)
		return true
	end,
	info = function(self, t)
		return ([[Your connection to fire nourishes you. Whenever you strike an enemy in melee, you inflict a burning curse upon them. As long as they continue to burn, you gain %0.2f health and %0.2f vim per turn.
		Each turn they remain within 10 spaces of you, all enemies with cursed flames will spread it to other burning enemies in radius 1, causing you to heal for the same amount for each enemy, as well as dealing %d fire damage on spreading.]]):
		tformat(t.getHeal(self, t), t.getVim(self, t), damDesc(self, DamageType.FIRE, t.getDam(self, t)))
	end,
}

newTalent{
	name = "Blazing Rebirth",
	type = {"corruption/heart-of-fire", 4},
	require = corrs_req4,
	points = 5,
	cooldown = function (self, t) return math.max(25, 50 - self:getTalentLevelRaw(t) * 5) end,
	vim = 30,
	no_npc_use = true, --No.
	getDur = function (self, t) return math.ceil(self:combatTalentScale(t, 4, 8)) end,
	getRange = function(self, t) return math.ceil(self:combatTalentScale(t, 1, 4)) end,
	action = function(self, t)
		local hp = self.max_life - self.life
		
		local old_life = self.life
		self:heal(hp)
		if self.life == old_life then return nil end

		self:setEffect(self.EFF_REBIRTH_BY_FIRE, t.getDur(self,t), {power = hp / t.getDur(self,t), radius = t.getRange(self,t)})		
		game.level.map:particleEmitter(self.x, self.y, 1, "circle", {oversize=1.7, a=190, limit_life=12, shader=true, appear=12, speed=0, img="blazing_rebirth", radius=0})
		return true
	end,
	info = function(self, t)
		return ([[Restore yourself to full health, but take damage equal to the damage healed over %d turns. This damage is split evenly among you and all burning enemies in radius %d. Damage you take is irresistable. Damage to enemies is fire damage.]]):
		tformat(t.getDur(self, t), t.getRange(self, t))
	end,
}