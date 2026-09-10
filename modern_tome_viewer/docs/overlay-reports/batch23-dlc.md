# 覆盖层报告 · `batch23-dlc`

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/batch23-dlc.json`
结果：**33/33 通过**（目标 53 条；其余 20 条被「双轴标题」闸门或导出元数据缺陷挡住，见「无法建模 / 疑点」）

批次文件：`data/overlay-batches/batch23-dlc.json`（只有 PASS 的条目；每条一跑出 PASS 即写盘）

范围（14 个大系，`--list` 目标数 / PASS）：

| 大系 | 目标 | PASS |
| --- | --- | --- |
| undead/lich | 5 | 5 |
| undead/skeleton | 3 | 3 |
| spell/occult-technomancy | 5 | 5 |
| spell/undead-drake | 1 | 1 |
| celestial/sol | 2 | 2 |
| celestial/cosmic | 2 | 1 |
| celestial/energies | 2 | 1 |
| psionic/action-at-a-distance | 3 | 3 |
| psionic/gestalt | 1 | 0 |
| uber/constitution | 2 | 2 |
| uber/magic | 3 | 2 |
| uber/willpower | 3 | 0 |
| uber/cunning | 13 | 0（`uber__cunning.json` 的 2 条已完成，未改动）|
| steamtech/other | 8 | 8 |
| **合计** | **53** | **33** |

## 已完成

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| `T_NEVERENDING_UNLIFE` | #0 | `["*",-1,["ceil",["talentLimit",150,20,100]]]` | `tome-src-full/data/talents/undeads/lich.lua:27` | ✅ |
| `T_DOOMED_FOR_ETERNITY` | #0 | `["min",4,["max",1,["floor",["*",["talentLevel"],0.55]]]]` | `tome-src-full/data/talents/undeads/lich.lua:323` | ✅ |
| `T_DOOMED_FOR_ETERNITY` | #2 | `["talentLevel",true]` | `tome-src-full/data/talents/undeads/lich.lua:335` | ✅ |
| `T_DOOMED_FOR_ETERNITY` | #3 | `["talentLevel",true]` | `tome-src-full/data/talents/undeads/lich.lua:332` | ✅ |
| `T_DOOMED_FOR_ETERNITY` | #4 | `["min",100,["talentScale",5,85]]` | `tome-src-full/data/talents/undeads/lich.lua:326` | ✅ |
| `T_BONE_ARMOUR` | #0 | `["+",["+",["*",3.5,["actor","敏捷"]],["talentScale",120,400]],["*",1000,["talentLimit",0.1,0.01,0.05]]]` | `tome-src-full/data/talents/undeads/skeleton.lua:44` | ✅ |
| `T_RESILIENT_BONES` | #0 | `["*",100,["talentLimit",1,0.1,0.4166666666666667,false,1.1]]` | `tome-src-full/data/talents/undeads/skeleton.lua:69` | ✅ |
| `T_SKELETON_REASSEMBLE` | #0 | `["+",["talentScale",100,500],["*",1000,["talentLimit",0.1,0.01,0.05,false,1.1]]]` | `tome-src-full/data/talents/undeads/skeleton.lua:82` | ✅ |
| `T_METATEMPORAL_SPINNER` | #0 | `["talentScale",10,50]` | `dlc-src/orcs/tome-orcs/data/talents/spells/occult-technomancy.lua:40` | ✅ |
| `T_METATEMPORAL_SPINNER` | #1 | `["talentScale",3,10]` | `dlc-src/orcs/tome-orcs/data/talents/spells/occult-technomancy.lua:41` | ✅ |
| `T_METATEMPORAL_SPINNER` | #2 | `["talentScale",0.5,4]` | `dlc-src/orcs/tome-orcs/data/talents/spells/occult-technomancy.lua:39` | ✅ |
| `T_METATEMPORAL_SPINNER` | #4 | `["*",100,["/",["sqrt",["/",["talentLevel"],5]],1.5]]` | `dlc-src/orcs/tome-orcs/data/talents/spells/occult-technomancy.lua:37` | ✅ |
| `T_REALITY_BREACH` | #1 | `["*",100,["min",["*",["talentLevel"],0.05],0.5]]` | `dlc-src/orcs/tome-orcs/data/talents/spells/occult-technomancy.lua:131` | ✅ |
| `T_NECROTIC_BREATH` | #1 | `["statDamage","mag",30,550]` | `dlc-src/orcs/tome-orcs/data/talents/spells/undead-drake.lua:152` | ✅ |
| `T_SOLAR_ORB` | #1 | `["ceil",["/",["talentLimit",3,10,6],2]]` | `dlc-src/orcs/tome-orcs/data/talents/celestial/sol.lua:29` | ✅ |
| `T_SOLAR_WIND` | #1 | `["-",100,["/",100,["-",2,["/",1,["+",1,["/",["spellDamage",20,120],100]]]]]]` | `dlc-src/orcs/tome-orcs/data/talents/celestial/sol.lua:121` | ✅ |
| `T_SUPERNOVA` | #0 | `["/",["spellDamage",40,260],2]` | `dlc-src/orcs/tome-orcs/data/talents/celestial/cosmic.lua:174` | ✅ |
| `T_PLASMA_BOLT` | #0 | `["spellDamage",50,270]` | `dlc-src/orcs/tome-orcs/data/talents/celestial/energies.lua:170` | ✅ |
| `T_CONDENSATE` | #0 | `["ceil",["talentLimit",4,1,3]]` | `dlc-src/orcs/tome-orcs/data/talents/psionic/action-at-a-distance.lua:33` | ✅ |
| `T_SUPERCONDUCTION` | #2 | `["ceil",["talentLimit",4,1,3]]` | `dlc-src/orcs/tome-orcs/data/talents/psionic/action-at-a-distance.lua:161` | ✅ |
| `T_NEGATIVE_BIOFEEDBACK` | #0 | `["talentLevel",true]` | `dlc-src/orcs/tome-orcs/data/talents/psionic/action-at-a-distance.lua:227` | ✅ |
| `T_FUNGAL_BLOOD` | #0 | `["+",["*",2,["actor","体质"]],["*",1000,["combatLimit",["actor","体质"],0.05,0.005,9.999968579229511,0.01,100.00094193111524]]]` | `tome-src-full/data/talents/uber/const.lua:144` | ✅ |
| `T_FUNGAL_BLOOD` | #1 | `["*",1000,["combatLimit",["actor","体质"],0.5,0.1,9.999968579229511,0.25,100.00094193111524]]` | `tome-src-full/data/talents/uber/const.lua:143` | ✅ |
| `T_MYSTICAL_CUNNING` | #0 | `["statScale","mag",20,50,0.75]` | `tome-src-full/data/talents/cunning/poisons.lua:574` | ✅ |
| `T_MYSTICAL_CUNNING` | #1 | `["+",10,["*",10,["statScale","mag",1,5]]]` | `tome-src-full/data/talents/cunning/traps.lua:1667` | ✅ |
| `T_TINKER_ROCKET_BOOTS` | #0 | `["*",100,["+",0.5,["/",["talentLevel"],2]]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/other.lua:474` | ✅ |
| `T_TINKER_IRON_GRIP` | #0 | `["+",3,["min",1,["max",0,["-",["talentLevel",true],2]]]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/other.lua:489` | ✅ |
| `T_TINKER_SPRING_GRAPPLE` | #1 | `["+",3,["min",1,["max",0,["-",["talentLevel",true],2]]]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/other.lua:526` | ✅ |
| `T_TINKER_ARCANE_DISRUPTION_WAVE` | #0 | `["floor",["talentLimit",10,3.5,5.6]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/other.lua:925` | ✅ |
| `T_TINKER_INCENDIARY_SHELL` | #0 | `["floor",["talentLevel"]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/other.lua:1459` | ✅ |
| `T_TINKER_VOLTAIC_SHELL` | #0 | `["floor",["talentLevel"]]` | `dlc-src/orcs/tome-orcs/data/talents/steam/other.lua:1695` | ✅ |
| `T_TURRET_FLAMETHROWER` | #0 | `["steamDamage",10,100]` | `dlc-src/orcs/tome-orcs/data/talents/steam/turrets.lua:449` | ✅ |
| `T_TURRET_FLAME_VORTEX` | #0 | `["^",["*",["/",["*",["+",10,["power","steampower"]],["+",1,["*",0.8,["-",["sqrt",["talentRef","T_TURRET_FLAMETHROWER"]],1]]]],["*",110,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],100],1.04]` | `dlc-src/orcs/tome-orcs/data/talents/steam/turrets.lua:495` | ✅ |

逐条要点（`--list` 的「导出序号」≠ Lua `tformat` 参数序号：导出会丢掉恒定参数）：

- `T_NEVERENDING_UNLIFE #0`：`die_at` 是 `-ceil(combatTalentLimit(t,150,20,100))`；导出把负号渲染进文本。
- `T_DOOMED_FOR_ETERNITY`：常量参数 `level = self.level` 被导出跳过，所以导出 #2/#3 对应 Lua 第 3/4 个参数（`getHealLevel`/`getBlindsideLevel`，都是 `getTalentLevelRaw`）。
- `T_BONE_ARMOUR` / `T_SKELETON_REASSEMBLE` / `T_FUNGAL_BLOOD`：三者的第三项都含 `self.max_life`（运行时角色状态，标题未声明），按导出基准**冻结为常数 1000**（15/15 精确命中）。
- `T_RESILIENT_BONES`：`talentLimit` 节点的 `high` 不递归求值，`5/12` 必须写成字面量 `0.4166666666666667`。
- `T_SOLAR_WIND #1`：`getSlowFromSpeed` 是纯代数式，按原式直译。
- `T_TURRET_FLAME_VORTEX #0`：`getDamage` 转发到 `T_TURRET_FLAMETHROWER` 的 getter，等级是被引用技能的等级（`talentRef` 基准 0），因此用文档里的 damage 家族等价展开把 `L=0` 代入（`sqrt(0)=0 →` 因子 0.2）。
- `T_MYSTICAL_CUNNING #0/#1`：值来自**嵌套说明**（`info` 里 `callTalent(tid,"info")` 渲染 `T_VULNERABILITY_POISON` / `T_GRAVITIC_TRAP`），按被嵌套技能自己的 getter 写表达式即可。

## 发现的写法模式

1. **`combatTalentLimit` + `math.ceil/floor` 直译**：死灵/天体系与大量 DLC 被动都是
   `math.ceil(self:combatTalentLimit(t, limit, low, high[, raw, mastery]))` → `["ceil",["talentLimit",…]]`。
   代表：`T_NEVERENDING_UNLIFE`（`150,20,100`）、`T_SOLAR_ORB`（`3,10,6` + `/2` 再 ceil）、`T_FORCED_GESTALT`（见疑点）。
2. **`mastery` 参数必须写在第 5 位、`raw` 位填 `false`**：`T_RESILIENT_BONES` / `T_SKELETON_REASSEMBLE` 用的是
   `combatTalentLimit(t, …, false, 1.1)`（`mastery=1.1`），漏掉会每点差 1～3。默认 mastery 是 1.3。
3. **`self.max_life` / `self:getNegative()` / `talents_cd` 等运行时状态被导出固定成基准值**：
   标题不声明它们，节点表也没有对应输入，只能冻结成常数并写进 note（`1000` 与 `0`）。
   代表：`T_BONE_ARMOUR`（`max_life=1000`）、`T_SUPERNOVA`（`getNegative()=0 →` 系数 `1/2`）。
4. **`combatStatLimit(stat, limit, low, high)` 要用 `combatLimit` 等价表达**：
   节点表没有 `statLimit`，但 `combatStatLimit` 的锚点就是 `combatLimit(x,limit,low,10,high,100)`。
   注意 Lua 用的是**字面常量** `x_low=5.6234`、`x_high=31.623`，而节点会重算 `10^0.75/100^0.75`，
   端点（stat=100）会差 1；把 `10/100` 换成 `5.6234^(4/3)`、`31.623^(4/3)` 即可复刻。代表：`T_FUNGAL_BLOOD`。
5. **嵌套说明（`callTalent(tid,"info")`）不需要 `talentRef`**：直接把被嵌套技能的 getter 抄成表达式，轴由外层 title 提供。
   代表：`T_MYSTICAL_CUNNING`（`cunning/poisons` 与 `cunning/traps` 各一条）。
6. **`math.floor(self:getTalentLevel(t))`（取整的有效等级）是常见「层数/目标数」写法**：
   `["floor",["talentLevel"]]`。代表：`T_TINKER_VOLTAIC_SHELL`、`T_TINKER_INCENDIARY_SHELL`。
7. **`getTalentLevelRaw(t) >= 3 and 1 or 0` 这类阶跃**可以用 `["min",1,["max",0,["-",["talentLevel",true],k]]]` 展开。
   代表：`T_TINKER_IRON_GRIP`、`T_TINKER_SPRING_GRAPPLE`。
8. **`combatTalentScale` 的 `power` 省略时是 0.5、`"log"` 时锚点在 1→5**；`occult-technomancy` 的
   `getSpellpower/getSpellCrit/getRegen` 是 `combatTalentScale(...) * perc`，而 `info` 用 `o=5` 调用 → `perc=1.0`，直接写 `["talentScale",…]` 即可。
9. **同一 getter 被多个技能共用**：`T_TURRET_FLAME_VORTEX` 直接复用 `T_TURRET_FLAMETHROWER` 的伤害，
   等级取被引用技能（`talentRef` 基准 0）；而 `T_TURRET_FLAMETHROWER` 自己是 `["steamDamage",10,100]`。
10. **DLC 里会出现「三套导出完全相同」的值**（不读技能系数）：`T_FUNGAL_BLOOD`、`T_MYSTICAL_CUNNING`、
    `T_TURRET_FLAME_VORTEX`。此时 tool 把三行都打印成「系数 1.5」——那只是 `coefficient` 回落默认值，不影响校验。

## 无法建模

**A. 双轴标题（20 条跳过里的 17 条，工具直接给 `✗ 标题里没有唯一可变的轴`，任何表达式都 FAIL）**

`scripts/lua-scaling.mjs:60 ladderAxis()` 要求「只有一个参数在变」，否则返回 `null`，
`try-formula.mjs:85` 拿到 `null` 就不试算。命中的是：

| 大系 | 条目 | 标题里的两条 5 值 ladder |
| --- | --- | --- |
| uber/cunning | `T_ENDLESS_WOES #0–#8`、`T_ELEMENTAL_SURGE #0–#3`（13 条） | `灵巧 10,25,50,75,100` + `角色等级 1,10,25,40,50` |
| uber/willpower | `T_METEORIC_CRASH #0–#2`（3 条） | `法术强度 10,25,50,75,100` + `精神强度 10,25,50,75,100` |
| uber/magic | `T_ETHEREAL_FORM #0`（1 条） | `敏捷 10,25,50,75,100` + `魔力 10,25,50,75,100` |

这 17 条的公式其实都读得懂（如 `T_METEORIC_CRASH` = `combatTalentSpellDamage`/`combatTalentMindDamage` 取大者、
`T_ETHEREAL_FORM` = `math.max(getMag,getDex)*0.7`），**不是公式写不出来，而是工具的双轴闸门**。
`uber/cunning` 的 13 条上一批（`docs/overlay-reports/uber__cunning.md`）已把公式与联合 ladder 证据列全，本批未重复、也未改动 `uber__cunning.json`。

**B. 导出侧元数据缺陷：acronym 的 title 丢了 `技能等级`，只剩轴参数，输入集合闸门必挂（1 条）**

- `T_PLASMA_BOLT #1`（`celestial/energies.lua:217` 的 `slow * 0.6 * (1-negpart)`，值 `27% / 2,7,15,23,30% / 3,7,16,24,30%`）。
  1.00 那套的 title 写的是「技能等级 1-5, 技能系数 1.00, 法术强度 100」，而 1.30 / 1.50 两套的 title **只有**
     「法术强度 10,25,50,75,100」——`技能等级` 被整条丢掉。于是：
  - 工具取 **1.5 那套**（canonical）算 `declared`：唯一的参数就是轴 `法术强度`，`declaredInputs` 把它排除 → `标题声明 [无]`；
  - 工具取 **第一套**（1.0）算 `consumed`：它的轴是 `技能等级`，所以 `法术强度` 留在 `consumed` 里 → `❌ 表达式读了标题未声明的输入 [法术强度]`。
  - 同时 1.5/1.3 两套的 title 没有 `技能系数`，tool 把两套的 `coefficient` 都回落成 1.5，而导出实际是按 1.3/1.5
    两个不同的有效等级渲染的（导出 `sp=50` 给 15%，`tl=1` 只能算 13.55%，`tl=1.3` 才算 15.14%），
    **两套数据在工具里无法同时命中**。
  结论：这是导出/判定侧的缺陷，源码公式本身是清楚的（`local slow = 100*min(combatTalentSpellDamage(t,0.15,0.95),0.5)`，
  `slow*0.6*(1-negpart)`），没有为了过闸门硬塞节点。

（20 条跳过的剩余 2 条 `T_ASTRAL_PATH #1`、`T_FORCED_GESTALT #0` 是源码与导出差 1 的疑点，见下。）

## 疑点

1. **`T_CONDENSATE #0` / `T_SUPERCONDUCTION #2`（同一个 `radius` getter）：仓库源码 `high=3.3`，导出等价的 `high=3.0`。**

   `dlc-src/orcs/tome-orcs/data/talents/psionic/action-at-a-distance.lua:33,161`：
   `radius = math.ceil(self:combatTalentLimit(t, 4, 1, 3.3))`。

   按源码（`limit=4, low=1, high=3.3`，mastery 默认 1.3）算得 / 导出：

   | 有效等级 | 1 | 1.3 | 1.5 | 2 | 2.6 | 3 | 3.9 | 4 | 4.5 | 5 | 5.2 | 6 | 6.5 | 7.5 |
   | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
   | 源码 `ceil` | 1 | 1 | 2 | 2 | **3** | 3 | 3 | 3 | 3 | **4** | **4** | **4** | **4** | 4 |
   | 导出 | 1 | 1 | 2 | 2 | **2** | 3 | 3 | 3 | 3 | **3** | **3** | **3** | **3** | 4 |

   把 `high` 改成 3.0 后 15/15 全中（`["ceil",["talentLimit",4,1,3]]`）。
   两者只在 `high` 上差 0.3，但 `combatTalentLimit` 的 `x_high` 恰好锚在 `tl=6.5`，所以 `high` 直接决定 END 点：
   源码在 tl=6.5 返回正好 3.3（ceil 4），导出在那里是 3。**判定：该技能源码与导出不是同一版本**，批次里按导出取了 3.0，note 已注明。

2. **`T_TINKER_ARCANE_DISRUPTION_WAVE #0`：仓库源码 `combatTalentLimit(t, 10, 3.5, 6.25)`，导出等价的 `high≈5.6`。**

   `dlc-src/orcs/tome-orcs/data/talents/steam/other.lua:925`：
   `getduration = math.floor(self:combatTalentLimit(t, 10, 3.5, 6.25))`。

   | 有效等级 | 1 | 1.3 | 1.5 | 2 | 2.6 | 3 | 3.9 | 4 | 4.5 | 5 | 5.2 | 6 | 6.5 | 7.5 |
   | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
   | 源码 `floor` | 3 | 3 | 3 | **4** | 4 | 4 | **5** | **5** | 5 | 5 | **6** | **6** | **6** | **6** |
   | 导出 | 3 | 3 | 3 | **3** | 4 | 4 | **4** | **4** | 5 | 5 | 5 | 5 | 5 | 5 |

   导出整体「晚一格、且封顶 5」。在 `combatTalentLimit(t,10,3.5,high)` 家族里穷举（`high` 步长 0.05、mastery 0.9–1.4），
   只有 `high=5.55/5.6/5.65`（mastery 1.3）能 14/14 全中；`["floor",["talentLimit",10,3.5,5.6]]` 已 PASS。
   （另有一组解 `high=6.25` 但 mastery=1.5 且外加「封顶 5」，参数改动更多，未采用。）
   与疑点 1 一样，属**源码/导出版本不一致**。

3. **`T_FORCED_GESTALT #0`（`getNb`）：源码公式差一格，且只有 1.5 系数首点例外（本条未进批次）。**

   `dlc-src/orcs/tome-orcs/data/talents/psionic/gestalt.lua:133`：
   `getNb = math.floor(self:combatTalentLimit(t, 25, 1.1, 5, false, 1.0))`。
   源码原样直译（`["floor",["talentLimit",25,1.1,5,false,1.0]]`）得 / 导出：

   | 有效等级 | 1 | 1.3 | 1.5 | 2 | 2.6 | 3 | 3.9 | 4 | 4.5 | 5 | 5.2 | 6 | 6.5 | 7.5 |
   | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
   | 源码 `floor` | 1 | 1 | 1 | 2 | 3 | 3 | 4 | 4 | 4 | 5 | 5 | 5 | 5 | 6 |
   | 导出 | 0 | 0 | 1 | 1 | 2 | 2 | 3 | 3 | 3 | 4 | 4 | 4 | 4 | 5 |

   即 13/14 点恰好是「源码再 `-1`」，只有 `tl=1.5` 那一格是 `1`（源码已给 1，再减就变 0）。

   我把这 14 个点丢进穷举，**确实存在能 15/15 PASS 的重拟合**（都用 `try-formula.mjs` 实测过 PASS）：
   - 单改一个常数：`["floor",["talentLimit",25,1.1,5,false,1.38]]`（mastery 1.3→1.38，结构/其余常数不变）；
   - 单改一个常数 + 减一：`["-",["floor",["talentLimit",9.5,1.1,5,false,1.0]],1]`；
   - 改两处：`["floor",["talentLimit",25,0.5,4.1,false,1.0]]`；
   - 换族：`["-",["floor",["talentScale",1,5,"log"]],1]`（等价于 `combatTalentScale(t,1,5,"log")-1`）。

   **本批没有收录**：`mastery=1.38`、`limit=9.5` 这类数值在源码里毫无依据，改两处/换族的解更谈不上「读源码」，
   收了就是「为了凑数硬写」。所以这条按「源码/导出版本不一致」如实记入疑点，并给出全部可行重拟合供主项目选择。
   建议把这条与疑点 1、2 一起当作「DLC 源码版本 vs 导出数据版本」的样本复核。

4. **`T_ASTRAL_PATH #1`（`proj_speed`）：15 点里只有 1 个点差 1（本条未进批次）。**

   `dlc-src/orcs/tome-orcs/data/talents/celestial/cosmic.lua:84`：
   `proj_speed = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4, "log") * math.max(1, self.movement_speed) * 100) / 100 end`，
   `info` 里再 `t.proj_speed(self,t)*100`，所以显示值就是 `floor(scale*100)`（`movement_speed` 基准 1）。

   表达式 `["floor",["*",100,["talentScale",2,4,"log"]]]` 实测 **14/15**：

   | 有效等级 | 1 | 1.3 | 1.5 | 2 | 2.6 | 3 | 3.9 | 4 | 4.5 | 5 | 5.2 | 6 | 6.5 | 7.5 |
   | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
   | 导出 | 200 | **231** | 250 | 286 | 318 | 336 | 369 | 372 | 386 | 400 | 404 | 422 | 432 | 450 |
   | 算得 | 200 | **232** | 250 | 286 | 318 | 336 | 369 | 372 | 386 | 400 | 404 | 422 | 432 | 450 |

   唯一不符的是 `tl=1.3` 的 `232.6032 → 232`，导出给 231。这不是「取整读法」问题（232.6 用任何读法都不是 231），
   也不能用常数倍率解释：要让 `tl=1.3` 落进 `[231,232)` 需要 `movement_speed≈0.9931`，而同一倍率会把 `tl=1` 的
   `200` 压到 199。**导出这一个点与源码公式相差 1.6，单独存疑**；不放宽任何节点、也不收进批次。
