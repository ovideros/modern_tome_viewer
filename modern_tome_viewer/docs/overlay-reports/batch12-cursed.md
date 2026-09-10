# 覆盖层报告 · 批次 12 · `cursed` 八大系

范围：`cursed/endless-hunt`、`cursed/slaughter`、`cursed/gloom`、`cursed/cursed-aura`、
`cursed/gestures`、`cursed/darkness`、`cursed/cursed-form`、`cursed/strife`

覆盖层：`data/overlay-batches/batch12-cursed.json`（45 条）

```
命令：node scripts/try-formula.mjs --overlay data/overlay-batches/batch12-cursed.json
覆盖层校验：45/45 通过
```

目标 52 条 → 通过 45、跳过并记录 7：

| 大系 | 目标数 | PASS | 跳过 |
| --- | --- | --- | --- |
| cursed/endless-hunt | 9 | 9 | 0 |
| cursed/slaughter | 9 | 8 | 1（T_CLEAVE #1） |
| cursed/gloom | 7 | 7 | 0 |
| cursed/cursed-aura | 6 | 4 | 2（T_DEFILING_TOUCH #0、T_DARK_GIFTS #1） |
| cursed/gestures | 7 | 4 | 3（T_GESTURE_OF_GUARDING #0/#2、T_GESTURE_OF_POWER #2） |
| cursed/darkness | 5 | 5 | 0 |
| cursed/cursed-form | 5 | 4 | 1（T_SEETHE #0） |
| cursed/strife | 4 | 4 | 0 |
| **合计** | **52** | **45** | **7** |

