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

newTalent{
	name = "Medical Injector", short_name = "GLOBAL_MEDICAL_CD",
	type = {"steamtech/objects",1},
	points = 1,
	cooldown = 1,
	no_npc_use = true,
	hide = true,
	cooldownStart = function(self, t, o)
		local base_cd = self.talents_cd[t.id]

		local d, injector_id = self:getMedicalInjector()
		if d and base_cd then self.talents_cd[injector_id] = math.ceil(base_cd * d.cooldown_mod / 100) end

		-- Can we continue ?
		local d = self:getMedicalInjector()
		if d then
			table.print(d)
			self.talents_cd[t.id] = nil
			print("Some medical injector still usable, cancelling global CD")
			self:fireTalentCheck("callbackOnMedicalSalve", o, false)
		else
			print("No medical injector still usable, setting up global CD")
			local min = 999
			local c = self.medical_injector_config
			for i = 1, #c do
				local tid = c[i]
				min = math.min(min, self.talents_cd[tid.id])
			end
			self.talents_cd[t.id] = min
			self:fireTalentCheck("callbackOnMedicalSalve", o, true)
		end
	end,
	cooldownStop = function(self, t)
		
	end,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ""
	end,
}

newTalent{
	name = "Medical Urgency Vest", image = "talents/implant__medical_injector.png",
	type = {"steamtech/objects", 1},
	points = 1,
	cooldown = 0,
	no_npc_use = true,
	cooldownStart = function(self, t)
		local bt = self:getTalentFromId(self.T_GLOBAL_MEDICAL_CD)
		bt.cooldownStart(self, bt)
	end,
	on_learn = function(self, t)
		self:addMedicalInjector(t)
	end,
	on_unlearn = function(self, t)
		self:removeMedicalInjector(t)
	end,
	action = function(self, t)
		game.bignews:saySimple(120, "#LIGHT_BLUE#Medical Urgency Vest selected to be used first by salves.")
		game.logPlayer(self, "This medical injector will now be used first if available when using medical salves.")
		self:setFirstMedicalInjector(t)
		return false
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[The medical urgency vest allows using therapeutics with %d%% efficiency and cooldown mod of %d%%.]])
		:tformat(data.power + data.inc_stat, data.cooldown_mod)
	end,
}

newTalent{
	name = "Life Support", image = "talents/implant__medical_injector.png",
	type = {"steamtech/objects", 1},
	points = 1,
	cooldown = 0,
	no_npc_use = true,
	cooldownStart = function(self, t)
		local bt = self:getTalentFromId(self.T_GLOBAL_MEDICAL_CD)
		bt.cooldownStart(self, bt)
	end,
	on_learn = function(self, t)
		self:addMedicalInjector(t)
	end,
	on_unlearn = function(self, t)
		self:removeMedicalInjector(t)
	end,
	action = function(self, t)
		game.bignews:saySimple(120, "#LIGHT_BLUE#Life Support Suit selected to be used first by salves.")
		game.logPlayer(self, "This medical injector will now be used first if available when using medical salves.")
		self:setFirstMedicalInjector(t)
		return false
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[The life support suit allows using therapeutics with %d%% efficiency and cooldown mod of %d%%.]])
		:tformat(data.power + data.inc_stat, data.cooldown_mod)
	end,
}

newTalent{
	name = "Create Tinker",
	type = {"steamtech/other",1},
	points = 1,
	no_npc_use = true,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 1 then
			self.can_tinker = self.can_tinker or {}
			self.can_tinker.steamtech = 1
		end
	end,
	on_unlearn = function(self, t)
		if self:getTalentLevelRaw(t) == 0 then
			self.can_tinker.steamtech = nil
			if not next(self.can_tinker) then self.can_tinker = nil end
		end
	end,
	action = function(self, t)
		return self:talentDialog(game.party:createTinkerUI())
	end,
	info = function(self, t)
		return (_t[[Allows you to create tinkers.]])
	end,
}

newTalent{
	name = "Weapon Automaton: One Handed",
	short_name = "TINKER_WEAPON_AUTOMATON_1H",
	type = {"steamtech/other",1},
	points = 1,
	cooldown = 40,
	range = 5,
	no_npc_use = true,
	getDuration = function(self, t)
		local elec = self:getTalentFromId(self.T_ELECTRICITY)		
		return math.floor(self:combatTalentScale(t, 4, 8) + self:combatTalentScale(elec, 1, 8)) 
	end,
	getAttackSpeed = function(self, t) return self:combatTalentScale(t, 0.6, 1.4) end,
	action = function(self, t)
		local inven = self:getInven("INVEN")
		local found = false
		for i, obj in pairs(inven) do
			if type(obj) == "table" and obj.type == "weapon" then
				found = true
				break
			end
		end
		if not found then
			game.logPlayer(self, "You cannot use %s without a one handed melee weapon in your inventory!", t.name)
			return false
		end

		-- select the location
		local range = self:getTalentRange(t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, x, y = self:canProject(tg, tx, ty)
		if game.level.map(x, y, Map.ACTOR) or game.level.map:checkEntity(x, y, game.level.map.TERRAIN, "block_move") then return nil end

		-- select the item
		local d = self:showInventory(_t"Select a weapon for your Automaton", inven,
			function(o)
				-- this is intended to cover all 1H melee weapons except Mindstars/Staves, not sure if there's a better way
				return o.type == "weapon" and o.subtype and (o.subtype ~= "staff" and o.subtype ~= "mindstar") and o.slot == "MAINHAND" and not o.forbid_slot and not o.twohanded
			end, nil)
				d.action = function(o, item)
				d.used_talent = true
				d.selected_object = o
				d.selected_item = item

				return false
			end
			
		local co = coroutine.running()
		d.unload = function(self) coroutine.resume(co, self.used_talent, self.selected_object, d.selected_item) end
		local used_talent, o, item = coroutine.yield()
		if not used_talent then return nil end

		local result = self:removeObject(inven, item)

		local NPC = require "mod.class.NPC"
		local sentry = NPC.new {
			type = "construct", subtype = "weapon",
			display = o.display, color=o.color, image = o.image, blood_color = colors.GREY,
			name = ("Weapon Automaton: %s"):tformat(o:getName()), -- bug fix
			faction = self.faction,
			desc = _t"An Automaton wielding a chosen weapon.",
			faction = self.faction,
			body = { INVEN = 10, MAINHAND=1, QUIVER=1 },
			rank = 2,
			size_category = 1,

			autolevel = o.combat.wil_attack and "summoner" or "warrior",
			ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, },

			max_life = 50 + self.max_life*self:combatTalentLimit(t, 1, 0.04, 0.17),  -- Add % of summoner's life < 100%
			life_rating = 3,
			stats = o.combat.wil_attack and {wil= 20, cun = 20, mag=10, con=10} or {str=20, dex=20, mag=10, con=10},
			combat = { dam=1, atk=1, apr=1 },
			combat_armor = math.max(100,50 + self.level),
			combat_armor_hardiness = math.min(70,5*self:getTalentLevel(t)),
			combat_def = math.max(50,self.level),
			inc_damage = table.clone(self.inc_damage or {}, true),
			resists_pen = table.clone(self.resists_pen or {}, true),
			
			combat_physspeed = t.getAttackSpeed(self, t),
			infravision = 10,

			resists = { all = self:combatTalentLimit(t, 100, 71, 75), },
			cut_immune = 1,
			blind_immune = 1,
			fear_immune = 1,
			poison_immune = 1,
			disease_immune = 1,
			stone_immune = 1,
			see_invisible = 30,
			no_breath = 1,
			disarm_immune = 1,

			moddable_tile = "human_male",
			moddable_tile_base = "tinkers_weapon_automaton_npc.png",
			moddable_tile_shadow = "tinkers_weapon_automaton_npc_shadow.png",
			moddable_tile_nude = true,

			resolvers.talents{
				[Talents.T_WEAPON_COMBAT]={base=1, every=10},
				[Talents.T_WEAPONS_MASTERY]={base=1, every=10},
				[Talents.T_KNIFE_MASTERY]={base=1, every=10},
				[Talents.T_EXOTIC_WEAPONS_MASTERY]={base=1, every=10},
				[Talents.T_STAFF_MASTERY]={base=1, every=10},
				[Talents.T_BOW_MASTERY]={base=1, every=10},
				[Talents.T_SLING_MASTERY]={base=1, every=10},
				[Talents.T_PSIBLADES]=o.combat.wil_attack and {base=1, every=10},
				[Talents.T_SHOOT]=1,
			},
			o.combat.wil_attack and resolvers.sustains_at_birth(),
			summoner = self,
			summoner_gain_exp=true,
			summon_time = t.getDuration(self, t),
			summon_quiet = true,

			on_die = function(self, who)
				game.logSeen(self, "#F53CBE#%s runs out of power.", self:getName():capitalize())
			end,
		}

		sentry:resolve()
		sentry:resolve(nil, true)
		sentry:forceLevelup(self.level)

		-- Auto alloc some stats to be able to wear it
		if rawget(o, "require") and rawget(o, "require").stat then
			for s, v in pairs(rawget(o, "require").stat) do
				if sentry:getStat(s) < v then
					sentry.unused_stats = sentry.unused_stats - (v - sentry:getStat(s))
					sentry:incStat(s, v - sentry:getStat(s))
				end
			end
		end

		result = sentry:wearObject(o, true, false)
		game.zone:addEntity(game.level, sentry, "actor", x, y)

		sentry.no_party_ai = true
		sentry.unused_stats = 0
		sentry.unused_talents = 0
		sentry.unused_generics = 0
		sentry.unused_talents_types = 0
		sentry.no_points_on_levelup = true
		if game.party:hasMember(self) then
			sentry.remove_from_party_on_death = true
			game.party:addMember(sentry, { control="no", type="summon", title=_t"Summon"})
		end

		game:playSoundNear(self, "talents/spell_generic")

		return true
	end,
	info = function(self, t)
		return ([[Deploy a Weapon Automaton based on a selected one handed melee item.  The Automaton will wield the selected weapon and drop it when it times out or is destroyed.  Aside from the weapon selected, the Automaton will scale off Tinker talent levels, your own stats, and other things that will be described in this tooltip at some point.  
		]]):tformat()
	end,
}

