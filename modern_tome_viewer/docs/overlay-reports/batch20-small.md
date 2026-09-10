# batch20-small — 19 个大系公式补写报告

范围（按任务给定，共 19 个大系）：

`psionic/dream-forge`、`psionic/dreaming`、`psionic/dream-smith`、`psionic/thermal-mastery`、
`psionic/charged-mastery`、`psionic/slumber`、`psionic/thought-forms`、`psionic/augmented-mobility`、
`psionic/distortion`、`psionic/discharge`、`cursed/punishments`、`cursed/advanced-shadowmancy`、
`cursed/hatred`、`cursed/predator`、`cursed/one-with-shadows`、`cursed/fears`、`cursed/rampage`、
`cunning/lethality`、`cunning/traps`

覆盖层文件：`data/overlay-batches/batch20-small.json`（30 条）

```
$ node scripts/try-formula.mjs --overlay data/overlay-batches/batch20-small.json
覆盖层校验：30/30 通过
```

目标 30 条（`--list` 逐大系汇总），PASS 30 条，跳过 0 条；数组长度 30 == 通过数 30。

| 大系 | 目标数 | PASS | 跳过 |
| --- | --- | --- | --- |
| psionic/dream-forge | 2 | 2 | 0 |
| psionic/dreaming | 2 | 2 | 0 |
| psionic/dream-smith | 2 | 2 | 0 |
| psionic/thermal-mastery | 2 | 2 | 0 |
| psionic/charged-mastery | 2 | 2 | 0 |
| psionic/slumber | 1 | 1 | 0 |
| psionic/thought-forms | 1 | 1 | 0 |
| psionic/augmented-mobility | 1 | 1 | 0 |
| psionic/distortion | 1 | 1 | 0 |
| psionic/discharge | 1 | 1 | 0 |
| cursed/punishments | 3 | 3 | 0 |
| cursed/advanced-shadowmancy | 3 | 3 | 0 |
| cursed/hatred | 2 | 2 | 0 |
| cursed/predator | 2 | 2 | 0 |
| cursed/one-with-shadows | 1 | 1 | 0 |
| cursed/fears | 1 | 1 | 0 |
| cursed/rampage | 1 | 1 | 0 |
| cunning/lethality | 1 | 1 | 0 |
| cunning/traps | 1 | 1 | 0 |
| **合计** | **30** | **30** | **0** |

---

## 一、已完成

