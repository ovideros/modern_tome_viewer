# 覆盖层报告 · `batch22-corruptions`

命令：`node scripts/try-formula.mjs --overlay data/overlay-batches/batch22-corruptions.json`
结果：**33/33 通过**（目标 34 条；1 条记入「无法建模」，0 条记入「疑点未收录」）

```
覆盖层校验：33/33 通过
```

覆盖的 13 个大系与目标数：

| 大系 | 目标数 | PASS | 跳过 |
| --- | --- | --- | --- |
| corruption/wrath | 8 | 8 | 0 |
| corruption/demonic-pact | 6 | 6 | 0 |
| corruption/oppression | 2 | 2 | 0 |
| corruption/fearfire | 1 | 1 | 0 |
| corruption/demonic-strength | 1 | 1 | 0 |
| corruption/torture | 1 | 1 | 0 |
| corruption/doom-covenant | 1 | 1 | 0 |
| corruption/doom-shield | 1 | 1 | 0 |
| corruption/black-magic | 2 | 1 | 1 |
| corruption/blight | 6 | 6 | 0 |
| corruption/torment | 2 | 2 | 0 |
| corruption/shadowflame | 2 | 2 | 0 |
| corruption/rot | 1 | 1 | 0 |
| **合计** | **34** | **33** | **1** |

源码位置：前 9 个大系在 `dlc-src/ashes-urhrok/tome-ashes-urhrok/data/talents/corruptions/`，
后 4 个（blight / torment / shadowflame / rot）在 `tome-src-full/data/talents/corruptions/`。

## 已完成

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_DESTROYER | #3 | `["ceil",["/",["talentLevel",true],3]]` | wrath.lua:200 | ✅ |
| T_DESTROYER | #4 | `["*",10,["talentLevel",true]]` | wrath.lua:201 | ✅ |
| T_DESTROYER | #5 | `["+",3,["ceil",["/",["talentLevel",true],2]]]` | wrath.lua:201 | ✅ |
| T_DESTROYER | #6 | `["ceil",["/",["talentLevel",true],4]]` | wrath.lua:202 | ✅ |
| T_DESTROYER | #7 | `["ceil",["/",["talentLevel",true],2]]` | wrath.lua:203 | ✅ |
| T_DESTROYER | #8 | `["+",25,["*",10,["talentLevel",true]]]` | wrath.lua:204 | ✅ |
| T_DESTROYER | #9 | `["*",["talentLevel",true],0.4]` | wrath.lua:205 | ✅ |
| T_DESTROYER | #10 | `["*",["talentLevel",true],10]` | wrath.lua:206 | ✅ |
| T_DEMON_SEED | #0 | `["*",100,["weaponDamage",0.6,1.6]]` | demonic-pact.lua:603 | ✅ |
| T_DEMON_SEED | #1 | `["*",100,["weaponDamage",0.6,1.4]]` | demonic-pact.lua:603 | ✅ |
| T_DEMON_SEED | #2 | `["floor",["talentScale",2.5,4.5]]` | demonic-pact.lua:604 | ✅ |
| T_DEMON_SEED | #3 | `["floor",["max",0,["+",["*",16.180339887498945,["^",["talentLevel"],0.5]],-6.1803398874989455]]]` | demonic-pact.lua:605 | ✅ |
| T_SUFFUSE_LIFE | #0 | `["ceil",["talentScale",3,8]]` | demonic-pact.lua:907 | ✅ |
| T_SUFFUSE_LIFE | #2 | `["+",15,["spellDamage",10,150]]` | demonic-pact.lua:906 | ✅ |
| T_HORRIFYING_BLOWS | #2 | `["*",1.25,["min",1,["max",0,["floor",["/",["talentLevel"],3]]]]]` | oppression.lua:53 | ✅ |
| T_HORRIFYING_BLOWS | #3 | `["min",1,["max",0,["floor",["/",["talentLevel"],5]]]]` | oppression.lua:46 | ✅ |
| T_FEARSCAPE_SHIFT | #3 | `["min",10,["floor",["+",7.5,["/",["talentLevel",true],2]]]]` | fearfire.lua:38 | ✅ |
| T_SURGE_OF_POWER | #2 | `["-",0,["ceil",["spellDamage",20,250]]]` | demonic-strength.lua:58 | ✅ |
| T_INCINERATING_BLOWS | #4 | `["*",5,["talentLevel",true]]` | torture.lua:54 | ✅ |
| T_DREAD_END | #1 | `["-",0,["spellDamage",15,60]]` | doom-covenant.lua:67 | ✅ |
| T_OSMOSIS_SHIELD | #1 | `["+",5,["/",["*",200,["*",50,["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],-0.8889040310163111],0.6568315874976276]]]]],100]]` | doom-shield.lua:36 | ✅ |
| T_GRIM_FUTURE | #1 | `["/",["spellDamage",20,200],10]` | black-magic.lua:81 | ✅ |
| T_POISON_STORM | #0 | `["floor",["talentScale",6,10]]` | blight.lua:165 | ✅ |
| T_POISON_STORM | #1 | `["/",["spellDamage",12,130],4]` | blight.lua:166 | ✅ |
| T_POISON_STORM | #2 | `["spellDamage",12,130]` | blight.lua:166 | ✅ |
| T_POISON_STORM | #3 | `["/",["*",150,["talentScale",15,40]],["+",["talentScale",15,40],50]]` | blight.lua:169 | ✅ |
| T_POISON_STORM | #4 | `["talentScale",15,40]` | blight.lua:169 | ✅ |
| T_POISON_STORM | #5 | `["/",["*",50,["talentScale",15,40]],["+",["talentScale",15,40],26]]` | blight.lua:171 | ✅ |
| T_BLOOD_VENGEANCE | #0 | `["talentLimit",5,15,8]` | torment.lua:122 | ✅ |
| T_BLOOD_VENGEANCE | #1 | `["combatLimit",["spellDamage",10,90],100,20,0,50,61.3]` | torment.lua:122 | ✅ |
| T_WRAITHFORM | #1 | `["talentScale",5,20]` | shadowflame.lua:30 | ✅ |
| T_WRAITHFORM | #2 | `["talentScale",5,16]` | shadowflame.lua:30 | ✅ |
| T_WORM_WALK | #0 | `["max",0,["-",7,["floor",["talentLevel"]]]]` | rot.lua:236 | ✅ |

