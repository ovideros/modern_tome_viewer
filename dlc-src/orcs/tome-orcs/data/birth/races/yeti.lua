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

-- getBirthDescriptor("race", "Giant").descriptor_choices.subrace["Kruk Yeti"] = "allow"
newBirthDescriptor{
	type = "race",
	name = "Yeti",
	locked = function() return profile.mod.allow_build.race_yeti end,
	locked_desc = _t"Infuse the mind, sacrifice the body but the Pride remains.",
	desc = {
		_t[[Yetis are a towering mass of muscle.]],
	},
	descriptor_choices =
	{
		subrace =
		{
			['Kruk Yeti'] = "allow",
			__ALL__ = "disallow",
		},
	},
	copy = {
		type = "giant", subtype="yeti",
		resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=100}, 1),
		resolvers.inscription("INFUSION:_WILD", {cooldown=14, what={physical=true}, dur=4, power=14}, 2),
		resolvers.inscription("INFUSION:_HEALING", {cooldown=12, heal=50}, 3),
	},

	moddable_attachement_spots = "race_yeti", moddable_attachement_spots_sexless=true,

	default_cosmetics = { {"hairs", "Hair 1"} },
	cosmetic_options = {
		skin = {
			{name=_t"Skin Color 1", file="base_01"},
			{name=_t"Skin Color 2", file="base_02"},
			{name=_t"Skin Color 3", file="base_03"},
			{name=_t"Skin Color 4", file="base_04"},
			{name=_t"Skin Color 5", file="base_05"},
			{name=_t"Skin Color 6", file="base_06"},
			{name=_t"Skin Color 7", file="base_07"},
			{name=_t"Skin Color 8", file="base_08"},
			{name=_t"Skin Color 9", file="base_09"},
			{name=_t"Demonic Red Skin", file="demonic_01", addons={"ashes-urhrok"}, unlock="cosmetic_red_skin"},
		},
		hairs = {
			{name=_t"Hair 1", file="hair_01"},
			{name=_t"Hair 2", file="hair_02"},
		},
		facial_features = {
			{name=_t"Beard 1", file="beard_01"},
			{name=_t"Beard 2", file="beard_02"},
			{name=_t"Beard 3", file="beard_03"},
			{name=_t"Eyebrows", file="face_eyebrows_01"},
			{name=_t"Fangs", file="face_fangs_01"},
			{name=_t"Mustache", file="face_mustache_01"},
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
--                       Yetis                         --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Kruk Yeti",
	locked = function() return profile.mod.allow_build.race_yeti end,
	locked_desc = _t"Infuse the mind, sacrifice the body but the Pride remains.",
	desc = {
		_t"Yetis are a towering mass of muscle. While normal yetis are non-sentient beasts this kind is special.",
		_t"A few orcs of the Kruk pride have mastered techno-psionics, allowing them to literally hijack a yeti's mind and transfer their own mind inside.",
		_t"Doing so drains their old knowledge and they need to start afresh, gaining considerable strength in the process; for the good of the Prides.",
		_t"They possess the #GOLD#Algid Rage#WHITE# talent which allows them to encase their foes in blocks of ice.",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +5 Strength, -3 Dexterity, +4 Constitution",
		_t"#LIGHT_BLUE# * +0 Magic, +1 Willpower, -1 Cunning",
		_t"#GOLD#Life per level:#LIGHT_BLUE# 13",
		_t"#GOLD#Experience penalty:#LIGHT_BLUE# 12%",
	},
	inc_stats = { str=5, con=4, dex=-3, wil=1, cun=-1 },
	talents_types = { ["race/yeti"]={true, 0} },
	talents = {
		[ActorTalents.T_ALGID_RAGE]=1,
	},
	copy = {
		auto_id = 100,
		faction = "kruk-pride",
		subtype="yeti",
		default_wilderness = {"playerpop", "yeti"},
		starting_zone = "orcs+vaporous-emporium",
		starting_quest = "orcs+start-orc",
		starting_intro = "orc-yeti",
		moddable_tile = "yeti",
		moddable_tile_head_underwear = "fur_head.png",
		moddable_tile_higher_underwear = "fur_body.png",
		moddable_tile_lower_underwear = "fur_legs.png",
		life_rating=13,
	},
	experience = 1.12,
}
