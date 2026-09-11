# 物品词缀社区补充表导入报告

由 `scripts/items/community.mjs` 生成，请勿手工编辑。

## 总览

- 生成时间：2026-09-11T13:55:18.235Z
- 来源文件：`others/物品词缀表（1.7.6版本适用）.xlsx`
- 工作表数：20
- 数据行（词缀名非空）：594
- 匹配到 ego 的行：570（其中仅经共享池匹配：65）
- 未匹配行：24
- 稀有度冲突：14
- 数值区间对不上：3
- 写入 ego 记录：530（其中 `confidence: shared-pool`：25）
- 其中被标记 `updated`：14

## 匹配口径

1. 工作表名映射到一个「本池」（见下表）。
2. 允许池集合由 `public/data/items-report.json` 的 `pools[].loads` 派生，不硬编码，包含三部分：本池本身 ∪ 本池加载的池（传递闭包）∪ 加载本池的池。
   - 加载闭包：`heavy-armor` 加载 `armor`，所以重甲/板甲/轻甲可以出普通护甲（armor）词缀；
   - 反向的「加载本池」：`bow`/`sling` 加载 `ranged`，所以远程武器表可以覆盖弓/投石索专属词缀；`light-boots` 加载 `boots`，所以鞋子表的「潜行」有归属。
   - 有意排除「兄弟池」：`steamsaw` 同时加载 `weapon` 和 `shield`，但普通长剑不是盾，因此近战武器表不会拉入 shield 专有词缀（盾牌表同理），否则共享中文名会产生错误匹配。
3. 一个 ego 命中，当且仅当其**所属池** `ego.pool`（定义它的文件）属于允许池集合。不使用 `ego.pools`（可达集）求交集——可达集包含兄弟池，会造成上面那条的越界匹配；`ego.pool` 同时用于报告。
4. 置信度取值：
   - `high`：本池直接命中（`ego.pool === 本池`）；
   - `shared-pool`：经共享池命中（`ego.pool` 属于允许集合但不是本池，例如 armor 词缀落在重甲/板甲/轻甲上）；
   - `medium`：允许池内有多个同名 ego，整行记给全部候选。
5. 允许池集合之外的任何池都不会被匹配；未命中行仍带跨池同名线索进入「未匹配行」供人工排查。

## 允许池集合（本池 ∪ 加载闭包 ∪ 加载本池的池）

| 工作表 | 本池 | 允许池集合 |
| --- | --- | --- |
| 近战武器 | weapon | weapon、steamsaw |
| 远程武器 | ranged | ranged、bow、sling、steamgun |
| 弹药 | ammo | ammo |
| 法杖 | staves | staves |
| 灵晶 | mindstars | mindstars |
| 盾牌 | shield | shield、steamsaw |
| 项链 | amulets | amulets |
| 披风 | cloak | cloak |
| 腰带 | belt | belt |
| 鞋子 | boots | boots、light-boots |
| 手套 | gloves | gloves |
| 法袍 | robe | robe |
| 重甲 | heavy-armor | heavy-armor、armor |
| 板甲 | massive-armor | massive-armor、armor |
| 轻甲 | light-armor | light-armor、armor |
| 头盔 | helm | helm |
| 法师帽 | wizard-hat | wizard-hat |
| 灯具 | lite | lite |
| 戒指 | rings | rings |
| 锄头 | digger | digger |

## 每个工作表

