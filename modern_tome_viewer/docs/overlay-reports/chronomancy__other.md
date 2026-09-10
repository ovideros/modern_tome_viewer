# 覆盖层报告 · `chronomancy/other`

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/chronomancy__other.json`
结果：**12/12 通过**（该 tree 目标 28 条；16 条见「无法建模 / 疑点」）

汇总行：`覆盖层校验：12/12 通过`

## 已完成

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_DREDGE_FRENZY | #4 | `["*",-100,["combatLimit",["spellDamage",10,50],1,0,0,0.329,32.9]]` | misc/npcs.lua:1672 | ✅ |
| T_SEVER_LIFELINE | #0 | `["*",10000,["spellDamage",20,220,["power","法术强度",["pmod",["actor","paradox"]]]]]` | misc/npcs.lua:1722 | ✅ |
| T_WARP_MINE_TOWARD | #4 | `["floor",["*",["floor",["combatScale",["*",["actor","时空地雷 技能等级"],["talentLevel"]],6,1,10,5,0.5]],["pmod",["actor","paradox"]]]]` | spacetime-folding.lua:216 | ✅ |
| T_WARP_MINE_AWAY | #4 | 同 #4（共用 `T_WARP_MINES.getDuration`）| spacetime-folding.lua:216 | ✅ |
| T_SPACETIME_MASTERY | #0 | `["floor",["*",10,X]]` | other.lua:188 | ✅ |
| T_SPACETIME_MASTERY | #1 | `["floor",["*",20,X]]` | other.lua:188 | ✅ |
| T_REPULSION_FIELD | #2 | `["floor",["*",["floor",["talentScale",4,8]],["pmod",["actor","paradox"]]]]` | other.lua:493 | ✅ |
| T_TEMPORAL_CLONE | #0 | `["floor",["*",["floor",["talentScale",6,12]],["pmod",["actor","paradox"]]]]` | other.lua:537 | ✅ |
| T_DAMAGE_SMEARING | #1 | `["floor",["*",["floor",["talentScale",3,6]],["pmod",["actor","paradox"]]]]` | other.lua:611 | ✅ |
| T_PHASE_SHIFT | #0 | `["floor",["*",["floor",["talentLimit",25,3,7,true]],["pmod",["actor","paradox"]]]]` | other.lua:645 | ✅ |
| T_SWAP | #1 | `["min",50,["*",["talentLevel",true],10]]` | other.lua:669 | ✅ |
| T_TEMPORAL_WAKE | #0 | `["floor",["*",["floor",["talentScale",3,7]],["pmod",["actor","paradox"]]]]` | other.lua:738 | ✅ |

其中 `X` = `combatTalentLimit(0.8, 0.1, 0.5)` 的 **Lua 运算顺序**展开（完整字面量见批次文件）：

```json
["*",0.8,["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],A],B]]]]
A = ["/",["log",["/",["-",0.5,0.8],["-",0.1,0.8]]],["-",["sqrt",6.5],["sqrt",1.3]]]
B = ["/",["-",0,["-",["*",["-",["sqrt",6.5],["sqrt",1.3]],["log",["-",1,["/",0.5,0.8]]]],
                      ["*",["sqrt",6.5],["log",["/",["-",0.5,0.8],["-",0.1,0.8]]]]]],
         ["-",["sqrt",1.3],["sqrt",6.5]]]
```

（配合 `["floor",["*",scale,X]]`，scale 分别取 10 / 20。）

## 发现的写法模式

1. **`getExtensionModifier(self, t, value)` 包裹 = paradox 唯一被真正消费的地方**（`tome-src-full/data/talents/chronomancy/chronomancer.lua:188`）：
   `value = floor(value * pmod)`，等价表达式 `["floor",["*",<inner>,["pmod",["actor","paradox"]]]]`。
   本大系的 duration 类值全部是这个形状（12 条 PASS 里占 6 条）。
   **反过来**：凡是不含 `getExtensionModifier` 的 acronym，数值虽然 15/15 全中，却过不了 paradox 声明闸门（见「疑点」）。

2. **必须按 Lua 的运算顺序手工展开 `combatTalentLimit` / `combatTalentSpellDamage`**（新增的重要发现）。
   节点表的 `["talentLimit",…]` 与 `combatTalentSpellDamage` 族用的是**代数等价但重排过**的写法：
   - 节点：`limit + (low-limit)*((high-limit)/(low-limit))**fraction`
   - 源码（Combat.lua:1606）：`limit*(1-exp(sqrt(tl)*a+b))`
   两者在锚点 `tl = sqrt(1.3) / sqrt(6.5)`（即系数 1.30 套的等级 1 / 等级 5）上浮点结果会落在整数的两侧：
   节点得 `10.000000000000002`，源码得 `9.999999999999998`，经 `%d` 截断就是 **10 vs 9**。
   代表技能：`T_SPACETIME_MASTERY` #0/#1（1.3 套第 5 点差 1）、`T_DAMAGE_SMEARING` #0（1.3 套第 1、5 点差 1）。
   做法：照抄 `a`、`b` 的算式，用 `["exp"]`/`["log"]`/`["sqrt"]` 展开即可精确复现（本报告已完成表里的两条已实测 15/15）。
   同样地 `combatTalentSpellDamage` 的 Lua 顺序是 `(base+P)*S*(max/((base+100)*K))` 而非 `(base+P)*S*max/D`，逐条核对过 `T_CARBON_SPIKES` #1 两种写法浮点结果一致，本例不是它造成的。

3. **嵌套描述里「别的技能等级」当轴时，系数只能借 `["talentLevel"]` 取**。
   `T_WARP_MINE_TOWARD/AWAY` 的 title 轴是 `时空地雷 技能等级 1-5`：`parseAcronymTitle` 把它标成 `talentLevel` 但 label ≠ `技能等级`，
   于是 `defaultSimParams` 的 `talentLevel` 回落到 **1**，`["talentLevel"]` 的值恰好等于**技能系数**（1.00/1.30/1.50）。
   被嵌技能 `T_WARP_MINES` 的**有效**等级因此写成
   `["*",["actor","时空地雷 技能等级"],["talentLevel"]]`（原始等级 × 系数）。
   再配合模式 4 展开 `combatTalentScale`，`#4` 即 15/15。
   注：轴本身在 `consumedInputs` 里被按 label 过滤掉，所以走 `["actor","时空地雷 技能等级"]` 与 `["talentRef","T_WARP_MINES"]`
   （会被 `bindTalentRefs` 重写成同一个 actor 查找）在闸门上是等价的。

4. **`combatTalentScale(t, low, high)` @ 任意等级 L** ⟺ `["combatScale", L, low, 1, high, 5, 0.5]`（默认 power 0.5）。
   本批用于 `#4` 的 `getDuration`；轴是原生 `技能等级` 时直接用 `["talentScale",low,high]` 更短（其余 5 条 duration 用了后者）。

5. **原始等级 vs 有效等级**：三套数字完全相同 ⇒ 按 `getTalentLevelRaw` 计算，写 `["talentLevel",true]`。
   代表：`T_SWAP` #1（`min(50, raw*10)`，三套同为 10/20/30/40/50）、`T_PHASE_SHIFT` #0（`combatTalentLimit(...,raw=true)`，三套同为 2/3/4/5/6）。

## 无法建模

| 技能id | acronym#N | 原因 |
| --- | --- | --- |
| T_SPACETIME_TUNING | #0 | **导出标题里有两个 5 点轴**（`意志 10,25,50,75,100` 与 `法术强度 10,25,50,75,100`），`ladderAxis()` 要求除轴以外每个参数都只有一个值，于是三套全部返回「标题里没有唯一可变的轴」，表达式再对也无法判定。源码本身是清楚的：`#0 = getParadoxSpellpower`（吃法术强度）、`#1 = -2×意志`、`#2 = max(0, paradox - 2×意志)`（吃意志），但工具结构上无法指定「这个 acronym 的轴是哪一个」。 |
| T_SPACETIME_TUNING | #1 | 同上 |
| T_SPACETIME_TUNING | #2 | 同上 |

（实测输出：`输入集合：标题声明 [无] vs 表达式消耗 [无] ✅`，但三套均为 `✗ 标题里没有唯一可变的轴` → `结论：FAIL`。
即 `declared`/`consumed` 都退化成空数组，闸门「看起来通过」，真正拦下的是定轴失败。这属于导出侧参数建模缺陷，不是公式写不出来。）

## 疑点

### 1. 标题过度声明输入 → 输入集合是超集（12 条，数值**全部 15/15 全中**）

这类不是公式问题：表达式逐点复现三套 15 个数字，但 `declaredInputs ⊋ consumedInputs`，等号闸门直接 FAIL。
按要求**没有为了凑输入集合硬塞节点**。

| 技能id | acronym#N | 源码公式（数值已 15/15 复现） | 标题声明 vs 消耗 |
| --- | --- | --- | --- |
| T_SLOW | #0 | `["floor",["talentScale",2.25,3.25]]`（other.lua:144 radius） | `[paradox]` vs `[无]` |
| T_SLOW | #1 | `["floor",["talentScale",6,10]]`（other.lua:152 getDuration） | `[paradox]` vs `[无]` |
| T_REPULSION_FIELD | #0 | `["floor",["talentScale",1.5,3.5]]`（other.lua:488 radius） | `[paradox]` vs `[无]` |
| T_DAMAGE_SMEARING | #0 | `combatTalentLimit(t,50,10,30)`（other.lua:610 getPercent，Lua 顺序展开后 15/15） | `[paradox]` vs `[无]` |
| T_WARP_MINE_TOWARD | #0 | `T_WARP_MINES.getDamage/2`，`combatTalentSpellDamage(20,200,getParadoxSpellpower)` | `[paradox, 法术强度, 魔力]` vs `[paradox, 法术强度]`（多声明 `魔力`）|
| T_WARP_MINE_TOWARD | #1 | 同 #0（物理/时空两份，数值相同） | 同上 |
| T_WARP_MINE_TOWARD | #2 | `floor(0.8 × trapPower)`，`trapPower = max(1, combatScale(getTalentLevel(t)*getMag(15,true),0,0,75,75))` | `[paradox, 法术强度, 魔力]` vs `[魔力]`（多声明 `paradox`、`法术强度`）|
| T_WARP_MINE_TOWARD | #3 | `floor(trapPower)` 同上 | 同上 |
| T_WARP_MINE_AWAY | #0 | 同 TOWARD #0 | 同上（多声明 `魔力`）|
| T_WARP_MINE_AWAY | #1 | 同 TOWARD #1 | 同上 |
| T_WARP_MINE_AWAY | #2 | 同 TOWARD #2 | 同上（多声明 `paradox`、`法术强度`）|
| T_WARP_MINE_AWAY | #3 | 同 TOWARD #3 | 同上 |

`trapPower` 的写法说明：源码 `self:getMag(15, true)` 在导出场景（魔力=100）取值 **15**，
所以写成 `["max",1,["combatScale",["*",L,["*",["actor","魔力"],0.15]],0,0,75,75]]`（`L` = 时空地雷原始等级×系数）时：
- `#2` = `["floor",["*",<trapPower>,0.8]]` → 三套 26/37/46/53/60、30/43/52/61/68、32/46/56/65/73 全中；
- `#3` = `["floor",<trapPower>]` → 三套 33/47/58/67/75、38/54/66/76/85、41/58/71/82/91 全中。
`getMag(15,true)` 的 `15` 与 `魔力` 之间的比例（×0.15）由导出数据反解得到（魔力=100 → 15），仓库内没有 engine 源码可直接核对，故这是本批唯一一个**凭数据反解**的常量。

**现象与量化**：tometips 导出把 `paradox`（以及 `魔力`/`法术强度`）写进了该技能**多个** acronym 的 title，
但这些 acronym 的源码公式并不消费它们（`chronomancy` 全学派自动匹配率 42.7%，全库 65.8%，与上一批 `chronomancy/spacetime-folding` 报告一致）。
「多声明输入」不会让公式变得不可复现 —— 滑条上多一个不影响结果的输入而已。
当前闸门是等号（`JSON.stringify(declared) === JSON.stringify(consumed)`），改成子集判断（`consumed ⊆ declared`）即可解锁这一整类。

### 2. T_CARBON_SPIKES #1：15 点中 14 点命中，1.5 套第 3 点差 0.0017

表达式 `["spellDamage",1,150,["power","法术强度",["pmod",["actor","paradox"]]]]`（other.lua:801 `getDamageOnMeleeHit`），
输入集合 ✅ `[paradox, 法术强度]`，数值：

| 系数 | 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- |
| 导出 1.00 | 90 | 121 | 145 | 165 | 183 |
| 算得 | 89.6577 | 120.7421 | 144.8107 | 165.2233 | 183.2884 |
| 导出 1.30 | 100 | 136 | 163 | 187 | 207 |
| 算得 | 100.1368 | 135.7344 | 163.3024 | 186.6850 | 207.3799 |
| 导出 1.50 | 106 | 145 | **175** | 200 | 222 |
| 算得 | 106.4797 | 144.8107 | **174.4983** ❌ | 199.6799 | 221.9677 |

1.5 套第 3 点（有效等级 4.5）算得 174.4983，四舍五入阈值是 174.5，**差 0.0017（≈0.001%）**；
其余 14 点全部落在显示精度内（混合「截断/四舍五入」两种读法，`matchesDisplayed` 都接受）。
按 `%d`（截断）读法第 2 点会变 144 ≠ 145，故该 acronym 的显示只能是 `%.0f`，而 174.4983 无论如何进不到 175。

排除项：
- 不是运算顺序：Lua 的 `(base+P)*S*(max/((base+100)*K))` 与 JS 族的 `((base+P)*S*max)/D` 两种写法在这里浮点结果完全相同（都是 174.4983）；
- 不是强度：`P=100` 已被 `T_SEVER_LIFELINE #0`（×10000，对 P 极敏感）15/15 钉死；
- 量级反解：要让 15 点全成立，需要 `P≈100.0006` 或 `max≈150.0014` 或有效等级 `≈4.50009`（相对偏差 ~4×10⁻⁶），
  即导出端生成这份数据时的 spellpower/max 与整数 100/150 有极微小的浮点差，源码侧没有可见来源。

**结论**：表达式本身正确，属导出数据单点边界疑点；不建议为它改公式。
（**后续**：闸门放宽后本条已按「导出显示管线双重取整」解开并通过，见文末「闸门放宽后的补做」§2。）

---

# 闸门放宽后的补做

输入集合闸门由「`consumed == declared`」放宽为「覆盖（`consumed ⊆ declared`）」，原「疑点 1」的 12 条不再被拦。
本轮把该 tree 剩余未覆盖条目（16 条）逐条试算，**新 PASS 13 条**，批次文件从 12 条扩到 25 条。

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/chronomancy__other.json`
结果：**25/25 通过**（原 12 条逐字保留，仅追加 13 条）

汇总行：`覆盖层校验：25/25 通过`

## 1. 新 PASS（13 条，三套 15 点全中 + 输入集合覆盖）

| 技能id | acronym#N | 表达式（完整字面量见批次文件） | source | 15/15 | 输入集合关系 |
| --- | --- | --- | --- | --- | --- |
| T_WARP_MINE_TOWARD | #0 | `mineDamage`（= `T_WARP_MINES.getDamage/2`） | spacetime-folding.lua:215 | ✅ | 覆盖：标题超集，未用到 `魔力` |
| T_WARP_MINE_TOWARD | #1 | `mineDamage`（temporal 那一份，数值相同） | spacetime-folding.lua:215 | ✅ | 同上 |
| T_WARP_MINE_TOWARD | #2 | `["*",trapPower,0.8]` | spacetime-folding.lua:217 | ✅ | 覆盖：标题超集，未用到 `paradox, 法术强度` |
| T_WARP_MINE_TOWARD | #3 | `trapPower` | spacetime-folding.lua:217 | ✅ | 同上 |
| T_WARP_MINE_AWAY | #0 | `mineDamage` | spacetime-folding.lua:215 | ✅ | 覆盖：标题超集，未用到 `魔力` |
| T_WARP_MINE_AWAY | #1 | `mineDamage` | spacetime-folding.lua:215 | ✅ | 同上 |
| T_WARP_MINE_AWAY | #2 | `["*",trapPower,0.8]` | spacetime-folding.lua:217 | ✅ | 覆盖：标题超集，未用到 `paradox, 法术强度` |
| T_WARP_MINE_AWAY | #3 | `trapPower` | spacetime-folding.lua:217 | ✅ | 同上 |
| T_SLOW | #0 | `["floor",["talentScale",2.25,3.25]]` | other.lua:144 | ✅ | 覆盖：标题超集，未用到 `paradox` |
| T_SLOW | #1 | `["floor",["talentScale",6,10]]` | other.lua:152 | ✅ | 同上 |
| T_REPULSION_FIELD | #0 | `["floor",["talentScale",1.5,3.5]]` | other.lua:488 | ✅ | 同上 |
| T_DAMAGE_SMEARING | #0 | `["*",["/",LuaLimit50_10_30,100],100]` | other.lua:610 | ✅ | 同上 |
| T_CARBON_SPIKES | #1 | `round2+round(["spellDamage",1,150,P])` | other.lua:801 | ✅ | ✅ 完全一致 `[paradox, 法术强度]` |

上表 `P = ["*",["power","法术强度"],["pmod",["actor","paradox"]]]`，
`mineDamage` / `trapPower` / `LuaLimit50_10_30` 的完整字面量见批次文件对应条目的 `expr`。

### 新用到的写法

- **`mineDamage`（`combatTalentSpellDamage` @ 非本技能等级 L）**：
  `["/",["^",["*",["*",["+",20,P],["+",1,["*",0.8,["-",["sqrt",L],1]]]],["/",200,["*",["+",20,100],["+",1,["*",0.8,["-",["sqrt",5],1]]]]]],1.04],2]`，
  其中 `L = ["*",["actor","时空地雷 技能等级"],["talentLevel"]]`（原始等级 × 系数，同旧报告「写法模式 3」）。
  注意 `["*",a,b,c]` 不是三目乘法（求值器只吃二元 `["*",a,b]`），必须嵌套写成 `["*",["*",a,b],c]`（第一版追加时踩过，表现为漏乘 mod → 每点偏大）。
- **`trapPower`**：`["max",1,["combatScale",["*",L,["*",["actor","魔力"],0.15]],0,0,75,75]]`；
  `combatScale` 省略 power 时默认 **0.5**，故 = `75·√(L·魔力·0.15/75)`。源码无 `floor`，
  info 用 `%d` 截断显示，表达式按源码原样写（工具在 precision=0 时接受「截断」读法）。
- **`combatTalentLimit` 手工展开 + 保留源码的 `/100*100`**（`T_DAMAGE_SMEARING` #0）：
  `getPercent = combatTalentLimit(t,50,10,30)/100`，info 再 `*100`。用节点 `["talentLimit",50,10,30]` 会在
  1.3 套第 1/5 点得到 `10.000…`/`30.000…`（Lua 手工展开为 `9.9995…`/`29.999…`），
  再经 `/100*100` 的浮点往返后导出成 **9 / 29**。故必须：
  ① 用 `exp/log/sqrt` 按 Combat.lua:1606 的运算顺序展开；
  ② 外层保留 `["*",["/",<limit>,100],100]`。两处都做到后 15/15。

## 2. T_CARBON_SPIKES #1 —— 旧「疑点 2」已解开

旧报告认为 1.5 套第 3 点 `174.4983 → 174.5` 无论如何进不到导出值 **175**。放宽后复核发现：
该技能 bleed 的 info 格式是 **`%0.2f`**，导出管线对 `|v|≥10` 的值是「**先按描述格式渲染成 2 位小数，再取整**」——
与 `docs/overlay-reports/spell__other.md` §4 总结的确定性规则（`v_display = |v|<10 ? round(v,2) : Math.round(v)`）一致，
也与 `docs/expression-overlay-report.md` §3 的「双重取整」条目同类。逐个复核本 acronym 15 点：

| 算得真值 | `%0.2f` | 取整 | 导出 |
| --- | --- | --- | --- |
| 89.6577 | 89.66 | 90 | 90 ✅ |
| 120.7421 | 120.74 | 121 | 121 ✅ |
| 144.8107 | 144.81 | 145 | 145 ✅ |
| 165.2233 | 165.22 | 165 | 165 ✅ |
| 183.2884 | 183.29 | 183 | 183 ✅ |
| 100.1368 | 100.14 | 100 | 100 ✅ |
| 135.7344 | 135.73 | 136 | 136 ✅ |
| 163.3024 | 163.30 | 163 | 163 ✅ |
| 186.6850 | 186.68 | 187 | 187 ✅ |
| 207.3799 | 207.38 | 207 | 207 ✅ |
| 106.4797 | 106.48 | 106 | 106 ✅ |
| 144.8107 | 144.81 | 145 | 145 ✅ |
| **174.4983** | **174.50** | **175** | **175** ✅ |
| 199.6799 | 199.68 | 200 | 200 ✅ |
| 221.9677 | 221.97 | 222 | 222 ✅ |

故在 `["spellDamage",1,150,P]` 外层加一层「先 2 位小数再取整」即 15/15 PASS：

```json
["floor",["+",0.5,["/",["floor",["+",0.5,["*",100,["spellDamage",1,150,["*",["power","法术强度"],["pmod",["actor","paradox"]]]]]]],100]]]
```

**口径说明**：这 13 条里 12 条是纯源码公式，只有本条多了一层并非源码的**显示取整**（复刻导出管线）。
若主项目坚持「覆盖层只放源码公式」，把这一条从批次文件删掉即可（其余 12 条不受影响）；
工具侧的根治办法是把 `matchesDisplayed` 扩展为「按 info 真实 format 先渲染再取整」，这样本条也能用纯 `["spellDamage",1,150,P]` 通过。

## 3. 仍不通（3 条）：`T_SPACETIME_TUNING` #0 / #1 / #2

三套全部报 `✗ 标题里没有唯一可变的轴` → `结论：FAIL`。原因不是公式，而是导出侧参数建模缺陷：
该 tooltip 的**每一个** acronym 标题都同时声明了两条 5 点阶梯
（`意志 10,25,50,75,100` 与 `法术强度 10,25,50,75,100`，两者数值恰好完全相同），
`ladderAxis()` 取「第一个 ladder>1 的参数」后要求其余参数都是单值，于是直接返回 `null`。
副作用：`declaredInputs`/`consumedInputs` 都退化成空数组，工具显示 `标题声明 [无] vs 表达式消耗 [无] ✅`，
看起来闸门通过，真正拦下的是定轴失败。

| 技能id | acronym#N | 标题声明 vs 消耗 | 失败原因 |
| --- | --- | --- | --- |
| T_SPACETIME_TUNING | #0 | `[意志, 法术强度]`（双 5 点轴） vs `[法术强度]` | 定轴失败：两条 5 点阶梯 |
| T_SPACETIME_TUNING | #1 | `[意志, 法术强度]`（双 5 点轴） vs `[意志]` | 同上 |
| T_SPACETIME_TUNING | #2 | `[意志, 法术强度]`（双 5 点轴） vs `[意志]` | 同上 |

源码侧公式是清楚的（`other.lua:114-131` info 的 tformat 顺序，`other.lua:33-40` getTuning）：

| acronym#N | 源码语义 | 拟写表达式 | 导出三套（相同） |
| --- | --- | --- | --- |
| #0 | `getParadoxSpellpower(self,t)` = 法术强度 × pmod | `["*",["power","法术强度"],["pmod",["actor","paradox"]]]` | 10/25/50/75/100 |
| #1 | `will_modifier`（`Actor.lua:5378`，`(getWil()+0)*2`，文本渲染成 `-%d`） | `["*",-2,["actor","意志"]]` | -20/-50/-100/-150/-200 |
| #2 | `modified_paradox = max(0, paradox - will_modifier + sustain)`（sustain=0） | `["max",0,["-",300,["*",2,["actor","意志"]]]]` | 280/250/200/150/100 |

这三条不是「5 分钟没过」，而是**工具结构上无法评估**：即便表达式正确，`ladderAxis` 也先返回 `null`，
15 点比对根本不会执行。要解锁需要主项目让 acronym 能显式指定轴（或在 title 里把非轴参数收敛为单值），
本轮按规则**没有**为凑通过而硬塞节点。

## 4. 本轮小结

- 补做数 **16**（清单内），新 PASS **13**，仍不通 **3**（全部为 `T_SPACETIME_TUNING` 的双轴缺陷）。
- 批次文件条目 **12 → 25**，`--overlay` 第一行：`覆盖层校验：25/25 通过`。
- 旧「疑点 1」（标题过度声明输入，12 条）在新闸门下全部转为 PASS 并已保留在批次文件；
  旧「疑点 2」（`T_CARBON_SPIKES` #1 的 `.5` 边界）已按导出显示管线双重取整解开并写盘。
