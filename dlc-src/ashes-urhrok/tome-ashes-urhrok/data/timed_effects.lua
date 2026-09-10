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

local function floorEffect(t)
	t.name = t.name or t.desc
	t.name = t.name:upper():gsub("[ ']", "_")
	local d = t.long_desc
	if type(t.long_desc) == "string" then t.long_desc = function() return d end end
	t.type = "other"
	t.subtype = { floor=true }
	t.status = "neutral"
	t.parameters = {}
	t.on_gain = function(self, err) return nil, "+"..t.desc end
	t.on_lose = function(self, err) return nil, "-"..t.desc end

	newEffect(t)
end


newEffect{
	name = "DEMON_BLADE", image = "talents/demon_blade.png",
	desc = _t"Demon Blade",
	long_desc = function(self, eff) return ("Each melee hit generates a radius 1 ball of fire dealing %0.2f damage."):tformat(eff.dam) end,
	type = "magical",
	subtype = { demonic=true },
	status = "beneficial",
	parameters = { },
	on_gain = function(self, err) return _t"#Target# imbues its weapon with demonic fire.", _t"+Demon Blade" end,
	on_lose = function(self, err) return _t"#Target#'s weapon looks less threatening.", _t"-Demon Blade" end,
	callbackOnMeleeAttack = function(self, eff, target, hitted, crit, weapon, damtype, mult, dam)
		if hitted and weapon and not self.turn_procs.demon_blade then
			self.turn_procs.demon_blade = true
			self:project({type="ball", radius=1, friendlyfire=false}, target.x, target.y, DamageType.FIRE, eff.dam)
			game.level.map:particleEmitter(target.x, target.y, 1, "fireflash", {radius=1, tx=target.x, ty=target.y})
		end
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "FIERY_TORMENT",
	desc = _t"Fiery Torment",
	long_desc = function(self, eff) return ("The target's fire resistance is reduced by %d%%, and the target is highly vulnerable to the flames of the fearscape. When the effect ends, the target will take %d fire damage. This damage will increase by %d%% of all damage taken while under torment"):tformat(eff.power, eff.finaldam, eff.rate*100) end,
	type = "magical",
	subtype = { curse=true },
	status = "detrimental",
	parameters = { power=20, rate=10, finaldam=50, },
	on_gain = function(self, err) return _t"#Target# is surrounded by a vile flame!", _t"+Fiery Torment" end,
	on_lose = function(self, err) return _t"The black flame around #Target# dies down", _t"-Fiery Torment" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.FIRE]=-eff.power})
		self:effectTemporaryValue(eff, "fiery_torment", 1)
	end,
	deactivate = function(self, eff)
		eff.src:project({type="hit", x=self.x, y=self.y}, self.x, self.y, DamageType.FIRE, eff.finaldam, nil)
		game.level.map:particleEmitter(self.x, self.y, 1, "dark")
	end,
	callbackOnHit = function(self, eff, cb)
		eff.finaldam = eff.finaldam + (cb.value * eff.rate)
		return true
	end,
}

newEffect{
	name = "DESTROYER_FORM", image = "talents/destroyer.png",
	desc = _t"Destroyer",
	long_desc = function(self, eff) return ("The target assumes the form of a powerful demon."):tformat() end,
	type = "magical",
	subtype = { fire=true },
	status = "beneficial",
	parameters = {power = 5, destroyer_level = 1},
	on_gain = function(self, err) return _t"#Target# turns into a demon!", _t"+Destroyer" end,
	on_lose = function(self, err) return _t"#Target# is no longer transformed.", _t"-Destroyer" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "stamina_regen", eff.power)
		self:effectTemporaryValue(eff, "combat_dam", eff.power)
		self:effectTemporaryValue(eff, "stun_immune", eff.power/40)
		self:effectTemporaryValue(eff, "disarm_immune", eff.power/40)
		self:effectTemporaryValue(eff, "is_destroyer", eff.destroyer_level)
		self:effectTemporaryValue(eff, "demon", 1)
		self:effectTemporaryValue(eff, "size_category", 2)

		self.replace_display = mod.class.Actor.new{
			image="invis.png", add_mos = {{image = "npc/demon_major_champion_of_urh_rok.png", display_y = -1, display_h = 2}},
		}
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
	end,
	deactivate = function(self, eff)
		self.replace_display = nil
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
	end,
}

newEffect{
	name = "VORACIOUS_BLADE", image = "talents/voracious_blade.png",
	desc = _t"Voracious Blade",
	long_desc = function(self, eff) return ("Next %d melee attacks are certain to critically strike, and this unit has %d%% more critical power."):tformat(eff.hits, eff.power) end,
	type = "magical",
	subtype = { corruption=true },
	status = "beneficial",
	parameters = { power=0.1, hits=1 },
	on_gain = function(self, err) return _t"#Target#'s weapon glows with critical power!", _t"+Voracious" end,
	on_lose = function(self, err) return _t"#Target#'s weapon stops glowing.", _t"-Voracious" end,
	charges = function(self, eff) return eff.hits end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_critical_power", eff.power)
		self:effectTemporaryValue(eff, "combat_physcrit", 100)
	end,
	callbackOnMeleeAttack = function(self, eff, target, hitted)
		if not hitted then return end
		eff.hits = eff.hits - 1
		if eff.hits < 1 then
			self:removeEffect(self.EFF_VORACIOUS_BLADE)
		end
		game.level.map:particleEmitter(target.x, target.y, 1, "circle", {oversize=1.7, a=170, limit_life=12, shader=true, appear=12, speed=0, img="voracious_blade", radius=0})
		return true
	end,
}

newEffect{
	name = "RAGING_FLAMES", image = "talents/burning_sacrifice.png",
	desc = _t"Raging flames",
	long_desc = function(self, eff) return ("Next melee attack will always trigger incinerating blows, and the damage from incinerating blows will be multiplied by %d%%"):tformat(eff.power * 100) end,
	type = "magical",
	subtype = { corruption=true },
	status = "beneficial",
	parameters = { power = 1.2,},
	on_gain = function(self, err) return _t"#Target#'s weapon surges with fire!", _t"+Revel" end,
	on_lose = function(self, err) return _t"#Target#'s is no longer blazing.", _t"-Revel" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "raging_flame_mult", eff.power)
	end,
	callbackOnMeleeAttack = function(self, eff, target, hitted)
		if not hitted or target.dead == true then return end
		self:removeEffect(self.EFF_RAGING_FLAMES)
		return true
	end,
}

