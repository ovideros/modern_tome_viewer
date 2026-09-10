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
	name = "Condensate",
	type = {"psionic/action-at-a-distance", 1},
	points = 5, 
	require = psi_wil_req1,
	psi = 10,
	steam = 10,
	cooldown = 5,
	range = 7,
	requires_target = true,
	tactical = { ATTACKAREA = {FIRE = 2} },
	radius = function(self, t) return math.ceil(self:combatTalentLimit(t, 4, 1, 3.3)) end,
	target = function(self, t)
		local tg = {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), talent=t, friendlyfire=false}
		return tg
	end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 25, 300) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = self:mindCrit(t.getDamage(self, t))
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			DamageType:get(DamageType.FIRE).projector(self, px, py, DamageType.FIRE, dam)
			target:setEffect(target.EFF_WET, 4, {apply_power=self:combatMindpower()})
		end)

		local _ _, _, _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "vapour_explosion", {radius=tg.radius, smoke="particles_images/smoke_whispery_bright"})
		game.level.map:particleEmitter(x, y, tg.radius, "vapour_explosion", {radius=tg.radius, smoke="particles_images/smoke_heavy_bright"})
		game.level.map:particleEmitter(x, y, tg.radius, "vapour_explosion", {radius=tg.radius, smoke="particles_images/smoke_dark"})

		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Condensate hot steam around your foes in radius %d, burning them for %0.2f fire damage and applying the wet effect for 4 turns, halving their stun resistances.
		The damage will increase with your Mindpower.]]):
		tformat(self:getTalentRadius(t), damDesc(self, DamageType.FIRE, damage))
	end,
}

newTalent{
	name = "Solidify Air",
	type = {"psionic/action-at-a-distance", 2},
	points = 5,
	require = psi_wil_req2,
	psi = 10,
	steam = 10,
	cooldown = 15,
	range = 0,
	requires_target = true,
	target = function(self, t)
		local tg = {type="cone", range=self:getTalentRange(t), radius=8, talent=t, cone_angle = 25}
		return tg
	end,
	no_npc_use = true, -- creating walls is super annoying against players and will benefit them more often than harming, giving them 9 free turns on their own to rest 
	getDur = function(self, t) return self:combatTalentLimit(t, 10, 2, 8) end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 25, 400) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = self:mindCrit(t.getDamage(self, t))
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then
				local oe = game.level.map(px, py, Map.TERRAIN)
				if not oe or oe.special then return end
				if not oe or oe:attr("temporary") or game.level.map:checkAllEntities(px, py, "block_move") then return end
				local e = Object.new{
					old_feat = oe,
					name = _t"solid air", image = oe.image, add_mos={{image = "terrain/solidified_air.png"}},
					desc = _t"a piece of solidified air",
					type = "wall",
					display = '#', color=colors.LIGHT_BLUE, back_color=colors.LIGHT_BLUE,
					always_remember = true,
					can_pass = {pass_wall=1},
					does_block_move = true,
					show_tooltip = true,
					block_move = true,
					block_sight = false,
					temporary = t.getDur(self, t),
					x = px, y = py,
					canAct = false,
					act = function(self)
						self:useEnergy()
						self.temporary = self.temporary - 1
						if self.temporary <= 0 then
							game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
							game.level:removeEntity(self)
							game.level.map:updateMap(self.x, self.y)
							game.nicer_tiles:updateAround(game.level, self.x, self.y)
						end
					end,
					dig = function(src, x, y, old)
						game.level:removeEntity(old, true)
						return nil, old.old_feat
					end,
					summoner_gain_exp = true,
					summoner = self,
				}
				e.tooltip = mod.class.Grid.tooltip
				game.level:addEntity(e)
				game.level.map(px, py, Map.TERRAIN, e)
			--	game.nicer_tiles:updateAround(game.level, px, py)
			--	game.level.map:updateMap(px, py)
			else
				DamageType:get(DamageType.PHYSICAL).projector(self, px, py, DamageType.PHYSICAL, dam)
			end
		end)
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[You concentrate your will in a cone in front of you, condensing the air into a tangible, solid form.
		Any creatures caught inside take %0.2f physical damage.
		Any places with no creatures will be filled with solid air, blocking the way for %d turns.
		The damage will increase with your Mindpower.]]):
		tformat(damDesc(self, DamageType.PHYSICAL, damage), t.getDur(self, t))
	end,
}

