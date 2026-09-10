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
	name = "Steam Pool",
	type = {"base/class", 1},
	info = _t"Allows you to have a steam pool. Steam is used to use most steamtech equipments and powers.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
}

newTalentType{ is_steam=true, type="inscriptions/implants", name = _t("implants", "talent type"), hide = true, description = _t"Steamtech directly embedded on the skin." }

newTalentType{ is_steam=true, type="steamtech/objects", name = _t("other", "talent type"), description = _t"Tinkers with stuff." }
newTalentType{ is_steam=true, type="steamtech/other", name = _t("other", "talent type"), description = _t"Tinkers with stuff." }

newTalentType{ allow_random=true, is_steam=true, type="steamtech/physics", generic=true, name = _t("physics", "talent type"), description = _t"Learn the mechanical side of steamtech." }
newTalentType{ allow_random=true, is_steam=true, type="steamtech/chemistry", generic=true, name = _t("chemistry", "talent type"), description = _t"Learn the chemistry side of steamtech." }
newTalentType{ allow_random=true, is_steam=true, type="steamtech/blacksmith", generic=true, name = _t("blacksmith", "talent type"), description = _t"All this metalworking has improved you." }
newTalentType{ allow_random=true, is_steam=true, type="steamtech/engineering", generic=true, name = _t("engineering", "talent type"), description = _t"You don't just know how tinkering works, you know all the interesting details too!" }

newTalentType{ allow_random=true, is_steam=true, speed="weapon", type="steamtech/butchery", name = _t("butchery", "talent type"), description = _t"Strap saws to your arms and rush into battle!" }
newTalentType{ allow_random=true, is_steam=true, speed="weapon", type="steamtech/sawmaiming", name = _t("sawmaiming", "talent type"), description = _t"Use steam powered saws to their maximum efficiency! Maim! Cut! Shred!" }
newTalentType{ allow_random=true, is_steam=true, speed="weapon", type="steamtech/battlefield-management", name = _t("battlefield management", "talent type"), description = _t"Use steam powered saws to maneuver around the battlefield, gaining strategic advantage." }
newTalentType{ allow_random=true, is_steam=true, type="steamtech/battle-machinery", name = _t("battle machinery", "talent type"), description = _t"Use steam powered engines to tilt the battle in your favour." }
newTalentType{ allow_random=true, is_steam=true, speed="weapon", type="steamtech/automated-butchery", min_lev = 10, name = _t("automated butchery", "talent type"), description = _t"Improve your saws and tinkers with automated processes to help shred your foes." }
newTalentType{ allow_random=true, is_steam=true, type="steamtech/furnace", name = _t("furnace", "talent type"), description = _t"Harness the power of fire." }

newTalentType{ allow_random=true, is_steam=true, can_offshoot= true, speed="archery", type="steamtech/gunner-training", name = _t("gunner training", "talent type"), description = _t"Use steam powered guns to rain bullets of death on your foes!  (Learning these talents allow you to fire two steamguns at once.)" }
newTalentType{ allow_random=true, is_steam=true, can_offshoot= true, speed="archery", type="steamtech/gunslinging", name = _t("gunslinging", "talent type"), description = _t"Use advanced marksmanship to confound and overwhelm your foes!  (Learning these talents allow you to fire two steamguns at once.)" }
newTalentType{ allow_random=true, is_steam=true, can_offshoot= true, type="steamtech/bullets-mastery", name = _t("bullets mastery", "talent type"), description = _t"Use various kinds of technology to temporarily enhance your bullets.  (Learning these talents allow you to fire two steamguns at once.)" }
newTalentType{ allow_random=true, is_steam=true, type="steamtech/avoidance", name = _t("avoidance", "talent type"), description = _t"Using various enhancements of your cloak you are able to manage incoming damage." }
newTalentType{ allow_random=true, is_steam=true, type="steamtech/elusiveness", name = _t("elusiveness", "talent type"), description = _t"Incredible feats of slipperiness!" }
newTalentType{ allow_random=true, is_steam=true, type="steamtech/automation", name = _t("automation", "talent type"), min_lev = 10, description = _t"Use small automated devices to control the battlefield." }

newTalentType{ allow_random=true, is_steam=true, type="steamtech/psytech-gunnery", name = _t("psytech gunnery", "talent type"), description = _t"Meld your psionic powers with awesome steamtech! For mayhem!" }
newTalentType{ allow_random=true, is_steam=true, type="steamtech/thoughts-of-iron", name = _t("thoughts of iron", "talent type"), description = _t"Apply some of your formidable willpower through steam devices." }
newTalentType{ allow_random=true, is_steam=true, type="steamtech/mechstar", name = _t("mechstar", "talent type"), description = _t"Control your mindstar and infuse it with steamtech." }
newTalentType{ allow_random=true, is_steam=true, is_mind=true, type="steamtech/dread", name = _t("dread", "talent type"), description = _t"Behold the mechanized horrors." }