newEffect{
	name = "CURSED_FLAMES", image = "talents/devouring_flames.png",
	desc = _t"Devouring flames",
	long_desc = function(self, eff) return ("This character's flames are feeding the source, healing them for %d per turn and giving them %d vim."):tformat(eff.heal, eff.vim) end,
	type = "magical",
	subtype = { corruption=true },
	status = "detrimental",
	decrease = 0, no_stop_enter_worlmap = true, cancel_on_level_change = true,
	parameters = { heal = 10, vim = 2},
	on_gain = function(self, err) return _t"#Target#'s is surrounded with an all-consuming flame!", _t"+Devoured" end,
	on_lose = function(self, err) return _t"#Target#'s is no longer blazing.", _t"-Devoured" end,
	on_timeout = function(self, eff)
		eff.src:heal(eff.heal)
		eff.src:incVim(eff.vim)
	
		local is_burning = false
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.subtype.fire and p.power and e.status == "detrimental" then is_burning = true end
		end
	
		if not is_burning then
			self:removeEffect(self.EFF_CURSED_FLAMES)
		end
	end,
}

newEffect{
	name = "INFERNAL_FEAR", image = "talents/horrifying_blows.png",
	desc = _t"Overwhelming Fear",
	long_desc = function(self, eff) return ("The target is losing faith that it can defeat you, reducing its damage by %d%% and slowing it by %d%%"):tformat(eff.power*eff.stacks, eff.slow_power*eff.stacks*100) end,
	type = "mental",
	subtype = { corruption=true },
	parameters = { power=-3, max_stacks = 8, max_distance = 5, slow_power = 0, stacks = 1  },
	on_gain = function(self, err) return _t"#Target# begins to fear you." end,
	on_lose = function(self, err) return _t"#Target#'s shakes the fear off." end,
	charges = function(self, eff) return eff.stacks or 1 end,
	activate = function(self, eff)
		eff.stack1 = self:addTemporaryValue("numbed", eff.power*eff.stacks)
		if eff.slow_power ~= 0 then eff.stack2 = self:addTemporaryValue("global_speed_add", eff.slow_power*eff.stacks) end
		
		if eff.stacks >= eff.max_stacks then
			eff.particle = self:addParticles(Particles.new("wildfire", 1))
		else
			eff.particle = self:addParticles(Particles.new("darkness_shield", 1))
		end
		
	end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		
		local stackCount = old_eff.stacks + new_eff.stacks
		if stackCount >= old_eff.max_stacks then 
			stackCount = old_eff.max_stacks
			if old_eff.particle then self:removeParticles(old_eff.particle) end
			old_eff.particle = self:addParticles(Particles.new("wildfire", 1))
		end
		
		self:removeTemporaryValue("numbed", old_eff.stack1)
		if old_eff.stack2 then self:removeTemporaryValue("global_speed_add", old_eff.stack2) end
		old_eff.stack2 = nil
		old_eff.stack1 = self:addTemporaryValue("numbed", old_eff.power*stackCount)
		if old_eff.slow_power ~= 0 then old_eff.stack2 = self:addTemporaryValue("global_speed_add", old_eff.slow_power*stackCount) end
		
		old_eff.stacks = stackCount
		
		return old_eff
		
	end,
	deactivate = function(self, eff)		
		self:removeTemporaryValue("numbed", eff.stack1)
		if eff.stack2 then self:removeTemporaryValue("global_speed_add", eff.stack2) end
		if eff.particle then self:removeParticles(eff.particle) end
		
	end,
	on_timeout = function(self, eff)
		if not self.x or not eff.src.x then return end
		-- Check for distance to source and reduce duration if greater than max_distance
		local distance = core.fov.distance(self.x, self.y, eff.src.x, eff.src.y)
		if distance > eff.max_distance then
			eff.dur = eff.dur - 1
		end
	end,
}

newEffect{
	name = "HOPELESS", image = "talents/hope_wanes.png",
	desc = _t"Abandoned hope",
	long_desc = function(self, eff) return (_t"The target's spirit is broken, rendering it inactive.") end,
	type = "other", -- Nothing should affect this
	subtype = { corruption=true },
	--status = "detrimental",
	parameters = { power=1 },
	on_gain = function(self, err) return _t"#Target#'s spirit is broken.", _t"+Unable to act" end,
	on_lose = function(self, err) return _t"#Target# regains the will to fight.", _t"-Unable to act" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "dont_act", 1)
		eff.particle = self:addParticles(Particles.new("circle", 1, {oversize=1, a=220, shader=true, appear=12, img="abandon_hope", speed=0, base_rot=180, radius=0}))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "SUFFERING_IMMUNE", image = "talents/eternal_suffering.png",
	desc = _t"Suffered",
	long_desc = function(self, eff) return (_t"The target has recently suffered, and cannot do so again yet.") end,
	type = "other",
	subtype = { corruption=true },
	--status = "detrimental",
	parameters = { power=1 },
	on_gain = function(self, err) return _t"#Target# suffers!", _t"+Eternal Suffering" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "suffering_immune", 1)
	end,
}

