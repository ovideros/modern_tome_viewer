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
	name = "Micro Spiderbot",
	type = {"spell/terrene-technomancy",1},
	require = technomancy_req_high1, is_technomancy = true, is_steam = true,
	points = 5,
	steam = 10,
	mana = 5,
	cooldown = 5,
	is_body_of_stone_affected = true,
	tactical = { ATTACK = { PHYSICAL = 2, COLD = 2 }, },
	requires_target = true,
	range = 10,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), selffire=self:spellFriendlyFire(), talent=t} end,
	getNbBots = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3)) end,
	getMaxBots = function(self, t) return math.ceil(self:combatTalentScale(t, 2, 10)) end,
	getDur = function(self, t) return math.ceil(self:combatTalentScale(t, 8, 15)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 35, 290) / 10 end,
	on_pre_use = function(self, t, silent) if not self:knowTalent(self.T_TINKER_ARCANE_DYNAMO) then if not silent then game.logPlayer(self, "You need an arcane dynamo to cast this spell.") end return false end return true end,
	on_learn = function(self, t)
		self.micro_spiderbots_store = self.micro_spiderbots_store or {bots={}}
	end,
	callbackOnCloned = function(self, t)
		--Just like a newborn!
		self.micro_spiderbots_store = {bots={}}
	end,
	callbackOnChangeLevel = function(self, t, what)
		if what ~= "leave" then return end
		t.removeBots(self, t)
	end,
	callbackOnActBase = function(self, t)
		t.updateBotsSystem(self, t, -1)
	end,
	removedBot = function(self, t, bot, do_digs)
		game.level.map:removeParticleEmitter(bot.particle)
		if do_digs and self:isTalentActive(self.T_CRYOGENIC_DIGS) then
			self:callTalent(self.T_CRYOGENIC_DIGS, "doDig", bot.x, bot.y)
		end
	end,
	removeBot = function(self, t, bot, do_digs)
		local p = self.micro_spiderbots_store
		if not p then return end
		for i, tbot in ipairs(p.bots) do
			if tbot == bot then
				t.removedBot(self, t, bot, do_digs)
				table.remove(p.bots, i)				
			end
		end
	end,
	removeBots = function(self, t)
		local p = self.micro_spiderbots_store
		if not p then return end
		for _, bot in ipairs(p.bots) do
			-- Dont do the cryogenic digs code
			game.level.map:removeParticleEmitter(bot.particle)
		end
		p.bots = {}
	end,
	moveBot = function(self, t, bot, x, y)
		game.level.map:particleEmitter(bot.x, bot.y, 1, "spiderbot_move", {tx=x-bot.x, ty=y-bot.y}, nil, 13)

		bot.particle.x, bot.particle.y = x, y
		bot.x, bot.y = x, y
	end,
	hasBot = function(self, t, p, x, y)
		for _, bot in ipairs(p.bots) do if bot.x == x and bot.y == y then return true end end
	end,
	countBots = function(self, t, p, x, y)
		local nb = 0
		for _, bot in ipairs(p.bots) do if bot.x == x and bot.y == y then nb = nb + 1 end end
		return nb
	end,
	doDamage = function(self, t, p)
		local dam = t.getDamage(self, t)
		local tgts = {}
		for _, bot in ipairs(p.bots) do
			local target = game.level.map(bot.x, bot.y, Map.ACTOR)
			-- No target, lets find one!
			local nb_bots = t.countBots(self, t, p, bot.x, bot.y)
			if not target or self:reactionToward(target) >= 0 or nb_bots > 1 then
				local tgts = self:projectCollect({type="ball", radius=10, x=bot.x, y=bot.y}, bot.x, bot.y, Map.ACTOR, function(target) return self:reactionToward(target) < 0 end)
				local tx, ty = nil, nil

				-- First look for the one we had before, only if we are alone here
				if nb_bots == 1 then for target, _ in pairs(tgts) do
					if target.uid == bot.last_uid_target then
						tx, ty = target.x, target.y
						break
					end
				end end

				-- Ok find the closest, in the direction of the player if possible
				if not tx then
					local range = self:getTalentRange(t)
					local possibles = {}
					for target, d in pairs(tgts) do
						local pdist = core.fov.distance(self.x, self.y, target.x, target.y)
						if pdist < range then
							-- Add in pdist / range which is always < 1 to automaticalyl sort the equidistant ones to finsd the ones closest to the player side
							possibles[#possibles+1] = {target=target, dist=d.dist + pdist / range + (t.hasBot(self, t, p, target.x, target.y) and 20 or 0)}
						end
					end
					if #possibles > 0 then
						table.sort(possibles, "dist")
						tx, ty = possibles[1].target.x, possibles[1].target.y
					end
				end

				if tx then t.moveBot(self, t, bot, tx, ty) end
			end

			-- And now?
			local target = game.level.map(bot.x, bot.y, Map.ACTOR)
			if target and self:reactionToward(target) < 0 then
				tgts[target] = tgts[target] or {cnt=0, bots={}}
				tgts[target].cnt = tgts[target].cnt + 1
				tgts[target].bots[bot] = true
			end
		end

		for target, data in pairs(tgts) do
			if target.x and self:hasLOS(target.x, target.y) then
				DamageType:get(DamageType.TERRENE).projector(self, target.x, target.y, DamageType.TERRENE, dam * data.cnt ^ 0.7)
				if rng.percent(25) and target:canBe("pin") and not target:attr("fly") and not target:attr("levitation") then
					target:setEffect(target.EFF_FROZEN_FEET, 5, {apply_power=self:combatSpellpower()})
				end
				for bot, _ in pairs(data.bots) do bot.last_uid_target = target.uid end
			end
		end
	end,
	updateBotsSystem = function(self, t, turns)
		local p = self.micro_spiderbots_store
		if not p then return end

		-- Delete by durations
		for i, bot in ripairs(p.bots) do
			bot.dur = bot.dur + turns
			if bot.dur <= 0 then
				table.remove(p.bots, i)
				t.removedBot(self, t, bot, true)
			end
		end

		if turns ~= 0 then t.doDamage(self, t, p) end
	end,
	placeBot = function(self, t, x, y)
		local p = self.micro_spiderbots_store
		if not p then return end

		local ps = game.level.map:particleEmitter(x, y, 1, "spiderbot", {}, nil, 13)
		table.insert(p.bots, {x=x, y=y, dur=t.getDur(self, t), particle=ps})

		while #p.bots > t.getMaxBots(self, t) do
			local bot = table.remove(p.bots, 1)
			t.removedBot(self, t, bot, true)
		end

		t.updateBotsSystem(self, t, 0)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)

		for i = 1, t.getNbBots(self, t) do
			t.placeBot(self, t, x, y)
		end

		game:playSoundNear(self, "talents/spiderbot")

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local range = self:getTalentRange(t)
		return ([[You build %d micro spiderbot(s) from the earthly elements around you. Spiderbots are powered by an arcane cryogenic power unit directly linked to your own power.
		Spiderbots will deal %0.2f terrene damage (physical and cold) each turn to their targets. The deep cold of the attack has 25%% chance to freeze the feet of the target, pinning it to the ground for 5 turns.
		If a target dies, the spiderbot will jump onto a new target in range %d around you.
		If there are multiple spiderbots on a single target and more free targets are in range they will dispatch on as many as possible.
		If there are multiple spiderbots on a single target they attack as one, stacking their damage (with disminishing returns) and trying to freeze once.
		You can maintain up to %d spiderbots at once and each can last up to %d turns, but spiderbots need to be in sight to be able to act.
		The cooldown of this spell is affected by Body of Stone.
		The damage will increase with your Spellpower.

		You have currently %d spiderbot(s) up.]]):tformat(t.getNbBots(self, t), damDesc(self, DamageType.TERRENE, damage), range, t.getMaxBots(self, t), t.getDur(self, t), self.micro_spiderbots_store and #self.micro_spiderbots_store.bots or 0)
	end,
}

