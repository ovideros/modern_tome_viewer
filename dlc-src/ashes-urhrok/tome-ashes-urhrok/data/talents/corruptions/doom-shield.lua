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
	name = "Osmosis Shield",
	type = {"corruption/doom-shield", 1},
	require = corrs_req1,
	points = 5,
	mode = "sustained",
	remove_on_zero = true,
	sustain_vim = 5,
	drain_vim = 3,
	sustain_stamina = 20,
	cooldown = 15,
	tactical = { DEFEND = 2 },
	range = 10,
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "You require a weapon and a shield to use this talent.") end return false end return true end,
	getChance = function(self, t) return self:combatTalentLimit(t, 100, 20, 70) end,
	getAbsorb = function(self, t)
		local block = self:combatShieldBlock()
		if not block then return 0 end
		return 5 + block * self:combatTalentLimit(t, 50, 15, 40) / 100
	end,
	deactivate_on = {no_combat=true, run=true, rest=true},
	callbackOnHit = function(self, t, cb, src)
		local a = t.getAbsorb(self, t)
		if not a then return end
		if self:getTalentLevel(t) >= 3 and cb.value > a * 2 and rng.percent(t.getChance(self, t)) and not self.turn_procs.osmosis_shield then
			if self:removeEffectsFilter(self, {type="physical", status="detrimental"}, 1) > 0 then
				self.turn_procs.osmosis_shield = true
			end
		end
		
		local abs = math.min(cb.value, a)
		self.osmosis_shield_abs = (self.osmosis_shield_abs or 0) + abs
		game:delayedLogDamage(src, self, 0, ("#SLATE#(%d turned into osmosis)#LAST#"):tformat(abs), false)
		return true
	end,
	callbackOnAct = function(self, t)
		if not self.osmosis_shield_abs or self.osmosis_shield_abs <= 0 then return end
		self:setEffect(self.EFF_OSMOSIS_REGEN, 3, {power=self.osmosis_shield_abs})
		self.osmosis_shield_abs = 0
	end,
	activate = function(self, t)
		local ret = {}
		self.osmosis_shield_abs = 0
		self.energy.value = self.energy.value + game.energy_to_act * self:combatSpellSpeed()
		game:playSoundNear(self, "talents/spell_generic")

		if core.shader.allow("adv") then
			ret.particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {toback=true, a=0.5, rotation=3.5, radius=1.5, img="osmosis_shield"}, {type="osmosis_shield"}))
		end

		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self.osmosis_shield_abs = nil
		return true
	end,
	info = function(self, t)
		return ([[You infuse your shield with the energies of Urh'Rok, bringing about a magical shield that heals you for the first points of all damage you receive (based on your shield's block value) over 3 turns. This effect stacks.
		Amount is 5 + %d%% of your shield block value (currently %d).
		At level 3 if a damage dealt is at least twice as high you have %d%% chance to also remove a physical detrimental effect. This effect can only happen once per turn.
		This spell disabled automatically on rest or run.
		#{bold}#Activating the shield takes no time but de-activating it does.#{normal}#
		The damage increases with spellpower.]])
		:tformat(self:combatTalentLimit(t, 50, 15, 40), t.getAbsorb(self, t), t.getChance(self, t))
	end,
}

newTalent{
	name = "Hardened Core",
	type = {"corruption/doom-shield", 2},
	require = corrs_req2,
	points = 5,
	sustain_vim = 18,
	sustain_stamina = 18,
	cooldown = 30,
	mode = "sustained",
	tactical = { BUFF = 2 },
	armor = function(self, t, v)
		return 10 + v * self:combatTalentScale(t, 1, 1.3)
	end,
	spellpower = function(self, t) return self:combatTalentScale(t, 20, 40, 0.75) end,
	activate = function(self, t)
		local ret = {}
		-- self:addShaderAura("hardened_core", "awesomeaura", {time_factor=7500, alpha=0.6, flame_scale=0.6}, "particles_images/darkwings.png")
		self:addShaderAura("hardened_core", "crystalineaura", {time_factor=2500, spikeOffset=0.223123, spikeLength=0.5, spikeWidth=1, growthSpeed=2, color=colors.hex1"ab2828"}, "particles_images/spikes.png")
		return ret
	end,
	deactivate = function(self, t)
		self:removeShaderAura("hardened_core")
		return true
	end,
	info = function(self, t)
		return ([[Taking example from Mal'Rok, the demon's homeworld you harden yourself.
		Increases total armour by %d%% + 10 and spellpower by %d.]]):
		tformat((self:combatTalentScale(t, 1, 1.3)-1) * 100, self:combatTalentScale(t, 20, 40, 0.75))
	end,
}

