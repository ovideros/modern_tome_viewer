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

function getMecharachnid(self)
	if self.tinker_mecharachnid and game.level and game.level:hasEntity(self.tinker_mecharachnid) then
		return self.tinker_mecharachnid
	end
end

function hasTailWeapon(self, type)
	if self:attr("disarmed") then
		return nil, _t"disarmed"
	end
	
	local weapon = table.get(self:getInven("MECHARACHNID_TAIL"), 1)
	
	if weapon and type and type=="steamsaw" and weapon.subtype=="steamsaw" then 
		return weapon
	else
		-- find ammo and shooters
		local ammo = table.get(self:getInven("QUIVER"), 1)
		if not ammo then return nil, _t"no ammo" end
		if not ammo.archery_ammo or not ammo.combat then return nil, _t"bad ammo" end
		local msg
		if weapon and weapon.combat and weapon.archery_kind then
			if type and weapon.archery_kind ~= type then
				msg = _t"incompatible missile launcher"
			elseif weapon.archery ~= ammo.archery_ammo then
				msg = _t"incompatible ammo"
			end
			if msg then weapon = nil end
		else weapon = nil
		end

		if not weapon then return nil, msg or _t"no shooter" end
		return weapon, ammo
	end
end

function tailgun_range(self, t)
	local weapon = table.get(self:getInven("MECHARACHNID_TAIL"), 1)
	if weapon and weapon.subtype=="steamgun" then 
		local br = (self.archery_bonus_range or 0)
		local range = math.max(weapon and br + weapon.combat.range or 6, self:attr("archery_range_override") or 0)
		return math.max(weapon and br + weapon.combat.range or 6, self:attr("archery_range_override") or 0)
	else
		return 0
	end
end


newTalent{
	name = "Mecharachnid Link",
	type = {"steamtech/other", 1},
	points = 1,
	mode = "sustained",
	requires_target = true,
	range = 10,
	tactical = { BUFF=100 },
	activate = function(self, t) return {} end,
	deactivate = function(self, t, p) return true end,
	info = function(self, t) return (_t[[Link to the summoner.]]) end,
}

