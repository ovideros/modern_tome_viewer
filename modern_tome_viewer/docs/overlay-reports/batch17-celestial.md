# batch17 · celestial 大系公式覆盖报告

- 范围（只做这 11 个大系）：`celestial/other`、`celestial/hymns`、`celestial/combat`、`celestial/chants`、
  `celestial/radiance`、`celestial/dirge`、`celestial/twilight`、`celestial/glyphs`、`celestial/sun`、
  `celestial/guardian`、`celestial/chants-chants`
- 覆盖层：`data/overlay-batches/batch17-celestial.json`（37 条）
- 汇总：`node scripts/try-formula.mjs --overlay data/overlay-batches/batch17-celestial.json`
  → **`覆盖层校验：37/37 通过`**（第一行通过数 37 == 数组长度 37）
- 目标 38 条 → PASS 37、跳过 1（`T_MIND_BLAST` #2，见「无法建模」）

各大系：目标数 / PASS 数 / 跳过数

| 大系 | 目标 | PASS | 跳过 |
| --- | --- | --- | --- |
| celestial/other | 6 | 6 | 0 |
| celestial/hymns | 6 | 6 | 0 |
| celestial/combat | 6 | 6 | 0 |
| celestial/chants | 6 | 6 | 0 |
| celestial/radiance | 4 | 4 | 0 |
| celestial/dirge | 3 | 3 | 0 |
| celestial/twilight | 3 | 2 | 1 |
| celestial/glyphs | 1 | 1 | 0 |
| celestial/sun | 1 | 1 | 0 |
| celestial/guardian | 1 | 1 | 0 |
| celestial/chants-chants | 1 | 1 | 0 |
| 合计 | 38 | 37 | 1 |

## 一、已完成

每条都跑出「结论：PASS（三套 15 点全中，输入集合覆盖）」；`source` 指向据以写公式的 getter/打印点。

