# 批次报告 · batch02-spells（9 个大系 / 50 条目标）

覆盖层：`data/overlay-batches/batch02-spells.json`
命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/batch02-spells.json`
结果：**49/49 通过**（目标 50 条；1 条记入「疑点」，未强行写入）

范围：`spell/glacial-waste`、`spell/age-of-dusk`、`spell/water`、`spell/eradication`、
`spell/meta`、`spell/animus`、`spell/thaumaturgy`、`spell/explosives`、`spell/storm`。

## 缩写（本报告表格用）

| 缩写 | 含义 |
| --- | --- |
| `S(low,high)` | `combatTalentScale` 的**Lua 运算顺序**展开（Combat.lua:1556）：`max(0, m·tl^p + b + add)`，`m=(high-low)/(5^p-1^p)`、`b=low-m·1^p`、`p=0.5`、等级取**有效**等级 |
| `Sraw(low,high)` | 同上，但等级取 `["talentLevel",true]`（`raw=true`，源码里的 `getTalentLevelRaw`） |
| `L(limit,low,high)` | `combatTalentLimit` 的 **Lua 运算顺序**展开（Combat.lua:1613-1619）：递增支 `limit·(1-exp(sqrt(tl)·a+b))`；`low>high` 时走减支 `low-(low-limit)·(1-exp(…))`，且 `b` 里的 `log(1-…)` 换成 `log(1-(low-high)/(low-limit))` |
| `BOUND` | `["min",500,["max",0,["+",50,["spellDamage",50,450]]]]`（`util.bound(50+combatTalentSpellDamage(t,50,450),0,500)`） |
| `ICE0` | 被嵌「冰雪风暴」的 `getDamage` 在**等级 0**处的展开：`["^",["*",["/",["*",["+",5,["power","法术强度"]],["+",1,["*",0.8,["-",["sqrt",0],1]]]],["*",["+",5,100],["+",1,["*",0.8,["-",["sqrt",5],1]]]]],90],1.04]` |

`S` 的完整字面量（以 `S(3,8)` 为例，其余只换数字）：

```json
["max",0,["+",["+",["*",["/",["-",8,3],["-",["^",5,0.5],["^",1,0.5]]],["^",["+",["talentLevel"],0],0.5]],["-",3,["*",["/",["-",8,3],["-",["^",5,0.5],["^",1,0.5]]],["^",1,0.5]]]],0]]
```

`L` 的完整字面量（以 `L(1,10,3)` 为例——`limit < low`、`low > high`，走减支，也是 `T_SOUL_LEECH` 用的那条）：

```json
["-",10,["*",["-",10,1],["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],["/",["log",["/",["-",3,1],["-",10,1]]],["-",["sqrt",6.5],["sqrt",1.3]]]],["/",["-",0,["-",["*",["-",["sqrt",6.5],["sqrt",1.3]],["log",["-",1,["/",["-",10,3],["-",10,1]]]]],["*",["sqrt",6.5],["log",["/",["-",3,1],["-",10,1]]]]]],["-",["sqrt",1.3],["sqrt",6.5]]]]]]]]
```

（递增支把 `["-",10,…]` 换成 `["*",limit,…]`、把减支的 `log(1-(low-high)/(low-limit))` 换成 `log(1-high/limit)`。）

## 已完成

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_HIEMAL_SHIELD | #0 | `["spellDamage",10,450]` | glacial-waste.lua:33 | ✅ |
| T_HIEMAL_SHIELD | #1 | `["spellDamage",10,60]` | glacial-waste.lua:32 | ✅ |
| T_HIEMAL_SHIELD | #2 | `["talentScale",10,40,0.75]` | glacial-waste.lua:34 | ✅ |
| T_DESOLATE_WASTE | #1 | `["spellDamage",10,40]` | glacial-waste.lua:184 | ✅ |
| T_DESOLATE_WASTE | #2 | `["talentScale",2,5]` | glacial-waste.lua:182 | ✅ |
| T_CRUMBLING_EARTH | #0 | `["spellDamage",30,120]` | glacial-waste.lua:219 | ✅ |
| T_BLEAK_GUARD | #0 | `L(50,10,25)` | glacial-waste.lua:238 | ✅ |
| T_BLEAK_GUARD | #1 | `["*",L(50,10,25),1.33]` | glacial-waste.lua:242 | ✅ |
| T_DIRE_PLAGUE | #1 | `["spellDamage",15,70]` | age-of-dusk.lua:33 | ✅ |
| T_DIRE_PLAGUE | #2 | `["talentScale",2,7]` | age-of-dusk.lua:34 | ✅ |
| T_CREPUSCULE | #0 | `["floor",S(3,8)]` | age-of-dusk.lua:67 | ✅ |
| T_CREPUSCULE | #1 | `["spellDamage",20,170]` | age-of-dusk.lua:68 | ✅ |
| T_THE_END_OF_ALL_HOPE | #1 | `["floor",S(1,5)]` | age-of-dusk.lua:109 | ✅ |
| T_THE_END_OF_ALL_HOPE | #2 | `["floor",S(30,80)]` | age-of-dusk.lua:110 | ✅ |
| T_GOLDEN_AGE_OF_NECROMANCY | #0 | `["floor",S(10,55)]` | age-of-dusk.lua:131 | ✅ |
| T_GOLDEN_AGE_OF_NECROMANCY | #1 | `["floor",L(100,20,50)]` | age-of-dusk.lua:130 | ✅ |
| T_SHIVGOROTH_FORM | #0 | `["+",4,["ceil",["talentLevel"]]]` | water.lua:180 | ✅ |
| T_SHIVGOROTH_FORM | #1 | `["talentLevel",true]` | water.lua:206 | ✅ |
| T_SHIVGOROTH_FORM | #2 | `["*",["/",BOUND,500],100]` | water.lua:181 | ✅ |
| T_SHIVGOROTH_FORM | #3 | `["/",<#2>,2]` | water.lua:206 | ✅ |
| T_SHIVGOROTH_FORM | #4 | `["+",50,<#2>]` | water.lua:206 | ✅ |
| T_SHIVGOROTH_FORM | #5 | `ICE0` | water.lua:224（经 :198 嵌套） | ✅ |
| T_SHIVGOROTH_FORM | #6 | `["+",5,["*",["power","法术强度"],0.05]]` | water.lua:225（经 :198 嵌套） | ✅ |
| T_BONEYARD | #0 | `["floor",S(5,15)]` | eradication.lua:33 | ✅ |
| T_BONEYARD | #1 | `["floor",S(10,30)]` | eradication.lua:34 | ✅ |
| T_BONEYARD | #2 | `["floor",S(10,55)]` | eradication.lua:35 | ✅ |
| T_BONEYARD | #3 | `["floor",S(1,9)]` | eradication.lua:36 | ✅ |
| T_TO_THE_GRAVE | #1 | `["floor",S(1,5)]` | eradication.lua:84 | ✅ |
| T_SPELLCRAFT | #0 | `["*",["min",0.3,["max",0.05,["/",["talentLevel",true],15]]],100]` | meta.lua:129 | ✅ |
| T_SPELLCRAFT | #1 | `["*",["talentLevel",true],20]` | meta.lua:128 | ✅ |
| T_ENERGY_ALTERATION | #0 | `["min",100,["ceil",S(30,90)]]` | meta.lua:161 | ✅ |
| T_METAFLOW | #1 | `["min",4,["max",1,["floor",["talentLevel"]]]]` | meta.lua:213 | ✅ |
| T_METAFLOW | #2 | `["floor",S(2,7)]` | meta.lua:214 | ✅ |
| T_SOUL_LEECH | #0 | `["ceil",["*",L(1,10,3),3]]` | animus.lua:32 | ✅ |
| T_SOUL_LEECH | #1 | `["ceil",["*",L(1,10,3),2.2]]` | animus.lua:33 | ✅ |
| T_SOUL_LEECH | #2 | `["ceil",["*",L(1,10,3),1.3]]` | animus.lua:34 | ✅ |
| T_SOUL_LEECH | #3 | `["ceil",L(1,10,3)]` | animus.lua:35 | ✅ |
| T_SOUL_LEECH | #4 | `["floor",S(2,8)]` | animus.lua:40 | ✅ |
| T_ORB_OF_THAUMATURGY | #0 | `["floor",S(2,6)]` | thaumaturgy.lua:36 | ✅ |
| T_ORB_OF_THAUMATURGY | #1 | `["-",100,["floor",L(0,55,25)]]` | thaumaturgy.lua:48 | ✅ |
| T_MULTICASTER | #0 | `["talentLimit",100,15,30]` | thaumaturgy.lua:63 | ✅ |
| T_SLIPSTREAM | #0 | `["floor",S(2,7)]` | thaumaturgy.lua:150 | ✅ |
| T_ALCHEMIST_PROTECTION | #0 | `["min",100,["*",["talentLevel",true],20]]` | explosives.lua:167 | ✅ |
| T_EXPLOSION_EXPERT | #0 | `["max",1,["floor",Sraw(2,6)]]` | explosives.lua:177 | ✅ |
| T_EXPLOSION_EXPERT | #1 | `["*",["/",["log10",THEO],["-",6,["min",["talentLevel",true],5]]],100]` | explosives.lua:178 | ✅ |
| T_HURRICANE | #0 | `["+",30,["*",["talentLevel"],5]]` | storm.lua:115 | ✅ |
| T_HURRICANE | #1 | `["+",2,["min",1,["floor",["/",["talentLevel"],3]]]]` | storm.lua:116 | ✅ |
| T_TEMPEST | #2 | `["*",["talentLevel"],9]` | storm.lua:159 | ✅ |
| T_TEMPEST | #3 | `["/",["*",["talentLevel"],9],2]` | storm.lua:188 | ✅ |

`THEO = ["^",["+",["*",2,["max",1,["floor",Sraw(2,6)]]],1],1.94]`（`minmax` 的 `theoretical_nb`）。

## 发现的写法模式

1. **`combatTalentLimit` 必须按 Combat.lua:1613-1619 的运算顺序手工展开，尤其是被 `floor`/`ceil` 包裹时。**
   节点 `["talentLimit",…]` 是代数等价的闭式，但在 `tl = 系数 × 等级` 的锚点上浮点会落到整数的另一侧：
   闭式得 `10.000000000000002`，源码序得 `9.999999999999998`，`%d` 截断就是 10 vs 9。
   代表：`T_BLEAK_GUARD` #0/#1（1.30 套第 1/5 点）、`T_GOLDEN_AGE_OF_NECROMANCY` #1、
   `T_SOUL_LEECH` #0-#3（`ceil` 同理，闭式在锚点上多进 1）、`T_ORB_OF_THAUMATURGY` #1（`limit=0` 时闭式直接 NaN）。
   反例：`T_MULTICASTER` #0 的闭式节点 15/15 通过——锚点恰好没被显示层取整放大，此时可以用短写法。

2. **`combatTalentLimit` 的 `low > high`（递减）支不能复用递增支的 `exp` 常数。**
   源码 Combat.lua:1618 把 `log(1-high/limit)` 换成 `log(1-(low-high)/(low-limit))`。
   代表：`T_SOUL_LEECH`（`combatTalentLimit(t,1,10,3)`：10 → 1 递减）。

3. **`floor`/`ceil` 包裹的 `combatTalentScale` 也要按 Combat.lua:1556 的顺序展开。**
   节点 `["talentScale",…]` 与之代数等价，但 `S(3,8)` 在 1.00 套第 5 点算出 `7.999999999999999`，`floor` 成 7，导出是 8。
   代表：`T_CREPUSCULE` #0。凡是**没有**取整包裹的 scale（如 `T_DIRE_PLAGUE` #2）闭式节点即可。

4. **嵌套整段技能说明（`getTalentFullDescription`）里被嵌技能的等级可能不是本技能的等级。**
   `T_SHIVGOROTH_FORM` 的 `info`（water.lua:198）把冰雪风暴整段说明嵌进 `%s`，被嵌技能在导出里是**等级 0**
   （描述头自己写着「有效技能等级：0.0」）。因此 #5 的等级项按 0 冻结（`(sqrt(0)-1)·0.8+1 = 0.19999999999999996`，
   必须原样写 `["+",1,["*",0.8,["-",["sqrt",0],1]]]` 而不是常量 0.2），#6 的 `getTalentLevel(t)` 项也是 0。
   与 `spell/deeprock` 的嵌套不同（那里嵌入的是 `raw × 2` 的 NPC 技能），这里没有可读的等级输入，只能冻结。

5. **「三套数字完全相同」= 按原始等级算**（`["talentLevel",true]`）：
   `T_SHIVGOROTH_FORM` #1、`T_SPELLCRAFT` #0/#1、`T_ALCHEMIST_PROTECTION` #0、
   `T_EXPLOSION_EXPERT` #0/#1（源码本身就写 `getTalentLevelRaw` / `raw=true`）。

6. **把 if/else 写成节点**：`T_HURRICANE` #1 的
   `local radius = 2; if self:getTalentLevel(t) >= 3 then radius = 3 end`
   ⟺ `["+",2,["min",1,["floor",["/",["talentLevel"],3]]]]`（15/15）。

7. **`util.bound` / `math.min` / `math.max` 直接照抄成 `min`/`max`**，注意保持 Lua 的运算顺序与参数顺序：
   `T_SHIVGOROTH_FORM` 的 `util.bound(x,0,500)/500*100`（写成 `["*",["/",BOUND,500],100]`，不要合并成 `/5`，
   `/500` 再 `*100` 与 `/5` 的最后一位不同）、`T_SPELLCRAFT` #0 的 `util.bound(raw/15,0.05,0.3)*100`。

8. **`power` 族的强度是「有效强度」**：`T_SHIVGOROTH_FORM` #5 用 `["power","法术强度"]` 作为
   `combatTalentSpellDamage` 的 `(base+P)` 项即可，不需要再换算原始值。

## 无法建模

本批没有「读懂了但写不出来」的条目。

## 疑点

### 1. `T_ALCHEMIST_PROTECTION` #1：源码与导出系统性不一致

| 系数 | 等级 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- |
| 导出 1.00 / 1.30 / 1.50（三套**完全相同**）| 3% | 6% | 9% | 12% | 15% |
| `["talentScale",4,17]` 算得（1.50 套）| 4 ❌ | 8.3564 ❌ | 11.6991 ❌ | 14.5172 ❌ | 17 ❌ |
| `["talentScale",4,17,…,raw=true]` 算得 | 4 ❌ | 8.3564 ❌ | 11.6991 ❌ | 14.5172 ❌ | 17 ❌ |

源码 `explosives.lua:157` 写的是 `getResists = function(self, t) return self:combatTalentScale(t, 4, 17) end`，
而导出三套都是**原始等级的线性 3×L**（3/6/9/12/15）。任何 `combatTalentScale` 都不可能产出线性序列，
也不用能解释锚点 3（低于 scale 的下界 4）。同一技能的 #0（`min(100, raw×20)`）与同文件的
`T_EXPLOSION_EXPERT` #0/#1 都与源码 15/15 吻合，所以不是文件错位。

判断：**导出侧数据来自 Alchemist Protection 抗性公式的旧版本/旧缓存**（导出是中文数据集），
不是可以用节点表写出来的源码公式。按「不编」原则**未写入覆盖层**；若主项目希望以导出为准，
可用 `["*",["talentLevel",true],3]`（15/15、输入集合也过），但它不是 `explosives.lua:157` 的公式。

### 2. （已解决，记录备查）闭式 `["talentLimit",…]` 的锚点浮点

前文「写法模式 1」的两条：`T_BLEAK_GUARD` #0 在 1.30 套第 1/5 点闭式给 10 / 25、导出是 9 / 24；
`T_GOLDEN_AGE_OF_NECROMANCY` #1 同理（19/49 vs 20/50）。展开成 Lua 顺序后 15/15。
这不是数据缺陷，是求值器口径问题——建议构建端对**带 `floor`/`ceil` 的 `combatTalentLimit`** 直接展开，
或用 `low > high` 时不要用闭式节点。
