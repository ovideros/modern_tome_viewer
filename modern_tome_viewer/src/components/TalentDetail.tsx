import { useEffect, useMemo, useState } from 'react';
import type { DatasetMeta, TalentEntry, TalentTree } from '../lib/types';
import { COST_KIND_LABELS, RANGE_KIND_LABELS, RESOURCE_LABELS, flagLabel } from '../lib/data';
import { acronymAxis, defaultSimParams, paradoxModifier, rawCombatStat, valueInputs } from '../lib/scaling';
import type { Acronym, SimParams } from '../lib/scaling';
import { Highlight } from './Highlight';
import { Chip, TalentIcon } from './TalentBits';
import { VariableText, hasSimulatableValues, type DisplayOptions } from './VariableText';

interface TalentDetailProps {
  talent: TalentEntry;
  tree: TalentTree | undefined;
  meta: DatasetMeta;
  terms: string[];
  onClose: () => void;
  onJumpToTree: (treeId: string) => void;
  onAddFlag: (flag: string) => void;
  onSelectClass: (classId: string) => void;
  favorite: boolean;
  onToggleFavorite: (id: string) => void;
  inCompare: boolean;
  onToggleCompare: (id: string) => void;
  compareFull: boolean;
  /**
   * Compact mode drops the search-specific extras (highlight terms, tree
   * breadcrumb) for the class/race pages, which embed the same panel.
   */
  compact?: boolean;
  /**
   * Category mastery of the tree this talent is being viewed through (1.0 when
   * unknown, e.g. on the search page). It seeds the coefficient slider, because
   * the effective talent level is `raw level × mastery`.
   */
  mastery?: number;
  /**
   * Embedded panels are opened from inside another view (the monster
   * encyclopedia) rather than being the page's own detail. They keep the full
   * text and simulator but drop the tree breadcrumb, which has nowhere to go,
   * and the favourite/compare actions, which the host page owns.
   */
  embedded?: boolean;
  /**
   * Text for the close button. The monster page uses "返回怪物" on narrow
   * viewports, where the talent sheet sits in the same slot as the monster
   * sheet and closing it is what brings the monster back.
   */
  closeLabel?: string;
}

function Row({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="flex gap-3 border-b border-line py-1.5 last:border-b-0">
      <dt className="w-20 shrink-0 text-[12px] text-subtle">{label}</dt>
      <dd className="min-w-0 flex-1 text-[12.5px]">{children}</dd>
    </div>
  );
}

