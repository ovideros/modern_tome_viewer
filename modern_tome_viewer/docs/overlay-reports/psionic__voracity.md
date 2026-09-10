# 覆盖层报告 · `psionic/voracity`

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/psionic__voracity.json`
结果：**8/8 通过**（目标 21 条；另 13 条记入「无法建模 / 疑点」）

目标范围：`tome-src-full/data/talents/psionic/voracity.lua` 的 3 个技能
（Kinetic/Thermal/Charge Leech，每个 7 个 acronym，共 21 条）。
`T_INSATIABLE` 已被自动提取命中（`data/talents.json` 里 `lua=Y`），不在本批。

本批所有可建模的取值共用同一个「灵能值因子」：

```
F = math.max(0.5, 1.5 - psi/self:getMaxPsi())
```

标题把该输入写成**百分数**（`psi 50%`，见导出 info_text 的 title），
所以 `psi/maxPsi` 就等于 `psi/100`，可直接用 `["actor","psi"]` 写出：

```
F = ["max",0.5,["-",1.5,["/",["actor","psi"],100]]]
```

下面表格里 `T(X,限,低,高)` 是 `combatTalentLimit` 的节点表等价展开（`mastery` 默认 1.3）：

```
T(X,limit,low,high) =
["+",limit,["*",["-",low,limit],
  ["^",["/",["-",high,limit],["-",low,limit]],
       ["/",["-",["sqrt",X],["sqrt",1.3]],["-",["sqrt",6.5],["sqrt",1.3]]]]]]
