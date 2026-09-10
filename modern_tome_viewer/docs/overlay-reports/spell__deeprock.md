# 覆盖层报告 · `spell/deeprock`

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/spell__deeprock.json`
结果：**8/8 通过**（目标 13 条；5 条记入「疑点/无法建模」）

## 已完成

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_DEEPROCK_FORM | #3 | `["talentScale",7.3,11.5,0.75]` | deeprock.lua:35 | ✅ |
| T_VOLCANIC_ROCK | #2 | `["*",2,["talentLevel",true]]` | deeprock.lua:76 | ✅ |
| T_VOLCANIC_ROCK | #3 | `["floor",["combatScale",["*",2,["talentLevel",true]],5,1,9,5,0.5]]` | npcs.lua:1550 | ✅ |
| T_VOLCANIC_ROCK | #4 | `["floor",["+",1,["*",["/",4,["log10",5]],["log10",["*",2,["talentLevel",true]]]]]]` | npcs.lua:1551 | ✅ |
| T_VOLCANIC_ROCK | #5 | `["/",["^",["*",["/",["*",["+",15,["power","法术强度"]],["+",1,["*",0.8,["-",["sqrt",["*",2,["talentLevel",true]]],1]]]],["*",115,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],80],1.04],2]` | npcs.lua:1552 | ✅ |
| T_VOLCANIC_ROCK | #6 | 同 #5 | npcs.lua:1552 | ✅ |
| T_BOULDER_ROCK | #2 | `["*",2,["talentLevel",true]]` | deeprock.lua:92 | ✅ |
| T_BOULDER_ROCK | #4 | `["floor",["combatScale",["*",2,["talentLevel",true]],4,1,8,5,0.5]]` | npcs.lua:1168 | ✅ |

## 发现的写法模式

1. **嵌套整段技能说明**：`info` 里 `self:getTalentFullDescription(tv, self:getTalentLevelRaw(t) * 2)` 会把**别的技能**（这里是 NPC 技能 `T_VOLCANO` / `T_THROW_BOULDER`）的完整说明嵌进来，导出的 acronym 因此包含：
   - 被嵌技能的「有效技能等级」= `2 × 原始等级` → `["*",2,["talentLevel",true]]`；
   - 被嵌技能各 getter 在**该等级**下的取值（`floor(combatTalentScale(...))`、`combatTalentSpellDamage`、`combatScale(str*L, ...)`）。
   代表技能：`T_VOLCANIC_ROCK`、`T_BOULDER_ROCK`。
   注：全库只有 3 处 `getTalentFullDescription`，属小众但高确定性的写法。

2. **「任意等级驱动游戏公式」的等价展开**（节点表没有 level 参数，但可在表达式层展开）：
   - `combatTalentScale(t, low, high, power)` @ L ⟺ `["combatScale", L, low, 1, high, 5, power]`
   - `combatTalentScale(t, low, high, "log")` @ L ⟺ `["+", low, ["*", ["/", ["-", high, low], ["log10", 5]], ["log10", L]]]`
   - `combatTalentSpellDamage(t, base, max)` @ L、强度 P ⟺
     `["^", ["*", ["/", ["*", ["+", base, P], ["+", 1, ["*", 0.8, ["-", ["sqrt", L], 1]]]], ["*", ["+", base, 100], ["+", 1, ["*", 0.8, ["-", ["sqrt", 5], 1]]]]], max], 1.04]`
   以上三条均已实测 15/15 PASS（本条大系 #3/#4/#5/#6 即证据）。

3. **原始等级 vs 有效等级**：三套导出数字完全相同的值，几乎一定是按**原始等级**（`getTalentLevelRaw`）算的，用 `["talentLevel",true]`；只用 `["talentLevel"]` 会在 1.30/1.50 两套上崩。

## 无法建模

| 技能id | acronym#N | 原因 |
| --- | --- | --- |
| T_BOULDER_ROCK | #0 | **导出标题过度声明输入**：该 acronym 的 title 同时声明 `力量 100` 与 `法术强度 100`，但源码 `getDam = 5 + combatTalentSpellDamage(t,10,250)/10` 只消耗法术强度 → 输入集合永远对不上（工具实测 `标题声明 [力量, 法术强度] vs 消耗 [法术强度]`）|
| T_BOULDER_ROCK | #3 | 同上：`Throw Boulder getDam = combatScale(getStr()*getTalentLevel(t),12,0,262,500)` 只消耗力量，标题却多声明了法术强度，实测 `[力量, 法术强度] vs [力量]` |

这两条是**导出侧的元数据缺陷**，不是公式写不出来：表达式本身能 15 点全中，卡在输入集合闸门。建议主项目考虑「标题参数为该技能全部 acronym 的并集」这一事实，评估是否放宽该闸门（或按 acronym 的 title 精确解析）。

## 疑点

**`combatTalentLimit(t, 100, 6.6, 13)` 三处全部对不上，且偏离随等级增大**（同文件三个技能共用同一 getter）：

- `T_DEEPROCK_FORM` #2、`T_VOLCANIC_ROCK` #1、`T_BOULDER_ROCK` #1

| 系数 | 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- |
| 导出 1.00 | 5.9 | 7.9 | 9.3 | 11 | 12 |
| 导出 1.30 | 6.6 | 8.8 | 10 | 12 | 13 |
| 导出 1.50 | 7.0 | 9.3 | 11 | 13 | 14 |
| `["talentLimit",100,6.6,13]` 算得（1.50 套）| 6.997 ✅ | 9.343 ✅ | 11.103 ❌ | 12.561 ❌ | 13.825 ❌ |

把导出值反解成等级：需要的 `tl` ≈ 1.501 / 2.964 / 4.402 / 6.499 / 7.722，而按 `原始等级 × 系数` 应为 1.5 / 3 / 4.5 / 6 / 7.5 —— **不是任一个固定 mastery 能解释的偏差**（我用 1.0/1.2/1.3/1.5/1.95 逐一代入均无法同时命中 15 点）。

排除项：
- 求值器没坏：`data/talents.json` 里 `talentLimit` 已有 **439 条**成功匹配；
- 同文件其它 getter 对得上（`getArmor` 15/15、`getDam` 自动匹配成功）→ 不是版本/文件错位。

结论：这是**源码与导出数据的真实系统性不一致**，按要求不硬凑，记入疑点。

---

# 闸门放宽后的补做

输入集合闸门由「相等」放宽为「覆盖」（`consumed ⊆ declared`）后，对 `spell/deeprock` 的 5 条待补值重新处理。

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/spell__deeprock.json`
结果：**10/10 通过**（原 8 条 + 本次新增 2 条；待补 5 条中 3 条确认不可补，见下文）

## 本次新增（PASS，已写入批次文件）

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_BOULDER_ROCK | #0 | `["+",5,["/",["spellDamage",10,250],10]]` | deeprock.lua:86 | ✅ |
| T_BOULDER_ROCK | #3 | `["combatScale",["*",["actor","力量"],["*",2,["talentLevel",true]]],12,0,262,500]` | npcs.lua:1167 | ✅ |

两条原来的阻塞原因都是**标题过度声明输入**（title 是整技能 4 个 acronym 的并集，含 `力量` 与 `法术强度`），
表达式本身一直是对的；闸门改为覆盖判定后直接 PASS：

- `#0` 标题声明 `[力量, 法术强度]` vs 消耗 `[法术强度]` → `✅ 覆盖（标题是超集，本值未用到：力量）`
- `#3` 标题声明 `[力量, 法术强度]` vs 消耗 `[力量]` → `✅ 覆盖（标题是超集，本值未用到：法术强度）`

注：`#3`（嵌套 Throw Boulder 的 `getDam`）取的是 `npcs.lua:1167`（`getDist` 在 1168 行，别混）。
`["actor","力量"]` = `self:getStr()`。

## 疑点（复核后维持）：`combatTalentLimit(t,100,6.6,13)` 三处

`T_DEEPROCK_FORM#2`、`T_VOLCANIC_ROCK#1`、`T_BOULDER_ROCK#1` —— 仍不通，**但根因已改写**：
不是「源码与导出系统性不一致」，也不是 low/high/等级口径选错，而是**导出侧的显示精度把梯形图渲染成了 2 位有效数字**，
导致 15 点目标集在任何固定小数精度下自相矛盾。

### 新根因（本次独立复核发现）

导出里该 acronym 的字面串（三套，取自 `starsapphirex.github.io/tometips/data/master/talents.spell-*.json` 的 `info_text`）：

```
系数 1.00 : 5.9% , 7.9% , 9.3% , 11% , 12%
系数 1.30 : 6.6% , 8.8% , 10%  , 12% , 13%
系数 1.50 : 7.0% , 9.3% , 11%  , 13% , 14%
```

用源码原式 `combatTalentLimit(t,100,6.6,13)` 在 `tl = 系数 × 等级` 处求值，再做 **2 位有效数字**格式化
（`Number.prototype.toPrecision(2)` / Python `%.2g`；注意 `7.0` 保留 `.0` 而 `11/13/14` 丢掉 `.0`，正是 `%.2g` 的行为）：

| 系数 | 等级 | tl | 算得 | 2 位有效数字 | 导出 | |
| --- | --- | --- | --- | --- | --- | --- |
| 1.00 | 1..5 | 1/2/3/4/5 | 5.9382 / 7.8803 / 9.3432 / 10.5585 / 11.6156 | 5.9 / 7.9 / 9.3 / 11 / 12 | 5.9 / 7.9 / 9.3 / 11 / 12 | ✅ |
| 1.30 | 1..5 | 1.3/2.6/3.9/5.2/6.5 | 6.6000 / 8.7955 / 10.4451 / 11.8125 / 13.0000 | 6.6 / 8.8 / 10 / 12 / 13 | 6.6 / 8.8 / 10 / 12 / 13 | ✅ |
| 1.50 | 1..5 | 1.5/3/4.5/6/7.5 | 6.9970 / 9.3432 / 11.1033 / 12.5606 / 13.8247 | 7.0 / 9.3 / 11 / 13 / 14 | 7.0 / 9.3 / 11 / 13 / 14 | ✅ |

**15/15 字面串全部对上**（不是近似，是逐串相等）。所以源码公式 `["talentLimit",100,6.6,13]` 就是导出所用的公式，
旧报告里「导出 11 / 算得 11.1033 ❌」是拿 `%0.1f` 去读一个 `%.2g` 渲染串。

### 为什么仍然写不进去（可证明的不可满足）

工具按 **acronym 级固定精度**比较：该 acronym 有 `5.9/9.3` 这类小数 → `precision = 1`，
于是 `matchesDisplayed` 要求每点 `|算得 − 导出| ≤ 0.05`（`scripts/lua-scaling.mjs:13`）。
但导出串是 2 位有效数字渲染，目标集自身跳变：

- 系数 1.00 等级 4 → `tl = 4.0`，导出 `11` ⇒ 要求 `f(4.0) ∈ [10.95, 11.05)`
- 系数 1.30 等级 3 → `tl = 3.9`，导出 `10` ⇒ 要求 `f(3.9) ∈ [ 9.95, 10.05)`

`Δtl = 0.1` 内要跳 1.0。任何连续函数（`talentLimit` / `combatLimit` 全族，任意 limit/low/high/mastery、任意等级口径）都不可能；
能过的写法只能是拿 `floor/ceil` 去**拟合渲染噪声**，属于硬凑，按规则不做。

本次验证规模：

1. `--talent/--arg/--expr` 试了 **18 组**：`talentLimit` 的 raw × mastery ∈ {1, 1.1, 1.2, 1.3, 1.4, 1.5, 6.5} 组合、
   `combatLimit` 等价展开（锚点 1.3/6.5 与 1/5 两种口径）、以及 limit/low/high 扰动（101 / 7 / 12.5）——**18 组全部 FAIL**。
2. 对 `talentLimit` 全族做参数搜索（网格 ~数百万组 + 随机 400 万组，`limit/low/high/mastery` 大范围）：
   15 点中最少违例数为 **7**，而源码所用 `(100, 6.6, 13, mastery 1.3)` **本身就取到这个最小值** ——
   即源码常数已经是最优解，不存在能过 15 点的另一组常数。

结论：**维持疑点，但成因改为「导出 2 位有效数字渲染 × 工具固定精度比较」的导出侧缺陷**；
`["talentLimit",100,6.6,13]` 是正确公式，不应硬凑。建议构建端对这类「同一 acronym 内小数位不一致」的梯子
按 2 位有效数字解析（或把 `%0.1f` 与 `%.2g` 两种读法都接受）。

### 附：同一现象的正例

`T_BOULDER_ROCK#0` 的导出串是 `20%, 26%, 30%, 33%, 36%`（`%0.1f%%` 的真值 20.2514/25.5391/29.6333/33.1057/36.1787
同样被 2 位有效数字截成整数），但该 acronym 5 个值**全是整数串** → `precision = 0` → 工具允许截断/四舍五入，
噪声被容差吸收，所以能 PASS。同一套 unmodeled 值里，闸门放宽解决了 `#0/#3`，而 `getPen` 卡在精度模型而非输入集合。
