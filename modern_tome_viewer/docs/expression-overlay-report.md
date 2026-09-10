# 表达式覆盖层总报告

> 目标：把自动提取失败的技能数值，通过**读游戏 Lua 源码手写表达式**补上，并用仓库自带判分器证明正确。
> 全部命令：`cd modern_tome_viewer && node scripts/try-formula.mjs --overlay data/lua-expressions.json`

## 0. 结论摘要

| 项 | 数值 |
| --- | --- |
| 交付覆盖层条目 | **1053** 条，涉及 **253** 个大系 |
| 覆盖层验收 | `覆盖层校验：1053/1053 通过`（每条：三套导出系数 1.00/1.30/1.50 共 15 点全中 ＋ 表达式读到的输入都被标题声明过 ＋ 整条阶梯只用一种整数约定）|
| 构建端复验 | `overlay 1053/1053 accepted (re-validated against 3 renderings)` |
| **全库有源码公式** | 2469 → 3618 → **3650 / 3750 = 97.3%**（另有 71 条拟合估算、29 条仅导出参考）|
| 回归 | typecheck OK · scaling **45/45** · verify **77/77** · smoke **42/42** · e2e **160/160** |
| 派发命中率 | 上一轮派发 786 条可攻目标，拿下 **768 = 97.7%**；本轮多轴专项 34 条拿下 **33** |
| 滑条完整性审计 | 扫出 101 条「声明了却没读到」，逐条回源码核对后修好 **24 条**（含 22 条漏 `pmod`、2 条写死常数）；余 93 条确认是导出过度声明 |

**交付物**

1. `modern_tome_viewer/data/lua-expressions.json` —— 覆盖层（1053 条：`talent` / `acronym` / `expr` / `source` / `note`）
2. `modern_tome_viewer/docs/expression-overlay-report.md` —— 本报告
3. `modern_tome_viewer/data/overlay-batches/*.json` —— 39 个批次（可单独重跑，审计留痕）
4. `modern_tome_viewer/docs/overlay-reports/*.md` —— 34 份分批复述（含逐条表达式与疑点）

---

## 一、本轮修掉的两处判分器缺陷（覆盖率跃升的真正原因）

两处都不是「公式写不出来」，而是**工具把正确的公式判成了错**。

### 缺陷 1：输入集合用的是「等号」

- **位置**：`scripts/lua-scaling.mjs`（`matchLuaFormula`）、`scripts/try-formula.mjs`
- **现象**：闸门原先要求 `表达式消耗 == 标题声明`。但导出会把整个 tooltip 的参数并集抄进多个 acronym 的 title，
  于是一条**根本不读 paradox** 的 range 也带着 `paradox 300`，公式正确却被判 FAIL。
- **证据**：`chronomancy` 全学派自动匹配率只有 **119/279 = 42.7%**（全库 65.8%）。
- **修法**：改为**覆盖**判定 `表达式消耗 ⊆ 标题声明`，工具区分三态：
  `✅ 完全一致` / `✅ 覆盖（标题是超集，本值未用到：X）` / `❌ 表达式读了标题未声明的输入 [X]`。
- **保留的那半边**：读了标题没声明的输入仍然 FAIL——那种输入没有滑条，数字会静默依赖没人能设的状态。
  处理办法是换成等价写法、或按导出基准**冻结成常数**并在 `note` 说明。

### 缺陷 2：显示读数按「整条阶梯最大小数位」统一比对

- **位置**：`scripts/lua-scaling.mjs`（`matchesDisplayed` / `integerRounding`）、`src/lib/scaling-core.js`（`formatAcronymValue`）
- **现象**：acronym 的精度被取成「整条阶梯里最多的小数位」，然后要求**每个点**都按该精度精确匹配。但导出的真实渲染是：
  ① 按技能自己的格式符（`%d` / `%0.1f` / `%0.2f` …）渲染；② **数值 ≥ 10 时只打印整数部分**（全库 6557 个 ≥10 的显示值里**没有**带小数点的）；
  ③ 所以同一条阶梯会混着 `3.33` 与 `10`，而某个整数点可能是「先按格式符归整、再取整」的产物（`%0.1f` 的 46.4835 → `"46.5"` → 47）。
- **修法**：判定与渲染共认四种整数读数 `trunc` / `round` / `round1` / `round2`，由**该阶梯自己的证据**选定一种、
  且必须能复现整条阶梯；小数点仍按该点自己的小数位精确比对。`formatAcronymValue` 同步按同一读数渲染。
- **护栏**：改动一度让不变量测试 `every source value re-renders its own ladder exactly as exported` 失败
  （暴露 `T_NEBULA_SPEAR`/`T_CELESTIAL_ACCELERATION` 能被判过但渲染不出来）。正是它逼出了「读数由阶梯证据选定、
  判分器与渲染器共用」的正确设计，而不是单纯放松判分器。

### 方法论：不接受「复刻显示规则」的包装

