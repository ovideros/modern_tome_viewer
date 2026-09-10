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
local entity = require 'engine.Entity'

newTalent{
	name = "Heavy Weapons", image = "talents/hw_flamethrower.png",
	type = {"steamtech/heavy-weapons", 1},
	points = 5, 
	require = steam_req1,
	mode = "passive",
	require = {
		stat = { cun=function(level) return 12 + (level-1) * 2 end },
		level = function(level) return 0 + (level-1) * 6  end,
	},
	no_npc_use = true,
	getNb = function(self, t) return 5 end,
	getFlamethrowerBaseDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.5) end,	
	getBoltgunBaseDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.6, 1.1) end,	
	getBoltgunSaves = function(self, t) return self:combatTalentSteamDamage(t, 10, 35) end,
	getBoltgunSteam = function(self, t) return self:combatTalentSteamDamage(t, 1, 6) end,
	getShockstaffBaseDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.2, 1.5) end,	
	getShockstaffNumb = function(self, t) return math.floor(self:combatTalentLimit(t, 50, 10, 25)) end,	
	callbackOnActBase = function(self, t)
		local max = t.getNb(self, t)
		if not self:isTalentActive(self.T_HW_FLAMETHROWER) and not self:isTalentActive(self.T_HW_SHOCKSTAFF) and not self:isTalentActive(self.T_HW_BOLTGUN) then
			self:setEffect(self.EFF_HEAVY_AMMUNITION, 1, {stacks=0, stack_bits=1, max_stacks=max})
		end
	end,
	on_learn = function(self, t)
		if self:getTalentLevel(t) >= 1 then
			local max = t.getNb(self, t)
			self:setEffect(self.EFF_HEAVY_AMMUNITION, 1, {stacks=max, max_stacks=max})	
			self:learnTalent(self.T_HW_FLAMETHROWER, true)
			self:learnTalent(self.T_HW_SHOCKSTAFF, true)
			self:learnTalent(self.T_HW_BOLTGUN, true)
		end
	end,	
	on_unlearn = function(self, t)
		if self:getTalentLevel(t) < 1 then
			self:unlearnTalent(self.T_HW_FLAMETHROWER)
			self:unlearnTalent(self.T_HW_SHOCKSTAFF)
			self:unlearnTalent(self.T_HW_BOLTGUN)
			self:removeEffect(self.EFF_HEAVY_AMMUNITION)		
		end
	end,
	info = function(self, t)
		local nb = t.getNb(self,t)
		local fdam = t.getFlamethrowerBaseDamage(self,t)*100
		local sdam = t.getShockstaffBaseDamage(self,t)*100
		local snumb = t.getShockstaffNumb(self,t)
		local bdam = t.getBoltgunBaseDamage(self,t)*100
		local bsteam = t.getBoltgunSteam(self,t)
		-- local bsave = t.getBoltgunSaves(self,t)
		return([[You gain the ability to equip one of 3 heavy weapons listed below, temporarily granting you a special attack. Heavy weapons are significantly more powerful than a steamgun, but require heavy ammunition to fire. You can store up to %d ammunition at a time, and regenerate 1 every 3 turns while a heavy weapon is not equipped.
		
		#AQUAMARINE#Flamethrower#LAST#: An incendiary device which projects streams of liquid flame at your foes. Deals %d%% steamgun fire damage over 3 turns to those in radius 5. The flamethrower ignores armor, always hits, and counts as a steamgun shot for the purpose of on-hits.
		#AQUAMARINE#Shockstaff#LAST#: An electrically charged baton wielded in close combat. Deals %d%% lightning damage to enemies in a frontal arc, as well as reducing the damage they deal by %d%% for 3 turns. This counts as a melee attack but triggers ammunition on-hit effects. All shockstaff attacks will also make a shield attack for the same damage as lightning. You can charge up to your steamgun's range to make shockstaff attacks.
		#AQUAMARINE#Boltgun#LAST#: A multi-barreled steamgun that launches efficient, chemical infused bolts. Fires twice for %d%% steamgun acid damage and generates %d steam per hit.
		
		The damage dealt by your Heavy Weapons is based off your currently equipped ammunition, and are treated as Steamguns for the purposes of weapon mastery talents and other effects.
		Firing your Steamgun will immediately unequip your heavy weapon.		
		]]):
			tformat(nb, fdam, sdam, snumb, bdam, bsteam)
	end,
}