newTalent{
	name = "Superconduction",
	type = {"psionic/action-at-a-distance", 3},
	points = 5,
	require = psi_wil_req3,
	psi = 10,
	steam = 10,
	cooldown = 5,
	range = 7,
	requires_target = true,
	radius = function(self, t) return math.ceil(self:combatTalentLimit(t, 4, 1, 3.3)) end,
	target = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		return tg
	end,
	tactical = { ATTACKAREA = { LIGHTNING = function(self, t, target) if target:hasEffect(target.EFF_WET) then return 2 end return 0 end},
				 ATTACK = { LIGHTNING = function(self, t, target) if not target:hasEffect(target.EFF_WET) then return 1.5 end return 0 end},
				 DISABLE = 1},
	getSearing = function(self, t) return self:combatTalentScale(t, 15, 40) end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 25, 400) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = t.getDamage(self, t)
		dam = rng.avg(dam / 3, dam, 3)
		dam = self:mindCrit(dam)
		local target, px, py = nil
		self:project(tg, x, y, function(_px, _py)
			px, py = _px, _py
			target = game.level.map(px, py, Map.ACTOR)
		end)
		if not target then return end

		local tg = {type="ball", radius=0, friendlyfire=false, start_x=px, start_y=py, talent=t}
		if target:hasEffect(target.EFF_WET) then
			tg.radius = self:getTalentRadius(t)
			if core.shader.active() then game.level.map:particleEmitter(px, py, tg.radius, "ball_lightning_beam", {radius=tg.radius}, {type="lightning"})
			else game.level.map:particleEmitter(px, py, tg.radius, "ball_lightning_beam", {radius=tg.radius}) end
		end

		self:project(tg, px, py, function(ppx, ppy)
			local target = game.level.map(ppx, ppy, Map.ACTOR)
			if not target then return end
			DamageType:get(DamageType.LIGHTNING).projector(self, ppx, ppy, DamageType.LIGHTNING, dam)
			target:setEffect(target.EFF_SEARED, 4, {apply_power=self:combatMindpower(), power=t.getSearing(self, t)})
		end)

		if core.shader.active() then game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(px-self.x), math.abs(py-self.y)), "lightning_beam", {tx=px-self.x, ty=py-self.y}, {type="lightning"})
		else game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(px-self.x), math.abs(py-self.y)), "lightning_beam", {tx=px-self.x, ty=py-self.y})
		end
		game:playSoundNear(self, "talents/lightning")

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Call a streak of lightning on your target, dealing %0.2f to %0.2f lightning damage.
		If it is wet the lightning propagates to all foes in radius %d, doing the same damage to each.
		All affected foes are seared for 4 turns, reducing their fire resistance by %d%% and and mind save by %d.
		The damage will increase with your Mindpower.]]):
		tformat(damDesc(self, DamageType.LIGHTNING, damage) / 3, damDesc(self, DamageType.LIGHTNING, damage), self:getTalentRadius(t), t.getSearing(self, t), t.getSearing(self, t))
	end,
}

newTalent{
	name = "Negative Biofeedback",
	type = {"psionic/action-at-a-distance", 4},
	points = 5,
	mode = "sustained",
	sustain_psi = 50,
	drain_steam = 2,
	cooldown = 20,
	require = psi_wil_req4,
	tactical = { ANNOY = 2, BUFF = 2 },
	getNb = function(self, t) return self:getTalentLevelRaw(t) end,
	getSave = function(self, t) return self:combatTalentScale(t, 3, 7) end,
	getPower = function(self, t) return self:combatTalentScale(t, 2, 6) end,
	callbackOnDealDamage = function(self, t, val, target, dead, death_note)
		if dead or not death_note or not death_note.source_talent or target == self then return end
		if not death_note.source_talent.is_mind then return end
		if self.turn_procs.negative_biofeedback and self.turn_procs.negative_biofeedback ~= target then return end

		target:setEffect(target.EFF_NEGATIVE_BIOFEEDBACK, 5, {max_stacks=t.getNb(self, t), save=t.getSave(self, t), power=t.getPower(self, t), no_ct_effect = true})
		self.turn_procs.negative_biofeedback = target
	end,
	activate = function(self, t)
		local ret = {}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Any time you deal damage with a psionic ability you incur a negative biofeedback in your foes, stacking up to %d times for 5 turns.
		Each stack reduces their physical save by %d, defense and armour by %d.
		This effect may only occur once per turn.]]):
		tformat(t.getNb(self, t), t.getSave(self, t), t.getPower(self, t))
	end,
}