有代理为过关，在纯源码公式外套了一层复刻渲染的壳（`["min",1,["floor",["/",v,10]]]` 当选择子）。**明确否决**：
它固化的是静态导出的渲染伪影，滑条一动就错。这类条目已全部换回纯源码公式，禁令写进 `docs/expression-overlay.md`。

### 连带收益

这两处缺陷同时也是**自动匹配**的瓶颈：重跑全库后自动匹配 2469 → **2611**（+142），再加上覆盖层，
`manifest.scaling.source` 最终到 **3618 / 3750 = 96.5%**。

### ⚠ 放宽闸门的盲点：悄悄丢掉的滑条（已审计）

「覆盖」判定（`消耗 ⊆ 声明`）放行了一类**危险的形状**：公式声明了一个输入却**不读**它。
多数情况这是导出把整份 tooltip 的参数并集抄进了每个 acronym 的 title（无害），但**如果源码真的用到它，滑条就失效了**——
而 15 点校验**看不出来**，因为导出把非轴输入钉在固定值上。

实例（用户在网页上撞见）：`T_TEMPORAL_REPRIEVE`（时空避难所）
- 源码 `getDuration = getExtensionModifier(self,t,floor(combatTalentScale(t,2,6)))`，helper 里 `value = math.floor(value * pm)`
- 错误公式 `["max",1,["floor",["combatScale",["talentLevel"],2,1,6,5]]]`，note 还写着「pm=1」
- **`pmod(300) = 1.000`**（导出钉住值）→ 乘与不乘 pmod 在 15 个点上逐位相同，闸门无从分辨
- 后果：paradox 300 → 675 时持续时间本该 2/6 → **3/9**（长 50%），错误公式下纹丝不动

**已做的处置**：

1. 对全部 1035 条扫出「声明 ⊋ 消耗」的 **101 条**；
2. 派两个 agent 逐条回源码核对 getter，判出 **24 条真漏读**并修复：
   - **22 条 `getExtensionModifier` 漏读 `paradox`**（`T_TEMPORAL_REPRIEVE`、`T_STOP#2`、`T_PHASE_PULSE#2`、`T_TIME_STOP#0`、
     `T_WORMHOLE#1`、`T_PRECOGNITION#1`、`T_SEE_THE_THREADS#0`、`T_STATIC_HISTORY#0`、`T_TEMPORAL_FUGUE#0`、
     `T_TEMPORAL_VIGOUR#0`、`T_TIME_DILATION#1`、`T_TIME_SKIP#1`、`T_TWIST_FATE#0`、`T_WARP_BLADE#1`、`T_BRAID_LIFELINES#0`、
     `T_BREACH#1`、`T_CELERITY#1`、`T_CHRONO_TIME_SHIELD#1`、`T_ENTROPY#0`、`T_GRAVITY_WELL#0`、`T_INVIGORATE#0`）
   - **2 条 `getCun(15,true)` 被写死成常数 15**（`T_PIERCING_SIGHT#0/#1`、`T_AMBUSCADE#3`）——只在灵巧=100 时成立，
     灵巧滑条一动就错；其中 `T_AMBUSCADE#3` 的原 note 还断言「写成 `["actor","灵巧"]` 会让 15 点全错」，实测是**误判**
3. 其余 **77 条**确认是导出过度声明（如 pure 等级阶梯的 range 被抄上 paradox、`psi` 显式传 0 使因子恒 1.5、
   两个标签互为整份 tooltip 并集），公式正确，保持原样；
4. **加结构性防护**：`try-formula --overlay` 与 `build-data` 现在都会报出这类条目数
   （`其中 N 条是「标题声明 ⊋ 表达式消耗」…` / `manifest.overlay.superset`），并指向审计报告——避免它再次悄悄长出来。

审计逐条结论见 `docs/overlay-reports/audit-superset-A.md`、`audit-superset-B.md`（各 50 条，未能判定 0 条）。

**教训**：数值复现（15 点）与"滑条正确"是两件事。导出把非轴输入钉死时，前者**无法**证明后者；
这类条目必须回源码确认，或至少被显式计数以便复核。

---

## 一之二、多轴阶梯：第三、四处判分器缺陷

**症状**：`manifest.scaling.reasons` 里 `unsupported input dimensions: 34` —— 34 个值有源码可读，却
连候选都进不了筛选，因为 `ladderAxis()` 要求「除轴以外每个输入都必须是单一值」，而这些标题带着
**2–6 条阶梯**。典型的两个：

| 技能 | 标题里的阶梯 | 导出阶梯 |
| --- | --- | --- |
| 无尽追踪 `T_RELENTLESS_PURSUIT` | `physical save` / `spell save` / `mental save` 各 `10,25,50,75,100` | `2,5,10,15,20` |
| 飞刀投掷 `T_THROWING_KNIVES` | `力量`/`敏捷`/`灵巧`/`幸运`/`精准`/`physical power` 各 `10,25,50,75,100` | `4,11,23,34,45` |

