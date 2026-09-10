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
	name = "Obliterating Smash",
	type = {"corruption/wrath", 1},
	require = str_corrs_req_high1,
	points = 5,
	cooldown = 18,
	stamina = 24,
	vim = 24,
	tactical = { ATTACKAREA = {weapon=2 }, },
	requires_target = true,
	range = function(self, t) return 3 + math.ceil((self.is_destroyer or 0)/4)	end,
	getDamage = function (self, t) return self:combatTalentWeaponDamage(t, 0.3, 1.79) end,
	getSunder = function(self, t) return math.ceil(self:combatTalentScale(t, 10, 20)) end,
	on_pre_use = function(self, t, silent) if not (self:hasTwoHandedWeapon() or self:attr("obliterating_smash_wall")) then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	action = function(self, t)
		local tg = {type="cone", nolock=true, can_autoaccept=true, range=0, radius=self:getTalentRange(t), cone_angle = 179}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self.turn_procs.auto_melee_hit = true
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if self:attr("obliterating_smash_wall") then
				self:project({type="ball", range=10, radius=0, friendlyfire=true}, px, py, DamageType.DIG, 1)
			end
			if not target then return end
			self:attackTarget(target, nil, t.getDamage(self, t), true)
			if self:getTalentLevel(t) > 5 then
				target:setEffect(target.EFF_SUNDER_ARMOUR, 5, {apply_power=self:combatPhysicalpower(),src=self, power= t.getSunder(self, t)})
			end
		end)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "obliterating_smash", {radius=tg.radius, tx=x-self.x, ty=y-self.y, allow=core.shader.allow("distort")})
		self.turn_procs.auto_melee_hit = nil
		return true
	end,
	info = function(self, t)
		return ([[Swing your weapon with incredible force, striking all enemies in a radius %d semicircle, dealing %d%% weapon damage to all targets.
		Starting from talent level 5, all targets hit will have their armour and saves reduced by %d.
		This attack can not miss.]]):
		tformat(self:getTalentRange(t), 100 * t.getDamage(self, t), t.getSunder(self, t))
	end,
}

newTalent{
	name = "Detonating Charge",
	type = {"corruption/wrath", 2},
	require = str_corrs_req_high2,
	points = 5,
	random_ego = "attack",
	stamina = 24,
	vim = 18,
	cooldown = 12,
	tactical = { ATTACKAREA = { weapon = 1,	FIRE = 1 }, CLOSEIN = 3 },
	requires_target = true,
	getMainHit = function (self, t) return self:combatTalentWeaponDamage(t, 0.5, 1.9) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 190) end,
	range = function(self, t) return  math.ceil(self:combatTalentScale(t, 4, 8.5)) end,
	fireRadius = function(self, t) return math.ceil(self:combatTalentScale(t, 1, 4)) end,
--	fireDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 3, 5)) end,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() or self:attr("never_move") then if not silent then game.logPlayer(self, "You require a two handed weapon and being able to move to use this talent.") end return false end return true end,
	on_pre_use = function(self, t) return not self:attr("never_move") end,
	action = function(self, t)
		if self:attr("never_move") then game.logPlayer(self, "You can not do that currently.") return end
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

		local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
		local l = self:lineFOV(x, y, block_actor)
		local lx, ly, is_corner_blocked = l:step()
		if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then
			game.logPlayer(self, "You are too close to build up momentum!")
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
		
		local did_crit=self:spellCrit(1)

		-- Attack ?
		if core.fov.distance(self.x, self.y, x, y) == 1 then
			if self:attackTarget(target, nil, t.getMainHit(self,t), true) then
				target:attr("knockback_immune", 1)
				local blast = {type="ball", range=0, radius=3, friendlyfire=false} --radius=self:spellCrit(t.fireRadius(self,t))
				local grids = self:project(blast, self.x, self.y, DamageType.FIREKNOCKBACK, {dist=t.fireRadius(self,t), dam= did_crit * (t.getDamage(self, t))})
				if core.shader.active(4) then
					game.level.map:particleEmitter(self.x, self.y, blast.radius, "detonating_charge", {radius=blast.radius})
				else
					game.level.map:particleEmitter(self.x, self.y, blast.radius, "ball_fire", {radius=blast.radius})
				end
				game:playSoundNear(self, "talents/fire")
				target:attr("knockback_immune", -1)
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Launch yourself toward a target. If the target is reached you get a free attack doing %d%% weapon damage.
		If the attack hits you release a massive burst of fire in radius %d, knocking away all enemies except your target and dealing %d damage.
		You must charge from at least 2 tiles away.]]):tformat(t.getMainHit(self,t) * 100, t.fireRadius(self,t), t.getDamage(self, t))
	end,
}

