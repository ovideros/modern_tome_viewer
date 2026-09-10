# 提示词：为 ToME4 技能数值补写公式（交给外部代理工具）

> 把下面横线以内的全部内容作为提示词发给执行代理。它自带仓库访问权与 shell。

---

## 你的角色

你是一名"读源码补公式"的工程代理。目标：把一个 ToME4 技能数值模拟器里**自动提取失败的数值**，
通过阅读游戏 Lua 源码，**手写公式表达式**补上，并用仓库里现成的工具证明你的公式是对的。

## 仓库与环境

仓库：`/Users/ovideros/Codes/senior1/modern_tome/`（以下路径都相对它）

| 路径 | 是什么 |
| --- | --- |
| `modern_tome_viewer/` | 网页项目（Vite + React），构建产物只在 `public/`、`dist/`，**你不要动源码** |
| `modern_tome_viewer/scripts/try-formula.mjs` | **你的工作台**：列目标、试算公式、批量验收 |
| `modern_tome_viewer/docs/expression-overlay.md` | **表达式节点表 + 硬性规则**（动手前必读）|
| `modern_tome_viewer/data/lua-coefficients.json` | 自动提取结果：每个技能 → 源码文件:行号、候选表达式、失败原因 |
| `modern_tome_viewer/public/data/talents.json` | 构建产物：每个技能的全部数值（`d`=导出数字，`p`=标题条件，`l`=已有源码公式）|
| `tome-src-full/`、`dlc-src/` | 游戏本体与三个 DLC 的 Lua 源码（公式在这里）|
| `starsapphirex.github.io/tometips/data/master/` | 导出数据：同一批技能在**三种系数**下各一份（`talents.*-1.json` / `-1.3` / `-1.5`）|

背景（30 秒）：网页要把技能说明里那些数字变成"拖滑条实时重算"。做法是从游戏源码里提取公式——
自动提取已经拿到 2469 条，剩下 1281 条因为写法太花（局部变量、别的技能、条件倍率、自定义 helper…）没拿到。
你要处理的就是这些。

## 验收铁律（唯一标准，不许自己判断对错）

一条公式**只有同时满足**下面两条才算通过：

1. **三套导出共 15 个点全部复现**（系数 1.00 / 1.30 / 1.50，每套 5 个点，按显示精度：整数允许"截断"或"四舍五入"其中一种读法，小数必须精确）；
2. **表达式读到的每个输入都在标题里声明过**（轴除外），即 `表达式消耗 ⊆ 标题声明`。

第 2 条**只要求覆盖，不要求用完**：导出会把整个 tooltip 的参数并集抄进多个 acronym 的 title，所以
`标题声明 [paradox, 法术强度, 魔力] vs 表达式消耗 [paradox, 法术强度]` 会显示
`✅ 覆盖（标题是超集，本值未用到：魔力）` 并判 PASS。反过来，表达式读了标题没声明的输入会被点名 FAIL
（`❌ 表达式读了标题未声明的输入 [X]`）——那时要么换成标题声明过的等价写法，要么把该量**冻结成常数**
并在 `note` 说明理由，**不要**用 `["*",0,["actor","X"]]` 之类假节点凑集合。

工具会直接告你 PASS/FAIL，并列出每个点的"导出值 / 算得值"。**不要凭印象提交。**

## 工作台用法

```sh
cd /Users/ovideros/Codes/senior1/modern_tome/modern_tome_viewer

# 1) 取目标清单（每行：技能id / 名称 / 大系 / acronym#序号 / 可投点数 / 三套导出值 / 标题参数 / 源码位置 / 记录状态）
node scripts/try-formula.mjs --list --tree chronomancy/anomalies --limit 20

# 2) 试算一个表达式
node scripts/try-formula.mjs --talent T_FLAMESHOCK --arg 1 --expr '["spellDamage",10,250]'

# 3) 批量验收你写好的覆盖层
node scripts/try-formula.mjs --overlay data/lua-expressions.json
```

试算输出示例（这是**正确**的样子）：

```
技能 T_FLAMESHOCK (火焰冲击 / spell/fire) · acronym#1
源码 tome-src-full/data/talents/spells/fire.lua:89
输入集合：标题声明 [法术强度] vs 表达式消耗 [法术强度] ✅
  系数 1   : ✅ 5/5  1→ 导出 153 / 算得 152.5143✅(四舍五入)  … 5→ 导出 312 / 算得 311.7867✅
  系数 1.3 : ✅ 5/5  …
  系数 1.5 : ✅ 5/5  …
结论：PASS（三套 15 点全中，输入集合一致）
```

