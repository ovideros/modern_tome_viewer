# 覆盖层报告：`technique/other`

- 目标数：**24** 条 acronym（`node scripts/try-formula.mjs --list --tree technique/other`）
- PASS：**13** 条（写入 `data/overlay-batches/technique__other.json`）
- 无法建模 / 未通过：**11** 条（见下两节）
- 批次自检：`node scripts/try-formula.mjs --overlay data/overlay-batches/technique__other.json`
  → `覆盖层校验：13/13 通过`

## 已完成（每条均 `结论：PASS（三套 15 点全中，输入集合一致）`）

| 技能id | acronym | 表达式 | source | 三套 |
| --- | --- | --- | --- | --- |
| `T_BODY_SHOT` | #0 | `["*",100,["weaponDamage",1.1,1.8]]` | `tome-src-full/data/talents/misc/npcs.lua:2293` | 15/15 |
| `T_BODY_SHOT` | #1 | `["*",2,["talentLevel"]]` | `tome-src-full/data/talents/misc/npcs.lua:2328` | 15/15 |
| `T_BODY_SHOT` | #2 | `["ceil",["*",0.25,["talentScale",1,5]]]` | `tome-src-full/data/talents/misc/npcs.lua:2294` | 15/15 |
| `T_BODY_SHOT` | #3 | `["ceil",["*",1.25,["talentScale",1,5]]]` | `tome-src-full/data/talents/misc/npcs.lua:2294` | 15/15 |
| `T_MAIM` | #0 | `["physicalDamage",10,100]` | `tome-src-full/data/talents/misc/npcs.lua:2382` | 15/15 |
| `T_BLOODRAGE` | #0 | `["floor",["*",6,["talentLevel"]]]` | `tome-src-full/data/talents/misc/npcs.lua:2439` | 15/15 |
| `T_COMBO_STRING` | #0 | `["combatLimit",["*",["+",5,["/",["*",["actor","灵巧"],5],100]],["talentLevel"]],100,0,0,50,50]` | `tome-src-full/data/talents/misc/npcs.lua:2344` | 15/15 |
| `T_RELAXED_SHOT` | #1 | `["+",12,["*",8,["talentLevel"]]]` | `tome-src-full/data/talents/techniques/archery.lua:735` | 15/15 |
| `T_GNASHING_MAW` | #1 | `["*",3,["talentLevel"]]` | `dlc-src/orcs/tome-orcs/data/talents/misc/npcs.lua:83` | 15/15 |
| `T_THROW_PEEBLE` | #0 | `["combatScale",["*",["actor","力量"],["talentLevel"]],12,0,262,500]` | `dlc-src/cults/tome-cults/data/talents/misc/misc.lua:319` | 15/15 |
| `T_VENOMOUS_AMMUNITION` | #0 | 见批次文件（power 家族手工展开，等级用 `["talentRef","T_EXOTIC_MUNITIONS"]`） | `tome-src-full/data/talents/techniques/munitions.lua:219` | 15/15 |
| `T_VENOMOUS_THROW` | #0 | 见批次文件（statDamage 手工展开，等级用 `["talentRef","T_VENOMOUS_STRIKE"]`） | `tome-src-full/data/talents/cunning/poisons.lua:301` | 15/15 |
| `T_VENOMOUS_THROW` | #1 | 同 #0 的表达式（Leeching Poison 用的同一 `getSecondaryDamage`） | `tome-src-full/data/talents/cunning/poisons.lua:301` | 15/15 |

说明：`getUnarmedTrainingBonus(self)`（`T_MAIM` / `T_ROUNDHOUSE_KICK`）在导出基准角色上没有 Unarmed Mastery（等级 0，`getPercentInc = sqrt(tl/5)/1.5 = 0`），所以倍率恰为 1，不额外乘因子。

## 发现的写法模式

1. **`combatTalentWeaponDamage` 直接映射**：`self:combatTalentWeaponDamage(t, base, max)` → `["weaponDamage", base, max]`；info 里 `*100` 就写 `["*",100,…]`。
   代表：`T_BODY_SHOT` #0（`npcs.lua:2293`）。
2. **`combatTalentScale` 默认 `power = 0.5`（√ 曲线，不是线性）**：工具节点已有同一个默认值，直接 `["talentScale", low, high]` 即可；外层 `math.ceil/floor` 照抄成 `["ceil"]`/`["floor"]`。
   代表：`T_BODY_SHOT` #2/#3（`getDuration` 里 `combatTalentScale(t,1,5) * (0.25 + comb/5)`）。若误当线性会把中间点算错。