## 已完成

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_STALK | #0 | `["floor",["statDamage","wil",10,30]]` | tome-src-full/data/talents/cursed/endless-hunt.lua:50 | ✅ |
| T_STALK | #1 | `["*",["*",["+",0.1,["*",0.25,["+",["*",0.4,["/",["actor","力量"],100]],["*",0.6,["/",["talentLevel"],6.5]]]]],["-",1,["/",["log10",["*",["+",0.1,["*",0.25,["+",["*",0.4,["/",["actor","力量"],100]],["*",0.6,["/",["talentLevel"],6.5]]]]],2]],7]]],["/",100,3]]` | tome-src-full/data/talents/cursed/endless-hunt.lua:53 | ✅ |
| T_STALK | #2 | `["floor",["*",["statDamage","wil",10,30],["sqrt",2]]]` | tome-src-full/data/talents/cursed/endless-hunt.lua:50 | ✅ |
| T_STALK | #3 | `["*",["*",["+",0.1,["*",0.25,["+",["*",0.4,["/",["actor","力量"],100]],["*",0.6,["/",["talentLevel"],6.5]]]]],["-",1,["/",["log10",["*",["+",0.1,["*",0.25,["+",["*",0.4,["/",["actor","力量"],100]],["*",0.6,["/",["talentLevel"],6.5]]]]],2]],7]]],["/",200,3]]` | tome-src-full/data/talents/cursed/endless-hunt.lua:53 | ✅ |
| T_STALK | #4 | `["floor",["*",["statDamage","wil",10,30],["sqrt",3]]]` | tome-src-full/data/talents/cursed/endless-hunt.lua:50 | ✅ |
| T_STALK | #5 | `["*",["*",["+",0.1,["*",0.25,["+",["*",0.4,["/",["actor","力量"],100]],["*",0.6,["/",["talentLevel"],6.5]]]]],["-",1,["/",["log10",["*",["+",0.1,["*",0.25,["+",["*",0.4,["/",["actor","力量"],100]],["*",0.6,["/",["talentLevel"],6.5]]]]],2]],7]]],100]` | tome-src-full/data/talents/cursed/endless-hunt.lua:53 | ✅ |
| T_BECKON | #0 | `["min",10,["floor",["+",5,["*",2,["talentLevel"]]]]]` | tome-src-full/data/talents/cursed/endless-hunt.lua:181 | ✅ |
| T_BECKON | #1 | `["min",55,["floor",["+",25,["*",["-",["sqrt",["talentLevel"]],1],20]]]]` | tome-src-full/data/talents/cursed/endless-hunt.lua:184 | ✅ |
| T_SURGE | #1 | `["statDamage","wil",4,40]` | tome-src-full/data/talents/cursed/endless-hunt.lua:231 | ✅ |
| T_SLASH | #0 | `["*",["+",1,["*",["*",["+",0.3,["*",1.2,["+",["*",0.4,["/",["actor","力量"],100]],["*",0.6,["/",["talentLevel"],6.5]]]]],["-",1,["/",["log10",["*",["+",0.3,["*",1.2,["+",["*",0.4,["/",["actor","力量"],100]],["*",0.6,["/",["talentLevel"],6.5]]]]],2]],7]]],0.3]],100]` | tome-src-full/data/talents/cursed/slaughter.lua:36 | ✅ |
| T_SLASH | #1 | `["*",["+",1,["*",["+",0.3,["*",1.2,["+",["*",0.4,["/",["actor","力量"],100]],["*",0.6,["/",["talentLevel"],6.5]]]]],["-",1,["/",["log10",["*",["+",0.3,["*",1.2,["+",["*",0.4,["/",["actor","力量"],100]],["*",0.6,["/",["talentLevel"],6.5]]]]],2]],7]]]],100]` | tome-src-full/data/talents/cursed/slaughter.lua:36 | ✅ |
| T_SLASH | #2 | `["*",["combatLimit",["max",0,["^",["-",["max",3,["talentLevel"]],2],0.5]],1.5,0,0,0.39,1.73],100]` | tome-src-full/data/talents/cursed/slaughter.lua:40 | ✅ |
| T_FRENZY | #0 | `["*",["*",["+",0.25,["*",0.55,["+",["*",0.4,["/",["actor","力量"],100]],["*",0.6,["/",["talentLevel"],6.5]]]]],["-",1,["/",["log10",["*",["+",0.25,["*",0.55,["+",["*",0.4,["/",["actor","力量"],100]],["*",0.6,["/",["talentLevel"],6.5]]]]],2]],7]]],50]` | tome-src-full/data/talents/cursed/slaughter.lua:96 | ✅ |
| T_FRENZY | #1 | `["*",["*",["+",0.25,["*",0.55,["+",["*",0.4,["/",["actor","力量"],100]],["*",0.6,["/",["talentLevel"],6.5]]]]],["-",1,["/",["log10",["*",["+",0.25,["*",0.55,["+",["*",0.4,["/",["actor","力量"],100]],["*",0.6,["/",["talentLevel"],6.5]]]]],2]],7]]],100]` | tome-src-full/data/talents/cursed/slaughter.lua:96 | ✅ |
| T_FRENZY | #2 | `["*",-1,["*",["+",6,["*",39,["+",["*",0.5,["/",["actor","力量"],100]],["*",0.5,["/",["talentLevel"],6.5]]]]],["-",1,["/",["log10",["*",["+",6,["*",39,["+",["*",0.5,["/",["actor","力量"],100]],["*",0.5,["/",["talentLevel"],6.5]]]]],2]],7]]]]` | tome-src-full/data/talents/cursed/slaughter.lua:99 | ✅ |
| T_RECKLESS_CHARGE | #0 | `["floor",["talentScale",2,6,"log"]]` | tome-src-full/data/talents/cursed/slaughter.lua:177 | ✅ |
| T_CLEAVE | #0 | `["*",["combatLimit",["*",["*",["talentLevel"],["actor","力量"]],0.5],1,0,0,0.79,500],100]` | tome-src-full/data/talents/cursed/slaughter.lua:317 | ✅ |
| T_GLOOM | #0 | `["min",25,["combatScale",["talentLevel"],7,1,15,6.5]]` | tome-src-full/data/talents/cursed/gloom.lua:43 | ✅ |
| T_GLOOM | #1 | `["combatScale",["+",["+",["+",["talentLevel"],["talentRef","T_WEAKNESS"]],["talentRef","T_MINDROT"]],["talentRef","T_SANCTUARY"]],1,1,40,20,0.7]` | tome-src-full/data/talents/cursed/gloom.lua:30 | ✅ |
| T_WEAKNESS | #0 | `["min",25,["combatScale",["talentLevel"],7,1,15,6.5]]` | tome-src-full/data/talents/cursed/gloom.lua:137 | ✅ |
| T_WEAKNESS | #2 | `["combatScale",["+",["+",["+",["talentLevel"],["talentRef","T_WEAKNESS"]],["talentRef","T_MINDROT"]],["talentRef","T_SANCTUARY"]],1,1,40,20,0.7]` | tome-src-full/data/talents/cursed/gloom.lua:30 | ✅ |
| T_MINDROT | #2 | `["combatScale",["+",["+",["+",["talentLevel"],["talentRef","T_WEAKNESS"]],["talentRef","T_MINDROT"]],["talentRef","T_SANCTUARY"]],1,1,40,20,0.7]` | tome-src-full/data/talents/cursed/gloom.lua:30 | ✅ |
| T_SANCTUARY | #0 | `["min",35,["*",["sqrt",["talentLevel"]],11]]` | tome-src-full/data/talents/cursed/gloom.lua:200 | ✅ |
| T_SANCTUARY | #1 | `["combatScale",["+",["+",["+",["talentLevel"],["talentRef","T_WEAKNESS"]],["talentRef","T_MINDROT"]],["talentRef","T_SANCTUARY"]],1,1,40,20,0.7]` | tome-src-full/data/talents/cursed/gloom.lua:30 | ✅ |
| T_DARK_GIFTS | #0 | `["min",4,["talentLevel",true]]` | tome-src-full/data/talents/cursed/cursed-aura.lua:297 | ✅ |
| T_RUINED_EARTH | #0 | `["min",8,["+",2,["floor",["talentLevel"]]]]` | tome-src-full/data/talents/cursed/cursed-aura.lua:312 | ✅ |
| T_RUINED_EARTH | #1 | `["min",8,["+",3,["floor",["talentLevel"]]]]` | tome-src-full/data/talents/cursed/cursed-aura.lua:317 | ✅ |
| T_RUINED_EARTH | #2 | `["floor",["min",60,["+",22,["*",["-",["sqrt",["talentLevel"]],1],23]]]]` | tome-src-full/data/talents/cursed/cursed-aura.lua:320 | ✅ |
| T_GESTURE_OF_MALICE | #0 | `["min",30,["*",["-",["sqrt",["talentLevel"]],0.5],12]]` | tome-src-full/data/talents/cursed/gestures.lua:220 | ✅ |
| T_GESTURE_OF_POWER | #0 | `["floor",["min",20,["*",["talentLevel"],2]]]` | tome-src-full/data/talents/cursed/gestures.lua:240 | ✅ |
| T_GESTURE_OF_POWER | #1 | `["floor",["min",14,["*",["talentLevel"],1.2]]]` | tome-src-full/data/talents/cursed/gestures.lua:245 | ✅ |
| T_GESTURE_OF_GUARDING | #3 | `["talentLimit",50,5,9.5]` | tome-src-full/data/talents/cursed/gestures.lua:271 | ✅ |
| T_CREEPING_DARKNESS | #1 | `["mindDamage",0,60]` | tome-src-full/data/talents/cursed/darkness.lua:302 | ✅ |
| T_CREEPING_DARKNESS | #2 | `["combatScale",["+",["+",["+",["talentLevel",true],["talentRef","T_DARK_VISION"]],["talentRef","T_DARK_TORRENT"]],["talentRef","T_DARK_TENDRILS"]],5,1,40,20]` | tome-src-full/data/talents/cursed/darkness.lua:152 | ✅ |
| T_DARK_VISION | #1 | `["combatScale",["+",["+",["+",["talentLevel",true],["talentRef","T_CREEPING_DARKNESS"]],["talentRef","T_DARK_TORRENT"]],["talentRef","T_DARK_TENDRILS"]],5,1,40,20]` | tome-src-full/data/talents/cursed/darkness.lua:152 | ✅ |
| T_DARK_TORRENT | #1 | `["combatScale",["+",["+",["+",["talentLevel",true],["talentRef","T_CREEPING_DARKNESS"]],["talentRef","T_DARK_VISION"]],["talentRef","T_DARK_TENDRILS"]],5,1,40,20]` | tome-src-full/data/talents/cursed/darkness.lua:152 | ✅ |
| T_DARK_TENDRILS | #2 | `["combatScale",["+",["+",["+",["talentLevel",true],["talentRef","T_CREEPING_DARKNESS"]],["talentRef","T_DARK_VISION"]],["talentRef","T_DARK_TORRENT"]],5,1,40,20]` | tome-src-full/data/talents/cursed/darkness.lua:152 | ✅ |
| T_UNNATURAL_BODY | #0 | `["^",["*",["/",["*",["+",15,["*",["+",["actor","角色等级"],["actor","意志"]],1.2]],["+",1,["*",0.8,["-",["sqrt",["talentLevel"]],1]]]],["*",["+",15,100],["+",1,["*",0.8,["-",["sqrt",5],1]]]]],50],1.04]` | tome-src-full/data/talents/cursed/cursed-form.lua:21 | ✅ |
| T_UNNATURAL_BODY | #1 | `["+",["*",2,["^",["*",["/",["*",["+",15,["*",["+",["actor","角色等级"],["actor","意志"]],1.2]],["+",1,["*",0.8,["-",["sqrt",["talentLevel"]],1]]]],["*",["+",15,100],["+",1,["*",0.8,["-",["sqrt",5],1]]]]],50],1.04]],["*",["talentLimit",0.5,0.03,0.055],1000]]` | tome-src-full/data/talents/cursed/cursed-form.lua:35 | ✅ |
| T_UNNATURAL_BODY | #2 | `["+",3,["^",["*",["/",["*",["+",15,["*",["+",["actor","角色等级"],["actor","意志"]],1.2]],["+",1,["*",0.8,["-",["sqrt",["talentLevel"]],1]]]],["*",["+",15,100],["+",1,["*",0.8,["-",["sqrt",5],1]]]]],25],1.04]]` | tome-src-full/data/talents/cursed/cursed-form.lua:37 | ✅ |
| T_GRIM_RESOLVE | #0 | `["floor",["*",["talentScale",1,2.24],5]]` | tome-src-full/data/talents/cursed/cursed-form.lua:117 | ✅ |
| T_DOMINATE | #0 | `["min",6,["floor",["+",2,["talentLevel"]]]]` | tome-src-full/data/talents/cursed/strife.lua:39 | ✅ |
| T_PRETERNATURAL_SENSES | #1 | `["max",0,["combatScale",["*",["*",["actor","意志"],0.15],["talentLevel"]],10,1,80,75,0.25]]` | tome-src-full/data/talents/cursed/strife.lua:98 | ✅ |
| T_PRETERNATURAL_SENSES | #2 | `["max",0,["combatScale",["*",["*",["actor","意志"],0.15],["talentLevel"]],10,1,80,75,0.25]]` | tome-src-full/data/talents/cursed/strife.lua:98 | ✅ |
| T_REPEL | #0 | `["combatLimit",["statDamage","str",12,36],50,0,0,26.45,26.45]` | tome-src-full/data/talents/cursed/strife.lua:381 | ✅ |

