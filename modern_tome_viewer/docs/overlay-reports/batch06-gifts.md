# 覆盖层报告：batch06 — wild-gift 七个大系（契约/精神法杖/沙龙/反魔/土系）

- 目标数：**49**（`node scripts/try-formula.mjs --list --tree <大系>` 七个大系求和，见下表）
- 批次文件：`data/overlay-batches/batch06-gifts.json`（数组长度 **49**，键唯一）
- 验收命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/batch06-gifts.json`
- 汇总行：**`覆盖层校验：49/49 通过`**（无 FAIL，无输入集合不符）
- 跳过数：**0**（本批没有出现「源码: 无记录」，也没有「标题里没有唯一可变的轴」；49 条全部跑出
  `结论：PASS（三套 15 点全中，输入集合覆盖）`）

各大系统计：

| 大系 | 目标数 | PASS | 跳过 | 源码文件 |
| --- | --- | --- | --- | --- |
| wild-gift/summon-distance | 12 | 12 | 0 | `tome-src-full/data/talents/gifts/summon-distance.lua` |
| wild-gift/mindstar-mastery | 8 | 8 | 0 | `.../gifts/mindstar-mastery.lua` |
| wild-gift/sand-drake | 7 | 7 | 0 | `.../gifts/sand-drake.lua` |
| wild-gift/antimagic | 6 | 6 | 0 | `.../gifts/antimagic.lua` |
| wild-gift/summon-utility | 6 | 6 | 0 | `.../gifts/summon-utility.lua` |
| wild-gift/earthen-power | 6 | 6 | 0 | `.../gifts/earthen-power.lua` |
| wild-gift/earthen-vines | 4 | 4 | 0 | `.../gifts/earthen-vines.lua` |
| **合计** | **49** | **49** | **0** | |

## 一、已完成（49/49，全部三套 15 点全中 + 输入集合一致）

缩写：`AC` = `["combatScale",…]`、`TL` = `["talentLevel"]`、`TS(a,b[,p])` = `["talentScale",a,b[,p]]`、
`TLim(l,a,b)` = `["talentLimit",l,a,b]`、`MD(b,m)` = `["mindDamage",b,m]`、
`PD(b,m)` = `["physicalDamage",b,m]`、`SD(s,b,m)` = `["statDamage",s,b,m]`、
`P(q)` = `["power","q"]`、`S` = `["talentScale",0.2,1,0.75]`、`TT` = `["talentScale",2,10,0.75]`。
表里写的是**完整 JSON**（可直接复用），未缩写。

| 技能 | acronym | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_RITCH_FLAMESPITTER | #0 | `["-",["floor",["combatScale",["talentLevel"],5,0,10,5]],1]` | summon-distance.lua:426 | ✅ |
| T_RITCH_FLAMESPITTER | #1 | `["+",15,["*",["*",["power","精神强度"],2],["talentScale",0.2,1,0.75]]]` | summon-distance.lua:421 | ✅ |
| T_RITCH_FLAMESPITTER | #2 | `["+",15,["*",["*",["power","精神强度"],1.7],["talentScale",0.2,1,0.75]]]` | summon-distance.lua:422 | ✅ |
| T_HYDRA | #0 | `["-",["floor",["combatScale",["talentLevel"],5,0,10,5]],1]` | summon-distance.lua:543 | ✅ |
| T_HYDRA | #1 | `["+",15,["*",["*",["power","精神强度"],1.6],["talentScale",0.2,1,0.75]]]` | summon-distance.lua:547 | ✅ |
| T_HYDRA | #2 | `["+",10,["talentScale",2,10,0.75]]` | summon-distance.lua:549 | ✅ |
| T_RIMEBARK | #0 | `["-",["floor",["combatScale",["talentLevel"],5,0,10,5]],1]` | summon-distance.lua:660 | ✅ |
| T_RIMEBARK | #1 | `["+",15,["*",["*",["power","精神强度"],2],["talentScale",0.2,1,0.75]]]` | summon-distance.lua:664 | ✅ |
| T_RIMEBARK | #2 | `["+",15,["*",["*",["power","精神强度"],1.6],["talentScale",0.2,1,0.75]]]` | summon-distance.lua:665 | ✅ |
| T_FIRE_DRAKE | #0 | `["-",["floor",["combatScale",["talentLevel"],2,0,7,5]],1]` | summon-distance.lua:822 | ✅ |
| T_FIRE_DRAKE | #1 | `["+",15,["*",["*",["power","精神强度"],2],["talentScale",0.2,1,0.75]]]` | summon-distance.lua:826 | ✅ |
| T_FIRE_DRAKE | #2 | `["+",20,["*",["*",["power","精神强度"],1.5],["talentScale",0.2,1,0.75]]]` | summon-distance.lua:828 | ✅ |
| T_TURTLE | #0 | `["-",["floor",["combatScale",["talentLevel"],5,0,10,5]],1]` | summon-utility.lua:119 | ✅ |
| T_TURTLE | #1 | `["+",15,["*",["*",["power","精神强度"],2.1],["talentScale",0.2,1,0.75]]]` | summon-utility.lua:123 | ✅ |
| T_TURTLE | #2 | `["+",10,["talentScale",2,10,0.75]]` | summon-utility.lua:125 | ✅ |
| T_SPIDER | #0 | `["-",["floor",["combatScale",["talentLevel"],5,0,10,5]],1]` | summon-utility.lua:249 | ✅ |
| T_SPIDER | #1 | `["+",15,["*",["*",["power","精神强度"],2],["talentScale",0.2,1,0.75]]]` | summon-utility.lua:253 | ✅ |
| T_SPIDER | #2 | `["+",10,["talentScale",2,10,0.75]]` | summon-utility.lua:255 | ✅ |
| T_PSIBLADES | #0 | `["+",1.076,["*",0.324,["sqrt",["talentLevel"]]]]` | mindstar-mastery.lua:38 | ✅ |
| T_PSIBLADES | #1 | `["+",0.65,["*",0.51,["sqrt",["talentLevel"]]]]` | mindstar-mastery.lua:39 | ✅ |
| T_PSIBLADES | #2 | `["+",1.076,["*",0.324,["sqrt",["talentLevel"]]]]` | mindstar-mastery.lua:37 | ✅ |
| T_PSIBLADES | #3 | `["*",100,["/",["sqrt",["/",["talentLevel"],5]],1.5]]` | mindstar-mastery.lua:41 | ✅ |
| T_THORN_GRAB | #1 | `["/",["mindDamage",15,250],10]` | mindstar-mastery.lua:104 | ✅ |
| T_LEAVES_TIDE | #0 | `["+",5,["mindDamage",5,35]]` | mindstar-mastery.lua:121 | ✅ |
| T_LEAVES_TIDE | #1 | `["min",40,["max",10,["+",10,["mindDamage",3,25]]]]` | mindstar-mastery.lua:122 | ✅ |
| T_NATURE_S_EQUILIBRIUM | #1 | `["+",50,["mindDamage",5,250]]` | mindstar-mastery.lua:168 | ✅ |
| T_SWALLOW | #2 | `["combatLimit",["*",3,["talentLevel"]],50,13,1,25,5]` | sand-drake.lua:35 | ✅ |
| T_SWALLOW | #3 | `["combatLimit",["*",1.5,["talentLevel"]],50,13,1,25,5]` | sand-drake.lua:35 | ✅ |
| T_SWALLOW | #4 | `["combatLimit",["talentLevel"],50,13,1,25,5]` | sand-drake.lua:35 | ✅ |
| T_SWALLOW | #5 | `["combatLimit",["*",0.75,["talentLevel"]],50,13,1,25,5]` | sand-drake.lua:35 | ✅ |
| T_SWALLOW | #6 | `["combatLimit",["*",0.6,["talentLevel"]],50,13,1,25,5]` | sand-drake.lua:35 | ✅ |
| T_SWALLOW | #7 | `["combatLimit",["*",0.5,["talentLevel"]],50,13,1,25,5]` | sand-drake.lua:35 | ✅ |
| T_SAND_BREATH | #1 | `["statDamage","str",10,400]` | sand-drake.lua:191 | ✅ |
| T_RESOLVE | #0 | `["+",5,["max",["mindDamage",15,30],["physicalDamage",15,30]]]` | antimagic.lua:31 | ✅ |
| T_AURA_OF_SILENCE | #0 | `["max",["mindDamage",1,110],["physicalDamage",1,110]]` | antimagic.lua:77 | ✅ |
| T_ANTIMAGIC_SHIELD | #0 | `["max",["mindDamage",20,85],["physicalDamage",20,85]]` | antimagic.lua:134 | ✅ |
| T_MANA_CLASH | #0 | `["max",["mindDamage",10,460],["physicalDamage",10,460]]` | antimagic.lua:194 | ✅ |
| T_MANA_CLASH | #1 | `["/",["max",["mindDamage",10,460],["physicalDamage",10,460]],2]` | antimagic.lua:222 | ✅ |
| T_MANA_CLASH | #2 | `["/",["max",["mindDamage",10,460],["physicalDamage",10,460]],4]` | antimagic.lua:223 | ✅ |
| T_STONESHIELD | #0 | `["*",100,["talentLimit",1,0.08,0.165]]` | earthen-power.lua:35 | ✅ |
| T_STONESHIELD | #1 | `["talentScale",6,10]` | earthen-power.lua:36 | ✅ |
| T_STONESHIELD | #2 | `["*",100,["talentLimit",0.5,0.075,0.2]]` | earthen-power.lua:37 | ✅ |
| T_STONESHIELD | #3 | `["talentScale",5,9,"log"]` | earthen-power.lua:38 | ✅ |
| T_STONESHIELD | #4 | `["*",100,["/",["sqrt",["/",["talentLevel"],5]],1.5]]` | earthen-power.lua:41 | ✅ |
| T_STONE_FORTRESS | #0 | `["talentScale",60,100,"log"]` | earthen-power.lua:59 | ✅ |
| T_STONE_VINES | #0 | `["floor",["talentScale",4.5,6.5]]` | earthen-vines.lua:30 | ✅ |
| T_STONE_VINES | #1 | `["statDamage","wil",6,80]` | earthen-vines.lua:31 | ✅ |
| T_STONE_VINES | #2 | `["floor",["talentScale",5,9]]` | earthen-vines.lua:31 | ✅ |
| T_STONE_VINES | #3 | `["+",4,["floor",["talentScale",4.5,6.5]]]` | earthen-vines.lua:74 | ✅ |

acronym 与 `info` 的对应（`tformat` 参数顺序）：

- `T_RITCH_FLAMESPITTER` `:tformat(summonTime, wil, cun, con)` —— con=10 常数，未列 acronym。
- `T_HYDRA` `:tformat(summonTime, wil, con, str)` —— str=18 常数。
- `T_RIMEBARK` `:tformat(summonTime, wil, cun, con)` —— con=10 常数。
- `T_FIRE_DRAKE` `:tformat(summonTime, str, con)` —— wil=38 常数。
- `T_TURTLE` `:tformat(summonTime, con, dex)` —— wil=18 常数。
- `T_SPIDER` `:tformat(summonTime, dex, str, con)` —— con=10 常数。
- `T_PSIBLADES` `:tformat(statmult, aprmult, powermult, 100*inc)`（第 5 参 `damage=30` 是文本里的字面量）。
- `T_THORN_GRAB` `:tformat(100*speedPenalty, damDesc(NATURE, dam), mult)` —— #0 已自动提取，本批补 #1。
- `T_LEAVES_TIDE` `:tformat(dam, chance, mult)` —— mult 恒为 1（常数）。
- `T_NATURE_S_EQUILIBRIUM` `:tformat(wdam*100, maxHeal, mult)` —— #0 已自动提取。
- `T_SWALLOW` `:tformat(100*wdam, passiveCrit, maxSwallow(size=1..6))` —— #0/#1 已自动提取。
- `T_SAND_BREATH` `:tformat(radius, damage, duration)` —— #0（radius）/ #2（duration=3）已自动提取或为常数。
- `T_RESOLVE` `:tformat(resist, regen)` —— #1 `regen=1` 常数。
- `T_AURA_OF_SILENCE` `:tformat(duration, radius, floorDuration, damage, equiRegen)` —— #3 已自动提取。
- `T_ANTIMAGIC_SHIELD` / `T_STONE_FORTRESS` / `T_STONE_VINES` 见上。
- `T_MANA_CLASH` `:tformat(mana, vim, positive, is_adept)` —— is_adept 是字符串。
- `T_STONESHIELD` `:tformat(100*m, mm, 100*e, em, damage=30, 100*inc)` —— 常数 30 不占 acronym 槽。

## 二、发现的写法模式（可提升为解析器规则）

1. **`summon-distance` / `summon-utility` 与 `summon-melee` 是同一套召唤模板，`summonTime` 完全可复用。**
   四个文件里 `summonTime` 都是
   `math.floor(self:combatScale(self:getTalentLevel(t), low, 0, high, 5)) + self:callTalent(self.T_RESILIENCE,"incDur")`，
   与 `summon-melee` 已验证的 `["-",["floor",["combatScale",["talentLevel"],low,0,high,5]],1]` 一字不差。
   只有火龙例外用 `(2,0,7,5)`。代表：`T_RITCH_FLAMESPITTER` #0。
   **规则**：`gifts/` 目录下任何 `newTalent` 里出现 `combatScale(self:getTalentLevel(t), A, 0, B, 5)` + `callTalent(T_RESILIENCE,"incDur")`
   都可直接产出 `["-",["floor",["combatScale",["talentLevel"],A,0,B,5]],1]`。

2. **召唤物属性一律 `incStats(self,t,true)` + `base + mp*k*combatTalentScale(t,0.2,1,0.75)`，且 `T = combatTalentScale(t,2,10,0.75)`。**
   本批 6 个召唤技能全部只需读 3 行即可套出：`wil/cun/dex/str/con = base + 精神强度*k*S (+ TT)`。
   系数表：Ritch wil 2 / cun 1.7；Hydra wil 1.6 / con = 10+TT；Rimebark wil 2 / cun 1.6；Fire Drake str 2 / con 20+1.5·mp·S；
   Turtle con 2.1 / dex = 10+TT；Spider dex 2 / str = 10+TT。
   代表：`T_SPIDER` #1/#2。

3. **纯 `S`/`TT` 项（不含精神强度）的 acronym，标题也一定不声明「精神强度」。**
   若为「看起来完整」补一个 `["power","精神强度"]`，输入集合会立刻 FAIL。代表：`T_HYDRA` #2、`T_TURTLE` #2。

4. **本地 helper `local function combatTalentPhysicalMindDamage(self,t,b,s) return math.max(mind, physical) end`
   必须按 `["max",["mindDamage",b,s],["physicalDamage",b,s]]` 展开，不能只写一支。**
   虽然导出基准两项强度都是 100、`max` 两支等值，但标题把 `physical power` 和 `精神强度` 都声明了，
   写两支才能和源码语义一致（且正好「完全一致」而非「超集」）。整个 `wild-gift/antimagic` 4 个技能共用它。
   代表：`T_RESOLVE` #0、`T_MANA_CLASH` #0。

5. **「先算 base 再除」的派生量要整套重复 base 的表达式，不能把除法折进 base。**
   `T_MANA_CLASH` 的 `vim = base/2`、`positive = base/4`，源码是先算 `base` 再除；
   `["mindDamage",5,230]` 之类的写法会因 `^1.04` 非线性而与 `["mindDamage",10,460]/2` 不等。代表：`T_MANA_CLASH` #1。

6. **`getXXmult` 型简单闭式直接照抄系数，`["sqrt",["talentLevel"]]` 即可。**
   `T_PSIBLADES` 的 `getStatmult/getPowermult = 1.076 + 0.324*sqrt(tl)`、`getAPRmult = 0.65 + 0.51*sqrt(tl)`，
   以及 `getPercentInc = sqrt(tl/5)/1.5`（`T_PSIBLADES` #3 与 `T_STONESHIELD` #4 共用同式）。
   注意 `level or self:getTalentLevel(t)` 的 `level` 在 `info` 里永远为空，所以取**有效等级**。代表：`T_PSIBLADES` #0。

7. **`util.bound(x, lo, hi)` 展开成 `["min",hi,["max",lo,x]]`；上限在高系数下真的会咬住，不能省。**
   `T_LEAVES_TIDE` #1 的 `bound(10+mindDamage(t,3,25),10,40)`：系数 1.5 时 tl=6/7.5 算得 41.0/44.4，
   导出正好是上限 `40`，去掉 clamp 就会 FAIL。代表：`T_LEAVES_TIDE` #1。

8. **`getValues` 一次返回多值，`info` 用 `local a,b,c,d = t.getValues(self,t)` 解构**
   （自动提取报 `Multiple local assignment`）。**按位置一一对应 `tformat` 顺序**即可：
   `T_STONESHIELD` 的 `(100m, mm, 100e, em, damage=30, 100inc)`、`T_STONE_VINES` 的 `(rad, dam, xs, turns, rad+4)`。
   代表：`T_STONESHIELD` #0–#4。

9. **`x and T or nil` 的「别的技能未点亮则为空」分支可以整段丢掉。**
   `T_STONE_VINES.getValues` 第 3 个返回值 `self:knowTalent(T_ELDRITCH_VINES) and callTalent(...) or nil` 在导出基准是 `nil`，
   `info` 里 `xs = arcanedam and (...) or ""` 于是变成空串，**不占 acronym 槽**——所以 4 个 acronym 依次是
   rad / dam / turns / rad+4，而不是 5 个。`T_SAND_BREATH` 的 `T_CHROMATIC_FURY` 分支同理（恒 0，可省）。代表：`T_STONE_VINES`。

10. **「按大小分档」的同一条公式会在 `tformat` 里重复出现 N 次（N=6）。**
    `T_SWALLOW.maxSwallow(self,t,size) = combatLimit(tl*size_category/size, 50, 13, 1, 25, 5)`，
    `size_category` 是**玩家运行时尺寸**（导出基准 = 3），size 循环 1..6 →
    系数依次 3 / 1.5 / 1 / 0.75 / 0.6 / 0.5，全部用 `["combatLimit",["*",k,["talentLevel"]],50,13,1,25,5]`。
    代表：`T_SWALLOW` #2–#7。

11. **`combatTalentStatDamage` 的 `^(1/1.04)` 与 `rescaleDamage` 的 `^1.04` 互相抵消**，
    所以节点 `["statDamage",…]` 输出的是「线性值 × 递减因子」，不需要额外包 `["^",…,1.04]`。
    `T_SAND_BREATH` #1 = `["statDamage","str",10,400]`、`T_STONE_VINES` #1 = `["statDamage","wil",6,80]`。
    （反面：`mindDamage`/`physicalDamage` **只有** `rescaleDamage` 的 `^1.04`，节点已含。）

## 三、无法建模

**本批 49 条全部建模成功，无「无法建模」条目。** 以下是本批触及大系里**存在但未被 acronym 覆盖**的不可建模点，
记录以备后续同目录其它技能参考：

1. 召唤实体运行时数值：`max_life = resolvers.rngavg(...)`、`combat = { dam = resolvers.levelup(resolvers.rngavg(...), …) }`、
   `setupSummon()` 之后的最终属性（summon-distance 各 `action`、summon-utility 各 `action`）——依赖随机数。
2. `T_SAND_BREATH.getDamage` 的 `self:knowTalent(self.T_CHROMATIC_FURY)` 分支在本批基准为假，但**若某天基准点亮它**，
   需要读另一个技能的等级或状态，表达式语言没有对应节点（`talentRef` 只给等级，不给「是否点亮」）。
   本批按「未点亮 → bonus=0」处理并已 15 点验证。
3. `T_ANTIMAGIC_SHIELD.getMax` 的 `T_TRICKY_DEFENSES.shieldmult` 分支同理（别的技能 getter），本批基准为未点亮。
4. `T_STONE_FORTRESS.getPercent` 的消费者 `ReduceDamage` 需要 `self:combatArmor()` 与攻击方 `src:combatAPR()`（运行时/别的角色），
   但 acronym 只是 `getPercent` 本身，故不受影响。
5. `get_mindstar_power_mult(self, div)`（mindstar-mastery.lua:20）依赖 **玩家武器**（主手/副手精神法杖的 `combat.dam`）：
   `1 + (main.dam + off.dam)*0.8/div`。导出基准未装备双精神法杖，`hasPsiblades` 返回空 → `return 1`，
   本批 4 条相关 acronym 因此把该乘数**冻结为 1**（`note` 已注明）。这是本批唯一「冻结」的量，且冻结的是
   **源码在基准下确实等于 1** 的表达式，不是标题声明的输入。

## 四、疑点

1. **`summonTime` 的系统性 `-1`（继承 `wild-gift/summon-melee` 的结论，本批再次全面复现）。**
   源码末尾 `+ self:callTalent(self.T_RESILIENCE, "incDur")`。导出基准里召唤师未点亮 Resilience
   （`getTalentLevel(T_RESILIENCE)=0`），而 `Combat.lua:1610` 的 `combatTalentLimit` 有 `if tl <= 0 then tl = 0.5 end`，
   于是内层 `combatTalentLimit(t, 6, 2, 5)` 在 tl=0.5 时算出 `-0.1244…` → `floor = -1`。
   本批 5 个技能的 `#0` 全部按常数 `-1` 写入并 15/15 通过（Ritch / Hydra / Rimebark / Fire Drake / Turtle / Spider），
   证明这不是单条巧合。**Resilience 等级不在标题声明里，写常数不违反「不许硬编码输入」。**
   证据（`T_RIMEBARK` #0）：系数 1.00 导出 `6/7/7/8/9`，`floor(√曲线)` = `7/8/8/9/10` → 全 -1 命中；
   系数 1.5 导出 `6/7/8/9/10`，`floor` = `7/8/9/10/11` → 全 -1 命中。

