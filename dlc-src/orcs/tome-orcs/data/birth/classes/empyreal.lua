-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

-- getBirthDescriptor("class", "Celestial").descriptor_choices.subclass["Empyreal"] = "allow"

newBirthDescriptor{
	type = "subclass",
	name = "Empyreal",
	desc = {
		_t"Their most important stats are: Magic and Constitution",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +3 Constitution",
		_t"#LIGHT_BLUE# * +6 Magic, +0 Willpower, +0 Cunning",
		_t"#GOLD#Life per level:#LIGHT_BLUE# +0",
	},
	power_source = {arcane=true},
	stats = { mag=6, con=3, },
	talents_types = {
		["celestial/sol"]={true, 0.3},
		["celestial/cosmic"]={true, 0.3},
		["celestial/energies"]={true, 0.3},
		["celestial/reflection"]={true, 0.3},
		["celestial/twilight"]={false, 0},
		--["celestial/star-fury"]={false, 0.1}, disabled unless mirror wall reflects beams (and has the proper targeting stuff)
		["celestial/circles"]={false, 0.2},
		["celestial/void"]={false, 0.2},
		
		["celestial/light"]={true, 0},
		["celestial/chants"]={true, 0.2},
		["celestial/hymns"]={false, 0.2},
		["cunning/survival"]={false, 0},
		
	},
	talents = {
		[ActorTalents.T_SOLAR_ORB] = 1,
		[ActorTalents.T_LUNAR_ORB] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", ignore_material_restriction=true, autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", ignore_material_restriction=true, autoreq=true, ego_chance=-1000}
		},
	},
}

-- Allow it in Maj'Eyal campaign
-- getBirthDescriptor("world", "Maj'Eyal").descriptor_choices.class.Empyreal = "allow"
