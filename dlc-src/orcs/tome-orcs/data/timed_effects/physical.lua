-- ToME - Tales of Maj'Eyal:
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

local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "STRAFING", image = "talents/strafe.png",
	desc = _t"Strafing",
	long_desc = function(self, eff) return ("The target is moving while shooting, and will reload %sammo when finished strafing."):tformat(self.player and self:callTalent(self.T_STRAFE, "getReload", eff.turns).." " or "") end,
	type = "physical",
	subtype = { technique=true },
	status = "beneficial",
	parameters = {turns = 0},
	charges = function(self, eff) return self.player and self:callTalent(self.T_STRAFE, "getReload", eff.turns) or "--" end,
	deactivate = function(self, eff)
		self:startTalentCooldown(self.T_STRAFE)

		local weapon, ammo, offweapon = self:hasArcheryWeapon()
		if weapon and ammo and not ammo.infinite then
			local t = self:getTalentFromId(self.T_STRAFE)
			ammo.combat.shots_left = math.min(ammo.combat.shots_left + t.getReload(self, t, eff.turns), ammo.combat.capacity)
			game.logSeen(self, "%s reloads.", self:getName():capitalize())
		end
	end,
}

newEffect{
	name = "STARTLING_SHOT", image = "talents/startling_shot.png",
	desc = _t"Startled",
	long_desc = function(self, eff) return ("The target is startled after being strangely missed by a shot. The next shot it takes will deal %d%% more damage."):tformat(eff.power*100) end,
	type = "physical",
	subtype = { technique=true },
	status = "detrimental",
	parameters = {power=1.2},
}

newEffect{
	name = "IRON_GRIP", image = "talents/iron_grip.png",
	desc = _t"Iron Grip",
	long_desc = function(self, eff) return ("The target has been crushed, pinning it and reducing defense and armour by %d."):tformat(eff.power) end,
	type = "physical",
	subtype = { steamtech=true },
	status = "detrimental",
	on_gain = function(self, err) return _t"#Target# is crushed by the iron grip.", _t"+Iron Grip" end,
	on_lose = function(self, err) return _t"#Target# is free from the iron grip.", _t"-Iron Grip" end,
	parameters = {power=10},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "never_move", 1)
		self:effectTemporaryValue(eff, "combat_def", -eff.power)
		self:effectTemporaryValue(eff, "combat_armor", -eff.power)
	end,
}

newEffect{
	name = "ENHANCED_BULLETS_OVERHEAT", image = "talents/overheat_bullets.png",
	desc = _t"Bullet Mastery: Overheated",
	long_desc = function(self, eff) return ("Bullets shot are overheated:  When striking their target, they set it on fire for %d fire damage over 5 turns"):tformat(self:damDesc(DamageType.FIRE, eff.power)) end,
	type = "physical",
	subtype = { steamtech=true },
	status = "beneficial",
	on_gain = function(self, err) return ("#Target# tweaks some of %s bullets."):tformat(string.his_her(self)), _t"+Bullet Mastery" end,
	parameters = {power = 10},
}
newEffect{
	name = "ENHANCED_BULLETS_SUPERCHARGE", image = "talents/supercharge_bullets.png",
	desc = _t"Bullet Mastery: Supercharged",
	long_desc = function(self, eff) return ("Bullets shot are supercharged:  They can pass through multiple targets and have %d additional armour penetration."):tformat(eff.power) end,
	type = "physical",
	subtype = { steamtech=true },
	status = "beneficial",
	on_gain = function(self, err) return ("#Target# tweaks some of %s bullets."):tformat(string.his_her(self)), _t"+Bullet Mastery" end,
	parameters = {power = 5},
}
newEffect{
	name = "ENHANCED_BULLETS_PERCUSIVE", image = "talents/percussive_bullets.png",
	desc = _t"Bullet Mastery: Percussive",
	long_desc = function(self, eff) return ("Bullets shot are percussive:  When striking, they have a %d%% chance to knock back and a %d%% chance to stun."):tformat(eff.power, eff.stunpower) end,
	type = "physical",
	subtype = { steamtech=true },
	status = "beneficial",
	on_gain = function(self, err) return ("#Target# tweaks some of %s bullets."):tformat(string.his_her(self)), _t"+Bullet Mastery" end,
	parameters = {power=10, stunpower=10},
}
newEffect{
	name = "ENHANCED_BULLETS_COMBUSTIVE", image = "talents/combustive_bullets.png",
	desc = _t"Bullet Mastery: Combustive",
	long_desc = function(self, eff) return ("Bullets shot are combustive:  When striking their target, they explode (radius 2) for %d fire damage."):tformat(self:damDesc(DamageType.FIRE, eff.power)) end,
	type = "physical",
	subtype = { steamtech=true },
	status = "beneficial",
	on_gain = function(self, err) return ("#Target# tweaks some of %s bullets."):tformat(string.his_her(self)), _t"+Bullet Mastery" end,
	parameters = {power = 10},
}

newEffect{
	name = "UNCANNY_RELOAD", image = "talents/uncanny_reload.png",
	desc = _t"Uncanny Reload",
	long_desc = function(self, eff) return ("Firing steamguns does not consume shots."):tformat() end,
	type = "physical",
	subtype = { steamtech=true },
	status = "beneficial",
	on_gain = function(self, err) return _t"#Target# is focuses on firing.", _t"+Uncanny Reload" end,
	on_lose = function(self, err) return _t"#Target# is less focused.", _t"-Uncanny Reload" end,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "infinite_ammo", 1)
	end,
}

newEffect{
	name = "CLOAK", image = "talents/cloak.png",
	desc = _t"Cloak",
	long_desc = function(self, eff) return (_t"The target is wrapped in a cloak of shadow, granting sealth.") end,
	type = "physical",
	subtype = { steamtech=true },
	status = "beneficial",
	on_gain = function(self, err) return _t"#Target# disappears from sight.", _t"+Cloak" end,
	on_lose = function(self, err) return _t"#Target# re-appears.", _t"-Cloak" end,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "stealth", eff.power)
	end,
}

newEffect{
	name = "PAIN_SUPPRESSOR_SALVE", image = "talents/pain_suppressor_salve.png",
	desc = _t"Pain Suppressor Salve",
	long_desc = function(self, eff) return ("Fight to the brink of death, can not die before going under -%d life (but life under 0 is not shown) and increases all resistances by %d%%."):tformat(eff.die_at, eff.resists) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	on_gain = function(self, err) return _t"#Target# uses a pain suppressor salve.", _t"+Pain Suppressor" end,
	on_lose = function(self, err) return _t"#Target# is not affected anymore by the salve.", _t"-Pain Suppressor" end,
	parameters = { power=1 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "die_at", -eff.die_at)
		self:effectTemporaryValue(eff, "resists", {all=eff.resists})
	end,
}

newEffect{
	name = "FROST_SALVE", image = "talents/frost_salve.png",
	desc = _t"Frost Salve",
	long_desc = function(self, eff) return ("Provides a frost aura, giving you +%d%% cold, nature and darkness affinity."):tformat(eff.power) end,
	type = "physical",
	subtype = { frost=true },
	status = "beneficial",
	on_gain = function(self, err) return _t"#Target# uses a frost salve.", _t"+Frost Salve" end,
	on_lose = function(self, err) return _t"#Target# is not affected anymore by the salve.", _t"-Frost Salve" end,
	parameters = { power=1 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "damage_affinity", {
			[DamageType.COLD] = eff.power,
			[DamageType.NATURE] = eff.power,
			[DamageType.DARKNESS] = eff.power,
		})
	end,
}

newEffect{
	name = "FIERY_SALVE", image = "talents/fiery_salve.png",
	desc = _t"Fiery Salve",
	long_desc = function(self, eff) return ("Provides a frost aura, giving you +%d%% fire, light, and lightning affinity."):tformat(eff.power) end,
	type = "physical",
	subtype = { fire=true },
	status = "beneficial",
	on_gain = function(self, err) return _t"#Target# uses a fiery salve.", _t"+Fiery Salve" end,
	on_lose = function(self, err) return _t"#Target# is not affected anymore by the salve.", _t"-Fiery Salve" end,
	parameters = { power=1 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "damage_affinity", {
			[DamageType.FIRE] = eff.power,
			[DamageType.LIGHT] = eff.power,
			[DamageType.LIGHTNING] = eff.power,
		})

		local zones = { ["orcs+sunwall-observatory"]=true, ["orcs+sunwall-outpost"]=true, ["orcs+gates-of-morning"]=true }
		if game.zone and zones[game.zone.short_name or ""] and self.player and eff.power >= 66 then
			world:gainAchievement("ORCS_FIERY_MOCKERY", game.player)
		end
	end,
}