newTalent{
	name = "Hand Cannon", short_name = "TINKER_HAND_CANNON",
	type = {"steamtech/other",1},
	points = 5,
	steam = 20,
	cooldown = 15,
	tactical = { ATTACK = 2 },
	requires_target = true,
	range = 10,
	getAttacks = function(self, t)
		if (self:getTalentLevel(t) >= 5) then
			return 2
		else
			return 1
		end
	end,
	getDamage = function(self, t)
		return self:combatTalentWeaponDamage(t, 0.5, 2.5)
	end,
	on_pre_use = function(self, t) return self:getInven("QUIVER") and self:getInven("QUIVER")[1] end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		
		local ammoWeapon = table.clone(self:getInven("QUIVER")[1])
		
		-- better for this to be a ranged melee attack because it synergizes better with the builds that actually want it
		if ammoWeapon and ammoWeapon.combat then
			-- special_on_hit and similar are the same for ranged and melee weapons, but we need to convert ranged_project 
			ammoWeapon.combat.melee_project = {}
			for k, v in pairs(ammoWeapon.combat) do
				if (k == "ranged_project") then
					ammoWeapon.combat["melee_project"] = v
				end
			end
					
			self:attackTargetWith(target, ammoWeapon.combat, nil, t.getDamage(self, t))
			if t.getAttacks(self, t) > 1 then 
				self:attackTargetWith(target, ammoWeapon.combat, nil, t.getDamage(self, t))
			end
			
		else
			game.logPlayer(self, "You have no ammo!")
			return false
		end		


		return true
	end,
	info = function(self, t)
		return ([[Fires your ammo at an enemy in range %d for %d%% weapon damage.  If this tinker is made of voratun you will fire an additional shot.
			This shot is a ranged melee attack but will use the ranged procs of your ammo as well.]]):
		tformat(self:getTalentRange(t), t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Fatal Attractor", short_name = "TINKER_FATAL_ATTRACTOR",
	type = {"steamtech/other",1},
	range = 7,
	points = 5,
	steam = 20,
	cooldown = 20,
	--tactical = { ATTACKAREA = 2 },
	requires_target = true,
	getHP = function(self, t) return self:combatTalentSteamDamage(t, 10, 1000) end,
	getResist = function(self, t) return self:combatTalentSteamDamage(t, 20, 50) end,
	getArmor = function(self, t) return self:combatTalentSteamDamage(t, 5, 45) end,
	getReflection = function(self, t) return 30 end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "construct", subtype = "steambot",
			display = "*", color=colors.GREEN,
			name = _t"fatal attractor", faction = self.faction, image = "object/tinkers_fatal_attractor_t5.png",
			desc = _t[[A psionic contraption that reflects damage and forces things to attack it.]],
			autolevel = "none",
			ai = "summoned", ai_real = nil, ai_state = { talent_in=1, }, ai_target = {actor=nil},
			level_range = {1, 1}, exp_worth = 0,

			max_life = self:steamCrit(t.getHP(self, t)),
			combat_armor_hardiness = 50,
			combat_armor = t.getArmor(self, t),
			resists = {all = t.getResist(self, t)},
			life_rating = 3,
			never_move = 1,
			never_anger = true,
			
			reflect_damage = t.getReflection(self, t),

			negative_status_effect_immune = 1,
			cant_be_moved = 1,
			
			resolvers.talents{
				[self.T_TAUNT]=self:getTalentLevel(t),
			},
			
			-- no AI, just Taunt
			on_act = function(self)
				self:forceUseTalent(self.T_TAUNT, {})
			end,

			summoner = self, summoner_gain_exp=true,
			summon_time = 8,
		}
		
		m:resolve() m:resolve(nil, true)
		m:forceLevelup(self.level)
		game.zone:addEntity(game.level, m, "actor", x, y)
		
		m:forceUseTalent(m.T_TAUNT, {})
		return true
	end,
	info = function(self, t)
		return ([[Quickly create a psionic-enhanced metal contraption that lures all your foes to it and reflects %d%% of the damage it takes to its attackers.
		The contraption will have %d life and last 5 turns.
		Damage, life, resists, and armor scale with your Steampower.]]):
		tformat(t.getReflection(self, t), t.getHP(self, t))
	end,
}

newTalent{
	name = "Rocket Boots", short_name = "TINKER_ROCKET_BOOTS",
	type = {"steamtech/other",1},
	points = 5,
	mode = "sustained",
	drain_steam = 15,
	sustain_steam = 0,
	remove_on_zero = true,
	no_energy = true,
	cooldown = function(self, t) return math.floor(15 - self:getTalentLevel(t)) end,
	tactical = { ESCAPE = 3, CLOSEIN = 3 },
	requires_target = true,
	deactivate_on = {run=true, rest=true},
	getDam = function(self, t) return self:combatTalentSteamDamage(t, 20, 150) end,
	callbackBreakOnTalent = function(self, t, bt)
		if t.id == bt.id then return end
		self:forceUseTalent(t.id, {ignore_energy=true})
	end,
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "movement_speed", 0.5 + self:getTalentLevel(t) / 2)
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Activate the rocket boots, firing huge flames from your boots increasing your movement speed by %d%%.
		Each movement will leave a trail of flames doing %0.2f fire damage for 4 turns.
		Doing any other actions will break the effect.
		#{italic}#Burninate them all!#{normal}#]]):
		tformat(100 * (0.5 + self:getTalentLevel(t) / 2), damDesc(self, DamageType.FIRE, t.getDam(self, t)))
	end,
}

newTalent{
	name = "Iron Grip", short_name = "TINKER_IRON_GRIP",
	type = {"steamtech/other",1},
	points = 5,
	steam = 20,
	no_energy = true,
	cooldown = 12,
	tactical = { DISABLE = 2 },
	requires_target = true,
	range = 1,
	getReduc = function(self, t) return self:combatTalentSteamDamage(t, 20, 500) / 10 end,
	getDur = function(self, t) return 3 + ((self:getTalentLevelRaw(t) >= 3) and 1 or 0) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 1.2, 2.1), true, true)

		-- Try to stun !
		if hit then
			if target:canBe("pin") then
				target:setEffect(target.EFF_IRON_GRIP, t.getDur(self, t), {apply_power=self:combatSteampower(), power=t.getReduc(self, t)})
			else
				game.logSeen(target, "%s resists the iron grip!", target:getName():capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Activate the pistons to crush your target for %d turns and dealing %d%% unarmed melee damage.
		While the target is held it can not move and its armour and defense are reduced by %d.
		#{italic}#Crush their bones!#{normal}#]]):
		tformat(t.getDur(self, t), self:combatTalentWeaponDamage(t, 1.2, 2.1) * 100, t.getReduc(self, t))
	end,
}