3. **`combatLimit(x, 100, 0, 0, 50, 50)` = 把 x 线性推到 50 再渐近 100**，可直接用 `["combatLimit", x, 100, 0, 0, 50, 50]`。
   代表：`T_COMBO_STRING` #0 / `T_DEFENSIVE_THROW` `getchance`（`npcs.lua:2344`）。
4. **`getCun(5, true)` 这类带 `raw` 的属性读取 = 属性 × 倍率 / 100**：`self:getCun(5, true)` 在 `灵巧=100` 时是 5，写成 `["/",["*",["actor","灵巧"],5],100]`。
   代表：`T_COMBO_STRING` #0。
5. **三套数字完全相同的值 = 按“别的技能等级 / 原始等级”算**：`["talentLevel", true]` 或 `["talentRef", 别的技能]`。
   代表：`T_VENOMOUS_THROW`（用 `T_VENOMOUS_STRIKE` 的等级）、`T_VENOMOUS_AMMUNITION`（用 `T_EXOTIC_MUNITIONS` 的等级）。
6. **`callTalent(T_X, "getY")` 链**：`getY` 用的是 `T_X` 自己的等级，导出基准为 0。工具里写 `["talentRef","T_X"]` 即得 0；但 `statDamage` / power 家族节点只吃“本技能的等级”，此时按 `docs/expression-overlay.md`「已验证的等价展开」把公式手工展开、把 `L` 换成 `talentRef`。
   代表：`T_VENOMOUS_THROW` #0/#1（`combatTalentStatDamage(t,"cun",50,550)` @ `T_VENOMOUS_STRIKE` 等级 0）、`T_VENOMOUS_AMMUNITION` #0（`combatTalentPhysicalDamage(t,20,180)` @ `T_EXOTIC_MUNITIONS` 等级 0）。
7. **双输入驱动用 `combatScale` 的 driver 表达式**：`combatScale(self:getStr() * self:getTalentLevel(t), 12, 0, 262, 500)` → `["combatScale",["*",["actor","力量"],["talentLevel"]],12,0,262,500]`。
   代表：`T_THROW_PEEBLE` #0（`misc.lua:319`）。
8. **纯等级线性值的取整层**：`self:getTalentLevel(t) * k` 直接写 `["*",k,["talentLevel"]]`，需要 `floor`/`ceil` 时照抄；导出是 `%d` 截断还是 `%.0f` 四舍五入由工具按 15 点自动认一种。
   代表：`T_BODY_SHOT` #1、`T_BLOODRAGE` #0、`T_GNASHING_MAW` #1、`T_RELAXED_SHOT` #1。
9. **`damDesc(self, DT, v)` 是纯包裹**，取 `v`；`%d%%` 的百分比若源码已是 `*100` 就照写。

## 无法建模

