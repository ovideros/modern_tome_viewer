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

engine.Faction:add{ name="Kruk Pride", reaction={}, }
engine.Faction:add{ name="Free Whitehooves", reaction={}, }
engine.Faction:add{ name="Whitehooves", reaction={}, }
engine.Faction:add{ name="Kar'Haïb Dominion", short_name="kar-haib-dominion", reaction={}, }
engine.Faction:add{ name="Atmos Tribe", short_name="atmos-tribe", reaction={}, }
engine.Faction:add{ name="Kaltor's Shop", short_name="kaltor-shop", reaction={}, hostile_on_attack=true, }
engine.Faction:add{ name="Amakthel", reaction={}, }

engine.Faction:setInitialReaction("kruk-pride", "orc-pride", 100, true)
engine.Faction:setInitialReaction("kruk-pride", "enemies", -100, true)
engine.Faction:setInitialReaction("kruk-pride", "fearscape", -100, true)
engine.Faction:setInitialReaction("kruk-pride", "sunwall", -100, true)
engine.Faction:setInitialReaction("kruk-pride", "undead", -100, true)
engine.Faction:setInitialReaction("kruk-pride", "allied-kingdoms", -100, true)
engine.Faction:setInitialReaction("kruk-pride", "shalore", -100, true)
engine.Faction:setInitialReaction("kruk-pride", "thalore", -100, true)
engine.Faction:setInitialReaction("kruk-pride", "iron-throne", -100, true)
engine.Faction:setInitialReaction("kruk-pride", "the-way", -100, true)
engine.Faction:setInitialReaction("kruk-pride", "angolwen", -100, true)
engine.Faction:setInitialReaction("kruk-pride", "dreadfell", -100, true)
engine.Faction:setInitialReaction("kruk-pride", "rhalore", -100, true)
engine.Faction:setInitialReaction("kruk-pride", "zigur", -100, true)
engine.Faction:setInitialReaction("kruk-pride", "vargh-republic", -100, true)
engine.Faction:setInitialReaction("kruk-pride", "fearscape", -100, true)
engine.Faction:setInitialReaction("kruk-pride", "kar-haib-dominion", -100, true)
engine.Faction:setInitialReaction("kruk-pride", "atmos-tribe", -100, true)
engine.Faction:setInitialReaction("kruk-pride", "horrors", -100, true)
engine.Faction:setInitialReaction("kruk-pride", "whitehooves", -100, true)

engine.Faction:setInitialReaction("atmos-tribe", "horrors", -100, true)

engine.Faction:copyReactions("free-whitehooves", "kruk-pride")

engine.Faction:copyReactions("amakthel", "horrors")
