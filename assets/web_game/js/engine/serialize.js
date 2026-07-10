// ===== المزامنة أونلاين: تحويل الحالة لكائن بسيط والعكس =====
export function serializeMatch(match) {
  const s = match.state;
  return {
    totals: match.totals,
    dealer: match.dealer,
    handsPlayed: match.handsPlayed,
    matchOver: match.matchOver,
    winnerTeam: match.winnerTeam,
    safeMode: match.safeMode,
    state: s ? {
      phase: s.phase, hands: s.hands, topCard: s.topCard, firstPlayer: s.firstPlayer,
      mode: s.mode, trump: s.trump, buyer: s.buyer, ashkal: s.ashkal || false, bidding: s.bidding,
      currentTrick: s.currentTrick, trickHistory: s.trickHistory,
      leader: s.leader, turn: s.turn, countedProjects: s.countedProjects,
      projects: s.projects || [],
      announcedProjects: s.announcedProjects || [],
      balootTeam: s.balootTeam == null ? null : s.balootTeam,
      balootSeat: s.balootSeat == null ? null : s.balootSeat,
      revealedProjects: s.revealedProjects || [], violation: s.violation || null,
      playedCards: s.playedCards, awaitingDeclare: s.awaitingDeclare || false,
      declareSeats: s.declareSeats || [],
      doubleLevel: s.doubleLevel || 1, doubleTeam: s.doubleTeam == null ? null : s.doubleTeam,
      awaitingDouble: s.awaitingDouble || false, doubling: s.doubling || null,
      result: s.result || null,
    } : null,
  };
}

// فايربيس (Realtime Database) ما يخزّن مصفوفات فاضية ([]) — أي مقعد يفضى يده (آخر ورقة
// تُلعب) يختفي مفتاحه كلياً من اللقطة، وأحياناً تتحوّل المصفوفة الخارجية كلها لكائن متفرّق
// {0:..,1:..,3:..} بدل مصفوفة رباعية. لازم نطبّع كل مقعد صراحة وإلا hands[seat] يطلع
// undefined ويكسر أي كود يتوقع مصفوفة (renderHand/sortHand وغيرها).
function normalizeHands(hands) {
  const out = [[], [], [], []];
  if (!hands) return out;
  for (let s = 0; s < 4; s++) out[s] = hands[s] || [];
  return out;
}

// نبني كائن "match" للعرض فقط عند العميل (ما يشغّل المحرك)
export function deserializeMatch(obj) {
  const m = {
    totals: obj.totals || [0, 0], dealer: obj.dealer || 0,
    handsPlayed: obj.handsPlayed || 0, matchOver: !!obj.matchOver,
    winnerTeam: obj.winnerTeam == null ? null : obj.winnerTeam,
    safeMode: !!obj.safeMode, state: null,
  };
  if (obj.state) {
    const s = obj.state;
    m.state = {
      phase: s.phase, hands: normalizeHands(s.hands), topCard: s.topCard,
      firstPlayer: s.firstPlayer, mode: s.mode, trump: s.trump, buyer: s.buyer, ashkal: !!s.ashkal,
      bidding: s.bidding || { round: 1, turn: 0, spoken: 0, best: null },
      currentTrick: s.currentTrick || [], trickHistory: s.trickHistory || [],
      leader: s.leader, turn: s.turn, countedProjects: s.countedProjects || [],
      announcedProjects: s.announcedProjects || [],
      balootTeam: s.balootTeam == null ? null : s.balootTeam,
      balootSeat: s.balootSeat == null ? null : s.balootSeat,
      balootState: null,
      revealedProjects: s.revealedProjects || [], violation: s.violation || null,
      droppedProjects: [], projects: s.projects || [],
      pendingAnnounce: [], pendingReveal: [],
      playedCards: s.playedCards || [],
      awaitingDeclare: !!s.awaitingDeclare, declareSeats: s.declareSeats || [],
      doubleLevel: s.doubleLevel || 1, doubleTeam: s.doubleTeam == null ? null : s.doubleTeam,
      awaitingDouble: !!s.awaitingDouble, doubling: s.doubling || null,
      result: s.result || null,
      voids: [new Set(), new Set(), new Set(), new Set()],
    };
  }
  return m;
}
