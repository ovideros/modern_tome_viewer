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

local Object = require "mod.class.Object"

newTalent{
	name = "Shed Skin",
	type = {"demented/horrific-body", 1},
	require = dementedreq1,
	points = 5,
	insanity = -10,
	cooldown = 10,
	no_energy = true,
	tactical = { DEFEND = 2 },
	getAbsorb = function(self, t) return self:combatTalentSpellDamage(t, 30, 370) end,
	getDuration = function(self, t) return 7 end,
	action = function(self, t)
		local power = self:spellCrit(t.getAbsorb(self, t))
		self:setEffect(self.EFF_DAMAGE_SHIELD, t.getDuration(self, t), {
			image = "shed_skin",
			-- color = {1,1,1,1},
			power = power,
			last_trigger = power,
			is_shed_skin = true,
			on_absorb = function(self, eff, src, val)
				if self:knowTalent(self.T_PUSTULENT_GROWTH) then
					self:callTalent(self.T_PUSTULENT_GROWTH, "createPustule", eff)
				end
			end,
		})
		game:playSoundNear(self, "talents/shed_skin")
		return true
	end,
	info = function(self, t)
		return ([[You shed the outer layer of your mutated skin and empower it to act as a damage shield for %d turns.
		The shield can absorb up to %d damage before it crumbles.
		]]):tformat(self:getShieldDuration(t.getDuration(self, t)), self:getShieldAmount(t.getAbsorb(self, t)))
	end,
}

newTalent{
	name = "Pustulent Growth",
	type = {"demented/horrific-body", 2},
	require = dementedreq2,
	mode = "passive",
	points = 5,
	getResist = function(self, t) return math.ceil(self:combatTalentSpellDamage(t, 1, 50) / 10) end,
	getMax = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	getCutoff = function(self, t) return self:combatTalentLimit(t, 10, 45, 20) end,
	createPustule = function(self, t, eff)
		if eff == "damage" then
			self:setEffect(self.EFF_PUTRESCENT_PUSTULE, 5, {max_stacks=t.getMax(self, t), power=t.getResist(self, t)})
		else
			if not eff.is_shed_skin then return end
			if not self.damage_shield_absorb then return end
			local p = (eff.last_trigger - self.damage_shield_absorb) / self.damage_shield_absorb_max
			if p >= t.getCutoff(self, t) / 100 then
				self:setEffect(self.EFF_PUTRESCENT_PUSTULE, 6, {max_stacks=t.getMax(self, t), power=t.getResist(self, t)})
				eff.last_trigger = self.damage_shield_absorb
			end
		end
	end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, state)
		if dam > 0 and state and not self:attr("invulnerable") and dam > self.max_life*0.15 then
			if self:knowTalent(self.T_PUSTULENT_GROWTH) then
				self:callTalent(self.T_PUSTULENT_GROWTH, "createPustule", "damage")
			end
		end
	end,
	info = function(self, t)
		return ([[Each time your shed skin looses %d%% of its max power or you take damage over 15%% of your maximum life a black putrescent pustule grows on your body for 5 turns.
		Each pustule increases all your resistances by %d%%. You can have up to %d pustules at once.
		Resistance scales with your Spellpower.]]):
		tformat(t.getCutoff(self, t), t.getResist(self, t), t.getMax(self, t))
	end,
}

newTalent{
	name = "Pustulent Fulmination",
	type = {"demented/horrific-body", 3},
	require = dementedreq3,
	points = 5,
	insanity = -20,
	cooldown = 6,
	range = 0,
	no_energy = true,
	radius = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 2, 5)) end,
	tactical = { ATTACKAREA = {DARKNESS = 2} },
	target = function(self, t) return {type="ball", radius=self:getTalentRadius(t), range=0, selffire=false, friendlyfire=false, talent=t} end,
	requires_target = true,
	getDam = function(self, t) return self:combatTalentSpellDamage(t, 10, 70) end,
	getHeal = function(self, t) return self:combatTalentSpellDamage(t, 20, 50) end,
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_PUTRESCENT_PUSTULE) end,
	action = function(self, t)
		local eff = self:hasEffect(self.EFF_PUTRESCENT_PUSTULE)
		local stacks = eff.stacks

		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.DARKNESS, self:spellCrit(t.getDam(self, t) * stacks))
		self:heal(self:spellCrit(t.getHeal(self, t) * stacks), self)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "pustulent_fulmination", {radius=tg.radius})
		game:playSoundNear(self, "talents/slime")

		self:removeEffect(self.EFF_PUTRESCENT_PUSTULE)

		if self:knowTalent(self.T_DEFILED_BLOOD) then self:callTalent(self.T_DEFILED_BLOOD, "on_fulmination", tg.radius) end

		return true
	end,
	info = function(self, t)
		return ([[You make all your putrescent pustules explode at once, splashing all creatures in radius %d with black fluids that deal %0.2f darkness damage per pustule and healing you for %0.1f per pustule.]]):
		tformat(self:getTalentRadius(t), damDesc(self, DamageType.DARKNESS, t.getDam(self, t)), t.getHeal(self, t))
	end,
}

newTalent{
	name = "Defiled Blood",
	type = {"demented/horrific-body", 4},
	require = dementedreq4,
	mode = "passive",
	points = 5,
	getDam = function(self, t) return 0.1 end,
	getHeal = function(self, t) return self:combatTalentSpellDamage(t, 10, 280) / 10 end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, state)
		if not src.hasEffect or not src:hasEffect(src.EFF_DEFILED_BLOOD) then return end
		self:heal(dam * t.getHeal(self, t) / 100, src)
	end,
	on_fulmination = function(self, t, radius)
		game.level.map:addEffect(self,
			self.x, self.y, 5,
			DamageType.DEFILED_BLOOD, t.getDam(self, t),
			radius,
			5, nil,
			MapEffect.new{zdepth=6, color_br=255, color_bg=255, color_bb=255, effect_shader="shader_images/defiled_blood.png"},
			nil, false, 0
		)
	end,
	info = function(self, t)
		return ([[When you make your pustules explode you leave a pool of defiled blood on the ground for 5 turns.
		Foes caught inside get assaulted by black tentacles every turn, dealing %d%% darkness tentacle damage and covering them in your black blood for 2 turns.
		Creatures that hit you while covered in your blood heal you for %d%% of the damage done.
		The healing received increases with your Spellpower.]]):
		tformat(t.getDam(self, t) * 100, t.getHeal(self, t))
	end,
}
