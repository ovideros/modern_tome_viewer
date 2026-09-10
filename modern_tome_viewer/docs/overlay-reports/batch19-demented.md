# batch19 — demented（疯狂系）公式补写报告

范围：`dlc-src/cults/tome-cults/data/talents/demented/` 下 10 个大系
（calamity / writhing-body / void / scourge-drake / controlled-horrors /
friend-of-the-worm / tentacles / doom / beyond-sanity / prophecy）。

覆盖层文件：`data/overlay-batches/batch19-demented.json`（23 条）。

验收命令与结果：

```
$ node scripts/try-formula.mjs --overlay data/overlay-batches/batch19-demented.json
覆盖层校验：23/23 通过
```

目标数 25 条（`--list`），PASS 23 条，跳过 2 条。

---

## 一、已完成

全部 23 条均为 `结论：PASS（三套 15 点全中，输入集合覆盖）`。

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_JINXED_TOUCH | #0 | `["max",1,["min",3,["floor",["/",["+",["talentLevel",true],2],2]]]]` | demented/calamity.lua:37 | ✅ |
| T_JINXED_TOUCH | #1 | `["+",1,["*",0.5,["floor",["/",["-",["talentLevel",true],1],2]]]]` | demented/calamity.lua:28 | ✅ |
| T_PREORDAIN | #0 | `["min",7,["+",1,["talentLevel"]]]` | demented/calamity.lua:83 | ✅ |
| T_LUCKDRINKER | #1 | `["max",1,["min",3,["floor",["/",["+",["talentLevel",true],2],2]]]]` | demented/calamity.lua:107 | ✅ |
| T_LUCKDRINKER | #2 | `["+",1,["*",0.5,["floor",["/",["-",["talentLevel",true],1],2]]]]` | demented/calamity.lua:98 | ✅ |
| T_LUCKDRINKER | #3 | `["min",6,["+",2,["floor",["/",["talentLevel"],2]]]]` | demented/calamity.lua:116 | ✅ |
| T_MUTATED_HERERAGEGAND | #0 | `["*",100,["/",["sqrt",["/",["talentLevel"],5]],2]]` | demented/writhing-body.lua:31 | ✅ |
| T_MUTATED_HERERAGEGAND | #2 | `["talentScale",0,10]` | demented/writhing-body.lua:44 | ✅ |
| T_MUTATED_HERERAGEGAND | #3 | `["talentLimit",25,2,12]` | demented/writhing-body.lua:47 | ✅ |
| T_NULLMAIL | #0 | `["statDamage","mag",10,50]` | demented/void.lua:151 | ✅ |
| T_NULLMAIL | #1 | `["+",50,["spellDamage",30,200]]` | demented/void.lua:152 | ✅ |
| T_BLACK_MONOLITH | #2 | combatStatLimit 指数原式展开（见「发现的写法模式」③）| demented/void.lua:203 | ✅ |
| T_MAGGOT_BREATH | #1 | `["statDamage","mag",30,550]` | demented/scourge-drake.lua:170 | ✅ |
| T_MAGGOT_BREATH | #3 | `["*",0.075,["statDamage","mag",30,550]]` | demented/scourge-drake.lua:174 | ✅ |
| T_DECAYED_DEVOURERS | #3 | `["floor",["talentLevel"]]` | demented/controlled-horrors.lua:160 | ✅ |
| T_DECAYED_BLADE_HORROR | #3 | `["floor",["talentLevel"]]` | demented/controlled-horrors.lua:270 | ✅ |
| T_TWOFOLD_CURSE | #0 | `["talentLevel"]` | demented/doom.lua:376 | ✅ |
| T_WORM_THAT_WALKS | #0 | `["/",["+",60,["spellDamage",15,450]],7]` | demented/friend-of-the-worm.lua:348 | ✅ |
| T_SHARED_INSANITY | #1 | `["floor",["/",["talentLevel",true],2]]` | demented/friend-of-the-worm.lua:528 | ✅ |
| T_MUTATED_HAND | #0 | `["*",100,["/",["sqrt",["/",["talentLevel"],5]],1.5]]` | demented/tentacles.lua:36 | ✅ |
| T_MUTATED_HAND | #2 | `["talentLimit",25,2,12]` | demented/tentacles.lua:53 | ✅ |
| T_CHAOS_ORBS | #1 | `-combatTalentLimit(t,5,25,9)` 指数原式展开再取负（见「发现的写法模式」③）| demented/beyond-sanity.lua:27 | ✅ |
| T_PROPHECY_OF_RUIN | #0 | `combatTalentSpellDamage(t,1,120)` 在原始等级 0 处展开（见「疑点」①）| demented/doom.lua:29 | ✅ |

（两条长表达式原文见 JSON 文件。）

---

## 二、发现的写法模式

### ① 等级阶梯分支：`if raw >= N then return X elseif ... end`

厄运之触 / 幸运汲取的 `getSaves` / `getCrit` 都是「原始等级阈值返回常数」。
节点表没有 `if`，但这类分段常数可以无损写成算术式：

