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

resolvers.racials_defs.drem = {
	T_DREM_FRENZY = {last=10, base=0, every=4, max=5},
	T_SPIKESKIN = {last=15, base=0, every=4, max=5},
	T_FACELESS = {last=20, base=0, every=4, max=5},
	-- no 4th
}

resolvers.racials_defs.krog = {
	T_KROG_WRATH = {last=10, base=0, every=4, max=5},
	["T_DRAKE-INFUSED_BLOOD"] = {last=15, base=0, every=4, max=5},
	T_FUEL_PAIN = {last=20, base=0, every=4, max=5},
	T_WARBORN = {last=30, base=0, every=4, max=5},
}

resolvers.racials_visuals_defs.Giant.Krog = {
	{kind="skin", filter={"all"}},
	{kind="hairs", filter={"all"}},
	{kind="facial_features", percent=20, filter={"all"}},
	{kind="tatoos", percent=35, filter={"all"}},
}
