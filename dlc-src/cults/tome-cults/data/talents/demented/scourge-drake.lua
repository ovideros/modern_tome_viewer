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
	name = "Tentacled Wings",
	type = {"demented/scourge-drake", 1},
	require = dementedreq1,
	points = 5,
	cooldown = 10,
	insanity = 15,
	direct_hit = true,
	requires_target = true,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 3, 8)) end,
	target = function(self, t) return {type="cone", range=0, radius=self:getTalentRange(t)} end,
	tactical = { ATTACKAREA = {weapon=1.5}, CLOSEIN = 2 },
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 1.4) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local weapondam = t.getDamage(self, t)
		local hitActors = {}
		self:project(tg, x, y, function(px, py)
			local act = game.level.map(px, py, Map.ACTOR)
			if act and not hitActors[act] and self:reactionToward(act) < 0 then
				hitActors[act] = true
				local hit = self:attackTarget(act, DamageType.BLIGHT, weapondam, true)
				if hit then act:pull(self.x, self.y, self:getTalentRange(t)) end
				self:addParticles(Particles.new("tentacle_pull", 1, {range=core.fov.distance(self.x, self.y, px, py), dir=math.deg(math.atan2(py-self.y, px-self.x)+math.pi/2)}))
			end
		end)

		if core.shader.active(4) then
			local bx, by = self:attachementSpot("back", true)
			self:addParticles(Particles.new("shader_wings", 1, {img="sickwings", life=18, x=bx, y=by, fade=-0.006, deploy_speed=14}))
		end
		
		return true
	end,
	info = function(self, t)
		return ([[You project tentacles in a cone of radius %d in front of you.
		Any foes caught inside are grappled by the tentacles and suffer %d%% weapon damage as blight, if the attack hits the creatures are also pulled towards you.]]):
		tformat(self:getTalentRange(t), damDesc(self, DamageType.BLIGHT, t.getDamage(self, t) * 100))
	end,
}

newTalent{
	name = "Decaying Grounds",
	type = {"demented/scourge-drake", 2},
	require = dementedreq2,
	points = 5,
	cooldown = 15,
	tactical = { ATTACKAREA = { BLIGHT = 2 }, DISABLE = 2 },
	range = 6,
	radius = 3,
	insanity = 15,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getDamage = function(self, t) return math.max(self:combatTalentSpellDamage(t, 15, 40), self:combatTalentMindDamage(t, 15, 40)) end,
	getDuration = function(self, t) return 5 end,
	getPower = function(self,t) return math.floor(self:combatTalentScale(t, 25, 60)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.DECAYING_GROUND, {dam=self:spellCrit(t.getDamage(self, t)), power=t.getPower(self,t) / 100},
			self:getTalentRadius(t),
			5, nil,
			MapEffect.new{zdepth=6, color_br=255, color_bg=255, color_bb=255, effect_shader="shader_images/decaying_ground.png"},
			nil, false
		)
		game:playSoundNear(self, "talents/decayed_ground")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[You blight a zone as a decaying ground for %d turns. All creatures inside take %0.2f blight damage per turn and have all their cooldowns increased by %d%% for 3 turns.
		The damage will scale with the highest of your spell or mind power.]]):
		tformat(t.getDuration(self, t), damDesc(self, DamageType.DARKNESS, damage), t.getPower(self,t))
	end,
}

newTalent{
	name = "Augment Despair",
	type = {"demented/scourge-drake", 3},
	require = dementedreq3,
	points = 5,
	insanity = -20,
	cooldown = 12,
	tactical = { ATTACK = {BLIGHT=3}, DISABLE = 2 },
	direct_hit = true,
	range = 7,
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	getDuration = function(self, t) return  math.floor(self:combatTalentScale(t, 1, 5)) end,
	getDamage = function(self, t) return math.max(self:combatTalentSpellDamage(t, 15, 120), self:combatTalentMindDamage(t, 15, 120)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		self:project(tg, x, y, function(px, py)
			local act = game.level.map(px, py, Map.ACTOR)
			if act then
				local effs = act:effectsFilter({status="detrimental"}, 50)
				local nb = #effs
				if nb > 0 then
					for _, eff_id in ipairs(effs) do
						act.tmp[eff_id].dur = act.tmp[eff_id].dur + t.getDuration(self, t)
					end
					local dam = t.getDamage(self, t)
					for i = 1, nb do
						DamageType:get(DamageType.BLIGHT).projector(self, px, py, DamageType.BLIGHT, dam)
						dam = dam * 0.75
					end
				end
			end
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[You target a single creature with all your hatred and insanity, augmenting its despair, increasing the duration of detrimental effects by %d turns and dealing %0.2f blight damage per detrimental effect (each effect deals 75%% of the previous one).
		The damage will scale with the highest of your spell or mind power.]]):
		tformat(t.getDuration(self, t), damDesc(self, DamageType.BLIGHT, t.getDamage(self, t)))
	end,
}


newTalent{
	name = "Maggot Breath",
	type = {"demented/scourge-drake", 4},
	require = dementedreq4,
	points = 5,
	cooldown = 12,
	message = _t"@Source@ breathes a wave of maggots!",
	tactical = { ATTACKAREA = { BLIGHT = 2 }, DISABLE = { slow = 2, disease = 2  }, },
	range = 0,
	insanity = -25,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t)
		local bonus = self:knowTalent(self.T_CHROMATIC_FURY) and self:combatTalentStatDamage(t, "wil", 30, 550) or 0
		return self:combatTalentStatDamage(t, "mag", 30, 550) + bonus
	end,
	getDiseaseDamage = function(self, t) return t.getDamage(self, t) * 0.75 / 10 end,
	getSlow = function(self, t) return self:combatTalentLimit(t, 0.7, 0.15, 0.5) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:spellCrit(t.getDamage(self, t))
		self:project(tg, x, y, function(px, py)
			local act = game.level.map(px, py, Map.ACTOR)
			if act then
				DamageType:get(DamageType.BLIGHT).projector(self, px, py, DamageType.BLIGHT, dam)
				if act:canBe("disease") and act:canBe("slow") then
					act:setEffect(act.EFF_CRIPPLING_DISEASE, 10, {apply_power=math.max(self:combatMindpower(), self:combatSpellpower()), src=self, dam=t.getDiseaseDamage(self, t), speed=t.getSlow(self, t)})
				end
			end
		end)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "maggot_breath", {radius=tg.radius, tx=x-self.x, ty=y-self.y})

		if core.shader.active(4) then
			local bx, by = self:attachementSpot("back", true)
			self:addParticles(Particles.new("shader_wings", 1, {img="sickwings", life=18, x=bx, y=by, fade=-0.006, deploy_speed=14}))
		end
		game:playSoundNear(self, "talents/vile_breath")
		return true
	end,
	info = function(self, t)
		return ([[You breathe a wave of dead maggots in a cone of radius %d. Any target caught in the area will take %0.2f blight damage and be infected with a crippling disease for 10 turns.
		Crippling disease slows creatures by %d%% and deals %0.2f blight damage per turn.
		The damage will increase with your Magic, and the critical chance is based on your Spell crit rate.]]):
		tformat(self:getTalentRadius(t), damDesc(self, DamageType.BLIGHT, t.getDamage(self, t)), t.getSlow(self, t) * 100, damDesc(self, DamageType.BLIGHT, t.getDiseaseDamage(self, t)))
	end,
}