### 缺陷 3：把"同一条阶梯的多个名字"当成了第二个维度

ToME 的 tooltip 渲染器会把**整个 `info` 函数**碰到的参数并集抄进**每一个** acronym 的 title：
无尽追踪的 `info` 用 `for e_type, fn in pairs(self.save_for_effects)` 调了 `getReduction` 三次
（魔法/物理/精神各一次），于是**每一行**的标题都背上了三条豁免阶梯。

更关键的是渲染语义：**引擎一列一列地推进所有带阶梯的参数**，不是"变一个、其余钉在首值"。
本轮 14 条自动新解的公式**直接证明了这一点**——它们读的就是多个同阶梯参数：

| 技能 | 自动解出的公式 | 为什么能证明 |
| --- | --- | --- |
| 匕首格挡 `T_DAGGER_BLOCK#0` | `120 + 灵巧 + 敏捷` | 导出 `140,170,220,270,320`；若"只变一个、另一个钉在 10"，第 2 点会是 `155` 而不是 `170` |
| 战斗意志 `T_WILLFUL_COMBAT#1` | `statScale("wil") + statScale("cun")` | 同阶梯两路相加，只有一起推进才单调整条阶梯 |
| 咬一口 `T_TAKE_A_BITE#0` | `max(str, dex, mag) / 100 * 100` | 三条同时推进，`max` 才等于阶梯值 |
| 落星 `T_METEORIC_CRASH#0` | `max(法术强度, 精神强度)` 分两路 | 同上 |
| 虚幻形态 `T_ETHEREAL_FORM#0` | `max(魔力, 敏捷) * 0.7` | 同上 |
| 森林的恩赐 `T_THALOREN_WRATH#0` | `6 + max(意志, 体质) * 0.6` | 同上 |

**修法**（`scaling-core.js`）：新增 `axisSiblings()`——**逐元素完全相同**的阶梯才算同一个维度。
`simAtAxis()` 让它们随轴一起推进；`ladderAxis()` 只对"真的不一样"的第二条阶梯继续返回 null
（例如 `魔力 10,25,50,75,100` 配 `角色等级 1,10,25,40,50`，那是真正的联合轴，本轮不动）。
这条放宽是**保守**的：它只对原本一律返回 null 的场景生效，不可能让任何既有匹配失效
（重建后实测：失去 0 条、新增 14 条）。

### 缺陷 4：`isDeclaredInput` 不认 `kind: "other"`

标题解析器把认不出类别的标签放进 `kind: "other"`（`physical save`、`精准`、`shield block 200`），
而这些标签**恰恰是公式真读的输入**。于是 `["actor","spell save"]` 会被判成"读了标题未声明的输入"。
现在 `other` 与 `power`/`stat` 一视同仁算已声明。

### 缺陷 5：一条阶梯可以「这点截断、那点四舍五入」

`matchesDisplayed()` 是**逐点**判的：整数点只要 `%d` 或 `%.0f` 任一读法对上就算过。
可是一次 `tformat` 调用把整条阶梯**用同一个格式符**打印出来，五点不可能混用两种约定。
于是「第 2 点只能四舍五入、第 5 点只能截断」的公式会被误判为匹配。

抓到它的过程：一个子代理提交了心灵震爆 `T_MIND_BLAST#2` 的
`min(10, combatScale(tl + 0.05×法术强度, 2, 0, 12, 10))`，`try-formula` 报 PASS；逐点看输出才发现
1.5 那一套是**截断、四舍五入、截断、截断、四舍五入**混着凑出来的。

修法：新增 `readingIsConsistent()`，要求整条阶梯的整数点能被**同一个**约定读完；
`matchLuaFormula()` 与 `checkHandExpression()` 都接上。两个细节：

- 约定集合是 6 种（`trunc` / `round` × 不做前置 / `%0.1f` / `%0.2f`），因为导出会在
  talent 自己的格式符之后再取一次整数部分；
- **落在整数上的点不参与判定**：`-8.9999999999999982` 与打印值 `-9` 只差 2e-15，
  该由哪种约定读它没有信息量，不能让浮点最后一位决定（混沌之球 `T_CHAOS_ORBS#1` 就栽在这上面，
  加了这个豁免后正确恢复）。

收紧后全库只有 **2 条**会掉（3481 条整数阶梯里 3479 条本来就只用一种约定），代价可忽略：

| 被拒的条目 | 预测 vs 导出 | 结论 |
| --- | --- | --- |
| 驾驶机械蜘蛛 `T_MECHARACHNID_PILOTING#2` | `6.78,15.82,21.87,26.44,30.10` → `6,15,22,26,30` | 第 3 点必须四舍五入、其余必须截断 —— 原先的拟合只是钻了闸门的空子，正确剔除 |
| 心灵震爆 `T_MIND_BLAST#2` | 见下 | 源码公式本身就复现不了，见 §2.5 |