newEffect{
	name = "PURIFIED_BY_FIRE", image = "talents/cauterize_spirit.png",
	desc = _t"Cleansing flames",
	long_desc = function(self, eff) return ("The target is purified by fire, losing %0.2f%% of their max health per turn."):tformat(eff.power*100) end,
	type = "other",
	subtype = { fire=true }, no_ct_effect = true,
	--status = "detrimental",
	parameters = { power=1 }, -- power is the % of max HP lost each turn
	on_gain = function(self, err) return _t"#Target# is purified by fire.", _t"+Fire" end,
	on_lose = function(self, err) return _t"#Target#'s purification is complete.", _t"-Fire" end,
	on_timeout = function(self, eff)
		local dam = (eff.power * self.max_life)
		self.life = (self.life - dam)

		game.logSeen(self, string.tformat("%s loses %d health to the soulburn.", self:getName():capitalize(), dam))
		self:restStop(_t"Damage from soulburn.")
	end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("circle", 1, {oversize=1, a=140, shader=true, appear=12, img="cauterize_spirit", speed=8, radius=0}))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "REBIRTH_BY_FIRE", image = "talents/blazing_rebirth.png",
	desc = _t"Blazing Rebirth",
	long_desc = function(self, eff) return ("The target is burning, taking %d damage per turn, split among it and burning foes in radius %d."):tformat(eff.power, eff.radius) end,
	type = "other",
	subtype = { fire=true }, no_ct_effect = true,
	--status = "detrimental",
	parameters = { power = 100, radius = 3 },
	on_gain = function(self, err) return _t"#Target# is purified by fire.", _t"+Fire" end,
	on_lose = function(self, err) return _t"#Target#'s purification is complete.", _t"-Fire" end,
	on_timeout = function(self, eff)
		local tg = {type="ball", range=0, radius = eff.radius, friendlyfire=false}
		local targets = {}
		local hitcount = 1
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end
			local is_burning = false
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.subtype.fire and p.power and e.status == "detrimental" then is_burning = true end
			end
			if is_burning then
				targets[#targets+1] = target
				hitcount = hitcount + 1
			end
		end)
		
		local dam = eff.power / hitcount		
		self.life = self.life - dam
		
		game.logSeen(self, "%s loses %d health to the soulburn.", self:getName():capitalize(), math.ceil(dam))
		
		for i, d in ipairs(targets) do
			engine.DamageType:get(engine.DamageType.FIRE).projector(self, d.x, d.y, engine.DamageType.FIRE, dam)
		end
	end,
}

newEffect{
	name = "FIERY_GRASP", image = "talents/fiery_grasp.png",
	desc = _t"Fiery Grasp",
	long_desc = function(self, eff)
		if eff.silence == 1 then
			return ("The target is pinned and on fire, taking %0.2f fire damage per turn. They are also silenced."):tformat(eff.power, text) 
		else
			return ("The target is pinned and on fire, taking %0.2f fire damage per turn."):tformat(eff.power, text) 
		end
	end,
	type = "physical",
	subtype = { fire=true , pin=true},
	status = "detrimental",
	parameters = { power=10, silence = 0 },
	on_gain = function(self, err) return _t"#Target# is grabbed!", _t"+Fiery Grasp" end,
	on_lose = function(self, err) return _t"#Target# is released.", _t"-Fiery Grasp" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "never_move", 1)
		self:effectTemporaryValue(eff, "silence", eff.silence)
		eff.particle = self:addParticles(Particles.new("circle", 1, {base_rot=0, oversize=0.7, a=255, appear=8, speed=0, img="fiery_hand", radius=0}))		
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
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
		DamageType:get(DamageType.FIRE).projector(eff.src, self.x, self.y, DamageType.FIRE, eff.power)
	end,
}

newEffect{
	name = "FIRE_SHIELD", image = "talents/fiery_aegis.png",
	desc = _t"Fiery Aegis",
	long_desc = function(self, eff) return ("The target is surrounded by a magical shield, absorbing %d/%d damage before it crumbles and dealing %d damage in a radius of %d when it does."):tformat(self.fiery_aegis_damage_shield_absorb, eff.power, eff.power, eff.radius) end,
	type = "magical",
	subtype = { arcane=true, shield=true },
	status = "beneficial",
	parameters = { power=100, radius = 1 },
	on_gain = function(self, err) return _t"A shield forms around #target#.", _t"+Shield" end,
	on_lose = function(self, err) return _t"The shield around #target# crumbles.", _t"-Shield" end,
	on_aegis = function(self, eff, aegis)
		self.fiery_aegis_damage_shield_absorb = self.fiery_aegis_damage_shield_absorb + eff.power * aegis / 100
		if core.shader.active(4) then
			self:removeParticles(eff.particle)
			local bc = {1.0, 0.7, 0.4, 1.0}
			local ac = {0xff/255, 0x9f/255, 0x21/255, 1}
			if eff.color then
				bc = table.clone(eff.color) bc[4] = 1
				ac = table.clone(eff.color) ac[4] = 1
			end
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.3, img="runicshield"}, {type="runicshield", shieldIntensity=0.14, ellipsoidalFactor=1.2, time_factor=-4500, bubbleColor=bc, auraColor=ac}))
		end		
	end,
	damage_feedback = function(self, eff, src, value)
		if eff.particle and eff.particle._shader and eff.particle._shader.shad and src and src.x and src.y then
			local r = -rng.float(0.2, 0.4)
			local a = math.atan2(src.y - self.y, src.x - self.x)
			eff.particle._shader:setUniform("impact", {math.cos(a) * r, math.sin(a) * r})
			eff.particle._shader:setUniform("impact_tick", core.game.getTime())
		end
	end,
	callbackOnHit = function(self, eff, cb, src)
		local value = cb.value
		-- Phased attack?
		local adjusted_value = value
		if src and src.attr and src:attr("damage_shield_penetrate") then
			adjusted_value = value * (1 - (util.bound(src.damage_shield_penetrate, 0, 100) / 100))
		end
		-- Absorb damage into the shield
		self.fiery_aegis_damage_shield_absorb = self.fiery_aegis_damage_shield_absorb or 0
		if adjusted_value <= self.fiery_aegis_damage_shield_absorb then
			self.fiery_aegis_damage_shield_absorb = self.fiery_aegis_damage_shield_absorb - adjusted_value
			value = value - adjusted_value
		else
			value = adjusted_value - self.fiery_aegis_damage_shield_absorb
			adjusted_value = self.fiery_aegis_damage_shield_absorb
			self.fiery_aegis_damage_shield_absorb = 0
		end
		game:delayedLogDamage(src, self, 0, ("#SLATE#(%d absorbed)#LAST#"):tformat(adjusted_value), false)
		-- If we are at the end of the capacity, release the time shield damage
		if not self.fiery_aegis_damage_shield_absorb or self.fiery_aegis_damage_shield_absorb <= 0 then
			game.logPlayer(self, "Your shield crumbles under the damage!")
			self:removeEffect(self.EFF_FIRE_SHIELD)
		end
		cb.value = value
		return true
	end,
	activate = function(self, eff)
		self:removeEffect(self.EFF_PSI_DAMAGE_SHIELD)
		eff.power = self:getShieldAmount(eff.power)
		eff.dur = self:getShieldDuration(eff.dur)
		eff.tmpid = self:addTemporaryValue("fiery_aegis_damage_shield", eff.power)
		self.fiery_aegis_damage_shield_absorb = eff.power
		self.fiery_aegis_damage_shield_absorb_max = eff.power
		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, nil, {type="shield", shieldIntensity=0.2, color=eff.color or {1.0, 0.7, 0.4}}))
		else
			eff.particle = self:addParticles(Particles.new("damage_shield", 1))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("fiery_aegis_damage_shield", eff.tmpid)
		if eff.refid then self:removeTemporaryValue("damage_shield_reflect", eff.refid) end
		self.fiery_aegis_damage_shield_absorb = nil
		self.fiery_aegis_damage_shield_absorb_max = nil
		local tg = {type="ball", 10, radius=eff.radius, friendlyfire=false}
		self:project(tg, self.x, self.y, DamageType.FIREBURN, {dur=3, dam=self:spellCrit(eff.power)})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_fire", {radius=tg.radius})
	end,
}

