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
	name = "Steamsaw Mastery",
	type = {"steamtech/butchery", 1},
	points = 5,
	require = { stat = { str=function(level) return 12 + level * 6 end }, },
	mode = "passive",
	getDamage = function(self, t) return 30 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 1.5 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[Increases weapon damage by %d%% and Physical Power by 30 when using steamsaws.]])
		:tformat(inc * 100)
	end,
}

newTalent{
	name = "Overheat Saws",
	type = {"steamtech/butchery",2},
	require = str_steamreq2,
	points = 5,
	drain_steam = 3,
	mode = "sustained",
	no_energy = true,
	tactical = { ATTACK = 2 },
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 20, 120) end,
	on_pre_use = function(self, t, silent) if not self:hasDualWeapon("steamsaw") then if not silent then game.logPlayer(self, "You require two steamsaws for this talent.") end return false end return true end,
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "melee_project", {[DamageType.FIREBURN]=t.getDamage(self, t)})
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Channel hot steam around your saws, burning foes you strike in melee for %0.2f fire damage over 3 turns (which can stack)!
		#{italic}#Hot, steamy maiming!#{normal}#]])
		:tformat(damDesc(self, DamageType.FIRE, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Tempest of Metal",
	type = {"steamtech/butchery",3},
	require = str_steamreq3,
	points = 5,
	drain_steam = 3,
	cooldown = 10,
	mode = "sustained",
	requires_target = true,
	radius = 1,
	tactical = { ATTACKAREA = 2 },
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)} end,
	on_pre_use = function(self, t, silent) if not self:hasDualWeapon("steamsaw") then if not silent then game.logPlayer(self, "You require two steamsaws for this talent.") end return false end return true end,
	callbackOnMeleeAttack = function(self, t, initial_target, hitted, crit, weapon, damtype, mult, dam)
		if not initial_target or not hitted or self.turn_procs.tempest_metal then return end
		self.turn_procs.tempest_metal = true

		local showoff = false
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and self:reactionToward(target) < 0 then
				self:attackTarget(target, nil, 0.3, true)
			end
		end)
		self:addParticles(Particles.new("meleestorm", 1, {img="spinningwinds_red"}))
		self:addParticles(Particles.new("meleestorm", 1, {img="spinningwinds_red"}))
	end,
	getEvasion = function(self, t)
		return math.min(self:combatTalentSteamDamage(t, 5, 190) / 10 + 5, 30)
	end,
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "cancel_damage_chance", t.getEvasion(self, t))
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Continuously swing your steamsaws around you, dealing %d%% weapon damage to adjacent foes each time you attack.
		Your chaotic motions make it difficult for anything to hit you, granting %d%% chance to completely negate all damage.
		Damage avoidance chance increases with Steampower.
		#{italic}#Make the metal talk!#{normal}#]])
		:tformat(30, t.getEvasion(self, t))
	end,
}

newTalent{
	name = "Overcharge Saws",
	type = {"steamtech/butchery", 4},
	points = 5,
	cooldown = 15,
	steam = 20,
	require = str_steamreq4,
	requires_target = true,
	tactical = { BUFF=2 },
	no_energy = true,
	getDur = function(self, t) return math.floor(self:combatTalentLimit(t, 20, 3, 9)) end,
	getPower = function(self, t) return math.floor(self:combatTalentLimit(t, 50, 26, 36)) end,
	on_pre_use = function(self, t, silent) if not self:hasDualWeapon("steamsaw") then if not silent then game.logPlayer(self, "You require two steamsaws for this talent.") end return false end return true end,
	action = function(self, t)
		self:setEffect(self.EFF_OVERCHARGE_SAWS, t.getDur(self, t), {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[You temporarily overcharge the saw motors, increasing the effective talent level of all saw talents by %d%% for %d turns.
		#{italic}#The pain shall never stop!#{normal}#]])
		:tformat(t.getPower(self, t), t.getDur(self, t))
	end,
}