### 战果

| 指标 | 放宽前 | 放宽 + 收紧后 |
| --- | --- | --- |
| `unsupported input dimensions` | 34 | **9**（剩下的都是"两条阶梯真的不同"的联合轴）|
| `Info control flow` | 1 | **0** |
| `Multiple local assignment` | 13 | 10 |
| `source unavailable` | 75 | 70 |
| `reference mismatch` | 9 | 11 |
| 全库有源码公式 | 3618 | **3650**（+32）|
| `full` / `partial` / `none` | 1572 / 20 / 15 | **1591 / 9 / 7** |
| 覆盖层条目 | 1035 | **1053**（+19 新写，−1 剔除旧假阳性）|

34 个目标里 **33 个解决**，剩下 `T_MIND_BLAST#2` 判定为**导出与源码不自洽**（§2.5）。

---

## 二、本轮施工

### 2.1 按批次

派发方式从「一个大系一个 agent」改为**按同学派打包成 ~50 条的自包含批次**：固定开销（读文档、熟悉工具、写报告）
从 244 份摊薄到 19 份，同一文件里的 helper 写法可以跨大系复用。

| 批次 | 条目 | 报告 |
| --- | --- | --- |
| `batch01-spells` | 51 | [`batch01-spells.md`](overlay-reports/batch01-spells.md) |
| `batch02-spells` | 49 | [`batch02-spells.md`](overlay-reports/batch02-spells.md) |
| `batch03-spells` | 47 | [`batch03-spells.md`](overlay-reports/batch03-spells.md) |
| `batch04-techniques` | 49 | [`batch04-techniques.md`](overlay-reports/batch04-techniques.md) |
| `batch05-techniques` | 42 | [`batch05-techniques.md`](overlay-reports/batch05-techniques.md) |
| `batch06-gifts` | 49 | [`batch06-gifts.md`](overlay-reports/batch06-gifts.md) |
| `batch07-gifts` | 37 | [`batch07-gifts.md`](overlay-reports/batch07-gifts.md) |
| `batch08-psionic` | 52 | [`batch08-psionic.md`](overlay-reports/batch08-psionic.md) |
| `batch10-steamtech` | 51 | [`batch10-steamtech.md`](overlay-reports/batch10-steamtech.md) |
| `batch12-cursed` | 45 | [`batch12-cursed.md`](overlay-reports/batch12-cursed.md) |
| `batch14-cunning` | 51 | [`batch14-cunning.md`](overlay-reports/batch14-cunning.md) |
| `batch16-chronomancy` | 47 | [`batch16-chronomancy.md`](overlay-reports/batch16-chronomancy.md) |
| `batch17-celestial` | 37 | [`batch17-celestial.md`](overlay-reports/batch17-celestial.md) |
| `batch18-misc` | 21 | [`batch18-misc.md`](overlay-reports/batch18-misc.md) |
| `batch19-demented` | 23 | [`batch19-demented.md`](overlay-reports/batch19-demented.md) |
| `batch20-small` | 30 | [`batch20-small.md`](overlay-reports/batch20-small.md) |
| `batch21-small` | 29 | [`batch21-small.md`](overlay-reports/batch21-small.md) |
| `batch22-corruptions` | 33 | [`batch22-corruptions.md`](overlay-reports/batch22-corruptions.md) |
| `batch23-dlc` | 33 | [`batch23-dlc.md`](overlay-reports/batch23-dlc.md) |
| `chronomancy__anomalies` | 29 | [`chronomancy__anomalies.md`](overlay-reports/chronomancy__anomalies.md) |
| `chronomancy__other` | 25 | [`chronomancy__other.md`](overlay-reports/chronomancy__other.md) |
| `chronomancy__spacetime-folding` | 12 | [`chronomancy__spacetime-folding.md`](overlay-reports/chronomancy__spacetime-folding.md) |
| `corruption__demon-seeds` | 16 | [`corruption__demon-seeds.md`](overlay-reports/corruption__demon-seeds.md) |
| `cunning__artifice` | 33 | [`cunning__artifice.md`](overlay-reports/cunning__artifice.md) |
| `cunning__traps` | 31 | [`cunning__traps.md`](overlay-reports/cunning__traps.md) |
| `cursed__shadows` | 13 | [`cursed__shadows.md`](overlay-reports/cursed__shadows.md) |
| `psionic__other` | 12 | [`psionic__other.md`](overlay-reports/psionic__other.md) |
| `psionic__voracity` | 21 | [`psionic__voracity.md`](overlay-reports/psionic__voracity.md) |
| `spell__deeprock` | 13 | [`spell__deeprock.md`](overlay-reports/spell__deeprock.md) |
| `spell__master-of-flesh` | 12 | [`spell__master-of-flesh.md`](overlay-reports/spell__master-of-flesh.md) |
| `spell__other` | 13 | [`spell__other.md`](overlay-reports/spell__other.md) |
| `technique__other` | 21 | [`technique__other.md`](overlay-reports/technique__other.md) |
| `uber__cunning` | 2 | [`uber__cunning.md`](overlay-reports/uber__cunning.md) |
| `wild-gift__summon-melee` | 14 | [`wild-gift__summon-melee.md`](overlay-reports/wild-gift__summon-melee.md) |
| **合计** | **1035** | 34 份 |

