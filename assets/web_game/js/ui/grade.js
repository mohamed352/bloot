// تحليل أداء اللاعب البشري نهاية المباراة — قراءة إحصاءات match.metrics فقط (مقعد اللاعب = mySeat)
import { legalMoves, cardStrength, cardPoints, trickWinnerIdx, teamOf } from "../engine/index.js";

export function trackHumanCard(match, card, mySeat) {
  const st = match.state;
  const trick = st.currentTrick;
  if (!trick.length) return;
  const m = match.metrics;
  const led = trick[0].card.suit;
  const legal = legalMoves(st.hands[mySeat], trick, st.mode, st.trump, mySeat);
  const curBest = Math.max(...trick.map((t) => cardStrength(t.card, led, st.mode, st.trump)));
  const winSeat = trick[trickWinnerIdx(trick, st.mode, st.trump)].seat;
  if (teamOf(winSeat) === teamOf(mySeat)) return; // ما نحلل إلا لما الخصم كان رابح قبل ورقتي

  const myStr = cardStrength(card, led, st.mode, st.trump);
  if (myStr > curBest) return; // ورقتي كسبت — ما فيه خطأ

  const myPts = cardPoints(card, st.mode, st.trump);
  const hasCheap = legal.some((c) => cardPoints(c, st.mode, st.trump) <= 4 && cardStrength(c, led, st.mode, st.trump) <= curBest);
  if (myPts >= 10 && hasCheap) m.pointMistakes++;

  if (trick.length === 3) {
    const trickPts = trick.reduce((s, t) => s + cardPoints(t.card, st.mode, st.trump), 0);
    const couldWin = legal.some((c) => cardStrength(c, led, st.mode, st.trump) > curBest);
    if (couldWin && trickPts >= 10) m.missedWins++;
  }
}

export function trackTrick(match, winner, mySeat) {
  match.metrics.totalTricks++;
  if (teamOf(winner) === teamOf(mySeat)) match.metrics.teamTricks++;
}

export function trackHand(match, result, mySeat) {
  if (match.state.buyer === mySeat) {
    match.metrics.humanBids++;
    if (!result.buyerLost) match.metrics.humanBidWins++;
  }
}

const GRADE_TABLE = [
  [88, "A+", "يا وحش! لعبك يتدرّس 🏆"],
  [78, "A", "بروفيشنل صدق، ما شاء الله 👑"],
  [68, "B+", "لعب قوي وثابت، عاش 👏"],
  [58, "B", "لعبك زين وباقي لك شوي"],
  [50, "C+", "ماشي الحال — ركّز بالشراء"],
  [42, "C", "راجع حساباتك شوي 🤔"],
  [32, "D", "يومك مو يومك 😅 عيدها"],
  [-1, "F", "خويك بيعتذر عن الصكة الجاية 😂"],
];

export function computeGrade(match, mySeat) {
  const m = match.metrics || {
    humanBids: 0, humanBidWins: 0,
    teamTricks: 0, totalTricks: 0,
    pointMistakes: 0, missedWins: 0,
  };
  const myTeam = teamOf(mySeat);
  const total = match.totals[0] + match.totals[1];
  const qaidShare = total ? match.totals[myTeam] / total : 0.5;
  const trickShare = m.totalTricks ? m.teamTricks / m.totalTricks : 0.5;
  const bidRate = m.humanBids ? m.humanBidWins / m.humanBids : null;
  const mistakes = m.pointMistakes + m.missedWins;

  let score = qaidShare * 60 + trickShare * 20;
  score += bidRate !== null ? bidRate * 12 : 7;
  score += Math.max(0, 8 - mistakes * 2);

  const row = GRADE_TABLE.find(([min]) => score >= min);
  return { grade: row[1], comment: row[2], score, qaidShare, trickShare, bidRate, mistakes };
}

export function getStats() {
  try { return JSON.parse(localStorage.getItem("baloot-stats") || '{"matches":[]}'); }
  catch { return { matches: [] }; }
}

export function saveMatchStats(match, safeMode, mySeat) {
  const g = computeGrade(match, mySeat);
  const myTeam = teamOf(mySeat);
  const s = getStats();
  s.matches.push({
    date: new Date().toISOString().slice(0, 10),
    win: match.winnerTeam === myTeam,
    my: match.totals[myTeam], opp: match.totals[1 - myTeam],
    grade: g.grade, mode: safeMode ? "safe" : "normal",
  });
  if (s.matches.length > 100) s.matches = s.matches.slice(-100);
  localStorage.setItem("baloot-stats", JSON.stringify(s));
  return s;
}
