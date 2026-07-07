export type SearchHit = {
  id: string;
  key: string;
  score: number;
  content: string;
  tags?: string[];
  updated_at: string;
  source: "vector" | "keyword";
};

/** Reciprocal rank fusion for hybrid retrieval. */
export function mergeHybridResults(
  vectorHits: SearchHit[],
  keywordHits: SearchHit[],
  topK: number,
): SearchHit[] {
  const k = 60;
  const scores = new Map<
    string,
    { score: number; hit: SearchHit }
  >();

  const add = (hits: SearchHit[], weight: number) => {
    hits.forEach((hit, rank) => {
      const id = `${hit.key}::${hit.id}`;
      const rrf = weight / (k + rank + 1);
      const prev = scores.get(id);
      if (prev) {
        prev.score += rrf;
        if (hit.score > prev.hit.score) {
          prev.hit = { ...hit, score: prev.score + rrf };
        }
      } else {
        scores.set(id, { score: rrf, hit: { ...hit, score: rrf } });
      }
    });
  };

  add(vectorHits, 1);
  add(keywordHits, 0.8);

  return [...scores.values()]
    .sort((a, b) => b.score - a.score)
    .slice(0, topK)
    .map(({ score, hit }) => ({ ...hit, score }));
}