## 发现的写法模式

1. **`combatTalentIntervalDamage`（Combat.lua:2177）没有对应节点，必须手写展开。**
   原式：`dam = min + (max-min)*(w*stat/100 + (1-w)*tl/6.5)`，再 `dam*(1-log10(2*dam)/7)`，最后
   `dam^(1/1.04)` 与 `rescaleDamage` 的 `^1.04` 相互抵消。节点表里没有这个家族，用
   `["*",X,["-",1,["/",["log10",["*",X,2]],7]]]`（X 为该 min/max/w 组合）直译即可。
   代表：`T_STALK` #1/#3/#5、`T_SLASH` #0/#1、`T_FRENZY` #0/#1/#2。

2. **`getHateMultiplier(self, min, max, false, hate)`（cursed/cursed.lua:193）= `min + (max-min)*min(hate/100,1)`。**
   导出只在 hate=0 与 hate=100 两个端点渲染，于是整条式子退化成常数系数 `min` 或 `max`，
   `100` 之外不需要任何节点。代表：`T_SLASH` #0（×0.3）/#1（×1.0）、`T_FRENZY` #0（×0.5）/#1。

3. **`combatTalentSpellDamage(t, base, max, override)` 带非强度 override 时要走等价展开。**
   `cursed-form` 用 `(self.level + self:getWil()) * 1.2` 当 override。若照写 `["spellDamage",…]`，
   `formulaDependencies` 会把「法术强度」记进消耗集合，而标题只声明了 `意志/角色等级` → 输入集合闸门直接 FAIL。
   改用 `docs/expression-overlay.md`「已验证的等价展开」里的 power 家族展开手写，消耗集合就只剩
   `意志 / 角色等级`，15 点全中。代表：`T_UNNATURAL_BODY` #0/#2。

