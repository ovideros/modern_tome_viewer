# 覆盖层审计报告 · 超集清单 B（50 条）

范围：`.snapshots/audit-superset-B.json` 的全部 50 条。每条审查「标题声明了、但公式没读」的标签
（`unused`），逐个回到 `source` 指向的 `newTalent{...}` 块，找出**真正喂给该 acronym 的 getter**
（`info` 里 `tformat(...)` 的参数顺序 ↔ acronym 顺序；嵌套 `callTalent` 的要顺藤摸瓜到被调技能的 getter），
判断该 getter 是否真的使用那个标签。

判定口径：`--overlay` 只要求 `表达式消耗 ⊆ 标题声明`，所以这 50 条**本来就是全 PASS 的**。
本报告要回答的是更细的问题：**它是「标题过度声明」还是「公式漏读」**。判据只有一条——
「把该输入从导出钉死的基准值挪开，这个值会不会跟着动」。导出把 `paradox` 钉在 300
（`pmod(300)=1.000`）、把 `stat` 钉在 100，所以漏读的公式在 15 个点上和正确的公式**数值完全相同**，
判分器分不出来。

## 汇总

| 项 | 数 |
| --- | --- |
| 审计条目 | 50 |
| 判定「源码真用未读标签」 | **15** |
| 判定「导出过度声明，公式正确」 | **35** |
| 处置「改」 | **15** |
| 未能判定 | **0** |

改动文件（只动了清单里的条目，且只写盘这两个文件）：

- `modern_tome_viewer/data/overlay-batches/batch16-chronomancy.json`（13 条）
- `modern_tome_viewer/data/overlay-batches/batch18-misc.json`（2 条）

## 两类漏读

### 1) `getExtensionModifier`（13 条 · 全是 `paradox`）

`tome-src-full/data/talents/chronomancy/chronomancer.lua:188`：

```lua
getExtensionModifier = function(self, t, value)
	local pm = getParadoxModifier(self)
	local mod = 1
	...
	value = math.floor(value * pm)   -- paradox modifier rounds down
	value = math.ceil(value * mod)
	return math.max(1, value)
end
```

所有 `getDuration = getExtensionModifier(self, t, X)` 的 getter 都真的乘 `pmod`。
原式的 note 里普遍写着「pm=1」——那正是 **导出把 paradox 钉在 300** 造成的假象。
统一形状（`X` 为源码里传给 helper 的实参，含它自己的 `floor`/`ceil`）：

```
["max",1,["floor",["*", X, ["pmod",["actor","paradox"]]]]]
```

这正是主项目已修好的 `T_TEMPORAL_REPRIEVE` 的写法。这批里 13 条同类（另可对照
`T_WARP_MINES#4` / `T_SPATIAL_TETHER#0` / `T_BANISH#2` / `T_DIMENSIONAL_ANCHOR#0` /
`T_REPULSION_FIELD#2` / `T_TEMPORAL_CLONE#0` / `T_DAMAGE_SMEARING#1` / `T_PHASE_SHIFT#0` /
`T_TEMPORAL_WAKE#0`，它们此前已带上 `pmod`，本次不在清单里）。

后果演示（以 `T_PHASE_PULSE` 为例）：paradox 300 → 675 时 `pmod` 由 1.000 升到 1.5，
持续时间本该 2/3/3/4/4 → 3/4/4/6/6，原式纹丝不动。

### 2) `getCun(15,true)`（2 条 · `灵巧`）

`misc/npcs.lua:3287` `T_PIERCING_SIGHT.seePower`：

```lua
seePower = function(self, t) return math.max(0, self:combatScale(self:getCun(15, true)*self:getTalentLevel(t), 10, 1, 80, 75, 0.25)) end,
```

`getX(mod, true) = X * mod / 100`（同库既有实证：`getMag(15,true)=魔力*0.15` 见 `T_WARP_MINES#2/#3`
已在用且 PASS；`getWil(10,true)=意志/10` 见 `T_THOUGHT_SENSE#0`；`getCun(5,true)=灵巧*5/100`
见 `T_COMBAT_STRING#0`）。所以驱动量是 `灵巧*0.15*等级`；原式写死成 `15*等级`，
恰好等于**导出把灵巧钉在 100** 时的值。灵巧滑条一动原式就错（灵巧 50 时驱动量应减半）。

## 逐条明细