newTalent{
	name = "Spring Grapple", short_name = "TINKER_SPRING_GRAPPLE",
	type = {"steamtech/other",1},
	range = 6,
	points = 5,
	steam = 30,
	cooldown = 14,
	tactical = { DISABLE = 1, CLOSEIN = 3 },
	requires_target = true,
	getDur = function(self, t) return 3 + ((self:getTalentLevelRaw(t) >= 3) and 1 or 0) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end

			target:pull(self.x, self.y, tg.range)
			
			local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.8, 1.8), true, true)

			if hit then
				if target:canBe("pin") then
					target:setEffect(target.EFF_PINNED, t.getDur(self, t), {apply_power=self:combatSteampower()})
				else
					game.logSeen(target, "%s resists the pin!", target:getName():capitalize())
				end
			end
		end)

		return true
	end,
	info = function(self, t)
		return ([[Grab the target and pull them towards you, striking for %d%% unarmed melee damage, and if you hit, pinning them for %d turns.]]):
		tformat(self:combatTalentWeaponDamage(t, 0.8, 1.8) * 100, t.getDur(self, t))
	end,
}

newTalent{
	name = "Toxic Cannister Launcher", short_name = "TINKER_TOXIC_CANNISTER_LAUNCHER",
	type = {"steamtech/other",1},
	range = 7,
	points = 5,
	steam = 20,
	radius = 3,
	cooldown = 15,
	tactical = { ATTACKAREA = {poison = 2} },
	requires_target = true,
	getDam = function(self, t) return self:combatTalentSteamDamage(t, 10, 300) end,
	getHP = function(self, t) return self:combatTalentSteamDamage(t, 10, 1000) end,
	getResist = function(self, t) return self:combatTalentSteamDamage(t, 20, 50) end,
	getArmor = function(self, t) return self:combatTalentSteamDamage(t, 5, 45) end,
	target = function(self, t) return {type="bolt", nowarning=true, radius=3, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t} end, -- for the ai
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "construct", subtype = "cannister",
			display = "*", color=colors.GREEN,
			name = _t"toxic cannister", faction = self.faction, image = "object/canister_toxic_gas.png",
			desc = _t[[A smelly cannister.]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented", ai_state = { talent_in=1, },
			level_range = {1, 1}, exp_worth = 0,

			max_life = self:steamCrit(t.getHP(self, t)),
			life_rating = 0,
			never_move = 1,

			inc_damage = table.clone(self.inc_damage),
			resists_pen = table.clone(self.resists_pen),
			combat_armor_hardiness = 50,
			combat_armor = t.getArmor(self, t),
			resists = {all = t.getResist(self, t)},
			damcloud = t.getDam(self, t),
			powerapply = self:combatSteampower(),

			negative_status_effect_immune = 1,
			cant_be_moved = 1,
			next_act = 1,
			on_act = function(self)
				self.next_act = self.next_act + 1
				if self.next_act < 2 then return end
				self.next_act = 0

				-- Add a lasting map effect
				game.level.map:addEffect(self,
					self.x, self.y, 5,
					engine.DamageType.POISON, {dam=self.damcloud, power=self.powerapply},
					3,
					5, nil,
					{type="vapour"},
					nil, 0, 100
				)
			end,

			summoner = self, summoner_gain_exp=true,
			summon_time = 8,
			embed_particles = {{name="bolt_slime"}},
		}
		if self:getTalentLevel(t) >= 5 then
			m.on_die = function(self, src)
				if not src or src == self then return end
				self:project({type="ball", range=0, radius=4}, self.x, self.y, function(px, py)
					local trap = game.level.map(px, py, engine.Map.TRAP)
					if not trap or not trap.lure_trigger then return end
					trap:trigger(px, py, src)
				end)
			end
		end

		m:resolve() m:resolve(nil, true)
		m:forceLevelup(self.level)
		game.zone:addEntity(game.level, m, "actor", x, y)
		return true
	end,
	info = function(self, t)
		return ([[Launch a cannister filled with toxic gas at a location.
		Every 2 turns the cannister emits a poison cloud of radius 3 around it each turn.
		The poison does %0.2f nature damage over 5 turns.
		The cannister has %d life and lasts 8 turns. When it ends or is destroyed a last cloud is created.
		Damage, life, resists, and armor scale with your Steampower.
		Damage and penetration are inherited from the creator.]]):
		tformat(damDesc(self, DamageType.NATURE, t.getDam(self, t)), t.getHP(self, t))
	end,
}

newTalent{
	name = "Steam Powered Armour", short_name = "TINKER_POWERED_ARMOUR",
	type = {"steamtech/other",1},
	points = 5,
	mode = "sustained",
	drain_steam = 6,
	no_energy = true,
	cooldown = function(self, t) return math.floor(15 - self:getTalentLevel(t)) end,
	tactical = { DEFEND = 3 },
	requires_target = true,
	getRes = function(self, t) return self:combatTalentSteamDamage(t, 3, 90) end,
	getDam = function(self, t) return self:combatTalentSteamDamage(t, 15, 120) end,
	callbackOnActBase = function(self, t)
		if rng.percent(50) then return end
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 6, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="ball", radius=1, range=self:getTalentRange(t), talent=t, selffire=false}
		for i = 1, 1 do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:project(tg, a.x, a.y, DamageType.LIGHTNING, rng.avg(1, self:steamCrit(t.getDam(self, t)), 3))
			if core.shader.active() then game.level.map:particleEmitter(a.x, a.y, tg.radius, "ball_lightning_beam", {radius=tg.radius, tx=x, ty=y}, {type="lightning"})
			else game.level.map:particleEmitter(a.x, a.y, tg.radius, "ball_lightning_beam", {radius=tg.radius, tx=x, ty=y}) end
			game:playSoundNear(self, "talents/lightning")
		end
	end,

	activate = function(self, t)
		local ret = {}
		local r = t.getRes(self, t)
		self:talentTemporaryValue(ret, "flat_damage_armor", {
			[DamageType.PHYSICAL] = r,
			[DamageType.ARCANE] = r,
			[DamageType.BLIGHT] = r,
			[DamageType.FIRE] = r,
			[DamageType.COLD] = r,
			[DamageType.LIGHTNING] = r,
			[DamageType.ACID] = r,
			[DamageType.LIGHT] = r,
			[DamageType.DARKNESS] = r,
			[DamageType.NATURE] = r,
			[DamageType.TEMPORAL] = r,
		})
		if core.shader.active(4) then
			ret.particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=0, radius=1.1, img="lightningshield_yellowish"}, {type="lightningshield"}))
		else
			ret.particle = self:addParticles(Particles.new("tempest", 1))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[Activate the armour's active defense system.
		A flow of electricity covers your armour to attenuate the force of energy attacks while small steam engines move key pieces of the armour to attenuate physical attacks.
		All damage except mind damage is reduced by a flat %d.
		In addition the electric power of the armour sometimes leaks, each turn there is a 50%% chance to produce a electrical arc toward a foe, dealing %0.2f to %0.2f lightning damage to all foes in radius 1.
		The effects increase with your Steampower.]]):
		tformat(t.getRes(self, t), t.getDam(self, t) / 3, t.getDam(self, t))
	end,
}

newTalent{
	name = "Viral Needlegun", short_name = "TINKER_VIRAL_NEEDLEGUN",
	type = {"steamtech/other", 1},
	points = 5,
	cooldown = 10,
	steam = 10,
	tactical = { ATTACKAREA = {BLIGHT = 2} },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 3.7, 6.5)) end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t} end,
	tactical = {ATTACKAREA = {PHYSICAL=1,
		BLIGHT=function(self, t, aitarget) return 2*(1-(aitarget:attr("disease_immune") or 0)) end}
	},
	damage = function(self, t) return self:combatTalentSteamDamage(t, 5, 120) end,
	diseaseChance = function(self, t) return self:combatTalentLimit(t, 100, 30, 50) end,
	diseaseDamage = function(self, t) return self:combatTalentSteamDamage(t, 10, 600)/20 end,
	diseaseStat = function(self, t) return self:combatTalentSteamDamage(t, 10, 20) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.BLIGHTED_NEEDLES, {
			dam = self:steamCrit(t.damage(self, t)),
			disease_chance = t.diseaseChance(self, t),
			disease_dam = self:steamCrit(t.diseaseDamage(self, t)), -- damage/turn
			disease_power = t.diseaseStat(self, t),
			dur = 20,
		})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_acid", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[You fire a cone of blighted needles, hitting everything in a frontal cone of radius %d for %0.2f physical damage.
		Each creature hit has a %d%% chance of being infected by a random disease, doing %0.2f blight damage and reducing either Constitution, Strength or Dexterity by %d for 20 turns.
		The damage and disease effects increase with your Steampower.]]):tformat(self:getTalentRadius(t), damDesc(self, DamageType.PHYSICAL, t.damage(self, t)), t.diseaseChance(self, t), damDesc(self, DamageType.BLIGHT, t.diseaseDamage(self, t)), t.diseaseStat(self, t))
	end,
}

