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

-- Those are never generated randomly, but used when we want humanoid random bosses

newEntity{ base = "BASE_NPC_HUMANOID_RANDOM_BOSS", define_as = "NPC_HUMANOID_KROG",
	display = 'P',
	name = "krog", subtype = "krog", color=colors.BLUE,
	random_name_def = "thalore_#sex#",
	humanoid_random_boss = 2, zigur_random_boss = 1,
	resolvers.racial_visual(nil, "Giant", "Krog"),
	resolvers.racial(),
}
