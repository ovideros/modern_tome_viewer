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

newBirthDescriptor{
	type = "race",
	name = "MinotaurUndead",
	display_name = _t"Undead",
	locked = function() return profile.mod.allow_build.race_whitehooves end,
	locked_desc = _t"Grave strength, dread will, this flesh cannot stay still. Kings die, masters fall, we will outlast them all.",
	desc = {
		_t"Undead are humanoids (Humans, Elves, Dwarves, ...) that have been brought back to life by the corruption of dark magics.",
		_t"Undead can take many forms, from ghouls to vampires and liches.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			Whitehoof = "allow",
		},
		class =
		{
			Wilder = "disallow",
		},
	},
	talents = {
		[ActorTalents.T_UNDEAD_ID]=1,
	},
	copy = {
		type = "undead",
		undead = 1, true_undead = 1,
		forbid_nature = 1,
		inscription_forbids = { ["inscriptions/infusions"] = true, },
		resolvers.inscription("RUNE:_SHIELDING", {cooldown=14, dur=5, power=130}, 1),
		resolvers.inscription("RUNE:_SHATTER_AFFLICTIONS", {cooldown=18, shield=50}, 2),
		resolvers.inscription("RUNE:_BLINK", {cooldown=18, power=10, range=4,}, 3),
	},

	cosmetic_options = {
		skin = {
			{name=_t"Skin Color 1", file="base_01"},
			{name=_t"Skin Color 2", file="base_02"},
			{name=_t"Skin Color 3", file="base_03"},
			{name=_t"Skin Color 4", file="base_04"},
			{name=_t"Skin Color 5", file="base_05"},
			{name=_t"Skin Color 6", file="base_06"},
			{name=_t"Skin Color 7", file="base_07"},
			{name=_t"Demonic Red Skin", file="demonic_01", addons={"ashes-urhrok"}, unlock="cosmetic_red_skin"},
		},
		facial_features = {
			{name=_t"Beard 1", file="beard_01"},
			{name=_t"Beard 2", file="beard_02"},
			{name=_t"Redhead Beard", file="beard_redhead_01", unlock="cosmetic_race_human_redhead"},
			{name=_t"Hair 1", file="hair_01"},
			{name=_t"Hair 2", file="hair_02"},
			{name=_t"Hair 3", file="hair_03"},
			{name=_t"Hair 4", file="hair_04"},
			{name=_t"Redhead Hair 1", file="hair_redhead_01", unlock="cosmetic_race_human_redhead"},
			{name=_t"Redhead Hair 2", file="hair_redhead_02", unlock="cosmetic_race_human_redhead"},
		},
		horns = {
			{name=_t"Horns 1", file="base_horns_01"},
			{name=_t"Horns 2", file="base_horns_02"},
			{name=_t"Horns 3", file="base_horns_03"},
			{name=_t"Horns 4", file="base_horns_04"},
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
--                 Unread Minotaurs                    --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Whitehoof",
	locked = function() return profile.mod.allow_build.race_whitehooves end,
	locked_desc = _t"Grave strength, dread will, this flesh cannot stay still. Kings die, masters fall, we will outlast them all.",
	desc = {
		_t"A clan of minotaurs turned to necromancy when faced with imminent destruction.",
		_t"Whitehooves are resilient and magic imbued undead, hardened by their trials and made stronger by their undeath.",
		_t"They now seek to help their orc allies, in hope they will help them back.",
		_t"They have access to #GOLD#special talents#WHITE# and a wide range of undead abilities:",
		_t"- silence resistance",
		_t"- bleeding immunity",
		_t"- fear immunity",
		_t"- no need to breathe",
		_t"- special whitehoof talents: dead hide, lifeless rush, essence drain",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +3 Strength, -1 Dexterity, +2 Constitution",
		_t"#LIGHT_BLUE# * +2 Magic, -3 Willpower, +1 Cunning",
		_t"#GOLD#Life per level:#LIGHT_BLUE# 14",
		_t"#GOLD#Experience penalty:#LIGHT_BLUE# 15%",
	},
	inc_stats = { str=3, con=2, dex=-1, mag=2, wil=-3, cun=1 },
	talents_types = { ["race/whitehooves"]={true, 0} },
	talents = {
		[ActorTalents.T_WHITEHOOVES]=1,
	},
	copy = {
		auto_id = 100,
		faction = "free-whitehooves",
		subtype="minotaur",
		default_wilderness = {"playerpop", "yeti"},
		starting_zone = "orcs+vaporous-emporium",
		starting_quest = "orcs+start-orc",
		starting_intro = "orc-whitehooves",
		moddable_tile = "whitehoof",
		moddable_tile_base = "base_01.png",
		moddable_tile_nude = 1,
		no_breath = 1,
		poison_immune = 1,
		cut_immune = 1,
		silence_immune = 0.5,
		life_rating=14,
	},
	moddable_attachement_spots = "race_whitehoof", moddable_attachement_spots_sexless = true,
	experience = 1.15,
}