newTalent{
	name = "Sand Shredder", short_name = "TINKER_SAND_SHREDDER",
	type = {"steamtech/other", 1},
	points = 5,
	mode = "passive",
	radius = 1,
	callbackOnMove = function(self, t, moved, force, ox, oy, x, y)
		if game.level.map:checkEntity(x, y, Map.TERRAIN, "name") ~= "sandwall" then return end
		self:project({type="ball", radius=self:getTalentRadius(t)}, self.x, self.y, DamageType.DIG, 1)
		game.logSeen(self, "%s shreds through sandwalls!", self:getName():capitalize())
		self:useEnergy()
	end,
	info = function(self, t)
		return (_t[[You shred pieces of sandwalls. Brrrmmm!.]])
	end,
}

newTalent{
	name = "Flamethrower",
	type = {"steamtech/other",1},
	points = 5,
	steam = 25,
	cooldown = 3,
	tactical = { ATTACK = { FIRE = 1 } },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8, 0.5, 0, 0, true)) end,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 10, 250) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIRE, self:steamCrit(t.getDamage(self, t)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_fire", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Throw a cone of flame with radius %d
		The damage will increase with your Steampower.]]):
		tformat(radius, damDesc(self, DamageType.FIRE, damage))
	end,
}

-- This should probably be incorporated into a std ai function that optimizes AOE placement.
local findheals = function(self, t) -- find allies to heal
	local nb_to_heal, sqradius = 0, self:getTalentRadius(t)^2
	local healfov = {}
	for act, params in pairs(self.fov.actors) do
		if params.sqdist <= sqradius then
			local heal = t.heal_check(self, t, act)
			if heal and heal > act.max_life*0.1 then --only targets with >10% damage
				nb_to_heal = nb_to_heal + 1
				healfov[act] = params
			end
		end
	end
	return nb_to_heal, healfov
end

local heal_check = function(self, t, act) -- determines if target can be healed
	return act ~= self and (act.type == "mechanical" or act.subtype == "mechanical") and self:reactionToward(act) > 0 and self:canSee(act) and act.max_life-act.life > 0 and act.max_life-act.life or false
end

newTalent{
	name = "Mass Repair",
	type = {"steamtech/other",1},
	points = 5,
	steam = 50,
	cooldown = 6,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8, 0.5, 0, 0, true)) end,
	getHeal = function(self, t) return self:combatTalentSteamDamage(t, 60, 850) end,
	is_heal = true,
	heal_check = heal_check,
	target = function(self, t) return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, selffire=false,
		filter=function(x, y) -- skip unhealable or full-health targets 
			local act = game.level.map(x, y, Map.ACTOR)
			if act then
				if t.heal_check(self, t, act) then
--game.log("---%s can be healed at (%s, %s)", act.name, x, y)
					return true
				end
			end
		end
	} end,
	findheals = findheals,

	tactical = {HEAL = 3},
	on_pre_use_ai = function(self, t, silent, fake)
		return t.findheals(self, t) > 0
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y
		if self.player then
			x, y = self:getTarget(tg)
			if not x or not y then return nil end
		else --npc tries to find the best spot for the heal
			local nb_heals, healfov = t.findheals(self, t)
			if nb_heals == 0 then return end
			local bestheal, bestspot, need = 0, {}, 0
			for act, params in pairs(healfov) do
				need = 0
				self:project(tg, params.x, params.y,
					function(px, py, typ, self)
						local act = game.level.map(px, py, engine.Map.ACTOR)
						if act and act ~= self then
--game.log("projected %s, (%s, %s), %s", self and self.name, px, py, act and act.name)
							need = need + (t.heal_check(self, t, act) or 0)
						end
					end
				)
				if need > bestheal then
					bestheal = need; bestspot = params
					x, y = params.x, params.y
--game.log("%d total healing at (%d, %d)", need, x, y)
				end
			end
--game.log("%d total healing at (%d, %d)", bestheal, x, y)
-- print(("[Mass_Repair] %d total healing at (%d, %d)"):tformat(bestheal, x, y))
		end
		if not x then return true end
		self:project(tg, x, y, DamageType.REPAIR_MECHANICAL, self:steamCrit(t.getHeal(self, t)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "cogstorm", {radius=tg.radius})
		-- game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Throw a cone of healing with radius %d, healing other mechanical creatures (steam spiders) for %d.
		The healing will increase with your Steampower.]]):
		tformat(radius, heal)
--		tformat(radius, damDesc(self, DamageType.FIRE, damage))
	end,
}

newTalent{
	name = "Arcane Disruption Wave", image = "talents/aura_of_silence.png", short_name = "TINKER_ARCANE_DISRUPTION_WAVE",
	type = {"steamtech/other", 1},
	points = 5,
	steam = 20,
	cooldown = 15,
	tactical = { DISABLE = { silence = 4 } },
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 5, 11.5)) end,
	getduration = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 3.5, 6.25)) end, -- Limit <10
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
			local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.SILENCE, {dur=t.getduration(self,t), power_check=self:combatSteampower()})
		game.level.map:particleEmitter(self.x, self.y, 1, "shout", {size=4, distorion_factor=0.3, radius=self:getTalentRadius(t), life=30, nb_circles=8, rm=0.8, rM=1, gm=0, gM=0, bm=0.5, bM=0.8, am=0.6, aM=0.8})
		return true
	end,
	info = function(self, t)
		local rad = self:getTalentRadius(t)
		return ([[Let out a technopsionic wave that silences for %d turns all those affected in a radius of %d, including the user.
		The silence chance will increase with your Steampower.]]):
		tformat(t.getduration(self,t), rad)
	end,
}

newTalent{
	name = "Mind Crush", image = "talents/yeek_will.png", short_name = "TINKER_YEEK_WILL",
	type = {"steamtech/other", 1},
	points = 5,
	steam = 20,
	cooldown = 15,
	range = 4,
	no_npc_use = true,
	requires_target = true,
	direct_hit = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target or target.dead or target == self then return end
			if not target:canBe("instakill") or target.rank > 3 or target:attr("undead") or game.party:hasMember(target) or not target:checkHit(self:getWil(20, true) + self.level * 1.5, target.level) then
				game.logSeen(target, "%s resists the mental assault!", target:getName():capitalize())
				return
		end
			target:takeHit(1, self)
			target:takeHit(1, self)
			target:takeHit(1, self)
			target:setEffect(target.EFF_DOMINANT_WILL, 6, {src=self})
		end)
		return true
	end,
	info = function(self, t)
		return ([[Shatters the mind of your victim, giving you full control over its actions for 6 turns.
		When the effect ends, you pull out your mind and the victim's body collapses, dead.
		This effect does not work on rares, bosses, or undead.
		.]]):tformat()
	end,
}

