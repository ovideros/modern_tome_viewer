# 表达式覆盖层总报告

> 目标：把自动提取失败的技能数值，通过**读游戏 Lua 源码手写表达式**补上，并用仓库自带判分器证明正确。
> 全部命令：`cd modern_tome_viewer && node scripts/try-formula.mjs --overlay data/lua-expressions.json`

## 0. 结论摘要

| 项 | 数值 |
| --- | --- |
| 交付覆盖层条目 | **1035** 条，涉及 **253** 个大系 |
| 覆盖层验收 | `覆盖层校验：1035/1035 通过`（每条：三套导出系数 1.00/1.30/1.50 共 15 点全中 ＋ 表达式读到的输入都被标题声明过）|
| 构建端复验 | `overlay 1035/1035 accepted (re-validated against 3 renderings)` |
| **全库有源码公式** | 2469 → **3618 / 3750 = 96.5%** |
| 回归 | typecheck OK · scaling **41/41** · verify **77/77** · smoke **42/42** · e2e **160/160** |
| 派发命中率 | 本轮派发 786 条可攻目标，拿下 **768 = 97.7%** |

**交付物**

1. `modern_tome_viewer/data/lua-expressions.json` —— 覆盖层（1035 条：`talent` / `acronym` / `expr` / `source` / `note`）
2. `modern_tome_viewer/docs/expression-overlay-report.md` —— 本报告
3. `modern_tome_viewer/data/overlay-batches/*.json` —— 34 个批次（可单独重跑，审计留痕）
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
