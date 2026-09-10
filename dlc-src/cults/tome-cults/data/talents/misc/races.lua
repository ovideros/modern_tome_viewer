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

local Dialog = require "engine.ui.Dialog"

------------------------------------------------------------------------------
-- Drem
------------------------------------------------------------------------------
newTalentType{ type="race/drem", name = _t("drem", "talent type"), generic = true, description = _t"The various racial bonuses a character can have." }
newTalent{
	short_name = "DREM_FRENZY",
	name = "Frenzy",
	type = {"race/drem", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 8, 45, 25)) end, -- Limit >8
	fixed_cooldown = true,
	tactical = { BUFF = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_DREM_FRENZY, 3, {})
		return true
	end,
	info = function(self, t)
		return ([[Enter a killing frenzy for 3 turns.
		During the frenzy the first time you use a class talent it has no cooldown (but does if used twice).
		This does not work for inscriptions, talents that take no turn to use, passives, or talents with fixed cooldowns.
		]]):
		tformat()
	end,
}

newTalent{
	name = "Spikeskin",
	type = {"race/drem", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	getDamage = function(self, t) return self:combatStatScale("mag", 40, 150) / 5 end,
	getNb = function(self, t) return math.floor(self:getTalentLevel(t)) end,
	callbackOnMeleeHit = function(self, t, src, dam)
		if self.turn_procs.spikeskin or src:hasEffect(src.EFF_SPIKESKIN_BLACK_BLOOD) then return end
		self.turn_procs.spikeskin = true
		src:setEffect(src.EFF_SPIKESKIN_BLACK_BLOOD, 5, {src=self, power=t.getDamage(self, t)})
	end,
	callbackOnActBase = function(self, t)
		local nb_foes = 0
		for i = 1, #self.fov.actors_dist do
			local act = self.fov.actors_dist[i]
			if act and self:canSee(act) and act:hasEffect(act.EFF_SPIKESKIN_BLACK_BLOOD) and core.fov.distance(self.x, self.y, act.x, act.y) <= 2 then nb_foes = nb_foes + 1 end
		end
		if nb_foes >= 1 then
			nb_foes = math.min(nb_foes, t.getNb(self, t))
			self:setEffect(self.EFF_SPIKESKIN, 2, {power=nb_foes * 5})
		end
	end,
	info = function(self, t)
		return ([[Your skin grows small spikes coated in dark blight.
		When you are hit in melee the attacker starts bleeding black blood for 5 turns that deals %0.2f darkness damage each turn. This effect may only happen once per turn.
		You are empowered by the sight of the black blood, for each bleeding creature in radius 2 you gain 5%% all resistances, limited to %d creatures.
		The damage will scale with your Magic stat.]]):
		tformat(damDesc(self, DamageType.DARKNESS, t.getDamage(self, t)), t.getNb(self, t))
	end,
}

newTalent{
	name = "Faceless",
	type = {"race/drem", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	getSave = function(self, t) return self:combatTalentScale(t, 8, 30, 0.75) end,
	getImmune = function(self, t) return self:combatTalentScale(t, 20, 60, 0.75) / 100 end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_mentalresist", t.getSave(self, t))
		self:talentTemporaryValue(p, "confusion_immune", t.getImmune(self, t))
	end,
	info = function(self, t)
		return ([[Your faceless visage is puzzling and emotionless, allowing you to more easily resist mind tricks.
		You gain %d mental save, %d%% confusion immunity.]]):
		tformat(t.getSave(self, t), t.getImmune(self, t) * 100)
	end,
}

newTalent{
	name = "From Below It Devours",
	type = {"race/drem", 4},
	require = racial_req4,
	points = 5,
	cooldown = function(self, t) return 45 end,
	range = 5,
	no_npc_use = true,
	getLife = function(self, t) return self:combatStatScale("con", 70, 800) * (1 + self:getTalentLevel(t) / 5) end,
	getTime = function(self, t) return 4 + math.floor(self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = {type="hit", nowarning=true, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
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
			type = "horror", subtype = "corrupted",
			name = _t"hungering mouth",
			display = "h", color=colors.GREEN, blood_color = colors.GREEN,
			desc = _t[["From below, it devours."]],
			body = { INVEN = 10 },
			faction = self.faction,
			image="npc/hungering_mouth.png",
			level_range = {1, self.level}, exp_worth = 0,
			max_life = t.getLife(self, t), life_rating = 20, fixed_rating = true,
			rank = 3,
			size_category = 3,
			infravision = 10,
			never_move = 1,
			immune_possession = 1,
			no_auto_resists = true,

			resists = {all = math.min(50, self.level)},
			combat_armor = self.level,
			combat_armor_hardiness = 60,
			combat = {dam=1},

			resolvers.talents{
				[self.T_DREM_CALL_OF_AMAKTHEL]=1,
			},

			autolevel = "warriormage",
			ai = "summoned", ai_real = "dumb_talented", ai_state = { talent_in=1, },
			summoner = self, summoner_gain_exp=true,
			summon_time = t.getTime(self, t),
		}

		m:resolve() m:resolve(nil, true)
		m:forceLevelup(self.level)
		game.zone:addEntity(game.level, m, "actor", x, y)
		m:forceUseTalent(m.T_DREM_CALL_OF_AMAKTHEL, {ignore_cooldown=true, ignore_energy=true})

		if self:knowTalent(self.T_STONE_FORTRESS) then
			self:setEffect(self.EFF_HORRIFIC_FORTRESS, 1, {src=m, power=self:combatArmor() * self:callTalent(self.T_STONE_FORTRESS, "getPercent")/ 100})
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Your affinity with things that dwell deep beneath the surface allows you to summon a hungering mouth.
		The mouth has %d bonus life, lasts for %d turns, and deals no damage.
		Each turn the mouth will draw all enemies in radius 10 2 spaces towards itself.
		Its bonus life depends on your Constitution stat and talent level.  Many other stats will scale with level.]]):
		tformat(t.getLife(self, t), t.getTime(self, t))
	end,
}
-- Alter Stone Fortress description
local oldinfo_stone_fortress = Talents.talents_def.T_STONE_FORTRESS.info
Talents.talents_def.T_STONE_FORTRESS.info = function(self, t)
	local desc = oldinfo_stone_fortress(self, t)
	return desc.._t"\nFor Drems this effect activates as long as the hungering mouth summoned by From Below It Devours is alive."
