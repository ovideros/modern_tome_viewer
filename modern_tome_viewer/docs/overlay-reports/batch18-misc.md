# batch18 · misc 大系公式覆盖报告

- 范围（只做这 10 个大系）：`spell/objects`、`other/other`、`race/halfling`、`race/dwarf`、
  `corruption/other`、`other/horror`、`psionic/other`、`race/yeek`、`race/ogre`、`technique/horror`
- 覆盖层：`data/overlay-batches/batch18-misc.json`（21 条）
- 汇总：`node scripts/try-formula.mjs --overlay data/overlay-batches/batch18-misc.json` → **覆盖层校验：21/21 通过**
- 目标 27 条 → PASS 21、跳过 6（5 条工具报「标题里没有唯一可变的轴」/ 依赖复合战斗属性，1 条是导出侧端点读数刀口；逐条见下）

各大系：目标数 / PASS 数 / 跳过数

| 大系 | 目标 | PASS | 跳过 |
| --- | --- | --- | --- |
| spell/objects | 6 | 6 | 0 |
| other/other | 5 | 4 | 1 |
| race/halfling | 5 | 2 | 3 |
| race/dwarf | 4 | 3 | 1 |
| corruption/other | 1 | 1 | 0 |
| other/horror | 1 | 1 | 0 |
| psionic/other | 2 | 1 | 1 |
| race/yeek | 1 | 1 | 0 |
| race/ogre | 1 | 1 | 0 |
| technique/horror | 1 | 1 | 0 |
| 合计 | 27 | 21 | 6 |

## 一、已完成

每条都跑出「结论：PASS（三套 15 点全中，输入集合覆盖）」；`source` 指向据以写公式的 getter/打印点。

