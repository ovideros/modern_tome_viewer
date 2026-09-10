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
	name = "Accelerate",
	type = {"demented/timethief", 1},
	require = dementedreq1,
	points = 5,
	cooldown = 12,
	insanity = -10,
	no_energy = true,
	tactical = { DISABLE = {slow = 1}, ESCAPE = 2 },
	requires_target = true,
	radius = 4,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4.5)) end,
	getSpeed = function(self, t) return self:combatTalentScale(t, 100, 300) end,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local nb = 0
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if target and target:canBe("slow") and target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 5) then
				nb = math.min(4, nb + 1)
				target:setEffect(target.EFF_SLOW_MOVE, t.getDuration(self, t), {power=0.5})
			end	
		end)
		
		local power = t.getSpeed(self,t)
		
		power = power + (power * nb / 8) 
		
		game:onTickEnd(function()
			self:setEffect(self.EFF_ACCELERATE, 1, {src = self, power = power} )
		end)
		
		game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "generic_ball", {radius=self:getTalentRadius(t), rm=100, rM=125, gm=100, gM=125, bm=100, bM=125, am=200, aM=255})
		game:playSoundNear(self, "talents/echo")		
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local dur = t.getDuration(self, t)
		local speed = t.getSpeed(self, t)
		return ([[Distorting spacetime around yourself, you reduce the movement speed of all enemies in radius %d by 50%% for %d turns.
You use the siphoned speed to grant yourself incredible quickness for 1 turn, increasing movement speed by %d%%, increased by a further %d%% for each enemy slowed, to a maximum of 4.
Any actions other than movement will cancel the effect.]]):
		tformat(radius, dur, speed, speed/8)
	end,
}

newTalent{
	name = "Switch",
	type = {"demented/timethief", 2},
	require = dementedreq2,
	points = 5,
	cooldown = 7,
	insanity = -15,
	tactical = { CURE = 3 },
	requires_target = true,
	radius = 10,
	getNb = function(self, t) return 1 + math.floor(self:combatTalentScale(t, 1, 3)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5.5)) end,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tgts = {}
		local effs = {}
		local max_nb, dur = t.getNb(self,t), t.getDuration(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py)
			local act = game.level.map(px, py, Map.ACTOR)
			if not act or self:reactionToward(act) >= 0 then return end
			local nb = 0
			for eff_id, p in pairs(act.tmp) do
				local e = act.tempeffect_def[eff_id]
				if e.status == "beneficial" and e.type ~= "other" and e.decrease ~= 0 then
					local odur = p.dur				
					p.dur = p.dur - dur
					
					if p.dur <= 0 then
						act:dispel(eff_id, self)
					end
					
					nb = nb + 1
					if nb >= max_nb then break end
				end
			end		
			nb = 0
			tgts[#tgts+1] = act
		end)
		
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" and e.type ~= "other" and not e.subtype["cross tier"] then
				effs[#effs+1] = eff_id
			end
		end

		for i = 1, t.getNb(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			local e2 = self.tmp[eff]
			local odur = e2.dur
			e2.dur = e2.dur - t.getDuration(self, t)
			if e2.dur <= 0 then self:dispel(eff, self) end
		end
	
		game:onTickEnd(function()
			if game.level then
				self:resetCanSeeCache()
				if self.player then for uid, e in pairs(game.level.entities) do if e.x then game.level.map:updateMap(e.x, e.y) end end game.level.map.changed = true end
			end
		end)		
		
		game:playSoundNear(self, "talents/switch")
		return true
	end,
	info = function(self, t)
		local nb = t.getNb(self,t)
		local dur = t.getDuration(self,t)
		return ([[Release a surge of entropy, cleansing yourself of afflictions while draining the energy from others. All enemies in range 10 will have the duration of %d beneficial effects reduced by %d turns, while you will have an equal number of detrimental effects reduced by the same duration.]]):
		tformat(nb, dur)
	end,
}

newTalent{
	name = "Suspend",
	type = {"demented/timethief", 3},
	require = dementedreq3,
	points = 5,
	tactical = { ESCAPE = 2, DISABLE = 2 },
	insanity = -10,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 40, 25)) end,
	requires_target = true,
	direct_hit = true,
	requires_target = true,
	no_npc_use = true, -- this would be absurdly frustrating to fight against vs npcs
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4.5)+1) end,
	action = function(self, t)
		local dur = t.getDuration(self,t)
		self:setEffect(self.EFF_SUSPEND_BEN, dur, {power=dur} )
		
		game:playSoundNear(self, "talents/suspend")
		return true
	end,
	info = function(self, t)
		local dur = t.getDuration(self,t)
		return ([[You freeze yourself in time for %d turns, preventing you from taking any action but preventing any damage taken.
				Negative effects and cooldowns will decrease in duration, while beneficial effects will remain at their current duration.]]):tformat(dur)
	end,
}