## 发现的写法模式

1. **`t:_getX(self)` / `t.getX(self, t)` 仍是有效等级**（沿用 `demon-seeds` 的结论）。
   代表技能：`T_POISON_STORM` #1–#5（`t.getEffects` 一次返回 `power, heal_factor, fail` 三个值，
   工具报 `Multiple local assignment`，但三个 acronym 都能各自写成闭式并 15/15）、
   `T_WRAITHFORM` #1/#2（`t.getDefs` 返回 `def, armor` 两个 `combatTalentScale`）。
   **多返回值 getter 不必建模成元组**，只要按 `tformat` 的位置拆成独立表达式即可。

2. **导出 acronym 的编号 ≠ `tformat` 参数顺序**，必须按**导出渲染文本**数（沿用 `demon-seeds` 结论）。
   本批两个典型：
   - `T_DESTROYER` 的 8 个目标正好是 `tformat` 的 `dest` 系列（源码第 197–206 行），
     但 `#3..#10` 之间夹着 `math.min(math.ceil(...))` 等常量/派生量；
   - `T_INCINERATING_BLOWS` 只有 5 个 acronym（`tformat` 有 7 个参数），
     常量 `%d%% chance`（25）与常量 `3 turns` 不进 acronym 表，
     所以 `#4` 是源码里第 7 个参数 `getPowerbonus`，不是文本第 5 个 `getDur`。
     直接看 `public/data/talents.json` 的 `acronyms[]` 逐项对照 `l` 字段最快。

3. **同一 acronym 里既可以有 `< 10` 的小数也可以有 `≥ 10` 的整数**，判分器自己会挑 `trunc`/`round` 读数，
   **不要在外面套显示包装**（文档「导出的显示读数」一节的结论在本批再次成立）。
   代表：`T_POISON_STORM` #4（`["talentScale",15,40]`，同一阶梯上 `19.5456→19`、`44.3165→44` 都是截断）
   与 #1（`["/",["spellDamage",12,130],4]`，`22.9389→23` 是四舍五入）。两者都直接写裸公式即可。

