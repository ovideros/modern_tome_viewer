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

local Object = require "engine.Object"

newTalent{
	name = "Slip Away",
	type = {"steamtech/elusiveness", 1},
	points = 5,
	cooldown = 8,
	steam = 10,
	require = steamreq1,
	tactical = { ESCAPE=2 },
	range = 1,
	no_energy = true,
	getAway = function(self, t) return self:combatTalentScale(t, 2, 5) end,
	getRange = function(self, t) return self:combatTalentScale(t, 1, 5) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local ox, oy = self.x, self.y
		self:probabilityTravel(x, y, t.getRange(self, t), function(tx, ty) return not game.level.map(tx, ty, Map.ACTOR) and true or false end, true)
		if ox == self.x and oy == self.y then return nil end

		self:knockback(ox, oy, t.getAway(self, t))

		return true
	end,
	info = function(self, t)
		return ([[Using small steam motors to enhance your movements, you are able to slip past up to %d foes in a line.
		After passing the targets, you will quickly run %d tiles away.]])
		:tformat(t.getRange(self, t), t.getAway(self, t))
	end,
}

newTalent{
	name = "Agile Gunner",
	type = {"steamtech/elusiveness", 2},
	points = 5,
	require = steamreq2,
	cooldown = 15,
	mode = "sustained",
	drain_steam = 4,
	no_energy = true,
	requires_target = true,
	tactical = { ESCAPE=2, CLOSEIN=2 },
	getMax = function(self, t) return math.floor(self:combatTalentScale(t, 3, 8)) end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 10)) end,
	callbackOnAct = function(self, t, p)
		p = p or self:isTalentActive(t.id)
		local nb_foes = 0
		local act
		local sqdist
		local sqradius = self:getTalentRadius(t) ^ 2
		for i = 1, #self.fov.actors_dist do
			act = self.fov.actors_dist[i]
			sqdist = self.fov.actors and self.fov.actors and self.fov.actors[act] and self.fov.actors[act].sqdist
			if act and sqdist and self:reactionToward(act) < 0 and self:canSee(act) and sqdist <= sqradius then nb_foes = nb_foes + 1 end
		end
		if nb_foes ~= p.nb_foes then
			if p.tmpid then self:removeTemporaryValue("movement_speed", p.tmpid) p.tmpid = nil end
			if nb_foes > 0 then p.tmpid = self:addTemporaryValue("movement_speed", math.min(nb_foes, t.getMax(self, t)) * 0.2) end
		end
		p.nb_foes = nb_foes
	end,
	activate = function(self, t)
		local ret = { nb_foes=0 }
		t.callbackOnAct(self, t, ret)
		return ret
	end,
	deactivate = function(self, t, p)
		if p.tmpid then self:removeTemporaryValue("movement_speed", p.tmpid) end
		return true
	end,
	info = function(self, t)
		local p = self:isTalentActive(t.id)
		local cur = 0
		if p then cur = math.min(p.nb_foes, t.getMax(self, t)) * 20 end
		return ([[The thrill of the hunt invigorates you. For each foe in radius %d around you, you gain 20%% movement speed (up to %d%%).
		Current bonus: %d%%.]])
		:tformat(self:getTalentRadius(t), t.getMax(self, t) * 20, cur)
	end,
}

newTalent{
	name = "Awesome Toss",
	type = {"steamtech/elusiveness", 3},
	points = 5,
	cooldown = 12,
	steam = 25,
	require = steamreq3,
	no_energy = true,
	no_npc_use = true,
	tactical = { BUFF=2, ATTACKAREA={weapon=2} },
	on_pre_use = function(self, t, silent) if not self:hasDualArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require two steamguns for this talent.") end return false end return true end,
	getResist = function(self, t) return self:combatTalentLimit(t, 35, 5, 20) end,
	getMultiple = function(self, t) return self:combatTalentWeaponDamage(t, 1, 2) end,
	action = function(self, t)
		self:setEffect(self.EFF_AWESOME_TOSS, 2, {dam=t.getMultiple(self, t), resist=t.getResist(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[In an awesome feat of agility and technological prowess, you toss both of your steamguns in the air, causing them to spin madly for 3 turns.
		Each turn, they will fire twice at random targets in range, dealing %d%% weapon damage.
		While the guns are airborne, you are disarmed and cannot attack.
		The spectacle is so distracting that your foes have a hard time concentrating on you, increasing all of your resistances by %d%%.]])
		:tformat(100 * t.getMultiple(self, t), t.getResist(self, t))
	end,
}

newTalent{
	name = "Dazzling Jump",
	type = {"steamtech/elusiveness", 4},
	points = 5,
	cooldown = 12,
	steam = 25,
	require = steamreq4,
	tactical = { ESCAPE=2, DEBUFF={slow=3} },
	no_energy = true,
	radius = 3,
	getAway = function(self, t) return self:combatTalentScale(t, 4, 9) end,
	getRange = function(self, t) return self:combatTalentScale(t, 3, 5) end,
	getSlow = function(self, t) return self:combatTalentLimit(t, 70, 20, 52) end,
	on_pre_use = function(self, t, silent) return self:hasEffect(self.EFF_AWESOME_TOSS) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), simple_dir_request=true, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		local ox, oy = self.x, self.y

		self:project({type="ball", radius=self:getTalentRadius(t), range=1, friendlyfire=false}, target.x, target.y, function(px, py)
			local tgt = game.level.map(px, py, Map.ACTOR)
			if tgt then
				tgt:setEffect(target.EFF_SLOW, 4, {power=t.getSlow(self, t) / 100, apply_power=self:combatSteampower()})
			end
		end)
		game.level.map:particleEmitter(target.x, target.y, self:getTalentRadius(t), "gravity_spike", {radius=self:getTalentRadius(t), allow=core.shader.allow("distort")})
		game:playSoundNear(self, "talents/earth")

		self:knockback(target.x, target.y, t.getAway(self, t))

		if target:canBe("knockback") then
			target:knockback(ox, oy, t.getRange(self, t))
		else
			game.logSeen(target, "%s seems immune to the powerful kick.", target:getName():capitalize())
		end

		return true
	end,
	info = function(self, t)
		return ([[While your foes are distracted by your Awesome Toss, you use powerful steam motors to jump into the air and kick a target %d tiles away.
		The impact is so great that it ripples outwards, slowing all creatures in radius 3 by %d%% for 4 turns while the reaction force propels you %d tiles backwards.]])
		:tformat(t.getRange(self, t), t.getSlow(self, t), t.getAway(self, t))
	end,
}
