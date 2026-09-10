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

local base_newEntity = newEntity
function newEntity(t) t.tinker_category = "therapeutics" return base_newEntity(t) end

local Talents = require "engine.interface.ActorTalents"
local DamageType = require "engine.DamageType"

local medical = {_t"simple", _t"potent", _t"powerful", _t"great", _t"amazing"}

for i = 1, 5 do
newEntity{ base = "BASE_SALVE", define_as = "TINKER_HEALING_SALVE"..i,
	name = ("%s healing salve"):tformat(medical[i]), image = "talents/healing_salve.png",
	color = colors.LIGHT_GREEN,
	material_level = i,
	steamtech_power_def = function(self, who)
		return who:combatScaleTherapeutic(self, 110, 50)
	end,
	resolvers.medical_salves(_t"heal %d", 15, function(self, who)
		who:attr("allow_on_heal", 1)
		who:heal(self:getCharmPower(who), who)
		who:attr("allow_on_heal", -1)
		
		if core.shader.active(4) then
			who:addParticles(engine.Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0}))
			who:addParticles(engine.Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0}))
		end
		return {id=true, used=true}
	end),
}
end

-- for i = 1, 5 do
-- newEntity{ base = "BASE_SALVE", define_as = "TINKER_METALPELT_SALVE"..i,
-- 	name = ("%s metalpelt salve"):tformat(medical[i]), image = "talents/metalpelt.png",
-- 	color = colors.LIGHT_GREEN,
-- 	material_level = i,
-- 	steamtech_power_def = function(self, who)
-- 		return who:combatScaleTherapeutic(self, 50, 75)
-- 	end,
-- 	resolvers.medical_salves("heal %d", 15, function(self, who)
-- 		self:attr("allow_on_heal", 1)
-- 		who:heal(who:steamCrit(self:getCharmPower(who)), who)
-- 		self:attr("allow_on_heal", -1)
		
-- 		if core.shader.active(4) then
-- 			who:addParticles(engine.Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0}))
-- 			who:addParticles(engine.Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0}))
-- 		end
-- 		return {id=true, used=true}
-- 	end),
-- }
-- end

for i = 1, 5 do
newEntity{ base = "BASE_SALVE", define_as = "TINKER_PAIN_SUPPRESSOR_SALVE"..i,
	name = ("%s pain suppressor salve"):tformat(medical[i]), image = "talents/pain_suppressor_salve.png",
	color = colors.GREEN,
	material_level = i,
	steamtech_power_def = function(self, who)
		return who:combatScaleTherapeutic(self, 90, 45)
	end,
	resists_all_power = function(self, who)
		return who:combatScaleTherapeutic(self, 10, 4)
	end,
	use_no_energy = true,
	resolvers.medical_salves(function(self, who) return ("let you fight up to -%%d life and reduces all damage by %d%%%% for %d turns (takes no time to activate)"):tformat(self:resists_all_power(who), 4 + math.ceil(self.material_level / 2)) end, 10, function(self, who)
		who:setEffect(who.EFF_PAIN_SUPPRESSOR_SALVE, 2 + math.ceil(self.material_level / 2), {die_at=self:getCharmPower(who), resists=self:resists_all_power(who)})
		return {id=true, used=true}
	end),
}
end

for i = 1, 5 do
newEntity{ base = "BASE_SALVE", define_as = "TINKER_FROST_SALVE"..i,
	name = ("%s frost salve"):tformat(medical[i]), image = "talents/frost_salve.png",
	color = colors.BLUE,
	material_level = i,
	steamtech_power_def = function(self, who)
		return who:combatScaleTherapeutic(self, 10, 3)
	end,
	use_no_energy = true,
	resolvers.medical_salves(function(self) local nb=math.ceil(self.material_level/2) return ("remove %d physical effects and grants a frost aura (%s cold, darkness and nature affinity)"):tformat(nb, "%d%%") end, 25, function(self, who)
		who:removeEffectsFilter(who, {type="physical", subtype={["cross tier"] = true}, status="detrimental"})
		who:removeEffectsFilter(who, {status="detrimental", type="physical"}, math.ceil(self.material_level/2))
		who:setEffect(who.EFF_FROST_SALVE, self.material_level, {power=self:getCharmPower(who)})
		return {id=true, used=true}
	end),
}
end

