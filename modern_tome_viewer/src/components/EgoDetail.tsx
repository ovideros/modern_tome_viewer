/**
 * Equipment ego affix detail panel.
 *
 * The question a reader arrives with is "which slots can roll this, and what
 * does it actually do", so applicability comes before the effect list and the
 * shared-pool relationship is shown rather than hidden: an ego reachable through
 * a chainsaw's shield pool is marked as `共享`, which is the difference between
 * "this affix exists" and "this affix can appear on my weapon".
 *
 * `ItemProperties` renders the effect groups with the same wearer/weapon split
 * the artifact page uses, so the two pages read identically.
 */

import { useState } from 'react';
import { Highlight } from './Highlight';
import { ItemProperties } from './ItemProperties';
import type { CommunityRow, CommunityUnmatched, Ego, EgoDataset, ItemsReport } from '../lib/items';
import { sourcePath } from '../lib/items';
import { egoFactLines, egoNoteLines, renderNote } from '../lib/ego-facts';

interface EgoDetailProps {
  ego: Ego;
  dataset: EgoDataset;
  report: ItemsReport;
  terms: string[];
  damageTypes: Record<string, string>;
  /** Chinese labels for the pools that have base items, from the report. */
  poolLabels: Record<string, string>;
  /** Community spreadsheet row matched to this ego, when the supplement exists. */
  community: CommunityRow | null;
  /** Community recommendation (1–5), shown next to the name as a tag. */
  recommendation?: number;
  /** Unmatched spreadsheet rows that mention this ego's name, as leads only. */
  communityLeads: CommunityUnmatched[];
  /** Item material level chosen on the page (1–5), or null for "every level". */
  materialLevel?: number | null;
  /** Turns engine codes into Chinese (talent names, tree names, actor types). */
  labelResolver?: (code: string) => string | null;
  onSelectPool: (pool: string) => void;
  onClose: () => void;
}

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

