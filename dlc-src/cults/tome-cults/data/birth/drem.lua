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

getBirthDescriptor("race", "Dwarf").descriptor_choices.subrace["Drem"] = "allow"

newBirthDescriptor
{
	type = "subrace",
	name = "Drem",
	locked = function() return profile.mod.allow_build.race_drem end,
	locked_desc = _t[[Faceless, but not mindless.]],
	desc = {
		_t"Drem are mindless mutants who live deep in the earth. It is only recently that thinking Drem have appeared among them. They still remain deep below Eyal's surface, believing that they would not be welcomed among the surface races.",
		_t"They possess the #GOLD#Frenzy#WHITE# talent which allows them to ignore cooldowns once in a while.",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +3 Strength, +1 Dexterity, +1 Constitution",
		_t"#LIGHT_BLUE# * +2 Magic, -1 Willpower, +0 Cunning",
		_t"#GOLD#Life per level:#LIGHT_BLUE# 12",
		_t"#GOLD#Experience penalty:#LIGHT_BLUE# 12%",
	},
	inc_stats = { str=3, con=1, wil=-1, mag=2, dex=1 },
	talents_types = { ["race/drem"]={true, 0} },
	talents = { [ActorTalents.T_DREM_FRENZY]=1 },
	copy = {
		moddable_tile = "dwarf_#sex#",
		moddable_tile_base = "base_drem_01.png",
		random_name_def = "dwarf_#sex#", random_name_max_syllables = 4,
		_forbid_start_override = true,
		default_wilderness = {20, 17},
		starting_zone = "cults+town-kroshkkur",
		starting_quest = "cults+start-cults",
		cults_race_start_quest = "start-allied",
		faction = "sanctuary-of-horrors",
		starting_intro = "cults",
		life_rating = 12,
		resolvers.inscription("RUNE:_SHIELDING", {cooldown=14, dur=5, power=100}, 1),
		resolvers.inscription("RUNE:_SHATTER_AFFLICTIONS", {cooldown=18, shield=50}, 2),
		resolvers.inscription("RUNE:_BLINK", {cooldown=16, range=3, dur=3, power=15}, 3),
	},
	experience = 1.12,
	random_escort_possibilities = { {"tier1.1", 1, 2}, {"tier1.2", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },
	default_cosmetics = { {"hairs", "Dark Hair 1"}, {"facial_features", "Beard 5", {sex="Male"}} },
	cosmetic_options = {
		skin = {
			{name=_t"Skin Color 1", file="base_drem_01"},
			{name=_t"Skin Color 2", file="base_drem_02"},
			{name=_t"Skin Color 3", file="base_drem_03"},
			{name=_t"Skin Color 4", file="base_drem_04"},
			{name=_t"Skin Color 5", file="base_drem_05"},
			{name=_t"Skin Color 6", file="base_drem_06"},
			{name=_t"Skin Color 7", file="base_drem_07"},
			{name=_t"Skin Color 8", file="base_drem_08"},
			{name=_t"Skin Color 9", file="base_drem_09"},
			{name=_t"Demonic Red Skin", file="demonic_drem_01", addons={"ashes-urhrok"}, unlock="cosmetic_red_skin"},
		},
		hairs = {
			{name=_t"Dark Hair 1", file="hair_drem_01"},
			{name=_t"Redhead Hair 1", file="hair_drem_redhead_01", unlock="cosmetic_race_human_redhead"},
		},
		facial_features = {
			{name=_t"Beard 1", file="drem_beard_01", only_for={sex="Male"}},
			{name=_t"Beard 2", file="drem_beard_02", only_for={sex="Male"}},
			{name=_t"Redhead Beard 1", file="drem_beard_readhead_01", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
			{name=_t"Redhead Beard 2", file="drem_redhead_beard_02", unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
			{name=_t"Demonic Beard", file="drem_demonic_beard", addons={"ashes-urhrok"}, only_for={sex="Male"}},
			{name=_t"Demonic Redhead Beard", file="drem_demonic_redhead_beard", addons={"ashes-urhrok"}, unlock="cosmetic_race_human_redhead", only_for={sex="Male"}},
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