newTalentType{ allow_random=true, is_steam=true, speed="shield", type="steamtech/magnetism", name = _t("magnetism", "talent type"), description = _t"Use the power of electricity to supercharge your shield." }
newTalentType{ allow_random=true, is_steam=true, type="steamtech/demolition", name = _t("demolition", "talent type"), description = _t"The use of high explosives." }
newTalentType{ allow_random=true, is_steam=true, type="steamtech/gadgets", name = _t("gadgets", "talent type"), description = _t"Cunning devices to augment your combat skill." }
newTalentType{ allow_random=true, is_steam=true, speed="archery", type="steamtech/heavy-weapons", name = _t("heavy weapons", "talent type"), description = _t"Wield powerful steamtech tools of destruction." }
newTalentType{ allow_random=true, is_steam=true, type="steamtech/turrets", name = _t("turrets", "talent type"), description = _t"Deploy steam powered turrets to assist you in combat." }
newTalentType{ allow_random=true, is_steam=true, type="steamtech/turret-types", name = _t("turrets", "talent type"), description = _t"The various kinds of turrets." }
newTalentType{ allow_random=true, is_steam=true, speed="archery", min_lev = 10, type="steamtech/artillery", name = _t("artillery", "talent type"), description = _t"Advanced explosive weaponry." }
newTalentType{ allow_random=true, is_steam=true, min_lev = 10, type="steamtech/mecharachnid", name = _t("mecharachnid", "talent type"), description = _t"Build and deploy a powerful mechanical arachnid to assist you." }
newTalentType{ allow_random=true, is_steam=true, speed="archery", min_lev = 10, type="steamtech/chemical-warfare", name = _t("chemical warfare", "talent type"), description = _t"Unleash toxic steamtech weaponry on your enemies." }

steamgun_range = Talents.main_env.archery_range

