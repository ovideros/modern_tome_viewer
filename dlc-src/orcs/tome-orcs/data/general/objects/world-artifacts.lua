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

loadIfNot("/data-orcs/general/objects/generic-world-artifacts.lua")

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {steam=true},
	unique = true,
	name = "Medical Urgency Vest", image = "object/artifact/medical_urgency_vest.png",
	moddable_tile = "special/upper_medical_urgency_vest", moddable_tile2 = "special/lower_medical_urgency_vest", moddable_tile_big = true,
	unided_name = _t"medical armour",
	desc = _t[[This light leather armour features a special medical injector.]],
	level_range = {25, 40},
	rarity = 270,
	cost = 200,
	require = { stat = { str=22 }, },
	material_level = 3,
	wielder = {
		combat_def = 6,
		combat_armor = 7,
		fatigue = 7,
		heal_factor = 0.2,
		combat_physresist = 15,
		inscriptions_data = { MEDICAL_URGENCY_VEST = {
			power = 80,
			cooldown_mod = 120,
			cooldown = 1,
		}},
		learn_talent = { [Talents.T_MEDICAL_URGENCY_VEST] = 1, },
	},
}

newEntity{ base = "BASE_HEAVY_BOOTS", define_as = "STEAM_POWERED_BOOTS",
	power_source = {steam=true},
	name = "Steam Powered Boots", unique = true,
	image = "object/artifact/voratun_power_armour_boots.png",
	moddable_tile = "special/boots_voratun_powergreaves",
	desc = _t[[Boots. But with steam power!]],
	level_range = {40, 50},
	cost = 700,
	material_level = 5,
	steam_boots_on_move = 3,
	special_desc = function(self, who) return ("Generate %d steam each time you walk."):tformat(self.steam_boots_on_move) end,
	callbackOnMove = function(self, who, moved, force, ox, oy, x, y)
		if not moved or force or (ox == who.x and oy == who.y) then return end
		who:incSteam(self.steam_boots_on_move)
	end,
	wielder = {
		combat_armor = 15,
		combat_def = 8,
		fatigue = 8,
		inc_stats = { 
			[Stats.STAT_STR] = 8, 
			[Stats.STAT_DEX] = 10, 
		},
		pin_immune=0.5,
		inc_damage = { [DamageType.FIRE] = 10 },
	},
	set_list = { {"define_as", "TINKER_POWER_ARMOUR5"}, {"define_as", "STEAM_POWERED_HELM"}, {"define_as", "STEAM_POWERED_GAUNTLETS"} },
	set_desc = { steamarmor =  _t"The more steam the better!" },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","pin_immune"}, 0.5)
		self:specialSetAdd({"steam_boots_on_move"}, 4)
	end,
}

newEntity{ base = "BASE_HELM", define_as = "STEAM_POWERED_HELM",
	power_source = {steam=true},
	name = "Steam Powered Helm", unique = true,
	image = "object/artifact/voratun_power_helm.png",
	moddable_tile = "special/head_voratun_powerhelm",
	desc = _t[[A Helmet. But with steam power!]],
	level_range = {40, 50},
	cost = 700,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_CON] = 5, },
		combat_def = 3,
		combat_armor = 12,
		fatigue = 10,
		blind_immune = 0.5,
		resists = { all = 10 },
	},
	set_list = { {"define_as", "TINKER_POWER_ARMOUR5"}, {"define_as", "STEAM_POWERED_BOOTS"}, {"define_as", "STEAM_POWERED_GAUNTLETS"} },
	set_desc = { steamarmor =  _t"The more steam the better!" },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","blind_immune"}, 0.5)
	end,
}

