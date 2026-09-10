# 覆盖层报告 · `psionic/other`

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/psionic__other.json`
结果：**10/10 通过**（`--list --tree psionic/other` 共 14 条目标；另 4 条记入「无法建模 / 疑点」）

## 已完成

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_TF_BOWMAN | #0 | `["/",<STAT>,2]` | thought-forms.lua:259 | ✅ |
| T_TF_BOWMAN | #1 | `<STAT>` | thought-forms.lua:259 | ✅ |
| T_TF_BOWMAN | #2 | `["/",<STAT>,2]` | thought-forms.lua:259 | ✅ |
| T_TF_WARRIOR | #0 | `<STAT>` | thought-forms.lua:361 | ✅ |
| T_TF_WARRIOR | #1 | `["/",<STAT>,2]` | thought-forms.lua:361 | ✅ |
| T_TF_WARRIOR | #2 | `["/",<STAT>,2]` | thought-forms.lua:361 | ✅ |
| T_TF_DEFENDER | #0 | `["/",<STAT>,2]` | thought-forms.lua:465 | ✅ |
| T_TF_DEFENDER | #1 | `["/",<STAT>,2]` | thought-forms.lua:465 | ✅ |
| T_TF_DEFENDER | #2 | `<STAT>` | thought-forms.lua:465 | ✅ |
| T_PERFECT_CONTROL | #0 | `["combatScale",<X>,15,0,49,34]` | npcs.lua:2533 | ✅ |

其中两条被复用的子表达式（批次文件里按字面写全，此处只为可读性缩写）：

```
STAT = ["^",["*",["/",["*",["+",5,["power","精神强度"]],
        ["+",1,["*",0.8,["-",["sqrt",["talentRef","T_THOUGHT_FORMS"]],1]]]],
        ["*",105,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],50],1.04]

X    = ["*",["talentLevel"],
        ["^",["+",1,["*",8,["+",["*",0.5,["/",["power","精神强度"],100]],
        ["*",0.5,["/",["talentLevel"],6.5]]]]],1.04]]
```

## 发现的写法模式

1. **`getStatBonus` 转发到别的技能、且该技能在导出里等级为 0**（代表：`T_TF_BOWMAN/#1`）。
   `thought-forms.lua` 里三个具象之弧的 `getStatBonus` 都写成
   `local t = self:getTalentFromId(self.T_THOUGHT_FORMS) return t.getStatBonus(self, t)`，
   真正的公式是 `T_THOUGHT_FORMS.getStatBonus = combatTalentMindDamage(t, 5, 50)`（thought-forms.lua:481）。
   注意两点：
   - 传入的 `t` 是 **T_THOUGHT_FORMS**，不是具象之弧本身 —— 所以驱动等级是 T_THOUGHT_FORMS 的等级；
   - 导出的标题里**没有**「技能等级」参数（只有 `精神强度 10, 25, 50, 75, 100`），也就是说导出把这个等级渲染成了 **0**。
   用 `["talentRef","T_THOUGHT_FORMS"]` 表达（该节点在未绑定标题参数时取导出基准 0），再套用
   docs 里「power 家族任意等级展开」得到 `STAT`。这条展开在 5 个点上每一处都靠 `%d` 截断才对上（算得 0.7088/1.4575/2.7377/4.0423/5.3636 → 导出 0/1/2/4/5），
   若误用 `["mindDamage",5,50]`（默认等级 1）会得到 3.78/… 全错。

2. **`combatStatTalentIntervalDamage` 的复合驱动**（代表：`T_PERFECT_CONTROL/#0`）。
   ```lua
   getBoost = function(self, t)
     return self:combatScale(self:getTalentLevel(t)*self:combatStatTalentIntervalDamage(t, "combatMindpower", 1, 9), 15, 0, 49, 34)
   end
   ```
   `combatStatTalentIntervalDamage(t, stat, min, max, stat_weight)`（`mod/class/interface/Combat.lua:2186`）=
   `rescaleDamage(min + (max-min)*((stat_weight*self[stat](self)/100) + (1-stat_weight)*getTalentLevel(t)/6.5))`，
   默认 `stat_weight = 0.5`；`rescaleDamage(x) = x^1.04`（`Combat.lua:1467`，注意 `x<=0` 时原样返回）。
   这里 `stat = "combatMindpower"` 即**精神强度**，于是驱动量可整体手写为表达式 —— 这是「公式族只吃自己等级」之外的又一种必须手工展开的写法。
   建议解析器规则：识别 `combatScale(getTalentLevel(t)*combatStatTalentIntervalDamage(t,"combatMindpower",a,b), yl, xl, yh, xh)` 这一形状。

3. **`tformat` 里同一局部变量反复使用、且没有取整层**（代表：`T_TF_DEFENDER/#0`）。
   `local stat = t.getStatBonus(self, t)` 后 `tformat(stat/2, stat/2, stat)` —— `stat` 本身**没有** `math.floor`，
   `stat/2` 也是实数。写成 `["floor", stat]/2` 会在 `0.7288→0`、`2.6818→2` 这类点上错（截断前就丢了小数）。
   直接保留实数、让校验层的 `matchDisplayed` 选 `%d` 截断读法即可。反过来，`getDamage` 里**有** `math.floor` 的
   （如 `T_TELEKINETIC_THROW`）就必须照抄 `["floor", …]`。
   一句话规律：**`info` 里直接用的 getter 值一般已被 getter 自己取整；`info` 里的 `/2`、`*0.5` 之后的取整要照抄源码，源码没写就别加。**

4. **同文件三个技能的 info 只差参数顺序**：具象之弧三个技能的 `getStatBonus` 完全一样，只有
   `tformat(stat/2, stat, stat/2)` / `tformat(stat, stat/2, stat/2)` / `tformat(stat/2, stat/2, stat)` 三种排列。
   这类「同一 getter + 参数排列不同」的大系可以先读一个再套用。

## 无法建模

| 技能id | acronym#N | 原因 |
| --- | --- | --- |
| T_TELEKINETIC_THROW | #0 | **标题给出两个 5 值阶梯**：`力量 10, 25, 50, 75, 100,` 与 `精神强度 10, 25, 50, 75, 100` 同时出现在一条 title 里，工具 `ladderAxis()` 因此返回 `null`（「标题里没有唯一可变的轴」），三套全无法校验。源码 `range = math.floor(combatStatScale("str",1,5) + combatMindpower()/20)`（npcs.lua:2634）确实是**双输入**，导出沿对角线同时变两个值，属导出侧的表示缺陷，不是公式问题。 |
| T_TELEKINETIC_THROW | #1 | **标题过度声明输入**：数值本身 15/15 全中（`["floor",["mindDamage",10,170]]`，三套 102/137/164/188/208、114/154/186/212/236、121/164/198/227/252 一字不差），但 title 同时声明了 `力量 100`，而 `getDamage = math.floor(combatTalentMindDamage(t, 10, 170))`（npcs.lua:2635）只消耗精神强度 → `标题声明 [力量, 精神强度] vs 消耗 [精神强度]`，输入集合闸门过不了。按规则不硬塞节点，故不入批次。 |
| T_TELEKINETIC_THROW | #2 | 同 #1：`["/",["mindDamage",10,170],2]` 三套 15/15 全中（含 68.5→69、113.72→114 这类四舍五入点），但输入集合同样被 `力量` 卡住。（顺带证明源码 `dam/2` 是**先除以 2 再显示**，不是在 getter 里取整。） |

三条都不是「写不出来」，而是**导出标题的元数据缺陷**：值公式已经读出并验证，只是闸门判定输入集合不一致 / 无唯一轴。若主项目愿意为 `T_TELEKINETIC_THROW` 放宽（把 #0 的两条阶梯合并成一条复合轴、或允许标题多声明的 `力量` 不参与校验），这三条可以立即补上。

## 疑点

| 技能id | acronym#N | 现象 | 三套数据 |
| --- | --- | --- | --- |
| T_PERFECT_CONTROL | #1 | **导出自身不自洽**：源码 `tformat(boost, 0.5*boost, dur)`（npcs.lua:2545），#1 就是同一个 `boost` 的一半。`["*",0.5,<#0 的表达式>]` 在系数 1.00 的 5 点、系数 1.30 的 5 点全部命中（15→18→21→24→27、16→20→24→27→31），但系数 1.50 的第 3、4 点算得 25.4602 / 29.4854，导出写的是 26 / 30（各差 0.54、0.51，刚好跨过四舍五入边界）。 | `#0` 导出：`29/36/42/48/53`、`31/40/47/54/61`、`33/42/50/58/66`；`#1` 导出：`15/18/21/24/27%`、`16/20/24/27/31%`、`17/21/26/30/33%` |

**为什么可以断定是导出错、而不是我的公式错**：两个 acronym 出自同一次 `tformat(boost, 0.5*boost, …)`，用的是**同一个 `boost`**。反推 1.50 套：
- `#0` 的显示值（`#0` 本身已实测 15/15 全中，截断读法）要求 `boost ∈ [33,34) / [42,43) / [50,51) / [58,59) / [66,67)`；
- `#1` 若要按四舍五入得到 `17/21/26/30/33`，则 `0.5*boost ∈ [16.5,17.5)/[20.5,21.5)/[25.5,26.5)/[29.5,30.5)/[32.5,33.5)`，即 `boost ∈ [33,35)/[41,43)/[51,53)/[59,61)/[65,67)`；
- 第 3 点交集 `[50,51) ∩ [51,53) = ∅`，第 4 点 `[58,59) ∩ [59,61) = ∅`。

即：**不存在任何一个 `boost` 值能同时产生这两个 acronym 在 1.50 套第 3、4 点的显示值**，因此该套导出（大概率是站点生成器版本/取整链与源码不同）在这两点上自行矛盾。按铁律 #1「三套 15 点全中」不允许把 #1 放进批次，故 `--overlay` 里不含它。

其余 13 条（10 条 PASS + T_TELEKINETIC_THROW #1/#2 值全中但输入集合被卡）都能在源码里找到唯一、可复核的写法，未见其它系统性偏移。

---

# 闸门放宽后的补做

**背景**：判分器的输入集合闸门已由「`consumed == declared`」放宽为「**覆盖** `consumed ⊆ declared`」——
表达式读到的每个输入都必须在标题里声明过即可；标题声明了但本值未用到的输入**不再算 FAIL**，
工具改显示 `✅ 覆盖（标题是超集，本值未用到：X）` 并给 PASS。

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/psionic__other.json`
结果：**12/12 通过**（批次文件已由原 10 条追加到 **12** 条，原有 10 条一字未改）
`--list --tree psionic/other` 共 14 条目标 → **12 条 PASS，2 条仍不通**（见下）。

## 补做清单（4 条）逐条结论

| 序 | 技能id | acronym#N | 结论 | 依据 |
| --- | --- | --- | --- | --- |
| 1 | T_TELEKINETIC_THROW | #1 | ✅ **PASS 并已写入** | `["floor",["mindDamage",10,170]]`，三套 15/15 全中；输入集合显示 `✅ 覆盖（标题是超集，本值未用到：力量）` |
| 2 | T_TELEKINETIC_THROW | #2 | ✅ **PASS 并已写入** | `["/",["mindDamage",10,170],2]`，三套 15/15 全中；同样命中「覆盖」路径 |
| 3 | T_TELEKINETIC_THROW | #0 | ❌ **仍不通（工具侧无唯一轴，非公式问题）** | 标题同时给出两条 5 值阶梯，`ladderAxis()` 返回 `null`；本轮工具**仍无法验收任何表达式**。见疑点 A |
| 4 | T_PERFECT_CONTROL | #1 | ❌ **仍不通（导出自身不自洽）** | 上一轮已证明 `#0`/`#1` 对同一个 `boost` 的可行区间交集为空；放宽后复跑依旧 `系数 1.5` 第 3、4 点 FAIL。见疑点 B，未再尝试其它写法 |

## 本轮新增条目（已追加进批次）

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_TELEKINETIC_THROW | #1 | `["floor",["mindDamage",10,170]]` | npcs.lua:2635 | ✅ |
| T_TELEKINETIC_THROW | #2 | `["/",["mindDamage",10,170],2]` | npcs.lua:2635 | ✅ |

源码（`tome-src-full/data/talents/misc/npcs.lua:2625` 起）：

```lua
range = function(self, t) return math.floor(self:combatStatScale("str", 1, 5) + self:combatMindpower()/20) end,
getDamage = function (self, t) return math.floor(self:combatTalentMindDamage(t, 10, 170)) end,
...
info = function(self, t)
  local range = self:getTalentRange(t)
  local dam = damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t))
  return (...):tformat(range, dam, dam/2, t.getKBResistPen(self, t))
end,
```

- `#1` = `dam`：`damDesc` 只做包裹，`getDamage` 自带的 `math.floor` 必须照抄（不写 `floor` 会在 4 个点上差 1）。
- `#2` = `dam/2`：**先除 2 再显示**，`info` 里没有取整层，所以不写 `floor`
  （含 `68.5→69`、`113.72→114` 这类四舍五入点，写 `floor` 会全错）。

## 疑点（本轮新增/复核）

### 疑点 A · `T_TELEKINETIC_THROW` #0 —— 双 5 值阶梯，工具侧无唯一轴

导出的 title 原文：

```
title="以下状况的数值<br>力量 10, 25, 50, 75, 100,<br>精神强度 10, 25, 50, 75, 100"  → 1, 3, 5, 7, 10
```

`scripts/lua-scaling.mjs:19 ladderAxis()` 的实现要求：**恰好一个**参数 `ladder.length > 1`，且其余参数全部单值：

```js
const axis = acronym.params.find((p) => p.ladder.length > 1);
if (!axis) return null;
...
const others = acronym.params.filter((p) => p !== axis);
if (others.some((p) => p.ladder.length > 1)) return null;
```

这里 `力量` 与 `精神强度` **都是 5 值**，于是 `others` 里命中第二条 → `ladderAxis()` 恒为 `null`，
三套导出全部报 `✗ 标题里没有唯一可变的轴`。**任何表达式（哪怕数值完全正确）都过不了**，
所以本轮**没有**把它写进批次。这是工具的能力边界，不是公式写不出来。

**补充证据：源码公式本身是对的。** 源码 `range = math.floor(combatStatScale("str",1,5) + combatMindpower()/20)`（npcs.lua:2634），
导出沿**对角线**（`str == 精神强度`）同时推进两个阶梯。
注意 `combatStatScale` 的默认 `power = 0.5`（即 `sqrt` 变换，锚点 10→1、100→5），
这与直觉的线性内插不同——按线性算会得到 `1/2/4/7/10`，全部错位。按 `sqrt` 变换手算：

| 阶梯点 | str = 精神强度 | `combatStatScale("str",1,5)` | `+mp/20` | `floor` | 导出 |
| --- | --- | --- | --- | --- | --- |
| 1 | 10 | 1.0000 | 1.5000 | **1** | 1 ✅ |
| 2 | 25 | 2.0750 | 3.3250 | **3** | 3 ✅ |
| 3 | 50 | 3.2867 | 5.7867 | **5** | 5 ✅ |
| 4 | 75 | 4.2163 | 7.9663 | **7** | 7 ✅ |
| 5 | 100 | 5.0000 | 10.0000 | **10** | 10 ✅ |

（用仓库引擎 `evaluateLuaExpression(["floor",["+",["statScale","str",1,5],["/",["power","精神强度"],20]]], {stats:{力量:v},powers:{"精神强度":v}})` 复算，
5 点输出 `1/3/5/7/10`，与导出逐点一致；三套系数下数值相同，也说明该值不随技能等级/系数变化，与源码 `range` 不含 `t` 一致。）

**给主项目的建议**：若要收下这条，需要工具支持「多轴对角线」——把 title 里并列的多条阶梯视为一个复合轴
（各阶梯同索引取值同时推进），或允许为 `力量` 声明一个与 `精神强度` 联动的绑定。在此之前这条无法验收。

### 疑点 B · `T_PERFECT_CONTROL` #1 —— 导出自身不自洽（复核，未再尝试）

按指示本轮**未再尝试**新写法，仅复跑上一轮结论一次以确认放宽闸门后判据未变：

```
node scripts/try-formula.mjs --talent T_PERFECT_CONTROL --arg 1 \
  --expr '["*",0.5,["combatScale",["*",["talentLevel"],["^",["+",1,["*",8,["+",["*",0.5,["/",["power","精神强度"],100]],["*",0.5,["/",["talentLevel"],6.5]]]]],1.04]],15,0,49,34]]'
输入集合：标题声明 [精神强度] vs 表达式消耗 [精神强度] ✅ 完全一致
  系数 1   : ✅ 5/5    系数 1.3 : ✅ 5/5
  系数 1.5 : ❌  3→ 导出 26% / 算得 25.4602❌   4→ 导出 30% / 算得 29.4854❌
结论：FAIL
```

输入集合这条**已经不构成障碍**（本来就完全一致），卡住它的是铁律 #1：`#0` 与 `#1` 出自同一次
`tformat(boost, 0.5*boost, dur)`（npcs.lua:2545），1.50 套第 3、4 点对 `boost` 的可行区间交集为空
（`[50,51) ∩ [51,53) = ∅`、`[58,59) ∩ [59,61) = ∅`），即**不存在任何 boost 能同时产生这两个 acronym 的显示值**。
放宽输入集合闸门对这条没有帮助，属导出侧缺陷，保持不入批次。

## 小结

- **补做 4 条 → PASS 2 条**（`T_TELEKINETIC_THROW` #1、#2，均已写盘），**仍不通 2 条**（`#0` 工具无唯一轴、`T_PERFECT_CONTROL` #1 导出不自洽）。
- 批次文件：原 10 条 → 12 条，`--overlay` 首行 **`覆盖层校验：12/12 通过`**，与数组长度 **12** 一致。
