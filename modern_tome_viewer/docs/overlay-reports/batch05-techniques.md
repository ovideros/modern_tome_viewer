# 覆盖层报告：`batch05-techniques`（29 个战术系）

范围：`technique/` 下 29 个大系（源码主要在 `tome-src-full/data/talents/techniques/`，个别在
`tome-src-full/data/talents/misc/npcs.lua`）。产出文件：`data/overlay-batches/batch05-techniques.json`。

- 目标数：**54** 条 acronym（逐系 `node scripts/try-formula.mjs --list --tree <大系>` 枚举，共 54 行）
- PASS：**42** 条
- 跳过并记录：**12** 条（全部为「标题里没有唯一可变的轴」或「依赖玩家装备」，见「无法建模」）
- 批次自检：`node scripts/try-formula.mjs --overlay data/overlay-batches/batch05-techniques.json`
  → `覆盖层校验：42/42 通过`（通过数 = 数组长度）

| 大系 | 目标数 | PASS | 跳过 |
| --- | --- | --- | --- |
| `technique/bloodthirst` | 3 | 3 | 0 |
| `technique/archery-sling` | 3 | 3 | 0 |
| `technique/grappling` | 2 | 2 | 0 |
| `technique/other` | 3 | 2 | 1 |
| `technique/unarmed-other` | 5 | 2 | 3 |
| `technique/duelist` | 3 | 2 | 1 |
| `technique/2hweapon-offense` | 2 | 2 | 0 |
| `technique/dualweapon-attack` | 2 | 2 | 0 |
| `technique/combat-techniques-passive` | 2 | 2 | 0 |
| `technique/strength-of-the-berserker` | 2 | 2 | 0 |
| `technique/shield-defense` | 2 | 2 | 0 |
| `technique/archery-training` | 2 | 2 | 0 |
| `technique/conditioning` | 1 | 1 | 0 |
| `technique/2hweapon-cripple` | 1 | 1 | 0 |
| `technique/dualweapon-training` | 2 | 1 | 1 |
| `technique/archery-bow` | 1 | 1 | 0 |
| `technique/unarmed-discipline` | 1 | 1 | 0 |
| `technique/unarmed-training` | 1 | 1 | 0 |
| `technique/battle-tactics` | 1 | 1 | 0 |
| `technique/warcries` | 1 | 1 | 0 |
| `technique/combat-techniques-active` | 1 | 1 | 0 |
| `technique/agility` | 1 | 1 | 0 |
| `technique/skirmisher-slings` | 1 | 1 | 0 |
| `technique/thuggery` | 2 | 0 | 2 |
| `technique/shield-offense` | 1 | 1 | 0 |
| `technique/buckler-training` | 1 | 1 | 0 |
| `technique/marksmanship` | 1 | 1 | 0 |
| `technique/field-control` | 1 | 1 | 0 |
| `technique/throwing-knives` | 5 | 1 | 4 |
| **合计** | **54** | **42** | **12** |

## 已完成（每条均 `结论：PASS（三套 15 点全中，输入集合覆盖）`）

