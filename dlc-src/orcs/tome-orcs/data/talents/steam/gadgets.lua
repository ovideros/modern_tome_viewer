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

newTalent{
	name = "Autoloader",
	type = {"steamtech/gadgets", 1},
	points = 5,
	require = steamreq1,
	mode = "passive",
	autolearn_talent = "T_SHOOT",
	getChance = function(self, t) return math.floor(self:combatTalentLimit(t, 100, 25, 75)) end,
	getReload = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3)) end,
	getDamage = function(self, t) return 30 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 1.5 end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p,"archery_pass_friendly", 1)
	end,
	callbackOnArcheryAttack = function(self, t, target, hitted, crit, weapon, ammo, damtype, mult, dam, talent)
		if (talent and talent.heavy_weapon) or not self:knowTalent(self.T_HEAVY_WEAPONS) then return end
		if not rng.percent(t.getChance(self, t)) then return end
		if self:isTalentActive(self.T_HW_FLAMETHROWER) or self:isTalentActive(self.T_HW_SHOCKSTAFF) or self:isTalentActive(self.T_HW_BOLTGUN) then return end
		self:setEffect(self.EFF_HEAVY_AMMUNITION, 1, {stacks=1, max_stacks=self:callTalent(self.T_HEAVY_WEAPONS, "getNb")})
	end,
	callbackOnTalentPost = function(self, t, ab, ret)
		if ab.id == self.T_BLOCK and ret == true and self:knowTalent(self.T_HEAVY_WEAPONS) then
			self:setEffect(self.EFF_HEAVY_AMMUNITION, 1, {stacks=1, max_stacks=self:callTalent(self.T_HEAVY_WEAPONS, "getNb")})
		end
		local weapon, ammo, offweapon = self:hasArcheryWeapon()
		if weapon and ammo and not ammo.infinite and ab.heavy_weapon == true and ret == true then
			ammo.combat.shots_left = math.min(ammo.combat.shots_left + t.getReload(self, t), ammo.combat.capacity)
			return true
		else 
			return 
		end
	end,
	info = function(self, t)
		local chance = t.getChance(self,t)
		local ammo = t.getReload(self,t)
		local dam = t.getDamage(self,t)
		local perc = t.getPercentInc(self,t)*100
		return ([[You link your weapons and shield to your steam generators, using them to load ammunition and improve the power of your weapons. 
		Each time you fire your Steamgun, you have a %d%% chance to reload 1 Heavy Weapon ammo.
		Each time you fire a Heavy Weapon you reload %d ammo.
		Each time you raise your shield to block, you reload 1 Heavy Weapon ammo.
		This also increases weapon damage by %d%% and Physical Power by 30 when using steamguns or heavy weapons.
		In addition, your steamgun and heavy weapon shots now bypass friendly targets harmlessly.]]):
		tformat(chance, ammo, perc)
	end,
}

