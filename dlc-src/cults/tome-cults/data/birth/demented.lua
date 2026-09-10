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

-- Add Demented to all campaigns that can do Defilers
for i, bdata in ipairs(Birther.birth_descriptor_def.world) do
	if bdata.descriptor_choices and bdata.descriptor_choices.class and bdata.descriptor_choices.class.Defiler == "allow" then
		bdata.descriptor_choices.class.Demented = "allow"
	end
end

newBirthDescriptor{
	type = "class",
	name = "Demented",
	desc = {
		_t"The thirst for knowledge is seen by most arcane users as as good thing.",
		_t"But some take it too far, some delve into lost knowledge. They may gain huge power from it, but at what cost?"
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			['Writhing One'] = "allow",
			['Cultist of Entropy'] = "allow",
		},
	},
	copy = {
		max_life = 110,
	},
}

local start_zone = function(self)
	if self.descriptor.world == "Maj'Eyal" and (
		self.descriptor.race == "Human" or
		self.descriptor.race == "Elf" or
		self.descriptor.race == "Dwarf" or
		self.descriptor.race == "Yeek" or
		self.descriptor.race == "Halfling" or 
		(self.descriptor.race == "Giant" and self.descriptor.subrace == "Ogre")
	) and not self._forbid_start_override then
		self.cults_race_start_quest = self.starting_quest
		-- Some overrides
		if self.descriptor.race == "Dwarf" then self.cults_race_start_quest = "start-allied" end
		if self.descriptor.race == "Yeek" then self.cults_race_start_quest = "start-allied" end
		--self.default_wilderness = {"zone-pop", "angolwen-portal"}  This erases Angolwen
		self.default_wilderness = {20, 17}
		self.starting_zone = "cults+town-kroshkkur"
		self.starting_quest = "cults+start-cults"
		self.starting_intro = "cults"
	end
	self:triggerHook{"BirthStartZone:cults"}
end

newBirthDescriptor{
	type = "subclass",
	name = "Writhing One",
	desc = {
		_t"Writhing Ones know that what we call #{italic}#horrors#{normal}# hold the key to some ancient knowledge and power from the Age of Haze and they are ready to do anything to access it.",
		_t"In their lust for power they somehow lost a part of themselves, turning more and more into the horrors they study.",
		_t"Most of them forgo an entire arm to turn it into a deadly tentacle.",
		_t"Some are even known to never leave their sanctuary without their own worm that walks friend.",
		_t"Their most important stats are: Strength and Magic",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +3 Strength, +0 Dexterity, +3 Constitution",
		_t"#LIGHT_BLUE# * +3 Magic, +0 Willpower, +0 Cunning",
		_t"#GOLD#Life per level:#LIGHT_BLUE# +3",
	},
	power_source = {arcane=true, technique=true,},
	stats = { mag=3, con=3, str=3,},
	-- birth_example_particles = {
	-- 	function(actor)
	-- 		actor:addParticles(Particles.new("destroyer", 1))
	-- 	end,
	-- },
	talents_types = {
		["demented/tentacles"]={true, 0.3},
		["demented/path-of-horror"]={true, 0.3},
		["demented/slow-death"]={false, 0.3},
		["demented/horrific-body"]={true, 0.3},
		["demented/disfigured-face"]={true, 0.3},
		["demented/friend-of-the-worm"]={false, 0.3},
		["demented/controlled-horrors"]={true, 0.3},
		["demented/beyond-sanity"]={true, 0.3},
		["technique/combat-training"]={true, 0.0},
		["cunning/survival"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_INSANITY_POOL] = 1,
		[ActorTalents.T_MUTATED_HAND] = 1,
		[ActorTalents.T_ARMOUR_TRAINING] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_WEAPONS_MASTERY] = 1,
		[ActorTalents.T_CHAOS_ORBS] = 1,
		[ActorTalents.T_CARRION_FEET] = 1,
	},
	copy = {
		class_start_check = start_zone,
		resolvers.equip{ id=true,
			{type="weapon", subtype="longsword", name="iron longsword", autoreq=true, ego_chance=-1000,},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000,},
		},
	},
	copy_add = {
		life_rating = 3,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Cultist of Entropy",
	locked = function() return profile.mod.allow_build.demented_cultist_entropy end,
	locked_desc = _t"Everything ends eventually. Harness this inevitability.",
	desc = {
		_t"Cultists of Entropy are doomed beings which have unlocked the secrets of using entropy as a weapon. Their spells cause their bodies to wither away from entropic backlash, but they have learned how to resist this backlash and even pass it onto their foes.",
		_t"Their most important stats are: Magic and Cunning",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution",
		_t"#LIGHT_BLUE# * +6 Magic, +0 Willpower, +3 Cunning",
		_t"#GOLD#Life per level:#LIGHT_BLUE# -4",
	},
	power_source = {arcane=true},
	stats = { mag=6, cun=3, },
	birth_example_particles = {
		function(actor)	if core.shader.active(4) then actor:addParticles(Particles.new("shadowfire", 1)) end end,
		function(actor) if core.shader.active(4) then local x, y = actor:attachementSpot("back", true) actor:addParticles(Particles.new("shader_wings", 1, {infinite=1, x=x, y=y, img="bloodwings", flap=28, a=0.6})) end
		end,
	},
	talents_types = {
		["demented/nether"]={true, 0.3},
		["demented/madness"]={true, 0.3},
		["demented/void"]={true, 0.3},
		["demented/entropy"]={true, 0.3},
		["demented/timethief"]={true, 0.3},		
		["demented/oblivion"]={false, 0.3},
		["demented/chronophage"]={false, 0.3},
		["demented/rift"]={false, 0.3},
		["demented/doom"]={true, 0.3},
		["demented/calamity"]={true, 0.3},		
		["demented/beyond-sanity"]={true, 0.3},
		["technique/combat-training"]={true, 0},
		["cunning/survival"]={false, 0},		
	},
	talents = {
		[ActorTalents.T_NETHERBLAST] = 1,
		[ActorTalents.T_VOID_STARS] = 1,
		[ActorTalents.T_ENTROPIC_GIFT] = 1,
		[ActorTalents.T_CHAOS_ORBS] = 1,
	},
	copy = {
		class_start_check = start_zone,
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="Rags of the Sanctuary", base_list="mod.class.Object:/data-cults/general/objects/special-misc.lua", autoreq=true, ego_chance=-1000, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = -4,
	},
}