| 技能id | acronym | 表达式 | source（相对 `tome-src-full/data/`）| 三套 |
| --- | --- | --- | --- | --- |
| `T_BLOODBATH` | #1 | `["talentScale",1.7,5]` | `techniques/bloodthirst.lua:59` | 15/15 |
| `T_BLOODBATH` | #5 | `["talentScale",1.7,5]` | `techniques/bloodthirst.lua:60` | 15/15 |
| `T_BOW_MASTERY` | #0 | `["/",["*",100,["sqrt",["/",["talentLevel"],5]]],1.5]` | `techniques/bow.lua:26` | 15/15 |
| `T_SLING_MASTERY` | #0 | `["/",["*",100,["sqrt",["/",["talentLevel"],5]]],1.5]` | `techniques/sling.lua:26` | 15/15 |
| `T_SLING_MASTERY` | #1 | `["floor",["/",["talentLevel"],2]]` | `techniques/sling.lua:27` | 15/15 |
| `T_MASTER_MARKSMAN` | #0 | `["/",["*",100,["sqrt",["/",["talentLevel"],5]]],1.5]` | `techniques/marksmanship.lua:33` | 15/15 |
| `T_SKIRMISHER_SLING_SUPREMACY` | #0 | `["/",["*",100,["sqrt",["/",["talentLevel"],5]]],1.5]` | `techniques/skirmisher-slings.lua:24` | 15/15 |
| `T_UNARMED_MASTERY` | #0 | `["/",["*",100,["sqrt",["/",["talentLevel"],5]]],1.5]` | `techniques/unarmed-training.lua:67` | 15/15 |
| `T_BLOODY_BUTCHER` | #0 | `["combatScale",["*",["/",["*",5,["actor","力量"]],100],["talentLevel"]],5,0,40,35]` | `techniques/bloodthirst.lua:84` | 15/15 |
| `T_MULTISHOT` | #0 | `["talentScale",2.8,4.3,"log"]` | `techniques/sling.lua:124` | 15/15 |
| `T_SLOW_MOTION` | #0 | `["min",90,["+",15,["*",["/",["*",10,["actor","敏捷"]],100],["talentLevel"]]]]` | `techniques/field-control.lua:140` | 15/15 |
| `T_THROWING_KNIVES` | #1 | `["floor",["talentLimit",10,4,7]]` | `techniques/throwing-knives.lua:127` | 15/15 |
| `T_SUNDER_ARMS` | #1 | `["*",3,["talentLevel"]]` | `techniques/2hweapon.lua:353` | 15/15 |
| `T_BULL_SHOT` | #1 | `["+",1,["min",1,["floor",["/",["talentLevel"],3]]]]` | `techniques/agility.lua:199` | 15/15 |
| `T_SKIRMISHER_BASH_AND_SMASH` | #1 | `["+",2,["min",1,["floor",["/",["talentLevel"],3]]]]` | `techniques/buckler-training.lua:89` | 15/15 |
| `T_UNFLINCHING_RESOLVE` | #0 | `["*",["combatLimit",["actor","体质"],1,0.28,10,0.745,100],["talentLimit",100,45,80]]` | `techniques/conditioning.lua:56` | 15/15 |
| `T_GRAPPLING_STANCE` | #0 | `["/",["*",20,["actor","力量"]],100]` | `techniques/grappling.lua:32` | 15/15 |
| `T_GRAPPLING_STANCE` | #1 | `["/",["*",10,["actor","力量"]],100]` | `techniques/grappling.lua:33` | 15/15 |
| `T_STEADY_SHOT` | #0 | `["*",100,["weaponDamage",1.0,1.8]]` | `techniques/archery.lua:152` | 15/15 |
| `T_STEADY_SHOT` | #1 | `["min",100,["+",20,["floor",["talentScale",2,10]]]]` | `techniques/archery.lua:155` | 15/15 |
| `T_CRIPPLING_SHOT` | #1 | `["min",40,["max",10,["*",15,["talentLevel"]]]]` | `techniques/archery.lua:764` | 15/15 |
| `T_VENOMOUS_AMMUNITION` | #1 | `["^",["*",["/",["*",["+",20,["power","physical power"]],["+",1,["*",0.8,["-",["sqrt",["talentRef","T_EXOTIC_MUNITIONS"]],1]]]],["*",120,["+",1,["*",0.8,["-",["sqrt",5],1]]]]],180],1.04]` | `techniques/munitions.lua:220` | 15/15 |
| `T_CRUSHING_HOLD` | #1 | `["*",["min",1,["floor",["/",["talentLevel"],5]]],["*",100,["^",["*",["/",["*",["+",0.05,100],["+",1,["*",0.8,["-",["sqrt",["talentLevel"]],1]]]],["*",["+",0.05,100],["+",1,["*",0.8,["-",["sqrt",5],1]]]]],0.45],1.04]]]` | `techniques/grappling.lua:120` | 15/15 |
| `T_TAKE_DOWN` | #1 | `["physicalDamage",10,400]` | `techniques/grappling.lua:241` | 15/15 |
| `T_QUICK_RECOVERY` | #0 | `["talentScale",0.6,2.5,0.75]` | `techniques/combat-techniques.lua:188` | 15/15 |
| `T_UNENDING_FRENZY` | #0 | `["talentScale",5,20,0.5]` | `techniques/combat-techniques.lua:244` | 15/15 |
| `T_HEARTSEEKER` | #0 | `["*",100,["weaponDamage",1.0,1.7]]` | `techniques/dualweapon.lua:307` | 15/15 |
| `T_HEARTSEEKER` | #1 | `["*",50,["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],["/",["log",["/",["-",30,50],["-",10,50]]],["-",["sqrt",6.5],["sqrt",1.3]]]],["/",["-",0,["-",["*",["-",["sqrt",6.5],["sqrt",1.3]],["log",["-",1,["/",30,50]]]],["*",["sqrt",6.5],["log",["/",["-",30,50],["-",10,50]]]]]],["-",["sqrt",1.3],["sqrt",6.5]]]]]]]` | `techniques/dualweapon.lua:308` | 15/15 |
| `T_DUAL_WEAPON_MASTERY` | #0 | `["-",100,["*",100,["talentLimit",1,0.6,0.85]]]` | `techniques/duelist.lua:60` | 15/15 |
| `T_DUAL_WEAPON_MASTERY` | #2 | `["min",100,["combatLimit",["*",["talentLevel"],["actor","敏捷"]],90,15,20,60,250]]` | `techniques/duelist.lua:39` | 15/15 |
| `T_BERSERKER` | #0 | `["combatScale",["*",["/",["*",7,["actor","敏捷"]],100],["talentLevel"]],5,0,40,35]` | `techniques/2hweapon.lua:73` | 15/15 |
| `T_BERSERKER` | #1 | `["combatScale",["*",["/",["*",7,["actor","力量"]],100],["talentLevel"]],5,0,40,35]` | `techniques/2hweapon.lua:72` | 15/15 |
| `T_BERSERKER_RAGE` | #0 | `["combatScale",["*",["/",["*",7,["actor","敏捷"]],100],["talentLevel"]],5,0,40,35]` | `techniques/strength-of-the-berserker.lua:72` | 15/15 |
| `T_BERSERKER_RAGE` | #1 | `["combatScale",["*",["/",["*",7,["actor","力量"]],100],["talentLevel"]],5,0,40,35]` | `techniques/strength-of-the-berserker.lua:71` | 15/15 |
| `T_CLOSE_COMBAT_MANAGEMENT` | #0 | `["combatScale",["*",["/",["*",25,["actor","敏捷"]],100],["talentLevel"]],0,0,35,125,0.5,0,1]` | `techniques/dualweapon.lua:113` | 15/15 |
| `T_PRECISE_STRIKES` | #1 | `["+",["+",["statScale","dex",0.4,4,0.75],4],["*",["*",["/",4,["-",["sqrt",5],1]],["statScale","dex",0.4,4,0.75]],["-",["sqrt",["talentLevel"]],1]]]` | `techniques/combat-techniques.lua:106` | 15/15 |
| `T_TOUCH_OF_DEATH` | #1 | `["*",20,["+",1,["+",["^",["+",1,["/",["talentLimit",100,25,40],100]],2],["+",["^",["+",1,["/",["talentLimit",100,25,40],100]],3],["^",["+",1,["/",["talentLimit",100,25,40],100]],4]]]]]` | `techniques/unarmed-discipline.lua:175` | 15/15 |
| `T_LAST_STAND` | #1 | `["+",["statDamage","con",30,500],["*",1000,["talentLimit",1,0.02,0.1]]]` | `techniques/weaponshield.lua:321` | 15/15 |
| `T_LAST_STAND` | #2 | `["-",0,["+",["statDamage","con",30,500],["*",1000,["talentLimit",1,0.02,0.1]]]]` | `techniques/weaponshield.lua:362` | 15/15 |
| `T_RIPOSTE` | #2 | `["*",["+",10,["*",40,["+",["*",0.5,["/",["actor","敏捷"],100]],["*",0.5,["/",["talentLevel"],6.5]]]]],["-",1,["/",["log10",["*",2,["+",10,["*",40,["+",["*",0.5,["/",["actor","敏捷"],100]],["*",0.5,["/",["talentLevel"],6.5]]]]]]],7]]]` | `techniques/weaponshield.lua:82` | 15/15 |
| `T_STEP_UP` | #0 | `["min",100,["*",["talentLevel",true],20]]` | `techniques/battle-tactics.lua:52` | 15/15 |
| `T_BATTLE_CRY` | #1 | `["*",7,["talentLevel"]]` | `techniques/warcries.lua:123` | 15/15 |