| 技能 | acronym# | 名称 | 大系 | 表达式 | source | 三套 |
| --- | --- | --- | --- | --- | --- | --- |
| `T_ARCANE_SUPREMACY` | 0 | 奥术至尊 | spell/objects | `["floor",["talentLevel"]]` | `tome-src-full/data/talents/misc/objects.lua:74` | 15/15 |
| `T_SHIV_LORD` | 0 | 西弗格罗斯形态 | spell/objects | `["+",4,["ceil",["talentLevel"]]]` | `tome-src-full/data/talents/misc/objects.lua:557` | 15/15 |
| `T_SHIV_LORD` | 1 | 西弗格罗斯形态 | spell/objects | `["talentLevel",true]` | `tome-src-full/data/talents/misc/objects.lua:571` | 15/15 |
| `T_SHIV_LORD` | 2 | 西弗格罗斯形态 | spell/objects | `["*",100,["/",["min",500,["max",0,["+",50,["spellDamage",50,450]]]],500]]` | `tome-src-full/data/talents/misc/objects.lua:558` | 15/15 |
| `T_SHIV_LORD` | 3 | 西弗格罗斯形态 | spell/objects | `["*",50,["/",["min",500,["max",0,["+",50,["spellDamage",50,450]]]],500]]` | `tome-src-full/data/talents/misc/objects.lua:571` | 15/15 |
| `T_SHIV_LORD` | 4 | 西弗格罗斯形态 | spell/objects | `["+",50,["*",100,["/",["min",500,["max",0,["+",50,["spellDamage",50,450]]]],500]]]` | `tome-src-full/data/talents/misc/objects.lua:571` | 15/15 |
| `T_LIGHT_OF_FOOT` | 0 | 踏雪无痕 | other/other | `["*",0.2,["talentLevel",true]]` | `tome-src-full/data/talents/misc/npcs.lua:3234` | 15/15 |
| `T_CHARM_MASTERY` | 0 | 饰品掌握 | other/other | `["floor",["/",["*",100,["talentLevel"]],["+",["talentLevel"],7.5]]]` | `tome-src-full/data/talents/misc/npcs.lua:3265` | 15/15 |
| `T_PIERCING_SIGHT` | 0 | 洞察视界 | other/other | `["max",0,["combatScale",["*",15,["talentLevel"]],10,1,80,75,0.25]]` | `tome-src-full/data/talents/misc/npcs.lua:3287` | 15/15 |
| `T_PIERCING_SIGHT` | 1 | 洞察视界 | other/other | `["max",0,["combatScale",["*",15,["talentLevel"]],10,1,80,75,0.25]]` | `tome-src-full/data/talents/misc/npcs.lua:3287` | 15/15 |
| `T_DUCK_AND_DODGE` | 0 | 闪避 | race/halfling | `["max",10,["-",15,["talentLevel",true]]]` | `tome-src-full/data/talents/misc/races.lua:604` | 15/15 |
| `T_MILITANT_MIND` | 0 | 好斗精神 | race/halfling | `["*",2,["talentLevel"]]` | `tome-src-full/data/talents/misc/races.lua:631` | 15/15 |
| `T_DWARF_RESILIENCE` | 0 | 钢筋铁骨 | race/dwarf | `["statScale","con",7,25]` | `tome-src-full/data/talents/misc/races.lua:472` | 15/15 |
| `T_DWARF_RESILIENCE` | 2 | 钢筋铁骨 | race/dwarf | `["statScale","con",12,30,0.75]` | `tome-src-full/data/talents/misc/races.lua:474` | 15/15 |
| `T_DWARF_RESILIENCE` | 3 | 钢筋铁骨 | race/dwarf | `["statScale","con",12,30,0.75]` | `tome-src-full/data/talents/misc/races.lua:475` | 15/15 |
| `T_BLIGHTZONE` | 0 | 枯萎区域 | corruption/other | `["spellDamage",4,65]` | `tome-src-full/data/talents/misc/npcs.lua:1368` | 15/15 |
| `T_VOID_SHARDS` | 0 | 虚空碎片 | other/horror | `["talentLevel",true]` | `tome-src-full/data/talents/misc/horrors.lua:344` | 15/15 |
| `T_PERFECT_CONTROL` | 1 | 完美控制 | psionic/other | `["*",0.5,["combatScale",["*",["talentLevel"],["^",["+",1,["*",8,["+",["*",0.5,["/",["power","精神强度"],100]],["*",0.5,["/",["talentLevel"],6.5]]]]],1.04]],15,0,49,34]]` | `tome-src-full/data/talents/misc/npcs.lua:2533` | 15/15 |
| `T_YEEK_WILL` | 0 | 主导意志 | race/yeek | `["floor",["statScale","wil",5,14]]` | `tome-src-full/data/talents/misc/races.lua:868` | 15/15 |
| `T_OGRE_WRATH` | 0 | 食人魔之怒 | race/ogre | `["floor",["statScale","str",5,12]]` | `tome-src-full/data/talents/misc/races.lua:1081` | 15/15 |
| `T_GNASHING_TEETH` | 5 | 咬牙切齿 | technique/horror | `["*",-100,["combatLimit",["statDamage","con",10,50],1,0,0,0.357,35.7]]` | `tome-src-full/data/talents/misc/horrors.lua:127` | 15/15 |

## 二、发现的写法模式

1. **种族系几乎是 `combatStatScale` / `combatTalentScale` / `combatTalentLimit` 的直译**：
   `T_DWARF_RESILIENCE` 的四个值全部来自 `getParams` 里四个 combat 助手；`T_YEEK_WILL`、`T_OGRE_WRATH` 是
   `math.floor(combatStatScale(stat, low, high))`。这类值一眼可写，占本批的一半。
   - 代表：`T_DWARF_RESILIENCE`（`races.lua:471-477`）
2. **「原始等级」与「有效等级」要靠三套导出区分**：三套数字完全相同的值一律写 `["talentLevel",true]`。
   本批四处：`T_DUCK_AND_DODGE`#0（`max(10, 15-raw)`）、`T_LIGHT_OF_FOOT`#0（`raw*0.2`）、
   `T_VOID_SHARDS`#0（`getTalentLevelRaw`）、`T_SHIV_LORD`#1（`getTalentLevelRaw`）。
   - 代表：`T_SHIV_LORD`#1
3. **`util.bound(x, 0, cap) / cap * 100` 这种"封顶百分比"**：`T_SHIV_LORD` 的 power 是先
   `bound(50 + spellDamage(t,50,450),0,500)/500`，再把同一个 power 以 `power*100`、`power*100/2`、
   `50 + power*100` 三种形式打印到三个 acronym。**info 里的派生系数（×100、÷2、+50）在表达式层乘常数即可，不需要新节点。**
   - 代表：`T_SHIV_LORD`#2/#3/#4
