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
	name = "Galvanic Rod",
	type = {"spell/galvanic-technomancy",1},
	require = technomancy_req_high1, is_technomancy = true, is_steam = true,
	points = 5,
	steam = 8,
	mana = 10,
	cooldown = 9,
	fixed_cooldown = true,
	tactical = { ATTACKAREA = { FIRE = 1, LIGHTNING = 1 }, },
	requires_target = true,
	range = 10,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2)) end,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=self:spellFriendlyFire(), talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 270) end,
	on_pre_use = function(self, t, silent) if not self:knowTalent(self.T_TINKER_ARCANE_DYNAMO) then if not silent then game.logPlayer(self, "You need an arcane dynamo to cast this spell.") end return false end return true end,
	isRodUsable = function(self, t, eff, i)
		if not eff then eff = self:hasEffect(self.EFF_GALVANIC_ROD) end if not eff then return false end
		local cd = self:getTalentCooldown(t)
		local rod = eff.rods[i]
		if rod.turns - cd >= 0 then
			return true
		else
			return false, math.floor(cd - rod.turns)
		end
	end,
	hasRodUsable = function(self, t, eff)
		if not eff then eff = self:hasEffect(self.EFF_GALVANIC_ROD) end if not eff then return false end
		for i, rod in ipairs(eff.rods) do
			if t.isRodUsable(self, t, eff, i) then return i, eff end
		end
		return false
	end,
	getFasterRod = function(self, t, eff)
		if not eff then eff = self:hasEffect(self.EFF_GALVANIC_ROD) end if not eff then return 1, 1 end
		local id, cd = false, 99999
		for i, rod in ipairs(eff.rods) do
			local ok, rcd = t.isRodUsable(self, t, eff, i)
			if not ok and rcd < cd then id = i; cd = rcd end
		end
		return cd, id
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)

		if not self:hasEffect(self.EFF_GALVANIC_ROD) then self:setEffect(self.EFF_GALVANIC_ROD, 1, {}) end
		if not t.hasRodUsable(self, t) then return end

		self:project(tg, x, y, DamageType.GALVANIC, self:spellCrit(t.getDamage(self, t)))
		game.level.map:particleEmitter(x, y, tg.radius, "galvanic_ball", {radius=tg.radius})
		game:playSoundNear(self, "talents/lightning")

		if self:attr("burning_wake") then
			game.level.map:addEffect(self, x, y, 4, DamageType.INFERNO, self:attr("burning_wake"), tg.radius, 5, nil, {type="inferno"}, nil, self:spellFriendlyFire())
		end
		if self:isTalentActive(self.T_HURRICANE) then
			self:projectApply(tg, x, y, Map.ACTOR, function(target) if rng.percent(25) then self:callTalent(self.T_HURRICANE, "do_hurricane", target) end end)
		end

		if self:isTalentActive(self.T_GALVANIC_ARCING) then
			self:callTalent(self.T_GALVANIC_ARCING, "placeRod", x, y)
		end
		return true
	end,
	post_action = function(self, t)
		if not self:isTalentCoolingDown(t) then return end

		local rod_id, eff = t.hasRodUsable(self, t)
		if not rod_id then return end -- Shouldnt happen
		eff.rods[rod_id].turns = 0
		-- eff.rods[1].turns = 0
		-- eff.rods[2].turns = 0
		-- eff.rods[3].turns = 0
		self.talents_cd[t.id] = nil

		-- That was the last charge
		if not t.hasRodUsable(self, t) then
			self.talents_cd[t.id] = t.getFasterRod(self, t)
		end
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[You summon a galvanic rod at a location. Upon arrival the rod releases a shock in radius %d dealing %0.2f galvanic damage (fire and lightning) to all creatures.
		You have 3 rods each with their own %d turns cooldown.
		This spell works with Burning Wake.
		This spell has 25%% chance to try to activate Hurricane, if used.
		The damage will increase with your Spellpower.]]):tformat(radius, damDesc(self, DamageType.GALVANIC, damage), self:getTalentCooldown(t))
	end,
}

