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

local Object = require "engine.Object"

function cancelSapper(self)
	local todel = {}
	for tid, p in pairs(self.sustain_talents) do
		local t = self:getTalentFromId(tid)
		if t.sapper then
			todel[#todel+1] = tid
		end
	end
	while #todel > 0 do self:forceUseTalent(rng.tableRemove(todel), {ignore_energy=true}) end
end

function grenadeTarget(self, t)
	local tgt = self.ai_target.actor
	local tg = {type="hit", selffire=false}
	if tgt then	tg.x, tg.y = tgt.x, tgt.y end
	return tg
end

newTalent{
	name = "Grenade Launcher",
	type = {"steamtech/demolition", 1},
	points = 5,
	require = dex_steamreq1,
	mode = "passive",
	cooldown = 9,
	range = steamgun_range,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2.6)) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.6, 1.6) end,
	target = function(self, t)
		local weapon, ammo = self:hasArcheryWeapon()
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), friendlyfire=false, display=self:archeryDefaultProjectileVisual(weapon, ammo)}
	end,
	callbackOnArcheryAttack = function(self, t, target, hitted, crit, weapon, ammo, damtype, mult, dam, talent)
		if (not self:isTalentCoolingDown(t) or self:hasEffect(self.EFF_GRENADE_BARRAGE)) and (talent.id == self.T_SHOOT or talent.id == self.T_FLAME_JET or talent.id == self.T_STORMSTRIKE or talent.id == self.T_FLECHETTE_BURST) then
			local tg = self:getTalentTarget(t)
			local targets = self:archeryAcquireTargets(tg, {no_sound=true, one_shot=true, infinite=true, no_energy=true, x=target.x, y=target.y})
			if not targets then return end
			
			local dam = t.getDamage(self,t)
			local eff = self:hasEffect(self.EFF_GRENADE_BARRAGE)
			
			if self:hasEffect(self.EFF_GRENADE_BARRAGE) then
				dam = dam / 2
				local effect = rng.range(1, 3)
				if not self:knowTalent(self.T_SAPPER) then effect = 4 end
				if effect==1 then
					self:archeryShoot(targets, t, tg, {mult=dam, damtype=DamageType.INCENDIARY_GRENADE})
				elseif effect==2 then
					self:archeryShoot(targets, t, tg, {mult=dam, damtype=DamageType.CHEMICAL_GRENADE})
				elseif effect==3 then
					self:archeryShoot(targets, t, tg, {mult=dam, damtype=DamageType.SHOCK_GRENADE})
				else 
					self:archeryShoot(targets, t, tg, {mult=dam})
				end			
				game.level.map:particleEmitter(target.x, target.y, tg.radius, "thunder_grenade", {radius=tg.radius})
				game:playSoundNear(self, "talents/fireflash")
				eff.stacks = eff.stacks - 1
				if eff.stacks <= 0 then self:removeEffect(self.EFF_GRENADE_BARRAGE) end
			else
				if self:isTalentActive(self.T_INCENDIARY_GRENADE) then
					self:archeryShoot(targets, t, tg, {mult=dam, damtype=DamageType.INCENDIARY_GRENADE})
				elseif self:isTalentActive(self.T_CHEMICAL_GRENADE) then
					self:archeryShoot(targets, t, tg, {mult=dam, damtype=DamageType.CHEMICAL_GRENADE})
				elseif self:isTalentActive(self.T_SHOCK_GRENADE) then
					self:archeryShoot(targets, t, tg, {mult=dam, damtype=DamageType.SHOCK_GRENADE})
				else 
					self:archeryShoot(targets, t, tg, {mult=dam})
				end			
				game.level.map:particleEmitter(target.x, target.y, tg.radius, "thunder_grenade", {radius=tg.radius})
				game:playSoundNear(self, "talents/fireflash")
				self:startTalentCooldown(t)
			end
		end
	end,
	info = function(self, t)
		local dam = t.getDamage(self,t)*100
		local rad = self:getTalentRadius(t)
		return ([[You mount a grenade launcher on your steamgun that launches high explosive rounds. Each time you make a basic attack with your steamgun or a heavy weapon, you fire a grenade at the target that explodes for %d%% steamgun damage in radius %d.
		This talent also reinforces the armor of you and your minions to give you immunity to your own grenades.
		You can only fire a single grenade once every 9 turns.]]):
		tformat(dam, rad)
	end,
}

