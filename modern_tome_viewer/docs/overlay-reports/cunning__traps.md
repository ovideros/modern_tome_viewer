# 覆盖层报告 · `cunning/traps`

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/cunning__traps.json`
结果：**31/31 通过**（目标 32 条；未覆盖 1 条）

> 说明：本大系由批量代理产出，其原始分析笔记未随文件落盘；本报告由批次 JSON 与目标清单机械生成，
> 未覆盖条目的成因见总报告 `docs/expression-overlay-report.md` 的「无法建模」与「疑点」两节。

## 已完成

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_SPRINGRAZOR_TRAP | #0 | `["*",25,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]` | tome-src-full/data/talents/cunning/traps.lua:873 | ✅ |
| T_SPRINGRAZOR_TRAP | #1 | `["floor",["*",3,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | tome-src-full/data/talents/cunning/traps.lua:875 | ✅ |
| T_BEAR_TRAP | #0 | `["+",20,["*",10,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | tome-src-full/data/talents/cunning/traps.lua:951 | ✅ |
| T_BEAR_TRAP | #1 | `["+",20,["*",10,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | tome-src-full/data/talents/cunning/traps.lua:951 | ✅ |
| T_DISARMING_TRAP | #0 | `["+",10,["*",30,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | tome-src-full/data/talents/cunning/traps.lua:1013 | ✅ |
| T_DISARMING_TRAP | #1 | `["floor",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],2.1,1,4.43,5]]` | tome-src-full/data/talents/cunning/traps.lua:1014 | ✅ |
| T_PITFALL_TRAP | #0 | `["+",10,["*",25,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | tome-src-full/data/talents/cunning/traps.lua:1070 | ✅ |
| T_FLASH_BANG_TRAP | #0 | `["+",25,["*",25,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | tome-src-full/data/talents/cunning/traps.lua:1193 | ✅ |
| T_FLASH_BANG_TRAP | #1 | `["+",1,["floor",["*",2,["sqrt",["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]]]` | tome-src-full/data/talents/cunning/traps.lua:1192 | ✅ |
| T_BLADESTORM_TRAP | #0 | `["floor",["*",0.75,["floor",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],9,1,13,5]]]]` | tome-src-full/data/talents/cunning/traps.lua:1269 | ✅ |
| T_BEAM_TRAP | #0 | `["floor",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],3,1,6,5]]` | tome-src-full/data/talents/cunning/traps.lua:1325 | ✅ |
| T_BEAM_TRAP | #1 | `["/",["+",15,["/",["*",["statScale","cun",10,60],["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5]],20]],3]` | tome-src-full/data/talents/cunning/traps.lua:1326 | ✅ |
| T_POISON_GAS_TRAP | #0 | `["+",10,["*",25,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | tome-src-full/data/talents/cunning/traps.lua:1407 | ✅ |
| T_FREEZING_TRAP | #0 | `["+",10,["*",15,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | tome-src-full/data/talents/cunning/traps.lua:1486 | ✅ |
| T_FREEZING_TRAP | #1 | `["/",["+",10,["*",15,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]],3]` | tome-src-full/data/talents/cunning/traps.lua:1486 | ✅ |
| T_DRAGONSFIRE_TRAP | #0 | `["/",["+",10,["*",18,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]],3]` | tome-src-full/data/talents/cunning/traps.lua:1576 | ✅ |
| T_DRAGONSFIRE_TRAP | #1 | `["/",["+",10,["*",18,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]],2]` | tome-src-full/data/talents/cunning/traps.lua:1576 | ✅ |
| T_GRAVITIC_TRAP | #0 | `["+",10,["*",10,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","mag",1,5]]]]` | tome-src-full/data/talents/cunning/traps.lua:1667 | ✅ |
| T_GRAVITIC_TRAP | #1 | `["floor",["*",10,["-",1,["exp",["+",["*",["sqrt",["*",["actor","陷阱专精 技能等级"],["talentLevel"]]],["/",["log",["/",["-",5,10],["-",3,10]]],["-",["sqrt",6.5],["sqrt",1.3]]]],["/",["-",0,["-",["*",["-",["sqrt",6.5],["sqrt",1.3]],["log",["-",1,["/",5,10]]]],["*",["sqrt",6.5],["log",["/",["-",5,10],["-",3,10]]]]]],["-",["sqrt",1.3],["sqrt",6.5]]]]]]]]` | tome-src-full/data/talents/cunning/traps.lua:1668 | ✅ |
| T_AMBUSH_TRAP | #0 | `["floor",["*",25,["-",1,["exp",["+",["*",["sqrt",["*",["actor","陷阱专精 技能等级"],["talentLevel"]]],["/",["log",["/",["-",7,25],["-",3,25]]],["-",["sqrt",6.5],["sqrt",1.3]]]],["/",["-",0,["-",["*",["-",["sqrt",6.5],["sqrt",1.3]],["log",["-",1,["/",7,25]]]],["*",["sqrt",6.5],["log",["/",["-",7,25],["-",3,25]]]]]],["-",["sqrt",1.3],["sqrt",6.5]]]]]]]]` | tome-src-full/data/talents/cunning/traps.lua:1788 | ✅ |
| T_PURGING_TRAP | #0 | `["+",25,["*",25,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","wil",1,5]]]]` | tome-src-full/data/talents/cunning/traps.lua:1860 | ✅ |
| T_PURGING_TRAP | #1 | `["/",["+",25,["*",25,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","wil",1,5]]]],2]` | tome-src-full/data/talents/cunning/traps.lua:1860 | ✅ |
| T_PURGING_TRAP | #2 | `["/",["+",25,["*",25,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","wil",1,5]]]],4]` | tome-src-full/data/talents/cunning/traps.lua:1860 | ✅ |
| T_PURGING_TRAP | #3 | `["/",["+",25,["*",25,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","wil",1,5]]]],4]` | tome-src-full/data/talents/cunning/traps.lua:1860 | ✅ |
| T_PURGING_TRAP | #4 | `["+",25,["*",25,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","wil",1,5]]]]` | tome-src-full/data/talents/cunning/traps.lua:1860 | ✅ |
| T_PURGING_TRAP | #5 | `["floor",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],2.5,1,4.5,5]]` | tome-src-full/data/talents/cunning/traps.lua:1859 | ✅ |
| T_PURGING_TRAP | #6 | `["floor",["+",1,["*",["/",["-",3,1],["log10",5]],["log10",["*",["actor","陷阱专精 技能等级"],["talentLevel"]]]]]]` | tome-src-full/data/talents/cunning/traps.lua:1858 | ✅ |
| T_EXPLOSION_TRAP | #0 | `["+",30,["*",35,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | tome-src-full/data/talents/cunning/traps.lua:1984 | ✅ |
| T_CATAPULT_TRAP | #0 | `["+",1,["floor",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],2,1,6,5]]]` | tome-src-full/data/talents/cunning/traps.lua:2055 | ✅ |
| T_NIGHTSHADE_TRAP | #0 | `["+",20,["*",35,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | tome-src-full/data/talents/cunning/traps.lua:2175 | ✅ |
| T_NIGHTSHADE_TRAP | #1 | `["/",["+",20,["*",35,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]],10]` | tome-src-full/data/talents/cunning/traps.lua:2175 | ✅ |

## 未覆盖目标

| 技能id | acronym | 三套导出值 | 标题参数 |
| --- | --- | --- | --- |
| T_CATAPULT_TRAP | acronym#1 | 值: 89/91/92/93/94% | 89/92/93/94/95% | 90/92/93/94/95% | 参数: 陷阱专精 技能等级=1/2/3/4/5, 技能系数=1.5 |
