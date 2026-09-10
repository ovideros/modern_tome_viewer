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
	name = "Dark Whispers",
	type = {"demented/madness", 1},
	require = dementedreq1,
	points = 5,
	insanity = 8,
	cooldown = 3,
	tactical = { ATTACKAREA = {DARKNESS = 2}, DISABLE = 1  },
	range = 10,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 35) end,
	getPowerLoss = function(self, t) return self:combatTalentSpellDamage(t, 1, 20) end,
	radius = function(self, t) return 3 end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), can_autoaccept=true, nowarning=true, friendlyfire=false, selffire=false, talent=t}
	end,
	requires_target = true,
	direct_hit = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		
		local damage = self:spellCrit(t.getDamage(self, t))
		local stat = t.getPowerLoss(self,t)
		
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_DARK_WHISPERS, 5, {src=self, dam=damage, power=stat, maxpower=stat*3, hv=1})
--			game.level.map:particleEmitter(px, py, 1, "circle", {oversize=0.7, a=200, limit_life=8, appear=8, speed=-2, img="disease_circle", radius=0})
		end)

		game.level.map:particleEmitter(x, y, tg.radius, "generic_sploom", {rm=160, rM=180, gm=50, gM=50, bm=200, bM=220, am=35, aM=90, radius=tg.radius, basenb=60})
		game:playSoundNear(self, "talents/tidalwave")

		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self,t)
		local stat = t.getPowerLoss(self,t)
		local rad = self:getTalentRadius(t)
		return ([[Terrible visions and maddening voices fill the minds of enemies within a radius %d area, inflicting %0.2f darkness damage each turn for 5 turns. In addition, this distraction will reduce physical, spell and mindpower of those affected by %d.
The power loss caused by this spell can stack, to a maximum of %d powers.
		The effect will increase with your Spellpower.]]):
		tformat(rad, damDesc(self, DamageType.DARKNESS, dam), stat, stat*3)
	end,
}

newTalent{
	name = "Hideous Visions",
	type = {"demented/madness", 2},
	require = dementedreq2,
	points = 5,
	mode = "passive",
	getChance = function(self, t) return 10 end,
	getDuration = function(self, t) return 3 end,	
	getDamageReduction = function(self, t) return self:combatTalentLimit(t, 40, 15, 35) end,
	hideous_vision = function(self, t, target)
		if not target.dead then
			local x, y = util.findFreeGrid(target.x, target.y, 1, true, {[Map.ACTOR]=true})
			if not x then
				return
			end
			
			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				name = _t"hallucination",
				display = "h", color=colors.DARK_GREY, image="npc/horror_eldritch_nightmare_horror.png",
				blood_color = colors.BLUE,
				type = "horror", subtype = "eldritch",
				rank = 2,
				size_category = 2,
				body = { INVEN = 10 },
				level_range = {self.level, self.level},
				no_drops = true,
				autolevel = "warriorwill",
				exp_worth = 0,
				ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2 },
				stats = { str=15, dex=15, wil=15, con=15, cun=15},
				infravision = 10,
				silent_levelup = true,
				no_breath = 1,
				negative_status_effect_immune = 1,
				infravision = 10,
				resists = {all = 50},
				max_life = resolvers.rngavg(10, 30),
				life_rating = 6,
				combat_armor = 1, combat_def = 10,
				combat = { dam=1, atk=1, apr=1, damtype=DamageType.DARKNESS },

			}
			m.faction = self.faction
			m.summoner = self
			m.summoner_gain_exp = true
			m.tg = target
			m.target = target
			m.hallucination = true
			m.on_die = function(self)
				local target = self.target
				local DamageType = require "engine.DamageType"
				if target and not target.dead then 
					target:removeEffect(target.EFF_HIDEOUS_VISIONS)
					if self.summoner:knowTalent(self.summoner.T_SANITY_WARP) then
						local t = self.summoner:getTalentFromId(self.summoner.T_SANITY_WARP)
						local tg = {type="ball", radius=self.summoner:getTalentRadius(t), range=100, friendlyfire=false, talent=t}
						local damage = self.summoner:spellCrit(t.getDamage(self.summoner,t))
						self.summoner:projectSource(tg, target.x, target.y, DamageType.DARKNESS, damage, nil, t)
						game.level.map:particleEmitter(self.x, self.y, self.summoner:getTalentRadius(t), "generic_ball", {radius=self.summoner:getTalentRadius(t), rm=50, rM=50, gm=50, gM=50, bm=50, bM=50, am=200, aM=255})

						if target:hasEffect(target.EFF_CACOPHONY) then
							local ceff = target:hasEffect(target.EFF_CACOPHONY)
							local cdam = ceff.power * damage
							self.summoner:projectSource(tg, target.x, target.y, DamageType.TEMPORAL, cdam, nil, t)
						end
					end
				end
			end
			m.on_act = function(self)
				self.energy.value = 0
			end
			m.summon_time = t.getDuration(self, t)
			m.remove_from_party_on_death = true
			m:resolve() m:resolve(nil, true)
			m:forceLevelup(self.level)			
			local x, y = util.findFreeGrid(x, y, 1, true, {[Map.ACTOR]=true})
			if x then 
				game.zone:addEntity(game.level, m, "actor", x, y)
				target:setEffect(target.EFF_HIDEOUS_VISIONS, t.getDuration(self,t), {src=m, power=t.getDamageReduction(self,t)})
			end
			game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=60, rM=130, gm=20, gM=110, bm=90, bM=130, am=70, aM=180})
		end
	end,
	info = function(self, t)
		local chance = t.getChance(self,t)
		local dur = t.getDuration(self,t)
		local damage = t.getDamageReduction(self,t)
		return ([[Each time an enemy takes damage from Dark Whispers, there is a %d%% chance for one of their visions to manifest in an adjacent tile for %d turns. This vision takes no actions but the victim will deal %d%% reduced damage to all other targets until the vision is slain.
		A target cannot have more than one hallucination at a time.]]):
		tformat(chance, dur, damage)
	end,
}

