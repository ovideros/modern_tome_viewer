# 覆盖层报告 · `cunning/artifice`

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/cunning__artifice.json`
结果：**`覆盖层校验：33/33 通过`**（目标 33 条；无法建模 0 条）

批次文件：`data/overlay-batches/cunning__artifice.json`（只放 PASS 的条目，每条一跑出 PASS 即写盘）

相关源码：`tome-src-full/data/talents/cunning/artifice.lua`（本大系全部 4 个技能都在这一个文件里）

## 已完成

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| `T_ROGUE_S_TOOLS` | #0 | `["talentLevel",true]` | `tome-src-full/data/talents/cunning/artifice.lua:146` | ✅ |
| `T_ROGUE_S_TOOLS` | #1 | `["+",15,["statDamage","cun",12,150]]` | `tome-src-full/data/talents/cunning/artifice.lua:620` | ✅ |
| `T_ROGUE_S_TOOLS` | #2 | `["ceil",["talentScale",3,5]]` | `tome-src-full/data/talents/cunning/artifice.lua:519` | ✅ |
| `T_ROGUE_S_TOOLS` | #3 | `["floor",["talentScale",1,6,"log",0,4]]` | `tome-src-full/data/talents/cunning/artifice.lua:520` | ✅ |
| `T_ROGUE_S_TOOLS` | #4 | `["talentScale",4,7]` | `tome-src-full/data/talents/cunning/artifice.lua:687` | ✅ |
| `T_ROGUE_S_TOOLS` | #5 | `["*",["weaponDamage",1,1.8],100]` | `tome-src-full/data/talents/cunning/artifice.lua:305` | ✅ |
| `T_ROGUE_S_TOOLS` | #6 | `["+",["statScale","cun",10,200,0.7],["talentScale",20,200,0.7]]` | `tome-src-full/data/talents/cunning/artifice.lua:427` | ✅ |
| `T_ROGUE_S_TOOLS` | #7 | `["+",["+",["*",["/",45,["-",["^",100,0.75],["^",10,0.75]]],["^",["actor","灵巧"],0.75]],["-",5,["*",["/",45,["-",["^",100,0.75],["^",10,0.75]]],["^",10,0.75]]]],["+",["*",["/",45,["-",["^",5,0.75],["^",1,0.75]]],["^",["talentLevel"],0.75]],["-",5,["*",["/",45,["-",["^",5,0.75],["^",1,0.75]]],["^",1,0.75]]]]]` | `tome-src-full/data/talents/cunning/artifice.lua:430` | ✅ |
| `T_ROGUE_S_TOOLS` | #8 | `["floor",["talentScale",1,3,"log"]]` | `tome-src-full/data/talents/cunning/artifice.lua:432` | ✅ |
| `T_CUNNING_TOOLS` | #0 | `["talentLevel",true]` | `tome-src-full/data/talents/cunning/artifice.lua:146` | ✅ |
| `T_CUNNING_TOOLS` | #1 | `["+",15,["statDamage","cun",12,150]]` | `tome-src-full/data/talents/cunning/artifice.lua:620` | ✅ |
| `T_CUNNING_TOOLS` | #2 | `["ceil",["talentScale",3,5]]` | `tome-src-full/data/talents/cunning/artifice.lua:519` | ✅ |
| `T_CUNNING_TOOLS` | #3 | `["floor",["talentScale",1,6,"log",0,4]]` | `tome-src-full/data/talents/cunning/artifice.lua:520` | ✅ |
| `T_CUNNING_TOOLS` | #4 | `["talentScale",4,7]` | `tome-src-full/data/talents/cunning/artifice.lua:687` | ✅ |
| `T_CUNNING_TOOLS` | #5 | `["*",["weaponDamage",1,1.8],100]` | `tome-src-full/data/talents/cunning/artifice.lua:305` | ✅ |
| `T_CUNNING_TOOLS` | #6 | `["+",["statScale","cun",10,200,0.7],["talentScale",20,200,0.7]]` | `tome-src-full/data/talents/cunning/artifice.lua:427` | ✅ |
| `T_CUNNING_TOOLS` | #7 | 同 `T_ROGUE_S_TOOLS` #7（Lua 运算顺序展开） | `tome-src-full/data/talents/cunning/artifice.lua:430` | ✅ |
| `T_CUNNING_TOOLS` | #8 | `["floor",["talentScale",1,3,"log"]]` | `tome-src-full/data/talents/cunning/artifice.lua:432` | ✅ |
| `T_INTRICATE_TOOLS` | #0 | `["talentLevel",true]` | `tome-src-full/data/talents/cunning/artifice.lua:146` | ✅ |
| `T_INTRICATE_TOOLS` | #1 | `["+",15,["statDamage","cun",12,150]]` | `tome-src-full/data/talents/cunning/artifice.lua:620` | ✅ |
| `T_INTRICATE_TOOLS` | #2 | `["ceil",["talentScale",3,5]]` | `tome-src-full/data/talents/cunning/artifice.lua:519` | ✅ |
| `T_INTRICATE_TOOLS` | #3 | `["floor",["talentScale",1,6,"log",0,4]]` | `tome-src-full/data/talents/cunning/artifice.lua:520` | ✅ |
| `T_INTRICATE_TOOLS` | #4 | `["talentScale",4,7]` | `tome-src-full/data/talents/cunning/artifice.lua:687` | ✅ |
| `T_INTRICATE_TOOLS` | #5 | `["*",["weaponDamage",1,1.8],100]` | `tome-src-full/data/talents/cunning/artifice.lua:305` | ✅ |
| `T_INTRICATE_TOOLS` | #6 | `["+",["statScale","cun",10,200,0.7],["talentScale",20,200,0.7]]` | `tome-src-full/data/talents/cunning/artifice.lua:427` | ✅ |
| `T_INTRICATE_TOOLS` | #7 | 同 `T_ROGUE_S_TOOLS` #7（Lua 运算顺序展开） | `tome-src-full/data/talents/cunning/artifice.lua:430` | ✅ |
| `T_INTRICATE_TOOLS` | #8 | `["floor",["talentScale",1,3,"log"]]` | `tome-src-full/data/talents/cunning/artifice.lua:432` | ✅ |
| `T_MASTER_ARTIFICER` | #0 | `["talentLimit",50,20,40]` | `tome-src-full/data/talents/cunning/artifice.lua:672` | ✅ |
| `T_MASTER_ARTIFICER` | #1 | `["+",30,["statDamage","cun",10,150]]` | `tome-src-full/data/talents/cunning/artifice.lua:594` | ✅ |
| `T_MASTER_ARTIFICER` | #2 | `["+",30,["statDamage","cun",15,200]]` | `tome-src-full/data/talents/cunning/artifice.lua:814` | ✅ |
| `T_MASTER_ARTIFICER` | #3 | `["+",30,["statDamage","cun",15,200]]` | `tome-src-full/data/talents/cunning/artifice.lua:814` | ✅ |
| `T_MASTER_ARTIFICER` | #4 | `["*",["weaponDamage",1.8,3],100]` | `tome-src-full/data/talents/cunning/artifice.lua:361` | ✅ |
| `T_MASTER_ARTIFICER` | #5 | `["talentScale",100,600]` | `tome-src-full/data/talents/cunning/artifice.lua:490` | ✅ |

逐条说明（acronym 序号 → getter）：

- `T_ROGUE_S_TOOLS` / `T_CUNNING_TOOLS` / `T_INTRICATE_TOOLS`（三个"工具槽"技能，数值逐字相同）
  - #0 `self:getTalentLevelRaw(t)`（`info`，artifice.lua:146/179/212）
  - #1 Dart Launcher `getDamage`（:620）
  - #2 Smokescreen `getDuration`（:519）/ #3 `getSightLoss`（:520）
  - #4 Grappling Hook `range`（:687）
  - #5 Hidden Blades `getDamage`（:305）
  - #6 Rogue's Brew `getHeal`（:427）/ #7 `getStam`（:430）/ #8 `getCure`（:432）
- `T_MASTER_ARTIFICER`
  - #0 Dart Launcher Mastery `getSlow`（:672，`/100` 后又被 `short_info` `*100`）
  - #1 Smokescreen Mastery `getDamage`（:594）
  - #2 / #3 Grappling Hook Mastery `getSecondaryDamage`（:814，物理/自然两个 `damDesc` 同值）
  - #4 Assassinate `getDamage`（:361）
  - #5 Rogue's Brew Mastery `getDieAt`（:490）

## 发现的写法模式

1. **"容器技能"把别人的 `short_info` 拼进自己的说明**：三个工具槽技能的 `info` 只贡献自己的原始等级（#0），其余 8 个数字全部来自
   `artifice_tools_get_descs`（artifice.lua:67）→ `for tool_id, mt in pairs(artifice_tool_tids)` → `tool.short_info(self, tool, t)`。
   所以三套工具槽技能的 #1–#8 数字**逐字相同**，可以只推一遍、复制三份（但要按各技能的 `数据` 分别校验，本批已验证 3×9 条全过）。
2. **`short_info(self, t, slot_talent)` 的第三个参数才是驱动等级**：`tool.short_info(self, tool, t)` 里 `t` 是工具技能（`points=1`，恒为 1 级），
   `slot_talent` 是工具槽技能。`getHeal(self, slot_talent)` 等把 `slot_talent` 传进 `combatStatScale`/`combatTalentScale`，
   因此这些值随**工具槽技能的等级与系数**变化 → 表达式一律写 `["talentLevel"]`（描述所在技能的有效等级），不要写工具自己的等级。
3. **getter → 节点 的一对一映射**（本大系 100% 覆盖）：
   - `combatTalentScale(t, low, high[, power, add, shift])` → `["talentScale", low, high, power, add, shift]`
     （代表：`getDuration` = `math.ceil(...3,5)`、`getSightLoss` = `math.floor(...1,6,"log",0,4)`、Grappling `range` = `...4,7`、`getDieAt` = `...100,600`）
   - `combatTalentWeaponDamage(t, base, max)` → `["weaponDamage", base, max]`，`short_info` 里的 `%d%%` 是 `*100`
     （代表：Hidden Blades `1.0→1.8`、Assassinate `1.8→3.0`）
   - `combatStatScale("cun", low, high, power) + combatTalentScale(t, low, high, power)` → `["+",["statScale","cun",…],["talentScale",…]]`
     （代表：`getHeal` = `10→200,0.7` + `20→200,0.7`）
   - `N + combatTalentStatDamage(t,"cun",base,max)` → `["+", N, ["statDamage","cun",base,max]]`
     （代表：Dart `15+12→150`、Smokescreen Mastery `30+10→150`、Grapple Mastery `30+15→200`）
   - `combatTalentLimit(t, limit, low, high)/100*100` → `["talentLimit", limit, low, high]`（代表：Dart Launcher Mastery `getSlow`）
   - `math.floor/ceil(...)` 原样照抄成 `["floor"/"ceil", …]`。
4. **浮点运算顺序会决定整数截断**（本批唯一不能直译节点的一条）：
   `combatStatScale` 在 Lua 里是 `m*(stat+shift)^power + b + add`（`b = low - m*x_low_adj`），
   而工具里的 `["statScale",…]` 节点是 `slope*(x^power - x_low^power) + low`。两者代数等价，但在锚点 `属性=100` 上
   Lua 得 `49.99999999999999`、节点得整 `50`。`getStam`（`statScale(…,5,50,0.75) + talentScale(…,5,50,0.75)`）的两个锚点
   （tl=1、tl=5）Lua 值分别是 `54.99999999999999` / `99.99999999999999`，`%d` 截断成 **54 / 99**（导出值），
   直译节点会给整 `55 / 100`，两种读法都差 1 → FAIL。按 Lua 的运算顺序把两个 `combatXxxScale` 手工展开成
   `["^",…,0.75]` + `["-",…]` 的算式后 15/15。旁证：同族的 `getHeal` 在关键点上是 `220/400`，
   即使存在同样的浮点误差也能被"四舍五入"读法兜住，所以它直译就过——**只有两个锚点都被 `%d` 卡死时才必须展开**。

## 无法建模

**0 条。** 这个 tree 的 33 个目标全部建模成功。

最初预期"工匠的数值依赖运行时装置定义/玩家装备"，实际读下来并非如此：`cunning/artifice` 的导出数字**全部**是
`工具槽技能等级（含系数） + 灵巧` 的确定性函数——说明文本里的 tool 列表是 5 个**技能**的 `short_info`，
不是运行时数据表；`artifice_tool_tids` 只是 id 映射，`self.artifice_tools` 只影响"显示哪个工具名"（`%s`，非数字，不进 acronym）。
真正依赖运行时的部分（工具实际生效的属性、装到角色身上的 `combat_apr`/cooldown、装置投射）源码里在 `action`/`callback` 中，
导出说明文本根本不显示，因此也不在目标清单里。

## 疑点

1. **槽技能 #1–#8 的顺序与源码声明顺序不一致**。`artifice_tool_tids`（artifice.lua:27）声明顺序是
   `T_HIDDEN_BLADES, T_SMOKESCREEN, T_ROGUE_S_BREW, T_DART_LAUNCHER, T_GRAPPLING_HOOK`，
   但 `artifice_tools_get_descs` 用的是 `pairs()`（哈希序）。导出实际顺序是：
   **#1 Dart Launcher → #2/#3 Smokescreen → #4 Grappling Hook → #5 Hidden Blades → #6/#7/#8 Rogue's Brew**。
   按数字反查 getter 才可靠，不要按源码声明顺序对号入座（我一开始就按声明顺序猜过一轮，全部对不上）。
2. **`T_MASTER_ARTIFICER` 导出少一个数字**。`info`（:260）遍历 5 个 mastery 的 `short_info`，共产生 **7** 个数字：
   Assassinate 1 + Smokescreen Mastery 1 + Rogue's Brew Mastery 1 + Dart Launcher Mastery 1 + Grappling Hook Mastery **3**
   （`%d%%` 徒手倍率 + 物理 `%0.2f` + 自然 `%0.2f`）。导出只有 **6** 个 acronym，
   **缺的是 Grappling Hook Mastery 的 `getDamage*100`（`combatTalentWeaponDamage(MASTER_ARTIFICER,1.0,1.9)*100`）**，
   其余 6 个都能对上（#4 = 233%… 就是 Assassinate）。属导出侧缺项，不是公式问题，故未写进批次（写了也没有对应的 acronym 可校）。
3. **`%s` 不占 acronym 序号**。`T_MASTER_ARTIFICER` 的 `info` 第一个参数是 `%s`（当前精通的工具名），
   三个槽技能的 `info` 也是 `%d` 之后跟一大段 `%s`。acronym 序号只数**数字**，所以 #0 分别是"原始等级"/"slow%"。
4. **`灵巧` 只在部分 acronym 上声明**：槽技能 #1/#6/#7 有 `灵巧=100`，#2/#3/#4/#5/#8 没有；
   `T_MASTER_ARTIFICER` 的 #1/#2/#3 有。这正好对应 `short_info` 里哪些 getter 读了属性：
   Rogue's Brew 的 `getCure` 不读灵巧（#8 输入集合为空），Smokescreen 的持续时间/视距、Grappling 的射程、Hidden Blades 的倍率也都不读。
   写表达式时必须让消耗集合与之一致（多塞 `["actor","灵巧"]` 会 FAIL）。
5. **`["talentLevel",true]`（原始等级）只用于三个槽技能的 #0**（`getTalentLevelRaw`），三套导出数字完全相同（1/2/3/4/5）。
   其余 30 条都随系数变化（`1.00/1.30/1.50` 三套数字不同），必须用有效等级 `["talentLevel"]`。
6. **`["talentLimit",50,20,40]` 的 mastery 语义**：工具节点的 `mastery` 是字面量参数、默认 `1.3`，不随 `技能系数` 变；
   而 `combatTalentLimit` 在游戏里用的是 `getTalentMastery()`。本批恰好 15/15 通过（系数只进 `tl`，`mastery` 固定 1.3），
   但这说明**节点与游戏在该参数上并非严格等价**——若将来遇到别的技能在此 FAIL，优先怀疑这里，而不是公式读错了。
