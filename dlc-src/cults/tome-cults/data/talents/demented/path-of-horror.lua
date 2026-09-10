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
	name = "Carrion Feet",
	type = {"demented/path-of-horror", 1},
	require = dementedreq1,
	no_unlearn_last = true,
	points = 5,
	insanity = 10,
	cooldown = 15,
	tactical = { CLOSEIN = 3 },
	requires_target = true,
	direct_hit = true,
	target = function(self, t) return {type="cone", x=self.x, y=self.y, stop_before_target=true, radius=2, range=self:getTalentRange(t), nolock=true} end,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 5, 10, 0.5, 0, 1)) end,
	getPassiveSpeed = function(self, t) return self:combatTalentScale(t, 0.08, 0.4, 0.7) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "movement_speed", t.getPassiveSpeed(self, t))
	end,
	action = function(self, t)
		self:setTarget(nil) -- stop_before_target requires that to force a scan
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

		local ox, oy = self.x, self.y

		local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
		local l = self:lineFOV(x, y, block_actor)
		local lx, ly, is_corner_blocked = l:step()
		local tx, ty, _ = lx, ly
		while lx and ly do
			if is_corner_blocked or block_actor(_, lx, ly) then break end
			tx, ty = lx, ly
			lx, ly, is_corner_blocked = l:step()
		end

		-- Find space
		if block_actor(_, tx, ty) then return nil end
		local fx, fy = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not fx then return end

		-- We project BEFORE we move so that the cone is well oriented
		local hit = false
		self:project(tg, fx, fy, function(px, py)
			local act = game.level.map(px, py, Map.ACTOR)
			if act and self:reactionToward(act) <= 0 then
				hit = true
				act:setEffect(act.EFF_CARRION_FEET, 1, {power=70}) 
			end
		end, 0, {type="slime"})

		if hit then self:incInsanity(20) end
		
		self:move(fx, fy, true)
		if config.settings.tome.smooth_move > 0 then
			self:resetMoveAnim()
			self:setMoveAnim(ox, oy, 9, 5)
		end


		return true
	end,
	info = function(self, t)
		return ([[Your feet start to continuously produce carrion worms that are constantly crushed as you walk, passively increasing movement speed by %d%%.
		You can also activate this talent to instantly destroy more worms, letting you jump in range %d to visible terrain.
		Upon landing you crush more worms, creating a radius 2 cone of gore; any creatures caught inside deals 70%% less damage for one turn.
		If at least 1 enemy is effected by the cone you gain an additional 20 insanity.]]):
		tformat(t.getPassiveSpeed(self, t)*100, self:getTalentRange(t))
	end,
}

newTalent{
	name = "Horrific Evolution",
	short_name = "DECAYING_GUTS",
	type = {"demented/path-of-horror", 2},
	require = dementedreq2,
	mode = "passive",
	points = 5,
	getAccuracy = function(self, t) return self:combatTalentStatDamage(t, "mag", 15, 50) end,
	getSpellpower = function(self, t) return self:combatTalentStatDamage(t, "mag", 15, 50) end,
	passives = function(self, t, p)
		local Stats = require "engine.interface.ActorStats"
		self:talentTemporaryValue(p, "combat_atk", t.getAccuracy(self, t))
		self:talentTemporaryValue(p, "combat_spellpower", t.getSpellpower(self, t))
	end,
	callbackOnStatChange = function(self, t, stat, v)
		if stat == self.STAT_MAG then
			self:updateTalentPassives(t)
		end
	end,
	info = function(self, t)
		return ([[Your mutations have enhanced your offense even farther.
		You gain %d Accuracy and %d Spellpower.
		The effects will increase with your Magic stat.]])
		:tformat(t.getAccuracy(self, t), t.getSpellpower(self, t))
	end,
}

newTalent{
	name = "Overgrowth", short_name = "CULTS_OVERGROWTH",
	type = {"demented/path-of-horror", 3},
	require = dementedreq3,
	points = 5,
	insanity = -20,
	cooldown = 35,
	no_energy = true,
	tactical = { BUFF = 4 },
	requires_target = true,
	getDur = function(self, t) return self:combatTalentLimit(t, 9, 3, 8) end,
	getDam = function(self, t) return self:combatTalentScale(t, 10, 30) end,
	getResist = function(self, t) return self:combatTalentScale(t, 10, 30) end,
	action = function(self, t)
		self:setEffect(self.EFF_CULTS_OVERGROWTH, t.getDur(self, t), {dam=t.getDam(self, t), resist=t.getResist(self, t)})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[You trigger a cascade of rapidly mutating cells in your body for %d turns.
		Your body grows much bigger, gaining 2 size categories, making you able to walk through walls and increasing all your damage by %d%% and all your resistances by %d%%.
		Each time you take a step your monstrous form causes a small quake destroying and rearranging nearby terrain.]]):
		tformat(t.getDur(self, t), t.getDam(self, t), t.getResist(self, t))
	end,
}

newTalent{
	name = "Writhing One",
	type = {"demented/path-of-horror", 4},
	require = dementedreq4,
	points = 5,
	mode = "passive",
	getCritResist = function(self, t) return self:combatTalentScale(t, 15, 50) end,
	getImmunities = function(self, t) return self:combatTalentLimit(t, 1, 0.2, 0.5) end,
	getDam = function(self, t) return self:combatTalentScale(t, 3, 15) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "inc_damage", {[DamageType.DARKNESS]=t.getDam(self, t), [DamageType.BLIGHT]=t.getDam(self, t)})
		self:talentTemporaryValue(p, "stun_immune", t.getImmunities(self, t))
		self:talentTemporaryValue(p, "ignore_direct_crits", t.getCritResist(self, t))
	end,
	info = function(self, t)
		return ([[At last you unlock the true power of your mutated body!
		You gain %d%% stun immunity, %d%% chances to ignore critical strikes and your darkness and blight damage are increased by %d%%.]]):
		tformat(t.getImmunities(self, t) * 100, t.getCritResist(self, t), t.getDam(self, t))
	end,
}
