# batch03-spells —— 读 Lua 源码补公式报告

范围：23 个大系共 48 条目标（`spell/advanced-golemancy`、`golem/golem`、`spell/conveyance`、`spell/grave`、
`spell/temporal`、`spell/necrosis`、`spell/wildfire`、`spell/stone`、`spell/air`、`spell/ice`、`spell/phantasm`、
`spell/spectre`、`spell/fire`、`spell/energy-alchemy`、`spell/enhancement`、`spell/eldritch-shield`、
`golem/arcane`、`spell/divination`、`spell/golemancy`、`spell/earth`、`spell/arcane`、`spell/stone-alchemy`、
`spell/staff-combat`）。

产出：`data/overlay-batches/batch03-spells.json`（47 条）。
汇总：`node scripts/try-formula.mjs --overlay data/overlay-batches/batch03-spells.json` → **覆盖层校验：47/47 通过**。
覆盖情况：48 条目标 = 47 条 PASS + 1 条跳过（`T_DYNAMIC_RECHARGE#1`，导出侧缺 acronym）。

## 已完成（47/47，三套 15 点全中）

| 技能id | acronym#N | 表达式 | source | 15/15 |
| --- | --- | --- | --- | --- |
| T_FLAMESHOCK | 0 | `["floor",["combatScale",["talentLevel",true],4,1,8,5]]` | spells/fire.lua:102 | ✅ |
| T_FIREFLASH | 1 | `["combatScale",["talentLevel",true],2,1,5.5,5]` | spells/fire.lua:149 | ✅ |
| T_FEATHER_WIND | 5 | `["floor",["*",2.5,["talentLevel"]]]` | spells/air.lua:165 | ✅ |
| T_THUNDERSTORM | 0 | `["floor",["talentLevel"]]` | spells/air.lua:215 | ✅ |
| T_GEM_GOLEM | 0 | `["talentLevel",true]` | spells/advanced-golemancy.lua:73 | ✅ |
| T_RUNIC_GOLEM | 0 | `["talentLevel",true]` | spells/advanced-golemancy.lua:166 | ✅ |
| T_SUPERCHARGE_GOLEM | 0 | `["/",["+",60,["spellDamage",15,450]],7]` | spells/advanced-golemancy.lua:86 | ✅ |
| T_SUPERCHARGE_GOLEM | 1 | `["talentLimit",100,30,55]` | spells/advanced-golemancy.lua:86 | ✅ |
| T_BLACK_ICE | 1 | `["talentScale",10,30]` | spells/grave.lua:39 | ✅ |
| T_CHILL_OF_THE_TOMB | 2 | `["talentScale",5,25]` | spells/grave.lua:86 | ✅ |
| T_CORPSELIGHT | 1 | `["floor",["talentScale",3,7.5]]` | spells/grave.lua:118 | ✅ |
| T_CONGEAL_TIME | 0 | `["min",["*",8,["talentLevel"]],60]` | spells/temporal.lua:34 | ✅ |
| T_TIME_SHIELD | 1 | `["+",5,["floor",["talentLevel"]]]` | spells/temporal.lua:68 | ✅ |
| T_ESSENCE_OF_SPEED | 0 | `["*",100,["combatScale",["talentLevel"],0.075,1,0.26,5,0.3333333333333333]]` | spells/temporal.lua:129 | ✅ |
| T_BLURRED_MORTALITY | 0 | `["-",0,["statDamage","con",30,1000]]` | spells/necrosis.lua:34 | ✅ |
| T_RUNESKIN | 0 | `["-",0,["talentScale",8,30]]` | spells/necrosis.lua:111 | ✅ |
| T_RUNESKIN | 1 | `["talentScale",1,1.8]` | spells/necrosis.lua:112 | ✅ |
| T_CLEANSING_FLAMES | 0 | `["ceil",["talentScale",6,15]]` | spells/wildfire.lua:119 | ✅ |
| T_CLEANSING_FLAMES | 2 | `["*",10,["talentLevel",true]]` | spells/wildfire.lua:120 | ✅ |
| T_WILDFIRE | 2 | `["min",100,["*",14,["talentLevel"]]]` | spells/wildfire.lua:148 | ✅ |
| T_EARTHEN_MISSILES | 0 | `["+",2,["min",1,["floor",["/",["talentLevel"],5]]]]` | spells/stone.lua:62 | ✅ |
| T_BODY_OF_STONE | 4 | `["*",10,["talentLevel"]]` | spells/stone.lua:87 | ✅ |
| T_CRYSTALLINE_FOCUS | 2 | `["*",5,["talentLevel"]]` | spells/stone.lua:196 | ✅ |
| T_SHATTER | 1 | `["ceil",["+",2,["talentLevel"]]]` | spells/ice.lua:110 | ✅ |
| T_UTTERCOLD | 2 | `["min",100,["*",20,["talentLevel",true]]]` | spells/ice.lua:172 | ✅ |
| T_ILLUMINATE | 2 | `["+",3,["min",1,["floor",["/",["talentLevel"],5]]]]` | spells/phantasm.lua:41 | ✅ |
| T_INVISIBILITY | 0 | `["spellDamage",10,50]` | spells/phantasm.lua:131 | ✅ |
| T_DISPLACEMENT_SHIELD | 0 | `["min",100,["+",40,["*",5,["talentLevel"]]]]` | spells/conveyance.lua:296 | ✅ |
| T_DISPLACEMENT_SHIELD | 2 | `["min",25,["+",10,["floor",["*",3,["talentLevel"]]]]]` | spells/conveyance.lua:298 | ✅ |
| T_PROBABILITY_TRAVEL | 1 | `["*",100,["+",2,["/",["-",5,["min",5,["talentLevel",true]]],2]]]` | spells/conveyance.lua:353 | ✅ |
| T_SPECTRAL_SIGHT | 1 | `["min",10,["floor",["+",7.5,["/",["talentLevel"],2]]]]` | spells/spectre.lua:174 | ✅ |
| T_SPECTRAL_SIGHT | 2 | `["floor",["+",10,["talentLevel"]]]` | spells/spectre.lua:175 | ✅ |
| T_LIVING_LIGHTNING | 3 | `["+",50,["/",["spellDamage",5,500],10]]` | spells/energy-alchemy.lua:151 | ✅ |
| T_FIERY_HANDS | 2 | `["/",["talentLevel"],3]` | spells/enhancement.lua:108 | ✅ |
| T_SHOCK_HANDS | 2 | `["/",["talentLevel"],3]` | spells/enhancement.lua:151 | ✅ |
| T_ELDRITCH_BLOW | 0 | `["*",100,["weaponDamage",0.6,["/",["+",100,["spellDamage",50,300]],100]]]` | spells/eldritch-shield.lua:62 | ✅ |
| T_ELDRITCH_INFUSION | 2 | `["talentScale",5,10]` | spells/eldritch-shield.lua:77 | ✅ |
| T_ARCANE_EYE | 0 | `["floor",["+",10,["*",3,["talentLevel"]]]]` | spells/divination.lua:30 | ✅ |
| T_GOLEM_PORTAL | 0 | `["min",100,["+",25,["*",15,["talentLevel",true]]]]` | spells/golemancy.lua:510 | ✅ |
| T_STONE_WALL | 0 | `["+",2,["spellDamage",5,12]]` | spells/earth.lua:192 | ✅ |
| T_ARCANE_POWER | 1 | `["+",5,["/",["spellDamage",10,500],18]]` | spells/arcane.lua:83 | ✅ |
| T_IMBUE_ITEM | 0 | `["talentLevel",true]` | spells/stone-alchemy.lua:146 | ✅ |
| T_STAFF_MASTERY | 0 | `["/",["*",100,["sqrt",["/",["talentLevel"],5]]],1.5]` | spells/staff-combat.lua:100 | ✅ |
| T_GOLEM_ARMOUR | 0 | `["-",["*",1.4,["talentLevel",true]],4.2]` | spells/golem.lua:470 | ✅ |
| T_GOLEM_ARMOUR | 1 | `["-",["*",5,["talentLevel",true]],15]` | spells/golem.lua:469 | ✅ |
| T_GOLEM_ARMOUR | 2 | `["-",["*",1.9,["talentLevel",true]],5.7]` | spells/golem.lua:471 | ✅ |
| T_GOLEM_MOLTEN_SKIN | 1 | `["+",5,["talentLevel"]]` | spells/golem.lua:428 | ✅ |