- `getSaves`：`raw>=4→3, raw>=2→2, else 1` ⇒ `max(1, min(3, floor((raw+2)/2)))`
- `getCrit`：`raw>=5→2, raw>=3→1.5, else 1` ⇒ `1 + 0.5*floor((raw-1)/2)`

两处都必须用 **原始等级** `["talentLevel",true]`（三套系数下数字完全相同），
写成有效等级会在 1.30 那套崩掉（例如 raw=3 时有效等级 3.9 → 误判为 ≥4）。
代表技能：`T_JINXED_TOUCH`、`T_LUCKDRINKER`（同一函数在两条技能里各抄一遍）。

### ② `getXxx` 多返回值被 `tformat` 展开

`tformat(t.getPower(self,t))` 这种写法里，Lua 会把函数的**全部返回值**塞进 tformat，
导出因此多出 acronym。例：`T_WORM_THAT_WALKS.getPower` 返回
`(60+combatTalentSpellDamage(t,15,450))/7, 7, combatTalentLimit(t,100,27,55)`，
acronym#0 只取第 1 个 ⇒ `["/",["+",60,["spellDamage",15,450]],7]`。

### ③ 节点表的 `talentLimit` / `combatLimit` 与原游戏是**两种不同插值**

`Combat.lua` 里 `combatTalentLimit` / `combatStatLimit` 用的是**指数**形式
（`a = log((high-limit)/(low-limit))/(x_high-x_low)`、`b = ...`、
`low - (low-limit)*(1-exp(sqrt(tl)*a+b))`），而节点表的 `talentLimit` / `combatLimit`
是**幂**形式。两者只在端点重合，中间点会差；更关键的是端点处浮点结果不同：

- `combatTalentLimit(t,5,25,9)` 在 tl = 1.3（系数 1.30、原始等级 1）时，
  指数原式给 `24.999999999999996` → 导出 `24`，而幂式给正好 `25` → 判 FAIL；
- `combatStatLimit("mag",70,15,40)` 在 stat=100 时，指数原式给 `39.99984` → 导出 `39`，
  幂式（`combatLimit` 内部取 `100^0.75`）给 `40.0` → 判 FAIL。

这两条都改成用节点表里的 `exp` / `log` / `sqrt` / `pow` **照抄 Combat.lua 原式**后 15/15 通过。
代表技能：`T_CHAOS_ORBS`（beyond-sanity.lua:27）、`T_BLACK_MONOLITH`（void.lua:203）。
建议：把「指数版 combatTalentLimit / combatStatLimit」提成解析器规则或新节点族。

### ④ 同一 getter 服务多个技能 / 别的技能通过 `callTalent` 取用

- `T_PROPHECY_OF_RUIN.getDamage` = `self:callTalent(self.T_PROPHECY, "getRuinDamage")`，
  而 `getRuinDamage = combatTalentSpellDamage(t, 1, 120)`（`self.T_PROPHECY` 是取 getter，
  `t` 仍是当前技能）⇒ 直接写 `["spellDamage",1,120]`，不需要 `talentRef`。
- `T_MUTATED_HERERAGEGAND`（writhing-body）与 `T_MUTATED_HAND`（tentacles）是**同一段
  getTentacleCombat 的两个副本**，写法完全一样（`combatTalentScale(t,0,10)`、
  `combatTalentLimit(t,25,2,12)`、`100*sqrt(tl/5)/2` vs `/1.5`）。

### ⑤ 同一个数值在多个技能里重复出现

`["floor",["talentLevel"]]` 同时是 `T_DECAYED_DEVOURERS#3`、
`T_DECAYED_BLADE_HORROR#3`（源码里都写作 `math.floor(self:getTalentLevel(t))`），
`T_TWOFOLD_CURSE#0` 则是**没有取整**的 `self:getTalentLevel(t)`（截断交给显示层）。

### ⑥ 装备/状态条件被冻结成常数

- `T_NULLMAIL.getArmor / getAbsorb` 末尾乘 `t.ArmorEffect(self,t)`：布甲 = 1，其它 = 0。
  导出按布甲渲染，故冻结为 1（标题没有声明这类输入，无法也不该做成滑条）。
- `T_MAGGOT_BREATH.getDamage` 里 `knowTalent(T_CHROMATIC_FURY) and combatTalentStatDamage(t,"wil",30,550) or 0`：
  导出未学该技能（标题也只声明了 魔力，没有 意志），bonus 冻结为 0。

---

## 三、无法建模

| 技能id | acronym#N | 原因 |
| --- | --- | --- |
| T_MUTATED_HERERAGEGAND | #1 | `getTentacleCombat` 的 `Object:descCombat` 文本被导出切成 10 个数字（`10/-14/20/-28/...`，即 `基础伤害 10-14`、`20-28`… 被当成两个数），而标题只声明 5 个 `技能等级` ⇒ 工具报「标题里没有唯一可变的轴」。属于**导出侧解析伪影**，源码里该值就是 `combatTalentScale(t,10,40)`（见「疑点」②）。 |
| T_MUTATED_HAND | #1 | 同上（tentacles 版 descCombat，`dam = combatTalentScale(t,10,40)`，`damrange = 1.4`）。 |

