/**
 * Fixed artifact detail panel.
 *
 * Information order follows the handoff's §5.1, and each block is skipped
 * entirely when the item does not configure it — an artifact without a
 * `use_power` must not render an empty "主动能力" heading.
 *
 * Identity and properties are deliberately separated: the header answers "what
 * is this and what does it need", `ItemProperties` answers "what does it do"
 * with the wearer/weapon split preserved, and the tail covers special
 * mechanics, how to obtain it and the flavour text.
 */

import { useState } from 'react';
import { Highlight } from './Highlight';
import { ItemProperties } from './ItemProperties';
import type { Artifact, ArtifactDataset, ItemsReport } from '../lib/items';
import { formatPropValue, sourceLabel, sourcePath } from '../lib/items';
import { assetUrl } from '../lib/data';
import type { TalentEntry } from '../lib/types';

interface ArtifactDetailProps {
  artifact: Artifact;
  /** Labels, source list and the shared `fieldMeta` table. */
  dataset: ArtifactDataset;
  /** The `files` dictionary that property `source.file` ids index into. */
  report: ItemsReport;
  terms: string[];
  /** Damage-type code -> Chinese, built once by the page. */
  damageTypes: Record<string, string>;
  /** Turns engine codes into Chinese (talent names, tree names, actor types). */
  labelResolver?: (code: string) => string | null;
  /** Resolve a talent id to the shared dataset entry. */
  talentOf: (id: string) => TalentEntry | undefined;
  /** Open a talent in the in-page panel; never navigates away. */
  onSelectTalent: (talent: TalentEntry) => void;
  selectedTalentId: string | null;
  onClose: () => void;
}

/** Chinese names for the item's power source, which the game shows as a tag. */
const POWER_SOURCE_LABELS: Record<string, string> = {
  arcane: '奥术',
  technique: '技巧',
  nature: '自然',
  psionic: '灵能',
  steam: '蒸汽',
  antimagic: '反魔',
  wilder: '自然之力',
  spell: '法术',
  chronomancy: '时空',
  corruption: '堕落',
  undead: '亡灵',
};

const REQUIREMENT_LABELS: Record<string, string> = {
  stat: '属性',
  level: '等级',
  talent: '技能',
  stat_str: '力量',
};

const STAT_LABELS: Record<string, string> = {
  str: '力量',
  dex: '敏捷',
  con: '体质',
  mag: '魔法',
  wil: '意志',
  cun: '灵巧',
  lck: '幸运',
};

/** Native icon with a category fallback, matching the monster encyclopedia. */
function ArtifactIcon({ artifact, size = 64 }: { artifact: Artifact; size?: number }) {
  const [failed, setFailed] = useState(false);
  const src = artifact.imagePath ? assetUrl(artifact.imagePath) : null;

  if (!src || failed) {
    return (
      <div
        className="flex shrink-0 items-center justify-center rounded-md border border-line bg-sunken text-[11px] text-subtle"
        style={{ width: size, height: size }}
        title={
          artifact.image
            ? `缺少图标（源码路径：${artifact.image}）`
            : '该物品的图标由游戏按材质模板生成，没有独立文件'
        }
      >
        {artifact.typeZh ?? artifact.type ?? '?'}
      </div>
    );
  }

  return (
    <img
      src={src}
      alt=""
      width={size}
      height={size}
      // Pixel art: keep it crisp instead of letting the browser blur it.
      style={{ imageRendering: 'pixelated' }}
      className="shrink-0 rounded-md border border-line bg-sunken"
      onError={() => setFailed(true)}
    />
  );
}

function RequirementRow({ artifact }: { artifact: Artifact }) {
  if (!artifact.require?.length) return null;
  return (
    <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1 text-[12px]">
      <span className="text-muted">装备需求</span>
      {artifact.require.map((group, index) => (
        <span key={`${group.kind}-${index}`} className="inline-flex items-baseline gap-1">
          <span className="text-subtle">{REQUIREMENT_LABELS[group.kind ?? ''] ?? group.kind}</span>
          {group.stats?.length ? (
            group.stats.map((stat) => (
              <span key={stat.key} className="font-medium tabular-nums">
                {(STAT_LABELS[stat.key ?? ''] ?? stat.key) ?? '?'} {stat.amount ?? '?'}
              </span>
            ))
          ) : (
            <span className="font-medium tabular-nums">{group.amount}</span>
          )}
        </span>
      ))}
    </div>
  );
}