newEffect{
	name = "WATER_SALVE", image = "talents/water_salve.png",
	desc = _t"Water Salve",
	long_desc = function(self, eff) return ("Provides a frost aura, giving you +%d%% blight, mind and acid affinity."):tformat(eff.power) end,
	type = "physical",
	subtype = { water=true },
	status = "beneficial",
	on_gain = function(self, err) return _t"#Target# uses a water salve.", _t"+Water Salve" end,
	on_lose = function(self, err) return _t"#Target# is not affected anymore by the salve.", _t"-Water Salve" end,
	parameters = { power=1 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "damage_affinity", {
			[DamageType.BLIGHT] = eff.power,
			[DamageType.MIND] = eff.power,
			[DamageType.ACID] = eff.power,
		})
	end,
}

newEffect{
	name = "UNSTOPPABLE_FORCE_SALVE", image = "talents/unstoppable_force_salve.png",
	desc = _t"Unstoppable Force Salve",
	long_desc = function(self, eff) return ("Increases all saves by %d and healing factor by %d%%."):tformat(eff.power, eff.power / 2) end,
	type = "physical",
	subtype = { tech=true },
	status = "beneficial",
	on_gain = function(self, err) return _t"#Target# uses an unstoppable force salve.", _t"+Unstoppable Force" end,
	on_lose = function(self, err) return _t"#Target# is not affected anymore by the salve.", _t"-Unstoppable Force" end,
	parameters = { power=1 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physresist", eff.power)
		self:effectTemporaryValue(eff, "combat_spellresist", eff.power)
		self:effectTemporaryValue(eff, "combat_mentalresist", eff.power)
		self:effectTemporaryValue(eff, "healing_factor", eff.power / 2)
	end,
}

newEffect{
	name = "SLOW_TALENT", image = "talents/slow.png",
	desc = _t"Slow Talents",
	long_desc = function(self, eff) return ("Attacking, casting and mind speed have been reduced by %d%%."):tformat(eff.power * 100) end,
	type = "physical",
	subtype = { slow=true },
	status = "detrimental",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physspeed", -eff.power)
		self:effectTemporaryValue(eff, "combat_mindspeed", -eff.power)
		self:effectTemporaryValue(eff, "combat_spellspeed", -eff.power)
	end,
}

newEffect{
	name = "SUPERCHARGE_TINKERS", image = "talents/supercharge_tinkers.png",
	desc = _t"Supercharge Tinkers",
	long_desc = function(self, eff) return ("Increases steampower by %d and steam crit by %d%%."):tformat(eff.power, eff.crit) end,
	type = "physical",
	subtype = { tech=true },
	status = "beneficial",
	on_gain = function(self, err) return _t"#Target# supercharges all tinkers.", _t"+Supercharge Tinkers" end,
	on_lose = function(self, err) return _t"#Target#'s supercharge is fading.", _t"-Supercharge Tinkers" end,
	parameters = { power=10, crit=1 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_steampower", eff.power)
		self:effectTemporaryValue(eff, "combat_steamcrit", eff.crit)
	end,
}

newEffect{
	name = "OVERCHARGE_SAWS", image = "talents/overcharge_saws.png",
	desc = _t"Overcharge Saws",
	long_desc = function(self, eff) return ("Increases all saws talent levels by %d%%."):tformat(eff.power) end,
	type = "physical",
	subtype = { tech=true },
	status = "beneficial",
	on_gain = function(self, err) return _t"#Target# overcharges saw motors.", _t"+Overcharge Saws" end,
	on_lose = function(self, err) return _t"#Target#'s saw motors are back to normal.", _t"-Overcharge Saws" end,
	parameters = { power=20 },
	activate = function(self, eff)
		local tts = {
			["steamtech/butchery"] = eff.power / 100,
			["steamtech/sawmaiming"] = eff.power / 100,
			["steamtech/battlefield-management"] = eff.power / 100,
			["steamtech/automated-butchery"] = eff.power / 100,
		}
		eff.tts = tts
		eff.tmpid = self:addTemporaryValue("talents_types_mastery", tts)

		local list = {}
		for tid, _ in pairs(self.sustain_talents) do
			local t = self:getTalentFromId(tid)
			if tts[t.type[1]] then list[#list+1] = tid end
		end
		for _, tid in ipairs(list) do
			self:forceUseTalent(tid, {silent=true, ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})
			self:forceUseTalent(tid, {silent=true, ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("talents_types_mastery", eff.tmpid)

		local list = {}
		for tid, _ in pairs(self.sustain_talents) do
			local t = self:getTalentFromId(tid)
			if eff.tts[t.type[1]] then list[#list+1] = tid end
		end
		for _, tid in ipairs(list) do
			self:forceUseTalent(tid, {silent=true, ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})
			self:forceUseTalent(tid, {silent=true, ignore_energy=true, ignore_cd=true, no_equilibrium_fail=true, no_paradox_fail=true})
		end
	end,
}

newEffect{
	name = "ALGID_RAGE", image = "talents/algid_rage.png",
	desc = _t"Algid Rage",
	long_desc = function(self, eff) return ("You have %d%% chances to encase your foes in iceblocks."):tformat(eff.power) end,
	type = "physical",
	subtype = { ice=true },
	status = "beneficial",
	callbackOnDealDamage = function(self, eff, value, target, dead, death_node)
		if dead then return end
		if not rng.percent(eff.power) then return end
		target:setEffect(target.EFF_FROZEN, 3, {hp=util.bound(value * 0.7, 30, 300)})
	end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "iceblock_pierce", 50)
	end,
}

local ritchlarva = nil
newEffect{
	name = "RITCH_LARVA_EGGS", image = "talents/ritch_larva_infect.png",
	desc = _t"Larvae Infestation",
	long_desc = function(self, eff)
		local source = eff.src or self
		return ("The target has been impregnated with %d developing ritch larvae which are feeding on it%s.  After a %d turn gestation period, each will burst out violently, dealing %0.2f physical and %0.2f fire damage to its host."):tformat(eff.nb,
		eff.turns < eff.gestation and (" for %0.2f physical damage (increasing) each turn"):tformat(
		source:damDesc("PHYSICAL", TemporaryEffects.tempeffect_def.EFF_RITCH_LARVA_EGGS.gestation_damage(self, eff, eff.turns + 1))) or "",
		eff.gestation, source:damDesc("PHYSICAL", eff.dam/2), source:damDesc("FIRE", eff.dam/2))
	end,
	type = "physical",
	subtype = { disease=true },
	status = "detrimental",
	activate = function(self, eff)
	end,
	parameters = {dam=10, nb=2, gestation=5, turns=0 },
	on_gain = function(self, err) return _t"#Target# is #ORANGE#INFESTED#LAST# with ritch larvae!", _t"+Larvae Infestation" end,
	gestation_damage = function(self, eff, turn)
		return eff.nb*eff.dam*(turn * 0.05)
	end,
	on_timeout = function(self, eff)
		eff.turns = eff.turns + 1
		-- Creepy, so the player tries to get rid of it as soon as possible...
		local source = eff.src or self
		source:project({}, self.x, self.y, DamageType.PHYSICAL, TemporaryEffects.tempeffect_def.EFF_RITCH_LARVA_EGGS.gestation_damage(self, eff, eff.turns))
	end,
	deactivate = function(self, eff)
		local chance, strength = 100, 0
		if eff.dur >= 0 then -- prematurely removed: hatch chance < 100% and larva may be weaker
			chance = math.ceil(self:combatLimit(util.bound(1-eff.turns/eff.gestation, 0, 1), 0, 100, 0, 35, 0.6))
			strength = util.bound(self:combatLimit(util.bound(1-eff.turns/eff.gestation, 0, 1), -1, 0, 0, -.5, 0.6), -1, 0)
		end
		if not ritchlarva then
			local list = mod.class.NPC:loadList("/data-orcs/general/npcs/ritch-extended.lua")
			ritchlarva = list.RITCH_LARVA
		end
		local larva_name = (strength < 0 and _t"developing " or "").._t(ritchlarva.name)
		local source = eff.src or self
		for i = 1, eff.nb do
			if rng.percent(chance) then
				local larva
				source.__project_source = eff
				DamageType:get(DamageType.MOLTENROCK).projector(source, self.x, self.y, DamageType.MOLTENROCK, eff.dam*(1 + strength))
				source.__project_source = nil
				game.level.map:particleEmitter(self.x, self.y, 1, "slime")
				game:playSoundNear(self, "talents/slime")
				local x, y = util.findFreeGrid(self.x, self.y, 2, true, {[Map.ACTOR]=true})
				if x then
					larva = ritchlarva:clone()
					larva.inc_damage.all = (larva.inc_damage.all or 0) + strength*100
					larva.life_rating = larva.life_rating * (1 + strength)
					larva.name = larva_name
					larva.exp_worth = 1 + strength -- The Ritch mothers are annoying enough that this shouldn't be farming issue.
					if game.party:hasMember(eff.src) then
						larva.exp_worth = 0 --For if player has this
					end
					larva.faction = eff.src.faction or "enemies"
					larva:resolve()
					larva:resolve(nil, true)
					game.zone:addEntity(game.level, larva, "actor", x, y)
				end
				game.logSeen(self, "A %s #ORANGE#BURSTS OUT#LAST# of %s%s!", larva_name, self:getName():capitalize(), x and "" or _t" but is crushed")
			end
		end
	end,
}

newEffect{
	name = "TECH_OVERLOAD", image = "talents/tech_overload.png",
	desc = _t"Tech Overload",
	long_desc = function(self, eff) return ("Doubles your maximum steam and stops steam regeneration."):tformat() end,
	type = "physical",
	subtype = { steamtech=true },
	status = "beneficial",
	activate = function(self, eff)
		self:incSteam(self:getMaxSteam() * eff.regen)
		self:effectTemporaryValue(eff, "max_steam", self:getMaxSteam())
		self:effectTemporaryValue(eff, "steam_regen", -self.steam_regen / 2)
	end,
}

newEffect{
	name = "CONTINUOUS_BUTCHERY", image = "talents/continuous_butchery.png",
	desc = _t"Continuous Butchery",
	long_desc = function(self, eff) return ("Increases steamsaw damage multiplier by %d%%."):tformat(eff.power) end,
	type = "physical",
	subtype = { steamtech=true },
	status = "beneficial",
	parameters = {power=20, power_inc=20},
	charges = function(self, eff) return eff.power end,
	callbackOnMeleeAttack = function(self, eff, target, hitted, crit, weapon, damtype, mult, dam)
		if self.turn_procs.continuous_butchery then return end
		if not target or not hitted then return end
		if eff.target ~= target then self:removeEffect(self.EFF_CONTINUOUS_BUTCHERY) return end

		self.turn_procs.continuous_butchery = true

		eff.power = eff.power + eff.power_inc

		self:removeTemporaryValue("steamsaw_dam_mult", eff.tmpid)
		eff.tmpid = self:addTemporaryValue("steamsaw_dam_mult", eff.power)
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("steamsaw_dam_mult", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("steamsaw_dam_mult", eff.tmpid)
	end,
}

newEffect{
	name = "EXPLOSIVE_WOUND", --image = "talents/.png",
	image = "talents/explosive_saw.png",
	desc = _t"Explosive Saw",
	long_desc = function(self, eff) return ("Target is being assailed by an automated saw blade that cuts its flesh for %0.2f physical damage each turn%s. When the effect expires, the saw will explode for %0.2f fire damage and fly back to its source, pulling the target with it (up to %d tiles)."):tformat(eff.power, eff.silence and _t" and silences it" or "", eff.src:damDesc(DamageType.FIRE, eff.power_final), eff.range) end,
	type = "physical",
	subtype = { wound=true, cut=true, bleed=true },
	status = "detrimental",
	parameters = {power=10, range =4},
	charges = function(self, eff) return eff.silence and _t"sil" or "" end,
	on_gain = function(self, eff) return _t"#Target# is assailed by an automated saw blade.", _t"+Explosive Wounds" end,
	on_lose = function(self, eff) return _t"The saw embedded in #Target# flies back its source.", _t"-Explosive Wounds" end,
	activate = function(self, eff)
		if eff.silence then
			self:effectTemporaryValue(eff, "silence", 1)
		end
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.power)
	end,
	deactivate = function(self, eff) -- if it ticked all the way down, apply special removal effects
		if eff.dur >= 0 or not eff.src or eff.src.dead or not eff.src.x or not eff.src.y then return end
		DamageType:get(DamageType.FIRE).projector(eff.src or self, self.x, self.y, DamageType.FIRE, eff.power_final)
		if self:canBe("knockback") then
			self:logCombat(eff.src, "The saw drags #Source# towards #Target#!")
			self:pull(eff.src.x, eff.src.y, eff.range)
		end
	end,
}

newEffect{
	name = "SUBCUTANEOUS_METALLISATION", image = "talents/subcutaneous_metallisation.png",
	desc = _t"Subcutaneous Metallisation",
	long_desc = function(self, eff) return ("All damage reduced by %d."):tformat(eff.power) end,
	type = "physical",
	subtype = { steamtech=true, resistance=true },
	status = "beneficial",
	on_gain = function(self, err) return _t"#Target# internal structure metallises.", _t"+Subcutaneous Metallisation" end,
	on_lose = function(self, err) return _t"#Target# internal structure returns to normal.", _t"-Subcutaneous Metallisation" end,
	parameters = {power=10},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "flat_damage_armor", {all=eff.power})
	end,
}

newEffect{
	name = "PAIN_ENHANCEMENT_SYSTEM", image = "talents/pain_enhancement_system.png",
	desc = _t"Pain Enhancement System",
	long_desc = function(self, eff) return ("All stats increased by %d."):tformat(eff.power) end,
	type = "physical",
	subtype = { steamtech=true, power=true },
	status = "beneficial",
	on_gain = function(self, err) return _t"#Target# revels in the pain.", _t"+Pain Enhancement System" end,
	on_lose = function(self, err) return _t"#Target# no longer feels strong.", _t"-Pain Enhancement System" end,
	parameters = {power=10},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "inc_stats", {
			[Stats.STAT_DEX] = math.floor(eff.power),
			[Stats.STAT_MAG] = math.floor(eff.power),
			[Stats.STAT_WIL] = math.floor(eff.power),
			[Stats.STAT_CUN] = math.floor(eff.power),
			[Stats.STAT_CON] = math.floor(eff.power),
		})
	end,
}

newEffect{
	name = "NET_PROJECTOR", image = "talents/net_projector.png",
	desc = _t"Net Projector",
	long_desc = function(self, eff) return ("The target has been pinned by an electrified net, reducing all resistances by %d%%."):tformat(eff.power) end,
	type = "physical",
	subtype = { steamtech=true, pin=true },
	status = "detrimental",
	on_gain = function(self, err) return _t"#Target# is trapped by the net.", _t"+Net Projector" end,
	on_lose = function(self, err) return _t"#Target# is free from the net.", _t"-Net Projector" end,
	parameters = {power=10},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "never_move", 1)
		self:effectTemporaryValue(eff, "resists", {all=-eff.power})
	end,
}

newEffect{
	name = "FURNACE_MOLTEN_POINT", image = "talents/molten_metal.png",
	desc = _t"Molten Point",
	long_desc = function(self, eff) return ("You have %d charges."):tformat(eff.stacks) end,
	type = "other",
	decrease = 0, no_player_remove = true,
	subtype = { fire=true },
	status = "beneficial",
	parameters = { stacks=1, max_stacks=10 },
	charges = function(self, eff) return eff.stacks end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.stacks = util.bound(old_eff.stacks + 1, 1, new_eff.max_stacks)
		return old_eff
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "PRESSURE_SUIT", image = "talents/elemental_surge.png",
	desc = _t"Pressure-enhanced Slashproof Combat Suit",
	long_desc = function(self, eff) return ("When hit the suit's motors displace you quickly, ignoring the blow.") end,
	type = "physical",
	subtype = { steam=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "phase_shift", 1)
	end,
}

newEffect{
	name = "MOLTEN_IRON_BLOOD", image = "talents/molten_iron_blood.png",
	desc = _t"Molten Iron Blood",
	long_desc = function(self, eff) return ("All resistances increased by %d%%, all new detrimental effects reduced by %d%%, %0.2f fire splash damage."):tformat(eff.resists, eff.reduction, eff.dam) end,
	type = "physical",
	subtype = { steamtech=true, psionic=true, fire=true, resistance=true },
	status = "beneficial",
	on_gain = function(self, err) return _t"#Target#'s blood turn into molten iron.", true end,
	on_lose = function(self, err) return _t"#Target# no longer has molten iron blood.", true end,
	parameters = {dam=10, resists=10, reduction=10},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "on_melee_hit", {[DamageType.FIRE] = eff.dam})
		self:effectTemporaryValue(eff, "resists", {all=eff.resists})
		self:effectTemporaryValue(eff, "reduce_detrimental_status_effects_time", eff.reduction)
	end,
}

newEffect{
	name = "SEARED",
	desc = _t"Seared",
	long_desc = function(self, eff) return ("Fire resistance decreased by %d%% and mind save by %d."):tformat(eff.power, eff.power) end,
	type = "physical",
	subtype = { psionic=true, fire=true },
	status = "detrimental",
	on_gain = function(self, err) return _t"#Target# is seared.", true end,
	on_lose = function(self, err) return _t"#Target# is no longer seared.", true end,
	parameters = {power=10},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.FIRE] = -eff.power})
		self:effectTemporaryValue(eff, "combat_mentalresist", -eff.power)
	end,
}