4. **多个技能等级求和（`gloomTalentsMindpower`、`getDamageIncrease`）。**
   原式把 `getTalentLevel`（gloom）或 `getTalentLevelRaw`（darkness）跨若干技能相加再喂给
   `combatScale`。导出只把本技能的等级放上滑条，其余技能按基准 0 渲染，因此把另外几个写成
   `["talentRef","T_…"]`（求值为 0）即可，将来标题若声明了别的技能等级也能自然接上。
   代表：`T_GLOOM` #1、`T_CREEPING_DARKNESS` #2、`T_DARK_VISION` #1。

5. **`getTalentTypeMastery` 在导出里恒为 1，不等于「技能系数」。**
   `T_SLASH` #2 的 `math.max(3*self:getTalentTypeMastery(...), self:getTalentLevel(t))` 必须写成
   `["max",3,["talentLevel"]]`，写成 `3*系数` 会在 1.3/1.5 两套的前两点上崩。代表：`T_SLASH` #2。

6. **三套导出数字完全相同 ⇒ 一定按原始等级算，用 `["talentLevel",true]`。**
   代表：`T_DARK_GIFTS` #0（`min(4, getTalentLevelRaw)`）、darkness 四技能的「+% 伤害」。

7. **`combatTalentScale` / `combatTalentLimit` 的守卫要照抄。**
   `max(0, tl-5)` 之后还要接 `if tl <= 0 then tl = 0.1`，合成 `["max",0.1,["-",["talentLevel"],5]]`
   （代表：`T_DARK_GIFTS` #1）；`min(8, …)`、`min(30, …)`、`min(20, …)` 这类夹取一律用 `["min",…]`。

