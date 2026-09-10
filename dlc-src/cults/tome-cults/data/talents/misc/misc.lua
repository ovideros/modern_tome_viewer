-- ToME - Tales of Maj'Eyal:
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

-- Alter alchemist's golems
local prev_make_golem = Talents.main_env.makeAlchemistGolem
Talents.main_env.makeAlchemistGolem = function(self)
	local g = prev_make_golem(self)

	if self.alchemist_golem_is_glass_golem then
		g.name = _t"glass golem"
		g.moddable_tile = "glass_golem"
		g.moddable_tile_base = "base_01.png"
		g.golem_appearance_set = true
		g:learnTalentType("golem/glass", true)
	end

	return g
end

newTalent{
	name = "Self-destruction", short_name = "WTW_DESTRUCT", image = "talents/golem_destruct.png",
	type = {"demented/other", 1},
	points = 1,
	range = 0,
	radius = 4,
	no_unlearn_last = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	no_npc_use = true,
	on_pre_use = function(self, t)
		return self.summoner and self.summoner.dead
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.BLIGHT, 50 + 10 * self.level)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_blight", {radius=tg.radius})
		game:playSoundNear(self, "talents/fireflash")
		self:die(self)
		return true
	end,
	info = function(self, t)
		local rad = self:getTalentRadius(t)
		return ([[Self destruct in a glorious explosion of gore dealing %0.2f blight damage to all enemies in %d radius.  Your summoner must be dead to use this talent.]])
			:tformat(damDesc(self, DamageType.BLIGHT, 50 + 10 * self.level), rad)
	end,
}

-- Demented & Drem, teleprot to krushkkur
newTalent{
	short_name = "TELEPORT_KROSHKKUR",
	name = "Teleport: Kroshkkur",
	type = {"base/class", 1},
	cooldown = 400,
	no_npc_use = true,
	no_unlearn_last = true,
	no_silence=true, is_spell=true,
	action = function(self, t)
		if game.state.cults_kroshkkur_destroyed then
			game.logPlayer(self, "#CRIMSON#Kroshkkur is destroyed, there is nothing to teleport to.")
			return
		end

		if not self:canBe("worldport") or self:attr("never_move") then
			game.logPlayer(self, "The spell fizzles...")
			return
		end

		local seen = false
		-- Check for visible monsters, only see LOS actors, so telepathy wont prevent it
		core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, 20, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
			local actor = game.level.map(x, y, game.level.map.ACTOR)
			if actor and actor ~= self then
				if actor.summoner and actor.summoner == self then
					seen = false
				else
					seen = true
				end
			end
		end, nil)
		if seen then
			game.log("There are creatures that could be watching you; you cannot take the risk.")
			return
		end

		self:setEffect(self.EFF_TELEPORT_KROSHKKUR, 40, {})
		return true
	end,
	info = _t[[Allows to teleport to Kroshkkur.
	You have studied the forbidden secrets there and have been granted a special portal spell to teleport back.
	This spell must be kept secret; it should never be used within view of uninitiated witnesses.
	The spell takes time (40 turns) to activate, and you must be out of sight of any other creature when you cast it and when the teleportation takes effect.]]
}

-- Modified Call of Amakthel to be more useful for the Drem racial
newTalent{
	name = "Call of Amakthel",
	short_name = "DREM_CALL_OF_AMAKTHEL",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 2,
	tactical = { DISABLE = 2 },
	range = 0,
	radius = function(self, t)
		return 10
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tgts = {}
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			if self:reactionToward(target) < 0 and not tgts[target] and not target:attr("never_move") then
				tgts[target] = true
				local ox, oy = target.x, target.y
				target:pull(self.x, self.y, 2)
				if target.x ~= ox or target.y ~= oy then game.logSeen(target, "%s is pulled in!", target:getName():capitalize()) end
			end
		end)
		return true
	end,
	info = function(self, t)
		return (_t[[Pull all foes within radius 10 2 grids towards you.]])
	end,
}

