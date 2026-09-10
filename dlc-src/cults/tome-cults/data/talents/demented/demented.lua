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

newTalent{
	name = "Insanity Pool",
	type = {"base/class", 1},
	info = _t"Allows you to have an insanity pool. Insanity is used for most demented powers.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
	callbackOnChangeLevel = function(self, t, what, zone, level)
		if what == "leave" then self.insanity = 0 end
	end,
}

newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/tentacles", name = _t("tentacles", "talent type"), description = _t"Grow horrific tentacles to assail your foes." }
newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/horrific-body", name = _t("horrific body", "talent type"), description = _t"Let your body mutate in terrible and efficient ways." }
newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/writhing-body", name = _t("writhing body", "talent type"), description = _t"Enhance your body and tentacle with new attacks and horrific growths." }
newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/path-of-horror", name = _t("path of horror", "talent type"), description = _t"Continue your journey on the side of horror." }
newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/controlled-horrors", name = _t("controlled horrors", "talent type"), description = _t"Summon decaying horrors to do your bidding!" }
newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/slow-death", no_npc_use=true, name = _t("slow death", "talent type"), description = _t"Turn the insides of your body into a digesting weapon of pain!" }
newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/disfigured-face", name = _t("disfigured face", "talent type"), description = _t"Your face is the stuff of nightmares!" }
newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/friend-of-the-worm", name = _t("friend of the worm", "talent type"), min_lev = 10, description = _t"Conjure your Worm that Walks friend!" }
newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/nether", name = _t("nether", "talent type"), description = _t"Annihilate your foes with pure void energy." }
newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/madness", name = _t("madness", "talent type"), description = _t"Spread the madness of the void to your enemies." }
newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/void", name = _t("void", "talent type"), description = _t"Draw upon the power of the void to protect yourself from harm." }
newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/entropy", name = _t("entropy", "talent type"), description = _t"Learn to withstand and direct the entropy you cause." }
newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/timethief", name = _t("timethief", "talent type"), description = _t"Steal time from others, weakening them to empower yourself." }
newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/oblivion", name = _t("oblivion", "talent type"), min_lev = 10, description = _t"Channel the essence of entropy to reduce your foes to dust." }
newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/rift", name = _t("rift", "talent type"), min_lev = 10, description = _t"Tear holes in space and time to unleash devastating forces on your foes." }
newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/chronophage", name = _t("chronophage", "talent type"), min_lev = 10, description = _t"Feast upon the ruined timelines of your enemies." }

newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/scourge-drake", name = _t("scourge drake", "talent type"), description = _t"Take on the defining aspects of a Scourge Drake." }

newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/doom", generic = true, name = _t("doom", "talent type"), description = _t"Foretell the dire fate of your enemies." }
newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/prophecy", name = _t("prophecy", "talent type"), description = _t"The various prophecies you can tell." }	
newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/calamity", generic = true, name = _t("calamity", "talent type"), description = _t"Stack the odds in your favour." }


newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="demented/beyond-sanity", name = _t("beyond sanity", "talent type"), generic=true, description = _t"Let yourself walk in chaos!" }

newTalentType{ no_silence=true, is_spell=true, type="demented/other", name = _t("other", "talent type"), hide = true, description = _t"Talents of the various entities of the world." }

-- Generic requires for spells based on talent level
dementedreq1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
dementedreq2 = {
	stat = { mag=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
dementedreq3 = {
	stat = { mag=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
dementedreq4 = {
	stat = { mag=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
dementedreq5 = {
	stat = { mag=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
dementedreq_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
dementedreq_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
dementedreq_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
dementedreq_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
dementedreq_high5 = {
	stat = { mag=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

load("/data-cults/talents/demented/tentacles.lua")
load("/data-cults/talents/demented/writhing-body.lua")
load("/data-cults/talents/demented/horrific-body.lua")
load("/data-cults/talents/demented/path-of-horror.lua")
load("/data-cults/talents/demented/controlled-horrors.lua")
load("/data-cults/talents/demented/friend-of-the-worm.lua")
load("/data-cults/talents/demented/slow-death.lua")
load("/data-cults/talents/demented/disfigured-face.lua")
load("/data-cults/talents/demented/chronophage.lua")
load("/data-cults/talents/demented/rift.lua")
load("/data-cults/talents/demented/oblivion.lua")
load("/data-cults/talents/demented/timethief.lua")
load("/data-cults/talents/demented/entropy.lua")
load("/data-cults/talents/demented/void.lua")
load("/data-cults/talents/demented/madness.lua")
load("/data-cults/talents/demented/nether.lua")
load("/data-cults/talents/demented/beyond-sanity.lua")
load("/data-cults/talents/demented/doom.lua")
load("/data-cults/talents/demented/calamity.lua")
load("/data-cults/talents/demented/scourge-drake.lua")
