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

defineTile('<', "GRASS_UP_WILDERNESS")
defineTile('t', "TREE")
defineTile("^", "MOUNTAIN_WALL")
defineTile(';', "GRASS")
defineTile("_", "FLOOR_ROAD_STONE")
defineTile(".", "FLOOR")
defineTile("M", "FLOOR", nil, "METASH")
defineTile('#', "HARDWALL")
defineTile("'", "GRASS_WOODEN_BARRICADE")
defineTile("&", "FLOOR_WOODEN_BARRICADE")
defineTile("~", "MECH_WALL")
defineTile("+", "BAMBOO_HUT_DOOR")
defineTile(">", "CAVE_IN")

defineTile('1', "HARDWALL", nil, nil, "TRAINER")
defineTile('2', "MECH_WALL", nil, nil, "MELEE_WEAPON_STORE")
defineTile('3', "MECH_WALL", nil, nil, "RANGED_WEAPON_STORE")
defineTile('4', "HARDWALL", nil, nil, "HERBALIST")
defineTile('5', "HARDWALL", nil, nil, "TINKER_STORE")
defineTile('7', "MECH_WALL", nil, nil, "LIGHT_ARMOR_STORE")
defineTile('8', "HARDWALL", nil, nil, "HEAVY_ARMOR_STORE")
defineTile('9', "HARDWALL", nil, nil, "LIBRARY")

startx = 23
starty = 0
endx = startx
endy = starty

-- addSpot section
addSpot({19, 37}, "spawn", "player")
addSpot({16, 43}, "spawn", "giants-respawn")
addSpot({17, 43}, "spawn", "giants-respawn")
addSpot({12, 35}, "spawn", "defender")
addSpot({15, 42}, "spawn", "giants")
addSpot({16, 42}, "spawn", "giants")
addSpot({17, 42}, "spawn", "giants")
addSpot({18, 42}, "spawn", "giants")
addSpot({14, 41}, "spawn", "defender")
addSpot({20, 39}, "spawn", "defender")
addSpot({17, 39}, "spawn", "defender")
addSpot({17, 44}, "feature", "down")
addSpot({4, 23}, "aaa", "aaa")
addSpot({5, 23}, "aaa", "aaa")
addSpot({6, 23}, "aaa", "aaa")
addSpot({7, 23}, "aaa", "aaa")
addSpot({8, 23}, "aaa", "aaa")
addSpot({9, 23}, "aaa", "aaa")
addSpot({10, 23}, "aaa", "aaa")
addSpot({11, 23}, "aaa", "aaa")
addSpot({12, 23}, "aaa", "aaa")
addSpot({13, 23}, "aaa", "aaa")
addSpot({14, 23}, "aaa", "aaa")
addSpot({15, 23}, "aaa", "aaa")
addSpot({16, 23}, "aaa", "aaa")
addSpot({17, 23}, "aaa", "aaa")
addSpot({18, 23}, "aaa", "aaa")
addSpot({19, 23}, "aaa", "aaa")
addSpot({20, 23}, "aaa", "aaa")
addSpot({21, 23}, "aaa", "aaa")
addSpot({4, 25}, "aaa", "aaa")
addSpot({5, 25}, "aaa", "aaa")
addSpot({6, 25}, "aaa", "aaa")
addSpot({7, 25}, "aaa", "aaa")
addSpot({8, 25}, "aaa", "aaa")
addSpot({9, 25}, "aaa", "aaa")
addSpot({10, 25}, "aaa", "aaa")
addSpot({11, 25}, "aaa", "aaa")
addSpot({12, 25}, "aaa", "aaa")
addSpot({13, 25}, "aaa", "aaa")
addSpot({14, 25}, "aaa", "aaa")
addSpot({15, 25}, "aaa", "aaa")
addSpot({16, 25}, "aaa", "aaa")
addSpot({17, 25}, "aaa", "aaa")
addSpot({18, 25}, "aaa", "aaa")
addSpot({19, 25}, "aaa", "aaa")
addSpot({20, 25}, "aaa", "aaa")
addSpot({21, 25}, "aaa", "aaa")
addSpot({22, 25}, "aaa", "aaa")
addSpot({4, 27}, "aaa", "aaa")
addSpot({5, 27}, "aaa", "aaa")
addSpot({6, 27}, "aaa", "aaa")
addSpot({7, 27}, "aaa", "aaa")
addSpot({8, 27}, "aaa", "aaa")
addSpot({9, 27}, "aaa", "aaa")
addSpot({10, 27}, "aaa", "aaa")
addSpot({11, 27}, "aaa", "aaa")
addSpot({12, 27}, "aaa", "aaa")
addSpot({13, 27}, "aaa", "aaa")
addSpot({14, 27}, "aaa", "aaa")
addSpot({15, 27}, "aaa", "aaa")
addSpot({16, 27}, "aaa", "aaa")
addSpot({17, 27}, "aaa", "aaa")
addSpot({18, 27}, "aaa", "aaa")
addSpot({19, 27}, "aaa", "aaa")
addSpot({20, 27}, "aaa", "aaa")
addSpot({21, 27}, "aaa", "aaa")
addSpot({4, 13}, "aaa", "aaa")
addSpot({5, 13}, "aaa", "aaa")
addSpot({6, 13}, "aaa", "aaa")
addSpot({7, 13}, "aaa", "aaa")
addSpot({8, 13}, "aaa", "aaa")
addSpot({9, 13}, "aaa", "aaa")
addSpot({10, 13}, "aaa", "aaa")
addSpot({11, 13}, "aaa", "aaa")
addSpot({12, 13}, "aaa", "aaa")
addSpot({13, 13}, "aaa", "aaa")
addSpot({14, 13}, "aaa", "aaa")
addSpot({15, 13}, "aaa", "aaa")
addSpot({16, 13}, "aaa", "aaa")
addSpot({17, 13}, "aaa", "aaa")
addSpot({18, 13}, "aaa", "aaa")
addSpot({19, 13}, "aaa", "aaa")
addSpot({20, 13}, "aaa", "aaa")
addSpot({21, 13}, "aaa", "aaa")
addSpot({24, 4}, "aaa", "aaa")
addSpot({25, 4}, "aaa", "aaa")
addSpot({26, 4}, "aaa", "aaa")
addSpot({27, 4}, "aaa", "aaa")
addSpot({28, 4}, "aaa", "aaa")
addSpot({29, 4}, "aaa", "aaa")
addSpot({30, 4}, "aaa", "aaa")
addSpot({31, 4}, "aaa", "aaa")
addSpot({32, 4}, "aaa", "aaa")
addSpot({33, 4}, "aaa", "aaa")
addSpot({34, 4}, "aaa", "aaa")
addSpot({35, 4}, "aaa", "aaa")
addSpot({36, 4}, "aaa", "aaa")
addSpot({37, 4}, "aaa", "aaa")
addSpot({38, 4}, "aaa", "aaa")
addSpot({39, 4}, "aaa", "aaa")
addSpot({40, 4}, "aaa", "aaa")
addSpot({41, 4}, "aaa", "aaa")
addSpot({27, 40}, "aaa", "aaa")
addSpot({28, 40}, "aaa", "aaa")
addSpot({29, 40}, "aaa", "aaa")
addSpot({30, 40}, "aaa", "aaa")
addSpot({31, 40}, "aaa", "aaa")
addSpot({32, 40}, "aaa", "aaa")
addSpot({33, 40}, "aaa", "aaa")
addSpot({34, 40}, "aaa", "aaa")
addSpot({35, 40}, "aaa", "aaa")
addSpot({36, 40}, "aaa", "aaa")
addSpot({37, 40}, "aaa", "aaa")
addSpot({38, 40}, "aaa", "aaa")
addSpot({39, 40}, "aaa", "aaa")
addSpot({40, 40}, "aaa", "aaa")
addSpot({41, 40}, "aaa", "aaa")
addSpot({42, 40}, "aaa", "aaa")
addSpot({43, 40}, "aaa", "aaa")
addSpot({44, 40}, "aaa", "aaa")

