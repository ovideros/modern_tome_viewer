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
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "CELESTIAL_ACCELERATION", image = "talents/celestial_acceleration.png",
	desc = _t"Celestial Acceleration",
	long_desc = function(self, eff)
		local strings = {}
		if eff.move then
			strings[#strings + 1] = ("Your movement speed is increased by %d%%."):tformat(eff.move * 100)
		end 
		if eff.cast then
			strings[#strings + 1] = ("Your casting speed is increased by %d%%."):tformat(eff.cast * 100)
		end 
		if eff.attack then
			strings[#strings + 1] = ("Your attack speed is increased by %d%%."):tformat(eff.attack * 100)
		end 
		if eff.mind then
			strings[#strings + 1] = ("Your mind speed is increased by %d%%."):tformat(eff.mind * 100)
		end 
		if eff.power then
			strings[#strings + 1] = ("Your global speed is increased by %d%%."):tformat(eff.power * 100)
		end
		
		return table.concat(strings, " ")
	end,
	type = "other",
	subtype = { speed=true },
	status = "beneficial", 
	decrease = 0, no_remove = true,
	parameters = { },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "movement_speed", eff.move)
		self:effectTemporaryValue(eff, "combat_spellspeed", eff.cast)
	end,
}

newEffect{
	name = "OUTSIDE_THE_STARSCAPE", image = "talents/starscape.png",
	desc = _t"Outside the Starscape",
	long_desc = function(self, eff) return (_t"This unit is outside of the starscape and cannot be harmed from within it,") end,
	type = "other",
	subtype = {spacetime=true},
	status = "neutral",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "invulnerable", 1)
		self:effectTemporaryValue(eff, "time_prison", 1)
		self:effectTemporaryValue(eff, "no_timeflow", 1)
		self:effectTemporaryValue(eff, "status_effect_immune", 1)
	end
}

newEffect{
	name = "MINDWALL_CONFUSED", image = "effects/confused.png",
	desc = _t"Mindblasted",
	long_desc = function(self, eff) return ("The target is confused, acting randomly (chance %d%%) and unable to perform complex actions."):tformat(eff.power) end,
	type = "other",
	subtype = { confusion=true },
	status = "detrimental", no_ct_effect = true,
	parameters = { power=100 },
	on_gain = function(self, err) return _t"#Target# wanders around!", _t"+Confused" end,
	on_lose = function(self, err) return _t"#Target# seems more focused.", _t"-Confused" end,
	activate = function(self, eff)
		eff.power = math.floor(util.bound(eff.power, 0, 50))
		eff.tmpid = self:addTemporaryValue("confused", eff.power)
		if eff.power <= 0 then eff.dur = 0 end
		if self == game.player and self.updateMainShader then self:updateMainShader() end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("confused", eff.tmpid)
		if self == game.player and self.updateMainShader then self:updateMainShader() end
	end,
}

newEffect{
	name = "AERYN_SUN_SHIELD", image = "talents/barrier.png",
	desc = _t"Shield of the Sun",
	long_desc = function(self, eff) return (_t"The power of the Sun itself shields the target.") end,
	type = "other", decrease = 0, no_remove = true,
	subtype = {sun=true},
	status = "beneficial",
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.6, img="runicshield"}, {type="runicshield", shieldIntensity=0.14, ellipsoidalFactor=1.2, time_factor=5000, bubbleColor=colors.hex1alpha"ebf400ff", auraColor=colors.hex1alpha"eca700ff"}))
		self:effectTemporaryValue(eff, "movement_speed", 1)
		self:effectTemporaryValue(eff, "invulnerable", 1)
		self:effectTemporaryValue(eff, "status_effect_immune", 1)
		self:removeEffectsFilter(self, {status="detrimental"})
		self.ai = "orcs+move_aeryn_sun_flee"
		self:doEmote(_t"TO THE MOUNTAINS!", 120)
	end,
	deactivate = function(self, eff)
		self.ai = "tactical"
		self:removeParticles(eff.particle)
		self:setEffect(self.EFF_AERYN_SUN_REZ, 1, {})
	end,
}