newTalent{
	name = "Shocking Touch", short_name = "TINKER_SHOCKING_TOUCH",
	type = {"steamtech/other", 1},
	points = 5,
	cooldown = 10,
	steam = 10,
	tactical = { ATTACKAREA = {LIGHTNING = 2} },
	range = 1,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t) return {type="bolt", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 10, 250) end,
	getTargetCount = function(self, t) return self:getTalentLevelRaw(t) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local fx, fy = self:getTarget(tg)
		if not fx or not fy then return nil end

		local nb = t.getTargetCount(self, t)
		local affected = {}
		local first = nil
		local dam = self:steamCrit(t.getDamage(self, t))

		self:project(tg, fx, fy, function(dx, dy)
			print("[Chain lightning] targeting", fx, fy, "from", self.x, self.y)
			local actor = game.level.map(dx, dy, Map.ACTOR)
			if actor and not affected[actor] then
				affected[actor] = true
				first = actor

				print("[Chain lightning] looking for more targets", nb, " at ", dx, dy, "radius ", 2, "from", actor.name)
				self:project({type="ball", selffire=false, x=dx, y=dy, radius=2, range=0}, dx, dy, function(bx, by)
					local actor = game.level.map(bx, by, Map.ACTOR)
					if actor and not affected[actor] and self:reactionToward(actor) < 0 then
						print("[Chain lightning] found possible actor", actor.name, bx, by, "distance", core.fov.distance(dx, dy, bx, by))
						affected[actor] = true
					end
				end)
				return true
			end
		end)

		if not first then return end
		local targets = { first }
		affected[first] = nil
		local possible_targets = table.listify(affected)
		print("[Chain lightning] Found targets:", #possible_targets)
		for i = 2, nb do
			if #possible_targets == 0 then break end
			local act = rng.tableRemove(possible_targets)
			targets[#targets+1] = act[1]
		end

		local sx, sy = self.x, self.y
		for i, actor in ipairs(targets) do
			local tgr = {type="beam", range=self:getTalentRange(t), selffire=false, talent=t, x=sx, y=sy}
			print("[Chain lightning] jumping from", sx, sy, "to", actor.x, actor.y)
			self:project(tgr, actor.x, actor.y, DamageType.LIGHTNING, dam)
			if core.shader.active() then game.level.map:particleEmitter(sx, sy, math.max(math.abs(actor.x-sx), math.abs(actor.y-sy)), "lightning_beam", {tx=actor.x-sx, ty=actor.y-sy}, {type="lightning"})
			else game.level.map:particleEmitter(sx, sy, math.max(math.abs(actor.x-sx), math.abs(actor.y-sy)), "lightning_beam", {tx=actor.x-sx, ty=actor.y-sy})
			end

			sx, sy = actor.x, actor.y
		end

		game:playSoundNear(self, "talents/lightning")

		return true
	end,
	info = function(self, t)
		return ([[Touch a creature to release a nasty electrical charge into them, doing %0.2f lightning damage.
		If this tinker is above tier 1, the electricity can arc to another target up to 2 tiles away.
		The number of enemies hit is at most the tinker tier.
		The damage increases with your Steampower.]]):tformat(damDesc(self, DamageType.LIGHTNING, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Flash Powder", short_name = "TINKER_FLASH_POWDER",
	type = {"steamtech/other", 1},
	points = 5,
	cooldown = 12,
	steam = 0,
	tactical = { DISABLE = {blind = 2} },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 3.7, 6.5)) end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t} end,
	duration = function(self, t) return math.floor(self:combatTalentScale(t, 2.9, 5.5)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if target then
				if target:canBe("blind") then
					target:setEffect(target.EFF_BLINDED, t.duration(self, t), {apply_power=self:combatSteampower(), no_ct_effect=true})
				else
					game.logSeen(target, "%s resists the blinding light!", target:getName():capitalize())
				end
			end
		end)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_earth", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[Throw a handful of dust that rapidly oxidises, releasing a blinding light.
		Creatures in a cone of radius %d are blinded for %d turns.
		The blindness effect is applied with your Steampower.]]):tformat(self:getTalentRadius(t), t.duration(self, t))
	end,
}

newTalent{
	name = "Itching Powder", short_name = "TINKER_ITCHING_POWDER",
	type = {"steamtech/other", 1},
	points = 5,
	cooldown = 20,
	steam = 0,
	tactical = { DISABLE = {confuse = 2} },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 3.7, 6.5)) end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t} end,
	duration = function(self, t) return math.floor(self:combatTalentScale(t, 1.9, 4.5)) end,
	failChance = function(self, t) return self:combatTalentLimit(t, 100, 15, 40) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if target then
				if target:canBe("confuse") then
					target:setEffect(target.EFF_ITCHING_POWDER, t.duration(self, t), {chance=t.failChance(self, t), apply_power=self:combatSteampower(), apply_save="combatMentalResist", no_ct_effect=true})
				else
					game.logSeen(target, "%s resists the itching powder!", target:getName():capitalize())
				end
			end
		end)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_earth", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[Throw a handful of dust that is very itchy to touch.
		Creatures in a cone of radius %d are itchy for %d turns, causing them to fail talents %d%% of the time.
		The itchiness effect is applied with your Steampower.]]):tformat(self:getTalentRadius(t), t.duration(self, t), t.failChance(self, t))
	end,
}

newTalent{
	name = "Thunder Grenade", short_name = "TINKER_THUNDER_GRENADE",
	type = {"steamtech/other", 1},
	points = 5,
	cooldown = 20,
	steam = 5,
	tactical = { DISABLE = {stun = 2} },
	range = 6,
	radius = 1,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t} end,
	duration = function(self, t) return math.floor(self:combatTalentScale(t, 1.9, 3.5)) end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 10, 250) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.PHYSICAL, self:steamCrit(t.getDamage(self, t)))
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if target then
				if target:canBe("stun") then
					target:setEffect(target.EFF_STUNNED, t.duration(self, t), {apply_power=self:combatSteampower(), no_ct_effect=true})
				else
					game.logSeen(target, "%s resists the explosion!", target:getName():capitalize())
				end
			end
		end)
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "thunder_grenade", {radius=tg.radius})
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		return ([[Throw a grenade at your foes, dealing %0.2f physical damage in radius %d.
		Creatures hit will also be stunned for %d turns.
		The stun effect is applied with your Steampower.]]):tformat(t.getDamage(self, t), self:getTalentRadius(t), t.duration(self, t))
	end,
}

newTalent{
	name = "Project Saw", short_name = "TINKER_PROJECT_SAW",
	type = {"steamtech/other", 1},
	points = 5,
	cooldown = 15,
	steam = 10,
	tactical = { ATTACK = {PHYSICAL = 2} },
	range = function(self, t) return math.floor(self:combatTalentScale(t, 3.7, 6.5)) end,
	radius = 0,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="beam", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 10, 450) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTargetLimited(tg)
		if not x or not y then return nil end
		local dam = self:steamCrit(t.getDamage(self, t))
		self:project(tg, x, y, DamageType.PHYSICALBLEED, dam)
		game.level.map:particleEmitter(self.x, self.y, tg.range, "flying_sawblade", {tx=x - self.x, ty=y - self.y})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[You activate hidden springs to project a saw towards your foes.
		Any creature caught in the beam takes %0.2f physical damage and bleeds for half more in 5 turns.
		The damage increases with your Steampower.]]):tformat(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Voltaic Bolt", short_name = "TINKER_VOLTAIC_BOLT",
	type = {"steamtech/other",1},
	points = 5,
	cooldown = 1,
	tactical = { ATTACK = { LIGHTNING = 2 } },
	range = 8,
	travel_speed = 6,
	requires_target = true,
	reflectable = true,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 20, 350) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_lightning", trail="lightningtrail"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = t.getDamage(self, t)
		self:projectile(tg, x, y, DamageType.LIGHTNING, (self.damcloud or dam), {type="lightning_explosion"})
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Fires a bolt of lightning, doing %0.2f lightning damage.
		The damage will increase with your Steampower.]]):
		tformat(damDesc(self, DamageType.LIGHTNING, damage))
	end,
}

newTalent{
	name = "Voltaic Sentry", short_name = "TINKER_VOLTAIC_SENTRY",
	type = {"steamtech/other",1},
	range = 7,
	points = 5,
	steam = 20,
	cooldown = 15,
	tactical = { ATTACKAREA = {LIGHTNING = 2} },
	requires_target = true,
	getDam = function(self, t) return self:combatTalentSteamDamage(t, 20, 100) end,
	getResist = function(self, t) return self:combatTalentSteamDamage(t, 20, 50) end,
	getArmor = function(self, t) return self:combatTalentSteamDamage(t, 5, 45) end,
	getHP = function(self, t) return self:combatTalentSteamDamage(t, 10, 1000) end,
	target = function(self, t) return {type="bolt", nowarning=true, radius=2, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t} end, -- for the ai
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "construct", subtype = "sentry",
			display = "*", color=colors.GREEN,
			name = _t"volatic sentry", faction = self.faction, image = "object/canister_toxic_gas.png",
			desc = _t[[A strange device. Your hair stands on end when you approach.]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented", ai_state = { talent_in=1, },
			level_range = {1, 1}, exp_worth = 0,

			max_life = self:steamCrit(t.getHP(self, t)),
			life_rating = 0,
			never_move = 1,

			inc_damage = table.clone(self.inc_damage),
			resists_pen = table.clone(self.resists_pen),

			combat_armor_hardiness = 50,
			combat_armor = t.getArmor(self, t),
			resists = {all = t.getResist(self, t)},

			negative_status_effect_immune = 1,
			cant_be_moved = 1,
			
			resolvers.talents{
				[self.T_TINKER_VOLTAIC_BOLT]=self:getTalentLevel(t),
			},

			summoner = self, summoner_gain_exp=true,
			summon_time = 10,
			embed_particles = {{name="bolt_lightning"}},
		}

		m:resolve() m:resolve(nil, true)
		m:forceLevelup(self.level)
		game.zone:addEntity(game.level, m, "actor", x, y)
		return true
	end,
	info = function(self, t)
		return ([[Place an electrically charged sentry device at a location.
		Every turn it will fire a bolt of electricity at a nearby enemy.
		The bolts do %0.2f lightning damage.
		The sentry has %d life and lasts 10 turns.
		Damage, life, resists, and armor scale with your Steampower.
		Damage and penetration are inherited from the creator.]]):
		tformat(damDesc(self, DamageType.LIGHTNING, t.getDam(self, t)), t.getHP(self, t))
	end,
}

