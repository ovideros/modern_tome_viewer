-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

newTalentType{ allow_random=true, no_silence=true, is_necromancy=true, is_spell=true, type="spell/undead-drake", name = _t("undead drake", "talent type"), description = _t"Take on the defining aspects of an Undead Drake." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/galvanic-technomancy", name = _t("galvanic technomancy", "talent type"), min_lev = 10, description = _t"Combine the power of steamtech and arcane forces to destroy your foes with fire and lightning." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/terrene-technomancy", name = _t("terrene technomancy", "talent type"), min_lev = 10, description = _t"Combine the power of steamtech and arcane forces to destroy your foes with earth and water." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/occult-technomancy", name = _t("occult technomancy", "talent type"), min_lev = 10, description = _t"Combine the power of steamtech and arcane forces to destroy your foes with arcane and time." }
newTalentType{ no_silence=true, is_spell=true, mana_regen=true, type="spell/other-technomancy", name = _t("other technomancy", "talent type"), min_lev = 10, description = _t"Combine the power of steamtech and arcane forces to destroy your foes." }

technomancy_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
	talent = { "T_TINKER_ARCANE_DYNAMO" },
}
technomancy_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
	talent = { "T_TINKER_ARCANE_DYNAMO" },
}
technomancy_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
	talent = { "T_TINKER_ARCANE_DYNAMO" },
}
technomancy_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
	talent = { "T_TINKER_ARCANE_DYNAMO" },
}

load("/data-orcs/talents/spells/undead-drake.lua")
load("/data-orcs/talents/spells/galvanic-technomancy.lua")
load("/data-orcs/talents/spells/terrene-technomancy.lua")
load("/data-orcs/talents/spells/occult-technomancy.lua")
load("/data-orcs/talents/spells/other-technomancy.lua")