newTalent{
	name = "Self-destruction", short_name = "MECHARACHNID_DESTRUCTION",
	type = {"steamtech/other", 1},
	points = 1,
	range = 0,
	radius = 4,
	no_unlearn_last = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	tactical = { ATTACKAREA = { FIRE = 3 } },
	no_npc_use = true,
	on_pre_use = function(self, t)
		return self.summoner and self.summoner.dead
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.FIRE, 50 + 10 * self.level)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_fire", {radius=tg.radius})
		game:playSoundNear(self, "talents/fireflash")
		self:die(self)
		return true
	end,
	info = function(self, t)
		local rad = self:getTalentRadius(t)
		return ([[The mecharachnid self-destructs, destroying itself and generating a blast of fire in a radius of %d, doing %0.2f fire damage.
		This spell is only usable when the mecharachnid's master is dead.]]):tformat(rad, damDesc(self, DamageType.FIRE, 50 + 10 * self.level))
	end,
}

local function makeMecharachnid(self)
	self:attr("summoned_times", 11)
	local g = require("mod.class.NPC").new{
		type = "mechanical", subtype = "arachnid",
		name = "mecharachnid", color=colors.GREY,
		desc = _t[[A heavily armored mechachnical spider, armed to the teeth with advanced weaponry.]],
		display = 'S', color=colors.GREY,
		resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/mechanical_arachnid_automated_defense_system_two.png", display_h=2, display_y=-1}}},		
		level_range = {1, self.max_level}, exp_worth=0,
		life_rating = 16,
		never_anger = true,
		difficulty_boosted = 1,  -- Avoid difficulty boosting, adding to party probably also works but I'm positive this always does

		save_hotkeys = true,

		combat = { dam=10, atk=10, apr=0, dammod={str=1.0} },

		body = { INVEN = 1000, MAINHAND = 1, OFFHAND = 1, QUIVER = 1, BODY = 1, },
		equipdoll = "mecharachnid",
		infravision = 10,
		rank = 3,
		size_category = 3,
		movement_speed = 2,
		no_breath = 1,
		stormcoil = nil,
		archery_pass_friendly = 1,
		mecharachnid = 1, 
		minion_be_nice = 1, --not entirely appropriate but works
		can_tinker = { steamtech = 1 },
		
		resolvers.talents{
			[Talents.T_SHOOT]=1,
			[Talents.T_MECHARACHNID_LINK]=1,
			[Talents.T_MECHARACHNID_DESTRUCTION]=1,
		},

		resolvers.equip{ id=true,
			{type="weapon", subtype="steamgun", base_list="mod.class.Object:/data-orcs/general/objects/steamgun.lua", autoreq=true, ego_chance=-1000, not_properties = {"unique"}},
			{type="weapon", subtype="steamgun", base_list="mod.class.Object:/data-orcs/general/objects/steamgun.lua", autoreq=true, ego_chance=-1000, not_properties = {"unique"}},
			{type="ammo", subtype="shot", autoreq=true, ego_chance=-1000, not_properties = {"unique"}},
			{type="armor", subtype="heavy", ego_chance = -1000, id=true, autoreq=true, not_properties = {"unique"}},
		},

		power_source = {arcane = true},
		resolvers.inscription("IMPLANT:_STEAM_GENERATOR", {cooldown=32, power=10}),

		max_inscriptions = 1,

		hotkey = {},
		hotkey_page = 1,
		move_others = true,

		ai = "tactical",
		ai_state = { talent_in=1, ai_move="move_astar", ally_compassion=0 },
		ai_tactic = {type="mecharachnid_pet", attack=2, attackarea=2, disable=2, escape=1, safe_range=3, defend=2,},
		stats = { str=15, dex=12, cun=15, con=12 },
		combat_atk = resolvers.levelup(1, 1, 2),  -- We don't have many gear slots or talents, make sure binary outcome stats scale naturally

		-- No natural exp gain
		gainExp = function() end,
		forceLevelup = function(self) if self.summoner then return mod.class.Actor.forceLevelup(self, self.summoner.level) end end,

		-- Break control when losing LOS
		on_act = function(self)
			if not self:isTalentActive(self.T_MECHARACHNID_LINK) then self:forceUseTalent(self.T_MECHARACHNID_LINK, {ignore_cooldown=true, ignore_energy=true}) end
			if game.player ~= self then return end
			if self:hasEffect(self.EFF_MECHARACHNID_PILOTING) then return end
			if not self.summoner.dead and not self:hasLOS(self.summoner.x, self.summoner.y) then
				if not self:hasEffect(self.EFF_MECHARACHNID_OFS) then
					self:setEffect(self.EFF_MECHARACHNID_OFS, 4, {})
				end
			else
				if self:hasEffect(self.EFF_MECHARACHNID_OFS) then
					self:removeEffect(self.EFF_MECHARACHNID_OFS)
				end
			end
		end,

		on_can_control = function(self, vocal)
			if not self:hasLOS(self.summoner.x, self.summoner.y) then
				if vocal then game.logPlayer(game.player, "Your mecharachnid is out of sight; you cannot establish direct control.") end
				return false
			end
			return true
		end,
		
		on_takehit = function(self, value, src, death_note)
			if self.stormcoil then
				
				if value >= self.max_life*0.15 then
					local excess = value - self.max_life*0.15
					excess = excess * (self.summoner:callTalent(self.summoner.T_STORMCOIL_GENERATOR, "getDamageReduction"))
					value = value - excess
					self:setEffect(self.EFF_SPEED, 2, {src=self, (self.summoner:callTalent(self.summoner.T_STORMCOIL_GENERATOR, "getSpeed"))})
				end
			end
			return value
		end,

		-- Restrict what it can wear
		canWearObject = function(self, o, try_slot)
			if o.type == "weapon" and o.subtype ~= "steamgun" then
				return nil, "mecharachnid can only use steamguns"
			end
			return mod.class.Actor.canWearObject(self, o, try_slot)
		end,
		
		--- Update tile for races that can handle it
		moddable_tile = "mecharachnid",
		chassis_tile_id = 1,
		chassis_base_id = 1,
		updateModdableTile = function(self)
			if not self:updateModdableTilePrepare() then return end
			local mecharachnid_dy = 0

			local is_piloted = nil
			if self:hasEffect(self.EFF_MECHARACHNID_PILOTING) then
				local base_name = "unknown"
				local summoner = self:hasEffect(self.EFF_MECHARACHNID_PILOTING).src
				if summoner and summoner.moddable_tile then base_name = summoner.moddable_tile:gsub("#sex#", summoner.female and "female" or "male") end
				mecharachnid_dy = (self:getTalentFromId(self.T_MECHARACHNID).mecharachnid_offsets[base_name] or 40) / 128
				is_piloted = summoner
			end

			local base = "player/mecharachnid/"
			self.image = "invis.png"
			self.add_mos = {}
			local add = self.add_mos
			local i
			local weapontiers = { [1] = "iron", [2] = "steel", [3] = "dsteel", [4] = "stralite", [5] = "voratun"}

			add[#add+1] = {image=base.."base_shadow.png", display_y=mecharachnid_dy}
			add[#add+1] = {image=base..("base_tail_%02d.png"):format(self.chassis_tile_id), display_y=mecharachnid_dy-1, display_h=2}
			if not self:attr("disarmed") then
				i = self:getObjectModdableTile(self.INVEN_MECHARACHNID_TAIL); if i then
					if i.moddable_tile then
						local custom = i.moddable_tile:format("tail")
						add[#add+1] = {image = base..custom..".png", display_y=mecharachnid_dy-1, auto_tall=1}
					elseif i.subtype == "steamsaw" then
						add[#add+1] = {image = base..("tail_steamsaw_front_%s.png"):format(weapontiers[i.material_level or 1]), display_y=mecharachnid_dy-1, display_h=2}
					else
						add[#add+1] = {image = base..("tail_steamgun_front_%s.png"):format(weapontiers[i.material_level or 1]), display_y=mecharachnid_dy-1, display_h=2}
					end
				end
			end

			if is_piloted then
				add[#add+1] = {image=is_piloted.image}
				for _, mo in ipairs(is_piloted.add_mos or {}) do
					add[#add+1] = table.clone(mo, true)
				end
			end

			add[#add+1] = {image=base..("base%d_%02d.png"):format(self.chassis_base_id, self.chassis_tile_id), display_y=mecharachnid_dy-1, display_h=2}
			if not self:attr("disarmed") then
				i = self:getObjectModdableTile(self.INVEN_MAINHAND); if i then
					if i.moddable_tile then
						local custom = i.moddable_tile:format("right")
						add[#add+1] = {image = base..custom..".png", auto_tall=1}
					else
						add[#add+1] = {image = base..("right_steamgun_front_%s.png"):format(weapontiers[i.material_level or 1])}
					end
				end
				i = self:getObjectModdableTile(self.INVEN_OFFHAND); if i then
					if i.moddable_tile then
						local custom = i.moddable_tile:format("left")
						add[#add+1] = {image = base..custom..".png", auto_tall=1}
					else
						add[#add+1] = {image = base..("left_steamgun_front_%s.png"):format(weapontiers[i.material_level or 1])}
					end
				end
			end

			if self.x and game.level then game.level.map:updateMap(self.x, self.y) end
		end,

		unused_stats = 0,
		unused_talents = 0,
		unused_generics = 0,
		unused_talents_types = 0,

		no_points_on_levelup = function(self)
			self.unused_stats = self.unused_stats + 2
		end,

		keep_inven_on_death = true,
--		no_auto_resists = true,
		open_door = true,
		stun_immune = 0.5,
		blind_immune = 0.5,
		disease_immune = 1,
		poison_immune = 1,
		cut_immune = 1,
		fear_immune = 1,
		see_invisible = 30,
		can_change_level = true,
	}

	return g
end

newTalent{
	name = "Mecharachnid",
	type = {"steamtech/mecharachnid", 1},
	require = steamreq_high1,
	no_unlearn_last = true,
	points = 5,
	steam = 40,
	cooldown = 15,
	cant_steal = true,
	mecharachnid_offsets = {
		dwarf_female 	= 66,
		dwarf_male 	= 66,
		elf_female 	= 54,
		elf_male 	= 54,
		ghoul 		= 64,
		glass_golem 	= 44,
		halfling_female = 66,
		halfling_male 	= 66,
		human_female 	= 54,
		human_male 	= 54,
		ogre_female 	= 44,
		ogre_male 	= 44,
		orc_female 	= 64,
		orc_male 	= 64,
		runic_gole 	= 66,
		skeleton 	= 54,
		whitehoof 	= 44,
		yeek 		= 66,
		yeti 		= 64,
	},
	on_levelup_close = function(self, t)
		t.update_mecharachnid(self, t)
	end,
	on_unlearn = function(self, t)  -- This should almost never happen as the talent can't be unlearned
		if self:getTalentLevelRaw(t) == 0 and self.tinker_mecharachnid then
			if game.party:hasMember(self) and game.party:hasMember(self.tinker_mecharachnid) then game.party:removeMember(self.tinker_mecharachnid) end
			self.tinker_mecharachnid:disappear()
			self.tinker_mecharachnid = nil
		end
	end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, state)
		local mecha = self.tinker_mecharachnid
		if not mecha or mecha.dead or not mecha.x then return end
		if (mecha.ai_target and mecha.ai_target.actor) then return end
		if not src:isClassName("mod.class.Actor") then return end
		mecha:setTarget(src)
	end,
	invoke_mecharachnid = function(self, t)
		self.tinker_mecharachnid = game.zone:finishEntity(game.level, "actor", makeMecharachnid(self))
		if game.party:hasMember(self) then
			game.party:addMember(self.tinker_mecharachnid, {
				control="full", type="mecharachnid", title=_t"mecharachnid", important=true,
				orders = {target=true, leash=true, anchor=true, talents=true, behavior=true, rename=function(self, name) return ("%s (servant of %s)"):tformat(name, self.summoner and self.summoner.name or "???") end},
			})
		end
		if not self.tinker_mecharachnid then return end
		self.tinker_mecharachnid.faction = self.faction
		self.tinker_mecharachnid.name = ("mecharachnid (servant of %s)"):tformat(self:getName())
		self.tinker_mecharachnid.summoner = self
		self.tinker_mecharachnid.summoner_gain_exp = true

		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to invoke!")
			return
		end
		game.zone:addEntity(game.level, self.tinker_mecharachnid, "actor", x, y)
	end,
	update_mecharachnid = function(self, t)
		local mecharachnid = self.tinker_mecharachnid
		if not mecharachnid or (mecharachnid and mecharachnid.dead) then return end  -- Don't update if the pet is dead just in case something weird happens
		
		mecharachnid.ai_tactic.never_move_escape = 1
		mecharachnid.ai_talents = mecharachnid.ai_talents or {}
		mecharachnid.ai_talents.T_ATTACK = mecharachnid.ai_talents.T_ATTACK or -5

		if mecharachnid.level < self.level then
			mecharachnid.max_level = self.max_level
			mecharachnid:forceLevelup(self.level)
		end

		-- avoid unequipping heavy armor
		local old_tl = mecharachnid:getTalentLevelRaw(mecharachnid.T_ARMOUR_TRAINING)
		local new_tl = self:getTalentLevelRaw(t)
		if old_tl > new_tl then
			mecharachnid:unlearnTalent(mecharachnid.T_ARMOUR_TRAINING, old_tl - new_tl, {no_unlearn=true})
		else if old_tl < new_tl then
			mecharachnid:learnTalent(mecharachnid.T_ARMOUR_TRAINING, true, new_tl - old_tl)
		end end

		mecharachnid:unlearnTalent(mecharachnid.T_WEAPON_COMBAT, mecharachnid:getTalentLevelRaw(mecharachnid.T_WEAPON_COMBAT), {no_unlearn=true})
		mecharachnid:unlearnTalent(mecharachnid.T_STEAMGUN_MASTERY, mecharachnid:getTalentLevelRaw(mecharachnid.T_STEAMGUN_MASTERY), {no_unlearn=true})

		mecharachnid:learnTalent(mecharachnid.T_WEAPON_COMBAT, true, self:getTalentLevelRaw(t))
		mecharachnid:learnTalent(mecharachnid.T_STEAMGUN_MASTERY, true, self:getTalentLevelRaw(t))

		if self:knowTalent(self.T_STORMCOIL_GENERATOR) then
			mecharachnid.stormcoil = true
		end
		if self:knowTalent(self.T_MECHARACHNID_CHASSIS) then
			self:callTalent(self.T_MECHARACHNID_CHASSIS, "setup_mecharachnid_chassis")
		end
	end,
	on_pre_use = function(self, t, silent) if self.tinker_mecharachnid and not self.tinker_mecharachnid:attr("dead") then if not silent then game.logPlayer(self, "Your mecharachnid is not dead.") end return false end return true end,
	getPower = function(self, t) return (60 + self:combatTalentSteamDamage(t, 15, 450)) / 7, 7, self:combatTalentLimit(t, 100, 27, 55) end, --Limit life gain < 100%
	action = function(self, t)
		if not self.tinker_mecharachnid then
			t.invoke_mecharachnid(self, t)
			t.update_mecharachnid(self, t)
			return true
		end

		if not game.level:hasEntity(self.tinker_mecharachnid) or self.tinker_mecharachnid.dead then
			self.tinker_mecharachnid.dead = nil
			self.tinker_mecharachnid.life = self.tinker_mecharachnid.max_life / 100 * t.getPower(self, t)

			-- Find space
			local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to invoke!")
				return
			end
			game.zone:addEntity(game.level, self.tinker_mecharachnid, "actor", x, y)
			self.tinker_mecharachnid:setTarget(nil)
			self.tinker_mecharachnid.ai_state.tactic_leash_anchor = self
			self.tinker_mecharachnid:removeAllEffects()
			self.tinker_mecharachnid.talents_cd = {}  -- Make sure defensive inscriptions can be used right away
		end
		t.update_mecharachnid(self, t)

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	-- This is an all-catch talent, and it is auto-learned on anything involving mecharachnids, so this is a good place to stick that onto
	callbackOnLevelup = function(self, t, new_level)
		local mecharachnid = getMecharachnid(self)
		if not mecharachnid then return end
		t.update_mecharachnid(self, t)
	end,
	callbackOnCombat = function(self, t, state)
		if state == false and not game.zone.wilderness then
			if self.tinker_mecharachnid and self.tinker_mecharachnid.dead and not game.level:hasEntity(self.tinker_mecharachnid) then
				self.tinker_mecharachnid.dead = nil
				self.tinker_mecharachnid.life = self.tinker_mecharachnid.max_life  -- Full life since were out of combat

				-- Find space
				local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
				if not x then
					game.logPlayer(self, "Not enough space to invoke!")
					return
				end
				game.zone:addEntity(game.level, self.tinker_mecharachnid, "actor", x, y)
				self.tinker_mecharachnid:setTarget(nil)
				self.tinker_mecharachnid.ai_state.tactic_leash_anchor = self
				self.tinker_mecharachnid:removeAllEffects()
				self.tinker_mecharachnid.talents_cd = {}  -- Make sure defensive inscriptions can be used right away
			
				t.update_mecharachnid(self, t)
			
				game:playSoundNear(self, "talents/arcane")
			end
			-- Recall pet and make sure it isn't chasing anything
			if self.tinker_mecharachnid then
				local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
				if not x then return end
				self.tinker_mecharachnid:move(x, y, true)
				self.tinker_mecharachnid:setTarget(nil)
			end
		end	
	end,
	info = function(self, t)
		return ([[You build a mighty mechanical arachnid to assist you in combat. You can equip the mecharachnid with 2 steamguns, ammunition, and armor of your choice.
If your mecharachnid is dead, this will resurrect it with %d%% of its maximum life. Your mecharachnid is automatically rebuilt at full life when combat ends.
Your mecharachnid has level %d Steamgun Mastery, Combat Accuracy and Armor Training. The mecharachnid uses Dexterity instead of Strength to equip armor.
The mecharachnid has an inbuilt teleportation device that will recall it to you when combat ends if it is not nearby.]]):
		tformat(t.getPower(self,t), self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Stormcoil Generator",
	type = {"steamtech/mecharachnid", 2},
	require = steamreq_high2,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self:callTalent(self.T_MECHARACHNID, "update_mecharachnid")
	end,
	on_unlearn = function(self, t)
		self:callTalent(self.T_MECHARACHNID, "update_mecharachnid")
	end,	
	getDamageReduction = function(self, t) return self:combatTalentLimit(t, 90, 15, 65)/100 end,
	getSpeed = function(self, t) return self:combatTalentLimit(t, 50, 10, 30)/100 end,
	info = function(self, t)
		return ([[You equip your mecharachnid with a stormcoil generator, a mechanical device that projects a powerful electrical field. On taking a hit greater than 15%% of its maximum life, the excess damage will be reduced by %d%% and converted into energy, giving your mecharachnid %d%% increased global speed for 2 turns.]])
		:tformat(t.getDamageReduction(self,t)*100, t.getSpeed(self,t)*100)
	end,
}

newTalent{
	name = "Mecharachnid Chassis",
	type = {"steamtech/mecharachnid", 3},
	require = steamreq_high3,
	points = 5,
	cooldown = 60,
	no_npc_use = true,
	no_unlearn_last = true,
	on_levelup_close = function(self, t)
		t.setup_mecharachnid_chassis(self,t)
	end,
	setup_mecharachnid_chassis = function(self, t)
		local mecharachnid = self.tinker_mecharachnid
		if not mecharachnid or (mecharachnid and mecharachnid.dead) then return end  -- Don't update if the pet is dead just in case something weird happens

		if not mecharachnid.upgraded_chassis then	
			mecharachnid.body = {MECHARACHNID_TAIL = 1}
			mecharachnid:initBody()
	
			mecharachnid:learnTalentType("steamtech/assault", true)
		
			mecharachnid:learnTalent(mecharachnid.T_TAIL_ATTACHMENT, true, 1)

			mecharachnid.upgraded_chassis = "assault"
			t.change_mecharachnid_chassis(self, t, "assault", true)			
		else
			t.update_mecharachnid_chassis(self, t)
		end
	end,
	chassis_defs = {
		assault = {
			name = _t"Assault",
			talents = {"T_OVERRUN", "T_DEFENSIVE_PROTOCOL", "T_PINCER_STRIKE", "T_AUTOMATED_REPAIR_SYSTEM"},
			talent_type = "steamtech/assault",
			weapon_subtype = "steamsaw",
			chassis_tile_id = 5,
			chassis_base_id = 2,
		},
		armament = {
			name = _t"Armament",
			talent_type = "steamtech/armament",
			talents = {"T_GAUSS_CANNON", "T_MAGNETIC_ACCELERATOR", "T_HAYWIRE_MISSILES", "T_ADVANCED_TARGETING_SYSTEM"},
			weapon_subtype = "steamgun",
			chassis_tile_id = 3,
			chassis_base_id = 1,
		},
	},
	update_mecharachnid_chassis = function(self, t)
		local mecharachnid = self.tinker_mecharachnid
		if not mecharachnid then return end
		local def = t.chassis_defs[mecharachnid.upgraded_chassis]
		mecharachnid.unused_talents = t.getNb(self, t)
		for tid, lvl in pairs(mecharachnid.talents) do if lvl > 0 then
			local tt = self:getTalentFromId(tid)
			if not tt.generic and tt.type[1] == def.talent_type then
				mecharachnid.unused_talents = mecharachnid.unused_talents - lvl
			end
		end end
	end,
	change_mecharachnid_chassis = function(self, t, new_chassis, birth)
		local mecharachnid = self.tinker_mecharachnid
		if not mecharachnid or (mecharachnid and mecharachnid.dead) then return end  -- Don't update if the pet is dead just in case something weird happens
		if self.in_combat then game.logPlayer(self, "#LIGHT_RED#You must not be in combat to change the chassis.") return end
		if mecharachnid.in_combat then game.logPlayer(self, "#LIGHT_RED#Your mecharachnid must not be in combat to change its chassis.") return end
		if mecharachnid.upgraded_chassis == new_chassis and not birth then game.logPlayer(self, "#LIGHT_RED#Your mecharachnid is already in chassis %s.", new_chassis) return end
		mecharachnid.chassis_talents = mecharachnid.chassis_talents or {}
		mecharachnid.chassis_tail_items = mecharachnid.chassis_tail_items or {}

		local old_def = t.chassis_defs[mecharachnid.upgraded_chassis]
		local new_def = t.chassis_defs[new_chassis]

		-- Unlearn the old chassis
		if not birth then
			mecharachnid:unlearnTalentType(old_def.talent_type)
			mecharachnid.talents_types[old_def.talent_type] = nil -- To disappear totally
			mecharachnid.chassis_talents[mecharachnid.upgraded_chassis] = {}
			for _, tid in pairs(old_def.talents) do
				local lvl = mecharachnid:getTalentLevelRaw(tid)
				mecharachnid.chassis_talents[mecharachnid.upgraded_chassis][tid] = lvl
				mecharachnid:unlearnTalent(tid, lvl)
			end
		end

		-- Learn the new one
		mecharachnid.unused_talents = t.getNb(self, t)
		mecharachnid:learnTalentType(new_def.talent_type, true)
		for tid, lvl in pairs(mecharachnid.chassis_talents[new_chassis] or {}) do if lvl > 0 then
			mecharachnid:learnTalent(tid, true, lvl)
			mecharachnid.unused_talents = mecharachnid.unused_talents - lvl
		end end

		-- Look for the previous tail weapon to use
		local o_tail, item_tail = nil, nil
		local inven = mecharachnid:getInven("INVEN")
		if mecharachnid.chassis_tail_items[new_chassis] then
			local o, item = mecharachnid:findInInventory(inven, mecharachnid.chassis_tail_items[new_chassis], {no_add_name=true, force_id=true, no_count=true})
			if o and item then o_tail, item_tail = o, item end
		end
		-- Look for a good weapon to use instead
		if not o_tail then
			local candidates = {}
			for item, o in ipairs(inven) do
				if o.type == "weapon" and o.subtype == new_def.weapon_subtype then candidates[#candidates+1] = {o=o, item=item} end
			end
			table.sort(candidates, function(a, b)
				if (a.o.material_level or 1) == (b.o.material_level or 1) then
					return a.o:getPowerRank() > b.o:getPowerRank()
				else
					return (a.o.material_level or 1) > (b.o.material_level or 1)
				end
			end)
			if #candidates >= 1 then
				o_tail, item_tail = candidates[1].o, candidates[1].item
			end
		end
		if o_tail and item_tail then
			local old_tail_weapon = mecharachnid:callTalent(mecharachnid.T_TAIL_ATTACHMENT, "wearOnTail", o_tail, item_tail)
			if old_tail_weapon and old_tail_weapon.subtype == old_def.weapon_subtype then
				mecharachnid.chassis_tail_items[mecharachnid.upgraded_chassis] = old_tail_weapon:getName{no_add_name=true, force_id=true, no_count=true}
			end
		else 
			local old_tail_weapon = mecharachnid:callTalent(mecharachnid.T_TAIL_ATTACHMENT, "unwearOnTail")
			if old_tail_weapon and old_tail_weapon.subtype == old_def.weapon_subtype then
				mecharachnid.chassis_tail_items[mecharachnid.upgraded_chassis] = old_tail_weapon:getName{no_add_name=true, force_id=true, no_count=true}
			end
		end

		mecharachnid.chassis_tile_id = new_def.chassis_tile_id
		mecharachnid.chassis_base_id = new_def.chassis_base_id
		mecharachnid.chassis_weapon_subtype = new_def.weapon_subtype
		mecharachnid:updateModdableTile()
		mecharachnid.upgraded_chassis = new_chassis
		game.logPlayer(self, "Mecharachnid chassis changed to: #GOLD#%s", new_def.name)
	end,	
	no_npc_use = true,
	requires_target = true,
	on_pre_use = function(self, t, silent) 
		local mecharachnid = getMecharachnid(self) 
		if self.in_combat or not mecharachnid or not mecharachnid.x or mecharachnid.in_combat or not game.level or core.fov.distance(self.x, self.y, mecharachnid.x, mecharachnid.y) > 1 then 
			if not silent then 
				game.logPlayer(self, "You require your mecharachnid to be adjacent, and must be out of combat.") 
			end 
			return false 
		end 
		return true 
	end,
	getNb = function(self, t) return self:getTalentLevelRaw(t)*3 end,	
	action = function(self, t)
		local mecharachnid = getMecharachnid(self)
		t.change_mecharachnid_chassis(self, t, mecharachnid.upgraded_chassis == "assault" and "armament" or "assault")
		return true
	end,
	info = function(self, t)
		return ([[You craft a new chassis for your mecharachnid, allowing you to tailor it to different situations. Each chassis grants the mecharachnid a new talent category, the ability to attach a weapon to their tail, as well as granting them %d class talent points to spend in a new category based off their chassis.

		You can choose from the 2 chassis below by activating this talent outside of combat (default chassis: Assault)
		- Assault: An armored chassis focused on close combat and defenses, specialising in wielding a steamsaw.
		- Armament: A heavily armed chassis focused on ranged combat, specialising in wielding an additional steamgun.

		Tail weapons do not attack by default, and are instead used for special talents.]]):
		tformat(t.getNb(self,t))
	end,
}

newTalent{
	name = "Mecharachnid Piloting",
	type = {"steamtech/mecharachnid", 4},
	require = steamreq_high4,
	points = 5,
	steam = 40,
	cooldown = 30,
	no_npc_use = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	getDamage = function(self, t) return self:combatTalentLimit(t, 100, 10, 50) end,	
	getResist = function(self, t) return self:combatTalentLimit(t, 70, 10, 40) end,		
	on_pre_use = function(self, t, silent) local mecharachnid = getMecharachnid(self) if not mecharachnid or not mecharachnid.x or not game.level or core.fov.distance(self.x, self.y, mecharachnid.x, mecharachnid.y) > 1 then if not silent then game.logPlayer(self, "You require your mecharachnid to be adjacent.") end return false end return true end,
	action = function(self, t)
		local mecharachnid = self.tinker_mecharachnid	
		mecharachnid:setEffect(mecharachnid.EFF_MECHARACHNID_PILOTING, t.getDuration(self, t), {src=self})
		mecharachnid:setEffect(mecharachnid.EFF_MECHARACHNID_PILOTING_BUFF, 1, {src=self, damage=t.getDamage(self,t), resist=t.getResist(self,t)})		
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local dam = t.getDamage(self,t)
		local resist = t.getResist(self,t)
		return ([[Leap into your mecharachnid, assuming direct control of it for %d turns. While piloting it, all damage dealt is increased by %d%%, resistances are increased by %d%%, and all of its talents cooldown twice as fast.]]):
		tformat(duration, dam, resist)
	end,
}


newTalentType{ allow_random=true, is_steam=true, speed="archery", type="steamtech/armament", name = _t("armament", "talent type"), description = _t"Ranged combat mecharachnid abilities." }
newTalentType{ allow_random=true, is_steam=true, speed="weapon", type="steamtech/assault", name = _t("assault", "talent type"), description = _t"Close combat mecharachnid abilities." }

newTalent{
	name = "Overrun",
	type = {"steamtech/assault", 1},
	require = dex_steamreq1,
	points = 5,
	getDamage = function(self, t) return 30 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 1.5 end,
	cooldown = 4,
	steam = 15,
	range = function(self, t) return self:combatTalentScale(t, 5, 9) end,
	radius = function(self, t) return self:combatTalentScale(t, 1, 3) end,	
	tactical = { ATTACK = { weapon = 2 }, CLOSEIN = 3, PROTECT = 3 },
	requires_target = true,
	is_melee = true,
	getSawDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.4, 2.9) end,	
	on_pre_use = function(self, t, silent) if not hasTailWeapon(self,"steamsaw") then if not silent then game.logPlayer(self, "You require a tail-mounted steamsaw for this talent.") end return false end return true end,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t)}
	end,
	action = function(self, t)
		if self:attr("never_move") then game.logPlayer(self, "Your mecharachnid cannot do that currently.") return end
		local tail = hasTailWeapon(self, "steamsaw")
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		if core.fov.distance(self.x, self.y, x, y) > 1 then
			local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
			local l = self:lineFOV(x, y, block_actor)
			local lx, ly, is_corner_blocked = l:step()
			if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then
				return
			end
			local tx, ty = lx, ly
			lx, ly, is_corner_blocked = l:step()
			while lx and ly do
				if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then break end
				tx, ty = lx, ly
				lx, ly, is_corner_blocked = l:step()
			end

			local ox, oy = self.x, self.y
			self:move(tx, ty, true)
			if config.settings.tome.smooth_move > 0 then
				self:resetMoveAnim()
				self:setMoveAnim(ox, oy, 8, 5)
			end
		end

		-- Attack ?
		if core.fov.distance(self.x, self.y, x, y) > 1 then return true end
		local hit = self:attackTargetWith(target, tail.combat, nil, t.getSawDamage(self, t))
		local tg2 = {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), friendlyfire=false}
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end

			if self:reactionToward(target) < 0 then
				if self.ai_target then self.ai_target.target = target end
				target:setTarget(self)
				self:logCombat(target, "#Source# provokes #Target# to attack it.")
			end
		end)

		return true
	end,
	info = function(self, t)
		return ([[You rush to the target and strike with your tailsaw, dealing %d%% damage and taunting enemies within radius %d.
		You now also use your Dexterity in place of Strength when equipping Steamsaws as well as when calculating weapon damage, and have your Steamsaw damage increased by %d%% and Physical Power by %d.]]):
		tformat(t.getSawDamage(self,t)*100, self:getTalentRadius(t), t.getPercentInc(self,t)*100, t.getDamage(self, t))
	end,
}

newTalent{
	name = "Defensive Protocol",
	type = {"steamtech/assault", 2},
	require = dex_steamreq2,
	points = 5,
	mode = "passive",
	getEvasion = function(self, t) return self:combatTalentLimit(t, 50, 12, 30), 1 end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.5, 1.5) end,	
	target = function(self, t) return {type="ball", range=0, selffire=false, radius=1} end,	
	callbackOnActBase = function(self, t)
		local tail = hasTailWeapon(self, "steamsaw")
		if not tail then return end
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and self:reactionToward(target) < 0 then
				self:attackTargetWith(target, tail.combat, nil, t.getDamage(self, t))
			end
		end)
	end,
	callbackOnHit = function(self, t, val, src, death_note)
		if src and src.x and src.y and self.x and self.y and core.fov.distance(self.x, self.y, src.x, src.y) > 1 then return end
		local ev, spread = t.getEvasion(self, t)
		val.value = val.value * (100 - ev) / 100
		return true
	end,
	passives = function(self, t, p)
		local ev, spread = t.getEvasion(self, t)	
		self:talentTemporaryValue(p, "projectile_evasion", ev)
		self:talentTemporaryValue(p, "evasion", ev)		
		self:talentTemporaryValue(p, "projectile_evasion_spread", spread)		
	end,	
	info = function(self, t)
		local ev, spread = t.getEvasion(self, t)
		local dam = t.getDamage(self,t)*100
		return ([[Enhancements to your mecharachnid combat skill increases your melee and ranged evasion by %d%%, and causes you to automatically strike adjacent enemies with your tailsaw for %d%% damage each turn.]])
		:tformat(ev, dam)
	end,
}

newTalent{
	name = "Pincer Strike",
	type = {"steamtech/assault", 3},
	require = dex_steamreq3,
	points = 5,
	cooldown = 8,
	steam = 25,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = {PIN = 3} },
	requires_target = true,
	is_melee = true,
	range = 1,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.4, 1.0) end,
	getDuration = function(self, t) return self:combatTalentScale(t, 3, 7) end,
	getSlow = function(self, t) return self:combatTalentLimit(t, 50, 10, 35) end,		
	on_pre_use = function(self, t, silent) if not hasTailWeapon(self,"steamsaw") then if not silent then game.logPlayer(self, "You require a tail-mounted steamsaw for this talent.") end return false end return true end,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t)}
	end,
	action = function(self, t)
		local tail = hasTailWeapon(self, "steamsaw")
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local hit = self:attackTargetWith(target, tail.combat, nil, t.getDamage(self, t)*2)

		if hit and target:canBe("pin") then
			target:setEffect(target.EFF_PINCER_STRIKE, t.getDuration(self, t), {src=self, power=t.getSlow(self,t)/100, dam=t.getDamage(self,t)})

		else 
			self:logCombat(target, "#Target# resists the pincer strike from #Source#!")
		end


		return true
	end,

	info = function(self, t)
		local dam = t.getDamage(self,t)*100
		local dur = t.getDuration(self,t)
		local slow = t.getSlow(self,t)
		return ([[You strike the target with your tailsaw for %d%% damage. If this hits, you attempt to clamp them with your pincers for %d turns. This pins, reduces their attack, spell and mind speed by %d%%, and lets you make a free, unavoidable strike with your tailsaw against them each turn for %d%% damage. This ends if you move more than 1 tile from the target.]])
		:tformat(dam*2, dur, slow, dam)
	end,
}

newTalent{
	name = "Automated Repair System",
	type = {"steamtech/assault", 4},
	require = dex_steamreq4,
	points = 5,
	mode = "passive",
	cooldown = 40,
	getLife = function(self, t) return math.floor(self:combatTalentScale(t, 50, 650)) end,
	getHeal = function(self, t) return math.floor(self:combatTalentScale(t, 10, 110)) end,
	getResist = function(self, t) return self:combatTalentLimit(t, 70, 10, 40) end,			
	callbackOnHit = function(self, t, cb, src)
		if cb.value >= (self.life - self.die_at) and not self:isTalentCoolingDown(t) then
			self:startTalentCooldown(t)
			self:setEffect(self.EFF_AUTOMATED_REPAIR_SYSTEM, 1, {src=self, life=t.getLife(self,t), heal=t.getHeal(self,t), resist=t.getResist(self,t)})
		end
		return cb.value
	end,
	info = function(self, t)
		local life = t.getLife(self,t)
		local heal = t.getHeal(self,t)
		local resist = t.getResist(self,t)
		return ([[On falling below 0 life, you engage an automated repair mode. While in this mode you cannot act, but can survive below -%d life, heal for %0.1f life each turn and have all resistances increased by %d%%. This will last until you are destroyed or until you are fully healed.
		This effect has a cooldown.]])
		:tformat(life, heal, resist)
	end,
}

newTalent{
	name = "Gauss Cannon",
	type = {"steamtech/armament", 1},
	require = dex_steamreq1,
	no_energy = true,
	points = 5,
	cooldown = function(self, t) return self:combatTalentLimit(t, 2, 10, 4) end,
	steam = 15,
	range = tailgun_range,
	tactical = { ATTACK = { weapon = 2 } },
	onAIGetTarget = function(self, t)
		-- Pick the farthest target to avoid wasting the AoE
		local tgts = {}
		self:project({type="ball", radius=self:getTalentRange(t), friendlyfire=false, talent=t}, self.x, self.y, function(px, py)
			local tgt = game.level.map(px, py, Map.ACTOR)
			if tgt and (not tgt.src or self:reactionToward(tgt.src) < 0) then tgts[#tgts+1] = {x=px, y=py, tgt=tgt, dist=core.fov.distance(self.x, self.y, px, py)} end
		end)
		table.sort(tgts, function(a, b) return a.dist > b.dist end)

		if #tgts > 0 then
			return tgts[1].x, tgts[1].y, tgts[1].tgt 
		end
	end,
	on_pre_use_ai = function(self, t, silent) return t.onAIGetTarget(self, t) and true or false end,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), friendlyfire=false, talent=t, speed=200}
	end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.2, 2.5) end,	
	on_pre_use = function(self, t, silent) if not hasTailWeapon(self,"steamgun") then if not silent then game.logPlayer(self, "You require a tail-mounted steamgun for this talent.") end return false end return true end,
	action = util.finalize(function(myenv, self, t) myenv.archery_weapon_override = self.archery_weapon_override end, function(myenv, self, t) self.archery_weapon_override = myenv.archery_weapon_override end, function(myenv, self, t)
		self.archery_weapon_override = {hasTailWeapon(self)}
		local tg = self:getTalentTarget(t)
		local targets = self:archeryAcquireTargets(tg, {no_energy=true, one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, {type="beam", speed=200}, {mult=t.getDamage(self,t), damtype=DamageType.LIGHTNING, apr=1000})	
		return true
	end),
	info = function(self, t)
		return ([[Fire a charged shot at the farthest target with your tail-mounted steamgun that pierces through your enemies, ignoring armor and dealing %d%% weapon damage as lightning.
		This takes no time to use.]]):
		tformat(t.getDamage(self,t)*100)
	end,
}

newTalent{
	name = "Magnetic Accelerator",
	type = {"steamtech/armament", 2},
	require = dex_steamreq2,	
	points = 5,
	cooldown = 8,
	no_energy = true,
	no_break_stealth = true,
	getSpeed = function(self, t) return math.floor(self:combatTalentLimit(t, 150, 50, 100)) end,
	getCritPower = function(self, t) return self:combatTalentScale(t, 10, 35) end,	
	tactical = { ESCAPE = 3 },
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "slow_projectiles_outgoing", -t.getSpeed(self, t))
		self:talentTemporaryValue(p, "combat_critical_power", t.getCritPower(self, t))		
	end,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7, "log")) end,
    target = function(self, t)
        return {type="hit", range=self:getTalentRange(t), talent=t,
                grid_params = {want_range = self:getTalentRange(t)}
        }
    end,
	callbackOnActBase = function(self, t)
		local weapon, ammo, offweapon = self:hasArcheryWeapon()	
		if weapon and ammo and not ammo.infinite then self:reload() end
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return end
		if self.x == x and self.y == y then return end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) or not self:hasLOS(x, y) then return end

		if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move", self) then
			game.logPlayer(self, "You must have an empty space to leap to.")
			return false
		end

		self:move(x, y, true)
				
		return true
	end,

	info = function(self, t)
		local speed = t.getSpeed(self,t)
		local crit = t.getCritPower(self,t)
		local range = self:getTalentRange(t)
		return ([[Improved power output increases the speed of your projectiles by %d%%, critical damage by %d%%, and allows you to automatically reload each turn.
		In addition, you can instantly activate this talent to gain a sudden burst of speed, moving to a tile in range %d.]]):
		tformat(speed, crit, range)
	end,
}