| 工作表 | 词缀池 | 数据行 | 已匹配 | 本池命中 | 共享池命中 | 未匹配 |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 近战武器 | weapon | 39 | 37 | 37 | 0 | 2 |
| 远程武器 | ranged | 27 | 26 | 22 | 4 | 1 |
| 弹药 | ammo | 34 | 33 | 33 | 0 | 1 |
| 法杖 | staves | 28 | 28 | 28 | 0 | 0 |
| 灵晶 | mindstars | 33 | 31 | 31 | 0 | 2 |
| 盾牌 | shield | 33 | 32 | 32 | 0 | 1 |
| 项链 | amulets | 32 | 30 | 30 | 0 | 2 |
| 披风 | cloak | 25 | 25 | 25 | 0 | 0 |
| 腰带 | belt | 27 | 27 | 27 | 0 | 0 |
| 鞋子 | boots | 28 | 28 | 27 | 1 | 0 |
| 手套 | gloves | 33 | 27 | 27 | 0 | 6 |
| 法袍 | robe | 34 | 31 | 31 | 0 | 3 |
| 重甲 | heavy-armor | 25 | 25 | 5 | 20 | 0 |
| 板甲 | massive-armor | 26 | 26 | 6 | 20 | 0 |
| 轻甲 | light-armor | 31 | 31 | 11 | 20 | 0 |
| 头盔 | helm | 30 | 29 | 29 | 0 | 1 |
| 法师帽 | wizard-hat | 33 | 32 | 32 | 0 | 1 |
| 灯具 | lite | 18 | 18 | 18 | 0 | 0 |
| 戒指 | rings | 40 | 37 | 37 | 0 | 3 |
| 锄头 | digger | 18 | 17 | 17 | 0 | 1 |

## 稀有度冲突（Excel vs 源数据）

以源数据 `egos.json` 的 `rarity` 为准；下表仅为证据，不会写回 ego。

| 工作表 | 行 | 词缀名 | ego | Excel 稀有度 | 源稀有度 | 置信度 |
| --- | ---: | --- | --- | ---: | ---: | --- |
| 近战武器 | 5 | 强酸 | `tome:weapon:acidic` | 10 | 5 | high |
| 弹药 | 3 | 强酸 | `tome:ammo:acidic` | 10 | 5 | high |
| 弹药 | 4 | 仇恨 | `tome:ammo:hateful:greater` | 10 | 30 | high |
| 法杖 | 11 | 能量 | `tome:staves:power` | 3 | 10 | high |
| 灵晶 | 21 | 顿悟 | `tome:mindstars:epiphanous:greater` | 40 | 30 | high |
| 披风 | 25 | 雾 | `tome:cloak:fog:greater` | 8 | 18 | high |
| 腰带 | 10 | 暗夜符文 | `tome:belt:nightruned` | 6 | 9 | high |
| 腰带 | 28 | 亡灵 | `tome:belt:unlife:greater` | 30 | 90 | high |
| 鞋子 | 5 | 速度 | `tome:boots:speed` | 5 | 20 | high |
| 鞋子 | 14 | 瘟神 | `tome:boots:blight:greater` | 20 | 35 | high |
| 头盔 | 10 | 清除 | `tome:helm:cleanse` | 6 | 9 | high |
| 法师帽 | 13 | 闪烁 | `tome:wizard-hat:shimmering` | 6 | 12 | high |
| 戒指 | 17 | 山峦 | `tome:rings:mountain` | 12 | 24 | high |
| 戒指 | 28 | 生命 | `tome:rings:life:greater` | 15 | 12 | high |

## 数值区间交叉核对（Excel 文本 vs 源码推导）

把 Excel「效果」列里的 `a-b` 数字区间与源码推导出的区间逐一比对。一致即不列出；列出的行表示两边对不上，**页面一律显示源码推导值**。
这项工作同时是对本站数值模型的检验：`mbonus_material(max, add)` 的区间是 `add ~ add + max`（源码 `ceil(rng.mbonus(max, level, 90) * ml / 5) + add`），不是 `add + 材料等级 × max`。

| 工作表 | 行 | 词缀名 | ego | Excel 效果 | Excel 区间 | 源码区间 |
| --- | ---: | --- | --- | --- | --- | --- |
| 盾牌 | 34 | 抵抗 | `tome:shield:resistance:greater` | 8-13火焰寒冷闪电酸性抗性 | 8~13 | 5~13、5~7、5~9、5~10、5~12、5~13、5~13、5~7、5~9、5~10、5~12、5~13、5~13、5~7、5~9、5~10、5~12、5~13、5~13、5~7、5~9、5~10、5~12、5~13 |
| 法袍 | 13 | 精神 | `tome:robe:mind` | 10-20精神加成/10-20精神抗性 | 10~20、10~20 | 10~30、10~14、10~18、10~22、10~26、10~30 |
| 头盔 | 18 | 莽汉 | `tome:helm:bounder:greater` | 4-9力量敏捷/CD 20铁头功/铁头功额外伤害加成 | 4~9 | 5~9、5~6、5~7、5~8、5~9、5~9、5~9、5~6、5~7、5~8、5~9、5~9 |

