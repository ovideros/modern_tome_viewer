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

local alchemist = getBirthDescriptor("subclass", "Alchemist")
if alchemist then
	alchemist.cosmetic_options = alchemist.cosmetic_options or {}
	alchemist.cosmetic_options.golem = alchemist.cosmetic_options.golem or {}
	table.insert(alchemist.cosmetic_options.golem, {name=_t"Golem becomes a Glass Golem", unlock="cosmetic_class_alchemist_glass_golem", on_actor=function(actor) actor.alchemist_golem_is_glass_golem = true end})
end