| 技能id | acronym | 原因 |
| --- | --- | --- |
| `T_DEFENSIVE_THROW` | #3 | 标题同时给出 4 条并列 ladder（力量 / 敏捷 / 灵巧 / physical power 各 `10/25/50/75/100`），`ladderAxis` 找不到唯一可变的轴，工具三套都直接报 `标题里没有唯一可变的轴`，无法验收。源码 `getThrows = combatScale(getStr()+getDex()-20, 0,0, 2.24, 180)`（`npcs.lua:3379`）本身已读懂（手工算得 0 / 0.9145 / 1.4936 / 1.9038 / 2.24，与导出 0 / 0.9 / 1.5 / 1.9 / 2.2 完全一致），但工具吃不了多 ladder。 |
| `T_STEADY_MIND` | #0、#1 | **标题过度声明输入**：标题把`敏捷`与`灵巧`同时列为输入，但 info 第 0 个值只吃 `dex`（`getDefense`），第 1 个只吃 `cun`（`getMental`）。表达式分别为 `["statDamage","dex",5,35]` / `["statDamage","cun",5,35]`，15 点数值全中，但输入集合判定 `[敏捷, 灵巧] vs [敏捷]`（或 `[灵巧]`）必然不一致。按规范不硬塞节点凑集合。 |
| `T_DEFENSIVE_THROW` | #0、#1、#2 | 同上（标题声明 `physical power, 力量, 敏捷, 灵巧` 四项，实际 #0 只用 `灵巧`，`getchance = combatLimit(tl*(5+getCun(5,true)),100,0,0,50,50)`；#1/#2 只用 `physical power`，`combatTalentPhysicalDamage(t,5,50)` / `(t,10,75)`）。三条 15 点数值全中、表达式分别是 `["combatLimit",…]`、`["physicalDamage",5,50]`、`["physicalDamage",10,75]`，但输入集合过不了。 |
| `T_CRIPPLING_SHOT` | #1 | 源码用 `self:combatAttack()`（导出把该输入命名为`精准=100`），但导出把 `精准` 的类型标成 `other`，`declaredInputs()` 只认 `stat`/`power`/含「等级」的标签，于是标题声明被算成 `[]`。用 `["actor","精准"]` 读则 15 点数值全中（15/30/40/40/40 等）但消耗集合 `[精准]` 与声明 `[]` 不一致；写死常数 100 虽能过闸门却属硬编码输入，不做。 |
| `T_VENOMOUS_AMMUNITION` | #1 | **导出侧精度自相矛盾**：同一 acronym 内前两点是 2 位小数（`4.81, 7.33`），后三点是整数（`12, 16, 20`）。底层值其实是 `damage = combatTalentPhysicalDamage(T_EXOTIC_MUNITIONS, 20, 180)`（等级 0）= `4.8069 / 7.3282 / 11.6028 / 15.9401 / 20.3239`，若统一按 0 位读 5 点全中；但解析出的 precision=2，要求逐点精确到 2 位，`11.6028 ≠ 12`，无法通过。（其 `/5` 的 #0 已 PASS。） |

## 疑点（源码与导出在舍入边界上系统性不一致）

以下 3 条**只差最后一点、差量 ≤ 0.005**，公式本身在其余 14 点全中；失败原因是导出在 `.5` 边界上向上取整，而模型算得略低于 `.5`。

| 技能id | acronym | 系数 1.5 的第 3/末点 | 三套 |
| --- | --- | --- | --- |
| `T_ROUNDHOUSE_KICK` | #0 | `getDamage = combatTalentPhysicalDamage(t,15,150)*getUnarmedTrainingBonus`，展开为 `["physicalDamage",15,150]`。系数 1.5 第 3 点（有效等级 4.5）：**导出 175 / 算得 174.4983**（差 0.0017）。1.0 与 1.3 两套 10/10 全中。 | 14/15 |
| `T_INFECTIOUS_BITE` | #2 | `getPoisonDamage = combatTalentSpellDamage(t,12,150)`（`rot.lua:30`），展开为 `["spellDamage",12,150]`。导出数值与 `T_ROUNDHOUSE_KICK` #0 **逐点相同**（`base+100` 在归一化里约掉），同样系数 1.5 第 3 点 **导出 175 / 算得 174.4983**。 | 14/15 |
| `T_VENOMOUS_THROW` | #2 | `vdam = getSecondaryDamage*0.6`（`poisons.lua:348`），等级 0。`灵巧=100` 点：**导出 24 / 算得 23.4958**（差 0.0042；`round(23.4958)=23`，`trunc=23`，都到不了 24）。同一底层值 `39.1596` 在 #0（`%0.2f`→整数）与 #1（`%d` 截断）分别渲染成 `39 / 39`，两条已 PASS。 | 14/15 |

共因推测：导出渲染管线似乎先把值归整到 2 位小数（或 4 位有效数字）再取整——`174.4983 → 174.50 → 175`、`23.4958 → 23.50 → 24`——而校验工具用原始双精度直接取整，于是卡在边界。三者都无法在不改变输入集合、不发明节点的前提下绕过，故不计入批次。

## 其它备注

- 自动提取的 `candidates` 在这 24 条上几乎无用（多数「无候选」）；`lua-coefficients.json` 的 `file:line` 仍是定位 `newTalent{` 块最有效的入口。`T_THROW_PEEBLE` 在 `lua-coefficients.json` 里**没有记录**，其 blob 在 DLC `dlc-src/cults/.../misc.lua:310`（`short_name = "THROW_PEEBLE"`），靠 `short_name` 才能搜到。
- `technique/other` 是“混合大系”：24 条来自 6 个不同文件（本体 `misc/npcs.lua`、`techniques/archery.lua`、`throwing-knives.lua`、`munitions.lua`、`corruptions/rot.lua`、`cunning/poisons.lua`，以及 orcs/cults 两个 DLC），没有单一写法模式，逐条读 getter 不可避免。