-- AoE, anti-armor, anti-defense, fire/burning synergy
-- Only notable in-class mobility (Safety Override)
newTalent{
	name = "Flamethrower", short_name = "HW_FLAMETHROWER",
	type = {"steamtech/other", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
	no_energy = true,
	tactical = { ATTACK = 2 },
	no_npc_use = true,
	no_sustain_autoreset = true,
	deactivate_on = {no_combat=true, run=true, rest=true},
	on_pre_use = function(self, t, silent) 
		if not self:hasArcheryWeapon("steamgun") then 
			if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end
			return false
		end
		if not self:hasEffect(self.EFF_HEAVY_AMMUNITION) or self:hasEffect(self.EFF_HEAVY_AMMUNITION).stacks == 0 then
			if not silent then game.logPlayer(self, "You require heavy ammunition to use this talent.") end
			return false
		end
		return true
	end,
	activate = function(self, t)
		local flamethrower = self:getTalentFromId(self.T_FLAME_JET)
		if not flamethrower.fire_flamethrower(self, flamethrower) then return end
		local ret = {
		}

		if self:isTalentActive(self.T_HW_SHOCKSTAFF) then self:forceUseTalent(self.T_HW_SHOCKSTAFF, {ignore_energy=true}) end
		if self:isTalentActive(self.T_HW_BOLTGUN) then self:forceUseTalent(self.T_HW_BOLTGUN, {ignore_energy=true}) end
		if self.hotkey and self.isHotkeyBound then
			local pos = self:isHotkeyBound("talent", self.T_SHOOT)
			if pos then
				self.hotkey[pos] = {"talent", self.T_FLAME_JET}
			end
			self:talentTemporaryValue(ret, "auto_shoot_talent", "T_FLAME_JET")
		end

		local ohk = self.hotkey
		self.hotkey = nil
		self:learnTalent(self.T_FLAME_JET, true, 1, {no_unlearn=true})
		self.hotkey = ohk
		
		self.steam_using_heavy_weapon = "flamethrower"
		self:updateModdableTile()
		return ret
	end,
	deactivate = function(self, t, p)
--		self:removeParticles(p.particles)
		if self.hotkey and self.isHotkeyBound then
			local pos = self:isHotkeyBound("talent", self.T_FLAME_JET)
			if pos then
				self.hotkey[pos] = {"talent", self.T_SHOOT}
			end
		end

		self:unlearnTalent(self.T_FLAME_JET, 1, nil, {no_unlearn=true})
		
		self.steam_using_heavy_weapon = nil
		self:updateModdableTile()
		return true
	end,
	info = function(self, t)
		local hw = self:getTalentFromId(self.T_HEAVY_WEAPONS)
		local fdam = hw.getFlamethrowerBaseDamage(self, hw)*100
		return ([[You replace your steamgun and attack with an incendiary device that projects streams of liquid flame at your foes.
		
		Deals %d%% steamgun damage as fire over 3 turns to enemies in radius 5.

		These attacks cannot miss and ignore armor.]]):tformat(fdam)
	end,
}

newTalent{
	name = "Flame Jet",
	type = {"steamtech/other", 1},
	points = 1,
	no_energy = "fake",
	heavy_weapon = true,
	range = steamgun_range,
	innate = true,
	getDamage = function(self,t) return self:callTalent(self.T_HEAVY_WEAPONS, "getFlamethrowerBaseDamage") end,
	tactical = { ATTACKAREA = { weapon = 2 }, },
	no_npc_use = true,
	requires_target = true,
	target = function(self, t)
		local weapon, ammo = self:hasArcheryWeapon()
		return {type = "cone", range = 0, radius = self:getTalentRange(t), selffire = false, talent = t }
	end,
	on_pre_use = function(self, t, silent) 
		if self:attr("disarmed") then 
			if not silent then game.logPlayer(self, "You are disarmed.") end
			return false
		end
		if not self:hasArcheryWeapon("steamgun") then 
			if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end
			return false
		end
		if not self:hasEffect(self.EFF_HEAVY_AMMUNITION) or self:hasEffect(self.EFF_HEAVY_AMMUNITION).stacks == 0 then
			if not silent then game.logPlayer(self, "You require heavy ammunition to fire your flamethrower.") end 
			return false 
		end 
		return true 
	end,
	fire_flamethrower = function(self, t)
		local eff = self:hasEffect(self.EFF_HEAVY_AMMUNITION)
		if not eff then return nil end

		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return end
		local targets = {}
		local add_target = function(x, y)
			local target = game.level.map(x, y, game.level.map.ACTOR)
			if target and self:reactionToward(target) < 0 then
				targets[#targets + 1] = target
			end
		end
		self:project(tg, x, y, add_target)
		if #targets == 0 then return end

		table.shuffle(targets)

		-- Fire each shot individually.
		local old_target_forced = game.target.forced
		local fired = nil -- If we've fired at least one shot.
		for i = 1, #targets do
			local target = targets[i]
			game.target.forced = {target.x, target.y, target}
			local targets = self:archeryAcquireTargets({type = "hit", speed = 200}, {infinite=true, no_energy = fired, no_sound=true})
			if targets then
				local target = targets.dual and targets.main[1] or targets[1]
				local dist = core.fov.distance(self.x, self.y, target.x, target.y) - 1
				self:archeryShoot(targets, t, {type = "hit", speed = 200, start_x=target.x, start_y=target.y}, {mult = t.getDamage(self,t), apr=1000, phasing = true, phase_target = game.level.map(target.x, target.y, game.level.map.ACTOR), damtype=DamageType.FIREBURN})
				fired = true
			else
				-- If no target that means we're out of ammo.
				break
			end
		end
		game:playSoundNear(self, "talents/fireflash")

		game.target.forced = old_target_forced
		
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_fire", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		
		eff.stacks = eff.stacks - 1
		if eff.stacks <= 0 then self:removeEffect(self.EFF_HEAVY_AMMUNITION) end		

		return true
	end,
	action = function(self,t)
		return t.fire_flamethrower(self, t)
	end,
	info = function(self, t)
		local dam = t.getDamage(self,t)*100
		return ([[Fire a jet of flame, dealing %d%% weapon damage as fire over 3 turns.]])
		:tformat(dam)
	end,
}

-- Anti-melee, general defense, limited mobility, disable via stuns
newTalent{
	name = "Shockstaff", short_name = "HW_SHOCKSTAFF",
	type = {"steamtech/other", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
	-- no_energy = "fake",
	tactical = { ATTACK = 2 },
	no_npc_use = true,
	no_sustain_autoreset = true,
	deactivate_on = {no_combat=true, run=true, rest=true},
	on_pre_use = function(self, t, silent) 
		if not self:hasArcheryWeapon("steamgun") then 
			if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end
			return false
		end
		if not self:hasEffect(self.EFF_HEAVY_AMMUNITION) or self:hasEffect(self.EFF_HEAVY_AMMUNITION).stacks == 0 then
			if not silent then game.logPlayer(self, "You require heavy ammunition to power your shockstaff.") end 
			return false 
		end 
		return true 
	end,
	activate = function(self, t)
		local shockstaff = self:getTalentFromId(self.T_STORMSTRIKE)
		if not shockstaff.fire_shockstaff(self, shockstaff) then return end
		local ret = {
		}
		if self:isTalentActive(self.T_HW_FLAMETHROWER) then self:forceUseTalent(self.T_HW_FLAMETHROWER, {ignore_energy=true}) end
		if self:isTalentActive(self.T_HW_BOLTGUN) then self:forceUseTalent(self.T_HW_BOLTGUN, {ignore_energy=true}) end
		if self.hotkey and self.isHotkeyBound then
			local pos = self:isHotkeyBound("talent", self.T_SHOOT)
			if pos then
				self.hotkey[pos] = {"talent", self.T_STORMSTRIKE}
			end
			self:talentTemporaryValue(ret, "auto_shoot_talent", "T_STORMSTRIKE")
		end

		local ohk = self.hotkey
		self.hotkey = nil
		self:learnTalent(self.T_STORMSTRIKE, true, 1, {no_unlearn=true})
		self.hotkey = ohk
		
		self.steam_using_heavy_weapon = "shockstaff"
		self:updateModdableTile()
		return ret
	end,
	deactivate = function(self, t, p)
--		self:removeParticles(p.particles)
		if self.hotkey and self.isHotkeyBound then
			local pos = self:isHotkeyBound("talent", self.T_STORMSTRIKE)
			if pos then
				self.hotkey[pos] = {"talent", self.T_SHOOT}
			end
		end

		self:unlearnTalent(self.T_STORMSTRIKE, 1, nil, {no_unlearn=true})
		
		self.steam_using_heavy_weapon = nil
		self:updateModdableTile()
		return true
	end,
	info = function(self, t)
		local hw = self:getTalentFromId(self.T_HEAVY_WEAPONS)
		local sdam = hw.getShockstaffBaseDamage(self, hw)*100
		local snumb = hw.getShockstaffNumb(self, hw)
		return ([[You replace your steamgun and attack with a lightning-charged staff to engage in close combat.
		
		Deals %d%% steamgun damage as lightning to enemies in a frontal arc, as well as reducing the damage they deal by %d%% for 3 turns. This counts as a melee attack but triggers ammunition on-hit effects. All shockstaff attacks will also make a shield slam for the same damage as lightning. 

		You can charge up to your steamgun's range to make shockstaff attacks.]]):tformat(sdam, snumb)
	end,
}

table.insert(Talents:getTalentFromId("T_ATTACK").alternate_attacks, "T_STORMSTRIKE")

local function shockstaffMoveTarget(self, t)
	local tg = {type="bolt", nolock=true, can_autoaccept=true, range=self:getTalentRange(t)}
	local x, y, target = self:getTargetLimited(tg)
	if not x or not y or not target then return nil end

	if self:reactionToward(target) >= 0 then return end
	if core.fov.distance(self.x, self.y, x, y) > 1 and target and not self:attr("never_move") then
		local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
		local l = self:lineFOV(x, y, block_actor)
		local lx, ly, is_corner_blocked = l:step()
		if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then
			return
		end
		local tx, ty = lx, ly
		lx, ly, is_corner_blocked = l:step()
		while lx and ly do
			if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then break end
			tx, ty = lx, ly
			lx, ly, is_corner_blocked = l:step()
		end

		local ox, oy = self.x, self.y
		self:move(tx, ty, true)
		if config.settings.tome.smooth_move > 0 then
			self:resetMoveAnim()
			self:setMoveAnim(ox, oy, 8, 5)
		end
	end
	if core.fov.distance(self.x, self.y, target.x, target.y) > 1 then return end
	return x, y, target
end

newTalent{
	name = "Stormstrike",
	type = {"steamtech/other", 1},
	points = 1,
	cooldown = 0,
	range = steamgun_range,
	innate = true,
	tactical = { ATTACKAREA = {PHYSICAL=2 }, },
	no_npc_use = true,
	requires_target = true,
	heavy_weapon = true,
	getDamage = function(self,t) return self:callTalent(self.T_HEAVY_WEAPONS, "getShockstaffBaseDamage") end,
	getNumb = function(self, t) return self:callTalent(self.T_HEAVY_WEAPONS, "getShockstaffNumb") end,
	on_pre_use = function(self, t, silent) 
		if not self:hasArcheryWeapon("steamgun") then 
			if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end
			return false
		end
		if not self:hasEffect(self.EFF_HEAVY_AMMUNITION) or self:hasEffect(self.EFF_HEAVY_AMMUNITION).stacks == 0 then
			if not silent then game.logPlayer(self, "You require heavy ammunition to power your shockstaff.") end 
			return false 
		end 
		return true 
	end,
	-- Called by Attack to see if it wants to use this talent.
	can_alternate_attack = function(self, t)
		return t.on_pre_use(self, t, true)
	end,
	getShockstaffObject = function(self, t)
		local weapon = self:getInven("QUIVER")[1]
		if not weapon and weapon.combat then return end
		local ammoWeapon = weapon:cloneFull()
		ammoWeapon.combat.melee_project = {}
		ammoWeapon.combat.talented = "steamgun"
		for k, v in pairs(ammoWeapon.combat) do
			if (k == "ranged_project") then
				ammoWeapon.combat["melee_project"] = v
			end
		end
		return ammoWeapon
	end,
 	fire_shockstaff = function(self, t)
		local eff = self:hasEffect(self.EFF_HEAVY_AMMUNITION)
		if not eff then return nil end

		local ammoWeapon = t.getShockstaffObject(self, t)
		if not ammoWeapon then return end

		local x, y, target = shockstaffMoveTarget(self, t)
		if not x or not y or not target then return end
		
		self:project({type="cone", nolock=true, friendlyfire=false, range=0, radius=1}, x, y, function(px, py)
			local tmp_target = game.level.map(px, py, engine.Map.ACTOR)
			if tmp_target and tmp_target ~= self then
				local shield, shield_combat = self:hasShield()
				local hit = self:attackTargetWith(tmp_target, ammoWeapon.combat, DamageType.LIGHTNING, t.getDamage(self,t))
				if shield then 
					self:attackTargetWith(tmp_target, shield_combat, DamageType.LIGHTNING, t.getDamage(self, t))
				end
			
				if hit then tmp_target:setEffect(tmp_target.EFF_STORMSTRIKE, 3, {src=self, power=t.getNumb(self,t)}) end
			end
		end)

		if self:knowTalent(self.T_GRENADE_LAUNCHER) then
			self:callTalent(self.T_GRENADE_LAUNCHER, "callbackOnArcheryAttack", target, nil, nil, nil, nil, nil, nil, nil, t)
		end

		game.level.map:particleEmitter(self.x, self.y, 1, "stormstrike", {radius=1, tx=x-self.x, ty=y-self.y, allow=core.shader.allow("distort")})
		eff.stacks = eff.stacks - 1
		if eff.stacks <= 0 then self:removeEffect(self.EFF_HEAVY_AMMUNITION) end	
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	action = function(self, t)
		return t.fire_shockstaff(self, t)
	end,
	info = function(self, t)
		return ([[Sweep your shockstaff, striking all enemies in a frontal arc for %d%% weapon damage as lightning and reducing their damage dealt by %d%% for 3 turns.
		If you have a shield, you will also strike them.
		While active this replaces your normal melee attack.]]):
		tformat(t.getDamage(self,t)*100, t.getNumb(self,t), self:getTalentRange(t))
	end,
}

-- Steam efficient, multihit (proc synergy), highest DPS though an off damage type
-- The disarm on Heavy Weapon Expertise is probably the strongest of them, this kind of overlaps in role with Shockstaff though
newTalent{
	name = "Boltgun", short_name = "HW_BOLTGUN",
	type = {"steamtech/other", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
	no_energy = "fake",
	tactical = { ATTACK = 2 },
	no_npc_use = true,
	no_sustain_autoreset = true,
	on_pre_use = function(self, t, silent) 
		if not self:hasArcheryWeapon("steamgun") then 
			if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end
			return false
		end
		if not self:hasEffect(self.EFF_HEAVY_AMMUNITION) or self:hasEffect(self.EFF_HEAVY_AMMUNITION).stacks == 0 then
			if not silent then game.logPlayer(self, "You require heavy ammunition to fire your boltgun.") end 
			return false 
		end 
		return true 
	end,
	deactivate_on = {no_combat=true, run=true, rest=true},
	activate = function(self, t)
		local boltgun = self:getTalentFromId(self.T_FLECHETTE_BURST)
		if not boltgun.fire_boltgun(self, boltgun) then return end
		local ret = {
		}
		if self:isTalentActive(self.T_HW_FLAMETHROWER) then self:forceUseTalent(self.T_HW_FLAMETHROWER, {ignore_energy=true}) end
		if self:isTalentActive(self.T_HW_SHOCKSTAFF) then self:forceUseTalent(self.T_HW_SHOCKSTAFF, {ignore_energy=true}) end
		if self.hotkey and self.isHotkeyBound then
			local pos = self:isHotkeyBound("talent", self.T_SHOOT)
			if pos then
				self.hotkey[pos] = {"talent", self.T_FLECHETTE_BURST}
			end
			self:talentTemporaryValue(ret, "auto_shoot_talent", "T_FLECHETTE_BURST")
		end

		local ohk = self.hotkey
		self.hotkey = nil
		self:learnTalent(self.T_FLECHETTE_BURST, true, 1, {no_unlearn=true})
		self.hotkey = ohk
		
		self.steam_using_heavy_weapon = "boltgun"
		self:updateModdableTile()
		return ret
	end,
	deactivate = function(self, t, p)
--		self:removeParticles(p.particles)
		if self.hotkey and self.isHotkeyBound then
			local pos = self:isHotkeyBound("talent", self.T_FLECHETTE_BURST)
			if pos then
				self.hotkey[pos] = {"talent", self.T_SHOOT}
			end
		end

		self:unlearnTalent(self.T_FLECHETTE_BURST, 1, nil, {no_unlearn=true})

		self.steam_using_heavy_weapon = nil
		self:updateModdableTile()
		return true
	end,
	info = function(self, t)
		local hw = self:getTalentFromId(self.T_HEAVY_WEAPONS)
		local bdam = hw.getBoltgunBaseDamage(self, hw)*100
		local bsteam = hw.getBoltgunSteam(self, hw)
		-- local bsave = hw.getBoltgunSaves(self, hw)

		return ([[You replace your steamgun and attack with a multi-barreled bolt launcher, firing deadly chemical-infused flechettes.
		
		Each attack fires twice for %d%% weapon damage as acid and generates %d steam per hit.]]):tformat(bdam, bsteam)
	end,
}

newTalent{
	name = "Flechette Burst",
	type = {"steamtech/other", 1},
	points = 1,
	no_energy = "fake",
	heavy_weapon = true,
	range = steamgun_range,
	innate = true,
	getDamage = function(self,t) return self:callTalent(self.T_HEAVY_WEAPONS, "getBoltgunBaseDamage") end,
	getSteam = function(self,t) return self:callTalent(self.T_HEAVY_WEAPONS, "getBoltgunSteam") end,	
	getSaves = function(self, t) return self:callTalent(self.T_HEAVY_WEAPONS, "getBoltgunSaves") end,	
	tactical = { ATTACKAREA = { weapon = 2 }, },
	no_npc_use = true,
	requires_target = true,
	on_pre_use = function(self, t, silent) 
		if not self:hasArcheryWeapon("steamgun") then 
			if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end
			return false
		end
		if not self:hasEffect(self.EFF_HEAVY_AMMUNITION) or self:hasEffect(self.EFF_HEAVY_AMMUNITION).stacks == 0 then
			if not silent then game.logPlayer(self, "You require heavy ammunition to fire your boltgun.") end 
			return false 
		end 
		return true 
	end,
	archery_onhit = function(self, t, target, x, y, tg)
		if tg and tg.archery and tg.archery.boltgun_steam then
			self:incSteam(tg.archery.boltgun_steam)
			--game:delayedLogMessage(self, target, "boltgun_steam_count", {"#Source# generates steam from bolts!", {show_count=true}})
		end
		if tg and tg.archery and tg.archery.boltgun_disarm_dur then
			if table.get(self.turn_procs, "boltgun_disarm", target) then return end
			table.set(self.turn_procs, "boltgun_disarm", target, true)
			if target:canBe("disarm") then
				target:setEffect(target.EFF_DISARMED, tg.archery.boltgun_disarm_dur, {apply_power=self:combatSteampower()})
			else
				game.logSeen(target, "%s resists the disarm!", target:getName():capitalize())
			end
		end
	end,
	fire_boltgun = function(self, t, dam, nb, disarm)
		local eff = self:hasEffect(self.EFF_HEAVY_AMMUNITION)
		if not eff then return nil end

		local targets = self:archeryAcquireTargets(nil, {multishots=nb or 2, infinite=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {damtype=DamageType.ACID, mult=dam or t.getDamage(self, t), boltgun_steam = t.getSteam(self, t), boltgun_disarm_dur=disarm })
		
		eff.stacks = eff.stacks - 1
		if eff.stacks <= 0 then self:removeEffect(self.EFF_HEAVY_AMMUNITION) end
		
		return true
	end,
	action = function(self, t)
		return t.fire_boltgun(self, t)
	end,
	info = function(self, t)
		return ([[Fire two chemical flechettes, dealing %d%% weapon damage as acid and generating %d steam per hit.]])
		:tformat(t.getDamage(self,t)*100, t.getSteam(self,t))
	end,
}

newTalent{
	name = "Heavy Weapon Expertise",
	type = {"steamtech/heavy-weapons", 2},
	points = 5,
	steam = 15,
	no_energy = "fake",
	heavy_weapon = true,
	require = steamreq2,
	cooldown = 7,	
	range = steamgun_range,
	tactical = { ATTACKAREA = { weapon = 2 }, },
	no_npc_use = true,
	requires_target = true,
	on_pre_use = function(self, t, silent) 
		if not self:hasArcheryWeapon("steamgun") then 
			if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end
			return false
		end
		if not self:hasEffect(self.EFF_HEAVY_AMMUNITION) or not (self:isTalentActive(self.T_HW_FLAMETHROWER) or self:isTalentActive(self.T_HW_SHOCKSTAFF) or self:isTalentActive(self.T_HW_BOLTGUN)) then 
			if not silent then 
				game.logPlayer(self, "You require heavy ammunition and a heavy weapon to use this talent.")
			end 
			return false 
		end
		return true 
	end,
	getDamage = function(self, t) return self:combatTalentLimit(t, 100, 20, 50) end,
	getFireDamage = function(self, t) return self:combatTalentSteamDamage(t, 10, 90) end,
	getFlamethrowerDamage = function(self, t) 
		local flamethrower = self:getTalentFromId(self.T_FLAME_JET)
		local base = flamethrower.getDamage(self, flamethrower)
		local total = base * (1 + t.getDamage(self, t) / 100)
		return total
	end,
	getFireResist = function(self, t) return self:combatTalentLimit(t, 50, 15, 35) end,
	getShockDuration = function(self, t) return math.min(9, math.floor(self:combatTalentScale(t, 3, 5))) end,
	getShockstaffDamage = function(self, t) 
		local shockstaff = self:getTalentFromId(self.T_STORMSTRIKE)
		local base = shockstaff.getDamage(self, shockstaff)
		local total = base * (1 + t.getDamage(self, t) / 100)
		return total
	end,
	getAcidRadius = function(self, t) return math.min(9, math.floor(self:combatTalentScale(t, 2, 4))) end,
	getBoltgunAttacks = function(self, t) return 4 end,
	getBoltgunDamage = function(self, t)
		local boltgun = self:getTalentFromId(self.T_FLECHETTE_BURST)
		local base = boltgun.getDamage(self, boltgun)
		local total = base * (1 + t.getDamage(self, t) / 100) / 2.5 -- 4 hits so we tax the total damage mult a bit
		return total
	end,
	action = util.finalize(function(myenv, self, t) myenv.archery_weapon_override = self.archery_weapon_override end, function(myenv, self, t) self.archery_weapon_override = myenv.archery_weapon_override end, function(myenv, self, t)
		local eff = self:hasEffect(self.EFF_HEAVY_AMMUNITION)
		if not eff then return nil end
		
		if self:isTalentActive(self.T_HW_FLAMETHROWER) then
			local halflength = 3
			local tg =  {type="wall", range=self:getTalentRange(t), halflength=halflength, talent=t, halfmax_spots=halflength+1} 
			local x, y = self:getTarget(tg)
			if not x or not y then return end
			local targets = {}
			local add_target = function(x, y)
				local target = game.level.map(x, y, game.level.map.ACTOR)
				if target and self:reactionToward(target) < 0 and self:canSee(target) then
					targets[#targets + 1] = target
				end
			end
			self:project(tg, x, y, add_target)
			
			if #targets > 0 then
	
				table.shuffle(targets)
		
				-- Fire each shot individually.
				local old_target_forced = game.target.forced
				local fired = nil -- If we've fired at least one shot.
				for i = 1, #targets do
					local target = targets[i]
					game.target.forced = {target.x, target.y, target}
					local targets = self:archeryAcquireTargets({type = "hit", speed = 200}, {infinite=true, no_energy = fired, no_sound=true})
					if targets then
						local target = targets.dual and targets.main[1] or targets[1]
						local dist = core.fov.distance(self.x, self.y, target.x, target.y) - 1
						local mult = t.getFlamethrowerDamage(self, t)
						self:archeryShoot(targets, t, {type = "hit", speed = 200, start_x=target.x, start_y=target.y}, {mult = mult, phasing = true, phase_target = game.level.map(target.x, target.y, game.level.map.ACTOR), damtype=DamageType.FIRE})
						fired = true
					else
						-- If no target that means we're out of ammo.
						break
					end
				end
				game:playSoundNear(self, "talents/fireflash")
				game.target.forced = old_target_forced
			end
			
			local walldam = self:steamCrit(t.getFireDamage(self,t))
			self:project(tg, x, y, function(px, py)
				game.level.map:addEffect(self, px, py, 5, engine.DamageType.FIREWALL, {dam=walldam, power=t.getFireResist(self, t)}, 0, 5, nil, {type="inferno"}, nil, true)
			end)
				
			eff.stacks = eff.stacks - 1
			if eff.stacks <= 0 then self:removeEffect(self.EFF_HEAVY_AMMUNITION) end
			if not self.energy.used then self:useEnergy() end
			return true
		elseif self:isTalentActive(self.T_HW_SHOCKSTAFF) then
			local stormstrike = self:getTalentFromId(self.T_STORMSTRIKE)
			local shockstaff = stormstrike.getShockstaffObject(self, stormstrike)
			local tg = {type="bolt", can_autoaccept=true, nolock=true, range=self:getTalentRange(t)}
			local x, y, target = self:getTargetLimited(tg)
			if not x or not y or not target then return nil end
			
			if core.fov.distance(self.x, self.y, x, y) > 1 and target and not self:attr("never_move") then
				local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
				local l = self:lineFOV(x, y, block_actor)
				local lx, ly, is_corner_blocked = l:step()
				if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then
					return
				end
				local tx, ty = lx, ly
				lx, ly, is_corner_blocked = l:step()
				while lx and ly do
					if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then break end
					tx, ty = lx, ly
					lx, ly, is_corner_blocked = l:step()
				end
	
				local ox, oy = self.x, self.y
				self:move(tx, ty, true)
				if config.settings.tome.smooth_move > 0 then
					self:resetMoveAnim()
					self:setMoveAnim(ox, oy, 8, 5)
				end
			end
			local mult = t.getShockstaffDamage(self, t)
			local shield, shield_combat = self:hasShield()
			
			if core.fov.distance(self.x, self.y, x, y) > 1 then return end
			
			local speed, hit, damage = self:attackTargetWith(target, shockstaff, DamageType.LIGHTNING, mult)
			if shield then 
				self:attackTargetWith(target, shield_combat, DamageType.LIGHTNING, mult)
			end

			if hit then
				if target:canBe("stun") then
					target:setEffect(target.EFF_STUNNED, t.getShockDuration(self, t), {apply_power=self:combatSteampower()})
				else
					game.logSeen(target, "%s resists the stunning blow!", target:getName():capitalize())
				end
			
				local tg = {type="ball", range=1, radius=3, friendlyfire=false }
				self:project(tg, target.x, target.y, function(px, py, tg, self)
					local tmp_target = game.level.map(px, py, Map.ACTOR)
					if tmp_target and tmp_target ~= self and tmp_target ~= target then
						local hit = self:attackTargetWith(tmp_target, shockstaff.combat, DamageType.LIGHTNING, mult)
						if shield then 
							self:attackTargetWith(tmp_target, shield_combat, DamageType.LIGHTNING, mult)
						end						
						if tmp_target:canBe("stun") then
							tmp_target:setEffect(tmp_target.EFF_STUNNED, t.getShockDuration(self, t), {apply_power=self:combatSteampower()})
						else
							game.logSeen(tmp_target, "%s resists the stunning shock!", tmp_target:getName():capitalize())
						end						
					end
				end)
				if core.shader.active(4) then
					game.level.map:particleEmitter(target.x, target.y, tg.radius, "shader_ring", {radius=tg.radius*2, life=8}, {type="sparks"})
				else
					local x, y = target.x, target.y
					-- Lightning ball gets a special treatment to make it look neat
					local sradius = (tg.radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
					local nb_forks = 16
					local angle_diff = 360 / nb_forks
					for i = 0, nb_forks - 1 do
						local a = math.rad(rng.range(0+i*angle_diff,angle_diff+i*angle_diff))
						local tx = x + math.floor(math.cos(a) * tg.radius)
						local ty = y + math.floor(math.sin(a) * tg.radius)
						game.level.map:particleEmitter(x, y, tg.radius, "lightning", {radius=tg.radius, grids=grids, tx=tx-x, ty=ty-y, nb_particles=25, life=8})
					end
				end
				game:playSoundNear(self, "talents/echo")
			end
			
			eff.stacks = eff.stacks - 1
			if eff.stacks <= 0 then self:removeEffect(self.EFF_HEAVY_AMMUNITION) end
			if not self.energy.used then self:useEnergy() end
			return true
		elseif self:isTalentActive(self.T_HW_BOLTGUN) then
			local boltgun = self:getTalentFromId(self.T_FLECHETTE_BURST)
			local mult = t.getBoltgunDamage(self, t)
			if not boltgun.fire_boltgun(self, boltgun, mult, t.getBoltgunAttacks(self, t), 5) then return end
			if eff.stacks <= 0 then self:removeEffect(self.EFF_HEAVY_AMMUNITION) end
			if not self.energy.used then self:useEnergy() end
			return true
		end
	end),
	info = function(self, t)
		local dam = t.getDamage(self, t)
		local fdam = t.getFireDamage(self, t)
		local ftdam = t.getFlamethrowerDamage(self, t) * 100
		local fresist = t.getFireResist(self, t)
		local sdur = t.getShockDuration(self, t)
		local sdam = t.getShockstaffDamage(self, t) * 100
		local bdam = t.getBoltgunDamage(self, t) * 100
		local bcount = t.getBoltgunAttacks(self, t)
		-- local arad = t.getAcidRadius(self,t)
		return ([[Your advanced training unlocks specialised techniques, triggering an effect based on your current heavy weapon at the cost of 1 heavy weapon ammunition.
#AQUAMARINE#Flamethrower#LAST#: Sweep your flamethrower across the ground, dealing %d%% steamgun damage as fire and raising a length 7 wall of fire for 5 turns. Those inside the wall take %0.2f fire damage and have their fire resistance reduced by %d%% for 2 turns.
#AQUAMARINE#Shockstaff#LAST#: Slam your staff into the target, creating a radius 3 shockwave that deals %d%% shockstaff damage as lightning and stuns those within for %d turns.
#AQUAMARINE#Boltgun#LAST#: Fire %d boltgun shots dealing %d%% steamgun damage as acid and disarming the target for 5 turns.
The damage dealt by the fire wall and the chance to apply effects will increase with your Steampower.]])
		:tformat(ftdam, fdam, fresist, sdam, sdur, bcount, bdam)
	end,
}

newTalent{
	name = "Automated Defenses",
	type = {"steamtech/heavy-weapons", 3},
	points = 5,
	mode = "passive",
	no_npc_use = true,
	require = steamreq3,
	range = steamgun_range,
	radius = steamgun_range,
	getFlameDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.5, 2.5) end,
	getSilenceDuration = function(self, t) return math.min(5, math.floor(self:combatTalentScale(t, 3, 5))) end,
	getShockDamage = function(self, t) return self:combatTalentWeaponDamage(t, 2.0, 4.5) end,
	getBoltDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.4, 1.0) end,
	getBoltNb = function(self, t) return math.floor(self:combatTalentScale(t, 4, 12)) end,
	callbackOnTalentPost = function(self, t, ab, ret)
		local shield, shield_combat = self:hasShield()

		if ab.id == self.T_BLOCK and ret == true and shield then
			if self:isTalentActive(self.T_HW_FLAMETHROWER) then
				local dam = t.getFlameDamage(self, t)
				local tg = {type="ball", radius=self:getTalentRadius(t), range=0, friendlyfire=false}
				self:project(tg, self.x, self.y, function(px, py, tg, self)
					local target = game.level.map(px, py, Map.ACTOR)
					if target and target ~= self then
						local cs = nil
						if target:hasEffect(target.EFF_COUNTERSTRIKE) then
							cs = target:copyEffect(target.EFF_COUNTERSTRIKE)
							target:removeEffect(target.EFF_COUNTERSTRIKE)
						end				
						local speed, hit = self:attackTargetWith(target, shield_combat, DamageType.FIRE, dam)
						if cs then
							target:setEffect(target.EFF_COUNTERSTRIKE, cs.dur, cs)
						end							
						if hit then
							if target:canBe("silence") then target:setEffect(target.EFF_SILENCED, t.getSilenceDuration(self, t), {apply_power=self:combatSteampower()}) end
						end
					end
				end)
				-- game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_fire", {radius=tg.radius, tx=x-self.x, ty=y-self.y})	
				game.level.map:particleEmitter(self.x, self.y, tg.radius, "fireflash", {radius=tg.radius})
				return true
			elseif self:isTalentActive(self.T_HW_SHOCKSTAFF) then
					local dam = t.getShockDamage(self, t)				
					local cs = nil
					local tg = {type="ball", radius=3, friendlyfire=false, talent=t }
					local highest = 0
					self:project(tg, self.x, self.y, function(px, py, tg, self)
						local target = game.level.map(px, py, Map.ACTOR)
						if not target then return end
						if target:hasEffect(target.EFF_COUNTERSTRIKE) then
							cs = target:copyEffect(target.EFF_COUNTERSTRIKE)
							target:removeEffect(target.EFF_COUNTERSTRIKE)
						end
						local speed, hit, damage = self:attackTargetWith(target, shield_combat, DamageType.LIGHTNING, dam)
						if cs then
							target:setEffect(target.EFF_COUNTERSTRIKE, cs.dur, cs)
						end
						if damage and damage > highest then highest = damage end
					end)

					if highest > 0 then
						self:setEffect(self.EFF_DAMAGE_SHIELD, 6, {color={0xe1/255, 0xcb/255, 0x3f/255}, power=highest})
					end
				return true
			elseif self:isTalentActive(self.T_HW_BOLTGUN) then
				local dam = t.getBoltDamage(self, t)
				local tg = {type="ball", radius=7, range=0, friendlyfire=false, talent=t}
				
				self:project(tg, self.x, self.y, function(px, py, tg, self)
					local target = game.level.map(px, py, Map.ACTOR)
					if target and target ~= self then
						local cs = nil
						-- Not a great way to do this.. Modify the effect maybe?
						if target:hasEffect(target.EFF_COUNTERSTRIKE) then
							cs = target:copyEffect(target.EFF_COUNTERSTRIKE)
							target:removeEffect(target.EFF_COUNTERSTRIKE)
						end
						local speed, hit, damage = self:attackTargetWith(target, shield_combat, DamageType.ACID, dam)
						if cs then
							target:setEffect(target.EFF_COUNTERSTRIKE, cs.dur, cs)
						end							
						if hit then
							target:setEffect(target.EFF_CORROSIVE_FLECHETTE, 6, {src=self, power=damage/2, nb=t.getBoltNb(self,t)})
						end
					end
				end)
			end
		else return end
	end,
	info = function(self, t)
		return([[You augment your shield with your heavy weapon technology, causing an effect when you Block with a heavy weapon equipped.
#AQUAMARINE#Flamethrower#LAST#: Vent choking, burning smoke in an area of the same radius as your flamethrower. Enemies caught within take %d%% shield damage as fire and are silenced for %d turns.
#AQUAMARINE#Shockstaff#LAST#: Sheathe your shield in lightning and attack all enemies in radius 3, dealing %d%% shield damage as lightning and gaining a barrier absorbing an amount of damage equal to 100%% of the highest damage dealt for 6 turns.
#AQUAMARINE#Boltgun#LAST#: Fire a blast of flechettes from your shield at all enemies in radius 7, dealing %d%% shield damage as acid. %d flechettes remain embedded in each target for 6 turns, and when struck by a melee or ranged attack a flechette will detonate and cause acid damage equal to 50%% of the shield damage dealt.
These attacks will not trigger Counterstrike.
The chance to silence will increase with your Steampower.]])
:tformat(t.getFlameDamage(self,t)*100, t.getSilenceDuration(self,t), t.getShockDamage(self,t)*100, t.getBoltDamage(self,t)*100, t.getBoltNb(self,t))
	end,
}

newTalent{
	name = "Safety Override",
	type = {"steamtech/heavy-weapons", 4},
	points = 5,
	cooldown = 9,
	require = steamreq4,
	steam = 10,
	no_energy = "fake",
	heavy_weapon = true,
	no_npc_use = true,
	on_pre_use = function(self, t, silent) 
		if not self:hasArcheryWeapon("steamgun") then 
			if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end
			return false
		end
		if not self:hasEffect(self.EFF_HEAVY_AMMUNITION) or not (self:isTalentActive(self.T_HW_FLAMETHROWER) or self:isTalentActive(self.T_HW_SHOCKSTAFF) or self:isTalentActive(self.T_HW_BOLTGUN)) then 
			if not silent then 
				game.logPlayer(self, "You require heavy ammunition and a heavy weapon to use this talent.")
			end 
		return false 
		end 
		return true 
	end,
	getFlamethrowerRange = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,	
	getFlamethrowerDamage = function(self, t) return self:combatTalentSteamDamage(t, 20, 280) end,
	getFlamethrowerBurn = function(self, t) return math.floor(self:combatTalentScale(t, 50, 120))/100 end,
	getShockDamage = function(self, t) return self:combatTalentScale(t, 1.5, 2.5) end,
	getShockRadius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4.5)) end,				
	getShockKnockback = function(self, t) return math.floor(self:combatTalentScale(t, 5, 10)) end,
	getShockPulseDamage = function(self, t) return self:combatTalentSteamDamage(t, 20, 200) end,
	getBoltDamage = function(self, t) return self:combatTalentScale(t, 1.5, 2.5) end,
	getBoltDamageIncrease = function(self, t) return self:combatTalentScale(t, 5, 20) end,			
	getBoltDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4.5)) end,			
	action = util.finalize(function(myenv, self, t) myenv.archery_weapon_override = self.archery_weapon_override end, function(myenv, self, t) self.archery_weapon_override = myenv.archery_weapon_override end, function(myenv, self, t)
		local eff = self:hasEffect(self.EFF_HEAVY_AMMUNITION)
		if not eff then return nil end
		
		if self:isTalentActive(self.T_HW_FLAMETHROWER) then 	
			local tg = {type="hit", nolock=true, range=t.getFlamethrowerRange(self,t)}
			local x, y, target = self:getTarget(tg)
			if not x or not y then return nil end
			local _ _, x, y = self:canProject(tg, x, y)
	
			if game.level.map(x, y, Map.ACTOR) then
				x, y = util.findFreeGrid(x, y, 1, true, {[Map.ACTOR]=true})
				if not x then return end
			end
	
			if game.level.map:checkAllEntities(x, y, "block_move") then return end

			local tg2 = {type="ball", range=0, radius=4, selffire=false, friendlyfire=false, talent=t}
			self:project(tg2, self.x, self.y, DamageType.FLAME_FUEL, {dam=self:steamCrit(t.getFlamethrowerDamage(self, t)), burn=t.getFlamethrowerBurn(self,t)})
			game.level.map:particleEmitter(self.x, self.y, 4, "ball_fire", {radius=4})
			game:playSoundNear(self, "talents/fire")
			
			local ox, oy = self.x, self.y
			self:move(x, y, true)
			if config.settings.tome.smooth_move > 0 then
				self:resetMoveAnim()
				self:setMoveAnim(ox, oy, 8, 5)
			end

			if not self.energy.used then self:useEnergy() end
			self:removeEffect(self.EFF_HEAVY_AMMUNITION)
			self:forceUseTalent(self.T_HW_FLAMETHROWER, {ignore_energy=true})
			return true
		elseif self:isTalentActive(self.T_HW_SHOCKSTAFF) then
			local tg = {type="ball", range=0, radius=t.getShockRadius(self, t), friendlyfire=false }
			local state = {}
			self:project(tg, self.x, self.y, function(px, py, tg, self)
				local target = game.level.map(px, py, Map.ACTOR)
				if target then
					local stormstrike = self:getTalentFromId(self.T_STORMSTRIKE)
					local shockstaff = stormstrike.getShockstaffObject(self, stormstrike)
					local hit = self:attackTargetWith(target, shockstaff, DamageType.LIGHTNING, t.getShockDamage(self,t))
					local dam = t.getShockPulseDamage(self,t)
					if hit then 
						target:knockback(self.x, self.y, t.getShockKnockback(self,t), false, function(g, x, y)
							-- Deal our bonus damage
							if game.level.map:checkAllEntities(x, y, "block_move", target) then
								self:project({type="ball", range=100, radius=1, selffire=false, friendlyfire=false}, target.x, target.y, function(tx, ty)
									local target = game.level.map(tx, ty, Map.ACTOR)
									if target and not state[target] then
										if not state.did_crit then
											dam = self:steamCrit(dam)
											state.did_crit = true
										end
										state[target] = true  -- Avoid knockback multihits
										DamageType:get(DamageType.LIGHTNING).projector(self, target.x, target.y, DamageType.LIGHTNING, dam)
										if target:canBe("stun") then
											target:setEffect(target.EFF_STUNNED, 5, {apply_power=self:combatSteampower()})
										else
											game.logSeen(target, "%s resists the stun!", target:getName():capitalize())
										end
									end
								end)
								game.logSeen(target, "%s slams into something solid, emitting a pulse of stunning lightning!", target:getName():capitalize())
							end
						end)
					end
				end
			end)
			if core.shader.active(4) then
					game.level.map:particleEmitter(self.x, self.y, tg.radius, "shader_ring", {radius=tg.radius*2, life=8}, {type="sparks"})
				else
					local x, y = self.x, self.y
					-- Lightning ball gets a special treatment to make it look neat
					local sradius = (tg.radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
					local nb_forks = 16
					local angle_diff = 360 / nb_forks
					for i = 0, nb_forks - 1 do
						local a = math.rad(rng.range(0+i*angle_diff,angle_diff+i*angle_diff))
						local tx = x + math.floor(math.cos(a) * tg.radius)
						local ty = y + math.floor(math.sin(a) * tg.radius)
						game.level.map:particleEmitter(x, y, tg.radius, "lightning", {radius=tg.radius, grids=grids, tx=tx-x, ty=ty-y, nb_particles=25, life=8})
					end
			end

			self:removeEffect(self.EFF_HEAVY_AMMUNITION)
			self:forceUseTalent(self.T_HW_SHOCKSTAFF, {ignore_energy=true})
			game:playSoundNear(self, "talents/lightning")
			if not self.energy.used then self:useEnergy() end
			return true
		elseif self:isTalentActive(self.T_HW_BOLTGUN) then 	
			local damage = t.getBoltDamage(self,t)
			local targets = self:archeryAcquireTargets({type="beam"}, {one_shot=true})
			if not targets then return end
			self:archeryShoot(targets, t, {type="beam"}, {mult=t.getBoltDamage(self,t), damtype=DamageType.DEBILITATING_ACID})
			self:removeEffect(self.EFF_HEAVY_AMMUNITION)		
			self:forceUseTalent(self.T_HW_BOLTGUN, {ignore_energy=true})
			return true
		end
	end),
	info = function(self, t)
		local frange = t.getFlamethrowerRange(self,t)
		local fdam = t.getFlamethrowerDamage(self,t)
		local fburn = t.getFlamethrowerBurn(self,t)
		local sdam = t.getShockDamage(self,t)
		local srad = t.getShockRadius(self,t)
		local sknockback = t.getShockKnockback(self,t)
		local spulse = t.getShockPulseDamage(self,t)
		local bdam = t.getBoltDamage(self,t)
		local binc = t.getBoltDamageIncrease(self,t)
		local bdur = t.getBoltDuration(self,t)
		return ([[Push your heavy weapon beyond its normal limits to trigger a powerful effect. This will immediately disable your heavy weapon and expends all remaining ammunition.
#AQUAMARINE#Flamethrower#LAST#: Detonate your fuel tanks, creating a radius 4 explosion that launches you to a chosen tile in range %d. Enemies caught within the explosion take %0.2f fire damage, and further fire damage equal to %d%% of their current burning damage from the volatile fuel.
#AQUAMARINE#Shockstaff#LAST#: Drive your staff into the ground, discharging all remaining power to deal %d%% shockstaff damage as lightning in radius %d. Those struck will be knocked back %d tiles, and if they strike a wall they will emit a static pulse dealing %0.2f lightning damage in radius 1 and stunning them for 5 turns.
#AQUAMARINE#Boltgun#LAST#: Overcharge your boltgun, firing a single deadly bolt dealing %d%% steamgun damage as acid in a piercing line. For each negative physical, magical, or mental effect on the target, they take an additional %d%% damage (to a maximum of %d%%) and the duration of each negative effect is increased by %d turns.]]):
		tformat(frange, damDesc(self, DamageType.FIRE, fdam), fburn*100, sdam*100, srad, sknockback, damDesc(self, DamageType.LIGHTNING, spulse), bdam*100, binc, binc*5, bdur)
	end,
}