newTalent{
	name = "Explosive Shell", short_name = "TINKER_EXPLOSIVE_SHELL",
	type = {"steamtech/other",1},
	points = 5,
	cooldown = 10,
	steam = 5,
	radius = 1,
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACKAREA = { PHYSICAL = 2 }},
	target = function(self, t) return {type="ball", range=nil, radius=self:getTalentRadius(t), selffire=false} end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 20, 350) end,
	archery_onhit = function(self, t, target, x, y)
		local tg = self:getTalentTarget(t)
		self:project(tg, x, y, DamageType.PHYSICAL, self:steamCrit(t.getDamage(self, t)))
		game.level.map:particleEmitter(x, y, tg.radius, "thunder_grenade", {radius=tg.radius})
	end,
	action = function(self, t)
		local tg = t.target(self, t)
		local targets = self:archeryAcquireTargets(nil, {no_energy=true, infinite=true, one_shot=true, type="steamgun"})
		if targets then
			self:archeryShoot(targets, t, tg, {mult=1.0, type="steamgun"})
			return true
		end
	end,
	info = function(self, t)
		return ([[You fire a special explosive shot with your steamgun(s) at a spot within range.
		When each shot reaches its target, it does normal steamgun damage and explodes within radius %d, which does %0.2f physical damage.
		This talent does not use ammo as it is the ammo.]])
		:tformat(self:getTalentRadius(t), damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Flare Shell", short_name = "TINKER_FLARE_SHELL",
	type = {"steamtech/other",1},
	points = 5,
	cooldown = 10,
	steam = 5,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1.9, 3.5)) end,
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACKAREA = { LIGHT = 1 }},
	target = function(self, t) return {type="ball", range=nil, radius=self:getTalentRadius(t), selffire=false} end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	duration = function(self, t) return math.floor(self:combatTalentScale(t, 2.9, 5.5)) end,
	archery_onhit = function(self, t, target, x, y)
		local tg = self:getTalentTarget(t)
		self:project(tg, x, y, DamageType.LITE, 1)
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if target then
				if target:canBe("blind") then
					target:setEffect(target.EFF_BLINDED, t.duration(self, t), {apply_power=self:combatSteampower(), no_ct_effect=true})
				else
					game.logSeen(target, "%s resists the blinding light!", target:getName():capitalize())
				end
			end
		end)		
		game.level.map:particleEmitter(x, y, tg.radius, "ball_light", {radius=tg.radius})
	end,
	action = function(self, t)
		local tg = t.target(self, t)
		local targets = self:archeryAcquireTargets(nil, {no_energy=true, infinite=true, one_shot=true, type="steamgun"})
		if targets then
			self:archeryShoot(targets, t, tg, {mult=1.0, type="steamgun"})
			return true
		end
	end,
	info = function(self, t)
		return ([[You fire a special explosive shot with your steamgun(s) at a spot within range.
		When each shot reaches its target, it does normal steamgun damage and explodes within radius %d, which lights up the area and blinds for %d turns.
		This talent does not use ammo as it is the ammo.]])
		:tformat(self:getTalentRadius(t), t.duration(self, t))
	end,
}

newTalent{
	name = "Incendiary Shell", short_name = "TINKER_INCENDIARY_SHELL",
	type = {"steamtech/other",1},
	points = 5,
	cooldown = 10,
	steam = 5,
	radius = 2,
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACKAREA = { LIGHT = 1 }},
	target = function(self, t) return {type="ball", range=nil, radius=self:getTalentRadius(t), selffire=false} end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 20, 250) end,
	duration = function(self, t) return math.floor(self:combatTalentScale(t, 2.9, 5.5)) end,
	archery_onhit = function(self, t, target, x, y)
		local e = mod.class.Object.new{
			name = _t"clusterbomb",
			block_sight=false,
			canAct = false,
			target = target,
			damage = self:steamCrit(t.getDamage(self, t)),
			summoner = self,
			summoner_gain_exp = true,
			energy = {value=0, mod=0.50},
			act = function(self)
				local tg = {type="ball", radius=1, friendlyfire=false}
				for i, d in ipairs(self.points) do
					game.level.map:removeParticleEmitter(d.e)
					self.summoner:project(tg, d.x, d.y, engine.DamageType.FIRE, self.damage, nil)
					game.level.map:particleEmitter(d.x, d.y, 1, "ball_fire", {radius=1})
				end
				self.points = {}
				self:useEnergy()
				game.level:removeEntity(self)
			end,
		}
	
		local ps, p = {}, self.points or {}
		self.x, self.y = x, y
		self:project({type="ball", radius=3}, x, y, function(px, py)
			local g = game.level.map(px, py, engine.Map.TERRAIN)
			if not g:check("block_move") then
				ps[#ps+1] = {x=px, y=py}
			end
		end)
		for i = 1, math.floor(self:getTalentLevel(t)) do
			if #ps == 0 then break end
			p[#p+1] = rng.tableRemove(ps)
			p[#p].e = game.level.map:particleEmitter(p[#p].x, p[#p].y, 1, "bolt_fire", {trail_length=0})
		end
		e.points = p

		game.level:addEntity(e)
	end,
	action = function(self, t)
		local tg = t.target(self, t)
		local targets = self:archeryAcquireTargets(tg, {no_energy=true, infinite=true, one_shot=true, type="steamgun"})
		if targets then
			self:archeryShoot(targets, t, tg, {mult=1.0, type="steamgun"})
			return true
		end
	end,
	info = function(self, t)
		return ([[You fire a special explosive shot with your steamgun(s) at a spot within range.
		When each shot reaches its target, it does normal steamgun damage and releases %d explosive charges in a radius of 2.
		These charges will shortly explode for %0.2f fire damage in a radius of 1.
		This talent does not use ammo as it is the ammo.]])
		:tformat(math.floor(self:getTalentLevel(t)), damDesc(self, DamageType.FIRE, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Solid Shell", short_name = "TINKER_SOLID_SHELL",
	type = {"steamtech/other",1},
	points = 5,
	cooldown = 10,
	steam = 5,
	radius = 0,
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 2 }, ESCAPE = { knockback = 2 }},
	target = function(self, t) return {type="ball", range=nil, radius=self:getTalentRadius(t), selffire=false} end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	getMultiple = function(self, t) return self:combatTalentWeaponDamage(t, 0.5, 3) end,
	knockback = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	archery_onhit = function(self, t, target, x, y)
		if target:canBe("knockback") and not target.dead then
			target:knockback(self.x, self.y, t.knockback(self, t), false)
			target:crossTierEffect(target.EFF_OFFBALANCE, self:combatSteampower())
			game.logSeen(target, "%s is knocked back!", target:getName():capitalize())
		else
			game.logSeen(target, "%s resists the knockback!", target:getName():capitalize())
		end
	end,
	action = function(self, t)
		local tg = t.target(self, t)
		local targets = self:archeryAcquireTargets(nil, {no_energy=true, infinite=true, one_shot=true, type="steamgun"})
		if targets then
			self:archeryShoot(targets, t, tg, {mult=t.getMultiple(self, t), damtype=DamageType.PHYSICAL, type="steamgun"})
			return true
		end
	end,
	info = function(self, t)
		return ([[You fire a special solid shot with your steamgun(s) at a target for %d%% physical weapon damage.
		The weight of the shot will knock the target back %d tiles.
		This talent does not use ammo as it is the ammo.]])
		:tformat(100*t.getMultiple(self, t), t.knockback(self, t))
	end,
}

newTalent{
	name = "Impaler Shell", short_name = "TINKER_IMPALER_SHELL",
	type = {"steamtech/other",1},
	points = 5,
	cooldown = 10,
	steam = 5,
	radius = 0,
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 2 }, ESCAPE = { knockback = 2 }},
	target = function(self, t) return {type="ball", range=nil, radius=self:getTalentRadius(t), selffire=false} end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	getMultiple = function(self, t) return self:combatTalentWeaponDamage(t, 0.5, 3) end,
	duration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	archery_onhit = function(self, t, target, x, y)
		if target:canBe("knockback") and not target.dead then
			target:knockback(self.x, self.y, 2, false)
		end
		if target:canBe("pin") then
			target:setEffect(target.EFF_PINNED, t.duration(self, t), {apply_power=self:combatSteampower(), no_ct_effect=true})
		else
			game.logSeen(target, "%s resists the pin!", target:getName():capitalize())
		end
	end,
	action = function(self, t)
		local tg = t.target(self, t)
		local targets = self:archeryAcquireTargets(nil, {no_energy=true, infinite=true, one_shot=true, type="steamgun"})
		if targets then
			self:archeryShoot(targets, t, tg, {mult=t.getMultiple(self, t), damtype=DamageType.PHYSICAL, type="steamgun"})
			return true
		end
	end,
	info = function(self, t)
		return ([[You fire a special stake shot with your steamgun(s) at a target for %d%% physical weapon damage.
		The weight of the shot will knock the target back 2 tiles and they will be pinned for %d turns.
		This talent does not use ammo as it is the ammo.]])
		:tformat(100*t.getMultiple(self, t), t.duration(self, t))
	end,
}

