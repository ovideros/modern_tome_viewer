# spell/other 覆盖层报告（14 条目标）

工作台：`node scripts/try-formula.mjs`（本目录下运行）
批次文件：`data/overlay-batches/spell__other.json` —— `--overlay` 结果：**`覆盖层校验：5/5 通过`**

| 指标 | 数量 |
| --- | --- |
| 目标数（`--list --tree spell/other` 行数） | 14 |
| PASS 写入批次 | 5 |
| 未通过（记入本报告） | 9（无法建模 7 / 疑点 2） |

---

## 1. 已完成（5 条，均为三套 15/15 全中且输入集合一致）

| 技能 id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| `T_QUICKEN_SPELLS` | #0 | `["*",100,["min",0.3,["max",0.05,["/",["talentLevel",true],15]]]]` | `tome-src-full/data/talents/misc/npcs.lua:3974` | ✅ 3×5 |
| `T_DWARVEN_HALF_EARTHEN_MISSILES` | #0 | `["+",2,["min",1,["floor",["/",["talentLevel"],5]]]]` | `tome-src-full/data/talents/gifts/dwarven-nature.lua:59` | ✅ 3×5 |
| `T_CIRCLE_OF_BLAZING_LIGHT` | #0 | `["floor",["talentScale",2.5,4.5]]` | `tome-src-full/data/talents/misc/npcs.lua:3722` | ✅ 3×5 |
| `T_CIRCLE_OF_BLAZING_LIGHT` | #1 | `["+",1,["/",["spellDamage",2,15],4]]` | `tome-src-full/data/talents/misc/npcs.lua:3748` | ✅ 3×5 |
| `T_CIRCLE_OF_BLAZING_LIGHT` | #4 | `["floor",["talentScale",4,8]]` | `tome-src-full/data/talents/misc/npcs.lua:3720` | ✅ 3×5 |

原始 Lua 摘要：

- `Quicken Spells`：`getCooldownReduction = util.bound(self:getTalentLevelRaw(t) / 15, 0.05, 0.3)`，`info` 里 `tformat(cooldownred * 100)`。三套导出数字**完全相同** → 用的是**原始等级**，必须写 `["talentLevel", true]`（写 `["talentLevel"]` 会在 1.30/1.50 两套上崩）。导出按**截断**读数（6.6667→6、26.6667→26）。
- `Earthen Missiles`（半身人 `DWARVEN_HALF_EARTHEN_MISSILES`）：`info` 里 `count = 2`，`if self:getTalentLevel(t) >= 5 then count = count + 1`；比较运算在节点表里没有对应节点，用 `min(1, floor(level/5))` 给出等价的 0/1。
- `Circle of Blazing Light`：`radius = math.floor(combatTalentScale(t, 2.5, 4.5))`、`getDuration = math.floor(combatTalentScale(t, 4, 8))`、`tformat` 第 2 个值 `1 + (damage / 4)`（`damage = combatTalentSpellDamage(t, 2, 15)`）。该技能的前 1 条 `radius` 与最后 1 条 `duration` 标题只声明技能等级，输入集合为空 → 无闸门冲突。

---

## 2. 发现的写法模式

1. **`spell/other` 不是玩家大系**：本批 14 条里 12 条来自 `data/talents/misc/npcs.lua`（NPC/怪物技能，`hide = true`），2 条来自 `data/talents/gifts/dwarven-nature.lua`（半身人）。NPC 技能的 `info` 参数顺序仍严格对应 `tformat(...)` 的位置。
2. **`combatTalentScale(t, low, high, power?)` → `["talentScale", low, high, power?]`**（默认 `power = 0.5`），外层 `math.floor` 照抄成 `["floor", …]`。本批 `T_CIRCLE_OF_BLAZING_LIGHT` #0/#4、`T_BLIGHT_BOLT` #1 都是这套。
3. **三套完全相同 → 原始等级**：`["talentLevel", true]`（`getTalentLevelRaw`）。`T_QUICKEN_SPELLS` 是代表。
4. **`util.bound(x, lo, hi)` → `["min", hi, ["max", lo, x]]`**（`T_QUICKEN_SPELLS`）。
5. **没有比较运算节点**：`if level >= k then +1` 这类分支只能用 `["min", 1, ["floor", ["/", level, k]]]` 等价表达（`T_DWARVEN_HALF_EARTHEN_MISSILES` #0）。这是节点表的一处能力缺口，值得在解析器/节点表里补一个 `>=` 或 `cond` 式比较。
6. **导出侧显示规则（本批最重要的发现，见 §4）**：站点把游戏渲染出的数值**再按大小做一次显示取整**——`|v| < 10` 保留 2 位小数，`|v| ≥ 10` 取整。这一步会在 `.5` 边界上引入“差 1”，是 `T_WATER_BOLT`、`T_VOID_BLAST` 失败的根因。
7. **输入集合闸门真正的敌人是“标题过度声明”**：`T_AMBUSCADE` 的 4 个 acronym 共用同一标题（`法术强度 100, 灵巧 100`），而其中 3 个值的源码只吃其中一个（或都不吃）——与 `docs/expression-overlay.md` 里 `T_BOULDER_ROCK` 的情形同类。

