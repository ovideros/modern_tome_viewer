# 表达式覆盖层（手写公式）格式与规则

自动提取失败、但源码里确实有公式的数值，可以由人或代理**手写表达式**补上。
覆盖层只是一份**候选表达式清单**：构建时仍走同一套校验（输入集合一致 + 三套共 15 点复现 + 唯一候选），
校验不过的条目会被丢弃并在构建日志里报告——所以覆盖层无法绕过安全闸门。

## 文件

`data/lua-expressions.json`：

```json
[
  {
    "talent": "T_FLAMESHOCK",
    "acronym": 1,
    "expr": ["spellDamage", 10, 250],
    "source": "tome-src-full/data/talents/spells/fire.lua:89",
    "note": "getDamage = combatTalentSpellDamage(t, 10, 250)"
  },
  {
    "talent": "T_ASHES_TO_ASHES",
    "acronym": 1,
    "expr": ["spellDamage", 8, 135, ["power", "法术强度", ["*", 1, ["pmod", ["actor", "paradox"]]]]],
    "source": "tome-src-full/data/talents/chronomancy/age-manipulation.lua:90"
  }
]
```

| 字段 | 必填 | 说明 |
| --- | --- | --- |
| `talent` | ✅ | 技能 id（`T_...`）|
| `acronym` | ✅ | 该技能 `info` 文本里第几个 `<acronym>`（**0 基**，与 `--list` 输出的 `acronym#N` 一致）|
| `expr` | ✅ | 表达式（下面的节点表）|
| `source` | ✅ | 你据以写公式的 getter 所在 `文件:行号`（至少要能人工复核）|
| `note` | 建议 | 原 Lua 一行摘要，便于将来比对 |
| `conditions` | 可选 | 条件倍率的状态标志取值，如 `{"sun_paladin_avatar": false}`|

## 校验命令

```sh
node scripts/try-formula.mjs --list [--tree <大系>] [--limit N]   # 取目标清单
node scripts/try-formula.mjs --talent <ID> --arg <N> --expr '[...]'  # 单条试算
node scripts/try-formula.mjs --overlay data/lua-expressions.json    # 批量验收
```

**PASS 的定义**：三套导出（系数 1.00 / 1.30 / 1.50）各自的 5 个点全部复现，**且**表达式读到的每个输入都在
标题里声明过——即 `表达式消耗 ⊆ 标题声明`（轴除外）。任一不满足即为 FAIL。

**注意方向**：只要求「覆盖」，**不**要求「用完」。导出会把整个 tooltip 的参数并集抄进多个 acronym 的
title（某个 range 明明不读 paradox，title 却写着 `paradox 300`），所以

```
标题声明 [paradox, 法术强度, 魔力] vs 表达式消耗 [paradox, 法术强度] ✅ 覆盖（标题是超集，本值未用到：魔力）
```

是 PASS。反过来，表达式读了标题没声明的输入会被点名并 FAIL：

```
标题声明 [法术强度] vs 表达式消耗 [法术强度, 魔力] ❌ 表达式读了标题未声明的输入 [魔力]
```

后一种情况要么换成标题声明过的等价写法，要么把该量**冻结成常数**并在 `note` 里说明理由（常数允许写死，
声明过的输入不允许），**不要**用 `["*",0,["actor","X"]]` 之类假节点去凑。

## 表达式节点表

数值一律是 JS number。可用输入（由标题/滑条提供）：