30 条全部为 `结论：PASS（三套 15 点全中，输入集合覆盖）`。

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_FORGE_BELLOWS | #2 | `["min",7,["+",2,["ceil",["/",["talentLevel"],2]]]]` | tome-src-full/data/talents/psionic/dream-forge.lua:100 | ✅ |
| T_DREAMFORGE | #0 | `["min",5,["+",1,["ceil",["/",["talentLevel"],3]]]]` | tome-src-full/data/talents/psionic/dream-forge.lua:215 | ✅ |
| T_SLEEP | #2 | `["ceil",["mindDamage",5,25]]` | tome-src-full/data/talents/psionic/dreaming.lua:37 | ✅ |
| T_DREAM_WALK | #0 | `["max",0,["-",7,["floor",["talentLevel"]]]]` | tome-src-full/data/talents/psionic/dreaming.lua:139 | ✅ |
| T_HAMMER_TOSS | #1 | `["*",10,["talentLevel"]]` | tome-src-full/data/talents/psionic/dream-smith.lua:120 | ✅ |
| T_DREAM_CRUSHER | #2 | `["*",100,["/",["sqrt",["/",["talentLevel"],5]],1.5]]` | tome-src-full/data/talents/psionic/dream-smith.lua:174 | ✅ |
| T_THERMAL_BALANCE | #0 | `["*",["mindDamage",50,150],["*",2,["/",["actor","psi"],100]]]` | tome-src-full/data/talents/psionic/thermal-mastery.lua:153 | ✅ |
| T_THERMAL_BALANCE | #1 | `["*",["mindDamage",50,150],["-",1,["/",["actor","psi"],100]]]` | tome-src-full/data/talents/psionic/thermal-mastery.lua:153 | ✅ |
| T_THOUGHT_SENSE | #0 | `["floor",["combatScale",["*",["/",["actor","意志"],10],["talentLevel"]],10,0,15,50]]` | tome-src-full/data/talents/psionic/charged-mastery.lua:57 | ✅ |
| T_HEARTSTART | #0 | `["*",-1,["+",["mindDamage",0,300],["*",1000,["talentLimit",1,0.015,0.055]]]]` | tome-src-full/data/talents/psionic/charged-mastery.lua:127 | ✅ |
| T_SLUMBER | #1 | `["ceil",["mindDamage",10,100]]` | tome-src-full/data/talents/psionic/slumber.lua:42 | ✅ |
| T_TRANSCENDENT_THOUGHT_FORMS | #0 | `["floor",["talentLevel"]]` | tome-src-full/data/talents/psionic/thought-forms.lua:514 | ✅ |
| T_SKATE | #1 | `["*",-100,["exp",["+",["*",["sqrt",["talentLevel"]],-0.7795256696436651],0.09028831554388436]]]` | tome-src-full/data/talents/psionic/augmented-mobility.lua:28 | ✅ |
| T_MAELSTROM | #1 | `["min",4,["+",1,["ceil",["/",["talentLevel"],3]]]]` | tome-src-full/data/talents/psionic/distortion.lua:168 | ✅ |
| T_FEEDBACK_LOOP | #0 | `["floor",["*",24,["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],-0.3056641042538604],0.16618914321123798]]]]]` | tome-src-full/data/talents/psionic/discharge.lua:111 | ✅ |
| T_HATEFUL_WHISPER | #2 | `["min",3,["talentLevel",true]]` | tome-src-full/data/talents/cursed/punishments.lua:103 | ✅ |
| T_HATEFUL_WHISPER | #3 | `["ceil",["min",6,["sqrt",["*",["talentLevel"],2]]]]` | tome-src-full/data/talents/cursed/punishments.lua:101 | ✅ |
| T_HATEFUL_WHISPER | #4 | `["min",40,["*",15,["sqrt",["talentLevel"]]]]` | tome-src-full/data/talents/cursed/punishments.lua:105 | ✅ |
| T_STONE | #0 | `["mindDamage",0,280]` | tome-src-full/data/talents/cursed/advanced-shadowmancy.lua:66 | ✅ |
| T_SHADOW_S_PATH | #0 | `["mindDamage",0,210]` | tome-src-full/data/talents/cursed/advanced-shadowmancy.lua:117 | ✅ |
| T_CURSED_BOLT | #0 | `["mindDamage",0,180]` | tome-src-full/data/talents/cursed/advanced-shadowmancy.lua:204 | ✅ |
| T_SELF_SACRIFICE | #0 | `["/",1000,["ceil",["*",50,["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],-0.20412620765814088],0.009596134276285837]]]]]]` | tome-src-full/data/talents/cursed/self-hatred.lua:29 | ✅ |
| T_SELF_JUDGEMENT | #1 | `["talentScale",3,5]` | tome-src-full/data/talents/cursed/self-hatred.lua:161 | ✅ |
| T_SAVAGE_HUNTER | #1 | `["mindDamage",0,60]` | tome-src-full/data/talents/cursed/predator.lua:70 | ✅ |
| T_MARK_PREY | #0 | `["floor",["+",1,["/",["talentLevel"],2]]]` | tome-src-full/data/talents/cursed/predator.lua:276 | ✅ |
| T_SHADOW_DECOY | #0 | `["*",-1,["+",10,["mindDamage",0,700]]]` | tome-src-full/data/talents/cursed/one-with-shadows.lua:132 | ✅ |
| T_PANIC | #0 | `["+",3,["floor",["*",["sqrt",["talentLevel"]],2.2]]]` | tome-src-full/data/talents/cursed/fears.lua:258 | ✅ |
| T_SLAM | #0 | `["+",2,["min",3,["floor",["*",["talentLevel"],0.5]]]]` | tome-src-full/data/talents/cursed/rampage.lua:147 | ✅ |
| T_SNAP | #1 | `["max",1,["talentLevel",true]]` | tome-src-full/data/talents/cunning/lethality.lua:143 | ✅ |
| T_CATAPULT_TRAP | #1 | `["*",100,["-",1,["exp",["+",["*",["sqrt",["*",["actor","陷阱专精 技能等级"],["talentLevel"]]],-0.4918259386509031],-1.7418172443179685]]]]` | tome-src-full/data/talents/cunning/traps.lua:2041 | ✅ |

