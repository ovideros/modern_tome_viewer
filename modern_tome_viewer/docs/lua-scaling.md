# Lua 源码数值管线

2026-09-10 实现。构建优先使用经导出参考值校验的源码表达式；未匹配项保留原反解兜底。两类结果在 tooltip 中分别标为「源码公式」和「反解估算」。仅显示参考值的条目仍不可调。

## 当前结果

| 指标 | 改动前 | 改动后 |
| --- | ---: | ---: |
| 可重算数值 | 3313 / 3750（88.35%） | 3335 / 3750（88.93%） |
| 源码公式 | 0 | 1225 |
| 反解估算 | 3313 | 2110 |
| 仅参考值 | 437 | 415 |
| 全部可调技能 | 1304 | 1323 |
| 部分可调技能 | 197 | 184 |
| 完全不可调技能 | 106 | 100 |
| 数据构建耗时（同机最终项目实测） | 85.49 秒 | 57.84 秒 |

覆盖率表示能返回计算结果的比例，不表示所有输入下均准确。1225 条源码公式替换了 1203 条旧估算，并新增 22 条原本未解出的数值。2110 条兜底结果仍有旧算法的可辨识性限制。

## 文件与命令

- `scripts/extract-lua-coefficients.mjs`：Lua 词法扫描、块配对、纯 getter 与说明参数追踪，输出带来源的静态索引。
- `data/lua-coefficients.json`：可随项目分发的索引快照；1683 个导出技能成功定位，2423 个说明表达式候选。记录源码 hash、原始 JSON hash、DLC 来源、行号、方法参数及跳过原因。
- `scripts/lua-scaling.mjs`：候选与 acronym 输入维度、完整数值阶梯的唯一匹配。
- `src/lib/lua-formula.js`：构建和浏览器共享的封闭表达式求值器；不执行 Lua 文本，不使用 eval。
- `public/data/scaling-report.json`：每次构建生成的覆盖统计与未匹配原因；同样写入 manifest。
- `scripts/scaling.test.mjs`：解析安全边界、DLC 优先级、歧义拒绝、源码准确性及全量参考值检查。
- `scripts/generate-lua-oracle.mjs`：维护者工具，直接执行游戏 Combat.lua 中的独立公式函数，生成 `scripts/fixtures/lua-oracle.json`。

```sh
npm run data:lua        # 显式刷新索引，要求本体和三个 DLC 的源码目录齐全
npm run data            # 本地源码齐全时自动刷新；无本地本体源码时使用已分发快照
npm run test:scaling    # 不要求安装 Lua，使用真实 Lua 执行生成的测试基准
npm run check          # typecheck + test:scaling + verify + build:app + smoke
PLAYWRIGHT_BROWSERS_PATH=../.pw-browsers npm run e2e -- http://127.0.0.1:4173/

# 本地源码更新或求值器新增公式后，需检查源码变化，再重新生成对照基准：
node scripts/generate-lua-oracle.mjs ..

# 诊断旧反解路径，可指定独立输出目录；不作为默认发布产物：
node scripts/build-data.mjs --no-lua --out /tmp/tome-legacy
```

`--lua-workspace <目录>` 可指定构建所用游戏源码工作区。提取器有 `--workspace`、`--raw`、`--out` 参数。索引与原始 JSON 的 hash 不一致会中止构建，避免使用错误映射。源码仅部分安装时，自动刷新会中止；不会静默替换成残缺索引。

## 提取范围与匹配规则