### 2.2 按大系（覆盖层条目数 Top 30）

| 大系 | 覆盖层条目 |
| --- | --- |
| `cunning/artifice` | 33 |
| `cunning/traps` | 32 |
| `chronomancy/anomalies` | 29 |
| `chronomancy/other` | 25 |
| `technique/other` | 23 |
| `psionic/voracity` | 21 |
| `corruption/demon-seeds` | 16 |
| `wild-gift/summon-melee` | 14 |
| `spell/other` | 13 |
| `spell/deeprock` | 13 |
| `cursed/shadows` | 13 |
| `psionic/other` | 13 |
| `chronomancy/spacetime-folding` | 12 |
| `spell/master-of-flesh` | 12 |
| `wild-gift/summon-distance` | 12 |
| `cunning/trapping` | 12 |
| `psionic/feedback` | 11 |
| `technique/finishing-moves` | 11 |
| `spell/dreadmaster` | 11 |
| `spell/rime-wraith` | 11 |
| `psionic/projection` | 10 |
| `cunning/poisons-effects` | 10 |
| `spell/death` | 10 |
| `chronomancy/manifold` | 10 |
| `spell/master-necromancer` | 10 |
| `spell/master-of-bones` | 9 |
| `psionic/solipsism` | 9 |
| `cursed/endless-hunt` | 9 |
| `psionic/absorption` | 9 |
| `spell/glacial-waste` | 8 |
| **其它 223 个大系** | **604** |

完整条目见 `data/lua-expressions.json`；逐条表达式与出处见各批报告 `docs/overlay-reports/`。

### 2.3 仍未拿下的 18 条（占派发量 2.3%）

全部是**工具或导出侧缺陷**，没有一条是「读不懂公式」：

| 技能 | 症状 |
| --- | --- |
| `T_CLEAVE#1`、`T_SEETHE#0`、`T_HALFLING_LUCK#0/#1`、`T_DWARF_RESILIENCE#1`、`T_EVASION#1` | 自设锚点上数学值**恰为整数**，JS 正好等于它、Lua `libm` 低 1 ulp → 导出打印少 1；四种读数都救不了 |
| `T_THICK_SKIN#0`、`T_ALCHEMIST_PROTECTION#1`、`T_TWIST_THE_KNIFE#2`、`T_ASTRAL_PATH#1`、`T_FORCED_GESTALT#0` | 仓库源码与导出**不是同一版本**（常量或曲线不同）；按规则不拟合，公式已留在报告里 |
| `T_DEFILING_TOUCH#0`、`T_DARK_GIFTS#1`、`T_DYNAMIC_RECHARGE#1`、`T_PLASMA_BOLT#1` | 导出侧缺项/元数据缺陷（某套渲染里整个 acronym 被丢掉、title 丢参数）|
| `T_SKIRMISHER_PACE_YOURSELF#2` | 源码 `combatTalentLimit` 与导出差得多，穷举参数空间无解 |
| `T_GESTURE_OF_GUARDING#0`、`T_SKULLCRACKER#0` | 依赖玩家武器/装备链（`combatDamage`、`getPriceFlags`），属不可建模 |

### 2.4 本轮新写的 19 条（多轴阶梯专项）

`data/overlay-batches/batch34-*.json`（5 个批次文件，4 个并行子代理 + 主项目）。逐条都过了
「三套 15 点 + 输入集合」双闸门，主项目又用 `try-formula` 独立复跑了一遍（19/19）。

| 技能 | acronym | 表达式要点 |
| --- | --- | --- |
| 无尽追踪 | #0/#1/#2 | `floor(max(2, 对应豁免/5))`；**哪一行读哪个豁免只能由句子决定**——三条阶梯数值完全相同，15 点判分分辨不出（见下）|
| 时空调谐 | #0/#1/#2 | `power(法术强度, pmod(paradox))`、`-2×意志`、`max(0, paradox − 2×意志)` |
| 力量手势 | #2 | `combatMindCrit()` 展开，`combat_mindcrit` 冻结为 0 |
| 守护手势 | #2 | `combatStatScale("cun",0,2.25)` |
| 闪避 | #1 | `幸运/200 × max(0, (敏捷−10)×0.7 + (幸运−50)×0.4)`；`combat_def`/`mult`/`add` 冻结为导出基准 |
| 不朽的恩赐 | #0 | `100 × combatStatScale(max(敏捷,魔力), 0.1, 0.476)`——**保留 `max` 不退化**，两个属性滑条都真的有效 |
| 抵挡训练 / 双持掌握 | #1 | `combatScale(灵巧, 1→2.25 / 2→3, 锚点 10→100)`（`getDeflects`，不是自动候选里的 `getDefense`）|
| 飞刀投掷 | #2–#5 | `combatDamage` 的凸包前 3 段 + `rescaleDamage(^1.04)`；命中/暴击两条直接读 `精准`/`灵巧`+`幸运` |
| 铁头功 | #1 | `50 × (1 − exp(...))`，**必须照抄源码字面量 `5.6234/31.623`**：现成的 `combatLimit` 节点用精确幂会在敏捷 100 得 `45.0000`，截断成 45 ≠ 导出 44 |
| 攻击姿态 | #0/#2 | `floor(敏捷/4)`、`min(35, statScale("str",1,30,0.75))` |