4. **「按等级取开关值」的写法**：源码里用 `if self:getTalentLevel(t) >= N then X else 0 end`
   决定一个阈值（不是属性/状态标志）。节点表没有 `if`，用
   `["min",1,["max",0,["floor",["/",["talentLevel"],N]]]]`（取 0/1）或乘上 X 展开即可。
   代表：`T_HORRIFYING_BLOWS` #2（`getSlowPower`，阈值 3，值 `0.0125*100`）、
   #3（`radius`，阈值 5，值 1）、`T_WORM_WALK` #0（`max(0, 7-floor(tl))`）。

5. **`combatTalentSpellDamage` 家族照抄 `base`/`max` 即可**，`damDesc(...)` 是恒等包裹。
   代表：`T_POISON_STORM` #2、`T_GRIM_FUTURE` #1、`T_DREAD_END` #1。

6. **负号写在文本里的读数要当成读数的一部分**：`-%d HP`（`T_SURGE_OF_POWER` #2）与
   `until reaching %d life`（`T_DREAD_END` #1，效果里取负）在导出里是**负数**，
   表达式写成 `["-",0,<正值>]` 才 15/15。

7. **`combatLimit` 节点与 Lua 完全同构**，不需要手工展开。
   代表：`T_BLOOD_VENGEANCE` #1 直接 `["combatLimit",["spellDamage",10,90],100,20,0,50,61.3]` 15/15。

## 无法建模

### 1. `T_STRIPPED_LIFE` #0（`black-magic.lua:61`）——导出侧 acronym 跨段合并，工具报「没有唯一可变的轴」

源码：`getStack = math.ceil(combatTalentScale(t, 3, 9))`，说明文本
`For each stack of Bleak Outcome up to %d the afflicted creatures are weakened, reducing their resistances by 2%%.`
里只有**一个**变量 `%d`，`2%%` 是字面常量。

但导出的 `talents.json` 把两个数字**合并进同一个 acronym**：

```
T_STRIPPED_LIFE.acronyms[0].d = [5,2,7,2,9,2,11,2,12,2]
```

即 5 个真实值 `[5,7,9,11,12]` 与常量 `2` 交替出现（1.00 套为 `[3,2,6,2,7,2,8,2,9,2]`，
1.30 套为 `[4,2,6,2,8,2,10,2,11,2]`）。判分器据此无法确定唯一轴：

```
技能 T_STRIPPED_LIFE (灵魂弱化 / corruption/black-magic) · acronym#0
  系数 1: ✗ 标题里没有唯一可变的轴
  系数 1.3: ✗ 标题里没有唯一可变的轴
  系数 1.5: ✗ 标题里没有唯一可变的轴
结论：FAIL
```

`["ceil",["talentScale",3,9]]` 本身能复现 5 个真实值（`5/7/9/11/12` 等），
但工具在轴识别阶段就拒绝了——属于**导出侧元数据缺陷**，不是公式问题。
按任务规则（工具报「标题里没有唯一可变的轴」直接跳过）未写入批次。

## 疑点

### 1. 工具的 `["talentScale",…]` 节点在 `tl == x_high` 处比 Lua 少 1 个 ULP（本批已用等价展开规避）

源码 `Combat.lua:1556-1562` 的写法是

```
m = (high-low)/(x_high_adj - x_low_adj)
b = low - m*x_low_adj
value = max(0, m*(tl+shift)^power + b + add)
```

而工具 `src/lib/lua-formula.js:110-113` 把它重排成

```
slope = (high-low)/(transform(5)-transform(1))
value = max(0, slope*(transform(x) - transform(1)) + low + add)
```

两者数学恒等，但 `x == 5` 时前者的 `m*5^0.5 + b` 精确落回 `high`，后者的
`slope*(5^0.5-1) + low` 会落在 `high - 1ULP`。`floor`/`ceil` 恰好在边界上就分道扬镳。

实测 `T_DEMON_SEED` #3 = `math.floor(self:combatTalentScale(t, 10, 30))`：