newTalent{
	name = "Galvanic Arcing",
	type = {"spell/galvanic-technomancy",2},
	require = technomancy_req_high2, is_technomancy = true, is_steam = true,
	mode = "sustained",
	points = 5,
	sustain_mana = 40,
	cooldown = 30,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 3, 9)) end,
	tactical = { BUFF=2, ATTACKAREA = { LIGHTNING = 1, FIRE = 1 } },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 55) end,
	getDur = function(self, t) return 25 end,
	callbackOnCloned = function(self, t)
		local p = self:isTalentActive(t.id)
		if not p then return end
		p.rods = {}
		p.zone = nil
	end,
	callbackOnChangeLevel = function(self, t, what)
		if what ~= "leave" then return end
		t.removeRods(self, t)
	end,
	callbackOnActBase = function(self, t)
		t.updateRodsSystem(self, t, -1)
	end,
	removeRods = function(self, t)
		local p = self:isTalentActive(t.id)
		if not p then return end
		for _, rod in ipairs(p.rods) do
			game.level.map:removeParticleEmitter(rod.particle)
		end
		p.rods = {}
		if p.zone then
			for _, ps in ipairs(p.zone.particles) do game.level.map:removeParticleEmitter(ps) end
		end
	end,
	doDamage = function(self, t, p, damfct)
		if not p.zone then return end
		local selffire = self:spellFriendlyFire()
		if p.rods[1].is_weapon_rod then selffire = false end

		if not damfct then
			local dam = self:spellCrit(t.getDamage(self, t))
			damfct = function(px, py)
				-- game.level.map:particleEmitter(px, py, 1, "flame")
				DamageType:get(DamageType.GALVANIC).projector(self, px, py, DamageType.GALVANIC, dam)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if self:getTalentLevel(t) >= 3 and target then target:setEffect(target.EFF_SHOCKED, 1, {apply_power=self:combatSpellpower()}) end
				if self:isTalentActive(self.T_HURRICANE) and target then
					if rng.percent(15) then self:callTalent(self.T_HURRICANE, "do_hurricane", target) end
				end
			end
		-- Light it up!
		else
			if p.zone.mode == "triangle" then
				for i = 1, 6 do
					game.level.map:particleEmitter(p.zone.center.x, p.zone.center.y, 1, "galvanic_field", {temporary=true, r1=p.zone.r1, r2=p.zone.r2, r3=p.zone.r3}, nil, 13)
					game.level.map:particleEmitter(p.zone.center.x, p.zone.center.y, 1, "galvanic_field", {temporary=true, r1=p.zone.r1, r2=p.zone.r2, r3=p.zone.r3, do_edges=true}, nil, 13)
				end
			else
				for i = 1, 6 do
					game.level.map:particleEmitter(p.zone.center.x, p.zone.center.y, 1, "galvanic_link", {temporary=true, tx=p.zone.r2.x, ty=p.zone.r2.y}, nil, 13)
				end
			end
		end

		if p.zone.mode == "triangle" then
			self:project({type="triangle", tri_points={p.zone.r1, p.zone.r2, p.zone.r3}, tri_src="corners", x=p.zone.center.x, y=p.zone.center.y, selffire=selffire}, p.zone.center.x, p.zone.center.y, damfct)
		else
			self:project({type="beam", x=p.zone.r2.x+p.zone.center.x, y=p.zone.r2.y+p.zone.center.y, selffire=selffire, range=10}, p.zone.center.x, p.zone.center.y, damfct)
			damfct(p.zone.r2.x+p.zone.center.x, p.zone.r2.y+p.zone.center.y)
		end
	end,
	setupTriangleZone = function(self, t, p, turns, r1, r2, r3)
		if p.zone then
			if p.zone.mode == "triangle" and p.zone.r1.x == r1.x and p.zone.r1.y == r1.y and p.zone.r2.x == r2.x and p.zone.r2.y == r2.y and p.zone.r3.x == r3.x and p.zone.r3.y == r3.y then
				if turns ~= 0 then t.doDamage(self, t, p) end
				return
				-- for _, ps in ipairs(p.zone.particles) do game.level.map:removeParticleEmitter(ps) end
			else
				for _, ps in ipairs(p.zone.particles) do game.level.map:removeParticleEmitter(ps) end
			end
		end

		local range = self:getTalentRange(t)
		if not self:hasLOS(r2.x, r2.y, "block_sight", range, r1.x, r1.y) or
		   not self:hasLOS(r3.x, r3.y, "block_sight", range, r1.x, r1.y) or
		   not self:hasLOS(r3.x, r3.y, "block_sight", range, r2.x, r2.y) then
		   	return
		end

		local center = {x=math.floor((r1.x+r2.x+r3.x)/3), y=math.floor((r1.y+r2.y+r3.y)/3)}
		r1.x, r1.y = r1.x - center.x, r1.y - center.y
		r2.x, r2.y = r2.x - center.x, r2.y - center.y
		r3.x, r3.y = r3.x - center.x, r3.y - center.y
		p.zone = {
			mode = "triangle",
			r1 = r1,
			r2 = r2,
			r3 = r3,
			center = center,
			particles = {},
		}

		for i = 1, 3 do
			table.insert(p.zone.particles, game.level.map:particleEmitter(center.x, center.y, 1, "galvanic_field", {r1=r1, r2=r2, r3=r3}, nil, 13))
			table.insert(p.zone.particles, game.level.map:particleEmitter(center.x, center.y, 1, "galvanic_field", {r1=r1, r2=r2, r3=r3, do_edges=true}, nil, 13))
		end

		if turns ~= 0 then t.doDamage(self, t, p) end
	end,
	setupBeamZone = function(self, t, p, turns, r1, r2)
		if p.zone then
			if p.zone.mode == "line" and p.zone.r1.x == r1.x and p.zone.r1.y == r1.y and p.zone.r2.x == r2.x and p.zone.r2.y == r2.y then
				if turns ~= 0 then t.doDamage(self, t, p) end
				return
				-- for _, ps in ipairs(p.zone.particles) do game.level.map:removeParticleEmitter(ps) end
			else
				for _, ps in ipairs(p.zone.particles) do game.level.map:removeParticleEmitter(ps) end
			end
		end

		local range = self:getTalentRange(t)
		if not self:hasLOS(r2.x, r2.y, "block_sight", range, r1.x, r1.y) then
		   	return
		end

		local center = table.clone(r1)
		r1.x, r1.y = r1.x - center.x, r1.y - center.y
		r2.x, r2.y = r2.x - center.x, r2.y - center.y
		p.zone = {
			mode = "line",
			r1 = r1,
			r2 = r2,
			center = center,
			particles = {},
		}

		for i = 1, 3 do
			table.insert(p.zone.particles, game.level.map:particleEmitter(center.x, center.y, 1, "galvanic_link", {tx=r2.x, ty=r2.y}, nil, 13))
		end

		if turns ~= 0 then t.doDamage(self, t, p) end
	end,
	updateRodsSystem = function(self, t, turns)
		local p = self:isTalentActive(t.id)
		if not p then return end

		-- Delete by durations
		for i, rod in ripairs(p.rods) do
			rod.dur = rod.dur + turns
			if rod.dur <= 0 or rod.is_weapon_rod then
				game.level.map:removeParticleEmitter(rod.particle)
				table.remove(p.rods, i)
			end
		end

		-- Add weapon rod if any
		if self:getTalentLevel(t) >= 5 then
			local weapon = self:hasWeaponType(nil)
			if (weapon and weapon.metallic) or (weapon and weapon.tinker and weapon.tinker.metallic) then
				if #p.rods < 3 then
					table.insert(p.rods, 1, {x=self.x, y=self.y, dur=9999, is_weapon_rod=true})
				else
					if p.rods[1].is_weapon_rod then
						p.rods[1].x = self.x
						p.rods[1].y = self.y
					end
				end
			end
		end

		-- Delete dupes
		local todel = {}
		for i, rod in ripairs(p.rods) do
			for j, rod2 in ripairs(p.rods) do
				if i ~= j and rod.x == rod2.x and rod.y == rod2.y then
					if rod.is_weapon_rod then
						todel[i] = true
					elseif rod2.is_weapon_rod then
						todel[j] = true
					elseif rod.dur < rod2.dur then
						todel[i] = true
					else
						todel[j] = true
					end
				end
			end
		end
		if next(todel) then
			todel = table.keys(todel)
			table.sort(todel)
			for _, i in ripairs(todel) do
				local rod = table.remove(p.rods, i)
				game.level.map:removeParticleEmitter(rod.particle)
			end
		end

		if #p.rods == 3 then
			local r = {
				{x=p.rods[1].x, y=p.rods[1].y},
				{x=p.rods[2].x, y=p.rods[2].y},
				{x=p.rods[3].x, y=p.rods[3].y},
			}

			-- Detect if the 3 points are on a line: same thing as the triangle having an area of 0
			local area = math.triangle_area(r[1], r[2], r[3])

			if area < 0.001 then
				-- Find the two further apart and make a beam
				local edges = {}
				for i = 1, 3 do for j = 1, 3 do if i ~= j then
					edges[#edges+1] = {p1=r[i], p2=r[j], size=core.fov.distance(r[i].x, r[i].y, r[j].x, r[j].y)}
				end end end

				t.setupBeamZone(self, t, p, turns, edges[#edges].p1, edges[#edges].p2)
			else
				t.setupTriangleZone(self, t, p, turns, r[1], r[2], r[3])
			end
		elseif #p.rods == 2 then
			local r1 = {x=p.rods[1].x, y=p.rods[1].y}
			local r2 = {x=p.rods[2].x, y=p.rods[2].y}

			t.setupBeamZone(self, t, p, turns, r1, r2)
		else
			if p.zone then
				for _, ps in ipairs(p.zone.particles) do game.level.map:removeParticleEmitter(ps) end
				p.zone = nil
			end
		end
	end,
	placeRod = function(self, t, x, y)
		local p = self:isTalentActive(t.id)
		if not p then return end

		local ps = game.level.map:particleEmitter(x, y, 1, "image", {image="particles_images/galvanic_rod", size=64}, nil, 13)
		table.insert(p.rods, {x=x, y=y, dur=t.getDur(self, t), particle=ps})

		while #p.rods > 3 do
			local rod = table.remove(p.rods, 1)
			game.level.map:removeParticleEmitter(rod.particle)
		end

		t.updateRodsSystem(self, t, 0)
	end,
	on_pre_use = function(self, t, silent) if not self:knowTalent(self.T_TINKER_ARCANE_DYNAMO) then if not silent then game.logPlayer(self, "You need an arcane dynamo to cast this spell.") end return false end return true end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/lightning")
		return {
			rods = {},
		}
	end,
	deactivate = function(self, t, p)
		t.removeRods(self, t)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Using your arcane power you force galvanic rods to linger for %d turns. While lingering they are inert, but can link up to other rods.
		When two rods are present in range %d of one another they link with a galvanic beam.
		When three rods are present in range %d of one another they link with a triangular galvanic zone.
		Any creature caught in a galvanic beam or zone take %0.2f galvanic damage per turn.
		You can maintain at most 3 rods.
		At level 3 all affected creatures are shocked, reducing their stun and pin resistances by half.
		At level 5 your weapon (if metallic, or embedded with a metallic tinker) acts as a rod that does not count towards your maximum.
		This spell has 15%% chance to try to activate Hurricane, if used.
		The damage will increase with your Spellpower.]]):tformat(t.getDur(self, t), self:getTalentRange(t), self:getTalentRange(t), damDesc(self, DamageType.GALVANIC, damage))
	end,
}