**滑条注意**：无尽追踪那一组是"数值相等但语义不同"的典型 —— 15 点全中只能证明**这三行都能读**，
证明不了**哪一行读哪一个**。映射取自英文/中文句子的 `magical/physical/mental effect durations`，
已在 `note` 里写明依据。

### 2.5 判定为「导出与源码不自洽」：心灵震爆 `T_MIND_BLAST#2`

源码 `twilight.lua:170`：`getConfuseDuration = min(10, floor(combatScale(getTalentLevel(t) + getCun(5), 2, 0, 12, 10)))`，
`getCun(5)` = 灵巧×5/100。三套导出的标题**沿不同的轴渲染**：

| 系数 | 标题 | 导出 | 源码公式算得（`%d`）|
| --- | --- | --- | --- |
| 1.00 / 1.30 | `技能等级 1-5, 灵巧 100, 法术强度 100` | `9,10,10,10,10` | 9.746→9、10.35→10… ✅ 全中 |
| 1.50 | `灵巧 10..100, 法术强度 10..100`（**无技能等级**）| `5,7,7,8,10` | 5.87→5、6.74→6、7.92→7、8.89→8、9.75→9 ❌ |

`5,7,7,8,9` 与导出的 `5,7,7,8,10` 只差最后一点。已排除的解释：换任何固定技能等级都不行
（第 1 点要求 `x<1.6`、第 2 点要求 `x∈[2.5,3.6)`，与"等级 1..5 平推"矛盾）；`getCun(5)` 换成
`5+0.05×cun` 或 `cun+5` 在 1.00 那一套就崩；把两条阶梯改成不一起推进也救不了。
**结论：1.5 那一套的渲染输入与 1.00/1.30 不自洽，公式不写，记入疑点。**
（子代理一度用"混用读数"绕过闸门拿到 PASS，正是这条促使我们加了缺陷 5 的校验。）

---

## 三、发现的写法模式（建议提升为解析器规则）

按「被反复踩到」排序，每条都有多个批次的实测支撑。

### 3.1 工具侧应当修的四件事（收益最大）

1. **`talentScale` / `talentLimit` / `combatScale` 的浮点结合次序与 Lua 不一致**——**几乎每一批都踩到**。
   源码 `Combat.lua:1544` 是 `m*x^p + (low − m*x_low^p)`，节点是 `slope*(x^p − x_low^p) + low`；
   `combatTalentLimit`（`Combat.lua:1606`）是 `limit*(1−exp(√tl·a+b))`，节点是代数等价的幂式。
   两者**代数等价、浮点不等价**：在锚点（`tl = mastery`、`tl = 5*mastery`、`tl = 5`）差 1 个 ULP，被 `floor`/`ceil` 包住就差 1。
   实测受影响数十条（`T_SOULEATER`、`T_RIME_WRAITH`、`T_PERMAFROST`、`T_NECROTIC_AURA`、`T_HEARTSEEKER`、`T_BLEAK_GUARD`、
   `T_SOUL_LEECH`、`T_LIGHT_ARMOUR_TRAINING`、`T_CHANT_OF_FORTITUDE`、`T_SECOND_LIFE`、`T_CLARITY`、`T_SOLIPSISM` …），
   各批都靠「按 Lua 原运算顺序手工展开」绕过。**建议把节点实现改成源码次序**，可省掉大量手写展开。
   注意方向不统一：`T_GLYPHS#0`、`T_RADIANCE#0` 反而必须用重排式才能取到精确 low —— 修的时候要保留两条候选。
2. **`ladderAxis` 不支持多轴**：title 同时给两条 5 点阶梯时返回 `null`，**任何表达式都不试算**。本库仍有 **54 条**卡在这
   （`uber/cunning` 13、`T_SPACETIME_TUNING` 3、`T_METEORIC_CRASH` 3、`T_TAKE_A_BITE` 3、`T_STRIKING_STANCE` 3 …）。
   公式都读得出来，缺的是「沿导出给定的联合点同点代入」。
