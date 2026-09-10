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
	name = "Metaphasic Spin", short_name = "METATEMPORAL_SPINNER",
	type = {"spell/occult-technomancy",1},
	require = technomancy_req_high1, is_technomancy = true, is_steam = true,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	sustain_mana = 40,
	sustain_steam = 10,
	remove_on_zero = false,
	cooldown = function(self, t) if self:attr("metaphasic_spin_cd_reduce") then return 6 else return 30 end end,
	use_only_arcane = 5,
	tactical = { BUFF=2 },
	no_npc_use = true,
	on_levelup_close = function(self, t)
		game.party:learnTinker("STEAMSAW")
	end,
	getDamage = function(self, t) return 30 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 1.5 end,
	getRetaliationDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 2) end,
	getRegen = function(self, t, o) local perc = 0.5 + (type(o) == "number" and o or (o.material_level or 1)) / 10 return self:combatTalentScale(t, 0.5, 4) * perc end,
	getSpellpower = function(self, t, o) local perc = 0.5 + (type(o) == "number" and o or (o.material_level or 1)) / 10 return self:combatTalentScale(t, 10, 50) * perc end,
	getSpellCrit = function(self, t, o) local perc = 0.5 + (type(o) == "number" and o or (o.material_level or 1)) / 10 return self:combatTalentScale(t, 3, 10) * perc end,
	callbackOnMeleeHit = function(self, t, src, dam)
		local p = self:isTalentActive(self.T_METATEMPORAL_SPINNER)
		if not p then return end
		local weapon = p.o
		if src.turn_procs.metatemporal_spinner_retaliate or not weapon or dam <= 0 then return end
		src.turn_procs.metatemporal_spinner_retaliate = true

		self.turn_procs.auto_melee_hit = true
		self:attackTargetWith(src, weapon.combat, DamageType.OCCULT, t.getRetaliationDamage(self, t))
		self.turn_procs.auto_melee_hit = nil
	end,
	on_pre_use = function(self, t, silent) if not self:knowTalent(self.T_TINKER_ARCANE_DYNAMO) then if not silent then game.logPlayer(self, "You need an arcane dynamo to cast this spell.") end return false end return true end,
	activate = function(self, t)
		local inven = self:getInven("INVEN")
		local d = self:showInventory(_t"Select the steamsaw to use?", inven, function(o) return o.type == "weapon" and o.subtype == "steamsaw" end, nil)
		d.action = function(o, item) self:talentDialogReturn(true, o, item) return false end
		local ret, o, item = self:talentDialog(d)
		if not ret then return nil end

		self:removeObject(inven, item)

		local ret = {
			o = o,
		}
		self:talentTemporaryValue(ret, "combat_spellpower", t.getSpellpower(self, t, o))
		self:talentTemporaryValue(ret, "combat_spellcrit", t.getSpellCrit(self, t, o))
		self:talentTemporaryValue(ret, "mana_regen", t.getRegen(self, t, o))
		local oldblock = nil
		if o.wielder and o.wielder.learn_talent and o.wielder.learn_talent.T_BLOCK then
			oldblock = o.wielder.learn_talent.T_BLOCK
			o.wielder.learn_talent.T_BLOCK = nil
		end
		self:onWear(o, "FAKE", true, true)
		if oldblock then
			o.wielder.learn_talent.T_BLOCK = oldblock
		end

		if core.shader.active() then
			ret.particle1 = self:addParticles(Particles.new("image", 1, {image="particles_images/arcane_sawblade_smaller", x=0, y=-0.1, size=100}, {type="metaphasic_spin", time_factor=35, noup=2.0}))
		 	ret.particle1.toback = true
			ret.particle2 = self:addParticles(Particles.new("image", 1, {image="particles_images/arcane_sawblade_smaller", x=0, y=-0.1, size=100}, {type="metaphasic_spin", time_factor=35, noup=1.0}))
		end

		return ret
	end,
	deactivate = function(self, t, p)
		if p.particle1 then self:removeParticles(p.particle1) end
		if p.particle2 then self:removeParticles(p.particle2) end

		local o = p.o
		local oldblock = nil
		if o.wielder and o.wielder.learn_talent and o.wielder.learn_talent.T_BLOCK then
			oldblock = o.wielder.learn_talent.T_BLOCK
			o.wielder.learn_talent.T_BLOCK = nil
		end
		self:onTakeoff(o, "FAKE", true, true)
		if oldblock then
			o.wielder.learn_talent.T_BLOCK = oldblock
		end
		self:addObject("INVEN", o)
		self:sortInven()
		return true
	end,
	info = function(self, t)
		return ([[You imbue a steamsaw with arcane and temporal forces, making it spin very fast around your waist (ignoring requirements).
		The saw spins so fast it it disturbs spacetime around you, increasing your spellpower by up to %d, your spell critical chance by up to %d and your mana regen by up to %0.1f (depending on steamsaw tier).
		Any successful melee attack against you also triggers an automatic steamsaw attack that cannot miss dealing %d%% weapon damage as occult damage (arcane and temporal).
		The steamsaw used will provide its bonus as if it was worn, but you can not Block with it.
		Increases steamsaws weapon damage by %d%% and uses Magic instead of Strength to determine their damage.
		If using Aether Avatar, all Occult Technomancy spells become usable for its duration and all occult damage becomes pure arcane.

		#{italic}#When you first learn this talent you also learn the Steamsaw tinker creation if you didn't already know it.#{normal}#
		]]):tformat(t.getSpellpower(self, t, 5), t.getSpellCrit(self, t, 5), t.getRegen(self, t, 5), t.getRetaliationDamage(self, t) * 100, t.getPercentInc(self, t) * 100)
	end,
}