newEffect{
	name = "SURGE_OF_POWER", image = "talents/surge_of_power.png",
	desc = _t"Surge of Power",
	long_desc = function(self, eff) return ("This unit will not die until it has less than -%d HP."):tformat(eff.power) end,
	type = "physical",
	subtype = { corruption=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return _t"#Target# surges with an incredible power!", _t"+Surge of Power" end,
	on_lose = function(self, err) return _t"#Target#'s surge ends.", _t"-Surge of Power" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "die_at", -eff.power)
	end,
}

newEffect{
	name = "RECKLESS_PEN", image = "talents/reckless_strike.png",
	desc = _t"Recklessness",
	long_desc = function(self, eff) return ("This unit has %d%% resistance penetration."):tformat(eff.power) end,
	type = "magical",
	subtype = { corruption=true },
	status = "beneficial",
	parameters = { power=10,},
	on_gain = function(self, err) return _t"#Target# is surrounded by a vile flame!", _t"+Reckless" end,
	on_lose = function(self, err) return _t"The black flame around #Target# dies down", _t"-Reckless" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists_pen", {all=eff.power})
	end,
}

newEffect{
	name = "DEMON_SEED", image = "talents/demon_seed.png",
	desc = _t"Demon Seed",
	long_desc = function(self, eff) return ("Infected by a demon seed. When it dies the caster has a %d%% chance to get back the matured seed."):tformat(eff.chance) end,
	type = "magical",
	decrease = 0, no_stop_enter_worlmap = true, cancel_on_level_change = true,
	subtype = { corruption=true },
	status = "detrimental",
	parameters = { power=1, chance=10 },
	on_gain = function(self, err) return _t"#Target# is infected by a demon seed!", _t"+Demon Seed" end,
	on_lose = function(self, err) return _t"#Target# is free from the demon seed.", _t"-Demon Seed" end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	callbackOnDeath = function(self, eff)
		if not rng.percent(eff.chance) then return end
		eff.src:callTalent(eff.src.T_DEMON_SEED, "createSeed", self, eff.force_first)
	end,
}

newEffect{
	name = "OSMOSIS_REGEN", image = "effects/osmosis_regeneration.png",
	desc = _t"Osmosis Regeneration",
	long_desc = function(self, eff) return ("You regenerate a total of %0.2f life over the duration of the effect."):tformat(eff.power) end,
	type = "magical",
	subtype = { heal=true },
	status = "beneficial",
	parameters = { power=1 },
	on_gain = function(self, err) return nil, _t"+Osmosis Regen" end,
	on_lose = function(self, err) return nil, _t"-Osmosis Regen" end,
	charges = function(self, eff) return math.floor(eff.power) end,
	on_merge = function(self, old_eff, new_eff)
		local new = old_eff.power + new_eff.power
		local dur = math.max(old_eff.dur, new_eff.dur)
		old_eff.dur = dur
		old_eff.power = new
		return old_eff
	end,
	activate = function(self, eff)
		eff.power = eff.power

		if core.shader.active(4) then
			eff.particle1 = self:addParticles(Particles.new("shader_shield", 1, {toback=true,  size_factor=1.5, y=-0.3, img="healred"}, {type="healing", time_factor=9000, noup=2.0, circleColor={0,0,0,0}, beamsCount=7}))
			eff.particle2 = self:addParticles(Particles.new("shader_shield", 1, {toback=false, size_factor=1.5, y=-0.3, img="healred"}, {type="healing", time_factor=9000, noup=1.0, circleColor={0,0,0,0}, beamsCount=7}))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)
	end,
	on_timeout = function(self, eff)
		self:heal(eff.power / eff.dur, self)
		eff.power = eff.power - eff.power / eff.dur
		if eff.power < 0 then eff.dur = 0 end
	end,
}

newEffect{
	name = "ACIDIC_BATH", image = "talents/demon_seed_acidic_bath.png",
	desc = _t"Acidic Bath",
	long_desc = function(self, eff) return ("Gain %d%% resistance and %d%% affinity to acid."):tformat(eff.res, eff.aff) end,
	type = "magical",
	subtype = { resistance=true, heal=true },
	status = "beneficial",
	parameters = { aff=10, res=10 },
	on_gain = function(self, err) return nil, _t"+Acidic Bath" end,
	on_lose = function(self, err) return nil, _t"-Acidic Bath" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.ACID] = eff.res})
		self:effectTemporaryValue(eff, "damage_affinity", {[DamageType.ACID] = eff.aff})
	end,
}