newTalent{
	name = "Sanity Warp",
	type = {"demented/madness", 3},
	require = dementedreq3,
	points = 5,
	mode = "passive",
	radius = function(self, t) return self:combatTalentScale(t, 1, 2.6) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 60) end,
	info = function(self, t)
		local dam = t.getDamage(self,t)
		local radius = self:getTalentRadius(t)
		return ([[When a hallucination from Hideous Visions is slain, it unleashes a psychic shriek dealing %0.2f darkness damage to enemies in radius %d.]]):
		tformat(damDesc(self, DamageType.DARKNESS, dam), radius)
	end,
}

newTalent{
	name = "Cacophony",
	type = {"demented/madness", 4},
	require = dementedreq4,
	points = 5,
	insanity = -10,
	cooldown = 15,
	tactical = { ATTACK = {TEMPORAL = 2}, },
	requires_target = true,
	range = 0,
	direct_hit = true,
	getDamage = function(self, t) return (self:combatTalentSpellDamage(t, 40, 150)) / 100 end,
	getDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 2.5, 4.5)) end,
	radius = function(self, t) return 10 end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, friendlyfire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self.x, self.y
		local damage = t.getDamage(self, t)
		local dur = t.getDuration(self,t)
		
		local damage2 = self:spellCrit(self:callTalent(self.T_DARK_WHISPERS, "getDamage"))
		local stat = self:callTalent(self.T_DARK_WHISPERS, "getPowerLoss")

		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			if target:hasEffect(target.EFF_DARK_WHISPERS) then
				target:setEffect(target.EFF_DARK_WHISPERS, 5, {src=self, dam=damage2, power=stat, maxpower=stat*3, hv=1})
				target:setEffect(target.EFF_CACOPHONY, dur, {src=self, power=damage, apply_power=self:combatSpellpower()})
				--game.level.map:particleEmitter(px, py, 1, "circle", {oversize=0.7, a=200, limit_life=8, appear=8, speed=-2, img="disease_circle", radius=0})
			end
		end)

		game.level.map:particleEmitter(x, y, tg.radius, "generic_sploom", {rm=160, rM=180, gm=50, gM=50, bm=200, bM=220, am=35, aM=90, radius=tg.radius, basenb=60})
		game:playSoundNear(self, "talents/tidalwave")

		return true
	end,
	info = function(self, t)
		local rad = self:getTalentRadius(t)
		local dur = t.getDuration(self,t)
		local dam = t.getDamage(self,t)*100
		return ([[Raise your Dark Whispers in radius %d to a deafening crescendo for %d turns, applying another stack and drowning out all thought. 
			Targets afflicted by Dark Whispers will have 20%% higher chance to spawn hallucinations, and each time they take damage from your Dark Whispers or Sanity Warp they will take an additional %d%% damage as temporal damage.
		The damage will improve with your Spellpower.]]):tformat(rad, dur, dam)
	end,
}
