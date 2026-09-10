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
	name = "Incinerating Blows",
	type = {"corruption/torture", 1},
	require = str_corrs_req1,
	points = 5,
	mode = "passive",
	cooldown = 6,
	hotkey=true,
	--sustain_vim=0,
	--no_energy=true,
	activate = function(self, t)
		return true
	end,
	deactivate = function(self, t, p)
		return true
	end,
	radius = function(self, t)
		return math.floor(self:combatTalentScale(t, 1, 2.5))
	end,
	getStunRad = function(self, t)
		return  math.ceil(self:combatTalentScale(t, 2, 4))
	end,
	getChance = function(self, t) 
		if self:attr("is_destroyer") then
			return 25 + (10 * self.is_destroyer)
		elseif self:attr("raging_flame_mult") then
			return 100
		else
			return 25
		end
	end,
	getPowerbonus = function(self, t) 
		return 5 * self:getTalentLevelRaw(t)
	end,
	getDur = function(self, t) 
		return 3
	end,
	damBonus = function(self, t) return self:combatTalentSpellDamage(t, 20, 40) end,
	bigBonus = function(self, t) return self:combatTalentSpellDamage(t, 20, 150) end,
	callbackOnMeleeAttack = function(self, t, target, hitted)
		if not hitted then return end
		local tg = {type="hit", range=10, talent=t}
		local mult = 1
		if self:attr("raging_flame_mult") then
			mult = self.raging_flame_mult
		end
		local dam = self:spellCrit(t.damBonus(self, t)) * mult
		self:project(tg, target.x, target.y, DamageType.FIREBURN, dam)
		local procchance = t.getChance(self, t)
		if not rng.percent(procchance) then return end
		local dam = t.bigBonus(self, t) * mult
		if self:isTalentCoolingDown(t) and not self:attr("raging_flame_mult") then
			local tg = {type="ball", 10, radius=self:getTalentRadius(t), friendlyfire=false}
			self:project(tg, target.x, target.y, DamageType.FIREBURN, {dur=t.getDur(self, t), dam=self:spellCrit(dam)})
			game.level.map:particleEmitter(target.x, target.y, tg.radius, "ball_fire", {radius=tg.radius})		
		else
			local tg = {type="ball", 10, radius=t.getStunRad(self,t), friendlyfire=false}
			self:attr("combat_spellpower", t.getPowerbonus(self, t))
			self:project(tg, target.x, target.y, DamageType.FLAMESHOCK, {dur=t.getDur(self, t), dam=self:spellCrit(dam)})
			self:attr("combat_spellpower", -t.getPowerbonus(self, t))
			game.level.map:particleEmitter(target.x, target.y, tg.radius, "ball_fire", {radius=tg.radius})
			if not self:attr("raging_flame_mult") then
				self:startTalentCooldown(t)
			end
		end
		return
	end,
	info = function(self, t)
		return ([[The power of the Fearscape infuses your weapon: Your melee attacks will deal %0.2f fire damage, spread over 3 turns.
		Additionally, every time you attack, there is a %d%% chance of releasing a burst of powerful fire that will deal %0.2f fire damage to all enemies in radius %d over %d turns.
		If this talent is not on cooldown, the burst of fire will instead be radius %d, and stun all targets in addition to burning them.
		For the purposes of applying the stun, you have %d bonus spellpower.
		The damage will increase with your Spellpower.]]):
		tformat(
			damDesc(self, DamageType.FIRE, t.damBonus(self, t)),
			t.getChance(self, t),
			damDesc(self, DamageType.FIRE, t.bigBonus(self, t)),
			self:getTalentRadius(t),
			t.getDur(self, t),
			t.getStunRad(self,t),
			t.getPowerbonus(self, t)
		)
	end,
}

