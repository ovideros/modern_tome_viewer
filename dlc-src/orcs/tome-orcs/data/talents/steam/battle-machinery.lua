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

local Trap = require "mod.class.Trap"
local Object = require "mod.class.Object"

newTalent{
	name = "Explosive Steam Engine",
	type = {"steamtech/battle-machinery",1},
	require = steamreq1,
	points = 5,
	steam = 30,
	cooldown = 10,
	tactical = { ATTACKAREA = 2 },
	range = 5,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3, "log")) end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 20, 300) end,
	action = function(self, t)
		local tg = {type="ball", radius=self:getTalentRadius(t), nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		if game.level.map:checkEntity(tx, ty, Map.TERRAIN, "block_move") then return end
		local trap = game.level.map(tx, ty, Map.TRAP)
		if trap then return end

		local dam = self:steamCrit(t.getDamage(self, t))
		local trap = Trap.new{
			name = _t"critical steam engine",
			type = "steamtech", id_by_type=true, unided_name = _t"trap",
			display = '*', color=colors.RED, image = "trap/critical_steam_engine.png",
			dam = dam,
			radius = self:getTalentRadius(t),
			canTrigger = function(self, x, y, who) return false end,
			triggered = function(self, x, y, who) return true end,
			temporary = 3,
			x = tx, y = ty,
			disarm_power = math.floor(self:combatSteampower() * 1.8),
			detect_power = math.floor(self:combatSteampower() * 1.8),
			canAct = false,
			energy = {value=0},
			act = function(self)
				local DamageType = require "engine.DamageType"
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map:particleEmitter(self.x, self.y, self.radius, "fireflash", {radius=self.radius})
					self.summoner:project({type="ball", radius=self.radius, friendlyfire=false, x=self.x, y=self.y}, self.x, self.y, function(px, py)
						local target = game.level.map(px, py, engine.Map.ACTOR)
						if not target then return end
						local mult = 1
						if #target:effectsFilter({subtype={bleed=1}}, 1) > 0 then
							mult = mult * 1.4
						end
						DamageType:get(DamageType.FIRE).projector(self.summoner, px, py, DamageType.FIRE, self.dam * mult)
					end)
					game:playSoundNear(self, "talents/fire")

					if self.summoner:knowTalent(self.summoner.T_LINGERING_CLOUD) then
						game.level.map:addEffect(self.summoner,
							self.x, self.y, 5,
							engine.DamageType.FIERY_VAPOUR, {dam=self.summoner:callTalent(self.summoner.T_LINGERING_CLOUD, "getDamage"), steam=self.summoner:callTalent(self.summoner.T_LINGERING_CLOUD, "getRegen")},
							self.radius,
							5, 55,
							{type="inferno"},
							nil, true, true
						)
					end

					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
					game.level:removeEntity(self)
				end
			end,
			summoner = self,
			summoner_gain_exp = true,
		}
		game.level:addEntity(trap)
		trap:identify(true)
		trap:setKnown(self, true)
		game.zone:addEntity(game.level, trap, "trap", tx, ty)
		return true
	end,
	info = function(self, t)
		return ([[Throw a small, unstable steam engine on the battlefield that will go critical after 2 turns.
		It will then create an explosion of hot vapour in radius %d, burning all foes for %0.2f fire damage.
		Any bleeding foe caught in the flames will take 40%% more damage.
		Damage scales with your Steampower.
		#{italic}#Tick Tock Tick BOOM!#{normal}#]])
		:tformat(self:getTalentRadius(t), damDesc(self, DamageType.FIRE, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Lingering Cloud",
	type = {"steamtech/battle-machinery",2},
	require = steamreq2,
	points = 5,
	mode = "passive",
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 20, 400) / 5 end,
	getRegen = function(self, t) return self:combatTalentScale(t, 1, 5) end,
	info = function(self, t)
		return ([[Explosive Steam Engine vapour now lingers for 5 turns.
		Each turn, bleeding foes inside the cloud will take %0.2f fire damage.
		Any steamtech-using creature will also regenerate %d additional steam per turn while inside the cloud.
		Damage scales with your Steampower.
		#{italic}#Modern technology at the service of burnination!#{normal}#]])
		:tformat(damDesc(self, DamageType.FIRE, t.getDamage(self, t)), t.getRegen(self, t))
	end,
}

newTalent{
	name = "Tremor Engine",
	type = {"steamtech/battle-machinery",3},
	require = steamreq3,
	points = 5,
	steam = 30,
	cooldown = 10,
	tactical = { DISABLE = 2 },
	range = 5,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3, "log")) end,
	getDur = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	action = function(self, t)
		local tg = {type="ball", radius=self:getTalentRadius(t), nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		if game.level.map:checkEntity(tx, ty, Map.TERRAIN, "block_move") then return end
		local trap = game.level.map(tx, ty, Map.TRAP)
		if trap then return end

		local dur = t.getDur(self, t)
		local trap = Trap.new{
			name = _t"tremor engine",
			type = "steamtech", id_by_type=true, unided_name = _t"trap",
			display = '*', color=colors.UMBER, image = "trap/tremor_engine.png",
			dur = dur,
			radius = self:getTalentRadius(t),
			canTrigger = function(self, x, y, who) return false end,
			triggered = function(self, x, y, who) return true end,
			temporary = 8,
			x = tx, y = ty,
			disarm_power = math.floor(self:combatSteampower() * 1.8),
			detect_power = math.floor(self:combatSteampower() * 1.8),
			canAct = false,
			energy = {value=0},
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 5 then
					self.summoner:project({type="ball", radius=self.radius, friendlyfire=true, x=self.x, y=self.y}, self.x, self.y, function(px, py)
						local target = game.level.map(px, py, engine.Map.ACTOR)
						if not target or target == self.summoner then return end
						local eff = rng.table{{self.summoner.EFF_STUNNED, "stun"}, {self.summoner.EFF_PINNED, "pin"}, {self.summoner.EFF_DISARMED, "disarm"}}
						if target:canBe(eff[2]) then target:setEffect(eff[1], self.dur, {apply_power=self.summoner:combatSteampower()}) end
						self:setKnown(target, true, self.x, self.y)
					end)
					game.level.map:particleEmitter(self.x, self.y, self.radius, "gravity_spike", {radius=self.radius, allow=core.shader.allow("distort")})
					game:playSoundNear(self, "talents/earth")
				end

				if self.temporary <= 0 then
					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
					game.level:removeEntity(self)

					if self.summoner:knowTalent(self.summoner.T_SEISMIC_ACTIVITY) then self.summoner:callTalent(self.summoner.T_SEISMIC_ACTIVITY, "raiseVolcano", self.x, self.y) end
				end
			end,
			summoner = self,
			summoner_gain_exp = true,
		}
		game.level:addEntity(trap)
		trap:identify(true)
		trap:setKnown(self, true)
		game.zone:addEntity(game.level, trap, "trap", tx, ty)
		return true
	end,
	info = function(self, t)
		return ([[Throw a tremor engine on the battlefield that will trigger after 2 turns.
		For 5 turns after triggering, it will constantly shake the ground and stun, pin, or disarm any creature in radius %d for %d turns.
		#{italic}#The ground is mere paper to you!#{normal}#]])
		:tformat(self:getTalentRadius(t), t.getDur(self, t))
	end,
}


newTalent{
	name = "Seismic Activity",
	type = {"steamtech/battle-machinery",4},
	require = steamreq4,
	points = 5,
	mode = "passive",
	getDur = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 10, 200) end,
	nbProj = function(self, t) return 2 end,
	raiseVolcano = function(self, t, x, y)
		local function make_volcano(x, y)
			local oe = game.level.map(x, y, Map.TERRAIN)
			if not oe or oe:attr("temporary") then return end

			local e = Object.new{
				old_feat = oe,
				type = oe.type, subtype = oe.subtype,
				name = _t"raging volcano", image = oe.image, add_mos = {{image = "terrain/lava/volcano_01.png"}},
				display = '&', color=colors.LIGHT_RED, back_color=colors.RED,
				always_remember = true,
				temporary = t.getDur(self, t),
				x = x, y = y,
				canAct = false,
				nb_projs = t.nbProj(self, t),
				dam = t.getDamage(self, t),
				act = function(self)
					local tgts = {}
					local grids = core.fov.circle_grids(self.x, self.y, 5, true)
					for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
						local a = game.level.map(x, y, engine.Map.ACTOR)
						if a and self.summoner:reactionToward(a) < 0 then tgts[#tgts+1] = a end
					end end

					-- Randomly take targets
					local tg = {type="bolt", friendlyfire=false, selffire=false, range=5, x=self.x, y=self.y, talent=self.summoner:getTalentFromId(self.summoner.T_VOLCANO), display={image="object/lava_boulder.png"}}
					for i = 1, self.nb_projs do
						if #tgts <= 0 then break end
						local a, id = rng.table(tgts)
						table.remove(tgts, id)

						self.summoner:projectile(tg, a.x, a.y, engine.DamageType.MOLTENROCK, self.dam, {type="flame"})
						game:playSoundNear(self, "talents/fire")
					end

					self:useEnergy()
					self.temporary = self.temporary - 1
					if self.temporary <= 0 then
						game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
						game.level:removeEntity(self)
						game.level.map:updateMap(self.x, self.y)
						game.nicer_tiles:updateAround(game.level, self.x, self.y)
					end
				end,
				summoner_gain_exp = true,
				summoner = self,
			}
			game.level:addEntity(e)
			game.level.map(x, y, Map.TERRAIN, e)
			game.nicer_tiles:updateAround(game.level, x, y)
			game.level.map:updateMap(x, y)

			if core.shader.active(4) then
				game.level.map:particleEmitter(x, y, 1, "shader_ring_rotating", {rotation=0, radius=2, life=30, y=0, img="flamesshockwave"}, {type="firearcs"})
			end
		end
		make_volcano(x, y)
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[On its last pulse, your Tremor Engine shakes violently, raising a volcano for %d turns.
		Each turn, the volcano will send out fiery boulders that deal %0.2f fire and %0.2f physical damage.
		Damage scales with your Steampower.
		#{italic}#All the fury of fire at your disposal!#{normal}#]])
		:tformat(t.getDur(self, t), damDesc(self, DamageType.FIRE, dam/2), damDesc(self, DamageType.PHYSICAL, dam/2))
	end,
}

