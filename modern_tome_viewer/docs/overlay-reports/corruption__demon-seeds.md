# 覆盖层报告 · `corruption/demon-seeds`

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/corruption__demon-seeds.json`
结果：**15/15 通过**（目标 16 条；1 条记入「疑点」）

```
覆盖层校验：15/15 通过
```

源码文件：`dlc-src/ashes-urhrok/tome-ashes-urhrok/data/talents/corruptions/demon-seeds.lua`（1339 行）

## 已完成

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_DEMON_SEED_FIRE_BOLTS | #0 | `["+",["*",5,["talentLevel"]],20]` | demon-seeds.lua:58 | ✅ |
| T_DEMON_SEED_FIRE_BOLTS | #1 | `["+",1,["ceil",["/",["talentLevel"],2]]]` | demon-seeds.lua:58 | ✅ |
| T_DEMON_SEED_BLIGHTED_PATH | #0 | `["+",4,["*",2,["floor",["talentLevel"]]]]` | demon-seeds.lua:249 | ✅ |
| T_DEMON_SEED_BLIGHTED_PATH | #3 | `["/",["spellDamage",50,500],9]` | demon-seeds.lua:246 | ✅ |
| T_DEMON_SEED_SHADOWMELD | #1 | `["*",50,["-",1,["exp",["+",["*",-0.4918259386509031,["sqrt",["talentLevel"]]],0.33762429736186633]]]]` | demon-seeds.lua:361 | ✅ |
| T_DEMON_SEED_HEXED_SHIELD | #0 | `["talentLevel",true]` | demon-seeds.lua:869 | ✅ |
| T_DEMON_SEED_CURSED_ARM | #0 | `["*",50,["-",1,["exp",["+",["*",-0.4918259386509031,["sqrt",["talentLevel"]]],0.33762429736186633]]]]` | demon-seeds.lua:878 | ✅ |
| T_DEMON_SEED_CURSED_ARM | #1 | `["talentLevel",true]` | demon-seeds.lua:889 | ✅ |
| T_DEMON_SEED_BLOOD_DRINKER | #0 | `["*",100,["weaponDamage",0.9,2]]` | demon-seeds.lua:1026 | ✅ |
| T_DEMON_SEED_METEOR_SLAM | #0 | `["*",100,["weaponDamage",1.5,2.2]]` | demon-seeds.lua:1064 | ✅ |
| T_DEMON_SEED_DISEASED_BODY | #0 | `["*",100,["-",1,["exp",["+",["*",-0.695952146309044,["sqrt",["talentLevel"]]],0.570363982952362]]]]` | demon-seeds.lua:1223 | ✅ |
| T_DEMON_SEED_DISEASED_BODY | #1 | `["talentScale",5,10]` | demon-seeds.lua:1224 | ✅ |
| T_DEMON_SEED_DISEASED_BODY | #2 | `["+",5,["spellDamage",5,30]]` | demon-seeds.lua:1225 | ✅ |
| T_DEMON_SEED_DISEASED_BODY | #3 | `["spellDamage",5,28]` | demon-seeds.lua:1226 | ✅ |
| T_DEMON_SEED_VOLCANIC_SKIN | #0 | `["*",100,["-",1,["exp",["+",["*",-0.695952146309044,["sqrt",["talentLevel"]]],0.570363982952362]]]]` | demon-seeds.lua:1254 | ✅ |

两处 `exp` 展开的常量来源（mastery=1.3，`Combat.lua:1606 combatTalentLimit`）：

| 参数 | a | b |
| --- | --- | --- |
| `(limit,low,high) = (50,10,30)` | `-0.4918259386509031` | `0.33762429736186633` |
| `(limit,low,high) = (100,20,70)` | `-0.695952146309044` | `0.570363982952362` |

## 发现的写法模式

1. **`t:_getX(self)` 就是 `t.getX(self, t)`，用有效等级**（`t` 为技能表时 `getTalentLevel`）。
   证据：`Blighted Path` #3 用 `["/",["spellDamage",50,500],9]`（`t:_getShield`）、
   `Blood Drinker` #0 / `Meteor Slam` #0 用 `["weaponDamage",…]`（`t:_getDam`）、
   `Diseased Body` #0–#3 用 `t:_getChance/_getDur/_getDamage`，全部按 `原始等级 × 系数` 命中 15/15；
   若按原始等级写，1.30/1.50 两套会立刻崩。**`_get` 前缀在本批里不改变等级口径**，只是转调 getter。

2. **`combatTalentLimit` 必须按 Lua 的 `exp` 顺序展开，不能用 `["talentLimit",…]` 节点**（本批最重要的发现，见下节「疑点」的浮点分析）。
   代表技能：`T_DEMON_SEED_CURSED_ARM` #0、`T_DEMON_SEED_DISEASED_BODY` #0。
   已有生产环境（`src/lib/lua-formula.js:115-121`）用的是等价闭式
   `limit + (low-limit) * ((high-limit)/(low-limit)) ** fraction`，在锚点 `tl == mastery (1.3)` 上
   **精确等于 `low`**，而 Lua 的 `limit*(1-exp(sqrt(tl)*a+b))` 会落在 `low` 的下方一个 ULP，
   `%d` 截断后差 1。两者数学恒等，只在 IEEE 浮点上分道扬镳——导出侧跟的是 Lua 那一侧。

3. **原始等级 vs 有效等级**：`self:getTalentLevelRaw(t)` 直接写成 `["talentLevel", true]`。
   代表技能：`T_DEMON_SEED_HEXED_SHIELD` #0、`T_DEMON_SEED_CURSED_ARM` #1（三套导出一字不差，都是 `1/2/3/4/5`）。

4. **`damDesc(self, DamageType.X, v)` 在本批里是恒等包裹**：`Blighted Path` #3 的说明文本对
   `combatTalentSpellDamage(t, 50, 500) / 9` 做了 `damDesc(self, DamageType.BLIGHT, …)`，
   表达式直接写 `/9` 即可 15/15；同技能 #2（自动提取已命中）同样证明 BLIGHT 不加倍率。

5. **`%d%%` 显示的近战倍率 = `100 * combatTalentWeaponDamage(...)`**：
   代表技能：`T_DEMON_SEED_BLOOD_DRINKER` #0（`["*",100,["weaponDamage",0.9,2]]`）、
   `T_DEMON_SEED_METEOR_SLAM` #0（`["*",100,["weaponDamage",1.5,2.2]]`）。
   注意 `weaponDamage` 节点吃的是**有效等级**（`tl = 原始 × 系数`），不要乘 `100` 之外的额外系数。

6. **导出 acronym 顺序 ≠ `tformat` 参数顺序**：`Blighted Path` 的 info 文本把
   `range %d` 排在 `shield %d` 之前，所以导出里 #3 是护盾、#4 才是范围；而源码 `tformat`
   的顺序是 `maxCharges, vim, damage, range, shield`。定位 acronym 时要按**导出渲染文本**数，不要按源码数。

## 无法建模

本批 16 条**没有**真正无法建模的条目——每一条 getter 都能在源码里读到闭式或半闭式表达式。

补充说明（供主项目参考，不属于本批目标）：`demon-seeds.lua` 里未列入本批的部分技能确实依赖运行时信息，
例如 `Fiery Portal` 的传送/`Doom Storm` 的弹幕、以及 `T_DEMON_SEED_DISEASED_BODY` 的
`rng.table{弱化/腐烂/衰朽}`（疾病类型三选一随机）——**若将来把 `getChance/getDur/getDamage/getDiseasePower`
之外的随机部分做成滑条**，那才是不可建模的。本批要的四个数值都不含随机量。

## 疑点

### 1. 导出侧把 `≥ 10` 的数字渲染成整数，导致 `T_DEMON_SEED_BLIGHTED_PATH` #1 无法通过精度闸门

该 acronym 是 `getVim = combatTalentScale(t, 3, 10, 0.5)`。公式本身没有疑问，15 个点的**数值**全部吻合，
但导出文本里 `≥ 10` 的值被写成了整数：

| 系数 | 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- |
| 导出 1.00 | 3 | 5.35 | 7.15 | 8.66 | 10 |
| `["talentScale",3,10,0.5]` 1.00 | 3 | 5.3457 | 7.1457 | 8.6631 | 10 |
| 导出 1.30 | 3.79 | 6.47 | 8.52 | **10** | **12** |
| 算得 1.30 | 3.7938 | 6.4684 | 8.5206 | **10.2508** | **11.7751** |
| 导出 1.50 | 4.27 | 7.15 | 9.35 | **11** | **13** |
| 算得 1.50 | 4.2728 | 7.1457 | 9.3502 | **11.2086** | **12.846** |

四个偏差点全部满足「导出的整数 = 算得值的四舍五入」：
`10.2508→10`、`11.7751→12`、`11.2086→11`、`12.846→13`。

**证据（导出侧全局格式规则）**：扫描 `starsapphirex.github.io/tometips/data/master/talents.*-1.3.json`
全部 acronym 文本，`≥ 10` 的显示值共 **6557** 个，其中**带小数的为 0**；
而 `< 10` 的值里有 217 个 1 位小数、252 个 2 位小数。可见导出管线对 `≥ 10` 一律取整（四舍五入）。

**为什么会 FAIL**：`src/lib/scaling-core.js:270` 把 acronym 的 precision 取为
`Math.max(所有显示值的小数位数)`。同一个 acronym 里既有 `3.79`（2 位）又有 `10`（0 位），
precision 被推成 2，于是 `matchesDisplayed`（`scripts/lua-scaling.mjs:13-16`）按 `|差| ≤ 0.005` 精确比对，
要求 `10.2508` 等于 `10.00` → ❌。

**结论**：这是**导出侧元数据缺陷**（显示取整把精度信息抹掉了），不是公式写不出来。
表达式本身 15 点数值全中，但工具在第一行就判 ❌，按任务规则（必须 PASS 才写盘）**未写入批次**。
建议主项目考虑：当 acronym 的显示值跨越 10 时，precision 取**非整数值**的小数位数
（即忽略 magnitudes ≥ 10 的整数显示），或对 `≥10` 的显示值改用整数读取（`Math.round`/`Math.trunc` 二选一）。

### 2. `["talentLimit",…]` 节点在锚点等级上与 Lua 相差 1（已用 `exp` 展开规避）

不是导出问题，是**工具节点与游戏实现的浮点差异**，已通过手工展开解决，记录以备复核：

`combatTalentLimit(t, 50, 10, 30)`：

| 等级 | 导出（`%d` 截断） | `["talentLimit",50,10,30]` | Lua `exp` 形式 |
| --- | --- | --- | --- |
| 1.3 | **9** | 10（闭式精确等于 low） | 9.999999999999998 → 9 ✅ |
| 6.5 | **29** | 30（闭式精确等于 high） | 29.999999999999996 → 29 ✅ |

`combatTalentLimit(t, 100, 20, 70)`：

| 等级 | 导出（`%d` 截断） | `["talentLimit",100,20,70]` | Lua `exp` 形式 |
| --- | --- | --- | --- |
| 1.3 | **19** | 20 | 19.999999999999996 → 19 ✅ |
| 6.5 | 70 | 70 | 70.0 → 70 ✅ |

（`T_DEMON_SEED_SHADOWMELD` #1 与 `T_DEMON_SEED_CURSED_ARM` #0 共用 50/10/30；
`T_DEMON_SEED_DISEASED_BODY` #0 与 `T_DEMON_SEED_VOLCANIC_SKIN` #0 共用 100/20/70。）

其余 13 个点在两种写法下都落在同一个整数区间内，只有这两个锚点会分叉。
建议主项目把 `lua-formula.js` 的 `talentLimit` 改成 Lua 的 `exp` 形式（或直接接受 `["exp",…]` 展开），
这样以后同类值不必手工展开。
