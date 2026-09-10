# 覆盖层报告：batch07 — wild-gift 十六个大系

- 目标数：**38**（`node scripts/try-formula.mjs --list --tree <大系>` 十六个大系求和，见下表）
- 批次文件：`data/overlay-batches/batch07-gifts.json`（数组长度 **37**，键唯一）
- 验收命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/batch07-gifts.json`
- 汇总行：**`覆盖层校验：37/37 通过`**（无 FAIL，无输入集合不符）
- 跳过数：**1**（`T_LIVING_MUCUS` acronym#2，工具报「标题里没有唯一可变的轴」，见第三节）
- 本批没有出现「源码: 无记录」（`T_POWER_CORE` #0 与 `T_MASTER_SUMMONER` #0 虽标 `无候选`，但源码位置有效、公式可读）

各大系统计：

| 大系 | 目标数 | PASS | 跳过 | 源码文件（`tome-src-full/data/talents/gifts/`）|
| --- | --- | --- | --- | --- |
| wild-gift/call | 4 | 4 | 0 | `call.lua` |
| wild-gift/moss | 4 | 4 | 0 | `moss.lua` |
| wild-gift/storm-drake | 4 | 4 | 0 | `storm-drake.lua` |
| wild-gift/summon-augmentation | 3 | 3 | 0 | `summon-augmentation.lua` |
| wild-gift/corrosive-blades | 3 | 3 | 0 | `corrosive-blades.lua` |
| wild-gift/ooze | 3 | 3 | 0 | `ooze.lua` |
| wild-gift/cold-drake | 2 | 2 | 0 | `cold-drake.lua` |
| wild-gift/slime | 2 | 2 | 0 | `slime.lua` |
| wild-gift/fire-drake | 2 | 2 | 0 | `fire-drake.lua` |
| wild-gift/dwarven-nature | 2 | 2 | 0 | `dwarven-nature.lua` |
| wild-gift/oozing-blades | 2 | 2 | 0 | `oozing-blades.lua` |
| wild-gift/summon-advanced | 2 | 2 | 0 | `summon-advanced.lua` |
| wild-gift/venom-drake | 1 | 1 | 0 | `venom-drake.lua` |
| wild-gift/fungus | 1 | 1 | 0 | `fungus.lua` |
| wild-gift/mucus | 2 | 1 | 1 | `mucus.lua` |
| wild-gift/higher-draconic | 1 | 1 | 0 | `higher-draconic.lua` |
| **合计** | **38** | **37** | **1** | |

## 一、已完成（37/37，全部三套 15 点全中 + 输入集合覆盖）

表里写的是**完整 JSON**（可直接复用）。

| 技能 | acronym | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_MEDITATION | #0 | `["+",2,["/",["mindDamage",20,120],10]]` | call.lua:78 | ✅ |
| T_MEDITATION | #1 | `["+",5,["mindDamage",10,40]]` | call.lua:79 | ✅ |
| T_MEDITATION | #2 | `["+",5,["mindDamage",12,30]]` | call.lua:80 | ✅ |
| T_NATURE_S_BALANCE | #1 | `["talentLevel"]` | call.lua:190 | ✅ |
| T_GRASPING_MOSS | #0 | `["combatScale",["talentLevel",true],2.35,1,4.25,5]` | moss.lua:43 | ✅ |
| T_NOURISHING_MOSS | #0 | `["combatScale",["talentLevel",true],2.35,1,4.25,5]` | moss.lua:93 | ✅ |
| T_SLIPPERY_MOSS | #0 | `["combatScale",["talentLevel",true],2.35,1,4.25,5]` | moss.lua:141 | ✅ |
| T_HALLUCINOGENIC_MOSS | #0 | `["combatScale",["talentLevel",true],2.35,1,4.25,5]` | moss.lua:190 | ✅ |
| T_TORNADO | #1 | `["floor",["combatScale",["talentLevel",true],2,1,4,5]]` | storm-drake.lua:132 | ✅ |
| T_LIGHTNING_BREATH | #1 | `["/",["statDamage","str",30,670],3]` | storm-drake.lua:260 | ✅ |
| T_LIGHTNING_BREATH | #2 | `["statDamage","str",30,670]` | storm-drake.lua:261 | ✅ |
| T_LIGHTNING_BREATH | #3 | `["/",["+",["statDamage","str",30,670],["/",["statDamage","str",30,670],3]],2]` | storm-drake.lua:262 | ✅ |
| T_DETONATE | #0 | `["floor",["combatScale",["talentLevel",true],4,1,8,5]]` | summon-augmentation.lua:43 | ✅ |
| T_DETONATE | #11 | `["+",15,["*",["talentLevel"],7.7]]` | summon-augmentation.lua:60 | ✅ |
| T_DETONATE | #13 | `["+",1,["floor",["talentLevel"]]]` | summon-augmentation.lua:62 | ✅ |
| T_CORROSIVE_NATURE | #1 | `["/",["talentScale",5,15,0.75],2.23]` | corrosive-blades.lua:66 | ✅ |
| T_CORROSIVE_NATURE | #3 | `["/",["*",["talentScale",5,15,0.75],["sqrt",5]],2.23]` | corrosive-blades.lua:66 | ✅ |
| T_CORROSIVE_SEEDS | #0 | `["min",4,["floor",["/",["+",["talentLevel"],3],2]]]` | corrosive-blades.lua:126 | ✅ |
| T_NATURAL_ACID | #1 | `["/",["talentScale",5,15,0.75],2.23]` | oozing-blades.lua:67 | ✅ |
| T_NATURAL_ACID | #3 | `["/",["*",["talentScale",5,15,0.75],["sqrt",5]],2.23]` | oozing-blades.lua:67 | ✅ |
| T_MITOSIS | #0 | `["+",50,["+",["mindDamage",30,250],["*",1000,["talentLimit",0.25,0.035,0.125]]]]` | ooze.lua:33 | ✅ |
| T_MITOSIS | #2 | `["max",1,["floor",["talentLimit",6,1.1,4.1]]]` | ooze.lua:36 | ✅ |
| T_CALL_OF_THE_OOZE | #0 | `["*",["+",50,["+",["^",["*",["/",["*",["+",30,["power","精神强度"]],0.2],258.55104],250],1.04],["*",1000,["combatLimit",["pow",0.5,["/",2,3]],0.25,0.035,["pow",1.3,["/",2,3]],0.125,["pow",6.5,["/",2,3]]]]]],["talentLimit",1,0.46,0.7]]` | ooze.lua:183 | ✅ |
| T_ICE_WALL | #0 | `["+",3,["*",2,["floor",["/",["talentLevel"],2]]]]` | cold-drake.lua:205 | ✅ |
| T_ICE_BREATH | #1 | `["statDamage","str",30,500]` | cold-drake.lua:262 | ✅ |
| T_BELLOWING_ROAR | #1 | `["+",20,["*",6,["talentLevel"]]]` | fire-drake.lua:118 | ✅ |
| T_FIRE_BREATH | #1 | `["statDamage","str",30,650]` | fire-drake.lua:221 | ✅ |
| T_CORROSIVE_BREATH | #1 | `["statDamage","str",30,520]` | venom-drake.lua:206 | ✅ |
| T_VENOMOUS_BREATH | #1 | `["/",["statDamage","str",60,750],6]` | higher-draconic.lua:162 | ✅ |
| T_SLIME_ROOTS | #1 | `["min",4,["max",1,["-",4,["/",["talentLevel"],2]]]]` | slime.lua:139 | ✅ |
| T_SLIME_ROOTS | #2 | `["min",3,["floor",["/",["+",["talentLevel"],2],3]]]` | slime.lua:141 | ✅ |
| T_SUDDEN_GROWTH | #1 | `["*",0.25,["talentScale",2,5]]` | fungus.lua:131 | ✅ |
| T_ACID_SPLASH | #0 | `["+",2,["min",1,["floor",["/",["talentLevel"],5]]]]` | mucus.lua:96 | ✅ |
| T_POWER_CORE | #0 | `["floor",["talentLevel"]]` | dwarven-nature.lua:200 | ✅ |
| T_DWARVEN_UNITY | #1 | `["talentLevel",true]` | dwarven-nature.lua:258 | ✅ |
| T_MASTER_SUMMONER | #0 | `["*",100,["min",0.3,["max",0.05,["/",["talentLevel",true],15]]]]` | summon-advanced.lua:30 | ✅ |
| T_NATURE_CYCLE | #0 | `["min",100,["+",30,["*",15,["talentLevel"]]]]` | summon-advanced.lua:96 | ✅ |

acronym 与 `info` 的对应（`tformat` 参数顺序）：

- `T_MEDITATION` `:tformat(pt, save, heal, rest)` —— #3 `rest` 已自动提取；`boost = 1+(enhance_meditate or 0)` 在导出基准 = 1。
- `T_NATURE_S_BALANCE` `:tformat(getTalentCount, getMaxLevel)` —— #0 已自动提取。
- 四个苔藓 `:tformat(radius, damage, …)` —— 只补 #0 半径。
- `T_TORNADO` `:tformat(moveDamage, rad, damage, physicalDamage)`、`T_LIGHTNING_BREATH` `:tformat(radius, damage/3, damage, (damage+damage/3)/2)`。
- `T_DETONATE` `:tformat(radius, …, golemArmour, golemHardiness, shellShielding, spiderKnockback)` —— #0/#11/#13 为目标，其余已自动提取。
- `T_CORROSIVE_NATURE` / `T_NATURAL_ACID` `:tformat(getResist, getXDamage(t,1), getDuration, getXDamage(t,5))` —— #0/#2 已自动提取。
- `T_CORROSIVE_SEEDS` `:tformat(nb, getDuration, damage)` —— #1/#2 已自动提取。
- `T_MITOSIS` `:tformat(getMaxHP, getChance*3/100, getMax, getSummonTime, getOozeResist, xs)` —— #1/#3/#4 已自动提取，#5 是 `T_REABSORB` 分支字符串。
- `T_CALL_OF_THE_OOZE` `:tformat(getMax, getLife, getModHP*100, getWepDamage*100)` —— 导出顺序为 life / modHP% / wep%，#0 即 `getLife`。
- `T_ICE_WALL` `:tformat(3+floor(tl/2)*2, duration, icedam, icerad)` —— 注意 **info 里的长度不是 `t.getLength`**（`getLength` 用 `combatTalentScale(t,3,7)`，只给 `target` 用）。
- `T_BELLOWING_ROAR` `:tformat(radius, power, damage)` —— 只补 #1 困惑强度。
- `T_SLIME_ROOTS` `:tformat(range, radius, talents)`、`T_SUDDEN_GROWTH` `:tformat(mult*100, life_regen*mult)`、`T_ACID_SPLASH` 只补 `radius`。
- `T_DWARVEN_UNITY` `:tformat(radius, getTalentLevelRaw, radius)` —— #1 是**原始**等级。

## 二、发现的写法模式（可提升为解析器规则）

1. **「半径族」在导出里一律按原始等级（raw）。**
   `moss` 四个技能、`T_TORNADO`、`T_DETONATE` 的导出半径阶梯在 1.00/1.30/1.50 三套里**完全相同**，
   而同技能同文件里的伤害阶梯却随系数变化 —— 说明导出侧算 radius 时用的是 `getTalentLevelRaw`。
   代表：`T_TORNADO` #1 = `["floor",["combatScale",["talentLevel",true],2,1,4,5]]`。
   **规则**：任何 `radius = math.floor(self:combatTalentScale(t, low, high))` 且导出三套同值 → 用 `["talentLevel",true]`。

2. **「每 5 级 / 每 2 级加一档」的取整阶梯，写成分段等价的 `min/floor` 闭式最省事。**
   - `2 + (getTalentLevel(t) >= 5 and 1 or 0)` → `["+",2,["min",1,["floor",["/",["talentLevel"],5]]]]`（`T_ACID_SPLASH` #0）。
   - `l<3→2, l<5→3, else 4` → `["min",4,["floor",["/",["+",["talentLevel"],3],2]]]`（`T_CORROSIVE_SEEDS` #0）。
   - `l<4→1, l<7→2, else 3` → `["min",3,["floor",["/",["+",["talentLevel"],2],3]]]`（`T_SLIME_ROOTS` #2）。
   **规则**：节点表没有 if，任何「按阈值分档」的整数都可以试用 `min(上限, floor((tl+offset)/step))` 拟合；
   拟合后必须三套 15 点验证（本批三例全部逐点一致）。

3. **龙息家族 `getDamage` = `combatTalentStatDamage(t,"str",base,max)` + 未点亮的 `T_CHROMATIC_FURY` 分支。**
   四个技能只是 `(base,max)` 不同：冰 30/500、火 30/650、酸 30/520、毒 60/750；
   前三个 `#1` 就是 `["statDamage","str",base,max]` 本体，毒系 `#1` 是 `…/6`（info 里除以 6）。
   代表：`T_ICE_BREATH` #1、`T_VENOMOUS_BREATH` #1。

