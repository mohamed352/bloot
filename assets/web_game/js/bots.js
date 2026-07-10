// ذكاء البوتات — أربع مستويات: مبتدئ، هاوي، متمرس، محترف
import {
  teamOf, cardPoints, cardStrength, trickWinnerIdx,
  legalMoves, SUITS, RANKS, HOKUM_TRUMP_ORDER, SUN_ORDER,
} from "./engine/index.js";

export const LEVELS = { beginner: "مبتدئ 🐣", amateur: "نص نص", skilled: "شاطر", pro: "وحش 🔥" };

function rand(arr) { return arr[Math.floor(Math.random() * arr.length)]; }

// ===== تقييم اليد للمزايدة (5 أوراق + المشترى إذا كان لك) =====
function evalHokum(hand, suit, topCard, takesTop) {
  const cards = takesTop && topCard.suit === suit ? hand.concat([topCard]) : hand.slice();
  const trumps = cards.filter((c) => c.suit === suit);
  let score = 0;
  for (const c of trumps) {
    if (c.rank === "J") score += 3.2;
    else if (c.rank === "9") score += 2.2;
    else if (c.rank === "A") score += 1.6;
    else if (c.rank === "10") score += 1.2;
    else score += 0.8;
  }
  // أوراق جانبية قوية
  for (const c of cards) {
    if (c.suit === suit) continue;
    if (c.rank === "A") score += 1.1;
    else if (c.rank === "10") score += 0.5;
  }
  if (trumps.length >= 4) score += 1;
  return score;
}

function evalSun(hand, topCard, takesTop) {
  const cards = takesTop ? hand.concat([topCard]) : hand.slice();
  let score = 0;
  for (const c of cards) {
    if (c.rank === "A") score += 2.6;
    else if (c.rank === "10") score += 1.4;
    else if (c.rank === "K") score += 0.7;
    else if (c.rank === "Q") score += 0.3;
  }
  // تماسك الألوان
  for (const s of SUITS) {
    const n = cards.filter((c) => c.suit === s).length;
    if (n >= 3) score += 0.5;
  }
  return score;
}

// قرار المزايدة
export function decideBid(match, seat, level) {
  const st = match.state;
  const hand = st.hands[seat];
  const top = st.topCard;
  const round = st.bidding.round;
  const best = st.bidding.best;

  // عتبات حسب المستوى
  const th = {
    beginner: { hokum: 6.6, sun: 7.7, noise: 2.0 },
    amateur: { hokum: 6.1, sun: 7.3, noise: 1.0 },
    skilled: { hokum: 5.6, sun: 6.9, noise: 0.5 },
    pro: { hokum: 5.2, sun: 6.6, noise: 0.15 },
  }[level];

  // ضغط الموقع: بالجولة الثانية الشروط أخف، وآخر متكلم بدون شراء يجازف أكثر
  let adj = 0;
  if (round === 2) {
    adj -= 0.4;
    if (st.bidding.spoken === 3 && !best) adj -= 0.8;
  }
  th.hokum += adj;
  th.sun += adj;

  const noise = () => (Math.random() * 2 - 1) * th.noise;

  // صن دائماً متاح (يغلب الحكم)
  const sunScore = evalSun(hand, top, true) + noise();
  const canSun = !best || best.type !== "sun";

  if (round === 1) {
    const hokumScore = evalHokum(hand, top.suit, top, true) + noise();
    const canHokum = !best; // حكم واحد فقط بالجولة

    // الأشكل: بس للموزع أو اللي قبله بالدور. يلعب متل الصن، بس ما ياخذ الورقة المكشوفة لنفسه —
    // تروح لخويه. فيفضّلها البوت على الصن العادي لو يده قوية بذاتها بدون حاجة للورقة المكشوفة
    // (يعني ما يخسر شي بالتنازل عنها لخويه).
    const ashkalEligible = seat === match.dealer || seat === (match.dealer + 3) % 4;
    if (ashkalEligible) {
      const ashkalScore = evalSun(hand, top, false) + noise();
      if (ashkalScore >= th.sun && ashkalScore >= hokumScore && ashkalScore >= sunScore) {
        return { type: "ashkal" };
      }
    }

    if (canSun && sunScore >= th.sun && sunScore >= hokumScore) return { type: "sun" };
    if (canHokum && hokumScore >= th.hokum) return { type: "hokum" };
    if (canSun && sunScore >= th.sun) return { type: "sun" };
    return { type: "pass" };
  }

  // الجولة الثانية: حكم ثاني (أي لون غير المشترى) أو صن — الأشكل ما يصير إلا بالجولة الأولى
  let bestSuit = null, bestScore = -1;
  for (const s of SUITS) {
    if (s === top.suit) continue;
    const sc = evalHokum(hand, s, top, true);
    if (sc > bestScore) { bestScore = sc; bestSuit = s; }
  }
  bestScore += noise();
  if (canSun && sunScore >= th.sun && sunScore >= bestScore) return { type: "sun" };
  if (!best && bestScore >= th.hokum) return { type: "hokum", suit: bestSuit };
  if (canSun && sunScore >= th.sun) return { type: "sun" };
  return { type: "pass" };
}