## 写法模式（建议提升成解析器规则）

1. **`*_Mastery` 家族（弓/投石索/徒手/射击精通）**：`getPercentInc = sqrt(getTalentLevel(t)/5)/1.5`，
   tooltip 打印 `100*inc`。代表：`T_BOW_MASTERY`、`T_SLING_MASTERY`、`T_MASTER_MARKSMAN`、
   `T_SKIRMISHER_SLING_SUPREMACY`、`T_UNARMED_MASTERY`。表达式
   `["/",["*",100,["sqrt",["/",["talentLevel"],5]]],1.5]`，同一条公式 5 处复用。
2. **`self:getStr(base, true)` / `getDex(base, true)` 在导出模型里就是 `base*stat/100`**（不是 T-Engine 的
   `rescaleCombatStats` 版本）。实测：`getStr(20,true)@力量100 = 20`、`getStr(5,true)@力量100 = 5`、
   `getDex(10,true)@敏捷100 = 10`。凡源码写 `combatScale(self:getStr(B,true)*getTalentLevel(t), …)`
   的（`T_BLOODY_BUTCHER`、`T_BERSERKER`、`T_BERSERKER_RAGE`、`T_CLOSE_COMBAT_MANAGEMENT`、
   `T_GRAPPLING_STANCE`），照 `["/",["*",B,["actor","力量"]],100]` 写即可**消费到标题声明的属性**，
   不必冻结常数。