newEffect{
	name = "BURNING_PLAGUE", image = "talents/flame.png",
	desc = _t"Plaguefire",
	long_desc = function(self, eff) return ("The target is on fire, taking %0.2f fire damage per turn. On death, the flame will explode."):tformat(eff.power) end,
	type = "physical",
	subtype = { fire=true },
	status = "detrimental",
	parameters = { power=50, explosion=0.75, range=4, spreadlength=5, spreadcount=1, hasspread=0},
	on_gain = function(self, err) return _t"#Target# is on fire!", _t"+Burn" end,
	on_lose = function(self, err) return _t"#Target# stops burning.", _t"-Burn" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the flames!
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		old_eff.hasspread = math.max(old_eff.hasspread, new_eff.hasspread)
		return old_eff
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.FIRE).projector(eff.src, self.x, self.y, DamageType.FIRE, eff.power)
	end,
	callbackOnDeath = function(self, eff)
		if eff.explosion then
		local tg = {type="ball", range=0, radius=eff.range, friendlyfire=false}
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "fireflash", {radius=tg.radius})
		eff.src:project(tg, self.x, self.y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if eff.hasspread >= eff.spreadcount then return end
				if not target or target==eff.src then return end
				target:setEffect(target.EFF_BURNING_PLAGUE, eff.spreadlength, {power=eff.power*eff.explosion, hasspread=eff.hasspread + 1, spreadcount=eff.spreadcount, explosion = eff.explosion, src=eff.src})
			end)
		end
	end,
}

newEffect{
	name = "DEMON_SEED_CORRUPT_LIGHT", image = "talents/demon_seed_corrupt_light.png",
	desc = _t"Corrupted Light",
	long_desc = function(self, eff) return ("The target is overflowing with power, increasing all damage done by %d%%."):tformat(eff.power) end,
	type = "magical",
	subtype = { dark=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return _t"#Target# is filled with dark power!", _t"+Corrupted Light" end,
	on_lose = function(self, err) return _t"#Target# is no longer subject to the dark power.", _t"-Corrupted Light" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "lite", -1000)
		self:effectTemporaryValue(eff, "inc_damage", {all = eff.power})
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "DEMON_SEED_ARMOURED_LEVIATHAN", image = "talents/demon_seed_armoured_leviathan.png",
	desc = _t"Armoured Leviathan",
	long_desc = function(self, eff) return ("Increases your Strength and Magic stats by %d."):tformat(eff.power) end,
	type = "magical",
	subtype = { armour=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return _t"#Target# is filled with raw power!", _t"+Armoured Leviathan" end,
	on_lose = function(self, err) return _t"#Target# is no longer filled with power.", _t"-Armoured Leviathan" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "inc_stats", {
			[Stats.STAT_MAG] = eff.power,
			[Stats.STAT_STR] = eff.power,
		})
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "DEMON_SEED_DOOMED_NATURE", image = "talents/demon_seed_doomed_nature.png",
	desc = _t"Doomed Nature",
	long_desc = function(self, eff) return ("The target is affected by blight, all natural and psionic talent it tries to use has %d%% chance to fail and instead explode into %0.2f fire damage in radius 1."):tformat(eff.chance, eff.dam) end,
	type = "magical",
	subtype = { blight=true, curse=true },
	status = "detrimental",
	parameters = { chance=10, dam=100 },
	on_gain = function(self, err) return _t"#Target# is cut off from nature!", _t"+Doomed Nature" end,
	on_lose = function(self, err) return _t"#Target# is no longer cut off from nature.", _t"-Doomed Nature" end,
	callbackOnTalentDisturbed = function(self, eff, t)
		if not t.is_nature and not t.is_mind then return end

		eff.src:project({type="ball", radius=1, x=self.x, y=self.y}, self.x, self.y, DamageType.FIRE, eff.dam, nil)
		game.level.map:particleEmitter(self.x, self.y, 1, "fireflash", {radius=1})
	end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "nature_failure", eff.chance)
		self:effectTemporaryValue(eff, "mind_failure", eff.chance)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "DEMONIC_CUT", image = "talents/demon_horns.png",
	desc = _t"Demonic Cut",
	long_desc = function(self, eff) return ("Huge demonic that bleeds, doing %0.2f darkness damage per turn. Anytime you hit it you get healed for %d."):tformat(eff.dam, eff.heal) end,
	type = "magical",
	subtype = { wound=true, cut=true, bleed=true, darkness=true },
	status = "detrimental",
	parameters = { dam=1, heal=1 },
	on_gain = function(self, err) return _t"#Target# starts to bleed darkness.", _t"+Demonic Cut" end,
	on_lose = function(self, err) return _t"#Target# stops bleeding darkness.", _t"-Demonic Cut" end,
	callbackOnMeleeHit = function(self, eff, src, dam)
		if not dam or dam <= 0 or src ~= eff.src then return end

		src:heal(eff.heal)
		if core.shader.active(4) then
			src:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healdark", life=25}, {type="healing", time_factor=6000, beamsCount=15, noup=2.0, beamColor1={0xcb/255, 0xcb/255, 0xcb/255, 1}, beamColor2={0x35/255, 0x35/255, 0x35/255, 1}}))
			src:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healdark", life=25}, {type="healing", time_factor=6000, beamsCount=15, noup=1.0, beamColor1={0xcb/255, 0xcb/255, 0xcb/255, 1}, beamColor2={0x35/255, 0x35/255, 0x35/255, 1}}))
		end
		game:playSoundNear(src, "talents/heal")
	end,
	activate = function(self, eff)
		if eff.src and eff.src:knowTalent(self.T_BLOODY_BUTCHER) then
			local t = eff.src:getTalentFromId(eff.src.T_BLOODY_BUTCHER)
			local resist = math.min(t.getResist(eff.src, t), math.max(0, self:combatGetResist(DamageType.PHYSICAL)))
			self:effectTemporaryValue(eff, "resists", {[DamageType.PHYSICAL] = -resist})
		end
	end,
	on_timeout = function(self, eff)
		(eff.src or self):callTalent(self.T_DEMON_HORNS, "doTimeout", self, eff.dam)
	end,
}

