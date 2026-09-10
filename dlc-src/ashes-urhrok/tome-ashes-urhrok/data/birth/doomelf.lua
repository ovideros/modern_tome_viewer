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

getBirthDescriptor("race", "Elf").descriptor_choices.subrace["Doomelf"] = "allow"

newBirthDescriptor
{
	type = "subrace",
	name = "Doomelf",
	locked = function() return profile.mod.allow_build.race_doomelf end,
	locked_desc = _t[[The demons of Mal'Rok would never bless you!
Three could tell them of the horrors elves wrought.
One rages and torments in deep oceans blue,
one fights for the third with the cultists she taught.
Silence these beings, maintain your deception,
and then you may witness a new elf's conception...]],
	desc = {
		_t"Doomelves are not a real race, they are Shaloren that have been taken by demons and transformed into harbingers of doom.",
		_t"They enjoy unleashing torments and suffering on their victims.",
		_t"They possess the #GOLD#Haste of the Doomed#WHITE# talent which allows them to phase away once in a while.",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * -2 Strength, +1 Dexterity, +1 Constitution",
		_t"#LIGHT_BLUE# * +3 Magic, +2 Willpower, +0 Cunning",
		_t"#GOLD#Life per level:#LIGHT_BLUE# 9",
		_t"#GOLD#Experience penalty:#LIGHT_BLUE# 12%",
	},
	inc_stats = { str=-2, mag=3, wil=2, cun=0, dex=1, con=1 },
	talents_types = { ["race/doomelf"]={true, 0} },
	talents = { [ActorTalents.T_HASTE_OF_THE_DOOMED]=1 },

	default_cosmetics = { {"hairs", "Blond Hair 3"}, {"horns", "Demonic Horns 1"} },
	copy = {
		moddable_tile = "elf_#sex#",
		moddable_tile_base = "demonic_01.png",
		random_name_def = "shalore_#sex#", random_name_max_syllables = 4,
		_forbid_start_override = true,
		default_wilderness = {"zone-pop", "angolwen-portal"},
		starting_zone = "ashes-urhrok+searing-halls",
		starting_quest = "ashes-urhrok+start-ashes",
		ashes_urhrok_race_start_quest = "start-shaloren",
		faction = "shalore",
		starting_intro = "ashes-urhrok",
		life_rating = 9,
		resolvers.inscription("RUNE:_SHIELDING", {cooldown=14, dur=5, power=100}, 1),
		resolvers.inscription("RUNE:_SHATTER_AFFLICTIONS", {cooldown=18, shield=50}, 2),
		resolvers.inscription("RUNE:_BLINK", {cooldown=16, range=3, dur=3, power=15}, 3),
	},
	experience = 1.12,
	random_escort_possibilities = { {"tier1.1", 1, 2}, {"tier1.2", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },
}