3. **`combatTalentScale` 的三参/四参形态**：`["talentScale",low,high,power]`（`T_BLOODBATH`、
   `T_QUICK_RECOVERY` 用 0.75、`T_MULTISHOT` 用 `"log"`、`T_UNENDING_FRENZY` 用 0.5）。
   注意 `talentScale` 节点的第三参**必须显式给出或省略**，传 `null` 会得到 NaN。
4. **`util.bound(x,lo,hi)*100` → `["min",hi,["max",lo,x]]`**。代表：`T_CRIPPLING_SHOT#1`（结果还整体 ×15）。
5. **`if getTalentLevel(t) >= N then A else B end` 这种阶跃**没有条件节点，用
   `B + min(1, floor(tl/N)) * (A-B)` 展开（恰好只跨一级）。代表：`T_BULL_SHOT#1`（`1+min(1,floor(tl/3))`）、
   `T_SKIRMISHER_BASH_AND_SMASH#1`（`2+min(1,floor(tl/3))`）、`T_CRUSHING_HOLD#1`（乘 `min(1,floor(tl/5))`）。
6. **`combatTalentLimit` / `combatTalentStatDamage` / `combatTalentWeaponDamage` 直接有节点**，优先用节点；
   仅当节点与导出出现浮点级差别时才手写原式（见「疑点」第 1 条）。
7. **`talentScale` / `statScale` 的 `low`/`high` 位置不吃嵌套表达式**（实现里是裸数组，不会递归求值）。
   凡是 `combatTalentScale(t, dex, dex*5, …)` 这种「上下界本身是变量」的写法，必须自己按
   `low + (high-low)*(transform(tl)-transform(1))/(transform(5)-transform(1))` 展开。
   代表：`T_PRECISE_STRIKES#1`（`dex = combatStatScale("dex",0.4,4,0.75)`）。
8. **`combatTalentIntervalDamage(t, stat, min, max)` 没有节点**，等价于
   `v*(1-log10(2v)/7)`（外层 `^(1/1.04)` 与 `rescaleDamage(^1.04)` 相消），其中
   `v = min + (max-min)*(0.5*stat/100 + 0.5*tl/6.5)`。代表：`T_RIPOSTE#2`。
9. **`combatTalentStatDamage` 的 DR 层用 `["statDamage",stat,base,max]` 节点即可**（默认开递减，
   并且它内部已经把 `^(1/1.04)`+`^1.04` 相消）。代表：`T_LAST_STAND#1/#2`。
10. **同一 tooltip 里 `tformat` 的静态参数会消失、acronym 序号会前移**：`T_TOUCH_OF_DEATH` 的
    `damage=20`（`getStrikingStyle` 未开姿态时返回 0）在导出里是纯文本，于是 `#0=mult`、`#1=finaldam`、
    `#2=radius`，比源码 tformat 的位次各少 1。读 tooltip 的 `info_text` 定位 acronym 序号最稳。

## 无法建模