newEntity{ base = "BASE_GAUNTLETS", define_as = "STEAM_POWERED_GAUNTLETS",
	power_source = {steam=true},
	name = "Steam Powered Gauntlets", unique = true,
	image = "object/artifact/voratun_power_armour_gauntlets.png",
	moddable_tile = "special/hands_voratun_powergauntlets",
	desc = _t[[Gauntlets. But with steam power!]],
	level_range = {40, 50},
	cost = 700,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 6, [Stats.STAT_DEX] = 6 },
		inc_damage = { all=8 },
		combat_physcrit = 10,
		combat_steamcrit = 10,
		combat_critical_power = 30,
		combat_armor = 12,
		combat = {
			dam = 35,
			apr = 10,
			physcrit = 10,
			physspeed = 0.2,
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			damrange = 0.3,
		},
		disarm_immune = 0.5,
	},
	set_list = { {"define_as", "TINKER_POWER_ARMOUR5"}, {"define_as", "STEAM_POWERED_HELM"}, {"define_as", "STEAM_POWERED_BOOTS"} },
	set_desc = { steamarmor =  _t"The more steam the better!" },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","disarm_immune"}, 0.5)
	end,
}
newEntity{ base = "BASE_HEAVY_BOOTS",
	power_source = {steam=true},
	name = "Anti-Gravity Boots", unided_name = _t"overheating steel greaves",
	unique = true,
	image = "object/artifact/anti_gravity_boots.png",
	moddable_tile = "special/boots_voratun_powergreaves",
	desc = _t[[These boots seem to have been made by a... creative individual who seems to have decided that launching yourself through the air via rocketry qualifies as "anti-gravity".
They look like they will work, though.
Probably.
If you're very careful.]],
	level_range = {10, 25},
	cost = 300,
	rarity = 220,
	material_level = 2,
	wielder = {
		combat_armor = 8,
		combat_def = 8,
		fatigue = 8,
		combat_steampower=3,
		inc_stats = { 
			[Stats.STAT_STR] = 5, 
			[Stats.STAT_DEX] = 4, 
		},
		pin_immune=0.5,
		resists={
			[DamageType.FIRE] = 10,
		},
		inc_damage={
			[DamageType.FIRE] = 10,
		},
	},	
	max_power = 18, power_regen = 1,
	special_desc = function(self, who) return ("These boots have a %d%% chance to fail to operate properly (reduced by Cunning)."):tformat(self.use_power.fail_chance(self, who)) end,
	use_power = {
		name = function(self, who)
			local dam1 = who:damDesc(engine.DamageType.FIRE, self.use_power.damage1(self, who))
			local dam2 = who:damDesc(engine.DamageType.FIRE, self.use_power.damage2(self, who))
			return ("jump to a nearby location within range %d, blasting everything within radius 2 (%d burning fire damage, 2 tile knockback) of the jump point and within radius 3 (%d burning fire damage, 3 tile knockback) of the landing point (damage based on Cunning)"):tformat(self.use_power.range, dam1, dam2)
		end,
		fail_chance = function(self, who) return math.ceil(who:combatStatLimit("cun", 0, 15, 5)) end, --This is to keep these from being better than similar higher-tier artifacts.
		power = 18,
		range = 7,
		damage1 = function(self, who) return 12 + who:getCun()*0.8 end,
		damage2 = function(self, who) return 25 + who:getCun()*1.3 end,
		target = function(self, who) return  {type="ball", radius=3, selffire=false, nolock=true, pass_terrain=false, nowarning=true, range=self.use_power.range,requires_knowledge=false} end,
		tactical = {ATTACKAREA = {FIRE = 2}, CLOSEIN = 1, ESCAPE = 2},
		findlanding = function(self, who, tx, ty, tg) -- find landing spot near (tx, ty)
--			print(("[Anti-Gravity Boots] looking for landing at (%s, %s)"):format(tx, ty))
			if tx == who.x and ty == who.y and not game.level.map:checkEntity(tx, ty, engine.Map.TERRAIN, "block_move", who) then return tx, ty end
			local fx, fy, grids = util.findFreeGrid(tx, ty, 3, false, {[engine.Map.ACTOR]=true})
			if not fx then return false end
			for i, grid in ipairs(grids) do
				if who:canProject(tg, grid[1], grid[2]) then return grid[1], grid[2] end
			end
			return false
		end,
		use = function(self, who)

			local tg = self.use_power.target(self, who)
			local tx, ty = who:getTarget(tg)
			if not tx or not ty then return nil end
			local fx, fy, grids
			local tactic = not who.player and who.ai_state.tactic
--			print(("[Anti-Gravity Boots]--%s : target selected at (%s, %s)"):format(who.name, tx, ty))
			if tactic == "escape" then -- try to jump away
				x = who.x + (who.x - tx)*100
				y = who.y + (who.y - ty)*100
				local _ _, x, y = who:canProject(tg, x, y)
				if not x or not y then return nil end
				fx, fy = self.use_power.findlanding(self, who, x, y, tg)
				if not fx or not fy or core.fov.distance(fx, fy, tx, ty) <= core.fov.distance(who.x, who.y, tx, ty) then return nil end -- no spot further away from target
			else -- try to jump to target location
				local _ _, x, y = who:canProject(tg, tx, ty)
				if not x or not y then return nil end
				fx, fy = self.use_power.findlanding(self, who, x, y, tg)
				
				if not fx or not fx then
					game.logPlayer(who, "#LIGHT_RED#You see no place to land near there.")
					return nil
				end
				if tactic == "closein" and core.fov.distance(fx, fy, tx, ty) >= core.fov.distance(who.x, who.y, tx, ty) then return nil end
				if tactic == "attackarea" and core.fov.distance(fx, fy, tx, ty) > 3 then return nil end
			end
			local fail = (rng.percent(self.use_power.fail_chance(self, who)) or who:attr("never_move") or who:attr("encased_in_ice") or false)
			who:logCombat(nil, "#Source# ignites %s %s, creating a #LIGHT_RED#blast of fire#LAST# that %s!", who:his_her(), self:getName({no_add_name=true, do_color=true}), fail and ("engulfs %s spectacularly"):tformat(who:him_her()) or ("launches %s in the air"):tformat(who:him_her()))
			
			who:project({type="ball", range=0, radius=2, selffire=fail}, who.x, who.y, engine.DamageType.FIREKNOCKBACK_MIND, {dist=2, dam=self.use_power.damage1(self, who)})
			game.level.map:particleEmitter(who.x, who.y, tg.radius, "ball_fire", {radius=2})
			if fail then return {id=true, used=true} end
			
			local ox, oy = who.x, who.y
			who:move(fx, fy, true)
			if config.settings.tome.smooth_move > 0 then
				who:resetMoveAnim()
				who:setMoveAnim(ox, oy, 8, 5)
			end
			who:logCombat(nil, "#Source# lands in a #LIGHT_RED#firey explosion#LAST#!")
			local tg = {type="ball", range=0, radius=3, selffire=false}
			who:project(tg, who.x, who.y, engine.DamageType.FIREKNOCKBACK_MIND, {dist=3, dam=self.use_power.damage2(self, who)})
			game.level.map:particleEmitter(who.x, who.y, tg.radius, "ball_fire", {radius=3})
			game:playSoundNear(who, "talents/fire")
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_GAUNTLETS",
	power_source = {steam=true},
	name = "Assassin's Surprise", unided_name = _t"glistening steel gauntlets",
	unique = true, image = "object/artifact/gauntlet_assassins_surprise.png",
	desc = _t[[These steel gauntlets feature a hidden contraption embedded in the left index finger that fires poisonous bolts.]],
	level_range = {10, 20},
	cost = 220,
	material_level = 2,
	rarity = 200,
	use_no_energy=true,
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = 5},
		combat_armor = 4,
		melee_project={[DamageType.POISON] = 10},
		combat = {
			dam = 20,
			apr = 8,
			physcrit = 5,
			physspeed = 0.2,
			melee_project={[DamageType.CRIPPLING_POISON] = 10},
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			damrange = 0.3,
		},
		poison_immune = 0.2,
	},
	
	max_power = 24, power_regen = 1,
	use_power = {
		name = function(self, who)
			local dam = self.use_power.damage(self, who)
			local dur = dam.dur
			local damage = who:damDesc(engine.DamageType.NATURE, dam.dam)
			return ("fire a poisonous bolt out to range %d that deals %d nature damage and afflicts the target with crippling poison (%d%% fail chance) that deals %d addition nature damage over %d turns (damage based on Cunning)"):tformat(self.use_power.range, damage/dur, dam.fail, damage, dur)
		end,
		power = 12,
		range = 6,
		target = function(self, who) return {type="bolt", range=self.use_power.range} end,
		requires_target = true,
		tactical = {ATTACK = {NATURE = 2}, DISABLE = {poison = 1.5}},
		duration = 3,
		damage = function(self, who) return {dam=10+who:getCun()*0.6, dur=self.use_power.duration, fail=15} end,
		
		use = function(self, who)

			local dam = self.use_power.damage(self, who)
			local tg = self.use_power.target(self, who)
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			local act = game.level.map(x, y, engine.Map.ACTOR)
			who:logCombat(act or {x=x, y=y, name=_t"something"}, "#Source# fires a bolt of #GREEN#poison#LAST# at #target# from %s %s!", who:his_her(), self:getName({do_color = true, no_add_name = true}))
			dam.dam = who:steamCrit(dam.dam)
			who:project(tg, x, y, engine.DamageType.CRIPPLING_POISON, dam)
			local _ _, x, y = who:canProject(tg, x, y)
			game.level.map:particleEmitter(who.x, who.y, math.max(math.abs(x-who.x), math.abs(y-who.y)), "ooze_beam", {tx=x-who.x, ty=y-who.y})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_STEAMGUN",
	power_source = {steam=true},
	name = "Nacrush's Decimator", image = "object/artifact/gun_nakrushes_decimator.png",
	unided_name = _t"unwieldy gun", unique = true,
	level_range = {25, 32},
	rarity = 250,
	desc = _t[[Nacrush was known for a tendency towards overkill.]],
	special_desc = function(self) return _t"Knocks you back when fired." end,
	require = { stat = { dex=30, str=25 }, },
	cost = 400,
	material_level = 3,
	combat = {
		range = 5,
		apr = 25,
		dam_mult = 1.2,
	},
	on_archery_trigger = function(self, who, tg, params, target, talent)
		if who.turn_procs.unwieldy_gun or not target.x then return end
		who.turn_procs.unwieldy_gun = true
		if who:canBe("knockback") then
			who:knockback(target.x, target.y, rng.range(1, 3))
			who:logCombat(target, "#Source# recoils from the shot.")
		end
	end,
}

newEntity{ base = "BASE_STEAMGUN",
	power_source = {steam=true},
	name = "Signal", image = "object/artifact/signal.png",
	rarity = 200,
	unided_name = _t"red barreled steamgun", unique = true,
	level_range = {11, 19},
	use_no_energy = "fake",
	desc = _t[[An odd, stubby gun with a large, red barrel.]],
	require = { stat = { dex=20 }, },
	cost = 400,
	material_level = 2,
	combat = {
		range = 7,
		apr = 4,
		dam_mult = 1.25,
		travel_speed=3,
		convert_damage = {
			[DamageType.FIREBURN] = 80,
		},
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_FLARE, level = 3, power = 20 },
}

newEntity{ base = "BASE_STEAMGUN",
	power_source = {steam=true, arcane=true},
	name = "Glacia", image = "object/artifact/glacia.png",
	rarity = 200,
	unided_name = _t"frozen gun", unique = true,
	level_range = {30, 40},
	desc = _t[[Strange coils encircle this extremely cold gun.]],
	require = { stat = { dex=28 }, },
	cost = 400,
	material_level = 4,
	combat = {
		range = 7,
		apr = 7,
		dam_mult = 1.3,
		travel_speed=10,
		special_on_hit = {desc=_t"deal cold damage equal to 100 + the higher of your steam or spellpower, and attempt to freeze the target (20% chance).", fct=function(combat, who, target)
			game.level.map:particleEmitter(who.x, who.y, 0, "icebeam", {tx=target.x-who.x, ty=target.y-who.y})
			local dam = 100 + math.max(who:combatSpellpower(), who:combatSteampower())
			local tg = {type="hit", range=100}
			who:project(tg, target.x, target.y, engine.DamageType.COLD, dam, {type="freeze"})
			if rng.percent(20) then
				target:setEffect(target.EFF_FROZEN, 5, {hp=dam * 1.5, apply_power=math.max(who:combatSpellpower(), who:combatSteampower()), min_dur=1})
			end
		end},
	},
	wielder = {
		iceblock_pierce=20,
	},
}

newEntity{ base = "BASE_STEAMGUN",
	power_source = {steam=true},
	name = "Tinkerer's Twinblaster", image = "object/artifact/tinkerers_twinblaster.png",
	unided_name = _t"two barreled steamgun", unique = true,
	level_range = {4, 11},
	rarity = 220,
	desc = _t[[This gun seems to be some experiment in firing multiple shots simultaneously.
The design is somewhat rudimentary, but it seems to work.]],
	require = { stat = { dex=20 }, },
	cost = 400,
	material_level = 1,
	combat = {
		range = 4,
		apr = 4,
		dam_mult = 0.5,
		attack_recurse = 2,
		ranged_project = {[DamageType.PHYSICAL] = 5},
		use_resources = {steam = 3},
	},
}

newEntity{ base = "BASE_STEAMGUN",
	power_source = {steam=true},
	name = "Flashpoint", image = "object/artifact/flashpoint.png",
	unided_name = _t"overheated gun", unique = true,
	level_range = {1, 10},
	rarity = 200,
	desc = _t[["Have you ever looked at some guys and thought 'you know, I really wish they were on fire right now', but you didn't feel like walking all the way over there? Well, there's now a better way!"]],
	require = { stat = { dex=20 }, },
	cost = 400,
	material_level = 1,
	combat = {
		range = 5,
		apr = 5,
		dam_mult = 1.3,
	},
	wielder = {
		ranged_project = {[DamageType.FIREBURN] = 10},
	},
}

newEntity{ base = "BASE_STEAMGUN",
	power_source = {steam=true, psionic=true},
	name = "S.H. Spear", image = "object/artifact/s_h_spear.png",
	unided_name = _t"engraved steamgun", unique = true,
	level_range = {22, 30},
	rarity = 250,
	desc = _t[[This gun is engraved with a strange material which focuses mental powers.
It seems like your mind will operate even faster with this equipped.]],
	require = { stat = { dex=20, wil = 15 }, },
	cost = 400,
	material_level = 3,
	combat = {
		range = 7,
		apr = 5,
		dam_mult = 0.9,
	},
	wielder = {
		combat_mindspeed=0.1,
		combat_steamspeed=0.1,
		combat_mindpower = 10,
		combat_mindcrit = 2,
		combat_steampower=5,
		talent_cd_reduction = {
			[Talents.T_BOILING_SHOT] = 1,
			[Talents.T_BLUNT_SHOT] = 1,
			[Talents.T_VACUUM_SHOT] = 1,
		},
	},
}


newEntity{ base = "BASE_STEAMGUN",
	power_source = {steam=true, psionic=true},
	name = "Dreamweaver", image = "object/artifact/dreamweaver.png",
	unided_name = _t"shimmering steamgun", unique = true,
	level_range = {30, 40},
	rarity = 250,
	desc = _t[[This isn't so much a gun, as it is the idea of a gun.  You'll be able to remember it pretty easily if you lose it.]],
	require = { stat = { dex=24, wil = 18 }, },
	cost = 400,
	material_level = 4,
	combat = {
		range = 7,
		apr = 5,
		dam_mult = 1.1,
	},
	wielder = {
		combat_mindpower = 15,
		combat_mindcrit = 7,
		combat_steampower=5,
	},
	max_power = 20, power_regen = 1,
	use_power = {
		name = function(self, who) return ("throw the gun and cause it to explode, dealing by %d mind damage (based on Cunning and Willpower) to all targets in an area, attempting to put them to sleep, and disarming yourself for 3 turns"):tformat(self.use_power.dam(self, who)) end,
		power = 20,
		dam = function(self, who) return 150 + who:getCun() + who:getWil() end,
		range = 7,
		radius = 3,
		target = function(self, who) return {type="ball", friendlyfire=false, range=self.use_power.range, radius=self.use_power.radius} end,
		requires_target = true,
		tactical = {ATTACKAREA = {MIND = 2}},
		use = function(self, who)
			local tg = self.use_power.target(self, who)
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			game.logSeen(who, "%s tosses %s %s!", who:getName():capitalize(), who:his_her(), self:getName({do_color = true, no_add_name = true}))
			who:project(tg, x, y, engine.DamageType.MIND, self.use_power.dam(self, who))
			who:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if target then
				if target:canBe("sleep") then
					target:setEffect(target.EFF_SLEEP, 6, {src=who, power=self.use_power.dam(self, who)/2, no_ct_effect=true, apply_power=who:combatMindpower()})
					game.level.map:particleEmitter(target.x, target.y, 1, "generic_charge", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
				else
					game.logSeen(self, "%s resists the sleep!", target:getName():capitalize())
				end
			end
			end)	
			who:setEffect(who.EFF_DISARMED, 3, {})
			game.level.map:particleEmitter(x, y, tg.radius, "ball_light", {radius=tg.radius, tx=x, ty=y})
			return {id=true, used=true}
		end,	
	},
}


newEntity{ base = "BASE_STEAMGUN",
	power_source = {steam=true, psionic=true},
	name = "Thoughtcaster", image = "object/artifact/thoughtcaster.png",
	unided_name = _t"crystalline handgun", unique = true,
	level_range = {40, 50},
	rarity = 250,
	desc = _t[[From body, mind. From mind, body.]],
	require = { stat = { dex=25, wil = 20 }, },
	cost = 400,
	material_level = 5,
	combat = {
		range = 10,
		apr = 5,
		dam_mult = 1.1,
		special_on_hit = {desc=function(self, who, special)
				local dam = special.damage(self, who)
				return ("deal %0.2f mind damage (based on Mindpower) in a radius 1 around the target"):tformat(who:damDesc(engine.DamageType.MIND, dam))
			end,
			damage = function(self, who) return who:combatMindpower() end,
			fct=function(combat, who, target, dam, special)
				local tg = {type="ball", range=100, radius=1, friendlyfire=false}
				local damage = special.damage(self, who)
				who:project(tg, target.x, target.y, engine.DamageType.MIND, damage)
			end},
	},
	wielder = {
		combat_mindpower = 15,
		combat_mindcrit = 5,
		combat_steampower=15,
		combat_steamcrit=5,
		talent_cd_reduction = {
			[Talents.T_BLUNT_SHOT] = 3,
			[Talents.T_VACUUM_SHOT] = 2,
		},
	},
	on_wear = function(self, who)
		self.worn_by = who
	end,
	on_takeoff = function(self, who)
		self.worn_by = nil
	end,
	special_desc = function(self)
		return (_t"On hitting with a mindstar, deal physical damage equal to your steampower in radius 1 around the target.")
	end,
	callbackOnMeleeAttack = function(self, who, target, hitted, crit, weapon)
		if not hitted or not weapon or weapon.talented ~= "mindstar" then return end
		local tg = {type="ball", range=100, radius=1, friendlyfire=false}
		local damage = who:combatSteampower()
		who:project(tg, target.x, target.y, engine.DamageType.PHYSICAL, damage)
		return
	end,
}

newEntity{ base = "BASE_SHOT",
	power_source = {steam=true, nature=true}, define_as = "SPIDER_FANG",
	unique = true,
	name = "Spider's Fangs", image = "object/artifact/spiders_fangs.png",
	unided_name = _t"pouch of envenomed shots",
	desc = _t[[A dedicated technician seems to have built pockets of spider venom into these rounds. It's not clear how happy the spiders were about this.]],
	color = colors.GREEN,
	level_range = {30, 40},
	rarity = 300,
	cost = 100,
	material_level = 4,
	require = { stat = { dex=24 }, },
	special_desc = function(self)
		local maxp = self:min_power_to_trigger()
		return ("%s"):tformat(self.power < maxp and ("(cooling down: %d turns)"):tformat(maxp - self.power) or _t"Ready to trigger!") 
	end,
	combat = {
		capacity = 20,
		dam = 22,
		apr = 8,
		physcrit = 2,
		dammod = {dex=0.7, cun=0.5},
		damtype = DamageType.NATURE,
		special_on_crit = {desc=_t"bursts into an cloud of spydric poison, pinning those inside (with a 10 turn cooldown)",on_kill=1, fct=function(combat, who, target)
			local duration = 4
			local radius = 1
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "SPIDER_FANG")
			if not o or not who:getInven(inven_id).worn then return end
			if o.power < o:min_power_to_trigger() then return end
			local dam = (10 + who:getCun())
			-- Add a lasting map effect
			game.level.map:addEffect(who,
				target.x, target.y, duration,
				engine.DamageType.SPYDRIC_POISON, dam,
				radius,
				5, nil,
				{type="acidstorm", only_one=true},
				nil,
				false
			)
			
			o.power=0
		end},
	},
	max_power = 10, power_regen = 1,
	min_power_to_trigger = function(self) return self.max_power * (self.worn_by and (100 - (self.worn_by:attr("use_object_cooldown_reduce") or 0))/100 or 1) end, -- special handling of the Charm Mastery attribute
}

newEntity{ base = "BASE_SHOT",
	power_source = {psionic=true, nature=true},
	unique = true,
	name = "Scattermind", image = "object/artifact/scattermind.png",
	unided_name = _t"shattered mindstar",
	desc = _t[[A linen pouch of jagged mindstar fragments, each radiating a palpable sense of confusion and pain. They must have made up an impressive whole originally, before some cretin turned it to bits.]],
	color = colors.GREEN,
	level_range = {20, 30},
	rarity = 300,
	cost = 100,
	material_level = 3,
	require = { stat = { dex=24 }, },
	combat = {
		capacity = 20,
		dam = 17,
		apr = 7,
		physcrit = 3,
		dammod = {dex=0.6, cun=0.6},
		damtype = DamageType.MIND,
		special_on_crit = {desc=_t"strike the target with one of Mind Sear, Psychic Lobotomy, or Sunder Mind, at random.", fct=function(combat, who, target)
			local randtalent = rng.table{ who.T_SUNDER_MIND, who.T_PSYCHIC_LOBOTOMY, who.T_MIND_SEAR  }
			who:forceUseTalent(randtalent, {ignore_cd=true, ignore_energy=true, force_target=target, force_level=3, ignore_ressources=true})
		end},
	},
}

newEntity{ base = "BASE_SHOT",
	power_source = {steam=true, arcane=true},
	unique = true,
	name = "Thundercrack", image = "object/artifact/thundercrack.png",
	unided_name = _t"pouch of copper shots",
	desc = _t[[Through a combination of magic and airborne probes, these shots incite powerful bolts of lightning to strike your target from above, frying them and those around them!]],
	color = colors.LIGHT_BLUE,
	level_range = {40, 50},
	rarity = 300,
	cost = 100,
	material_level = 5,
	require = { stat = { dex=24 }, },
	combat = {
		capacity = 16,
		dam = 35,
		apr = 8,
		physcrit = 2,
		dammod = {dex=0.7, cun=0.5},
		damtype = DamageType.PHYSICAL, --The shot
		special_on_hit = {desc=_t"a bolt of lightning strikes your target, dealing lightning damage to them and fire damage to those around them.",on_kill=1, fct=function(combat, who, target)
			local tg = {type="ball", range=0, radius=3, selffire=false, start_x=target.x, start_y=target.y}
			local tgg = {type="ball", range=0, radius=0, selffire=false, start_x=target.x, start_y=target.y}
			game.level.map:particleEmitter(target.x, target.y, 20, "lightning", {tx=0, ty=-20})
			local grids = who:project(tg, target.x, target.y, engine.DamageType.FIRE, 40 + who:getMag()*0.6 + who:getCun()*0.6)
			local grids = who:project(tgg, target.x, target.y, engine.DamageType.LIGHTNING, 40 + who:getMag()*0.6 + who:getCun()*0.6)
			game.level.map:particleEmitter(target.x, target.y, tg.radius, "ball_fire", {radius=tg.radius})
		end},
	},
}


newEntity{ base = "BASE_STEAMGUN",
	power_source = {steam=true, arcane = true},
	name = "Vindicator", image = "object/artifact/vindicator.png",
	unided_name = _t"engraved gun", unique = true,
	level_range = {20, 30},
	desc = _t[["Pesky undead plaguing your village? Necromancers ransacking your burial grounds? The Vindicator is the solution to all your woes!"]],
	require = { stat = { dex=30 }, },
	cost = 400,
	rarity = 250,
	material_level = 3,
	combat = {
		range = 7,
		apr = 20,
		dam_mult = 1,
		inc_damage_type = {undead=25},
		special_on_crit = {desc=_t"release a burst of light dealing damage equal to your cunning plus your magic in a ball of radius 2. If the target is undead, the damage and radius are doubled.", on_kill=1, fct=function(combat, who, target)
			local tg = {type="ball", range=0, radius=2, friendlyfire=false, start_x=target.x, start_y=target.y}
			local damage = who:getCun() + who:getMag()
			if target.undead then
				damage = damage * 2
				tg.radius = tg.radius * 2
			end
			local grids = who:project(tg, target.x, target.y, engine.DamageType.LIGHT, damage)
			game.level.map:particleEmitter(target.x, target.y, tg.radius, "ball_light", {radius=tg.radius})
		end},
	},
}

newEntity{ base = "BASE_STEAMGUN",
	power_source = {steam=true},
	name = "Overburst", image = "object/artifact/overburst.png",
	unided_name = _t"wide barreled steamgun", unique = true,
	level_range = {30, 40},
	desc = _t[["Have you ever fired a shot into a group of monsters and thought 'there must be a better way?' Well now, there is!"]],
	require = { stat = { dex=30 }, },
	cost = 400,
	rarity = 250,
	material_level = 4,
	combat = {
		range = 7,
		apr = 20,
		dam_mult = 1.2,
		special_on_hit = {desc=_t"Release a burst of shrapnel, dealing physical damage equal to your steampower in a cone from the target of radius 4.", on_kill=1, fct=function(combat, who, target)
			local a = math.atan2(target.y - who.y, target.x - who.x)
			local dx, dy = target.x + math.cos(a) * 100, target.y + math.sin(a) * 100
			local tg = {type="cone", range=0, radius=4, friendlyfire=false, start_x=target.x, start_y=target.y}
			local damage = who:combatSteampower()
			local grids = who:project(tg, dx, dy, engine.DamageType.PHYSICAL, damage)
			game.level.map:particleEmitter(target.x, target.y, 4, "directional_shout", {life=8, size=3, tx=dx-target.x, ty=dy-target.y, distorion_factor=0.1, radius=4, nb_circles=8, rm=0.8, rM=1, gm=0.4, gM=0.6, bm=0.1, bM=0.2, am=1, aM=1})
		end},
	},
}


newEntity{ base = "BASE_STEAMGUN",
	power_source = {steam=true},
	name = "Murderfang's Surekill", image = "object/artifact/murderfangs_surekill.png",
	unided_name = _t"wide barreled steamgun", unique = true,
	level_range = {30, 40},
	desc = _t[["Murderfang came over yesterday, raving about this idea for a steamgun he had. He described it in great detail, everything, except for how it would actually work.
What do you even grip it by? Insisted I make it though, left some design notes.
They all just say 'make it really flashy'.
 
-Pizurk, Master Tinker]],
	require = { stat = { dex=40, cun =30 }, },
	cost = 400,
	rarity = 250,
	material_level = 3,
	combat = {
		range = 6,
		apr = 20,
		dam_mult = 1,
		physcrit=-10,
		travel_speed=15, --Superfast, partly for the crushing blows active
		special_on_crit = {desc=_t"Burst apart, dealing physical damage equal to 25% of the original damage in a ball of radius 1.", on_kill=1, fct=function(combat, who, target, dam)
			local tg = {type="ball", range=0, radius=1, friendlyfire=false, start_x=target.x, start_y=target.y}
			local damage = dam * 0.25
			who:project(tg, who.x, who.y, function(px, py)
				local target2 = game.level.map(px, py, engine.Map.ACTOR)
				if not target2 or target2 == target then return end
				local tg2 = {type="ball", range=0, radius=0, friendlyfire=false, start_x=target2.x, start_y=target2.y}
				who:project(tg2, target2.x, target2.y, engine.DamageType.PHYSICAL, damage)
			end)
			game.level.map:particleEmitter(target.x, target.y, 1, "force_blast", {radius=1})
		end},
	},
	wielder = {
		learn_talent = { [Talents.T_GUN_SUREKILL] = 3,},
		combat_critical_power = 50,
	},
}

newEntity{ base = "BASE_STEAMGUN",
	power_source = {steam=true},
	name = "The Long-Arm", image = "object/artifact/the_long_arm.png",
	unided_name = _t"long barreled gun", unique = true,
	level_range = {42, 50},
	slot_forbid = "OFFHAND", twohanded = true, double_weapon = true, offslot = table.NIL_MERGE,
	desc = _t[[This gun has an absurdly long barrel. You wonder for whom it may have been designed.]],
	moddable_tile = "special/%s_the_long_arm",
	require = { stat = { dex=30 }, },
	cost = 600,
	material_level = 5,
	use_no_energy=true,
	rarity = 300,
	combat = {
		range = 10,
		apr = 25,
		dam_mult = 2.5,
		physspeed= 1.5,
		tg_type = "beam",
		use_resources = {steam = 6}
	},
	max_power = 20, power_regen = 1,
	use_power = {
		name = function(self, who)
			return ("Focus your aim on a target, marking them for death - reducing their ranged defense by %d and their resistances by %d%%"):tformat(self.use_power.def, self.use_power.dam)
		end,
		range = 10,
		duration = 5,
		power = 20,
		dam = 10,
		def = 15,
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
				who:logCombat(target, "#Source# takes aim at #target# using %s!", self:getName({do_color=true, no_add_name=true}))
				target:setEffect(target.EFF_MARKED_LONGARM, self.use_power.duration, {dam = self.use_power.dam, def = self.use_power.def})				
			end)
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_STEAMGUN", define_as = "STEAMGUN_ANNIHILATOR",
	power_source = {steam=true},
	name = "Annihilator", image = "object/artifact/annihilator.png",
	unided_name = _t"gigantic many barreled gun", unique = true,
	level_range = {45, 50},
	slot_forbid = "OFFHAND", twohanded = true, double_weapon = true, offslot = table.NIL_MERGE,
	desc = _t[[This gun features a wheel with several barrels attached and seems to be powered by an engine. It looks... impressive.]],
	special_desc = function(self) return _t"Fire rate increases while firing, up to 5 shots per turn. Resets after 5 turns without firing." end,
	moddable_tile = "special/%s_annihilator",
	require = { stat = { dex=30 }, },
	cost = 1000, --Miniguns are expensive, yo
	material_level = 5,
	sentient = true,
	fired = 0,
	rarity = 400, -- Many rare
	combat = {
		range = 8,
		apr = 12,
		dam_mult = 1,
		physspeed= 1.5,
		use_resources = {steam = 1},
		special_on_hit = {desc=_t"50% chance to reload 1 ammo", on_kill=1, fct=function(combat, who, target)
			if not rng.percent(50) then return end
			local ammo = who:hasAmmo()
			if not ammo or not ammo.combat or not ammo.combat.shots_left then return end
			ammo.combat.shots_left = util.bound(ammo.combat.shots_left + 1, 0, ammo.combat.capacity)
		end},
	},
	on_wear = function(self, who)
		self.worn_by = who
	end,
	on_takeoff = function(self, who) self.worn_by = nil end,
	act = function(self) 
		self:useEnergy()
		self:regenPower()
		if not self.worn_by then return end
		if self.fired > 0 then
			self.fired = self.fired - 1
		end
		if self.fired == 0 then
			self.combat.physspeed = 1.5
		end
	end,
	on_archery_trigger = function(self, who, tg, params, target, talent)
		if who.turn_procs.unwieldy_gun or not target.x then return end
		who.turn_procs.unwieldy_gun = true
		self.fired = 5
		if self.combat.physspeed > 0.3 then
			self.combat.physspeed = self.combat.physspeed - 0.12
		end
	end,
}

newEntity{ base = "BASE_STEAMGUN",
	power_source = {steam=true},
	name = "The Shotgonne", image = "object/artifact/shotgonne.png",
	unided_name = _t"huge gun", unique = true,
	level_range = {35, 45}, 
	moddable_tile = "special/%s_the_shotgonne",
	slot_forbid = "OFFHAND", twohanded = true, double_weapon = true, offslot = table.NIL_MERGE,
	encumber = 9,
	desc = _t[[This huge steamgun can be loaded with more than one bullet so that multiple shots can be fired in a nasty cone of death.
It also seems to have been carefully balanced to work like a dual gun set.]],
	require = { stat = { dex=40, str=25 }, },
	cost = 700,
	material_level = 5,
	rarity = 320,
	combat = {
		range = 6,
		apr = 10,
		dam_mult = 1.25, -- very powerful, can triple-shoot the primary target
		use_resources = {steam = 4}
	},
	special_desc = function(self) return _t"When fired, shoots up to 4 extra shots at random foes with a radius 4 cone centered on the target." end,

	on_archery_trigger = function(self, who, tg, params, target, talent)
		if not target.x or who.turn_procs.shotgonning then return end

		local weapon, ammo, offweapon = who:hasDualArcheryWeapon("steamgun")
		if weapon ~= self or not ammo then return end -- must be primary

		who.turn_procs.shotgonning = true -- make sure this is only triggered once per turn

		local tgts = {}
		who:project({type="cone", radius=4, range=0}, target.x, target.y, function(px, py)
			local tgt = game.level.map(px, py, engine.Map.ACTOR)
			-- make sure extra shots are not fired into a target in front of other targets.
-- Note: Need to add support for an "actorblock" parameter to the target table (make aoe projections stop at any actor) to obviate this kludge....
			if not tgt or not who:canProject({type="bolt"}, px, py) then return end
			tgts[#tgts+1] = tgt
		end)
		local nb = 4
		local targets = {main={}, off={}, dual=true}
		-- Note: higher steam cost compensates for not deducting firing costs here (alternatively could manually deduct costs with each extra shot
		while #tgts > 0 and nb > 0 and ammo.combat.shots_left > 0 do
			ammo.combat.shots_left = ammo.combat.shots_left - 1
			nb = nb - 1
			local tgt = rng.tableRemove(tgts)
			targets.main[#targets.main+1] = {x=tgt.x, y=tgt.y, ammo=ammo.combat}
		end
		if #targets.main > 0 then
			who:archeryShoot(targets, who:getTalentFromId(who.T_SHOOT), nil, nil)
		end
	end,
}

newEntity{ base = "BASE_CLOAK",
	power_source = {steam=true},
	unique = true,
	name = "Cloak of Daggers", image = "object/artifact/cloak_of_daggers.png",
	unided_name = _t"bladed cloak",
	desc = _t[[This cloak seems to incorporate a series of blades attached to various spring mechanisms.  Apparently the designer believed that the best defense was an active one.]],
	level_range = {30, 40},
	rarity = 240,
	cost = 200,
	material_level = 4,
	sentient = true,
	wielder = {
		combat_def = 10,
		combat_dam = 5,
		combat_physresist = 10,
		inc_stats = { [Stats.STAT_CUN] = 6,},
	},
	bleed_damage = function(self, who) return 40+ who:getCun() * 1.5 end,
	special_desc = function(self, who)
		local dam = who:damDesc(engine.DamageType.PHYSICAL, self:bleed_damage(who))
		return ("Has a 50%% chance each turn to slash an adjacent enemy for %d physical damage (based on Cunning), making them bleed."):tformat(dam)
	end,
	act = function(self)
		self:useEnergy()
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) then self.worn_by = nil return end
		if self.worn_by:attr("dead") then return end
		if not rng.percent(50)  then return end
		local who = self.worn_by
		local Map = require "engine.Map"
		--local project = require "engine.DamageType"
		local tgts = {}
		local DamageType = require "engine.DamageType"
		--local project = "engine.ActorProject"
		local grids = core.fov.circle_grids(who.x, who.y, 1, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and who:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		local tg = {type="hit", range=1,}
		if #tgts <= 0 then return end
		local a, id = rng.table(tgts)
		table.remove(tgts, id)
--		who:project(tg, a.x, a.y, engine.DamageType.PHYSICALBLEED, 40+ who:getCun() * 1.5 )
		who:project(tg, a.x, a.y, engine.DamageType.PHYSICALBLEED, self:bleed_damage(who))
		game.level.map:particleEmitter(a.x, a.y, 1, "melee_attack", {color=a.blood_color,}) 
		game:playSoundNear(self, "actions/melee")
		who:logCombat(a, "#Source#'s %s #GOLD#lashes out#LAST#, cutting #Target#!", self:getName({do_color=true, no_add_name=true}))
	end,
	on_wear = function(self, who)
		self.worn_by = who
	end,
	on_takeoff = function(self)
		self.worn_by = nil
	end,
}

newEntity{ base = "BASE_CLOAK",
	power_source = {steam=true},
	unique = true,
	name = "Jetpack", image = "object/artifact/jetpack.png",
	unided_name = _t"a jetpack",
	desc = _t[[Finally.]],
	level_range = {40, 50},
	rarity = 240,
	cost = 200,
	material_level = 5,
	sentient = true,
	metallic=true,
	wielder = {
		combat_def = 10,
		combat_dam = 5,
		combat_physresist = 10,
		inc_stats = { [Stats.STAT_CUN] = 6,},
		movement_speed=0.1,
		avoid_pressure_traps = 1,
		learn_talent = {[Talents.T_ROCKET_DASH] = 1},
	},
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	power_source = {technique = true, steam = true},
	unique = true,
	name = "Therapeutic Platemail", image = "object/artifact/armor_plate_therapeutic_armor.png",
	moddable_tile = "special/upper_armor_plate_therapeutic_armor", moddable_tile2 = "special/lower_armor_plate_therapeutic_armor", moddable_tile_big = true,
	unided_name = _t"heated armor",
	desc = _t[[This thick sealed armor utilizes a ventilation system to heal your wounds using a heated mist.]],
	color = colors.BROWN,
	level_range = {10, 20},
	rarity = 220,
	require = { stat = { str=22 }, },
	cost = 300,
	material_level = 2,
	encumber = 12,
	wielder = {
		inc_stats = { [Stats.STAT_CON] = 3, [Stats.STAT_DEX] = 3,},
		combat_armor = 10,
		combat_steampower = 10,
		combat_def = 4,
		fatigue = 22,
		resists = {
			[DamageType.COLD] = 15,
			[DamageType.FIRE] = 10,
		},
		healing_factor = 0.3,
	},
	max_power = 20, power_regen = 1,
	use_power = {
		on_pre_use = function(self, who)
			return #(who:effectsFilter(function(e) return e.subtype.wound or e.subtype.poison end, 1)) > 0
		end,
		name = function(self, who)
			return _t"cleanse up to 3 poisons or wounds detrimental effects"
		end,
		power = 12,
		tactical = {DEFEND = 2},
		use = function(self, who)
			if not self.use_power.on_pre_use(self, who) then return end
			who:removeEffectsFilter(who, function(e) return e.subtype.wound or e.subtype.poison end, 3)
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_STEAMGUN",
	power_source = {steam=true},
	name = "Titan",
	unided_name = _t"huge gun", unique = true,
	level_range = {5, 17},
	image = "object/artifact/steam_gun_titan.png",
	desc = _t[[A gun sure to turn all to ash. As long as its nearby.]],
	require = { stat = { dex=20 }, },
	cost = 300,
	rarity = 280,
	material_level = 2,
	combat = {
		range = 3,
		apr = 20,
		dam_mult = 1.75,
	},
}

newEntity{ base = "BASE_STEAMGUN", define_as = "GOLDEN_GUN",
	power_source = {steam=true},
	name = "Golden Gun", image = "object/artifact/golden_gun.png",
	unided_name = _t"golden gun", unique = true,
	level_range = {25, 35},
	desc = _t[[A gun sure to turn all to ash. As long as its nearby.]],
	require = { stat = { dex=20 }, },
	cost = 300,
	rarity = 240,
	charge=0,
	material_level = 3,
	combat = {
		range = 7,
		apr = 20,
		dam_mult = 1.2,
		physcrit=0,
		special_on_hit = {desc=_t"every third hit always crits.", fct=function(combat, who, target)
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "GOLDEN_GUN")
			if not o or not who:getInven(inven_id).worn then return end
			o.charge = o.charge + 1
			if o.charge == 3 then
				o.combat.physcrit=100
				o.charge = 0
			else
				o.combat.physcrit=0
			end
		end},
	},
}

newEntity{ base = "BASE_LONGSWORD",
	power_source = {steam=true},
	unique = true,
	name = "Cautery Sword",
	unided_name = _t"searing sword",
	image = "object/artifact/cautery_sword.png",
	desc = _t[[This sword is equipped with a heated core to add a bit of extra pain to the wounds.]],
	level_range = {20, 30},
	rarity = 215,
	require = { stat = { str=28 }, },
	cost = 300,
	material_level = 3,
	combat = {
		dam = 40,
		apr = 10,
		physcrit = 8,
		dammod = {str=1},
		special_on_hit = {desc=_t"inflict fire damage based on steampower", fct=function(combat, who, target)
			local tg = {type="ball", range=1, radius=0, selffire=false}
			who:project(tg, target.x, target.y, engine.DamageType.FIRE, who:combatSteampower())
		end},
	},
	wielder = {
		cut_immune=1,
	},
}

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {steam=true},
	unique=true, rarity=240,
	name = "Stimulus", image = "object/artifact/stimulus.png",
	unided_name = _t"autosyringe", subtype = "injector",
	color = colors.GOLD,
	level_range = {28, 40},
	desc = _t[[This injecting unit is complemented by a belt of tiny vials, containing some sickly yellow liquid. The papers describe the contents as 'invigorating' and 'increasing the combat potency.']],
	cost = 350,
	material_level = 4,
	use_no_energy = true,
	wielder = {		
		inc_stats = {[Stats.STAT_CUN] = 5,},
		combat_physresist = 15,
		combat_spellresist = 15,
		combat_mentalresist = 15,
		combat_def = 12,		
	},
	max_power = 20, power_regen = 1,
	use_power = {
		on_pre_use = function(self, who) return not who:attr("stimpak_capped") end,
		name = function(self, who)
			return _t"inject yourself with painkillers, reducing all incoming damage by 5. Stacks up to 5 times. When the effect ends, lose 5% of your max life per stack"
		end,
		power = 4,
		tactical = {DEFEND = 2},
		use = function(self, who)
			if not self.use_power.on_pre_use(self, who) then return end
			who:setEffect(who.EFF_STIMPAK, 6, {})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {steam=true, arcane=true, nature=true, technique=true, psionic=true, unknown=true},
	unique=true, rarity=370,
	name = "Qog's Essentials", image = "object/artifact/qogs_essentials.png",
	unided_name = _t"strange injector", subtype = "injector",
	color = colors.GOLD,
	level_range = {40, 50},
	desc = _t[[A hypospray full of ...something. There is no telling what you're injecting yourself with.]],
	cost = 350,
	material_level = 5,
	--use_no_energy = true,
	wielder = {		
		inc_stats = {[Stats.STAT_CUN] = 5,[Stats.STAT_CON] = 5,[Stats.STAT_STR] = 5,[Stats.STAT_MAG] = 5,[Stats.STAT_WIL] = 5,[Stats.STAT_DEX] = 5,},
	},
	max_power = 30, power_regen = 1,
	use_no_energy = true,
	use_power = {
		name = function(self, who)
			return _t"Gain a random beneficial effect"
		end,
		power = 30,
		tactical = {DEFEND = 2},
		use = function(self, who)
			local eff = rng.table{who.EFF_REGENERATION, who.EFF_EVASION, who.EFF_SPEED, who.EFF_DWARVEN_RESILIENCE, who.EFF_STONE_SKIN, who.EFF_ETERNAL_WRATH, who.EFF_SHELL_SHIELD, who.EFF_PAIN_SUPPRESSION, who.EFF_PRIMAL_ATTUNEMENT, who.EFF_PURGE_BLIGHT, who.EFF_HEROISM, who.EFF_MIGHTY_BLOWS, who.EFF_WILD_SPEED, who.EFF_HUNTER_SPEED, who.EFF_STEP_UP, who.EFF_DEFENSIVE_MANEUVER, who.EFF_LIGHTNING_SPEED, who.EFF_WATERS_OF_LIFE, who.EFF_FREE_ACTION, who.EFF_ADRENALINE_SURGE, who.EFF_LEAVES_COVER, who.EFF_COUNTER_ATTACKING, who.EFF_SPINE_OF_THE_WORLD, who.EFF_JUGGERNAUT, who.EFF_RELENTLESS_FURY, who.EFF_ARCANE_STORM, who.EFF_EARTHEN_BARRIER, who.EFF_REFLECTIVE_SKIN, who.EFF_INVISIBILITY, who.EFF_SUPERCHARGE_GOLEM, who.EFF_POWER_OVERLOAD, who.EFF_LIFE_TAP, who.EFF_ALL_STAT, who.EFF_TIME_SHIELD, who.EFF_DAMAGE_SHIELD, who.EFF_WRAITHFORM, who.EFF_SHIFTING_SHADOWS, who.EFF_PRESCIENCE, who.EFF_INVIGORATE, who.EFF_SURGE_OF_UNDEATH, who.EFF_BONE_SHIELD, who.EFF_ARCANE_SUPREMACY, who.EFF_HASTE, who.EFF_IRRESISTIBLE_SUN, who.EFF_TEMPORAL_FORM, who.EFF_CORRUPT_LOSGOROTH_FORM, who.EFF_RECEPTIVE_MIND, who.EFF_RIGHTEOUS_STRENGTH, who.EFF_OGRIC_WRATH, who.EFF_ELEMENTAL_SURGE_ARCANE, who.EFF_ELEMENTAL_SURGE_COLD, who.EFF_ELEMENTAL_SURGE_NATURE, who.EFF_BATTLE_SHOUT, who.EFF_WILLFUL_COMBAT, who.EFF_QUICKNESS, who.EFF_CONTROL, who.EFF_HALFLING_LUCK, who.EFF_DEADLY_STRIKES, who.EFF_ORC_FURY, who.EFF_CLEAR_MIND, who.EFF_HEART_STARTED, who.EFF_MILITANT_MIND, who.EFF_HIGHBORN_S_BLOOM, who.EFF_DRACONIC_WILL, who.EFF_UNSTOPPABLE}
			local getpower = who:getEffectFromId(eff)
			local powerup = (getpower.parameters.power or 0) * 2
			
			who:setEffect(eff, rng.range(4,7), {power = powerup, mind = 10, crits = 10, def = 10, armor = 10, max_power = 20,}) --Problem children: Halfling's Luck, Juggernaut, Wraithform, Righteous Strength
			return {id=true, used=true}
		end
	},
}

-- newEntity{ base = "BASE_GREATSWORD",
-- 	power_source = {steam=true}, --This may or may not just be a chainsaw.
-- 	name = "Sawrd", unique=true, image = "object/artifact/sawrd.png",
-- 	unided_name = _t"sawblade lined sword", color=colors.GREY,
-- 	desc = _t[[A brutal weapon of countless blades.]],
-- 	require = { stat = { str=35 }, },
-- 	level_range = {40, 50},
-- 	rarity = 240,
-- 	cost = 280,
-- 	material_level = 5,
-- 	combat = {
-- 		dam = 30,
-- 		apr = 19,
-- 		physcrit = 10,
-- 		dammod = {str=1.2},
-- 		attack_recurse = 3,
-- 		attack_recurse_procs_reduce = 3,
-- 		damtype=DamageType.PHYSICALBLEED,
-- 	},
-- 	wielder = {
-- 		inc_stats = { [Stats.STAT_STR] = 7, [Stats.STAT_DEX] = 7, [Stats.STAT_CUN] = 7 },
-- 		talents_types_mastery = {
-- 			["technique/2hweapon-assault"] = 0.2,
-- 		},
-- 	},
-- }


newEntity{ base = "BASE_SHIELD",
	power_source = {steam=true},
	unique = true,
	unided_name = _t"vibrating shield",
	name = "Deflector", image = "object/artifact/deflector.png",
	desc = _t[[The front plate of this shield vibrates at all times, covering some strange assembly you can't quite make sense of.]],
	moddable_tile = "special/%s_deflector",
	color = colors.LIGHT_GREY,
	rarity = 300,
	level_range = {34, 44,},
	require = { stat = { str=38 }, },
	cost = 400,
	material_level = 4,
	special_desc = function(self) return _t"Knocks melee attackers away. Distance scales with damage incoming." end,
	special_combat = {
		dam = 49,
		block = 230,
		physcrit = 7,
		dammod = {str=1.3},
	},
	wielder = {
		combat_armor = 11,
		combat_def = 22,
		fatigue = 8,
		combat_physresist = 20,
		learn_talent = { [Talents.T_BLOCK] = 4, },
	},
	callbackOnMeleeHit = function(self, who, target, dam)
		local dist = math.ceil(math.sqrt(dam)) / 10 + 1
		target:knockback(who.x, who.y, dist)
	end,
}

newEntity{ base = "BASE_GREATMAUL",
	power_source = {steam=true},
	unique = true,
	name = "Skysmasher", color = colors.UMBER, image = "object/artifact/skysmasher.png",
	unided_name = _t"rocket powered maul",
	desc = _t[[The discovery of rockets has proved incredibly dangerous. It is not always clear for whom.]],
	level_range = {40, 50},
	rarity = 270,
	require = { stat = { str=40 }, },
	cost = 250,
	material_level = 5,
	combat = {
		dam = 70,
		apr = 17,
		physcrit = 20,
		dammod = {str=1.3},
		burst_on_crit = {
			[DamageType.PHYSICAL] = 75,
			[DamageType.FIRE] = 75,
		},
	},
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_CUN] = 5, },
		learn_talent = { [Talents.T_ROCKET_SMASH] = 1,},
	},
}

newEntity{ base = "BASE_LEATHER_CAP",
	power_source = {psionic=true},
	unique = true,
	name = "Nimbus of Enlightenment", image = "object/artifact/nimbus_of_enlightenment.png",
	unided_name = _t"elaborate cap",
	level_range = {40, 50},
	color=colors.WHITE,
	encumber = 1,
	rarity = 300,
	metallic=true,
	special_desc = function(self) return _t"They are out to get you.\nThis is not real this is not real this is not real." end,
	desc = _t[[By all accounts, just an ordinary cooking pot with an array of antennae haphazardly soldered onto it. An attached manual contains nothing but fifty pages of deranged gibberish, nonsensical diagrams and lines upon lines of numbers with no apparent pattern or reason to them. 

Putting this on your head may not be the best idea.]],
	cost = 200,
	material_level=5,
	wielder = {
		combat_def=7,
		combat_mindpower=20,
		combat_mindcrit=10,
		combat_mentalresist = -25,
		infravision=5,
		confusion_immune=-0.3,
		max_psi=50,
		psi_on_crit = 5,
		hate_on_crit = 5,
	},
	callbackOnActBase = function(self, who)
		local rad = math.ceil(10)
		for i = who.x - rad, who.x + rad do for j = who.y - rad, who.y + rad do if game.level.map:isBound(i, j) then
			local actor = game.level.map(i, j, game.level.map.ACTOR)
			if actor and who:reactionToward(actor) < 0 and not actor:attr("hunted_difficulty_immune") then
				if rng.percent(10) then 
					actor:setEffect(actor.EFF_HUNTER_PLAYER, 10, {src=who})
				end
				if who:canSee(actor) and core.fov.distance(who.x, who.y, actor.x, actor.y) < 8 and not actor.been_demoned then
					self.doInnerDemon(actor,who)
					actor.been_demoned = 1
				end
			end
		end end end
	end,
	doInnerDemon = function(target, who)
		local x, y = util.findFreeGrid(target.x, target.y, 1, true, {[engine.Map.ACTOR]=true})
		if not x then
			return
		end
		if target:attr("summon_time") then return end

		local m = target:cloneActor{
			shader = "shadow_simulacrum",
			shader_args = { color = {0.6, 0.0, 0.3}, base = 0.6, time_factor = 1500 },
			no_drops = true, keep_inven_on_death = false,
			faction = who.faction,
			summoner = who, summoner_gain_exp=true,
			summon_time = 8,
			ai_target = {actor=target},
			ai = "summoned", ai_real = "tactical",
			name = ("%s's Shadow"):tformat(target:getName()),
			desc = _t[[itshereitshereitshereitshere
itshereitshereitshereitshere
itshereitshereitshereitshere
itshereitshereitshereitshere]],
		}
		m:removeAllMOs()
		m.make_escort = nil
		m.on_added_to_level = nil
		m.on_added = nil

		mod.class.NPC.castAs(m)
		engine.interface.ActorAI.init(m, m)

		m.exp_worth = 0
		m.energy.value = 0
		m.player = nil
		m.max_life = m.max_life / 2 / m.rank
		m.life = util.bound(m.life, 0, m.max_life)
		m.inc_damage.all = (m.inc_damage.all or 0) - 60
		m.forceLevelup = function() end
		m.on_die = nil
		m.die = nil
		m.puuid = nil
		m.on_acquire_target = nil
		m.no_inventory_access = true
		m.on_takehit = nil
		m.seen_by = nil
		m.can_talk = nil
		m.clone_on_hit = nil
		m.self_resurrect = nil
		if m.talents.T_SUMMON then m.talents.T_SUMMON = nil end
		if m.talents.T_MULTIPLY then m.talents.T_MULTIPLY = nil end
		
		-- Inner Demon's never flee
		m.ai_tactic = m.ai_tactic or {}
		m.ai_tactic.escape = 0
		
		-- Remove some talents
		local tids = {}
		for tid, _ in pairs(m.talents) do
			local t = m:getTalentFromId(tid)
			if t.no_npc_use then tids[#tids+1] = t end
		end
		for i, t in ipairs(tids) do
			if t.mode == "sustained" and m:isTalentActive(t.id) then m:forceUseTalent(t.id, {ignore_energy=true}) end
			m.talents[t.id] = nil
		end
		
		-- remove detrimental timed effects
		local effs = {}
		for eff_id, p in pairs(m.tmp) do
			local e = m.tempeffect_def[eff_id]
			if e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		while #effs > 0 do
			local eff = rng.tableRemove(effs)
			if eff[1] == "effect" then
				m:removeEffect(eff[2])
			end
		end

		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=60, rM=130, gm=20, gM=110, bm=90, bM=130, am=70, aM=180})

		game.logSeen(target, "#F53CBE#%s's shadow awakens!", target:getName():capitalize())
	end,
}

newEntity{ base = "BASE_CLOAK",
	power_source = {steam=true},
	unique = true,
	name = "Pressurizer", image = "object/artifact/cloak_pressurizer.png",
	unided_name = _t"heavy lined cloak",
	desc = _t[[This cloak hides and protects a series of powerful steam compressors.]],
	level_range = {10, 20},
	rarity = 240,
	cost = 200,
	material_level = 2,
	wielder = {
		combat_def = 8,
		combat_steampower = 10,
		combat_steamcrit = 10,
		talents_types_mastery = { 
			["steamtech/automation"] = 0.1, 
			["steamtech/avoidance"] = 0.1, 
		},
		inc_stats = {[Stats.STAT_DEX] = 3,},
	},
}

newEntity{ base = "BASE_LEATHER_HAT",
	power_source = {technique=true},
	unique = true,
	name = "Eastern Wood Hat", image = "object/artifact/eastern_wood_hat.png",
	unided_name = _t"worn leather hat",
	level_range = {36, 48},
	color=colors.BROWN,
	encumber = 2,
	rarity = 200,
	desc = _t[[This hat was made from materials from a forest whose name is long since lost, far in the east. It is said to have belonged to one of the first gunslingers.]],
	cost = 500,
	material_level=5,
	wielder = {
		combat_def=15,
		inc_stats = { [Stats.STAT_DEX] = 18, [Stats.STAT_CUN] = 12, },
		blind_immune=1,
		combat_atk = 40,
		combat_apr = 15,
		combat_steamcrit = 15,
		combat_physcrit = 10,
		inc_damage={
			[DamageType.PHYSICAL] = 10,
		},
		resists_pen={
			[DamageType.PHYSICAL] = 15,
		},
		talents_types_mastery = { ["steamtech/gunslinging"] = 0.2, ["steamtech/bullets-mastery"] = 0.2,},
	},
}

newEntity{ base = "BASE_LEATHER_HAT",
	power_source = {steam=true},
	unique = true,
	name = "Steamcatcher", image = "object/artifact/steamcatcher.png",
	unided_name = _t"pipe coated leather hat",
	level_range = {30, 42},
	color=colors.BROWN,
	encumber = 2,
	rarity = 200,
	desc = _t[[There's an old saying that most of your body heat escapes through your head. It's not true of body heat, but strangely, is actually true of steam.]],
	cost = 500,
	material_level=4,
	special_desc = function(self) return _t"On taking fire damage: Gain 5% of the damage as steam." end,
	wielder = {
		combat_def=12,
		inc_stats = { [Stats.STAT_CUN] = 10, },
		steam_regen=1,
		combat_steampower = 15,
		combat_steamcrit = 5,
		inc_damage={
			[DamageType.PHYSICAL] = 10,
		},
		resists={
			[DamageType.FIRE] = 15,
		},
	},
	callbackOnTakeDamage = function(self, who, src, x, y, type, dam, state)
		if type == engine.DamageType.FIRE then
			who:incSteam(dam/20)
		end
	end,
}


newEntity{ base = "BASE_LEATHER_BOOT", define_as = "SHOES_OF_MOVING_QUICKLY",
	power_source = {steam=true},
	unique = true,
	name = "Shoes of Moving Quickly", image = "object/artifact/shoes_of_moving_quickly.png",
	moddable_tile = "special/shoes_of_moving_quickly",
	unided_name = _t"rocket powered boots",
	desc = _t[[Accurately? Less so.]],
	color = colors.PURPLE,
	level_range = {30, 40},
	rarity = 200,
	cost = 100,
	material_level = 4,
	moving = false,
	special_desc = function(self) return _t"You move 3 spaces at once." end,
	wielder = {
		combat_armor = 12,
		combat_def = 10,
		fatigue = 3,
		combat_steampower=5,
		inc_stats = { [Stats.STAT_DEX] = 8, [Stats.STAT_CUN] = 8,},
		pin_immune = 1,
		knockback_immune = -1,
	},
	callbackOnMove = function(self, who, moved, force, ox, oy, x, y)
		if not moved or force or (ox == who.x and oy == who.y) then return end
		if self.moving == true then return end
		if who.running then return end
		self.moving = true
		who:knockback(ox, oy, 2)
		self.moving = false
	end,
}

newEntity{ base = "BASE_LEATHER_BELT",
	power_source = {steam=true, arcane=true},
	unique = true,
	name = "Band of Protection", image = "object/artifact/belt_of_protection.png",
	unided_name = _t"reinforced belt",
	desc = _t[[This belt utilizes an enchanted gem to focus a burst of steam into a powerful barrier.]],
	color = colors.GOLD,
	level_range = {20, 30},
	rarity = 200,
	cost = 380,
	material_level = 3,
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = 3,},
		combat_physresist = 10,
		combat_spellresist = 10,
		combat_steampower = 5,
	},
	max_power = 24, power_regen = 1,
	use_power = {
		name = function(self, who)
			return ("generate a personal shield that absorbs up to %d damage and damages attackers striking the wearer for %d fire damage while it lasts (based on Cunning)"):tformat(who:getShieldAmount(self.use_power.shield_power(self, who)), who:damDesc(engine.DamageType.FIRE, self.use_power.retaliate_damage(self, who)))
		end,
		shield_power = function(self, who) return 80 + who:getCun(200) end,
		retaliate_damage = function(self, who) return 10 + who:getCun()*.25 end,
		power = 24,
		tactical = {DEFEND = 2},
		on_pre_use = function(self, who) return not who:attr("damage_shield") end,
		use = function(self, who)
			if not self.use_power.on_pre_use(self, who) then return end
			who:setEffect(who.EFF_STEAM_SHIELD, 6, {power=self.use_power.shield_power(self, who), retaliate = self.use_power.retaliate_damage(self, who)})
			game:playSoundNear(who, "talents/arcane")
			game.logSeen(who, "%s summons a barrier of steam from %s %s!", who:getName():capitalize(), who:his_her(), self:getName({do_color=true, no_add_name=true}))
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_STEAMSAW",
	power_source = {steam=true, arcane=true},
	name = "Viletooth", image = "object/artifact/viletooth.png",
	unided_name = _t"rusted steamsaw", unique = true,
	level_range = {13, 22},
	desc = _t[[This aged looking saw is very rusty, and you think you see a thin layer of... something... on its blades.]],
	require = { stat = { str=20 }, },
	cost = 300,
	material_level = 2,
	rarity = 240,
	combat = {
		dam = 20,
		convert_damage={[DamageType.BLIGHT] = 50,},
		apr = 12,
		physcrit = 3,
		dammod = {str=1},
		block = 40,
		special_on_hit = {desc=_t"may infect the target with a random disease", fct=function(combat, who, target)
			if not rng.percent(33) then return end
			local eff = rng.table{"weakness", "decrep", "rotting",}
			if not target:canBe(eff) then return end
			if not who:checkHit(who:combatMindpower(), target:combatMentalResist()) then return end
			if eff == "weakness" then target:setEffect(target.EFF_WEAKNESS_DISEASE, 5, {src = who, str = who:combatSteampower() / 4, dam = 10})
			elseif eff == "rotting" then target:setEffect(target.EFF_ROTTING_DISEASE, 5, {src = who, con = who:combatSteampower() / 4, dam = 10})
			elseif eff == "decrep" then target:setEffect(target.EFF_DECREPITUDE_DISEASE, 5, {src = who, dex = who:combatSteampower() / 4, dam = 10})
			end
		end},
	},
	wielder = {
		combat_armor = 4,
		combat_def = 6,
		fatigue = 8,
		learn_talent = { [Talents.T_BLOCK] = 1, },
	},
}

newEntity{ base = "BASE_STEAMSAW",
	power_source = {steam=true, arcane=true},
	name = "Mirrorazor", image = "object/artifact/mirrorazor.png",
	unided_name = _t"rippling portal", unique = true,
	moddable_tile = "special/%s_mirrorazor",
	level_range = {30, 40},
	use_no_energy=true,
	metallic = false,
	rarity = 300,
	desc = _t[[The experiment of a mad chronomancer, this strange device is a portal into a backwards universe!
That is, everything there spins the opposite direction.
I guess it probably grinds things pretty well.]],
	require = { stat = { str=24 }, },
	cost = 300,
	material_level = 4,
	combat = {
		dam = 35,
		convert_damage={[DamageType.TEMPORAL] = 50,},
		apr = 23,
		physcrit = 5,
		dammod = {str=1},
		block = 60,
		talent_on_hit = { [Talents.T_TURN_BACK_THE_CLOCK] = {level=2, chance=8} },
	},
	wielder = {
		combat_armor = 5,
		combat_def = 20,
		fatigue = 8,
		resists={
			[DamageType.TEMPORAL] = 15,
		},
		learn_talent = { [Talents.T_BLOCK] = 2, },
	},

	callbackOnKill = function(self, who, target)
		if not self.lored_giants and rng.percent(1) and target and target.x and target.y then
			self.lored_giants = 1
			local o = mod.class.Object.new{
				type = "lore", subtype="lore", not_in_stores=true, no_unique_lore=true,
				unided_name = _t"scroll", identified=true,
				display = "?", color=colors.ANTIQUE_WHITE, image="object/scroll-lore.png",
				encumber = 0,
				checkFilter = function(self) if self.lore and game.party.lore_known and game.party.lore_known[self.lore] then print('[LORE] refusing', self.lore) return false else return true end end,
				desc = _t[[This parchment contains some lore.]],

				name = _t"time-warped paper scrap", lore="orcs-mirror-graynot-1", lore2="orcs-mirror-graynot-2",
				desc = _t[[It came a long way away!]],
				rarity = false,
				encumberance = 0,
				on_prepickup = function(self, who, idx)
					if who.player and self.lore then
						game.level.map:removeObject(who.x, who.y, idx)
						require("engine.ui.Dialog"):simpleLongPopup(_t"Screw that!", _t"Oh, for the love of...  You're way too busy to deal with this nonsense.  You rev up Mirrorazor again, re-syncing it with the Mirror Universe, and toss the note back in.  A different note flies out the other side, miraculously not torn to shreds by the massive difference in planetary rotations.", 500, function()
							game.party:learnLore(self.lore2)							
						end)
						game.party:learnLore(self.lore)
						return true
					end
				end,
			}
			game.level.map:addObject(target.x, target.y, o)

			game.bignews:saySimple(120, "#LIGHT_BLUE#Mirrorazor shudders as a note falls out from a different timeline!")
		end
	end,
	
	max_power = 30, power_regen = 1,
	use_power = {
		power = 30,
		name = _t"5 turns after use, mirror yourself across the map (centered around the location you were standing when activated).",
		use = function(self, who)
			who:setEffect(who.EFF_FLIP_SWAP, 5, {power = 1})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_STEAMSAW",
	power_source = {steam=true},
	name = "Razorlock", image = "object/artifact/razorlock.png",
	unided_name = _t"interlocked steamsaws", unique = true,
	slot_forbid = "OFFHAND", twohanded = true, double_weapon = true, offslot = table.NIL_MERGE,
	moddable_tile = "special/%s_razorlock",
	level_range = {40, 50},
	desc = _t[[This intricate set of steamsaws lock together in a nearly indecipherable system.
They sure seem sharp though.]],
	require = { stat = { str=40 }, },
	rarity = 270,
	cost = 300,
	material_level = 5,
	combat = {
		dam = 25,
		apr = 24,
		physcrit = 5,
		dammod = {str=1},
		block = 150,
		attack_recurse = 2,
	},
	wielder = {
		combat_armor = 10,
		combat_def = 11,
		fatigue = 13,
		learn_talent = { [Talents.T_BLOCK] = 5, },
	},
}

newEntity{ base = "BASE_STEAMSAW",
	power_source = {steam=true},
	name = "Ramroller", image = "object/artifact/ramroller.png",
	unided_name = _t"a... chariot?", unique = true,
	slot_forbid = "OFFHAND", twohanded = true, double_weapon = true, offslot = table.NIL_MERGE,
	moddable_tile = "special/%s_ramroller",
	level_range = {40, 50},
	desc = _t[["So we were thinking. You know what's better than saws? Really BIG saws. Unfortunately, no one could lift them. So we came up with an innovative new solution: Mount them on a motorized platform, allowing easy transportation and unparalleled cutting power!"]],
	require = { stat = { str=30 }, },
	rarity = 270,
	cost = 300,
	material_level = 5,
	special_desc = function(self) return _t"Moving builds up a stacking movement speed (caps at 25%) and damage bonus (caps at double). Hitting removes the bonus." end,
	combat = {
		dam = 40,
		basedam=40,
		apr = 24,
		physcrit = 5,
		dammod = {str=1},
		block = 180, --Unusually good for a saw, this is because of it being very much like a chariot
	},
	wielder = {
		combat_armor = 19,
		combat_def = 14,
		fatigue = 0, --You aren't lifting anything!
		learn_talent = { [Talents.T_BLOCK] = 5, },
		movement_speed = 0,
	},
	callbackOnMove = function(self, who, moved, force, ox, oy, x, y)
		if not moved or force or (ox == who.x and oy == who.y) then return end
		if self.wielder.movement_speed < 0.24 then
			who:attr("no_learn_talent_item_cd", 1)
			who:onTakeoff(self, inven_id, true)
			self.wielder.movement_speed = self.wielder.movement_speed + 0.025
			self.combat.dam = self.combat.basedam * (1 + self.wielder.movement_speed * 4)
			who:onWear(self, inven_id, true)
			who:attr("no_learn_talent_item_cd", -1)
		end
	end,
	callbackOnMeleeAttack = function(self, who, target, hitted, crit, weapon)
		who:attr("no_learn_talent_item_cd", 1)
		who:onTakeoff(self, inven_id, true)
		self.combat.dam = self.combat.basedam
		self.wielder.movement_speed=0
		who:onWear(self, inven_id, true)
		who:attr("no_learn_talent_item_cd", -1)
	end,
}

newEntity{ base = "BASE_STEAMSAW",
	power_source = {steam=true},
	name = "Overcutter", image = "object/artifact/overcutter.png",
	unided_name = _t"enormous steamsaw", unique = true,
	slot_forbid = "OFFHAND", twohanded = true, double_weapon = true, offslot = table.NIL_MERGE,
	level_range = {5, 12},
	moddable_tile = "special/%s_overcutter",
	desc = _t[[Earlier steamsaws were notably not meant to be used with one hand.]],
	require = { stat = { str=20 }, },
	rarity = 270,
	cost = 300,
	material_level = 1,
	combat = {
		dam = 13,
		apr = 12,
		physcrit = 2,
		dammod = {str=1},
		block = 70,
	},
	wielder = {
		combat_armor = 7,
		combat_def = 8,
		fatigue = 10,
		learn_talent = { [Talents.T_BLOCK] = 2, },
	},
}

newEntity{ base = "BASE_STEAMSAW",
	power_source = {steam=true},
	name = "Turbocutter", image = "object/artifact/turbocutter.png",
	unided_name = _t"red striped steamsaw", unique = true,
	level_range = {20, 30},
	rarity = 300,
	desc = _t[["Have you ever thought your steamsaws were just too slow? Well, have I got the thing for you..."]],
	require = { stat = { str=24 }, },
	cost = 300,
	material_level = 3,
	special_desc = function(self) return _t"Increases the speed bonus from Saw Wheels by 25%." end,
	combat = {
		dam = 30,
		apr = 23,
		physcrit = 4,
		dammod = {str=1},
		block = 50,
	},
	wielder = {
		combat_armor = 5,
		combat_def = 16,
		fatigue = 8,
		sawwheel_speed = 0.25,
		talents_types_mastery = {
			["steamtech/battlefield-management"] = 0.2,
			["steamtech/sawmaiming"] = 0.2,
		},
		learn_talent = { [Talents.T_BLOCK] = 2, },
	},
}

newEntity{ base = "BASE_STEAMSAW",
	power_source = {steam=true},
	name = "Whipsnap", image = "object/artifact/whipsnap.png",
	unided_name = _t"spring loaded steamsaw", unique = true,
	level_range = {12, 22},
	rarity = 280,
	desc = _t[["Sick of your pesky enemies hitting you with weapons? Well, with the new spring loaded Whipsnap, you can quickly put a stop to that!"]],
	require = { stat = { str=24 }, },
	cost = 300,
	material_level = 2,
	combat = {
		dam = 18,
		apr = 15,
		physcrit = 4,
		dammod = {str=1},
		block = 50,
		talent_on_hit = { T_TO_THE_ARMS = {level=2, chance=10}},
	},
	wielder = {
		combat_armor = 6,
		combat_def = 7,
		fatigue = 8,
		learn_talent = { [Talents.T_BLOCK] = 1, },
	},
}

newEntity{ base = "BASE_STEAMSAW",
	power_source = {steam=true},
	name = "Pinwheel", image = "object/artifact/pinwheel.png",
	unided_name = _t"spike tipped steamsaw", unique = true,
	level_range = {3, 11},
	rarity = 280,
	desc = _t[["Create new, exciting connections in other people's lives, such as between their feet and the floor!"]],
	require = { stat = { str=18 }, },
	cost = 300,
	material_level = 1,
	combat = {
		dam = 13,
		apr = 10,
		physcrit = 3,
		dammod = {str=1},
		block = 50,
		special_on_hit = {desc=_t"15% chance to pin the target", fct=function(combat, who, target)
			if not rng.percent(15) then return end
			target:setEffect(target.EFF_PINNED, 4, {apply_power=who:combatSteampower()})
		end},
	},
	wielder = {
		combat_armor = 4,
		combat_def = 7,
		fatigue = 7,
		learn_talent = { [Talents.T_BLOCK] = 1, },
	},
}

newEntity{ base = "BASE_STEAMSAW",
	power_source = {steam=true, arcane=true},
	name = "Frostbite", image = "object/artifact/frostbite.png",
	unided_name = _t"icy steamsaw", unique = true,
	level_range = {10, 20},
	rarity = 280,
	desc = _t[[Fashioned from magical ice, and perfect for carving ice - especially ice with someone else inside it.]],
	require = { stat = { str=18 }, },
	cost = 300,
	material_level = 2,
	metallic = false,
	combat = {
		dam = 18,
		apr = 12,
		physcrit = 3,
		dammod = {str=1},
		block = 60,
		convert_damage = {
			[DamageType.ICE] = 50,
		},
	},
	wielder = {
		combat_armor = 10,
		combat_def = 7,
		fatigue = 9,
		iceblock_pierce=40,
		learn_talent = { [Talents.T_BLOCK] = 1, },
	},
}


newEntity{ base = "BASE_STEAMSAW", define_as = "THE_LUMBERATOR",
	power_source = {steam=true, nature=true},
	name = "The Lumberator", image = "object/artifact/the_lumberator.png",
	unided_name = _t"vined coated steamsaw", unique = true, define_as = "LUMBERSAW",
	level_range = {23, 31},
	rarity = 260,
	desc = _t[["Spread the wonders of nature even quicker than ever with this seed injecting steamsaw! Your former enemies will be freshly grown trees before you even know it!"]],
	require = { stat = { str=24 }, },
	cost = 300,
	material_level = 3,
	combat = {
		dam = 27,
		apr = 19,
		physcrit = 3,
		dammod = {str=1},
		damtype = DamageType.NATURE,
		block = 50,
		special_on_kill = {desc=_t"summon a treant (5 turn cooldown)", fct=function(combat, who, target)
			if not who.player then return end
			if not who:canBe("summon") then game.logPlayer(who, "You cannot summon; you are suppressed!") return end
			local o, item, inven_id = who:findInAllInventoriesBy("define_as", "LUMBERSAW")
			if not o or not who:getInven(inven_id).worn then return end
			if o.power < o:min_power_to_trigger() then return end
			o.power=0
			local x, y = util.findFreeGrid(target.x, target.y, 5, true, {[engine.Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to invoke!")
				return
			end
			local Talents = require "engine.interface.ActorTalents"
			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				type = "immovable", subtype = "plants",
				display = "#", color=colors.WHITE,
				blood_color = colors.GREEN,
				body = { INVEN = 10 },
				autolevel = "warrior",
				ai = "dumb_talented_simple", ai_state = { talent_in=3, },
				stats = { str=10, dex=10, mag=3, con=10 },
				infravision = 10,
				combat_armor = 10, combat_def = 1,
				cut_immune = 1,
				fear_immune = 1,
				power_source = {nature=true, antimagic=true},
				name = _t"treant", color=colors.GREEN,
				desc = _t"A very strong near-sentient tree, which has become hostile to other living things.",
				sound_moam = "creatures/treants/treeant_2",
				sound_die = {"creatures/treants/treeant_death_%d", 1, 2},
				sound_random = {"creatures/treants/treeant_%d", 1, 3},
				resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/immovable_plants_treant.png", display_h=2, display_y=-1}}},
				level_range = {12, nil}, exp_worth = 0,
				max_life = resolvers.rngavg(100,130),
				life_rating = 15,
				combat = { dam=resolvers.levelup(resolvers.rngavg(8,13), 1, 1.2), atk=15, apr=5, sound="actions/melee_thud" },
				rank = 2,
				size_category = 5,
				resolvers.talents{
					[Talents.T_STUN]={base=3, every=8},
				},
				
				faction = who.faction,
				summoner = who, summoner_gain_exp=true,
				summon_time=15,
			}

			m:resolve()
			game.zone:addEntity(game.level, m, "actor", x, y)
			m.remove_from_party_on_death = true,
			game.party:addMember(m, {
				control=false,
				type="summon",
				title=_t"Summon",
				orders = {target=true, leash=true, anchor=true, talents=true},
			})
		end},
	},
	max_power = 5, power_regen = 1,
	min_power_to_trigger = function(self) return self.max_power * (self.worn_by and (100 - (self.worn_by:attr("use_object_cooldown_reduce") or 0))/100 or 1) end, -- special handling of the Charm Mastery attribute
	wielder = {
		combat_armor = 14,
		combat_def = 4,
		fatigue = 8,
		learn_talent = { [Talents.T_BLOCK] = 1, },
	},
}


newEntity{ base = "BASE_STEAMSAW",
	power_source = {steam=true, psionic=true},
	name = "Grinder", image = "object/artifact/grinder.png",
	unided_name = _t"bloody steamsaw", unique = true,
	level_range = {31, 42},
	rarity = 310,
	desc = _t[[Originally a kitchen implement used by the giants to saw through tough, frozen carcasses. Something is especially sinister about this example though.]],
	require = { stat = { str=24 }, },
	cost = 300,
	material_level = 4,
	special_desc = function(self) return _t"On Taking Damage: Blindside the attacker (range 6)." end,
	combat = {
		dam = 36, --Strong because of the passive's risk
		apr = 20,
		physcrit = 14, --high
		dammod = {str=1},
		block = 50,
		lifesteal=5,
		melee_project={[DamageType.RANDOM_GLOOM] = 10},
	},
	wielder = {
		combat_armor = 8,
		combat_def = 12,
		fatigue = 10,
		sawwheel_speed = 0.25,
		learn_talent = { [Talents.T_BLOCK] = 2, },
	},
	callbackOnTakeDamage = function(self, who, src, x, y, type, dam, state) -- Trigger Blindside
		if who.turn_procs.grindersaw then return end
		who.turn_procs.grindersaw = true
		if not src:isClassName("mod.class.Actor") or src:attr("dead") then return end --Make sure it doesn't trigger on traps or w/e
		local dist = core.fov.distance(x, y, src.x, src.y)
		if dist > 1 and dist < 6 then
			who:forceUseTalent(who.T_BLINDSIDE, {ignore_cd=true, ignore_energy=true, force_target=src, force_level=2, ignore_ressources=true})
		end
	end
}

newEntity{ base = "BASE_STEAMSAW",
	power_source = {steam=true, arcane=true},
	name = "Overclocked Radius", image = "object/artifact/overclocked_radius.png",
	unided_name = _t"distorted steamsaw", unique = true,
	level_range = {24, 31},
	rarity = 310,
	desc = _t[[Faced with the petty quandaries of 'conventional physics', some mad tinker must have coated this sawblade with a fine sheathe of dilated time to maximize its speed.
 
There were ...side effects.]],
	require = { stat = { str=24 }, },
	cost = 300,
	material_level = 3,
	special_desc = function(self) return _t"Attack speed increases with paradox, up to 250% at 1000 paradox." end,
	sentient=true,
	combat = {
		dam = 28,
		apr = 19,
		physcrit = 9,
		physspeed = 1,
		dammod = {str=1},
		block = 50,
		special_on_hit = {desc=_t"increase paradox by a random amount", on_kill=true, fct=function(combat, who, target)
			who:incParadox(rng.range(5, 10))
		end},
		special_on_crit = {desc=function(self, who, special)
				return ("increase paradox by a drastic amount with a chance to do an anomaly (%d%% chance). If anomaly triggers, halve paradox."):tformat(who:paradoxFailChance())
			end, on_kill=true,
			fct=function(combat, who, target, dam, special)
			who:incParadox(rng.range(50, 100))
			if who:paradoxDoAnomaly(who:paradoxFailChance(), 0, {anomaly_type="random", silent=silent}) then
				who:incParadox(-who.paradox / 2)
			end
		end},
	},
	wielder = {
		combat_armor =7,
		combat_def = 10,
		fatigue = 9,
		damage_affinity={
			[DamageType.TEMPORAL] = 30, -- ^_^
		},
		learn_talent = { [Talents.T_BLOCK] = 2, [Talents.T_PARADOX_POOL] = 1, },
	},
	on_wear = function(self, who)
		self.worn_by = who
	end,
	on_takeoff = function(self)
		self.worn_by = nil
	end,
	act = function(self)
		self:useEnergy()
		self:regenPower()
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by = nil return end
		if self.worn_by:attr("dead") then return end
		self.combat.physspeed = 1 - util.bound(0, 0.6 * self.worn_by.paradox/1000, 0.6)
	end,
}

newEntity{ base = "BASE_STEAMSAW",
	power_source = {steam=true},
	name = "Heartrend", image = "object/artifact/heartrend.png",
	unided_name = _t"distorted steamsaw", unique = true,
	level_range = {32, 43},
	rarity = 310,
	desc = _t[[There is an attached note.
 
'I've spilt the heartsblood of my work, feeling it pound, like a heart, in my palms.
Some people just can't let go until they've bled dry.']],
	require = { stat = { str=30 }, },
	cost = 300,
	material_level = 4,
	special_desc = function(self) return _t"All damage dealt by or to you (that is over 1% of max life) bleeds for an additional 20% of the damage as physical damage (ignores most status resistances).\nWhile you are bleeding, Heartrend's damage increases and it gains lifesteal." end,
	sentient=true,
	combat = {
		dam = 28,
		base_dam = 28,
		apr = 19,
		physcrit = 9,
		physspeed = 1,
		dammod = {str=1},
		block = 50,
		lifesteal = 0,
		special_on_hit = {desc=_t"If bleed damage per turn is greater than 5% of max life, attacks cleave.", on_kill=1, fct=function(combat, who, target, dam)
			local cut = who:hasEffect(who.EFF_HEART_CUT)
			if not cut then return end
			local cut_percent = cut.power / who.max_life
			if cut_percent < 5 then return end
			
			
			local tg = {type="cone", range=0, radius=1, friendlyfire=false, start_x=who.x, start_y=who.y}
			local damage = dam * 0.5
			who:project(tg, who.x, who.y, function(px, py)
				local target2 = game.level.map(px, py, engine.Map.ACTOR)
				if not target2 or target2 == target then return end
				local tg2 = {type="ball", range=0, radius=0, friendlyfire=false, start_x=target2.x, start_y=target2.y}
				who:project(tg2, target2.x, target2.y, engine.DamageType.PHYSICAL, damage)
			end)
		end},
	},
	wielder = {
		combat_armor =10,
		combat_def = 8,
		fatigue = 9,
		learn_talent = { [Talents.T_BLOCK] = 2, },
	},
	on_wear = function(self, who)
		self.worn_by = who
	end,
	on_takeoff = function(self)
		self.worn_by = nil
	end,
	act = function(self)
		self:useEnergy()
		self:regenPower()
		if not self.worn_by then return end
		if game.level and not game.level:hasEntity(self.worn_by) and not self.worn_by.player then self.worn_by = nil return end
		if self.worn_by:attr("dead") then return end
		
		local who = self.worn_by
		
		local cut = who:hasEffect(who.EFF_HEART_CUT)
		if not cut then return end
		local cut_percent = cut.power / who.max_life
		self.combat.physspeed = 1 / (1 + cut_percent * 5)
		self.combat.dam = self.combat.base_dam * (1 + cut_percent * 2)
		self.combat.lifesteal = cut_percent * 100
	end,
	callbackOnTakeDamage = function(self, who, src, x, y, type, dam, state)
		if not who.ignore_heartrend then
			who:setEffect(who.EFF_HEART_CUT, 5, {power=dam * 0.04, no_ct_effect=true, src=src})
		end
	end,
	callbackOnDealDamage = function(self, who, dam, target)
		if not target.ignore_heartrend then
			target:setEffect(target.EFF_HEART_CUT, 5, {power=dam * 0.04, no_ct_effect=true, src=who})
		end
	end,
}

newEntity{ base = "BASE_STEAMSAW",
	power_source = {steam=true, arcane=true},
	name = "Dethzaw", image = "object/artifact/dethzaw.png",
	unided_name = _t"fiery steamsaw", unique = true,
	level_range = {40, 50},
	rarity = 340,
	desc = _t[[Grushgore the Destroyer was absolutely enthralled when he discovered steamsaws. He immediately kidnapped several tinkerers and forced them to create this for him.
His naming skills have not improved.]],
	require = { stat = { str=32 }, },
	cost = 300,
	material_level = 5,
	combat = {
		dam = 40,
		apr = 27,
		physcrit = 6,
		dammod = {str=1.1},
		damtype = DamageType.FIRE,
		block = 80,
		special_on_crit = {desc=_t"deal a melee attack against all other enemies in a circle around you", on_kill=true, fct=function(combat, who, target)
		if who.turn_procs.dethzaw then return end
		who.turn_procs.dethzaw = true --don't recurse
		local tg = {type="ball", range=0, friendlyfire=false, radius=1}
			who:project(tg, who.x, who.y, function(px, py, tg, who)
			local target2 = game.level.map(px, py, engine.Map.ACTOR)
			if target2 and target2 ~= who and target2 ~= target then
				who:attackTarget(target2, nil, 1, true)
			end
		end)
		who.turn_procs.dethzaw = nil
		who:addParticles(engine.Particles.new("meleestorm", 1, {radius=4, img="spinningwinds_blue"}))
		end},
	},
	wielder = {
		combat_armor = 15,
		combat_def = 12,
		fatigue = 9,
		inc_stats = { [Stats.STAT_STR] = 10, [Stats.STAT_CUN] = 8 },
		talents_types_mastery = {
			["steamtech/sawmaiming"] = 0.3,
		},
		learn_talent = { [Talents.T_BLOCK] = 3, },
	},
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true, steamtech=true},
	unique = true,
	name = "Galen's Flowing Robe", color = colors.RED, image = "object/artifact/galen_s_flowing_robe.png",
	unided_name = _t"ample robe", moddable_tile = "upper_body_galen_s_flowing_robe",
	desc = _t[[This robe was worn by the Technomancer Galen, infused with technomancy enchantments it is said to react to techno-spells!]],
	level_range = {40, 50},
	rarity = 230,
	cost = 350,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 7, [Stats.STAT_WIL] = 7, [Stats.STAT_CUN] = 7, },
		combat_spellpower = 35,
		combat_spellcrit = 12,
		mana_regen = 2,
		max_mana = 77,
		inc_damage = {
			[DamageType.FIRE] = 37, [DamageType.LIGHTNING] = 37,
			[DamageType.ARCANE] = 37, [DamageType.TEMPORAL] = 37,
			[DamageType.COLD] = 37, [DamageType.PHYSICAL] = 37,
		},
		talents_types_mastery = {
			["spell/occult-technomancy"] = 0.1,
			["spell/galvanic-technomancy"] = 0.1,
			["spell/terrene-technomancy"] = 0.1,
		},
	},
	special_desc = function(self) return _t[[20% chance when casting a technomancy spell (or 10% chance when casting a normal spell) to power-up the internal defense circuits of the robe.
The circuit will do one of:
#AQUAMARINE#if more than one foe is in melee range#LAST#: teleport away all foes
#AQUAMARINE#if below 50% life#LAST#: increase all resistances by 20% for 5 turns
#AQUAMARINE#if below 20 steam#LAST#: supercharge the arcane dynamo to produce 4 more steam per 10 mana spent for 5 turns
#AQUAMARINE#otherwise#LAST#: reset the cooldown of the spell with the highest remaining cooldown
]] end,
	callbackOnTalentPost = function(self, who, ab)
		if ab.is_technomancy then if not rng.percent(20) then return end
		elseif ab.is_spell then if not rng.percent(10) then return end
		else return end
		local name = self:getName{do_color=1, no_add_name=1}
		local foes = who:projectCollect({type="ball", radius=1}, who.x, who.y, engine.Map.ACTOR, "hostile")

		if table.count(foes) >= 2 then
			game.logSeen(who, "#PURPLE#%s activates and teleports away all nearby creatures!", name)
			for target, _ in pairs(foes) do
				if target:canBe("teleport") then
					game.level.map:particleEmitter(target.x, target.y, 1, "teleport")
					target:teleportRandom(target.x, target.y, 10)
					game.level.map:particleEmitter(target.x, target.y, 1, "teleport")
				end
			end
		elseif who.life / who.max_life < 0.5 and not who:hasEffect(who.EFF_GALEN_PROTECTION) then
			game.logSeen(who, "#PURPLE#%s activates and increases %s's resistances!", name, who:getName())
			who:setEffect(who.EFF_GALEN_PROTECTION, 5, {power=20})
		elseif who:getSteam() < 20 and who:getMaxSteam() > 20 and not who:hasEffect(who.EFF_GALEN_DYNAMO) then
			game.logSeen(who, "#PURPLE#%s activates and increases %s's arcane dynamo power!", name, who:getName())
			who:setEffect(who.EFF_GALEN_DYNAMO, 5, {power=4})
		else
			local cds = {}
			for tid, cd in pairs(who.talents_cd) do
				local e = who:getTalentFromId(tid)
				if not e.fixed_cooldown and e.is_spell then
					cds[#cds+1] = {t=e, cd=cd}
				end
			end
			if #cds == 0 then return end
			table.sort(cds, "cd")
			who:alterTalentCoolingdown(cds[#cds].t.id, -cds[#cds].cd)
			game.logSeen(who, "#PURPLE#%s activates and resets %s's %s cooldown!", name, who:getName(), cds[#cds].t.name)
		end
	end,

}

newEntity{ base = "BASE_STEAMSAW",
	power_source = {steam=true, arcane=true},
	name = "Galen's Will", image = "object/artifact/turbocutter.png", moddable_tile = "%s_galen_s_will",
	unided_name = _t"aether-infused steamsaw", unique = true,
	level_range = {30, 40},
	rarity = 300,
	desc = _t[[Saws made of metal? That is no good for a discerning Technomancer so Galen made a saw out of pure arcane forces!]],
	require = { stat = { mag=30 }, },
	cost = 500,
	material_level = 4,
	combat = {
		dam = 40,
		apr = 45,
		dammod = {mag=1},
		block = 50,
		damtype = DamageType.OCCULT,
	},
	wielder = {
		combat_spellresist = 10,
		silence_immune = 0.4,
		combat_spellspeed = 0.1,
		arcane_dynamo = 2,
		inc_stats = {[Stats.STAT_MAG] = 9, [Stats.STAT_CUN] = 9},
		fatigue = 15,
		learn_talent = { [Talents.T_BLOCK] = 3, [Talents.T_ELECTRON_INCANTATION]=4 },
	},
	special_desc = function() return _t"Increases the steam your arcane dynamo generate per 10 points of mana by 2." end,
}

newEntity{ base = "BASE_MINDSTAR",
	power_source = {psionic=true},
	unique = true,
	name = "Eye of the Lost", image = "object/artifact/eye_of_the_lost.png",
	unided_name = _t"pale mindstar",
	level_range = {40, 50},
	color=colors.AQUAMARINE,
	rarity = 320,
	desc = _t[[A strange aura surrounds this mindstar. You feel a presence, but it is obscured, as if it refuses to be found.]],
	cost = 280,
	require = { stat = { wil=35 }, },
	use_no_energy = true,
	material_level = 5,
	combat = {
		dam = 17,
		apr = 27,
		physcrit = 5,
		dammod = {wil=0.5, cun=0.3},
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
	max_power = 25, power_regen = 1,
	use_power = {
		power = 25,
		name = _t"see all other beings around you for 5 turns",
		use = function(self, who)
			who:setEffect(who.EFF_ALL_SIGHT, 5, {power=300})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_LEATHER_HAT",
	power_source = {technique=true},
	unique = true,
	name = "Brass Goggles", image = "object/artifact/brass_goggles.png",
	unided_name = _t"classy goggles",
	level_range = {32, 40},
	color=colors.BROWN,
	encumber = 2,
	rarity = 200,
	desc = _t[[No self respecting craftsman would be caught without them!]],
	cost = 500,
	material_level=4,
	wielder = {
		combat_def=10,
		inc_stats = { [Stats.STAT_CUN] = 20, },
		blind_immune=1,
		combat_atk = 20,
		combat_apr = 15,
		combat_steamcrit = 5,
		combat_steampower = 5,
		resists={
			[DamageType.FIRE] 	= 20, -- Of course!
		},
		sight = 1, -- Superstrong
		infravision = 3,
		talents_types_mastery = { ["steamtech/chemistry"] = 0.2, ["steamtech/physics"] = 0.2,},
	},
}

newEntity{ base = "BASE_LEATHER_HAT",
	power_source = {steam=true, unknown=true},
	unique = true,
	name = "X-Ray Goggles", image = "object/artifact/x_ray_goggles.png",
	unided_name = _t"pitch black goggles",
	level_range = {40, 50},
	color=colors.BROWN,
	encumber = 2,
	rarity = 800, --Super rare
	desc = _t[[How do these even work?]],
	cost = 500,
	material_level=5,
	wielder = {
		combat_def=10,
		inc_stats = { [Stats.STAT_CUN] = 10, },
		blind_immune=1,
		combat_atk = 20,
	},
	max_power = 30, power_regen = 1,
	use_power = {
		power = 30,
		name = _t"see everything. EVERYTHING. For 5 turns, anyway",
		use = function(self, who)
			who:setEffect(who.EFF_X_RAY, 5, {power=300})
			who:magicMap(10)
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_GREATMAUL",
	power_source = {steam=true, unknown=true},
	unique = true,
	name = "Laser Powered Giant Smasher", color = colors.RED, image = "object/artifact/l_p_g_s.png",
	unided_name = _t"radiant hammer",
	desc = _t[[The Laser Powered Giant Smasher, nicknamed the Gloryhammer. You can feel it vibrating with untold power in your hands.]],
	moddable_tile = "%s_hand_L_P_G_S",
	level_range = {40, 50},
	rarity = 270,
	require = { stat = { str=40 }, },
	cost = 250,
	material_level = 5,
	combat = {
		dam = 80,
		apr = 0,
		physcrit = 25,
		dammod = {str=1.3},
		damtype = DamageType.LIGHT,
		melee_project = {
			[DamageType.LIGHTNING] = 20,
			[DamageType.FIRE] = 20,
		},
	},
	wielder = {
		inc_damage_actor_type = {humanoid = 10, giant = 10},
		confusion_immune = 1,
		fear_immune = 1,
		learn_talent = { [Talents.T_LASER_POWERED_SMASH] = 1,},
	},
	on_wear = function(self, who)
		if who.name and who.name:lower():prefix("angus ") then
			local Talents = require "engine.interface.ActorStats"
			self:specialWearAdd({"combat","dam"}, 20)
			self:specialWearAdd({"combat","apr"}, 20)
			self:specialWearAdd({"combat","physcrit"}, 20)
			self:specialWearAdd({"wielder","stun_immune"}, 1)
			game.logPlayer(who, "#PURPLE#You feel the power of the Gloryhammer course through you! It has become fully empowered!")
		end
	end,
}