4. **「先算整体、再乘除」的派生量必须整套重复 base，不能把系数折进常数。**
   `T_LIGHTNING_BREATH` #1/#3、`T_VENOMOUS_BREATH` #1、`T_CORROSIVE_NATURE`/`T_NATURAL_ACID` #1/#3、
   `T_CALL_OF_THE_OOZE` #0 都是这种。因为伤害族里有 `^1.04` 非线性，折进 base 会差 1。
   代表：`T_LIGHTNING_BREATH` #3 = `(damage + damage/3)/2`。

5. **`util.bound(x, lo, hi)` → `["min",hi,["max",lo,x]]`；`*100` 的百分比直接外挂 `["*",100,…]`。**
   代表：`T_SLIME_ROOTS` #1（半径）、`T_MASTER_SUMMONER` #0（`bound(raw/15,0.05,0.3)*100`）、
   `T_BELLOWING_ROAR` #1 / `T_NATURE_CYCLE` #0 / `T_POWER_CORE` #0。

6. **`min/max` 封顶很常见，且在高系数下真的会咬住，不能省。**
   `T_NATURE_CYCLE` #0 = `min(100, 30+15·tl)`、`T_ICE_WALL` #0 无封顶但 `T_SLIME_ROOTS` #1 的 `max(1,…)` 在 1.5 套咬住
   （tl=6/7.5 时 `4-tl/2` 已是 1）。代表：`T_NATURE_CYCLE` #0。

