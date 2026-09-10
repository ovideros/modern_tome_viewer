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
	name = "Mutated Hereragegand",
	type = {"demented/writhing-body", 1},
	require = dementedreq1,
	no_unlearn_last = true,
	points = 5,
	require = { stat = { str=function(level) return 12 + level * 6 end }, },
	mode = "passive",
	getDamage = function(self, t) return 30 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 2 end,
	canTentacleCombat = function(self, t)
		local offhand = self:getInven(self.INVEN_OFFHAND)
		if not offhand or offhand[1] then return false end -- No lefthand or lefthand used, nope
		if self:hasTwoHandedWeapon() then return false end
		-- No check for disarmed, you cant disarm a tentacle!
		return true
	end,
	getTentacleCombat = function(self, t, force)
		if not t.canTentacleCombat(self, t) and not force then return nil end
		return {
			talented = "tentacles",
			dam = self:combatTalentScale(t, 10, 40),
			apr = self:combatTalentScale(t, 0, 10),
			dammod = {mag=1},
			damrange = 1.4,
			physcrit = self:combatTalentLimit(t, 25, 2, 12),
			physspeed = 1,
			--DGDGDGDG
			sound = {"actions/melee", pitch=0.6, vol=1.2}, sound_miss = {"actions/melee", pitch=0.6, vol=1.2},
		}
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		local allow_tcombat = t.canTentacleCombat(self, t)
		local tcombat = {combat=t.getTentacleCombat(self, t, true)}
		local tcombatdesc = Object:descCombat(self, tcombat, {}, "combat")
		return ([[
		Also increases Physical Power by %d, and increases weapon damage by %d%% for your tentacles attacks.

		Your tentacle hand currently has those stats%s:
		%s]]):
		tformat(damage, 100*inc, allow_tcombat and "" or _t", #CRIMSON# but is currently disabled due to non-empty offhand#WHITE#", tostring(tcombatdesc))
	end,
}

newTalent{
	name = "Lash Outrthrthrth",
	type = {"demented/writhing-body", 2},
	require = dementedreq2,
	points = 5,
	insanity = 15,
	cooldown = 9,
	tactical = { ATTACKAREA = {weapon=2} },
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:callTalent(self.T_MUTATED_HAND, "canTentacleCombat") then if not silent then game.logPlayer(self, "You require an empty offhand to use your tentacle hand.") end return false end return true end,
	radius = 3,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.4, 2.1) end,
	getDamageTentacle = function(self, t) return self:combatTalentWeaponDamage(t, 1.2, 1.9) end,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)} end,
	action = function(self, t)
		local weapon = self:hasWeaponType(nil)
		local tentacle = self:callTalent(self.T_MUTATED_HAND, "getTentacleCombat")
		if not weapon or not tentacle then
			game.logPlayer(self, "You require a weapon and an empty offhand!")
			return nil
		end

		self.__tentacle_hand_recurse = true
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				self:attackTargetWith(target, tentacle, nil, t.getDamageTentacle(self, t))
			end
		end)
		tg.radius = 1
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				self:attackTargetWith(target, weapon.combat, nil, t.getDamage(self, t))
			end
		end)
		self.__tentacle_hand_recurse = nil

		-- game.level.map:particleEmitter(self.x, self.y, 3, "tentacle_field", {radius=3})
		self:addParticles(Particles.new("meleestorm", 1, {}))
		local hx, hy = self:attachementSpot(self._flipx and "hand1" or "hand2", true)
		for i = 0, 360, 35 do
			local ps = Particles.new("tentacle_lash", 1, {dir=i, dist=3})
			ps.dx = hx ps.dy = hy self:addParticles(ps)
		end

		return true
	end,
	info = function(self, t)
		return ([[Spin around, extending your weapon and damaging all targets around you for %d%% weapon damage while your tentacle hand extends and hits all targets in radius 3 for %d%% tentacle damage.
		]]):tformat(100 * t.getDamage(self, t), 100 * t.getDamageTentacle(self, t))
	end,
}

