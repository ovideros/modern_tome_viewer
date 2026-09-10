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

local Object = require "mod.class.Object"

newTalent{
	name = "Netherblast",
	type = {"demented/nether", 1},
	require = dementedreq1,
	points = 5,
	cooldown = 3,
	insanity = 11,
	range = 10,
	tactical = { ATTACK = {DARKNESS = 2, TEMPORAL = 2} },
	requires_target = true,
	getDamage = function(self,t) return self:combatTalentSpellDamage(t, 20, 250)+30 end,
	getBacklash = function(self,t) return t.getDamage(self, t)*0.1 end,
	target = function(self, t)
		local eff = self:hasEffect(self.EFF_HALO_OF_RUIN)
		if eff and eff.charges==5 then
			return {type="beam", range=self:getTalentRange(t), friendlyfire=false, talent=t}
		else
			local ff = false
			if game.zone.short_name == "cults+ft-cultist" then ff = true end  -- This zone needs NB to be FF and making an entirely separate talent seems silly
			return {type="bolt", range=self:getTalentRange(t), talent=t, friendlyblock = ff, display={particle="netherblast"}}
		end
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTargetLimited(tg)
		if not x or not y then return nil end

		local dam = self:spellCrit(t.getDamage(self,t))
		local eff = self:hasEffect(self.EFF_HALO_OF_RUIN)
		if eff and eff.charges==5 then
			self.turn_procs.halo_of_ruin = true

			local perc = self:callTalent(self.T_HALO_OF_RUIN, "getSpikeDamage")
			self:project(tg, x, y, DamageType.VOIDBURN, {dam=dam, dur=5, perc=perc})
			local _ _, _, _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, tg.range, "netherlance", {tx=x - self.x, ty=y - self.y})
			self:removeEffect(self.EFF_HALO_OF_RUIN)
			game:playSoundNear(self, "talents/netherlance")
		else
			self:projectile(tg, x, y, DamageType.VOID, dam, {type="voidblast"})
			game:playSoundNear(self, "talents/netherblast")
		end
		if self.in_combat then
			self:setEffect(self.EFF_ENTROPIC_WASTING, 8, {src=self, power=t.getBacklash(self, t) / 8})
		end
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self,t)/2
		local backlash = t.getBacklash(self,t)
		return ([[Fire a burst of unstable void energy, dealing %0.2f darkness and %0.2f temporal damage to the target. The power of this spell inflicts entropic backlash on you, causing you to take %d damage over 8 turns. This damage counts as entropy for the purpose of Entropic Gift.
		The damage will increase with your Spellpower.]]):
		tformat(damDesc(self, DamageType.DARKNESS, dam), damDesc(self, DamageType.TEMPORAL, dam), backlash)
	end,
}