## 未匹配行

这些行的中文名在「本池 ∪ 加载闭包」内找不到 ego。`跨池同名候选` 是允许池集合之外的同名 ego，仅作排查线索，绝不会被自动匹配。

| 工作表 | 行 | 词缀名 | 效果 | 跨池同名候选 |
| --- | ---: | --- | --- | --- |
| 近战武器 | 15 | 史莱姆 | 武器命中时5-20%概率减速对方 | tome:ammo:slime<br>tome:robe:slimy |
| 近战武器 | 39 | 审判官 | 武器暴击时造成法力燃烧伤害，并且将随机法术技能打入冷却 | — |
| 远程武器 | 11 | 寒冷 | 8-22寒冷加成/5-20远程寒冷附伤 | — |
| 弹药 | 34 | 审判官 | 武器暴击时造成法力燃烧伤害，并且将随机法术技能打入冷却 | — |
| 灵晶 | 2 | 创造 | 2-8灵巧/5-25暴击伤害 | — |
| 灵晶 | 32 | 审判官 | 灵晶暴击时造成法力燃烧伤害，并且将随机法术技能打入冷却 | — |
| 盾牌 | 29 | 生命 | 20-120生命上限/10-20自然枯萎抗性/盾牌10-20自然附伤 | tome:belt:life<br>tome:mindstars:life<br>tome:rings:life:greater<br>tome:robe:life:greater |
| 项链 | 21 | 完美 | 0.1-0.4 随机两系技能系数 | — |
| 项链 | 32 | 心灵编织 | 1-6意志/10-25混乱免疫/5-15精神豁免/5-15精神强度 | tome:robe:mindwoven<br>tome:wizard-hat:mindwoven |
| 手套 | 2 | 沙 | 3-11物理加成/5-15物理附伤/5-10护甲/手套命中触发：10%沙瀑吐息 | tome:mindstars:sand:greater |
| 手套 | 9 | 自然主义 | 3-11自然加成/5-15自然附伤/5-10自然抗性/手套命中触发：10% 剧毒吐息 | — |
| 手套 | 10 | 两级 | 3-11寒冷加成/5-15寒冷附伤/5-10寒冷抗性/手套命中触发：10% 冰息术 | — |
| 手套 | 11 | 零能力者 | 3-11精神加成/5-15精神附伤/5-10精神抗性/手套命中触发：20% 精神切断 | — |
| 手套 | 12 | 风暴 | 3-11闪电加成/5-15闪电附伤/5-10闪电抗性/手套命中触发：10%闪电吐息 | tome:ammo:storm<br>tome:mindstars:storms:greater |
| 手套 | 20 | 岩石守卫 | 4-12物理抗性/5-15体质/5-20护甲/5-15护甲强度/手套命中时触发：5%石化之触 | — |
| 法袍 | 3 | 冰冻 | 10-30寒冷加成/15-45寒冷抗性 | tome:mindstars:frost:greater<br>tome:shield:icy |
| 法袍 | 4 | 冰冻 | 10-30寒冷加成/15-45寒冷抗性 | tome:mindstars:frost:greater<br>tome:shield:icy |
| 法袍 | 15 | 法术编织 | 15-30法术豁免/2-6法术强度、暴击 | — |
| 头盔 | 13 | 防御者 | 2-7全抗/4-8闪避/4-9护甲/5-15物理豁免 | — |
| 法师帽 | 7 | 酸性 | 10-20酸性加成/15-30酸性抗性 | — |
| 戒指 | 8 | 冰冻 | 10-20寒冷加成/20-40寒冷抗性 | tome:mindstars:frost:greater<br>tome:shield:icy |
| 戒指 | 35 | 痛苦编织 | 4-8全体伤害加成/5-20物理法术精神强度 | — |
| 戒指 | 40 | 树精 | 5-15自然枯萎抗性/10-30毒素疾病免疫 | — |
| 锄头 | 3 | 忍耐 | 1-5力量/4-10疲劳移除 | tome:ranged:enduring:greater<br>tome:shield:patience:greater<br>tome:weapon:enduring:greater |