1. 词法层忽略行注释、长注释、带转义的字符串、Lua 任意等号层级的长字符串；配对括号并识别函数、条件和循环块。不是完整 Lua 解释器。
2. 用 `type`、显式 `short_name`、名称候选、`source_code` 路径/行号定位导出 ID。大系和序号并非对所有辅助技能都唯一，不能只靠它们猜 ID。
3. 从说明 `info` 的 `format/tformat` 实参反向追踪简单局部变量、纯 getter、直接返回的 combat 调用、字面量算术、`math.floor/ceil/min/max`。只出现在 action 中的数值不会冒充说明公式。
4. combat 函数参数仅接受白名单内的字面量，包括有符号数字、布尔值、nil 默认值、属性名和 `"log"`。`25+self:getWil()/10`、参数内部算术、角色状态分支、跨技能依赖、power override 等不解释。
5. 每个候选必须拥有与导出 title 一致的依赖维度，使用 title 中的实际技能系数，并在**全部等级点**达到显示精度以内（整数 ±0.5）。不调整源码系数或拟合倍率。
6. 若多个不同表达式都匹配，保留兜底。特别是强度 100 时，不同 base、相同 max 的伤害曲线完全相同，不能据此挑选某个 getter。
7. 元数据保留完整表达式，包括倍率、取整、Scale 的 power/add/shift/raw、Limit 的上限/mastery、StatDamage 的递减选项。`acronyms` 原字段保留，新增可选 compact 字段 `l`；旧数据仍能加载。
8. `damDesc` 按没有额外伤害加成的参考角色处理；不模拟装备、暴击、临时效果、目标抗性和完整战斗状态。

## 公式支持

源码求值支持 `combatTalentSpellDamage`、`MindDamage`、`PhysicalDamage`、`SteamDamage`、`combatTalentScale`（含 log、raw）、`combatTalentLimit`、`combatTalentWeaponDamage`（无第二技能参数）、`combatTalentStatDamage`（含递减分支）和 `combatStatScale`。

原 `scaling-core.js` 中的反解和属性伤害近似函数保留供兼容兜底；带 `lua` 元数据的项直接进入新的求值器，不使用这些近似函数。源码 `talentScale` 正确应用技能系数；raw 选项则使用原始等级。

## DLC 与版本边界

按本次源码 init.lua 的 weight 顺序：本体 → Ashes（2）→ Cults（3）→ Orcs（10）。高优先级静态定义覆盖低优先级；同优先级重复定义视为歧义。扫描 superload/overload/hooks：被显式 `T_*` 引用或源文件路径覆盖的技能保守禁用源码候选，并记录补丁路径。

这不是游戏加载器。动态字符串索引、运行时注册/补丁和任意加载逻辑不在支持范围；若要支持新的 DLC 或源码版本，必须审查其加载行为及 Combat.lua，并重跑 Lua 对照和全量参考值测试。源码 hash 包含技能文件、init.lua、Combat.lua 与扫描的补丁文件；数值匹配能发现很多版本差异，但不能证明完整语义等价。

## 修正原反解结论

伤害公式在固定强度 P 下只有一个可辨识的幅度：

```
A = max * (base + P) / (base + 100)
```

技能等级只改变另一个乘数，因此五个等级点并不构成能唯一识别 base/max 的五个独立约束。P=100 时 base 完全消去。旧网格搜索找到的解即使重现参考曲线，也不能保证改变强度后仍正确。

火焰冲击的真实源码是 `combatTalentSpellDamage(t,10,250)`，系数 1.5 时伤害四舍五入为 `181,246,297,340,378`。其半径的源码曲线与导出阶梯不一致，本实现明确拒绝用它覆盖参考数据；持续时间则能独立匹配。不能只因同属一个技能就批量替换全部 acronym。

## 独立验证与抽样

最终回归：typecheck 无错；数值测试 40/40、verify 77/77、smoke 42/42、e2e 156/156。
对比构建前后完整数据，除 acronyms 外所有字段一致，原有可调数值无减少。
首次暂存目录数据构建为 56.47 秒，最终真实项目构建（含自动源码提取）为 57.84 秒；
相对旧管线 85.49 秒缩短约 32.3%。计时均为单次实测，不是统计基准。

直接用系统 Lua 执行游戏公式生成 1200 组基准，覆盖 9 个公式家族、技能等级 1–5、系数 0.5/1/1.5/3、强度或属性 10/100/300，并包含 raw、log、递增/递减上限等选项。日常 Node 测试逐一对照，误差阈值为相对 1e-10（小数值使用绝对 1e-10）。

