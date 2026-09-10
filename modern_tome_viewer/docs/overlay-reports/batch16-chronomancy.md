# 覆盖层报告 · chronomancy 16 个大系（batch16）

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/batch16-chronomancy.json`
结果：**47/47 通过**（目标 47 条；未覆盖 0 条）

范围（各大系 目标数/PASS）：manifold 10 / temporal-hounds 7 / temporal-combat 5 / stasis 4 / spacetime-weaving 3 / speed-control 3 / age-manipulation 2 / chronomancy 2 / timetravel 2 / timeline-threading 2 / energy 2 / guardian 1 / flux 1 / threaded-combat 1 / blade-threading 1 / gravity 1

判定口径：每条都跑出 `结论：PASS（三套 15 点全中，输入集合覆盖）`；`--overlay` 第一行「通过数」== 数组长度。

## 已完成

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_FOLD_FATE | #0 | `["*",40,["-",1,["exp",["+",["*",["sqrt",["*",["actor","多态武器 技能等级"],["/",["talentLevel"],["talentLevel",true]]]],-0.7795256696436654],0.6011139393098757]]]]` | tome-src-full/data/talents/chronomancy/temporal-combat.lua:274 | ✅ |
| T_FOLD_FATE | #1 | `["min",2,["+",1,["floor",["/",["*",["actor","多态武器 技能等级"],["/",["talentLevel"],["talentLevel",true]]],4]]]]` | tome-src-full/data/talents/chronomancy/temporal-combat.lua:50 | ✅ |
| T_FOLD_FATE | #2 | `["+",7,["*",["power","法术强度",["*",0.092,["pmod",["actor","paradox"]]]],["combatScale",["*",["actor","多态武器 技能等级"],["/",["talentLevel"],["talentLevel",true]]],1,1,7,5]]]` | tome-src-full/data/talents/chronomancy/temporal-combat.lua:273 | ✅ |
| T_FOLD_WARP | #0 | `["*",40,["-",1,["exp",["+",["*",["sqrt",["*",["actor","多态武器 技能等级"],["/",["talentLevel"],["talentLevel",true]]]],-0.7795256696436654],0.6011139393098757]]]]` | tome-src-full/data/talents/chronomancy/temporal-combat.lua:274 | ✅ |
| T_FOLD_WARP | #1 | `["min",2,["+",1,["floor",["/",["*",["actor","多态武器 技能等级"],["/",["talentLevel"],["talentLevel",true]]],4]]]]` | tome-src-full/data/talents/chronomancy/temporal-combat.lua:98 | ✅ |
| T_FOLD_WARP | #2 | `["/",["+",7,["*",["power","法术强度",["*",0.092,["pmod",["actor","paradox"]]]],["combatScale",["*",["actor","多态武器 技能等级"],["/",["talentLevel"],["talentLevel",true]]],1,1,7,5]]],2]` | tome-src-full/data/talents/chronomancy/temporal-combat.lua:130 | ✅ |
| T_FOLD_WARP | #3 | `["/",["+",7,["*",["power","法术强度",["*",0.092,["pmod",["actor","paradox"]]]],["combatScale",["*",["actor","多态武器 技能等级"],["/",["talentLevel"],["talentLevel",true]]],1,1,7,5]]],2]` | tome-src-full/data/talents/chronomancy/temporal-combat.lua:130 | ✅ |
| T_FOLD_GRAVITY | #0 | `["*",40,["-",1,["exp",["+",["*",["sqrt",["*",["actor","多态武器 技能等级"],["/",["talentLevel"],["talentLevel",true]]]],-0.7795256696436654],0.6011139393098757]]]]` | tome-src-full/data/talents/chronomancy/temporal-combat.lua:274 | ✅ |
| T_FOLD_GRAVITY | #1 | `["min",2,["+",1,["floor",["/",["*",["actor","多态武器 技能等级"],["/",["talentLevel"],["talentLevel",true]]],4]]]]` | tome-src-full/data/talents/chronomancy/temporal-combat.lua:141 | ✅ |
| T_FOLD_GRAVITY | #2 | `["+",7,["*",["power","法术强度",["*",0.092,["pmod",["actor","paradox"]]]],["combatScale",["*",["actor","多态武器 技能等级"],["/",["talentLevel"],["talentLevel",true]]],1,1,7,5]]]` | tome-src-full/data/talents/chronomancy/temporal-combat.lua:273 | ✅ |
| T_INVIGORATE | #0 | `["max",1,["floor",["*",14,["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],-0.3624587951042149],0.07679437416765682]]]]]]` | tome-src-full/data/talents/chronomancy/temporal-combat.lua:232 | ✅ |
| T_WEAPON_MANIFOLD | #1 | `["min",2,["+",1,["floor",["/",["talentLevel"],4]]]]` | tome-src-full/data/talents/chronomancy/temporal-combat.lua:271 | ✅ |
| T_WEAPON_MANIFOLD | #3 | `["min",2,["+",1,["floor",["/",["talentLevel"],4]]]]` | tome-src-full/data/talents/chronomancy/temporal-combat.lua:271 | ✅ |
| T_WEAPON_MANIFOLD | #6 | `["min",2,["+",1,["floor",["/",["talentLevel"],4]]]]` | tome-src-full/data/talents/chronomancy/temporal-combat.lua:271 | ✅ |
| T_BREACH | #1 | `["floor",["combatScale",["talentLevel"],3,1,7,5]]` | tome-src-full/data/talents/chronomancy/temporal-combat.lua:312 | ✅ |
| T_TEMPORAL_HOUNDS | #4 | `["+",11,["statDamage","mag",10,150]]` | tome-src-full/data/talents/chronomancy/temporal-hounds.lua:238 | ✅ |
| T_TEMPORAL_HOUNDS | #5 | `["+",11,["statDamage","mag",10,150]]` | tome-src-full/data/talents/chronomancy/temporal-hounds.lua:238 | ✅ |
| T_TEMPORAL_HOUNDS | #6 | `["+",11,["statDamage","mag",10,150]]` | tome-src-full/data/talents/chronomancy/temporal-hounds.lua:238 | ✅ |
| T_TEMPORAL_HOUNDS | #7 | `["+",11,["statDamage","mag",10,150]]` | tome-src-full/data/talents/chronomancy/temporal-hounds.lua:238 | ✅ |
| T_TEMPORAL_HOUNDS | #8 | `["+",11,["statDamage","mag",10,150]]` | tome-src-full/data/talents/chronomancy/temporal-hounds.lua:238 | ✅ |
| T_TEMPORAL_HOUNDS | #9 | `["+",11,["statDamage","mag",10,150]]` | tome-src-full/data/talents/chronomancy/temporal-hounds.lua:238 | ✅ |
| T_TEMPORAL_VIGOUR | #0 | `["max",1,["floor",["combatScale",["talentLevel"],1,1,3,5]]]` | tome-src-full/data/talents/chronomancy/temporal-hounds.lua:347 | ✅ |
| T_CHRONO_TIME_SHIELD | #1 | `["min",15,["max",5,["+",5,["floor",["talentLevel"]]]]]` | tome-src-full/data/talents/chronomancy/stasis.lua:52 | ✅ |
| T_CHRONO_TIME_SHIELD | #2 | `["+",25,["min",35,["max",15,["+",15,["floor",["*",["talentLevel"],2]]]]]]` | tome-src-full/data/talents/chronomancy/stasis.lua:53 | ✅ |
| T_STOP | #2 | `["max",1,["ceil",["combatScale",["talentLevel"],2.3,1,4.3,5]]]` | tome-src-full/data/talents/chronomancy/stasis.lua:87 | ✅ |
| T_STATIC_HISTORY | #0 | `["max",1,["floor",["+",1,["max",0,["+",["*",["/",6,["-",["sqrt",5],1]],["sqrt",["talentLevel"]]],["-",1,["/",6,["-",["sqrt",5],1]]]]]]]]` | tome-src-full/data/talents/chronomancy/stasis.lua:129 | ✅ |
| T_DIMENSIONAL_SHIFT | #0 | `["ceil",["talentLevel"]]` | tome-src-full/data/talents/chronomancy/spacetime-weaving.lua:99 | ✅ |
| T_WORMHOLE | #1 | `["max",1,["floor",["combatScale",["talentLevel"],6,1,10,5]]]` | tome-src-full/data/talents/chronomancy/spacetime-weaving.lua:140 | ✅ |
| T_PHASE_PULSE | #2 | `["max",1,["floor",["combatScale",["talentLevel"],2,1,4,5]]]` | tome-src-full/data/talents/chronomancy/spacetime-weaving.lua:258 | ✅ |
| T_CELERITY | #1 | `["max",1,["floor",["combatScale",["talentLevel"],1,1,2,5]]]` | tome-src-full/data/talents/chronomancy/speed-control.lua:27 | ✅ |
| T_TIME_DILATION | #1 | `["max",1,["floor",["combatScale",["talentLevel"],1,1,2,5]]]` | tome-src-full/data/talents/chronomancy/speed-control.lua:50 | ✅ |
| T_TIME_STOP | #0 | `["max",1,["floor",["*",4,["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],-0.7795256696436654],0.6011139393098757]]]]]]` | tome-src-full/data/talents/chronomancy/speed-control.lua:102 | ✅ |
| T_TEMPORAL_FUGUE_OLD | #1 | `["min",50,["*",["talentLevel",true],10]]` | tome-src-full/data/talents/chronomancy/age-manipulation.lua:68 | ✅ |
| T_ASHES_TO_ASHES | #2 | `["+",5,["ceil",["talentLevel"]]]` | tome-src-full/data/talents/chronomancy/age-manipulation.lua:104 | ✅ |
| T_PRECOGNITION | #1 | `["max",1,["floor",["combatScale",["talentLevel"],2,1,10,5]]]` | tome-src-full/data/talents/chronomancy/chronomancy.lua:30 | ✅ |
| T_SEE_THE_THREADS | #0 | `["max",1,["floor",["max",0,["+",["*",["/",12,["-",["sqrt",5],1]],["sqrt",["talentLevel"]]],["-",4,["/",12,["-",["sqrt",5],1]]]]]]]` | tome-src-full/data/talents/chronomancy/chronomancy.lua:172 | ✅ |
| T_TIME_SKIP | #1 | `["max",1,["floor",["+",2,["ceil",["combatScale",["talentLevel"],0.3,1,2.3,5]]]]]` | tome-src-full/data/talents/chronomancy/timetravel.lua:132 | ✅ |
| T_TEMPORAL_REPRIEVE | #0 | `["max",1,["floor",["combatScale",["talentLevel"],2,1,6,5]]]` | tome-src-full/data/talents/chronomancy/timetravel.lua:223 | ✅ |
| T_TEMPORAL_FUGUE | #0 | `["max",1,["floor",["max",0,["+",["*",["/",5,["-",["sqrt",5],1]],["sqrt",["talentLevel"]]],["-",3,["/",5,["-",["sqrt",5],1]]]]]]]` | tome-src-full/data/talents/chronomancy/timeline-threading.lua:120 | ✅ |
| T_BRAID_LIFELINES | #0 | `["max",1,["floor",["combatScale",["talentLevel"],3,1,7,5]]]` | tome-src-full/data/talents/chronomancy/timeline-threading.lua:197 | ✅ |
| T_ENERGY_ABSORPTION | #0 | `["+",1,["floor",["*",3,["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],-0.7795256696436654],0.8887960117616567]]]]]]` | tome-src-full/data/talents/chronomancy/energy.lua:73 | ✅ |
| T_ENTROPY | #0 | `["max",1,["floor",["max",0,["+",["*",["/",6,["-",["sqrt",5],1]],["sqrt",["talentLevel"]]],["-",1,["/",6,["-",["sqrt",5],1]]]]]]]` | tome-src-full/data/talents/chronomancy/energy.lua:167 | ✅ |
| T_STRENGTH_OF_PURPOSE | #0 | `["*",100,["/",["sqrt",["/",["talentLevel"],5]],1.5]]` | tome-src-full/data/talents/chronomancy/guardian.lua:26 | ✅ |
| T_TWIST_FATE | #0 | `["max",1,["floor",["max",0,["+",["*",["/",5,["-",["sqrt",5],1]],["sqrt",["talentLevel"]]],["-",1,["/",5,["-",["sqrt",5],1]]]]]]]` | tome-src-full/data/talents/chronomancy/flux.lua:156 | ✅ |
| T_BLENDED_THREADS | #0 | `["ceil",["talentLevel"]]` | tome-src-full/data/talents/chronomancy/threaded-combat.lua:150 | ✅ |
| T_WARP_BLADE | #1 | `["max",1,["floor",["combatScale",["talentLevel"],3,1,7,5]]]` | tome-src-full/data/talents/chronomancy/blade-threading.lua:36 | ✅ |
| T_GRAVITY_WELL | #0 | `["max",1,["floor",["combatScale",["talentLevel"],4,1,8,5]]]` | tome-src-full/data/talents/chronomancy/gravity.lua:233 | ✅ |

## 发现的写法模式

1. **子技能等级 = 轴 × 技能系数**（manifold 家族）。`T_FOLD_FATE/WARP/GRAVITY` 的 `getChance/getDamage/getResists/getDuration` 全部是
   `self:callTalent(self.T_WEAPON_MANIFOLD, "getX")`，所以真正驱动量是 **Weapon Manifold 的有效等级**；导出把
   `多态武器 技能等级` 当轴（ladder 1–5，原始），有效等级 = 轴 × 技能系数。节点层写法：
   `["*",["actor","多态武器 技能等级"],["/",["talentLevel"],["talentLevel",true]]]`（`talentLevel`/`raw` 之比就是系数）。
   代表：`T_FOLD_FATE #2`（damage = 7 + getParadoxSpellpower(self,t,0.092) * combatTalentScale(t,1,7)）。

2. **`getExtensionModifier(self,t,v)` 是本批 paradox 唯一真正被消费的地方**：`floor(v*pm)` → `ceil(·*mod)` → `max(1,·)`。
   paradox=300 时 `pm=1`、无 Extension 时 `mod=1`，整条退化为 `max(1, floor(v))`（或 `max(1, v)`）。
   代表：`T_CHRONO_TIME_SHIELD #1`（`util.bound(5+floor(tl),5,15)`）、`T_ASHES_TO_ASHES #2`。
   其余带 `paradox 300` 的 acronym 大多只是在标题里声明（超集），值本身不读它。

3. **`combatTalentScale` 的浮点结合次序必须照抄 Lua**。内置 `["combatScale",L,low,1,high,5]` 按 `m*(x^p−1^p)+low` 结合，
   Lua 按 `m*tl^p + (low − m)` 结合；两者在 `tl=high` 锚点上可能差 1 ulp，而锚点值常是整数，`floor` 后差 1。
   凡 `floor/ceil(combatTalentScale)` 的条目，本批改成手写
   `["+",["*",["/",(high−low),["-",["sqrt",5],1]],["sqrt",L]],["-",low,["/",(high−low),["-",["sqrt",5],1]]]]`。
   代表：`T_STATIC_HISTORY #0`（内置给 8，Lua 给 6.999999999999999→7）、`T_SEE_THE_THREADS #0`（内置 16，Lua 15）、
   `T_ENTROPY #0`（内置 7，Lua 6）、`T_TEMPORAL_FUGUE #0`（内置 7.999999999999999，Lua 8）、`T_TWIST_FATE #0`。

4. **表达式语言没有比较节点，阈值阶梯用算术复刻**：`getTalentLevel(T_WEAPON_MANIFOLD) >= 4 and 2 or 1` 写成
   `["min",2,["+",1,["floor",["/",L,4]]]]`。代表：`T_FOLD_FATE #1`（三套 1/1/1/2/2、1/1/1/2/2、1/1/2/2/2 全中）。

5. **`combatTalentLimit` 必须按源码指数式展开**。内置 `["talentLimit",limit,low,high]` 用的是三个锚点间的几何插值、
   而且只能吃本技能等级；子技能等级驱动 / `floor` 包住的场景要写 `limit*(1−exp(sqrt(tl)*a+b))`，
   `a=ln((high−limit)/(low−limit))/(sqrt(5m)−sqrt(m))`、`b` 同 Combat.lua:1606，`m` 默认 1.3。
   代表：`T_INVIGORATE #0`（内置节点在 tl=1.3 给 4，Lua 浮点给 3.9999999999999992→3）、`T_TIME_STOP #0`、`T_FOLD_FATE #0`。

6. **原始等级 vs 有效等级**：三套系数下数字完全相同的按原始等级算，用 `["talentLevel",true]`；
   三套各不相同的按有效等级 `["talentLevel"]`。代表：`T_TEMPORAL_FUGUE_OLD #1`（`min(50, raw*10)`）对 `T_DIMENSIONAL_SHIFT #0`（`ceil(tl)`）。
   `ceil(getTalentLevel(t))` 是本批第二个高频家族：`T_DIMENSIONAL_SHIFT #0`、`T_BLENDED_THREADS #0`。

7. **同一 getter 被多个 acronym 复用**：`T_TEMPORAL_HOUNDS #4–#9` 六个缩写同值（`incStats.str+1 … cun+1` = `11+combatTalentStatDamage(t,"mag",10,150)`）；
   `T_WEAPON_MANIFOLD #1/#3/#6` 三处 radius 同式。

## 无法建模

（无——本批 47 条全部落成可判定表达式）

## 疑点

1. **`T_ENERGY_ABSORPTION #0`：源码快照与导出系统性不一致（已按导出版本落公式）**。
   源码 `energy.lua:73`：`getTalentCount = 1 + math.floor(self:combatTalentLimit(t, 3, 0.1, 2, false, 1.0))`。
   在 技能等级 1 / 系数 1.00 时 `x_low=sqrt(1.0)=1`，结果恰为锚点 `low=0.1`，`1+floor(0.1)=1` —— **该式的最小值就是 1**，
   但导出首点是 **0**。逐点核对：导出三套为 1.00 `0/1/2/2/2`、1.30 `0/1/2/2/3`、1.50 `1/2/2/2/3`；
   它们被**旧参数化** `1 + floor(combatTalentLimit(t, 3, 0, 2))`（`low=0`、`mastery` 取默认 `1.3`）15 点精确复现。
   本批次按导出版本落公式（解析器无从分辨），`note` 已写明。
2. **内置 `["talentLimit",…]` 节点的函数形状与 Lua `combatTalentLimit` 不同**（只在 low/high/mastery 三个锚点重合），
   凡 `floor/ceil` 包住它的值都可能差 1；本批 `T_INVIGORATE #0`、`T_TIME_STOP #0`、`T_ENERGY_ABSORPTION #0` 都改用源码展开。
   建议解析器把 `talentLimit` 改成与 `combatLimit` 同级的精确指数实现。
3. **标题过度声明 paradox（非缺陷，判定按"覆盖"通过）**：下列 acronym 的 title 带 `paradox 300`，但值只依赖技能等级，
   表达式消耗为空集 —— `T_FOLD_FATE #0/#1`、`T_FOLD_WARP #0/#1`、`T_FOLD_GRAVITY #0/#1`、`T_WEAPON_MANIFOLD #1/#3/#6`、
   `T_TEMPORAL_VIGOUR #0`、`T_CHRONO_TIME_SHIELD #1/#2`、`T_STOP #2`、`T_STATIC_HISTORY #0`、`T_TIME_SKIP #1`、
   `T_TEMPORAL_REPRIEVE #0`、`T_TEMPORAL_FUGUE #0`、`T_BRAID_LIFELINES #0`、`T_ENTROPY #0`、`T_WARP_BLADE #1`、`T_GRAVITY_WELL #0`。
   工具显示 `✅ 覆盖（标题是超集，本值未用到：paradox）`。
