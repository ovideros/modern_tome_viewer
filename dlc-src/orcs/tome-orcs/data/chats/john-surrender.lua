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

local Stats = require "engine.interface.ActorStats"

local function destroy(npc, player)
	local ring, item, inven_id = player:findInAllInventoriesBy("define_as", "RING_LOST_LOVE")
	if not ring then return end

	local was_worn = ring.wielded
	if was_worn then player:onTakeoff(ring, inven_id, true) end
	ring.plot = nil
	ring.wielder.resists.all = 10
	ring.wielder.inc_damage = {all = 10}
	ring.wielder.inc_stats[Stats.STAT_STR] = 6
	ring.wielder.inc_stats[Stats.STAT_CUN] = 6
	ring.wielder.inc_stats[Stats.STAT_DEX] = 6
	ring.wielder.esp = { humanoid = 1, giant = 1 }
	ring.wielder.esp_range = 10
	if was_worn then player:onWear(ring, inven_id, true) end

	npc:die(player)

	if player.descriptor and player.descriptor.subclass == "Sun Paladin" then
		game:setAllowedBuild("paladin_fallen", true)
	end
end

local function bind(npc, player)
	local ring, item, inven_id = player:findInAllInventoriesBy("define_as", "RING_LOST_LOVE")
	if not ring then return end
	ring.plot = nil

	local was_worn = ring.wielded
	if was_worn then player:onTakeoff(ring, inven_id, true) end

	local john = game.zone:makeEntityByName(game.level, "actor", "JOHN_SUMMON", true)
	ring.john_base = john

	ring.power = 100
	ring.max_power = 100
	ring.power_regen = 1
	ring.use_power = { name = "summon Crimson Paladin John", power = 80, use = function(self, who)
		if not who:canBe("summon") then game.logPlayer(who, "You cannot summon; you are suppressed!") return end

		for i = 1, 1 do
			-- Find space
			local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
			if not x then break end

			local john = self.john_base:cloneFull()
			john.make_escort = nil
			john.silent_levelup = true
			john.faction = who.faction
			john.ai = "summoned"
			john.ai_real = "tactical"
			john.summoner = who
			john.summon_time = 12
			john.exp_worth = 0

			local setupSummon = getfenv(who:getTalentFromId(who.T_SPIDER).action).setupSummon
			setupSummon(who, john, x, y)
			game:playSoundNear(who, "talents/slime")

			john:doEmote(rng.table{
				_t"HATE!", _t"PAIN!", _t"REGRET!", _t"My love...", _t"I feel so lost.", _t"Please let me die!", _t"RAAAAARGGGG!",
				_t"Someday you will pay!", _t"DEATH!", _t"*Sobs*"
			}, 120)
		end
		return {id=true, used=true}
	end }

	if was_worn then player:onWear(ring, inven_id, true) end
	game:addEntity(ring)

	world:gainAchievement("ORCS_JOHN_CAPTURED", player)

	npc:die(player)
end

newChat{ id="welcome",
	text = _t[[#LIGHT_GREEN#*The Crimson Templar looks exhausted, nearly dead. You feel the ring attuning to him and suddenly you understand you could absorb his essence to power the ring.*#WHITE#
Go on kill me @playername@! My life is destroyed, my friends are dead, my dear Aeryn is dead. All dead by your murderous hands! Finish me, let me have some #{italic}#rest#{normal}#.]],
	answers = {
		{_t"#LIGHT_GREEN#[destroy him to power the ring]#WHITE# So be it!", action=destroy, jump="destroy"},
		{_t"#LIGHT_GREEN#[bind him to the ring]#WHITE# No, you are more useful alive and broken to me!", action=bind, jump="bind"},
	}
}

newChat{ id="destroy",
	text = _t[[#LIGHT_GREEN#*The malevolent energies around you condensate into the ring, absorbing the last remains of John.
The ring is now much more powerful.*#WHITE#
Aeryn... my love...]],
	answers = {
		{_t"#LIGHT_GREEN#[done]#WHITE#"},
	}
}

newChat{ id="bind",
	text = _t[[#LIGHT_GREEN#*The malevolent energies around you condense into the ring, binding John to it forever.
The ring is now able to summon him for a few turns at will.*#WHITE#
#{bold}#I HATE YOU!#{normal}#]],
	answers = {
		{_t"#LIGHT_GREEN#[done]#WHITE#"},
	}
}

return "welcome"
