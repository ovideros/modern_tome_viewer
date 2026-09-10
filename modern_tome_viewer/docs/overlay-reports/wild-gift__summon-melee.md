# 覆盖层报告：wild-gift/summon-melee（契约系近战召唤）

- 目标数：**14**（`node scripts/try-formula.mjs --list --tree wild-gift/summon-melee`）
- 批次文件：`data/overlay-batches/wild-gift__summon-melee.json`
- 验收命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/wild-gift__summon-melee.json`
- 汇总行：**`覆盖层校验：14/14 通过`**（数组长度 14，无 FAIL / 无输入集合不符）
- 源码集中：`tome-src-full/data/talents/gifts/summon-melee.lua`（4 个 `newTalent` 块：War Hound 75、Jelly 185、Minotaur 306、Stone Golem 421）

## 一、已完成（14/14，全部三套 15 点全中 + 输入集合一致）

| 技能 | acronym | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_WAR_HOUND | #0 summonTime | `["-",["floor",["combatScale",["talentLevel"],5,0,10,5]],1]` | summon-melee.lua:110 | ✅ |
| T_WAR_HOUND | #1 str | `["+",15,["+",["*",["*",["power","精神强度"],2],["talentScale",0.2,1,0.75]],["talentScale",2,10,0.75]]]` | summon-melee.lua:114 | ✅ |
| T_WAR_HOUND | #2 dex | `["+",15,["+",["*",["power","精神强度"],["talentScale",0.2,1,0.75]],["talentScale",2,10,0.75]]]` | summon-melee.lua:115 | ✅ |
| T_JELLY | #0 summonTime | `["-",["floor",["combatScale",["talentLevel"],5,0,10,5]],1]` | summon-melee.lua:219 | ✅ |
| T_JELLY | #1 con | `["+",10,["*",["*",["power","精神强度"],1.6],["talentScale",0.2,1,0.75]]]` | summon-melee.lua:223 | ✅ |
| T_JELLY | #2 str | `["+",10,["talentScale",2,10,0.75]]` | summon-melee.lua:224 | ✅ |
| T_MINOTAUR | #0 summonTime | `["-",["floor",["combatScale",["talentLevel"],2,0,7,5]],1]` | summon-melee.lua:339 | ✅ |
| T_MINOTAUR | #1 str | `["+",25,["+",["*",["*",["power","精神强度"],2.1],["talentScale",0.2,1,0.75]],["talentScale",2,10,0.75]]]` | summon-melee.lua:343 | ✅ |
| T_MINOTAUR | #2 con | `["+",10,["talentScale",2,10,0.75]]` | summon-melee.lua:345 | ✅ |
| T_MINOTAUR | #3 dex | `["+",10,["+",["*",["*",["power","精神强度"],1.8],["talentScale",0.2,1,0.75]],["talentScale",2,10,0.75]]]` | summon-melee.lua:344 | ✅ |
| T_STONE_GOLEM | #0 summonTime | `["-",["floor",["combatScale",["talentLevel"],5,0,10,5]],1]` | summon-melee.lua:458 | ✅ |
| T_STONE_GOLEM | #1 str | `["+",15,["+",["*",["*",["power","精神强度"],2],["talentScale",0.2,1,0.75]],["talentScale",2,10,0.75]]]` | summon-melee.lua:462 | ✅ |
| T_STONE_GOLEM | #2 con | `["+",10,["talentScale",2,10,0.75]]` | summon-melee.lua:464 | ✅ |
| T_STONE_GOLEM | #3 dex | `["+",15,["+",["*",["*",["power","精神强度"],1.9],["talentScale",0.2,1,0.75]],["talentScale",2,10,0.75]]]` | summon-melee.lua:463 | ✅ |

acronym 与 info 的对应（`tformat` 参数顺序）：

- War Hound `:tformat(summonTime, str, dex, con)`，con 是字面量 15（不是 acronym）。
- Jelly `:tformat(summonTime, con, str)`。
- Minotaur `:tformat(summonTime, str, con, dex)`。
- Stone Golem `:tformat(summonTime, str, con, dex)`。

## 二、发现的写法模式（可提升为解析器规则）

1. **`combatScale` 缺省 power = 0.5（√ 曲线），不是 1**。
   `math.floor(self:combatScale(self:getTalentLevel(t), low, 0, high, 5))` 配 `["combatScale",["talentLevel"],low,0,high,5]`（节点默认 power=0.5）。
   另外 `Combat.lua:1505` 的 `combatScale` **没有** `x<=x_low` / `x>=x_high` 的夹紧分支（只有 `combatTalentScale` 锚定 1→5），所以系数 1.5 时 `tl>5` 仍然线性外推；`["combatScale",…]` 节点行为一致，这是本批能过 15/15 的关键。
   代表：`T_WAR_HOUND` #0。

2. **`talentScale` 原生节点吃「有效等级 = 原始等级 × 技能系数」**，三套导出数字不同的值一律用默认（`["talentLevel"]`），不需要按「已验证的等价展开」手工展开成 `combatScale`。本批只有「等级来自别的表达式」时才需要展开，本批没有。
   代表：`T_JELLY` #2 = `10 + combatTalentScale(t,2,10,0.75)`。

3. **召唤物属性 = 召唤师算完塞进 NPC 的 `inc_stats`**，info 取的是 `t.incStats(self, t, true)` —— 第三参 `fake=true`。源码里 `(fake and mp or self:mindCrit(mp))` 在 fake=true 时**旁路 mindCrit**，所以面板值就是纯 `combatMindpower()`（= 标题声明的「精神强度」），用 `["power","精神强度"]` 即可；若漏掉 fake 这一层，会误以为需要随机暴击系数。
   代表：`T_WAR_HOUND` #1。

4. **同一文件一套 helper 反复出现**：`S = combatTalentScale(t, 0.2, 1, 0.75)`、`T = combatTalentScale(t, 2, 10, 0.75)`，4 个技能只是基数/倍率不同：
   `str = base + mp*k*S + T`、`dex = base + mp*k*S + T`、`con = 10 + T`。
   摸清 2 条后其余 10 条可直接套系数（2 / 1 / 1.6 / 2.1 / 1.8 / 1.9）。
   代表：`T_STONE_GOLEM` #1/#2/#3。

5. **纯 `T` 项（不含精神强度）的 acronym，标题也确实不声明精神强度**，表达式不要为了「看起来完整」塞 `["power",…]`，否则输入集合会 FAIL。
   代表：`T_JELLY` #2、`T_MINOTAUR` #2、`T_STONE_GOLEM` #2。

## 三、无法建模

**本批 14 条全部建模成功，无「无法建模」条目。** 以下只记录本大系的边界（本批 acronym 未触及）：

1. 召唤实体的运行时数值不可建模：`max_life = resolvers.rngavg(25,50)`（War Hound 146、Jelly 255）、Minotaur/Stone Golem 的 `max_life = rngavg(50,80)`、`combat = { dam = ... rng.avg(12,25) }`（War Hound 151）、`dam = 25 + self:getWil()`（Stone Golem 503）、以及 `setupSummon()` 之后的最终属性 —— 都依赖随机数或召唤实体的运行时状态，且标题里没有对应输入。所幸这 4 个技能的 3–4 个 acronym 只落在 `summonTime` 与 `incStats` 上。
2. `incStats` 里的 `self:mindCrit(mp)` 分支不可建模（随机暴击）；本批 info 走 `fake=true`，因此不影响。
3. `summonTime` 里的 `+ self:callTalent(self.T_RESILIENCE, "incDur")` 是**别的技能的 getter**，表达式语言没有「读另一个技能 getter 结果」的节点（`talentRef` 只给等级）。本批按导出基准取常数（见下节疑点 1），这是唯一可行写法。

## 四、疑点

1. **`summonTime` 存在系统性 `-1` 偏移，但已证实不是导出缺陷，也不需要「硬凑」。**
   源码：`math.floor(self:combatScale(self:getTalentLevel(t), 5, 0, 10, 5)) + self:callTalent(self.T_RESILIENCE, "incDur")`。
   导出 15 点全部等于 `floor(combatScale(...)) - 1`。原因是导出基准下召唤师**未点亮 Resilience**：`getTalentLevel(T_RESILIENCE) = 0`，而 `Combat.lua:1611` 的 `combatTalentLimit` 有 `if tl <= 0 then tl = 0.5 end`，于是
   `incDur = floor(combatTalentLimit(t, 6, 2, 5))`，在 `tl = 0.5` 时内层值为 **-0.1244144123**（已数值复算）→ `floor = -1`。
   所以 `-1` 就是「导出基准（Resilience 等级 0）下 `incDur` 的取值」，写常数与写 `talentRef` 语义一致，不违反「不许硬编码标题声明的输入」（Resilience 等级不在标题里）。
   证据（T_WAR_HOUND #0，三套）：
   - 系数 1.00：导出 `6/7/7/8/9`，`floor(√曲线)` `7/8/8/9/10` → 全 -1 命中
   - 系数 1.30：导出 `6/7/8/9/9`，`floor` `7/8/9/10/10` → 全 -1 命中
   - 系数 1.50：导出 `6/7/8/9/10`，`floor` `7/8/9/10/11` → 全 -1 命中
   交叉验证：`wild-gift/summon-distance` / `summon-utility` 的同类 `summonTime` acronym 用同一表达式也 PASS（抽查 `T_SPIDER` #0），说明这是整个召唤系的统一现象。

2. **同一文件里召唤时长锚点不一致**：Minotaur 用 `combatScale(tl, 2, 0, 7, 5)`，War Hound / Jelly / Stone Golem 用 `(5, 0, 10, 5)`（源码 339 vs 110/219/458）。导出数据与各自源码一致，非疑点，但解析器按文件统一取锚点会错。

3. **整数显示读法在同一 acronym 内不统一（源码是 `%d`，即 Lua 截断）**：例如 `T_WAR_HOUND` #1 系数 1.3 第 1 点算得 72.5884 → 导出 72 只能截断，第 2 点 132.0884 截断/四舍五入都对；系数 1.5 第 1 点 82.4758 → 82 只能截断，第 3 点 206.7893 → 206 只能截断。统一解释为截断即可，不构成源码与导出的不一致。

4. 未发现「标题过度声明输入」的情况：本批 6 条声明 `[精神强度]` 的 acronym 表达式都确实消耗精神强度，8 条声明 `[无]`（仅技能等级轴）的表达式都不含任何强度节点。

---

### 交付范围声明

本次仅写入两个文件：

- `modern_tome_viewer/data/overlay-batches/wild-gift__summon-melee.json`（14 条，全部 PASS 后落盘）
- `modern_tome_viewer/docs/overlay-reports/wild-gift__summon-melee.md`（本文件）

未修改 `src/**`、`scripts/**`、`public/**`、`data/raw/**`、`data/lua-coefficients.json`，也未写 `data/lua-expressions.json` 与 `docs/expression-overlay-report.md`。