---

## 二、发现的写法模式

### ① 半径/回合数的「min + ceil/floor」阶梯（灵能系扎堆）

一批 tooltip 值就是技能半径或持续回合，直接照抄一行即可，无需任何 helper：

- `radius = math.min(N, K + math.ceil(tl/d))` ⇒ `["min",N,["+",K,["ceil",["/",["talentLevel"],d]]]]`
  （`T_FORGE_BELLOWS` #2 用 `min(7, 2+ceil(tl/2))`，`T_DREAMFORGE` #0 用 `min(5, 1+ceil(tl/3))`，
  `T_MAELSTROM` #1 用 `min(4, 1+ceil(tl/3))`）
- `radius = math.max(0, N - math.floor(tl))` ⇒ 递减型（`T_DREAM_WALK` #0，三套分别 6/5/4/3/2 → 6/5/4/2/1 → 6/4/3/1/0）
- `math.floor(self:getTalentLevel(t))` ⇒ `["floor",["talentLevel"]]`（`T_TRANSCENDENT_THOUGHT_FORMS` #0）

### ② 灵能 `combatTalentMindDamage` 的「包裹层」写法

`getXxx` 里对 `combatTalentMindDamage` 再包一层取整/取负/乘系数时，外层必须照抄：

- `math.ceil(self:combatTalentMindDamage(t, b, m))` ⇒ `["ceil",["mindDamage",b,m]]`（`T_SLEEP` #2、`T_SLUMBER` #1）
- `getDamage*shadowWarriorMult(self)`，未学 `T_SHADOW_WARRIORS` 时 `mult=1`
  ⇒ 直接 `["mindDamage",0,280]`（`T_STONE`/`T_SHADOW_S_PATH`/`T_CURSED_BOLT` 三条同一模式）
- `10 + combatTalentMindDamage(t,0,700)` 且文本写作 `-%d life` ⇒ `["*",-1,["+",10,["mindDamage",0,700]]]`
  （`T_SHADOW_DECOY` #0，负号是文本字面量，导出把它并进了 acronym）
- 双子值：`damDesc(DARKNESS, d/2) + damDesc(MIND, d/2)` 两条 `damDesc` 相加后就是 `d` 本身
  ⇒ `["mindDamage",0,60]`（`T_SAVAGE_HUNTER` #1）

### ③ 灵能 psi 轴：`psi/maxPsi` 显式展开，`maxPsi=100` 是冻结常数

`T_THERMAL_BALANCE` 的 `dam1 = dam*(maxPsi-psi)/maxPsi`、`dam2 = dam*psi/maxPsi*2`。
标题只声明 `psi`（导出固定 50），`maxPsi` 从不出现，因此把 `maxPsi=100` 写成常数、`psi` 用
`["actor","psi"]` 读取，输入集合仍完全一致且 15/15。`T_SKATE` #1 的 `1-combatTalentLimit(...)`
同理（无 psi）。

### ④ 别的技能等级当轴：`["actor","陷阱专精 技能等级"] * ["talentLevel"]`

`T_CATAPULT_TRAP.resetChance` 用的是 **陷阱专精** 的等级，而不是自己的等级，而它的三套导出值又随
技能系数变化。沿用 `cunning/traps` 既有 31/31 的写法：轴取 `["actor","陷阱专精 技能等级"]`，
再乘 `["talentLevel"]`（在该 acronym 语境下它取的是技能系数 1/1.3/1.5），得到有效等级。
代表技能：`T_CATAPULT_TRAP` #1。

### ⑤ 「原始等级」判据：三套数字完全相同 ⇒ 用 `["talentLevel",true]`