newEffect{
	name = "AWESOME_TOSS", image = "talents/awesome_toss.png",
	desc = _t"Awesome Toss",
	long_desc = function(self, eff) return ("All resistances increased by %d%%, randomly attacks two foes each turn at random."):tformat(eff.resist, eff.dam) end,
	type = "physical",
	cancel_on_level_change = true,
	subtype = { steamtech=true, awesome=true, resistance=true },
	status = "beneficial",
	on_gain = function(self, err) return _t"#Target# tosses steamguns in the air, awesome!", true end,
	on_lose = function(self, err) return _t"#Target# somehow catches the falling steamguns.", true end,
	parameters = {dam=10, resist=10},
	callbackOnActBase = function(self, eff)
		self.disarmed = self.disarmed - 1
		local weapon, ammo, offweapon = self:hasDualArcheryWeapon("steamgun")
		self.disarmed = self.disarmed + 1
		local realweapon = weapon
		weapon = weapon and weapon.combat
		local realoffweapon = offweapon
		offweapon = offweapon and offweapon.combat
		if not weapon or not offweapon then return end

		self.disarmed = self.disarmed - 1

		local targets = {main={}, off={}, dual=true}
		local function run(weapon, where)
			local range = weapon.range or 6
			local tgts = {}
			self:project({type="ball", radius=range, start_x=eff.x, start_y=eff.y}, eff.x, eff.y, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if not target or self:reactionToward(target) >= 0 then return end
				tgts[#tgts+1] = target
			end)
			if #tgts == 0 then return end

			local target = rng.table(tgts)
			where[#where+1] = {x=target.x, y=target.y, ammo=ammo.combat}
		end
		run(weapon, targets.main)
		run(offweapon, targets.off)

		if #targets.main > 0 or #targets.off > 0 then
			local sound = weapon.sound
			if sound then game:playSoundNear(self, sound) end
			self:archeryShoot(targets, self:getTalentFromId(self.T_AWESOME_TOSS), {start_x=eff.x, start_y=eff.y}, {mult=eff.dam})
		end

		self.disarmed = self.disarmed + 1
	end,
	activate = function(self, eff)
		eff.x, eff.y = self.x, self.y
		self:effectTemporaryValue(eff, "resists", {all=eff.resist})
		self:effectTemporaryValue(eff, "disarmed", 1)
	
		eff.p1 = game.level.map:particleEmitter(eff.x, eff.y, 2, "vapour_spin", {radius=1, smoke="particles_images/smoke_whispery_bright"})
		eff.p2 = game.level.map:particleEmitter(eff.x, eff.y, 2, "vapour_spin", {radius=1, smoke="particles_images/smoke_heavy_bright"})
		eff.p3 = game.level.map:particleEmitter(eff.x, eff.y, 2, "vapour_spin", {radius=1, smoke="particles_images/smoke_dark"})
		eff.p4 = game.level.map:particleEmitter(eff.x, eff.y, 2, "steamgun_spin", {})
	end,
	deactivate = function(self, eff)
		if eff.p1 then game.level.map:removeParticleEmitter(eff.p1) end
		if eff.p2 then game.level.map:removeParticleEmitter(eff.p2) end
		if eff.p3 then game.level.map:removeParticleEmitter(eff.p3) end
		if eff.p4 then game.level.map:removeParticleEmitter(eff.p4) end
	end,
}

newEffect{
	name = "MARKED_LONGARM", image = "talents/snap.png",
	desc = _t"Marked for Death",
	long_desc = function(self, eff) return ("Ranged defense reduced by %d, takes %d%% extra damage from all sources."):tformat(eff.def, eff.dam) end,
	type = "physical",
	subtype = { steam=true },
	status = "detrimental",
	parameters = { def=10, dam = 10 },
	on_gain = function(self, err) return _t"#Target# is marked!", _t"+Marked for Death" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_def_ranged", -eff.def)
		self:effectTemporaryValue(eff, "resists", {all = -eff.dam})
	end,
}

newEffect{
	name = "ITCHING_POWDER", image = "talents/slippery_moss.png",
	desc = _t"Itching Powder",
	long_desc = function(self, eff) return ("The target is very itchy, causing their actions to fail."):tformat() end,
	type = "physical",
	subtype = { powder=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return _t"#Target# is very itching!", _t"+Itching Powder" end,
	on_lose = function(self, err) return _t"#Target# regains their concentration.", _t"-Itching Powder" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("talent_fail_chance", eff.chance)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("talent_fail_chance", eff.tmpid)
	end,
}

newEffect{
	name = "SMOKE_COVER", image = "talents/blinding_ink.png",
	desc = _t"Smoke Cover",
	long_desc = function(self, eff) return ("%d%% chance to fully absorb any damaging actions, %d stealth value."):tformat(eff.power, eff.stealth) end,
	type = "physical",
	subtype = { steamtech=true },
	status = "beneficial",
	parameters = { power=10, stealth=10 },
	on_gain = function(self, err) return _t"#Target# is hiding in smoke.", _t"+Smoke Cover" end,
	on_lose = function(self, err) return _t"#Target# is no longer hiding in smoke.", _t"-Smoke Cover" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "cancel_damage_chance", eff.power)
		self:effectTemporaryValue(eff, "stealth", eff.stealth)
	end,
}

newEffect{
	name = "MAGNETISED", image = "talents/tinker_magnetic_shell.png",
	desc = _t"Magnetised",
	long_desc = function(self, eff) return ("The target has been magnetised, reducing defense by %d and increasing fatigue by %d."):tformat(eff.power, eff.power) end,
	type = "physical",
	subtype = { steamtech=true },
	status = "detrimental",
	on_gain = function(self, err) return _t"#Target# is magnetised.", _t"+Magnetised" end,
	on_lose = function(self, err) return _t"#Target# is free from the magnetism.", _t"-Magnetised" end,
	parameters = {power=10},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_def", -eff.power)
		self:effectTemporaryValue(eff, "fatigue", eff.power)
		-- Worth adding projectile evasion/normal evasion reduction to this?
	end,
}

newEffect{
	name = "BLOODSTAR", image = "talents/bloodstar.png",
	desc = _t"Bloodstar",
	long_desc = function(self, eff) return ("Continuously drain blood, dealing %0.2f physical damage per turn and healing the caster for half of it."):tformat(eff.dam) end,
	type = "physical",
	subtype = { blood=true, drain=true, heal=true },
	status = "detrimental",
	parameters = { dam=10 },
	on_gain = function(self, err) return _t"#Target# is caught in the bloodstar.", true end,
	on_lose = function(self, err) return _t"#Target# is free from the bloodstar.", true end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("bloodstar_tendrils", 1, {tx=eff.src.x-self.x, ty=eff.src.y-self.y}))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
	on_timeout = function(self, eff)
		local severed = false
		local src = eff.src or self
		if core.fov.distance(self.x, self.y, src.x, src.y) >= eff.free or src.dead or not game.level:hasEntity(src) then severed = true end

		self:removeParticles(eff.particle)
		eff.particle = self:addParticles(Particles.new("bloodstar_tendrils", 1, {tx=eff.src.x-self.x, ty=eff.src.y-self.y}))

		if severed then
			return true
		else
			self:attr("damage_dont_undaze", 1)
			if eff.steamstar then
				if DamageType:get(DamageType.FIRE).projector(src, self.x, self.y, DamageType.FIRE, eff.steamstar.dam) > 0 then
					local nb_done = eff.src.turn_procs.steamstar_steam or 0
					eff.src:incSteam(eff.steamstar.steam * 0.3 ^ nb_done)
					eff.src.turn_procs.steamstar_steam = nb_done + 1
				end
			end
			local realdam = DamageType:get(DamageType.PHYSICAL).projector(src, self.x, self.y, DamageType.PHYSICAL, eff.dam)
			self:attr("damage_dont_undaze", -1)
			if realdam > 0 then
				local nb_done = eff.src.turn_procs.bloodstar_heals or 1
				eff.src:heal(realdam * 0.5 ^ nb_done, self)
				eff.src.turn_procs.bloodstar_heals = nb_done + 1
			end
		end
	end,
}

newEffect{
	name = "HEART_CUT", image = "effects/cut.png",
	desc = _t"Heartrended",
	long_desc = function(self, eff) return ("Vicious cut that bleeds, doing %0.2f physical damage per turn."):tformat(eff.power) end,
	type = "physical",
	subtype = { wound=true, cut=true, bleed=true },
	status = "detrimental",
	parameters = { power=1 },
	on_gain = function(self, err) return _t"#Target# starts to bleed.", _t"+Bleeds" end,
	on_lose = function(self, err) return _t"#Target# stops bleeding.", _t"-Bleeds" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the flames!
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		self.ignore_heartrend = true
		local inc = 0
		if eff.src.inc_damage then
			if eff.src.combatGetDamageIncrease then inc = eff.src:combatGetDamageIncrease(type)
			else inc = (eff.src.inc_damage.all or 0) + (eff.src.inc_damage[DamageType.PHYSICAL] or 0)
			end
		end
		DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.power * 100 / (100 + inc))
		self.ignore_heartrend = false
	end,
}