## 数据质量发现

### 完全重复的行

- 法袍 第 3、4 行：`冰冻`，同一工作表内有 2 行完全相同。

### 词缀名与效果错位

判定方式：名称匹配到的 ego 按其源 `keyword` 应有伤害类型词，若该行效果里出现的是另一个伤害类型词，则为错位。

| 工作表 | 行 | 词缀名 | ego | 应有伤害类型 | 效果中的伤害类型 |
| --- | ---: | --- | --- | --- | --- |
| 法师帽 | 5 | 光系 | `tome:wizard-hat:light` | 光系 | 闪电 |
| 法师帽 | 6 | 暗影 | `tome:wizard-hat:darkness` | 暗影 | 光系 |
| 法师帽 | 8 | 腐蚀 | `tome:wizard-hat:corrosion` | 酸性 | 暗影 |

### 池内同名（多个 ego 共享同一中文名）

（无）

### 共享池：同一个 ego 被多个工作表命中

这是预期行为：共享池词缀（如 armor）在重甲/板甲/轻甲上都会出现。`byEgoId` 每个 ego 只保留首行记录，其余工作表出处列在下面。

| ego | 所属池 | 命中的工作表与行 |
| --- | --- | --- |
| `tome:armor:stable` | armor | 重甲 3<br>板甲 3<br>轻甲 2 |
| `tome:armor:fire res` | armor | 重甲 4<br>板甲 4<br>轻甲 3 |
| `tome:armor:cold res` | armor | 重甲 5<br>板甲 5<br>轻甲 4 |
| `tome:armor:lightning res` | armor | 重甲 6<br>板甲 6<br>轻甲 5 |
| `tome:armor:prismatic` | armor | 重甲 7<br>板甲 7<br>轻甲 6 |
| `tome:armor:shielding` | armor | 重甲 8<br>板甲 8<br>轻甲 7 |
| `tome:armor:resilience` | armor | 重甲 9<br>板甲 9<br>轻甲 9 |
| `tome:armor:acid res` | armor | 重甲 10<br>板甲 10<br>轻甲 10 |
| `tome:armor:temporal res` | armor | 重甲 11<br>板甲 11<br>轻甲 11 |
| `tome:armor:cleansing` | armor | 重甲 12<br>板甲 12<br>轻甲 12 |
| `tome:armor:rejuv` | armor | 重甲 13<br>板甲 13<br>轻甲 8 |
| `tome:armor:eyal:greater` | armor | 重甲 15<br>板甲 14<br>轻甲 17 |
| `tome:armor:thunder:greater` | armor | 重甲 16<br>板甲 15<br>轻甲 13 |
| `tome:armor:command:greater` | armor | 重甲 19<br>板甲 19<br>轻甲 26 |
| `tome:armor:delving:greater` | armor | 重甲 20<br>板甲 20<br>轻甲 18 |
| `tome:armor:natural_resilience:greater` | armor | 重甲 21<br>板甲 21<br>轻甲 19 |
| `tome:armor:enlight:greater` | armor | 重甲 22<br>板甲 23<br>轻甲 30 |
| `tome:armor:searing:greater` | armor | 重甲 23<br>板甲 24<br>轻甲 29 |
| `tome:armor:deep:greater` | armor | 重甲 24<br>板甲 25<br>轻甲 31 |
| `tome:armor:radiant:greater` | armor | 重甲 26<br>板甲 27<br>轻甲 32 |

### 一个 ego 被同一工作表的多行命中

（无）