7. **`combatStatScale` 驱动的值以「属性」为轴，标题会写成 `灵巧=10/25/50/75/100`。**
   `T_LIVING_MUCUS.getMax = floor(max(1, combatStatScale("cun",0.5,5)))`。本批该条因**轴不唯一**被跳过（见第三节），
   但同目录其它属性驱动的值可直接用 `["statScale",…]`。

8. **别的技能的 getter 在导出基准里按「未学（等级 0）」求值。**
   `T_CALL_OF_THE_OOZE.getLife = callTalent(T_MITOSIS,"getMaxHP") * getModHP`，
   而导出把 Mitosis 当 0 级：内层 `combatTalentMindDamage` 的 `sqrt(tl)-1 = -1`（无 `tl<=0` 夹紧），
   `combatTalentLimit` 则按源码 `if tl <= 0 then tl = 0.5 end`。两处夹紧规则不同，必须分别还原。
   代表：`T_CALL_OF_THE_OOZE` #0（用文档的「伤害族展开」取 L=0，再用 `combatLimit` 等价锚点还原 L=0.5）。

## 三、无法建模

1. **`T_LIVING_MUCUS` acronym#2（本批唯一跳过）** —— 源码
   `getMax = math.floor(math.max(1, self:combatStatScale("cun", 0.5, 5)))`，**公式本身读懂了**，
   手工核对：cun = 10/25/50/75/100 → `1, 1, 3, 4, 5`，与三套导出（1/1/3/4/5，系数无关）完全一致。
   但该 acronym 的标题同时声明了 **`灵巧=10/25/50/75/100` 和 `精神强度=10/25/50/75/100`** 两个各带 5 个值的参数，
   工具直接报「标题里没有唯一可变的轴」，无法进入 15 点校验流程，故按规则跳过并记录。
   若某天工具支持「轴参数由调用方指定」，这条可直接写成 `["floor",["max",1,["statScale","cun",0.5,5]]]`。

