import { HOKUM_TRUMP_ORDER } from "./constants.js";
import { teamOf, trickWinnerIdx } from "./cards.js";

/**
 * الأوراق المسموح لعبها.
 * strict=true (دبل نازل بمستوى ≥2): يلغي استثناء "خويك رابح → حر" — القص/التسييد
 * واجب حتى لو خويك رابح بالأكلة.
 */
export function legalMoves(hand, trick, mode, trump, mySeat, strict) {
  if (trick.length === 0) return hand.slice();
  const led = trick[0].card.suit;
  const follow = hand.filter((c) => c.suit === led);

  if (mode === "sun") return follow.length ? follow : hand.slice();

  // حكم
  if (follow.length) {
    if (led === trump) {
      // التسييد واجب: لازم تلعب حكم أعلى إن قدرت
      const bestTrump = Math.max(...trick.filter((t) => t.card.suit === trump)
        .map((t) => HOKUM_TRUMP_ORDER.indexOf(t.card.rank)));
      const higher = follow.filter((c) => HOKUM_TRUMP_ORDER.indexOf(c.rank) > bestTrump);
      return higher.length ? higher : follow;
    }
    return follow;
  }

  // ما عندك اللون
  const winIdx = trickWinnerIdx(trick, mode, trump);
  const winnerSeat = trick[winIdx].seat;
  if (!strict && teamOf(winnerSeat) === teamOf(mySeat)) return hand.slice(); // خويك رابح → حر (إلا بالدبل)

  const trumps = hand.filter((c) => c.suit === trump);
  if (!trumps.length) return hand.slice();

  const trumpedInTrick = trick.filter((t) => t.card.suit === trump);
  if (trumpedInTrick.length) {
    const bestTrump = Math.max(...trumpedInTrick.map((t) => HOKUM_TRUMP_ORDER.indexOf(t.card.rank)));
    const higher = trumps.filter((c) => HOKUM_TRUMP_ORDER.indexOf(c.rank) > bestTrump);
    return higher.length ? higher : hand.slice(); // ما تقدر تسيّد → حر
  }
  return trumps; // القص واجب
}

/**
 * البوابة الوحيدة لصحة أي حركة لعب — تُستخدم من المحرك (match.js)، أونلاين، والبوتات،
 * فيستحيل أن تُطبَّق حركة غير قانونية بأي مسار. ترجع سبب الرفض لو الحركة غير قانونية.
 */
export function validateMove(hand, trick, mode, trump, mySeat, card, strict) {
  const legal = legalMoves(hand, trick, mode, trump, mySeat, strict);
  const ok = legal.some((c) => c.suit === card.suit && c.rank === card.rank);
  return { ok, legalMoves: legal };
}

// تصنيف نوع المخالفة (لأنواع القيد): وش القاعدة اللي انكسرت بهاللعبة غير القانونية؟
// - qatee (قيد قاطع، صن وحكم): عنده لون السوق ورمى لون ثاني
// - makabr (ما كبر بحكم): السوق حكم (أو فيه قص) وعنده أعلى وما سيّد
// - madaq (ما دق بحكم): ما عنده اللون والخصم رابح وعنده حكم وما قص
// - rubu (ربع في الدبل): بالدبل النازل (مستوى ≥2)، خويك رابح بس ما قصيت/سيّدت مع إنك تقدر
//   (بدون الدبل هالحالة كانت قانونية تماماً — الدبل هو اللي يوجب الالتزام)
export const VIOLATION_NAMES = { qatee: "قيد قاطع", makabr: "ما كبر بحكم", madaq: "ما دق بحكم", sawa: "سوا خاطئ", rubu: "ربع في الدبل" };

export function classifyViolation(hand, trick, mode, trump, card, seat, doubleLevel) {
  const led = trick.length ? trick[0].card.suit : null;
  if (led === null) return "qatee"; // ما يصير عملياً — القائد دايم حر
  const hasLed = hand.some((c) => c.suit === led);
  if (hasLed && card.suit !== led) return "qatee";
  if (mode === "hokum") {
    if (!hasLed && (doubleLevel || 1) >= 2) {
      const winIdx = trickWinnerIdx(trick, mode, trump);
      const winnerSeat = trick[winIdx].seat;
      if (teamOf(winnerSeat) === teamOf(seat)) return "rubu";
    }
    // لعب من لون السوق وهو حكم بس ما سيّد، أو قص بحكم أدنى وهو يملك أعلى
    if (card.suit === trump) return "makabr";
    // ما عنده اللون وعنده حكم وما قص (والخصم رابح — وإلا كانت قانونية أصلاً)
    if (!hasLed && hand.some((c) => c.suit === trump)) return "madaq";
  }
  return "qatee";
}