newTalent{
	name = "Saw Shell", short_name = "TINKER_SAW_SHELL",
	type = {"steamtech/other",1},
	points = 5,
	cooldown = 10,
	steam = 5,
	radius = 0,
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 3 }},
	target = function(self, t) return {type="ball", range=nil, radius=self:getTalentRadius(t), selffire=false} end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	getMultiple = function(self, t) return self:combatTalentWeaponDamage(t, 0.5, 3) end,
	action = function(self, t)
		local tg = t.target(self, t)
		local targets = self:archeryAcquireTargets(nil, {no_energy=true, infinite=true, one_shot=true, type="steamgun"})
		if targets then
			self:archeryShoot(targets, t, tg, {mult=t.getMultiple(self, t), damtype=DamageType.PHYSICALBLEED, type="steamgun"})
			return true
		end
	end,
	info = function(self, t)
		return ([[You fire a special steamsaw shot with your steamgun(s) at a target for %d%% physical weapon damage.
		The steamsaw will cut into the target, doing %d%% physical weapon damage over 5 turns.
		This talent does not use ammo as it is the ammo.]])
		:tformat(100*t.getMultiple(self, t), 50*t.getMultiple(self, t))
	end,
}

newTalent{
	name = "Hook Shell", short_name = "TINKER_HOOK_SHELL",
	type = {"steamtech/other",1},
	points = 5,
	cooldown = 10,
	steam = 5,
	radius = 0,
	range = steamgun_range,
	requires_target = true,
	tactical = { CLOSEIN = 2},
	target = function(self, t) return {type="bolt", range=self:getTalentRange(t), nolock=true, talent=t} end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	distance = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	action = function(self, t)
		local tg = t.target(self, t)
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		
		if target then
			if target:canBe("knockback") then
				target:pull(self.x, self.y, t.distance(self, t))
			else
				game.logSeen(target, "%s resists the pull!", target:getName():capitalize())
			end
		else
			self:pull(tx, ty, t.distance(self, t))
		end
		return true
	end,
	info = function(self, t)
		return ([[You fire a special hook shot with your steamgun(s) at a target creature or location.
		If you target a creature, they are pulled up to %d tiles towards you.
		If you target an empty tile, you are pulled up to %d tiles towards it.
		This talent does not use ammo as it is the ammo.]])
		:tformat(t.distance(self, t), t.distance(self, t))
	end,
}

newTalent{
	name = "Magnetic Shell", short_name = "TINKER_MAGNETIC_SHELL",
	type = {"steamtech/other",1},
	points = 5,
	cooldown = 10,
	steam = 5,
	radius = 0,
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACK = { weapon = 1 }, DEBUFF = 2},
	target = function(self, t) return {type="ball", range=nil, radius=self:getTalentRadius(t), selffire=false} end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	duration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	getPower = function(self, t) return 10 + self:combatTalentSteamDamage(t, 0, 100) end,
	archery_onhit = function(self, t, target, x, y)
		target:setEffect(target.EFF_MAGNETISED, t.duration(self, t), {power=t.getPower(self, t), apply_power=self:combatSteampower(), no_ct_effect=true})
	end,
	action = function(self, t)
		local tg = t.target(self, t)
		local targets = self:archeryAcquireTargets(nil, {no_energy=true, infinite=true, one_shot=true, type="steamgun"})
		if targets then
			self:archeryShoot(targets, t, tg, {mult=1.0, type="steamgun"})
			return true
		end
	end,
	info = function(self, t)
		return ([[You fire a special magnetic shot with your steamgun(s) at a target for normal weapon damage.
		The shot will magnetise the target for %d turns. This lowers their defense and increases fatigue by %d.
		This talent does not use ammo as it is the ammo.
		Effect strength scales with Steampower.]])
		:tformat(t.duration(self, t), t.getPower(self, t))
	end,
}

newTalent{
	name = "Voltaic Shell", short_name = "TINKER_VOLTAIC_SHELL",
	type = {"steamtech/other",1},
	points = 5,
	cooldown = 10,
	steam = 5,
	radius = 0,
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACK = { LIGHTNING = 3 } },
	target = function(self, t) return {type="ball", range=nil, radius=self:getTalentRadius(t), selffire=false} end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 20, 250) end,
	archery_onhit = function(self, t, target, x, y)
		local tgts = {}
		local grids = core.fov.circle_grids(x, y, 5, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, engine.Map.ACTOR)
			if a and a ~= target and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end
		
		local dam = self:steamCrit(t.getDamage(self, t))

		for i = 1, math.floor(self:getTalentLevel(t)) do
			-- Randomly take targets
			local tg = {type="beam", range=5, friendlyfire=false, x=x, y=y}
			if #tgts <= 0 then return end
			local a, id = rng.tableRemove(tgts)

			self:project(tg, a.x, a.y, engine.DamageType.LIGHTNING, dam)
			game.level.map:particleEmitter(x, y, math.max(math.abs(a.x-x), math.abs(a.y-y)), "lightning", {tx=a.x-x, ty=a.y-y})
		end
		game:playSoundNear(target, "talents/lightning")
	end,
	action = function(self, t)
		local tg = t.target(self, t)
		local targets = self:archeryAcquireTargets(nil, {no_energy=true, infinite=true, one_shot=true, type="steamgun"})
		if targets then
			self:archeryShoot(targets, t, tg, {mult=1.0, damtype=DamageType.LIGHTNING, type="steamgun"})
			return true
		end
	end,
	info = function(self, t)
		return ([[You fire a special voltaic shot with your steamgun(s) at a target for 100%% weapon damage as lightning.
		The shot will release powerful electrical currents at up to %d nearby enemies. 
		Each bolt does %0.2f lightning damage.
		This talent does not use ammo as it is the ammo.
		Bolt damage scales with Steampower.]])
		:tformat(math.floor(self:getTalentLevel(t)), damDesc(self, DamageType.LIGHTNING, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Antimagic Shell", short_name = "TINKER_ANTIMAGIC_SHELL",
	type = {"steamtech/other",1},
	points = 5,
	cooldown = 10,
	steam = 5,
	radius = 0,
	range = steamgun_range,
	requires_target = true,
	tactical = { DEBUFF = 2 },
	target = function(self, t) return {type="ball", range=nil, radius=self:getTalentRadius(t), selffire=false} end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 20, 250) end,
	archery_onhit = function(self, t, target, x, y)
		DamageType:get(DamageType.MANABURN).projector(self, x, y, DamageType.MANABURN, self:steamCrit(t.getDamage(self, t)))
		-- Pondering applying a spell failure chance effect too.
	end,
	action = function(self, t)
		local tg = t.target(self, t)
		local targets = self:archeryAcquireTargets(nil, {no_energy=true, infinite=true, one_shot=true, type="steamgun"})
		if targets then
			self:archeryShoot(targets, t, tg, {mult=1.0, type="steamgun"})
			return true
		end
	end,
	info = function(self, t)
		return ([[You fire a special antimagic shot with your steamgun(s) at a target for 100%% normal weapon damage.
		The shot will release antimagic sap on the target, doing %0.2f arcane resource burn damage.
		This talent does not use ammo as it is the ammo.
		Sap damage scales with Steampower.]])
		:tformat(damDesc(self, DamageType.ARCANE, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Botanical Shell", short_name = "TINKER_BOTANICAL_SHELL",
	type = {"steamtech/other",1},
	points = 5,
	cooldown = 10,
	steam = 5,
	radius = function(self, t)
		return math.floor(self:combatTalentScale(t, 1.0, 2.0, nil, 0, 0, true))
	end,
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACKAREA = {NATURE=1}, HEAL = 1 },
	target = function(self, t) return {type="ball", range=nil, radius=self:getTalentRadius(t), selffire=false} end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 6, 40) end,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 16, 4, 8)) end, -- Limit < 16
	getHeal = function(self, t) return math.floor(self:combatTalentLimit(t, 200, 62, 110)) end, -- Limit < 200%	
	archery_onhit = function(self, t, target, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.NOURISHING_MOSS, {dam=self:steamCrit(t.getDamage(self, t)), factor=t.getHeal(self, t)/100},
			self:getTalentRadius(t),
			5, nil,
			{type="moss"},
			nil, false, false
		)
		game:playSoundNear(target, "talents/slime")
	end,
	action = function(self, t)
		local tg = t.target(self, t)
		local targets = self:archeryAcquireTargets(nil, {no_energy=true, infinite=true, one_shot=true, type="steamgun"})
		if targets then
			self:archeryShoot(targets, t, tg, {mult=1.0, damtype=DamageType.NATURE, type="steamgun"})
			return true
		end
	end,
	info = function(self, t)
		return ([[You fire a special botanical shot with your steamgun(s) at a target for 100%% weapon damage as nature.
		The shot will release spores which grow into Nourishing Moss in a radius of %d for %d turns.
		Each turn the moss deals %0.2f nature damage to each foe within its radius.
		This moss has vampiric properties and heals the user for %d%% of the damage done.
		This talent does not use ammo as it is the ammo.
		Moss damage scales with Steampower.]])
		:tformat(self:getTalentRadius(t), t.getDuration(self, t), damDesc(self, DamageType.NATURE, t.getDamage(self, t)), t.getHeal(self, t))
	end,
}

