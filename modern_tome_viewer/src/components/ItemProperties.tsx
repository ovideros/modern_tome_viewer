/**
 * Grouped property display for artifacts and ego affixes.
 *
 * The requirements this component implements come from the handoff's §5.1 and
 * the Modified Item Descriptions addon it references:
 *
 *  - stable section order, so two items can be compared by eye;
 *  - same-kind properties grouped under one label and laid out on one row
 *    (`抗性  火焰 +20%  寒冷 +15%`) instead of one line per damage type;
 *  - **two independent axes kept apart**: the display group (`进攻` / `防御` /
 *    `资源与其他`) says what a property is for, while the area heading
 *    (`穿戴时` / `该武器攻击时` / `受击时`) says when it actually applies. The
 *    addon collapses these into one; merging them is how a weapon's own crit
 *    ends up looking like the wearer's physical crit;
 *  - no empty headings, no fabricated zeros, and a visible marker when a value
 *    is not statically knowable.
 *
 * Alignment uses CSS grid, not full-width padding characters, so long value
 * lists wrap on narrow screens.
 */

import { useMemo, useState } from 'react';
import type { ItemFieldMeta, ItemProp, ItemPropItem, ItemPropertyGroup } from '../lib/items';
import { formatPropValue } from '../lib/items';
import {
  AREA_HEADINGS, FIELD_GROUP, GROUP_LABELS, IMMUNITY_TAGS, ROW_GROUPS, STAT_TAGS,
  type GroupKey,
} from '../lib/item-labels';

interface ItemPropertiesProps {
  groups: ItemPropertyGroup[];
  fieldMeta: Record<string, ItemFieldMeta>;
  /** Chinese names for damage types, keyed by the engine code (`FIRE`). */
  damageTypes: Record<string, string>;
  /** Chinese names for talent categories and talents, for table values. */
  labelResolver?: (code: string) => string | null;
  /**
   * Selected item material level (1–5), or null for "not chosen".
   *
   * `resolvers.mbonus_material(max, add)` scales with the item's tier, so a
   * value written once in the source spans a different range on an iron item
   * than on a voratun one. With a level chosen the row shows that level's range
   * and says which level it is for; with none, the widest range is shown and
   * labelled as varying.
   */
  materialLevel?: number | null;
}

/** A value that is not statically knowable is shown as words, never as a digit. */
function ValueCell({ item, meta, damageTypes, labelResolver, materialLevel = null }: {
  item: ItemPropItem;
  meta: ItemFieldMeta | undefined;
  damageTypes: Record<string, string>;
  labelResolver?: (code: string) => string | null;
  materialLevel?: number | null;
}) {
  const tag = item.code
    ? damageTypes[item.code] ?? labelResolver?.(item.code) ?? item.code
    : item.key
      ? STAT_TAGS[item.key] ?? labelResolver?.(item.key) ?? item.key
      : null;

  if (item.kind === 'literal') {
    return (
      <span className="inline-flex items-baseline gap-1">
        {tag && <span className="text-muted">{tag}</span>}
        <span className="font-medium tabular-nums">{formatPropValue(meta, item.value)}</span>
      </span>
    );
  }

  if (item.kind === 'resolver') {
    // `range` is the statically recoverable span; the meaning explains why it
    // varies (material level, generation roll) so the number is not read as a
    // constant. When a material level is selected that level's own range is
    // shown instead, which is the point of the selector: "5~15 on a voratun
    // item" rather than "5~15 across every tier".
    const perLevel = materialLevel !== null ? item.materialRanges?.[materialLevel - 1] ?? null : null;
    const range = perLevel
      ? `${formatPropValue(meta, perLevel[0])} ~ ${formatPropValue(meta, perLevel[1])}`
      : item.range
        ? `${formatPropValue(meta, item.range[0])} ~ ${formatPropValue(meta, item.range[1])}`
        : null;
    return (
      <span className="inline-flex flex-wrap items-baseline gap-1">
        {tag && <span className="text-muted">{tag}</span>}
        {range ? (
          <span className="font-medium tabular-nums">{range}</span>
        ) : (
          <span className="font-medium tabular-nums">{formatPropValue(meta, item.value)}</span>
        )}
        <span className="chip" title={item.text ?? undefined}>
          {perLevel ? `材料等级 ${materialLevel}` : item.meaning ?? '随生成变化'}
        </span>
      </span>
    );
  }

  if (item.kind === 'function' || item.kind === 'computed') {
    return (
      <span className="inline-flex flex-wrap items-baseline gap-1">
        {tag && <span className="text-muted">{tag}</span>}
        <span className="text-subtle">由游戏在运行时计算</span>
        {item.text && <code className="rounded bg-chip px-1 text-[10.5px]">{item.text}</code>}
      </span>
    );
  }

  if (item.kind === 'ref') {
    return (
      <span className="inline-flex items-baseline gap-1">
        {tag && <span className="text-muted">{tag}</span>}
        <span className="text-subtle">{item.ref ?? item.text ?? '引用值'}</span>
      </span>
    );
  }

  return (
    <span className="inline-flex items-baseline gap-1">
      {tag && <span className="text-muted">{tag}</span>}
      <span className="text-subtle">{item.text ?? item.ref ?? '—'}</span>
    </span>
  );
}

