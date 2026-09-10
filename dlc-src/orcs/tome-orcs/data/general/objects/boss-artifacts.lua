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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

newEntity{ base = "BASE_CLOAK", define_as = "YETI_CLOAK",
	power_source = {nature=true},
	unique = true,
	name = "Yeti-fur Cloak", color = colors.WHITE, image = "object/artifact/yeti_fur_cloak.png",
	unided_name = _t"matted fur cloak",
	desc = _t[[This fur cloak is thick and matted, yet remains incredibly soft to the touch.]],
	level_range = {1, 10},
	rarity = 20,
	cost = 250,
	material_level = 1,
	wielder = {
		combat_def = 9,
		combat_armor = 2,
		combat_dam = 5,
		combat_physresist = 10,
		resists={[DamageType.COLD] = 15},
	},
}

newEntity{ base = "BASE_TOOL_MISC", define_as = "KORBEK_GLASS",
	power_source = {technique=true},
	unique=true, rarity=240,
	name = "Korbek's Spyglass", image = "object/artifact/korbeks_ancient_spyglass.png",
	unided_name = _t"golden telescope",
	color = colors.GOLD,
	level_range = {10, 20},
	desc = _t[[This antique spyglass is weathered from use, but seems well maintained.]],
	cost = 350,
	material_level = 2,
	wielder = {
		combat_physcrit = 5,		
		inc_stats = {[Stats.STAT_CUN] = 5,},
		combat_atk=10,
		infravision = 2,
		sight=1,
	},
}

