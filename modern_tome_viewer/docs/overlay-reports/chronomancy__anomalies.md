# 覆盖层报告 · `chronomancy/anomalies`

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/chronomancy__anomalies.json`
结果：**29/29 通过**（目标 29 条；未覆盖 0 条）

> 说明：本大系由批量代理产出，其原始分析笔记未随文件落盘；本报告由批次 JSON 与目标清单机械生成，
> 未覆盖条目的成因见总报告 `docs/expression-overlay-report.md` 的「无法建模」与「疑点」两节。

## 已完成

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_ANOMALY_REARRANGE | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:57 | ✅ |
| T_ANOMALY_TELEPORT | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:57 | ✅ |
| T_ANOMALY_TELEPORT | #1 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],80,20,20,40,100]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:51 | ✅ |
| T_ANOMALY_DISPLACEMENT_SHIELD | #0 | `["*",2,["*",["/",2,3],["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],20,10,220,100,0.75]]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:28 | ✅ |
| T_ANOMALY_PROBABILITY_TRAVEL | #0 | `["*",2,["ceil",["*",0.75,["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],4,10,12,100,0.75]]]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:44 | ✅ |
| T_ANOMALY_PROBABILITY_TRAVEL | #1 | `["ceil",["*",0.75,["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],4,10,12,100,0.75]]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:44 | ✅ |
| T_ANOMALY_BLINK | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:57 | ✅ |
| T_ANOMALY_BLINK | #1 | `["ceil",["*",0.75,["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],4,10,12,100,0.75]]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:44 | ✅ |
| T_ANOMALY_SLOW | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:57 | ✅ |
| T_ANOMALY_SLOW | #1 | `["*",100,["-",1,["/",1,["+",1,["/",["ceil",["*",0.75,["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],10,10,50,100,0.75]]],100]]]]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:649 | ✅ |
| T_ANOMALY_HASTE | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:57 | ✅ |
| T_ANOMALY_HASTE | #1 | `["*",100,["-",1,["/",1,["+",1,["/",["ceil",["*",0.75,["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],10,10,50,100,0.75]]],100]]]]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:699 | ✅ |
| T_ANOMALY_STOP | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:57 | ✅ |
| T_ANOMALY_TEMPORAL_BUBBLE | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:57 | ✅ |
| T_ANOMALY_TEMPORAL_SHIELD | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:57 | ✅ |
| T_ANOMALY_INVIGORATE | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:57 | ✅ |
| T_ANOMALY_GRAVITY_PULL | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:57 | ✅ |
| T_ANOMALY_DIG | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:57 | ✅ |
| T_ANOMALY_ENTROPY | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:57 | ✅ |
| T_ANOMALY_ENTROPY | #1 | `["ceil",["*",0.75,["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],4,10,12,100,0.75]]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:44 | ✅ |
| T_ANOMALY_GRAVITY_WELL | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:57 | ✅ |
| T_ANOMALY_QUAKE | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:57 | ✅ |
| T_ANOMALY_FLAWED_DESIGN | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:57 | ✅ |
| T_ANOMALY_FLAWED_DESIGN | #1 | `["ceil",["*",0.75,["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],10,10,50,100,0.75]]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:39 | ✅ |
| T_ANOMALY_CALCIFY | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:57 | ✅ |
| T_ANOMALY_CALCIFY | #1 | `["ceil",["*",0.75,["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],4,10,12,100,0.75]]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:44 | ✅ |
| T_ANOMALY_DEUS_EX | #0 | `["ceil",["*",0.75,["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],4,10,12,100,0.75]]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:44 | ✅ |
| T_ANOMALY_MASS_DIG | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | tome-src-full/data/talents/chronomancy/anomalies.lua:57 | ✅ |
| T_ANOMALY_TEMPORAL_STORM | #2 | `["/",["combatScale",["power","法术强度",["*",1,["pmod",["actor","paradox"]]]],10,10,50,100,0.75],3]` | tome-src-full/data/talents/chronomancy/anomalies.lua:1020 | ✅ |

## 未覆盖目标

（无）