-- Generic requires for spells based on talent level
steamreq1 = {
	stat = { cun=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
steamreq2 = {
	stat = { cun=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
steamreq3 = {
	stat = { cun=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
steamreq4 = {
	stat = { cun=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
steamreq5 = {
	stat = { cun=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
steamreq_high1 = {
	stat = { cun=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
steamreq_high2 = {
	stat = { cun=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
steamreq_high3 = {
	stat = { cun=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
steamreq_high4 = {
	stat = { cun=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
steamreq_high5 = {
	stat = { cun=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

str_steamreq1 = {
	stat = { str=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
str_steamreq2 = {
	stat = { str=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
str_steamreq3 = {
	stat = { str=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
str_steamreq4 = {
	stat = { str=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
str_steamreq5 = {
	stat = { str=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
str_steamreq_high1 = {
	stat = { str=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
str_steamreq_high2 = {
	stat = { str=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
str_steamreq_high3 = {
	stat = { str=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
str_steamreq_high4 = {
	stat = { str=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
str_steamreq_high5 = {
	stat = { str=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

dex_steamreq1 = {
	stat = { dex=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
dex_steamreq2 = {
	stat = { dex=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
dex_steamreq3 = {
	stat = { dex=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
dex_steamreq4 = {
	stat = { dex=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
dex_steamreq5 = {
	stat = { dex=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
dex_steamreq_high1 = {
	stat = { dex=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
dex_steamreq_high2 = {
	stat = { dex=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
dex_steamreq_high3 = {
	stat = { dex=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
dex_steamreq_high4 = {
	stat = { dex=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
dex_steamreq_high5 = {
	stat = { dex=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

function craft_levelup(self, t, lvl, old_lvl, lvl_raw, old_lvl_raw, from_dialog)
	-- hack around 1.4 bug :<
	if self:isClassName("mod.dialogs.LevelupDialog") then self = self.actor end

	---------------------------------------------------------------------------
	-- Achieve things!
	---------------------------------------------------------------------------
	game:onTickEnd(function()
		if self.player and self.descriptor and self.descriptor.class == "Mage" and
		   self:getTalentLevelRaw(self.T_THERAPEUTICS) >= 5 and self:getTalentLevelRaw(self.T_CHEMISTRY) >= 5 and self:getTalentLevelRaw(self.T_EXPLOSIVES) >= 5 and 
		   self:getTalentLevelRaw(self.T_SMITH) >= 5 and self:getTalentLevelRaw(self.T_MECHANICAL) >= 5 and self:getTalentLevelRaw(self.T_ELECTRICITY) >= 5
		   then
			world:gainAchievement("ORCS_MAGE_FULL_TINKER", game.player)
		end
	end)

	---------------------------------------------------------------------------
	-- Learn tinkers
	---------------------------------------------------------------------------
	game.party.tinkers_auto_learnt = game.party.tinkers_auto_learnt or {}
	game.party.tinkers_auto_learnt[t.id] = game.party.tinkers_auto_learnt[t.id] or 0
	if game.party.tinkers_auto_learnt[t.id] >= 2 then return end

	local function learn_one(force_level)
		local tinker_id = nil
		local possibles = {}
		for tid, tinker in pairs(game.party.__tinkers_ings) do if tinker.random_schematic and tinker.talents and tinker.talents[t.id] and not game.party:knowTinker(tinker.id) then
			local max, maxid = -1, ""
			for ttid, lvl in pairs(tinker.talents) do if lvl > max then max = lvl; maxid = ttid end end
			local is_major = maxid == t.id
			if (not force_level or tinker.talents[t.id] == force_level) and is_major then
				possibles[#possibles+1] = tinker
			end
		end end
		if #possibles > 0 then
			local tinker = rng.table(possibles)
			game.party.tinkers_auto_learnt[t.id] = game.party.tinkers_auto_learnt[t.id] + 1
			game.log("#VIOLET#EUREKA!")
			if from_dialog then game.bignews:saySimple(120, "#VIOLET#EUREKA!#WHITE# Schematic learnt: #LIGHT_BLUE#%s", tinker.name) end
			game.party:learnTinker(tinker.id)
		end
	end

	for i = old_lvl_raw + 1, lvl_raw do
		if game.party.tinkers_auto_learnt[t.id] >= 2 then return end

		if i == 1 then learn_one(1)
		elseif i == 5 then learn_one()
		elseif rng.percent(20) then learn_one()
		end
	end
end

function tinkers_list_for_craft(self, t)
	local l = {}
	l[#l+1] = _t"This talent is required for the following tinkers (you still need to learn/find the schematics):"
	for tid, tinker in pairs(game.party.__tinkers_ings) do if tinker.random_schematic and not tinker.unique and tinker.talents and tinker.talents[t.id] then
		local known = ""
		if game.party:knowTinker(tinker.id) then known = _t" #LIGHT_BLUE#(known)#LAST#" end
		l[#l+1] = "#{italic}#* "..tinker.name..known.."#{normal}#"
	end end
	l[#l+1] = _t"#{italic}#* ...perhaps more to discover...#{normal}#"
	return table.concat(l, "\n")
end

load("/data-orcs/talents/steam/butchery.lua")
load("/data-orcs/talents/steam/sawmaiming.lua")
load("/data-orcs/talents/steam/battlefield-management.lua")
load("/data-orcs/talents/steam/battle-machinery.lua")
load("/data-orcs/talents/steam/automated-butchery.lua")
load("/data-orcs/talents/steam/furnace.lua")

load("/data-orcs/talents/steam/gunner-training.lua")
load("/data-orcs/talents/steam/gunslinging.lua")
load("/data-orcs/talents/steam/bullets-mastery.lua")
load("/data-orcs/talents/steam/avoidance.lua")
load("/data-orcs/talents/steam/elusiveness.lua")
load("/data-orcs/talents/steam/automation.lua")

load("/data-orcs/talents/steam/psytech-gunnery.lua")
load("/data-orcs/talents/steam/thoughts-of-iron.lua")
load("/data-orcs/talents/steam/mechstar.lua")
load("/data-orcs/talents/steam/dread.lua")

load("/data-orcs/talents/steam/other.lua")
load("/data-orcs/talents/steam/physics.lua")
load("/data-orcs/talents/steam/chemistry.lua")
load("/data-orcs/talents/steam/blacksmith.lua")
load("/data-orcs/talents/steam/engineering.lua")

load("/data-orcs/talents/steam/magnetism.lua")
load("/data-orcs/talents/steam/demolition.lua")
load("/data-orcs/talents/steam/gadgets.lua")
load("/data-orcs/talents/steam/heavy-weapons.lua")
load("/data-orcs/talents/steam/turrets.lua")
load("/data-orcs/talents/steam/artillery.lua")
load("/data-orcs/talents/steam/mecharachnid.lua")
load("/data-orcs/talents/steam/chemical-warfare.lua")