newTalent{
	name = "Unstable Blast",
	type = {"spell/galvanic-technomancy",3},
	require = technomancy_req_high3, is_technomancy = true, is_steam = true,
	points = 5,
	steam = 45,
	mana = 15,
	cooldown = 15,
	tactical = { ATTACKAREA = { FIRE = 1, LIGHTNING = 1 }, DISABLE = {stun = 2} },
	range = 10,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDur = function(self, t) return self:combatTalentLimit(t, 9, 3, 7) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 310) end,
	on_pre_use = function(self, t, silent)
		if not self:knowTalent(self.T_TINKER_ARCANE_DYNAMO) then if not silent then game.logPlayer(self, "You need an arcane dynamo to cast this spell.") end return false end
		local p = self:isTalentActive(self.T_GALVANIC_ARCING)
		if not p or #p.rods == 0 or p.rods[#p.rods].is_weapon_rod then if not silent then game.logPlayer(self, "You need Galvanic Arcing active and at least one rod to cast this spell.") end return false end
		return true
	end,
	action = function(self, t)
		local p = self:isTalentActive(self.T_GALVANIC_ARCING)
		if not p then return nil end
		local lk_t = self:getTalentFromId(self.T_GALVANIC_ARCING)

		local dam = self:spellCrit(t.getDamage(self, t))
		local damfct = function(px, py)
			DamageType:get(DamageType.GALVANIC).projector(self, px, py, DamageType.GALVANIC, dam)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if target and target:canBe("stun") then target:setEffect(target.EFF_STUNNED, t.getDur(self, t), {apply_power=self:combatSpellpower()}) end
			if self:attr("burning_wake") then
				game.level.map:addEffect(self, px, py, 4, DamageType.INFERNO, self:attr("burning_wake"), 0, 5, nil, {type="inferno"}, nil, self:spellFriendlyFire())
			end
		end

		if #p.rods == 1 then
			self:project({type="ball", radius=1, range=10}, p.rods[1].x, p.rods[1].y, damfct)
			game.level.map:particleEmitter(p.rods[1].x, p.rods[1].y, 1, "galvanic_ball", {radius=1})
		elseif #p.rods >= 2 then
			-- We call linked rods doDamage BUT with out own t
			lk_t.doDamage(self, t, p, damfct)
		end

		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Reaching through the aether you temporarily destabilize a galvanic rod's control systems. (Using your weapon as a rod does not count as a valid target)
		This creates a blast in radius 1 around it, or through all connected rods if they are linked dealing %0.2f galvanic damage to all creatures and stunning them for %d turns.
		This spell works with Burning Wake.
		The damage will increase with your Spellpower.]]):tformat(damDesc(self, DamageType.GALVANIC, damage), t.getDur(self, t))
	end,
}