newTalent{
	name = "Reality Breach",
	type = {"spell/occult-technomancy",2},
	require = technomancy_req_high2, is_technomancy = true, is_steam = true,
	points = 5,
	steam = 25,
	mana = 30,
	cooldown = 6,
	use_only_arcane = 5,
	tactical = { ATTACKAREA = { TEMPORAL = 2, ARCANE = 2 }, },
	requires_target = true,
	range = 10,
	target = function(self, t) return {type="widebeam", force_max_range=true, radius=1, range=self:getTalentRange(t), selffire=false, talent=t} end,
	getSlow = function(self, t) return math.min(self:getTalentLevel(t) * 0.05, 0.5) end,
	getProj = function(self, t) return math.min(90, 5 + self:combatTalentSpellDamage(t, 5, 500) / 10) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 370) end,
	on_pre_use = function(self, t, silent)
		if not self:knowTalent(self.T_TINKER_ARCANE_DYNAMO) then if not silent then game.logPlayer(self, "You need an arcane dynamo to cast this spell.") end return false end
		if not self.is_technomancy_image and not self:isTalentActive(self.T_METATEMPORAL_SPINNER) then if not silent then game.logPlayer(self, "You need to activate Metatemporal Spinner to cast this spell.") end return false end
		return true
	end,
	callbackOnCloned = function(self, t)
		self._reality_breach_remain = nil
		self._reality_breach_desc = nil
	end,
	callbackOnChangeLevel = function(self, t, what)
		self._reality_breach_remain = nil
		self._reality_breach_desc = nil
	end,
	callbackOnAct = function(self, t)
		if self._reality_breach_remain then
			self._reality_breach_remain = self._reality_breach_remain - 1
			if self._reality_breach_remain <= 0 then
				self._reality_breach_remain = nil
				self._reality_breach_desc = nil
			end
		end
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		if core.fov.distance(self.x, self.y, x, y) < 1 then return nil end

		local tgts = {}
		local dam = self:spellCrit(t.getDamage(self, t))
		local slow = t.getSlow(self, t)
		local proj = t.getProj(self, t)
		self:project(tg, x, y, function(px, py)
			DamageType:get(DamageType.OCCULT).projector(self, px, py, DamageType.OCCULT, dam)
			local target = game.level.map(px, py, Map.ACTOR)
			if target then tgts[target] = true end
		end)

		local sorted_tgts = {}
		for target, _ in pairs(tgts) do
			sorted_tgts[#sorted_tgts+1] = {target=target, dist=core.fov.distance(self.x, self.y, target.x, target.y)}
		end
		table.sort(sorted_tgts, "dist")

		-- Compute beam direction to knockback all targets in that direction even if they are on the sides of the beam
		local angle = math.atan2(y - self.y, x - self.x)

		for _, tgt in ripairs(sorted_tgts) do
			local target = tgt.target
			if target:canBe("slow") then
				target:setEffect(target.EFF_CONGEAL_TIME, 4, {slow=slow, proj=proj, apply_power=self:combatSpellpower()})
			end
			if self:getTalentLevel(t) >= 5 and target:canBe("knockback") then
				target:pull(target.x + math.cos(angle) * 10, target.y + math.sin(angle) * 10, 3)
			end
		end

		if self:getTalentLevel(t) >= 3 then
			self:projectApply(tg, x, y, Map.PROJECTILE, function(proj, px, py)
				proj:terminate(px, py)
				game.level:removeEntity(proj, true)
				proj.dead = true
				self:logCombat(proj, "#Source# annihilates '#Target#'!")
			end)
		end

		game.level.map:particleEmitter(self.x, self.y, 10, "time_breach", {tx=x-self.x, ty=y-self.y})
		game.level.map:particleEmitter(self.x, self.y, 10, "time_breach", {tx=x-self.x, ty=y-self.y})
		game.level.map:particleEmitter(self.x, self.y, 10, "time_breach3", {tx=x-self.x, ty=y-self.y})
		game.level.map:particleEmitter(self.x, self.y, 10, "time_breach2", {tx=x-self.x, ty=y-self.y})
		if core.shader.allow("distort") then
			game.level.map:particleEmitter(self.x, self.y, 10, "time_breach_distort", {tx=x-self.x, ty=y-self.y})
		end

		game:shakeScreen(10, 3)
		game:playSoundNear(self, "talents/reality_breach")

		local effect_desc = {
			from = {x=self.x, y=self.y},
			to = {x=x, y=y},
			range = self:getTalentRange(t),
		}

		if self:hasEffect(self.EFF_METAPHASIC_ECHO) then
			local eff = self:hasEffect(self.EFF_METAPHASIC_ECHO)
			eff.list[#eff.list+1] = effect_desc
		end

		self._reality_breach_desc = effect_desc
		self._reality_breach_remain = 2

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local slow = t.getSlow(self, t)
		local proj = t.getProj(self, t)
		return ([[Spin your saw at incredible speeds for an instant, fully breaking reality in a 3-wide beam in front of you.
		Any creatures caught by the beam take %0.2f occult damage and are untethered from reality, reducing their global speed by %d%% and the speed of any projectiles they fire by %d%% for 4 turns.
		At level 3 any projectiles caught in the beam are instantly annihilated.
		At level 5 the beam is so strong that all creatures caught inside are knocked back 3 tiles.
		The breach is so deep that the beam will always have the maximum possible length it can.
		The damage will increase with your Spellpower.]]):tformat(damDesc(self, DamageType.OCCULT, damage), 100 * slow, proj)
	end,
}

newTalent{
	name = "Ethereal Steam",
	type = {"spell/occult-technomancy",3},
	require = technomancy_req_high3, is_technomancy = true, is_steam = true,
	points = 5,
	steam = 20,
	mana = 15,
	cooldown = 15,
	use_only_arcane = 5,
	tactical = { ATTACKAREA = { ARCANE = 1, TEMPORAL = 1 }, },
	radius = 10,
	target = function(self, t) return {type="ball", radius=self:getTalentRadius(t), talent=t} end,
	getDur = function(self, t) return self:combatTalentLimit(t, 25, 6, 15) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 220) / 10 end,
	on_pre_use = function(self, t, silent)
		if not self:knowTalent(self.T_TINKER_ARCANE_DYNAMO) then if not silent then game.logPlayer(self, "You need an arcane dynamo to cast this spell.") end return false end
		if not self:isTalentActive(self.T_METATEMPORAL_SPINNER) then if not silent then game.logPlayer(self, "You need to activate Metatemporal Spinner to cast this spell.") end return false end
		return true
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tgts = self:projectCollect(tg, self.x, self.y, Map.ACTOR, function(target)
			return self:reactionToward(target) < 0 and target:hasEffect(target.EFF_CONGEAL_TIME)
		end)
		if not next(tgts) then return nil end

		local dam = self:spellCrit(t.getDamage(self, t))
		for target, _ in pairs(tgts) do
			target:setEffect(target.EFF_ETHEREAL_STEAM, t.getDur(self, t), {src=self, dam=dam})
		end

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[You reach out through the aether to all creatures in sight that were slowed by Reality Breach or Congeal Time.
		For each target you create a link of arcane infused steam to it that lasts %d turns.
		Any time the target uses a talent one of your cooling down spells is reduced by 1 (prioritizing Technomancy spells).
		Each turn the link is up the target and any creature inside the link takes %0.2f occult damage.
		As long as at least one link is up, the cooldown of your Metaphasic Spin spell is set to 6 turns instead of 30.
		The damage will increase with your Spellpower.]]):tformat(t.getDur(self, t), damDesc(self, DamageType.OCCULT, damage))
	end,
}