newEntity{ base = "BASE_STEAMGUN", define_as = "TALOSIS_GUN",
	power_source = {steam=true},
	name = "Talosis' Counterpoint", image = "object/artifact/gun_ancient_talosis_counterpoint.png",
	unided_name = _t"ornate gun", unique = true,
	level_range = {5, 15},
	desc = _t[[It's said that Talosis never lost an argument. Now you know why.]],
	require = { stat = { dex=24 }, },
	cost = 300,
	material_level = 2,
	combat = {
		range = 8,
		apr = 10,
		ranged_project = {[DamageType.PHYSICAL] = 15},
	},
	wielder = {
		combat_physcrit = 4,		
		inc_stats = {[Stats.STAT_CON] = 2,},
		combat_atk=5,
		learn_talent = { [Talents.T_TALOSIS_CEASEFIRE] = 3,},
	},
}

newEntity{ base = "BASE_STEAMSAW", define_as = "TWISTED_BLADE",
	power_source = {steam=true, unknown=true},
	name = "The Twisted Blade", image = "object/artifact/the_twisted_blade.png",
	unided_name = _t"vile, twisted steamsaw", unique = true,
	slot_forbid = "OFFHAND", twohanded = true, double_weapon = true, offslot = table.NIL_MERGE,
	moddable_tile = "special/%s_the_twisted_blade",
	level_range = {40, 50},
	desc = _t[[You see flecks of gold in this vile mass of twisted steel, implying a once great origin. Whatever glory it once had is long gone, replaced by something far more sinister...]],
	require = { stat = { dex=27 }, },
	rarity = 270,
	cost = 300,
	material_level = 5,
	combat = {
		dam = 50,
		apr = 24,
		physcrit = 5,
		dammod = {str=1},
		block = 150,
		lifesteal=10,
		special_on_kill = {desc=_t"Fully heal yourself. (15 turn cooldown)", fct=function(combat, who, target)
			local Talents = require "engine.interface.ActorTalents"
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "TWISTED_BLADE")
			if not o or not who:getInven(inven_id).worn then return end
			if o.power < o:min_power_to_trigger() then return end
			who:attr("allow_on_heal", 1)
			who:heal(who.max_life)
			who:attr("allow_on_heal", -1)
			if core.shader.active(4) then
			who:addParticles(engine.Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healred", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, circleDescendSpeed=3.5}))
			who:addParticles(engine.Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healred", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, circleDescendSpeed=3.5}))
		end
			o.power = 0
		end},
	},
	wielder = {
		combat_armor = 18,
		combat_def = 14,
		fatigue = 15,
		learn_talent = { [Talents.T_BLOCK] = 5, },
	},
	max_power = 10, power_regen = 1,
	min_power_to_trigger = function(self) return self.max_power * (self.worn_by and (100 - (self.worn_by:attr("use_object_cooldown_reduce") or 0))/100 or 1) end, -- special handling of the Charm Mastery attribute
}

newEntity{ base = "BASE_AMULET", define_as = "SUNSTONE",
	power_source = {arcane=true, steam=true},
	unique = true,
	name = "Sunstone", color = colors.DARK_RED, image = "object/artifact/sun_stone.png",
	unided_name = _t"warm stone",
	desc = _t[[This strange stone shines with the heat of the Sun. Perhaps it could be used to generate more steam?]],
	level_range = {10, 30},
	rarity = 220,
	cost = 300,
	material_level = 2,
	wielder = {
		steam_regen=1,
		combat_steampower = 8,
		inc_damage={
			[DamageType.FIRE] = 10,
			[DamageType.LIGHT] = 10,
 		},
		resists = {
			[DamageType.COLD] = 10,
		},
	},
}

newEntity{ base = "BASE_MINDSTAR", define_as = "OVERSEER",
	power_source = {psionic=true},
	unique = true,
	name = "Overseer",
	unided_name = _t"cracked mindstar",
	level_range = {20, 30},
	color=colors.AQUAMARINE, image = "object/artifact/cracked_mindstar.png",
	rarity = 320,
	desc = _t[[Fragments of the Mindwall's power still inhabit this cracked, ancient gem.]],
	cost = 280,
	require = { stat = { wil=28 }, },
	material_level = 3,
	combat = {
		dam = 17,
		apr = 27,
		physcrit = 5,
		dammod = {wil=0.4, cun=0.2},
		damtype = DamageType.MIND,
		special_on_hit = {desc=_t"reduces mental save", fct=function(combat, who, target)
			target:setEffect(target.EFF_WEAKENED_MIND, 2, {power=0, save=20})
		end},
	},
	wielder = {
		combat_mindpower = 10,
		combat_mindcrit = 7,
		combat_mentalresist=24,
		inc_damage={
			[DamageType.MIND] 	= 10,
		},
		resists={
			[DamageType.MIND] 	= 25,
		},
		resists_pen={
			[DamageType.MIND] 	= 15,
		},
		inc_stats = { [Stats.STAT_WIL] = 7, [Stats.STAT_CUN] = 3, },
	},
	max_power = 60, power_regen = 1,
	use_power = {
		name = function(self, who)
			return ("either mentally dominate or psychically stun (depending on immunities) a nearby target within range %d for %d turns (success depends on Mindpower)"):tformat(self.use_power.range, self.use_power.duration)
		end,
		range = 4,
		duration = 5,
		power = 60,
		target = function(self, who) return {type="hit", range=self.use_power.range} end,
		tactical = {DISABLE=3},
		requires_target = true,
		use = function(self, who)
			local tg = self.use_power.target(self, who)
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end

			who:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target or target.dead or who.faction == target.faction or (not who.player and who:reactionToward(target) > 0) then return end
				who:logCombat(target, "#Source# psychically dominates #target# through %s %s!", who:his_her(), self:getName({do_color=true, no_add_name=true}))
				local eff_id, params = target.EFF_DOMINATE_ENTHRALL, {src=who, apply_power=who:combatMindpower()*1.2}
				if not target:canBe("instakill") or game.party:hasMember(target) then
					eff_id = target.EFF_MADNESS_STUNNED
					params.mindResistChange=50
				end
				target:setEffect(eff_id, self.use_power.duration, params)
				if target:hasEffect(eff_id) then
					target:setTarget()
				end
			end)
			return {id=true, used=true}
		end
	},
}
	
newEntity{ base = "BASE_GEM", define_as = "URESLAK_FOCUS",
	power_source = {arcane=true},
	unique = true,
	unided_name = _t"crystallized drake heart",
	name = "Ureslak's Focus", subtype = "multi-hued",
	color = colors.BLACK, image = "object/artifact/undead_dragon_heart.png",
	level_range = {30, 40},
	desc = _t[[This cracked gemstone fell from the remains of the dead Ureslak. It appears to have been turned into a vibrant crystal in whatever process reanimated him.]],
	rarity = 240,
	cost = 200,
	identified = false,
	material_level = 4,
	wielder = {
		inc_stats = {[Stats.STAT_MAG] = 6, [Stats.STAT_CON] = 6, },
		combat_spellpower=12,
		combat_dam=12,
		inc_damage = {
			[DamageType.DARKNESS] = 18,
			[DamageType.PHYSICAL] 	= 6,
			[DamageType.FIRE] 	= 6,
			[DamageType.COLD] 	= 6,
			[DamageType.LIGHTNING] 	= 6,
			[DamageType.ACID] 	= 6,
		},
	},
	imbue_powers = {
		inc_stats = {[Stats.STAT_MAG] = 6, [Stats.STAT_CON] = 6, },
		combat_spellpower=12,
		combat_dam=12,
		inc_damage = {
			[DamageType.DARKNESS] = 18,
			[DamageType.PHYSICAL] 	= 6,
			[DamageType.FIRE] 	= 6,
			[DamageType.COLD] 	= 6,
			[DamageType.LIGHTNING] 	= 6,
			[DamageType.ACID] 	= 6,
		},
	},
	talent_on_spell = { {chance=12, talent=Talents.T_NECROTIC_BREATH, level=2} },
}

newEntity{ base = "BASE_STAFF", define_as = "STARCALLER",
	power_source = {arcane=true},
	unique = true,
	name = "Starcaller",
	flavor_name = "starstaff",
	unided_name = _t"black staff", image = "object/artifact/starcaller.png",
	level_range = {25, 35},
	color=colors.VIOLET,
	rarity = 200,
	desc = _t[[A light staff covered in stralite and gems. It seems to reflect the light of the stars even in daylight.]],
	moddable_tile = "special/%s_starcaller",
	cost = 200,
	material_level = 4,

	only_element = "element_star",
	require = { stat = { mag=32 }, },
	combat = {
		dam = 25,
		apr = 4,
		dammod = {mag=1.2},
		damtype = DamageType.DARKNESS,
	},
	wielder = {
		learn_talent = {[Talents.T_COMMAND_STAFF] = 1,},
		combat_spellpower = 15,
		combat_spellcrit = 15,
		inc_damage={
			[DamageType.DARKNESS] = 30,
		},
		damage_affinity={
			[DamageType.DARKNESS] = 20,
		},
		inc_stealth = 20,
	},
	talent_on_spell = { {chance=15, talent=Talents.T_GALACTIC_PULSE, level=3} },
}

newEntity{ base = "BASE_CLOAK", define_as = "LIQUID_METAL_CLOAK",
	power_source = {steam=true},
	unique = true,
	name = "Liquid Metal Cloak", color = colors.WHITE, image = "object/artifact/liquid_metal_cloak.png",
	unided_name = _t"shiny metallic cloak",
	desc = _t[[This strange sheet of metal flows with the wind just like a normal cloak. Whoever crafted it was a true master.]],
	level_range = {35, 45},
	rarity = 350,
	cost = 600,
	material_level = 5,
	wielder = {
		combat_def = 20,
		combat_armor = 10,
		resists={[DamageType.PHYSICAL] = 15},
		talents_types_mastery = {
			["steamtech/avoidance"] = 0.2,
		},
		combat_physresist = 40,

	},
	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_CLOAK, level = 1, power = 60 },
}