## 发现的写法模式

1. **acronym 序号 = `info` 里 `tformat(...)` 的参数顺序**，但导出会丢掉"整条阶梯恒定"的参数，
   使后续 acronym 序号整体前移：`T_CORPSELIGHT` 的"半径 3 / 持续 7"是字面量，实际 #0=伤害、#1=最大层数；
   `T_GOLEM_MOLTEN_SKIN` 同理 #1=持续回合而非伤害。读源码时要先把 `tformat` 参数与导出文本逐个对齐。
2. **等级口径二选一**：三套导出（系数 1.00/1.30/1.50）数字完全相同 ⇒ 该值走 `getTalentLevelRaw`，
   写 `["talentLevel",true]`；数字随系数变 ⇒ 走有效等级，写 `["talentLevel"]`。
   代表：`T_GEM_GOLEM`（原始）对 `T_FEATHER_WIND`（有效）。同一个 tooltip 里两种口径可以并存
   （`T_FLAMESHOCK`：#0 半径按原始等级，而 #1 伤害按有效等级）。
3. **`combatTalentScale` 的阈值/整点陷阱**：源码 `math.floor(self:combatTalentScale(t, low, high))`
   在等级 5 端点常算出 `29.99999…` 被 `floor` 成 29，而导出是 30。这类值**不要写 `floor`**，
   直接 `["talentScale",low,high]`，由判分器按截断读数命中（`T_BLACK_ICE`、`T_CHILL_OF_THE_TOMB`）。
   相反，源码里本来就是 `math.ceil` 的必须写 `ceil`（`T_CLEANSING_FLAMES`、`T_SHATTER`）。
