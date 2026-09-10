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

-- Add popup when talent points are unspent so people notice

function getWtWBuddy(self)
	if self.demented_wtw and game.level and game.level:hasEntity(self.demented_wtw) then
		return self.demented_wtw
	end
end


newTalent{
	name = "Worm that Walks Link",
	type = {"corruption/other", 1},
	points = 1,
	mode = "sustained",
	requires_target = true,
	range = 10,
	tactical = { BUFF=100 },
	activate = function(self, t) return {} end,
	deactivate = function(self, t, p) return true end,
	info = function(self, t) return (_t[[Link to the summoner.]]) end,
}

local function learnWTWTalents(self)
	if not self.demented_wtw or not self.player then return end
	-- Do stuff for NPC talents here
end


local function makeWtW(self)
	self:attr("summoned_times", 11)
	local g = require("mod.class.NPC").new{
		type = "horror", subtype = "eldritch",
		name = "worm that walks", color=colors.SANDY_BROWN,
		desc = _t[[A bulging rotten robe seems to tear at the seams, with masses of bloated worms spilling out all around the moving form.  Two arm-like appendages, each made up of overlapping mucus-drenched maggots, grasp tightly around the handles of bile-coated waraxes.
Each swing drips pustulant fluid before it, and each droplet writhes and wriggles in the air before splashing against the ground.]],
		display = 'h', color=colors.SANDY_BROWN, image = "npc/horror_eldritch_worm_that_walks.png",
		level_range = {1, self.max_level}, exp_worth=0,
		life_rating = 10,
		life_regen = 1,
		never_anger = true,
		difficulty_boosted = 1,  -- Avoid difficulty boosting, adding to party probably also works but I'm positive this always does

		save_hotkeys = true,

		moddable_tile = "orc_male",
		moddable_tile_nude = 1,
		moddable_tile_base = "worm_that_walks_base.png",

		combat = { dam=10, atk=10, apr=0, dammod={str=0.5, mag=0.5} },
		combat_atk = resolvers.levelup(1, 1, 2),
		combat_spellpower = resolvers.levelup(1, 1, 2),

		body = { INVEN = 1000, QS_MAINHAND = 1, QS_OFFHAND = 1, MAINHAND = 1, OFFHAND = 1, BODY=1, },
		equipdoll = "wtw_buddy",
		is_wtw_buddy = 1,
		infravision = 10,
		rank = 3,
		size_category = 3,

		resists = { [DamageType.ACID] = 100, [DamageType.BLIGHT] = 100, [DamageType.FIRE] = -50},
		inc_damage = { all = -60, },
		healing_factor = 0.5,
		combat_spellspeed = 0.8,
		combat_physspeed = 0.8,
		damage_affinity = { [DamageType.BLIGHT] = 10 },

		resolvers.talents{
			[Talents.T_ARMOUR_TRAINING]=1,
			[Talents.T_WEAPON_COMBAT]=1,
			[Talents.T_CORRUPTED_STRENGTH]=1,
			[Talents.T_BLINDSIDE]=1,
			[Talents.T_WORM_THAT_WALKS_LINK]=1,
			[Talents.T_WTW_DESTRUCT]=1,

		},

		resolvers.equip{ id=true,
			{type="weapon", subtype="waraxe", ego_chance = -1000, id=true, forbid_power_source={antimagic=true}, autoreq=true, not_properties = {"unique"}},
			{type="weapon", subtype="waraxe", ego_chance = -1000, id=true, forbid_power_source={antimagic=true}, autoreq=true, not_properties = {"unique"}},
			{type="armor", subtype="cloth", name="Robe of the Worm", base_list="mod.class.Object:/data-cults/general/objects/special-misc.lua", ego_chance = -1000, id=true, autoreq=true}
		},

		talents_types = {
			["corruption/reaving-combat"] = true,
			["corruption/rot"] = true,
			["corruption/plague"] = true,
			["corruption/scourge"] = true,
			["technique/combat-training"] = true,
		},

		-- Spamming Infestation worms is one of the most powerful things the WTW does, lets not make them too strong
		talents_types_mastery = {
			["corruption/rot"] = -0.2,
		},

		power_source = {arcane = true},
		resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=60}),

		max_inscriptions = 1,

		hotkey = {},
		hotkey_page = 1,
		move_others = true,

		ai = "tactical",
		-- We want a high emphasis on closing range (for Reaving Combat proc) survival via healing/defense (inscriptions) and the rest of the weighting doesn't matter much
		ai_state = { talent_in=1, ai_move="move_astar", ally_compassion=10 },
		ai_tactic = {type="wtw_pet", attack=2, buff=6, attackarea=2, disable=2, escape=0, closein=3, defend=2, heal=4, go_melee=1},
		hate_regen = 2, vim_regen = 2,
		stats = { str=15, dex=12, mag=15, con=12 },

		-- No natural exp gain
		gainExp = function() end,
		forceLevelup = function(self) if self.summoner then return mod.class.Actor.forceLevelup(self, self.summoner.level) end end,

		-- Break control when losing LOS
		on_act = function(self)
			self.movement_speed = self.summoner.movement_speed  -- Quality of life
			if not self:isTalentActive(self.T_WORM_THAT_WALKS_LINK) then self:forceUseTalent(self.T_WORM_THAT_WALKS_LINK, {ignore_cooldown=true, ignore_energy=true}) end
			if game.player ~= self then return end
			if not self.summoner.dead and not self:hasLOS(self.summoner.x, self.summoner.y) then
				if not self:hasEffect(self.EFF_WTW_OFS) then
					self:setEffect(self.EFF_WTW_OFS, 4, {})
				end
			else
				if self:hasEffect(self.EFF_WTW_OFS) then
					self:removeEffect(self.EFF_WTW_OFS)
				end
			end
		end,

		on_can_control = function(self, vocal)
			if not self:hasLOS(self.summoner.x, self.summoner.y) then
				if vocal then game.logPlayer(game.player, "Your worm that walks is out of sight; you cannot establish direct control.") end
				return false
			end
			return true
		end,

		unused_stats = 0,
		unused_talents = 0,
		unused_generics = 0,
		unused_talents_types = 0,

		no_points_on_levelup = function(self)
			self.unused_stats = self.unused_stats + 2
			if self.level >= 2 and self.level % 2 == 0 then self.unused_talents = self.unused_talents + 1 end
			if self.level >= 2 and self.level % 4 == 0 then self.unused_generics = self.unused_generics + 1 end
		end,

		keep_inven_on_death = true,