| 系数 | 1 | 1.3 | 1.5 |
| --- | --- | --- | --- |
| 导出 | 10/16/21/26/**30** | 12/19/25/30/35 | 13/21/28/33/38 |
| `["floor",["talentScale",10,30]]` | 10/16/21/26/**29** ❌ | 全中 | 全中 |

展开成 Lua 顺序后 15/15：

```
["floor",["max",0,["+",["*",16.180339887498945,["^",["talentLevel"],0.5]],-6.1803398874989455]]]
```

（`m = 16.180339887498945`，`b = low - m = -6.1803398874989455`。）
本批其他 `talentScale`（#2、`T_SUFFUSE_LIFE` #0、`T_POISON_STORM` #0/#3/#4/#5、
`T_WRAITHFORM` #1/#2）用节点原样通过，只有 `tl=5` 点落在整数边界的那一条需要展开。
建议主项目把 `lua-formula.js` 的 `talentScale` 改成 Lua 的 `m*(tl)^p+b` 顺序，
以后同类值不必手工展开。

### 2. `["talentLimit",…]` 节点在锚点 `tl == mastery` 上仍差 1（沿用 `demon-seeds` 的结论）

`T_OSMOSIS_SHIELD` #1 用节点的闭式写法时，系数 1.30、等级 1（有效等级 1.3 = mastery）失败：

| | 系数 1.3、等级 1 |
| --- | --- |
| 导出 | **34** |
| `["+",5,["/",["*",200,["talentLimit",50,15,40]],100]]` | 35（闭式精确等于 `low`，U 排在整数上方）|
| exp 展开（本批采用） | 34 ✅ |

采用的手工展开（`limit*(1-exp(sqrt(tl)*a+b))`，`a=-0.8889040310163111`、`b=0.6568315874976276`）：

```
["+",5,["/",["*",200,["*",50,["-",1,["exp",["+",["*",["sqrt",["talentLevel"]],-0.8889040310163111],0.6568315874976276]]]]],100]]
```

`T_BLOOD_VENGEANCE` #0 的 `["talentLimit",5,15,8]` 则**没有**触发这个问题（15 个点全中），
说明分叉只发生在「锚点值被取整成整数」的那些构造上。建议与 §1 一并修。

### 3. `T_OSMOSIS_SHIELD` 的标题没有声明 `shield block`，公式里的 block 值被冻结成常数

源码 `doom-shield.lua:36` 是 `5 + block * combatTalentLimit(t, 50, 15, 40) / 100`，
`block = self:combatShieldBlock()`。导出 `--list` 的标题参数写着 `shield block=200`，
但工具读到的**标题声明是 `[无]`**——按文档第 4 条，声明里没有的量只能冻结成常数：

- `["+",5,["/",["*",["actor","shield block"],…],100]]` → `❌ 表达式读了标题未声明的输入 [shield block]`；
- `["+",5,["/",["*",200,…],100]]` → 输入集合 ✅ 且 15/15。

`note` 里已注明「shield block 未被标题声明故冻结为 200」。请主项目核对是导出侧漏抄了参数标签，
还是 `combatShieldBlock()` 属于「玩家装备」一类本就不可建模——若是后者，本条应改成
「以 200 格挡为基准的示意公式」。

### 4. `T_GRIM_FUTURE` #1：源码故意把技能等级临时压成 1，导出却按真实等级阶梯

源码 `black-magic.lua:81-89`：

```lua
getDam = function(self, t)
    local old = self.talents[t.id]
    self.talents[t.id] = 1                      -- "Dont want double scaling. Ugh"
    local v
    pcall(function() v = self:combatTalentSpellDamage(t, 20, 200) / 10 end)
    self.talents[t.id] = old
    return v or 1
end,
```

按源码字面，这个值应当是**常数**（1 级的伤害/10）；但三套导出都是随等级上升的阶梯
（1.00：12/16/20/22/25，1.30：14/18/22/25/28，1.50：14/20/24/27/30），
与**不压缩等级**的 `["/",["spellDamage",20,200],10]` 15/15 吻合。

推测导出管线在生成 tooltip 时恢复/绕过了这个临时改写（或 `pcall` 与 `t.id` 的组合使它没生效）。
表达式按**导出读数**写（全等级），`note` 里已注明差异，供人工复核。

### 5. 本批未发现「标题过度声明输入」的条目

33 条里输入集合检查全部是 `✅ 完全一致` 或 `✅ 覆盖`（`T_SUFFUSE_LIFE` #2 / `T_GRIM_FUTURE` #1 /
`T_BLOOD_VENGEANCE` #1 / `T_POISON_STORM` #1/#2 / `T_SURGE_OF_POWER` #2 / `T_DREAD_END` #1
声明 `[法术强度]` 且表达式正好只用 `[法术强度]`）。
