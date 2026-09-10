-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

local Map = require "engine.Map"

newTalent{
	name = "Soul Eater", short_name = "DEMON_SOUL_EATER",
	type = {"corruption/other", 1},
	points = 5,
	radius = 10,
	callbackOnAct = function(self, t)
		self:project({type="ball", radius=self:getTalentRadius(t)}, self.x, self.y, function(px, py)
			local act = game.level.map(px, py, Map.ACTOR)
			if not act or act == self or self:reactionToward(act) <= 0 then return end
			if act.summoner then return end
			act.summoner = self
			game.logSeen(act, "#CRIMSON#%s is bound to %s will.", act:getName():capitalize(), self:getName())
		end)
	end,
	callbackOnSummonDeath = function(self, t, summon, killer, death_note)
		if summon.is_soul_eater_husk or summon:attr("undead") then return end
		game.logSeen(summon, "#PURPLE#As %s falls down you see %s reach to it, devour its essence and raise it back as a demonic husk.", summon:getName(), self:getName())

		summon.dead = false
		summon.is_soul_eater_husk = true
		summon.name = ("%s (demonic husk)"):tformat(_t(summon.name))
		summon.movement_speed = 0.5
		summon.max_life = summon.max_life * 1.5
		summon.life = summon.max_life
		summon.shader = "greyscale"
		local talents = { 
			"T_DRAINING_ASSAULT", "T_FIERY_GRASP", "T_SHARE_THE_PAIN",
			"T_DEMON_SEED_FIERY_CLEANSING", "T_DEMON_SEED_FARSTRIKE", "T_DEMON_SEED_DOOM_TENDRILS",
			"T_DISMEMBER", "T_SURGE_OF_POWER",
			"T_OBLITERATING_SMASH",
		}

		for i = 1, rng.range(2, 3) do
			local tid = rng.tableRemove(talents)
			summon:learnTalent(tid, true, 1 + math.floor(summon.level / 10))
		end

		summon:removeAllMOs()
		game.level.map:updateMap(summon.x, summon.y)

		if core.shader.active(4) then game.level.map:particleEmitter(summon.x, summon.y, 2, "shader_ring_rotating", {rotation=0, radius=2, life=30, img="flamesgeneric"}, {type="firesurge"})
		else game.level.map:particleEmitter(summon.x, summon.y, 1, "demon_teleport")
		end

		-- Learn about demonologits
		if game.level.map.seens(self.x, self.y) then
			game:setAllowedBuild("corrupter_demonologist", true)
		end

		return true
	end,
	on_learn = function(self, t)
		return {
			particle = self:addParticles(Particles.new("circle", 1, {oversize=0.7, a=75, appear=8, speed=8, img="rogroth_aura", radius=self:getTalentRadius(t)})),
		}
	end,
	on_unlearn = function(self, t, p)
		self:removeParticles(p.particle)
	end,
	info = function(self, t)
		return ([[Any nearby allied creature that is not a summon will be bound to your will.
		Each time a creature bound to your will dies it is resurrected as a demonic husk.
		Demonic husks have:
		- slow movement speed
		- more life
		- new demonic talents]]):
		tformat()
	end,
}