newTalent{
	name = "Cryogenic Digs",
	type = {"spell/terrene-technomancy",2},
	require = technomancy_req_high2, is_technomancy = true, is_steam = true,
	mode = "sustained",
	points = 5,
	sustain_mana = 40,
	cooldown = 30,
	tactical = { BUFF=2 },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 60) end,
	getDur = function(self, t) return math.floor(self:combatTalentScale(t, 3, 8)) end,
	doDig = function(self, t, x, y)
		if rng.percent(50) then
			game.level.map:addEffect(self,
				x, y, t.getDur(self, t),
				DamageType.PHYSICAL_STUN, self:spellCrit(t.getDamage(self, t)),
				1,
				5, nil,
				{type="quake"},
				nil, false
			)
		else
			game.level.map:addEffect(self,
				x, y, t.getDur(self, t),
				DamageType.GLACIAL_VAPOUR, self:spellCrit(t.getDamage(self, t)),
				1,
				5, nil,
				{type="ice_vapour"},
				nil, false
			)
		end
	end,
	on_pre_use = function(self, t, silent) if not self:knowTalent(self.T_TINKER_ARCANE_DYNAMO) then if not silent then game.logPlayer(self, "You need an arcane dynamo to cast this spell.") end return false end return true end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spiderbot_sustain")
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Each time a spiderbot expires it digs around, producing either a Glacial Vapour (%0.2f cold damage and doing 30%% more damage to wet targets) or Earthquake (%0.2f physical damage and 25%% chances to stun for 2 turns) of radius 1 that last for %d turns.
		Those special kinds of Glacial Vapour and Earthquake do not affect the caster.
		The damage will increase with your Spellpower.]]):tformat(damDesc(self, DamageType.COLD, damage), damDesc(self, DamageType.PHYSICAL, damage), t.getDur(self, t))
	end,
}