-- This lets you place it 1 tile depth into a wall letting you hit on the other side, I assume block_path needs to be modified or something?
newTalent{
	name = "Rift Cutter",
	type = {"demented/nether", 2},
	require = dementedreq2,
	points = 5,
	cooldown = 5,
	insanity = 10,
	range = 10,
	tactical = { ATTACKAREA = {DARKNESS = 2} },
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), friendlyfire=false, talent=t}
	end,
	getDamage = function(self,t) return self:combatTalentSpellDamage(t, 25, 150) end,
	getBacklash = function(self,t) return t.getDamage(self, t)*0.8 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:spellCrit(t.getDamage(self, t))
		local edam = 0
		local pin = 0
		local rad = 1
		local eff = self:hasEffect(self.EFF_HALO_OF_RUIN)
		if eff and eff.charges==5 then
			self.turn_procs.halo_of_ruin = true
			edam = self:spellCrit(self:callTalent(self.T_HALO_OF_RUIN, "getRiftDamage"))
			pin = self:callTalent(self.T_HALO_OF_RUIN, "getPin")
			rad = rad + self:callTalent(self.T_HALO_OF_RUIN, "getRiftRadius")
			self:removeEffect(self.EFF_HALO_OF_RUIN)
		end
		local grids = self:project(tg, x, y, DamageType.DARKNESS, dam)
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "shadow_beam", {tx=x-self.x, ty=y-self.y})

		game.level.map:addEffect(self, self.x, self.y, 4,
			engine.DamageType.RIFT,
			{
				dam = dam, edam = edam,
				pin = pin,
				radius = 1, self = self, talent = t
			},
			0, 5, grids,
			MapEffect.new{
				zdepth=6,
				color_br=12, color_bg=12, color_bb=12,
				effect_shader="shader_images/unstable_rift_ground.png"
			},
			function(e, update_shape_only)
				if not update_shape_only and e.duration == 1 then
					local DamageType = require("engine.DamageType") --block_path means that it will always hit the tile we've targeted here

					for px, ys in pairs(e.grids) do for py, _ in pairs(ys) do
						local aoe = {type="ball", radius = rad, friendlyfire=false, talent=e.dam.talent, block_path = function(self, t) return false, true, true end}
						e.src:projectSource(aoe, px, py, DamageType.RIFT_EXPLOSION, e.dam.dam, nil, e.dam.talent)
						game.level.map:particleEmitter(px, py, 1, "unstable_rift_explosion", {id=1, radius=rad})
						game.level.map:particleEmitter(px, py, 1, "unstable_rift_explosion", {id=2, radius=rad})
						game.level.map:particleEmitter(px, py, 1, "unstable_rift_explosion", {id=3, radius=rad})
						game.level.map:particleEmitter(px, py, 1, "unstable_rift_explosion", {id=4, radius=rad})
					end end
					e.duration = 0

					game:playSoundNear(self, "talents/fireflash")
					--I'll let map remove it
				end						
			end
		)
		if self.in_combat then
			self:setEffect(self.EFF_ENTROPIC_WASTING, 8, {src=self, power=t.getBacklash(self, t) / 8})
		end
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Fire a beam of energy that rakes across the ground, dealing %0.2f darkness damage to enemies within and leaving behind an unstable rift. After 3 turns the rift detonates, dealing %0.2f temporal damage to adjacent enemies.
		Targets cannot be struck by more than a single rift explosion at once.
		The power of this spell inflicts entropic backlash on you, causing you to take %d damage over 8 turns. This damage counts as entropy for the purpose of Entropic Gift.
		The damage will increase with your Spellpower.]]):
		tformat(damDesc(self, DamageType.DARKNESS, t.getDamage(self,t)), damDesc(self, DamageType.TEMPORAL, t.getDamage(self,t)), t.getBacklash(self, t))
	end,
}