| 技能 | acronym# | 大系 | 表达式 | source | 三套 |
| --- | --- | --- | --- | --- | --- |
| `T_HYMN_ACOLYTE` | 0 | celestial/hymns | `["^",["*",["/",["*",["+",20,["power","法术强度"]],0.2],["*",["+",20,100],1.9888543819998319]],50],1.04]` | `tome-src-full/data/talents/celestial/hymns.lua:59` | 15/15 |
| `T_HYMN_ACOLYTE` | 1 | celestial/hymns | `["^",["*",["/",["*",["+",7,["power","法术强度"]],0.2],["*",["+",7,100],1.9888543819998319]],20],1.04]` | `tome-src-full/data/talents/celestial/hymns.lua:60` | 15/15 |
| `T_HYMN_ACOLYTE` | 2 | celestial/hymns | `["^",["*",["/",["*",["+",2,["power","法术强度"]],0.2],["*",["+",2,100],1.9888543819998319]],25],1.04]` | `tome-src-full/data/talents/celestial/hymns.lua:160` | 15/15 |
| `T_HYMN_ACOLYTE` | 3 | celestial/hymns | `["^",["*",["/",["*",["+",2,["power","法术强度"]],0.2],["*",["+",2,100],1.9888543819998319]],25],1.04]` | `tome-src-full/data/talents/celestial/hymns.lua:159` | 15/15 |
| `T_HYMN_ACOLYTE` | 4 | celestial/hymns | `["^",["*",["/",["*",["+",10,["power","法术强度"]],0.2],["*",["+",10,100],1.9888543819998319]],50],1.04]` | `tome-src-full/data/talents/celestial/hymns.lua:161` | 15/15 |
| `T_CHANT_ACOLYTE` | 0 | celestial/chants | `["^",["*",["/",["*",["+",5,["power","法术强度"]],0.2],["*",["+",5,100],1.9888543819998319]],60],1.04]` | `tome-src-full/data/talents/celestial/chants.lua:37` | 15/15 |
| `T_CHANT_ACOLYTE` | 1 | celestial/chants | `["^",["*",["/",["*",["+",5,["power","法术强度"]],0.2],["*",["+",5,100],1.9888543819998319]],60],1.04]` | `tome-src-full/data/talents/celestial/chants.lua:98` | 15/15 |
| `T_CHANT_ACOLYTE` | 2 | celestial/chants | `["floor",["^",["*",["/",["*",["+",8,["power","法术强度"]],0.2],["*",["+",8,100],1.9888543819998319]],25],1.04]]` | `tome-src-full/data/talents/celestial/chants.lua:97` | 15/15 |
| `T_CHANT_ACOLYTE` | 3 | celestial/chants | `["floor",["^",["*",["/",["*",["+",8,["power","法术强度"]],0.2],["*",["+",8,100],1.9888543819998319]],25],1.04]]` | `tome-src-full/data/talents/celestial/chants.lua:97` | 15/15 |
| `T_CHANT_ACOLYTE` | 4 | celestial/chants | `["^",["*",["/",["*",["+",5,["power","法术强度"]],0.2],["*",["+",5,100],1.9888543819998319]],60],1.04]` | `tome-src-full/data/talents/celestial/chants.lua:163` | 15/15 |
| `T_CHANT_ACOLYTE` | 5 | celestial/chants | `["^",["*",["/",["*",["+",10,["power","法术强度"]],0.2],["*",["+",10,100],1.9888543819998319]],30],1.04]` | `tome-src-full/data/talents/celestial/chants.lua:159` | 15/15 |
| `T_GLYPH_OF_PARALYSIS` | 1 | celestial/other | `["*",0.8,["max",1,["combatScale",["*",["talentLevel"],["*",["actor","魔力"],0.15]],0,0,75,75]]]` | `tome-src-full/data/talents/celestial/other.lua:125` | 15/15 |
| `T_GLYPH_OF_PARALYSIS` | 2 | celestial/other | `["max",1,["combatScale",["*",["talentLevel"],["*",["actor","魔力"],0.15]],0,0,75,75]]` | `tome-src-full/data/talents/celestial/other.lua:125` | 15/15 |
| `T_GLYPH_OF_REPULSION` | 1 | celestial/other | `["*",0.8,["max",1,["combatScale",["*",["talentLevel"],["*",["actor","魔力"],0.15]],0,0,75,75]]]` | `tome-src-full/data/talents/celestial/other.lua:198` | 15/15 |
| `T_GLYPH_OF_REPULSION` | 2 | celestial/other | `["max",1,["combatScale",["*",["talentLevel"],["*",["actor","魔力"],0.15]],0,0,75,75]]` | `tome-src-full/data/talents/celestial/other.lua:198` | 15/15 |
| `T_GLYPH_OF_FATIGUE` | 1 | celestial/other | `["max",1,["combatScale",["*",["talentLevel"],["*",["actor","魔力"],0.15]],0,0,75,75]]` | `tome-src-full/data/talents/celestial/other.lua:368` | 15/15 |
| `T_GLYPH_OF_FATIGUE` | 2 | celestial/other | `["max",1,["combatScale",["*",["talentLevel"],["*",["actor","魔力"],0.15]],0,0,75,75]]` | `tome-src-full/data/talents/celestial/other.lua:368` | 15/15 |
| `T_GLYPHS` | 0 | celestial/glyphs | `["talentLimit",6,2,5]` | `tome-src-full/data/talents/celestial/glyphs.lua:43` | 15/15 |
| `T_BRANDISH` | 3 | celestial/guardian | `["floor",["talentScale",2.5,4.5]]` | `tome-src-full/data/talents/celestial/guardian.lua:79` | 15/15 |
| `T_SUN_BEAM` | 0 | celestial/sun | `["spellDamage",20,220]` | `tome-src-full/data/talents/celestial/sun.lua:44` | 15/15 |
| `T_RADIANCE` | 0 | celestial/radiance | `["talentLimit",14,4,10]` | `tome-src-full/data/talents/celestial/radiance.lua:30` | 15/15 |
| `T_JUDGEMENT` | 0 | celestial/radiance | `["spellDamage",3,50]` | `tome-src-full/data/talents/celestial/radiance.lua:61` | 15/15 |
| `T_JUDGEMENT` | 2 | celestial/radiance | `["spellDamage",6,50]` | `tome-src-full/data/talents/celestial/radiance.lua:63` | 15/15 |
| `T_ILLUMINATION` | 0 | celestial/radiance | `["+",15,["spellDamage",1,100]]` | `tome-src-full/data/talents/celestial/radiance.lua:171` | 15/15 |
| `T_TWILIGHT` | 0 | celestial/twilight | `["combatScale",["*",["talentLevel"],["*",["actor","灵巧"],0.4]],24,4,220,200,0.5,0,40]` | `tome-src-full/data/talents/celestial/twilight.lua:31` | 15/15 |
| `T_SHADOW_SIMULACRUM` | 1 | celestial/twilight | `["combatLimit",["*",["*",["actor","灵巧"],0.1],["talentLevel"]],90,0,0,50,50]` | `tome-src-full/data/talents/celestial/twilight.lua:206` | 15/15 |
| `T_DIRGE_ADEPT` | 0 | celestial/dirge | `["floor",["talentLevel"]]` | `tome-src-full/data/talents/celestial/dirge.lua:292` | 15/15 |
| `T_DIRGE_ACOLYTE` | 0 | celestial/dirge | `["*",["combatScale",0.1,2,1,6,5,0.75],["sqrt",["actor","角色等级"]]]` | `tome-src-full/data/talents/celestial/dirge.lua:63` | 15/15 |
| `T_DIRGE_ACOLYTE` | 1 | celestial/dirge | `["talentLimit",100,33,67]` | `tome-src-full/data/talents/celestial/dirge.lua:102` | 15/15 |
| `T_WEAPON_OF_LIGHT` | 0 | celestial/combat | `["+",7,["*",["power","法术强度",0.092],["talentScale",1,7]]]` | `tome-src-full/data/talents/celestial/combat.lua:72` | 15/15 |
| `T_WEAPON_OF_LIGHT` | 1 | celestial/combat | `["+",7,["*",["power","法术强度",0.092],["talentScale",1,7]]]` | `tome-src-full/data/talents/celestial/combat.lua:73` | 15/15 |
| `T_WAVE_OF_POWER` | 0 | celestial/combat | `["*",100,["weaponDamage",0.9,2]]` | `tome-src-full/data/talents/celestial/combat.lua:135` | 15/15 |
| `T_WAVE_OF_POWER` | 1 | celestial/combat | `["*",100,["*",["weaponDamage",0.9,2],["talentLimit",1,0.4,0.65]]]` | `tome-src-full/data/talents/celestial/combat.lua:135` | 15/15 |
| `T_WAVE_OF_POWER` | 2 | celestial/combat | `["combatLimit",["*",["talentLevel"],2],100,15,4,70,50]` | `tome-src-full/data/talents/celestial/combat.lua:132` | 15/15 |
| `T_HYMN_ADEPT` | 2 | celestial/hymns | `["spellDamage",20,30]` | `tome-src-full/data/talents/celestial/hymns.lua:437` | 15/15 |
| `T_CHANT_OF_FORTITUDE` | 2 | celestial/chants-chants | `["*",1000,["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],-0.10937836137264567],-0.008820872949819132]]]]` | `tome-src-full/data/talents/celestial/chants.lua:38` | 15/15 |
| `T_SECOND_LIFE` | 0 | celestial/combat | `["*",1500,["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],-0.18616183439704276],0.06915630503021047]]]]` | `tome-src-full/data/talents/celestial/combat.lua:235` | 15/15 |