/** One labelled row; values wrap naturally instead of being padded to a width. */
function PropRow({ label, children, hint }: { label: string; children: React.ReactNode; hint?: string | null }) {
  return (
    <div className="grid grid-cols-1 gap-x-3 gap-y-0.5 py-1 sm:grid-cols-[8.5rem_1fr]">
      <div className="flex items-baseline gap-1 text-[12.5px] text-muted" title={hint ?? undefined}>
        <span>{label}</span>
        {hint && <span className="text-subtle" aria-hidden>·</span>}
      </div>
      <div className="flex flex-wrap items-baseline gap-x-4 gap-y-1 text-[12.5px]">{children}</div>
    </div>
  );
}

export function ItemProperties({ groups, fieldMeta, damageTypes, labelResolver, materialLevel = null }: ItemPropertiesProps) {
  const [showSource, setShowSource] = useState(false);

  const sections = useMemo(() => {
    return groups.map((group) => {
      // Index every property by key once, so the grouped rows can pull their
      // members regardless of the order the Lua table was written in.
      const byKey = new Map<string, ItemProp>();
      for (const prop of group.props) if (!byKey.has(prop.key)) byKey.set(prop.key, prop);

      const consumed = new Set<string>();
      const rows: { id: string; label: string; items: ItemPropItem[]; hint: string | null }[] = [];

      for (const spec of ROW_GROUPS) {
        const members: ItemPropItem[] = [];
        const hints: string[] = [];
        for (const key of spec.keys) {
          const prop = byKey.get(key);
          if (!prop) continue;
          consumed.add(key);
          // An immunity is a scalar, but it belongs on the shared 状态免疫 row.
          if (key.endsWith('_immune')) {
            members.push({
              key: IMMUNITY_TAGS[key] ?? key,
              code: null,
              ref: null,
              kind: prop.kind,
              value: prop.value,
              range: prop.range,
              materialRanges: prop.materialRanges,
              meaning: prop.meaning,
              text: prop.text,
              resolver: prop.resolver,
            });
          } else {
            members.push(...(prop.items ?? [{
              key: null, code: null, ref: null, kind: prop.kind,
              value: prop.value, range: prop.range, materialRanges: prop.materialRanges,
              meaning: prop.meaning, text: prop.text, resolver: prop.resolver,
            }]));
          }
          if (prop.meaning) hints.push(prop.meaning);
        }
        if (members.length) {
          rows.push({ id: spec.id, label: spec.label, items: members, hint: hints.length ? [...new Set(hints)].join('；') : null });
        }
      }

      // Everything else keeps its own row, bucketed into display groups.
      const rest = group.props.filter((prop) => !consumed.has(prop.key));
      const bucketed = new Map<GroupKey, ItemProp[]>();
      for (const prop of rest) {
        const key = FIELD_GROUP[prop.key] ?? 'utility';
        const list = bucketed.get(key) ?? [];
        list.push(prop);
        bucketed.set(key, list);
      }

      return { area: group.area, rows, bucketed, group };
    });
  }, [groups]);

  const hasAnything = sections.some((section) => section.rows.length > 0 || section.bucketed.size > 0);
  if (!hasAnything) return null;

  return (
    <div className="space-y-4">
      {sections.map(({ area, rows, bucketed }) => {
        const heading = AREA_HEADINGS[area] ?? { title: area, note: null };
        return (
          <section key={area} className="rounded-lg border border-line bg-surface-raised/60 px-3 py-2.5">
            <header className="mb-1.5 flex flex-wrap items-baseline gap-2">
              <h3 className="text-[13px] font-semibold">{heading.title}</h3>
              {heading.note && <span className="text-[11px] text-subtle">{heading.note}</span>}
            </header>

            {rows.length === 0 && bucketed.size === 0 ? (
              // No empty headings: a section with nothing to say is not rendered.
              null
            ) : (
              <div className="space-y-2">
                {rows.length > 0 && (
                  <div className="divide-y divide-line/60">
                    {rows.map((row) => (
                      <PropRow key={row.id} label={row.label} hint={row.hint}>
                        {row.items.map((item, index) => (
                          <ValueCell
                            // Two damage types can repeat a key, so the index keeps
                            // the list keys stable.
                            key={`${item.code ?? item.key ?? 'v'}-${index}`}
                            item={item}
                            meta={fieldMeta[item.code ?? ''] ?? fieldMeta[item.key ?? '']}
                            damageTypes={damageTypes}
                            labelResolver={labelResolver}
                            materialLevel={materialLevel}
                          />
                        ))}
                      </PropRow>
                    ))}
                  </div>
                )}

                {[...bucketed.entries()].map(([groupKey, props]) => (
                  <div key={groupKey}>
                    <h4 className="mb-0.5 text-[11.5px] font-semibold text-subtle">
                      {GROUP_LABELS[groupKey as GroupKey]}
                    </h4>
                    <div className="divide-y divide-line/60">
                      {props.map((prop) => {
                        const meta = fieldMeta[prop.key];
                        const label = meta?.labelZh ?? prop.key;
                        return (
                          <PropRow key={prop.key} label={label} hint={prop.meaning ?? meta?.note ?? null}>
                            {prop.kind === 'table' && prop.items?.length ? (
                              prop.items.map((item, index) => (
                                <ValueCell
                                  key={`${item.code ?? item.key ?? 'v'}-${index}`}
                                  item={item}
                                  meta={meta}
                                  damageTypes={damageTypes}
                                  labelResolver={labelResolver}
                                  materialLevel={materialLevel}
                                />
                              ))
                            ) : (
                              <ValueCell
                                item={{
                                  key: null,
                                  code: null,
                                  ref: prop.ref ?? null,
                                  kind: prop.kind,
                                  value: prop.value,
                                  range: prop.range,
                                  meaning: prop.meaning,
                                  text: prop.text,
                                  resolver: prop.resolver,
                                }}
                                meta={meta}
                                damageTypes={damageTypes}
                                labelResolver={labelResolver}
                                materialLevel={materialLevel}
                              />
                            )}
                            {prop.overridden && (
                              <span className="chip" title="该物品同时重写了继承自基类的同名属性">
                                覆盖基类
                              </span>
                            )}
                            {prop.untranslatedLabel && (
                              <span className="chip" title="游戏汉化缺少该属性标签的中文，显示英文原文">
                                未翻译
                              </span>
                            )}
                          </PropRow>
                        );
                      })}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </section>
        );
      })}

      <div className="text-[11px] text-subtle">
        <button type="button" className="btn-ghost btn px-2 py-0.5" onClick={() => setShowSource((v) => !v)}>
          {showSource ? '隐藏属性出处' : '查看属性出处'}
        </button>
        {showSource && (
          <p className="mt-1.5 leading-relaxed">
            每条属性都带有游戏源码中的字段名与行号，用于校对；数值取自源码，未做任何模拟计算。
            标注「随材料等级变化」的属性来自 <code className="rounded bg-chip px-1">resolvers.mbonus_material(max, add)</code>，
            区间为 <code className="rounded bg-chip px-1">add ~ add + max</code>（按源码 <code className="rounded bg-chip px-1">ceil(rng.mbonus(max, 等级, 90) × 材料等级 / 5) + add</code> 推导），
            不选材料等级时给出的是材料等级 1–5 的最大范围，选中某一级后显示该等级自己的范围。这里的「材料等级」是物品品阶，
            不是装备需求等级。
          </p>
        )}
      </div>
    </div>
  );
}