| 输入 | 表达式写法 | 含义 |
| --- | --- | --- |
| 技能等级 | `["talentLevel"]` | **有效**等级 = 原始等级 × 系数 |
| 技能等级（原始）| `["talentLevel", true]` | 未乘系数的原始等级（源码里 `getTalentLevelRaw` / `raw_scale`）|
| 四类有效强度 | `["power", "法术强度"]`、`"精神强度"`、`"physical power"`、`"steampower"` | 有效强度，可带倍率：`["power","法术强度",0.15]` |
| 角色等级 | `["actor", "角色等级"]` | |
| 属性 / 资源 | `["actor", "魔力"]`、`["actor", "paradox"]`、`["actor", "psi"]`、`["actor", "陷阱专精 技能等级"]` | 标签必须与标题里的参数标签一致 |
| 悖论修正 | `["pmod", ["actor", "paradox"]]` | `bound(sqrt(paradox/300), 0.5, 1.5)` |
| 条件标志 | `["cond", "sun_paladin_avatar", A, B]` | 状态开时取 A，否则取 B |
| 别的技能等级 | `["talentRef", "T_SHIELD_EXPERTISE"]` | 匹配时绑定到标题参数，否则按导出基准 0 |

运算与函数：

| 节点 | 说明 |
| --- | --- |
| `["+", a, b]` `["-", a, b]` `["*", a, b]` `["/", a, b]` `["^", a, b]` | 四则与幂 |
| `["floor", x]` `["ceil", x]` `["min", …]` `["max", …]` | 取整与极值 |
| `["sqrt", x]` `["abs", x]` `["log", x]` `["log10", x]` `["exp", x]` `["pow", x, y]` | 其它数学函数 |

游戏公式家族（`tl` 一律指有效等级）：

| 节点 | 游戏函数 | 语义 |
| --- | --- | --- |
| `["spellDamage", base, max, override?]` | `combatTalentSpellDamage` | `(base+强度)·((√tl−1)·0.8+1)·max/((base+100)·((√5−1)·0.8+1))`，再 `^1.04`；`mindDamage` / `physicalDamage` / `steamDamage` 同理，强度按类型取 |
| `["talentScale", low, high, power?, add?, shift?, raw?]` | `combatTalentScale` | 在等级 1→5 上匹配 `low`→`high`；`power` 可为 `"log"` |
| `["talentLimit", limit, low, high, raw?, mastery?]` | `combatTalentLimit` | 指数逼近上限；`mastery` 默认 1.3 |
| `["weaponDamage", base, max, bonus?]` | `combatTalentWeaponDamage` | `base+(max−base)·√((tl+bonus/2)/5)`（倍率，不是伤害）|
| `["statDamage", stat, base, max, noDR?]` | `combatTalentStatDamage` | 驱动量是属性（`"str"`…`"lck"`）；`noDR=true` 关闭递减 |
| `["statScale", stat, low, high, power?, add?, shift?]` | `combatStatScale` | 锚点在属性 10→100 |
| `["combatScale", x, yLow, xLow, yHigh, xHigh, power?, add?, shift?]` | `combatScale` | 通用版，锚点自定，驱动量是任意表达式 |
| `["combatLimit", x, limit, yLow, xLow, yHigh, xHigh]` | `combatLimit` | 通用版上限逼近 |
| `["pmod", x]` | `getParadoxModifier` | 见上 |

## 已验证的等价展开（用于「任意等级驱动」与嵌套描述）

节点表里的游戏公式族只能吃**该技能自己的**等级（有效等级或原始等级）。但有两类常见的值需要「用别的表达式当等级」：

- 嵌套整段说明：`info` 里 `self:getTalentFullDescription(tv, self:getTalentLevelRaw(t) * k)`，于是 acronym 来自 `tv` 技能的说明，而它的等级是 `k × 原始等级`；
- 某个 getter 内部先算出等级再转交给 `combatTalentScale` / `combatTalentXXXDamage`。

这两种情况不用新增节点，**在表达式层展开即可**（以下三条均由 `spell/deeprock` 实测 15/15 PASS）：