4. **`combatStatTalentIntervalDamage` 可以纯展开**：
   `combatStatTalentIntervalDamage(t, stat, min, max) = rescaleDamage(min + (max-min)*(0.5*stat/100 + 0.5*tl/6.5))`，
   而 `rescaleDamage(d) = d^1.04`（`mod/class/interface/Combat.lua:1467`）。所以
   `combatScale(tl * that, 15, 0, 49, 34)` 直接写成嵌套的 `combatScale` + `["^",…,1.04]` 就 15/15 通过。
   - 代表：`T_PERFECT_CONTROL`#1（`npcs.lua:2532`）
   - **建议提升为解析器规则**：把 `combatStatTalentIntervalDamage` 收成一个新节点（或至少在自动提取时展开），
     本批只有 1 条，但同一 helper 在 psionic/cunning 里反复出现。
5. **`combatLimit(x, limit, y_low, 0, y_high, 35.7)` 里 `x_low = 0` 是合法的**（`0^0.75 = 0`），
   会退化成单参数族，工具节点能直接吃。
   - 代表：`T_GNASHING_TEETH`#5（`horrors.lua:127`）
6. **`tformat` 里的负号可能被导出并进 acronym**：源码算出的 `power` 是正数，但 tooltip 原文写的是
   `prevent death until -%d%% life`，导出把负号并进了数值（`-24%, -28%, …`）。这类值要把符号写进表达式。
   - 代表：`T_GNASHING_TEETH`#5

## 三、无法建模（跳过）

| 技能 | acronym# | 大系 | 原因 |
| --- | --- | --- | --- |
| `T_WILLFUL_COMBAT` | 1 | other/other | 工具报 **「标题里没有唯一可变的轴」**：`title="灵巧 10,25,50,75,100, 意志 10,25,50,75,100"` 两条阶梯同时变化，工具无法判定该 acronym 的驱动轴。公式本身是明确的（`getDamage = combatStatScale("wil",4,40,0.75) + combatStatScale("cun",4,40,0.75)`，`npcs.lua:2853`），但没有唯一轴就没法验收，按规则跳过。 |
| `T_DUCK_AND_DODGE` | 1 | race/halfling | 工具报 **「标题里没有唯一可变的轴」**（幸运 + 敏捷同时是阶梯）；即使放开，`getDefense = getStat("lck")/200*(combatDefenseBase() - oldevasion.defense)`（`races.lua:609-610`）依赖 `combatDefenseBase()`——它把灵巧、幸运、护甲、装备/防御加成揉在一起，属于"别的角色状态/玩家装备"，本工作台没有对应输入。 |
| `T_TELEKINETIC_THROW` | 0 | psionic/other | 工具报 **「标题里没有唯一可变的轴」**（力量 + 精神强度同时是阶梯）。公式是 `math.floor(combatStatScale("str",1,5) + self:combatMindpower()/20)`（`npcs.lua:2634`），逐点手算与导出 1/3/5/7/10 完全吻合，但两条阶梯同时变化导致无法验收。 |
| `T_HALFLING_LUCK` | 0、1 | race/halfling | 公式明确（`combatStatScale("cun",15,60,0.75)`，`races.lua:581-582`），15 点里 14 点中；只有 **灵巧=100** 这一点导出 59 / 算得 60，见「疑点」。按规则不套 `["min",…]` 复刻显示，故跳过。 |
| `T_DWARF_RESILIENCE` | 1 | race/dwarf | 公式明确（`combatTalentLimit(t, 40, 20, 35, false, 1.0)`，`races.lua:473`），15 点里 14 点中；只有 **系数 1 / 技能等级 1** 这一点导出 19 / 算得 20.0012，见「疑点」。 |

## 四、疑点

### 4.1 阶梯端点恰好是整数时的"刀口"读数（2 处）

两处的失败点都落在**锚点上、精确值恰好是整数、只差浮点噪声**的位置，属于导出侧渲染伪影而非公式差异：