newEffect{
	name = "METAL_POISONING", image = "talents/tinker_toxic_shell.png",
	desc = _t"Metal Poisoning",
	long_desc = function(self, eff) return ("The target is poisoned with heavy metals, taking %0.2f blight damage per turn and decreasing their global speed by %d%%."):tformat(eff.power, eff.speed) end,
	type = "physical",
	subtype = { poison=true, blight=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10, speed=30},
	on_gain = function(self, err) return _t"#Target# is poisoned!", _t"+Metal Poisoning" end,
	on_lose = function(self, err) return _t"#Target# is no longer poisoned.", _t"-Metal Poisoning" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "global_speed_add", -eff.speed/100)
	end,
	-- There are situations this matters, such as copyEffect
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = math.max(old_eff.dur, new_eff.dur)
		return old_eff
	end,
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power, eff.src)
		else DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.power)
		end
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "MOSS_TREAD", image = "talents/mucus.png",
	desc = _t"Moss Tread",
	long_desc = function(self, eff) return ("You lay moss where you walk."):tformat() end,
	type = "physical",
	subtype = { moss=true },
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return nil, _t"+Moss" end,
	on_lose = function(self, err) return nil, _t"-Moss" end,
	callbackOnMove = function(self, eff, moved, force, ox, oy)
		if not moved or force or (ox == self.x and oy == self.y) then return end
		self:callTalent(self.T_TINKER_MOSS_TREAD, nil, self.x, self.y, eff.dam)
	end,
}