for i = 1, 5 do
newEntity{ base = "BASE_SALVE", define_as = "TINKER_FIERY_SALVE"..i,
	name = ("%s fiery salve"):tformat(medical[i]), image = "talents/fiery_salve.png",
	color = colors.RED,
	material_level = i,
	steamtech_power_def = function(self, who)
		return who:combatScaleTherapeutic(self, 10, 3)
	end,
	use_no_energy = true,
	resolvers.medical_salves(function(self) local nb=math.ceil(self.material_level/2) return ("remove %d magical effects and grants a fiery aura (%s fire, light and lightning affinity)"):tformat(nb, "%d%%") end, 25, function(self, who)
		who:removeEffectsFilter(who, {type="magical", subtype={["cross tier"] = true}, status="detrimental"})
		who:removeEffectsFilter(who, {status="detrimental", type="magical"}, math.ceil(self.material_level/2))
		who:setEffect(who.EFF_FIERY_SALVE, self.material_level, {power=self:getCharmPower(who)})
		return {id=true, used=true}
	end),
}
end

for i = 1, 5 do
newEntity{ base = "BASE_SALVE", define_as = "TINKER_WATER_SALVE"..i,
	name = ("%s water salve"):tformat(medical[i]), image = "talents/water_salve.png",
	color = colors.LIGHT_BLUE,
	material_level = i,
	steamtech_power_def = function(self, who)
		return who:combatScaleTherapeutic(self, 10, 3)
	end,
	use_no_energy = true,
	resolvers.medical_salves(function(self) local nb=math.ceil(self.material_level/2) return ("remove %d mental effects and grants a water aura (%s blight, mind and acid affinity)."):tformat(nb, "%d%%") end, 25, function(self, who)
		who:removeEffectsFilter(who, {type="mental", subtype={["cross tier"] = true}, status="detrimental"})
		who:removeEffectsFilter(who, {status="detrimental", type="mental"}, math.ceil(self.material_level/2))
		who:setEffect(who.EFF_WATER_SALVE, self.material_level, {power=self:getCharmPower(who)})
		return {id=true, used=true}
	end),
}
end

for i = 1, 5 do
newEntity{ base = "BASE_SALVE", define_as = "TINKER_UNSTOPPABLE_FORCE_SALVE"..i,
	name = ("%s unstoppable force salve"):tformat(medical[i]), image = "talents/unstoppable_force_salve.png",
	color = colors.GOLD,
	material_level = i,
	steamtech_power_def = function(self, who)
		return who:combatScaleTherapeutic(self, 15, 17)
	end,
	use_no_energy = true,
	resolvers.medical_salves(_t"increases all saves by %d and healing factor by half", 18, function(self, who)
		who:setEffect(who.EFF_UNSTOPPABLE_FORCE_SALVE, self.material_level, {power=self:getCharmPower(who)})
		return {id=true, used=true}
	end),
}
end