newTalent{
	name = "Split",
	require = dementedreq4,
	type = {"demented/timethief", 4},
	random_ego = "attack",
	points = 5,
	cooldown = 20,
	insanity = -25,
	tactical = { DISABLE = 3 },
	requires_target = true,
	range = 10,
	getDuration = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 3, 8)) end,
	getPower = function(self, t) return math.floor(self:combatTalentLimit(t, 40, 5, 20)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		local target = game.level.map(tx, ty, Map.ACTOR)
		if not target or self:reactionToward(target) >= 0 then return end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 1, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		if target:attr("summon_time") then
			game.logPlayer(self, "You can't clone summons!")
			return
		end

		if target:reactionToward(self) >= 0 or not self:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 5) then
			game.logSeen(target, "%s resists!", target:getName():capitalize())
			return true
		end

		local modifier = t.getPower(self, t)
	
		local m = target:cloneActor{
			shader = "shadow_simulacrum",
			shader_args = { color = {0.6, 0.0, 0.3}, base = 0.6, time_factor = 1500 },
			no_drops = true, keep_inven_on_death = false,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = t.getDuration(self, t),
			ai_target = {actor=target},
			ai = "summoned", ai_real = "tactical",
			name = ("#LIGHT_STEEL_BLUE#%s's Temporal Clone#LAST#"):tformat(target:getName()),
			desc = _t[[A warped image resembling the creature it appeared from, its features a flickering blur of all possible futures.]],
		}
		m:removeAllMOs()
		m.make_escort = nil
		m.on_added_to_level = nil
		m.on_added = nil

		mod.class.NPC.castAs(m)
		engine.interface.ActorAI.init(m, m)

		m.exp_worth = 0
		m.energy.value = 0
		m.player = nil
		m.max_life = m.max_life - ((m.max_life * (20 + modifier)) / 100)
		m.life = util.bound(m.life, 0, m.max_life)
		m.inc_damage.all = (m.inc_damage.all or 0) - (100 - (40 + modifier))
		m.forceLevelup = function() end
		m.on_die = nil
		m.die = nil
		m.puuid = nil
		m.on_acquire_target = nil
		m.no_inventory_access = true
		m.on_takehit = nil
		m.seen_by = nil
		m.can_talk = nil
		m.clone_on_hit = nil
		m.self_resurrect = nil
		m.no_drops = true
		
		if m.talents.T_SUMMON then m.talents.T_SUMMON = nil end
		if m.talents.T_MULTIPLY then m.talents.T_MULTIPLY = nil end
		
		-- Inner Demon's never flee
		m.ai_tactic = m.ai_tactic or {}
		m.ai_tactic.escape = 0
		if game.party:hasMember(self) then
			m.remove_from_party_on_death = true
			game.party:addMember(m, {
				control=false,
				temporary_level = true,
				type="summon",
				title=_t"Summon",
			})
		end
		
		-- Remove some talents
		local tids = {}
		for tid, _ in pairs(m.talents) do
			local t = m:getTalentFromId(tid)
			if t.no_npc_use then tids[#tids+1] = t end
		end
		for i, t in ipairs(tids) do
			if t.mode == "sustained" and m:isTalentActive(t.id) then m:forceUseTalent(t.id, {ignore_energy=true}) end
			m.talents[t.id] = nil
		end
		
		-- remove detrimental timed effects
		local effs = {}
		for eff_id, p in pairs(m.tmp) do
			local e = m.tempeffect_def[eff_id]
			if e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		while #effs > 0 do
			local eff = rng.tableRemove(effs)
			if eff[1] == "effect" then
				m:removeEffect(eff[2])
			end
		end

		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "shadow")

		target:setEffect(target.EFF_SPLIT, t.getDuration(self,t), {src = self, resist = 80-modifier, dam = 40+modifier } )

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local dur = t.getDuration(self, t)
		local power = t.getPower(self,t)
		local res = 80 - power
		local dam = 40 + power
		local life = 20 + power
		return ([[The target enemy will be partially removed from the normal flow of time for %d turns, inhibiting their ability to interact with the world. All damage taken will be reduced by %d%%, while all damage dealt will be reduced by %d%%.
While active, you form the frayed threads of their timeline into a temporal clone of them for the same duration, which assists you in combat. This clone is identical, but has %d%% reduced life and deals %d%% damage.]]):
		tformat(dur, res, dam, life, dam)
	end,
}