newTalent{
	name = "Haywire Missiles",
	type = {"steamtech/armament", 3},
	require = dex_steamreq3,	
	no_energy = "fake",
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	steam = 25,
	range = tailgun_range,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4)) end,
	tactical = { ATTACKAREA = { weapon = 2 }, DISABLE = {STUN = 2} },
	requires_target = true,
	target = function(self, t)
		local weapon, ammo = hasTailWeapon(self)
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), friendlyfire=false, display=self:archeryDefaultProjectileVisual(weapon, ammo)}
	end,
	on_pre_use = function(self, t, silent) if not hasTailWeapon(self,"steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	getDamage = function(self, t)
		return self:combatTalentWeaponDamage(t, 1.0, 2.1)
	end,
	archery_onhit = function(self, t, target, x, y, tg)
		if target:canBe("stun") then
			target:setEffect(target.EFF_DAZED, 2, {apply_power=self:combatAttack()})
		end
	end,
	action = util.finalize(function(myenv, self, t) myenv.archery_weapon_override = self.archery_weapon_override end, function(myenv, self, t) self.archery_weapon_override = myenv.archery_weapon_override end, function(myenv, self, t)
		self.archery_weapon_override = {hasTailWeapon(self)}	
		local tg = self:getTalentTarget(t)
		local targets = self:archeryAcquireTargets(tg)
		if not targets then return end
		local mult = t.getDamage(self,t)
		self:archeryShoot(targets, t, {type="hit", selffire=false}, {damtype=DamageType.LIGHTNING, mult=dam})
		
		return true
	end),
	info = function(self, t)
		local rad = self:getTalentRadius(t)
		local dam = t.getDamage(self,t)*100
		return ([[Fires a barrage of charged missiles from your tail-mounted steamgun at a radius %d area, dealing %d%% steamgun damage as lightning as well as dazing those within for 2 turns.
		The daze chance increases with your Accuracy.]])
		:tformat(rad, dam)
	end,
}

