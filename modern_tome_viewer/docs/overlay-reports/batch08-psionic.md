# 覆盖层报告 · `batch08-psionic`（8 个灵能大系）

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/batch08-psionic.json`
结果：**52/52 通过**（数组长度 52，通过数 52；无跳过）

覆盖的大系与源码目录：`tome-src-full/data/talents/psionic/`

| 大系 | 目标数 | PASS | 跳过 |
| --- | --- | --- | --- |
| `psionic/feedback` | 12 | 12 | 0 |
| `psionic/projection` | 9 | 9 | 0 |
| `psionic/absorption` | 9 | 9 | 0 |
| `psionic/solipsism` | 9 | 9 | 0 |
| `psionic/kinetic-mastery` | 4 | 4 | 0 |
| `psionic/mentalism` | 3 | 3 | 0 |
| `psionic/nightmare` | 3 | 3 | 0 |
| `psionic/psi-fighting` | 3 | 3 | 0 |
| **合计** | **52** | **52** | **0** |

`--list` 的 52 行与覆盖层 52 条逐条对齐（无缺失、无多余，脚本交叉核对过）。
本批没有 `源码: 无记录`、没有「标题里没有唯一可变的轴」、也没有依赖运行时状态的条目。

---

## 已完成

全部 52 条均实测 `结论：PASS（三套 15 点全中，输入集合覆盖）`。
下表的 `source` 是 getter 所在行（`--list` 给的是 `newTalent{` 起始行）。
`C(...)` 等缩写见「发现的写法模式」。

### psionic/feedback（`feedback.lua`）

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_AMPLIFICATION | #0 | `["*",10,["talentLevel",true]]` | feedback.lua:74 | ✅ |
| T_AMPLIFICATION | #1 | `["*",100,["talentScale",0.15,0.5,0.75]]` | feedback.lua:70 | ✅ |
| T_AMPLIFICATION | #2 | `["*",100,["*",["combatLimit",["actor","角色等级"],0,0.5,1,0.2,50],["+",1,["talentScale",0.15,0.5,0.75]]]]` | misc/misc.lua:112 | ✅ |
| T_CONVERSION | #0 | `["*",10,["mindDamage",10,50]]` | feedback.lua:106 | ✅ |
| T_CONVERSION | #1 | `["mindDamage",10,50]` | feedback.lua:106 | ✅ |
| T_CONVERSION | #2 | `["*",1.8,["mindDamage",10,50]]` | feedback.lua:106 | ✅ |
| T_CONVERSION | #3 | `["*",1.5,["mindDamage",10,50]]` | feedback.lua:106 | ✅ |
| T_CONVERSION | #4 | `["mindDamage",10,50]` | feedback.lua:106 | ✅ |
| T_CONVERSION | #5 | `["/",["mindDamage",10,50],2]` | feedback.lua:106 | ✅ |
| T_CONVERSION | #6 | `["*",0.7,["mindDamage",10,50]]` | feedback.lua:106 | ✅ |
| T_CONVERSION | #7 | `["/",["mindDamage",10,50],4]` | feedback.lua:106 | ✅ |

### psionic/projection（`projection.lua`）

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_KINETIC_AURA | #0 / #1 | `["mindDamage",10,40]` | projection.lua:19 | ✅ |
| T_KINETIC_AURA | #2 | `["*",8,["mindDamage",10,40]]` | projection.lua:23 | ✅ |
| T_THERMAL_AURA | #0 / #1 | `["mindDamage",10,40]` | projection.lua:19 | ✅ |
| T_THERMAL_AURA | #2 | `["*",10,["mindDamage",10,40]]` | projection.lua:23 | ✅ |
| T_CHARGED_AURA | #0 / #1 | `["mindDamage",10,40]` | projection.lua:19 | ✅ |
| T_CHARGED_AURA | #2 | `["+",3,["floor",["*",0.5,["talentLevel"]]]]` | projection.lua:433 | ✅ |
| T_CHARGED_AURA | #3 | `["*",10,["mindDamage",10,40]]` | projection.lua:23 | ✅ |

（覆盖层里 #0 与 #1 是两条独立记录，表达式相同。）

### psionic/absorption（`absorption.lua`）

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_KINETIC_SHIELD | #0 | `["mindDamage",20,100]` | absorption.lua:21 | ✅ |
| T_KINETIC_SHIELD | #1 | `["-",100,["mindDamage",40,50]]` | absorption.lua:34 | ✅ |
| T_KINETIC_SHIELD | #2 | `["+",2,["talentScale",0.3,1]]` | absorption.lua:30 | ✅ |
| T_THERMAL_SHIELD | #0 | `["mindDamage",20,100]` | absorption.lua:21 | ✅ |
| T_THERMAL_SHIELD | #1 | `["-",100,["mindDamage",40,50]]` | absorption.lua:34 | ✅ |
| T_THERMAL_SHIELD | #2 | `["+",2,["talentScale",0.3,1]]` | absorption.lua:30 | ✅ |
| T_CHARGED_SHIELD | #0 | `["mindDamage",20,100]` | absorption.lua:21 | ✅ |
| T_CHARGED_SHIELD | #1 | `["-",100,["mindDamage",40,50]]` | absorption.lua:34 | ✅ |
| T_CHARGED_SHIELD | #2 | `["+",2,["talentScale",0.3,1]]` | absorption.lua:30 | ✅ |

### psionic/solipsism（`solipsism.lua`）

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_SOLIPSISM | #0 / #1 | `["*",100,TL(1,0.2,0.5)]`（见文首 `TL`，指数式展开） | solipsism.lua:30 | ✅ |
| T_SOLIPSISM | #2 | `["-",100,["/",["-",100,["talentLimit",50,3,11]],["+",1,["/",["+",1,["actor","角色等级"]],80]]]]` | solipsism.lua:31 | ✅ |
| T_SOLIPSISM | #3 | `["*",100,["-",1,["/",1,["+",1,["/",["+",1,["actor","角色等级"]],80]]]]]` | solipsism.lua:35 | ✅ |
| T_SOLIPSISM | #4 | `["talentLimit",50,3,11]` | solipsism.lua:34 | ✅ |
| T_BALANCE | #0 / #1 | `["*",100,["min",["+",0.1,["*",0.1,["talentLevel"]]],1]]` | solipsism.lua:73 | ✅ |
| T_CLARITY | #0 | `["*",100,TL(0,0.85,0.6)]` | solipsism.lua:112 | ✅ |
| T_CLARITY | #1 | `["*",100,["-",1,TL(0,0.85,0.6)]]` | solipsism.lua:144 | ✅ |

### psionic/kinetic-mastery · mentalism · nightmare · psi-fighting

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_DEFLECT_PROJECTILES | #0 / #2 | `["talentLimit",90,20,40]` | kinetic-mastery.lua:172 | ✅ |
| T_DEFLECT_PROJECTILES | #1 | `["min",2,["+",1,["floor",["/",["talentLevel"],4]]]]` | kinetic-mastery.lua:172 | ✅ |
| T_DEFLECT_PROJECTILES | #3 | `["floor",["talentScale",4,8,"log"]]` | kinetic-mastery.lua:167 | ✅ |
| T_PSYCHOMETRY | #0 | `["*",1.1539,["talentLevel"]]` | mentalism.lua:28 | ✅ |
| T_PROJECTION | #1 | `["/",["mindDamage",5,40],2]` | mentalism.lua:142 | ✅ |
| T_PROJECTION | #2 | `["ceil",["mindDamage",5,40]]` | mentalism.lua:142 | ✅ |
| T_NIGHTMARE | #1 | `["ceil",["mindDamage",5,25]]` | nightmare.lua:39 | ✅ |
| T_INNER_DEMONS | #1 | `["combatLimit",["mindDamage",15,30],100,0,0,21,21]` | nightmare.lua:102 | ✅ |
| T_WAKING_NIGHTMARE | #2 | `["combatLimit",["mindDamage",15,50],100,0,0,35.75,35.75]` | nightmare.lua:203 | ✅ |
| T_AUGMENTATION | #1 | `["ceil",["*",["talentScale",0.1,0.3],["actor","意志"]]]` | psi-fighting.lua:105 | ✅ |
| T_AUGMENTATION | #2 | `["ceil",["*",["talentScale",0.1,0.3],["actor","灵巧"]]]` | psi-fighting.lua:106 | ✅ |
| T_WARDING_WEAPON | #1 | `["floor",["*",100,["-",1,["exp",ST(灵巧,100,5,30)]]]]` | psi-fighting.lua:124 | ✅ |

---

## 发现的写法模式

1. **灵能系的「基础数值」几乎全是 `combatTalentMindDamage`**（12 个 getter）。
   节点表 `["mindDamage",base,max]` 直接可用，`damDesc(self, DamageType.X, v)` 只是显示包装、取 `v`。
   代表：`T_CONVERSION#1`（`md(10,50)`）、三个护盾的 `getShieldStrength`（`md(20,100)`）、
   三个光环的 `aura_strength`（`md(10,40)`）。

2. **同一个 getter 被 tooltip 多次引用 → 多条 acronym**。导出会把变量节点逐个编号，
   源码里出现两次的 `dam` / `power` / `chance` 就是两条独立条目，表达式照抄同一份。
   代表：`T_KINETIC_AURA#0/#1`、`T_PROJECTION#1/#2`、`T_DEFLECT_PROJECTILES#0/#2`。

3. **`combatTalentMindDamage` 的倍数/取整写在 info 或 getter 外层**：
   `base*10`（heal）、`base*1.8`（mana）、`base/2`（positive 与 spike 的 `*.5`）、
   `base*0.7`（psi）、`base/4`（hate）、`ceil(...)`、`floor(...)` 直接照抄成 `["*",…]` / `["ceil",…]`。
   代表：`T_CONVERSION#0..#7`、`T_CHARGED_AURA#2`。

4. **`combatTalentLimit` 必须按 `Combat.lua:1606` 的指数式手写展开**（本批 4 条）。
   节点表的 `["talentLimit",limit,low,high]` 用的是**幂式**近似
   （`fraction=(√tl−√m)/(√(5m)−√m)`），在 `tl = mastery`（=1.3）与 `tl = 5·mastery`（=6.5）
   两处会给出**精确的** `low` / `high`，而游戏用的是 `limit*(1−exp(√tl·a+b))`，
   在那两点得到 `84.99999999999997` / `59.99999999999999`，`%d` 截断后比节点表少 1。
   三套系数里 `1.30` 套的等级 1/5 正好命中这两个边界，所以凡是「`talentLimit` 结果 ×100 后
   贴近整数」的值都必须手写展开。文首 `TL(limit,low,high)` 即展开式：

   ```
   XL=["sqrt",1.3]  XH=["sqrt",6.5]
   TL(limit,low,high)  -- low>high 与 high>=low 两个分支都照 Combat.lua:1611-1619 抄
   ```

   代表：`T_CLARITY#0`（limit=0,low=0.85,high=0.6）、`T_SOLIPSISM#0/#1`（limit=1,low=0.2,high=0.5）。
   同样地 `T_SOLIPSISM#2/#4` 的 `talentLimit(50,3,11)` 因为后面还除以 lifemod，
   微差被冲掉，直接用节点即可。

5. **`combatStatLimit` 没有节点，用 `combatLimit` 也不行**（本批 1 条）。
   `Combat.lua:1630` 里的锚点是**字面舍入常量** `x_low = 5.6234`、`x_high = 31.623`，
   而 `100^0.75 = 31.6227766 < 31.623`，于是 stat=100 处返回值是 `30 − ε`，
   `math.floor` 得 **29**；`["combatLimit",…]` 用 `xHigh**0.75` 算锚点会精确得 30。
   必须按源码展开并把两个常量写死（它们是源码常量，不是输入）。
   代表：`T_WARDING_WEAPON#1`（`floor(combatStatLimit("cun",100,5,30))`）。

6. **`getTalentLevel(t)` vs `getTalentLevelRaw(t)`**：两者都出现过，靠三套导出是否同值区分。
   `T_AMPLIFICATION#0` 的 `getMaxFeedback = getTalentLevelRaw(t)*10` 三套都是 10/20/30/40/50 → `["talentLevel",true]`；
   `T_CHARGED_AURA#2` / `T_BALANCE` / `T_PSYCHOMETRY` 用**有效**等级 → `["talentLevel"]`。

7. **「另一技能的 getter」在本批只有一次**：`T_AMPLIFICATION#2` 的
   `getFeedbackRatio`（misc/misc.lua:112）= `combatLimit(level,…) * (1 + callTalent(T_AMPLIFICATION,"getFeedbackGain"))`。
   被转发的是**自己**的 getter，所以不用 `["talentRef",…]`，把 `getFeedbackGain` 的
   `combatTalentScale(t,0.15,0.5,0.75)` 直接内联展开即可（导出的 `talentRef` 基准是 0，用它反而错）。

8. **布尔/阶梯档要写成节点表内的等价式**：`getEvasion` 的第二返回值
   `self:getTalentLevel(t) >= 4 and 2 or 1` → `["min",2,["+",1,["floor",["/",["talentLevel"],4]]]]`
   （有效等级 <4 得 1，≥4 得 2；`min` 只为在更高系数下仍封顶 2）。
   代表：`T_DEFLECT_PROJECTILES#1`。

9. **`math.min(...)`、乘性资源系数直接照抄**：`T_BALANCE` 的 `min(0.1+tl*0.1,1)`、
   `T_AUGMENTATION` 的 `ceil(getMult*getWil())` / `ceil(getMult*getCun())`（标题声明了
   意志+灵巧，表达式只各用其中一个 → `覆盖（标题是超集）`，PASS）。

10. **`combatLimit` 用于「几率逼近上限」**：`T_INNER_DEMONS#1` / `T_WAKING_NIGHTMARE#2`
    写成 `["combatLimit",["mindDamage",b,m],100,0,0,X,X]`（`x_low=x_high` 的退化情形，
    节点实现与 `Combat.lua` 一致，15/15 通过）。

---

## 无法建模

本批 **0 条**：52 个目标全部写出了 15/15 的表达式，没有「读懂了但写不出来」的条目。
未出现运行时数据表、玩家武器、随机数、别的角色状态、需要先解析别的技能 getter 的情况。
唯一一处「源码与导出不一致」记在下面的「疑点」，但它仍有一条 15/15 的表达式。

---

## 疑点

1. **`T_PROJECTION` 的两个 `power` 在导出里是两个不同的阶梯（源码却是同一个值）**。
   `mentalism.lua:142` 只有
   `getPower = function(self, t) return math.ceil(self:combatTalentMindDamage(t, 5, 40)/2) end`，
   `info`（:227）写的是 `tformat(duration, power, power)` —— **同一个 `power` 出现两次**。
   但导出给的两档完全不同：

   | 套 | acronym#1 | acronym#2 |
   | --- | --- | --- |
   | 1.00 | 11/15/18/21/23 | 23/31/37/42/47 |
   | 1.30 | 13/17/21/24/26 | 26/35/42/48/53 |
   | 1.50 | 13/18/22/25/28 | 27/37/45/51/57 |

   - 源码 `ceil(md/2)` 应为 12/16/19/21/24（三套系数下另算），**两档都不是它**。
   - #1 恰好是**未 ceil 的** `md/2`（11.34→11、15.27→15、18.32→18、20.89→21、23.18→23，
     由判分器的整数读数归整）；#2 恰好是 `ceil(md)`（23/31/37/42/47，截断即中）。
   - 二者不可能同时来自一个 `power`，所以导出侧这两档**至少有一档不是当前源码的值**。
   本批按「导出是判分基准」把两条都写上并各自 15/15（#1 写裸 `md/2`、#2 写 `ceil(md)`），
   `note` 里已注明 #2 是「按导出反推」。**建议主项目复核 `mentalism.lua` 的版本**
   （要么源码 `getPower` 曾返回 `md`，要么第一条显示层用了 `power/2`）。

2. **节点表 `talentLimit` 与游戏 `combatTalentLimit` 不是同一算式**（不是数值差一点，而是构造不同）。
   节点用幂式 `limit+(low−limit)·((high−limit)/(low−limit))^fraction`，
   游戏用指数式 `limit·(1−exp(√tl·a+b))`（`Combat.lua:1603-1620`）。
   两者只在 `tl=mastery` 与 `tl=5·mastery` 两侧边界产生可见差异（约 1e-14，但 `%d` 截断会放大成 1）。
   本批凡结果贴近整数的都手写展开（模式 4）。**建议把 `talentLimit` 节点换成指数式**，
   否则 `--overlay` 与构建端会在同类技能上反复出现这类「差 1」。

3. **`combatLimit` 节点的锚点算法对 `combatStatLimit` 不适用**。
   `combatStatLimit` 用的字面常量 `5.6234 / 31.623` 与 `10^0.75 / 100^0.75` 有微小出入，
   stat=100 处会差 1（`T_WARDING_WEAPON#1`：导出 29 / `combatLimit` 算得 30）。
   本批已按源码展开写死常量。（若将来把该值接到滑条，滑条行为与游戏一致，无需担心。）

4. **`T_AMPLIFICATION#0` 的三套导出同值**，只能解释为按**原始等级**算
   （`getTalentLevelRaw`，`feedback.lua:74`），因此写 `["talentLevel",true]`。
   这与 `docs/expression-overlay.md` 的提示一致，不构成不一致，仅记录取证过程。

---

## 复核命令

```sh
cd modern_tome_viewer
node scripts/try-formula.mjs --overlay data/overlay-batches/batch08-psionic.json
# 覆盖层校验：52/52 通过
```
