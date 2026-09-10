# 覆盖层报告 · `cursed/shadows`

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/cursed__shadows.json`
结果：**13/13 通过**（目标 13 条；未覆盖 0 条）

> 说明：本大系由批量代理产出，其原始分析笔记未随文件落盘；本报告由批次 JSON 与目标清单机械生成，
> 未覆盖条目的成因见总报告 `docs/expression-overlay-report.md` 的「无法建模」与「疑点」两节。

## 已完成

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_CALL_SHADOWS | #0 | `["min",4,["max",1,["floor",["*",0.55,["talentLevel"]]]]]` | tome-src-full/data/talents/cursed/shadows.lua:350 | ✅ |
| T_CALL_SHADOWS | #2 | `["talentLevel",true]` | tome-src-full/data/talents/cursed/shadows.lua:362 | ✅ |
| T_CALL_SHADOWS | #3 | `["talentLevel",true]` | tome-src-full/data/talents/cursed/shadows.lua:359 | ✅ |
| T_CALL_SHADOWS | #4 | `["max",0,["min",100,["combatScale",["talentLevel"],5,1,85,5]]]` | tome-src-full/data/talents/cursed/shadows.lua:353 | ✅ |
| T_SHADOW_WARRIORS | #0 | `["floor",["*",23,["-",["sqrt",["talentLevel"]],0.5]]]` | tome-src-full/data/talents/cursed/shadows.lua:482 | ✅ |
| T_SHADOW_WARRIORS | #1 | `["floor",["*",35,["-",["sqrt",["talentLevel"]],0.5]]]` | tome-src-full/data/talents/cursed/shadows.lua:479 | ✅ |
| T_SHADOW_WARRIORS | #2 | `["talentLevel",true]` | tome-src-full/data/talents/cursed/shadows.lua:485 | ✅ |
| T_SHADOW_WARRIORS | #3 | `["combatLimit",["^",["talentLevel"],0.5],100,7,1,15.65,2.23]` | tome-src-full/data/talents/cursed/shadows.lua:491 | ✅ |
| T_SHADOW_WARRIORS | #4 | `["max",3,["-",8,["talentLevel",true]]]` | tome-src-full/data/talents/cursed/shadows.lua:525 | ✅ |
| T_SHADOW_MAGES | #1 | `["talentLevel",true]` | tome-src-full/data/talents/cursed/shadows.lua:550 | ✅ |
| T_SHADOW_MAGES | #2 | `["combatLimit",["^",["talentLevel"],0.5],100,7,1,15.65,2.23]` | tome-src-full/data/talents/cursed/shadows.lua:536 | ✅ |
| T_SHADOW_MAGES | #3 | `["*",["talentLevel",true],["max",0,["min",1,["-",["floor",["talentLevel"]],2]]]]` | tome-src-full/data/talents/cursed/shadows.lua:553 | ✅ |
| T_SHADOW_MAGES | #4 | `["*",["combatLimit",["^",["talentLevel"],0.5],100,7,1,15.65,2.23],["max",0,["min",1,["-",["floor",["talentLevel"]],2]]]]` | tome-src-full/data/talents/cursed/shadows.lua:543 | ✅ |

## 未覆盖目标

（无）