newEffect{
	name = "LINK_OF_PAIN", image = "talents/link_of_pain.png",
	desc = _t"Link of Pain",
	long_desc = function(self, eff) return ("When this target is damaged %d%% of the damage will also be done to an other victim."):tformat(eff.power) end,
	type = "magical",
	subtype = { ritual=true, darkness=true },
	status = "detrimental",
	parameters = { power=40 },
	on_gain = function(self, err) return _t"#Target# is linked through pain.", _t"+Link of Pain" end,
	on_lose = function(self, err) return _t"#Target# link of pain disappears.", _t"-Link of Pain" end,
	callbackOnHit = function(self, eff, cb, src)
		if cb.value <= 0 then return end
		if eff.victim.dead then return end
		if self.turn_procs.link_of_pain then return end

		self.turn_procs.link_of_pain = true
		local linked_damage = cb.value * eff.power / 100
		eff.victim:takeHit(linked_damage, src)
		game:delayedLogMessage(self, eff.victim, "linkofpain" ,"#ORANGE##Source# shares some pain with #target#!#LAST#")
		game:delayedLogDamage(self, eff.victim, linked_damage, ("#CRIMSON#(%d linked)#LAST#"):tformat(linked_damage), false)

		if eff.victim.dead then
			for _, tid in ipairs(table.keys(eff.src.talents_cd or {})) do
				eff.src:alterTalentCoolingdown(tid, -1)
			end
		end
		self.turn_procs.link_of_pain = nil
	end,
	callbackOnMove = function(self, eff)
		self:removeParticles(eff.particle)
		if not eff.victim.dead then
			eff.particle = self:addParticles(Particles.new("link_of_pain", 1, {tx=(eff.victim.x-self.x), ty=(eff.victim.y-self.y)}))
		end
	end,
	callbackOnAct = function(self, eff)
		self:removeParticles(eff.particle)
		if not eff.victim.dead then
			eff.particle = self:addParticles(Particles.new("link_of_pain", 1, {tx=(eff.victim.x-self.x), ty=(eff.victim.y-self.y)}))
		end
	end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("link_of_pain", 1, {tx=(eff.victim.x-self.x), ty=(eff.victim.y-self.y)}))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "ONLY_ASHES_LEFT", image = "talents/only_ashes_left.png",
	desc = _t"Only Ashes Left",
	long_desc = function(self, eff) return ("The target burns with darkness, taking %0.2f damage each turn until it dies or runs away."):tformat(eff.power) end,
	type = "magical",
	subtype = { darkness=true },
	status = "detrimental",
	decrease = 0, no_stop_enter_worlmap = true, cancel_on_level_change = true,
	parameters = { power=1, max_dist=4 },
	on_gain = function(self, err) return _t"#Target# burns with dark flames.", _t"+Only Ashes Left" end,
	on_lose = function(self, err) return _t"#Target# stops burning.", _t"-Only Ashes Left" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("circle", 1, {shader=true, base_rot=0, oversize=0.8, a=170, appear=8, speed=0, img="only_ashes_left", radius=0, x=-0.2, y=-0.5}))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
	on_timeout = function(self, eff)
		if not eff.src or not eff.src.x or not self.x or not game.level or not game.level:hasEntity(eff.src) or core.fov.distance(eff.src.x, eff.src.y, self.x, self.y) > eff.max_dist then
			self:removeEffect(self.EFF_ONLY_ASHES_LEFT)
			return
		end

		(eff.src or self):callTalent(self.T_ONLY_ASHES_LEFT, "doTimeout", self, eff.power)
	end,
}

newEffect{
	name = "SHATTERED_MIND", image = "talents/shattered_mind.png",
	desc = _t"Shattered Mind",
	long_desc = function(self, eff) return ("The target has %d%% chances to fail any talents use and suffers %d reduced physical, mental and spell saves."):tformat(eff.fail, eff.save) end,
	type = "magical",
	subtype = { spellblaze=true },
	status = "detrimental",
	parameters = { fail=10, save=10 },
	on_gain = function(self, err) return _t"The Spellblaze ripples through #target#!", _t"+Shattered Mind" end,
	on_lose = function(self, err) return _t"#Target# is no longer influenced by the Spellblaze.", _t"-Shattered Mind" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "talent_fail_chance", eff.fail)
		self:effectTemporaryValue(eff, "combat_physresist", -eff.save)
		self:effectTemporaryValue(eff, "combat_spellresist", -eff.save)
		self:effectTemporaryValue(eff, "combat_mentalresist", -eff.save)
		eff.particle = self:addParticles(Particles.new("circle", 1, {shader=true, base_rot=0, oversize=0.8, a=255, appear=8, speed=0, img="shattered_mind", radius=0, y=-0.5}))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "DARK_REIGN", image = "talents/dark_reign.png",
	desc = _t"Dark Reign",
	long_desc = function(self, eff) local p = 1 for i = 1, eff.stacks do p = p * 0.92 end p = 100 * (1 - p) return ("All damage affinity increased by %d%%.\nWill not die until %d life"):tformat(p, -((eff.die_at or 0) * eff.stacks)) end,
	type = "magical",
	subtype = { dark=true },
	status = "beneficial",
	parameters = { stacks=1, max_stacks=3, die_at = 0 },
	charges = function(self, eff) return eff.stacks end,
	on_gain = function(self, err) return _t"#Target# is filled with dark power!", _t"+Dark Reign" end,
	on_lose = function(self, err) return _t"#Target# is no longer subject to the dark power.", _t"-Dark Reign" end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.stacks = util.bound(old_eff.stacks + 1, 1, new_eff.max_stacks)

		local p = 1 for i = 1, old_eff.stacks do p = p * 0.92 end p = 100 * (1 - p)

		self:removeTemporaryValue("damage_affinity", old_eff.eff_id)
		old_eff.eff_id = self:addTemporaryValue("damage_affinity", {all = p})
		if old_eff.eff_id2 then self:removeTemporaryValue("die_at", old_eff.eff_id2) end
		if new_eff.die_at then old_eff.eff_id2 = self:addTemporaryValue("die_at", -(old_eff.stacks * new_eff.die_at) ) end

		self:removeShaderAura("dark_reign")
		local visual = 0.3 + 0.1 * old_eff.stacks
		self:addShaderAura("dark_reign", "awesomeaura", {time_factor=7500, alpha=visual, flame_scale=visual}, "particles_images/darkwings.png")
		return old_eff
	end,
	activate = function(self, eff)
		eff.eff_id = self:addTemporaryValue("damage_affinity", {all = 8})
		eff.eff_id2 = self:addTemporaryValue("die_at", -eff.die_at)

		self:addShaderAura("dark_reign", "awesomeaura", {time_factor=7500, alpha=0.4, flame_scale=0.4}, "particles_images/darkwings.png")
	end,
	deactivate = function(self, eff)
		self:removeShaderAura("dark_reign")
		self:removeTemporaryValue("damage_affinity", eff.eff_id)
		if eff.eff_id2 then self:removeTemporaryValue("die_at", eff.eff_id2) end
	end,
}

