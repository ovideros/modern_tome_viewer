# 表达式覆盖层总报告

> 目标：把自动提取失败的技能数值，通过**读游戏 Lua 源码手写表达式**补上，并用仓库自带判分器证明正确。
> 全部命令：`cd modern_tome_viewer && node scripts/try-formula.mjs --overlay data/lua-expressions.json`

## 0. 结论摘要

| 项 | 数值 |
| --- | --- |
| 目标总数 | **1281** 条（285 个大系）|
| 本次交付 | **267** 条，覆盖 **15** 个大系 |
| 这 15 个大系内覆盖率 | **267 / 290 = 92.1%**（处理前是 208 / 290 = 71.7%）|
| 全库覆盖率 | **267 / 1281 = 20.8%** |
| 验收 | `覆盖层校验：267/267 通过`（每条都满足：三套导出系数 1.00/1.30/1.50 共 15 点全中 ＋ 表达式读到的输入都被标题声明过）|
| 回归 | scaling **41/41** · verify **77/77** · smoke **42/42** · e2e **160/160** · typecheck OK |
| 分树报告 | 15 份，见 `docs/overlay-reports/` |

**交付物**

1. `modern_tome_viewer/data/lua-expressions.json` —— 覆盖层（267 条，字段 `talent` / `acronym` / `expr` / `source` / `note`）
2. `modern_tome_viewer/docs/expression-overlay-report.md` —— 本报告
3. `modern_tome_viewer/data/overlay-batches/<tree>.json` —— 每大系原始批次（可单独重跑，审计留痕）
4. `modern_tome_viewer/docs/overlay-reports/<tree>.md` —— 每大系报告

---

## 一、本轮修掉的两处判分器缺陷（覆盖率从 71.7% 升到 92.1% 的真正原因）

这两处都不是「公式写不出来」，而是**工具把正确的公式判成了错**。它们各自有实测证据，修完后回归全绿。

### 缺陷 1：输入集合用的是「等号」，多声明即判 FAIL

- **位置**：`scripts/lua-scaling.mjs`（`matchLuaFormula`）、`scripts/try-formula.mjs`
- **现象**：闸门原先要求 `表达式消耗 == 标题声明`。但导出会把整个 tooltip 的参数并集抄进多个 acronym 的 title，
  于是一条**根本不读 paradox** 的 range 也带着 `paradox 300`，公式正确却被判 FAIL。
- **证据**：`chronomancy` 全学派自动匹配率只有 **119/279 = 42.7%**，全库是 **65.8%**；
  `chronomancy/spacetime-folding` 处理前只有 4/16 已匹配。
- **修法**：判定改为**覆盖**——`表达式消耗 ⊆ 标题声明`。工具现在区分三种情形：
  `✅ 完全一致` / `✅ 覆盖（标题是超集，本值未用到：X）` / `❌ 表达式读了标题未声明的输入 [X]`。
- **保留的那半边**：读了标题没声明的输入仍然 FAIL（`uncoveredInputs`）。这是正确性规则——那种输入没有滑条，
  数字会静默依赖没人能设的状态。要处理它只能换成等价写法、或按导出基准**冻结成常数**并在 `note` 说明。
- **收益**：直接回收 50 条；更关键的是解开了整个 `chronomancy` / `psionic` 一类的系统性封锁。

### 缺陷 2：显示读数按「整条阶梯最大小数位」统一比对

- **位置**：`scripts/lua-scaling.mjs`（`matchesDisplayed` / `integerRounding`）、`src/lib/scaling-core.js`（`formatAcronymValue`）
- **现象**：`scaling-core.js` 把 acronym 的精度取成「整条阶梯里最多的小数位」，然后要求**每个点**都按该精度精确匹配。
  但导出的真实渲染是：
  1. 游戏按技能自己的格式符（`%d` / `%0.1f` / `%0.2f` …）渲染；
  2. **数值 ≥ 10 时只打印整数部分**——全库 6557 个 ≥10 的显示值里**没有**带小数点的；
  3. 所以同一条阶梯会混着 `3.33` 与 `10`，而某个整数点可能是「先按格式符归整、再取整」的产物
     （`%0.1f` 的 46.4835 → `"46.5"` → 47）。
- **证据（典型）**：

  | 技能 | 显示 | 算得 | 旧判定 |
  | --- | --- | --- | --- |
  | `T_ANOMALY_TEMPORAL_STORM#2` | 3.33, 6.18, **10, 14, 17** | 3.3333, 6.1831, 10.0923, 13.5194, 16.6667 | 后 3 点按 2 位小数判 ❌ |
  | `T_DEEPROCK_FORM#2`（`getPen`）| **7.0, 9.3, 11, 13, 14** | 6.997, 9.343, 11.103, 12.561, 13.825 | 整数点按 1 位小数判 ❌ |
  | `T_WATER_BOLT#0` | 47, 107, 285 | 46.4835, 106.4634, 284.4959 | 全整数阶梯无两段取整 ❌ |

- **修法**：判定与渲染共认**四种整数读数** `trunc` / `round` / `round1` / `round2`（`round1/2` = 先按 1/2 位小数
  归整再取整），由**该阶梯自己的证据**选定一种，且必须能复现整条阶梯；小数点仍按该点自己的小数位精确比对。
  `formatAcronymValue` 同步按同一读数渲染，保证「网页显示的数」与「导出印的数」逐字一致。
- **收益**：回收 27 条；并且推翻了一条旧结论——`spell/deeprock` 的 `getPen` 原先记为「源码与导出系统性不一致」，
  实际**公式一直是对的**（3 条现已成为覆盖层条目）。
- **护栏**：这次改动一度让一条不变量测试失败（`every source value re-renders its own ladder exactly as exported`，
  暴露 `T_NEBULA_SPEAR`/`T_CELESTIAL_ACCELERATION` 能被判过但渲染不出来）。正是这条测试逼出了「读数由阶梯证据选定、
  判分器与渲染器共用」的正确设计，而不是单纯放松判分器。

### 连带收益：自动提取器本身也涨了 142 条

两处判分器缺陷同时也是**自动匹配**的瓶颈。用新判分器把全库 3750 条 acronym 重跑一遍自动匹配：

| | 条数 | 占比 |
| --- | --- | --- |
| 旧判分器自动匹配（manifest 记录） | 2469 | 65.8% |
| **新判分器自动匹配** | **2611** | **69.6%** |
| 净增 | **+142** | +3.8pp |

再加上覆盖层：**合计 2850 / 3750 = 76.0%**（旧口径 2469 + 208 = 2677 = 71.4%）。
其中覆盖层真正独有的贡献是 **239** 条，另有 28 条在新判分器下已能被自动提取（冗余但无害，构建时按
`matches.size !== 1` 会判歧义，见第五节建议 1）。

也就是说：**重建一次数据（`npm run data`）本身就能白拿 +142 条**，不需要任何新的覆盖层条目。

### 方法论：不接受「复刻显示规则」的包装

中途有代理为了过关，在纯源码公式外面套了一层复刻渲染的包装（用 `["min",1,["floor",["/",v,10]]]` 当选择子）。
**本报告明确否决这类条目**：它固化的是静态导出的渲染伪影，滑条一动就错。这 6 条已全部换回纯源码公式，
并在 `docs/expression-overlay.md` 新增「导出的显示读数（不要把它写进公式）」一节，避免后续再犯。

---

## 二、已完成

### 2.1 按大系

| 大系 | 已完成 / 目标 | 覆盖率 | 分树报告 |
| --- | --- | --- | --- |
| `cunning/artifice` | 33 / 33 | 100% | [`cunning__artifice.md`](overlay-reports/cunning__artifice.md) |
| `cunning/traps` | 31 / 32 | 97% | [`cunning__traps.md`](overlay-reports/cunning__traps.md) |
| `chronomancy/anomalies` | 29 / 29 | 100% | [`chronomancy__anomalies.md`](overlay-reports/chronomancy__anomalies.md) |
| `chronomancy/other` | 25 / 28 | 89% | [`chronomancy__other.md`](overlay-reports/chronomancy__other.md) |
| `technique/other` | 21 / 24 | 88% | [`technique__other.md`](overlay-reports/technique__other.md) |
| `psionic/voracity` | 21 / 21 | 100% | [`psionic__voracity.md`](overlay-reports/psionic__voracity.md) |
| `corruption/demon-seeds` | 16 / 16 | 100% | [`corruption__demon-seeds.md`](overlay-reports/corruption__demon-seeds.md) |
| `wild-gift/summon-melee` | 14 / 14 | 100% | [`wild-gift__summon-melee.md`](overlay-reports/wild-gift__summon-melee.md) |
| `spell/other` | 13 / 14 | 93% | [`spell__other.md`](overlay-reports/spell__other.md) |
| `cursed/shadows` | 13 / 13 | 100% | [`cursed__shadows.md`](overlay-reports/cursed__shadows.md) |
| `spell/deeprock` | 13 / 13 | 100% | [`spell__deeprock.md`](overlay-reports/spell__deeprock.md) |
| `psionic/other` | 12 / 14 | 86% | [`psionic__other.md`](overlay-reports/psionic__other.md) |
| `chronomancy/spacetime-folding` | 12 / 12 | 100% | [`chronomancy__spacetime-folding.md`](overlay-reports/chronomancy__spacetime-folding.md) |
| `spell/master-of-flesh` | 12 / 12 | 100% | [`spell__master-of-flesh.md`](overlay-reports/spell__master-of-flesh.md) |
| `uber/cunning` | 2 / 15 | 13% | [`uber__cunning.md`](overlay-reports/uber__cunning.md) |
| **合计** | **267 / 290** | **92.1%** | 15 份 |

