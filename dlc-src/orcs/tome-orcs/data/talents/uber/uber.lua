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

knowRessource = Talents.main_env.knowRessource

uberTalent = function(t)
	t.type = {"uber/strength", 1}
	t.uber = true
	t.require = t.require or {}
	t.require.level = 25
	t.require.stat = t.require.stat or {}
	t.require.stat.str = 50
	newTalent(t)
end
load("/data-orcs/talents/uber/str.lua")

uberTalent = function(t)
	t.type = {"uber/dexterity", 1}
	t.uber = true
	t.require = t.require or {}
	t.require.stat = t.require.stat or {}
	t.require.level = 25
	t.require.stat.dex = 50
	newTalent(t)
end
load("/data-orcs/talents/uber/dex.lua")

uberTalent = function(t)
	t.type = {"uber/constitution", 1}
	t.uber = true
	t.require = t.require or {}
	t.require.stat = t.require.stat or {}
	t.require.level = 25
	t.require.stat.con = 50
	newTalent(t)
end
load("/data-orcs/talents/uber/const.lua")

uberTalent = function(t)
	t.type = {"uber/magic", 1}
	t.uber = true
	t.require = t.require or {}
	t.require.stat = t.require.stat or {}
	t.require.level = 25
	t.require.stat.mag = 50
	newTalent(t)
end
load("/data-orcs/talents/uber/mag.lua")

uberTalent = function(t)
	t.type = {"uber/willpower", 1}
	t.uber = true
	t.require = t.require or {}
	t.require.level = 25
	t.require.stat = t.require.stat or {}
	t.require.stat.wil = 50
	newTalent(t)
end
load("/data-orcs/talents/uber/wil.lua")

uberTalent = function(t)
	t.type = {"uber/cunning", 1}
	t.uber = true
	t.require = t.require or {}
	t.require.level = 25
	t.require.stat = t.require.stat or {}
	t.require.stat.cun = 50
	newTalent(t)
end
load("/data-orcs/talents/uber/cun.lua")
