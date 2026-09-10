# 覆盖层报告 · `uber/cunning`

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/uber__cunning.json`
结果：**2/2 通过**（目标 15 条；其余 13 条被「双轴标题」闸门挡住，读懂了公式也过不了工具，见「无法建模」）

批次文件：`data/overlay-batches/uber__cunning.json`（只有 PASS 的条目；每条一跑出 PASS 即写盘）

## 已完成

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_TRICKY_DEFENSES | #0 | `["*",100,["statScale","cun",0.1,0.5]]` | `tome-src-full/data/talents/uber/cun.lua:77` | ✅ |
| T_MASTER_OF_DISASTERS | #0 | `["floor",["+",20,["/",["*",60,["actor","灵巧"]],100]]]` | `dlc-src/orcs/tome-orcs/data/talents/uber/cun.lua:25` | ✅ |

- `T_TRICKY_DEFENSES`：`shieldmult = self:combatStatScale("cun", 0.1, 0.5)`，`info` 里 `tformat(t.shieldmult(self)*100)`。
  导出 10/20/32/42/50%，`["*",100,…]` 后用 `%d` 截断读法命中（25→20.7505→20、50→32.866→32）。
- `T_MASTER_OF_DISASTERS`：`getPower = math.floor(20 + self:getCun(60))`。
  `getCun(60)` 是属性百分比缩放（灵巧 × 60/100），10/25/50/75/100 → 26/35/50/65/80 精确命中。
  该技能源码在 **DLC**（`dlc-src/orcs/…`），所以 `--list` 的「源码」列显示 `无记录`。

## 发现的写法模式

1. **`self:combatStatScale("cun", low, high, power)` → `["statScale","cun",low,high,power]`**。
   `uber/cunning` 的被动数值几乎全部来自它（本批 15 条里有 13 条的轴是灵巧）；`power` 省略时默认 `0.5`。
   代表技能：`T_TRICKY_DEFENSES`（`0.1,0.5`）、`T_ENDLESS_WOES` 的 `getDamage`（`10,350`）。
2. **整族 `getXxx(self, t)` getter + `info` 里的 `tformat(...)` 位置 = acronym 序号**。
   `T_ENDLESS_WOES` 的 `info`（cun.lua:205）一口气排了 10 个参数，
   `T_ELEMENTAL_SURGE`（cun.lua:368）排了 7 个；导出**只保留会变的值**，恒定参数（`radius=3`、`getFire()=30`、
   `getLight()=20`、`math.max(100, getCun())=100`）在 acronym 列表里被跳过，所以导出序号比 Lua 参数序号少。
   读源码时不能按「第 N 个 `%d`」硬对，要看导出的 5 个数字反查是哪个 getter。
3. **`self:getXxx(N)` 的属性百分比缩放**：`getCun(60)` = 灵巧 × 60/100（`getStat(stat, sc)`）。
   表达式写 `["/",["*",60,["actor","灵巧"]],100]`（或用 `0.6`，两者都 15/15）。
   代表技能：`T_MASTER_OF_DISASTERS`。
4. **`math.floor(...)` 照抄**：`T_MASTER_OF_DISASTERS` 的 `floor(20 + …)` 是必需的（不 floor 会差 0～1）。
5. **`util.bound(x, 0, 50)` → `["min",50,x]`**（`T_ENDLESS_WOES` 的 `getMind`，本批被闸门挡住）。
6. **这些 uber 被动的三套导出数字完全相同**，因为 getter 只读属性/等级，**不读技能等级**；
   所以表达式里不需要 `["talentLevel"]`（`T_MASTER_OF_DISASTERS` 甚至没有 `点数`/等级轴）。
   注意工具把这类值的三行都打印成「系数 1.5」——导出 title 里没有「技能系数」参数，`coefficient` 回落到默认 1.5，
   这只是显示，不影响校验（三套数字本来就一样）。

## 无法建模

**13 条：`T_ENDLESS_WOES #0–#8`、`T_ELEMENTAL_SURGE #0–#3`。**