newTalent{
	name = "Advanced Targeting System",
	type = {"steamtech/armament", 4},
	require = dex_steamreq4,	
	points = 5,
	mode = "passive",
	getChance = function(self, t) return math.floor(self:combatTalentLimit(t, 100, 15, 40)) end,
	getResistPen = function(self, t) return self:combatTalentLimit(t, 100, 17, 50) end, -- Limit < 100%
	passives = function(self, t, p)
		local resists_pen = t.getResistPen(self, t)
		self:talentTemporaryValue(p, "resists_pen", {[DamageType.PHYSICAL]=resists_pen,
			[DamageType.LIGHTNING]=resists_pen,
			})
	end,
	callbackOnArcheryAttack = function(self, t, target, hitted)
		if self.turn_procs.advanced_targeting_system or not target or not rng.percent(t.getChance(self, t)) then
			return
		else
			self.turn_procs.advanced_targeting_system = true
		end
		local archery_weapon_override = self.archery_weapon_override
		self.archery_weapon_override = {hasTailWeapon(self)}	
		
		local targets = self:archeryAcquireTargets({type="bolt", friendlyfire=false, friendlyblock=false}, {one_shot=true, x=target.x, y=target.y, infinite=true, no_energy = true})
		if targets then self:archeryShoot(targets, t, nil, {damtype=DamageType.LIGHTNING, mult=1}) end
		self.archery_weapon_override = archery_weapon_override						
	end,
	info = function(self, t)
		local chance = t.getChance(self,t)
		local pen = t.getResistPen(self,t)
		return ([[Enhancements to your targeting systems give all ranged attacks a %d%% chance to trigger an immediate shot from your tail-mounted steamgun for 100%% damage as lightning.
		In addition, your physical and lightning resistance penetration is increased by %d%%.]]):
		tformat(chance, pen)
	end,
}

