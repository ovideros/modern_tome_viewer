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

newEntity{ base = "BASE_SHIELD",
	power_source = {arcane=true},
	unique = true,
	name = "Blackfire Aegis", image = "object/artifact/blackfire_aegis.png",
	moddable_tile = "special/%s_blackfire_aegis", moddable_tile_big = true,
	unided_name = _t"blackened stone shield",
	desc = _t[[This rugged stone shield flickers with bursts of pitch black flame.]],
	color = colors.DARK_RED,
	metallic = false,
	level_range = {30, 40},
	rarity = 260,
	require = { stat = { str=28 }, },
	cost = 350,
	material_level = 4,
	special_combat = {
		dam = 57,
		block = 235,
		physcrit = 7,
		dammod = {str=1},
		damtype = DamageType.FIRE_STUN,
		convert_damage = {
			[DamageType.DARKNESS] = 50,
		},
		talents_types_mastery = {
			["corruption/doom-shield"] = 0.2,
		},
		special_on_hit = {desc=_t"releases a burst of dark fire, dealing damage equal to your magic stat", on_kill=1, fct=function(combat, who, target)
			local tg = {type="ball", range=0, radius=1, selffire=false}
			local grids = who:project(tg, target.x, target.y, engine.DamageType.SHADOWFLAME, who:getMag())
			game.level.map:particleEmitter(target.x, target.y, tg.radius, "fireflash", {radius=tg.radius})
			game.level.map:particleEmitter(target.x, target.y, tg.radius, "shadow_flash", {radius=tg.radius})
			game.level.map:particleEmitter(target.x, target.y, tg.radius, "circle", {zdepth=6, oversize=1, a=130, appear=8, limit_life=12, speed=5, img="demon_flames_circle", radius=tg.radius})
		end},
	},
	wielder = {
		resists={[DamageType.FIRE] = 35, [DamageType.DARKNESS] = 20,},
		on_melee_hit={[DamageType.FIRE] = 24, [DamageType.DARKNESS] = 24},
		combat_armor = 18,
		combat_def = 8,
		combat_def_ranged = 12,
		fatigue = 25,
		learn_talent = { [Talents.T_BLOCK] = 1, },
		combat_spellpower = 8,
	},
}

newEntity{ base = "BASE_GAUNTLETS",
	power_source = {arcane=true, technique=true},
	unique = true,
	name = "Will of Ul'Gruth", color = colors.BROWN, image = "object/artifact/will_of_ulgruth.png",
	moddable_tile = "special/will_of_ulgruth", moddable_tile_big = true,
	unided_name = _t"massive metallic gauntlets",
	desc = _t[[These massive gauntlets once belonged to a very powerful demon named Ul'Gruth. The behemoth was said to be able to level entire buildings with a single swing of his hands.]],
	level_range = {40, 50},
	rarity = 290,
	cost = 800,
	material_level = 5,
	special_desc = function(self) return _t"Your Obliterating Smash can destroy walls." end,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_MAG] = 5 },
		inc_damage = { all = 15 },
		resists_pen = { all = 10 },
		combat_armor = 15,
		talents_types_mastery = {
			["corruption/wrath"] = 0.1,
			["corruption/brutality"] = 0.1,
		},
		obliterating_smash_wall = 1,
		combat = {
			dam = 37,
			apr = 10,
			physcrit = 7,
			physspeed = 0.2,
			dammod = {dex=0.4, str=-0.6, cun=0.4, mag=0.1 },
			talent_on_hit = { T_OBLITERATING_SMASH = {level=3, chance=20}, },
			damrange = 0.3,
		},
	},
	max_power = 25, power_regen = 1,
	use_talent = { id = Talents.T_OBLITERATING_SMASH, level = 3, power = 25 },
}