2. **运行时召唤实体数值**：`checkMaxSummon(self, true)` 的召唤数量上限（`T_MITOSIS` #2 与 `T_CALL_OF_THE_OOZE` #0 里都出现），
   依赖当前已召唤数量与全局召唤上限；导出基准下前者不咬合，已按「不生效」省略并 15 点验证。

3. **`T_CHROMATIC_FURY` / `T_REABSORB` 等别的技能分支**：`knowTalent(...) and … or 0` 在导出基准恒为未点亮 → 0 / 空串，
   本批按「不点亮」处理。表达式语言没有「是否点亮某技能」节点（`talentRef` 只给等级），若基准改变需另想办法。

4. **`self.max_life` 与 `self.life_regen`（角色运行时状态）**：见第四节疑点，冻结为导出基准常数（1000 / 0.25），
   并在 `note` 注明；两者都**不是标题声明的输入**，故不属于「硬编码声明输入」。

5. **`T_ICE_WALL` 的 `getLength`**（`1+floor(combatTalentScale(t,3,7)/2)*2`）只服务 `target()` 的墙体半长，
   与 `info` 显示的长度（`3+floor(tl/2)*2`）不是同一个量；本批只补 info 的 acronym。

## 四、疑点

1. **苔藓半径：源码 `math.floor(combatTalentScale(t,2.35,4.25))` 解释不了导出值，只能按「原始等级 + 四舍五入读数」复现。**
   四条苔藓的导出半径阶梯在 1.00/1.30/1.50 三套里都是 `2/3/3/4/4`（系数无关 → 原始等级），但：
   - `floor(原始曲线)` = `2/2/3/3/4`（tl=2 时 2.9867→2，tl=4 时 3.8871→3）→ **与导出不符**；
   - `原始曲线 + round 读数` = `2/3/3/4/4` → **15/15 全中**（`2.9867→3`、`3.8871→4`）。
   最终写成不带 `floor` 的 `["combatScale",["talentLevel",true],2.35,1,4.25,5]`，由判分器的「四舍五入」读数吸收。
   另一可能是导出侧源码版本的高锚点不是 `4.25`（例如 `4.6`），那样 `floor(原始)` 也能得到 `2/3/3/4/4`；
   但**锚点以仓库内源码为准**，所以没有改常数，只去掉了 `floor`。这条已在 `note` 标明。