export function EgoDetail({
  ego,
  dataset,
  report,
  terms,
  damageTypes,
  poolLabels,
  community,
  recommendation,
  communityLeads,
  materialLevel = null,
  labelResolver,
  onSelectPool,
  onClose,
}: EgoDetailProps) {
  const [showSource, setShowSource] = useState(false);
  const path = sourcePath(report, ego.file);
  const positionLabel = ego.position === 'prefix' ? '前缀' : ego.position === 'suffix' ? '后缀' : '未标注';

  // The same lines the list card shows, so opening a row never contradicts the
  // list it was opened from.
  const facts = egoFactLines(ego, dataset.fieldMeta, damageTypes, materialLevel, labelResolver);
  const notes = egoNoteLines(ego, materialLevel);
  const hasEffect = facts.length > 0 || notes.length > 0;
  const randomWeightTotal = (ego.randomOptions ?? []).reduce((total, option) => total + option.weight, 0);

  // Group applicability by the pool it comes from, so a shared pool can be
  // shown as such instead of being flattened into one list of slots.
  const byPool = new Map<string, typeof ego.applicable>();
  for (const entry of ego.applicable) {
    const list = byPool.get(entry.pool) ?? [];
    list.push(entry);
    byPool.set(entry.pool, list);
  }

  return (
    <article className="space-y-4" data-testid="ego-detail">
      <header className="space-y-1.5">
        <div className="flex flex-wrap items-baseline gap-x-2 gap-y-0.5">
          <h2 className="text-[16px] font-semibold">
            <Highlight text={ego.name.zh ?? ego.name.clean} terms={terms} />
          </h2>
          <span className="text-[12px] text-subtle">{ego.name.clean}</span>
          <button type="button" className="btn btn-ghost ml-auto px-2 py-0.5" onClick={onClose}>
            关闭
          </button>
        </div>

        <div className="flex flex-wrap items-center gap-1.5">
          <span className="chip">{positionLabel}</span>
          {/*
            Same colour as the list card: the marker must be recognisable across
            both views, otherwise the reader has to re-learn it in the detail.
          */}
          {ego.greater && (
            <span
              className="inline-flex items-center rounded-full border border-amber-500/50 bg-amber-500/15 px-1.5 text-[10.5px] font-semibold text-amber-800 dark:text-amber-300"
              title="greater_ego：同一词缀的高级档"
            >
              高级词缀
            </span>
          )}
          {ego.uniqueEgoTag && <span className="chip" title={`unique_ego = ${ego.uniqueEgoTag}`}>唯一词缀</span>}
          {ego.powerSources.map((source) => (
            <span key={source} className="chip" title={`力量来源：${source}`}>
              {POWER_SOURCE_LABELS[source] ?? source}
            </span>
          ))}
          <span className="chip">{dataset.sources.find((s) => s.id === ego.source)?.label ?? ego.source}</span>
          {recommendation !== undefined && (
            <span className="chip" title="玩家词缀表的推荐度（社区评价，不是游戏数据）">
              社区推荐 {recommendation} / 5
            </span>
          )}
        </div>

        {/* Name placeholders the engine resolves at generation time. Tokens are
            explained rather than expanded, because their value is the item's own
            stat and there is no single number to show. */}
        {ego.name.tokens.length > 0 && (
          <p className="text-[11.5px] text-subtle">
            名称中的占位符：
            {ego.name.tokens.map((token) => (
              <span key={token} className="chip ml-1" title={dataset.labels.nameTokens[token]?.note}>
                #{token}# = {dataset.labels.nameTokens[token]?.zh ?? token}
              </span>
            ))}
          </p>
        )}

        <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1 text-[11.5px] text-subtle">
          {ego.rarity !== null && (
            <span>生成权重 {ego.rarity}（相对权重，数值越小越常见，不是掉落概率）</span>
          )}
          {ego.levelRange?.length === 2 && (
            <span>
              生成等级 {ego.levelRange[0]}–{ego.levelRange[1]}（可生成区间，不是装备需求等级）
            </span>
          )}
          {ego.cost !== null && <span>基础价值 {ego.cost}</span>}
          <button
            type="button"
            className="btn btn-ghost px-1.5 py-0"
            onClick={() => setShowSource((v) => !v)}
            title="查看词缀定义在游戏源码中的位置"
          >
            {showSource ? '隐藏源码' : '源码'}
          </button>
          {showSource && <code className="rounded bg-chip px-1 text-[10.5px]">{path}:{ego.line}</code>}
        </div>
      </header>

      {/* --- Applicability first: the most common question --- */}
      <section className="rounded-lg border border-line bg-surface-raised/60 px-3 py-2.5">
        <h3 className="mb-1.5 text-[13px] font-semibold">适用装备</h3>
        <div className="space-y-2">
          {[...byPool.entries()].map(([pool, entries]) => {
            const shared = entries.some((entry) => entry.via === 'shared');
            return (
              <div key={pool}>
                <div className="flex flex-wrap items-baseline gap-1.5">
                  <button type="button" className="btn px-1.5 py-0 text-[11.5px]" onClick={() => onSelectPool(pool)}>
                    {poolLabels[pool] ?? pool}
                  </button>
                  <span className="text-[10.5px] text-subtle">{pool}</span>
                  {shared && (
                    <span className="chip" title="该词缀来自被此装备共享加载的词缀池，不是该部位专属">
                      共享词缀池
                    </span>
                  )}
                </div>
                <div className="mt-0.5 flex flex-wrap gap-1">
                  {entries.map((entry) => (
                    <span
                      key={`${entry.pool}-${entry.subtype}-${entry.slot}`}
                      className="chip"
                      title={entry.example ? `例：${entry.example}` : undefined}
                    >
                      {(entry.subtypeZh ?? entry.subtype) ?? entry.typeZh ?? '—'}
                      {entry.slotZh ? ` · ${entry.slotZh}` : ''}
                    </span>
                  ))}
                </div>
              </div>
            );
          })}
          {byPool.size === 0 && (
            <p className="text-[12px] text-subtle">未能从源码解析出该词缀的适用装备，已记录为待完善项。</p>
          )}
        </div>
      </section>

      {/* --- Effects: summary first, full property table below --- */}
      {hasEffect ? (
        <section className="rounded-lg border border-line bg-surface-raised/60 px-3 py-2.5">
          <h3 className="mb-1.5 flex flex-wrap items-baseline gap-2 text-[13px] font-semibold">
            效果
            {materialLevel !== null && (
              <span className="chip" title="页面左上角选择的材料等级">
                数值按材料等级 {materialLevel} 计算
              </span>
            )}
          </h3>
          {facts.length > 0 && (
            <ul className="space-y-0.5 text-[12.5px] leading-relaxed">
              {facts.map((line) => (
                <li key={line} className="tabular-nums">{line}</li>
              ))}
            </ul>
          )}
          {/*
            Effects that are not a property table. A `game` note is the game's
            own wording (translated), a `source` note is hand-written from the
            callback; both are labelled so the reader knows which is which.
          */}
          {notes.length > 0 && (
            <ul className={`space-y-1 text-[12.5px] leading-relaxed ${facts.length ? 'mt-1.5 border-t border-line pt-1.5' : ''}`}>
              {(ego.notes ?? []).map((note, index) => (
                <li key={`${note.basis}-${index}`}>
                  <span
                    className="chip mr-1"
                    title={note.basis === 'game'
                      ? '游戏自身的说明文本，数值由本站按源码推导填入'
                      : `由本站根据源码回调整理：${note.from ?? ''}`}
                  >
                    {note.basis === 'game' ? '游戏说明' : '源码整理'}
                  </span>
                  <span>{notes[index]}</span>
                  {note.en && note.en !== notes[index] && (
                    <span className="ml-1 text-[10.5px] text-subtle">
                      {renderNote({ ...note, text: note.en }, materialLevel)}
                    </span>
                  )}
                </li>
              ))}
            </ul>
          )}
        </section>
      ) : (
        <p className="rounded-lg border border-line bg-surface-raised/60 px-3 py-2.5 text-[12px] text-subtle">
          该词缀的效果写在运行时回调里，源码中没有可以静态读取的属性表，
          社区词缀表也没有对应的效果记录，因此这里不做猜测。
        </p>
      )}

      {ego.randomOptions && ego.randomOptions.length > 0 && (
        <section className="rounded-lg border border-line bg-surface-raised/60 px-3 py-2.5" data-testid="ego-random-options">
          <h3 className="mb-1.5 flex flex-wrap items-baseline gap-2 text-[13px] font-semibold">
            随机技能池
            <span className="chip">{ego.randomOptions.length} 个候选</span>
          </h3>
          <p className="mb-2 text-[11.5px] leading-relaxed text-subtle">
            每次触发时从下列技能中按权重抽取 1 项；权重越大，被选中的机会越高。总权重 {randomWeightTotal}，不是等概率抽取。
          </p>
          <div className="flex flex-wrap gap-1.5">
            {ego.randomOptions.map((option) => (
              <span key={option.talentId} className="chip" title={`抽取权重 ${option.weight}`}>
                {labelResolver?.(option.talentId) ?? '未翻译技能'}
                <span className="ml-1 text-[10px] text-subtle">×{option.weight}</span>
              </span>
            ))}
          </div>
        </section>
      )}

      {ego.areas.length > 0 && (
        <ItemProperties
          groups={ego.areas}
          fieldMeta={dataset.fieldMeta}
          damageTypes={damageTypes}
          materialLevel={materialLevel}
          labelResolver={labelResolver}
        />
      )}

      {ego.desc && (
        <p className="text-[12px] leading-relaxed text-muted">{ego.desc}</p>
      )}

      {/*
        Community reference, clearly walled off from the game data above.
        The spreadsheet is one player's opinion and its rarity column disagrees
        with the source in 14 places; those disagreements are listed as conflicts
        in the coverage report and the source value is what the page shows.
      */}
      {(community || communityLeads.length > 0) && (
        <section className="rounded-lg border border-dashed border-line bg-surface-raised/40 px-3 py-2.5">
          <h3 className="mb-1.5 flex flex-wrap items-baseline gap-2 text-[13px] font-semibold">
            社区参考
            <span className="text-[10.5px] font-normal text-subtle">
              来自玩家整理的《物品词缀表》，属于社区评价，不是游戏客观数据
            </span>
          </h3>
          {community ? (
            <div className="space-y-1 text-[12px]">
              <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1">
                {community.recommend && (
                  <span>
                    推荐度 <span className="font-semibold tabular-nums">{community.recommend}</span>
                    <span className="text-subtle"> / 5</span>
                  </span>
                )}
                {community.greater && <span className="chip">表中标注：{community.greater === '是' ? '高级词缀' : '普通词缀'}</span>}
                <span className="text-[10.5px] text-subtle">
                  出处：{community.sheet} 第 {community.row} 行
                </span>
              </div>
              {community.effect && (
                <p className="leading-relaxed">
                  <span className="text-muted">表中的效果描述</span>
                  <span className="ml-1">{community.effect}</span>
                </p>
              )}
              {community.note && (
                <p className="leading-relaxed">
                  <span className="text-muted">玩家备注</span>
                  <span className="ml-1">{community.note}</span>
                </p>
              )}
              {community.updated && (
                <p className="text-[11.5px] text-subtle">
                  该行的稀有度与源码不一致（表内值已保留在覆盖报告里，页面显示的是源码值）。
                </p>
              )}
            </div>
          ) : (
            <p className="text-[12px] text-subtle">
              社区表中有 {communityLeads.length} 行提到这个词缀名，但没有归到同一个词缀池，本站没有强行匹配。
              这些行留在覆盖报告的待核实清单里。
            </p>
          )}
        </section>
      )}

      {/* A field the field map does not know is surfaced, never hidden. */}
      {ego.unmapped.length > 0 && (
        <section className="rounded-lg border border-dashed border-line px-3 py-2.5">
          <h3 className="mb-1 text-[12px] font-semibold text-subtle">待完善映射的属性字段</h3>
          <div className="flex flex-wrap gap-1">
            {ego.unmapped.map((key) => (
              <code key={key} className="chip">{key}</code>
            ))}
          </div>
          <p className="mt-1 text-[11px] text-subtle">
            这些字段已在源码中出现，但还没有对应的中文标签与展示分类；数值没有被丢弃，也没有被当作 0。
          </p>
        </section>
      )}
    </article>
  );
}
