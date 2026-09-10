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
	name = "Raze",
	type = {"spell/undead-drake", 1},
	require = spells_req1,
	points = 5,
	cooldown = 10,
	mode = "sustained",
	sustain_soul=0,
	autolearn_talent = "T_SOUL_POOL",
	getDamage = function(self, t) return math.max(self:combatTalentSpellDamage(t, 10, 20), self:combatTalentMindDamage(t, 10, 20)) end,
	soulBonus = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2, 0.75)) end,
	activate = function(self, t)
		return true
	end,
	deactivate = function(self, t, p)
		return true
	end,
	callbackOnKill = function(self, t, target)
		self:incSoul(t.soulBonus(self, t))
		return true
	end,
	callbackOnDealDamage = function(self, t, value, target, dead, death_node)
		if dead or self:attr("dont_raze") then return end
		if self.turn_procs.raze and self.turn_procs.raze >= 25 then return end
		
		self:attr("dont_raze",1)
		local dam = self:spellCrit(t.getDamage(self, t))
		DamageType:get(DamageType.DARKNESS).projector(self, target.x, target.y, DamageType.DARKNESS, dam)
		self:attr("dont_raze",-1)

		self.turn_procs.raze = self.turn_procs.raze or 0
		self.turn_procs.raze = self.turn_procs.raze + 1
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[You revel in death, devouring the souls of your victims. Whenever you inflict damage to a target, you deal an additional %0.2f darkness damage.
		Additionally, you gain %d souls whenever you score a kill.
		The damage will scale with the highest of your spell or mind power and can only occur up to 25 times per turn.]]):
		tformat(damDesc(self, DamageType.DARKNESS, damage), t.soulBonus(self,t))
	end,
}

newTalent{
	name = "Infectious Miasma",
	type = {"spell/undead-drake", 2},
	require = spells_req2,
	points = 5,
	cooldown = 18,
	tactical = { ATTACKAREA = { DARKNESS = 2 }, },
	range = 6,
	radius = 3,
	soul = 1,
	autolearn_talent = "T_SOUL_POOL",
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getDamage = function(self, t) return math.max(self:combatTalentSpellDamage(t, 15, 40), self:combatTalentMindDamage(t, 15, 40)) end,
	getDuration = function(self, t) return 5 end,
	getBaneDur = function(self,t) return math.floor(self:combatTalentScale(t, 4.5, 6.5)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.MIASMA, {dam=self:spellCrit(t.getDamage(self, t)), dur=t.getBaneDur(self,t)},
			self:getTalentRadius(t),
			5, nil,
			{type="circle_of_death"},
			nil, false
		)
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Release a cloud of deadly miasma over a targeted area, dealing %0.2f darkness damage to all units inside it with a 20%% chance of inflicting a disease that will do blight damage and weaken either Constitution, Strength or Dexterity for %d turns.
		The damage will scale with the highest of your spell or mind power.]]):
		tformat(damDesc(self, DamageType.DARKNESS, damage), t.getBaneDur(self,t))
	end,
}

newTalent{
	name = "Vampiric Surge",
	type = {"spell/undead-drake", 3},
	require = spells_req3,
	points = 5,
	random_ego = "attack",
	autolearn_talent = "T_SOUL_POOL",
	soul = 3,
	cooldown = 24,
	tactical = { BUFF = 3, HEAL = 2 },
	direct_hit = true,
	range = 10,
	no_energy = true,
	requires_target = true,
	getDuration = function(self, t) return  math.floor(self:combatTalentScale(t, 4, 6)) end,
	getPower = function(self, t) return math.ceil(self:combatTalentScale(t, 6, 10, 0.75)) end,
	action = function(self, t)
		self:setEffect(self.EFF_VAMPIRIC_SURGE, t.getDuration(self, t), {power=t.getPower(self, t)})
		game:playSoundNear(self, "talents/tidalwave")
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		local dur = t.getDuration(self, t)
		return ([[You surge with a life draining energy for %d turns.
		While the effect lasts, you heal yourself for %d%% of all damage you deal.]]):
		tformat(dur, power)
	end,
}


newTalent{
	name = "Necrotic Breath",
	type = {"spell/undead-drake", 4},
	require = spells_req4,
	points = 5,
	random_ego = "attack",
	autolearn_talent = "T_SOUL_POOL",
	cooldown = 12,
	message = _t"@Source@ breathes a wave of darkness!",
	tactical = { ATTACKAREA = { DARKNESS = 2 }, DISABLE = { confusion = 2, blind = 2  }, },
	range = 0,
	soul = 2,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t)
		local bonus = self:knowTalent(self.T_CHROMATIC_FURY) and self:combatTalentStatDamage(t, "wil", 30, 550) or 0
		return self:combatTalentStatDamage(t, "mag", 30, 550) + bonus
	end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.CIRCLE_DEATH, {dam=self:spellCrit(t.getDamage(self, t))/4,dur=4})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_dark", {radius=tg.radius, tx=x-self.x, ty=y-self.y})

		if core.shader.active(4) then
			local bx, by = self:attachementSpot("back", true)
			self:addParticles(Particles.new("shader_wings", 1, {img="darkwings", life=18, x=bx, y=by, fade=-0.006, deploy_speed=14}))
		end
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[You breathe a wave of deathly miasma in a cone of radius %d. Any target caught in the area will take %0.2f darkness damage over 4 turns and receive either a bane of confusion or a bane of blindness for 4 turns.
		The damage will increase with your Magic, and the critical chance is based on your Spell crit rate.]]):tformat(self:getTalentRadius(t), damDesc(self, DamageType.DARKNESS, t.getDamage(self, t)))
	end,
}