end

------------------------------------------------------------------------------
-- Krogs
------------------------------------------------------------------------------
newTalentType{ type="race/krog", name = _t("krog", "talent type"), generic = true, description = _t"The various racial bonuses a character can have." }
newTalent{
	short_name = "KROG_WRATH",
	name = "Wrath of the Wilds",
	type = {"race/krog", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 15, 45, 25)) end,
	tactical = { BUFF = 2 },
	getChance = function(self, t) return self:combatStatScale("con", 7, 20) end,
	action = function(self, t)
		self:setEffect(self.EFF_KROG_WRATH, 5, {power=t.getChance(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[You unleash the wrath of the wilds for 5 turns.
		When you deal damage to a creature while wrath is active you have %d%% chance (100%% for the first creature hit each turn) to stun them for 3 turns.
		This effect can only stun a creature once per turn.
		Chance scales with your Constitution and apply power is the highest or your physical or mind power.]]):
		tformat(t.getChance(self, t))
	end,
}

-- Only let players change this occasionally so the micromanagement isn't tedious but do make it instant so it can be used adaptively instead of just to fill gaps in resist gear
newTalent{
	name = "Drake-Infused Blood",
	type = {"race/krog", 2},
	require = racial_req2,
	points = 5,
	no_energy = true,
	getImmune = function(self, t) return self:combatTalentScale(t, 20, 60, 0.75) end,
	getResist = function(self, t) return self:combatStatScale("wil", 20, 60) end,
	getRetaliation = function(self, t) return self:combatStatScale("wil", 1, 80) end,
	on_pre_use = function(self, t, silent) if not (self.krog_kills and self.krog_kills >= 100) then if not silent then game.logPlayer(self, "You must kill more enemies before you can use this talent!") end return false end return true end,
	passives = function(self, t, p)
		local damtype = self.drake_infused_blood_type or DamageType.FIRE
		local resist = t.getResist(self, t)
		local damage = t.getRetaliation(self, t)
		if damtype == DamageType.PHYSICAL then 
			resist = resist / 3
			damage = damage / 3
		end		
		self:talentTemporaryValue(p, "melee_project", {[damtype] = damage})
		self:talentTemporaryValue(p, "resists", {[damtype] = resist})
		self:talentTemporaryValue(p, "stun_immune", t.getImmune(self, t) / 100)
		self:talentTemporaryValue(p, "allow_any_dual_weapons", 1)

	end,
	callbackOnKill = function(self, t, target)
		if target:worthExp(self) <= 0 then return end
		self.krog_kills = self.krog_kills or 0
		self.krog_kills = self.krog_kills + 1

		if self.krog_kills == 100 then game.bignews:say(120, "#GREEN#You can now change your elemental drake aspect") end
		return true
	end,
	callbackOnLevelup = function(self, t, new_level)
		self:updateTalentPassives(t.id)
	end,
	callbackOnStatChange = function(self, t, stat, v)
		if stat == self.STAT_WIL then
			self:updateTalentPassives(t)
		end
	end,
	action = function(self, t)
		local possibles = {
			{name=DamageType:get(DamageType.FIRE).text_color.._t"Fire Drake / Fire Resistance", damtype=DamageType.FIRE},
			{name=DamageType:get(DamageType.COLD).text_color.._t"Cold Drake / Cold Resistance", damtype=DamageType.COLD},
			{name=DamageType:get(DamageType.LIGHTNING).text_color.._t"Storm Drake / Lightning Resistance", damtype=DamageType.LIGHTNING},
			{name=DamageType:get(DamageType.PHYSICAL).text_color.._t"Sand Drake / Physical Resistance (1/3rd values)", damtype=DamageType.PHYSICAL},
			{name=DamageType:get(DamageType.NATURE).text_color.._t"Wild Drake / Nature Resistance", damtype=DamageType.NATURE},
			{name=DamageType:get(DamageType.ACID).text_color.._t"Acid Drake / Acid Resistance", damtype=DamageType.ACID},
			{name=_t"Never mind"},
		}
		local cur_type = self.drake_infused_blood_type or DamageType.FIRE
		for _, item in ipairs(possibles) do
			if item.damtype and item.damtype == cur_type then
				item.name = item.name .. _t'#LAST# #{italic}#(current)#{normal}#'
				break
			end
		end
		local damtype = self:talentDialog(Dialog:listPopup(_t"Drake Aspect", _t"Choose an aspect to bring forth:", possibles, 500, 400, function(item) self:talentDialogReturn(item) end))
		if damtype and damtype.damtype then
			self.drake_infused_blood_type = damtype.damtype
			self:updateTalentPassives(t.id)
			self.krog_kills = 0
		end
		return true
	end,
	info = function(self, t)
		local damtype = self.drake_infused_blood_type or DamageType.FIRE
		local resist = t.getResist(self, t)
		local damage = t.getRetaliation(self, t)
		if damtype == DamageType.PHYSICAL then
			resist = resist / 3
			damage = damage / 3
		end
		local damname = DamageType:get(damtype).text_color..DamageType:get(damtype).name.."#LAST#"
		return ([[Since ziguranth removed those filthy magic runes from your body you have needed an alternative form of power to sustain your body. Thanks to drake blood you have found that power.
		Your blood hardens yourself, passively increasing stun resistance by %d%%, %s resistance by %d%% and dealing %d %s damage on melee attacks.
		You can activate this talent to change which drake aspect to bring forth, altering the elemental type of the bonus.
		The resistance and damage scales with your Willpower.

		Changing your aspect requires combat experience, you may only do so after slaying 100 enemies (current %d).

		When you learn this talent you become so strong you can wield any type of one handed weapon in your offhand.]]):
		tformat(t.getImmune(self, t), damname, resist, damDesc(self, damtype, damage), damname, self.krog_kills or 0)
	end,
}