newEntity{ base = "BASE_CLOAK",
	power_source = {arcane=true},
	unique = true,
	name = "Fearfire Mantle", image = "object/artifact/fearfire_mantle.png",
	moddable_tile = "special/fearfire_mantle_%s", moddable_tile_big = true,
	unided_name = _t"cloak shaped flames",
	desc = _t[[Black fires born of a blackened heart.]],
	level_range = {15, 30},
	color = colors.RED,
	rarity = 300,
	cost = 300,
	material_level = 3,
	sentient=true,
	special_desc = function(self) return _t"All enemies in radius 2 take 20 fire damage each turn and healing you for 10% of the damage dealt." end,
	wielder = {
		combat_def = 14,
		resists = {[DamageType.DARKNESS] = 10, [DamageType.FIRE] = 10, [DamageType.COLD] = 10,},
		talents_types_mastery = {
			["corruption/fearfire"] = 0.2,
		},
		on_melee_hit={[DamageType.FIRE] = 30},
	},
	on_takeoff = function(self, who)
		self.worn_by=nil
		who:removeParticles(self.particle)
	end,
	on_wear = function(self, who)
		self.worn_by=who
		self.particle = who:addParticles(engine.Particles.new("destroyer", 1, {am=0.1, aM=0.3}))
	end,
	act = function(self)
		self:useEnergy()
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by=nil return end
		if self.worn_by:attr("dead") then return end
		local who = self.worn_by
		local blast = {type="ball", range=0, radius=2, friendlyfire=false}
		who:project(blast, who.x, who.y, engine.DamageType.FIRE_DRAIN, 20)
	end,
}

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Plague-Fire Sceptre",
	slot_forbid = false,
	twohanded = false,
	flavor_name = "magestaff",
	unided_name = _t"darkness infused staff", image = "object/artifact/pleguefire_scepter.png",
	moddable_tile = "special/%s_pleguefire_scepter", moddable_tile_big = true,
	level_range = {23, 28},
	color=colors.RED,
	rarity = 220,
	desc = _t[[The flames of Mal'Rok can be more stubborn than most. When they run out of fuel they have been known go out of their way to find more.]],
	cost = 200,
	material_level = 3,
	require = { stat = { mag=24 }, },
	special_desc = function(self) return _t"Plaguefire detonates when its victim dies, spreading to other enemies up to two times." end,
	combat = {
		dam = 24,
		apr = 4,
		dammod = {mag=1.25},
		damtype = DamageType.FIRE,
	},
	wielder = {
		combat_spellpower = 27,
		combat_spellcrit = 7,
		inc_damage={
			[DamageType.FIRE] = 20,
			[DamageType.BLIGHT] = 20,
		},
	},
	max_power = 15, power_regen = 1,
	use_power = { name = _t"fire a bolt of plaguefire, dealing damage over time based on your magic stat", power = 15,
		use = function(self, who)
			local tg = {type="bolt", range=5, selffire=false}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			who:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				target:setEffect(target.EFF_BURNING_PLAGUE, 5, {power=30 + who:getMag() / 2, spreadcount=2, explosion=0.75, src=who})
			end)
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_GREATSWORD",
	power_source = {technique=true, arcane=true}, define_as = "DETHBLYD",
	name = "Dethblyd", unique=true, image = "object/artifact/dethblyd.png",
	moddable_tile = "special/%s_dethblyd", moddable_tile_big = true,
	unided_name = _t"pitch black sword", color=colors.BLACK,
	desc = _t[[Grushgore the Destroyer was as famous for his incredible brutality as he was for his childlike intelligence. He wasn't known for his subtlety of naming, but there's no denying the power of his massive sword.]],
	require = { stat = { str=35 }, },
	level_range = {40, 50},
	rarity = 240,
	cost = 280,
	material_level = 5,
	sentient=true,
	stacks=0,
	combat = {
		dam = 70,
		apr = 18,
		physcrit = 20,
		dammod = {str=1.3, mag = 0.1},
		lifesteal = 5,
		special_on_hit = {desc=_t"Increases all damage dealt, and reduces all damage taken, by 1%, stacking up to 10 times. Resets after 10 turns without attacking.", on_kill=1, fct=function(combat, who, target)
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "DETHBLYD")
			if not o or not who:getInven(inven_id).worn then return end
			o.stacks = math.min(o.stacks + 1, 10)
			who:onTakeoff(o, inven_id, true)
			o.wielder.inc_damage.all = o.stacks
			o.wielder.resists.all = o.stacks
			who:onWear(o, inven_id, true)
		end},
	},
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 10, [Stats.STAT_MAG] = 8, [Stats.STAT_CON] = 5},
		talents_types_mastery = {
			["corruption/brutality"] = 0.2,
			["corruption/wrath"] = 0.2,
			["corruption/torture"] = 0.1,
		},
		inc_damage={},
		resists={},
		talent_cd_reduction= {
			[Talents.T_DRAINING_ASSAULT] = 1,
			[Talents.T_ABDUCTION] = 1,
			[Talents.T_DETONATING_CHARGE] = 1,
		},
	},
	act = function(self)
		self:useEnergy()
		self:regenPower()
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by=nil return end
		if self.worn_by:attr("dead") then return end
		local who = self.worn_by
		local o, item, inven_id = who:findInAllInventoriesBy("define_as", "DETHBLYD")
		if self.stacks > 0 and self.power == self.max_power then
			who:onTakeoff(self, inven_id, true)
			self.stacks=0
			self.wielder.inc_damage={}
			self.wielder.resists={}
			who:onWear(self, inven_id, true)
			self.power=10
		end
	end,
	max_power = 10, power_regen = 1,
	use_power = { name = _t"", power = 10, hidden = true, use = function(self, who) return end},
	on_wear = function(self, who)
		self.worn_by = who
	end,
	on_takeoff = function(self, who)
		self.worn_by = nil
	end,
}