-- addZone section

-- ASCII map section
return [[
tttttt'''''''''''''''''<'''''''''''ttttttttttttttt
ttttt;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ttttttttttttttt
ttttt;;....####.......;;;;;.......;ttttttttttttttt
ttttt;;....####....................;;;;;;;tttttttt
ttttt;;;...####.....................;;;;;;;;tttttt
tttt;;;;...####......................;;;;;;ttttttt
tttt;;;;...####................M......;;;;;ttttttt
tttt;;;....####........................;;;tttttttt
tttt;;;....####.......###.......~~~~~...;;tttttttt
tttt;;.....#4##......#####......~~~~~...;ttttttttt
tttt;;...............#####......~~~~~...;ttttttttt
tttt;;................#5#.......~2~3~..;;;tttttttt
tttt;;.................................;;;;ttttttt
ttt;;;................................;;;;;;tttttt
ttt;;;........................#####;..;;;;;;tttttt
ttt;;.........................#####;;;;;;;;ttttttt
ttt;######.....~~~............#####;;;;;;;;ttttttt
ttt;######.....~~~............#####;;;tttt;;tttttt
ttt;#####......~~~..............;;;;ttttttt;;ttttt
ttt;#9#8#......~7~...............;;ttttttttttttttt
ttt;;;...................~~~~....;;ttttttttttttttt
ttt;;....................~~~~.....;;;;tttttttttttt
ttt;;.....................~~......;;;;;ttttttttttt
ttt;;;....................~~......;;;;;;tttttttttt
ttt;;;...................~~~~.....;######ttttttttt
ttt;;;;...................~~.....;;######;tttttttt
ttt;;;;...................~~.....;;######;;;tttttt
ttt;;;;...................~~.....;;######;;;tttttt
ttt;;;;......&...................;;######;tttttttt
tttt;;;......&...................;;######ttttttttt
ttttt;;..&...&.....&.............;;######ttttttttt
ttttt;;..&.&&......&..............;;;;tttttttttttt
ttttt;;............&&&.&&..........;;;tttttttttttt
tttt;;;............................;;;tttttttttttt
tt^^;;;..&.........................;;;tttttttttttt
t^^;;;..&&...&&&....................;;;;;;;^tttttt
t^^....&&.........&&.&&&&...........;;;;;;;^^ttttt
^^^^....................&&.................^^^tttt
^^^^^^...................&..................^^^^^t
^^^^^^^^......&&&....^...&...................^^^^^
^^^^^^^^^............^.......................^^^^^
^^^^^^^^^...^^......^^........................^^^^
^^^^^^^^^^^^^^^....^^^^^...........^^.........^^^^
^^^^^^^^^^^^^^^^...^^^^^^^....^....^^^^^.......^^^
^^^^^^^^^^^^^^^^...^^^^^^^^^^^^..^^^^^^^^^^^...^^^
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^]]