--		no_auto_resists = true,
		open_door = true,
		stun_immune = 1,
		blind_immune = 1,
		disease_immune = 1,
		see_invisible = 30,
		can_change_level = true,
	}

	return g
end

newTalent{
	name = "Worm that Walks",
	type = {"demented/friend-of-the-worm", 1},
	require = dementedreq_high1,
	points = 5,
	insanity = -40,
	cooldown = 15,
	cant_steal = true,
	no_unlearn_last = true,
	unlearn_on_clone = true,
	tactical = { BUFF = 5, ATTACK = 5 },
	on_unlearn = function(self, t)
		if self:getTalentLevelRaw(t) == 0 and self.demented_wtw then
			-- There have been multiple issues with this triggering when it wasn't really unlearned, all I know of are fixed but keep an eye out
			self.worm = nil
			if game.party:hasMember(self) and game.party:hasMember(self.demented_wtw) then game.party:removeMember(self.demented_wtw) end
			self.demented_wtw:disappear()
			self.demented_wtw = nil
			self.initialized_wtw = nil
		end
	end,
	on_levelup_close = function(self, t)
		self.worm = 1  -- Flag for healing from Infestation blight pools, we do this here instead of in passives so updateTalentTypeMastery doesn't cause issues with pet deletion
		if self.demented_wtw then 
			t.update_wtw(self, t)
			return
		end
		if self.initialized_wtw then return end  -- We can't rely on the first check because it may not happen immediately

		self.initialized_wtw = true

		if not game.level:hasEntity(self) then
			-- We aren't on the level yet so delay the spawn
			-- This should only be possible at birth.. I think.
			self.on_added_old = self.on_added
			self.on_added = function(self)
				local t = self:getTalentFromId(self.T_WORM_THAT_WALKS)
				if self.on_added_old then
					self.on_added_old(self) 
				end
				self.on_added_old = nil
				t.invoke_wtw(self, t)
				t.update_wtw(self, t)
			end
		else
			-- Create the pet immediately when the talent is learned if we already exist
			t.invoke_wtw(self, t)
			t.update_wtw(self, t)
		end
	end,
	invoke_wtw = function(self, t)
		if self.demented_wtw then return end  -- Avoid any odd bugs causing regeneration of the pet
		if game.zone.wilderness then return end

		self.demented_wtw = game.zone:finishEntity(game.level, "actor", makeWtW(self))
		if game.party:hasMember(self) then
			game.party:addMember(self.demented_wtw, {
				control="full", type="wtw", title=_t"wtw", important=true,
				orders = {target=true, leash=true, anchor=true, talents=true, behavior=true, rename=function(self, name) return ("%s (servant of %s)"):tformat(name, self.summoner and self.summoner:getName() or "???") end},
			})
		end
		if not self.demented_wtw then return end
		self.demented_wtw.faction = self.faction
		self.demented_wtw.name = ("worm that walks (servant of %s)"):tformat(self:getName())
		self.demented_wtw.summoner = self
		self.demented_wtw.summoner_gain_exp = true

		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to invoke!")
			return
		end
		game.zone:addEntity(game.level, self.demented_wtw, "actor", x, y)
	end,
	update_wtw = function(self, t)
		local wtw = self.demented_wtw
		if not wtw or wtw.dead or not wtw.x then return end  -- Don't update if the pet is dead just in case something weird happens

		if wtw.level < self.level then
			wtw.max_level = self.max_level
			wtw:forceLevelup(self.level)
		end

		if self:knowTalent(self.T_SHARED_INSANITY) then
			wtw.max_inscriptions = 1 + self:callTalent(self.T_SHARED_INSANITY, "getInscriptions")
		end

		if self:knowTalent(self.T_WORM_THAT_STABS) then
			wtw.talent_cd_reduction = {[Talents.T_BLINDSIDE] = (1 + self:callTalent(self.T_WORM_THAT_STABS, "getBlindside"))}
		end

		-- Create some starting gear so players aren't forced to start micromanaging immediately and so NPCs don't suck
		-- Charms are a bit different though so lets not give them that
		local level = self:getTalentLevelRaw(t)
		if level >= 2 then
			if not wtw.init_body then
				local no = game.zone:makeEntity(game.level, "object", {name="iron mail armour", ignore_material_restriction=true, no_tome_drops=true, ego_filter={keep_egos=true}}, nil, true)
				local o, item, inven_id = wtw:findInAllWornInventoriesBy(true, "define_as", "ROBE_OF_THE_WORM")
				if o then
					o.wtw_can_takeoff = true
					if no then
						wtw:takeoffObject(inven_id, item)
						game:addEntity(game.level, no, "object")
						no:identify(true)
						no.name = _t"Robe of the Worm (Improved)"
						no.short_name = "worm"
						no.cosmetic=true
						no.image = "object/robe_of_the_worm.png"
						no.moddable_tile = "cults/robe_of_the_worm"
						no.special = 1
						wtw:wearObject(no)
					end
				end
			end
			wtw.init_body = true
		end
		if level >= 3 then
			if not wtw.init_belt then
				wtw.body = {BELT = 1}
				wtw:initBody()
				local o = game.zone:makeEntity(game.level, "object", {name="rough leather belt", ignore_material_restriction=true, no_tome_drops=true, ego_filter={keep_egos=true}}, nil, true)
				game:addEntity(game.level, o, "object")
				o:identify(true)
				wtw:wearObject(o)
			end
			wtw.init_belt = true
		end
		if level >= 4 then
			if not wtw.init_ring1 then
				wtw.body = {FINGER = 2}
				wtw:initBody()
				for i = 1,2 do
					local o = game.zone:makeEntity(game.level, "object", {name="copper ring", ignore_material_restriction=true, no_tome_drops=true, ego_filter={keep_egos=true}}, nil, true)
					game:addEntity(game.level, o, "object")
					o:identify(true)
					wtw:wearObject(o)
				end
			end
			wtw.init_ring1 = true
		end
		if level >= 5 then
			if not wtw.init_ring2 then
				local ring1, ring2

				if wtw:getInven("FINGER")[1] then ring1 = wtw:takeoffObject(wtw:getInven("FINGER"), 1) end
				if wtw:getInven("FINGER")[1] then ring2 = wtw:takeoffObject(wtw:getInven("FINGER"), 1) end

				wtw.body = {FINGER = 4, TOOL = 1}
				wtw:initBody()

				if ring1 then wtw:wearObject(ring1) end
				if ring2 then wtw:wearObject(ring2) end

				for i = 1,2 do
					local o = game.zone:makeEntity(game.level, "object", {name="copper ring", ignore_material_restriction=true, no_tome_drops=true, ego_filter={keep_egos=true}}, nil, true)
					game:addEntity(game.level, o, "object")
					o:identify(true)
					wtw:wearObject(o)
				end
			end
			wtw.init_ring2 = true
		end
	end,
	on_pre_use = function(self, t, silent) if self.demented_wtw and not self.demented_wtw:attr("dead") then if not silent then game.logPlayer(self, "Your friendly horror is not dead.") end return false end return true end,
	getPower = function(self, t) return (60 + self:combatTalentSpellDamage(t, 15, 450)) / 7, 7, self:combatTalentLimit(t, 100, 27, 55) end, --Limit life gain < 100%
	action = function(self, t)
		-- Initialize pet if we somehow haven't, such as the case of a player learning the talent in the wilderness (on_added does not run for players)
		if not self.demented_wtw then
			t.invoke_wtw(self, t)
			t.update_wtw(self, t)
			return true
		end

		if self.demented_wtw:attr("dead") then game.level:removeEntity(self.demented_wtw, true) end

		if not game.level:hasEntity(self.demented_wtw) then
			self.demented_wtw.dead = nil
			self.demented_wtw.life = self.demented_wtw.max_life / 100 * t.getPower(self, t)

			-- Find space
			local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to invoke!")
				return
			end
			game.zone:addEntity(game.level, self.demented_wtw, "actor", x, y)
			self.demented_wtw:setTarget(nil)
			self.demented_wtw.ai_state.tactic_leash_anchor = self
			self.demented_wtw:removeAllEffects()
			self.demented_wtw.talents_cd = {}  -- Make sure defensive inscriptions can be used right away
		end
		t.update_wtw(self, t)

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	-- This is an all-catch talent, and it is auto-learned on anything involving wtws, so this is a good place to stick that onto
	callbackOnLevelup = function(self, t, new_level)
		local wtw = getWtWBuddy(self)
		if not wtw then return end
		t.update_wtw(self, t)
	end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, state)
		local wtw = self.demented_wtw
		if not wtw or wtw.dead or not wtw.x then return end
		if (wtw.ai_target and wtw.ai_target.actor) then return end
		if core.fov.distance(self.x, self.y, x, y) >= 5 then return end  -- Avoid aggroing anything distant this way since it easily leads to pet suicide
		if not src:isClassName("mod.class.Actor") then return end
		wtw:setTarget(src)
	end,
	callbackOnCombat = function(self, t, state)
		if state == false and not game.zone.wilderness then
			if self.demented_wtw and self.demented_wtw.dead and not game.level:hasEntity(self.demented_wtw) then
				self.demented_wtw.dead = nil
				self.demented_wtw.life = self.demented_wtw.max_life  -- Full life since were out of combat

				-- Find space
				local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
				if not x then
					game.logPlayer(self, "Not enough space to invoke!")
					return
				end
				game.zone:addEntity(game.level, self.demented_wtw, "actor", x, y)
				self.demented_wtw:setTarget(nil)
				self.demented_wtw.ai_state.tactic_leash_anchor = self
				self.demented_wtw:removeAllEffects()
				self.demented_wtw.talents_cd = {}  -- Make sure defensive inscriptions can be used right away
			
				t.update_wtw(self, t)
			
				game:playSoundNear(self, "talents/arcane")
			end
			-- Recall pet and make sure it isn't chasing anything
			if self.demented_wtw then
				local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
				if not x then return end
				self.demented_wtw:move(x, y, true)
				self.demented_wtw:setTarget(nil)
			end
		end	
	end,
	info = function(self, t)
		return ([[You invoke a long standing pact with a fellow horror, a Worm that Walks, to help you in your travels.
		You can fully control, level, and equip it.
		Using this spell will ressurect your friendly horror if it died, giving it back %d%% life.
		Higher raw talent levels will give your horror more equipment slots:

		Level 1:  Mainhand, Offhand
		Level 2:  Body
		Level 3:  Belt
		Level 4:  Ring, Ring
		Level 5:  Ring, Ring, Trinket

		To change your horror's equipment and talents first transfer the equipment from your inventory then take control of it.]]):
		tformat(t.getPower(self, t))
	end,
}

newTalent{
	name = "Foul Convergence",
	short_name = "WORM_THAT_STABS",
	type = {"demented/friend-of-the-worm", 2},
	require = dementedreq_high2,
	points = 5,
	insanity = 30,
	cooldown = function(self, t) return self:combatTalentLimit(t, 8, 25, 10) end,
	tactical = { ATTACK = { weapon = 0.5, }, CLOSEIN = 3 },
	range = 10,
	direct_hit = true,
	requires_target = true,
	is_melee = true,
	is_teleport = true,
	no_npc_use = true,  -- Lets just not try to balance a 2 Actor teleport strike talent
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.7, 1.3) end,
	getBlindside = function(self, t) return math.floor(self:combatTalentLimit(t, 5, 1, 3.5)) end,
	on_pre_use = function(self, t, silent) 
		if self.demented_wtw and self.demented_wtw:attr("dead") then 
			if not silent then game.logPlayer(self, "Your friendly horror is dead.") end
			return false
		end
		return true
	end,
	on_learn = function(self, t)
		if self:knowTalent(self.T_WORM_THAT_WALKS) then
			self:callTalent(self.T_WORM_THAT_WALKS, "update_wtw")
		end
	end,
	on_unlearn = function(self, t)
		if self:knowTalent(self.T_WORM_THAT_WALKS) then
			self:callTalent(self.T_WORM_THAT_WALKS, "update_wtw")
		end
	end,
	action = function(self, t)
		if self:attr("never_move") then return end
		local wtw = self.demented_wtw
		if not wtw or (wtw and wtw.dead) then return end
		
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if not target or not self:canProject(tg, x, y) then return nil end
		if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then return nil end -- To prevent teleporting through walls
		if not self:teleportRandom(x, y, 0) then 
			game.logSeen(self, "%s's teleport fizzles!", self:getName():capitalize()) 
			return true 
		end

		if target and target.x and core.fov.distance(self.x, self.y, target.x, target.y) == 1 then
			local DamageType = require "engine.DamageType"
			self:attackTarget(target, DamageType.PHYSICAL, t.getDamage(self, t), true)
			game:playSoundNear(self, "talents/teleport")
		end

		-- Bring a friend
		-- For convenience we won't check range or LOS for the pet
		if not wtw:teleportRandom(x, y, 0) then
			game.logSeen(wtw, "%s's teleport fizzles!", self:getName():capitalize())
			return true 
		end

		if target and target.x and core.fov.distance(wtw.x, wtw.y, target.x, target.y) == 1 then
			local DamageType = require "engine.DamageType"
			wtw:attackTarget(target, DamageType.PHYSICAL, t.getDamage(self, t), true)
			wtw:setTarget(target)
		end
		return true
	end,
	info = function(self, t)
		return ([[You and your Worm that Walks both teleport to an enemy in range %d and make a melee attack for %d%% damage.
			Your Worm that Walks' Blindside talent cooldown is reduced by %d.]])
		:tformat(10, t.getDamage(self, t) * 100, t.getBlindside(self, t))
	end,
}

-- Resist gets high on randbosses but since you can just nuke the pet its probably fine
newTalent{
	name = "Shared Insanity",
	type = {"demented/friend-of-the-worm", 3},
	require = dementedreq_high3,
	points = 5,
	mode = "passive",
	no_unlearn_last = true,  -- Avoid whatever happens when you have more inscriptions than your max_inscription
	getResist = function(self, t) return math.floor(self:combatTalentScale(t, 15, 25)) end,
	getInscriptions = function(self, t) return math.floor(self:getTalentLevelRaw(t) / 2) end,
	on_learn = function(self, t)
		if self:knowTalent(self.T_WORM_THAT_WALKS) then
			self:callTalent(self.T_WORM_THAT_WALKS, "update_wtw")
		end
	end,
	callbackOnActBase = function(self, t)
		local wtw = self.demented_wtw
		if not wtw or wtw.dead or not wtw.x then return end
		if core.fov.distance(self.x, self.y, wtw.x, wtw.y) <= 3 then
			local save = 0
			if self:knowTalent(self.T_TERRIBLE_SIGHT) then save = self:callTalent(self.T_TERRIBLE_SIGHT, "getSave") end
			self:setEffect(self.EFF_WTW_SHARED_INSANITY, 5, {resist=t.getResist(self, t), save = save})
			wtw:setEffect(wtw.EFF_WTW_SHARED_INSANITY, 5, {resist=t.getResist(self, t), save = save})
		end
	end,
	info = function(self, t)
		return ([[You establish a powerful mental link with your Worm that Walks.
		As long as you remain within radius 3 of your worm that walks each of you gains %d%% all resistance for 5 turns.
		Additionally, your Worm that Walks permanently gains an inscription slot every 2 raw talent levels (%d).]])
		:tformat(t.getResist(self, t), t.getInscriptions(self, t))
	end,
}
	
newTalent{
	name = "Terrible Sight",
	type = {"demented/friend-of-the-worm", 4},
	require = dementedreq_high4,
	points = 5,
	insanity = -10,
	cooldown = 20,
	tactical = { ANNOY = 4, DEFEND = 3 },
	requires_target = true,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 3, 6)) end,
	target = function(self, t) return {type="ball", radius=self:getTalentRange(t), friendlyfire=false} end,
	getDur = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 2, 8)) end,
	getSave = function(self, t) return math.floor(self:combatTalentSpellDamage(t, 15, 55)) end,
	on_pre_use = function(self, t, silent) local wtw = getWtWBuddy(self) if not wtw or not wtw.x or core.fov.distance(self.x, self.y, wtw.x, wtw.y) >= 3 then if not silent then game.logPlayer(self, "You require your worm that walk to be alive and closeby.") end return false end return true end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py)
			local actor = game.level.map(px, py, Map.ACTOR)
			if not actor or not actor:canBe("stun") then return end
			actor:setEffect(actor.EFF_STUNNED, t.getDur(self, t), {apply_power=self:combatSpellpower()})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[While within range 3 of your Worm that Walks you can project an aura of terror.
		At the sight of two maddening horrors fighting together all your foes in radius %d must make a physical save against your spellpower or be stunned for %d turns.

		Additionally your Shared Insanity effect will cause enemies in radius 3 to lose %d spell save and %d defense for 3 turns.]]):
		tformat(self:getTalentRange(t), t.getDur(self, t), t.getSave(self, t), t.getSave(self, t))
	end,
}