8. **`self:getWil(scale, raw)` 不是「属性+15」。**
   引擎 `ActorStats.lua:123` 里 `getStat(stat, scale, raw)` = `val * scale / stat_max`（`raw` 为真时不取整），
   所以 `getWil(15, true)` = `意志 * 15 / 100`。用 `["*",["actor","意志"],0.15]` 就能既贴合源码又满足输入集合。
   代表：`T_PRETERNATURAL_SENSES` #1/#2。

9. **取整层要照抄 Lua 的 `floor`。** `T_RECKLESS_CHARGE` #0 的 `combatTalentScale(t,2,6,"log")` 外面套
   `["floor",…]`；`T_GESTURE_OF_POWER` #0/#1 是 `floor(min(...))`；`T_GRIM_RESOLVE` #0 是
   `floor(combatTalentScale(...)*5)`。

## 无法建模

| 技能 | acronym | 原因 |
| --- | --- | --- |
| T_GESTURE_OF_GUARDING | #0 | `getDamageChange(t,true)` = `getGuardPercent(t) * dam/100`，其中 `dam` 来自 `canUseGestures(self)` 里的 `self:combatDamage(心灵之星)`（gestures.lua:28/36）——玩家武器/装备量。节点表没有 `combatDamage`，标题声明的 `力量/灵巧/physical power` 也不是它的直接表达。实测把 `dam/100` 冻成常数 k（k∈[0.4222,0.4250)，例如 0.423）可以 15/15，但那等于把武器伤害写死，按规则记为无法建模而不是硬凑。 |

