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

getBirthDescriptor("race", "Giant").descriptor_choices.subrace["Krog"] = "allow"

newBirthDescriptor
{
	type = "subrace",
	name = "Krog",
	locked = function() return profile.mod.allow_build.race_krog end,
	locked_desc = _t[[Once an abomination, now a weapon.]],
	desc = {
		_t"Krogs were formerly Ogres, that have been radically changed. Stripped of the runes from their bodies, the Ziguranth have managed to prevent the Krog from dying by injecting them with a concoction of natural infusions and drake blood. The Krog are entirely devoted to the anti-magic cause and seemingly know of nothing else in their lives.",
		_t"They possess the #GOLD#Wrath of the Wilds#WHITE# talent which allows them to stun/daze their foes.",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +3 Strength, -1 Dexterity, +2 Constitution",
		_t"#LIGHT_BLUE# * -2 Magic, +2 Willpower, +0 Cunning",
		_t"#GOLD#Life per level:#LIGHT_BLUE# 13",  -- We should really rename this to life rating since life per level is a lie
		_t"#GOLD#Experience penalty:#LIGHT_BLUE# 15%",
	},
	moddable_attachement_spots = "race_ogre",
	inc_stats = { str=3, con=2, wil=2, mag=-2, dex=-1 },
	talents_types = {
		["race/krog"]={true, 0},
		["wild-gift/antimagic"]={true, 0.2},
	},
	talents = { [ActorTalents.T_KROG_WRATH]=1 },
	copy = {
		subtype = "krog",
		moddable_tile = "ogre_#sex#",
		moddable_tile_base = "krog_base_01.png",
		moddable_tile_ornament = {male="krog_deco_beard_default", female="krog_deco_braids_default"},
		random_name_def = "thalore_#sex#", random_name_max_syllables = 4,
		default_wilderness = {24, 14}, -- ohh evil hardcoding :/
		starting_zone = "ruins-kor-pul",
		starting_quest = "start-allied",
		faction = "zigur",
		starting_intro = "krog",
		life_rating = 13,
		size_category = 4,
		forbid_arcane = 1,
		resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=100}, 1),
		resolvers.inscription("INFUSION:_WILD", {cooldown=14, what={physical=true}, dur=4, power=14}, 2),
		resolvers.inscription("INFUSION:_HEALING", {cooldown=12, heal=50}, 3),
		resolvers.inventory{ id=true, {defined="ORB_SCRYING"} },
	},
	experience = 1.15,
	random_escort_possibilities = { {"tier1.1", 1, 2}, {"tier1.2", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },

	default_cosmetics = { {"hairs", "Dark Hair 1"}, {"facial_features", "Beard 5", {sex="Male"}} },
	cosmetic_options = {
		skin = {
			{name=_t"Skin Color 1", file="base_krog_01"},
			{name=_t"Skin Color 2", file="base_krog_02"},
			{name=_t"Skin Color 3", file="base_krog_03"},
			{name=_t"Skin Color 4", file="base_krog_04"},
			{name=_t"Skin Color 5", file="base_krog_05"},
		},
		hairs = {
			{name=_t"Dark Hair 1", file="hair_krog_01"},
			{name=_t"Dark Hair 2", file="hair_krog_02"},
			{name=_t"Dark Hair 3", file="hair_krog_03", only_for={sex="Female"}},
			{name=_t"Dark Hair 4", file="hair_krog_04", only_for={sex="Female"}},
			{name=_t"Dark Hair 5", file="hair_krog_05", only_for={sex="Female"}},
			{name=_t"Dark Hair 6", file="hair_krog_06", only_for={sex="Female"}},
			{name=_t"Dark Hair 7", file="hair_krog_07", only_for={sex="Female"}},
			{name=_t"Dark Hair 8", file="hair_krog_08", only_for={sex="Female"}},
			{name=_t"Blond Hair 1", file="hair_krog_light_01"},
			{name=_t"Blond Hair 2", file="hair_krog_light_02"},
			{name=_t"Blond Hair 3", file="hair_krog_light_03", only_for={sex="Female"}},
			{name=_t"Blond Hair 4", file="hair_krog_light_04", only_for={sex="Female"}},
			{name=_t"Blond Hair 5", file="hair_krog_light_05", only_for={sex="Female"}},
			{name=_t"Blond Hair 6", file="hair_krog_light_06", only_for={sex="Female"}},
			{name=_t"Blond Hair 7", file="hair_krog_light_07", only_for={sex="Female"}},
			{name=_t"Blond Hair 8", file="hair_krog_light_08", only_for={sex="Female"}},
			{name=_t"Redhead Hair 1", file="hair_krog_redhead_01", unlock="cosmetic_race_human_redhead"},
			{name=_t"Redhead Hair 2", file="hair_krog_redhead_02", unlock="cosmetic_race_human_redhead"},
			{name=_t"Redhead Hair 3", file="hair_krog_redhead_03", only_for={sex="Female"}, unlock="cosmetic_race_human_redhead"},
			{name=_t"Redhead Hair 4", file="hair_krog_redhead_04", only_for={sex="Female"}, unlock="cosmetic_race_human_redhead"},
			{name=_t"Redhead Hair 5", file="hair_krog_redhead_05", only_for={sex="Female"}, unlock="cosmetic_race_human_redhead"},
			{name=_t"Redhead Hair 6", file="hair_krog_redhead_06", only_for={sex="Female"}, unlock="cosmetic_race_human_redhead"},
			{name=_t"Redhead Hair 7", file="hair_krog_redhead_07", only_for={sex="Female"}, unlock="cosmetic_race_human_redhead"},
			{name=_t"Redhead Hair 8", file="hair_krog_redhead_08", only_for={sex="Female"}, unlock="cosmetic_race_human_redhead"},
		},
		facial_features = {
			{name=_t"Facial Warpaint", file="face_warpaint"},
			{name=_t"Dark Beard 1", file="beard_krog_01", only_for={sex="Male"}},
			{name=_t"Dark Beard 2", file="beard_krog_02", only_for={sex="Male"}},
			{name=_t"Dark Beard 3", file="beard_krog_03", only_for={sex="Male"}},
			{name=_t"Dark Beard 4", file="beard_krog_04", only_for={sex="Male"}},
			{name=_t"Dark Beard 5", file="beard_krog_05", only_for={sex="Male"}},
			{name=_t"Blond Beard 1", file="beard_krog_light_01", only_for={sex="Male"}},
			{name=_t"Blond Beard 2", file="beard_krog_light_02", only_for={sex="Male"}},
			{name=_t"Blond Beard 3", file="beard_krog_light_03", only_for={sex="Male"}},
			{name=_t"Blond Beard 4", file="beard_krog_light_04", only_for={sex="Male"}},
			{name=_t"Blond Beard 5", file="beard_krog_light_05", only_for={sex="Male"}},
			{name=_t"Readhead Beard 1", file="beard_krog_redhead_01", only_for={sex="Male"}, unlock="cosmetic_race_human_redhead"},
			{name=_t"Readhead Beard 2", file="beard_krog_redhead_02", only_for={sex="Male"}, unlock="cosmetic_race_human_redhead"},
			{name=_t"Readhead Beard 3", file="beard_krog_redhead_03", only_for={sex="Male"}, unlock="cosmetic_race_human_redhead"},
			{name=_t"Readhead Beard 4", file="beard_krog_redhead_04", only_for={sex="Male"}, unlock="cosmetic_race_human_redhead"},
			{name=_t"Readhead Beard 5", file="beard_krog_redhead_05", only_for={sex="Male"}, unlock="cosmetic_race_human_redhead"},
		},
		tatoos = {
			{name=_t"Tatoo 1", file="tattoo_01"},
			{name=_t"Tatoo 2", file="krog_infusion_tattoos"},
		},
		special = {
			{name=_t"Bikini / Mankini", birth_only=true, on_actor=function(actor, birther, last)
				if not last then local o = birther.obj_list_by_name[birther.descriptors_by_type.sex == 'Female' and 'Bikini' or 'Mankini'] if not o then print("No bikini/mankini found!") return end actor:getInven(actor.INVEN_BODY)[1] = o:cloneFull() actor.moddable_tile_nude = 1
				else actor:registerOnBirthForceWear(birther.descriptors_by_type.sex == 'Female' and "FUN_BIKINI" or "FUN_MANKINI") end
			end},
		},
	},
}