// ===== اللعب =====

// هل هذي الورقة أعلى ورقة باقية بلونها؟ (سيد)
function isMaster(card, st) {
  const order = st.mode === "hokum" && card.suit === st.trump ? HOKUM_TRUMP_ORDER : SUN_ORDER;
  const myPow = order.indexOf(card.rank);
  for (const r of RANKS) {
    if (order.indexOf(r) <= myPow) continue;
    const played = st.playedCards.some((c) => c.suit === card.suit && c.rank === r);
    if (!played) return false; // فيه أعلى منها ما انلعبت
  }
  return true;
}

function trickPoints(trick, st) {
  return trick.reduce((s, t) => s + cardPoints(t.card, st.mode, st.trump), 0);
}

function currentWinner(trick, st) {
  if (!trick.length) return null;
  return trick[trickWinnerIdx(trick, st.mode, st.trump)].seat;
}

function strength(card, led, st) { return cardStrength(card, led, st.mode, st.trump); }

function lowestBy(cards, st) {
  return cards.slice().sort((a, b) => {
    const pa = cardPoints(a, st.mode, st.trump), pb = cardPoints(b, st.mode, st.trump);
    if (pa !== pb) return pa - pb;
    return strength(a, a.suit, st) - strength(b, b.suit, st);
  })[0];
}