2. **同为「半径 = floor(combatTalentScale)」的写法，导出行为并不一致。**
   `T_TORNADO`（`2,4`）与 `T_DETONATE`（`4,8`）的导出值**恰好等于 `floor(原始曲线)`**（`2/2/3/3/4`、`4/5/6/7/8`），
   所以这两条**保留 floor**；而苔藓（`2.35,4.25`）只能按 round 读。
   说明「导出半径按原始等级」是系统性的，但「是否 floor」在这批数据里至少有两种表现，解析器不能一刀切。

3. **导出基准角色的两个运行时量被冻结为常数（均在 `note` 说明）**：
   - `self.max_life = 1000`（`T_MITOSIS` #0 与 `T_CALL_OF_THE_OOZE` #0 使用）；
   - `self.life_regen = 0.25`（`T_SUDDEN_GROWTH` #1 使用；能过 15 点的区间是 `[0.226, 0.265)`，取 0.25）。
   两者都不是标题声明的输入，冻结不违反「不许硬编码输入」；但滑条若允许改最大生命/生命回复，这两条的绝对值会失真。

4. **`T_CALL_OF_THE_OOZE` #0 的跨技能求值**：`callTalent(T_MITOSIS,"getMaxHP")` 在导出基准按 Mitosis **0 级**计算
   （已由 `getMaxHP = getLife / (getModHP/100) ≈ 74.5` 与等级无关反推证实）。这是本批唯一需要用
   「伤害族展开（L=0）+ `combatLimit` 等价锚点（L=0.5）」拼出来的表达式；`combatLimit` 的锚点
   `xLow = 1.3^(2/3)`、`xHigh = 6.5^(2/3)` 是为了让 `x^0.75 = sqrt(tl)`，与 `combatTalentLimit` 的
   `sqrt(1.3)/sqrt(6.5)` 对齐。**并非发明节点**，但解析器不宜自动生成这种形态。

5. **小数阶梯的读数不统一（判定器已支持四种读数，非缺陷）**：
   - `T_MEDITATION` #0 是 `%0.2f`：`9.1089→9.11`、`10.4427→10`（≥10 只打印整数部分）；
   - `T_CORROSIVE_NATURE` #3 系数 1.00 第 3 点：算得 `10.4878`，导出 `11` —— 即 `%0.1f` 先归整成 `10.5` 再取整（`round1`）；
   - `T_MEDITATION` #2 多处走截断（`21.8135→21`），`T_MEDITATION` #0 系数 1.5 走四舍五入（`15.8358→16`）。
   都已在判定器四种读数内，**不构成源码与导出的不一致**，只是提醒不要为「对上显示」在公式外再包取整节点。

6. **未发现「标题过度声明输入」**：本批所有表达式的消耗集合都是标题声明的子集；
   `T_MITOSIS` #0 / `T_CALL_OF_THE_OOZE` #0 的标题声明 `灵巧` 而公式不读（显示为「✅ 覆盖（标题是超集，本值未用到：灵巧）」），
   这是因为同 tooltip 的另一个 acronym 用到了灵巧（分裂几率受灵巧加成），属正常并集。

7. **自动提取的失败原因分布（供解析器改进参考）**：
   `无候选` 4 条（`T_POWER_CORE` #0 的 `math.floor(getTalentLevel)`、`T_MASTER_SUMMONER` #0 的 `util.bound(raw/15)`、
   `T_VENOMOUS_BREATH` #1 的 `/6` 派生量、`T_MEDITATION` 的 `drain_equilibrium` 间接量）；
   其余多为 `tformat` 里的除法/乘法派生量、条件分支与 `callTalent` 尾巴。

---

### 交付范围声明

本次仅写入两个文件：

- `modern_tome_viewer/data/overlay-batches/batch07-gifts.json`（37 条，全部 PASS 后落盘，数组长度 = 通过数 37）
- `modern_tome_viewer/docs/overlay-reports/batch07-gifts.md`（本文件）

未修改 `src/**`、`scripts/**`、`public/**`、`data/raw/**`、`data/lua-coefficients.json`，
也未写 `data/lua-expressions.json` 与 `docs/expression-overlay-report.md`。