newTalent{
	name = "Voracious Blade",
	type = {"corruption/wrath", 3},
	require = str_corrs_req_high3,
	points = 5,
	mode = "passive",
	cooldown = 10,
	hotkey=true,
	vimBonus = function(self, t) return math.ceil(self:combatTalentScale(t, 1, 4, 0.75)) end,
	getMult = function(self, t) return math.ceil(self:combatTalentScale(t, 15, 30, 0.75)) end,
	getHits = function(self, t) return 1 + math.floor(self:combatTalentScale(t, 1, 2.8, 0.75)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "vim_on_death", t.vimBonus(self, t))
	end,
	callbackOnKill = function(self, t, target)
		if not self:isTalentCoolingDown(t) and self:reactionToward(target) < 0 then
			self:startTalentCooldown(t)
			game:onTickEnd(function() self:setEffect(self.EFF_VORACIOUS_BLADE, 6, {power=t.getMult(self, t), hits=t.getHits(self, t)}) end)
		end
		return true
	end,
	info = function(self, t)
		return ([[Your blade drinks in death. Whenever you score a kill with this talent off cooldown, your next %d melee attacks within 6 turns will always critically strike, and you gain %d%% critical multiplier for the duration.
		Additionally, you gain an extra %d vim per kill.]]):tformat(t.getHits(self, t), t.getMult(self, t), t.vimBonus(self, t))
	end,
}

newTalent{
	name = "Destroyer",
	type = {"corruption/wrath", 4},
	require = str_corrs_req_high4,
	points = 5,
	range=10,
	cooldown = 30,
	vim = 38,
	--no_npc_use = true,
	no_energy=true,
	tactical = { BUFF = 3 },
	getDuration = function(self, t) return  math.floor(self:combatTalentScale(t, 4, 7)) end,
	getDestroy = function(self, t) return  util.bound(self:getTalentLevelRaw(t), 1, 5) end,
	getPower = function(self, t) return 5 + math.ceil(self:combatTalentSpellDamage(t, 6, 30)) end,
	action = function(self, t)
		self:setEffect(self.EFF_DESTROYER_FORM, t.getDuration(self, t), {power=t.getPower(self, t), destroyer_level = t.getDestroy(self, t)})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local dest = t.getDestroy(self, t)
		return ([[Your body overflows with the power of the Fearscape, turning you into a powerful demon for %d turns. This increases your stamina regen and physical power by %d, and your disarm and stun immunity by %d%%.
		The physical power, stamina regen, and status resistances increase with your spellpower.
		Your other talents also gain a variety of bonuses:
		-Draining Assault: Reduces cooldown by %d.
		-Reckless Strike: Gain %d%% resistance penetration for all elements for %d turns.
		-Obliterating Smash: Increases range by %d.
		-Abduction: If it hits, get an additional %d attacks at 35%% weapon damage.
		-Incinerating Blows: Increases chance of bonus damage to %d%%.
		-Fearfeast: Gain %0.1f vim per stack.
		-Maw of Urh'rok: Increases cone width by %d degrees.]]):
		tformat(
			t.getDuration(self, t),
			t.getPower(self, t),
			math.min(math.ceil(t.getPower(self, t)/40 *100),100),
			math.ceil(dest/3),
			10 * dest, 3 + math.ceil(dest/2),
			math.ceil(dest/4),
			math.ceil(dest/2),
			25 + 10 * dest,
			dest * 0.4,
			dest * 10
		)
	end,
}