---

# 闸门放宽后的补做

背景：判分器输入集合闸门由「相等」放宽为「覆盖」（`consumed ⊆ declared`）。原先因**标题过度声明**被拦下的条目现在可以通过；表达式读了标题未声明的量仍然 FAIL 并点名。本节补做 11 条。

- 补做数：**11**（`T_STEADY_MIND` #0 #1；`T_DEFENSIVE_THROW` #0 #1 #2 #3；`T_ROUNDHOUSE_KICK` #0；`T_CRIPPLING_SHOT` #1；`T_VENOMOUS_THROW` #2；`T_VENOMOUS_AMMUNITION` #1；`T_INFECTIOUS_BITE` #2）
- 新增 PASS：**5**
- 仍不通：**6**
- 批次文件追加后条目：**13 → 18**
- 自检：`node scripts/try-formula.mjs --overlay data/overlay-batches/technique__other.json`
  → 第一行 `覆盖层校验：18/18 通过`

## 本次新增 PASS（每条均 `结论：PASS（三套 15 点全中，输入集合覆盖）`）

| 技能id | acronym | 表达式 | source | 三套 | 标题未用到的输入 |
| --- | --- | --- | --- | --- | --- |
| `T_STEADY_MIND` | #0 | `["statDamage","dex",5,35]` | `tome-src-full/data/talents/misc/npcs.lua:2359` | 15/15 | 灵巧 |
| `T_STEADY_MIND` | #1 | `["statDamage","cun",5,35]` | `tome-src-full/data/talents/misc/npcs.lua:2360` | 15/15 | 敏捷 |
| `T_DEFENSIVE_THROW` | #0 | `["combatLimit",["*",["talentLevel"],["+",5,["/",["*",["actor","灵巧"],5],100]]],100,0,0,50,50]` | `tome-src-full/data/talents/misc/npcs.lua:3376` | 15/15 | physical power, 力量, 敏捷 |
| `T_DEFENSIVE_THROW` | #1 | `["physicalDamage",5,50]` | `tome-src-full/data/talents/misc/npcs.lua:3373` | 15/15 | 力量, 敏捷, 灵巧 |
| `T_DEFENSIVE_THROW` | #2 | `["physicalDamage",10,75]` | `tome-src-full/data/talents/misc/npcs.lua:3374` | 15/15 | 力量, 敏捷, 灵巧 |

要点：

1. `T_STEADY_MIND` **标题确实把 `敏捷` 与 `灵巧` 并列声明**，但 `getDefense` 只吃 `dex`、`getMental` 只吃 `cun`。放宽后 `["statDamage","dex",5,35]` / `["statDamage","cun",5,35]` 分别判为「覆盖（标题是超集，本值未用到：灵巧/敏捷）」。这是本次放宽直接救回的两条，与原报告判断一致，**无须**为凑集合硬塞另一个属性。
2. `T_DEFENSIVE_THROW` #0/#1/#2 **同属“标题过度声明”**：标题声明 `physical power, 力量, 敏捷, 灵巧` 四项，实际 #0 只用 `灵巧`（`getchance`）、#1/#2 只用 `physical power`（`getDamage` / `getDamageTwo`）。三条 15 点全中。
3. `getUnarmedTrainingBonus(self)` 在导出基准角色上恒为 1（无 Unarmed Mastery，`getPercentInc = sqrt(tl/5)/1.5 = 0`），故 #1/#2 不再乘额外因子；与原报告中 `T_MAIM`/`T_ROUNDHOUSE_KICK` 的处理一致。

## 仍然不通（6 条，逐条给出实测）

### A. 工具侧：标题没有唯一可变的轴（1 条）

| 技能id | acronym | 现象 |
| --- | --- | --- |
| `T_DEFENSIVE_THROW` | #3 | 标题同时给 `力量 / 敏捷 / 灵巧 / physical power` **四条并列 ladder**（各 `10/25/50/75/100`），`ladderAxis` 找不到唯一轴，三套一律报 `✗ 标题里没有唯一可变的轴`，任何表达式都无法验收。源码 `getThrows = self:combatScale(self:getStr() + self:getDex()-20, 0, 0, 2.24, 180)`（`npcs.lua:3379`）已读懂，手工算得 `0 / 0.9145 / 1.4936 / 1.9038 / 2.24`，与导出 `0 / 0.9 / 1.5 / 1.9 / 2.2` 相符，但工具吃不了多 ladder。本轮仍**无法建模**，原报告结论不变。 |