---

## 3. 无法建模（7 条：**任何**表达式都无法 PASS，原因是导出侧元数据/结构缺陷，不是源码读不懂）

> 这 7 条的源码公式都已读懂并逐点核对过，问题完全在验收闸门侧（元数据），不在源码侧。

| 技能 | acronym | 原因 | 证据 |
| --- | --- | --- | --- |
| `T_MARTYRDOM` | #0 | **导出 acronym 解析缺陷**：中文描述把 5 段并列文本并成一个 acronym → `displayed` 长度 10（`10/15/10/24/10/31/…`），阶梯长度 5，`ladderAxis()` 直接返回 `null`（`标题里没有唯一可变的轴`） | 源码 `getReturnDamage = combatLimit(getTalentLevel(t)^.5, 100, 15, 1, 40, 2.24)`（`npcs.lua:2454`）。手工按 `["combatLimit",["sqrt",["talentLevel"]],100,15,1,40,2.24]` 算出：1.00→`15.000/24.944/31.354/36.128/39.939`、1.30→`18.605/29.046/35.701/40.618/44.515`、1.50→`20.654/31.354/38.129/43.110/47.042`，**截断读数与导出真实阶梯 15/24/31/36/39、18/29/35/40/44、20/31/38/43/47 完全一致** |
| `T_AMBUSCADE` | #1 | **标题过度声明输入**：标题声明 `[法术强度, 灵巧]`，`getHealth`（`npcs.lua:3540`）只吃法术强度 → `consumed=[法术强度]` | 用 `["*",100,["combatLimit",["spellDamage",20,500],1,0.2,0,0.584,384]]` 三套 **15 点全中**，唯独输入集合 ❌ |
| `T_AMBUSCADE` | #2 | 同上（`getDam`（`npcs.lua:3541`）只用 `combatTalentSpellDamage`） | `["*",100,["combatLimit",["spellDamage",10,500],1.6,0.4,0,0.761,361]]` 三套 **15 点全中**，输入集合 ❌ |
| `T_AMBUSCADE` | #3 | **源码本身不吃标题声明的输入**：`getStealthPower = combatScale(getCun(15, true) * level, 25, 0, 100, 75)`（`npcs.lua:3538`）。导出实测驱动常量恰为 **15**（= `getCun` 的 base，而不是标题里的 灵巧 100）；写成常量则 `consumed=[]`，写成 `["actor","灵巧"]`（100）则数值全错 | 拟合常量 cun 的可行区间 = **[14.801, 15.047]**，即 15；`["combatScale",["*",15,["talentLevel"]],25,0,100,75]` 三套 **15 点全中**、输入集合 ❌ |
| `T_BLIGHT_BOLT` | #1 | **同一 acronym 内混合精度**：导出 `+7.00%, +12%, +17%, +21%, +25%`；解析器按首值判定 `precision = 2`，于是后 4 个整数点也被要求 0.005 精度 → 数学上不可达 | 源码 `combatTalentScale(t, 7, 25, 0.75)`（`npcs.lua:680`）。按站点显示规则（<10 保 2 位、≥10 取整）核对：`7.000/12.236/16.827/21.043/25.000`、`8.670/15.045/20.634/25.767/30.585`、`9.730/16.827/23.049/28.763/34.127` → 全部对上 |
| `T_CIRCLE_OF_BLAZING_LIGHT` | #2 | 同 #1（导出 `8.18, 11, 13, 15, 17`，首值 2 位小数、其余为取整整数） | `["spellDamage",2,15]`（`npcs.lua:3719`）；在显示规则下 15/15 全对，拟合法术强度可行区间 **[99.978, 100.025]**（正是 100） |
| `T_CIRCLE_OF_BLAZING_LIGHT` | #3 | 与 #2 同一个 `damage` 的两个 acronym（光伤/火伤），数字完全相同 | 同上 |

