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

newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/sol", name = _t("Sol", "talent type"), description = _t"" }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/cosmic", name = _t("Cosmic", "talent type"), description = _t"" }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/energies", name = _t("Energies", "talent type"), description = _t"" }
newTalentType{ allow_random=false, no_silence=true, is_spell=true, type="celestial/reflection", name = _t("Reflection", "talent type"), description = _t"" }
--most of these spells are really awkward and the ai can't use them well. They can probably be made to work better later
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/void", name = _t("Void", "talent type"), description = _t""}

load("/data-orcs/talents/celestial/sol.lua")
load("/data-orcs/talents/celestial/cosmic.lua")
load("/data-orcs/talents/celestial/energies.lua")
load("/data-orcs/talents/celestial/reflection.lua")
load("/data-orcs/talents/celestial/void.lua")