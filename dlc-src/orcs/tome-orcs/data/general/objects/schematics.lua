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
local Talents = require "engine.interface.ActorTalents"

newEntity{
	define_as = "BASE_SCHEMATIC",
	type = "scroll", subtype="schematic",
	unided_name = _t"schematic", id_by_type = true,
	display = "?", color=colors.GREY, image="object/schematic.png",
	encumber = 0.1,
	stacking = true,
	no_transmo = true,
	use_sound = "actions/read",
	desc = _t[[Schematics are used by tinkers to learn how to build new constructs.]],
	material_level_min_only = true,
	power_source = {steamtech=true},
	require = { talent = { Talents.T_CREATE_TINKER }, }, -- This prevents wielding stuff, since we cant wear schematics this is only for show & clarity
	special_desc = function(self)
		local str = _t"#LIGHT_GREEN#[can be learnt]#LAST#"
		if game.party:knowTinker(self.tinker_id) then str = _t"#LIGHT_BLUE#[already known tinker]#LAST#" end
		return str
	end,
	use_simple = { name=_t"learn how to build this tinker", use = function(self, who, inven, item)
		if not who.player then return end
		if not who:knowTalent(who.T_CREATE_TINKER) then
			game.log("You can not learn schematics without knowing how to craft items.")
			return {used=false}
		end
		if game.party:knowTinker(self.tinker_id) then
			game.log("You already know this schematic.")
			return {used=false}
		end
		game.party:learnTinker(self.tinker_id, true)
		return {used=true, id=true, destroy=true}
	end},
	on_prepickup = function(self, who, id)
		if not who.player then return end
		if not who:knowTalent(who.T_CREATE_TINKER) then return end
		if not game.party:knowTinker(self.tinker_id) then
			game.party:learnTinker(self.tinker_id, true)
			game.level.map:removeObject(who.x, who.y, id)
			return true
		end
	end,
}

-- local list = {}
local PartyTinker = require "mod.class.interface.PartyTinker"
for tid, t in pairs(PartyTinker.__tinkers_ings) do if t.random_schematic then
	newEntity{ base = "BASE_SCHEMATIC", define_as = "SCHEMATIC_RANDOM_"..tid,
		name = ("schematic: %s"):tformat(t.name),
		level_range = {t.random_schematic.level, 50},
		unique = t.unique,
		rarity = t.random_schematic.rarity,
		cost = t.random_schematic.cost,
		material_level = 1,

		tinker_id = tid,
	}

	-- local cat = t.base_category
	-- if cat == "explosive" then cat = "explosives" end
	-- local level = -1
	-- if t.talents["T_"..cat:upper()] then level = t.talents["T_"..cat:upper()] end
	-- list[cat] = list[cat] or {}
	-- list[cat][level] = list[cat][level] or {}
	-- table.insert(list[cat][level], t.name)
end end
-- table.print(list)
-- os.crash()