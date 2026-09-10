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

return { one_per_level=true,
	{name="font-life", minor=true, percent=60},
	{name="orcs+sewer-alligator-nest", minor=true, percent=300, max_repeat=5, forbid={3, 4}},
	{name="sub-vault", minor=true, percent=40, max_repeat=2, forbid={3, 4}},
	{name="orcs+AAA", minor=true, percent=15},
	{name="glowing-chest", minor=true, percent=40},
	{name="orcs+herbs", minor=true, percent=100, forbid={1, 2}},
}