### 2.2 全量条目

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| `T_AMBUSCADE` | #1 | `["*",100,["combatLimit",["spellDamage",20,500],1,0.2,0,0.584,384]]` | `tome-src-full/data/talents/misc/npcs.lua:3540` | ✅ |
| `T_AMBUSCADE` | #2 | `["*",100,["combatLimit",["spellDamage",10,500],1.6,0.4,0,0.761,361]]` | `tome-src-full/data/talents/misc/npcs.lua:3541` | ✅ |
| `T_AMBUSCADE` | #3 | `["combatScale",["*",15,["talentLevel"]],25,0,100,75]` | `tome-src-full/data/talents/misc/npcs.lua:3538` | ✅ |
| `T_AMBUSH_TRAP` | #0 | `["floor",["*",25,["-",1,["exp",["+",["*",["sqrt",["*",["actor","陷阱专精 技能等级"],["talentLevel"]]],["/",["log",["/",["-",7,25],["-",3,25]]],["-",["sqrt",6.5],["sqrt",1.3]]]],["/",["-",0,["-",["*",["-",["sqrt",6.5],["sqrt",1.3]],["log",["-",1,["/",7,25]]]],["*",["sqrt",6.5],["log",["/",["-",7,25],["-",3,25]]]]]],["-",["sqrt",1.3],["sqrt",6.5]]]]]]]]` | `tome-src-full/data/talents/cunning/traps.lua:1788` | ✅ |
| `T_ANOMALY_BLINK` | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:57` | ✅ |
| `T_ANOMALY_BLINK` | #1 | `["ceil",["*",0.75,["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],4,10,12,100,0.75]]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:44` | ✅ |
| `T_ANOMALY_CALCIFY` | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:57` | ✅ |
| `T_ANOMALY_CALCIFY` | #1 | `["ceil",["*",0.75,["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],4,10,12,100,0.75]]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:44` | ✅ |
| `T_ANOMALY_DEUS_EX` | #0 | `["ceil",["*",0.75,["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],4,10,12,100,0.75]]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:44` | ✅ |
| `T_ANOMALY_DIG` | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:57` | ✅ |
| `T_ANOMALY_DISPLACEMENT_SHIELD` | #0 | `["*",2,["*",["/",2,3],["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],20,10,220,100,0.75]]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:28` | ✅ |
| `T_ANOMALY_ENTROPY` | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:57` | ✅ |
| `T_ANOMALY_ENTROPY` | #1 | `["ceil",["*",0.75,["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],4,10,12,100,0.75]]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:44` | ✅ |
| `T_ANOMALY_FLAWED_DESIGN` | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:57` | ✅ |
| `T_ANOMALY_FLAWED_DESIGN` | #1 | `["ceil",["*",0.75,["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],10,10,50,100,0.75]]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:39` | ✅ |
| `T_ANOMALY_GRAVITY_PULL` | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:57` | ✅ |
| `T_ANOMALY_GRAVITY_WELL` | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:57` | ✅ |
| `T_ANOMALY_HASTE` | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:57` | ✅ |
| `T_ANOMALY_HASTE` | #1 | `["*",100,["-",1,["/",1,["+",1,["/",["ceil",["*",0.75,["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],10,10,50,100,0.75]]],100]]]]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:699` | ✅ |
| `T_ANOMALY_INVIGORATE` | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:57` | ✅ |
| `T_ANOMALY_MASS_DIG` | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:57` | ✅ |
| `T_ANOMALY_PROBABILITY_TRAVEL` | #0 | `["*",2,["ceil",["*",0.75,["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],4,10,12,100,0.75]]]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:44` | ✅ |
| `T_ANOMALY_PROBABILITY_TRAVEL` | #1 | `["ceil",["*",0.75,["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],4,10,12,100,0.75]]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:44` | ✅ |
| `T_ANOMALY_QUAKE` | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:57` | ✅ |
| `T_ANOMALY_REARRANGE` | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:57` | ✅ |
| `T_ANOMALY_SLOW` | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:57` | ✅ |
| `T_ANOMALY_SLOW` | #1 | `["*",100,["-",1,["/",1,["+",1,["/",["ceil",["*",0.75,["combatScale",["*",["power","法术强度"],["pmod",["actor","paradox"]]],10,10,50,100,0.75]]],100]]]]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:649` | ✅ |
| `T_ANOMALY_STOP` | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:57` | ✅ |
| `T_ANOMALY_TELEPORT` | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:57` | ✅ |
| `T_ANOMALY_TELEPORT` | #1 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],80,20,20,40,100]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:51` | ✅ |
| `T_ANOMALY_TEMPORAL_BUBBLE` | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:57` | ✅ |
| `T_ANOMALY_TEMPORAL_SHIELD` | #0 | `["floor",["combatLimit",["*",["power","法术强度"],["pmod",["actor","paradox"]]],6,2,20,4,100]]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:57` | ✅ |
| `T_ANOMALY_TEMPORAL_STORM` | #2 | `["/",["combatScale",["power","法术强度",["*",1,["pmod",["actor","paradox"]]]],10,10,50,100,0.75],3]` | `tome-src-full/data/talents/chronomancy/anomalies.lua:1020` | ✅ |
| `T_BANISH` | #0 | `["/",["floor",["combatScale",["talentLevel"],8,1,16,5,0.5]],2]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:406` | ✅ |
| `T_BANISH` | #1 | `["floor",["combatScale",["talentLevel"],8,1,16,5,0.5]]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:406` | ✅ |
| `T_BANISH` | #2 | `["floor",["*",["floor",["talentScale",2,4]],["pmod",["actor","paradox"]]]]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:407` | ✅ |
| `T_BEAM_TRAP` | #0 | `["floor",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],3,1,6,5]]` | `tome-src-full/data/talents/cunning/traps.lua:1325` | ✅ |
| `T_BEAM_TRAP` | #1 | `["/",["+",15,["/",["*",["statScale","cun",10,60],["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5]],20]],3]` | `tome-src-full/data/talents/cunning/traps.lua:1326` | ✅ |
| `T_BEAR_TRAP` | #0 | `["+",20,["*",10,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | `tome-src-full/data/talents/cunning/traps.lua:951` | ✅ |
| `T_BEAR_TRAP` | #1 | `["+",20,["*",10,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | `tome-src-full/data/talents/cunning/traps.lua:951` | ✅ |
| `T_BLADESTORM_TRAP` | #0 | `["floor",["*",0.75,["floor",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],9,1,13,5]]]]` | `tome-src-full/data/talents/cunning/traps.lua:1269` | ✅ |
| `T_BLIGHT_BOLT` | #1 | `["talentScale",7,25,0.75]` | `tome-src-full/data/talents/misc/npcs.lua:680` | ✅ |
| `T_BLOODRAGE` | #0 | `["floor",["*",6,["talentLevel"]]]` | `tome-src-full/data/talents/misc/npcs.lua:2439` | ✅ |
| `T_BODY_SHOT` | #0 | `["*",100,["weaponDamage",1.1,1.8]]` | `tome-src-full/data/talents/misc/npcs.lua:2293` | ✅ |
| `T_BODY_SHOT` | #1 | `["*",2,["talentLevel"]]` | `tome-src-full/data/talents/misc/npcs.lua:2328` | ✅ |
| `T_BODY_SHOT` | #2 | `["ceil",["*",0.25,["talentScale",1,5]]]` | `tome-src-full/data/talents/misc/npcs.lua:2294` | ✅ |
| `T_BODY_SHOT` | #3 | `["ceil",["*",1.25,["talentScale",1,5]]]` | `tome-src-full/data/talents/misc/npcs.lua:2294` | ✅ |
| `T_BOULDER_ROCK` | #0 | `["+",5,["/",["spellDamage",10,250],10]]` | `tome-src-full/data/talents/spells/deeprock.lua:86` | ✅ |
| `T_BOULDER_ROCK` | #1 | `["talentLimit",100,6.6,13]` | `tome-src-full/data/talents/spells/deeprock.lua:87` | ✅ |
| `T_BOULDER_ROCK` | #2 | `["*",2,["talentLevel",true]]` | `tome-src-full/data/talents/spells/deeprock.lua:92` | ✅ |
| `T_BOULDER_ROCK` | #3 | `["combatScale",["*",["actor","力量"],["*",2,["talentLevel",true]]],12,0,262,500]` | `tome-src-full/data/talents/misc/npcs.lua:1167` | ✅ |
| `T_BOULDER_ROCK` | #4 | `["floor",["combatScale",["*",2,["talentLevel",true]],4,1,8,5,0.5]]` | `tome-src-full/data/talents/misc/npcs.lua:1168` | ✅ |
| `T_CALL_OF_THE_MAUSOLEUM` | #0 | `["floor",["-",30,["*",20,["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],["/",["log",["/",["-",12,10],["-",30,10]]],["-",["sqrt",6.5],["sqrt",1.3]]]],["/",["-",["*",["-",["sqrt",6.5],["sqrt",1.3]],["log",["-",1,["/",["-",30,12],["-",30,10]]]]],["*",["sqrt",6.5],["log",["/",["-",12,10],["-",30,10]]]]],["-",["sqrt",6.5],["sqrt",1.3]]]]]]]]]` | `tome-src-full/data/talents/spells/master-of-flesh.lua:132` | ✅ |
| `T_CALL_OF_THE_MAUSOLEUM` | #1 | `["max",1,["+",["actor","角色等级"],["floor",["combatScale",["talentLevel"],-6,0.9,2,5]]]]` | `tome-src-full/data/talents/spells/master-of-flesh.lua:134` | ✅ |
| `T_CALL_OF_THE_MAUSOLEUM` | #2 | `["max",1,["floor",["talentScale",1,5]]]` | `tome-src-full/data/talents/spells/master-of-flesh.lua:127` | ✅ |
| `T_CALL_OF_THE_MAUSOLEUM` | #3 | `["floor",["talentScale",5,10]]` | `tome-src-full/data/talents/spells/master-of-flesh.lua:133` | ✅ |
| `T_CALL_SHADOWS` | #0 | `["min",4,["max",1,["floor",["*",0.55,["talentLevel"]]]]]` | `tome-src-full/data/talents/cursed/shadows.lua:350` | ✅ |
| `T_CALL_SHADOWS` | #2 | `["talentLevel",true]` | `tome-src-full/data/talents/cursed/shadows.lua:362` | ✅ |
| `T_CALL_SHADOWS` | #3 | `["talentLevel",true]` | `tome-src-full/data/talents/cursed/shadows.lua:359` | ✅ |
| `T_CALL_SHADOWS` | #4 | `["max",0,["min",100,["combatScale",["talentLevel"],5,1,85,5]]]` | `tome-src-full/data/talents/cursed/shadows.lua:353` | ✅ |
| `T_CARBON_SPIKES` | #1 | `["spellDamage",1,150,["*",["power","法术强度"],["pmod",["actor","paradox"]]]]` | `tome-src-full/data/talents/chronomancy/other.lua:801` | ✅ |
| `T_CATAPULT_TRAP` | #0 | `["+",1,["floor",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],2,1,6,5]]]` | `tome-src-full/data/talents/cunning/traps.lua:2055` | ✅ |
| `T_CHARGE_LEECH` | #0 | `["floor",["+",["*",["/",["-",4,1],["-",["^",5,0.5],["^",1,0.5]]],["^",["talentLevel"],0.5]],["-",1,["/",["-",4,1],["-",["^",5,0.5],["^",1,0.5]]]]]]` | `tome-src-full/data/talents/psionic/voracity.lua:160` | ✅ |
| `T_CHARGE_LEECH` | #1 | `["*",["mindDamage",20,130],["max",0.5,["-",1.5,["/",["actor","psi"],100]]]]` | `tome-src-full/data/talents/psionic/voracity.lua:170` | ✅ |
| `T_CHARGE_LEECH` | #2 | `["*",["mindDamage",20,130],1.5]` | `tome-src-full/data/talents/psionic/voracity.lua:170` | ✅ |
| `T_CHARGE_LEECH` | #3 | `["+",100,["*",["-",25,100],["^",["/",["-",50,100],["-",25,100]],["/",["-",["sqrt",["*",["talentLevel"],["max",0.5,["-",1.5,["/",["actor","psi"],100]]]]],["sqrt",1.3]],["-",["sqrt",6.5],["sqrt",1.3]]]]]]` | `tome-src-full/data/talents/psionic/voracity.lua:174` | ✅ |
| `T_CHARGE_LEECH` | #4 | `["+",100,["*",["-",25,100],["^",["/",["-",50,100],["-",25,100]],["/",["-",["sqrt",["*",["talentLevel"],1.5]],["sqrt",1.3]],["-",["sqrt",6.5],["sqrt",1.3]]]]]]` | `tome-src-full/data/talents/psionic/voracity.lua:174` | ✅ |
| `T_CHARGE_LEECH` | #5 | `["*",["talentScale",10,20],["max",0.5,["-",1.5,["/",["actor","psi"],100]]]]` | `tome-src-full/data/talents/psionic/voracity.lua:166` | ✅ |
| `T_CHARGE_LEECH` | #6 | `["*",["talentScale",10,20],1.5]` | `tome-src-full/data/talents/psionic/voracity.lua:166` | ✅ |
| `T_CIRCLE_OF_BLAZING_LIGHT` | #0 | `["floor",["talentScale",2.5,4.5]]` | `tome-src-full/data/talents/misc/npcs.lua:3722` | ✅ |
| `T_CIRCLE_OF_BLAZING_LIGHT` | #1 | `["+",1,["/",["spellDamage",2,15],4]]` | `tome-src-full/data/talents/misc/npcs.lua:3748` | ✅ |
| `T_CIRCLE_OF_BLAZING_LIGHT` | #2 | `["spellDamage",2,15]` | `tome-src-full/data/talents/misc/npcs.lua:3719` | ✅ |
| `T_CIRCLE_OF_BLAZING_LIGHT` | #3 | `["spellDamage",2,15]` | `tome-src-full/data/talents/misc/npcs.lua:3719` | ✅ |
| `T_CIRCLE_OF_BLAZING_LIGHT` | #4 | `["floor",["talentScale",4,8]]` | `tome-src-full/data/talents/misc/npcs.lua:3720` | ✅ |
| `T_COMBO_STRING` | #0 | `["combatLimit",["*",["+",5,["/",["*",["actor","灵巧"],5],100]],["talentLevel"]],100,0,0,50,50]` | `tome-src-full/data/talents/misc/npcs.lua:2344` | ✅ |
| `T_CORPSE_EXPLOSION` | #0 | `["floor",["+",3,["/",["*",5,["-",["sqrt",["talentLevel"]],1]],["-",["sqrt",5],1]]]]` | `tome-src-full/data/talents/spells/master-of-flesh.lua:256` | ✅ |
| `T_CORPSE_EXPLOSION` | #1 | `["spellDamage",40,200]` | `tome-src-full/data/talents/spells/master-of-flesh.lua:257` | ✅ |
| `T_CORPSE_EXPLOSION` | #2 | `["spellDamage",5,28]` | `tome-src-full/data/talents/spells/master-of-flesh.lua:258` | ✅ |
| `T_CORPSE_EXPLOSION` | #3 | `["spellDamage",40,200]` | `tome-src-full/data/talents/spells/master-of-flesh.lua:272` | ✅ |
| `T_CUNNING_TOOLS` | #0 | `["talentLevel",true]` | `tome-src-full/data/talents/cunning/artifice.lua:146` | ✅ |
| `T_CUNNING_TOOLS` | #1 | `["+",15,["statDamage","cun",12,150]]` | `tome-src-full/data/talents/cunning/artifice.lua:620` | ✅ |
| `T_CUNNING_TOOLS` | #2 | `["ceil",["talentScale",3,5]]` | `tome-src-full/data/talents/cunning/artifice.lua:519` | ✅ |
| `T_CUNNING_TOOLS` | #3 | `["floor",["talentScale",1,6,"log",0,4]]` | `tome-src-full/data/talents/cunning/artifice.lua:520` | ✅ |
| `T_CUNNING_TOOLS` | #4 | `["talentScale",4,7]` | `tome-src-full/data/talents/cunning/artifice.lua:687` | ✅ |
| `T_CUNNING_TOOLS` | #5 | `["*",["weaponDamage",1,1.8],100]` | `tome-src-full/data/talents/cunning/artifice.lua:305` | ✅ |
| `T_CUNNING_TOOLS` | #6 | `["+",["statScale","cun",10,200,0.7],["talentScale",20,200,0.7]]` | `tome-src-full/data/talents/cunning/artifice.lua:427` | ✅ |
| `T_CUNNING_TOOLS` | #7 | `["+",["+",["*",["/",45,["-",["^",100,0.75],["^",10,0.75]]],["^",["actor","灵巧"],0.75]],["-",5,["*",["/",45,["-",["^",100,0.75],["^",10,0.75]]],["^",10,0.75]]]],["+",["*",["/",45,["-",["^",5,0.75],["^",1,0.75]]],["^",["talentLevel"],0.75]],["-",5,["*",["/",45,["-",["^",5,0.75],["^",1,0.75]]],["^",1,0.75]]]]]` | `tome-src-full/data/talents/cunning/artifice.lua:430` | ✅ |
| `T_CUNNING_TOOLS` | #8 | `["floor",["talentScale",1,3,"log"]]` | `tome-src-full/data/talents/cunning/artifice.lua:432` | ✅ |
| `T_DAMAGE_SMEARING` | #0 | `["*",["/",["*",50,["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],["/",["log",["/",["-",30,50],["-",10,50]]],["-",["sqrt",6.5],["sqrt",1.3]]]],["/",["-",0,["-",["*",["-",["sqrt",6.5],["sqrt",1.3]],["log",["-",1,["/",30,50]]]],["*",["sqrt",6.5],["log",["/",["-",30,50],["-",10,50]]]]]],["-",["sqrt",1.3],["sqrt",6.5]]]]]]],100],100]` | `tome-src-full/data/talents/chronomancy/other.lua:610` | ✅ |
| `T_DAMAGE_SMEARING` | #1 | `["floor",["*",["floor",["talentScale",3,6]],["pmod",["actor","paradox"]]]]` | `tome-src-full/data/talents/chronomancy/other.lua:611` | ✅ |
| `T_DEEPROCK_FORM` | #2 | `["talentLimit",100,6.6,13]` | `tome-src-full/data/talents/spells/deeprock.lua:34` | ✅ |
| `T_DEEPROCK_FORM` | #3 | `["talentScale",7.3,11.5,0.75]` | `tome-src-full/data/talents/spells/deeprock.lua:35` | ✅ |
| `T_DEFENSIVE_THROW` | #0 | `["combatLimit",["*",["talentLevel"],["+",5,["/",["*",["actor","灵巧"],5],100]]],100,0,0,50,50]` | `tome-src-full/data/talents/misc/npcs.lua:3376` | ✅ |
| `T_DEFENSIVE_THROW` | #1 | `["physicalDamage",5,50]` | `tome-src-full/data/talents/misc/npcs.lua:3373` | ✅ |
| `T_DEFENSIVE_THROW` | #2 | `["physicalDamage",10,75]` | `tome-src-full/data/talents/misc/npcs.lua:3374` | ✅ |
| `T_DEMON_SEED_BLIGHTED_PATH` | #0 | `["+",4,["*",2,["floor",["talentLevel"]]]]` | `dlc-src/ashes-urhrok/tome-ashes-urhrok/data/talents/corruptions/demon-seeds.lua:249` | ✅ |
| `T_DEMON_SEED_BLIGHTED_PATH` | #1 | `["talentScale",3,10,0.5]` | `dlc-src/ashes-urhrok/tome-ashes-urhrok/data/talents/corruptions/demon-seeds.lua:248` | ✅ |
| `T_DEMON_SEED_BLIGHTED_PATH` | #3 | `["/",["spellDamage",50,500],9]` | `dlc-src/ashes-urhrok/tome-ashes-urhrok/data/talents/corruptions/demon-seeds.lua:246` | ✅ |
| `T_DEMON_SEED_BLOOD_DRINKER` | #0 | `["*",100,["weaponDamage",0.9,2]]` | `dlc-src/ashes-urhrok/tome-ashes-urhrok/data/talents/corruptions/demon-seeds.lua:1026` | ✅ |
| `T_DEMON_SEED_CURSED_ARM` | #0 | `["*",50,["-",1,["exp",["+",["*",-0.4918259386509031,["sqrt",["talentLevel"]]],0.33762429736186633]]]]` | `dlc-src/ashes-urhrok/tome-ashes-urhrok/data/talents/corruptions/demon-seeds.lua:878` | ✅ |
| `T_DEMON_SEED_CURSED_ARM` | #1 | `["talentLevel",true]` | `dlc-src/ashes-urhrok/tome-ashes-urhrok/data/talents/corruptions/demon-seeds.lua:889` | ✅ |
| `T_DEMON_SEED_DISEASED_BODY` | #0 | `["*",100,["-",1,["exp",["+",["*",-0.695952146309044,["sqrt",["talentLevel"]]],0.570363982952362]]]]` | `dlc-src/ashes-urhrok/tome-ashes-urhrok/data/talents/corruptions/demon-seeds.lua:1223` | ✅ |
| `T_DEMON_SEED_DISEASED_BODY` | #1 | `["talentScale",5,10]` | `dlc-src/ashes-urhrok/tome-ashes-urhrok/data/talents/corruptions/demon-seeds.lua:1224` | ✅ |
| `T_DEMON_SEED_DISEASED_BODY` | #2 | `["+",5,["spellDamage",5,30]]` | `dlc-src/ashes-urhrok/tome-ashes-urhrok/data/talents/corruptions/demon-seeds.lua:1225` | ✅ |
| `T_DEMON_SEED_DISEASED_BODY` | #3 | `["spellDamage",5,28]` | `dlc-src/ashes-urhrok/tome-ashes-urhrok/data/talents/corruptions/demon-seeds.lua:1226` | ✅ |
| `T_DEMON_SEED_FIRE_BOLTS` | #0 | `["+",["*",5,["talentLevel"]],20]` | `dlc-src/ashes-urhrok/tome-ashes-urhrok/data/talents/corruptions/demon-seeds.lua:58` | ✅ |
| `T_DEMON_SEED_FIRE_BOLTS` | #1 | `["+",1,["ceil",["/",["talentLevel"],2]]]` | `dlc-src/ashes-urhrok/tome-ashes-urhrok/data/talents/corruptions/demon-seeds.lua:58` | ✅ |
| `T_DEMON_SEED_HEXED_SHIELD` | #0 | `["talentLevel",true]` | `dlc-src/ashes-urhrok/tome-ashes-urhrok/data/talents/corruptions/demon-seeds.lua:869` | ✅ |
| `T_DEMON_SEED_METEOR_SLAM` | #0 | `["*",100,["weaponDamage",1.5,2.2]]` | `dlc-src/ashes-urhrok/tome-ashes-urhrok/data/talents/corruptions/demon-seeds.lua:1064` | ✅ |
| `T_DEMON_SEED_SHADOWMELD` | #1 | `["*",50,["-",1,["exp",["+",["*",-0.4918259386509031,["sqrt",["talentLevel"]]],0.33762429736186633]]]]` | `dlc-src/ashes-urhrok/tome-ashes-urhrok/data/talents/corruptions/demon-seeds.lua:361` | ✅ |
| `T_DEMON_SEED_VOLCANIC_SKIN` | #0 | `["*",100,["-",1,["exp",["+",["*",-0.695952146309044,["sqrt",["talentLevel"]]],0.570363982952362]]]]` | `dlc-src/ashes-urhrok/tome-ashes-urhrok/data/talents/corruptions/demon-seeds.lua:1254` | ✅ |
| `T_DIMENSIONAL_ANCHOR` | #0 | `["floor",["*",["floor",["talentScale",6,10]],["pmod",["actor","paradox"]]]]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:462` | ✅ |
| `T_DISARMING_TRAP` | #0 | `["+",10,["*",30,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | `tome-src-full/data/talents/cunning/traps.lua:1013` | ✅ |
| `T_DISARMING_TRAP` | #1 | `["floor",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],2.1,1,4.43,5]]` | `tome-src-full/data/talents/cunning/traps.lua:1014` | ✅ |
| `T_DISCARDED_REFUSE` | #0 | `["floor",["+",1,["/",["*",5,["-",["sqrt",["talentLevel"]],1]],["-",["sqrt",5],1]]]]` | `tome-src-full/data/talents/spells/master-of-flesh.lua:402` | ✅ |
| `T_DRAGONSFIRE_TRAP` | #0 | `["/",["+",10,["*",18,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]],3]` | `tome-src-full/data/talents/cunning/traps.lua:1576` | ✅ |
| `T_DRAGONSFIRE_TRAP` | #1 | `["/",["+",10,["*",18,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]],2]` | `tome-src-full/data/talents/cunning/traps.lua:1576` | ✅ |
| `T_DREDGE_FRENZY` | #4 | `["*",-100,["combatLimit",["spellDamage",10,50],1,0,0,0.329,32.9]]` | `tome-src-full/data/talents/misc/npcs.lua:1672` | ✅ |
| `T_DWARVEN_HALF_EARTHEN_MISSILES` | #0 | `["+",2,["min",1,["floor",["/",["talentLevel"],5]]]]` | `tome-src-full/data/talents/gifts/dwarven-nature.lua:59` | ✅ |
| `T_EXPLOSION_TRAP` | #0 | `["+",30,["*",35,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | `tome-src-full/data/talents/cunning/traps.lua:1984` | ✅ |
| `T_FLASH_BANG_TRAP` | #0 | `["+",25,["*",25,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | `tome-src-full/data/talents/cunning/traps.lua:1193` | ✅ |
| `T_FLASH_BANG_TRAP` | #1 | `["+",1,["floor",["*",2,["sqrt",["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]]]` | `tome-src-full/data/talents/cunning/traps.lua:1192` | ✅ |
| `T_FREEZING_TRAP` | #0 | `["+",10,["*",15,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | `tome-src-full/data/talents/cunning/traps.lua:1486` | ✅ |
| `T_FREEZING_TRAP` | #1 | `["/",["+",10,["*",15,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]],3]` | `tome-src-full/data/talents/cunning/traps.lua:1486` | ✅ |
| `T_GNASHING_MAW` | #1 | `["*",3,["talentLevel"]]` | `dlc-src/orcs/tome-orcs/data/talents/misc/npcs.lua:83` | ✅ |
| `T_GRAVITIC_TRAP` | #0 | `["+",10,["*",10,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","mag",1,5]]]]` | `tome-src-full/data/talents/cunning/traps.lua:1667` | ✅ |
| `T_GRAVITIC_TRAP` | #1 | `["floor",["*",10,["-",1,["exp",["+",["*",["sqrt",["*",["actor","陷阱专精 技能等级"],["talentLevel"]]],["/",["log",["/",["-",5,10],["-",3,10]]],["-",["sqrt",6.5],["sqrt",1.3]]]],["/",["-",0,["-",["*",["-",["sqrt",6.5],["sqrt",1.3]],["log",["-",1,["/",5,10]]]],["*",["sqrt",6.5],["log",["/",["-",5,10],["-",3,10]]]]]],["-",["sqrt",1.3],["sqrt",6.5]]]]]]]]` | `tome-src-full/data/talents/cunning/traps.lua:1668` | ✅ |
| `T_INFECTIOUS_BITE` | #2 | `["spellDamage",12,150]` | `tome-src-full/data/talents/corruptions/rot.lua:30` | ✅ |
| `T_INTRICATE_TOOLS` | #0 | `["talentLevel",true]` | `tome-src-full/data/talents/cunning/artifice.lua:146` | ✅ |
| `T_INTRICATE_TOOLS` | #1 | `["+",15,["statDamage","cun",12,150]]` | `tome-src-full/data/talents/cunning/artifice.lua:620` | ✅ |
| `T_INTRICATE_TOOLS` | #2 | `["ceil",["talentScale",3,5]]` | `tome-src-full/data/talents/cunning/artifice.lua:519` | ✅ |
| `T_INTRICATE_TOOLS` | #3 | `["floor",["talentScale",1,6,"log",0,4]]` | `tome-src-full/data/talents/cunning/artifice.lua:520` | ✅ |
| `T_INTRICATE_TOOLS` | #4 | `["talentScale",4,7]` | `tome-src-full/data/talents/cunning/artifice.lua:687` | ✅ |
| `T_INTRICATE_TOOLS` | #5 | `["*",["weaponDamage",1,1.8],100]` | `tome-src-full/data/talents/cunning/artifice.lua:305` | ✅ |
| `T_INTRICATE_TOOLS` | #6 | `["+",["statScale","cun",10,200,0.7],["talentScale",20,200,0.7]]` | `tome-src-full/data/talents/cunning/artifice.lua:427` | ✅ |
| `T_INTRICATE_TOOLS` | #7 | `["+",["+",["*",["/",45,["-",["^",100,0.75],["^",10,0.75]]],["^",["actor","灵巧"],0.75]],["-",5,["*",["/",45,["-",["^",100,0.75],["^",10,0.75]]],["^",10,0.75]]]],["+",["*",["/",45,["-",["^",5,0.75],["^",1,0.75]]],["^",["talentLevel"],0.75]],["-",5,["*",["/",45,["-",["^",5,0.75],["^",1,0.75]]],["^",1,0.75]]]]]` | `tome-src-full/data/talents/cunning/artifice.lua:430` | ✅ |
| `T_INTRICATE_TOOLS` | #8 | `["floor",["talentScale",1,3,"log"]]` | `tome-src-full/data/talents/cunning/artifice.lua:432` | ✅ |
| `T_JELLY` | #0 | `["-",["floor",["combatScale",["talentLevel"],5,0,10,5]],1]` | `tome-src-full/data/talents/gifts/summon-melee.lua:219` | ✅ |
| `T_JELLY` | #1 | `["+",10,["*",["*",["power","精神强度"],1.6],["talentScale",0.2,1,0.75]]]` | `tome-src-full/data/talents/gifts/summon-melee.lua:223` | ✅ |
| `T_JELLY` | #2 | `["+",10,["talentScale",2,10,0.75]]` | `tome-src-full/data/talents/gifts/summon-melee.lua:224` | ✅ |
| `T_KINETIC_LEECH` | #0 | `["floor",["+",["*",["/",["-",4,1],["-",["^",5,0.5],["^",1,0.5]]],["^",["talentLevel"],0.5]],["-",1,["/",["-",4,1],["-",["^",5,0.5],["^",1,0.5]]]]]]` | `tome-src-full/data/talents/psionic/voracity.lua:34` | ✅ |
| `T_KINETIC_LEECH` | #1 | `["*",100,["+",0.5,["*",["-",0.16,0.5],["^",["/",["-",0.2,0.5],["-",0.16,0.5]],["/",["-",["sqrt",["*",["talentLevel"],["max",0.5,["-",1.5,["/",["actor","psi"],100]]]]],["sqrt",1.3]],["-",["sqrt",6.5],["sqrt",1.3]]]]]]]` | `tome-src-full/data/talents/psionic/voracity.lua:48` | ✅ |
| `T_KINETIC_LEECH` | #2 | `["*",100,["+",0.5,["*",["-",0.16,0.5],["^",["/",["-",0.2,0.5],["-",0.16,0.5]],["/",["-",["sqrt",["*",["talentLevel"],1.5]],["sqrt",1.3]],["-",["sqrt",6.5],["sqrt",1.3]]]]]]]` | `tome-src-full/data/talents/psionic/voracity.lua:48` | ✅ |
| `T_KINETIC_LEECH` | #3 | `["*",["mindDamage",5,45],["max",0.5,["-",1.5,["/",["actor","psi"],100]]]]` | `tome-src-full/data/talents/psionic/voracity.lua:44` | ✅ |
| `T_KINETIC_LEECH` | #4 | `["*",["mindDamage",5,45],1.5]` | `tome-src-full/data/talents/psionic/voracity.lua:44` | ✅ |
| `T_KINETIC_LEECH` | #5 | `["*",["talentScale",10,20],["max",0.5,["-",1.5,["/",["actor","psi"],100]]]]` | `tome-src-full/data/talents/psionic/voracity.lua:40` | ✅ |
| `T_KINETIC_LEECH` | #6 | `["*",["talentScale",10,20],1.5]` | `tome-src-full/data/talents/psionic/voracity.lua:40` | ✅ |
| `T_MAIM` | #0 | `["physicalDamage",10,100]` | `tome-src-full/data/talents/misc/npcs.lua:2382` | ✅ |
| `T_MASTER_ARTIFICER` | #0 | `["talentLimit",50,20,40]` | `tome-src-full/data/talents/cunning/artifice.lua:672` | ✅ |
| `T_MASTER_ARTIFICER` | #1 | `["+",30,["statDamage","cun",10,150]]` | `tome-src-full/data/talents/cunning/artifice.lua:594` | ✅ |
| `T_MASTER_ARTIFICER` | #2 | `["+",30,["statDamage","cun",15,200]]` | `tome-src-full/data/talents/cunning/artifice.lua:814` | ✅ |
| `T_MASTER_ARTIFICER` | #3 | `["+",30,["statDamage","cun",15,200]]` | `tome-src-full/data/talents/cunning/artifice.lua:814` | ✅ |
| `T_MASTER_ARTIFICER` | #4 | `["*",["weaponDamage",1.8,3],100]` | `tome-src-full/data/talents/cunning/artifice.lua:361` | ✅ |
| `T_MASTER_ARTIFICER` | #5 | `["talentScale",100,600]` | `tome-src-full/data/talents/cunning/artifice.lua:490` | ✅ |
| `T_MASTER_OF_DISASTERS` | #0 | `["floor",["+",20,["/",["*",60,["actor","灵巧"]],100]]]` | `dlc-src/orcs/tome-orcs/data/talents/uber/cun.lua:25` | ✅ |
| `T_MINOTAUR` | #0 | `["-",["floor",["combatScale",["talentLevel"],2,0,7,5]],1]` | `tome-src-full/data/talents/gifts/summon-melee.lua:339` | ✅ |
| `T_MINOTAUR` | #1 | `["+",25,["+",["*",["*",["power","精神强度"],2.1],["talentScale",0.2,1,0.75]],["talentScale",2,10,0.75]]]` | `tome-src-full/data/talents/gifts/summon-melee.lua:343` | ✅ |
| `T_MINOTAUR` | #2 | `["+",10,["talentScale",2,10,0.75]]` | `tome-src-full/data/talents/gifts/summon-melee.lua:345` | ✅ |
| `T_MINOTAUR` | #3 | `["+",10,["+",["*",["*",["power","精神强度"],1.8],["talentScale",0.2,1,0.75]],["talentScale",2,10,0.75]]]` | `tome-src-full/data/talents/gifts/summon-melee.lua:344` | ✅ |
| `T_NIGHTSHADE_TRAP` | #0 | `["+",20,["*",35,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | `tome-src-full/data/talents/cunning/traps.lua:2175` | ✅ |
| `T_NIGHTSHADE_TRAP` | #1 | `["/",["+",20,["*",35,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]],10]` | `tome-src-full/data/talents/cunning/traps.lua:2175` | ✅ |
| `T_PERFECT_CONTROL` | #0 | `["combatScale",["*",["talentLevel"],["^",["+",1,["*",8,["+",["*",0.5,["/",["power","精神强度"],100]],["*",0.5,["/",["talentLevel"],6.5]]]]],1.04]],15,0,49,34]` | `tome-src-full/data/talents/misc/npcs.lua:2533` | ✅ |
| `T_PHASE_SHIFT` | #0 | `["floor",["*",["floor",["talentLimit",25,3,7,true]],["pmod",["actor","paradox"]]]]` | `tome-src-full/data/talents/chronomancy/other.lua:645` | ✅ |
| `T_PITFALL_TRAP` | #0 | `["+",10,["*",25,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | `tome-src-full/data/talents/cunning/traps.lua:1070` | ✅ |
| `T_POISON_GAS_TRAP` | #0 | `["+",10,["*",25,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | `tome-src-full/data/talents/cunning/traps.lua:1407` | ✅ |
| `T_PURGING_TRAP` | #0 | `["+",25,["*",25,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","wil",1,5]]]]` | `tome-src-full/data/talents/cunning/traps.lua:1860` | ✅ |
| `T_PURGING_TRAP` | #1 | `["/",["+",25,["*",25,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","wil",1,5]]]],2]` | `tome-src-full/data/talents/cunning/traps.lua:1860` | ✅ |
| `T_PURGING_TRAP` | #2 | `["/",["+",25,["*",25,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","wil",1,5]]]],4]` | `tome-src-full/data/talents/cunning/traps.lua:1860` | ✅ |
| `T_PURGING_TRAP` | #3 | `["/",["+",25,["*",25,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","wil",1,5]]]],4]` | `tome-src-full/data/talents/cunning/traps.lua:1860` | ✅ |
| `T_PURGING_TRAP` | #4 | `["+",25,["*",25,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","wil",1,5]]]]` | `tome-src-full/data/talents/cunning/traps.lua:1860` | ✅ |
| `T_PURGING_TRAP` | #5 | `["floor",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],2.5,1,4.5,5]]` | `tome-src-full/data/talents/cunning/traps.lua:1859` | ✅ |
| `T_PURGING_TRAP` | #6 | `["floor",["+",1,["*",["/",["-",3,1],["log10",5]],["log10",["*",["actor","陷阱专精 技能等级"],["talentLevel"]]]]]]` | `tome-src-full/data/talents/cunning/traps.lua:1858` | ✅ |
| `T_PUTRESCENT_LIQUEFACTION` | #0 | `["max",1,["floor",["talentLimit",3.1,1,3]]]` | `tome-src-full/data/talents/spells/master-of-flesh.lua:289` | ✅ |
| `T_PUTRESCENT_LIQUEFACTION` | #2 | `["floor",["talentScale",1,2]]` | `tome-src-full/data/talents/spells/master-of-flesh.lua:290` | ✅ |
| `T_PUTRESCENT_LIQUEFACTION` | #3 | `["/",["spellDamage",40,400],5]` | `tome-src-full/data/talents/spells/master-of-flesh.lua:291` | ✅ |
| `T_QUICKEN_SPELLS` | #0 | `["*",100,["min",0.3,["max",0.05,["/",["talentLevel",true],15]]]]` | `tome-src-full/data/talents/misc/npcs.lua:3974` | ✅ |
| `T_RELAXED_SHOT` | #1 | `["+",12,["*",8,["talentLevel"]]]` | `tome-src-full/data/talents/techniques/archery.lua:735` | ✅ |
| `T_REPULSION_FIELD` | #0 | `["floor",["talentScale",1.5,3.5]]` | `tome-src-full/data/talents/chronomancy/other.lua:488` | ✅ |
| `T_REPULSION_FIELD` | #2 | `["floor",["*",["floor",["talentScale",4,8]],["pmod",["actor","paradox"]]]]` | `tome-src-full/data/talents/chronomancy/other.lua:493` | ✅ |
| `T_ROGUE_S_TOOLS` | #0 | `["talentLevel",true]` | `tome-src-full/data/talents/cunning/artifice.lua:146` | ✅ |
| `T_ROGUE_S_TOOLS` | #1 | `["+",15,["statDamage","cun",12,150]]` | `tome-src-full/data/talents/cunning/artifice.lua:620` | ✅ |
| `T_ROGUE_S_TOOLS` | #2 | `["ceil",["talentScale",3,5]]` | `tome-src-full/data/talents/cunning/artifice.lua:519` | ✅ |
| `T_ROGUE_S_TOOLS` | #3 | `["floor",["talentScale",1,6,"log",0,4]]` | `tome-src-full/data/talents/cunning/artifice.lua:520` | ✅ |
| `T_ROGUE_S_TOOLS` | #4 | `["talentScale",4,7]` | `tome-src-full/data/talents/cunning/artifice.lua:687` | ✅ |
| `T_ROGUE_S_TOOLS` | #5 | `["*",["weaponDamage",1,1.8],100]` | `tome-src-full/data/talents/cunning/artifice.lua:305` | ✅ |
| `T_ROGUE_S_TOOLS` | #6 | `["+",["statScale","cun",10,200,0.7],["talentScale",20,200,0.7]]` | `tome-src-full/data/talents/cunning/artifice.lua:427` | ✅ |
| `T_ROGUE_S_TOOLS` | #7 | `["+",["+",["*",["/",45,["-",["^",100,0.75],["^",10,0.75]]],["^",["actor","灵巧"],0.75]],["-",5,["*",["/",45,["-",["^",100,0.75],["^",10,0.75]]],["^",10,0.75]]]],["+",["*",["/",45,["-",["^",5,0.75],["^",1,0.75]]],["^",["talentLevel"],0.75]],["-",5,["*",["/",45,["-",["^",5,0.75],["^",1,0.75]]],["^",1,0.75]]]]]` | `tome-src-full/data/talents/cunning/artifice.lua:430` | ✅ |
| `T_ROGUE_S_TOOLS` | #8 | `["floor",["talentScale",1,3,"log"]]` | `tome-src-full/data/talents/cunning/artifice.lua:432` | ✅ |
| `T_ROUNDHOUSE_KICK` | #0 | `["physicalDamage",15,150]` | `tome-src-full/data/talents/misc/npcs.lua:3433` | ✅ |
| `T_SEVER_LIFELINE` | #0 | `["*",10000,["spellDamage",20,220,["power","法术强度",["pmod",["actor","paradox"]]]]]` | `tome-src-full/data/talents/misc/npcs.lua:1722` | ✅ |
| `T_SHADOW_MAGES` | #1 | `["talentLevel",true]` | `tome-src-full/data/talents/cursed/shadows.lua:550` | ✅ |
| `T_SHADOW_MAGES` | #2 | `["combatLimit",["^",["talentLevel"],0.5],100,7,1,15.65,2.23]` | `tome-src-full/data/talents/cursed/shadows.lua:536` | ✅ |
| `T_SHADOW_MAGES` | #3 | `["*",["talentLevel",true],["max",0,["min",1,["-",["floor",["talentLevel"]],2]]]]` | `tome-src-full/data/talents/cursed/shadows.lua:553` | ✅ |
| `T_SHADOW_MAGES` | #4 | `["*",["combatLimit",["^",["talentLevel"],0.5],100,7,1,15.65,2.23],["max",0,["min",1,["-",["floor",["talentLevel"]],2]]]]` | `tome-src-full/data/talents/cursed/shadows.lua:543` | ✅ |
| `T_SHADOW_WARRIORS` | #0 | `["floor",["*",23,["-",["sqrt",["talentLevel"]],0.5]]]` | `tome-src-full/data/talents/cursed/shadows.lua:482` | ✅ |
| `T_SHADOW_WARRIORS` | #1 | `["floor",["*",35,["-",["sqrt",["talentLevel"]],0.5]]]` | `tome-src-full/data/talents/cursed/shadows.lua:479` | ✅ |
| `T_SHADOW_WARRIORS` | #2 | `["talentLevel",true]` | `tome-src-full/data/talents/cursed/shadows.lua:485` | ✅ |
| `T_SHADOW_WARRIORS` | #3 | `["combatLimit",["^",["talentLevel"],0.5],100,7,1,15.65,2.23]` | `tome-src-full/data/talents/cursed/shadows.lua:491` | ✅ |
| `T_SHADOW_WARRIORS` | #4 | `["max",3,["-",8,["talentLevel",true]]]` | `tome-src-full/data/talents/cursed/shadows.lua:525` | ✅ |
| `T_SLOW` | #0 | `["floor",["talentScale",2.25,3.25]]` | `tome-src-full/data/talents/chronomancy/other.lua:144` | ✅ |
| `T_SLOW` | #1 | `["floor",["talentScale",6,10]]` | `tome-src-full/data/talents/chronomancy/other.lua:152` | ✅ |
| `T_SPACETIME_MASTERY` | #0 | `["floor",["*",10,["*",0.8,["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],["/",["log",["/",["-",0.5,0.8],["-",0.1,0.8]]],["-",["sqrt",6.5],["sqrt",1.3]]]],["/",["-",0,["-",["*",["-",["sqrt",6.5],["sqrt",1.3]],["log",["-",1,["/",0.5,0.8]]]],["*",["sqrt",6.5],["log",["/",["-",0.5,0.8],["-",0.1,0.8]]]]]],["-",["sqrt",1.3],["sqrt",6.5]]]]]]]]]` | `tome-src-full/data/talents/chronomancy/other.lua:188` | ✅ |
| `T_SPACETIME_MASTERY` | #1 | `["floor",["*",20,["*",0.8,["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],["/",["log",["/",["-",0.5,0.8],["-",0.1,0.8]]],["-",["sqrt",6.5],["sqrt",1.3]]]],["/",["-",0,["-",["*",["-",["sqrt",6.5],["sqrt",1.3]],["log",["-",1,["/",0.5,0.8]]]],["*",["sqrt",6.5],["log",["/",["-",0.5,0.8],["-",0.1,0.8]]]]]],["-",["sqrt",1.3],["sqrt",6.5]]]]]]]]]` | `tome-src-full/data/talents/chronomancy/other.lua:188` | ✅ |
| `T_SPATIAL_TETHER` | #0 | `["floor",["*",["floor",["talentScale",6,8]],["pmod",["actor","paradox"]]]]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:258` | ✅ |
| `T_SPATIAL_TETHER` | #3 | `["floor",["combatScale",["talentLevel"],1,1,2,5,0.5]]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:257` | ✅ |
| `T_SPRINGRAZOR_TRAP` | #0 | `["*",25,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]` | `tome-src-full/data/talents/cunning/traps.lua:873` | ✅ |
| `T_SPRINGRAZOR_TRAP` | #1 | `["floor",["*",3,["*",["+",1,["/",["combatScale",["*",["actor","陷阱专精 技能等级"],["talentLevel"]],25,1,100,5],100]],["statScale","cun",1,5]]]]` | `tome-src-full/data/talents/cunning/traps.lua:875` | ✅ |
| `T_STEADY_MIND` | #0 | `["statDamage","dex",5,35]` | `tome-src-full/data/talents/misc/npcs.lua:2359` | ✅ |
| `T_STEADY_MIND` | #1 | `["statDamage","cun",5,35]` | `tome-src-full/data/talents/misc/npcs.lua:2360` | ✅ |
| `T_STONE_GOLEM` | #0 | `["-",["floor",["combatScale",["talentLevel"],5,0,10,5]],1]` | `tome-src-full/data/talents/gifts/summon-melee.lua:458` | ✅ |
| `T_STONE_GOLEM` | #1 | `["+",15,["+",["*",["*",["power","精神强度"],2],["talentScale",0.2,1,0.75]],["talentScale",2,10,0.75]]]` | `tome-src-full/data/talents/gifts/summon-melee.lua:462` | ✅ |
| `T_STONE_GOLEM` | #2 | `["+",10,["talentScale",2,10,0.75]]` | `tome-src-full/data/talents/gifts/summon-melee.lua:464` | ✅ |
| `T_STONE_GOLEM` | #3 | `["+",15,["+",["*",["*",["power","精神强度"],1.9],["talentScale",0.2,1,0.75]],["talentScale",2,10,0.75]]]` | `tome-src-full/data/talents/gifts/summon-melee.lua:463` | ✅ |
| `T_SWAP` | #1 | `["min",50,["*",["talentLevel",true],10]]` | `tome-src-full/data/talents/chronomancy/other.lua:669` | ✅ |
| `T_TELEKINETIC_THROW` | #1 | `["floor",["mindDamage",10,170]]` | `tome-src-full/data/talents/misc/npcs.lua:2635` | ✅ |
| `T_TELEKINETIC_THROW` | #2 | `["/",["mindDamage",10,170],2]` | `tome-src-full/data/talents/misc/npcs.lua:2635` | ✅ |
| `T_TEMPORAL_CLONE` | #0 | `["floor",["*",["floor",["talentScale",6,12]],["pmod",["actor","paradox"]]]]` | `tome-src-full/data/talents/chronomancy/other.lua:537` | ✅ |
| `T_TEMPORAL_WAKE` | #0 | `["floor",["*",["floor",["talentScale",3,7]],["pmod",["actor","paradox"]]]]` | `tome-src-full/data/talents/chronomancy/other.lua:738` | ✅ |
| `T_TF_BOWMAN` | #0 | `["/",["^",["*",["/",["*",["+",5,["power","精神强度"]],["+",1,["*",0.8,["-",["sqrt",["talentRef","T_THOUGHT_FORMS"]],1]]]],["*",105,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],50],1.04],2]` | `tome-src-full/data/talents/psionic/thought-forms.lua:259` | ✅ |
| `T_TF_BOWMAN` | #1 | `["^",["*",["/",["*",["+",5,["power","精神强度"]],["+",1,["*",0.8,["-",["sqrt",["talentRef","T_THOUGHT_FORMS"]],1]]]],["*",105,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],50],1.04]` | `tome-src-full/data/talents/psionic/thought-forms.lua:259` | ✅ |
| `T_TF_BOWMAN` | #2 | `["/",["^",["*",["/",["*",["+",5,["power","精神强度"]],["+",1,["*",0.8,["-",["sqrt",["talentRef","T_THOUGHT_FORMS"]],1]]]],["*",105,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],50],1.04],2]` | `tome-src-full/data/talents/psionic/thought-forms.lua:259` | ✅ |
| `T_TF_DEFENDER` | #0 | `["/",["^",["*",["/",["*",["+",5,["power","精神强度"]],["+",1,["*",0.8,["-",["sqrt",["talentRef","T_THOUGHT_FORMS"]],1]]]],["*",105,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],50],1.04],2]` | `tome-src-full/data/talents/psionic/thought-forms.lua:465` | ✅ |
| `T_TF_DEFENDER` | #1 | `["/",["^",["*",["/",["*",["+",5,["power","精神强度"]],["+",1,["*",0.8,["-",["sqrt",["talentRef","T_THOUGHT_FORMS"]],1]]]],["*",105,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],50],1.04],2]` | `tome-src-full/data/talents/psionic/thought-forms.lua:465` | ✅ |
| `T_TF_DEFENDER` | #2 | `["^",["*",["/",["*",["+",5,["power","精神强度"]],["+",1,["*",0.8,["-",["sqrt",["talentRef","T_THOUGHT_FORMS"]],1]]]],["*",105,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],50],1.04]` | `tome-src-full/data/talents/psionic/thought-forms.lua:465` | ✅ |
| `T_TF_WARRIOR` | #0 | `["^",["*",["/",["*",["+",5,["power","精神强度"]],["+",1,["*",0.8,["-",["sqrt",["talentRef","T_THOUGHT_FORMS"]],1]]]],["*",105,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],50],1.04]` | `tome-src-full/data/talents/psionic/thought-forms.lua:361` | ✅ |
| `T_TF_WARRIOR` | #1 | `["/",["^",["*",["/",["*",["+",5,["power","精神强度"]],["+",1,["*",0.8,["-",["sqrt",["talentRef","T_THOUGHT_FORMS"]],1]]]],["*",105,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],50],1.04],2]` | `tome-src-full/data/talents/psionic/thought-forms.lua:361` | ✅ |
| `T_TF_WARRIOR` | #2 | `["/",["^",["*",["/",["*",["+",5,["power","精神强度"]],["+",1,["*",0.8,["-",["sqrt",["talentRef","T_THOUGHT_FORMS"]],1]]]],["*",105,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],50],1.04],2]` | `tome-src-full/data/talents/psionic/thought-forms.lua:361` | ✅ |
| `T_THERMAL_LEECH` | #0 | `["floor",["+",["*",["/",["-",4,1],["-",["^",5,0.5],["^",1,0.5]]],["^",["talentLevel"],0.5]],["-",1,["/",["-",4,1],["-",["^",5,0.5],["^",1,0.5]]]]]]` | `tome-src-full/data/talents/psionic/voracity.lua:100` | ✅ |
| `T_THERMAL_LEECH` | #1 | `["ceil",["combatScale",["*",["talentLevel"],["max",0.5,["-",1.5,["/",["actor","psi"],100]]]],1.3,1,3.2,5,0.5]]` | `tome-src-full/data/talents/psionic/voracity.lua:114` | ✅ |
| `T_THERMAL_LEECH` | #2 | `["ceil",["combatScale",["*",["talentLevel"],1.5],1.3,1,3.2,5,0.5]]` | `tome-src-full/data/talents/psionic/voracity.lua:114` | ✅ |
| `T_THERMAL_LEECH` | #3 | `["*",["mindDamage",20,130],["max",0.5,["-",1.5,["/",["actor","psi"],100]]]]` | `tome-src-full/data/talents/psionic/voracity.lua:110` | ✅ |
| `T_THERMAL_LEECH` | #4 | `["*",["mindDamage",20,130],1.5]` | `tome-src-full/data/talents/psionic/voracity.lua:110` | ✅ |
| `T_THERMAL_LEECH` | #5 | `["*",["talentScale",10,20],["max",0.5,["-",1.5,["/",["actor","psi"],100]]]]` | `tome-src-full/data/talents/psionic/voracity.lua:106` | ✅ |
| `T_THERMAL_LEECH` | #6 | `["*",["talentScale",10,20],1.5]` | `tome-src-full/data/talents/psionic/voracity.lua:106` | ✅ |
| `T_THROW_PEEBLE` | #0 | `["combatScale",["*",["actor","力量"],["talentLevel"]],12,0,262,500]` | `dlc-src/cults/tome-cults/data/talents/misc/misc.lua:319` | ✅ |
| `T_TRICKY_DEFENSES` | #0 | `["*",100,["statScale","cun",0.1,0.5]]` | `tome-src-full/data/talents/uber/cun.lua:77` | ✅ |
| `T_VENOMOUS_AMMUNITION` | #0 | `["/",["^",["*",["/",["*",["+",20,["power","physical power"]],["+",1,["*",0.8,["-",["sqrt",["talentRef","T_EXOTIC_MUNITIONS"]],1]]]],["*",120,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],180],1.04],5]` | `tome-src-full/data/talents/techniques/munitions.lua:219` | ✅ |
| `T_VENOMOUS_THROW` | #0 | `["*",["*",["+",50,["actor","灵巧"]],["*",["+",1,["*",0.8,["-",["sqrt",["talentRef","T_VENOMOUS_STRIKE"]],1]]],["/",550,["*",150,["+",1,["*",0.8,["-",["sqrt",5],1]]]]]]],["-",1,["/",["log10",["*",2,["*",["+",50,["actor","灵巧"]],["*",["+",1,["*",0.8,["-",["sqrt",["talentRef","T_VENOMOUS_STRIKE"]],1]]],["/",550,["*",150,["+",1,["*",0.8,["-",["sqrt",5],1]]]]]]]]],7]]]` | `tome-src-full/data/talents/cunning/poisons.lua:301` | ✅ |
| `T_VENOMOUS_THROW` | #1 | `["*",["*",["+",50,["actor","灵巧"]],["*",["+",1,["*",0.8,["-",["sqrt",["talentRef","T_VENOMOUS_STRIKE"]],1]]],["/",550,["*",150,["+",1,["*",0.8,["-",["sqrt",5],1]]]]]]],["-",1,["/",["log10",["*",2,["*",["+",50,["actor","灵巧"]],["*",["+",1,["*",0.8,["-",["sqrt",["talentRef","T_VENOMOUS_STRIKE"]],1]]],["/",550,["*",150,["+",1,["*",0.8,["-",["sqrt",5],1]]]]]]]]],7]]]` | `tome-src-full/data/talents/cunning/poisons.lua:301` | ✅ |
| `T_VENOMOUS_THROW` | #2 | `["*",0.6,["*",["*",["+",50,["actor","灵巧"]],["*",["+",1,["*",0.8,["-",["sqrt",["talentRef","T_VENOMOUS_STRIKE"]],1]]],["/",550,["*",150,["+",1,["*",0.8,["-",["sqrt",5],1]]]]]]],["-",1,["/",["log10",["*",2,["*",["+",50,["actor","灵巧"]],["*",["+",1,["*",0.8,["-",["sqrt",["talentRef","T_VENOMOUS_STRIKE"]],1]]],["/",550,["*",150,["+",1,["*",0.8,["-",["sqrt",5],1]]]]]]]]],7]]]]` | `tome-src-full/data/talents/cunning/poisons.lua:324` | ✅ |
| `T_VOID_BLAST` | #0 | `["spellDamage",15,240]` | `tome-src-full/data/talents/misc/npcs.lua:747` | ✅ |
| `T_VOLCANIC_ROCK` | #1 | `["talentLimit",100,6.6,13]` | `tome-src-full/data/talents/spells/deeprock.lua:71` | ✅ |
| `T_VOLCANIC_ROCK` | #2 | `["*",2,["talentLevel",true]]` | `tome-src-full/data/talents/spells/deeprock.lua:76` | ✅ |
| `T_VOLCANIC_ROCK` | #3 | `["floor",["combatScale",["*",2,["talentLevel",true]],5,1,9,5,0.5]]` | `tome-src-full/data/talents/misc/npcs.lua:1550` | ✅ |
| `T_VOLCANIC_ROCK` | #4 | `["floor",["+",1,["*",["/",4,["log10",5]],["log10",["*",2,["talentLevel",true]]]]]]` | `tome-src-full/data/talents/misc/npcs.lua:1551` | ✅ |
| `T_VOLCANIC_ROCK` | #5 | `["/",["^",["*",["/",["*",["+",15,["power","法术强度"]],["+",1,["*",0.8,["-",["sqrt",["*",2,["talentLevel",true]]],1]]]],["*",115,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],80],1.04],2]` | `tome-src-full/data/talents/misc/npcs.lua:1552` | ✅ |
| `T_VOLCANIC_ROCK` | #6 | `["/",["^",["*",["/",["*",["+",15,["power","法术强度"]],["+",1,["*",0.8,["-",["sqrt",["*",2,["talentLevel",true]]],1]]]],["*",115,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],80],1.04],2]` | `tome-src-full/data/talents/misc/npcs.lua:1552` | ✅ |
| `T_WAR_HOUND` | #0 | `["-",["floor",["combatScale",["talentLevel"],5,0,10,5]],1]` | `tome-src-full/data/talents/gifts/summon-melee.lua:110` | ✅ |
| `T_WAR_HOUND` | #1 | `["+",15,["+",["*",["*",["power","精神强度"],2],["talentScale",0.2,1,0.75]],["talentScale",2,10,0.75]]]` | `tome-src-full/data/talents/gifts/summon-melee.lua:114` | ✅ |
| `T_WAR_HOUND` | #2 | `["+",15,["+",["*",["power","精神强度"],["talentScale",0.2,1,0.75]],["talentScale",2,10,0.75]]]` | `tome-src-full/data/talents/gifts/summon-melee.lua:115` | ✅ |
| `T_WARP_MINE_AWAY` | #0 | `["/",["^",["*",["*",["+",20,["*",["power","法术强度"],["pmod",["actor","paradox"]]]],["+",1,["*",0.8,["-",["sqrt",["*",["actor","时空地雷 技能等级"],["talentLevel"]]],1]]]],["/",200,["*",["+",20,100],["+",1,["*",0.8,["-",["sqrt",5],1]]]]]],1.04],2]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:215` | ✅ |
| `T_WARP_MINE_AWAY` | #1 | `["/",["^",["*",["*",["+",20,["*",["power","法术强度"],["pmod",["actor","paradox"]]]],["+",1,["*",0.8,["-",["sqrt",["*",["actor","时空地雷 技能等级"],["talentLevel"]]],1]]]],["/",200,["*",["+",20,100],["+",1,["*",0.8,["-",["sqrt",5],1]]]]]],1.04],2]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:215` | ✅ |
| `T_WARP_MINE_AWAY` | #2 | `["*",["max",1,["combatScale",["*",["*",["actor","时空地雷 技能等级"],["talentLevel"]],["*",["actor","魔力"],0.15]],0,0,75,75]],0.8]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:217` | ✅ |
| `T_WARP_MINE_AWAY` | #3 | `["max",1,["combatScale",["*",["*",["actor","时空地雷 技能等级"],["talentLevel"]],["*",["actor","魔力"],0.15]],0,0,75,75]]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:217` | ✅ |
| `T_WARP_MINE_AWAY` | #4 | `["floor",["*",["floor",["combatScale",["*",["actor","时空地雷 技能等级"],["talentLevel"]],6,1,10,5,0.5]],["pmod",["actor","paradox"]]]]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:216` | ✅ |
| `T_WARP_MINE_TOWARD` | #0 | `["/",["^",["*",["*",["+",20,["*",["power","法术强度"],["pmod",["actor","paradox"]]]],["+",1,["*",0.8,["-",["sqrt",["*",["actor","时空地雷 技能等级"],["talentLevel"]]],1]]]],["/",200,["*",["+",20,100],["+",1,["*",0.8,["-",["sqrt",5],1]]]]]],1.04],2]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:215` | ✅ |
| `T_WARP_MINE_TOWARD` | #1 | `["/",["^",["*",["*",["+",20,["*",["power","法术强度"],["pmod",["actor","paradox"]]]],["+",1,["*",0.8,["-",["sqrt",["*",["actor","时空地雷 技能等级"],["talentLevel"]]],1]]]],["/",200,["*",["+",20,100],["+",1,["*",0.8,["-",["sqrt",5],1]]]]]],1.04],2]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:215` | ✅ |
| `T_WARP_MINE_TOWARD` | #2 | `["*",["max",1,["combatScale",["*",["*",["actor","时空地雷 技能等级"],["talentLevel"]],["*",["actor","魔力"],0.15]],0,0,75,75]],0.8]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:217` | ✅ |
| `T_WARP_MINE_TOWARD` | #3 | `["max",1,["combatScale",["*",["*",["actor","时空地雷 技能等级"],["talentLevel"]],["*",["actor","魔力"],0.15]],0,0,75,75]]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:217` | ✅ |
| `T_WARP_MINE_TOWARD` | #4 | `["floor",["*",["floor",["combatScale",["*",["actor","时空地雷 技能等级"],["talentLevel"]],6,1,10,5,0.5]],["pmod",["actor","paradox"]]]]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:216` | ✅ |
| `T_WARP_MINES` | #0 | `["/",["spellDamage",20,200,["*",["power","法术强度"],["pmod",["actor","paradox"]]]],2]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:215` | ✅ |
| `T_WARP_MINES` | #1 | `["/",["spellDamage",20,200,["*",["power","法术强度"],["pmod",["actor","paradox"]]]],2]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:215` | ✅ |
| `T_WARP_MINES` | #2 | `["floor",["*",["max",1,["combatScale",["*",["talentLevel"],["*",["actor","魔力"],0.15]],0,0,75,75]],0.8]]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:217` | ✅ |
| `T_WARP_MINES` | #3 | `["max",1,["combatScale",["*",["talentLevel"],["*",["actor","魔力"],0.15]],0,0,75,75]]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:217` | ✅ |
| `T_WARP_MINES` | #4 | `["floor",["*",["floor",["talentScale",6,10]],["pmod",["actor","paradox"]]]]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:216` | ✅ |
| `T_WARP_MINES` | #5 | `["floor",["combatScale",["talentLevel"],5,1,9,5,0.5,0,1]]` | `tome-src-full/data/talents/chronomancy/spacetime-folding.lua:214` | ✅ |
| `T_WATER_BOLT` | #0 | `["combatScale",["*",["power","法术强度"],["talentLevel"]],12,0,78.25,265,0.67]` | `tome-src-full/data/talents/misc/npcs.lua:568` | ✅ |

---

## 三、发现的写法模式（建议提升为解析器规则）

1. **原始等级 vs 有效等级**：三套导出数字**完全相同**的值，几乎一定按 `getTalentLevelRaw` 计算 → 写 `["talentLevel",true]`；
   写 `["talentLevel"]`（= 原始 × 系数）会在 1.30/1.50 两套上崩。代表：`T_QUICKEN_SPELLS#0`、`T_HEXED_SHIELD#0`、`T_VOLCANIC_ROCK#2`。
2. **「任意等级驱动」的等价展开**（节点表无 level 参数，但可表达）：
   - `combatTalentScale(t,low,high,power)` @L ⟺ `["combatScale",L,low,1,high,5,power]`
   - `combatTalentScale(t,low,high,"log")` @L ⟺ `["+",low,["*",["/",["-",high,low],["log10",5]],["log10",L]]]`
   - `combatTalentXXXDamage(t,base,max)` @L、强度 P ⟺ `["^",["*",["/",["*",["+",base,P],["+",1,["*",0.8,["-",["sqrt",L],1]]]],["*",["+",base,100],["+",1,["*",0.8,["-",["sqrt",5],1]]]]],max],1.04]`
   最常用形式是 `L = ["*",2,["talentLevel",true]]`（嵌套说明按 2 倍原始等级渲染）。
3. **嵌套整段技能说明**：`info` 里 `self:getTalentFullDescription(tv, <等级>)` 会把**别的技能**（可能是 NPC 技能，
   如 `misc/npcs.lua` 的 `T_VOLCANO`/`T_THROW_BOULDER`）的完整说明嵌入；导出最前面那个 acronym 就是「有效技能等级」本身。
   代表：`T_VOLCANIC_ROCK` #2–#6、`T_BOULDER_ROCK` #2/#4。
4. **时空系三件套**：`getParadoxSpellpower` = `["*",["power","法术强度"],["pmod",["actor","paradox"]]]`；
   `getExtensionModifier(self,t,v)` = `["floor",["*",v,["pmod",["actor","paradox"]]]]`（**paradox 唯一被真正消费的地方**）；
   anomaly 家族全是 `combatScale`/`combatLimit` + `rng.avg` 期望（`getAnomalyRadius/Range/Duration/EffectPower/Damage`）。
5. **陷阱/工匠系的「槽技能驱动」**：`short_info(self,t,slot_talent)` 的第三个参数才是驱动等级，用**槽技能**的 `["talentLevel"]`；
   `pairs()` 让导出 acronym 顺序是哈希序，**不能按源码声明顺序对号**。代表：`cunning/artifice` 三个工具槽 #1–#8 逐字相同。
6. **一对多节点映射**（机械可规则化）：`combatTalentScale→talentScale`、`combatTalentWeaponDamage→weaponDamage`（`%d%%` 时 ×100）、
   `combatStatScale+combatTalentScale→statScale+talentScale`、`N+combatTalentStatDamage→["+",N,["statDamage","cun",b,m]]`、
   `combatTalentLimit/100*100→talentLimit`。
7. **召唤系**：`summonTime = ["-",["floor",["combatScale",["talentLevel"],low,0,high,5]],1]`；属性 = `base + 精神强度*k*S + T`，
   `S=combatTalentScale(t,0.2,1,0.75)`、`T=combatTalentScale(t,2,10,0.75)`；`incStats(...,true)` 旁路 `mindCrit`。
8. **灵能/吞噬系的百分数写法**：因子 `F = max(0.5, 1.5 − psi/getMaxPsi())`，标题把 `psi` 写成**百分数**，
   故 `psi/getMaxPsi() = psi/100` → `["max",0.5,["-",1.5,["/",["actor","psi"],100]]]`，**不需要 maxPsi**。
9. **被转发到别的技能时用 `talentRef`**：`getStatBonus` 转发给 `T_THOUGHT_FORMS`（导出里等级 0）→ 用 `["talentRef","T_THOUGHT_FORMS"]`
   代入展开式；写 `["mindDamage",…]`（默认等级 1）全错。`callTalent(T_X,"getY")` 同理。
10. **常用守卫与等价改写**：`["max",1,…]`、`["min",4,…]` 照抄；无比较运算时用 `floor` 等价（`等级≥5 时 +1` ⟺ `["min",1,["floor",["/",["talentLevel"],5]]]`）；
    `t:_getX(self)` **不改变等级口径**；`getCun(n,true)` = `属性 × n / 100`；`rng.avg(a,b,n)` → 期望 `(a+b)/2`；
    求值器的 `["*",a,b,c]` **只吃二元**，必须嵌套 `["*",["*",a,b],c]`。

---

## 四、无法建模 / 仍不通（这 15 个大系内剩 23 条）

全部已定位到具体工具或导出缺陷，**没有一条是「读不懂公式」**：

| 成因 | 条数 | 目标 | 说明 |
| --- | --- | --- | --- |
| **多轴 ladder**：title 同时给两条 5 值阶梯，`ladderAxis()` 要求唯一可变轴 → 返回 `null`，**任何表达式都不试算** | 18 | `uber/cunning` `T_ENDLESS_WOES` #0–#8、`T_ELEMENTAL_SURGE` #0–#3；`chronomancy/other` `T_SPACETIME_TUNING` #0–#2；`technique/other` `T_DEFENSIVE_THROW#3`；`psionic/other` `T_TELEKINETIC_THROW#0` | 源码公式都已在各分树报告里给出，并按**对角线联合点**复算与导出逐点一致（如 `T_TELEKINETIC_THROW#0` 沿 `str==精神强度` 得 1/3/5/7/10 ✓）。缺的是工具的「多轴对角线」支持 |
| **导出 acronym 解析缺陷**：多段并列文本被并成一个 acronym，`displayed` 长 10 ≠ 阶梯 5 | 1 | `spell/other` `T_MARTYRDOM#0` | 源码 `["combatLimit",["sqrt",["talentLevel"]],100,15,1,40,2.24]` 手工核对与导出真实阶梯 15/24/31/36/39、18/29/35/40/44、20/31/38/43/47 完全一致 |
| **安全半边仍在**：公式读的输入标题没声明（`精准` 被导出标成 `kind:other`，`declaredInputs` 不认） | 1 | `technique/other` `T_CRIPPLING_SHOT#1` | 正确表达式数值 15/15 全中；按规则未写死 100，改记疑点。修 `isDeclaredInput` 的认类即可收 |
| **导出自身不自洽**：同一 `tformat` 的两条值对 boost 的可行区间交集为空 | 1 | `psionic/other` `T_PERFECT_CONTROL#1` | `#0` 需 boost∈[50,51)/[58,59)，`#1` 需 [51,53)/[59,61) → ∅ |
| **单点差 1，仍未定位** | 2 | `cunning/traps` `T_CATAPULT_TRAP#1`；`technique/other` `T_VENOMOUS_AMMUNITION#1` | 前者 15 点中 1 点差 1；后者同一 acronym 内精度自相矛盾（`4.81, 7.33` 与 `12, 16, 20`），新读数规则下复核仍未通过 |

**另有 63 条（4.9%）源码缺失**：导出包含仓库未提供的 addon（`source_code` 指向 `data-possessors/...` 等），
如 `psionic/psychic-blows` 12、`psionic/battle-psionics` 12、`psionic/deep-horror` 10 等——这类应直接跳过。

---

## 五、给主项目的建议（按收益排序）

1. **接入构建**（上一轮遗留的 ①）：`build-data.mjs` 读 `data/lua-expressions.json`，按 `(talent, acronymIndex)` 用覆盖层表达式
   走 `matchLuaFormula` 的同一套校验，过不了的丢弃并在构建日志报告。这样 267 条真正进入网站产物。
   ⚠️ 注意 `matchLuaFormula` 的「唯一候选」判定（`matches.size !== 1` → `ambiguous formula`）需单独处理：
   若覆盖层表达式与自动候选同时命中会被判歧义，应在有覆盖层条目时只放该条候选。
2. **加「多轴对角线」支持**（`ladderAxis`）：一条 title 有多条 5 值阶梯时，沿导出给定的联合点同点代入。
   可一次性解锁 **18 条**（本轮剩余的最大一块）。注意 `combatStatScale` 默认 `power=0.5`（sqrt 变换），按线性内插会全错。
3. **修 `isDeclaredInput` 的认类**：`kind: other`（如 `精准`）也算已声明；可解锁 `T_CRIPPLING_SHOT#1` 一类。
4. **修 acronym 切分**：并列多段文本被并成一个 acronym 导致 `displayed` 长度与阶梯不符；`T_MARTYRDOM#0` 即此类。
5. **继续分批**：按「声明 0–1 个输入」优先（628 条声明 0 输入、452 条声明 1 输入，合计 84%），跳过大系里的 63 条 addon 目标。
   闸门与读数两处修好后，后续大系的期望通过率应高于本轮的 92%（本轮大部分工作是在旧工具下做的）。

---

## 附：可复现步骤

```sh
cd modern_tome_viewer

node scripts/try-formula.mjs --list --tree <tree>                       # 1) 取目标清单
node scripts/try-formula.mjs --talent <ID> --arg <N> --expr '<JSON>'    # 2) 单条试算，迭代到 PASS
node scripts/try-formula.mjs --overlay data/overlay-batches/<slug>.json # 3) 校验某大系批次

# 4) 合并全部批次（按 talent#acronym 去重）+ 用判分器自身输出反复剔不合格条目
node scripts/try-formula.mjs --overlay data/lua-expressions.json        # 期望：267/267 通过
```