newTalent{
	name = "Crumble",
	type = {"spell/other",1},
	points = 1,
	mana = 15,
	cooldown = 10,
	tactical = { ATTACK = 3 },
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		local tg = {type="ball", radius=3, range=8, talent=t, friendlyfire=false, selffire=false}
		return tg
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 300) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		self:project(tg, x, y, DamageType.DIG, 1)
		self:project(tg, x, y, DamageType.DARKNESS, self:spellCrit(t.getDamage(self, t)), nil)
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "earth_beam", {tx=x-self.x, ty=y-self.y})  -- fix display
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Fire a blast of darkness at an enemy dealing %0.2f damage and destroying any walls in radius 3 around them.
		The damage will increase with your Spellpower.]]):
		tformat(damDesc(self, DamageType.DARKNESS, damage))
	end,
}

newTalent{
	name = "Blightlash",
	type = {"demented/other", 1},
	points = 1,
	cooldown = 6,
	range = 10,
	tactical = { ATTACK = {weapon = 2}},
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:callTalent(self.T_MUTATED_HAND, "canTentacleCombat") then if not silent then game.logPlayer(self, "You require an empty offhand to use your tentacle hand.") end return false end return true end,
	getDamageTentacle = function(self, t) return self:combatTalentWeaponDamage(t, 1, 2) end,
	action = function(self, t)
		local tentacle = self:callTalent(self.T_MUTATED_HAND, "getTentacleCombat")
		if not tentacle then
			game.logPlayer(self, "You require a weapon and an empty offhand!")
			return nil
		end

		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = t.getDamageTentacle(self, t)

		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end
			self:attackTarget(target, engine.DamageType.BLIGHT, dam, true)
		end)
		game.level.map:particleEmitter(x, y, tg.radius, "tentacle_field", {img="tentacle_black", radius=0})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Lash an enemy within range 10 with your tentacle, dealing %d%% blight damage.]]):
		tformat(t.getDamageTentacle(self, t) * 100)
	end,
}

newTalent{
	name = "Twisted Evolution",
	type = {"spell/other", 1},
	points = 1,
	cooldown = 15,
	mana = 30,
	tactical = { BUFF = 3 },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 250) end,
	getAmount = function(self, t) return 5 end,
	getEvolveSpeed = function(self, t) return self:combatTalentSpellDamage(t, 0.1, 0.5) end,
	getEvolveStat = function(self, t) return self:combatTalentSpellDamage(t, 1, 25) end,
	getEvolveDamage = function(self, t) return self:combatTalentSpellDamage(t, 1, 20) end,
	action = function(self, t)
		local tg = {type="ball", range=0, radius=10, selffire=false, talent=t}

		local x, y = self.x, self.y
		local amount = t.getAmount(self, t)
		local tgts = {}
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target or target:reactionToward(self) < 0 then return end  -- We only care about whether something likes uss
			tgts[#tgts+1] = target
		end)
		for i = 1, amount do
			if #tgts <= 0 then break end
			local target = rng.tableRemove(tgts)

			local evolve = rng.range(1, 3)
			if evolve == 1 then target:setEffect(target.EFF_TWISTED_SPEED, 5, {speed = t.getEvolveSpeed(self, t)})
			elseif evolve == 2 then target:setEffect(target.EFF_TWISTED_FORM, 5, {stat = t.getEvolveStat(self, t)})
			else target:setEffect(target.EFF_TWISTED_POWER, 5, {dam = t.getEvolveDamage(self, t)})
			end
		end
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "circle", {oversize=1, a=180, appear=8, limit_life=8, speed=-3, img="blood_circle", radius=tg.radius})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Evolve %d allies within radius 10 in random ways for 5 turns.
		#ORCHID#Speed:#LAST# Increases global speed by %d%%.
		#ORCHID#Form:#LAST# Increases all stats by %d.
		#ORCHID#Power:#LAST# Increases all damage by %d%%.]]):tformat(t.getAmount(self, t), t.getEvolveSpeed(self, t) * 100, t.getEvolveStat(self, t), t.getEvolveDamage(self, t))
	end,
}

