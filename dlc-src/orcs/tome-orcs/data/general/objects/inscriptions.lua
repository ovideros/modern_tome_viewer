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

newEntity{
	define_as = "BASE_IMPLANT",
	type = "scroll", subtype="implant", add_name = " (#INSCRIPTION#)",
	unided_name = _t"implant", id_by_type = true,
	display = "?", color=colors.LIGHT_BLUE, image="object/rune_red.png",
	encumber = 0.1,
	use_sound = "actions/read",
	use_no_blind = true,
	use_no_silence = true,
	desc = _t[[Steamtech implants can be grafted on the users skin..]],
	egos = "/data/general/objects/egos/infusions.lua", egos_chance = resolvers.mbonus(30, 5),
	material_level_min_only = true,

	power_source = {steam=true},
	use_simple = { name=_t"implant on your skin.", use = function(self, who, inven, item)
		if who:setInscription(nil, self.inscription_talent, self.inscription_data, true, true, {obj=self, inven=inven, item=item}) then
			return {used=true, id=true, destroy=true}
		end
	end}
}


-----------------------------------------------------------
-- Implants
-----------------------------------------------------------
newEntity{ base = "BASE_IMPLANT",
	name = "steam generator implant",
	level_range = {1, 50}, image = "object/steam_generator.png",
	rarity = 14,
	cost = 10,
	material_level = 1,

	inscription_kind = "steamgenerator",
	inscription_data = {
		newmode = true,
		cooldown = resolvers.rngrange(20, 32),
		power = resolvers.mbonus_level(130, 40, function(e, v) return v * 0.5, v * 0.1 end),
		use_stat_mod = 0.06,
	},
	inscription_talent = "IMPLANT:_STEAM_GENERATOR",
}

newEntity{ base = "BASE_IMPLANT",
	name = "medical injector implant",
	level_range = {1, 50}, image = "object/medical_injector.png",
	rarity = 14,
	cost = 10,
	material_level = 1,

	inscription_kind = "medicalinjector",
	inscription_data = {
		cooldown = 1,
		cooldown_mod = resolvers.rngrange(50, 100),
		power = resolvers.mbonus_level(120, 80, function(e, v) return v * 0.5 end),
		use_stat_mod = 0.7,
	},
	inscription_talent = "IMPLANT:_MEDICAL_INJECTOR",
}