## 二、发现的写法模式

1. **「入门」类 tooltip 把子技能渲染在等级 0**（本批最大的一类，13 条）。
   `T_HYMN_ACOLYTE` / `T_CHANT_ACOLYTE` / `T_DIRGE_ACOLYTE` 的 `info` 都先把子技能的
   `self.talents[子技能] = self.talents[入门技能]`，再逐项调用子技能 getter。导出侧的子技能等级是 **0**，
   所以 `combatTalentSpellDamage` 里 `(√tl−1)·0.8+1 = 0.2`、`combatTalentScale` 里 `tl<=0 → tl=0.1` 的守卫真的生效了。
   代表技能：`T_HYMN_ACOLYTE` #0（moveSpeed，`(20+SP)·0.2·50/((20+100)·K)` 再 `^1.04`）。
   → 解析器可加规则：入门技能文本里的值是「子技能 @ L=0」，按 `docs/expression-overlay.md` 的任意等级展开并代入 0。

2. **`combatTalentSpellDamage` 在锚点会少 1 个 ulp**，必须按源码 `limit*(1-exp(√tl·a+b))` 手工展开。
   代表技能：`T_CHANT_OF_FORTITUDE` #2（`combatTalentLimit(t,1,0.125,0.25)`，系数 1.30 / 等级 1 的真实值是
   `0.12499999999999988898` → `124`，而工作台里等价的 `["talentLimit",1,0.125,0.25]` 精确给 `0.125` → `125`）。
   同类：`T_SECOND_LIFE` #0（6.5 锚点给 `499.99999999999989` → `499`）。

