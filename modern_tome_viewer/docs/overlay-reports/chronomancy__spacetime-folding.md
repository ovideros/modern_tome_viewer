# 覆盖层报告 · `chronomancy/spacetime-folding`

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/chronomancy__spacetime-folding.json`
结果：**4/4 通过**（目标 12 条；8 条因**导出标题过度声明输入**无法通过闸门，见「疑点」）

## 已完成

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_WARP_MINES | #4 | `["floor",["*",["floor",["talentScale",6,10]],["pmod",["actor","paradox"]]]]` | spacetime-folding.lua:216 | ✅ |
| T_SPATIAL_TETHER | #0 | `["floor",["*",["floor",["talentScale",6,8]],["pmod",["actor","paradox"]]]]` | spacetime-folding.lua:258 | ✅ |
| T_BANISH | #2 | `["floor",["*",["floor",["talentScale",2,4]],["pmod",["actor","paradox"]]]]` | spacetime-folding.lua:407 | ✅ |
| T_DIMENSIONAL_ANCHOR | #0 | `["floor",["*",["floor",["talentScale",6,10]],["pmod",["actor","paradox"]]]]` | spacetime-folding.lua:462 | ✅ |

## 发现的写法模式

1. **`getExtensionModifier(self, t, value)` 包裹**（`chronomancy/chronomancer.lua:188`）：
   `value = floor(value * pmod)`，然后 `ceil(value * mod)`（`mod` 只在「扩展」技能激活该技能时才 >1，导出场景为 1）。
   等价表达式：`["floor",["*", <inner>, ["pmod",["actor","paradox"]]]]`。**这是 paradox 这个输入唯一被真正消费的地方**，
   也正好满足标题对 paradox 的声明。代表技能：整树的 duration 类值（本批 4 条全部）。

2. **`combatTalentSpellDamage(t, base, max, getParadoxSpellpower(self, t))` 的显式强度覆盖**：
   第 3 个参数是强度覆盖，写 `["*",["power","法术强度"],["pmod",["actor","paradox"]]]`。
   本大系 `getDamage`（215/260/461 行）都是这个形状。

3. **`combatScale(self:getTalentLevel(t) * self:getMag(15, true), 0, 0, 75, 75)`**（`trapPower`，217 行）：
   `getMag(15, true)` 在本导出场景等价于 `魔力 × 0.15`（魔力=100 时得 15），于是
   `["max",1,["combatScale",["*",["talentLevel"],["*",["actor","魔力"],0.15]],0,0,75,75]]` 能精确复现 15 点
   （我用它逐点验算过 33/47/58/67/75、38/54/66/76/85、41/58/71/82/91 三套），**但过不了输入集合闸门**（见疑点）。

## 无法建模（本质是导出元数据缺陷，不是公式写不出来）

| 技能id | acronym#N | 数值算出 | 卡在哪 |
| --- | --- | --- | --- |
| T_WARP_MINES | #0 | ✅ 15/15 | `标题声明 [paradox, 法术强度, 魔力] vs 消耗 [paradox, 法术强度]` —— 多声明了 `魔力` |
| T_WARP_MINES | #1 | ✅ 15/15 | 同上 |
| T_WARP_MINES | #2 | ✅ 15/15 | `[魔力, 法术强度, paradox]` vs `[魔力]` —— 多声明 `法术强度`、`paradox` |
| T_WARP_MINES | #3 | ✅ 15/15 | 同上（trapPower）|
| T_WARP_MINES | #5 | ✅ 15/15 | `[paradox]` vs `[]` —— getRange 不含 paradox |
| T_SPATIAL_TETHER | #3 | ✅ 15/15 | `[paradox]` vs `[]` —— radius = floor(combatTalentScale(t,1,2)) |
| T_BANISH | #0 / #1 | ✅ 15/15 | `[paradox]` vs `[]` —— range/2 与 range 不含 paradox |

**现象**：tometips 导出把 `paradox`（以及 `魔力`/`法术强度`）写进了该技能**多个** acronym 的 title，
但这些 acronym 的源码公式并不消费它们。判分器的「输入集合必须完全一致」因此把**数值完全正确**的公式判为 FAIL。

**量化**：`chronomancy` 全学派自动匹配率 **119/279 = 42.7%**，明显低于全库 **2469/3750 = 65.8%**；
本大系只有 4/16 已匹配。这不是公式难，而是闸门与导出元数据不匹配。

**建议**（供主项目决策，本次未改任何代码）：
- 方案 A：把 `declaredInputs` 从「title 声明的全部」放宽为「title 声明 ∩ 该技能任一同族表达式可能消费的集合」，或
- 方案 B：保留严格闸门，但把「数值 15/15 全中、仅输入集合为超集」单独记一类 `superset-inputs`，
  构建时按「表达式消耗 ⊆ 标题声明」放行（子集即可），因为**多声明输入不会让公式变得不可复现**——滑条上多一个不影响结果的输入而已。
  当前闸门是等号（`JSON.stringify(declared) === JSON.stringify(consumed)`），改成子集判断即可解锁这一整类。

## 疑点

除上述「输入集合为超集」外，本大系**没有**发现源码与导出数字本身的系统性不一致：
凡是能通过闸门的 4 条，数值三套 15 点全中；被拦下的 8 条数值也全中。故此处不重复列举数字。