```

（与 `["combatLimit",["^",X,["/",2,3]],limit,low,["^",1.3,["/",2,3]],high,["^",6.5,["/",2,3]]]`
数值等价，两种写法都实测 PASS；本批采用 closed form，便于和源码逐字对照。）

## 已完成

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_KINETIC_LEECH | #1 | `["*",100,T(["*",["talentLevel"],F],0.50,0.16,0.20)]` | voracity.lua:48 | ✅ |
| T_KINETIC_LEECH | #5 | `["*",["talentScale",10,20],F]` | voracity.lua:40 | ✅ |
| T_THERMAL_LEECH | #1 | `["ceil",["combatScale",["*",["talentLevel"],F],1.3,1,3.2,5,0.5]]` | voracity.lua:114 | ✅ |
| T_THERMAL_LEECH | #3 | `["*",["mindDamage",20,130],F]` | voracity.lua:110 | ✅ |
| T_THERMAL_LEECH | #5 | `["*",["talentScale",10,20],F]` | voracity.lua:106 | ✅ |
| T_CHARGE_LEECH | #1 | `["*",["mindDamage",20,130],F]` | voracity.lua:170 | ✅ |
| T_CHARGE_LEECH | #3 | `T(["*",["talentLevel"],F],100,25,50)` | voracity.lua:174 | ✅ |
| T_CHARGE_LEECH | #5 | `["*",["talentScale",10,20],F]` | voracity.lua:166 | ✅ |

（source 行号是 getter 所在行；`--list` 给的是 `newTalent{` 起始行。）

acronym 与 info 文本的对应（三个技能各自 7 个）：

| 技能 | #0 | #1 | #2 | #3 | #4 | #5 | #6 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Kinetic Leech | radius | slow%(当前ψ) | slow%(最大) | 吸体力 | 吸体力(最大) | 补ψ | 补ψ(最大) |
| Thermal Leech | radius | 冻结回合 | 冻结回合(最大) | 寒冷伤害 | 寒冷伤害(最大) | 补ψ | 补ψ(最大) |
| Charge Leech | radius | 闪电伤害 | 闪电伤害(最大) | 眩晕% | 眩晕%(最大) | 补ψ | 补ψ(最大) |

## 发现的写法模式

1. **「灵能值越低越强」的乘性因子**：`math.max(0.5, (1.5-psi/self:getMaxPsi()))`，
   出现在 `getLeech` / `getDam` / `getSlow` / `getDur` / `getDaze` 五个 getter 里（代表：`T_KINETIC_LEECH`）。
   标题里这个输入写作百分数 `psi 50%`（kind=`stat`），所以 `psi/maxPsi = psi/100`，
   `["actor","psi"]` 足以写出来；`getMaxPsi()` 本身**不需要**建模。
   参数 `psi` 的取值来自 `t.getX(self, t, psi)` 的第三参或运行时的 `self:getPsi()`。

2. **`combatTalentLimit` 被「等级表达式」驱动**：源码写成
   `combatTalentLimit(getTalentLevel(t)*F, limit, low, high)`（不是传技能表）。
   节点表里的 `talentLimit` 只吃本技能等级，因此要按 closed form 展开（见文首 `T(...)`）。
   代表：`T_KINETIC_LEECH#1`（0.50/0.16/0.20）、`T_CHARGE_LEECH#3`（100/25/50）。

3. **`combatTalentScale` 的等级驱动量被改写**：`combatTalentScale(getTalentLevel(t)*F, low, high)`
   ⟺ `["combatScale", L, low, 1, high, 5, 0.5]`（已在 deeprock 批次验证的展开）。
   代表：`T_THERMAL_LEECH#1`（`getDur`，外面还有 `math.ceil`）。

4. **乘性因子放在家族函数之外**：`combatTalentXXXDamage(t,…)*F` / `combatTalentScale(t,…)*F`
   直接写成 `["*",[…],F]`，不需要把因子塞进 `max` 参数。代表：三个技能的 `getDam` / `getLeech`。

5. **`t.getX(self, t, 0)` 表示「满值」**：源码给 getter 显式传 `psi=0`（Lua 里 `0` 为真值，
   不会被 `psi or self:getPsi()` 覆盖），于是值固定为因子 1.5 的那一档，**与标题声明的 psi 无关**。
   代表：所有 `(max …)` / `(最多 …)` 的 acronym（#2/#4/#6）。见「无法建模」。

6. `damDesc(self, DamageType.X, v)` 只是显示包装，取 `v`；`math.floor`/`math.ceil` 照抄。
   代表：`T_THERMAL_LEECH#3`（`damDesc(COLD, getDam(...))`）、`#1`（`math.ceil`）。

## 无法建模

| 技能id | acronym#N | 类别 | 原因 |
| --- | --- | --- | --- |
| T_KINETIC_LEECH | #2 / #4 / #6 | 标题过度声明输入 | 源码 `t.getSlow(self,t,0)` / `t.getDam(self,t,0)` / `t.getLeech(self,t,0)` 显式按 **psi=0** 取值，值恒等于因子 1.5 那一档；标题却声明 `psi 50%`。诚实表达式不消耗 psi（被乘的因子是常量 1.5），输入集合闸门必然不过：实测 `标题声明 [psi, 精神强度] vs 消耗 [精神强度]`（#4）、`[psi] vs [无]`（#2/#6）。**数值本身 15/15 全中**（用固定 1.5 试算），卡的是闸门不是公式。|
| T_THERMAL_LEECH | #2 / #4 / #6 | 同上 | 同上（`getDur` / `getDam` / `getLeech` 的 `psi=0` 档）。实测三套 `系数 1/1.3/1.5` 全 `✅ 5/5`，仅输入集合 `❌`。|
| T_CHARGE_LEECH | #2 / #4 / #6 | 同上 | 同上（`getDam` / `getDaze` / `getLeech` 的 `psi=0` 档）。实测三套全 `✅ 5/5`，仅输入集合 `❌`。|
| T_KINETIC_LEECH | #0 | 标题过度声明输入 | 源码 `radius = math.floor(self:combatTalentScale(t,1,4))` 不消耗任何输入，标题声明 `[psi]` → `[psi] vs [无]`。另外浮点取整层还有差异，见「疑点」。|
| T_THERMAL_LEECH | #0 | 同上 | 同 `radius`，`[psi] vs [无]`。|
| T_CHARGE_LEECH | #0 | 同上 | 同 `radius`，`[psi] vs [无]`。|

关于「标题过度声明输入」：这 12 条的 title 参数是**整个技能**的参数并集
（`技能等级/技能系数/精神强度/psi`），不是逐个 acronym 的真实依赖；
对 `(max …)` 档源码根本不用 psi，对 radius 档源码什么都不用。
按 `docs/expression-overlay.md` 规则 4，**没有为了凑输入集合而硬塞 `["*",0,["actor","psi"]]` 之类的假节点**。

灵能值因子两侧的边界也说明这不是「读不懂」：
把 psi 因子当成自由常数扫描 135 个点，**只有 `psi/maxPsi ∈ [0.49855, 0.49936]`
（即 maxPsi ∈ [100.129, 100.291]）能让 9 条全过**；标题写的是 50%，
`psi/maxPsi=0.5` 是唯一自然取值，而它恰好因为下面「疑点」第 1 条差一个点。

## 疑点

1. **`T_KINETIC_LEECH#3` 卡在导出侧的取整层（不是公式错）**。
   源码第 80 行（`info`）用的格式是 `%0.1f`（英文原文 `draining %0.1f (max %0.1f) stamina`），
   导出文本却只留整数。按 `psi/maxPsi = 50/100 = 0.5`（`F=1.0`）算：

   | 套 | 1 | 2 | 3 | 4 | 5 |
   | --- | --- | --- | --- | --- | --- |
   | 1.00 导出 | 26 | 35 | 41 | 47 | 52 |
   | 1.00 算得 | 25.6327 | 34.5195 | 41.4006 | 47.2365 | 52.4012 |
   | 1.30 导出 | 29 | 39 | 47 | 53 | 59 |
   | 1.30 算得 | 28.6286 | 38.8057 | 46.6873 | 53.3722 | 59.2888 |
   | 1.50 导出 | 30 | 41 | 50 | 57 | **64** |
   | 1.50 算得 | 30.442 | 41.4006 | 49.8881 | 57.0874 | **63.4594** |

   14/15 点吻合（`%d` 或 `%.0f` 都行），只有 `1.50 / 等级5` 差 1。
   注意 63.4594 的 **`%0.1f` 渲染正好是 `63.5`**，导出侧再取整得 64
   （先一位小数、再整数 = 双重取整）；工具 `matchesDisplayed` 在 `precision=0` 时只试
   `round(63.4594)=63` 与 `trunc=63`，两种都中不了 → FAIL。
   让 9 条全过的 psi 比例必须落在 `[0.49855, 0.49936]`，**没有任何自然取值**
   （反解 maxPsi ≈ 100.13–100.29），所以这 1 点判为**源码与导出的取整层不一致**，
   不为了过闸门把 maxPsi 从 100 挪到 100.2。建议主项目把这类「先 `%.1f` 再整数化」的
   双重取整纳入 `matchesDisplayed`（或按 title 里真实 format 标注 precision）。

2. **radius（#0）在系数 1.00 / 等级 5 上也有取整层差异**：
   `floor(combatTalentScale(t,1,4))` 在 L=5 处的数学值是 **4.0**（导出给 3）。
   Lua 的实现先算 `b = low - m*x_low_adj` 再算 `m*x^0.5 + b`，浮点关联顺序会得到
   `3.9999999999999996` → `math.floor` = 3；表达式节点按 `m*(x-lo)+low` 关联则正好得 4.0。
   系数 1.30/1.50 两套都 5/5 吻合，只有这一个点。
   （该条本来也因输入集合 `[psi] vs [无]` 过不了，记录在此备查。）

3. **输入集合闸门的系统性缺陷**：本批 21 条里有 **12 条**
   （9 条 `(max …)` 数值完全可复现，3 条 radius 公式清晰可写，只差浮点取整那一点），
   却因为「title 参数为技能全部 acronym 的并集」被闸门拦下。这与 deeprock 批次里 `T_BOULDER_ROCK` 的现象同源，
   建议主项目按 acronym 精确解析 title，或把「源码显式传常量参数的档」视为不声明该输入。

---

## 闸门放宽后的补做

（以上原文保留。本节为输入集合闸门由「表达式消耗 == 标题声明」放宽为「消耗 ⊆ 声明」之后追加。）

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/psionic__voracity.json`
结果：**20/20 通过**（原 8 条 + 本次补做 12 条；数组长度 20，通过数 20）。
待补 13 条中 **12 条 PASS**，仅 `T_KINETIC_LEECH#3` 仍不通（见下「仍不通」）。

本节的 `T(X,limit,low,high)` 仍指文首的 `combatTalentLimit` closed form；`M` 是本节新引入的
`combatScale` 斜率常量：

```
M = ["/",["-",4,1],["-",["^",5,0.5],["^",1,0.5]]]        -- (4-1)/(5^0.5 - 1^0.5)
R = ["floor",["+",["*",M,["^",["talentLevel"],0.5]],["-",1,M]]]
```

### 本次新增（12 条）

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_KINETIC_LEECH | #0 | `R`（radius 展开，见下） | voracity.lua:34 | ✅ |
| T_KINETIC_LEECH | #2 | `["*",100,T(["*",["talentLevel"],1.5],0.50,0.16,0.20)]` | voracity.lua:48 | ✅ |
| T_KINETIC_LEECH | #4 | `["*",["mindDamage",5,45],1.5]` | voracity.lua:44 | ✅ |
| T_KINETIC_LEECH | #6 | `["*",["talentScale",10,20],1.5]` | voracity.lua:40 | ✅ |
| T_THERMAL_LEECH | #0 | `R` | voracity.lua:100 | ✅ |
| T_THERMAL_LEECH | #2 | `["ceil",["combatScale",["*",["talentLevel"],1.5],1.3,1,3.2,5,0.5]]` | voracity.lua:114 | ✅ |
| T_THERMAL_LEECH | #4 | `["*",["mindDamage",20,130],1.5]` | voracity.lua:110 | ✅ |
| T_THERMAL_LEECH | #6 | `["*",["talentScale",10,20],1.5]` | voracity.lua:106 | ✅ |
| T_CHARGE_LEECH | #0 | `R` | voracity.lua:160 | ✅ |
| T_CHARGE_LEECH | #2 | `["*",["mindDamage",20,130],1.5]` | voracity.lua:170 | ✅ |
| T_CHARGE_LEECH | #4 | `T(["*",["talentLevel"],1.5],100,25,50)` | voracity.lua:174 | ✅ |
| T_CHARGE_LEECH | #6 | `["*",["talentScale",10,20],1.5]` | voracity.lua:166 | ✅ |

（12 条都是先单条 `--talent/--arg/--expr` 跑出 `结论：PASS（三套 15 点全中，输入集合覆盖）` 后才追加的；
覆盖层文件里保留原 8 条，新 12 条按 技能→acronym 顺序追加在末尾。）

### 新增写法模式

7. **「`(max …)` 档」= 源码显式传 `psi=0`，因子是常量 1.5**（本次 9 条）。
   `t.getSlow(self,t,0)` / `getDam(self,t,0)` / `getDur(self,t,0)` / `getDaze(self,t,0)` /
   `getLeech(self,t,0)` 里的 `0` 在 Lua 是真值，不会被 `psi or self:getPsi()` 覆盖，于是
   `F = math.max(0.5, 1.5 - 0/maxPsi) = 1.5` 是**与标题无关的常量**，按题目允许的做法冻结成
   `1.5`（每条 note 已说明）。表达式不读任何输入（`consumed = [无]`），标题声明 `[psi]`/`[psi,精神强度]`
   是整份 tooltip 的参数并集，于是工具判 `✅ 覆盖（标题是超集，本值未用到：psi）` → PASS。
   **没有为了凑集合硬塞假节点**。代表：`T_THERMAL_LEECH#4`。

8. **`radius` 的浮点结合序要照抄 Lua，不能直接用节点表的 `talentScale`/`combatScale`**（本次 3 条）。
   源码 `math.floor(self:combatTalentScale(t, 1, 4))`。两边的算式代数等价但结合序不同：

   | 实现 | 写法 | 系数1/等级5 的值 | floor |
   | --- | --- | --- | --- |
   | 节点表 `talentScale`/`combatScale` | `m*(x^p − 1) + 1` | `4` (精确) | 4 |
   | 游戏 `Combat.lua:1505 combatScale` | `m*x^p + b`，`b = low − m*1^p` | `3.9999999999999996` | **3** |

   导出给 3，所以按 Lua 结合序手工展开成 `R`（`m` 写成 `M` 表达式，而不是硬编码小数）。
   三套（1.00/1.30/1.50）15/15 全中。代表：`T_KINETIC_LEECH#0`。

### 仍不通（1 条）

`T_KINETIC_LEECH#3`（`getDam(self,t) = combatTalentMindDamage(t,5,45)*F`，`F = 1.5 − psi/maxPsi`）：
原文「疑点 1」的现象**复现且不可绕过**。输入集合一侧已经没问题（`[psi,精神强度]` 完全一致），
15 点里 14 点吻合，只有 `系数1.50 / 等级5` 导出 64、算得 63.4594。

这不是公式问题，而是导出侧的**双重取整**：源码 `info`（voracity.lua:80）的格式是 `%0.1f`，
`63.4594` 先被渲染成 `63.5`，导出再整数化得 64；工具 `matchesDisplayed` 在 `precision=0` 时只试
`round(63.4594)=63` 与 `trunc=63`，两种都中不了。
要让 `round` 得到 64 必须 `F ≥ 63.5/63.4594 = 1.00064`，即 `psi/maxPsi ≤ 0.49936`
（等价 `maxPsi ≥ 100.128`）；而标题钉死 `psi 50%`，`["actor","psi"]` 就是 50，`F` 恰好是 1.0。
**没有任何诚实写法能改变这个比值**，因此判为源码与导出的取整层不一致，不写盘、记为疑点。
建议主项目把这类「先 `%.1f` 再整数化」的双重取整纳入 `matchesDisplayed`（或按 title 里真实 format 标注 precision）。

### 与旧结论的关系

- 旧「无法建模」表里的 12 条（9 条 `(max …)` + 3 条 radius）**全部完成**，原因都是闸门要求「集合相等」，
  放宽成「覆盖」后 `consumed ⊆ declared` 自然成立；数值本来就 15/15。
- 旧「疑点 2」（radius 在 系数1/等级5 差 1）**已解决**：按 Lua 的 `m*x^p + b` 结合序写就吻合。
- 旧「疑点 1」（`T_KINETIC_LEECH#3` 双重取整）**仍成立**，是 13 条里唯一未通过项。
- 旧「疑点 3」（输入集合闸门系统性缺陷）已由本次闸门放宽修掉；`README` 式的建议保留备查。