newEntity{ base = "BASE_TINKER", define_as = "TINKER_LIFE_SUPPORT5",--Therapeutics Capstone
	slot = "BODY",
	type = "armor", subtype="light",
	add_name = " (#ARMOR#)",
	display = "[", color=colors.SLATE,
	moddable_tile = "upper_body_19",
	moddable_tile2 = "lower_body_06",
	encumber = 9,
	power_source = {steam=true}, is_tinker = false,
	unique = true,
	name = "Life Support Suit", image = "object/artifact/life_support_suit.png",
	moddable_tile = "special/upper_life_support_suit", moddable_tile2 = "special/lower_life_support_suit", moddable_tile_big = true,
	unided_name = _t"advanced medical armour",
	desc = _t[["We've done it, men. We cured death."]],
	rarity = false,
	cost = 1000,
	require = { stat = { str=22 }, },
	metallic = true,
	material_level = 5,
	special_desc = function(self) 
		local maxp = self:min_power_to_trigger()
		return ("You cannot bleed.\nWhen you take damage, if your life is under 20%%, heal for 30%% of your max life. %s"):tformat(self.power < maxp and ("(%d turns until ready)"):tformat(maxp - self.power) or _t"(15 turn cooldown)")
	end,
	wielder = {
		combat_def = 12,
		combat_armor = 10,
		die_at = -200,
		fatigue = 9,
		heal_factor = 0.3,
		combat_physresist = 25,
		ignore_bleed=1,
		resists = { all=5 },
		inscriptions_data = { LIFE_SUPPORT = {
			power = 90,
			cooldown_mod = 110,
			cooldown = 1,
		}},
		learn_talent = { [Talents.T_LIFE_SUPPORT] = 1, },
	},
	max_power = 20, power_regen = 1,
	min_power_to_trigger = function(self) return self.max_power * (self.worn_by and (100 - (self.worn_by:attr("use_object_cooldown_reduce") or 0))/100 or 1) end, -- special handling of the Charm Mastery attribute
	callbackOnTakeDamage = function(self, who, src, x, y, type, dam, state)
		if self.power < self:min_power_to_trigger() then return end
		if (who.life - dam)/who.max_life >=0.2 then return end
		who:attr("allow_on_heal", 1)
		who:heal(who.max_life*0.2)
		who:attr("allow_on_heal", -1)
			if core.shader.active(4) then
				who:addParticles(engine.Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healred", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, circleDescendSpeed=3.5}))
				who:addParticles(engine.Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healred", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, circleDescendSpeed=3.5}))
			end
		self.power = 0
	end,
}

for i = 1, 5 do
newEntity{ base = "BASE_TINKER", define_as = "TINKER_SECOND_SKIN"..i,
	name = ("%s second skin"):tformat(medical[i]), image = "object/tinkers_second_skin_t5.png",
	on_slot = "BODY",
	material_level = i,
	object_tinker = {
		wielder = {
			life_regen = i*2,
			cut_immune = 0.2 + 0.1*i,
			poison_immune = 0.2 + 0.1*i,
			disease_immune = 0.2+0.1*i,
		},
	},
}
end

for i = 1, 5 do
newEntity{ base = "BASE_TINKER", define_as = "TINKER_AIR_RECYCLER"..i,
	name = ("%s air recycler"):tformat(medical[i]), image = "object/tinkers_air_recycler_t5.png",
	on_slot = "HEAD",
	material_level = i,
	metallic = true,
	special_desc = function(self) return ("Returns %d air each turn."):tformat(self.object_tinker.wielder.air_regen) end,
	object_tinker = {
		wielder = {
			air_regen = i,
			silence_immune = 0.1*i,
		},
	},
}
end

-- for i = 1, 5 do
-- newEntity{ base = "BASE_TINKER", define_as = "TINKER_SMELLING_SALTS"..i,
-- 	name = ("%s smelling salts"):tformat(medical[i]), image = "object/tinkers_hand_cannon_t5.png",
-- 	on_slot = "BELT",
-- 	special_desc = function(self) return ("Recover from stun subtype effects %d%% faster."):tformat(self.object_tinker.wielder.stun_recovery*100) end,
-- 	material_level = i,
-- 	object_tinker = {
-- 		wielder = {
-- 			stun_recovery = 0.3*i,
-- 		},
-- 	},
-- 	on_tinker = function(self, o, who)
-- 		if o.callbackOnActBase then return true end
-- 		o.callbackOnActBase = function(self, who)
-- 			local effs = {}
-- 			-- Go through all effects
-- 			for eff_id, p in pairs(who.tmp) do
-- 				local e = who.tempeffect_def[eff_id]
-- 				if e.subtype.stun and e.type ~= "other" then -- Daze is stun subtype
-- 					p.dur = p.dur - who.stun_recovery
-- 					if p.dur <= 0 then who:removeEffect(eff_id) end
-- 				end
-- 			end
-- 		end
-- 	end,
-- 	on_untinker = function(self, o, who)
-- 		if not o.callbackOnActBase then return true end
-- 		o.callbackOnActBase = nil
-- 	end,
-- }
-- end

for i = 1, 5 do
newEntity{ base = "BASE_TINKER", define_as = "TINKER_MOSS_TREAD"..i,
	name = ("%s moss tread"):tformat(medical[i]), image = "object/tinkers_moss_tread_t5.png",
	on_slot = "FEET",
	material_level = i,
	object_tinker = {
		wielder = {
			inc_stealth = 2*i,
			learn_talent = {[Talents.T_TINKER_MOSS_TREAD] = i},
		},
	},
}
end

for i = 1, 5 do
newEntity{ base = "BASE_TINKER", define_as = "TINKER_FUNGAL_WEB"..i,
	name = ("%s fungal web"):tformat(medical[i]), image = "object/tinkers_fungal_web_t5.png",
	on_slot = "BELT",
	special_desc = function(self) return ("Heals you for %d life when you use a salve."):tformat(self.object_tinker.wielder.heal_on_salve) end,
	material_level = i,
	object_tinker = {
		wielder = {
			heal_on_salve = 25*i,
		},
	},
	on_tinker = function(self, o, who)
		if o.callbackOnMedicalSalve then return true end
		o.callbackOnMedicalSalve = function(self, who, o, on_cd)
			who:heal(who.heal_on_salve, who)
		end
	end,
	on_untinker = function(self, o, who)
		if not o.callbackOnMedicalSalve then return true end
		o.callbackOnMedicalSalve = nil
	end,
}
end