原因**不是公式写不出来，而是 `scripts/try-formula.mjs` 的轴判定**：这些 acronym 的 title 同时给出
**两条 5 值 ladder**——`灵巧 10, 25, 50, 75, 100` 与 `角色等级 1, 10, 25, 40, 50`：

> `title="以下状况的数值<br>灵巧 10, 25, 50, 75, 100,<br>角色等级 1, 10, 25, 40, 50"`

`scripts/lua-scaling.mjs:19 ladderAxis()` 要求「只有一个参数在变」，否则返回 `null`，
而 `scripts/try-formula.mjs:85` 拿到 `null` 就**直接报 `✗ 标题里没有唯一可变的轴`，连试算都不做**——
所以这 13 条对**任何**表达式都是 FAIL，包括源码原样翻译。

**证据**：我用仓库自己的 evaluator（`src/lib/scaling-core.js` 的 `defaultSimParams` / `evaluateAcronym`
+ `scripts/lua-scaling.mjs` 的 `matchesDisplayed`）沿导出给出的**联合 ladder**（灵巧与角色等级同点一起变）
逐点代入（临时脚本写在 `/tmp/uber_check.mjs`，未改动仓库任何文件）：

| 技能id | acronym#N | 表达式（源码原样） | source | 联合 ladder |
| --- | --- | --- | --- | --- |
| T_ENDLESS_WOES | #0 | `["*",16,["actor","角色等级"]]` | cun.lua:107 `getThreshold = 16*self.level` | ✅ 15/15 |
| T_ENDLESS_WOES | #1 | `["statScale","cun",10,350]` | cun.lua:108 `getDamage` | ✅ 15/15 |
| T_ENDLESS_WOES | #2 | `["statScale","cun",10,100,0.75]` | cun.lua:101 `getAcid` | ⚠ 14/15（末点浮点，见疑点 1）|
| T_ENDLESS_WOES | #3 | `["*",5,["statScale","cun",10,100,0.75]]` | cun.lua:205 `t.getAcid(...)*5` | ⚠ 14/15（同上）|
| T_ENDLESS_WOES | #4 | `["statScale","cun",1,20,0.75]` | cun.lua:98 `getBlight` 第 1 值 | ✅ 15/15 |
| T_ENDLESS_WOES | #5 | `["statScale","cun",5,30,0.75]` | cun.lua:98 `getBlight` 第 2 值 | ✅ 15/15 |
| T_ENDLESS_WOES | #6 | `["statScale","cun",1,30,0.75]` | cun.lua:100 `getDarkness` | ✅ 15/15 |
| T_ENDLESS_WOES | #7 | `["statScale","cun",1,40,0.75]` | cun.lua:102 `getTemporal` | ✅ 15/15 |
| T_ENDLESS_WOES | #8 | `["min",50,["statScale","cun",1,40,0.75]]` | cun.lua:103 `getMind` = `util.bound(...,0,50)` | ✅ 15/15 |
| T_ELEMENTAL_SURGE | #0 | `["*",16,["actor","角色等级"]]` | cun.lua:272 `getThreshold` | ✅ 15/15 |
| T_ELEMENTAL_SURGE | #1 | `["statScale","cun",10,350]` | cun.lua:273 `getDamage` | ✅ 15/15 |
| T_ELEMENTAL_SURGE | #2 | `["statScale","cun",10,30,0.75]` | cun.lua:263 `getCold().armor` | ✅ 15/15 |
| T_ELEMENTAL_SURGE | #3 | `["statScale","cun",200,500,0.75]` | cun.lua:268 `getLightning` | ✅ 15/15 |

即 **11/13 三套 15 点全中**，2 条只差最后一个点且已定位到浮点求值顺序（疑点 1）。
这 13 条**没有进批次文件**——因为批次的硬门槛是 `try-formula.mjs` 自己的 PASS，工具给不出。