newTalent{
	name = "Spatial Distortion",
	type = {"demented/nether", 3},
	require = dementedreq3,
	points = 5,
	insanity = -10,
	cooldown = 20,
	tactical = { ATTACKAREA = {DARKNESS = 1, TEMPORAL = 1}, ESCAPE = 2, DISABLE = 2 },
	requires_target = true,
	range = 10,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 200) end,
	getBacklash = function(self,t) return t.getDamage(self,t) end,
	getDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 2.5, 4.5)) end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4)) end,
	getSpatialDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 3.5, 5.5)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), nowarning=true, selffire = false, friendlyfire=false, talent=t}
	end,
	requires_target = true,
	direct_hit = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		
		game.logPlayer(self, "Select a teleport location...")
		local tg2 = {type="ball", nolock=true, nowarning=true, range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
		x2, y2 = self:getTarget(tg2)
		if not x2 then return nil end
		_, _, _, x2, y2 = self:canProject(tg, x2, y2)
		local sdur = 0
		local eff = self:hasEffect(self.EFF_HALO_OF_RUIN)
			if eff and eff.charges==5 then		
			self.turn_procs.halo_of_ruin = true		
			sdur = self:callTalent(self.T_HALO_OF_RUIN, "getSpatialDuration")
			self:removeEffect(self.EFF_HALO_OF_RUIN)
		end		
		
		local dam = self:spellCrit(t.getDamage(self, t))
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			game.level.map:particleEmitter(target.x, target.y, 1, "nether_teleport_in", {id=1, radius=tg.radius})
			game.level.map:particleEmitter(target.x, target.y, 1, "nether_teleport_in", {id=2, radius=tg.radius})
			game.level.map:particleEmitter(target.x, target.y, 1, "nether_teleport_in", {id=3, radius=tg.radius})
			game.level.map:particleEmitter(target.x, target.y, 1, "nether_teleport_in", {id=4, radius=tg.radius})
			game.level.map:particleEmitter(target.x, target.y, 1, "nether_teleport_in", {id=5, radius=tg.radius})


			if (self:checkHit(self:combatSpellpower(), target:combatSpellResist() + (target:attr("continuum_destabilization") or 0))) or self:reactionToward(target) >= 0 and target:canBe("teleport") then
				if not target:teleportRandom(x2, y2, 1) then
					game.logSeen(target, "The spell fizzles on %s!", target:getName():capitalize())
				else
					if self:reactionToward(target) < 0 then	target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self:combatSpellpower(0.3)}) end
					game.level.map:particleEmitter(target.x, target.y, 1, "nether_teleport_out", {id=1, radius=tg.radius})
					game.level.map:particleEmitter(target.x, target.y, 1, "nether_teleport_out", {id=2, radius=tg.radius})
					game.level.map:particleEmitter(target.x, target.y, 1, "nether_teleport_out", {id=3, radius=tg.radius})
					game.level.map:particleEmitter(target.x, target.y, 1, "nether_teleport_out", {id=4, radius=tg.radius})
					game.level.map:particleEmitter(target.x, target.y, 1, "nether_teleport_out", {id=5, radius=tg.radius})
					
					game.logSeen(target, "#CRIMSON#%s is swallowed by a portal!", target:getName():capitalize())
				end
			else
				game.logSeen(target, "%s resists the warp!", target:getName():capitalize())
			end
			if self:reactionToward(target) < 0 and not target.spatial_distortion then --sanity check
				target.spatial_distortion = true
				DamageType:get(DamageType.VOID).projector(self, target.x, target.y, DamageType.VOID, dam)
			end
		end)
		local x3, y3 = util.findFreeGrid(x2, y2, 3, true, {[Map.ACTOR]=true})
		if sdur > 0 and x3 then
			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				type = "horror", subtype = "eldritch",
				display = "h", blood_color = colors.BLUE,
				faction = self.faction,
				stats = { str=self:getMag(), dex=self:getMag(), mag=self:getMag(), con=self:getMag(), wil=self:getMag(), cun=self:getMag() },
				infravision = 10,
				no_breath = 1,
				fear_immune = 1,
				knockback_immune = 1,
				never_move = 1,
				name = _t"entropic maw", color=colors.GREY,
				desc = _t"Tendrils lash around the mouth of this gigantic beast, seeking prey to devour.",
				image="npc/entropic_fiend.png",
				level_range = {self.level, self.level}, exp_worth = 0,
				rank = 2,
				size_category = 3,
				autolevel = "warrior",
				life_rating = 20,
				life_regen = 4,
				combat_armor = 16, combat_def = 1,
				combat = { dam=10 + self.level*1.5, damtype=DamageType.VOID, atk=10 + self.level*1.5, apr=25, dammod={str=1.2}, physcrit = 10 },
		
				resists = {all = 30, [DamageType.DARKNESS] = 100, [DamageType.TEMPORAL] = 100},
		
				resolvers.talents{
					[Talents.T_GRASPING_TENDRILS] = 1,								
				},
				resolvers.sustains_at_birth(),
		
				ai = "summoned", ai_real = "tactical", ai_state = { ai_move="move_complex", talent_in=1, ally_compassion=0 },
				no_drops = true,
				faction = self.faction,
				summoner = self, summoner_gain_exp=true,
				summon_time = t.getSpatialDuration(self, t),
			}
			m:resolve()
			m:resolve(nil, true)		
			game.zone:addEntity(game.level, m, "actor", x3, y3)
		end
		if self.in_combat then
			self:setEffect(self.EFF_ENTROPIC_WASTING, 8, {src=self, power=t.getBacklash(self, t) / 8})
		end
		game:playSoundNear(self, "talents/terminus")

		return true
	end,

	info = function(self, t)
		local dam = t.getDamage(self,t)/2
		local backlash = t.getBacklash(self,t)
		local dur = t.getDuration(self,t)
		local rad = self:getTalentRadius(t)
		return ([[Briefly open a radius %d rift in spacetime that teleports those within to the targeted location. Enemies will take %0.2f darkness and %0.2f temporal damage.
		The power of this spell inflicts entropic backlash on you, causing you to take %d damage over 8 turns. This damage counts as entropy for the purpose of Entropic Gift.
		The damage will improve with your Spellpower.]]):tformat(rad, damDesc(self, DamageType.DARKNESS, dam), damDesc(self, DamageType.TEMPORAL, dam), backlash)
	end,
}