export function TalentDetail({
  talent,
  tree,
  meta,
  terms,
  onClose,
  onJumpToTree,
  onAddFlag,
  onSelectClass,
  favorite,
  onToggleFavorite,
  inCompare,
  onToggleCompare,
  compareFull,
  compact = false,
  mastery = 1,
  embedded = false,
  closeLabel = '关闭',
}: TalentDetailProps) {
  useEffect(() => {
    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape') onClose();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [onClose]);

  const flags = Object.keys(talent.flags);
  const ladder = talent.cooldown.values.length > 1 ? talent.cooldown.values : [];
  const rangeLadder = (talent.range.display ?? '').includes(',');
  const simulatable = useMemo(() => hasSimulatableValues(talent.acronyms), [talent.acronyms]);
  // The sliders and the recomputed text share one simulation, so a value can
  // never be rendered at inputs the panel is not showing. It starts at the
  // talent's defaults and is keyed to the open talent, because a fresh talent
  // must not be rendered for one frame with the previous talent's inputs.
  const defaults = useMemo(() => defaultSimFor(talent.acronyms, mastery), [talent.acronyms, mastery]);
  const simKey = `${talent.id}:${mastery}`;
  const [edited, setEdited] = useState<{ key: string; sim: SimParams } | null>(null);
  const sim = edited?.key === simKey ? edited.sim : defaults;
  const setSim = (next: SimParams) => setEdited({ key: simKey, sim: next });
  // How the text should present its numbers.
  const display: DisplayOptions = useMemo(
    () => ({
      // A one-point talent has no talent-level dimension, so its values describe
      // a single situation and collapse to one number.
      points: talent.points,
    }),
    [talent.points],
  );

  return (
    <aside data-testid="talent-detail" className="panel flex h-full flex-col overflow-hidden">
      <header className="flex items-start gap-3 border-b border-line px-3 py-3">
        <TalentIcon talent={talent} size={56} iconSize={meta.iconSize} />
        <div className="min-w-0 flex-1">
          <h2 className="text-[16px] font-semibold leading-tight">
            <Highlight text={talent.plainName} terms={terms} />
          </h2>
          <p className="mt-0.5 font-mono text-[11px] text-subtle">{talent.shortName}</p>
          {compact || embedded ? (
            <p className="mt-1 text-[11.5px] text-accent-strong">{talent.treePlainName}</p>
          ) : (
            <button
              type="button"
              onClick={() => onJumpToTree(talent.tree)}
              className="mt-1 text-left text-[11.5px] text-accent-strong hover:underline"
            >
              {talent.categoryName} / {talent.treePlainName}
            </button>
          )}
        </div>
        <div className="flex shrink-0 flex-col items-end gap-1">
          <button
            type="button"
            className="btn-ghost btn px-2 py-1"
            onClick={onClose}
            title={`${closeLabel}（Esc）`}
            aria-label={closeLabel}
          >
            {closeLabel === '关闭' ? '✕' : `← ${closeLabel}`}
          </button>
          {!embedded && (
            <>
              <button
                type="button"
                className="btn px-2 py-1 text-[11.5px]"
                aria-pressed={favorite}
                onClick={() => onToggleFavorite(talent.id)}
                title={favorite ? '取消收藏' : '加入收藏'}
              >
                {favorite ? '★ 已收藏' : '☆ 收藏'}
              </button>
              <button
                type="button"
                className="btn px-2 py-1 text-[11.5px]"
                aria-pressed={inCompare}
                onClick={() => onToggleCompare(talent.id)}
                title={inCompare ? '移出对比' : compareFull ? '对比列表已满' : '加入对比'}
              >
                {inCompare ? '− 移出对比' : '+ 对比'}
              </button>
            </>
          )}
        </div>
      </header>

      <div className="min-h-0 flex-1 overflow-y-auto px-3 py-3">
        <dl className="mb-3">
          <Row label="使用模式">{talent.mode || '—'}</Row>
          <Row label="使用速度">{talent.useSpeed || '—'}</Row>
          <Row label="冷却时间">
            {talent.cooldown.display === null ? (
              <span className="text-subtle">无</span>
            ) : (
              <>
                <span className="font-semibold">{talent.cooldown.display}</span>
                {ladder.length > 0 && (
                  <span className="ml-1 text-[11px] text-subtle">回合（随技能等级 1–{ladder.length}）</span>
                )}
                {talent.cooldown.fixed && (
                  <span className="ml-1.5 align-middle" data-testid="fixed-cooldown">
                    <Chip title="固定冷却：任何效果都不能增减它——减 CD 装备、超越永恒、时空回响等都无效（源码 fixed_cooldown = true）。数值本身仍可随技能等级变化。">
                      固定
                    </Chip>
                  </span>
                )}
              </>
            )}
          </Row>
          <Row label="射程">
            {talent.range.display ? (
              <>
                <span className="font-semibold">{talent.range.display}</span>
                <span className="ml-1 text-[11px] text-subtle">
                  （{RANGE_KIND_LABELS[talent.range.kind]}
                  {rangeLadder ? '，随等级变化' : ''}）
                </span>
              </>
            ) : (
              '—'
            )}
          </Row>
          <Row label="资源消耗">
            {talent.cost.display ? (
              <span>
                {talent.cost.display}
                {talent.cost.resource && (
                  <span className="ml-1 text-[11px] text-subtle">
                    （{RESOURCE_LABELS[talent.cost.resource] ?? talent.cost.resource}
                    {talent.cost.kind ? ` · ${COST_KIND_LABELS[talent.cost.kind]}` : ''}
                    {talent.cost.amount !== null ? ` · ${talent.cost.amount}` : ''}）
                  </span>
                )}
              </span>
            ) : (
              '—'
            )}
          </Row>
          <Row label="可投点数">{talent.points || '—'}</Row>
          <Row label="技能树位置">第 {talent.index + 1} 个</Row>
        </dl>

        {talent.require.length > 0 && (
          <section className="mb-3">
            <h3 className="mb-1.5 text-[12px] font-semibold text-muted">升级需求</h3>
            <div className="overflow-hidden rounded-md border border-line">
              {talent.require.map((requirement, index) => (
                <div
                  key={index}
                  className="flex items-center justify-between gap-2 border-b border-line px-2 py-1 text-[11.5px] last:border-b-0"
                >
                  <span className="text-subtle">等级 {index + 1}</span>
                  <span>{requirement.display}</span>
                </div>
              ))}
            </div>
          </section>
        )}

        {flags.length > 0 && (
          <section className="mb-3">
            <h3 className="mb-1.5 text-[12px] font-semibold text-muted">
              技能标记 <span className="font-normal text-subtle">（点击可加入筛选）</span>
            </h3>
            <div className="flex flex-wrap gap-1">
              {flags.map((flag) => (
                <button key={flag} type="button" onClick={() => onAddFlag(flag)} title={`按 ${flagLabel(flag)} 筛选`}>
                  <Chip>{flagLabel(flag)}</Chip>
                </button>
              ))}
            </div>
          </section>
        )}

        <section className="mb-3">
          <h3 className="mb-1.5 text-[12px] font-semibold text-muted">技能说明</h3>
          {talent.text ? (
            <VariableText
              html={talent.text}
              acronyms={talent.acronyms}
              sim={simulatable ? sim : undefined}
              display={display}
            />
          ) : (
            <p className="text-[12.5px] text-subtle">暂无说明文本。</p>
          )}
        </section>

        {/* Below the description: read the skill first, then dial its numbers. */}
        {simulatable && (
          <ValueSimulator
            acronyms={talent.acronyms}
            points={talent.points}
            sim={sim}
            onChange={setSim}
            active={edited !== null && edited.key === simKey}
            onReset={() => setEdited(null)}
          />
        )}

        {tree && tree.classes.length > 0 && (
          <section className="mb-3">
            <h3 className="mb-1.5 text-[12px] font-semibold text-muted">可学习此大系的职业</h3>
            <div className="flex flex-wrap gap-1">
              {tree.classes.map((classId) => {
                const cls = meta.classes.find((c) => c.id === classId);
                return (
                  <button key={classId} type="button" onClick={() => onSelectClass(classId)}>
                    <Chip tone="accent">{cls?.name ?? classId}</Chip>
                  </button>
                );
              })}
            </div>
          </section>
        )}

        <section>
          <h3 className="mb-1.5 text-[12px] font-semibold text-muted">数据来源</h3>
          <p className="break-all font-mono text-[11px] text-subtle">
            {talent.source ?? '未提供'} · id <span className="text-muted">{talent.id}</span>
          </p>
        </section>
      </div>
    </aside>
  );
}

/** Sliders for every input the talent's numbers depend on. */
function ValueSimulator({
  acronyms,
  points,
  sim,
  onChange,
  active,
  onReset,
}: {
  acronyms: Acronym[];
  /** Investable points; a talent capped at 1 has no meaningful talent level. */
  points: number;
  sim: SimParams;
  onChange: (next: SimParams) => void;
  active: boolean;
  onReset: () => void;
}) {
  const [open, setOpen] = useState(true);

  // Collect the adjustable inputs across all of this talent's values.
  const controls = useMemo(() => collectControls(acronyms, points), [acronyms, points]);
  if (!controls.length) return null;

  const set = (next: Partial<SimParams>) => onChange({ ...sim, ...next });

  return (
    <section className="mb-3 rounded-lg border border-line bg-sunken/50 px-2.5 py-2">
      <div className="mb-1.5 flex items-center justify-between gap-2">
        <button
          type="button"
          className="text-[12px] font-semibold text-muted hover:text-fg"
          onClick={() => setOpen((v) => !v)}
        >
          数值模拟 {open ? '▾' : '▸'}
        </button>
        {active && (
          <button type="button" className="btn px-1.5 py-0.5 text-[11px]" onClick={onReset}>
            恢复默认
          </button>
        )}
      </div>

      {open && (
        <div className="space-y-2">
          {controls.map((control) => {
            const value = controlValue(sim, control);
            return (
              <label key={`${control.kind}-${control.label}`} className="block">
                <span className="mb-0.5 flex items-baseline justify-between gap-2 text-[11.5px]">
                  <span className="text-muted">{control.label}</span>
                  <span className="font-mono text-accent-strong">
                    {value}
                    {control.kind === 'power' && (
                      <span className="ml-1 font-sans text-[10px] text-subtle" data-testid="raw-power">
                        {' '}
                        {rawPowerHint(value)}
                      </span>
                    )}
                    {control.kind === 'stat' && inputHint(control.label, value) && (
                      <span className="ml-1 font-sans text-[10px] text-subtle" data-testid="input-hint">
                        {' '}
                        {inputHint(control.label, value)}
                      </span>
                    )}
                  </span>
                </span>
                <input
                  type="range"
                  className="w-full accent-[var(--accent)]"
                  min={control.min}
                  max={control.max}
                  step={control.step}
                  value={value}
                  onChange={(event) => {
                    const next = Number(event.target.value);
                    if (control.kind === 'talentLevel') set({ talentLevel: next });
                    else if (control.kind === 'characterLevel') set({ characterLevel: next });
                    else if (control.kind === 'power') {
                      // Keep the legacy single field in step: fitted formulas and
                      // stored sims still read it.
                      set({
                        power: next,
                        powers: { ...sim.powers, [control.powerLabel ?? '法术强度']: next },
                      });
                    } else if (control.kind === 'coefficient') set({ coefficient: next });
                    else set({ stats: { ...sim.stats, [control.label]: next } });
                  }}
                />
              </label>
            );
          })}
          <p className="text-[10.5px] leading-snug text-subtle">
            数值按游戏内公式重算（源码公式优先，否则用导出数据反解），技能说明中的数字随滑条实时变化。
            技能系数=该大系掌握度：在职业页默认取该职业的掌握值（如 1.3），其他页面默认 1（掌握度未知）。
            「有效强度」是公式真正读取的那个值（游戏里 <code>combatSpellpower()</code> 的返回值）：
            原始强度要先过 <code>rescaleCombatStats</code> 递减曲线，所以有效 100 需要原始 300 左右，
            角色面板写作「Spellpower: +N (M eff.)」——N 是原始、M 是有效。
            {points <= 1 && ' 该技能只能投入 1 点，因此不提供技能等级滑条。'}
          </p>
        </div>
      )}
    </section>
  );
}

interface Control {
  label: string;
  kind: 'talentLevel' | 'characterLevel' | 'power' | 'coefficient' | 'stat';
  min: number;
  max: number;
  step: number;
  /** For `power` controls: which of the four powers this slider sets. */
  powerLabel?: string;
}

/**
 * The raw combat stat behind the effective one the slider sets.
 *
 * The curve is many-to-one and floored, so only a lower bound can be named —
 * and that is exactly what the game's own "Spellpower: +N (M eff.)" row means.
 */
function rawPowerHint(effective: number): string {
  const raw = rawCombatStat(effective);
  if (!Number.isFinite(raw)) return '';
  return effective <= 20 ? `原始值 ${raw}` : `原始值 ≥${raw}`;
}

/**
 * Slider ranges.
 *
 * The coefficient is the tree mastery (0.9–1.3 in the data, 1.3 for 347 of the
 * 466 tree references), so anything outside 1–2 is meaningless. Power is the
 * *effective* combat stat the damage helpers consume: the game puts the raw one
 * through `rescaleCombatStat` (Combat.lua:1477), where effective 100 already
 * needs raw 300 and effective 150 needs raw 640 — beyond that the curve is so
 * flat that no character a player actually builds reaches it (the export never
 * pins a power above 100), so 1–150 is the span worth dragging. The panel prints
 * the raw value the slider implies.
 */
const COEFFICIENT_RANGE = { min: 0.9, max: 1.5, step: 0.1 };
const POWER_RANGE = { min: 1, max: 150, step: 1 };

/** Power sliders name the power they set: 法术强度, 精神强度, physical power… */
function powerControl(label: string): Control {
  return { ...POWER_RANGE, label: `${label}（有效值）`, kind: 'power', powerLabel: label };
}

/**
 * Per-label ranges where the game states a real bound.
 *
 * Paradox has no cap of its own, but its *modifier* does: PMod is
 * `bound(sqrt(paradox/300), 0.5, 1.5)` (chronomancer.lua:153), so it saturates
 * at +50% exactly when paradox reaches **675** — past that, raising paradox
 * changes nothing, which is what the slider should cover. 300 is the balance
 * point the export itself pins.
 */
const STAT_RANGES: Record<string, { min: number; max: number; step: number }> = {
  paradox: { min: 0, max: 675, step: 1 },
};

/**
 * Range for an attribute or another talent's level.
 *
 * A laddered input keeps its real span; another talent's level is 0-10; a bare
 * attribute is pinned by the export (力量 100) and 0-300 covers what a character
 * can reach.
 */
function statControl(label: string, acronym: Acronym): Control {
  if (label === '角色等级') return { label, kind: 'characterLevel', min: 1, max: 50, step: 1 };
  const fixed = STAT_RANGES[label.toLowerCase()] ?? STAT_RANGES[label];
  if (fixed) return { label, kind: 'stat', ...fixed };
  const param = acronym.params.find((p) => p.label === label);
  if (param && param.ladder.length > 1) {
    return { label, kind: 'stat', min: param.ladder[0], max: param.ladder[param.ladder.length - 1], step: 1 };
  }
  if (/等级/.test(label)) return { label, kind: 'stat', min: 0, max: 10, step: 1 };
  return { label, kind: 'stat', min: 0, max: 300, step: 1 };
}

/** Extra readout for inputs whose game meaning needs the derived value. */
function inputHint(label: string, value: number): string | null {
  if (label.toLowerCase() === 'paradox') return `悖论修正 ×${paradoxModifier(value).toFixed(2)}`;
  return null;
}

/** Merge the adjustable parameters of every value, in a stable order. */
function collectControls(acronyms: Acronym[], points: number): Control[] {
  const found = new Map<string, Control>();
  const usable = acronyms.filter((a) => a.lua || (a.base !== null && a.max !== null));
  if (!usable.length) return [];
  // A talent capped at one point has no talent-level dimension to explore, even
  // when the export still renders its values across levels 1-5.
  const levelIsAdjustable = points > 1;

  const add = (key: string, control: Control) => {
    const existing = found.get(key);
    // Widen an existing slider rather than replacing it, so two values that
    // depend on the same input share one range that covers both.
    if (existing) {
      existing.min = Math.min(existing.min, control.min);
      existing.max = Math.max(existing.max, control.max);
      return;
    }
    found.set(key, control);
  };

  for (const acronym of usable) {
    // The axis a value's ladder was rendered along: talent level, character
    // level, a power, an attribute, or another talent's level.
    const axis = acronymAxis(acronym);
    if (axis) {
      const lo = axis.ladder[0];
      const hi = axis.ladder[axis.ladder.length - 1];
      if (axis.label === '技能等级') {
        if (levelIsAdjustable) {
          add('技能等级', { label: '技能等级', kind: 'talentLevel', min: lo, max: hi, step: 1 });
        }
      } else if (axis.kind === 'power') {
        add(`powers:${axis.label}`, powerControl(axis.label));
      } else if (axis.label !== '角色等级') {
        add(`stat:${axis.label}`, statControl(axis.label, acronym));
      }
    }

    // Every input a value actually reads gets a slider, taken from the same list
    // the tooltip prints — so the panel and the tooltip can never disagree about
    // which inputs exist. Four powers stay separate: a value may take the best
    // of spell power and mind power, which one slider could not express.
    for (const input of valueInputs(acronym)) {
      if (input.key === 'talentLevel') {
        if (levelIsAdjustable) add('技能等级', { label: '技能等级', kind: 'talentLevel', min: 1, max: 5, step: 1 });
      } else if (input.key === 'coefficient') {
        add('技能系数', { ...COEFFICIENT_RANGE, label: '技能系数', kind: 'coefficient' });
      } else if (input.key.startsWith('powers:')) {
        add(input.key, powerControl(input.label));
      } else if (input.key === 'characterLevel') {
        add('角色等级', { label: '角色等级', kind: 'characterLevel', min: 1, max: 50, step: 1 });
      } else if (input.key.startsWith('stat:')) {
        add(input.key, statControl(input.key.slice(5), acronym));
      }
    }
  }

  // Talent level matters for fitted formulas even when the title omits it.
  if (levelIsAdjustable && !found.has('技能等级')) {
    add('技能等级', { label: '技能等级', kind: 'talentLevel', min: 1, max: 5, step: 1 });
  }

  const order: Record<Control['kind'], number> = { talentLevel: 0, characterLevel: 1, coefficient: 2, power: 3, stat: 4 };
  return [...found.values()].sort((a, b) => order[a.kind] - order[b.kind] || a.label.localeCompare(b.label));
}

/**
 * Starting slider values.
 *
 * The coefficient starts at the tree's mastery — the game multiplies the raw
 * talent level by mastery, so 1.3 mastery is the honest default when viewing a
 * talent through its class, and 1.0 when the mastery is unknown. Three tree
 * references carry mastery 0.9, below the slider's floor, so the default is
 * clamped into the range rather than left outside it (a range input would show
 * the thumb at the floor while the text used the unclamped value).
 */
function defaultSimFor(acronyms: Acronym[], mastery: number): SimParams {
  const base: SimParams = {
    talentLevel: 1,
    characterLevel: 1,
    coefficient: clamp(mastery > 0 ? mastery : 1, COEFFICIENT_RANGE),
    power: 100,
    powers: {},
    stats: {},
  };
  for (const acronym of acronyms) {
    if (!acronym.lua && acronym.base === null) continue;
    const defaults = defaultSimParams(acronym);
    base.talentLevel = defaults.talentLevel;
    base.characterLevel = defaults.characterLevel ?? 1;
    Object.assign(base.stats, defaults.stats);
    const powers = base.powers ?? {};
    for (const [label, value] of Object.entries(defaults.powers ?? {})) {
      powers[label] = Math.min(POWER_RANGE.max, Math.max(POWER_RANGE.min, value));
    }
    base.powers = powers;
  }
  base.power = Object.values(base.powers ?? {})[0] ?? 100;
  return base;
}

/** The current value of one slider, from the simulation the panel is showing. */
function controlValue(sim: SimParams, control: Control): number {
  if (control.kind === 'talentLevel') return sim.talentLevel;
  if (control.kind === 'characterLevel') return sim.characterLevel;
  if (control.kind === 'power') {
    const perType = sim.powers?.[control.powerLabel ?? '法术强度'];
    if (typeof perType === 'number' && Number.isFinite(perType)) return perType;
    return Number.isFinite(sim.power) ? sim.power : 100;
  }
  if (control.kind === 'coefficient') return sim.coefficient;
  return sim.stats[control.label] ?? 0;
}

function clamp(value: number, range: { min: number; max: number }): number {
  return Math.min(range.max, Math.max(range.min, value));
}
