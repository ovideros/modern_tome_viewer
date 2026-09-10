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
	name = "GESTALT_STEAM", image = "talents/gestalt.png",
	desc = _t"Gestalt",
	long_desc = function(self, eff) return ("Steampower increased by %d."):tformat(eff.power) end,
	type = "mental",
	subtype = {psionic=true, gestalt=true},
	status = "beneficial",
	decrease = 0,
	parameters = {power = 1},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_steampower", eff.power)
	end,
	callbackOnTalentPost = function(self, eff, ab, ret, silent)
		if not ab.is_steam then return end
		game:onTickEnd(function() self:removeEffect(self.EFF_GESTALT_STEAM) end)
	end,
}

newEffect{
	name = "FORCED_GESTALT", image = "talents/forced_gestalt.png",
	desc = _t"Forced Gestalt",
	long_desc = function(self, eff) return ("All powers increased by %d."):tformat(eff.power) end,
	type = "mental",
	subtype = {psionic=true, gestalt=true},
	status = "beneficial",
	parameters = {power = 1},
	on_gain = function(self, eff) return _t"#Target# is drains all powers around #himher#.", true end,
	on_lose = function(self, eff) return _t"#Target# is less powerful.", true end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_generic_power", eff.power)
	end,
}

newEffect{
	name = "FORCED_GESTALT_FOE", image = "talents/forced_gestalt.png",
	desc = _t"Forced Gestalt",
	long_desc = function(self, eff) return ("All powers reduced by %d."):tformat(eff.power) end,
	type = "mental",
	subtype = {psionic=true, gestalt=true},
	status = "detrimental",
	parameters = {power = 1},
	on_gain = function(self, eff) return _t"#Target# is drained of all powers.", true end,
	on_lose = function(self, eff) return _t"#Target# is more powerful.", true end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_generic_power", -eff.power)
	end,
}


newEffect{
	name = "MIND_DRONE", image = "talents/mind_drones.png",
	desc = _t"Mind Drone",
	long_desc = function(self, eff) return ("Talents fail chance %d%%, fear and sleep immunity reduced by %d%%."):tformat(eff.fail, eff.reduction) end,
	type = "mental",
	subtype = {psionic=true, steam=true, disrupt=true},
	status = "detrimental",
	parameters = {fail = 10, reduction = 10},
	on_gain = function(self, eff) return _t"A mind drone bores into #Target#!", true end,
	on_lose = function(self, eff) return _t"#Target# is free from the mind drone.", true end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "talent_fail_chance", eff.fail)
		self:effectTemporaryValue(eff, "fear_immune", -eff.reduction / 100)
		self:effectTemporaryValue(eff, "sleep_immune", -eff.reduction / 100)
	end,
}

newEffect{
	name = "NEGATIVE_BIOFEEDBACK", image = "talents/negative_biofeedback.png",
	desc = _t"Negative Biofeedback",
	long_desc = function(self, eff) return ("Physical save reduced by %d, armour and defense by %d."):tformat(eff.save * eff.stacks, eff.power * eff.stacks) end,
	type = "mental",
	subtype = {psionic=true, biologic=true, physical=true, save=true},
	status = "detrimental",
	parameters = {power = 10, save = 10, stacks=1, max_stacks=1},
	on_gain = function(self, eff) return nil, true end,
	on_lose = function(self, eff) return nil, true end,
	charges = function(self, eff) return eff.stacks end,
	on_merge = function(self, old_eff, new_eff, ed)
		old_eff.save = new_eff.save
		old_eff.power = new_eff.power
		old_eff.dur = new_eff.dur
		old_eff.stacks = util.bound(old_eff.stacks + 1, 1, new_eff.max_stacks)

		ed.undoEffect(self, old_eff)
		ed.doEffect(self, old_eff)
		return old_eff
	end,
	doEffect = function(self, eff)
		eff.tmp1 = self:addTemporaryValue("combat_physresist", -eff.save * eff.stacks)
		eff.tmp2 = self:addTemporaryValue("combat_def", -eff.power * eff.stacks)
		eff.tmp3 = self:addTemporaryValue("combat_armor", -eff.power * eff.stacks)
		eff.particle = self:addParticles(Particles.new("circle", 1, {shader=true, base_rot=0, oversize=0.5, a=math.min(255, 128 + eff.stacks * 10), speed=0, img="transcend_electro", radius=0, x=0.5, y=-0.3}))
	end,
	undoEffect = function(self, eff)
		self:removeTemporaryValue("combat_physresist", eff.tmp1)
		self:removeTemporaryValue("combat_def", eff.tmp2)
		self:removeTemporaryValue("combat_armor", eff.tmp3)
		self:removeParticles(eff.particle)
	end,
	activate = function(self, eff, ed)
		ed.doEffect(self, eff)
	end,
	deactivate = function(self, eff, ed)
		ed.undoEffect(self, eff)
	end,
}