newEntity{ base = "BASE_HELM",
	power_source = {technique=true},
	unique = true,
	name = "Quasit's Skull", image = "object/artifact/quasits_skull.png",
	moddable_tile = "special/quasits_skull", moddable_tile_big = true,
	unided_name = _t"rocky helm",
	desc = _t[[Some enterprising adventurer seems to have noticed the skin of quasits is actually tougher than most metals, and fashioned this helm from one. Shame about the smell.]],
	level_range = {10, 19},
	rarity = 240,
	cost = 170,
	material_level = 2,
	skullcracker_mult = 2,
	wielder = {
		combat_armor = 12,
		fatigue = 5,
		combat_physresist = 12,
		stun_immune = 0.3,
		inc_stats = { [Stats.STAT_CON] = 3},
		combat_armor_hardiness = 5,
	},
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	power_source = {technique=true, arcane=true},
	unique = true,
	name = "Revenant", image = "object/artifact/revenant.png",
	unided_name = _t"shifting breastplate",
	moddable_tile = "special/upper_body_revenant",
	moddable_tile2 = "special/lower_body_revenant",
	moddable_tile_big = true,
	desc = _t[[The joints of this armor creak ominously, the frame bends and heaves, almost as if breathing. The scratch and crack of metal mutters of suffering, of loss, perseverance and revenge.]],
	color = colors.BLACK,
	level_range = {18, 30},
	rarity = 320,
	require = { stat = { str=28 }, },
	cost = 400,
	material_level = 3,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 5, [Stats.STAT_CON] = 5,},
		combat_def = 8,
		combat_armor = 20,
		confusion_immune = 0.2,
		stun_immune = 0.2,
		pin_immune = 0.2,
		silence_immune = 0.2,
		combat_mentalresist = 12,
		combat_physresist = 12,
		combat_spellresist = 12,
		fatigue = 12,
	},
	sentient = true,
	special_desc = function(self) return _t"Status resistances shift over time to match the statuses you are being hit by." end,
	on_wear = function(self, who)
		self.worn_by = who
	end,
	on_takeoff = function(self, who)
		self.worn_by = nil
	end,
	act = function(self)
		self:useEnergy()
		self:regenPower()
		
		local is_stun = false
		local is_conf = false
		local is_pin = false
		local is_sil = false
		
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by=nil return end
		if self.worn_by:attr("dead") then return end
		
		local who = self.worn_by
		
		for eff_id, p in pairs(who.tmp) do
			local e = who.tempeffect_def[eff_id]
			if e.subtype.confusion then
				is_conf = true
			end
			if e.subtype.silence then
				is_sil = true
			end
			if e.subtype.stun then
				is_stun = true
			end
			if e.subtype.pin then
				is_pin = true
			end
		end
		if not is_conf and not is_sil and not is_stun and not is_pin then return end
		
		if not is_conf and not is_sil and not is_stun and not is_pin then return end
		
		who:onTakeoff(self, inven_id, true)
		
		for i = 1, 5 do
		if is_conf then
			local add = 0
			if self.wielder.pin_immune > 0 then
				self.wielder.pin_immune = self.wielder.pin_immune - 0.01
				add = add + 0.01
			end
			if self.wielder.stun_immune > 0 then
				self.wielder.stun_immune = self.wielder.stun_immune - 0.01
				add = add + 0.01
			end
			if self.wielder.silence_immune > 0 then
				self.wielder.silence_immune = self.wielder.silence_immune - 0.01
				add = add + 0.01
			end
			self.wielder.confusion_immune = self.wielder.confusion_immune + add
		end
		
		if is_pin then
			local add = 0
			if self.wielder.confusion_immune > 0 then
				self.wielder.confusion_immune = self.wielder.confusion_immune - 0.01
				add = add + 0.01
			end
			if self.wielder.stun_immune > 0 then
				self.wielder.stun_immune = self.wielder.stun_immune - 0.01
				add = add + 0.01
			end
			if self.wielder.silence_immune > 0 then
				self.wielder.silence_immune = self.wielder.silence_immune - 0.01
				add = add + 0.01
			end
			self.wielder.pin_immune = self.wielder.pin_immune + add
		end
		
		if is_sil then
			local add = 0
			if self.wielder.pin_immune > 0 then
				self.wielder.pin_immune = self.wielder.pin_immune - 0.01
				add = add + 0.01
			end
			if self.wielder.stun_immune > 0 then
				self.wielder.stun_immune = self.wielder.stun_immune - 0.01
				add = add + 0.01
			end
			if self.wielder.confusion_immune > 0 then
				self.wielder.confusion_immune = self.wielder.confusion_immune - 0.01
				add = add + 0.01
			end
			self.wielder.silence_immune = self.wielder.silence_immune + add
		end
		
		if is_stun then
			local add = 0
			if self.wielder.pin_immune > 0 then
				self.wielder.pin_immune = self.wielder.pin_immune - 0.01
				add = add + 0.01
			end
			if self.wielder.confusion_immune > 0 then
				self.wielder.confusion_immune = self.wielder.confusion_immune - 0.01
				add = add + 0.01
			end
			if self.wielder.silence_immune > 0 then
				self.wielder.silence_immune = self.wielder.silence_immune - 0.01
				add = add + 0.01
			end
			self.wielder.stun_immune = self.wielder.stun_immune + add
		end
		end
		who:onWear(self, inven_id, true)
	end,
}

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {arcane=true},
	unique=true, rarity=240,
	name = "Imp Claw", image = "object/artifact/flame_imps_claw.png",
	unided_name = _t"red, mottled claw",
	color = colors.GOLD,
	level_range = {1, 12},
	desc = _t[[The battered remains of a flame imp's hand. It still burns with that unnatural flame.]],
	cost = 350,
	material_level = 1,
	wielder = {		
		lite = 1,
		see_stealth = 10,
	},
	max_power = 9, power_regen = 1,
	use_talent = { id = Talents.T_FLAME, level = 2, power = 9 },
}


newEntity{ base = "BASE_RING", define_as = "WHEEL_FATE",
	power_source = {arcane = true}, unique = true,
	name = "Wheel of Fate", image = "object/artifact/wheel_of_fate.png",
	desc = _t[["This isn't what I wished for!" - Howar Muransk, Cornac demonologist.

This band of gothic obsidian menaces with an embossed image of a grinning skull. It beckons you to tempt fate and put it on. Do you?]],
	unided_name = _t"strange black ring",
	level_range = {1, 30},
	rarity = 250,
	cost = 500,
	material_level = 2,
	material_level_min_only = true,
	wielder = {},
	stored_level = 0,
	on_cantakeoff = function(self, who) 
		if (who.level < self.stored_level) and who.max_level and who.level < who.max_level then
			game.logPlayer(who, "#RED#The ring refuses to be removed!")
			return true
		else
			return false
		end
	end,
	on_wear = function(self, who)
		self.worn_by = who
	end,
	on_takeoff = function(self)
		self.worn_by = nil
	end,
	special_desc = function(self)
		if not self.worn_by then return ("") end
		if self.worn_by.level < self.stored_level then
			if not self.worn_by.max_level or self.worn_by.level < self.worn_by.max_level then
				return ("Cannot be unequipped or rerolled until level %d."):tformat(self.stored_level)
			else
				return (_t"Can be unequipped, can't be rerolled.") 
			end
		else
			return (_t"Can be unequipped or rerolled.") 
		end
	end,
	use_force_worn = true,
	max_power = 1, power_regen = 1,
	use_power = { name = _t"re-generate the item with random stats. Can only be done three levels after the last reroll. Cannot be unequipped unless a reroll is available, or you are level 50", power = 1,
		no_npc_use = true,
		use = function(self, who)
			if who.level < self.stored_level then
				game.logPlayer(who, "#RED#The ring does not react.")
				return false
			end
			game:chronoCancel(_t"#CRIMSON#Your timetravel has no effect on pre-determined outcomes such as this.")
			
			local _, item, inven_id = who:findInAllInventoriesBy("define_as", "WHEEL_FATE")
			who:onTakeoff(self, inven_id, true)
			local o = game.zone:makeEntity(game.level, "object", {base_list=self:loadList("/data/general/objects/jewelry.lua"), type="jewelry", subtype="ring", not_properties={"unique"}, ego_filter={keep_egos=true, ego_chance=-1000}}, nil, true)
			if not o then return false end
			local art = game.state:generateRandart{base=o, lev=math.ceil(who.level * rng.avg(80,130)/100), egos=3, forbid_power_source={antimagic=true}} --Slightly over level to make up for RNG
			if not art then return false end
			
			art.name = _t"Wheel of Fate"
			art.define_as = "WHEEL_FATE"
			art.use_power = self.use_power
			art.max_power = self.max_power
			art.power_regen = 1
			art.power = self.power
			art.unique = true
			art.power_source = {arcane = true}
			art.image = self.image
			art.on_cantakeoff = self.on_cantakeoff
			art.on_wear = self.on_wear
			art.on_takeoff = self.on_takeoff
			art.special_desc = self.special_desc
			art.randart = false
			art.stored_level = self.stored_level + 3
			art.worn_by = who
			art.desc = self.desc
			art.keywords = nil
			art.short_name = nil
			art.use_talent = nil
			art.charm_on_use = nil
			
			art:identify(true)			
			
			local had_tinker = self.tinker
			self:replaceWith(art)
			
			who:onWear(self, inven_id, true)

			if had_tinker then
				local tinker = had_tinker:cloneFull()
				tinker.tinkered = nil
				who:doWearTinker(nil, nil, tinker, nil, nil, self, false)
			end

			game.logPlayer(who, "#GREEN#The skull embossed in the ring twists around momentarily. ...Did it just laugh?")
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_HELM",
	power_source = {technique=true},
	unique = true,
	name = "Helm of the Dominated", image = "object/artifact/helm_of_the_dominated.png",
	moddable_tile = "special/helm_of_the_dominated", moddable_tile_big = true,
	unided_name = _t"horned helm",
	desc = _t[[An experimental helmet designed to enhance the effects of the Doomelf corruption.]],
	level_range = {24, 32},
	rarity = 240,
	cost = 700,
	material_level = 3,
	special_desc = function(self) return _t"Increases the range of Haste of the Doomed by 1." end,
	wielder = {
		lite = -1,
		combat_armor = 9,
		fatigue = 4,
		silence_immune = 0.3,
		combat_dam = 10,
		combat_spellpower = 10,
		inc_stats = { [Stats.STAT_STR] = 2, [Stats.STAT_MAG] = 4, },
		talents_types_mastery = {
			["race/doomelf"] = 0.2,
		},
		control_haste_doom = 1,
	},
}

-------------------
--The Obsidian Treasures.
--Each one grants "Shadow Power," a stat which enhances the effects of all Obsidian Treasures.
--All items are uniformly black with minimalist descriptions.
--If someone would like to write lore for them, they are more than free to. They are just as fine ominously unexplained, of course. :) 
-- ~PureQuestion
-------------------
newEntity{ base = "BASE_HELM",
	power_source = {technique=true, arcane=true},
	unique = true, color = colors.BLACK,
	name = "The Black Crown", image = "object/artifact/the_black_crown.png",
	moddable_tile = "special/the_black_crown", moddable_tile_big = true,
	unided_name = _t"cracked obsidian crown",
	desc = _t[["For the demon who has everything."]],
	level_range = {35, 47},
	rarity = 225,
	cost = 170,
	material_level = 4,
	wielder = {
		combat_armor = 15,
		fatigue = 5,
		inc_stats = { [Stats.STAT_WIL] = 10, [Stats.STAT_CON] = 10},
		artifact_power_obsidian = 5,
		resists={
			[DamageType.DARKNESS] = 20,
			[DamageType.BLIGHT] = 20,
		},
		talents_types_mastery = {
			["corruption/demonic-pact"] = 0.2,
			["corruption/demon-seeds"] = 0.2,
		},
	},
	special_desc = function(self) return _t"Increases all saves by your Shadow Power." end,
	on_obsidian_power_update = function(self, who, inven_id, item, power)
		self.wielder.combat_physresist = power
		self.wielder.combat_mentalresist = power
		self.wielder.combat_spellresist = power
	end,
}

newEntity{ base = "BASE_AMULET",
	power_source = {arcane=true},
	unique = true,
	name = "The Black Core", color = colors.BLACK, image = "object/artifact/the_black_core.png",
	unided_name = _t"pitch black gemstone",
	desc = _t[["Lock your soul away, and death will never reach you."]],
	level_range = {15, 25},
	rarity = 225,
	cost = 300,
	material_level = 2,
	metallic = false,
	wielder = {
		infravision = 6,
		resists = { [DamageType.DARKNESS] = 15 },
		blind_immune = 1,
		die_at = -100,
		talents_types_mastery = {
			["corruption/black-magic"] = 0.2,
		},
		artifact_power_obsidian = 5,
--		learn_talent = { [Talents.T_DEMON_SEED_SHADOWMELD] = 1, }, --maybe
	},
	special_desc = function(self) return _t"Grants spellpower equal to your Shadow Power." end,
	on_obsidian_power_update = function(self, who, inven_id, item, power)
		self.wielder.combat_spellpower = power
	end,
}

newEntity{ base = "BASE_LONGSWORD",
	power_source = {arcane=true},
	unique = true,
	name = "The Black Spike", image = "object/artifact/the_black_spike.png",
	moddable_tile = "special/%s_hand_the_black_spike", moddable_tile_big = true,
	unided_name = _t"thin black sword", 
	level_range = {37, 50},
	color = colors.BLACK,
	rarity = 225,
	metallic = false,
	desc = _t[["All the better to pierce the heart of the world."]],
	cost = 400,
	require = { stat = { str=40 }, },
	material_level = 5,
	combat = {
		dam = 48,
		apr = 20, --Sharp!
		physcrit = 5,
		dammod = {str=1},
		convert_damage={[DamageType.DARKNESS] = 50,},
	},
	wielder = {
		resists = {
			[DamageType.DARKNESS] = 18,
			[DamageType.BLIGHT] = 12,
		},
		inc_damage = {
			[DamageType.DARKNESS] = 25,
		},
		resists_pen = {
			[DamageType.DARKNESS] = 15,
		},
		inc_stats = { [Stats.STAT_STR] = 10, [Stats.STAT_MAG] = 8 },
		artifact_power_obsidian = 5,
	},
	special_desc = function(self) return _t"Increases all damage penetration by 1% for each point of your Shadow Power." end,
	on_obsidian_power_update = function(self, who, inven_id, item, power)
		self.wielder.resists_pen = {all = power}
	end,
}

newEntity{ base = "BASE_LEATHER_BOOT",
	power_source = {arcane=true},
	unique = true,
	name = "The Black Boots", image = "object/artifact/the_black_boots.png",
	moddable_tile = "special/the_black_boots", moddable_tile_big = true,
	unided_name = _t"pair of pitch black boots",
	desc = _t[["It's a treacherous road to the top of the world."]],
	color = colors.BLACK,
	level_range = {10, 20},
	rarity = 225,
	cost = 100,
	material_level = 2,
	wielder = {
		combat_armor = 1,
		combat_def = 2,
		fatigue = 2,
		inc_stats = { [Stats.STAT_CUN] = 4, },
		artifact_power_obsidian = 5,
		inc_stealth = 10,
	},
	special_desc = function(self) return _t"Grants 2.5% movement speed for each point of Shadow Power." end,
	on_obsidian_power_update = function(self, who, inven_id, item, power)
		self.wielder.movement_speed = power/40
	end,
}

newEntity{ base = "BASE_RING",
	power_source = {arcane=true},
	unique = true,
	name = "The Black Ring", color = colors.BLACK, image = "object/artifact/the_black_ring.png",
	unided_name = _t"obsidian ring",
	desc = _t[["An innocuous bauble. Until you look through the hole."]],
	level_range = {17, 27},
	rarity = 225,
	cost = 300,
	material_level = 3,
	metallic = false,
	wielder = {
		inc_dam = { [DamageType.DARKNESS] = 10,  [DamageType.FIRE] = 10,},
		combat_spellresist = 7,
		artifact_power_obsidian = 5,
		talents_types_mastery = {
			["corruption/fearfire"] = 0.2,
		},
	},
	special_desc = function(self) return _t"Grants spell-crit equal to half of your Shadow Power." end,
	on_obsidian_power_update = function(self, who, inven_id, item, power)
		self.wielder.combat_spellcrit = math.ceil(power / 2)
	end,
	talent_on_spell = { {chance=10, talent=Talents.T_DARKFIRE, level=3} },
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	power_source = {arcane=true},
	unique = true,
	name = "The Black Plate", image = "object/artifact/the_black_plate.png",
	moddable_tile = "special/upper_body_the_black_plate", moddable_tile2 = "special/lower_body_the_black_plate", moddable_tile_big = true,
	unided_name = _t"pitch black breastplate",
	desc = _t[["Wreckage all about you. Is there anything left inside?"]],
	color = colors.BLACK,
	level_range = {40, 50},
	rarity = 225,
	require = { stat = { str=48 }, },
	cost = 800,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 6, [Stats.STAT_CUN] = 4, [Stats.STAT_CON] = 3,},
		resists = {
			[DamageType.ACID] = 15,
			[DamageType.BLIGHT] = 15,
			[DamageType.FIRE] = 25,
			[DamageType.COLD] = 20,
			[DamageType.DARKNESS] = 20,
		},
		combat_def = 25,
		combat_armor = 35,
		confusion_immune = 1,
		fear_immune = 1,
		combat_spellresist = 25,
		combat_physresist = 15,
		lite = -2,
		infravision=3,
		fatigue = 15,
		talents_types_mastery = {
			["corruption/oppression"] = 0.2,
			["corruption/wrath"] = 0.2,
			["corruption/infernal-combat"] = 0.2,
			["corruption/doom-covenant"] = 0.2,
		},
		artifact_power_obsidian = 10,
	},
	max_power = 15, power_regen = 1,
	special_desc = function(self) return _t"Grants physical power equal to your Shadow Power." end,
	on_obsidian_power_update = function(self, who, inven_id, item, power)
		self.wielder.combat_dam = power
	end,
}

