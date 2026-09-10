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
	name = "Fearscape Shift",
	type = {"corruption/fearfire", 1},
	require = corrs_req_high1,
	points = 5,
	random_ego = "attack",
	vim = 32,
	cooldown = 12,
	tactical = { ATTACK = {FIRE = 1}, CLOSEIN = 2 },
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), nolock=true, friendlyfire=true, selffire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 230) end,
	getVision = function(self, t) return math.min(10, math.floor(7.5 + self:getTalentLevelRaw(t)/2)) end,
	range = function(self, t)
		return math.ceil(self:combatTalentScale(t, 3.5, 7))
	end,
	radius = function(self, t)
		return  math.ceil(self:combatTalentScale(t, 1, 4.5))
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then game.logSeen(self, "You can't move there.") return nil	end
		local _ _, x, y = self:canProject(tg, x, y)
		
		-- since we're using a precise teleport we'll look for a free grid first
		local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
		if tx and ty then
			if not self:teleportRandom(tx, ty, 0) then
				game.logSeen(self, "The spell fizzles!")
			end
		end
		
		local dam = self:spellCrit(t.getDamage(self, t))
			self:project(tg, self.x, self.y, DamageType.DEMONFIRE, dam)
			local _ _, _, _, x, y = self:canProject(tg, self.x, self.y)
			game.level.map:addEffect(self,
				x, y, 4,
				DamageType.DEMONFIRE, dam/4,
				tg.radius,
				5, nil,
				{type="dark_inferno"},
				nil, self:spellFriendlyFire()
			)
			
			game.level.map:particleEmitter(x, y, tg.radius, "fire_blast", {radius=tg.radius})
			game:playSoundNear(self, "talents/fireflash")
			local rad = t.getVision(self, t)
			self:setEffect(self.EFF_SENSE, 4, {
			range = rad,
			actor = 1,
			})
		
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Open a gateway to the Fearscape, stepping through it to a nearby location. As you step out, a burst of fire will leave with you, dealing %0.2f demonfire damage to everyone within %d spaces and leaving flames which will deal an additional %0.2f demonfire damage over 4 turns.
		Additionally, shifting through reality enhances your awareness, allowing you to see all enemies within %d spaces for the next 3 turns.
		The damage will scale with your Spellpower and the range will increase with the talent level.]]):
		tformat(damDesc(self, DamageType.FIRE, damage), self:getTalentRadius(t), damDesc(self, DamageType.FIRE, damage), t.getVision(self, t))
	end,
}

 newTalent{
	name = "Cauterize Spirit",
	type = {"corruption/fearfire", 2},
	points = 5,
	require = corrs_req_high2,
	no_energy = true, 
	cooldown = 15,
	getBurnDamage = function(self, t)
		return math.max(self:combatTalentScale(t, 0.15, 0.05), 0.05)
	end,
	getBurnDuration = function(self, t)
		return 7
	end,
	action = function(self, t)
		-- Cleanse all debuffs with status detrimental, not type other, and not crosstier
		local cleansed = self:removeEffectsFilter(self, function(eff)
			if eff.status == "detrimental" and eff.type ~= "other" and not eff.subtype["cross tier"] then
				return true
			else
				return false
			end
		end, 254) 


		if cleansed == 0 then return false end
		local burnDamage = (cleansed * t.getBurnDamage(self, t))
		self:setEffect(self.EFF_PURIFIED_BY_FIRE, t.getBurnDuration(self, t), {power = (burnDamage / t.getBurnDuration(self, t)) })
		return true
	 end,
	 info = function(self, t)
		return ([[Removes all detrimental effects but causes you to burn for %d%% of your max health per effect, over 7 turns.
		This ignores all resists, defenses, and affinities.
		This does not take a turn.]]):tformat(t.getBurnDamage(self, t)*100)
	 end,
 }

newTalent{
	name = "Infernal Breath", short_name="INFERNAL_BREATH_DOOM", image = "talents/infernal_breath.png",
	type = {"corruption/fearfire", 3},
	require = corrs_req_high3,
	points=5,
	random_ego = "attack",
	vim = 18,
	cooldown = 12,
	tactical = { AREAATTACK = { FIRE = 2 }, HEAL = 1, },
	range = 0,
	radius = function(self, t)
		return  math.ceil(self:combatTalentScale(t, 5, 9))
	end,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.DEMONFIRE, self:spellCrit(self:combatTalentStatDamage(t, "str", 30, 375)))

		game.level.map:addEffect(self,
				self.x, self.y, 4,
				DamageType.DEMONFIRE, self:spellCrit(self:combatTalentStatDamage(t, "str", 30, 75)),
				tg.radius,
				{delta_x=x-self.x, delta_y=y-self.y}, 55,
				{type="dark_inferno"},
				nil, true
		)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_fire", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breathe")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Exhale a wave of dark fire with radius %d, lasting 4 turns. Any non-demon caught in the area will take %0.2f fire damage, and flames will be left dealing a further %0.2f each turn. Demons will be healed for the same amount.
		The damage will increase with your Strength Stat, but critically hit as a spell.]]):
		tformat(radius, damDesc(self, DamageType.FIRE, self:combatTalentStatDamage(t, "str", 30, 375)), damDesc(self, DamageType.FIRE, self:combatTalentStatDamage(t, "str", 30, 75)))
	end,
}

newTalent{
	name = "Maw of Urh'rok", short_name="FEARSCAPE_AURA",-- image = "talents/fearscape_aura.png",
	type = {"corruption/fearfire", 4},
	require = corrs_req_high4,
	points = 5,
	sustain_vim = 40,
	cooldown = 20,
	mode = "sustained",
	range = 0, 
	no_npc_use = true, --Not really a good idea, AI wise
	drain_vim = 5,
	radius = function(self, t)
		return  math.ceil(self:combatTalentScale(t, 4, 8))
	end,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), cone_angle = 90 + 10 * (self.is_destroyer or 0), selffire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 35, 150) end,
	activate = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self.fearscape_pull_x = x - self.x
		self.fearscape_pull_y = y - self.y
		return {particle = self:addParticles(Particles.new("destroyer", 1)),}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	callbackOnActBase = function(self, t)
		local tt = self:isTalentActive(t.id)
		if not tt then return end
		local firedamage = t.getDamage(self, t)
		local tg = {type="cone", range=0, radius=self:getTalentRadius(t), friendlyfire=false}
		local x = self.x + self.fearscape_pull_x
		local y = self.y + self.fearscape_pull_y
		
		self:project(tg, x, y, DamageType.FIRE, firedamage)	
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end
			target:pull(self.x, self.y, 1)
		end)		
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Your body becomes a nexus for the Fearscape, causing you to drag enemies towards you in a cone with a radius of %d, dealing %0.2f fire damage every turn.
		The damage will increase with your Spellpower.]]):tformat(radius, damDesc(self, DamageType.FIRE, damage), duration)
	end,
}