newEffect{
	name = "LUCID_SHOT", image = "talents/lucid_shot.png",
	desc = _t"Unclear Thoughts",
	long_desc = function(self, eff) return ("Can not discern foes from friends."):tformat() end,
	type = "mental",
	subtype = {confusion=true},
	status = "detrimental",
	parameters = {},
	on_gain = function(self, eff) return _t"#Target# wakes up from the nightmare very confused!", true end,
	on_lose = function(self, eff) return _t"#Target# is less afraid.", true end,
	activate = function(self, eff)
		self:setTarget(nil) -- Reset target to grab a random new one
		self:effectTemporaryValue(eff, "hates_everybody", 1)
	end,
}

newEffect{
	name = "PSY_WORM", image = "talents/psy_worm.png",
	desc = _t"Psy Worm",
	long_desc = function(self, eff) return ("Infected by a psionic worm, doing %0.2f mind damage per turn. Damage doubled on stunned or feared foes, can spread to nearby creatures."):tformat(eff.power) end,
	type = "mental",
	subtype = {psionic=true},
	status = "detrimental",
	parameters = {power=1, psi=1},
	on_gain = function(self, eff) return _t"#Target# is infected by a psy worm!", true end,
	on_lose = function(self, eff) return _t"#Target# is free from the psy worm.", true end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("circle", 1, {base_rot=0, oversize=0.7, a=150, appear=8, speed=0, img="psy_worm", radius=0}))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
	callbackOnDeath = function(self, eff)
		self:project({type="ball", radius=3}, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target or self:reactionToward(target) <= 0 or target:hasEffect(target.EFF_PSY_WORM) then return end
			target:setEffect(target.EFF_PSY_WORM, eff.dur, {apply_power=eff.src:combatMindpower(), power=eff.power, src=eff.src})
		end)
	end,
	on_timeout = function(self, eff)
		local dam = eff.power
		local psi = eff.psi
		if self:hasEffect(self.EFF_STUNNED) or #self:effectsFilter({subtype={fear=1}}, 1) > 0 then
			dam = dam * 2
			psi = psi * 2
		end
		eff.src:incPsi(psi)
		DamageType:get(DamageType.MIND).projector(eff.src or self, self.x, self.y, DamageType.MIND, dam)

		if rng.percent(25) then
			self:project({type="ball", radius=3}, self.x, self.y, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if not target or self:reactionToward(target) <= 0 or target:hasEffect(target.EFF_PSY_WORM) then return end
				target:setEffect(target.EFF_PSY_WORM, eff.dur, {apply_power=eff.src:combatMindpower(), power=eff.power, src=eff.src})
			end)
		end
	end,
}

newEffect{
	name = "NO_HOPE", image = "talents/no_hope.png",
	desc = _t"No Hope",
	long_desc = function(self, eff) return ("All damage reduced by 40%%."):tformat() end,
	type = "mental",
	subtype = {psionic=true, fear=true},
	status = "detrimental",
	parameters = {},
	on_gain = function(self, eff) return _t"#Target# loses all hope of winning!", true end,
	on_lose = function(self, eff) return _t"#Target# is once more confident.", true end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "inc_damage", {all=-40})
	end,
}

newEffect{
	name = "ALL_SIGHT", image = "talents/no_hope.png", --New Icon needed
	desc = _t"All Seeing",
	long_desc = function(self, eff) return ("Can see all other beings around them."):tformat() end,
	type = "mental",
	subtype = {psionic=true},
	status = "beneficial",
	parameters = {},
	on_gain = function(self, eff) return _t"#Target# sees all!", true end,
	on_lose = function(self, eff) return _t"#Target# loses their telepathy.", true end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "esp_all", 1)
	end,
}

newEffect{
	name = "CURSE_OF_AMAKTHEL", image = "talents/curse_of_amakthel.png",
	desc = _t"Curse of Amakthel",
	long_desc = function(self, eff) return ("All new negative effects on you will have their duration doubled."):tformat() end,
	type = "mental",
	subtype = { psionic=true, curse=true },
	status = "detrimental",
	parameters = { power=100 },
	on_gain = function(self, err) return _t"#Target# is cursed!", true end,
	on_lose = function(self, err) return _t"#Target# is no longer cursed.", true end,
	callbackOnTemporaryEffect = function(self, eff, eff_id, e, p)
		if e.status ~= "detrimental" then return end
		if eff_id == self.EFF_CURSE_OF_AMAKTHEL then return end
		p.dur = p.dur * 2
	end,
}