3. **`isDeclaredInput` 认类太窄**：`kind: other` 的标签（如 `精准`、`shield block 200`）不算已声明，
   于是 `["actor","精准"]` 会被判「读了标题未声明的输入」。多批撞到（`T_CRIPPLING_SHOT#1`、`T_LIGHTNING_WEB`、`T_OSMOSIS_SHIELD`）。
4. **节点参数不递归求值**：`["talentScale", low, high]` 的 `low`/`high`、`["talentLimit",…]` 的 `high` 只认数字字面量，
   `["/",1,7]` 会算出 `—`；`["talentScale",low,high,null]` 传 `null` 也 NaN。

### 3.2 通用写法（可机械规则化）

5. **原始等级 vs 有效等级**：三套导出数字**完全相同** ⇒ 该值按 `getTalentLevelRaw` 计算 ⇒ 写 `["talentLevel",true]`；
   随系数变 ⇒ `["talentLevel"]`。同一 tooltip 内两种口径可并存（`T_FLAMESHOCK#0` 半径按原始、`#1` 伤害按有效）。
6. **「任意等级驱动」的等价展开**：`combatTalentScale(t,low,high,power)` @L ⟺ `["combatScale",L,low,1,high,5,power]`；
   `"log"` 版 ⟺ `["+",low,["*",["/",["-",high,low],["log10",5]],["log10",L]]]`；power 家族 ⟺ `["^",…,1.04]` 手写展开。
   最常用 `L = ["*",2,["talentLevel",true]]`（嵌套说明按 2 倍原始等级渲染）。
7. **嵌套整段技能说明**：`info` 里 `self:getTalentFullDescription(tv, <等级>)` 会嵌入**别的技能**（含 NPC 技能）的完整说明；
   导出最前面那个 acronym 就是「有效技能等级」本身。被嵌技能常被渲染在**等级 0**
   （`T_SHIVGOROTH_FORM`、`T_HYMN_ACOLYTE`/`T_CHANT_ACOLYTE`/`T_DIRGE_ACOLYTE` 共 13 条）。
8. **`callTalent` / 转发 getter**：用 `["talentRef","T_X"]`（导出基准 0），且 `statDamage`/power 家族必须手工展开把 `L` 换成它；
   但 `callTalent(T_自己,…)` **不要**用 talentRef（会变 0），要内联该 getter。
9. **离散分支与阶跃**：`if tl>=N then A else B` ⟺ `["+",B,["*",["min",1,["floor",["/",["talentLevel"],N]]],["-",A,B]]]`；
   布尔阶梯 ⟺ `["min",2,["+",1,["floor",["/",L,4]]]]`；`util.bound(x,lo,hi)` ⟺ `["min",hi,["max",lo,x]]`。
10. **导出基准隐式常量**（未声明输入，按规则冻结并在 `note` 写明）：`self.max_life`=1000、`combatFatigue`=0、
    `getStrikingStyle`=0、`getTalentTypeMastery`=1、`T_RESILIENCE.incDur`=−1、`combat_def`≈39、`get_mindstar_power_mult`=1。
11. **属性类 getter 的缩放**：`getStr/getDex/getMag/getCun/getWil(B,true)` = `属性 × B/100`
    （所以能正常消费标题声明的属性，而不是冻结常数）；`getCun(15,true)=灵巧×0.15`。
12. **`combatTalentIntervalDamage` 无节点**，须手写 `x=min+(max−min)*(w*stat/100+(1−w)*tl/6.5)`，结果 `x*(1−log10(2x)/7)`
    （`^(1/1.04)` 与 `rescaleDamage` 的 `^1.04` 相抵）；`statDamage` 也不要再包 `^1.04`。
13. **`combatStatLimit` 无节点**，等价 `combatLimit(x,limit,low,10,high,100)`；但 Lua 锚点是字面常量 `5.6234/31.623`，
    节点重算 `10^0.75/100^0.75` 会让 stat=100 端点差 1，需传 `5.6234^(4/3)`、`31.623^(4/3)`。
14. **`rng.avg(a,b,n)` 在导出里表现为期望** `(a+b)/2`；`["*",a,b,c]` 只吃二元，必须嵌套。
15. **导出会把 tooltip 文本里的字面负号并进 acronym**（`T_GNASHING_TEETH#5`、`T_BLURRED_MORTALITY`），公式要整体取负。
16. **`math.ceil`/`math.floor` 常被导出的 `%d` 截断吃掉**：源码 `ceil(combatTalentScale(...))` 在导出里表现为 `floor`
    （`T_ILLUMINATION`、`T_HYMN_ADEPT`、`T_STEALTH#0`、`T_BLACK_ICE`、`T_CHILL_OF_THE_TOMB`）——先试去掉取整。

### 3.3 学派专属模板