newTalent{
	name = "Exoskeleton",
	type = {"steamtech/gadgets", 2},
	points = 5,
	require = steamreq2,
	mode = "sustained",
	drain_steam = 3,
	cooldown = 25,
	no_energy = true,
	no_sustain_autoreset = true,
	tactical = { DEFEND = 2 },
	getMaxDamage = function(self, t)
		return math.ceil(self:combatTalentSteamDamage(t, 30, 400))
	end,
	getSteamHeal = function(self, t)
		return self:combatTalentScale(t, 100, 250)
	end,
	iconOverlay = function(self, t, p)
		local val = (self.exoskeleton_absorb or 0)
		if val <= 0 then return "" end
		local fnt = "buff_font_small"
		if val >= 1000 then fnt = "buff_font_smaller" end
		return tostring(math.ceil(val)), fnt
	end,
	callbackOnTalentPost = function(self, t, ab, ret)
		if ab.type[1]:find("^steamtech/") and self.exoskeleton_absorb and ab.steam then
			local maxDamage = t.getMaxDamage(self, t)		
			local heal = util.getval(ab.steam, self, t) * t.getSteamHeal(self,t)/100
			self.exoskeleton_absorb = math.min((self.exoskeleton_absorb or 0) + heal, maxDamage)
		return true
		else return end
	end,
	activate = function(self, t)
		local ret = {}

		game:playSoundNear(self, "talents/lightning")
		self.exoskeleton_absorb = t.getMaxDamage(self,t)

		self.using_steam_exoskeleton = true
		self:updateModdableTile()

		return ret
	end,
	deactivate = function(self, t, p)
		self.using_steam_exoskeleton = nil
		self:updateModdableTile()

		self.exoskeleton_absorb = nil
		return true
	end,
	callbackOnHit = function(self, t, cb, src)
		if self:isTalentActive(self.T_EXOSKELETON) then
			local damageReduction = math.min(cb.value * 0.5, self.exoskeleton_absorb)
			cb.value = cb.value - damageReduction
			local exoReduction = damageReduction
			self.exoskeleton_absorb = math.max(0, self.exoskeleton_absorb - exoReduction )
			game:delayedLogDamage(src or self, self, 0, ("#STEEL_BLUE#(%d exoskeleton)#LAST#"):tformat(damageReduction), nil)
		end
		return cb.value
	end,
	callbackOnActBase = function(self,t)
		if self:isTalentActive(self.T_EXOSKELETON) then

			local maxDamage = t.getMaxDamage(self, t)

			if (self.exoskeleton_absorb or 0) > maxDamage then
				self.exoskeleton_absorb = maxDamage
			end
			if (self.exoskeleton_absorb or 0) < maxDamage then
				self.exoskeleton_absorb = math.min((self.exoskeleton_absorb or 0) + (maxDamage * 0.05), maxDamage)
			end
		end
	end,
	info = function(self, t)
		return ([[Current exoskeleton life: %d/%d
		You craft a set of steam powered armor that fits over your regular armor, enhancing your defense. The armor has %d life, and 50%% of all damage taken is redirected to it.
		Your powered armour repairs 5%% of it’s maximum life each turn, and each time you spend steam it will be repaired for %d%% of the steam cost.
		The armor's maximum life will increase with your Steampower.]]):tformat((self.exoskeleton_absorb or 0),t.getMaxDamage(self,t),t.getMaxDamage(self,t), t.getSteamHeal(self,t))
	end,
}

newTalent{
	name = "Hypervision Goggles",
	type = {"steamtech/gadgets", 3},
	require = steamreq3,
	points = 5,
	steam = 15,
	random_ego = "utility",
	cooldown = 20,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 10, 25)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	getPower = function(self, t) return math.floor(self:combatTalentLimit(t, 100, 15, 50)) end,
	getDetection = function(self, t) return math.floor(self:combatTalentLimit(t, 80, 10, 40)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "see_invisible", t.getDetection(self, t))
		self:talentTemporaryValue(p, "see_stealth", t.getDetection(self, t))
		self:talentTemporaryValue(p, "see_traps", t.getDetection(self, t))
	end,
	action = function(self, t)
		local rad = self:getTalentRadius(t)
		self:setEffect(self.EFF_HYPERVISION_GOGGLES, t.getDuration(self, t), {
			range = rad,
			actor = 1,
			power = t.getPower(self,t)
		})
		return true
	end,
	info = function(self, t)
		local dur = t.getDuration(self,t)
		local rad = self:getTalentRadius(t)
		local power = t.getPower(self,t)
		local detect = t.getDetection(self,t)
		return ([[Enhance your vision for %d turns, giving you vision of all targets in range %d, even through walls. While the goggles are active you also spot flaws in your opponent's defenses, increasing your resistance penetration by %d%%.
In addition, the goggles passively increase your stealth, invisibility and trap detection by %d.]]):tformat(dur, rad, power, detect)
	end,
}

newTalent{
	name = "AED",
	type = {"steamtech/gadgets", 4},
	require = steamreq4,
	points = 5,
	steam = 25,
	random_ego = "utility",
	cooldown = 30,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 5.6)) end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 30, 320) end,
	getLife = function(self, t) return self:combatTalentSteamDamage(t, 50, 500) end,
	action = function(self, t)
		self:setEffect(self.EFF_AED, 8, {
			life = t.getLife(self,t),
			damage = t.getDamage(self,t),
			rad = self:getTalentRadius(t)
		})
		return true
	end,
	info = function(self, t)
		local rad = self:getTalentRadius(t)
		local life = t.getLife(self,t)
		local dam = t.getDamage(self,t)
		return ([[Prepare a defensive device that stores an electrical charge for 8 turns.
If your life falls below 0 while the AED is active it will activate to shock you back into life, negating the triggering attack, restoring %d life and dealing %0.2f lightning damage in radius %d that dazes affected enemies for 3 turns.
If the AED does not activate, the cooldown is reduced by 15 turns.
The healing and damage will increase with your Steampower.]]):tformat(life, damDesc(self, DamageType.LIGHTNING, dam), rad)
	end,
}