newTalent{
	name = "Fuel Pain",
	type = {"race/krog", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	cooldown = function(self, t) return self:combatTalentLimit(t, 8, 25, 10) end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, state)
		if self:isTalentCoolingDown(self.T_FUEL_PAIN) then return end
		if dam < self.max_life * 0.2 then return end
		local list = {}
		for tid, c in pairs(self.talents_cd) do
			local t = self:getTalentFromId(tid)
			if t and t.is_inscription then
				list[#list+1] = tid
			end
		end
		if #list > 0 then
			local tid = rng.table(list)
			self:alterTalentCoolingdown(tid, -1000)
			self:startTalentCooldown(t)
			self:removeEffect(self.EFF_INFUSION_COOLDOWN)
		end
	end,
	info = function(self, t)
		return ([[Your body is used to pain. When you take a hit of 20%% or more of your max life one of your inscriptions is taken off cooldown and infusion saturation is removed.
		This effect has a cooldown of %d turns.]]):
		tformat(self:getTalentCooldown(t))
	end,
}

newTalent{
	name = "Drakeblood Strike",
	short_name = "WARBORN",
	type = {"race/krog", 4},
	require = racial_req4,
	points = 5,
	requires_target = true,
	tactical = { ATTACK = 3 },
	cooldown = 8,
	is_melee = true,
	getDuration = function(self, t) return 3 end,
	getDamage = function (self, t) return self:combatTalentWeaponDamage(t, 1.5, 3) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local damtype = self.drake_infused_blood_type or DamageType.FIRE
		local hit = self:attackTarget(target, damtype, t.getDamage(self, t), true)
		if hit then
			target:setEffect(target.EFF_SILENCED, t.getDuration(self, t), {apply_power=math.max(self:combatMindpower(), self:combatPhysicalpower())})
		end

		return true
	end,
	info = function(self, t)
		local damtype = self.drake_infused_blood_type or DamageType.FIRE
		local damname = DamageType:get(damtype).text_color..DamageType:get(damtype).name.."#LAST#"

		return ([[You were created by ziguranth for one purpose only, to wage war on magic!
			Strike your target dealing %d%% %s weapon damage and silencing them for %d turns.
			The damage type will change with your drake aspect.
			The chance to silence will increase with the highest of your physical or mind power.]]):tformat(100 * t.getDamage(self, t), damname, t.getDuration(self, t))
	end,
}

------------------------------------------------------------------------------
-- Parasite, Fanged Collar
------------------------------------------------------------------------------
newTalentType{ type="race/parasite", name = _t("parasite", "talent type"), generic = true, description = _t"The various racial bonuses a character can have.. when its head is cut off and replaced with a parasite." }
newTalent{
	name = "Take a Bite",
	type = {"race/parasite", 1},
	require = racial_req1,
	points = 5,
	range = 1,
	no_message = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 15, 45, 25)) end,
	tactical = { ATTACK = {weapon=2}, HEAL=1 },
	getDam = function(self, t) return math.max(self:combatStatScale("str", 50, 150), self:combatStatScale("dex", 50, 150), self:combatStatScale("mag", 50, 150)) / 100 end,
	getChance = function(self, t) return self:combatStatScale("con", 20, 70) end,
	getRegen = function(self, t) return self:combatStatScale("con", 3, 25) end,
	no_npc_use = true,
	is_melee = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		self:logCombat(target, "#Source# tries to bite #target#!")
		local hit = self:attackTarget(target, DamageType.BLIGHT, t.getDam(self, t), true)
		if not hit then return true end

		self:setEffect(self.EFF_REGENERATION, 5, {power=t.getRegen(self, t)})

		if (target.life * 100 / target.max_life > 20) and not target.dead then return true end

		if target.dead or target:canBe("instakill") then
			if not target.dead then target:die(self) end
		else
			game.logSeen(target, "%s resists!", target:getName():capitalize())
		end
		return true
	end,
	info = function(self, t)
		return ([[You try to bite off your foe with your #{italic}#head#{normal}# for %d%% blight weapon damage.
		If the target falls under 20%% life you have %d%% chances to outright kill it (bosses are immune).
		Whenever you succesfully bite a foe you regenerate %0.1f life per turn for 5 turns.
		Instant kill chances and regeneration increase with your Constitution stat and weapon damage increases with the highest of your Strength, Dexterity or Magic stat.]]):
		tformat(t.getDam(self, t) * 100, t.getChance(self, t), t.getRegen(self, t))
	end,
}