newTalent{
	name = "Abduction",
	type = {"corruption/torture", 2},
	require = str_corrs_req2,
	points = 5,
	cooldown = 10,
	random_ego = "attack",
	stamina = 25,
	vim = 14,
	range = function(self, t) return  math.ceil(self:combatTalentScale(t, 3.75, 8)) end,
	tactical = { CLOSEIN = 3, DISABLE = 1, ATTACK = {weapon = 1}, },
	requires_target = true,
	getSmallhit = function (self, t) return self:combatTalentWeaponDamage(t, 0.7, 1.05) end,
	getBighit = function (self, t) return self:combatTalentWeaponDamage(t, 1, 1.35) end,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		if not game.level.map.seens(x, y) or not self:hasLOS(x, y) then return nil end
		local had_effect = false
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end
			had_effect = true
			if self:attackTarget(target, nil, t.getSmallhit(self,t), true) and not target.dead then
				target:pull(self.x, self.y, tg.range)
				self:attackTarget(target, nil, t.getBighit(self,t), true)
				if self:attr("is_destroyer") then
					for i = 1, math.ceil(self.is_destroyer/2) do
						if not target.dead then self:attackTarget(target, nil, 0.35, true) end
					end
				end
			end
		end)
		return had_effect
	end,
	info = function(self, t)
		return ([[Hits the target doing %d%% weapon damage. If the attack hits, you pull the target in and strike them again, dealing another %d%% weapon damage.]]):tformat(100 * t.getSmallhit(self, t), 100 * t.getBighit(self, t))
	end,
}

newTalent{
	name = "Fiery Torment",
	type = {"corruption/torture", 3},
	require = str_corrs_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 14,
	vim = 20,
	stamina = 12,
	no_npc_use = true,
	getMainhit = function (self, t) return self:combatTalentWeaponDamage(t, 0.8, 1.15) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 80) end,
	getResist = function(self, t) return math.ceil(self:combatTalentScale(t, 10, 41.5)) end,
	getPercent = function(self, t) return self:combatTalentSpellDamage(t, 6, 30) end,
	getDur = function(self, t) return 5 end,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:attackTarget(target, nil, t.getMainhit(self,t), true)

		if hit then
			target:setEffect(target.EFF_FIERY_TORMENT, t.getDur(self,t), {src = self, apply_power=self:combatSpellpower(), finaldam=t.getDamage(self, t), rate=t.getPercent(self, t) *0.01, power=t.getResist(self,t)})
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with your weapon doing %d%% weapon damage. If the attack hits, the target is afflicted with Fiery Torment for %d turns, reducing their fire resistance by %d%%.
		When Fiery Torment ends the victim will take %d fire damage. This damage will increase by %d%% of all damage taken while under torment.
		The damage dealt by the effect will increase with spellpower.
		Demons under fiery torment will be burned by the flames of the Fearscape.]])
		:tformat(100 * t.getMainhit(self,t),
		t.getDur(self,t),
		t.getResist(self,t),
		t.getDamage(self, t),
		t.getPercent(self, t))
	end,
}

newTalent{
	name = "Eternal Suffering", --AKA Anti-Timeless
	type = {"corruption/torture", 4},
	require = str_corrs_req4,
	points = 5,
	sustain_vim = 20,
	cooldown = 15,
	mode = "sustained",
	range = 0,
	no_energy=true,
	no_npc_use=true, --Infinite Lockdown, boo
	getChance = function(self, t) return math.ceil(self:combatTalentScale(t, 15, 50)) end,
	getExtend = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3.5)) end,
	activate = function(self, t)
		return true
	end,
	deactivate = function(self, t, p)
		return true
	end,
	callbackOnMeleeAttack = function(self, t, target, hitted)
		local tt = self:isTalentActive(t.id)
		if not tt then return end
		if not rng.percent(t.getChance(self,t)) or not hitted or target:attr("suffering_immune") then return end
		local todel = {}
		local affected = false
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.type ~= "other" then
				if e.status == "beneficial" then
					p.dur = p.dur - t.getExtend(self, t)
					affected = true
					if p.dur <= 0 then todel[#todel+1] = eff_id end
				elseif e.status == "detrimental" then
					affected = true
					p.dur = p.dur + t.getExtend(self, t)
				end
			end
		end
		if affected then
			game.level.map:particleEmitter(target.x, target.y, 1, "circle", {oversize=1, a=170, limit_life=12, shader=true, appear=12, speed=0, base_rot=180, img="eternal_suffering", radius=0})
		end
		while #todel > 0 do
			target:removeEffect(table.remove(todel))
		end
		target:setEffect(target.EFF_SUFFERING_IMMUNE, 6, {})
		return true
	end,
	info = function(self, t)
		return ([[Your strikes are imbued with a vile power that extends your victim's suffering. When hitting in melee, you have a (%d%%) chance to extend the length of all negative effects and reduce the length of all positive effects on the target by %d turn(s).
		This can only trigger on any particular target once every 6 turns.]]):tformat(math.min(100, t.getChance(self,t)), t.getExtend(self,t))
	end,
}