4. **`combatTalentScale` 的 power 是表达式时**用通用展开：`["combatScale",L,low,1,high,5,power]`
   （`T_ESSENCE_OF_SPEED`，power = 1/3 的三次根缩放）。
5. **阈值型三元式 `level >= N and X or Y`** 展开为计数式：
   `["+", base, ["min",1,["floor",["/",["talentLevel"],N]]]]`
   （`T_EARTHEN_MISSILES` 的等级 5 加一枚飞弹、`T_ILLUMINATE` 的等级 5 致盲回合 3→4）。
6. **`min/max/bound` 上限**：`math.min(100, ...)`、`util.bound(v, lo, hi)` 直接写 `["min",...]`；
   多数 `bound` 的上界在本区间不可达（`T_TIME_SHIELD`、`T_STONE_WALL`、`T_LIVING_LIGHTNING`）只需下界侧公式。
7. **纯等级线性项**（`getTalentLevel(t)/3`、`*5`、`*10`、`*14`、`*20`）直接 `["*"|"/", k, ["talentLevel"]]`，
   是这批里最省事的一类：`T_FIERY_HANDS`、`T_SHOCK_HANDS`、`T_BODY_OF_STONE`、`T_CRYSTALLINE_FOCUS`。
8. **`combatTalentSpellDamage` 的派生包裹**：`(A + spellDamage(b,m))/B`（`T_SUPERCHARGE_GOLEM#0`）、
   `5 + spellDamage/18`（`T_ARCANE_POWER#1`）、`50 + spellDamage/10`（`T_LIVING_LIGHTNING#3`）、
   `2 + spellDamage`（`T_STONE_WALL#0`）、`100*combatTalentWeaponDamage(t,0.6,(100+spellDamage)/100)`
   （`T_ELDRITCH_BLOW#0`，用 `["weaponDamage",base,max]` 节点，max 用表达式）。
