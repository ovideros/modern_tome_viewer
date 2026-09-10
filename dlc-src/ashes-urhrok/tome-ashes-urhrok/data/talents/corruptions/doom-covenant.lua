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
	name = "Dark Reign",
	type = {"corruption/doom-covenant", 1},
	require = corrs_req_high1,
	points = 5,
	mode = "passive",
	getStack = function(self, t) return math.floor(self:combatTalentScale(t, 1, 4.5)) end,
	getThreshold = function(self, t) return 20 end,
	callbackOnDealDamage = function(self, t, val, target, dead, death_note)
		if self.turn_procs.dark_reign then return end
		if not death_note or not death_note.damtype or (death_note.damtype ~= DamageType.DARKNESS) or (target == self) then return end
		if self:reactionToward(target) >= 0 then return end -- Ally and self damage cheesing is bad
		if not death_note.source_talent_mode or death_note.source_talent_mode == "none" then return end
		if not rng.percent(t.getThreshold(self, t)) and not dead then return end

		self.turn_procs.dark_reign = true 

		local die_at = 0
		local dread = self:getTalentFromId(self.T_DREAD_END)
		local dread_level = self:getTalentLevel(dread)
		if dread and dread_level >= 3 then die_at = dread.getDieAt(self, dread) end
			
		self:setEffect(self.EFF_DARK_REIGN, 8, {max_stacks=t.getStack(self, t), die_at = die_at}) -- Made negative in the effect

	end,
	info = function(self, t)
		return ([[Your affinity for the shadows grow stronger.
		Whenever one of your spells deal darkness damage you have a %d%% chance to gain 8%% to all damage affinity for 8 turns.
		If you kill a creature with darkness damage this effect always triggers.
		You can only gain one stack of Dark Reign per turn.
		This effect stacks multiplicatively up to %d times.]]):
		tformat(t.getThreshold(self, t),t.getStack(self, t))
	end,
}

-- Note:  Number of pools scales with action speed
newTalent{
	name = "Dread End",
	type = {"corruption/doom-covenant", 2},
	require = corrs_req_high2,
	points = 5,
	mode = "passive",
	radius = 1,
	getThreshold = function(self, t) return 0.1 end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 40) end, -- 5 ticks, can crit, can be spawned 1 per turn in somewhat realistic scenarios
	getDieAt = function(self, t) return self:combatTalentSpellDamage(t, 15, 60) end,
	getTargetRadius = function(self, t) return 8 end, -- This should be static or it has weird scaling implications like "but I don't want to spawn them farther away"
	callbackOnDealDamage = function(self, t, val, target, dead, death_note)
		if self.turn_procs.dread_end then return end
		if not self:hasEffect(self.EFF_DARK_REIGN) then return end
		if not death_note or not death_note.damtype or target == self or not target.x then return end
		if self:reactionToward(target) >= 0 then return end -- Ally and self damage cheesing is bad
		if not ( (val >= target.max_life * t.getThreshold(self, t)) or dead ) then return end


		self.turn_procs.dread_end = true
		local damage = self:spellCrit(t.getDamage(self, t))

		-- Find all targets in the radius then pick one at random to spawn a pool on top of
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, t.getTargetRadius(self, t), true)
		
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, engine.Map.ACTOR)
			if a and self:reactionToward(a) < 0 then tgts[#tgts+1] = a end
		end end

		local actor = rng.tableRemove(tgts)
		if actor and actor.x and actor.y then
			local e = game.level.map:addEffect(self,
				actor.x, actor.y, 5,
				DamageType.DARKNESS, damage,
				self:getTalentRadius(t),
				5, nil,
				MapEffect.new{zdepth=6, color_br=255, color_bg=255, color_bb=255, effect_shader="shader_images/darkness_pools.png"},
				nil, false, 0
			)
			e.is_dread_end = true
		end
	end,
	info = function(self, t)
		return ([[You learn to use death around you to an even greater advantage. 
		Each time you kill or deal damage above %d%% of a creatures max life with non-darkness damage while Dark Reign is active the death will create a pool of dark energies of radius 1 for 5 turns.
		This pool spawns on top of a random enemy within radius %d.
		Any foes standing inside will take %0.2f darkness damage each turn.
		This effect can only happen once per turn.
		The damage increases with spellpower.
		At talent level 3 your Dark Reign buff also protects you from death until reaching %d life per stack.]])
		:tformat(t.getThreshold(self, t)*100, t.getTargetRadius(self, t), damDesc(self, DamageType.DARKNESS, t.getDamage(self, t)), t.getDieAt(self, t) )
	end,
}

