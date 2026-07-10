import { BALOOT_QAID } from "./constants.js";
import { teamOf, cardPoints } from "./cards.js";
import { projectQaid } from "./projects.js";

// ===== حساب قيد الصكة الواحدة =====
export function scoreHand(state) {
  const mode = state.mode;
  const buyTeam = teamOf(state.buyer);
  const pts = [0, 0];
  let capotTeam = null;

  const trickWins = [0, 0];
  for (const t of state.trickHistory) {
    trickWins[teamOf(t.winner)]++;
    for (const play of t.plays) pts[teamOf(t.winner)] += cardPoints(play.card, mode, state.trump);
  }
  const lastWinner = state.trickHistory[state.trickHistory.length - 1].winner;
  pts[teamOf(lastWinner)] += 10; // الأرض

  if (trickWins[0] === 8) capotTeam = 0;
  if (trickWins[1] === 8) capotTeam = 1;

  // قيد المشاريع
  const projQaid = [0, 0];
  for (const p of state.countedProjects) projQaid[teamOf(p.seat)] += projectQaid(p, mode);

  // البلوت (شايب+بنت الحكم بالتتابع أثناء اللعب): نقطتان تنضاف لفريق صاحبه،
  // مستقلة عن المشاريع، ولا تخسر أبداً (قطع/كبوت)
  const balootQaid = [0, 0];
  if (state.balootTeam != null) balootQaid[state.balootTeam] = BALOOT_QAID;

  // الدبل يضاعف قيد الصكة كله (نقاط + مشاريع) بس ما يمس البلوت (مستقل دايماً — بند 14)
  const mult = state.doubleLevel || 1;

  let qaid = [0, 0];
  if (capotTeam !== null) {
    // كبوت: قيد ثابت + مشاريع الفريق الكابت، مضاعف بالدبل، وبلوته يبقى فوقه. الخصم ما ياخذ إلا بلوته
    qaid[capotTeam] = ((mode === "hokum" ? 25 : 44) + projQaid[capotTeam]) * mult + balootQaid[capotTeam];
    qaid[1 - capotTeam] = balootQaid[1 - capotTeam];
  } else {
    const div = mode === "hokum" ? 10 : 5;
    const baseTotal = mode === "hokum" ? 16 : 26;
    const nonBuy = 1 - buyTeam;
    const nonBuyQaid = Math.round(pts[nonBuy] / div); // الكسر لصالح الخصم
    const buyQaid = baseTotal - nonBuyQaid;
    qaid[nonBuy] = (nonBuyQaid + projQaid[nonBuy]) * mult + balootQaid[nonBuy];
    qaid[buyTeam] = (buyQaid + projQaid[buyTeam]) * mult + balootQaid[buyTeam];
  }

  // المشتري لازم يجيب أكثر من الخصم وإلا خسران (دخلة/قطع)
  let buyerLost = false;
  if (capotTeam === null && qaid[buyTeam] <= qaid[1 - buyTeam]) {
    buyerLost = true;
  }
  if (capotTeam !== null && capotTeam !== buyTeam) buyerLost = true;

  // الوضع الآمن: فريق اللاعب (0) ما ينقطع — يبقى قيده مثل ما هو
  let safeSaved = false;
  if (buyerLost && capotTeam === null && state.safeMode && buyTeam === 0) {
    buyerLost = false;
    safeSaved = true;
  }

  if (buyerLost && capotTeam === null) {
    // الخصم ياخذ كل القيد (مضاعف أصلاً أعلاه)، والبلوت يبقى لصاحبه
    const total = qaid[0] + qaid[1] - balootQaid[buyTeam];
    qaid[1 - buyTeam] = total;
    qaid[buyTeam] = balootQaid[buyTeam];
  }

  return { qaid, pts, trickWins, capotTeam, buyerLost, safeSaved, projQaid, balootQaid, doubleLevel: mult };
}
