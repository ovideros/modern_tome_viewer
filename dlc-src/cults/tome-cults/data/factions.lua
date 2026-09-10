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

-- For kroshkkur
engine.Faction:add{ name="Sanctuary of Horrors", reaction={}, }
engine.Faction:copyReactions("sanctuary-of-horrors", "iron-throne")

-- For a view from the gallery
engine.Faction:add{ name="The Tribe", short_name="grung-faction", reaction={}, }
engine.Faction:add{ name="Food", short_name="grung-food", reaction={}, }
engine.Faction:add{ name="Things from above", short_name="grung-neutral-1", reaction={}, }
engine.Faction:add{ name="Things from above", short_name="grung-neutral-2", reaction={}, }
engine.Faction:setInitialReaction("grung-neutral-1", "grung-neutral-2", -100, true)
engine.Faction:setInitialReaction("grung-neutral-1", "grung-faction", -100, true)
engine.Faction:setInitialReaction("grung-neutral-2", "grung-faction", -100, true)
engine.Faction:setInitialReaction("grung-food", "grung-faction", -100, true)
