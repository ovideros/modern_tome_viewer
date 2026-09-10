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

newEntity{ define_as = "TRAP_RITCH",
	type = "natural", subtype="sand", id_by_type=true, unided_name = _t"trap",
	display = '^',
	triggered = function(self, x, y, who)
		self:project({type="hit",x=x,y=y}, x, y, self.damtype, self.dam or 10, self.particles and {type=self.particles})
		return true
	end,
}

newEntity{ base = "TRAP_RITCH", define_as = "RITCH_SAND_PIT",
	name = "sand pit", auto_id = true, image = "trap/sandpit_trap.png",
	detect_power = resolvers.clscale(6,50,8),
	disarm_power = resolvers.clscale(16,50,8),
	rarity = 3, level_range = {1, 50},
	color=colors.UMBER,
	pressure_trap = true,
	message = _t"@Target@ slides into a sand pit!",
	triggered = function(self, x, y, who)
		if who:canBe("stun") then
			if rng.percent(50) then
				who:setEffect(who.EFF_PINNED, 4, {apply_power=self.disarm_power + 5})
			else
				who:setEffect(who.EFF_DAZED, 3, {apply_power=self.disarm_power + 5})
			end
		else
			game.logSeen(who, "%s resists!", who:getName():capitalize())
		end
		return true
	end,
	energy = {value=0},
	act = function(self)
		self:useEnergy()
		if self.temporary then
			self.temporary = self.temporary - 1
			if self.temporary <= 0 then
				if game.level.map(self.x, self.y, engine.Map.TRAP) == self then
					game.level.map:remove(self.x, self.y, engine.Map.TRAP)
					game.level:removeEntity(self)
				end
			end
		end
	end
}