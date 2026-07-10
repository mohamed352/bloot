import { SUN_ORDER, HOKUM_TRUMP_ORDER, SUN_PTS, HOKUM_TRUMP_PTS, HOKUM_PLAIN_PTS } from "./constants.js";

export function teamOf(seat) { return seat % 2; } // مقاعد 0و2 فريق، 1و3 فريق

/** قوة ورقة داخل أكلة (للمقارنة بين الأوراق الملعوبة، وليست ترتيب مطلق) */
export function cardStrength(card, ledSuit, mode, trump) {
  if (mode === "hokum" && card.suit === trump) {
    return 100 + HOKUM_TRUMP_ORDER.indexOf(card.rank);
  }
  if (card.suit !== ledSuit) return -1;
  return SUN_ORDER.indexOf(card.rank);
}

export function cardPoints(card, mode, trump) {
  if (mode === "hokum") {
    return card.suit === trump ? HOKUM_TRUMP_PTS[card.rank] : HOKUM_PLAIN_PTS[card.rank];
  }
  return SUN_PTS[card.rank];
}

/** فهرس الرابح داخل مصفوفة الأكلة (0..3 نسبةً لترتيب اللعب، وليس رقم المقعد) */
export function trickWinnerIdx(trick, mode, trump) {
  const led = trick[0].card.suit;
  let best = 0;
  for (let i = 1; i < trick.length; i++) {
    if (cardStrength(trick[i].card, led, mode, trump) > cardStrength(trick[best].card, led, mode, trump)) best = i;
  }
  return best;
}