newTalent{
	name = "Energy Mass Conversion",
	type = {"spell/galvanic-technomancy",4},
	require = technomancy_req_high4, is_technomancy = true, is_steam = true,
	points = 5,
	steam = 40,
	mana = 40,
	cooldown = function(self, t) return self:combatTalentLimit(t, 7, 20, 12) end,
	tactical = { CLOSEIN = 2 },
	range = 10,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	radius = function(self, t) return self:combatTalentLimit(t, 9, 2, 7) end,
	on_pre_use = function(self, t, silent)
		if not self:knowTalent(self.T_TINKER_ARCANE_DYNAMO) then if not silent then game.logPlayer(self, "You need an arcane dynamo to cast this spell.") end return false end
		local p = self:isTalentActive(self.T_GALVANIC_ARCING)
		if not p or not p.zone or p.zone.mode ~= "triangle" then if not silent then game.logPlayer(self, "You need Galvanic Arcing active and three rods to cast this spell.") end return false end
		return true
	end,
	action = function(self, t)
		local p = self:isTalentActive(self.T_GALVANIC_ARCING)
		if not p or not p.zone or p.zone.mode ~= "triangle" then return nil end
		local lk_t = self:getTalentFromId(self.T_GALVANIC_ARCING)

		local tgts = {}
		for _, rod in ipairs(p.rods) do
			self:project({type="ball", radius=self:getTalentRadius(t), x=rod.x, y=rod.y, range=10}, rod.x, rod.y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if target and target ~= self and target:canBe("knockback") then tgts[target] = true end
			end)
		end
		
		local sorted_tgts = {}
		for target, _ in pairs(tgts) do
			sorted_tgts[#sorted_tgts+1] = {target=target, dist=core.fov.distance(p.zone.center.x, p.zone.center.y, target.x, target.y)}
		end
		table.sort(sorted_tgts, "dist")

		for _, tgt in ipairs(sorted_tgts) do
			-- Not resistable
			tgt.target:pull(p.zone.center.x, p.zone.center.y, 20)
		end

		self:forceUseTalent(self.T_UNSTABLE_BLAST, {ignore_cooldown=true, ignore_energy=true})

		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		return ([[Using large amounts of arcane power you create a supercharged Unstable Blast in your rods.
		The extra energy is briefly converted to a huge mass, pulling in all creatures (but you) in range %d of any rod towards the center of the galvanic field.
		Can only be used with a triangular field is setup.]])
		:tformat(self:getTalentRadius(t))
	end,
}