newTalent{
	name = "Reactive Armor",
	type = {"steamtech/demolition", 2},
	points = 5,
	require = dex_steamreq2,
	mode = "passive",
	on_unlearn = function(self, t) if self:hasEffect(self.EFF_REACTIVE_ARMOR) then self:removeEffect(self.EFF_REACTIVE_ARMOR) end end,
	cooldown = function(self, t) return math.max(3, math.floor(10-self:getTalentLevel(t))) end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	getReduction = function(self, t) return math.floor(self:combatTalentLimit(t, 100, 15, 40)) end,	
	getMult = function(self, t) return 25 end,	
	callbackOnActBase = function(self, t)
		local eff = self:hasEffect(self.EFF_REACTIVE_ARMOR)
		if eff and eff.stacks == 3 then return end
		if not self:isTalentCoolingDown(t) then
			self:setEffect(self.EFF_REACTIVE_ARMOR, 1 ,{src=self, reduce=t.getReduction(self,t), dam=t.getMult(self,t)*self:callTalent(self.T_GRENADE_LAUNCHER,"getDamage")/100, rad=self:getTalentRadius(t), stacks=1, max_stacks=3})
			self:startTalentCooldown(t)
		end
	end,
	callbackOnBlock = function(self, t, eff, dam, type, src, blocked)
		if self.turn_procs.reactive_armor_counterattack then return end
		if not src then return end
		if not src or src==self or src:attr("dead") or self:reactionToward(src) >= 0 then return end
		if src:getEntityKind(src) ~= "actor" then return end -- Don't try to hit traps and such
		if not src.x or not src.y then return end
		self.turn_procs.reactive_armor_counterattack = true	
		self.in_reactive_armor = true
		local t = self:getTalentFromId(self.T_REACTIVE_ARMOR)
		local tg = {type="cone", cone_angle=25, range=10, radius=self:getTalentRadius(t), friendlyfire=false}
		local targets = self:archeryAcquireTargets(tg, {one_shot=true, infinite=true, no_energy=true, x=src.x, y=src.y})
		if targets then
			self:archeryShoot(targets, t, tg, {mult=t.getMult(self,t)*self:callTalent(self.T_GRENADE_LAUNCHER,"getDamage")/100, phasing = true})
		end		
		self.in_reactive_armor = false
	end,
	info = function(self, t)
		local reduce = t.getReduction(self,t)
		local rad = self:getTalentRadius(t)
		local mult = t.getMult(self,t)		
		local cd = self:getTalentCooldown(t)
		return ([[You line your armor with explosive plating that detonates when struck. On taking a melee or ranged hit that deals more than 8%% of your maximum life a plate detonates, reducing the damage taken by %d%% and triggering a basic grenade attack in a radius %d cone projected at the target dealing %d%% of its usual damage.
		This cannot trigger more than once per turn.
		Blocking an attack with your shield will also trigger the retaliation damage, if it has not already triggered this turn.
		You have up to 3 plates at a time, and regain one every %d turns.]]):
		tformat(reduce, rad, mult, cd)
	end,
}

newTalent{
	name = "Sapper",
	type = {"steamtech/demolition", 3},
	points = 5,
	require = dex_steamreq3,
	mode = "passive",
	getFirePower = function(self, t) return math.floor(self:combatTalentLimit(t, 50, 5, 25)) end,	
	getAcidPower = function(self, t) return math.floor(self:combatTalentLimit(t, 50, 10, 30)) end,	
	getLightningPower = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5.5)) end,	
	getTurretPower = function(self, t) return self:combatTalentSteamDamage(t, 20, 300)  end,
	on_learn = function(self, t)
		self:learnTalent(self.T_INCENDIARY_GRENADE, true, nil, {no_unlearn=true})
		self:learnTalent(self.T_CHEMICAL_GRENADE, true, nil, {no_unlearn=true})
		self:learnTalent(self.T_SHOCK_GRENADE, true, nil, {no_unlearn=true})		
	end,
	on_unlearn = function(self, t)
		self:unlearnTalent(self.T_INCENDIARY_GRENADE)
		self:unlearnTalent(self.T_CHEMICAL_GRENADE)
		self:unlearnTalent(self.T_SHOCK_GRENADE)		
	end,
info = function(self, t)
	local ipower=t.getFirePower(self,t)
	local cpower=t.getAcidPower(self,t)
	local spower=t.getLightningPower(self,t)
	local tpower = t.getTurretPower(self,t)
	return ([[You load advanced grenades into your launcher.
	Incendiary Grenade: Deals fire damage over 3 turns, increasing damage taken by %d%%.
	Chemical Grenade: Deals acid damage and slows targets by %d%% for 3 turns.
	Shock Grenade: Deals lightning damage and shocks targets for %d turns, reducing stun and pin resistance by 50%%.
	In addition, your turrets now explode when destroyed, dealing %0.2f physical damage to enemies in radius 3.
	You can only choose a single type of grenade at a time.]]):
	tformat(ipower, cpower, spower, tpower)
end,
}