export function ArtifactDetail({
  artifact,
  dataset,
  report,
  terms,
  damageTypes,
  labelResolver,
  talentOf,
  onSelectTalent,
  selectedTalentId,
  onClose,
}: ArtifactDetailProps) {
  const [showLua, setShowLua] = useState(false);
  const talent = artifact.useTalent ? talentOf(artifact.useTalent.talentId) : undefined;
  const flavor = artifact.descZh ?? artifact.desc;
  const special = artifact.specialDesc;

  return (
    <article className="space-y-4" data-testid="artifact-detail">
      {/* --- Identity and requirements --- */}
      <header className="flex items-start gap-3">
        <ArtifactIcon artifact={artifact} />
        <div className="min-w-0 flex-1">
          <div className="flex flex-wrap items-baseline gap-x-2 gap-y-0.5">
            <h2 className="text-[16px] font-semibold">
              <Highlight text={artifact.nameZh ?? artifact.name} terms={terms} />
            </h2>
            {artifact.nameZh && (
              <span className="text-[12px] text-subtle">
                <Highlight text={artifact.name} terms={terms} />
              </span>
            )}
            <button type="button" className="btn btn-ghost ml-auto px-2 py-0.5" onClick={onClose}>
              关闭
            </button>
          </div>

          <div className="mt-1.5 flex flex-wrap items-center gap-1.5">
            {artifact.typeZh && <span className="chip">{artifact.typeZh}</span>}
            {artifact.subtypeZh && <span className="chip">{artifact.subtypeZh}</span>}
            {artifact.slotZh && <span className="chip" title={`装备栏位：${artifact.slot}`}>栏位 {artifact.slotZh}</span>}
            {artifact.tier !== null && <span className="chip" title="材质等级，影响部分词缀的数值">阶级 {artifact.tier}</span>}
            <span className="chip">{sourceLabel(dataset, artifact.source)}</span>
            {artifact.powerSources.map((source) => (
              <span key={source} className="chip" title={`力量来源：${source}`}>
                {POWER_SOURCE_LABELS[source] ?? source}
              </span>
            ))}
            {artifact.status === 'non-equipment' && (
              <span className="chip" title="这是固定神器，但不是可穿戴装备">非装备类</span>
            )}
            {artifact.quest && <span className="chip" title="任务相关物品">任务</span>}
          </div>

          <div className="mt-2 space-y-1">
            <RequirementRow artifact={artifact} />
            {/*
              `rarity` is a relative generation weight, never a drop rate, and
              `level_range` is the band the item generates in rather than the
              level needed to equip it. Both are spelled out in the visible text
              rather than only in a tooltip: a reader who never hovers must not
              come away thinking 200 is a 200% drop chance.
            */}
            <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1 text-[11.5px] text-subtle">
              {artifact.rarity !== null && (
                <span>生成权重 {artifact.rarity}（相对权重，不是掉落概率）</span>
              )}
              {artifact.levelRange?.length === 2 && (
                <span>
                  生成等级 {artifact.levelRange[0]}–{artifact.levelRange[1]}（可生成区间，不是装备需求等级）
                </span>
              )}
              {artifact.cost !== null && <span>基础售价 {artifact.cost / 10}</span>}
              {artifact.encumber !== null && <span>负重 {artifact.encumber}</span>}
            </div>
          </div>
        </div>
      </header>

      {/* --- Equipment body, wearer effects, triggers: grouped rendering --- */}
      {artifact.properties.length > 0 ? (
        <ItemProperties
          labelResolver={labelResolver}
          groups={artifact.properties}
          fieldMeta={dataset.fieldMeta}
          damageTypes={damageTypes}
        />
      ) : (
        <p className="rounded-lg border border-line bg-surface-raised/60 px-3 py-2.5 text-[12px] text-subtle">
          这件物品没有静态属性面板。
        </p>
      )}

      {/* --- Active ability --- */}
      {(artifact.useTalent || artifact.usePower) && (
        <section className="rounded-lg border border-line bg-surface-raised/60 px-3 py-2.5">
          <h3 className="mb-1.5 text-[13px] font-semibold">主动使用能力</h3>
          <div className="space-y-1.5 text-[12.5px]">
            {artifact.usePower && (
              <p className="leading-relaxed">
                <span className="text-muted">效果</span>{' '}
                {artifact.usePower.nameZh ?? artifact.usePower.name ?? '该能力的说明由游戏在运行时生成'}
                {artifact.usePower.nameIsFunction && (
                  <span className="chip ml-1.5" title="说明文本取决于穿戴者的属性">随角色变化</span>
                )}
              </p>
            )}
            <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1 text-[11.5px] text-subtle">
              {artifact.usePower?.power !== null && artifact.usePower?.power !== undefined && (
                <span>消耗 {artifact.usePower.power} 充能</span>
              )}
              {artifact.usePower?.cooldown !== null && artifact.usePower?.cooldown !== undefined && (
                <span>冷却 {artifact.usePower.cooldown} 回合</span>
              )}
            </div>
            {artifact.useTalent && (
              <div className="flex flex-wrap items-baseline gap-x-2 gap-y-1">
                <span className="text-muted">触发技能</span>
                <button
                  type="button"
                  disabled={!talent}
                  onClick={() => talent && onSelectTalent(talent)}
                  aria-pressed={selectedTalentId === artifact.useTalent.talentId}
                  className={`btn px-2 py-0.5 ${selectedTalentId === artifact.useTalent.talentId ? 'btn-primary' : ''}`}
                  title={talent ? '在本页技能面板中查看，不会离开神器页面' : '该技能不在技能库中'}
                >
                  {talent?.plainName ?? artifact.useTalent.talentId}
                  <span className="text-[10.5px] opacity-70">{artifact.useTalent.talentId}</span>
                </button>
                {artifact.useTalent.level !== null && <span className="text-[11.5px] text-subtle">等级 {artifact.useTalent.level}</span>}
                {artifact.useTalent.power !== null && <span className="text-[11.5px] text-subtle">消耗 {artifact.useTalent.power}</span>}
              </div>
            )}
          </div>
        </section>
      )}

      {/* --- Special mechanics --- */}
      {special && (special.zh || special.en) && (
        <section className="rounded-lg border border-line bg-surface-raised/60 px-3 py-2.5">
          <h3 className="mb-1.5 text-[13px] font-semibold">特殊机制</h3>
          <p className="text-[12.5px] leading-relaxed whitespace-pre-wrap">
            {special.zh ?? special.en}
          </p>
          {special.zh && special.en && (
            <p className="mt-1 text-[11px] text-subtle">{special.en}</p>
          )}
          {special.computed && (
            <p className="mt-1 text-[11px] text-subtle">
              该项由游戏按当前角色状态动态生成，此处只保留源码中的文字说明。
            </p>
          )}
        </section>
      )}

      {/* --- How it is obtained, and where it is defined --- */}
      <section className="rounded-lg border border-line bg-surface-raised/60 px-3 py-2.5">
        <h3 className="mb-1.5 text-[13px] font-semibold">获取与出处</h3>
        <div className="space-y-1 text-[12px]">
          {artifact.definitions.map((definition) => {
            const path = sourcePath(report, definition.file);
            return (
              <p key={`${definition.file}-${definition.line}`} className="text-muted">
                {definition.zone ? `区域「${definition.zone}」` : '物品定义'}
                <button
                  type="button"
                  className="btn-ghost btn ml-2 px-1.5 py-0"
                  onClick={() => setShowLua((v) => !v)}
                  title="查看源码位置，用于校对"
                >
                  {showLua ? '隐藏源码' : '源码'}
                </button>
                {showLua && (
                  <code className="ml-1.5 rounded bg-chip px-1 text-[10.5px]">
                    {path}:{definition.line}
                  </code>
                )}
              </p>
            );
          })}
          <p className="text-[11.5px] text-subtle">
            此处只列出可以从源码确认的定义位置。掉落关系写在怪物、区域或任务配置里，
            本站没有核实过的掉落概率一律不显示。
            {artifact.definitions.length > 1 && ' 该物品在多处有完全相同的定义，列为同一件。'}
          </p>
          {artifact.variantNote && (
            <p className="text-[11.5px] text-subtle">同名不同形态：{artifact.variantNote}</p>
          )}
        </div>
      </section>

      {/* --- Flavour text last, so it cannot bury the numbers --- */}
      {flavor && (
        <section className="rounded-lg border border-line bg-surface-raised/40 px-3 py-2.5">
          <h3 className="mb-1 text-[11.5px] font-semibold text-subtle">风味描述</h3>
          <p className="text-[12px] leading-relaxed text-muted italic">{flavor}</p>
          {artifact.descZh && artifact.desc && (
            <p className="mt-1 text-[10.5px] text-subtle italic">{artifact.desc}</p>
          )}
        </section>
      )}
    </article>
  );
}

/** Exported for tests: the same formatting the detail panel uses. */
export { formatPropValue };