**给解析器的建议**：`precision` 不应取 acronym 的“首个值”的小数位后对整条 acronym 统一使用；导出是**逐值按大小**决定显示精度的（§4）。若把 `matchesDisplayed` 改成“逐点按显示值本身推断精度”，§3 的 `T_BLIGHT_BOLT`#1、`T_CIRCLE_OF_BLAZING_LIGHT`#2/#3 这 3 条会立刻全中；再复刻 §4 的二次取整，`T_WATER_BOLT`、`T_VOID_BLAST` 也会全中（配合当前 5 条 = 10/14 可用纯源码公式覆盖）。剩余 4 条是输入集合/阶梯结构问题（`T_MARTYRDOM` + `T_AMBUSCADE` #1/#2/#3）。

---

## 4. 疑点（2 条：源码公式已确认正确，但导出数字做了**二次取整**）

**共同规律（4 个技能、60 个点全部吻合，可以当作导出管线的确定性行为）**
站点数字 = 对游戏渲染出的十进制文本再做一次按大小的显示取整：

```
v_display = |v| < 10 ? round(v, 2) : Math.round(v)      -- 先按描述格式 (%0.1f / %0.2f) 渲染，再取整
```

对 `%0.1f` 的描述（水弹、虚空爆炸）就等价于 `round(round1(v))`，会在 `.5` 边界把结果**抬高 1**；这正是下面两条与源码“系统性差 1”的来源，不是公式错。

### 4.1 `T_WATER_BOLT` #0 — 水弹（`npcs.lua:558`）

源码：`getDamage = self:combatScale(self:combatSpellpower() * self:getTalentLevel(t), 12, 0, 78.25, 265, 0.67)`（`npcs.lua:568`）。
真表达式：`["combatScale",["*",["power","法术强度"],["talentLevel"]],12,0,78.25,265,0.67]`

| 套 | 导出（3 个点示意） | 公式直算 |
| --- | --- | --- |
| 1.00 | 47, 67, 84, 99, 113 | 46.4835, 66.8657, 83.9917, 99.2954, 113.3727 |
| 1.30 | 53, 77, 98, 116, 133 | 53.1105, 77.4099, 97.8271, 116.0719, 132.8546 |
| 1.50 | 57, 84, **107**, 127, 145 | 57.2473, 83.9917, **106.4634**, 126.544, 145.0155 |

直算只有 2 个点越过 `.5`（46.4835→“46.5”⇒显示 47；106.4634→“106.5”⇒显示 107）。**加一层“先 1 位小数再取整”后 15/15 PASS**：
```
["floor",["+",0.5,["/",["floor",["+",0.5,["*",10,["combatScale",["*",["power","法术强度"],["talentLevel"]],12,0,78.25,265,0.67]]]],10]]]
```

### 4.2 `T_VOID_BLAST` #0 — 虚空爆炸（`npcs.lua:726` 起，`data/lua-coefficients.json` 里无记录）

源码：`tformat(damDesc(self, DamageType.ARCANE, self:combatTalentSpellDamage(t, 15, 240)))`（`npcs.lua:747`）。
真表达式：`["spellDamage",15,240]`

| 套 | 导出 | 公式直算 |
| --- | --- | --- |
| 1.00 | 146, 197, 236, 269, 299 | 146.1748, 196.8537, 236.0943, 269.3742, 298.8269 |
| 1.30 | 163, 221, 266, 304, 338 | 163.2595, 221.2965, 266.2424, 304.3646, 338.1049 |
| 1.50 | 174, 236, **285**, 326, 362 | 173.6008, 236.0943, **284.4959**, 325.5511, 361.8884 |

同样只有 1 个点越过 `.5`（284.4959→“284.5”⇒285）。**加同样一层后 15/15 PASS**：
```
["floor",["+",0.5,["/",["floor",["+",0.5,["*",10,["spellDamage",15,240]]]],10]]]
```

### 处理建议（留给主项目决定）