newEffect{
	name = "STIMPAK", image = "effects/cut.png",
	desc = _t"Stimulus",
	long_desc = function(self, eff) return ("Resisting pain, reducing all incoming damage by %0.2f. When the effect ends, take %d un-resistable damage."):tformat(eff.power, (eff.power/3)*0.05 * self.max_life) end,
	type = "physical",
	subtype = { steamtech=true },
	status = "beneficial",
	parameters = { power=3, capped = 0 },
	on_gain = function(self, err) return _t"#Target# starts to bleed.", _t"+Bleeds" end,
	on_lose = function(self, err) return _t"#Target# stops bleeding.", _t"-Bleeds" end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.power = math.min(old_eff.power + 3, 15)
		old_eff.dur = 6
		if old_eff.power == 15 then
		old_eff.capped = 1
		end
		return old_eff
	end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "flat_damage_armor", {all = eff.power})
		self:effectTemporaryValue(eff, "stimpak_capped", eff.capped)
	end,
	deactivate = function(self, eff)
		local dam = ((eff.power/3 * 0.05) * self.max_life)
		self.life = (self.life - dam)
	end,
}

newEffect{
	name = "TO_THE_ARMS", image = "talents/to_the_arms.png",
	desc = _t"To The Arms",
	long_desc = function(self, eff) return ("Damage reduced by %d%%."):tformat(eff.power) end,
	type = "physical",
	subtype = { maimed=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return _t"#Target# is suffering and fails to concentrate on dealing damage.", true end,
	on_lose = function(self, err) return _t"#Target# is suffering less.", true end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "generic_damage_penalty", eff.power)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ACID_BURN", image = "talents/acidic_skin.png",
	desc = _t"Acid Burn",
	long_desc = function(self, eff) return ("The target has been splashed with acid, taking %0.2f acid damage per turn."):tformat(eff.power) end,
	type = "physical",
	subtype = { acid=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return _t"#Target# is covered in acid!" end,
	on_lose = function(self, err) return _t"#Target# is free from the acid." end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the flames!
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		return old_eff
	end,
	-- Damage each turn
	on_timeout = function(self, eff)
		DamageType:get(DamageType.ACID).projector(eff.src, self.x, self.y, DamageType.ACID, eff.power)
	end,
}

newEffect{
	name = "STATIC_SHIELD", image = "talents/static_shock.png",
	desc = _t"Static Shield",
	long_desc = function(self, eff) return ("The target is surrounded by a static shield, increasing all resistances by %d%% and causing attacks against them to trigger a shield attack for %d%% damage as lightning."):tformat(eff.power, eff.dam*100) end,
	type = "physical",
	subtype = { lightning=true },
	status = "beneficial",
	parameters = { power=100 },
	on_gain = function(self, err) return _t"A static shield forms around #target#.", _t"+Static Shield" end,
	on_lose = function(self, err) return _t"The static shield around #target# crumbles.", _t"-Static Shield" end,
	callbackOnHit = function(self, eff, dam, target) --Target=attacker
		local src = eff.src
		if not target then return end
		local shield, shield_combat = src:hasShield()
		if not shield then return end
		if not target or target==src or target:attr("dead") or src:reactionToward(target) >= 0 then return end
		if target:getEntityKind(target) ~= "actor" then return end -- Don't try to hit traps and such
		if target.turn_procs.static_shock then return end
		if not target.x or not target.y then return end
		if core.fov.distance(src.x, src.y, target.x, target.y) > 10 then return end
		target.turn_procs.static_shock = 1
		local cs = nil
		if target:hasEffect(target.EFF_COUNTERSTRIKE) then
			cs = target:copyEffect(target.EFF_COUNTERSTRIKE)
			target:removeEffect(target.EFF_COUNTERSTRIKE)
		end
		src:attackTargetWith(target, shield_combat, DamageType.LIGHTNING, eff.dam)
		if cs then
			target:setEffect(target.EFF_COUNTERSTRIKE, cs.dur, cs)
		end
		return true
	end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {all=eff.power})
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "LIGHTNING_WEB", image = "talents/lightning_web.png",
	desc = _t"Lightning Web",
	long_desc = function(self, eff)
		return ("The target is surrounded by a crackling web of lightning, reducing all damage taken by %d."):tformat(eff.power)
	end,
	type = "physical",
	subtype = { steamtech=true, lightning=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	callbackOnHit = function(self, eff, cb, src)
		local absorb = math.min(eff.power, cb.value)
		if absorb > cb.value then absorb = absorb - cb.value end
		if eff.src and not eff.src.dead and eff.src:knowTalent(eff.src.T_CAPACITOR_DISCHARGE) then 
			eff.src:setEffect(eff.src.EFF_CAPACITOR_DISCHARGE, 10, {power=absorb, max_power=eff.src:callTalent(eff.src.T_CAPACITOR_DISCHARGE, "getDamage")}) 
		end	
		game:delayedLogDamage(src, self, 0, ("#LIGHT_BLUE#(%d lightning web)#LAST#"):tformat(absorb), false)		
		cb.value = cb.value - absorb
	end,
}

newEffect{
	name = "INCENDIARY_GRENADE", image = "talents/incendiary_grenade.png",
	desc = _t"Incendiary Grenade",
	long_desc = function(self, eff) return ("The target is burning for %d fire damage each turn and taking %d%% increased damage from all sources."):tformat(eff.dam, eff.power) end,
	type = "physical",
	subtype = { steamtech=true, fire=true },
	status = "detrimental",
	parameters = {power=10},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {all=-eff.power})	end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.FIRE).projector(eff.src, self.x, self.y, DamageType.FIRE, eff.dam)
	end,
}

