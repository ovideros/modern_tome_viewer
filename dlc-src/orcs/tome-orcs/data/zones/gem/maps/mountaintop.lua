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

-- defineTile section
defineTile("_", "EMPTY")
defineTile(">", "BACK_TO_CAVE")
defineTile(".", "ROCKY_GROUND")
defineTile("b", "ROCKY_GROUND", nil, "STAR_GAZER")
defineTile("S", "SUN_PILAR")
defineTile("M", "MOON_PILAR")
defineTile("T", "ROCKY_SNOWY_TREE")

startx = 19
starty = 21
endx = 19
endy = 21


-- addSpot section

-- addZone section

-- ASCII map section
return [[
______________________________
______________________________
______________________________
______________________________
______________________________
____________________..._______
__________...._.........______
_________..........T....._____
________..T..TTT...TTTT...____
________..T...........T...____
_______..TT.....M........_____
______......S.......S...._____
______.......b.....b....._____
______.TT.M.....b.....M.._____
______..T....b.....b....._____
______..T...S.......S..T._____
_______.T.......M........_____
_______....T............._____
________...TTT..........______
_________....TT...TTTT..______
__________.......TT.....______
___________......T.>....______
_______________........_______
__________________..__________
______________________________
______________________________
______________________________
______________________________
______________________________
______________________________]]