两条都不是「读不懂源码」，而是导出的 acronym 维度与标题维度对不上：

```
$ node scripts/try-formula.mjs --talent T_MUTATED_HERERAGEGAND --arg 1 --expr '["talentScale",10,40]'
  系数 1: ✗ 标题里没有唯一可变的轴
```

---

## 四、疑点

### ① `T_PROPHECY_OF_RUIN` 的导出按「原始等级 0」渲染

标题只声明 `法术强度 10/25/50/75/100`（`stat-variable`），源码是
`getRuinDamage = combatTalentSpellDamage(t, 1, 120)`。按等级 1 算，
法术强度 10 → 7.09，而导出是 **1.33**；两者比值恒为 `1/5.33 ≈ 0.1875`。

把等级因子 `(sqrt(L)-1)*0.8+1` 冻结为 `0.2`（即 `L = 0`）后 15/15 全中：

```
法术强度: 10→1.33  25→3.25  50→6.55  75→9.92  100→13.33(显示 13)
```

等价写法是 `combatTalentSpellDamage` 的 `max = 24`、等级 1（数值完全相同）。
对照：同一个 `getRuinDamage` 在 `T_PROPHECY#0` 里是正常按 `技能等级 1-5` +
`法术强度 100` 渲染的（84/115/138/158/176，与 `combatTalentSpellDamage(t,1,120)`
在 tl=1.5..7.5 处吻合）。所以这是**导出侧**把 `T_PROPHECY_OF_RUIN` 自己的 tooltip
按「未学会（等级 0）」渲染造成的，不是源码有问题。

处理方式：按「冻结未声明输入」规则，把等级因子写成常数 `0.2`（表达式里保留
`["sqrt",0]` 的形状以便复核），并在 `note` 里注明。这条如果主项目认为不该收，
可直接从覆盖层删掉——它不影响其它条目。

### ② `descCombat` 文本型 acronym 的维度错位（2 条跳过的根因）

`writhing-body` / `tentacles` 的 `T_MUTATED_*` tooltip 末尾直接内嵌
`Object:descCombat(...)` 的渲染文本。导出把它切成 10 个数字
（`基础伤害：10-14, 20-28, 28-39, 34-48, 40-56` → `10,-14,20,-28,28,-39,34,-48,40,-56`），
而参数表只有 5 个 `技能等级`，`ladderAxis` 的
`axis.ladder.length !== displayed.length` 检查因此直接判「没有唯一可变的轴」。

源码侧本身是唯一确定的（`dam = self:combatTalentScale(t, 10, 40)`，
`damrange = 1.4`，最大值 = `dam*1.4`），如果导出把这一串拆成 5 个区间读成
`[min,max]` 二元组，两条都能 PASS。建议在导出/解析侧修，而不是在覆盖层硬凑。

### ③ 节点表 `talentLimit` / `combatLimit` 与游戏实现的差异（系统性）

见「发现的写法模式」③。这不是个别技能的取整差，而是**两套插值函数**：
全库凡是端点恰好落在 `x_low`/`x_high` 的阶梯，幂式都会偏 1（`25` vs `24.999…`、
`40` vs `39.9998…`）。本批靠手工展开 Combat.lua 原式绕开，建议把指数版提成
解析器规则，否则后续批次会反复踩。

### ④ `T_TWOFOLD_CURSE#0` 的显示读数

源码是 `self:getTalentLevel(t)`（不取整），导出三套分别是
`1/2/3/4/5`、`1/2/3/5/6`、`1/3/4/6/7`，即 `%d` 对 `1.3/2.6/3.9/5.2/6.5`（系数 1.3）
截断、对 `1.5/4.5/7.5`（系数 1.5）截断。判定器接受 trunc 读数，故
`["talentLevel"]` 15/15 通过；`["floor",["talentLevel"]]` 也能过，但那是把显示层
的截断写进了公式，已按文档要求取**不取整**的写法。

---

## 附：本批 `--list` 目标与结果汇总

| 大系 | 目标数 | PASS | 跳过 |
| --- | --- | --- | --- |
| demented/calamity | 6 | 6 | 0 |
| demented/writhing-body | 4 | 3 | 1 |
| demented/void | 3 | 3 | 0 |
| demented/scourge-drake | 2 | 2 | 0 |
| demented/controlled-horrors | 2 | 2 | 0 |
| demented/friend-of-the-worm | 2 | 2 | 0 |
| demented/tentacles | 3 | 2 | 1 |
| demented/doom | 1 | 1 | 0 |
| demented/beyond-sanity | 1 | 1 | 0 |
| demented/prophecy | 1 | 1 | 0 |
| **合计** | **25** | **23** | **2** |