newTalentType{ type="golem/glass", name = _t("glass", "talent type"), description = _t"Glass Golem basic capacity." }
newTalent{
	name = "Glass Splinters",
	type = {"golem/glass", 1},
	require = Talents.main_env.spells_req_high1,
	points = 5,
	cooldown = 9,
	tactical = { ANNOY = 3, ATTACK = {arcane=2} },
	is_melee = true,
	requires_target = true,
	mana = 12,	
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDam = function(self, t) return self:combatTalentWeaponDamage(t, 0.7, 2) end,
	getMovePenalty = function(self, t) return self:combatTalentScale(t, 7, 30) end,
	action = function(self, t)
		local weapon = self:hasWeaponType()
		if not weapon then return nil end

		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local oldlife = target.life
		local speed, hit = self:attackTargetWith(target, weapon.combat, DamageType.ARCANE, t.getDam(self, t))
		local dam = math.max(0, oldlife - target.life)

		-- Try to cut !
		if hit then
			if target:canBe("cut") then
				target:setEffect(target.EFF_GLASS_SPLINTERS, 6, {apply_power=self:combatPhysicalpower(), bleed=dam * 0.08, move=dam * t.getMovePenalty(self, t) / 100, fail=self:getTalentLevel(t) >= 5 and 15 or 0})
			else
				game.logSeen(target, "%s resists the splinters!", target:getName():capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Smash your target with a splintering glass attack doing %d%% arcane weapon damage.
		If this attack hits the target will have glass splinters for 6 turns.
		Each turn the target will bleed for 8%% of the attack damage. The splinters are very painful and if the target moves it will instantly take %d%% of the attack damage.
		At level 5 the target suffers so much it has 15%% chances to fail using talents.]])
		:tformat(t.getDam(self, t) * 100, t.getMovePenalty(self, t))
	end,
}

newTalent{
	name = "Throw Pebble", short_name = "THROW_PEEBLE",
	type = {"technique/other", },
	points = 5,
	cooldown = 4,
	range = 7,
	radius = 0,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDam = function(self, t) return self:combatScale(self:getStr() * self:getTalentLevel(t), 12, 0, 262, 500) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local target = game.level.map(x, y, engine.Map.ACTOR) or self.ai_target.actor or {name=_t"something"}
		self:logCombat(target, "#Source# expertly hurls a pebble at #target#!")
		self:project(tg, x, y, DamageType.PHYSICAL, self:mindCrit(t.getDam(self, t)), {type="archery"})
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		return ([[Throw a pebble at your target, dealing %0.2f physical damage.
		The damage will increase with your Strength.]]):tformat(damDesc(self, DamageType.PHYSICAL, t.getDam(self, t)))
	end,
}

newTalent{
	name = "Netherforce",
	type = {"demented/other", 1},
	points = 1,
	cooldown = 5,
	insanity = 8,
	range = 5,
	tactical = { ATTACK = {DARKNESS = 1, TEMPORAL = 1}, ESCAPE = 3 },
	target = function(self, t) return {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="netherblast"}} end,
	requires_target = true,
	getDamage = function(self,t) return self:combatTalentSpellDamage(t, 20, 250) end,
	getBacklash = function(self,t) return t.getDamage(self, t)*0.2 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTargetLimited(tg)
		if not x or not y or not target then return nil end

		local dam = self:spellCrit(t.getDamage(self,t))		
		self:project(tg, x, y, DamageType.VOID, dam, {type="voidblast"})
		if not target:attr("dead") and target:canBe("knockback") then
			target:knockback(self.x, self.y, 8)
		end
		game:playSoundNear(self, "talents/netherlance")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self,t)/2
		local backlash = t.getBacklash(self,t)
		return ([[Smash the target with the force of the void dealing %0.2f darkness and %0.2f temporal damage to the target and knocking them back 8 spaces.
		The power of this spell inflicts entropic backlash on you, causing you to take %d damage over 8 turns. This damage counts as entropy for the purpose of Entropic Gift.
		The damage will increase with your Spellpower.]]):
		tformat(damDesc(self, DamageType.DARKNESS, dam), damDesc(self, DamageType.TEMPORAL, dam), backlash)
	end,
}