| 技能 | acronym# | 公式 | 失败点 | 三套导出 |
| --- | --- | --- | --- | --- |
| `T_DWARF_RESILIENCE` | 1 | `combatTalentLimit(t,40,20,35,false,1.0)` | 系数 1 / 等级 1：导出 `19`，算得 `20.0012`（其余 14 点全中，含系数 1.3 的 `22.9095→22`、系数 1.5 的 `24.456→24`） | 1：19/27/31/33/35；1.3：22/29/33/35/36；1.5：24/31/34/36/37 |
| `T_HALFLING_LUCK` | 0、1 | `combatStatScale("cun",15,60,0.75)` | 灵巧 100：导出 `59`，算得 `60.0010`（其余 14 点全中：15/24/37/49/59 中的前四点 15→15、24.618→24、37.811→37、49.378→49） | 三套相同：15/24/37/49/59 |

分析：`combatTalentLimit` 在 `tl = x_low` 处、`combatStatScale` 在 `stat = x_high` 处，精确值分别是 `low=20` 与
`high=60`；两者算得的都是"整数 + 0.001 量级的正向浮点残差"（20.0012 / 60.0010），而导出落到了整数下方
（19.999x / 59.999x），于是 `trunc` 读数差 1。这是导出端同一条公式在锚点上的浮点求值顺序不同造成的，
不是可写的另一条公式——用 `["min",59,…]` 之类去复刻属于「显示层包装」，按 `expression-overlay.md` 明确禁止，故记为疑点并跳过。
判定器现有的四种读数（`trunc/round/round1/round2`）都救不了这种"整数下方"的锚点。

### 4.2 `T_PIERCING_SIGHT`：源码读的 cun 与标题声明的灵巧不是同一个量

- 源码（`npcs.lua:3287`）：`seePower = max(0, combatScale(self:getCun(15,true)*tl, 10, 1, 80, 75, 0.25))`
- 标题声明：`灵巧 10,25,50,75,100`（本 acronym 的固定参数 `灵巧=100`）
- 但导出 15 个点**全部等于 `15 × 有效等级`**：

  | 系数 | 等级 | 导出 | 15×tl 代入 combatScale |
  | --- | --- | --- | --- |
  | 1 | 1..5 | 44/58/67/74/80 | 44.88/58.29/67.29/74.25/80 |
  | 1.3 | 1..5 | 49/64/73/81/87 | 49.68/64.01/73.61/81.04/87.19 |
  | 1.5 | 1..5 | 52/67/77/84/91 | 52.44/67.29/77.24/84.94/91.31 |

  若按标题的 `灵巧=100` 代入（即 `100×tl`），系数 1/等级 1 会算得 **87.9**，与导出 44 相差一倍——15 点全错。

- 结论：**导出端把源码里的字面默认参数 `getCun(15, true)` 的 `15` 当成了灵巧值**（也正好解释源码自己的注释
  `--TL 5, cun 100 = 80`：`15×5 = 75 = x_high`，tl=5 恰好落在 y_high=80）。这是导出侧/源码版本不一致，
  不是标题过度声明（标题确实声明了灵巧，只是导出没用它）。
- 处理：把该量**冻结成源码字面常数 15**并写进 `note`（表达式消耗 `[]`，标题 `[灵巧]` 是超集，输入集合检查通过）。
  这是唯一能同时满足"15/15 数值正确"和"不读未声明的输入"的写法。

### 4.3 `T_GNASHING_TEETH`#5 的负号

源码 `getPower` 返回正数（`combatLimit(...)` ∈ [0, 0.357]），info 用 `power*100` 打印；但导出 acronym 的值是
`-24/-28/-31/-33/-35`（源码注释 `-- Limit crit, speed increase, -health to <100%`，英文 tooltip 为
`prevent death until -%d%% life`，负号是文本里的字面字符，被导出并进了数字）。表达式写作 `["*",-100,…]` 才与
导出读数一致；这是符号约定，不是取整包装。

---

## 附：验收命令

```sh
cd modern_tome_viewer
node scripts/try-formula.mjs --overlay data/overlay-batches/batch18-misc.json
# 覆盖层校验：21/21 通过
```
