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

---------------------------------------------------------
--                        Orcs                         --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Orc",
	desc = {
		_t"Orcs have a long and sad history. They are seen, and are, as an aggressive race that more than one time managed to imperil all of Maj'Eyal.",
		_t"But one year ago the Scourge from the West came and wiped four of the five Prides. And a hundred years ago King Toknor wiped all traces of orcs from Maj'Eyal.",
		_t"The orc race is dangerously on the brink of destruction. One wrong move is all that is needed.",
		_t"But they are strong and will face whatever is needed to ensure a future of their own!",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			Orc = "allow",
		},
	},
	copy = {
		auto_id = 100,
		faction = "kruk-pride",
		type = "humanoid", subtype="orc",
		default_wilderness = {"playerpop", "orc"},
		starting_zone = "orcs+town-kruk",
		starting_quest = "orcs+kruk-invasion",
		starting_intro = "orc",
		resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=100}, 1),
		resolvers.inscription("INFUSION:_WILD", {cooldown=14, what={physical=true}, dur=4, power=14}, 2),
		resolvers.inscription("INFUSION:_HEALING", {cooldown=12, heal=50}, 3),
	},
--	random_escort_possibilities = { {"trollmire", 2, 3}, {"ruins-kor-pul", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },

	moddable_attachement_spots = "race_orc",

	cosmetic_options = {
		skin = {
			{name=_t"Skin Color 1", file="base_01"},
			{name=_t"Skin Color 2", file="base_02"},
			{name=_t"Skin Color 3", file="base_03"},
			{name=_t"Skin Color 4", file="base_04"},
			{name=_t"Skin Color 5", file="base_05"},
			{name=_t"Demonic Red Skin", file="demonic_01", addons={"ashes-urhrok"}, unlock="cosmetic_red_skin"},
		},
		facial_features = {
			{name=_t"Goggles 1", file="face_goggles_01"},
			{name=_t"Goggles 2", file="face_goggles_02"},
			{name=_t"Goggles 3", file="face_goggles_03"},
			{name=_t"Goggles 4", file="face_goggles_04"},
			{name=_t"Jaws 1", file="face_jaws_01"},
			{name=_t"Jaws 2", file="face_jaws_02"},
			{name=_t"Mechbiter 1", file="face_mechbiter_01"},
			{name=_t"Mechbiter 2", file="face_mechbiter_02"},
			{name=_t"Monocle Left 1", file="face_monocle_left_01"},
			{name=_t"Monocle Left 2", file="face_monocle_left_02"},
			{name=_t"Monocle Right 1", file="face_monocle_right_01"},
			{name=_t"Monocle Right 2", file="face_monocle_right_02"},
		},
		tatoos = {
			{name=_t"Tatoos 1", file="tattoo_01"},
			{name=_t"Tatoos 2", file="tattoo_02"},
			{name=_t"Tatoos 3", file="tattoo_03"},
		},
		horns = {
			{name=_t"Demonic Horns 1", file="horns_01", addons={"ashes-urhrok"}, unlock="cosmetic_doomhorns"},
			{name=_t"Demonic Horns 2", file="horns_02", addons={"ashes-urhrok"}, unlock="cosmetic_doomhorns"},
			{name=_t"Demonic Horns 3", file="horns_03", addons={"ashes-urhrok"}, unlock="cosmetic_doomhorns"},
			{name=_t"Demonic Horns 4", file="horns_04", addons={"ashes-urhrok"}, unlock="cosmetic_doomhorns"},
			{name=_t"Demonic Horns 5", file="horns_05", addons={"ashes-urhrok"}, unlock="cosmetic_doomhorns"},
			{name=_t"Demonic Horns 6", file="horns_06", addons={"ashes-urhrok"}, unlock="cosmetic_doomhorns"},
			{name=_t"Demonic Horns 7", file="horns_07", addons={"ashes-urhrok"}, unlock="cosmetic_doomhorns"},
			{name=_t"Demonic Horns 8", file="horns_08", addons={"ashes-urhrok"}, unlock="cosmetic_doomhorns"},
		},
		special = {
			{name=_t"Bikini / Mankini", birth_only=true, on_actor=function(actor, birther, last)
				if not last then local o = birther.obj_list_by_name[birther.descriptors_by_type.sex == 'Female' and 'Bikini' or 'Mankini'] if not o then print("No bikini/mankini found!") return end actor:getInven(actor.INVEN_BODY)[1] = o:cloneFull() actor.moddable_tile_nude = 1
				else actor:registerOnBirthForceWear(birther.descriptors_by_type.sex == 'Female' and "FUN_BIKINI" or "FUN_MANKINI") end
			end},
		},
	},
}

---------------------------------------------------------
--                        Orcs                         --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Orc",
	desc = {
		_t"Orcs have a long and sad history. They are seen, and are, as an aggressive race that more than one time managed to imperil all of Maj'Eyal.",
		_t"But one year ago the Scourge from the West came and wiped four of the five Prides. And a hundred years ago King Toknor wiped all traces of orcs from Maj'Eyal.",
		_t"The orc race is dangerously on the brink of destruction. One wrong move is all that is needed.",
		_t"But they are strong and will face whatever is needed to ensure a future of their own!",
		_t"They possess the #GOLD#Orcish Fury#WHITE# which allows them to increase all their damage for a few turns.",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +2 Strength, +1 Dexterity, +1 Constitution",
		_t"#LIGHT_BLUE# * -1 Magic, +1 Willpower, +1 Cunning",
		_t"#GOLD#Life per level:#LIGHT_BLUE# 12",
		_t"#GOLD#Experience penalty:#LIGHT_BLUE# 12%",
	},
	inc_stats = { str=2, con=1, dex=1, wil=1, cun=1, mag=-1 },
	talents_types = { ["race/orc"]={true, 0} },
	talents = {
		[ActorTalents.T_ORC_FURY]=1,
	},
	copy = {
		moddable_tile = "orc_#sex#",
		life_rating=12,
	},
	experience = 1.12,
}