固定随机种子 `20260910`，按 hash 排序抽取五个不同技能的已匹配说明数值，全部五点与导出一致：

| 技能 ID | 导出值 | 来源 |
| --- | --- | --- |
| T_MIND_STORM | 2, 3, 4, 5, 6 | 本体 psionic/discharge.lua:20 |
| T_VOLCANIC_ROCK | 23, 30, 35, 39, 43 | 本体 spells/deeprock.lua:64 |
| T_PSIONIC_FOG | 3, 5, 6, 7, 8 | Orcs psionic/psionic-fog.lua:145 |
| T_SUN_BEAM | 2, 3, 3, 4, 4 | 本体 celestial/sun.lua:21 |
| T_CORRUPTED_NEGATION | 84, 115, 138, 158, 176 | 本体 corruptions/blight.lua:50 |

这些是每个抽样技能中的一个数值，不表示该技能全部数值均获得源码支持。除此以外，所有源码匹配条目的所有参考点都经过自动校验。

## 整数显示读法（`%d` 截断 / `%.0f` 四舍五入）

导出不记录格式说明符，而 Lua 的 `%d` 向零截断、`%.0f` 四舍五入；这决定滑条滑到非采样点时显示什么。
阶梯本身能给出证据：某点预测值为小数且两种读法结果不同时即唯一确定说明符
（被捕猎 4.571→4＝`%d`，初现光芒 33.967→34＝`%.0f`）。
`integerRounding()` 取单条证据，`resolveIntegerRounding()` 按 `file:line`（同一次 `tformat` 调用共用格式串）
让无证据的值继承兄弟值的结论，并要求继承后仍能复现整条阶梯，否则放弃、按四舍五入显示。
结论随 wire 的 `l.rounding` 下发。当前 2237 条源码值：1245 `trunc`、550 `round`、389 无证据、53 条带小数。
回归测试 `every source value re-renders its own ladder exactly as exported` 断言
「渲染字符串 == 导出值」全量成立（>2200 条），比容差判定更强。

## 表达式语言范围（本轮扩展）

白名单新增：`math.sqrt/abs/log/log10/exp/pow`；`self:combatSpellpower(mind/Physical/Steam)` 四类有效强度
（分字段存放）；通用 `combatScale`/`combatLimit`；`self:getMag()` 等属性与 `getParadox`/`getPsi`/`getHate` 资源；
`self:getTalentLevel(self.T_X)`（绑定到标题参数，否则按导出基准 0）；条件倍率
`self:attr("x") and 2 or 1` 与 getter 的 `if <可选参数> then A else B end`。

匹配规则也统一为"标题声明的输入集合 == 公式消耗的输入集合"（轴除外），
其中属性/资源/他技能等级这类 actor 查询只要标题钉住就算已定，不再一律拒绝。

伤害辅助函数的第 4 个参数（power override）改为表达式，于是时序系的
`getParadoxSpellpower(self, t, mod)` 可以建模为 `raw × mod × PMod(paradox)`，
其中 `PMod = bound(sqrt(paradox/300), 0.5, 1.5)`（chronomancer.lua:153）。
PMod 在 paradox = 675 处打满 +50%，这也是 UI 里 paradox 滑条的上限（悖论本身无上限）。

解析器另修三处：`uberTalent{` / `newInscription{` 从未被识别（少 48 条数值）、
无索引的 `type = {"tree", }` 与未加引号的 `short_name = X`（整块被静默丢弃）、
以及 `ACTOR_STAT_LABELS` 漏定义导致属性通道一直不通。
DLC patch 的判定改为"真的定义或赋字段才算 patch"，此前的 26 个受影响技能全是误报。

## 后续工作

优先研究 reference mismatch：确认导出器如何处理 radius、mastery、取整和说明变换，再扩展有源码依据的解析模式。随后处理多个局部变量赋值、简单 getter 局部变量、属性阶梯、跨技能依赖和动态 DLC 补丁。不要通过放宽匹配容差或任选同曲线候选来提升覆盖率，也不能承诺只提取系数就达到 100%。