2. **同一文件里 `summonTime` 锚点不一致**：Fire Drake 用 `combatScale(tl, 2, 0, 7, 5)`，同文件其它三个用 `(5, 0, 10, 5)`
   （summon-distance.lua:822 vs 426/543/660）。导出数据与各自源码一致，**不是缺陷**，但解析器若按文件统一取锚点会错。

3. **整数显示读法在同一 acronym 内不统一**（源码是 `%d` / `%0.2f`，判定器按阶梯自选 trunc/round）：
   - `T_RITCH_FLAMESPITTER` #1 系数 1.00：`101.5447→101`（截断）、`142.3495→142`（两者皆可）、`179.8232→179`（截断）。
   - `T_THORN_GRAB` #1 系数 1.00：`15.2514→15`、`20.5391→21`（**必须四舍五入**）、`24.6333→25`（四舍五入）。
   - `T_AURA_OF_SILENCE` #0 系数 1.00：`64.9384→65`（四舍五入）、`87.4525→87`、`104.8852→105`（四舍五入）。
   - `T_LEAVES_TIDE` #0 系数 1.00：`24.7371→25`（四舍五入）、`41.372→41`。
   都已在判定器支持的四种读数内，**不构成源码与导出的不一致**，只是提醒：不要为「对上显示」在公式外再包取整节点。