newEffect{
	name = "AERYN_SUN_REZ", image = "talents/barrier.png",
	desc = _t"A Light in the Darkness",
	long_desc = function(self, eff) return (_t"The power of the Sun imbues the target.") end,
	type = "other", decrease = 0, no_remove = true,
	subtype = {sun=true},
	status = "beneficial",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "inc_damage", {all=35})
		self:effectTemporaryValue(eff, "max_life", self.max_life * 0.35)
		self:heal(self.max_life, self)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "X_RAY", image = "talents/total_thuggery.png",
	desc = _t"X-Ray Vision",
	long_desc = function(self, eff) return (_t"Can see EVERYTHING.") end,
	type = "other",
	subtype = {other=true},
	status = "beneficial",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "detect_range", 10)
		self:effectTemporaryValue(eff, "detect_actor", 1)
		self:effectTemporaryValue(eff, "detect_object", 10)
		self:effectTemporaryValue(eff, "detect_trap", 10)
	end,
	deactivate = function(self, eff)
	end,
	callbackOnMove = function(self, eff, moved, force, ox, oy)
		self:magicMap(10)
	end,
}

newEffect{
	name = "NEKTOSH_WAND", image = "talents/barrier.png",
	desc = _t"Aiming!",
	long_desc = function(self, eff) return (_t"Aiming a powerful beam. MOVE OUT!") end,
	type = "other",
	subtype = {other=true},
	status = "beneficial",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "never_act", 1)
		self:effectParticles(eff, {type="sun_path", args={tx=eff.x-self.x, ty=eff.y-self.y}})
		game.bignews:saySimple(120, "#PURPLE#NEKTOSH AIMS A POWERFUL BEAM! #{bold}#MOVE!!#{normal}#")
	end,
	deactivate = function(self, eff)
		local tg = {type="beam", range=10, selffire=false}
		if eff.dig then
			for i = 1, tg.range do self:project(tg, eff.x, eff.y, DamageType.DIG, 1) end
		end
		self.big_boom = true
		self.tmp[self.EFF_NEKTOSH_WAND] = eff -- This is a nasty hack, made under the control of a professional. Do not try this at home!
		self:project(tg, eff.x, eff.y, DamageType.ARCANE, eff.power)
		self.tmp[self.EFF_NEKTOSH_WAND] = nil
		self.big_boom = false
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(eff.x-self.x), math.abs(eff.y-self.y)), "mana_beam", {tx=eff.x-self.x, ty=eff.y-self.y})

		game.logSeen(self, "%s blinks away and summons some help!", self:getName():capitalize())

		self:forceUseTalent(self.T_SUMMON, {ignore_energy=true, ignore_ressources=true})

		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(self.x, self.y, 4)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
	end,
	callbackOnKill = function(self, eff, who)
		if not self.big_boom then return end
		if not who then return end
		if who.faction == self.faction then
			world:gainAchievement("ORCS_NEKTOSH_SELF", game.player)
		end
		if who == game:getPlayer(true) and not (
			who:attr("stunned") or
			who:attr("never_move") or
			who:attr("confused") or
			who:attr("dazed") or
			who:attr("sleep")
		) then
			world:gainAchievement("ORCS_DIE_NEKTOSH", game.player)
		end
	end,
}
newEffect{
	name = "CAPACITOR_DISCHARGE", image = "talents/capacitor_discharge.png",
	desc = _t"Capacitor Discharge",
	long_desc = function(self, eff) return ("Storing damage to unleash as a powerful lightning bolt (%d/%d)."):tformat(eff.power, eff.max_power) end,
	type = "other",
	subtype = { lightning=true },
	status = "beneficial", decrease = 0,
	parameters = { power = 5, duration = 1, max_power = 25 },
	charges = function(self, eff) return math.ceil(eff.power) end,
	on_merge = function(self, old_eff, new_eff)
		if old_eff.particle then self:removeParticles(old_eff.particle) old_eff.particle = nil end
		new_eff.power = math.min(new_eff.power + old_eff.power, new_eff.max_power)
		if new_eff.power >= new_eff.max_power then
			if core.shader.active(4) then new_eff.particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=0, radius=1.1, img="lightningshield"}, {type="lightningshield"}))
			else new_eff.particle = self:addParticles(Particles.new("tempest", 1))
			end
		end
		return new_eff
	end,
	activate = function(self, eff)
		if eff.power >= eff.max_power then
			if core.shader.active(4) then eff.particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=0, radius=1.1, img="lightningshield"}, {type="lightningshield"}))
			else eff.particle = self:addParticles(Particles.new("tempest", 1))
			end
		end
	end,
	deactivate = function(self, eff)
		if eff.particle then self:removeParticles(eff.particle) end
	end,
}