newEntity{ base = "BASE_GREATMAUL",
	power_source = {arcane=true},
	unique = true,
	name = "The Black Maul", color = colors.BLACK, image = "object/artifact/the_black_maul.png",
	moddable_tile = "special/left_hand_the_black_maul", moddable_tile_big = true,
	unided_name = _t"massive black hammer",
	desc = _t[["A fitting weapon for the Champion."]],
	level_range = {38, 48},
	rarity = 225,
	require = { stat = { str=40 }, },
	cost = 400,
	material_level = 5,
	combat = {
		dam = 70,
		apr = 15,
		physcrit = 2,
		dammod = {str=1.3},
		talent_on_hit = { [Talents.T_OBLITERATING_SMASH] = {level=3, chance=10} },
	},
	wielder = {
		combat_atk = 20,
		combat_dam = 12,
		artifact_power_obsidian = 10, --Because it takes two slots, rather than because it's special
		talents_types_mastery = {
			["corruption/brutality"] = 0.2,
			["technique/2hweapon-assault"] = 0.2,
		},
	},
	max_power = 25, power_regen = 1,
	use_talent = { id = Talents.T_RECKLESS_STRIKE, level = 3, power = 25 },
	special_desc = function(self) return _t"Increases all damage by 1% for each point of your Shadow Power." end, --This one is stronger because it's two slots
	on_obsidian_power_update = function(self, who, inven_id, item, power)
		self.wielder.inc_damage = {all = power}
	end,
}