newTalent{
	name = "Ramming Bot",
	type = {"spell/terrene-technomancy",3},
	require = technomancy_req_high3, is_technomancy = true, is_steam = true,
	points = 5,
	steam = 35,
	mana = 15,
	cooldown = 10,
	is_body_of_stone_affected = true,
	tactical = { ATTACKAREA = { PHYSICAL = 2, COLD = 2 }, DISABLE = {stun = 2} },
	range = 10,
	radius = 3,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, selffire=self:spellFriendlyFire()} end,
	getDur = function(self, t) return math.ceil(self:combatTalentLimit(t, 16, 4, 12)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 380) end,
	on_pre_use = function(self, t, silent) if not self.micro_spiderbots_store or #self.micro_spiderbots_store.bots == 0 or not self:knowTalent(self.T_TINKER_ARCANE_DYNAMO) then if not silent then game.logPlayer(self, "You need an arcane dynamo and an active spiderbot to cast this spell.") end return false end return true end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTargetLimited(tg)
		if not x then return nil end

		local p = self.micro_spiderbots_store
		local sbots = table.clone(p.bots, false)
		table.sort(sbots, "dur")
		local bot = sbots[1]
		if not bot then return end

		self:callTalent(self.T_MICRO_SPIDERBOT, "moveBot", bot, x, y)
		self:callTalent(self.T_MICRO_SPIDERBOT, "removeBot", bot, true)

		local dam = self:spellCrit(t.getDamage(self, t))
		local dur = t.getDur(self, t)
		self:projectApply(tg, x, y, Map.ACTOR, function(target, px, py)
			DamageType:get(DamageType.TERRENE).projector(self, px, py, DamageType.TERRENE, dam)
			target:setEffect(target.EFF_WET, dur, {apply_power=self:combatSpellpower()})
			if target:canBe("stun") then
				target:setEffect(target.EFF_FROZEN, math.floor(dur / 2), {hp = 100 + dam, apply_power=self:combatSpellpower()})
			end
		end)

		game.level.map:particleEmitter(x, y, tg.radius, "ramming_bot", {radius=tg.radius})

		game:playSoundNear(self, "talents/spiderbot_ram")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Command a random spiderbot to jump onto your target at ramming speed. The impact destroys the bot (possibly triggering Cryogenic Digs).
		This creates a radius %d explosion dealing %0.2f terrene damage to all creatures while also freezing them for %d turns and rendering them wet for %d turns.
		The cooldown of this spell is affected by Body of Stone.
		The damage will increase with your Spellpower.]]):tformat(radius, damDesc(self, DamageType.TERRENE, damage), t.getDur(self, t) / 2, t.getDur(self, t))
	end,
}

newTalent{
	name = "Spiderbot Shield",
	type = {"spell/terrene-technomancy",4},
	require = technomancy_req_high4, is_technomancy = true, is_steam = true,
	points = 5,
	steam = 80,
	mana = 30,
	cooldown = 20,
	is_body_of_stone_affected = true,
	tactical = { DEFEND = 3 },
	getNbBots = function(self, t) return math.floor(self:combatTalentScale(t, 3, 8)) end,
	getDur = function(self, t) return math.ceil(self:combatTalentScale(t, 10, 22)) end,
	getLife = function(self, t) return math.ceil(self:combatTalentScale(t, 50, 100)) end,
	on_pre_use = function(self, t, silent) if not self.micro_spiderbots_store or #self.micro_spiderbots_store.bots == 0 or not self:knowTalent(self.T_TINKER_ARCANE_DYNAMO) then if not silent then game.logPlayer(self, "You need an arcane dynamo and an active spiderbot to cast this spell.") end return false end return true end,
	action = function(self, t)
		local p = self.micro_spiderbots_store
		local sbots = table.clone(p.bots, false)
		table.sort(sbots, "dur")

		local nb = t.getNbBots(self, t)
		local nb_got = 0
		while nb > 0 and #sbots > 0 do
			local bot = table.remove(sbots, 1)

			self:callTalent(self.T_MICRO_SPIDERBOT, "moveBot", bot, self.x, self.y)
			self:callTalent(self.T_MICRO_SPIDERBOT, "removeBot", bot, false)
			nb_got = nb_got + 1
			nb = nb - 1
		end
		if nb_got == 0 then return end

		self:setEffect(self.EFF_SPIDERBOT_SHIELD, t.getDur(self, t), {nb=nb_got, life=t.getLife(self, t)})

		game:playSoundNear(self, "talents/spiderbot_shield")
		return true
	end,
	info = function(self, t)
		return ([[You call back up to %d spiderbots to you to create protective barrier for %d turns.
		Spiderbots have %d life and they take damage in order, always fully absorbing the blow that destroyed them.
		If Cryogenic Digs is active when a spiderbot is destroyed it jumps to the attacker and triggers the dig there.
		The cooldown of this spell is affected by Body of Stone.
		]])
		:tformat(t.getNbBots(self, t), t.getDur(self, t), t.getLife(self, t))
	end,
}