| 原写法 | 等价展开（`L` 可为任意表达式，例如 `["*",2,["talentLevel",true]]`）|
| --- | --- |
| `combatTalentScale(t, low, high, power)` @ L | `["combatScale", L, low, 1, high, 5, power]` |
| `combatTalentScale(t, low, high, "log")` @ L | `["+", low, ["*", ["/", ["-", high, low], ["log10", 5]], ["log10", L]]]` |
| `combatTalentXXXDamage(t, base, max)` @ L、强度 P | `["^", ["*", ["/", ["*", ["+", base, P], ["+", 1, ["*", 0.8, ["-", ["sqrt", L], 1]]]], ["*", ["+", base, 100], ["+", 1, ["*", 0.8, ["-", ["sqrt", 5], 1]]]]], max], 1.04]` |

`XXX` 为 spell/mind/physical/steam，`P` 用对应强度节点（spell 为 `["power","法术强度"]`）。守卫别漏：
`talentScale` 内有 `max(0, …)`、`log` 模式下有 `max(1, L)`；power 家族在 `damage <= 0` 时不做 `^1.04`。

**原始等级 vs 有效等级**：三套导出（系数 1.00/1.30/1.50）数字**完全相同**的值，几乎一定是按原始等级算的，
用 `["talentLevel", true]`；写 `["talentLevel"]` 会在 1.30/1.50 两套上崩。

## 导出的显示读数（不要把它写进公式）

判分器 `matchesDisplayed` 已按导出的**真实读数**逐点判定，所以**不要**为了"对上显示取整"而在公式外面套包装
（例如用 `["min",1,["floor",["/",v,10]]]` 当选择子去复刻渲染）。那固化的是静态导出的渲染伪影，滑条一动就错。

已知规律（判断器与渲染器都已实现）：

- 导出按技能自己的格式符（`%d` / `%0.1f` / `%0.2f` …）渲染每个值；
- 数值 **≥ 10** 时只打印整数部分——全库 6557 个 ≥10 的显示值里**没有**带小数点的；
- 所以同一条阶梯会混着 `3.33` 与 `10`，而某个整数点可能是"先按格式符归整、再取整"的产物
  （`%0.1f` 的 46.4835 → `"46.5"` → 47）。判定与渲染共认四种读数：`trunc` / `round` / `round1` / `round2`，
  由该阶梯自己的证据选定。

**你只写游戏公式；显示层的事交给判分器。** 若某条公式怎么算都过不了，先怀疑读数规律而不是公式。

## 硬性规则

1. **不许硬编码**：标题声明为输入的东西（技能等级、法术强度、paradox……）必须通过上表的写法读取。
   把 `["spellDamage",10,250]` 写成 `["spellDamage",10,250,300]` 只会在输入集合检查里被判 FAIL。
2. **不许无视轴**：表达式必须随该 acronym 的轴（标题里带 5 个值的那个参数）变化。
3. **只用上表的节点**；不要发明新节点（构建端不认识，会直接失败）。
4. **写不出来就写不出来**：以下情况没有唯一答案，请记入报告的"无法建模"清单，不要编：
   运行时数据表（符文/纹身/工匠的 `data.*`、`incStats.*`）、玩家武器/装备、随机数、投影链、
   别的角色状态、以及需要先解析别的技能 getter 才能得到的值。
   另有一类是**导出侧元数据缺陷**：acronym 的 title 声明了源码公式根本不用的输入（实测 `T_BOULDER_ROCK` #0 声明
   `[力量, 法术强度]`，而 `getDam` 只用 `["spellDamage",…]` → `[法术强度]`），表达式即使 15 点全中也过不了输入集合闸门。
   这类请写进报告的"疑点"一节，注明「标题过度声明输入」，不要为了凑输入集合而硬塞节点。
5. **改动范围**：只写 `data/lua-expressions.json` 与报告；不要改 `src/**`、`scripts/**`、`public/**`、`data/raw/**`。

## 说明：为什么是 15 个点

导出把同一批技能在三种"技能系数"下各渲染了一份（`talents.*-1.json` / `-1.3` / `-1.5`），
数字互不相同。三套一起校验，等于用三份独立数据证明同一条公式——只对 1.5 成立、
换个系数就崩的公式会被当场抓住。
