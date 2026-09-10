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

local DamageType = require "engine.DamageType"

newTalent{
	name = "Dismember",
	type = {"corruption/demonic-strength", 1},
	require = str_corrs_req1,
	points = 5,
	mode = "passive",
	statBonus = function(self, t) return self:combatTalentScale(t, 5, 20, 0.75) * 0.6 end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_physcrit", t.statBonus(self, t))
	end,
	getSlow = function(self, t) return math.ceil(self:combatTalentScale(t, 15, 30, 0.75)) end,
	getAcc = function(self, t) return math.ceil(self:combatTalentScale(t, 6, 20, 0.75)) * 1.2 end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5)) end,
	callbackOnMeleeAttack = function(self, t, target, hitted, crit)
		if not hitted or not crit then return end
		target:setEffect(target.EFF_DISABLE, t.getDuration(self, t), {speed=t.getSlow(self, t)/100, atk=t.getAcc(self, t),apply_power=self:combatPhysicalpower()})
		return true
	end,
	info = function(self, t)
		return ([[Your melee attacks cripple your targets when they critically strike, lowering their movement speed by %d%% and their accuracy by %d for %d turns.
		Additionally, you gain %d%% chance to critically strike with your melee attacks.]]):tformat(t.getSlow(self, t), t.getAcc(self, t), t.getDuration(self, t), t.statBonus(self, t))
	end,
}

newTalent{
	name = "Surge of Power",
	type = {"corruption/demonic-strength", 2},
	require = str_corrs_req2,
	points = 5,
	random_ego = "utility",
	cooldown = 24,
	tactical = { STAMINA = 2, HEAL = 2, },
	vim = 16,
	no_energy=true,
	stamValue = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) end,
	getHeal = function(self, t) return self:combatTalentSpellDamage(t, 10, 200) end,
	getPower = function(self, t) return math.ceil(self:combatTalentSpellDamage(t, 20, 250)) end,
	action = function(self, t)
		local didcrit = self:spellCrit(1)
		self:incStamina(didcrit * t.stamValue(self, t))
		self:attr("allow_on_heal", 1)
		self:heal(didcrit * t.getHeal(self, t), t)
		self:attr("allow_on_heal", -1)
		self:setEffect(self.EFF_SURGE_OF_POWER, 8, {power=t.getPower(self, t)})
		game.level.map:particleEmitter(self.x, self.y, 1, "circle", {oversize=1.7, a=170, limit_life=12, shader=true, appear=12, speed=0, base_rot=180, img="surge_of_power", radius=0, y=0.2})
		return true
	end,
	info = function(self, t)
		return ([[Use your stored vim to supercharge your body, recovering %d stamina and %d life.
		Additionally, you will be able to survive your HP going under 0, down to -%d HP, for the next 8 turns.
		These values will increase with your Spellpower.
		Spell criticals with this talent also effect the stamina gain.]]):
		tformat( t.stamValue(self, t), t.getHeal(self, t), t.getPower(self, t))
	end,
}

newTalent{
	name = "Demonic Blood",
	type = {"corruption/demonic-strength", 3},
	require = str_corrs_req3,
	points = 5,
	mode = "passive",
	no_npc_use = true,
	statBonus = function(self, t) return math.ceil(self:combatTalentScale(t, 5, 20, 0.75)) end,
	vimBonus = function(self, t) return math.ceil(self:combatTalentScale(t, 5, 31, 0.75)) end,
	atkBonus = function(self, t) return math.ceil(self:combatTalentScale(t, 4, 8, 0.75)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_spellpower", t.statBonus(self, t))
		self:talentTemporaryValue(p, "demonblood_dam", t.atkBonus(self, t) / 100)
		self:talentTemporaryValue(p, "max_vim", t.vimBonus(self, t))
	end,
	info = function(self, t)
		return ([[Demonic Blood flows through your veins, increasing your spellpower by %d and your maximum vim by %d.
		Additionally, you will recieve a bonus to all damage equal to %d%% of your current vim (Currently %d%%).]]):
		tformat(
			t.statBonus(self, t),
			t.vimBonus(self, t),
			(t.atkBonus(self, t)),
			(t.atkBonus(self, t)/100)*self:getVim()
		)
	end,
}

newTalent{
	name = "Abyssal Shield",
	type = {"corruption/demonic-strength", 4},
	require = str_corrs_req4,
	points = 5,
	mode = "sustained",
	cooldown = 20,
	sustain_vim = 15,
	no_energy=true,
	no_npc_use = true,
	tactical = { BUFF = 2 },
	statBonus = function(self, t) return self:combatTalentScale(t, 3, 15, 0.75) end,
	defBonus = function(self, t) return self:combatTalentScale(t, 4, 25, 0.8) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 30) end,
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "combat_armor", t.statBonus(self, t))
		self:talentTemporaryValue(ret, "on_melee_hit", {[DamageType.FIRE]= t.getDamage(self,t), [DamageType.BLIGHT]= t.getDamage(self,t)})
		self:talentTemporaryValue(ret, "demonblood_def", t.defBonus(self, t) / 100)
		ret.particle = self:addParticles(Particles.new("circle", 1, {oversize=1, a=140, shader=true, base_rot=180, appear=12, speed=0, img="abyssal_shield", radius=0}))
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[Surround yourself with a defensive aura, increasing armor by %d, and inflicting %0.2f fire and %0.2f blight damage to all attacking foes.
Additionally, your vim will enhance your defences, reducing all damage by %d%% of your current vim (currently %d), but never reducing by more than half of the original damage. This will cost vim equal to 5%% of the damage blocked.
The damage will scale with your Spellpower.]]):
		tformat(
			t.statBonus(self, t),
			damDesc(self, DamageType.FIRE, t.getDamage(self,t)),
			damDesc(self, DamageType.BLIGHT, t.getDamage(self,t)),
			t.defBonus(self, t),
			(t.defBonus(self, t)/100)*self:getVim()
		)
	end,
}