newTalent{
	name = "Tail Attachment",
	type = {"steamtech/other", 1},
	points = 1,
	cooldown = 0,
	steam = 0,
	type_no_req = true,
	no_unlearn_last = true,
	no_npc_use = true,
	unwearOnTail = function(self, t)
		local pf = self:getInven("MECHARACHNID_TAIL")
		local inven = self:getInven("INVEN")
		if not pf then return end
		local old = self:removeObject(pf, 1, true)
		if old then
			self:addObject(inven, old)
		end
		return old
	end,
	wearOnTail = function(self, t, o, item)
		local pf = self:getInven("MECHARACHNID_TAIL")
		local inven = self:getInven("INVEN")
		if not pf then return end

		-- Put back the old one in inventory
		local old = self:removeObject(pf, 1, true)
		if old then
			self:addObject(inven, old)
		end
--Note: error with set items -- set_list, on_set_broken, on_set_complete
		-- Fix the slot_forbid bug
		if o.slot_forbid then
			-- Store any original on_takeoff function
			if o.on_takeoff then
				o._old_on_takeoff = o.on_takeoff
			end
			-- Save the original slot_forbid
			o._slot_forbid = o.slot_forbid
			o.slot_forbid = nil
			-- And prepare the resoration of everything
			o.on_takeoff = function(self)
				-- Remove the slot forbid fix
				self.slot_forbid = self._slot_forbid
				self._slot_forbid = nil
				-- Run the original on_takeoff
				if self._old_on_takeoff then
					self.on_takeoff = self._old_on_takeoff
					self._old_on_takeoff = nil
					self:on_takeoff()
				-- Or remove on_takeoff entirely
				else
					self.on_takeoff = nil
				end
			end
		end

		o = self:removeObject(inven, item)
		-- Force "wield"
		self:addObject(pf, o)
		self:sortInven()
		game.logSeen(self, "%s mounts %s to its tail.", self:getName():capitalize(), o:getName{do_color=true})

		self:unlearnTalent(self.T_BLOCK, 10000) -- Unlearn block, because we can't block with tail-worn steamsaws

		return old
	end,
	action = function(self, t)
		local inven = self:getInven("INVEN")
		local ret = self:talentDialog(self:showInventory(_t"Attach which item?", inven, function(o) return o.type == "weapon" and o.subtype == self.chassis_weapon_subtype and not o.twohanded end, function(o, item)
			self:callTalent(t.id, "wearOnTail", o, item)
			self:talentDialogReturn(true)
		end))
		if not ret then return nil end
		return true
	end,
	info = function(self, t)
		return (_t[[Attach the chosen weapon to your tail.]])
	end,
}