`源码是否真用` 一列给出该 acronym 真正的 getter 及其使用的输入；
`新表达式` 一列 `—（保留原式）` 表示判定为标题过度声明、未改。

| 技能id | acronym | 未读标签 | 源码是否真用 | 处置 | 新表达式 |
| --- | --- | --- | --- | --- | --- |
| T_PHASE_PULSE | #2 | paradox | **真用**：`getDuration = getExtensionModifier(self,t,floor(combatTalentScale(t,2,4)))` | 改 | `["max",1,["floor",["*",["floor",["combatScale",["talentLevel"],2,1,4,5]],["pmod",["actor","paradox"]]]]]` |
| T_PIERCING_SIGHT | #0 | 灵巧 | **真用**：`seePower` 驱动量 `getCun(15,true)*getTalentLevel(t)` = 灵巧×0.15×等级 | 改 | `["max",0,["combatScale",["*",["*",["actor","灵巧"],0.15],["talentLevel"]],10,1,80,75,0.25]]` |
| T_PIERCING_SIGHT | #1 | 灵巧 | **真用**：同一 `seePower`（stealth / invis 两处读同一个 getter） | 改 | `["max",0,["combatScale",["*",["*",["actor","灵巧"],0.15],["talentLevel"]],10,1,80,75,0.25]]` |
| T_PRECOGNITION | #1 | paradox | **真用**：`getDuration = getExtensionModifier(self,t,floor(combatTalentScale(t,2,10)))` | 改 | `["max",1,["floor",["*",["floor",["combatScale",["talentLevel"],2,1,10,5]],["pmod",["actor","paradox"]]]]]` |
| T_REPULSION_FIELD | #0 | paradox | 不用：`radius = floor(combatTalentScale(t,1.5,3.5))`（同技能 #2 的 getDuration 才走 helper） | 不改 | —（保留原式） |
| T_SEE_THE_THREADS | #0 | paradox | **真用**：`getDuration = getExtensionModifier(self,t,floor(combatTalentScale(t,4,16)))` | 改 | `["max",1,["floor",["*",["floor",["max",0,["+",["*",["/",12,["-",["sqrt",5],1]],["sqrt",["talentLevel"]]],["-",4,["/",12,["-",["sqrt",5],1]]]]]],["pmod",["actor","paradox"]]]]]` |
| T_SLOW | #0 | paradox | 不用：`radius = floor(combatTalentScale(t,2.25,3.25))` | 不改 | —（保留原式） |
| T_SLOW | #1 | paradox | 不用：`getDuration = floor(combatTalentScale(t,6,10))`（该技能 getDuration **没有**走 helper） | 不改 | —（保留原式） |
| T_SPATIAL_TETHER | #3 | paradox | 不用：`radius = floor(combatTalentScale(t,1,2))`（#0 的 getDuration 才走 helper） | 不改 | —（保留原式） |
| T_STALK | #0 | 力量 | 不用：`getAttackChange` 用 `combatTalentStatDamage(t,"wil",10,30)` | 不改 | —（保留原式） |
| T_STALK | #1 | 意志 | 不用：`getStalkedDamageMultiplier` 用 `combatTalentIntervalDamage(t,"str",0.1,0.35,0.4)` | 不改 | —（保留原式） |
| T_STALK | #2 | 力量 | 不用：同 #0（bonus=2） | 不改 | —（保留原式） |
| T_STALK | #3 | 意志 | 不用：同 #1（bonus=2） | 不改 | —（保留原式） |
| T_STALK | #4 | 力量 | 不用：同 #0（bonus=3） | 不改 | —（保留原式） |
| T_STALK | #5 | 意志 | 不用：同 #1（bonus=3） | 不改 | —（保留原式） |
| T_STATIC_HISTORY | #0 | paradox | **真用**：`getDuration = getExtensionModifier(self,t,floor(1+combatTalentScale(t,1,7)))` | 改 | `["max",1,["floor",["*",["floor",["+",1,["max",0,["+",["*",["/",6,["-",["sqrt",5],1]],["sqrt",["talentLevel"]]],["-",1,["/",6,["-",["sqrt",5],1]]]]]]],["pmod",["actor","paradox"]]]]]` |
| T_STEADY_MIND | #0 | 灵巧 | 不用：`getDefense = combatTalentStatDamage(t,"dex",5,35)`；灵巧来自同 tooltip 的 getMental | 不改 | —（保留原式） |
| T_STEADY_MIND | #1 | 敏捷 | 不用：`getMental = combatTalentStatDamage(t,"cun",5,35)`；敏捷来自同 tooltip 的 getDefense | 不改 | —（保留原式） |
| T_STOP | #2 | paradox | **真用**：`getDuration = getExtensionModifier(self,t,ceil(combatTalentScale(t,2.3,4.3)))` | 改 | `["max",1,["floor",["*",["ceil",["combatScale",["talentLevel"],2.3,1,4.3,5]],["pmod",["actor","paradox"]]]]]` |
| T_TELEKINETIC_THROW | #1 | 力量 | 不用：`getDamage = floor(combatTalentMindDamage(t,10,170))`（精神强度）；力量来自 `range` 的 `combatStatScale("str",…)` | 不改 | —（保留原式） |
| T_TELEKINETIC_THROW | #2 | 力量 | 不用：同 #1 的一半 | 不改 | —（保留原式） |
| T_TEMPORAL_FUGUE | #0 | paradox | **真用**：`getDuration = getExtensionModifier(self,t,floor(combatTalentScale(t,3,8)))` | 改 | `["max",1,["floor",["*",["floor",["max",0,["+",["*",["/",5,["-",["sqrt",5],1]],["sqrt",["talentLevel"]]],["-",3,["/",5,["-",["sqrt",5],1]]]]]],["pmod",["actor","paradox"]]]]]` |
| T_TEMPORAL_VIGOUR | #0 | paradox | **真用**：`getDuration = getExtensionModifier(self,t,floor(combatTalentScale(t,1,3)))` | 改 | `["max",1,["floor",["*",["floor",["combatScale",["talentLevel"],1,1,3,5]],["pmod",["actor","paradox"]]]]]` |
| T_THERMAL_LEECH | #0 | psi | 不用：`radius = floor(combatTalentScale(t,1,4))` | 不改 | —（保留原式） |
| T_THERMAL_LEECH | #2 | psi | 不用：`getDur(self,t,0)`，源码在 info 里显式传 `psi=0`，因子 `max(0.5,1.5-0)=1.5` 是常量 | 不改 | —（保留原式） |
| T_THERMAL_LEECH | #4 | psi | 不用：`getDam(self,t,0)`，同上（显式 `psi=0`） | 不改 | —（保留原式） |
| T_THERMAL_LEECH | #6 | psi | 不用：`getLeech(self,t,0)`，同上（显式 `psi=0`） | 不改 | —（保留原式） |
| T_THOUGHT_SENSE | #0 | 精神强度 | 不用：`radius = floor(combatScale(getWil(10,true)*等级,…))`，`getWil(10,true)=意志/10`；精神强度来自 `getDefense` | 不改 | —（保留原式） |
| T_TIME_DILATION | #1 | paradox | **真用**：`getDuration = getExtensionModifier(self,t,floor(combatTalentScale(t,1,2)))` | 改 | `["max",1,["floor",["*",["floor",["combatScale",["talentLevel"],1,1,2,5]],["pmod",["actor","paradox"]]]]]` |
| T_TIME_SKIP | #1 | paradox | **真用**：`getDuration = getExtensionModifier(self,t,2+ceil(combatTalentScale(t,0.3,2.3)))` | 改 | `["max",1,["floor",["*",["+",2,["ceil",["combatScale",["talentLevel"],0.3,1,2.3,5]]],["pmod",["actor","paradox"]]]]]` |
| T_TIME_STOP | #0 | paradox | **真用**：`getDuration = getExtensionModifier(self,t,floor(combatTalentLimit(t,4,1,3)))` | 改 | `["max",1,["floor",["*",["floor",["*",4,["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],-0.7795256696436654],0.6011139393098757]]]]],["pmod",["actor","paradox"]]]]]` |
| T_TWIST_FATE | #0 | paradox | **真用**：`getDuration = getExtensionModifier(self,t,floor(combatTalentScale(t,1,6)))` | 改 | `["max",1,["floor",["*",["floor",["max",0,["+",["*",["/",5,["-",["sqrt",5],1]],["sqrt",["talentLevel"]]],["-",1,["/",5,["-",["sqrt",5],1]]]]]],["pmod",["actor","paradox"]]]]]` |
| T_WARP_BLADE | #1 | paradox | **真用**：`getDuration = getExtensionModifier(self,t,floor(combatTalentScale(t,3,7)))` | 改 | `["max",1,["floor",["*",["floor",["combatScale",["talentLevel"],3,1,7,5]],["pmod",["actor","paradox"]]]]]` |
| T_WARP_MINE_AWAY | #0 | 魔力 | 不用：伤害走 `T_WARP_MINES.getDamage` = `combatTalentSpellDamage(…,getParadoxSpellpower)`；魔力只用在同一 tooltip 的 trapPower | 不改 | —（保留原式） |
| T_WARP_MINE_AWAY | #1 | 魔力 | 不用：同 #0（temporal 一半） | 不改 | —（保留原式） |
| T_WARP_MINE_AWAY | #2 | paradox+法术强度 | 不用：`detect = trapPower*0.8`，`trapPower = max(1,combatScale(等级*getMag(15,true),…))`，只用魔力×0.15 | 不改 | —（保留原式） |
| T_WARP_MINE_AWAY | #3 | paradox+法术强度 | 不用：同 #2（disarm 本体） | 不改 | —（保留原式） |
| T_WARP_MINE_TOWARD | #0 | 魔力 | 不用：同 T_WARP_MINE_AWAY#0 | 不改 | —（保留原式） |
| T_WARP_MINE_TOWARD | #1 | 魔力 | 不用：同 T_WARP_MINE_AWAY#1 | 不改 | —（保留原式） |
| T_WARP_MINE_TOWARD | #2 | paradox+法术强度 | 不用：同 T_WARP_MINE_AWAY#2 | 不改 | —（保留原式） |
| T_WARP_MINE_TOWARD | #3 | paradox+法术强度 | 不用：同 T_WARP_MINE_AWAY#3 | 不改 | —（保留原式） |
| T_WARP_MINES | #0 | 魔力 | 不用：`/2 * spellDamage(20,200,法术强度*pmod)`；魔力只用在同一 tooltip 的 trapPower | 不改 | —（保留原式） |
| T_WARP_MINES | #1 | 魔力 | 不用：同 #0（temporal 一半） | 不改 | —（保留原式） |
| T_WARP_MINES | #2 | paradox+法术强度 | 不用：`detect = trapPower*0.8`，只用等级与魔力 | 不改 | —（保留原式） |
| T_WARP_MINES | #3 | paradox+法术强度 | 不用：同 #2（disarm 本体） | 不改 | —（保留原式） |
| T_WARP_MINES | #5 | paradox | 不用：`getRange = floor(combatTalentScale(t,5,9,0.5,0,1))` | 不改 | —（保留原式） |
| T_WEAPON_MANIFOLD | #1 | paradox | 不用：`radius = getTalentLevel(t)>=4 and 2 or 1`（纯等级阶梯） | 不改 | —（保留原式） |
| T_WEAPON_MANIFOLD | #3 | paradox | 不用：同 #1 | 不改 | —（保留原式） |
| T_WEAPON_MANIFOLD | #6 | paradox | 不用：同 #1 | 不改 | —（保留原式） |
| T_WORMHOLE | #1 | paradox | **真用**：`getDuration = getExtensionModifier(self,t,floor(combatTalentScale(t,6,10)))` | 改 | `["max",1,["floor",["*",["floor",["combatScale",["talentLevel"],6,1,10,5]],["pmod",["actor","paradox"]]]]]` |

## 未能判定

无。50 条全部给出了判定。

## 观察（超出本次清单，未改动）

- **`T_WEAPON_MANIFOLD` 的 duration 是同类潜在点，但不在导出 acronym 里**：源码
  `getDuration = getExtensionModifier(self,t,2)`（`temporal-combat.lua:272`），即
  `max(1,floor(2*pmod))`，paradox 300→675 时本该 2 → 3。但导出的 tooltip 只解析出 8 个 acronym
  （#0 chance / #1,#3,#6 radius / #2,#7 damage / #4,#5 damage/2），**没有 duration 这一格**，
  所以覆盖层无需也没法为它写公式。本次未改任何相关条目。
- **`T_PIERCING_SIGHT` 与 audit A 的 `T_AMBUSCADE#3` 同形**（都把 `getCun(15,true)` 写成了常数 15），
  但 `T_AMBUSCADE` 属 A 清单，本报告不动。