export function decidePlay(match, seat, level) {
  const st = match.state;
  const hand = st.hands[seat];
  // دبل نازل (مستوى ≥2) يلغي استثناء "خويك رابح → حر" — لازم يُمرَّر لـlegalMoves وإلا
  // البوت يفكر إنه حر ويقص/يسيّد بشكل خاطئ (مخالفة ربع) وقت الدبل.
  const strict = (st.doubleLevel || 1) >= 2;
  const legal = legalMoves(hand, st.currentTrick, st.mode, st.trump, seat, strict);
  if (legal.length === 1) return legal[0];

  if (level === "beginner") return rand(legal);

  const trick = st.currentTrick;
  const partner = (seat + 2) % 4;
  const isLast = trick.length === 3;

  // ===== قائد الأكلة =====
  if (!trick.length) {
    // متمرس+: العب السيد
    if (level !== "amateur") {
      const masters = legal.filter((c) => isMaster(c, st));
      if (masters.length) {
        // محترف: قدّم السيد اللي معه نقاط أعلى
        return masters.sort((a, b) => cardPoints(b, st.mode, st.trump) - cardPoints(a, st.mode, st.trump))[0];
      }
    }
    // محترف: قص الخوي — لو خويك هارب من لون وفيه حكم، العبه له
    if (level === "pro" && st.mode === "hokum") {
      const trumpsOut = st.playedCards.filter((c) => c.suit === st.trump).length;
      for (const c of legal) {
        if (c.suit !== st.trump && st.voids[partner].has(c.suit) && trumpsOut < 8) {
          const opp1 = (seat + 1) % 4, opp2 = (seat + 3) % 4;
          if (!st.voids[opp1].has(c.suit) || !st.voids[opp2].has(c.suit)) return c;
        }
      }
    }
    // تجنب فتح لون الخصم هارب منه (بيقصه)
    if (st.mode === "hokum" && level !== "amateur") {
      const opp1 = (seat + 1) % 4, opp2 = (seat + 3) % 4;
      const safe = legal.filter((c) => c.suit === st.trump || (!st.voids[opp1].has(c.suit) && !st.voids[opp2].has(c.suit)));
      if (safe.length) return lowestBy(safe, st);
    }
    return lowestBy(legal, st);
  }

  // ===== داخل الأكلة =====
  const led = trick[0].card.suit;
  const winSeat = currentWinner(trick, st);
  const partnerWinning = teamOf(winSeat) === teamOf(seat);
  const curBest = Math.max(...trick.map((t) => strength(t.card, led, st)));
  const winners = legal.filter((c) => strength(c, led, st) > curBest);
  const pts = trickPoints(trick, st);

  if (partnerWinning) {
    // تسمين: خويك رابح — عطه نقاط (متمرس+)
    if (level !== "amateur") {
      const partnerCard = trick.find((t) => t.seat === partner);
      const partnerSolid = partnerCard && (isLast || isMaster(partnerCard.card, st));
      if (partnerSolid) {
        const feed = legal.filter((c) => strength(c, led, st) <= curBest || c.suit !== led);
        if (feed.length) {
          const fat = feed.sort((a, b) => cardPoints(b, st.mode, st.trump) - cardPoints(a, st.mode, st.trump))[0];
          if (cardPoints(fat, st.mode, st.trump) >= 4) return fat;
          return lowestBy(feed, st);
        }
      }
    }
    return lowestBy(legal, st);
  }

  // الخصم رابح
  if (winners.length) {
    // اربح بأرخص ورقة تربح
    const cheapWin = winners.sort((a, b) => strength(a, led, st) - strength(b, led, st))[0];
    if (level === "amateur") return cheapWin;
    // متمرس+: لا تحرق سيد كبير على أكلة فاضية إلا لو أنت الأخير
    if (isLast) return cheapWin;
    if (pts >= 10 || cardPoints(cheapWin, st.mode, st.trump) <= 4) return cheapWin;
    // أكلة فاضية وورقتك غالية — وفّرها لو عندك بديل رخيص
    const cheap = legal.filter((c) => !winners.includes(c));
    if (cheap.length && Math.random() < 0.6) return lowestBy(cheap, st);
    return cheapWin;
  }

  // ما تقدر تربح → ارمِ الأرخص
  return lowestBy(legal, st);
}

// ===== قرار الدبل =====
// نفس تقييم قوة اليد المستخدم بالمزايدة: يد قوية بعد الشراء ترفع فرصة الدبل/الرد، والمستوى
// الأعلى أجرأ. البوت ما يحسب يد الخصم أبداً (بس قوته هو، متسق مع بقية سلوك البوتات بالملف).
function handStrength(match, seat) {
  const st = match.state;
  return st.mode === "hokum" ? evalHokum(st.hands[seat], st.trump, st.topCard, false)
    : evalSun(st.hands[seat], st.topCard, false);
}

export function decideDouble(match, seat, level) {
  const isBuyTeam = teamOf(seat) === teamOf(match.state.buyer);
  const score = handStrength(match, seat);
  const base = { beginner: 0.04, amateur: 0.1, skilled: 0.18, pro: 0.28 }[level] || 0.1;
  const strongThresh = isBuyTeam ? 6.4 : 5.4; // المشتري يحتاج يد أقوى عشان يرد (خطر أعلى)
  const chance = score >= strongThresh ? base + 0.35 : base * 0.25;
  return Math.random() < chance;
}