newEffect{
	name = "HEALING_MIST", image = "talents/time_shield.png",
	desc = _t"Healing Mist",
	long_desc = function(self, eff) return ("Newly applied status effects durations are reduced by %d%%."):tformat(eff.power) end,
	type = "physical",
	subtype = { steamtech=true },
	status = "beneficial",
	parameters = { power=10, heal=10 },
	callbackOnActBase = function(self, t)
		local eff = self:hasEffect(self.EFF_HEALING_MIST)
		local src = eff.src
		if src:hasEffect(src.EFF_UPGRADE) then
			eff = src:hasEffect(src.EFF_UPGRADE)
			if rng.percent(eff.power/3) and self:removeEffectsFilter(self, {status="detrimental", ignore_crosstier=true}, 1) > 0 then
				game.logSeen(self, "#ORCHID#%s has recovered!#LAST#", self:getName():capitalize())
			end
		end
	end,
	activate = function(self, eff)
		local src = eff.src
		eff.durid = self:addTemporaryValue("reduce_detrimental_status_effects_time", eff.power)
		if src:hasEffect(src.EFF_UPGRADE) then
			local eff2 = src:hasEffect(src.EFF_UPGRADE)
			eff.healid = self:addTemporaryValue("healing_factor", eff2.power/200)
		end
		self:attr("allow_on_heal", 1)
		self:heal(eff.heal, src)
		self:attr("allow_on_heal", -1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("reduce_detrimental_status_effects_time", eff.durid)
		if eff.healid then self:removeTemporaryValue("healing_factor", eff.healid) end
	end,
}

newEffect{
	name = "OVERCLOCK", image = "talents/barrier.png",
	desc = _t"Overclock",
	long_desc = function(self, eff) return ("The target is surrounded by a charged shield, absorbing %d/%d damage before it crumbles. While this holds, they will project a bolt of lightning against a random enemy within range 7 each turn for %0.2f lightning damage."):tformat(self.static_shield_absorb, eff.power, eff.dam) end,
	type = "physical",
	subtype = { lightning=true, shield=true },
	status = "beneficial",
	parameters = { power=100, dam=50 },
	on_gain = function(self, err) return _t"#target# surges with power!", _t"+Overclock" end,
	on_lose = function(self, err) return _t"#target# looks less powerful.", _t"-Overclock" end,
	damage_feedback = function(self, eff, src, value)
		if eff.particle and eff.particle._shader and eff.particle._shader.shad and src and src.x and src.y then
			local r = -rng.float(0.2, 0.4)
			local a = math.atan2(src.y - self.y, src.x - self.x)
			eff.particle._shader:setUniform("impact", {math.cos(a) * r, math.sin(a) * r})
			eff.particle._shader:setUniform("impact_tick", core.game.getTime())
		end
	end,
	callbackOnHit = function(self, eff, rvalue, src)
		local value = rvalue.value
		-- Phased attack?
		local adjusted_value = value
		if src and src.attr and src:attr("damage_shield_penetrate") then
			adjusted_value = value * (1 - (util.bound(src.damage_shield_penetrate, 0, 100) / 100))
		end
		-- Absorb damage into the shield
		self.static_shield_absorb = self.static_shield_absorb or 0
		if adjusted_value <= self.static_shield_absorb then
			self.static_shield_absorb = self.static_shield_absorb - adjusted_value
			value = value - adjusted_value
		else
			value = adjusted_value - self.static_shield_absorb
			adjusted_value = self.static_shield_absorb
			self.static_shield_absorb = 0
		end
		game:delayedLogDamage(src, self, 0, ("#SLATE#(%d absorbed)#LAST#"):tformat(adjusted_value), false)
		-- If we are at the end of the capacity, release the time shield damage
		if not self.static_shield_absorb or self.static_shield_absorb <= 0 then
			game.logPlayer(self, "Your shield crumbles under the damage!")
			self:removeEffect(self.EFF_OVERCLOCK)
		end
		rvalue.value = value
		return true
	end,
	callbackOnActBase = function(self, t)
	
		local eff = self:hasEffect(self.EFF_OVERCLOCK)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 6, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="ball", radius=0, range=6, talent=t, friendlyfire=false}
		if #tgts <= 0 then return end
		local a, id = rng.table(tgts)
		table.remove(tgts, id)

		self:project(tg, a.x, a.y, DamageType.LIGHTNING_DAZE, {dam=self:steamCrit(eff.dam), daze=25})
		if core.shader.active() then game.level.map:particleEmitter(a.x, a.y, 1, "ball_lightning_beam", {radius=1, tx=x, ty=y}, {type="lightning"})
		else game.level.map:particleEmitter(a.x, a.y, tg.radius, "ball_lightning_beam", {radius=1, tx=x, ty=y}) end
		game:playSoundNear(self, "talents/lightning")
	end,

	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("static_shield", eff.power)
		if eff.reflect then eff.refid = self:addTemporaryValue("damage_shield_reflect", eff.reflect) end
		--- Warning there can be only one time shield active at once for an actor
		self.static_shield_absorb = eff.power
		self.static_shield_absorb_max = eff.power
		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {a=eff.shield_transparency or 1, size_factor=1.4, img="shield3"}, {type="runicshield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=7, bubbleColor=colors.hex1alpha"9fe836a0", auraColor=colors.hex1alpha"36bce8da"}))
		else
			eff.particle = self:addParticles(Particles.new("damage_shield", 1))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("static_shield", eff.tmpid)
		if eff.refid then self:removeTemporaryValue("damage_shield_reflect", eff.refid) end
		self.static_shield_absorb = nil
		self.static_shield_absorb_max = nil
	end,
}


newEffect{
	name = "HYPERVISION_GOGGLES", image = "talents/track.png",
	desc = _t"Hypervision Goggles",
	long_desc = function(self, eff) return ("Improves senses, allowing the detection of enemies in radius %d and increasing resistance penetration by %d%%."):tformat(eff.range, eff.power) end,
	type = "physical",
	subtype = { sense=true },
	status = "beneficial",
	parameters = { range=10, actor=1, power=10 },
	--callbackOnArcheryAttack = function(self, t, target, hitted, crit, weapon, ammo, damtype, mult, dam, talent)
	--	if target and hitted and self:knowTalent(self.T_MASTER_GADGETEER) then
	--		target:setEffect(target.EFF_EXPOSED_WEAKNESS, 3, {power=self:callTalent(self.T_MASTER_GADGETEER, "getCrit")})
	--	end
	--end,
	activate = function(self, eff)
		eff.rid = self:addTemporaryValue("detect_range", eff.range)
		eff.aid = self:addTemporaryValue("detect_actor", eff.actor)
		eff.pid = self:addTemporaryValue("resists_pen", {all=eff.power})
		self.detect_function = eff.on_detect
		game.level.map.changed = true
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("detect_range", eff.rid)
		self:removeTemporaryValue("detect_actor", eff.aid)
		self:removeTemporaryValue("resists_pen", eff.pid)
		self.detect_function = nil
	end,
}

newEffect{
	name = "AED", image = "talents/aed.png",
	desc = _t"AED",
	long_desc = function(self, eff) return ("If life is brought below 0, cancels the attack, heals for %d and deals %0.2f lightning damage in radius %d as well as dazing for 2 turns."):tformat(eff.life, eff.damage, eff.rad) end,
	type = "physical",
	subtype = { steamtech=true },
	status = "beneficial",
	parameters = { life=100, damage=100, rad=2 },
	on_gain = function(self, err) return _t"#Target# prepares their AED!", _t"+AED" end,
	on_lose = function(self, err) return _t"#Target#'s AED deactivates.", _t"-AED" end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		if not eff.aed_trigger then self.talents_cd[self.T_AED] = self.talents_cd[self.T_AED] - 15 end
	end,
	callbackOnHit = function(self, eff, cb, src)
		if cb.value > self.life and not eff.aed_trigger then	
			cb.value = 0
			self:heal(eff.life, eff)
			local tg = {type="ball", radius=eff.rad, selffire=false, x=self.x, y=self.y}
			self:project(tg, self.x, self.y, DamageType.LIGHTNING_DAZE, {dam=eff.damage, daze=100})
			game.logSeen(self, "%s's AED triggers!", self:getName():capitalize())
			eff.aed_trigger = true
			if core.shader.active(4) then
				game.level.map:particleEmitter(self.x, self.y, eff.rad, "shader_ring", {radius=eff.rad*2, life=8}, {type="sparks"})
			else
				local x, y = self.x, self.y
				-- Lightning ball gets a special treatment to make it look neat
				local sradius = (eff.rad + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
				local nb_forks = 16
				local angle_diff = 360 / nb_forks
				for i = 0, nb_forks - 1 do
					local a = math.rad(rng.range(0+i*angle_diff,angle_diff+i*angle_diff))
					local tx = x + math.floor(math.cos(a) * eff.rad)
					local ty = y + math.floor(math.sin(a) * eff.rad)
					game.level.map:particleEmitter(x, y, eff.rad, "lightning", {radius=eff.rad, grids=grids, tx=tx-x, ty=ty-y, nb_particles=25, life=8})
				end
			end
			game:onTickEnd(function() self:removeEffect(self.EFF_AED) end)
			game:playSoundNear(self, "talents/lightning")		
		end
		return cb.value
	end,
}

newEffect{
	name = "BURNING_PHOSPHOROUS", image = "talents/incendiary_powder.png",
	desc = _t"Burning Phosphorous",
	long_desc = function(self, eff) return ("The target is covered in burning chemicals, taking %0.2f fire damage each turn. Subsequent shots deal %0.2f fire damage, and if they fall below 25%% life they have a %d%% chance to panic."):tformat(self:damDesc(DamageType.FIRE, eff.dam), self:damDesc(DamageType.FIRE, eff.initdam), eff.fear) end,
	type = "physical",
	subtype = { steamtech=true, fire=true },
	status = "detrimental",
	parameters = {dam=10, apr=5, initdam=5, fear=15},
	on_merge = function(self, old_eff, new_eff)
		DamageType:get(DamageType.FIRE).projector(new_eff.src, self.x, self.y, DamageType.FIRE, new_eff.initdam)
		old_eff.dam = new_eff.dam
		old_eff.apr = new_eff.apr
		old_eff.fear = new_eff.fear
		old_eff.dur = 3
		return old_eff
	end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_armor", -eff.apr)	
	end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.FIRE).projector(eff.src, self.x, self.y, DamageType.FIRE, eff.dam)
	end,
	callbackOnAct = function(self, eff)
		if eff.src.dead then
			self:removeEffect(self.EFF_BURNING_PHOSPHOROUS)
			return
		end
	
		if self.life / self.max_life >= 0.25 then return nil end

		if not self:enoughEnergy() then return nil end

		-- apply periodic timer instead of random chance
		if not eff.timer then
			eff.timer = rng.float(0, 100)
		end
		if not self:checkHit(eff.src:combatSteampower(), self:combatMentalResist(), 0, 95, 5) or not self:canBe("fear") then
			eff.timer = eff.timer + eff.fear * 0.5
			game.logSeen(self, "#F53CBE#%s resists the fear.", self:getName():capitalize())
		else
			eff.timer = eff.timer + eff.fear
		end

		if eff.timer > 100 then
			eff.timer = eff.timer - 100

			-- in range
			if not self:attr("never_move") then
				local sourceX, sourceY = eff.src.x, eff.src.y

				local bestX, bestY
				local bestDistance = 0
				local start = rng.range(0, 8)
				for i = start, start + 8 do
					local x = self.x + (i % 3) - 1
					local y = self.y + math.floor((i % 9) / 3) - 1

					if x ~= self.x or y ~= self.y then
						local distance = core.fov.distance(x, y, sourceX, sourceY)
						if distance > bestDistance
								and game.level.map:isBound(x, y)
								and not game.level.map:checkAllEntities(x, y, "block_move", self)
								and not game.level.map(x, y, Map.ACTOR) then
							bestDistance = distance
							bestX = x
							bestY = y
						end
					end
				end

				if bestX then
					self:move(bestX, bestY, false)
					game.logSeen(eff.src, "#F53CBE#%s panics and flees from %s!", self:getName():capitalize(), eff.src:getName():capitalize())
				else
					game.logSeen(eff.src, "#F53CBE#%s panics but fails to flee from %s!", self:getName():capitalize(), eff.src:getName():capitalize())
					self:useEnergy(game.energy_to_act * self:combatMovementSpeed(bestX, bestY))
				end
			end
		end
	end,
}

newEffect{
	name = "SCORCHED",
	desc = _t"Scorched",
	long_desc = function(self, eff) return ("Fire resistance decreased by %d%%."):tformat(eff.resist) end,
	type = "physical",
	subtype = { fire=true },
	status = "detrimental",
	on_gain = function(self, err) return _t"#Target# is scorched.", true end,
	on_lose = function(self, err) return _t"#Target# is no longer scorched.", true end,
	parameters = {resist=10},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.FIRE] = -eff.resist})
	end,
}