newTalent{
	name = "Ultra Instinct",
	type = {"race/parasite", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	getSpeed = function(self, t) return self:combatTalentLimit(t, 40, 5, 25) / 100 end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "global_speed_add", t.getSpeed(self, t))
	end,
	info = function(self, t)
		return ([[Without the distraction of #{bold}#thoughts#{normal}# or #{bold}#self#{normal}# your body reacts faster and better to aggressions.
		Increases global speed by %d%%.]]):
		tformat(t.getSpeed(self, t) * 100)
	end,
}

newTalent{
	name = "Corrupting Influence",
	type = {"race/parasite", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	getResist = function(self, t) return self:combatTalentLimit(t, 50, 14, 40) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "resists", {
			[DamageType.BLIGHT] = t.getResist(self, t),
			[DamageType.DARKNESS] = t.getResist(self, t),
			[DamageType.TEMPORAL] = t.getResist(self, t),
			[DamageType.ACID] = t.getResist(self, t),
			[DamageType.NATURE] = -t.getResist(self, t) / 3,
			[DamageType.LIGHT] = -t.getResist(self, t) / 3,
		})
	end,
	info = function(self, t)
		return ([[The parasite corruption seeps into your body, strengthening it.
		Increases blight, darkness, temporal and acid resistances by %d%% but decreases nature and light resistances by %d%%.]]):
		tformat(t.getResist(self, t), t.getResist(self, t) / 3)
	end,
}

newTalent{
	name = "Horror Shell",
	type = {"race/parasite", 4},
	require = racial_req4,
	points = 5,
	requires_target = true,
	range = 10,
	cooldown = function(self, t) return self:combatTalentLimit(t, 10, 30, 16) end,
	tactical = { DEFEND = 2 },
	getShield = function(self, t)
		return 3.2*self:getCon()+self:combatTalentScale(t, 120, 300) + self:combatTalentLimit(t, 0.1, 0.01, 0.05)*self.max_life
	end,
	action = function(self, t)
		self:setEffect(self.EFF_DAMAGE_SHIELD, 10, {color={0x6b/255, 0xcb/255, 0x9b/255}, power=t.getShield(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Creates a shell around you, absorbing %d damage. Lasts for 10 turns.
		The total damage the shield can absorb increases with your Constitution.]]):
		tformat(self:getShieldAmount(t.getShield(self, t)))
	end,
}