-- In practice you usually get two turns of this even at duration 1 since its instant
-- At actual duration 2 its a bit too easy to stack and also encourages you to just stack to full right off instead of spawn pools, boring
newTalent{
	name = "Blood Pact",
	type = {"corruption/doom-covenant", 3},
	require = corrs_req_high3,
	points = 5,
	cooldown = 7,
	no_energy = true,
	tactical = { VIM = 2 },
	getVim = function(self, t) return self:combatTalentScale(t, 5, 25, 0.75) end, 
	getStamina = function(self, t) return self:combatTalentScale(t, 5, 25, 0.75) end,
	getLifeCost = function(self, t) return 0.1 end, -- % of current, not max, to make it easier to re-use mid fight and more costly as the (ideal) initiation
	action = function(self, t)

		local life_loss = self.life * t.getLifeCost(self, t)
		self:takeHit(life_loss, self) -- Not sure this should count as actual damage

		game.level.map:particleEmitter(self.x, self.y, 1, "circle", {shader=true, oversize=1, a=120, appear=8, limit_life=14, speed=1.5, img="blood_pact", radius=0})
		
		-- Only give stamina/vim if we have a stack of Dark Reign to avoid out of combat vim gain
		local eff = self:hasEffect(self.EFF_DARK_REIGN)
		if eff and eff.stacks then
			self:incVim(t.getVim(self, t)*eff.stacks)
			self:incStamina(t.getStamina(self, t)*eff.stacks)
		end
		
		self:setEffect(self.EFF_BLOOD_PACT, 1, {})

		return true
	end,
	info = function(self, t)
		return ([[Pay %d%% of your current life and gain 100%% darkness damage conversion for 1 turns.
			If Dark Reign is active you also gain %d stamina and %d vim per stack.]]):
		tformat(t.getLifeCost(self, t)*100, t.getStamina(self, t),t.getVim(self, t))
	end,
}

newTalent{
	name = "Erupting Darkness",
	type = {"corruption/doom-covenant", 4},
	require = corrs_req_high4,
	points = 5,
	vim = 8,
	cooldown = 15,
	radius = 7,
	direct_hit = true,
	requires_target = true,
	no_energy = true,
	tactical = { ATTACKAREA = { FIRE = 2, PHYSICAL = 2} },
	getDuration = function(self, t) return 5 end,
	getNb = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3)) end,
	nbProj = function(self, t) return 2 end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 80) end,
	on_pre_use = function(self, t)
		if not game.level then return end
		local rad = self:getTalentRadius(t)
		for i, e in ipairs(game.level.map.effects) do if e.is_dread_end and e.src == self then
			local d = (self.x-e.x)^2 + (self.y-e.y)^2
			local r = (rad + e.radius)^2
			if d < r then
				return true
			end
		end end
	end,
	action = function(self, t)
		local function make_volcano(x, y)
			local oe = game.level.map(x, y, Map.TERRAIN)
			if not oe or oe:attr("temporary") then return end

			local e = Object.new{
				old_feat = oe,
				type = oe.type, subtype = oe.subtype,
				name = _t"raging volcano", image = oe.image, add_mos = {{image = "terrain/lava/volcano_01.png"}},
				display = '&', color=colors.LIGHT_RED, back_color=colors.RED,
				always_remember = true,
				temporary = t.getDuration(self, t),
				x = x, y = y,
				canAct = false,
				nb_projs = t.nbProj(self, t),
				dam = t.getDamage(self, t),
				act = function(self)
					local tgts = {}
					local grids = core.fov.circle_grids(self.x, self.y, 5, true)
					for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
						local a = game.level.map(x, y, engine.Map.ACTOR)
						if a and self.summoner:reactionToward(a) < 0 then tgts[#tgts+1] = a end
					end end

					-- Randomly take targets
					local tg = {type="bolt", friendlyfire=false, selffire=false, range=5, x=self.x, y=self.y, talent=self.summoner:getTalentFromId(self.summoner.T_VOLCANO), display={image="object/lava_boulder.png"}}
					for i = 1, self.nb_projs do
						if #tgts <= 0 then break end
						local a, id = rng.table(tgts)
						table.remove(tgts, id)

						self.summoner:projectile(tg, a.x, a.y, engine.DamageType.MOLTENROCK, self.dam, {type="flame"})
						game:playSoundNear(self, "talents/fire")
					end

					self:useEnergy()
					self.temporary = self.temporary - 1
					if self.temporary <= 0 then
						game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
						game.level:removeEntity(self)
						game.level.map:updateMap(self.x, self.y)
						game.nicer_tiles:updateAround(game.level, self.x, self.y)
					end
				end,
				summoner_gain_exp = true,
				summoner = self,
			}
			game.level:addEntity(e)
			game.level.map(x, y, Map.TERRAIN, e)
			game.nicer_tiles:updateAround(game.level, x, y)
			game.level.map:updateMap(x, y)

			if core.shader.active(4) then
				game.level.map:particleEmitter(x, y, 1, "shader_ring_rotating", {rotation=0, radius=2, life=30, y=0, img="flamesshockwave"}, {type="firearcs"})
			end
		end

		local es = {}
		local rad = self:getTalentRadius(t)
		for i, e in ipairs(game.level.map.effects) do if e.is_dread_end and e.src == self then
			local d = (self.x-e.x)^2 + (self.y-e.y)^2
			local r = (rad + e.radius)^2
			if d < r then
				es[#es+1] = e
			end
		end end

		if #es == 0 then return nil end

		local nb = t.getNb(self, t)
		while nb > 0 and #es > 0 do
			local e = rng.tableRemove(es)
			make_volcano(e.x, e.y)
		end

		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[When Dread End creates pools of darkness you can focus your raging thoughts on them to make them erupt into volcanos.
		Up to %d pools in radius %d will erupt, producing a volcano for %d turns.
		Each turn the volcano will send out fiery boulders that deal %0.2f fire and %0.2f physical damage.
		The effects will improve with your Spellpower.]]):
		tformat(t.getNb(self, t), self:getTalentRadius(t), t.getDuration(self, t), damDesc(self, DamageType.FIRE, dam/2), damDesc(self, DamageType.PHYSICAL, dam/2))
	end,
}