newTalent{
	name = "Corrosive Shell", short_name = "TINKER_CORROSIVE_SHELL",
	type = {"steamtech/other",1},
	points = 5,
	cooldown = 10,
	steam = 5,
	radius = 0,
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACK = { ACID = 2 }, DEBUFF = 2 },
	target = function(self, t) return {type="ball", range=nil, radius=self:getTalentRadius(t), selffire=false} end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	getMultiple = function(self, t) return self:combatTalentWeaponDamage(t, 0.5, 2.5) end,
	duration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	getPower = function(self, t) return 10 + self:combatTalentSteamDamage(t, 0, 50) end,
	archery_onhit = function(self, t, target, x, y)
		target:setEffect(target.EFF_CORRODE, t.duration(self, t), {atk=t.getPower(self, t), armor=t.getPower(self, t), defense=t.getPower(self, t), apply_power=self:combatSteampower(), no_ct_effect=true})
	end,
	action = function(self, t)
		local tg = t.target(self, t)
		local targets = self:archeryAcquireTargets(nil, {no_energy=true, infinite=true, one_shot=true, type="steamgun"})
		if targets then
			self:archeryShoot(targets, t, tg, {mult=t.getMultiple(self, t), damtype=DamageType.ACID, type="steamgun"})
			return true
		end
	end,
	info = function(self, t)
		return ([[You fire a special corrosive shot with your steamgun(s) at a target for %d%% weapon damage as acid.
		The acid released by the shot will also corrode the target, reducing its accuracy, defense and armour by %d.
		This talent does not use ammo as it is the ammo.
		Corrosion strength scales with Steampower.]])
		:tformat(100*t.getMultiple(self, t), t.getPower(self, t))
	end,
}

newTalent{
	name = "Toxic Shell", short_name = "TINKER_TOXIC_SHELL",
	type = {"steamtech/other",1},
	points = 5,
	cooldown = 10,
	steam = 5,
	radius = 0,
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACK = { BLIGHT = 2 }, DEBUFF = 2 },
	target = function(self, t) return {type="ball", range=nil, radius=self:getTalentRadius(t), selffire=false} end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	duration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	getPower = function(self, t) return 10 + self:combatTalentSteamDamage(t, 0, 50) end,
	archery_onhit = function(self, t, target, x, y)
		if target:canBe("poison") then
			target:setEffect(target.EFF_METAL_POISONING, t.duration(self, t), {src=self, power=t.getPower(self, t), speed=t.getPower(self, t)-10, apply_power=self:combatSteampower(), no_ct_effect=true})
		else
			game.logSeen(target, "%s resists the toxin!", target:getName():capitalize())
		end
	end,
	action = function(self, t)
		local tg = t.target(self, t)
		local targets = self:archeryAcquireTargets(nil, {no_energy=true, infinite=true, one_shot=true, type="steamgun"})
		if targets then
			self:archeryShoot(targets, t, tg, {mult=1.0, damtype=DamageType.BLIGHT, type="steamgun"})
			return true
		end
	end,
	info = function(self, t)
		return ([[You fire a special toxic shot with your steamgun(s) at a target for 100%% weapon damage as blight.
		The shot will release heavy metals into the target, inflicting %0.2f blight damage per turn and reducing their global speed by %d%% for %d turns.
		This talent does not use ammo as it is the ammo.
		Toxin strength scales with Steampower.]])
		:tformat(damDesc(self, DamageType.BLIGHT, t.getPower(self, t)), t.getPower(self, t)-10, t.duration(self, t))
	end,
}

newTalent{
	name = "Moss Tread", short_name = "TINKER_MOSS_TREAD",
	type = {"steamtech/other",1},
	points = 5,
	cooldown = 10,
	steam = 5,
	radius = 0,
	range = 0,
	no_energy = true,
	requires_target = true,
	tactical = { ATTACK = { NATURE = 1 }, ESCAPE = { pin = 1 } },
	target = function(self, t) return {type="ball", range=nil, radius=self:getTalentRadius(t), selffire=false} end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 6, 40) end,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 16, 4, 8)) end, -- Limit < 16
	getSlow = function(self, t) return math.ceil(self:combatTalentLimit(t, 100, 36, 60)) end, -- Limit < 100%
	getPin = function(self, t) return math.ceil(self:combatTalentLimit(t, 100, 25, 45)) end, -- Limit < 100%
	trigger = function(self, t, x, y, dam) -- avoid stacking on map tile
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.GRASPING_MOSS, {dam=dam, pin=t.getPin(self, t), slow=t.getSlow(self, t)},
			self:getTalentRadius(t),
			5, nil,
			{type="moss"},
			nil, false, false
		)
	end,
	action = function(self, t)
		local dur = t.getDuration(self, t)
		self:setEffect(self.EFF_MOSS_TREAD, dur*2, {dam=self:steamCrit(t.getDamage(self, t))})
		return true
	end,
	info = function(self, t)
		local dur = t.getDuration(self, t)
		local dam = t.getDamage(self, t)
		return ([[For %d turns, you lay down Grasping Moss where you walk or stand.
		The moss is placed automatically every step and lasts %d turns.
		Each turn the moss deals %0.2f nature damage to each foe standing on it.
		This moss is very thick and sticky causing all foes passing through it have their movement speed reduced by %d%% and have a %d%% chance to be pinned to the ground for 4 turns.
		The damage scales with your Steampower.]]):
		tformat(dur*2, dur, damDesc(self, DamageType.NATURE, dam), t.getSlow(self, t), t.getPin(self, t))
	end,
}

newTalent{
	name = "Arcane Dynamo", short_name = "TINKER_ARCANE_DYNAMO",
	type = {"steamtech/other",1},
	is_technomancy = true, is_steam = true, is_spell = true,
	type_no_req = true,
	mode = "passive",
	points = 5,
	autolearn_talent = "T_STEAM_POOL",
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "arcane_dynamo", self:getTalentLevel(t))
		if not self.in_combat then
			self:talentTemporaryValue(p, "steam_regen", -2)
		end
	end,
	getSpellpower = function(self, t)
		local p = self:getSteam() / 100 -- Not using max_steam to be able to go over 100% bonus
		return p * 80 - 20
	end,
	callbackOnTalentPost = function(self, t, ab)
		if ab.is_spell and ab.mana and not ab.steam and ab.mode == "activated" then
			local m = util.getval(ab.mana, self, ab)
			if tonumber(m) then self:incSteam(m / 10 * (self:attr("arcane_dynamo") or 1)) end
		end
	end,
	callbackOnCombat = function(self, t, combat)
		self:updateTalentPassives(t)
	end,
	info = function(self, t)
		return ([[Allows the use of Technomancy spells.
		Grants a magical steam reserve that regenerates %d steam per 10 mana spent.
		Grants Spellpower based on current steam level (currently %d; %d%% steam filled).
		Outside of combat, you relax and let your steam reserve slowly wither away.
		#{italic}#Metal Arcane Power!#{normal}#]]):
		tformat(self:attr("arcane_dynamo") or 1, t.getSpellpower(self, t), self:getSteam())
	end,
}