3. **锚点的方向不统一**：`T_GLYPHS` #0（`combatTalentLimit(t,6,2,5)`，系数 1.30 / 等级 1.3 锚点）与
   `T_RADIANCE` #0（`combatTalentLimit(t,14,4,10)`）反而要求锚点取到**精确的 low 值**（2、4），
   这时候工作台重排后的 `["talentLimit",…]` 是正确的、手工展开会差 1。
   → 两种写法都要留在工具箱里，逐条按导出读数选。

4. **`self:getXxx(mod, true)` = 属性 × mod/100**。
   `getMag(15,true) = 魔力×0.15`、`getCun(40,true) = 灵巧×0.40`、`getCun(10,true) = 灵巧×0.10`、`getCun(5) = 灵巧×0.05`。
   代表技能：`T_GLYPH_OF_PARALYSIS`（`combatScale(tl * getMag(15,true), 0,0,75,75)`，`tl·15`）、`T_TWILIGHT`。
   → 解析器可把 `getMag(v,true)`/`getCun(v,true)` 直接改写成 `["*",["actor","魔力"],v/100]`。

5. **`math.ceil(...)` 是源码写法、导出是 `%d` 截断**，所以公式里要**去掉 ceil**。
   代表技能：`T_ILLUMINATION` #0（`math.ceil(15 + combatTalentSpellDamage(t,1,100))`，导出 73 = `trunc(73.81)`）、
   `T_HYMN_ADEPT` #2（`math.ceil(combatTalentSpellDamage(t,20,30))`，导出 16 = `trunc(16.81)`）。

6. **同一 `tformat` 调用里同一数值被两种读数打印**：`T_WEAPON_OF_LIGHT` #0 是 `%0.1f`（≥10 只留整数、四舍五入），
   #1 是 `%d`（截断），导出值成对出现（16/35/49/61/71 与 16/34/48/60/71）。一条表达式即可，判分器自己认读数。

7. **纯等级式**：`T_DIRGE_ADEPT` #0 = `math.floor(self:getTalentLevel(t))` → `["floor",["talentLevel"]]`。

## 三、无法建模

| 技能 | acronym# | 原因 |
| --- | --- | --- |
| `T_MIND_BLAST` | 2 | **导出侧元数据缺陷 + 三套轴不一致**。源码是 `getConfuseDuration = min(10, floor(combatScale(tl + getCun(5), 2, 0, 12, 10)))`。系数 1.00 / 1.30 两套的 title 轴是`技能等级 1-5`（`灵巧 100` 固定），`["min",10,["floor",["combatScale",…]]]` 能 15 点全中；但系数 1.50 那一套同名 acronym 的 title 同时挂了 **两条 5 点阶梯**（`灵巧 10/25/50/75/100` 与 `法术强度 10/25/50/75/100`），`ladderAxis()` 直接判 `标题里没有唯一可变的轴`；即便强行按灵巧轴试算，该套读数 `5, 7, 7, 8, 10` 也不落在 `2+3.162278·√(tl+灵巧/20)` 的任何一种取整读法上（该式给 `5,6,7,8,9`）。工具报的正是「标题里没有唯一可变的轴」，按要求跳过。 |