newEntity{ base = "BASE_SHIELD",
	power_source = {arcane=true},
	unique = true,
	name = "The Black Wall", image = "object/artifact/the_black_wall.png",
	moddable_tile = "special/%s_hand_the_black_wall", moddable_tile_big = true,
	unided_name = _t"massive obsidian shield",
	desc = _t[["With this, no one will ever harm you again."]],
	color = colors.BLACK,
	metallic = false,
	level_range = {40, 50},
	rarity = 225,
	require = { stat = { str=28 }, },
	cost = 350,
	material_level = 5,
	special_combat = {
		dam = 52,
		block = 200, --Subpar because of the res-all
		physcrit = 4.5,
		dammod = {str=1},
		damtype = DamageType.DARKNESS,
	},
	wielder = {
		on_melee_hit={[DamageType.DARKNESS] = 10},
		combat_armor = 9,
		combat_def = 12,
		combat_def_ranged = 15,
		fatigue = 28, --HEAVY. ALSO, RES-ALL
		learn_talent = { [Talents.T_BLOCK] = 1, },
		artifact_power_obsidian = 5,
		talents_types_mastery = {
			["corruption/doom-shield"] = 0.2,
			["technique/shield-defense"] = 0.2,
			["technique/shield-offense"] = 0.2,
		},
	},
	special_desc = function(self) return _t"Increases all resists by 0.4% for each point of your Shadow Power." end,
	on_obsidian_power_update = function(self, who, inven_id, item, power)
		self.wielder.resists = {all = math.ceil(power * 0.4)}
	end,
}

