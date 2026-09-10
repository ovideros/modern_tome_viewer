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

load("/data-orcs/general/objects/objects.lua")

newEntity{ base = "BASE_LORE",
	define_as = "LORE_KRUK_HISTORY",
	unique=true, no_unique_lore=true, not_in_stores=false,
	name = "The Shunned Kruk", lore="kruk-history-1",
	desc = _t[[A history lesson.]],
	rarity = false,
	encumberance = 0,
	cost = 80,
}

newEntity{ base="BASE_LEATHER_CAP", define_as = "YETI_MIND_CONTROLLER",
	power_source = {steam=true},
	name = "Yeti Mind Controller", display = '*', color=colors.GOLD, unique=true, image = "object/artifact/yeti_mind_controller.png",
	desc = _t[[This device seems to be designed to 'hack' the mind of a wild yeti to make it able to be used as a weapon of war.]],
	metallic = true,
	cost = 160,
	rarity = false,
	material_level = 1,

	wielder = {
		combat_mindpower = 9,
		combat_mindcrit = 9,
		combat_mentalresist = 10,
		combat_armor = 3,
		fatigue = 3,
	},

	max_power = 8,
	use_power = { power=1, name=_t"hack the mind of a weakened yeti", no_npc_use = true, use = function(self, who, inven, item)
		local tg = {type="hit", nowarning=true, range=1}
		local tx, ty, target = who:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = who:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, engine.Map.ACTOR)
		if target == who then target = nil end
		if not target then return nil end
		if target.unique or target.type ~= "giant" or target.subtype ~= "yeti" or target.rank > 3 or not target.wild_yeti then
			game.logPlayer(who, "#CRIMSON#Impossible to to control.")
			game.bignews:saySimple(180, "#CRIMSON#Impossible to to control.")
			return nil
		end
		if target.life / target.max_life > 0.3 then
			game.logPlayer(who, "#CRIMSON#The yeti is not hurt enough to control.")
			game.bignews:saySimple(180, "#CRIMSON#The yeti is not hurt enough to control.")
			return nil
		end

		game.logPlayer(who, "#AQUAMARINE#You overtake the yeti's mind and order it to report to Kruk Pride.")
		game.bignews:saySimple(180, "#AQUAMARINE#You overtake the yeti's mind and order it to report to Kruk Pride.")
		target:disappear()
		who:hasQuest("orcs+yeti-abduction"):one_more(who)
		return {used=true, id=true}
	end},

	on_pickup = function(self, who)
		if not who.player then return end
		self.on_pickup = nil
		who:grantQuest("orcs+yeti-abduction")
	end,
}