1. `T_SKULLCRACKER#0`（`techniques/thuggery.lua:35`）——**依赖玩家装备与武器伤害**。
   `getDamage` 先取头部装备 `o = self:getInven("INVEN_HEAD")[1]`，用 `o:getPriceFlags()`、
   `o:getPowerRank()`、`o:material_level`、`o:attr("metallic")` 算 `add`，再拿 `self.combat_dam`（玩家武器）
   算 `power`，最后 `rescaleDamage(totstat/1.5*power*ta_mod)`。导出无对应滑条，写不出唯一公式。
2. `T_DEFENSIVE_THROW#3`（`misc/npcs.lua:3364`）、`T_STRIKING_STANCE#0/#1/#2`（`techniques/pugilism.lua:29`）、
   `T_DUAL_WEAPON_MASTERY#1`（`duelist.lua:24`）、`T_DUAL_WEAPON_DEFENSE#1`（`dualweapon.lua:39`）、
   `T_SKULLCRACKER#1`（`thuggery.lua:29`）、`T_THROWING_KNIVES#2/#3/#4/#5`（`throwing-knives.lua:100`）——
   工具直接报 `标题里没有唯一可变的轴`。这些 acronym 的 title 里并列了两条以上**取值阶梯完全相同**的
   属性轴（如 `力量 10,25,50,75,100, 敏捷 10,25,50,75,100`），判分器无法确定哪一个才是轴，故无法验收。
   `T_THROWING_KNIVES#2/#3/#5` 本身也是 `combatDamage(combat)` 装备链产物，即使有轴也过不了。

## 疑点

1. **`combatTalentLimit` 在锚点处导出比 sim 少 1（Lua 浮点截断）**：`T_HEARTSEEKER#1`
   （`dualweapon.lua:308`，`combatTalentLimit(t,50,10,30)`）在系数 1.3 的 5 点上导出为
   `9/18/23/27/29`，而 sim 的 `talentLimit` 节点给出 `10/18.291/23.4675/27.1692/30`——
   两个锚点（tl=1.3 与 tl=6.5）恰好是整数，**Lua 的 `math.exp` 给出 9.999999999999998 / 29.999999999999993，
   `%d` 截断成 9 / 29**；sim 的闭式（等价重排）恰好给出 10 / 30。解决办法：把 Lua 原式
   `limit*(1-exp(sqrt(tl)*a+b))` 用 `["exp"]`/`["log"]`/`["sqrt"]` 逐项展开（保留同样的运算顺序），
   浮点结果即与导出一致。已按此法写入并 PASS，示例见 `T_HEARTSEEKER#1` 的表达式。
   三套数据（导出 / 原式算得）：
   - 系数 1 ： 7/15/20/23/26 ｜ 7.145/15.0436/20.1024/23.7938/26.6665
   - 系数 1.3： 9/18/23/27/29 ｜ 9.999999999999998/18.291/23.4675/27.1692/29.999999999999993
   - 系数 1.5： 11/20/25/28/31 ｜ 11.6296/20.1024/25.3118/28.9916/31.7762
2. **`T_LAST_STAND#1/#2` 的生命值增益含 `self.max_life`**（`weaponshield.lua:321` 的
   `lifebonus`），而 title 只声明 `技能等级 + 敏捷 + 体质`。反解得导出角色的 `max_life ≈ 995–1003`，
   取整为 1000 后 15 点全中（`204/287/350/402/446`）。已在 `note` 里写明「max_life 冻结为 1000」，
   不是凭空常数。
3. **`T_CRUSHING_HOLD#1` 的 physical power 未被 title 声明**（`grappling.lua:120` 的 `getSlow` 走
   `combatTalentPhysicalDamage`）：直接用 `["physicalDamage",…]` 会被判
   `❌ 表达式读了标题未声明的输入 [physical power]`。反解得导出基线 physical power = 100，
   按「把该量冻结成常数并在 note 说明理由」处理，手动展开 power 家族（base 0.05 / max 0.45）。属导出侧
   **标题少声明输入**，非公式问题。
4. **`T_CRIPPLING_SHOT#1` 的 `精准` 未被判分器算作已声明输入**（`archery.lua:764`）：
   title 里写着 `精准 100`，但 `declaredInputs` 报 `[无]`，用 `["actor","精准"]` 会 FAIL
   `❌ 表达式读了标题未声明的输入 [精准]`。改冻结 `combatAttack()=精准=100`（即 `15*tl`）后 15 点全中。
   同 `T_SKULLCRACKER` 的 `精准` 一样属于「other 类标签没进声明集合」的元数据缺陷。
