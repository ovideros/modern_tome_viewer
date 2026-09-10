# 覆盖层报告 · `spell/master-of-flesh`

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/spell__master-of-flesh.json`
结果：**12/12 通过**（目标 12 条；PASS 12 条，无法建模 0 条）

源码集中在一个文件：`tome-src-full/data/talents/spells/master-of-flesh.lua`
（4 个技能：Call of the Mausoleum / Corpse Explosion / Putrescent Liquefaction / Discarded Refuse）。

## 已完成

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_CALL_OF_THE_MAUSOLEUM | #0 | `["floor",["-",30,["*",20,["-",1,["exp",…a/b 形式…]]]]]`（见下方模式 1）| master-of-flesh.lua:132 | ✅ |
| T_CALL_OF_THE_MAUSOLEUM | #1 | `["max",1,["+",["actor","角色等级"],["floor",["combatScale",["talentLevel"],-6,0.9,2,5]]]]` | master-of-flesh.lua:134 | ✅ |
| T_CALL_OF_THE_MAUSOLEUM | #2 | `["max",1,["floor",["talentScale",1,5]]]` | master-of-flesh.lua:127 | ✅ |
| T_CALL_OF_THE_MAUSOLEUM | #3 | `["floor",["talentScale",5,10]]` | master-of-flesh.lua:133 | ✅ |
| T_CORPSE_EXPLOSION | #0 | `["floor",["+",3,["/",["*",5,["-",["sqrt",["talentLevel"]],1]],["-",["sqrt",5],1]]]]` | master-of-flesh.lua:256 | ✅ |
| T_CORPSE_EXPLOSION | #1 | `["spellDamage",40,200]` | master-of-flesh.lua:257 | ✅ |
| T_CORPSE_EXPLOSION | #2 | `["spellDamage",5,28]` | master-of-flesh.lua:258 | ✅ |
| T_CORPSE_EXPLOSION | #3 | `["spellDamage",40,200]` | master-of-flesh.lua:272 | ✅ |
| T_PUTRESCENT_LIQUEFACTION | #0 | `["max",1,["floor",["talentLimit",3.1,1,3]]]` | master-of-flesh.lua:289 | ✅ |
| T_PUTRESCENT_LIQUEFACTION | #2 | `["floor",["talentScale",1,2]]` | master-of-flesh.lua:290 | ✅ |
| T_PUTRESCENT_LIQUEFACTION | #3 | `["/",["spellDamage",40,400],5]` | master-of-flesh.lua:291 | ✅ |
| T_DISCARDED_REFUSE | #0 | `["floor",["+",1,["/",["*",5,["-",["sqrt",["talentLevel"]],1]],["-",["sqrt",5],1]]]]` | master-of-flesh.lua:402 | ✅ |

说明：`#1`/`#3` 两处导出值相同，源码里 `info` 的 `tformat` 确实把 **`t:_getDamage(self)` 传了两次**（blight 伤害那格用的就是 `getDamage`，不是 `getDiseasePower`），而 `getDiseasePower` 落在 #2 上。

## 发现的写法模式

1. **`combatTalentLimit` 的 `low > high`（递减）分支必须按 `a`/`b` 字面展开，不能用 `talentLimit` 闭式节点。**
   源码 `Combat.lua:1616-1619` 的求值是 `low - (low-limit)*(1 - exp(√tl·a + b))`，其中 `a`、`b` 是两个大数（`a≈-1.634`、`b≈+1.863`），相加时发生**灾难性消去**：在有效等级恰好 1.3（`√tl = √1.3 = x_low`）处数学上是 0，浮点上却是 ≈ -0.00037，于是结果 29.99 而不是 30 → 导出 **29**。
   工具的 `["talentLimit",…]` 节点用的是代数等价的闭式 `limit+(low-limit)·r^f`，`f` 恰好为 0，得 30，于是 1.3 那一点永远对不上（`算得 30 / 导出 29`）。把 `a`/`b` 按源码顺序写出来即可 15/15。
   代表技能：`T_CALL_OF_THE_MAUSOLEUM` #0（`["floor",["-",30,["*",20,["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],A],B]]]]]]]`，
   `A = ["/",["log",["/",["-",high,limit],["-",low,limit]]],["-",["sqrt",6.5],["sqrt",1.3]]]`，
   `B = ["/",["-",["*",["-",["sqrt",6.5],["sqrt",1.3]],["log",["-",1,["/",["-",low,high],["-",low,limit]]]]],["*",["sqrt",6.5],["log",["/",["-",high,limit],["-",low,limit]]]]],["-",["sqrt",6.5],["sqrt",1.3]]]`）。

2. **`combatTalentLimit` 的 `high >= low`（递增）分支用 `talentLimit` 节点即可**：`["max",1,["floor",["talentLimit",3.1,1,3]]]` 15/15。
   代表技能：`T_PUTRESCENT_LIQUEFACTION` #0。（两个方向不能一概而论：递增分支的闭式与源码等价，递减分支才会撞上模式 1 的消去误差。）

