-- ToME - Tales of Maj'Eyal:
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

local Particles = require "engine.Particles"

getBirthDescriptor("class", "Defiler").descriptor_choices.subclass["Demonologist"] = "allow"
getBirthDescriptor("class", "Defiler").descriptor_choices.subclass["Doombringer"] = "allow"
getBirthDescriptor("class", "Defiler").locked = nil

local start_zone = function(self)
	if self.descriptor.world == "Maj'Eyal" and (
		self.descriptor.race == "Human" or
		self.descriptor.race == "Elf" or
		self.descriptor.race == "Dwarf" or
		self.descriptor.race == "Yeek" or
		self.descriptor.race == "Halfling" or 
		(self.descriptor.race == "Giant" and self.descriptor.subrace == "Ogre")
	) and not self._forbid_start_override then
		self.ashes_urhrok_race_start_quest = self.starting_quest
		-- Some overrides
		if self.descriptor.race == "Dwarf" then self.ashes_urhrok_race_start_quest = "start-allied" end
		if self.descriptor.race == "Yeek" then self.ashes_urhrok_race_start_quest = "start-allied" end
		self.default_wilderness = {"zone-pop", "angolwen-portal"}
		self.starting_zone = "ashes-urhrok+searing-halls"
		self.starting_quest = "ashes-urhrok+start-ashes"
		self.starting_intro = "ashes-urhrok"
	end
	self:triggerHook{"BirthStartZone:ashesurhrok"}
end

newBirthDescriptor{
	type = "subclass",
	name = "Doombringer",
	desc = {
		_t"Weapon in hand and sheathed in flame, a Doombringer is a terrifying force in combat.",
		_t"Doombringers are engines of war, cleaving and burning their way through entire armies.",
		_t"The most powerful Doombringers can harness the full power of their demonic ties and transform themselves into a gigantic demon.",
		_t"Their most important stats are: Strength and Magic",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +4 Strength, +0 Dexterity, +2 Constitution",
		_t"#LIGHT_BLUE# * +2 Magic, +0 Willpower, +1 Cunning",
		_t"#GOLD#Life per level:#LIGHT_BLUE# +3",
	},
		power_source = {arcane=true, technique=true,},
	stats = { mag=2, con=2, str=4, cun=1,},
	birth_example_particles = {
		function(actor)
			actor:addParticles(Particles.new("destroyer", 1))
		end,
	},
	talents_types = {
		["cunning/survival"]={true, 0},
		--Corruptions
	--	["corruption/vim"]={false, 0.2},
	--	["corruption/curses"]={false, 0},	
		["corruption/shadowflame"]={true, 0.3},
		["corruption/hexes"]={true, 0.1},	
		--Techniques
		["technique/combat-techniques-active"]={true, 0.3},
		["technique/combat-techniques-passive"]={true, 0.3},
		["technique/combat-training"]={true, 0.3},
		--New Corruptions
		["corruption/demonic-strength"]={true, 0.3},
		["corruption/fearfire"]={false, 0.3},
		["corruption/oppression"]={true, 0.3},
		["corruption/heart-of-fire"]={true, 0.3},
		--Melee Trees
		["corruption/brutality"]={true, 0.3},
		["corruption/wrath"]={false, 0.3},
		["corruption/torture"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_STAMINA_POOL] = 1, --Otherwise won't actually get one
		[ActorTalents.T_DRAINING_ASSAULT] = 1,
		[ActorTalents.T_INCINERATING_BLOWS] = 1,
		[ActorTalents.T_WRAITHFORM] = 1,
		[ActorTalents.T_ARMOUR_TRAINING] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_WEAPONS_MASTERY] = 1,
	},
	copy = {
		class_start_check = start_zone,
		resolvers.auto_equip_filters("Berserker"),
		resolvers.equip{ id=true,
			{type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true, ego_chance=-1000,},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000,},
		},
	},
	copy_add = {
		life_rating = 3,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Demonologist",
	locked = function() return profile.mod.allow_build.corrupter_demonologist end,
	locked_desc = _t"Most simply run, but I understand: a distant planet, ravaged and damned. Burnt creations seek righteous vengeance, Urh'Rok's ashes, now destruction's engines. Harness their power! Capture and tame! I call on you, demons - UNLEASH THE FLAMES!",
	desc = {
		_t"Contrary to popular beliefs Demonologists are not the pawns of demons, they enact pacts with them but always very carefully.",
		_t"They use those demonic powers for their own purpose, often evil but a few have been known to use demonic powers to fight demons.",
		_t"Demonologists are melee fighters, bashing their foes skulls with their shields while calling down rains of fire and darkness.",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +3 Strength, +0 Dexterity, +2 Constitution",
		_t"#LIGHT_BLUE# * +4 Magic, +0 Willpower, +0 Cunning",
		_t"#GOLD#Life per level:#LIGHT_BLUE# +2",
	},
	power_source = {technique=true, arcane=true},
	stats = { str=3, con=2, mag=4, },
	talents_types = {
		["corruption/spellblaze"]={false, 0.3},
		["corruption/doom-covenant"]={false, 0.3},
		["corruption/torment"]={true, 0.3},
		["corruption/shadowflame"]={true, 0.3},
		["corruption/infernal-combat"]={true, 0.3},
		["corruption/demonic-pact"]={true, 0.3},
		["corruption/doom-shield"]={true, 0.3},
		["corruption/black-magic"]={true, 0.3},
		["cunning/survival"]={true, 0},
		["technique/combat-training"]={true, 0},
		["technique/combat-techniques-active"]={true, 0.3},
		["technique/combat-techniques-passive"]={true, 0.3},
		["technique/shield-offense"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_ARMOUR_TRAINING] = 2,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_WEAPONS_MASTERY] = 1,
		[ActorTalents.T_SHIELD_PUMMEL] = 1,
		[ActorTalents.T_FLAME_LEASH] = 1,
		[ActorTalents.T_DEMON_SEED] = 1,
		[ActorTalents.T_BLEAK_OUTCOME] = 1,
	},
	copy = {
		class_start_check = start_zone,
		max_life = 110,
		resolvers.auto_equip_filters("Sun Paladin"),
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="longsword", name="iron longsword", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="shield", name="iron shield", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000}
		},
	},
	copy_add = {
		life_rating = 2,
	},
}
