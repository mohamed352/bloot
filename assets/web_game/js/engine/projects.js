import { SUITS, NATURAL, PROJECT_QAID, PROJECT_NAMES } from "./constants.js";
import { cardKey } from "./deck.js";
import { teamOf } from "./cards.js";

// ===== المشاريع ===== (بند 50 بـTASKS.md: نفس أنواع المشاريع تُكتشف بالصن والحكم — القيمة
// فقط تختلف حسب PROJECT_QAID. البلوت مستقل تماماً عن هذا المسار، ما يتأثر بهالتغيير.)
export function findProjects(hand, mode, trump) {
  const projects = [];
  const used = new Set();

  // أربع متشابهة (A K Q J 10 فقط)
  for (const rank of ["A", "K", "Q", "J", "10"]) {
    const cards = hand.filter((c) => c.rank === rank);
    if (cards.length === 4) {
      if (rank === "A") {
        projects.push({ type: "fourAces", cards });
      } else {
        projects.push({ type: "hundred", cards });
      }
      cards.forEach((c) => used.add(cardKey(c)));
    }
  }

  // السلاسل المتتالية لكل لون (بالترتيب الطبيعي)
  for (const suit of SUITS) {
    const idxs = hand
      .filter((c) => c.suit === suit && !used.has(cardKey(c)))
      .map((c) => NATURAL.indexOf(c.rank))
      .sort((a, b) => a - b);
    let run = [];
    const flush = () => {
      while (run.length >= 3) {
        let take;
        if (run.length >= 5) take = 5;
        else take = run.length; // 3 أو 4
        const type = take === 5 ? "hundred" : take === 4 ? "fifty" : "sira";
        const cards = run.slice(run.length - take).map((i) => ({ suit, rank: NATURAL[i] }));
        projects.push({ type, cards });
        run = run.slice(0, run.length - take);
        if (run.length < 3) break;
      }
      run = [];
    };
    for (let k = 0; k < idxs.length; k++) {
      if (run.length && idxs[k] === run[run.length - 1] + 1) run.push(idxs[k]);
      else { flush(); run = [idxs[k]]; }
    }
    flush();
  }
  return projects;
}

export function projectQaid(p, mode) { return PROJECT_QAID[mode][p.type]; }

// الأنواع المتاحة للإعلان — نفسها بالصن والحكم (بند 50)
export function projectTypesFor(mode) {
  const types = ["sira", "fifty", "hundred", "fourAces"];
  return types.map((t) => ({ type: t, name: PROJECT_NAMES[t], qaid: PROJECT_QAID[mode][t] }));
}

// مقارنة أقوى مشروع: الفريق صاحب الأقوى يحسب كل مشاريعه
export function resolveProjects(allProjects, mode, firstPlayer) {
  const comparable = allProjects;
  if (!comparable.length) return { counted: [], dropped: [] };

  function power(p) {
    const q = projectQaid(p, mode);
    const top = Math.max(...p.cards.map((c) => NATURAL.indexOf(c.rank)));
    // أولوية القيد ثم أعلى ورقة ثم الأقرب بالدور من أول لاعب
    const orderBonus = (4 + p.seat - firstPlayer) % 4;
    return q * 10000 + top * 100 + (3 - orderBonus);
  }
  let best = comparable[0];
  for (const p of comparable) if (power(p) > power(best)) best = p;
  const winTeam = teamOf(best.seat);
  const counted = comparable.filter((p) => teamOf(p.seat) === winTeam);
  const dropped = comparable.filter((p) => teamOf(p.seat) !== winTeam);
  return { counted, dropped };
}