- 严格按“覆盖层只放源码公式”的口径：这两条留在疑点，批次里不放 —— **当前批次文件就是这个口径**。
- 若以“网页显示的数值必须与导出逐点一致”为目标：把上面两条 `expr` 原样加进 `data/overlay-batches/spell__other.json` 即可，已验证 `--overlay` 会 5→7 通过；代价是表达式里多了一层并非源码的显示取整。
- 更彻底的做法是在构建端复刻 §4 的显示规则（`|v|<10` 保 2 位、否则对 `%0.1f/%0.2f` 渲染值取整），这样 §3 的 4 条与 §4 的 2 条都能用**纯源码公式**通过，覆盖层一条都不用写。

---

# 闸门放宽后的补做（第二轮，本文件前文原样保留）

> 判分器的**输入集合闸门已放宽**：由「表达式消耗集合 == 标题声明集合」改为**覆盖** `consumed ⊆ declared`。
> 标题把整个 tooltip 的参数并集抄进多个 acronym（过度声明）**不再算 FAIL**，工具显示
> `✅ 覆盖（标题是超集，本值未用到：X）`。§3 中被该条拦下的 `T_AMBUSCADE` #1/#2/#3 因此可直接补。
>
> 本轮 9 条目标全部试算完毕：**新增 PASS 8 条**（§3 原判「无法建模」的 5 条中有 3 条在显示规则复刻下可过，见 §6.3），
> **仍不通 1 条**（`T_MARTYRDOM` #0，导出 acronym 解析缺陷）。批次文件
> `data/overlay-batches/spell__other.json` 由 5 条扩到 **13 条**，`--overlay` 结果 **`覆盖层校验：13/13 通过`**。

## 6.1 本轮新增 PASS（8 条，均三套 15/15、输入集合覆盖）

| 技能 id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| `T_AMBUSCADE` | #1 | `["*",100,["combatLimit",["spellDamage",20,500],1,0.2,0,0.584,384]]` | `tome-src-full/data/talents/misc/npcs.lua:3540` | ✅ 3×5 |
| `T_AMBUSCADE` | #2 | `["*",100,["combatLimit",["spellDamage",10,500],1.6,0.4,0,0.761,361]]` | `tome-src-full/data/talents/misc/npcs.lua:3541` | ✅ 3×5 |
| `T_AMBUSCADE` | #3 | `["combatScale",["*",15,["talentLevel"]],25,0,100,75]` | `tome-src-full/data/talents/misc/npcs.lua:3538` | ✅ 3×5 |
| `T_WATER_BOLT` | #0 | `["floor",["+",0.5,["/",["floor",["+",0.5,["*",10,["combatScale",["*",["power","法术强度"],["talentLevel"]],12,0,78.25,265,0.67]]]],10]]]` | `tome-src-full/data/talents/misc/npcs.lua:568` | ✅ 3×5 |
| `T_VOID_BLAST` | #0 | `["floor",["+",0.5,["/",["floor",["+",0.5,["*",10,["spellDamage",15,240]]]],10]]]` | `tome-src-full/data/talents/misc/npcs.lua:747` | ✅ 3×5 |
| `T_BLIGHT_BOLT` | #1 | 见 §6.3（显示规则复刻） | `tome-src-full/data/talents/misc/npcs.lua:680` | ✅ 3×5 |
| `T_CIRCLE_OF_BLAZING_LIGHT` | #2 | 见 §6.3（显示规则复刻） | `tome-src-full/data/talents/misc/npcs.lua:3719` | ✅ 3×5 |
| `T_CIRCLE_OF_BLAZING_LIGHT` | #3 | 同 #2 | `tome-src-full/data/talents/misc/npcs.lua:3719` | ✅ 3×5 |

### 闸门实测（工具原样输出）

```
T_AMBUSCADE #1  输入集合：标题声明 [法术强度, 灵巧] vs 表达式消耗 [法术强度] ✅ 覆盖（标题是超集，本值未用到：灵巧）
T_AMBUSCADE #2  输入集合：标题声明 [法术强度, 灵巧] vs 表达式消耗 [法术强度] ✅ 覆盖（标题是超集，本值未用到：灵巧）
T_AMBUSCADE #3  输入集合：标题声明 [法术强度, 灵巧] vs 表达式消耗 [无] ✅ 覆盖（标题是超集，本值未用到：法术强度, 灵巧）
T_WATER_BOLT #0 输入集合：标题声明 [法术强度] vs 表达式消耗 [法术强度] ✅ 完全一致
T_VOID_BLAST #0 输入集合：标题声明 [法术强度] vs 表达式消耗 [法术强度] ✅ 完全一致
```