4. **`T_STONESHIELD` #1/#3 的 `%0.2f` 阶梯在高系数下会打印「整数」**：系数 1.3 的 #1 第 4/5 点算得
   `10.1433 / 11.0143`，导出却是 `10 / 11`；系数 1.5 的 #1 第 4 点 `10.6906→11`。
   这正是 `expression-overlay.md` 里「数值 ≥ 10 只打印整数部分」的现象，判定器已处理，**不是疑点**。

5. **未发现「标题过度声明输入」**：本批所有 acronym 的表达式消耗都是标题声明的子集，
   且 30 条「无输入」acronym 的表达式确实不含任何强度/属性节点。

6. **自动提取的失败原因分布（供解析器改进参考）**：
   `无候选` 24 条（全是 `summonTime` 的 `callTalent` 尾巴、`getXXmult` 的 `sqrt` 闭式、`combatTalentPhysicalMindDamage` 的
   本地 helper、`tformat` 里的除法派生量）；`Multiple local assignment` 10 条（`getValues` 多返回值解构）；
   `source path mismatch` 1 条（`T_STONE_FORTRESS`，`getPercent` 在块内第 8 行，不在 `newTalent{` 首行附近）。

---

### 交付范围声明

本次仅写入两个文件：

- `modern_tome_viewer/data/overlay-batches/batch06-gifts.json`（49 条，全部 PASS 后落盘，数组长度 = 通过数 49）
- `modern_tome_viewer/docs/overlay-reports/batch06-gifts.md`（本文件）

未修改 `src/**`、`scripts/**`、`public/**`、`data/raw/**`、`data/lua-coefficients.json`，
也未写 `data/lua-expressions.json` 与 `docs/expression-overlay-report.md`。