- `T_HATEFUL_WHISPER` #2：`min(getJumpCount, 4)`，`getJumpCount = math.min(3, getTalentLevelRaw(t))`
  ⇒ 三套恒为 1/2/3/3/3，必须用原始等级（用有效等级会在 1.3 那套把 raw=3 误判成 3.9→仍 3，
  但 raw=4 的 5.2 会超 3 之外的判定；关键是导出三套相同）
- `T_SNAP` #1：`math.max(1, getTalentLevelRaw(t))` ⇒ `["max",1,["talentLevel",true]]`

### ⑥ 分段常数/单调取整阶梯可直接写成闭式

- `T_PANIC` #0：`3 + math.floor(math.pow(tl,0.5)*2.2)`（导出里 `range=4` 是文本字面量，不是 acronym）
- `T_SLAM` #0：`2 + math.min(math.floor(tl*0.5), 3)`
- `T_MARK_PREY` #0：`math.floor(1 + tl/2)`
- `T_HATEFUL_WHISPER` #3：`math.ceil(math.min(6, math.sqrt(tl*2)))`；#4：`math.min(40, 15*math.sqrt(tl))`
- `T_HEARTSTART` #0：`combatTalentMindDamage(t,0,300) + max_life*combatTalentLimit(t,1,.015,.055)`，
  取负；`max_life=1000` 是导出模型角色的冻结常数（标题未声明）
- `T_SELF_SACRIFICE` #0：`max_life / math.ceil(combatTalentLimit(t,50,10,20))`，同样 `max_life=1000`

### ⑦ `combatTalentLimit` 被 `floor/ceil` 包裹时必须展开成 Combat.lua 的指数原式

见「疑点」②：闭式节点 `["talentLimit",…]` 在 `tl = mastery` 端点返回**精确**的 `low`/`high`，
而游戏 `math.exp` 路径会给出 `3.9999999999`/`10.0000000001` 这类临界值，`floor/ceil` 一包就分道扬镳。
本批有 4 条必须展开（`T_FEEDBACK_LOOP` #0、`T_SKATE` #1、`T_SELF_SACRIFICE` #0、`T_CATAPULT_TRAP` #1），
展开式：

```
a = ln((high-limit)/(low-limit)) / (sqrt(6.5) - sqrt(1.3))
b = -((sqrt(6.5)-sqrt(1.3))*ln(1-high/limit) - sqrt(6.5)*ln((high-limit)/(low-limit))) / (sqrt(1.3)-sqrt(6.5))
v = limit * (1 - exp(sqrt(tl)*a + b))
```

（`a`、`b` 在本批里作为数值常数嵌入，因为 limit/low/high 都是源码常量。）

---

## 三、无法建模

**无。** 本批 30 条全部 PASS。

任务允许直接跳过的三类（`源码: 无记录`、工具报「标题里没有唯一可变的轴」、依赖真随机/玩家武器/别的实体状态）
在本批一次都没有触发：`--list` 里标「无候选」的 6 条（`T_DREAM_WALK` #0、`T_TRANSCENDENT_THOUGHT_FORMS` #0、
`T_FEEDBACK_LOOP` #0、`T_STONE` #0、`T_SHADOW_S_PATH` #0、`T_CURSED_BOLT` #0、`T_CATAPULT_TRAP` #1）
都只是自动提取器没跟上写法，逐条手写后 15/15。

两个「差点写不出来」但最终解决的点，记录成因：

| 点 | 差点失败的原因 | 解法 |
| --- | --- | --- |
| T_FEEDBACK_LOOP #0 | 闭式 `talentLimit` 在 `tl=1.3` 返回精确 4，`floor` 得 4，导出是 3 | 展开成 Combat.lua 指数原式（模式⑦） |
| T_CATAPULT_TRAP #1 | 轴是「陷阱专精 技能等级」，三套值随技能系数变化 | 轴 × `["talentLevel"]`（模式④） |

---

## 四、疑点

### ① `T_SELF_JUDGEMENT` #1：源码 `math.ceil` 与导出读数不一致

源码（`cursed/self-hatred.lua:161`）：

```lua
getTime = function(self, t) return math.ceil(self:combatTalentScale(t, 3, 5)) end,
```