newEffect{
	name = "UPGRADE",-- image = "talents/last_stand.png",
	desc = _t"Upgrade",
	long_desc = function(self, eff) return ("This turret has been greatly enhanced."):tformat() end,
	type = "other",
	subtype = { tactical=true },
	status = "beneficial", decrease = 0,
	parameters = {power = 1},
	activate = function(self, eff)
		local life = eff.power * self.max_life / 100
		eff.lid = self:addTemporaryValue("max_life", life)
		self:heal(life, src)
		if self.steamgun_turret then
			self:learnTalent(self.T_TURRET_ROCKET_LAUNCHER, true, 1, {no_unlearn=true})
			self:learnTalent(self.T_TURRET_DUAL_STEAMGUN, true, 1, {no_unlearn=true})
			self.image = "npc/steamgun_turret2.png"
			self:removeAllMOs() game.level.map:updateMap(self.x, self.y)
		end
		if self.flame_turret then
			self:learnTalent(self.T_TURRET_FLAME_VORTEX, true, 1, {no_unlearn=true})
			self.image = "npc/flame_turret2.png"
			self:removeAllMOs() game.level.map:updateMap(self.x, self.y)
		end
		if self.medic_turret then
			self.image = "npc/healing_turret2.png"
			self:removeAllMOs() game.level.map:updateMap(self.x, self.y)
		end
		if self.guardian_turret then
			self.image = "npc/guardian_turret2.png"
			self:removeAllMOs() game.level.map:updateMap(self.x, self.y)
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("max_life", eff.lid)
		if self.max_life < self.life then self.life = self.max_life end
		if self.steamgun_turret then
			self:unlearnTalent(self.T_TURRET_ROCKET_LAUNCHER, 1, nil, {no_unlearn=true})
			self:unlearnTalent(self.T_TURRET_DUAL_STEAMGUN, 1, nil, {no_unlearn=true})
			self.image = "npc/steamgun_turret1.png"
			self:removeAllMOs() game.level.map:updateMap(self.x, self.y)
		end
		if self.flame_turret then
			self:unlearnTalent(self.T_TURRET_FLAME_VORTEX, 1, nil, {no_unlearn=true})
			self.image = "npc/flame_turret1.png"
			self:removeAllMOs() game.level.map:updateMap(self.x, self.y)
		end
		if self.medic_turret then
			self.image = "npc/healing_turret1.png"
			self:removeAllMOs() game.level.map:updateMap(self.x, self.y)
		end
		if self.guardian_turret then
			self.image = "npc/guardian_turret1.png"
			self:removeAllMOs() game.level.map:updateMap(self.x, self.y)
		end
	end,
}

