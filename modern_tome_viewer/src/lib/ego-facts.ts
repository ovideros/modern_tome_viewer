/**
 * One-line effect summaries: what the affix list shows before you open a row.
 *
 * Two shapes of effect have to meet here.
 *
 *  - **Properties.** `wielder.resists` and friends are structured, so the line
 *    is built from the same field metadata the detail panel uses. The numbers
 *    come from the build's value model (`add ~ add + max`, scaled by the field's
 *    tooltip multiplier), so a line can never disagree with the panel below it.
 *  - **Callbacks.** Charm procs, shield on-block effects and staff "imbued"
 *    spells have no property table. The build recovers either the game's own
 *    description string or a hand-written note, and both carry value
 *    descriptors with `{0}`, `{1}` placeholders that are filled here — which is
 *    why the material-level selector moves these numbers too.
 *
 * Nothing is invented: a placeholder with no statically known value renders as
 * `?`, and a value that is computed at use time says so by name.
 */

import type { Ego, EgoNote, ItemFieldMeta, ItemProp, ItemPropItem, ItemValueKind } from './items';
import { formatPropValue } from './items';
import { IMMUNITY_TAGS, ROW_GROUPS, STAT_TAGS } from './item-labels';

/** A range as the page prints it, or null when it is not statically known. */
export type ItemRange = [number, number] | null;

/** Translate a code to Chinese: talent name, tree name, actor type, stat. */
export type CodeLabeler = (code: string) => string | null;

/**
 * The range to show for one value at the selected material level.
 *
 * `materialLevel === null` means "not chosen": the widest case (material level
 * 5) is shown, which is the same span the community sheet quotes.
 */
export function resolveRange(
  value: { range?: [number, number] | null; materialRanges?: [number, number][] | null },
  materialLevel: number | null,
): ItemRange {
  if (materialLevel !== null && value.materialRanges?.length) {
    return value.materialRanges[materialLevel - 1] ?? value.range ?? null;
  }
  return value.range ?? null;
}

/**
 * `5~15` / `+5~+15` / `0.1%~0.2%`, or null when the range is unknown.
 *
 * Formatting is delegated to `formatPropValue`, the same function the detail
 * panel uses: a card that says `0~0` where the panel says `0.1%` is worse than
 * no card at all, and the rounding rule (`%.1f` in the field's format string)
 * lives in exactly one place.
 */
export function formatRange(meta: ItemFieldMeta | undefined, range: ItemRange): string | null {
  if (!range) return null;
  const [lo, hi] = range;
  return lo === hi
    ? formatPropValue(meta, lo)
    : `${formatPropValue(meta, lo)}~${formatPropValue(meta, hi)}`;
}

/**
 * The short tag for one value inside a grouped row (`火焰`, `力量`, `守护结界`).
 *
 * `known` distinguishes a name the page could resolve from a raw engine key it
 * had to print as-is (`on_kill`, `accuracy_effect_scale`). Callers drop unknown
 * tags when there is no value to go with them: `on_kill` next to a note that
 * already describes the effect is noise, while the same key with a number is a
 * fact worth showing.
 */
function memberTag(
  item: ItemPropItem,
  damageTypes: Record<string, string>,
  labelResolver?: CodeLabeler,
): { tag: string | null; known: boolean } {
  const named = (code: string | null): { tag: string | null; known: boolean } => {
    if (!code) return { tag: null, known: false };
    if (damageTypes[code]) return { tag: damageTypes[code], known: true };
    if (STAT_TAGS[code]) return { tag: STAT_TAGS[code], known: true };
    // Engine identifiers last: talent codes, tree ids and actor types.
    const resolved = labelResolver?.(code) ?? null;
    return resolved ? { tag: resolved, known: true } : { tag: code, known: false };
  };
  if (item.code) return named(item.code);
  if (item.key && IMMUNITY_TAGS[item.key]) return { tag: IMMUNITY_TAGS[item.key], known: true };
  return named(item.key);
}

/** One printable value: its tag and its rendered range, or null if unprintable. */
function describeMember(
  item: ItemPropItem,
  meta: ItemFieldMeta | undefined,
  damageTypes: Record<string, string>,
  materialLevel: number | null,
  labelResolver?: CodeLabeler,
): string | null {
  // A callback is not a value: `special_on_crit = { desc = function, fct =
  // function }` produced three card rows called `desc`, `fct` and
  // `acid_splash`, none of which is a statistic. The effect itself comes from
  // the note instead.
  if (item.kind === 'function' || item.kind === 'computed' || item.kind === 'empty') return null;
  if (item.kind === 'ref' || item.kind === 'special' || item.kind === 'flag') return null;
  const { tag, known } = memberTag(item, damageTypes, labelResolver);
  const range = formatRange(meta, resolveRange(item, materialLevel));
  if (range) return tag ? `${tag} ${range}` : range;
  // `can_breath = { water = 1 }` and similar flags: the member name *is* the
  // whole effect, so `water 1` would be noise.
  if (item.value === true || item.value === 1) return known ? tag : null;
  if (typeof item.value === 'number') {
    const single = formatPropValue(meta, item.value);
    return tag ? `${tag} ${single}` : single;
  }
  // A value the build could not recover keeps its name and nothing else: the
  // amount is computed at use time, so inventing a placeholder digit would be
  // worse than saying nothing.
  return known ? tag : null;
}