newTalent{
	name = "Piercing Tentacle",
	type = {"demented/writhing-body", 3},
	require = dementedreq3,
	points = 5,
	insanity = 12,
	cooldown = 11,
	range = function(self, t) return math.floor(self:combatTalentLimit(t, 7, 3, 6)) end,
	tactical = { ATTACKAREA = {weapon=2} },
	direct_hit = true,
	requires_target = true,
	getDiseasePower = function(self, t) return self:combatTalentSpellDamage(t, 5, 28) end,
	getDamageDisease = function(self, t) return 5 + self:combatTalentSpellDamage(t, 5, 30) end,
	getDamageTentacle = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.7) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 10)) end,
	target = function(self, t) return {type="beam", range=self:getTalentRange(t)} end,
	on_pre_use = function(self, t, silent) if not self:callTalent(self.T_MUTATED_HAND, "canTentacleCombat") then if not silent then game.logPlayer(self, "You require an empty offhand to use your tentacle hand.") end return false end return true end,
	action = function(self, t)
		local tentacle = self:callTalent(self.T_MUTATED_HAND, "getTentacleCombat")
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local diseases = {{self.EFF_WEAKNESS_DISEASE, "str"}, {self.EFF_ROTTING_DISEASE, "con"}, {self.EFF_DECREPITUDE_DISEASE, "dex"}}
		self:attr("combat_apr", 10000)
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end
			local disease = rng.table(diseases)
			local speed, hit = self:attackTargetWith(target, tentacle, nil, t.getDamageTentacle(self, t))
			if hit and target:canBe("disease") then
				target:setEffect(disease[1], 6, {src=self, dam=self:spellCrit(t.getDamageDisease(self, t)), [disease[2]]=t.getDiseasePower(self, t), apply_power=self:combatSpellpower()})
			end			
		end)
		self:attr("combat_apr", -10000)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "ooze_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/slime")

		return true
	end,
	info = function(self, t)
		return ([[You quickly extend your tentacle hand up to range %d, impaling all creatures in the way.
		Impaled creatures take %d%% tentacle damage and get sick, gaining a random disease for %d turns that deals %0.2f blight damage per turn and reduces strength, dexterity or constitution by %d.]]):
		tformat(
			self:getTalentRange(self, t), t.getDamageTentacle(self, t) * 100,
			t.getDuration(self, t), damDesc(self, DamageType.BLIGHT, t.getDamageDisease(self, t)), t.getDiseasePower(self, t)
			)
	end,
}

newTalent{
	name = "Tentaclesrsthrhrhrh Ground",
	type = {"demented/writhing-body", 4},
	require = dementedreq4,
	points = 5,
	insanity = 20,
	cooldown = 13,
	range = 8,
	radius = 2,
	tactical = { ATTACK = {BLIGHT = 2} },
	requires_target = true,
	healloss = function(self,t) return self:combatTalentLimit(t, 150, 44, 80) end, -- Limit < 150%
	disfact = function(self,t) return self:combatTalentLimit(t, 100, 36, 60) end, -- Limit < 100%
	-- Desease spreading handled in mod.data.damage_types.lua for BLIGHT
	spreadFactor = function(self, t) return self:combatTalentLimit(t, 0.05, 0.35, 0.17) end, -- Based on previous formula: 256 damage gave 100% chance (1500 hps assumed)
	
	do_spread = function(self, t, carrier, dam)
		if not dam or type(dam) ~= "number" then return end
		if not rng.percent(100*dam/(t.spreadFactor(self, t)*carrier.max_life)) then return end
		game.logSeen(self, "The diseases of %s spread!", self:getName())
		-- List all diseases
		local diseases = {}
		for eff_id, p in pairs(carrier.tmp) do
			local e = carrier.tempeffect_def[eff_id]
			if e.subtype.disease then
				diseases[#diseases+1] = {id=eff_id, params=p}
			end
		end

		if #diseases == 0 then return end
		self:project({type="ball", radius=self:getTalentRadius(t)}, carrier.x, carrier.y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target or target == carrier or target == self then return end

			local disease = rng.table(diseases)
			local params = table.clone(disease.params, true)
			params.src = self
			if target:canBe("disease") then
				target:setEffect(disease.id, 6, params)
			else
				game.logSeen(target, "%s resists the disease!", target:getName():capitalize())
			end
			game.level.map:particleEmitter(px, py, 1, "slime")
		end)
	end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		-- Try to rot !
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target or (self:reactionToward(target) >= 0) then return end
			target:setEffect(self.EFF_EPIDEMIC, 6, {src=self, dam=self:spellCrit(self:combatTalentSpellDamage(t, 15, 70)), heal_factor=t.healloss(self,t), resist=t.disfact(self,t), apply_power=self:combatSpellpower()})
			game.level.map:particleEmitter(px, py, 1, "circle", {oversize=0.7, a=200, limit_life=8, appear=8, speed=-2, img="disease_circle", radius=0})
		end)
		game:playSoundNear(self, "talents/slime")

		return true
	end,
	info = function(self, t)
		return ([[Infects the target with a very contagious disease, doing %0.2f damage per turn for 6 turns.
		If any blight damage from non-diseases hits the target, the epidemic may activate and spread a random disease to nearby targets within a radius 2 ball.
		The chance to spread increases with the blight damage dealt and is 100%% if it is at least %d%% of the target's maximum life.
		Creatures suffering from that disease will also suffer healing reduction (%d%%) and diseases immunity reduction (%d%%).
		Epidemic is an extremely potent disease; as such, it fully ignores the target's diseases immunity.
		The damage will increase with your Spellpower, and the spread chance increases with the amount of blight damage dealt.]]):
		tformat(damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 15, 70)), t.spreadFactor(self, t)*100 ,t.healloss(self,t), t.disfact(self,t))
	end,
}