newEffect{
	name = "PINCER_STRIKE", image = "talents/grab.png",
	desc = _t"Pincer Strike",
	long_desc = function(self, eff) return ("The target is grappled by %s, pinning them, reducing attack, spell and mind speed by %d%% and subjecting them to an automatic tailsaw strike each turn for %d%% damage."):tformat(eff.src:getName(), eff.power, eff.dam) end,
	type = "physical",
	subtype = { grapple=true, pin=true },
	status = "detrimental",
	parameters = { power=0.3, dam=1 },
	remove_on_clone = true,
	on_gain = function(self, eff) return ("%s clamps its pincers down on #Target#!"):tformat(eff.src and eff.src:getName() or "Something"), _t"+Pincer Strike" end,
	on_lose = function(self, eff) return ("#Target# is free from %s's pincers."):tformat(eff.src and eff.src:getName() or "something"), _t"-Pincer Strike" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "never_move", 1)
		self:effectTemporaryValue(eff, "combat_physspeed", -eff.power)
		self:effectTemporaryValue(eff, "combat_mindspeed", -eff.power)
		self:effectTemporaryValue(eff, "combat_spellspeed", -eff.power)
	end,
	on_timeout = function(self, eff)

		if not self.x or not eff.src or not eff.src.x or core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) > 1 or eff.src.dead or not game.level:hasEntity(eff.src) then
			self:removeEffect(self.EFF_PINCER_STRIKE)
		else
			eff.src:logCombat(self, "#Source# #LIGHT_RED#strikes down at#LAST# #Target#!")
			eff.src.turn_procs.auto_melee_hit = true
			self:attr("no_evasion", 1)
			local tail = table.get(eff.src:getInven("MECHARACHNID_TAIL"), 1)
			eff.src:attackTargetWith(self, tail.combat, nil, eff.dam)
			eff.src.turn_procs.auto_melee_hit = nil
			self:attr("no_evasion", -1)
		end
	end,
	deactivate = function(self, eff)
	end, 
}

newEffect{
	name = "REACTIVE_ARMOR", image = "talents/reactive_armor.png",
	desc = _t"Reactive Armor",
	long_desc = function(self, eff) return ("Next melee or ranged attack that deals more than 8%% of maximum life is reduced by %d%% and triggers a radius %d conal explosion dealing %d%% steamgun damage. %d stacks remaining."):tformat(eff.reduce, eff.rad, eff.dam*100, eff.stacks) end,
	type = "other",
	decrease = 0,
	subtype = { steamtech=true },
	status = "beneficial",
	parameters = { reduce=10, rad=3, dam=30, stacks=1, max_stacks=3 },
	charges = function(self, eff) return eff.stacks end,
	callbackOnHit = function(self, eff, cb, src)
		if self.turn_procs.reactive_armor then return end
		if not src then return end
		if not src.turn_procs or not src.turn_procs.weapon_type then return end
		if not src or src==self or src:attr("dead") or self:reactionToward(src) >= 0 then return end
		if src:getEntityKind(src) ~= "actor" then return end -- Don't try to hit traps and such
		if not src.x or not src.y then return end
		if self.max_life * 0.08 > cb.value then return end
		self.turn_procs.reactive_armor = true	
		self.in_reactive_armor = true
		local t = self:getTalentFromId(self.T_REACTIVE_ARMOR)
		local tg = {type="cone", cone_angle=25, range=10, radius=eff.rad, friendlyfire=false}
		local targets = self:archeryAcquireTargets(tg, {one_shot=true, infinite=true, no_energy=true, x=src.x, y=src.y})
		if targets and not self.turn_procs.reactive_armor_counterattack then
			self.turn_procs.reactive_armor_counterattack = true
			self:archeryShoot(targets, t, tg, {mult=eff.dam, phasing = true})
		end		
		self.in_reactive_armor = false
		local absorb = cb.value * eff.reduce/100
		game:delayedLogDamage(src, self, 0, ("#LIGHT_BLUE#(%d reactive armor)#LAST#"):tformat(absorb), false)		
		cb.value = cb.value - absorb
		if eff.stacks == 3 then self:startTalentCooldown(t) end
		eff.stacks = eff.stacks-1
		if eff.stacks <= 0 then self:removeEffect(self.EFF_REACTIVE_ARMOR) end
	end,	
	on_merge = function(self, old_eff, new_eff)
		old_eff.reduce = new_eff.reduce
		old_eff.rad = new_eff.rad
		old_eff.dam = new_eff.dam
		old_eff.stacks = util.bound(old_eff.stacks + 1, 1, new_eff.max_stacks)
		return old_eff
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "GRENADE_BARRAGE", image = "talents/barrage.png",
	desc = _t"Grenade Barrage",
	long_desc = function(self, eff) return ("Attack speed increased by %d%%. Next %d shot(s) trigger a grenade."):tformat(eff.power*100, eff.stacks) end,
	type = "physical",
	subtype = { steamtech=true },
	status = "beneficial",
	charges = function(self, eff) return eff.stacks end,
	on_gain = function(self, err) return _t"#Target# loads a magazine of grenades.", _t"+Grenade Barrage" end,
	parameters = {power = 10},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physspeed", eff.power)
	end,	
}

newEffect{
	name = "MIASMA_ADAPTATION", image = "talents/miasma_engine.png",
	desc = _t"Miasma Adaptation",
	long_desc = function(self, eff) return _t"Immune to miasma engine effects." end,
	type = "physical",
	subtype = { steamtech=true },
	status = "beneficial",
	parameters = {},
}