newTalent{
	name = "Halo of Ruin",
	require = dementedreq4,
	type = {"demented/nether", 4},
	points = 5,
	mode = "passive",
	getCrit = function(self, t) return 2 end,
	getSpikeDamage = function(self, t) return self:combatTalentScale(t, 1, 2) end,
	getRiftDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 120) end,
	getRiftRadius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2)) end,
	getSpatialDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 3.5, 5.5)) end,
	getPin = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 2, 8)) end,
	callbackOnTalentPost = function(self, t, ab)
		if ab.type[1]:find("^demented/") and not ab.no_energy then
			if self.turn_procs.halo_of_ruin then return end
			if not self.in_combat then return end
			local crit = t.getCrit(self, t)
			self:setEffect(self.EFF_HALO_OF_RUIN, 10, {power=crit, charges=1, max_charges=5})
			self.turn_procs.halo_of_ruin = true
		end
	end,
	info = function(self, t)
		return ([[Each time you cast a non-instant Demented spell, a nether spark begins orbiting around you for 10 turns, to a maximum of 5. Each spark increases your critical strike chance by %d%%, and on reaching 5 sparks your next Nether spell will consume all sparks to empower itself:
#PURPLE#Netherblast:#LAST# Becomes a deadly lance of void energy, piercing through enemies and dealing an additional %d%% damage over 5 turns.
#PURPLE#Rift Cutter:#LAST# Those in the rift will be pinned for %d turns, take %0.2f temporal damage each turn, and the rift explosion has %d increased radius.
#PURPLE#Spatial Distortion:#LAST# An Entropic Maw will be summoned at the rift's exit for %d turns, pulling in and taunting nearby targets with it's tendrils.
The damage will increase with your Spellpower.  Entropic Maw stats will increase with level and your Magic stat.]]):
		tformat(t.getCrit(self,t), t.getSpikeDamage(self,t)*100, t.getPin(self, t), damDesc(self, DamageType.TEMPORAL, t.getRiftDamage(self,t)), t.getRiftRadius(self,t), t.getSpatialDuration(self,t))
	end,
}

newTalent{
	name = "Grasping Tendrils",
	type = {"other/horror", 1},
	points = 1,
	cooldown = 2,
	range = 7,
	tactical = { ATTACK = 1, CLOSEIN = 3 },
	requires_target = true,
	target = function(self, t) return {type="bolt", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return 1.5 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		local target = game.level.map(x, y, engine.Map.ACTOR)
		if not x or not y or not target then return nil end

		target:pull(self.x, self.y, tg.range)
		target:setTarget(self)

		game:playSoundNear(self, "talents/slime")

		return true
	end,
	info = function(self, t)
		return ([[Grab a target and drag it to your side, dealing %d%% weapon damage and taunting it.]]):
		tformat(t.getDamage(self,t)*100)
	end,
}