newEffect{
	name = "GUARDIAN_SHIELD", image = "talents/hunker_down.png",
	desc = _t"Guardian Shield",
	long_desc = function(self, eff) return ("%d%% of all incoming damage is redirected to the adjacent Guardian Turret."):tformat(eff.power) end,
	type = "other",
	subtype = { steamtech=true },
	status = "beneficial",
	parameters = { power = 5},
	callbackOnHit = function(self, t, cb, src)
		local eff = self:hasEffect(self.EFF_GUARDIAN_SHIELD)
		local effsrc = eff.src
		if effsrc == self then return nil end
		local split = cb.value * eff.power/100
		
			game:delayedLogDamage(src, effsrc, split, ("#STEEL_BLUE#(%d shared)#LAST#"):tformat(split), nil)
			cb.value = cb.value - split
			effsrc:takeHit(split, src)
		return cb.value
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "MISSILE_COUNTDOWN", image = "talents/lightning_speed.png",
	desc = _t"Countdown",
	long_desc = function(self, eff) return ("At the end of this effect, your missile will explode!"):tformat() end,
	type = "other",
	subtype = { steamtech=true },
	status = "detrimental",
	parameters = {},
	get_fractional_percent = function(self, eff)
		local d = game.turn - eff.start_turn
		return util.bound(360 - d / eff.possible_end_turns * 360, 0, 360)
	end,
	activate = function(self, eff)
		eff.start_turn = game.turn
		eff.possible_end_turns = 10 * (eff.dur+1)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "LOCK_ON_BEN", image = "talents/lock_on.png",
	desc = _t"Locked On",
	long_desc = function(self, eff) return ("Automatically firing a missile barrage against a target for %d%% increased damage."):tformat(eff.power) end,
	type = "other",
	subtype = { steamtech=true },
	status = "beneficial",
	parameters = {},
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		if not eff.target or eff.target.dead or not eff.target:hasEffect(eff.target.EFF_LOCK_ON_DET) then self:removeEffect(self.EFF_LOCK_ON_BEN) end
	end,	
}

newEffect{
	name = "LOCK_ON_DET", image = "talents/lock_on.png",
	desc = _t"Locked On",
	long_desc = function(self, eff) return ("The target has been marked by a rocket pod, reducing defence by %d and negating all evasion effects."):tformat(eff.power) end,
	type = "other",
	subtype = { steamtech=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return _t"#Target# has been marked by a rocket pod!", _t"+Locked On" end,
	on_lose = function(self, err) return _t"#Target# is no longer being marked by a rocket pod.", _t"-Locked On" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_def", -eff.power)
		self:effectTemporaryValue(eff, "no_evasion", 1)
		self:effectTemporaryValue(eff, "blind_fighted", 1)
	end,
}

newEffect{
	name = "MECHARACHNID_OFS", image = "talents/mecharachnid.png",
	desc = _t"Mecharachnid out of sight",
	long_desc = function(self, eff) return _t"The Mecharachnid is out of sight of the annihilator; direct control will be lost!" end,
	type = "other",
	subtype = { miscellaneous=true },
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return _t"#LIGHT_RED##Target# is out of sight of its master; direct control will break!", _t"+Out of sight" end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		if game.player ~= self then return true end

		if eff.dur <= 1 then
			game:onTickEnd(function()
				game.logPlayer(self, "#LIGHT_RED#You lost sight of your mecharachnid for too long; direct control is broken!")
				game.player:runStop(_t"mecharachnid out of sight")
				game.player:restStop(_t"mecharachnid out of sight")
				game.party:setPlayer(self.summoner)
			end)
		end
	end,
}


newEffect{
	name = "MECHARACHNID_PILOTING", image = "talents/mecharachnid_piloting.png",
	desc = _t"Piloted",
	long_desc = function(self, eff) return ("Currently piloted."):tformat(eff.damage, eff.resist) end,
	type = "other",
	subtype = { steamtech=true },
	status = "beneficial",
	parameters = {},
	activate = function(self, eff) game:onTickEnd(function() 	
		game.logSeen(eff.src, "#GREEN#%s takes direct control of their mecharachnid!", eff.src:getName():capitalize())	
		game.level.map:particleEmitter(eff.src.x, eff.src.y, 1, "teleport")
		game.party:setPlayer(self, true)
		game.level:removeEntity(eff.src)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		eff.src.x, eff.src.y = nil, nil
		self:updateModdableTile()
	end) end,
	deactivate = function(self, eff)
		game.level:addEntity(eff.src)
		game.party:setPlayer(eff.src, true)
		local tx, ty = util.findFreeGrid(self.x, self.y, 100, true, {[Map.ACTOR]=true})
		game.player:move(tx, ty, true)
		self:updateModdableTile()
	end,
	on_die = function(self, eff)
		game.level:addEntity(eff.src)
		game.party:setPlayer(eff.src, true)
		local tx, ty = util.findFreeGrid(self.x, self.y, 100, true, {[Map.ACTOR]=true})
		game.player:move(tx, ty, true)
	end,	
}

newEffect{
	name = "MECHARACHNID_PILOTING_BUFF", image = "talents/mecharachnid_piloting.png",
	desc = _t"Direct Control", decrease = 0,
	long_desc = function(self, eff) return ("Direct control by the pilot increases damage by %d%% and resistances by %d%%."):tformat(eff.damage, eff.resist) end,
	type = "other",
	subtype = { steamtech=true },
	status = "beneficial",
	parameters = {},
	on_timeout = function(self, eff)
		if not self:hasEffect(self.EFF_MECHARACHNID_PILOTING) then
			self:removeEffect(self.EFF_MECHARACHNID_PILOTING_BUFF)
		end
		if not self:attr("no_talents_cooldown") then
			for tid, _ in pairs(self.talents_cd) do
				local t = self:getTalentFromId(tid)
				if t and not t.fixed_cooldown then
					self.talents_cd[tid] = self.talents_cd[tid] - 1
				end
			end
		end
	end,
	activate = function(self, eff) 
		eff.damid = self:addTemporaryValue("resists", {all=eff.resist})
		eff.resid = self:addTemporaryValue("inc_damage", {all=eff.damage})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.damid)
		self:removeTemporaryValue("inc_damage", eff.resid)
	end,
}