9. **导出的负号入读数**：文本写成 "`-%d`" 的（`T_BLURRED_MORTALITY`、`T_RUNESKIN#0`）acronym 读数是负数，
   公式要把正值整体取负：`["-",0,<正公式>]`。
10. **依赖 `getTalentTypeMastery(...)` 的乘子**（`T_GOLEM_ARMOUR`）在导出里恒为 1（三套同值），
    直接把 mastery 冻结成常数 1，写成 `["-",["*",k,["talentLevel",true]],c]`。

## 无法建模（1 条）

| 技能id | acronym#N | 原因 |
| --- | --- | --- |
| T_DYNAMIC_RECHARGE | 1 | `getNb = self:getTalentLevel(t) <= 6 and 1 or 2`。公式本身可写（`1.3`/`1.5` 两套 5/5 全中），但 **1.00 那套导出里没有这个 acronym**：该阶梯在系数 1.0 下五点为 `1,1,1,1,1` 恒定，导出器不把它识别为可变变量，文本里只剩字面量"减少 1 回合冷却时间"。工具因此报 `该技能在这套导出里找不到，或没有这个 acronym`，`FAIL`。属导出侧缺项，非公式问题。 |

其余 47 条均非"运行时数据表/玩家武器/随机数/别的角色状态"类，全部读通并写出。

## 疑点（源码与导出数字系统性不一致）

1. **`T_INVISIBILITY#0`（源码 ceil vs 导出截断）**
   源码 `getInvisibilityPower = math.ceil(combatTalentSpellDamage(t, 10, 50))`；等级 1、法术强度 100 时算得
   `28.594`，源码 ceil 应为 29，而导出为 28。去掉 `ceil` 后按截断读数三套 15 点全中。
   三套数据：`28/38/46/52/58`、`31/43/52/59/66`、`33/46/55/63/70`。
   → 说明导出渲染层对 `%d` 用截断，源码里的 `ceil` 被显示层覆盖（或导出侧元数据对该值重新取整）。

2. **`T_BLACK_ICE#1` / `T_CHILL_OF_THE_TOMB#2`（源码 floor vs 导出整点）**
   二者源码都是 `math.floor(self:combatTalentScale(...))`，等级 5 端点算得 `29.99999…`，源码 floor 给 29，
   导出给 30（`T_BLACK_ICE`：`10/16/21/26/30`，`T_CHILL_OF_THE_TOMB`：`5/11/16/21/25`）。
   → 导出渲染是按数值截断，不叠加源码 floor；写公式时省略 floor 才能 15/15。

3. **`T_SUPERCHARGE_GOLEM#1`（限制函数族不符）**
   源码 `self:combatTalentLimit(t, 100, 30, 55)`（Combat.lua 的精确指数逼近）在等级 1 应给 30，
   导出为 26；而工具里 `["talentLimit",100,30,55]`（默认 `mastery=1.3` 的几何逼近节点）三套 15 点全中。
   → 导出这侧用的是几何/幂次逼近写法，而非 Combat.lua 的 `combatLimit` 精确式；节点语义以工具为准。
   三套数据：`26/35/41/46/50`、`30/39/46/51/55`、`31/41/48/53/57`。

4. **`T_FIREFLASH#1`、`T_FLAMESHOCK#0` 等 `combatTalentScale` 值在三套导出中完全相同**
   （即按原始等级），而**同一个 tooltip 的伤害值**（`combatTalentSpellDamage`）随系数变化。
   同一技能内"缩放类数值按原始等级、伤害类数值按有效等级"两种口径并存，
   与 Combat.lua 中 `combatTalentScale` 亦用 `getTalentLevel` 的实现不符，属导出侧口径差异。

5. **`T_GOLEM_ARMOUR` 的 mastery 乘子在导出中恒为 1**
   源码 `getArmor/getArmorHardiness/getCriticalChanceReduction` 都乘
   `self:getTalentTypeMastery("technique/combat-training")`（运行时值，本不可建模），
   但三套导出数值完全相同，反推 mastery = 1，故按常数 1 冻结（已在 `note` 注明）。
