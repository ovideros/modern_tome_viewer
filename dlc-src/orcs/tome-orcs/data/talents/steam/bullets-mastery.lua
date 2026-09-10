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

local hasbulletmastery = function(self)
	return self:hasEffect(self.EFF_ENHANCED_BULLETS_OVERHEAT) or self:hasEffect(self.EFF_ENHANCED_BULLETS_PERCUSIVE) or self:hasEffect(self.EFF_ENHANCED_BULLETS_COMBUSTIVE) or self:hasEffect(self.EFF_ENHANCED_BULLETS_SUPERCHARGE)
end

newTalent{
	name = "Overheat Bullets",
	type = {"steamtech/bullets-mastery", 1},
	points = 5,
	require = steamreq1,
	cooldown = 15,
	steam = 30,
	no_energy = true,
	getTurns = function(self, t) return math.floor(self:combatTalentLimit(t, 15, 3, 8)) end,
	getDam = function(self, t) return self:combatTalentSteamDamage(t, 20, 300) / 2 end,
	range = 10,
	requires_target = true,
	tactical = { BUFF={FIRE=2}},
	on_pre_use = function(self, t, silent) if hasbulletmastery(self) or not self:hasDualArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You must dual wield steamguns for this talent.") end return false end return true end,
	action = function(self, t)
		self:setEffect(self.EFF_ENHANCED_BULLETS_OVERHEAT, t.getTurns(self, t), {kind="overheated", power=t.getDam(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[By sending a stream of hot steam over your bullets you overheat them. For the next %d turns, each bullet will set the target ablaze, making it burn for %0.2f fire damage over 5 turns (most of your shooting talents fire two bullets at once).
		Damage will increase with Steampower.
		Only one bullet enhancement can be used at once.]]):
		tformat(t.getTurns(self, t), damDesc(self, DamageType.FIRE, t.getDam(self, t)))
	end,
}

newTalent{
	name = "Supercharge Bullets",
	type = {"steamtech/bullets-mastery", 2},
	points = 5,
	require = steamreq2,
	cooldown = 15,
	steam = 30,
	no_energy = true,
	getTurns = function(self, t) return math.floor(self:combatTalentLimit(t, 15, 3, 8)) end,
	getPower = function(self, t) return self:combatTalentStatDamage(t, "cun", 5, 45) end,
	range = 10,
	requires_target = true,
	tactical = { ATTACK = 2 },
	on_pre_use = function(self, t, silent) if hasbulletmastery(self) or not self:hasDualArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You must dual wield steamguns for this talent.") end return false end return true end,
	action = function(self, t)
		self:setEffect(self.EFF_ENHANCED_BULLETS_SUPERCHARGE, t.getTurns(self, t), {kind="supercharge", power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[You are able to polish your bullets so well they can go through multiple targets for %d turns.
		This also improves their armour penetration by %d.
		Only one bullet enhancement can be used at once.]]):
		tformat(t.getTurns(self, t), t.getPower(self, t))
	end,
}

newTalent{
	name = "Percussive Bullets",
	type = {"steamtech/bullets-mastery", 3},
	points = 5,
	require = steamreq3,
	cooldown = 15,
	steam = 30,
	no_energy = true,
	range = 10,
	requires_target = true,
	tactical = { ESCAPE = {knockback = 2}, DISABLE={stun = 1.5}},
	getTurns = function(self, t) return math.floor(self:combatTalentLimit(t, 15, 3, 8)) end,
	getKBChance = function(self, t) return self:combatTalentLimit(t, 100, 30, 50) end, --2 hits = 49%/75%
	getStunChance = function(self, t) return self:combatTalentLimit(t, 100, 13, 30) end, --2 hits = 25%/49%
	on_pre_use = function(self, t, silent) if hasbulletmastery(self) or not self:hasDualArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You must dual wield steamguns for this talent.") end return false end return true end,
	action = function(self, t)
		self:setEffect(self.EFF_ENHANCED_BULLETS_PERCUSIVE, t.getTurns(self, t), {kind="percusive", power=t.getKBChance(self, t), stunpower=t.getStunChance(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[You swap your bullets for more massive ones for %d turns.
		When striking a creature, these bullets have a %d%% chance of knocking it back 3 tiles and a %d%% chance of stunning it for 3 turns.
		The chances to knockback and stun increase with your Steampower.
		Only one bullet enhancement can be used at once.]]):
		tformat(t.getTurns(self, t), t.getKBChance(self, t), t.getStunChance(self, t))
	end,
}

newTalent{
	name = "Combustive Bullets",
	type = {"steamtech/bullets-mastery", 4},
	points = 5,
	require = steamreq4,
	cooldown = 15,
	steam = 40,
	no_energy = true,
	getTurns = function(self, t) return math.floor(self:combatTalentLimit(t, 15, 3, 8)) end,
	getDam = function(self, t) return self:combatTalentSteamDamage(t, 20, 250) / 2 end,
	range = 10,
	requires_target = true,
	tactical = { BUFF={FIRE=2}},
	on_pre_use = function(self, t, silent) if hasbulletmastery(self) or not self:hasDualArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You must dual wield steamguns for this talent.") end return false end return true end,
	action = function(self, t)
		self:setEffect(self.EFF_ENHANCED_BULLETS_COMBUSTIVE, t.getTurns(self, t), {kind="combustive", power=t.getDam(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[You coat your bullets with flammable materials, for the next %d turns each bullet will explode when it hits its target, dealing %0.2f fire damage to all foes within radius 2 (most of your shooting talents fire two bullets at once).
		Damage will increase with Steampower.
		Only one bullet enhancement can be used at once.]]):
		tformat(t.getTurns(self, t), damDesc(self, DamageType.FIRE, t.getDam(self, t)))
	end,
}