newEffect{
	name = "HEAVY_AMMUNITION", image = "effects/heavy_ammunition.png",
	desc = _t"Heavy Ammunition",  decrease = 0,
	display_desc = function(self, eff) return ("%d Ammo"):tformat(eff.stacks) end,
	long_desc = function(self, eff) return ("Has %d heavy ammunition loaded. Current heavy weapon will be unequiped when no ammunitions are left."):tformat(eff.stacks) end,
	type = "other",
	subtype = { steamtech=true },
	status = "beneficial",
	parameters = { stacks=1, stack_bits=0, max_stacks=10 },
	charges = function(self, eff) return eff.stacks end,
	callbackOnRest = function(self, eff, what)
		if what ~= "check" then return end
		if self:isTalentActive(self.T_HW_FLAMETHROWER) or self:isTalentActive(self.T_HW_SHOCKSTAFF) or self:isTalentActive(self.T_HW_BOLTGUN) then return end
		if eff.stacks >= eff.max_stacks then return end
		return true
	end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.max_stacks = new_eff.max_stacks
		local add = 0
		old_eff.stack_bits = old_eff.stack_bits + new_eff.stack_bits
		if old_eff.stack_bits >= 3 then
			old_eff.stack_bits = old_eff.stack_bits % 3
			add = 1
		end
		old_eff.stacks = util.bound(old_eff.stacks + new_eff.stacks + add, 0, new_eff.max_stacks)
		return old_eff
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		if eff.stacks <= 0 then game:onTickEnd(function()
			if self:isTalentActive(self.T_HW_FLAMETHROWER) then self:forceUseTalent(self.T_HW_FLAMETHROWER, {ignore_energy=true}) end
			if self:isTalentActive(self.T_HW_BOLTGUN) then self:forceUseTalent(self.T_HW_BOLTGUN, {ignore_energy=true}) end
			if self:isTalentActive(self.T_HW_SHOCKSTAFF) then self:forceUseTalent(self.T_HW_SHOCKSTAFF, {ignore_energy=true}) end
		end) end
	end,
}

newEffect{
	name = "STORMSTRIKE", image = "talents/stormstrike.png",
	desc = _t"Stormstrike",
	long_desc = function(self, eff) return ("The target has been staggered, reducing all damage dealt by %d%%."):tformat(eff.power) end,
	charges = function(self, eff) return tostring(math.ceil(eff.power)).."%" end,
	type = "other",
	subtype = { lightning=true, },
	status = "detrimental",
	parameters = { power = 10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "numbed", eff.power)
	end,
}