newTalent{
	name = "Metaphasic Echoes", short_name = "METAPHASIC_PULSE",
	type = {"spell/occult-technomancy",4},
	require = technomancy_req_high4, is_technomancy = true, is_steam = true,
	points = 5,
	steam = 40,
	mana = 40,
	cooldown = function(self, t) return self:combatTalentLimit(t, 6, 30, 20) end,
	use_only_arcane = 5,
	tactical = { ATTACKAREA = { ARCANE = 2, TEMPORAL = 2 }, DISABLE = function(self, t, aitarget)
			if self:getTalentLevel(t) < 5 then return 0 end
			local nb = 0
			for eff_id, p in pairs(aitarget.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type ~= "other" and e.status == "beneficial" then nb = nb + 1 end
			end
			return nb^0.5
		end
	},
	range = 10,
	target = function(self, t) return {type="ball", radius=self:getTalentRange(t), talent=t} end,
	getReduce = function(self, t) return self:combatTalentScale(t, 1, 5) end,
	getDur = function(self, t) return self:combatTalentScale(t, 3, 6) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.4, 1.15) end,
	on_pre_use = function(self, t, silent)
		if not self:knowTalent(self.T_TINKER_ARCANE_DYNAMO) then if not silent then game.logPlayer(self, "You need an arcane dynamo to cast this spell.") end return false end
		if not self:isTalentActive(self.T_METATEMPORAL_SPINNER) then if not silent then game.logPlayer(self, "You need to activate Metatemporal Spinner to cast this spell.") end return false end
		if not self._reality_breach_remain then if not silent then game.logPlayer(self, "You can only cast this spell on the turn after Reality Breach.") end return false end
		return true
	end,
	doEcho = function(self, t, list)
		local p = self:isTalentActive(self.T_METATEMPORAL_SPINNER)
		if not p then return end
		local weapon = p.o

		local dam_tgts = {}
		for _, data in ipairs(list) do
			local x, y = data.to.x, data.to.y
			self:projectCollect({type="widebeam", radius=1, force_max_range=true, range=data.range, selffire=false, x=data.from.x, y=data.from.y}, x, y, Map.ACTOR, nil, dam_tgts)

			game.level.map:particleEmitter(data.from.x, data.from.y, data.range, "time_breach", {a=0.5, tx=x-data.from.x, ty=y-data.from.y})
			game.level.map:particleEmitter(data.from.x, data.from.y, data.range, "flying_sawblade", {size_factor=2, image="particles_images/arcane_sawblade_smaller", tx=x-data.from.x, ty=y-data.from.y})
			if core.shader.allow("distort") then
				game.level.map:particleEmitter(data.from.x, data.from.y, data.range, "time_breach_distort", {tx=x-data.from.x, ty=y-data.from.y})
			end
		end
		for target, _ in pairs(dam_tgts) do
			self.turn_procs.auto_melee_hit = true
			self:attackTargetWith(target, weapon.combat, DamageType.OCCULT, t.getDamage(self, t))
			self.turn_procs.auto_melee_hit = nil

			target:removeEffectsFilter(self, function(eff) return eff.status == "beneficial" and eff.type ~= "other" end, 1, false, false, function(_, eff_id)
				local p = target.tmp[eff_id]
				p.dur = p.dur - t.getReduce(self, t)
				if p.dur <= 0 then return true end
			end)
		end
		game:shakeScreen(4, 1)
	end,
	action = function(self, t)
		self:setEffect(self.EFF_METAPHASIC_ECHO, t.getDur(self, t), {list={self._reality_breach_desc}})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[Using your sheer arcane power you keep breaches in spacetime open for %d turns.
		Each turn they are open you project an occult clone of your saw along each breach, damaging any creature caught for %d%% occult weapon damage.
		The saw cuts both in a physical and arcane way, reducing the duration of a random beneficial effect on each target by %d each time.
		Each target can only be affected once per turn.
		This spell is only usable for one turn after casting Reality Breach but any Reality Breach cast during its duration is also recorded inside.]])
		:tformat(t.getDur(self, t), t.getDamage(self, t) * 100, t.getReduce(self, t))
	end,
}