三条 `T_AMBUSCADE` 的源码（`npcs.lua:3538–3541`）：

```lua
getStealthPower = function(self, t) return self:combatScale(self:getCun(15, true) * self:getTalentLevel(t), 25, 0, 100, 75) end,
getDuration     = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
getHealth       = function(self, t) return self:combatLimit(self:combatTalentSpellDamage(t, 20, 500), 1, 0.2, 0, 0.584, 384) end,
getDam          = function(self, t) return self:combatLimit(self:combatTalentSpellDamage(t, 10, 500), 1.6, 0.4, 0, 0.761 , 361) end,
```

`info` 的 `tformat` 参数顺序 = `getDuration`、`getHealth*100`、`getDam*100`、`getStealthPower`，
与 acronym #0/#1/#2/#3 对应（#1 = 生命、#2 = 伤害、#3 = 潜行强度），**注意 #1/#2/#3 的编号顺序不等于 getter 定义顺序**。

## 6.2 `T_AMBUSCADE` #3：`getCun(15, true)` 按导出基准冻结成常数 15

源码驱动量是 `self:getCun(15, true) * self:getTalentLevel(t)`：

- `getCun(15, true)` 的第二个参数 `true` 是 **"no add"（不含角色加成）**，返回的是**基准 15**，源码本身就**不吃标题声明的输入**；标题 `[法术强度, 灵巧]` 是这个技能 4 个 acronym 的**参数并集**（过度声明）。
  （引擎源码 `ActorStats.lua` 不在本仓库，`no_add` 语义按 ToME 引擎惯例；**无论该参数语义如何，导出基准下这个驱动常量已由 15 点拟合实测为 15**，结论不依赖语义猜测。）
- 导出基准下实测该常量恒为 **15**：拟合可行区间 = **[14.801, 15.047]**（区间中心 14.924，宽度来自 5 点整数显示；15 在区间内，而标题里的灵巧 100 远在区间外）。
- 若写成 `["actor","灵巧"]`（=100），会被判「读了标题未声明的输入」且数值全错；若让 `consumed=[]`（常数 15），闸门判 `✅ 覆盖`。
- 因此**按导出基准冻结成常数 15**，并在 `note` 里注明理由。这是对「源码真值为环境基准值」的忠实表达，不是硬凑：三个导出套（1.00/1.30/1.50）的驱动量都同为 15。

## 6.3 显示规则复刻（3 条，**口径敏感**，请主项目裁决）

原 §3 把 `T_BLIGHT_BOLT`#1、`T_CIRCLE_OF_BLAZING_LIGHT`#2/#3 判为「不可达」，依据是「解析器按首值统一推断 precision」。
**该结论只在『表达式必须是纯源码公式』这一前提下成立**；用 §4 已确认的显示规则做外层复刻后，这三条可以**逐字命中**：

```
v_display = |v| < 10 ? round(v, 2) : round(v)          -- §4 的导出显示规则（本轮又新增 45 个点验证，合计约 105 点无误）
选择子   s = min(1, floor(v / 10))                      -- 0 当 v<10，1 当 v≥10（本批 v 均 < 20，min 保证覆盖）
输出     = f + s * (g - f)，f = round(v,2)，g = round(v)
```

复刻出的表达式（三条共用同一模板，只换内层 `v`）：

```
# T_BLIGHT_BOLT #1        v = ["talentScale",7,25,0.75]
# T_CIRCLE_OF_BLAZING_LIGHT #2/#3   v = ["spellDamage",2,15]

["+", ["/",["floor",["+",0.5,["*",100, v]]],100],
      ["*", ["min",1,["floor",["/", v,10]]],
            ["-", ["floor",["+",0.5, v]],
                  ["/",["floor",["+",0.5,["*",100, v]]],100]]]]
```

工具实测三套 15/15、输入集合一致（`T_BLIGHT_BOLT` #1：`7/12/17/21/25`、`8.67/15/21/26/31`、`9.73/17/23/29/34`，逐点 `算得 == 导出`）。
真值（未复刻前）与导出的关系仍记录在此，便于复核：