失败示例（**源码与导出的取整层不同**，这种情况请不要硬凑，记入报告）：

```
技能 T_ILLUMINATION (照明 / celestial/radiance) · acronym#0
  系数 1   : ❌  1→ 导出 73 / 算得 74❌  …
  系数 1.5 : ❌  1→ 导出 84 / 算得 85❌  …
结论：FAIL
```

## 怎么做（每个值 3–8 分钟）

1. `--list` 拿到目标行；`源码: 文件:行号` 指向该技能的 `newTalent{` 块，从那里往下读到块的 `}`。
2. 找到 `info` 函数里的 `tformat(...)`，它的**参数顺序通常就对应说明文本里的 `<acronym>` 顺序**——
   `acronym#N` 的第 N 个参数就是你要写的值。注意 `info` 常把值先放进局部变量：
   `local damage = t.getDamage(self, t)` → 去读 `t.getDamage` 那个 getter。
3. `damDesc(self, DamageType.X, v)` 只是包裹（直接取 `v`）；`math.floor/ceil(...)` 要照抄成 `["floor", …]` / `["ceil", …]`。
4. 按 `docs/expression-overlay.md` 的节点表写出 JSON 表达式，用 `--talent/--arg/--expr` 迭代到 PASS。
5. PASS 后追加到 `modern_tome_viewer/data/lua-expressions.json`，`source` 字段写你据以写公式的 getter 的 `文件:行号`。
6. 每个大系做完就更新报告（见下），并把 `--overlay` 的汇总贴出来。

**技巧**：同一个大系里往往是同一套写法反复出现（例如整个 `chronomancy/anomalies`）。
先读 2–3 个值摸清模式，后面同类值会很快；把模式记进报告的"发现的写法"一节，
方便主项目把它提升成解析器规则。

## 交付物

1. `modern_tome_viewer/data/lua-expressions.json` —— 覆盖层（数组，字段见 `docs/expression-overlay.md`）
2. `modern_tome_viewer/docs/expression-overlay-report.md` —— 报告，含四节：
   - **已完成**：`技能id | acronym#N | 表达式 | source | 三套是否 15/15`
   - **发现的写法模式**：这一批里反复出现的 Lua 写法（一句话 + 一个代表技能）
   - **无法建模**：读懂了但写不出来的，逐条给出原因（运行时数据表 / 玩家武器 / 随机数 / 别的角色状态 / 需要先解析别的技能 getter）
   - **疑点**：源码与导出数字系统性不一致的（例如"每点都差 1"），附三套数据
3. 最后一条消息里贴 `node scripts/try-formula.mjs --overlay data/lua-expressions.json` 的汇总行。

## 硬性禁止

- **不许硬编码输入**：标题声明为输入的东西（技能等级、法术强度、paradox、属性……）必须用节点表里的写法读取；
  写死数字会在"输入集合"检查里直接 FAIL。
- **不许无视轴**：表达式必须随该数值自己的轴变化（工具会沿轴试算，恒定值不可能 PASS）。
- **不许发明节点**：只能用 `docs/expression-overlay.md` 里列出的节点。
- **不许修改代码**：`src/**`、`scripts/**`、`public/**`、`data/raw/**`、`data/lua-coefficients.json` 一律只读；
  你只新增/修改上面两个交付物。
- **不许编**：属于"无法建模"的情况，如实记入报告，不要为了凑数硬写。

## 建议批次（先做未匹配最多的大系，每批 ≤30 条）

```
cunning/artifice 33   cunning/traps 32   chronomancy/anomalies 29   chronomancy/other 28
technique/other 24    psionic/voracity 21   corruption/demon-seeds 16   uber/cunning 15
psionic/other 14      spell/other 14     wild-gift/summon-melee 14   cursed/shadows 13
spell/deeprock 13     chronomancy/spacetime-folding 12
```

建议第一站：`chronomancy/anomalies`（29 条、同一文件、写法重复）。
每批结束后把覆盖层与报告提交给我方复核——覆盖层不会被我方盲信：
构建时会用同一套校验重新跑一遍，过不了的条目会被丢弃并报告。