但导出值等于**未取整**的 `combatTalentScale(t,3,5)`（`%d` 截断渲染）：

| 系数 | 导出 | `combatTalentScale` 原值 | `ceil` 后 `%d` |
| --- | --- | --- | --- |
| 1.00 | 3, 3, 4, 4, 5 | 3, 3.670, 4.184, 4.618, 5 | 3, 4, 5, 5, 5 |
| 1.30 | 3, 3, 4, 5, 5 | 3.227, 3.991, 4.577, 5.072, 5.507 | 4, 4, 5, 6, 6 |
| 1.50 | 3, 4, 4, 5, 5 | 3.364, 4.184, 4.814, 5.345, 5.813 | 4, 5, 5, 6, 6 |

写 `["talentScale",3,5]` 后 15/15 全中。判断是**导出所据的游戏版本没有这层 `ceil`**（或该行后来才加），
不是显示层问题——`ceil` 后的读数在任何显示规则下都对不上导出。

### ② `combatTalentLimit` 在 `tl = mastery` 端点：节点表实现与游戏浮点结果不同

`["talentLimit",…]` 的闭式在 `tl = mastery`（默认 1.3）处严格返回 `low`，在 `tl = 5*mastery` 处严格返回 `high`
（数学上两者等价，但浮点路径不同）：

| 点 | 游戏 `math.exp` 路径 | 闭式节点 | 导出 |
| --- | --- | --- | --- |
| `combatTalentLimit(1.3, 24, 4, 11)` | 3.999999999999999 | 4 | 3（`floor`） |
| `combatTalentLimit(6.5, 24, 4, 11)` | 10.999999999999998 | 11 | 10（`floor`） |
| `combatTalentLimit(1.3, 100, 90, 95)` | 89.99999999999999 | 90 | 89（`trunc`） |

因此凡是被 `floor`/`ceil` 包裹的 `combatTalentLimit` 都必须按 Combat.lua 的 `exp/log/sqrt` 原式展开
（模式⑦）。未被取整包裹的（如 `T_HEARTSTART` #0 的 `max_life*limit`、`T_CATAPULT_TRAP` #1 之前）用闭式节点
也能过，因为差值远小于显示精度。

### ③ 导出 info_text 与仓库源码的 acronym 顺序/条数不一致（元数据层，非公式错）

同一个技能，仓库源码的 `tformat(...)` 参数序与导出 tooltip 的 `<acronym>` 序在以下几处对不上，
通常是因为**导出把纯字面量（不带占位符参数）留在正文里**，而源码的 `tformat` 仍为它占了一个位置：

| 技能 | 源码 `tformat` 序 | 导出实际 acronym | 说明 |
| --- | --- | --- | --- |
| `T_PANIC` | `(range, duration, chance)` | `#0=duration, #1=chance` | 导出正文「使 **4** 范围内」把 `range=4` 写成字面量 |
| `T_SAVAGE_HUNTER` | `(miasmaCount, radius, damage, chance)` | `#0=miasmaCount, #1=damage, #2=chance` | 导出正文「半径 X 码内的 **4** 格内」，`radius=4` 是字面量 |
| `T_DREAM_CRUSHER` | `(damage, stun, power, percent)` | `#0=damage, #1=stun, #2=percent` | 导出正文「增加 **30** 点…物理强度」，`power=30` 是字面量 |
| `T_SHADOW_DECOY` | `(power)` | `#0=-power` | 导出正文「降至 **-**%d 下」，负号被并进 acronym |

这几条都不影响可建模性——按导出的实际 acronym 语义（而不是源码的 tformat 位置）写表达式即可 30/30 通过；
登记在此供构建端修正 acronym 索引或标题元数据时参考。

### ④ `T_SELF_SACRIFICE` / `T_HEARTSTART` 依赖未声明的 `max_life`

两者的导出数值都含 `self.max_life`（标题只声明 `技能等级`/`技能系数`/`精神强度`，没有最大生命）。
按规则把 `max_life` 冻结成常数 `1000`（导出模型角色的取值，两条独立拟合都落在 1000 且 15/15 全中，
可交叉验证）。登记为「冻结常数」而非「硬编码输入」。