newEffect{
	name = "BLOOD_PACT", image = "talents/blood_pact.png",
	desc = _t"Blood Pact",
	long_desc = function(self, eff) return ("All damage you deal is converted to darkness."):tformat() end,
	type = "magical",
	subtype = { dark=true },
	status = "beneficial",
	parameters = { },
	on_gain = function(self, err) return _t"#Target# becomes an avatar of darkness!", _t"+Blood Pact" end,
	on_lose = function(self, err) return _t"The darkness within #target# subsides.", _t"-Blood Pact" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "all_damage_convert", DamageType.DARKNESS)
		self:effectTemporaryValue(eff, "all_damage_convert_percent", 100)
	end,
}

newEffect{
	name = "BLACKICE", image = "talents/blackice.png",
	desc = _t"Blackice",
	long_desc = function(self, eff) return ("You have %d charges."):tformat(eff.stacks) end,
	type = "magical",
	subtype = { dark=true, cold=true },
	status = "beneficial",
	parameters = { stacks=1, max_stacks=3 },
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
	name = "BLACKICE_DET", image = "talents/blackice.png",
	desc = _t"Blackice",
	long_desc = function(self, eff) return ("Fire and physical resistance reduced by %d%%."):tformat(eff.power) end,
	type = "magical",
	subtype = { dark=true, cold=true },
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.FIRE] = -eff.power, [DamageType.PHYSICAL] = -eff.power})
	end,
	deactivate = function(self, eff)
	end,
}


floorEffect{
	name = "FIRE_HAVEN",
	desc = _t"Fire Haven", image = "talents/inferno.png",
	long_desc = _t"The target is surrounded by a fire haven, granting 40% fire damage affinity but -15% to blight resistance.",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.BLIGHT] = -15})
		self:effectTemporaryValue(eff, "damage_affinity", {[DamageType.FIRE]=40})
	end,
}

newEffect{
	name = "BLEAK_OUTCOME", image = "talents/bleak_outcome.png",
	desc = _t"Bleak Outcome",
	long_desc = function(self, eff) return ("Victim is tormented with impending death.  When it dies, it will restore to the source (%s) up to %d times the normal amount of Vim."):tformat(eff.src and eff.src:getName():capitalize() or _t"none", eff.stacks) end,
	type = "magical",
	subtype = { vim=true, blight=true, curse=true },
	status = "detrimental", decrease = 0, no_stop_enter_worlmap = true, cancel_on_level_change = true,
	parameters = { stacks=1, max_stacks=3 },
	charges = function(self, eff) return eff.stacks end,
	updateBonus = function(self, eff)
		if eff.tmpids then self:tableTemporaryValuesRemove(eff.tmpids) end
		eff.tmpids = {}
		if eff.max_reduce > 0 then
			local r = math.min(eff.max_reduce, eff.stacks) * -2
			self:tableTemporaryValue(eff.tmpids, "resists", {all=r})
		end
	end,
	on_merge = function(self, old_eff, new_eff, ed)
		old_eff.dur = new_eff.dur
		old_eff.max_reduce = new_eff.max_reduce
		old_eff.stacks = util.bound(old_eff.stacks + 1, 1, new_eff.max_stacks)
		self:removeParticles(old_eff.particle)
		old_eff.particle = self:addParticles(Particles.new("circle", 1, {shader=true, base_rot=0, oversize=0.5, a=math.min(255, 128 + old_eff.stacks * 10), speed=0, img="bleak_outcome", radius=0, x=0.5, y=-0.3}))
		ed.updateBonus(self, old_eff)
		return old_eff
	end,
	activate = function(self, eff, ed)
		eff.particle = self:addParticles(Particles.new("circle", 1, {shader=true, base_rot=0, oversize=0.5, a=math.min(255, 128 + eff.stacks * 10), speed=0, img="bleak_outcome", radius=0, x=0.5, y=-0.3}))
		ed.updateBonus(self, eff)
	end,
	deactivate = function(self, eff, ed)
		if eff.tmpids then self:tableTemporaryValuesRemove(eff.tmpids) end
		self:removeParticles(eff.particle)
	end,
	on_timeout = function(self, eff) -- remove if the source is no longer available
		if not (eff.src and game.level:hasEntity(eff.src)) then self:removeEffect(eff.effect_id) end
	end,
	callbackOnDeath = function(self, eff)
		if not eff.src then return end
		eff.src:incVim((1 + eff.src:getWil() / 10) * eff.stacks)
	end,
}

newEffect{
	name = "GRIM_FUTURE", image = "talents/grim_future.png",
	desc = _t"Grim Future",
	long_desc = function(self, eff) return ("Spellpower increased by %d."):tformat(eff.power) end,
	type = "magical",
	subtype = { dark=true },
	status = "beneficial",
	parameters = { power=5 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_spellpower", eff.power)
	end,
}

newEffect{
	name = "DEMON_SEED_BLOOD_DRINKER_DEBUFF", image = "talents/demon_seed_blood_drinker.png",
	desc = _t"Blood Drinker",
	long_desc = function(self, eff) return _t"Triggers Blood Drinker if this creature dies." end,
	type = "magical",
	subtype = { blight=true, death=true },
	status = "detrimental",
	parameters = {},
	callbackOnDeath = function(self, eff)
		if eff.src then eff.src:callTalent(eff.src.T_DEMON_SEED_BLOOD_DRINKER, "deathTrigger", self) end
	end,
}

newEffect{
	name = "DEMON_SEED_BLOOD_DRINKER_BUFF", image = "talents/demon_seed_blood_drinker.png",
	desc = _t"Blood Drinker",
	long_desc = function(self, eff) return ("%d vim regen and %d%% evasion chance."):tformat(eff.vim, eff.evade) end,
	type = "magical",
	subtype = { blight=true, death=true },
	status = "beneficial",
	parameters = { evade=40, vim=7 },
	on_gain = function(self, err) return _t"#Target# is drunk with blood!", true end,
	on_lose = function(self, err) return _t"The bloodlust of #target# subsides.", true end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "evasion", eff.evade)
		self:effectTemporaryValue(eff, "vim_regen", eff.vim)
	end,
}