newEffect{
	name = "MIASMA_ENGINE", image = "talents/miasma_engine.png",
	desc = _t"Miasma Engine",
	long_desc = function(self, eff) return ("The target is surrounded by a toxic cloud or radius %d. Enemies within will suffer %d%% talent failure, %d%% reduced healing, and take %0.2f additional acid damage from melee and ranged attacks."):tformat(eff.radius, eff.fail * eff.stacks / eff.max_stacks, eff.heal, eff.dam) end,
	type = "physical",
	subtype = { steamtech=true, acid=true },
	status = "beneficial",
	parameters = {dam=100, heal=5, fail=5, stacks=1, radius=3, max_stacks=5},
	charges = function(self, eff) return eff.stacks end,		
	activate = function(self, eff)
--		local particle = Particles.new("generic_vortex", 5, {rm=230, rM=230, gm=20, gM=250, bm=250, bM=80, am=80, aM=150, radius=eff.radius, density=50})
		local particle = Particles.new("generic_vortex", 5, {rm=120, rM=120, gm=20, gM=70, bm=160, bM=160, am=80, aM=150, radius=eff.radius, density=100})
		if core.shader.allow("distort") then particle:setSub("vortex_distort", eff.radius, {radius=eff.radius}) end
		eff.particle = self:addParticles(particle)
		if self:knowTalent(self.T_SMOGSCREEN) then self:setEffect(self.EFF_SMOGSCREEN, 3, {src=self, power=self:callTalent(self.T_SMOGSCREEN, "getEvade")}) end
	end,
	deactivate = function(self, eff)
		if self:hasEffect(self.EFF_SMOGSCREEN) then self:removeEffect(self.EFF_SMOGSCREEN) end
		self:removeParticles(eff.particle)
	end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.stacks = math.min(old_eff.stacks + 1, new_eff.max_stacks)	
		old_eff.radius = new_eff.radius
		old_eff.fail = new_eff.fail
		old_eff.heal = new_eff.heal
		old_eff.dam = new_eff.dam
		old_eff.dur = new_eff.dur
		if self:knowTalent(self.T_SMOGSCREEN) then self:setEffect(self.EFF_SMOGSCREEN, 3, {src=self, power=self:callTalent(self.T_SMOGSCREEN, "getEvade") + (self:callTalent(self.T_SMOGSCREEN, "getEvadeStacks")*old_eff.stacks)}) end
		self:removeParticles(old_eff.particle)
		local particle = Particles.new("generic_vortex", 5, {rm=120, rM=120, gm=20, gM=70, bm=160, bM=160, am=80, aM=150, radius=old_eff.radius, density=100})
		if core.shader.allow("distort") then particle:setSub("vortex_distort", old_eff.radius, {radius=old_eff.radius}) end
		old_eff.particle = self:addParticles(particle)
		
		return old_eff
	end,	
	on_timeout = function(self, eff)
		local tgts = {}
		self:project({type="ball", range=0, friendlyfire=false, radius=eff.radius}, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and not target:hasEffect(target.EFF_MIASMA_ADAPTATION) then
				target:setEffect(target.EFF_MIASMA, 5, {src=self, fail=eff.fail * eff.stacks / eff.max_stacks, heal=eff.heal, dam=eff.dam, apply_power=self:combatSteampower(), no_ct_effect=true})
			end
		end)
	end,
}

newEffect{
	name = "SMOGSCREEN", image = "talents/smogscreen.png",
	desc = _t"Smogscreen",
	long_desc = function(self, eff) return ("%d%% chance to fully absorb any damaging actions."):tformat(eff.power) end,
	type = "other",
	subtype = { steamtech=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("cancel_damage_chance", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("cancel_damage_chance", eff.tmpid)
	end,
}

newEffect{
	name = "MIASMA", image = "talents/miasma_engine.png",
	desc = _t"Miasma",
	long_desc = function(self, eff) return ("Affected by toxic chemicals. Has %d%% talent failure, %d%% reduced healing, and takes %0.2f additional acid damage from melee and ranged attacks."):tformat(eff.fail, eff.heal, eff.dam) end,
	type = "physical",
	subtype = { steamtech=true, acid=true },
	status = "detrimental",
	parameters = {dam=100, heal=5, stacks=5},
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("talent_fail_chance", old_eff.tmpid)
		self:removeTemporaryValue("healing_factor", old_eff.healid)
		new_eff.tmpid = self:addTemporaryValue("talent_fail_chance", new_eff.fail)
		new_eff.healid = self:addTemporaryValue("healing_factor", -new_eff.heal / 100)
		new_eff.dur = old_eff.dur
		return new_eff
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("talent_fail_chance", eff.fail)
		eff.healid = self:addTemporaryValue("healing_factor", -eff.heal / 100)		
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("talent_fail_chance", eff.tmpid)
		self:removeTemporaryValue("healing_factor", eff.healid)
		game:onTickEnd(function()
			self._miasma_immuning = true
			self:removeEffect(self.EFF_MIASMA)
			self:setEffect(self.EFF_MIASMA_ADAPTATION, 9, {})
			self._miasma_immuning = nil
		end)	
	end,
	callbackOnHit = function(self, eff, cb, src)
		if not src or not src.turn_procs or not src.turn_procs.weapon_type or self.turn_procs.miasma then return end
		self.turn_procs.miasma = true
		DamageType:get(DamageType.ACID).projector(eff.src or self, self.x, self.y, DamageType.ACID, eff.dam)		
	end,		
}

newEffect{
	name = "DEATH_FROM_ABOVE", image = "talents/seeker_warhead.png",
	desc = _t"Death From Above",
	long_desc = function(self, eff) return ("Hovering in place, gaining %d%% evasion, %d%% movement speed and launching a powerful rocket barrage each turn."):tformat(eff.evasion, eff.speed*100) end,
	type = "physical",
	subtype = { steamtech=true },
	status = "beneficial",
	parameters = { dam=1, evasion=10, speed=1 },
	on_gain = function(self, err) return _t"#Target# takes flight!", _t"+Death From Above" end,
	on_lose = function(self, err) return _t"#Target# lands.", _t"-Death From Above" end,
	callbackOnTalentPost = function(self, t, ab)
		if ab.rocket_barrage then return end
		self:removeEffect(self.EFF_DEATH_FROM_ABOVE)
	end,
	get_fractional_percent = function(self, eff)
		local d = game.turn - eff.start_turn
		return util.bound(360 - d / eff.possible_end_turns * 360, 0, 360)
	end,
	activate = function(self, eff)
		if self.hotkey and self.isHotkeyBound then
			local pos = self:isHotkeyBound("talent", self.T_SEEKER_WARHEAD)
			if pos then
				self.hotkey[pos] = {"talent", self.T_ROCKET_BARRAGE}
			end
		end

		local ohk = self.hotkey
		self.hotkey = nil -- Prevent assigning hotkey, we just did
		self:learnTalent(self.T_ROCKET_BARRAGE, true, 1, {no_unlearn=true})
		self.hotkey = ohk
		eff.tmpid = self:addTemporaryValue("evasion", eff.evasion)
		eff.pid = self:addTemporaryValue("projectile_evasion", eff.evasion)
		eff.moveid = self:addTemporaryValue("movement_speed", eff.speed)
		eff.lid = self:addTemporaryValue("levitation", 1)
		eff.avid = self:addTemporaryValue("avoid_pressure_traps", 1)		
		eff.start_turn = game.turn
		eff.possible_end_turns = 10 * (eff.dur+1)		
	end,
	deactivate = function(self, eff)
		if self.hotkey and self.isHotkeyBound then
			local pos = self:isHotkeyBound("talent", self.T_ROCKET_BARRAGE)
			if pos then
				self.hotkey[pos] = {"talent", self.T_SEEKER_WARHEAD}
			end
		end

		self:unlearnTalent(self.T_ROCKET_BARRAGE, 1, nil, {no_unlearn=true})
		self:removeTemporaryValue("evasion", eff.tmpid)
		self:removeTemporaryValue("projectile_evasion", eff.pid)
		self:removeTemporaryValue("movement_speed", eff.moveid)	
		self:removeTemporaryValue("levitation", eff.lid)
		self:removeTemporaryValue("avoid_pressure_traps", eff.avid)				
	end,
}

newEffect{
	name = "CORROSIVE_FLECHETTE", image = "talents/flechette_burst.png",
	desc = _t"Corrosive Flechette",
	long_desc = function(self, eff) return ("%d corrosive flechettes are embedded in the target. Each melee and ranged attack against them will cause a flechette to burst for %0.2f acid damage"):tformat(eff.nb, eff.power) end,
	type = "physical",
	charges = function(self, eff) return eff.nb end,
	subtype = { steamtech=true, acid=true, },
	status = "detrimental",
	parameters = { power = 10, nb = 1 },
	callbackOnMeleeHit = function(self, eff, src, dam)
		if not src then return end
		if self.in_flechette then return end
		if not src or src==self or src:attr("dead") or self:reactionToward(src) >= 0 then return end
		if src:getEntityKind(src) ~= "actor" then return end -- Don't try to hit traps and such
		self.in_flechette = true
		DamageType:get(DamageType.ACID).projector(eff.src, self.x, self.y, DamageType.ACID, eff.power)
		self.in_flechette = nil
		eff.nb = eff.nb-1
		if eff.nb <= 0 then self:removeEffect(self.EFF_CORROSIVE_FLECHETTE) end
	end,
	callbackOnArcheryHit = function(self, eff, src, dam)
		if not src then return end
		if self.in_flechette then return end
		if not src or src==self or src:attr("dead") or self:reactionToward(src) >= 0 then return end
		if src:getEntityKind(src) ~= "actor" then return end -- Don't try to hit traps and such
		self.in_flechette = true
		DamageType:get(DamageType.ACID).projector(eff.src, self.x, self.y, DamageType.ACID, eff.power)
		self.in_flechette = nil
		eff.nb = eff.nb-1
		if eff.nb <= 0 then self:removeEffect(self.EFF_CORROSIVE_FLECHETTE) end
	end,
}