/** Normalise a scalar property into the member shape `describeMember` takes. */
function scalarMember(prop: ItemProp, key: string | null): ItemPropItem {
  return {
    key,
    code: null,
    ref: prop.ref ?? null,
    kind: prop.kind as ItemValueKind,
    value: prop.value,
    range: prop.range,
    materialRanges: prop.materialRanges,
    meaning: prop.meaning,
    text: prop.text,
  };
}

/**
 * Strip a grouped row down to its label and its newline-free value list.
 *
 * The return value is a single line on purpose: the card clamps to two lines,
 * and a nested table (`resists`) is far more readable as
 * `抗性 火焰 +10% 寒冷 +10%` than as one line per damage type.
 */
function describeProp(
  prop: ItemProp,
  meta: ItemFieldMeta | undefined,
  damageTypes: Record<string, string>,
  materialLevel: number | null,
  labelResolver?: CodeLabeler,
): string | null {
  const label = meta?.labelZh ?? prop.key;
  if (prop.kind === 'table' && prop.items?.length) {
    const parts = prop.items
      .map((item) => describeMember(item, meta, damageTypes, materialLevel, labelResolver))
      .filter((part): part is string => Boolean(part));
    return parts.length ? `${label} ${parts.join('、')}` : null;
  }
  const single = describeMember(scalarMember(prop, null), meta, damageTypes, materialLevel, labelResolver);
  return single ? `${label} ${single}` : null;
}

/**
 * The property part of an affix's effect, one string per row of the detail
 * panel, in the panel's own order.
 *
 * Grouped rows (`抗性`, `属性`, `状态免疫`) come first, exactly as in the panel,
 * so the card and the panel can be read side by side without re-learning the
 * layout.
 */
export function egoFactLines(
  ego: Ego,
  fieldMeta: Record<string, ItemFieldMeta>,
  damageTypes: Record<string, string>,
  materialLevel: number | null,
  labelResolver?: CodeLabeler,
): string[] {
  const out: string[] = [];
  for (const area of ego.areas) {
    const byKey = new Map<string, ItemProp>();
    for (const prop of area.props) if (!byKey.has(prop.key)) byKey.set(prop.key, prop);
    const consumed = new Set<string>();

    for (const spec of ROW_GROUPS) {
      const members: string[] = [];
      for (const key of spec.keys) {
        const prop = byKey.get(key);
        if (!prop) continue;
        consumed.add(key);
        const meta = fieldMeta[prop.key];
        const list = key.endsWith('_immune')
          // An immunity is a scalar, but it belongs on the shared 免疫 row, and
          // its own tag is the whole value.
          ? [scalarMember(prop, IMMUNITY_TAGS[key] ?? key)]
          : prop.items?.length
            ? prop.items
            : [scalarMember(prop, null)];
        for (const item of list) {
          const described = describeMember(item, meta, damageTypes, materialLevel, labelResolver);
          if (described) members.push(described);
        }
      }
      if (members.length) {
        // `状态免疫` already names the immunities, so its label collapses.
        out.push(`${spec.label === '状态免疫' ? '免疫' : spec.label} ${members.join('、')}`);
      }
    }

    for (const prop of area.props) {
      if (consumed.has(prop.key)) continue;
      const line = describeProp(prop, fieldMeta[prop.key], damageTypes, materialLevel, labelResolver);
      if (line) out.push(line);
    }
  }
  return [...new Set(out)];
}

/**
 * Fill a note's `{0}` / `{1}` placeholders.
 *
 * The numbers come from the same value model as the property rows, so selecting
 * a material level moves a charm proc's "heal for" figure as well.
 */
export function renderNote(note: EgoNote, materialLevel: number | null): string {
  return note.text.replace(/\{(\d+)\}/g, (_match, index: string) => {
    const value = note.values[index];
    if (!value) return '?';
    const range = resolveRange(value, materialLevel);
    // Notes are not tied to one field, so there is no field format to apply;
    // the values are already in the units the game prints.
    if (!range) return '?';
    const [lo, hi] = range;
    const plain = (n: number) => String(Math.round(n * 1000) / 1000);
    return lo === hi ? plain(lo) : `${plain(lo)}~${plain(hi)}`;
  });
}

/** The note lines to show, with placeholders filled in. */
export function egoNoteLines(ego: Ego, materialLevel: number | null): string[] {
  return (ego.notes ?? []).map((note) => renderNote(note, materialLevel));
}

/**
 * The complete effect line for a list card.
 *
 * Property rows win the limited space; a callback note is appended when the
 * affix has one, because "what it does when you use it" is the part a reader
 * cannot infer from the numbers.
 */
export function egoSummaryLines(
  ego: Ego,
  fieldMeta: Record<string, ItemFieldMeta>,
  damageTypes: Record<string, string>,
  materialLevel: number | null,
  labelResolver?: CodeLabeler,
  limit = 3,
): string[] {
  const facts = egoFactLines(ego, fieldMeta, damageTypes, materialLevel, labelResolver);
  const notes = egoNoteLines(ego, materialLevel);
  return [...facts, ...notes].slice(0, limit);
}