newTalent{
	name = "Demonic Madness",
	type = {"corruption/doom-shield", 3},
	require = corrs_req3,
	points = 5,
	stamina = 15,
	vim = 12,
	cooldown = 9,	
	range = 0,
	radius = 1,
	tactical = { ATTACKAREA = 2, DISABLE = {confusion = 2} },
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t)}
	end,
	getDam = function(self, t) return self:combatTalentWeaponDamage(t, 1.2, 2.2, self:getTalentLevel(self.T_SHIELD_EXPERTISE)) end,
	getDur = function(self, t) return self:combatTalentLimit(t, 7, 2, 5) end, -- Limit < 100%
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "You require a weapon and a shield to use this talent.") end return false end return true end,
	action = function(self, t)
		local shield, shield_combat = self:hasShield()
		if not shield then return nil end

		local shielddam = t.getDam(self, t)

		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				local speed, hit = self:attackTargetWith(target, shield_combat, DamageType.DARKNESS, shielddam)
				if hit then
					if target:canBe("confusion") then target:setEffect(target.EFF_CONFUSED, t.getDur(self, t), {apply_power=self:combatSpellpower(), power=50}) end
				end
			end
		end)

		self:addParticles(Particles.new("meleestorm2", 1, {}))
		self:addParticles(Particles.new("demonic_madness", 1, {radius=0}))

		if self:getTalentLevel(t) >= 4 then
			self:forceUseTalent(self.T_BLOCK, {ignore_cooldown=true, ignore_energy=true, no_talent_fail=true})
		end

		return true
	end,
	info = function(self, t)
		return ([[You spin around madly with your shield, bashing all those around you for %d%% shield damage as darkness, confusing your foes for %d turns.
		At level 4 you also automatically block at the end.]]):
		tformat(t.getDam(self, t) * 100, t.getDur(self, t))
	end,
}

newTalent{
	name = "Blighted Shield",
	type = {"corruption/doom-shield", 4},
	require = corrs_req4,
	points = 5,
	mode = "passive",
	imppower = function(self,t) return self:combatLimit(self:combatTalentSpellDamage(t, 10, 30),100, 0, 0, 19.36, 19.36) end, -- Limit to <100%
	callbackOnTemporaryEffect = function(self, t, eff_id, e, p)
		if eff_id ~= self.EFF_BLOCKING then return end
		p.properties = p.properties or {}
		p.properties.blighted_shield_on_cs = p.properties.on_cs
		p.properties.on_cs = function(self, eff, dam, type, src)
			if eff.properties.blighted_shield_on_cs then eff.properties.blighted_shield_on_cs(self, eff, dam, type, src) end

			local t = self:getTalentFromId(self.T_BLIGHTED_SHIELD)
			src:setEffect(src.EFF_CURSE_IMPOTENCE, 10, {power=t.imppower(self,t), apply_power=self:combatSpellpower()})
			game.level.map:particleEmitter(src.x, src.y, 1, "circle", {base_rot=0, oversize=0.7, a=130, limit_life=8, appear=8, speed=0, img="curse_gfx_02", radius=0})
		end
	end,
	info = function(self, t)
		return ([[Your shield is infused with a powerful blight. Anytime you block and apply a counterstrike effect the target is also afflicted by a curse of impotence.
		Cursed creatures have all their damage decreased by %d%% for 5 turns.
		The effects will improve with your Spellpower.]]):tformat(t.imppower(self,t))
	end,
}
