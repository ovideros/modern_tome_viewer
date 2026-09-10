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
local Talents = require "engine.interface.ActorTalents"


newEntity{
	power_source = {arcane=true},
	unique = true,
	type = "potion", subtype="potion",
	name = "Blood of Undeath",
	unided_name = _t"crimson phial",
	level_range = {1, 50},
	display = '!', color=colors.VIOLET, image="object/artifact/potion_blood_of_undeath.png",
	encumber = 0.4,
	rarity = 350,
	desc = _t[[This vial of corrupted blood reeks of death and decay. Yet somehow you feel drawn to it... Is it the tentalizing notion of eternal life? Or power? You can not tell, but the urge to drink it is great.]],
	cost = 1000,
	special = true,

	use_simple = { name = _t"quaff the Blood of Undeath to prepare your body for undeath", use = function(self, who)
		game.logSeen(who, "%s quaffs the %s!", who:getName():capitalize(), self:getName({no_add_name = true, do_color = true}))
		if self:triggerHook{"Artifact:BloodOfUndeath:used", who=who} then
			-- let addons do stuff
		elseif not who:attr("true_undead") then
			who:attr("blood_undeath", 1)
			game.logPlayer(who, "#CRIMSON#You feel the Blood of Undeath rushing through your veins. Your can feel your life wither away a little (-50 maximum life, -120 minimum life).")
			who.max_life = math.max(1, who.max_life - 50)
			who.die_at = who.die_at - 120
		else
			game.logPlayer(who, "#CRIMSON#The Blood of Undeath strengthens your undead body (-60 maximum life, -140 minimum life).")
			who.max_life = math.max(1, who.max_life - 60)
			who.die_at = who.die_at - 140
		end
		return {used=true, id=true, destroy=true}
	end},
}