newTalent{
	name = "Barrage",
	type = {"steamtech/demolition", 4},
	points = 5,
	require = dex_steamreq4,
	cooldown = 12,
	steam = 30,
	getNb = function(self, t) return math.floor(self:combatTalentScale(t, 3, 4.6)) end,
	getSpeed = function(self, t) return math.floor(self:combatTalentLimit(t, 75, 15, 50))/100 end,
	range = 10,
	requires_target = true,
	tactical = { ATTACK = 2 },
	on_pre_use = function(self, t, silent) if not (self:hasArcheryWeapon("steamgun") and self:isTalentCoolingDown(self.T_GRENADE_LAUNCHER)) then if not silent then game.logPlayer(self, "You require a steamgun and an empty grenade launcher for this talent.") end return false end return true end,
	action = function(self, t)
		self:setEffect(self.EFF_GRENADE_BARRAGE, 6, {src=self, power=t.getSpeed(self,t), stacks=t.getNb(self,t)})
		return true
	end,
	info = function(self, t)
		local nb = t.getNb(self,t)
		local speed = t.getSpeed(self,t)*100
		return ([[You load a magazine of %d grenades into your launcher, causing your next %d shots to fire a random grenade type in place of your usual Grenade Launcher, dealing 50%% of the usual grenade damage.
		While the magazine is loaded your attack speed is increased by %d%%.
		Your Grenade Launcher talent must be on cooldown to use this talent, and the magazine will only last for 6 turns.]]):
		tformat(nb, nb, speed)
	end,
}

newTalent{
	name = "Incendiary Grenade",
	type = {"steamtech/other", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
--	target = grenadeTarget,
	tactical = { BUFF = 2 },
--	on_pre_use_ai = poison_on_pre_use_ai,
--	ai_level = function(self, t) return self:getTalentLevelRaw(self.T_VILE_POISONS) end, -- talent level for ai
--	poison_tactics = { disable = {poison = 1.5}, defend = {poison = -0.5}},
--	tactical_imp = poisonTactics,
	no_unlearn_last = true,
	sapper = true,
	getEffect = function(self, t) return self:callTalent(self.T_SAPPER, "getFirePower") end,
	activate = function(self, t)
		cancelSapper(self)
		self.grenades = self.grenades or {}
		self.grenades[t.id] = true
		return {}
	end,
	deactivate = function(self, t, p)
		self.grenades[t.id] = nil
		return true
	end,
	info = function(self, t)
	return ([[Enhance your grenade with an incendiary agent that burns through armor, dealing fire damage over 3 turns and increasing damage taken while burning by %d%%.]]):
	tformat(t.getEffect(self, t))
	end,
}

newTalent{
	name = "Chemical Grenade",
	type = {"steamtech/other", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
--	target = grenadeTarget,
	tactical = { BUFF = 2 },
--	on_pre_use_ai = poison_on_pre_use_ai,
--	ai_level = function(self, t) return self:getTalentLevelRaw(self.T_VILE_POISONS) end, -- talent level for ai
--	poison_tactics = { disable = {poison = 1.5}, defend = {poison = -0.5}},
--	tactical_imp = poisonTactics,
	sapper = true,
	no_unlearn_last = true,
	getEffect = function(self, t) return self:callTalent(self.T_SAPPER, "getAcidPower") end,
	activate = function(self, t)
		cancelSapper(self)
		self.grenades = self.grenades or {}
		self.grenades[t.id] = true
		return {}
	end,
	deactivate = function(self, t, p)
		self.grenades[t.id] = nil
		return true
	end,
	info = function(self, t)
	return ([[Enhance your grenade with incapacitating chemicals that deal acid damage and reduce global speed by %d%% for 3 turns.]]):
	tformat(t.getEffect(self, t))
	end,
}

newTalent{
	name = "Shock Grenade",
	type = {"steamtech/other", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
--	target = grenadeTarget,
	tactical = { BUFF = 2 },
--	on_pre_use_ai = poison_on_pre_use_ai,
--	ai_level = function(self, t) return self:getTalentLevelRaw(self.T_VILE_POISONS) end, -- talent level for ai
--	poison_tactics = { disable = {poison = 1.5}, defend = {poison = -0.5}},
--	tactical_imp = poisonTactics,
	no_unlearn_last = true,
	sapper = true,	
	getEffect = function(self, t) return self:callTalent(self.T_SAPPER, "getLightningPower") end,
	activate = function(self, t)
		cancelSapper(self)
		self.grenades = self.grenades or {}
		self.grenades[t.id] = true
		return {}
	end,
	deactivate = function(self, t, p)
		self.grenades[t.id] = nil
		return true
	end,
	info = function(self, t)
	return ([[Enhance your grenade with an electrical charge, causing it to deal lightning damage and shock targets for %d turns, reducing stun and pin resistance by 50%%.]]):
	tformat(t.getEffect(self, t))
	end,
}