newEffect{
	name = "DEMON_SEED_PAIN_AFFINITY", image = "talents/demon_seed_pain_affinity.png",
	desc = _t"Pain Affinity",
	long_desc = function(self, eff) return ("All damage affinity increased by %d%%."):tformat(eff.power) end,
	type = "magical",
	subtype = { blight=true, affinity=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "damage_affinity", {all=eff.power})
	end,
}

newEffect{
	name = "OMINOUS_SHADOW", image = "talents/ominous_shadow.png",
	desc = _t"Ominous Shadow",
	long_desc = function(self, eff) return ("Improves/gives invisibility (power %d), converts all damage to darkness and uses your highest damage penetration and increase for darkness."):tformat(eff.power) end,
	type = "magical",
	subtype = { dark=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return _t"#Target# vanishes from sight.", _t"+Ominous Shadow" end,
	on_lose = function(self, err) return _t"#Target# is no longer invisible.", _t"-Ominous Shadow" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "all_damage_convert", DamageType.DARKNESS)
		self:effectTemporaryValue(eff, "all_damage_convert_percent", 100)
		self:effectTemporaryValue(eff, "auto_highest_inc_damage", {[DamageType.DARKNESS] = 1})
		self:effectTemporaryValue(eff, "auto_highest_resists_pen", {[DamageType.DARKNESS] = 1})

		eff.tmpid = self:addTemporaryValue("invisible", eff.power)
		if not self.shader then
			eff.set_shader = true
			self.shader = "invis_edge"
			self:removeAllMOs()
			game.level.map:updateMap(self.x, self.y)
		end
		if self.updateMainShader then self:updateMainShader() end
	end,
	deactivate = function(self, eff)
		if eff.set_shader then
			self.shader = nil
			self:removeAllMOs()
			game.level.map:updateMap(self.x, self.y)
		end
		self:removeTemporaryValue("invisible", eff.tmpid)
		self:resetCanSeeCacheOf()
		if self.updateMainShader then self:updateMainShader() end
	end,
}

newEffect{
	name = "CORRUPTION_OF_THE_DOOMED", image = "talents/corruption_of_the_doomed.png",
	desc = _t"Corruption of the Doomed",
	long_desc = function(self, eff) return ("The target assumes the form of a dúathedlen."):tformat() end,
	type = "magical",
	subtype = { blight=true, arcane=true },
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return _t"#Target# turns into a dúathedlen!", _t"+Corruption of the Doomed" end,
	on_lose = function(self, err) return _t"#Target# is no longer transformed.", _t"-Corruption of the Doomed" end,
	callbackOnDealDamage = function(self, eff, val, target, dead, death_note)
		if not val or val < eff.threshold or dead or not death_note or not death_note.damtype or target == self then return end
		if death_note.damtype == DamageType.MIND or death_note.damtype == DamageType.PHYSICAL then return end
		if self.turn_procs.corruption_of_the_doomed then return end
		game.logPlayer(self, "#CRIMSON#Your corruption explodes around %s!", target:getName() or " your enemies")

		self.turn_procs.corruption_of_the_doomed = true

		self:project({type="ball", radius=1, friendlyfire=false, x=target.x, y=target.y}, target.x, target.y, DamageType.DARKNESS, val / 2)
		if core.shader.active() then game.level.map:particleEmitter(target.x, target.y, 1, "starfall", {radius=1}) end
	end,
	activate = function(self, eff)
		-- self:effectTemporaryValue(eff, "all_damage_convert", DamageType.DARKNESS)
		-- self:effectTemporaryValue(eff, "all_damage_convert_percent", 100)
		self:effectTemporaryValue(eff, "stealth", eff.stealth)
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.DARKNESS] = eff.darkness})

		self.replace_display = mod.class.Actor.new{
			resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_major_duathedlen.png", display_h=2, display_y=-1}}},
		}
		self.replace_display:resolve() self.replace_display:resolve(nil, true)
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
		if self.updateMainShader then self:updateMainShader() end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self.replace_display = nil
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
		if self.updateMainShader then self:updateMainShader() end
	end,
}

newEffect{
	name = "DEMON_SEED_VOLCANIC_SKIN", image = "talents/demon_seed_volcanic_skin.png",
	desc = _t"Volcanic Skin",
	long_desc = function(self, eff) return ("%d charges."):tformat(eff.stacks) end,
	type = "magical",
	subtype = { demon=true, seismic=true },
	status = "beneficial", decrease = 0,
	parameters = { stacks=1, max_stacks=14 },
	on_gain = function(self, err) return nil, true end,
	on_lose = function(self, err) return nil, true end,
	charges = function(self, eff) return math.floor(eff.stacks) end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.stacks = util.bound(old_eff.stacks + new_eff.stacks, 1, old_eff.max_stacks)
		return old_eff
	end,
	on_timeout = function(self, eff)
		if self.in_combat then return end
		eff.stacks = eff.stacks - 1
		if eff.stacks <= 0 then self:removeEffect(self.EFF_DEMON_SEED_VOLCANIC_SKIN) end
	end,
}

-- Alter recall to hook in
local activate = TemporaryEffects.tempeffect_def.EFF_RECALL.activate
TemporaryEffects.tempeffect_def.EFF_RECALL.activate = function(self, eff)
	activate(self, eff)

	-- Only for people that did the start in the searing halls
	if self.starting_quest ~= "ashes-urhrok+start-ashes" then return end
	-- Already did
	if self:hasQuest("ashes-urhrok+re-abducted") then return end
	-- Only at level 18 or more
	if self.level < 18 then return end
	-- Only some chance of it
	if not rng.percent(15 + util.bound(math.scale(self.level, 18, 27, 0, 75), 0, 75)) then return end

	eff.where = "ashes-urhrok+anteroom-agony"
end
