-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

-- Talent trees
newTalentType{ allow_random=true, is_mind=true, type="psionic/gestalt", name = _t("gestalt", "talent type"), description = _t"Harness steam energies to power your own mind." }
newTalentType{ allow_random=true, is_mind=true, type="psionic/action-at-a-distance", name = _t("action at a distance", "talent type"), description = _t"Focus your mental energies to make things happen. Or combust." }
newTalentType{ allow_random=true, is_mind=true, type="psionic/psionic-fog", name = _t("psionic fog", "talent type"), description = _t"Psionically manipulate steam to harass your foes and protect yourself." }

load("/data-orcs/talents/psionic/gestalt.lua")
load("/data-orcs/talents/psionic/action-at-a-distance.lua")
load("/data-orcs/talents/psionic/psionic-fog.lua")