### B. 安全半边：读了标题未声明的输入（1 条）

| 技能id | acronym | 现象 |
| --- | --- | --- |
| `T_CRIPPLING_SHOT` | #1 | 源码 `util.bound(self:combatAttack() * 0.15 * self:getTalentLevel(t) / 100, 0.1, 0.4) * 100`（`archery.lua:761`）。表达式 `["*",100,["min",0.4,["max",0.1,["/",["*",["*",["actor","精准"],0.15],["talentLevel"]],100]]]]` **15 点数值全中**（15/30/40/40/40、19.5/39/40/40/40、22.5/40/40/40/40，截断读法），但 `["actor","精准"]` 会让工具报 `❌ 表达式读了标题未声明的输入 [精准]`：导出把 `精准` 的 `kind` 标成 `other`，`declaredInputs()` 只认 `stat`/`power`/含「等级」的标签，于是声明集合被算成 `[]`。写死 `100` 属硬编码输入，按规范不做。**如实记为无法建模（导出侧元数据缺陷）**。 |

### C. `.5` 边界：导出两段取整 vs 工具单段取整（4 条）

本轮补做了原始数值验证，**进一步坐实**了原报告「共因推测」：导出渲染管线是**先归整到 2 位小数、再按量级取整**，而工具直接用原始双精度取整。

| 技能id | acronym | 表达式（数值 14/15 全中） | source | 失败点 |
| --- | --- | --- | --- | --- |
| `T_ROUNDHOUSE_KICK` | #0 | `["physicalDamage",15,150]` | `npcs.lua:3420` 块内 `getDamage` | 系数 1.5 第 3 点：导出 `175` / 算得 `174.4983` |
| `T_INFECTIOUS_BITE` | #2 | `["spellDamage",12,150]` | `corruptions/rot.lua:30` | 同上，导出 `175` / 算得 `174.4983` |
| `T_VENOMOUS_THROW` | #2 | `0.6 × <#0 的 statDamage 展开>` | `cunning/poisons.lua:324`（`vdam = getSecondaryDamage*0.6`） | `灵巧=100` 点：导出 `24` / 算得 `23.4958` |
| `T_VENOMOUS_AMMUNITION` | #1 | `5 × <#0 的 power 家族展开>`（`getPoisonDamage`，等级 0） | `techniques/munitions.lua:160` | 导出 `4.81/7.33/12/16/20` / 算得 `4.8069/7.3282/11.6028/15.9401/20.3239`，后三点全差 |

`T_VENOMOUS_AMMUNITION` #1 是本轮**最强的直接证据**：**同一个 acronym 内部精度自相矛盾**——`4.81, 7.33`（<10，保留 2 位小数）与 `12, 16, 20`（≥10，归整到整数），而底层是同一公式的连续值。用「先 `round2` 再按 ≥10 取整」重放导出管线，5 点全部命中（`11.6028 → 11.60 → 12`、`15.9401 → 15.94 → 16`、`20.3239 → 20.32 → 20`）。同理 `174.4983 → 174.50 → 175`、`23.4958 → 23.50 → 24`。

**关于「是否可以用表达式模拟导出取整来过关」**：技术上可行（节点表里 `+ - * / floor min max` 足够拼出「两段取整」，用 `min(1,floor(v/10))` 当 ≥10 的阶跃开关），但那样写出来的**不是游戏公式，而是导出渲染器的取整伪影**，属于为迁就校验器而硬凑，且会在构建端被当成“真实公式”固化。因此本轮**明确不做**，按规范记入疑点；这 4 条保持 14/15 不计入批次。

## 本次结论汇总

- `T_STEADY_MIND` #0/#1、`T_DEFENSIVE_THROW` #0/#1/#2 共 **5 条** 已追加进 `data/overlay-batches/technique__other.json`（13 → 18），`--overlay` 第一行：`覆盖层校验：18/18 通过`。
- 剩余 6 条为 **1 条工具多-ladder 缺陷 + 1 条导出元数据缺陷（`精准` kind=other）+ 4 条导出两段取整边界**，均无法在不改节点、不硬编码、不模拟渲染伪影的前提下通过，如实保留为疑点/无法建模。