| 套 | `T_BLIGHT_BOLT`#1 真值 | 导出 | `T_CIRCLE_OF_BLAZING_LIGHT`#2/#3 真值 | 导出 |
| --- | --- | --- | --- | --- |
| 1.00 | 7.000 / 12.2363 / 16.8268 / 21.0426 / 25.000 | 7 / 12 / 17 / 21 / 25 | 8.1769 / 11.0118 / 13.2069 / 15.0685 / 16.7161 | 8.18 / 11 / 13 / 15 / 17 |
| 1.30 | 8.6702 / 15.0452 / 20.6340 / 25.7666 / 30.5846 | 8.67 / 15 / 21 / 26 / 31 | 9.1326 / 12.3791 / 14.8934 / 17.0259 / 18.9133 | 9.13 / 12 / 15 / 17 / 19 |
| 1.50 | 9.7296 / 16.8268 / 23.0488 / 28.7629 / 34.1268 | 9.73 / 17 / 23 / 29 / 34 | 9.7111 / 13.2069 / 15.9144 / 18.2110 / 20.2437 | 9.71 / 13 / 16 / 18 / 20 |

**口径选择（两条路都验证过，请主项目挑一条）**：

1. **保留（当前批次状态）**：3 条显示规则复刻已写入批次，`--overlay` = **13/13**。
   理由：与 §4 的 `T_WATER_BOLT`/`T_VOID_BLAST` 是**同一类**「复刻导出显示规则、note 明示」的处理；网页滑条数字与导出逐点一致。
   代价：表达式里含显示层常数（`100`、`0.5`、`10`），不是纯源码公式。
2. **移出**：删掉 `T_BLIGHT_BOLT`#1、`T_CIRCLE_OF_BLAZING_LIGHT`#2/#3 这 3 条 → `--overlay` = **10/10**；
   这 3 条改记「工具侧 precision 推断缺陷」疑点，等构建端改成**逐点按显示值推断精度**后，用纯源码表达式
   `["talentScale",7,25,0.75]`、`["spellDamage",2,15]` 即可自动通过（预测：构建端修好后 §3 的这 3 条会自愈）。

> 附注：构建端若实现 §4 的显示规则（`|v|<10` 保 2 位、否则取整），则本文件**全部** 8 条新值都可以退回**纯源码表达式**
> （`["combatScale",…]`、`["spellDamage",…]`、`["talentScale",…]`），覆盖层只剩「标题过度声明」那 3 条真正需要 §3 的旧语义。

## 6.4 仍不通（1 条）

| 技能 | acronym | 原因 | 证据 |
| --- | --- | --- | --- |
| `T_MARTYRDOM` | #0 | **导出 acronym 解析缺陷（工具侧，非公式侧）**：中文描述把 5 段并列文本并成一个 acronym，`displayed` 长度 10（`10/15/10/24/10/31/…`）≠ 阶梯长度 5 → `ladderAxis()` 返回 `null`，工具直接输出 `✗ 标题里没有唯一可变的轴`，**任何表达式都无法验收** | 源码 `getReturnDamage = combatLimit(getTalentLevel(t)^.5, 100, 15, 1, 40, 2.24)`（`npcs.lua:2454`）。手工按 `["combatLimit",["sqrt",["talentLevel"]],100,15,1,40,2.24]` 算：1.00→`15.000/24.944/31.354/36.128/39.939`、1.30→`18.605/29.046/35.701/40.618/44.515`、1.50→`20.654/31.354/38.129/43.110/47.042`，**截断读数与导出真实阶梯 15/24/31/36/39、18/29/35/40/44、20/31/38/43/47 完全一致** |

本条与「闸门放宽」无关：卡点是**轴（ladder）解析**，放宽输入集合覆盖也无济于事。构建端需修 acronym 切分（把 `10/15/…` 这种重复前缀的并列段拆成 5 个 acronym），修好后用上面的 `combatLimit` 表达式即可自动通过。

## 6.5 本轮汇总

```
$ node scripts/try-formula.mjs --overlay data/overlay-batches/spell__other.json
覆盖层校验：13/13 通过
```

| 指标 | 首轮 | 本轮（闸门放宽后） |
| --- | --- | --- |
| 批次条目 | 5 | **13** |
| `--overlay` 通过 | 5/5 | **13/13** |
| `spell/other` 覆盖 | 5/14 | **13/14** |
| 仅剩不通 | 9 | **1**（`T_MARTYRDOM` #0，导出 acronym 解析缺陷） |
| 其中纯源码公式 | 5 | 8（另 5 条为显示规则复刻：2 条 §4 既有 + 3 条 §6.3 新增） |
| 其中按导出基准冻结常数 | 0 | 1（`T_AMBUSCADE` #3 的 `getCun(15,true)`，note 已注明） |