17. **时空系**：`getParadoxSpellpower` = `["*",["power","法术强度"],["pmod",["actor","paradox"]]]`；
    `getExtensionModifier(self,t,v)` = `["floor",["*",v,["pmod",["actor","paradox"]]]]`（**paradox 唯一被真正消费的地方**）；
    anomaly 家族全是 `combatScale`/`combatLimit` + `rng.avg` 期望。
18. **召唤系**：`summonTime` = `["-",["floor",["combatScale",["talentLevel"],A,0,B,5]],1]`；属性 = `base + 精神强度*k*S + T`
    （`S=combatTalentScale(t,0.2,1,0.75)`、`T=combatTalentScale(t,2,10,0.75)`）；`incStats(...,true)` 旁路 `mindCrit`。
    半径族在导出里按**原始等级**算。`combatTalentPhysicalMindDamage` 展开成 `["max",["mindDamage",b,s],["physicalDamage",b,s]]`。
19. **陷阱/工匠系**：`short_info(self,t,slot_talent)` 的第三参才是驱动等级；`pairs()` 让导出 acronym 顺序是哈希序，
    **不能按源码声明顺序对号**；`trap_effectiveness(cun)`、`getCun(n,true)=灵巧×n/100`。
20. **灵能系**：因子 `F = ["max",0.5,["-",1.5,["/",["actor","psi"],100]]]`（标题的 psi 是**百分数**，不需要 maxPsi）。
21. **诅咒系**：多为 `["min",…,["max",…]]` 夹取 + `combatLimit`/`combatTalentIntervalDamage`。
22. **蒸汽系**：强度是 `["power","steampower"]`；**该 DLC 源码快照与导出不是同一版本**，至少 12 条 `combatTalentLimit` 常量对不上，
    只能按导出反推常量并注明。

---

## 四、仍无法建模的类别

1. **多轴 ladder（54 条）**：公式可读，工具不支持联合阶梯 → 需先修 `ladderAxis`。
2. **源码不在仓库（63 条）**：导出含未提供的 addon（`source_code` 指向 `data-possessors/...` 等），
   如 `psionic/psychic-blows` 12、`psionic/battle-psionics` 12、`psionic/deep-horror` 10 等——除非拿到 addon，否则无解。
   这些技能现在靠**反解估算**兜底（`manifest.scaling.estimated = 70`）。
3. **运行时状态**：真随机、玩家武器/装备链、别的实体状态、召唤物实体属性、运行时数据表（符文/装置/种子定义）。
4. **导出侧元数据缺陷**：多段并列文本被并成一个 acronym（`T_MARTYRDOM#0`、`T_STRIPPED_LIFE#0`、`T_MUTATED_*#1`）、
   某套渲染里 acronym 被整个丢掉（`T_DEFILING_TOUCH#0`、`T_DYNAMIC_RECHARGE#1`）、title 丢参数（`T_PLASMA_BOLT#1`）。
5. **源码↔导出版本不一致**：见 2.3 的 5 条；另有若干只差 1 的 `libm` 刀口读数。

---

## 五、建议（按收益排序）

1. **按 3.1-1 修 `talentScale`/`talentLimit`/`combatScale` 的浮点次序**。这是本轮**被踩最多次**的坑，修完可让大量手写展开回归短写法，
   也能让后续解析器少产出一批「假 FAIL」。注意保留「重排式」作为备选读数。
2. **按 3.1-2 给 `ladderAxis` 加多轴对角线支持**：一次性解锁 **54 条**（含 `uber/cunning` 13 条）。
3. **按 3.1-3 修 `isDeclaredInput` 的认类**（`kind: other` 也算声明）。
4. **按 3.1-4 让节点参数递归求值**（`low`/`high` 接受表达式）。
5. **把这批规律落成解析器规则**（第 3.2 / 3.3 节共 22 条），尤其是「任意等级展开」「嵌套 `getTalentFullDescription`」
   「学派 helper」「隐式冻结常量」——它们在大系内高度重复。
6. **剩余工作量**：全库 3750 条现已解决 3618（96.5%）；剩 132 条 = 多轴 54 + 无源码 63 + 其它刀口/缺陷约 15。
   若修好第 1、2 条，预计可再拿下 60–80 条。

---

## 附：可复现步骤

```sh
cd modern_tome_viewer

node scripts/try-formula.mjs --list --tree <tree>                       # 1) 取目标清单
node scripts/try-formula.mjs --talent <ID> --arg <N> --expr '<JSON>'    # 2) 单条试算，迭代到 PASS
node scripts/try-formula.mjs --overlay data/overlay-batches/<slug>.json # 3) 校验某批次

# 4) 合并全部批次（按 talent#acronym 去重）+ 用判分器自身输出反复剔不合格条目
node scripts/try-formula.mjs --overlay data/lua-expressions.json        # 期望：1035/1035 通过

node scripts/build-data.mjs                                             # 5) 重建（构建端会再验一遍三套渲染）
npx vite build                                                          # 6) 重建 dist
```