3. **`combatTalentScale` 在锚点上会被 `talentScale` 节点的浮点消去误差坑到，需展开成「除法在后」的形式。**
   节点算的是 `m·(√tl − 1) + low`，`m = (high−low)/(√5−1)`；在 `tl = 5` 处 `m·(√5−1)` 浮点上略小于 5，得 5.9999…/7.9999…，`floor` 后**少 1**（导出是 6/8）。
   改成 `low + (high−low)·(√tl−1)/(√5−1)`（先乘后除）后完全一致。
   代表技能：`T_CORPSE_EXPLOSION` #0、`T_DISCARDED_REFUSE` #0。

4. **`info` 用 `t:_getXxx(self)` 调本地 getter 是这批的通用形状**：`tformat` 的参数顺序就是 acronym 顺序，逐个跳去读 `newTalent` 块里的 `_getXxx`/`getXxx` 即可。
   若 getter 里带 `math.floor`，表达式要照抄 `["floor",…]`；带 `math.max(1, …)` 要照抄 `["max",1,…]`。

5. **`math.max(1, self.level + t:_getLevel(self))`（#1）里 `self.level` 是角色等级**，标题已把它钉成 50 → 用 `["actor","角色等级"]`，剩下 `getLevel = floor(combatScale(getTalentLevel(t), -6, 0.9, 2, 5))` 直接用 `combatScale` 节点（注意其 `power` 默认 0.5，与 `Combat.lua:1506` 的 `power or 0.5` 一致）。

6. **`damDesc(self, DamageType.X, v)` 是 passthrough**（本批 #1/#3 均如此）；`/5`、`*100` 之类的收尾运算照抄。

## 无法建模

本批 12 条目标全部跑出 PASS，**没有**跳过任何目标（也未触发 5 分钟时间盒）。以下值在同一文件里确实存在、但按规则属于不可建模，且它们**本来就不是本批 acronym 目标**（导出侧未列为待补值，故不计入失败）：

| 位置 | 值 | 原因 |
| --- | --- | --- |
| master-of-flesh.lua:27 | `soul` 消耗 `max(1, min(getNb, self:getSoul()))` | 依赖角色当前灵魂数（运行时资源状态） |
| master-of-flesh.lua:52 / 81 / 110 | `max_life = resolvers.rngavg(90,100)` 等召唤物属性 | 运行时数据表 + 随机数 |
| master-of-flesh.lua:60 / 89 / 114 | `resolvers.levelup(10,1,1)`、`dammod`、`resolvers.talents{...}` | 召唤物实体生成器，非技能等级函数 |
| master-of-flesh.lua:125 | `radius = self:getTalentRadius(self:getTalentFromId(self.T_NECROTIC_AURA))` | 依赖**别的技能**的等级/半径（该 acronym 已在导出侧有公式，未列入目标） |
| master-of-flesh.lua:224 | `mana` 实际消耗里的 `self:combatFatigue()` | 装备/状态驱动的运行时属性 |
| master-of-flesh.lua:259 / 292 / 411 | `necroArmyStats(self).nb_ghoul` | 场上召唤物计数，运行时状态 |

## 疑点

**没有遗留的源码/导出不一致**：逐条 15 点全部复现。此处只记一个**容易误判为疑点的陷阱**，供主项目复核时参考：

- `T_CALL_OF_THE_MAUSOLEUM` #0 在系数 1.30、等级 1 一点上，用 `["talentLimit",10,30,12]` 会得 `算得 30 / 导出 29`，看起来像导出侧系统性偏差。
  实际不是：源码的字面写法（`a`/`b` + `exp`）在双精度下给出 29.99…，与导出 29 一致；偏差来自 `talentLimit` 节点的**代数等价改写丢掉了消去误差**。
  换句话说，这是**求值器节点的口径问题**，不是数据缺陷——建议构建端若发现 `low > high` 的 `combatTalentLimit`，不要用闭式节点替代字面展开。附三套数据（该 acronym）：

  | 系数 | 1 | 2 | 3 | 4 | 5 |
  | --- | --- | --- | --- | --- | --- |
  | 导出 1.00 | 35 | 22 | 17 | 14 | 13 |
  | 导出 1.30 | 29 | 19 | 15 | 13 | 12 |
  | 导出 1.50 | 27 | 17 | 14 | 12 | 11 |
  | 字面展开（三套）| 35/29/27 | 22/19/17 | 17/15/14 | 14/13/12 | 13/12/11 |
  | 闭式 `talentLimit` | 同 | 1.30 套首点 ✗(30) | 同 | 同 | 同 |

- 同类的浮点边界还有 `T_CORPSE_EXPLOSION` #0 与 `T_DISCARDED_REFUSE` #0 的等级 5 点（`talentScale` 节点得 7.9999→7 / 5.9999→5，导出 8 / 6），已按模式 3 展开解决，同样不是数据缺陷。