--BOSS DROPS, Included here so they can appear elsewhere. I don't really want to make a new file for two items. --

newEntity{ base = "BASE_LITE", define_as = "PLANAR_BEACON",
	power_source = {arcane=true},
	unique = true,
	name = "Planar Beacon", image = "object/artifact/planar_beacon.png",
	unided_name = _t"glowing red orb",
	level_range = {5, 15},
	color=colors.RED,
	encumber = 1,
	rarity = 240,
	desc = _t[[A strange orb of demonic origins. It glows with a surreal red light.]],
	cost = 200,
	max_power = 25, power_regen = 1,
	use_talent = { id = Talents.T_FEARSCAPE_SHIFT, level = 2, power = 25 },
	wielder = {
		lite = 3,
	},
}

newEntity{ base = "BASE_LEATHER_BELT", --Theming too silly? idk
	power_source = {arcane=true}, define_as = "ROGROTH_JAW",
	unique = true,
	name = "Jaw of Rogroth", image = "object/artifact/jaw_of_rogroth.png",
	unided_name = _t"tooth lined belt",
	desc = _t[[Rogroth's mouth happened to be about the same size as your waist. Interesting.]],
	color = colors.LIGHT_RED,
	level_range = {15, 25},
	rarity = 190,
	cost = 350,
	material_level = 3,
	wielder = {
		max_soul = 3,
		combat_spellpower = 5,
		combat_spellcrit = 5,
		vim_on_death = 4,
	},
	max_power = 24, power_regen = 1,
	use_power = { name = _t"deal darkness damage equal to your 350%% of your spellpower to a target, and, if it kills the target, restores 15% of max hp and all resources (except paradox and equilibrium)", power = 24,
		use = function(self, who)
			local tg = {type="bolt", range=5}
			local x, y, target = who:getTarget(tg)
			if not x or not y or not target then return nil end
			if core.fov.distance(who.x, who.y, x, y) > 5 then return nil end
			if not game.level.map.seens(x, y) or not who:hasLOS(x, y) then return nil end
			who:project(tg, x, y, engine.DamageType.DARKNESS, 3.5 * who:combatSpellpower())
			game.level.map:particleEmitter(who.x, who.y, tg.radius, "shadow_beam", {tx=x-who.x, ty=y-who.y})
			if target:attr("dead") and not target.summoner then
				local factor = 0.15
				who:heal(who.max_life * factor)
				who:incMana(who.max_mana * factor)
				who:incVim(who.max_vim * factor)
				who:incPsi(who.max_psi * factor)
				who:incHate(who.max_hate * factor)
				who:incStamina(who.max_stamina * factor)
				who:incPositive(who.max_positive * factor)
				who:incNegative(who.max_negative * factor)
			end
			return {id=true, used=true}
		end
	},
}