其余 37 条没有「运行时数据表 / 玩家武器 / 真随机 / 别的角色状态」类障碍；
`T_GLYPHS` #0、`T_SUN_BEAM` #0 里 `if self:knowTalent(...)` / `self:attr("amplify_sun_beam")` 的分支，
导出基准都是「未学会 / 无 buff」，取 else 分支即可（已写进 `note`）。

## 四、疑点

1. **`self.max_life` 被冻结成常数 1000**（`T_CHANT_OF_FORTITUDE` #2、`T_SECOND_LIFE` #0）。
   title 只声明 `技能等级 / 技能系数`，没有 `最大生命值`，而源码是
   `life * self.max_life` / `self.max_life * combatTalentLimit(t,1.5,0.2,0.5)`。
   导出基准（未加 buff 的假 actor）max_life 恰为 1000：
   `T_CHANT_OF_FORTITUDE` #2 系数 1.30 等级 5 给 `0.25×1000 = 250`、
   `T_SECOND_LIFE` #0 系数 1.00 等级 1 给 `0.165630×1000 = 165`，15 点全部对上。
   按 `docs/expression-overlay.md` 的「未声明的量可冻结成常数并在 note 说明」处理，已在 `note` 写明。
   三套数据（`T_SECOND_LIFE` #0）：

   | 系数 | 1 | 2 | 3 | 4 | 5 |
   | --- | --- | --- | --- | --- | --- |
   | 1.00 | 165 | 264 | 335 | 392 | 439 |
   | 1.30 | 199 | 309 | 387 | 448 | 499 |
   | 1.50 | 220 | 335 | 417 | 481 | 534 |

   （对应算得 `165.63 / 264.66 / 335.63 / 392.29 / 439.91`、`200.00 / 309.42 / 387.09 / 448.62 / 500.00`、
   `220.31 / 335.63 / 417.02 / 481.21 / 534.59`，全部按 `%d` 截断。）

2. **`combatTalentLimit` 的锚点会「少 1」**（见「写法模式 2」）。这是源码指数式与解析器重排式的浮点差，
   不是导出错误；但说明 `["talentLimit",…]` 节点**不能**无条件替代源码展开。三套数据（`T_CHANT_OF_FORTITUDE` #2）：

   | 系数 | 1 | 2 | 3 | 4 | 5 |
   | --- | --- | --- | --- | --- | --- |
   | 1.00 | 111 | 150 | 179 | 203 | 223 |
   | 1.30 | **124** | 169 | 201 | 227 | 250 |
   | 1.50 | 133 | 179 | 214 | 241 | 265 |

   系数 1.30 / 等级 1 的真实公式值 `124.99999999999988898 → 124`；工作台 `["talentLimit",1,0.125,0.25]`
   给 `0.125 → 125`（差 1）。反之 `T_GLYPHS` #0 的同类锚点必须用重排式才能取到 `2`。建议构建端把这条
   记进解析器说明：**锚点两侧各留一条候选**。

3. **`T_JUDGEMENT` #0 与 #2 的 15 点读数完全相同**，但源码是两个不同 base：
   `getMoveDamage = combatTalentSpellDamage(t,3,50)`、`getSavePen = combatTalentSpellDamage(t,6,50)`。
   原因是指出基准 `法术强度 = 100` 使 `(base+SP) == (base+100)`，两者恰好同值，**不是重复导出**。
   滑条一旦离开 100 就会分开，所以两条都按各自 base 写。

4. **`T_HYMN_ACOLYTE` / `T_CHANT_ACOLYTE` 的 `技能系数` 列不参与**：这两条 title 只有 `法术强度` 一条阶梯，
   三套导出数字完全相同，工作台显示的三行「系数 1.5」是 `ref.params` 里没有 coefficient 时的展示兜底值，
   实际按 `技能系数 = 1` 求值（源码里子技能 @ L=0，与系数无关）。