newEffect{
	name = "CHEM_FLECHETTE", image = "talents/flechette_burst.png",
	desc = _t"Catalyst",
	long_desc = function(self, eff) return ("The target has been injected with chemicals, reducing all saves by %d."):tformat(eff.power) end,
	type = "other",
	subtype = { acid=true, },
	status = "detrimental",
	parameters = { power = 10 },
	activate = function(self, eff)
		eff.mental = self:addTemporaryValue("combat_mentalresist", -eff.power)
		eff.spell = self:addTemporaryValue("combat_spellresist", -eff.power)
		eff.physical = self:addTemporaryValue("combat_physresist", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_mentalresist", eff.mental)
		self:removeTemporaryValue("combat_spellresist", eff.spell)
		self:removeTemporaryValue("combat_physresist", eff.physical)
	end,
}

newEffect{
	name = "AUTOMATED_REPAIR_SYSTEM", image = "talents/automated_repair_system.png",
	desc = _t"Automated Repair System", decrease = 0,
	long_desc = function(self, eff) return ("Engaged in automated repairs, preventing any action but increasing life regen by %d, all resistances by %d%% and preventing death until falling below -%d life."):tformat(eff.heal, eff.resist, eff.life) end,
	type = "other",
	subtype = { steamtech=true, healing=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return _t"#Target# shuts down and engages its automated repair system.", _t"+Automated Repair System" end,
	on_lose = function(self, err) return _t"#Target#'s repairs are complete.", _t"-Automated Repair System" end,
	activate = function(self, eff)
		eff.heal = self:addTemporaryValue("life_regen", eff.heal)
		eff.resist = self:addTemporaryValue("resists", {all=eff.resist})
		eff.life = self:addTemporaryValue("die_at", -eff.life)
		self.never_act = true
	end,
	on_timeout = function(self, eff)
		if self.life == self.max_life then self:removeEffect(self.EFF_AUTOMATED_REPAIR_SYSTEM) end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("life_regen", eff.heal)
		self:removeTemporaryValue("resists", eff.resist)
		self:removeTemporaryValue("die_at", eff.life)		
		self.never_act = nil		
	end,
}

newEffect{
	name = "DEMAGNETIZED", image = "talents/magnetic_field.png",
	desc = _t"Demagnetized",
	long_desc = function(self, eff) return ("Beneficial effects of Magnetic Field lost."):tformat() end,
	type = "other",
	subtype = { steamtech=true, lightning=true },
	status = "detrimental",
	parameters = { slow=10, crit=5 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_crit_reduction", -eff.crit)
		self:effectTemporaryValue(eff, "slow_projectiles", -eff.slow)
	end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		if not self:isTalentCoolingDown(self:getTalentFromId(self.T_MAGNETIC_FIELD)) then 
			self:removeEffect(self.EFF_DEMAGNETIZED) 
		end
	end,
}

newEffect{
	name = "GALVANIC_ROD", image = "talents/galvanic_rod.png",
	desc = _t"Galvanic Rods",
	long_desc = function(self, eff)
		local desc = _t"Rods available:\n"
		for i, rod in ipairs(eff.rods) do
			local ok, cd = self:callTalent(self.T_GALVANIC_ROD, "isRodUsable", eff, i)
			if ok then desc = desc..("#LIGHT_GREEN#- Rod (%d): available\n"):tformat(i)
			else desc = desc..("#LIGHT_RED#- Rod (%d): %d turns\n"):tformat(i, cd) end
		end
		return desc
	end,
	type = "other",
	subtype = { technomancy=true, spell=true },
	status = "beneficial", decrease = 0, no_remove = true,
	parameters = {},
	charges = function(self, eff)
		local nb = 0
		for i, rod in ipairs(eff.rods) do
			local ok, cd = self:callTalent(self.T_GALVANIC_ROD, "isRodUsable", eff, i)
			if ok then nb = nb + 1 end
		end
		return nb
	end,
	callbackOnActBase = function(self, eff)
		for i, rod in ipairs(eff.rods) do rod.turns = rod.turns + 1 end
	end,
	on_merge = function(self, old_eff, new_eff)
		return old_eff
	end,
	activate = function(self, eff)
		eff.rods = {
			{turns=1000},
			{turns=1000},
			{turns=1000},
		}
	end,
}

newEffect{
	name = "INCOMING_DISASTERS", image = "talents/master_of_disasters.png",
	desc = _t"Incoming Disasters",
	long_desc = function(self, eff) return ("Vulnerable to more cross tier effects."):tformat() end,
	type = "other",
	subtype = { cunning=true },
	status = "detrimental",
	parameters = {},
}