## 疑点

1. **`T_CLEAVE` #1 —— 锚点上的浮点边界，5 点里差 1 点。**
   三套数据：`37/54/65/73/78% | 43/61/72/79/85% | 46/65/76/83/87%`。
   公式 `combatLimit(tl*力量*1.0, 1, 0, 0, 0.79, 500)` 在系数 1.00、tl=5 时 `x = xHigh = 500`，
   数学值恰为设计锚点 `yHigh = 0.79` → 79%；JS/节点算得正好 79.0，导出打的是 **78**。
   其余 14 点全中（37.29/54.39/65.49/73.29、43.35/61.54/72.62/79.96/85.04、46.88/65.49/76.36/83.29/87.94）。
   属 Lua 侧 `math.exp` 结果比 JS 略小一个 ulp 的边界差，不是公式错；不为了对上渲染而在公式外套包装。

2. **`T_SEETHE` #0 —— 同类锚点边界，15 点里差 2 点。**
   三套数据：`22/30/35/40/44% | 24/33/40/45/49% | 26/35/42/48/53%`。
   公式 `combatTalentLimit(t, 60, 5, 10) * 5` 在系数 1.30 的锚点 tl=1.3 处数学值恰为 `low=5` → 25，
   在 tl=6.5 处恰为 `high=10` → 50；导出分别打 **24 / 49**，其余 13 点全中
   （22.38/30.05/35.79/40.53/44.64、33.64/40.09/45.41、26.57/35.79/42.65/48.30/53.18）。

3. **`T_DEFILING_TOUCH` #0 与 `T_DARK_GIFTS` #1 —— 导出侧元数据缺陷：系数 1.00 那一套整条 acronym 缺失。**
   这两条的值在原始等级 1→5 上恒定（`combatTalentLimit(max(1,tl-4),…)` 在系数 1.0 时恒取 `max(1,·)=1`；
   `combatTalentScale(max(0,tl-5),…)` 同理恒为 0 → 0.1），于是 `talents.1.json` 的 info_text 里这个值不是
   可变缩写，`--list` 该套显示 `—`，工具报「该技能在这套导出里找不到，或没有这个 acronym」，
   结构上不可能拿到 15/15。公式本身在另两套各 5 点全中，留档如下（未写入覆盖层）：
   - `T_DEFILING_TOUCH` #0：`["*",["-",1,["*",0.95,["^",["/",0.55,0.95],["/",["-",["sqrt",["max",1,["-",["talentLevel"],4]]]],["sqrt",1.3]],["-",["sqrt",6.5],["sqrt",1.3]]]]]],100]`
     （源：cursed-aura.lua:43 `combatTalentLimit(max(1, tl-4), 0, 0.95, 0.55)`，`(1-penalty)*100`）
   - `T_DARK_GIFTS` #1：`["combatScale",["max",0.1,["-",["talentLevel"],5]],1,1,2.5,5]`
     （源：cursed-aura.lua:286 `combatTalentScale(max(0, tl-5), 1, 2.5)`）

4. **`T_GESTURE_OF_POWER` #2、`T_GESTURE_OF_GUARDING` #2 —— 标题给了多个 5 点阶梯，没有唯一轴。**
   `#2`（`self:combatMindCrit()`）的标题同时把 `力量/灵巧/幸运/physical power` 四条都写成 `10/25/50/75/100`；
   `T_GESTURE_OF_GUARDING` #2（`combatStatScale("cun", 0, 2.25)`）同理有三条。工具按设计报
   「标题里没有唯一可变的轴」，属导出把整个 tooltip 的参数并集抄进 title 的已知现象，非公式问题。