**给主项目的建议（未改任何代码）**：`ladderAxis()` 目前「多轴即放弃」，但这两条 ladder 是**同一支联合阶梯**
（导出就是按 `(灵巧, 等级) = (10,1) (25,10) (50,25) (75,40) (100,50)` 一起渲染的）。
可行的最小改动是：允许多轴，只要**所有 ladder 长度相同**，把它们当作**联合点**依次代入
（`simAtAxis` 对每个参数各自取第 i 个值），仍能保住「5 点 × 3 套」的证据强度。
现在这一整类（双轴被动，全库应不止这 13 条）在工具里是永久 FAIL，与公式对错无关。

## 疑点

1. **`statScale` 节点的浮点求值顺序与游戏 `combatStatScale` 不同，在 ladder 端点会差 1（`%d` 截断后）。**
   - 游戏 `tome-src-full/mod/class/interface/Combat.lua:1574`：
     `m = (high-low)/(x_high_adj-x_low_adj); b = low - m*x_low_adj; return m*stat_adj + b + add`
   - 覆盖层节点 `src/lib/lua-formula.js:104`：
     `slope*(transform(x) - lo) + low + add`（代数等价，浮点不等价）
   - 实测（stat = 100）：

     | (low,high,power) | Lua 序 | `%d` | JS 节点 | `%d` |
     | --- | --- | --- | --- | --- |
     | (10,100,0.75) | 99.99999999999999 | **99** | 100 | 100 |
     | (10,350,0.5) | 350 | 350 | 350 | 350 |
     | (1,30,0.75) | 30 | 30 | 30 | 30 |
     | (1,40,0.75) | 40 | 40 | 40 | 40 |
     | (10,30,0.75) | 30 | 30 | 30 | 30 |
     | (200,500,0.75) | 500 | 500 | 500 | 500 |

   - 症状：`T_ENDLESS_WOES #2` 末点（灵巧 100）导出 **99**，节点算得 **100**；
     `#3` 同理导出 **499**（= trunc(5 × 99.9999…)），算得 **500**。
     其余 4 个点三套全中（10/29/55/78 与 50/146/278/393）。
     注意只有 `(10,100,0.75)` 这一组踩到边界，`(1,30,0.75)`、`(1,40,0.75)` 都不踩——所以不是取整层不同，是浮点序。
   - 建议：把 `statScale`（以及同族的 `talentScale`/`combatScale`）改成 Lua 的 `m*x+b` 求值序，
     或对端点做 `1e-9` 容差后再取整。**本批没有为了过闸门而塞 `-1e-9` 之类的私货**（而且即使塞了也过不了轴闸门）。

2. **导出 title 对 `角色等级` 的声明是按整个技能并集的，不是按 acronym。**
   `T_ENDLESS_WOES` 的 9 个 acronym 里只有 #0（阈值）真的消费 `角色等级`，
   其余 8 个只消费灵巧，但 title 一律声明两者。即便轴判定修好，
   `declaredInputs` 的「等号闸门」还会把 #1–#8 判为 `[灵巧, 角色等级] vs [灵巧]` 不一致。
   这与 `chronomancy`/`spell/deeprock` 两批报告里记录的「标题过度声明输入」是同一个根因
   （见 `docs/overlay-reports/chronomancy__spacetime-folding.md` 的疑点一节），建议一并按「消耗 ⊆ 声明」放行。

3. **`T_ELEMENTAL_SURGE` / `T_ENDLESS_WOES` 的导出 acronym 序号与 Lua `tformat` 参数序号不一致**
   （恒值参数被导出省略：`radius=3`、`getFire()=30`、`getLight()=20`、`cold.dam=100`）。
   读源码对号时要靠数值反查 getter，不能数 `%d`。这不算缺陷，但值得写进解析器备注。
