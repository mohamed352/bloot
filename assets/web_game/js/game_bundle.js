(() => {
  var __defProp = Object.defineProperty;
  var __export = (target, all) => {
    for (var name in all)
      __defProp(target, name, { get: all[name], enumerable: true });
  };

  // js/engine/index.js
  var engine_exports = {};
  __export(engine_exports, {
    BALOOT_QAID: () => BALOOT_QAID,
    HOKUM_PLAIN_PTS: () => HOKUM_PLAIN_PTS,
    HOKUM_TRUMP_ORDER: () => HOKUM_TRUMP_ORDER,
    HOKUM_TRUMP_PTS: () => HOKUM_TRUMP_PTS,
    NATURAL: () => NATURAL,
    PROJECT_NAMES: () => PROJECT_NAMES,
    PROJECT_QAID: () => PROJECT_QAID,
    RANKS: () => RANKS,
    SUITS: () => SUITS,
    SUN_ORDER: () => SUN_ORDER,
    SUN_PTS: () => SUN_PTS,
    TARGET_QAID: () => TARGET_QAID,
    VIOLATION_NAMES: () => VIOLATION_NAMES,
    applyBid: () => applyBid,
    applyDouble: () => applyDouble,
    cardKey: () => cardKey,
    cardPoints: () => cardPoints,
    cardStrength: () => cardStrength,
    checkMatchEnd: () => checkMatchEnd,
    claimQaid: () => claimQaid,
    claimSawa: () => claimSawa,
    classifyViolation: () => classifyViolation,
    createMatch: () => createMatch,
    declareProject: () => declareProject,
    deserializeMatch: () => deserializeMatch,
    finalizeBid: () => finalizeBid,
    finalizeProjects: () => finalizeProjects,
    findProjects: () => findProjects,
    finishClaimedHand: () => finishClaimedHand,
    legalMoves: () => legalMoves,
    makeDeck: () => makeDeck,
    nextHand: () => nextHand,
    playCard: () => playCard,
    projectQaid: () => projectQaid,
    projectTypesFor: () => projectTypesFor,
    resolveProjects: () => resolveProjects,
    sameCard: () => sameCard,
    sawaGuaranteed: () => sawaGuaranteed,
    scoreHand: () => scoreHand,
    seededRng: () => seededRng,
    serializeMatch: () => serializeMatch,
    shuffle: () => shuffle,
    startHand: () => startHand,
    teamOf: () => teamOf,
    trickWinnerIdx: () => trickWinnerIdx,
    validateMove: () => validateMove
  });

  // js/engine/constants.js
  var SUITS = ["♠", "♥", "♦", "♣"];
  var RANKS = ["7", "8", "9", "10", "J", "Q", "K", "A"];
  var NATURAL = ["7", "8", "9", "10", "J", "Q", "K", "A"];
  var SUN_ORDER = ["7", "8", "9", "J", "Q", "K", "10", "A"];
  var HOKUM_TRUMP_ORDER = ["7", "8", "Q", "K", "10", "A", "9", "J"];
  var SUN_PTS = { A: 11, "10": 10, K: 4, Q: 3, J: 2, "9": 0, "8": 0, "7": 0 };
  var HOKUM_TRUMP_PTS = { J: 20, "9": 14, A: 11, "10": 10, K: 4, Q: 3, "8": 0, "7": 0 };
  var HOKUM_PLAIN_PTS = SUN_PTS;
  var PROJECT_QAID = {
    hokum: { sira: 4, fifty: 10, hundred: 20, fourAces: 20 },
    sun: { sira: 4, fifty: 10, hundred: 20, fourAces: 40 }
  };
  var PROJECT_NAMES = { sira: "سرا", fifty: "خمسين", hundred: "مية", fourAces: "أربعمية" };
  var BALOOT_QAID = 2;
  var TARGET_QAID = 152;

  // js/engine/rng.js
  function seededRng(seed) {
    let a = seed >>> 0 || 1;
    return function rng() {
      a |= 0;
      a = a + 1831565813 | 0;
      let t = Math.imul(a ^ a >>> 15, 1 | a);
      t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t;
      return ((t ^ t >>> 14) >>> 0) / 4294967296;
    };
  }
  function shuffle(arr, rng) {
    const a = arr.slice();
    for (let i = a.length - 1; i > 0; i--) {
      const j = Math.floor((rng ? rng() : Math.random()) * (i + 1));
      [a[i], a[j]] = [a[j], a[i]];
    }
    return a;
  }

  // js/engine/deck.js
  function makeDeck() {
    const deck = [];
    for (const s of SUITS) for (const r of RANKS) deck.push({ suit: s, rank: r });
    return deck;
  }
  function cardKey(c) {
    return c.rank + c.suit;
  }
  function sameCard(a, b) {
    return a.suit === b.suit && a.rank === b.rank;
  }

  // js/engine/cards.js
  function teamOf(seat) {
    return seat % 2;
  }
  function cardStrength(card, ledSuit, mode, trump) {
    if (mode === "hokum" && card.suit === trump) {
      return 100 + HOKUM_TRUMP_ORDER.indexOf(card.rank);
    }
    if (card.suit !== ledSuit) return -1;
    return SUN_ORDER.indexOf(card.rank);
  }
  function cardPoints(card, mode, trump) {
    if (mode === "hokum") {
      return card.suit === trump ? HOKUM_TRUMP_PTS[card.rank] : HOKUM_PLAIN_PTS[card.rank];
    }
    return SUN_PTS[card.rank];
  }
  function trickWinnerIdx(trick, mode, trump) {
    const led = trick[0].card.suit;
    let best = 0;
    for (let i = 1; i < trick.length; i++) {
      if (cardStrength(trick[i].card, led, mode, trump) > cardStrength(trick[best].card, led, mode, trump)) best = i;
    }
    return best;
  }

  // js/engine/rules.js
  function legalMoves(hand, trick, mode, trump, mySeat, strict) {
    if (trick.length === 0) return hand.slice();
    const led = trick[0].card.suit;
    const follow = hand.filter((c) => c.suit === led);
    if (mode === "sun") return follow.length ? follow : hand.slice();
    if (follow.length) {
      if (led === trump) {
        const bestTrump = Math.max(...trick.filter((t) => t.card.suit === trump).map((t) => HOKUM_TRUMP_ORDER.indexOf(t.card.rank)));
        const higher = follow.filter((c) => HOKUM_TRUMP_ORDER.indexOf(c.rank) > bestTrump);
        return higher.length ? higher : follow;
      }
      return follow;
    }
    const winIdx = trickWinnerIdx(trick, mode, trump);
    const winnerSeat = trick[winIdx].seat;
    if (!strict && teamOf(winnerSeat) === teamOf(mySeat)) return hand.slice();
    const trumps = hand.filter((c) => c.suit === trump);
    if (!trumps.length) return hand.slice();
    const trumpedInTrick = trick.filter((t) => t.card.suit === trump);
    if (trumpedInTrick.length) {
      const bestTrump = Math.max(...trumpedInTrick.map((t) => HOKUM_TRUMP_ORDER.indexOf(t.card.rank)));
      const higher = trumps.filter((c) => HOKUM_TRUMP_ORDER.indexOf(c.rank) > bestTrump);
      return higher.length ? higher : hand.slice();
    }
    return trumps;
  }
  function validateMove(hand, trick, mode, trump, mySeat, card, strict) {
    const legal = legalMoves(hand, trick, mode, trump, mySeat, strict);
    const ok = legal.some((c) => c.suit === card.suit && c.rank === card.rank);
    return { ok, legalMoves: legal };
  }
  var VIOLATION_NAMES = { qatee: "قيد قاطع", makabr: "ما كبر بحكم", madaq: "ما دق بحكم", sawa: "سوا خاطئ", rubu: "ربع في الدبل" };
  function classifyViolation(hand, trick, mode, trump, card, seat, doubleLevel) {
    const led = trick.length ? trick[0].card.suit : null;
    if (led === null) return "qatee";
    const hasLed = hand.some((c) => c.suit === led);
    if (hasLed && card.suit !== led) return "qatee";
    if (mode === "hokum") {
      if (!hasLed && (doubleLevel || 1) >= 2) {
        const winIdx = trickWinnerIdx(trick, mode, trump);
        const winnerSeat = trick[winIdx].seat;
        if (teamOf(winnerSeat) === teamOf(seat)) return "rubu";
      }
      if (card.suit === trump) return "makabr";
      if (!hasLed && hand.some((c) => c.suit === trump)) return "madaq";
    }
    return "qatee";
  }

  // js/engine/projects.js
  function findProjects(hand, mode, trump) {
    const projects = [];
    const used = /* @__PURE__ */ new Set();
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
    for (const suit of SUITS) {
      const idxs = hand.filter((c) => c.suit === suit && !used.has(cardKey(c))).map((c) => NATURAL.indexOf(c.rank)).sort((a, b) => a - b);
      let run = [];
      const flush = () => {
        while (run.length >= 3) {
          let take;
          if (run.length >= 5) take = 5;
          else take = run.length;
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
        else {
          flush();
          run = [idxs[k]];
        }
      }
      flush();
    }
    return projects;
  }
  function projectQaid(p, mode) {
    return PROJECT_QAID[mode][p.type];
  }
  function projectTypesFor(mode) {
    const types = ["sira", "fifty", "hundred", "fourAces"];
    return types.map((t) => ({ type: t, name: PROJECT_NAMES[t], qaid: PROJECT_QAID[mode][t] }));
  }
  function resolveProjects(allProjects, mode, firstPlayer) {
    const comparable = allProjects;
    if (!comparable.length) return { counted: [], dropped: [] };
    function power(p) {
      const q = projectQaid(p, mode);
      const top = Math.max(...p.cards.map((c) => NATURAL.indexOf(c.rank)));
      const orderBonus = (4 + p.seat - firstPlayer) % 4;
      return q * 1e4 + top * 100 + (3 - orderBonus);
    }
    let best = comparable[0];
    for (const p of comparable) if (power(p) > power(best)) best = p;
    const winTeam = teamOf(best.seat);
    const counted = comparable.filter((p) => teamOf(p.seat) === winTeam);
    const dropped = comparable.filter((p) => teamOf(p.seat) !== winTeam);
    return { counted, dropped };
  }

  // js/engine/scoring.js
  function scoreHand(state) {
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
    pts[teamOf(lastWinner)] += 10;
    if (trickWins[0] === 8) capotTeam = 0;
    if (trickWins[1] === 8) capotTeam = 1;
    const projQaid = [0, 0];
    for (const p of state.countedProjects) projQaid[teamOf(p.seat)] += projectQaid(p, mode);
    const balootQaid = [0, 0];
    if (state.balootTeam != null) balootQaid[state.balootTeam] = BALOOT_QAID;
    const mult = state.doubleLevel || 1;
    let qaid = [0, 0];
    if (capotTeam !== null) {
      qaid[capotTeam] = ((mode === "hokum" ? 25 : 44) + projQaid[capotTeam]) * mult + balootQaid[capotTeam];
      qaid[1 - capotTeam] = balootQaid[1 - capotTeam];
    } else {
      const div = mode === "hokum" ? 10 : 5;
      const baseTotal = mode === "hokum" ? 16 : 26;
      const nonBuy = 1 - buyTeam;
      const nonBuyQaid = Math.round(pts[nonBuy] / div);
      const buyQaid = baseTotal - nonBuyQaid;
      qaid[nonBuy] = (nonBuyQaid + projQaid[nonBuy]) * mult + balootQaid[nonBuy];
      qaid[buyTeam] = (buyQaid + projQaid[buyTeam]) * mult + balootQaid[buyTeam];
    }
    let buyerLost = false;
    if (capotTeam === null && qaid[buyTeam] <= qaid[1 - buyTeam]) {
      buyerLost = true;
    }
    if (capotTeam !== null && capotTeam !== buyTeam) buyerLost = true;
    let safeSaved = false;
    if (buyerLost && capotTeam === null && state.safeMode && buyTeam === 0) {
      buyerLost = false;
      safeSaved = true;
    }
    if (buyerLost && capotTeam === null) {
      const total = qaid[0] + qaid[1] - balootQaid[buyTeam];
      qaid[1 - buyTeam] = total;
      qaid[buyTeam] = balootQaid[buyTeam];
    }
    return { qaid, pts, trickWins, capotTeam, buyerLost, safeSaved, projQaid, balootQaid, doubleLevel: mult };
  }

  // js/engine/match.js
  function createMatch(opts) {
    return {
      players: opts.players,
      // [{name, isBot, level}] — 4
      safeMode: !!opts.safeMode,
      // آمن: فريق اللاعب ما ينقطع
      autoDeclare: !!opts.autoDeclare,
      // أونلاين: نعلن المشاريع تلقائياً
      totals: [0, 0],
      dealer: opts.dealer != null ? opts.dealer : Math.floor((opts.rng ? opts.rng() : Math.random()) * 4),
      handsPlayed: 0,
      handResults: [],
      metrics: {
        // لتحليل الأداء
        humanBids: 0,
        humanBidWins: 0,
        teamTricks: 0,
        totalTricks: 0,
        pointMistakes: 0,
        missedWins: 0
      },
      state: null,
      matchOver: false,
      winnerTeam: null
    };
  }
  function startHand(match, rng) {
    const deck = shuffle(makeDeck(), rng);
    const hands = [[], [], [], []];
    const firstPlayer = match.dealer;
    let di = 0;
    for (let round = 0; round < 5; round++) {
      for (let p = 0; p < 4; p++) hands[(firstPlayer + p) % 4].push(deck[di++]);
    }
    const topCard = deck[di++];
    const rest = deck.slice(di);
    match.state = {
      phase: "bidding",
      safeMode: match.safeMode,
      hands,
      topCard,
      rest,
      firstPlayer,
      mode: null,
      trump: null,
      buyer: null,
      ashkal: false,
      bidding: { round: 1, turn: firstPlayer, spoken: 0, best: null },
      currentTrick: [],
      trickHistory: [],
      leader: firstPlayer,
      turn: firstPlayer,
      projects: [],
      countedProjects: [],
      droppedProjects: [],
      // مرحلتان: الإعلان (الاسم فقط) مع لعبة صاحبه بالأكلة الأولى، والكشف (نزول الورق)
      // مع لعبته بالأكلة الثانية. المعلَن يشمل كل المشاريع المصرّح بها (حتى اللي بتخسر
      // المقارنة)، والمكشوف بس مشاريع الفريق الرابح بالمقارنة (countedProjects).
      pendingAnnounce: [],
      pendingReveal: [],
      announcedProjects: [],
      revealedProjects: [],
      // البلوت (حكم فقط): يتحقق أثناء اللعب — شايب+بنت الحكم بلعبتي اللاعب المتتاليتين
      balootState: null,
      // {seat, rank, trickIndex} أول ورقة من الثنائي
      balootTeam: null,
      balootSeat: null,
      awaitingDeclare: false,
      declareSeats: [],
      declarations: {},
      // الدبل: 1=عادي، 2=دبل، 3=تربل، 4=كوت. يُفتح باب المزايدة بعد حسم الشراء (finalizeBid)
      // ويُغلق بأول تمرير أو الوصول للكوت. awaitingDouble يمنع اللعب لحد ما ينحسم (متل awaitingDeclare).
      doubleLevel: 1,
      doubleTeam: null,
      awaitingDouble: false,
      doubling: null,
      violation: null,
      // قطع مكشوف حالياً وقابل للتقييد (تأكد لعب غير قانوني بدليل علني)
      pendingViolations: [],
      // قطوع صارت بس ما انكشفت بعد — ما تنكشف إلا لو نفس اللاعب رجع لعب ورقة كانت لازمة
      voids: [/* @__PURE__ */ new Set(), /* @__PURE__ */ new Set(), /* @__PURE__ */ new Set(), /* @__PURE__ */ new Set()],
      // ألوان مقطوعة معروفة
      playedCards: []
    };
    return match.state;
  }
  function finalizeProjects(match, declarations) {
    const st = match.state;
    const kept = [];
    for (let p = 0; p < 4; p++) {
      const seatProjs = st.projects.filter((pr) => pr.seat === p);
      if (match.players[p].isBot || !(p in declarations)) {
        kept.push(...seatProjs);
      } else {
        const claimed = declarations[p] || [];
        kept.push(...seatProjs.filter((pr) => claimed.includes(pr.type)));
      }
    }
    const res = resolveProjects(kept, st.mode, st.firstPlayer);
    st.countedProjects = res.counted;
    st.droppedProjects = res.dropped;
    st.awaitingDeclare = false;
    st.declareSeats = [];
    st.announcedProjects = [];
    st.revealedProjects = [];
    st.pendingAnnounce = kept.map((p) => ({ seat: p.seat, name: PROJECT_NAMES[p.type], type: p.type }));
    st.pendingReveal = st.countedProjects.map((p) => ({
      seat: p.seat,
      name: PROJECT_NAMES[p.type],
      qaid: projectQaid(p, st.mode),
      cards: p.cards
    }));
  }
  function declareProject(match, seat, claimedTypes) {
    const st = match.state;
    if (!st.awaitingDeclare || !(st.declareSeats || []).includes(seat)) throw new Error("مو وقت الإعلان");
    st.declarations[seat] = claimedTypes || [];
    st.declareSeats = st.declareSeats.filter((s) => s !== seat);
    if (st.declareSeats.length === 0) finalizeProjects(match, st.declarations);
    return [];
  }
  function sawaGuaranteed(state, claimSeat) {
    const mode = state.mode, trump = state.trump;
    const team = teamOf(claimSeat);
    const hands = state.hands.map((h) => h.slice());
    function teamWinsAll(hands2, leader) {
      if (hands2.every((h) => h.length === 0)) return true;
      return trickOutcome(hands2, leader, []);
    }
    function trickOutcome(hands2, leader, trick) {
      if (trick.length === 4) {
        const w = trick[trickWinnerIdx(trick, mode, trump)].seat;
        if (teamOf(w) !== team) return false;
        return teamWinsAll(hands2, w);
      }
      const seat = trick.length ? (trick[trick.length - 1].seat + 1) % 4 : leader;
      const legal = legalMoves(hands2[seat], trick, mode, trump, seat);
      const mine = teamOf(seat) === team;
      for (const c of legal) {
        const nh = hands2.map((h, i) => i === seat ? h.filter((x) => !sameCard(x, c)) : h);
        const ok = trickOutcome(nh, leader, trick.concat([{ seat, card: c }]));
        if (mine && ok) return true;
        if (!mine && !ok) return false;
      }
      return !mine;
    }
    return teamWinsAll(hands, claimSeat);
  }
  function claimSawa(match, seat) {
    const st = match.state;
    if (st.phase !== "playing") throw new Error("مو وقت السوا");
    if (st.turn !== seat || st.currentTrick.length) throw new Error("السوا بس لما تكون قائد الأكلة");
    const remaining = 8 - st.trickHistory.length;
    if (remaining > 4) throw new Error("السوا بس بآخر 4 أكلات");
    const valid = sawaGuaranteed(st, seat);
    const revealHands = valid ? st.hands.map((h) => h.slice()) : null;
    const events = [{ type: "sawaClaimed", seat, valid, remaining, hands: revealHands }];
    if (valid) {
      while (st.hands.some((h) => h.length)) {
        const plays = [];
        for (let p = 0; p < 4; p++) {
          const s = (seat + p) % 4;
          if (st.hands[s].length) {
            const c = st.hands[s].shift();
            plays.push({ seat: s, card: c });
            st.playedCards.push(c);
          }
        }
        st.trickHistory.push({ plays, winner: seat, pts: plays.reduce((t, x) => t + cardPoints(x.card, st.mode, st.trump), 0) });
      }
      st.currentTrick = [];
      const result = scoreHand(st);
      result.sawa = { seat, valid: true, hands: revealHands };
      match.totals[0] += result.qaid[0];
      match.totals[1] += result.qaid[1];
      match.handResults.push({ mode: st.mode, trump: st.trump, buyer: st.buyer, qaid: result.qaid, buyerLost: result.buyerLost, capotTeam: result.capotTeam, sawa: true });
      match.handsPlayed++;
      st.phase = "handEnd";
      st.result = result;
      events.push({ type: "handEnd", result });
    } else {
      finishClaimedHand(match, events, {
        winTeam: 1 - teamOf(seat),
        loseTeam: teamOf(seat),
        qatClaim: { type: "sawa", typeName: VIOLATION_NAMES.sawa, failed: true, claimSeat: seat, violSeat: seat }
      });
    }
    checkMatchEnd(match, events);
    return events;
  }
  function finishClaimedHand(match, events, info) {
    const st = match.state;
    const balootQaid = [0, 0];
    if (st.balootTeam != null) balootQaid[st.balootTeam] = BALOOT_QAID;
    const mult = st.doubleLevel || 1;
    const qaid = [0, 0];
    qaid[info.winTeam] = (st.mode === "hokum" ? 25 : 44) * mult + balootQaid[info.winTeam];
    qaid[info.loseTeam] = balootQaid[info.loseTeam];
    match.totals[0] += qaid[0];
    match.totals[1] += qaid[1];
    match.handResults.push({ mode: st.mode, trump: st.trump, buyer: st.buyer, qaid, buyerLost: true, capotTeam: null, qatClaim: true });
    match.handsPlayed++;
    const result = {
      qaid,
      pts: [0, 0],
      trickWins: [0, 0],
      capotTeam: null,
      buyerLost: true,
      safeSaved: false,
      projQaid: [0, 0],
      balootQaid,
      qatClaim: info.qatClaim,
      doubleLevel: mult
    };
    st.phase = "handEnd";
    st.result = result;
    st.violation = null;
    events.push({ type: "handEnd", result });
  }
  function checkMatchEnd(match, events) {
    if (match.totals[0] >= TARGET_QAID || match.totals[1] >= TARGET_QAID) {
      if (match.totals[0] !== match.totals[1]) {
        match.matchOver = true;
        match.winnerTeam = match.totals[0] > match.totals[1] ? 0 : 1;
        match.state.phase = "matchEnd";
        events.push({ type: "matchEnd", winnerTeam: match.winnerTeam });
      }
    }
  }
  function playCard(match, seat, card) {
    const st = match.state;
    if (st.phase !== "playing" || st.turn !== seat) throw new Error("مو دورك");
    const hand = st.hands[seat];
    const idx = hand.findIndex((c) => sameCard(c, card));
    if (idx === -1) throw new Error("الورقة مو عندك");
    const strict = (st.doubleLevel || 1) >= 2;
    const legal = legalMoves(hand, st.currentTrick, st.mode, st.trump, seat, strict);
    const isLegal = legal.some((c) => sameCard(c, card));
    if (!isLegal) {
      if (match.safeMode) throw new Error("حركة غير قانونية");
      st.pendingViolations.push({
        seat,
        card: { suit: card.suit, rank: card.rank },
        trickIndex: st.trickHistory.length,
        vtype: classifyViolation(hand, st.currentTrick, st.mode, st.trump, card, seat, st.doubleLevel),
        escaped: legal.map((c) => ({ suit: c.suit, rank: c.rank }))
      });
    }
    if (st.currentTrick.length) {
      const led = st.currentTrick[0].card.suit;
      if (card.suit !== led) st.voids[seat].add(led);
    }
    hand.splice(idx, 1);
    st.currentTrick.push({ seat, card });
    st.playedCards.push(card);
    const events = [{ type: "played", seat, card, lead: st.currentTrick.length === 1 }];
    if (st.mode === "hokum" && card.suit === st.trump && (card.rank === "K" || card.rank === "Q")) {
      const bs = st.balootState;
      const curTrick = st.trickHistory.length;
      if (bs && bs.seat === seat && bs.rank !== card.rank && curTrick === bs.trickIndex + 1 && st.balootTeam == null) {
        st.balootTeam = teamOf(seat);
        st.balootSeat = seat;
        st.balootState = null;
        events.push({ type: "baloot", seat });
      } else {
        st.balootState = { seat, rank: card.rank, trickIndex: curTrick };
      }
    }
    for (const pv of st.pendingViolations) {
      if (pv.confirmed || pv.seat !== seat) continue;
      if (pv.escaped.some((e) => sameCard(e, card))) {
        pv.confirmed = true;
        st.violation = { seat: pv.seat, card: pv.card, trickIndex: pv.trickIndex, vtype: pv.vtype || "qatee", provedBy: { suit: card.suit, rank: card.rank } };
        events.push({ type: "violationRevealed", seat: pv.seat, card: pv.card, trickIndex: pv.trickIndex, provedBy: card });
      }
    }
    if (st.trickHistory.length === 0 && st.pendingAnnounce.length) {
      const mine = st.pendingAnnounce.filter((p) => p.seat === seat);
      if (mine.length) {
        st.pendingAnnounce = st.pendingAnnounce.filter((p) => p.seat !== seat);
        const stamped = mine.map((m) => ({ seat: m.seat, name: m.name, type: m.type, at: Date.now() }));
        st.announcedProjects.push(...stamped);
        events.push({ type: "projectAnnounce", seat, names: mine.map((m) => m.name) });
      }
    }
    if (st.trickHistory.length === 1 && st.pendingReveal.length) {
      const mine = st.pendingReveal.filter((p) => p.seat === seat);
      if (mine.length) {
        st.pendingReveal = st.pendingReveal.filter((p) => p.seat !== seat);
        const stamped = mine.map((m) => Object.assign({ at: Date.now() }, m));
        st.revealedProjects.push(...stamped);
        for (const p of mine) {
          const restCards = p.cards.filter((c) => !sameCard(c, card));
          events.push({ type: "projectReveal", seat: p.seat, name: p.name, qaid: p.qaid, cards: p.cards, restCards });
        }
      }
    }
    if (st.currentTrick.length === 4) {
      const wIdx = trickWinnerIdx(st.currentTrick, st.mode, st.trump);
      const winner = st.currentTrick[wIdx].seat;
      const trickPts = st.currentTrick.reduce((s, t) => s + cardPoints(t.card, st.mode, st.trump), 0);
      st.trickHistory.push({ plays: st.currentTrick.slice(), winner, pts: trickPts });
      const finishedPlays = st.trickHistory[st.trickHistory.length - 1].plays;
      st.currentTrick = [];
      st.leader = winner;
      st.turn = winner;
      st.violation = null;
      events.push({ type: "trickEnd", winner, pts: trickPts, plays: finishedPlays });
      if (st.trickHistory.length === 8) {
        const result = scoreHand(match.state);
        match.totals[0] += result.qaid[0];
        match.totals[1] += result.qaid[1];
        match.handResults.push({
          mode: st.mode,
          trump: st.trump,
          buyer: st.buyer,
          qaid: result.qaid,
          buyerLost: result.buyerLost,
          capotTeam: result.capotTeam
        });
        match.handsPlayed++;
        st.phase = "handEnd";
        st.result = result;
        events.push({ type: "handEnd", result });
        checkMatchEnd(match, events);
      }
    } else {
      st.turn = (st.turn + 1) % 4;
    }
    return events;
  }
  function claimQaid(match, claimingSeat, claimType) {
    const st = match.state;
    if (st.phase !== "playing") throw new Error("مو وقت القيد");
    const claimTeam = teamOf(claimingSeat);
    const v = st.violation;
    const correct = !!v && teamOf(v.seat) !== claimTeam && (!claimType || claimType === v.vtype);
    const events = [];
    if (correct) {
      finishClaimedHand(match, events, {
        winTeam: claimTeam,
        loseTeam: teamOf(v.seat),
        qatClaim: {
          type: v.vtype,
          typeName: VIOLATION_NAMES[v.vtype] || "قيد",
          failed: false,
          claimSeat: claimingSeat,
          violSeat: v.seat,
          winTeam: claimTeam,
          violCard: v.card,
          trickIndex: v.trickIndex,
          provedBy: v.provedBy
        }
      });
    } else {
      finishClaimedHand(match, events, {
        winTeam: 1 - claimTeam,
        loseTeam: claimTeam,
        qatClaim: {
          type: claimType || "qatee",
          typeName: VIOLATION_NAMES[claimType] || "قيد",
          failed: true,
          claimSeat: claimingSeat,
          violSeat: claimingSeat,
          winTeam: 1 - claimTeam
        }
      });
    }
    const qc = st.result.qatClaim;
    events.unshift({ type: "qatClaimed", seat: claimingSeat, violSeat: qc.violSeat, failed: qc.failed, typeName: qc.typeName });
    checkMatchEnd(match, events);
    return events;
  }
  function nextHand(match, rng) {
    match.dealer = (match.dealer + 1) % 4;
    return startHand(match, rng);
  }

  // js/engine/bidding.js
  function applyBid(match, seat, action, rng) {
    const st = match.state;
    const b = st.bidding;
    if (seat !== b.turn) throw new Error("مو دورك بعد");
    const events = [];
    if (action.type === "sun") {
      b.best = { type: "sun", seat };
      events.push({ type: "bid", seat, say: "صن" });
      finalizeBid(match, events);
      return events;
    }
    if (action.type === "ashkal") {
      if (b.round !== 1) throw new Error("الأشكل بس بالجولة الأولى");
      const ashkalEligible = (match.dealer + 3) % 4;
      if (seat !== match.dealer && seat !== ashkalEligible) throw new Error("الأشكل بس للموزع أو اللي قبله بالدور");
      b.best = { type: "ashkal", seat };
      events.push({ type: "bid", seat, say: "أشكل" });
      finalizeBid(match, events);
      return events;
    }
    if (action.type === "hokum") {
      const suit = b.round === 1 ? st.topCard.suit : action.suit;
      if (b.round === 2 && suit === st.topCard.suit) throw new Error("حكم ثاني لازم لون غير المكشوف");
      if (!b.best) b.best = { type: "hokum", seat, suit };
      events.push({ type: "bid", seat, say: b.round === 1 ? "حكم" : "حكم ثاني" });
    } else {
      events.push({ type: "bid", seat, say: b.round === 1 ? "بس" : "ولا" });
    }
    b.spoken++;
    if (b.spoken === 4) {
      if (b.best) {
        finalizeBid(match, events);
      } else if (b.round === 1) {
        b.round = 2;
        b.spoken = 0;
        b.turn = st.firstPlayer;
        b.best = null;
        events.push({ type: "round2" });
      } else {
        match.dealer = (match.dealer + 1) % 4;
        startHand(match, rng);
        events.push({ type: "redeal" });
      }
    } else {
      b.turn = (b.turn + 1) % 4;
    }
    return events;
  }
  function finalizeBid(match, events) {
    const st = match.state;
    const best = st.bidding.best;
    st.buyer = best.seat;
    st.ashkal = best.type === "ashkal";
    st.mode = st.ashkal ? "sun" : best.type;
    st.trump = best.type === "hokum" ? best.suit : null;
    const topRecipient = st.ashkal ? (st.buyer + 2) % 4 : st.buyer;
    let ri = 0;
    st.hands[topRecipient].push(st.rest[ri++], st.rest[ri++]);
    for (let p = 0; p < 4; p++) {
      if (p === topRecipient) continue;
      st.hands[p].push(st.rest[ri++], st.rest[ri++], st.rest[ri++]);
    }
    st.hands[topRecipient].push(st.topCard);
    st.projects = [];
    for (let p = 0; p < 4; p++) {
      for (const pr of findProjects(st.hands[p], st.mode, st.trump)) {
        st.projects.push(Object.assign({ seat: p }, pr));
      }
    }
    st.phase = "playing";
    st.leader = st.firstPlayer;
    st.turn = st.firstPlayer;
    events.push({ type: "bidWon", seat: st.buyer, mode: st.mode, trump: st.trump, ashkal: st.ashkal });
    st.doubleLevel = 1;
    st.doubleTeam = null;
    const buyerTeam = teamOf(st.buyer);
    const oppTeam = 1 - buyerTeam;
    const sunDoubleAllowed = st.mode === "hokum" || match.totals[buyerTeam] > 100 && match.totals[oppTeam] <= 100;
    if (sunDoubleAllowed) {
      st.awaitingDouble = true;
      st.doubling = { turn: (st.buyer + 1) % 4, stage: "offer", nextLevel: 2 };
      events.push({ type: "doubleOpen", turn: st.doubling.turn, stage: "offer" });
    } else {
      st.awaitingDouble = false;
      st.doubling = null;
    }
    st.countedProjects = [];
    st.droppedProjects = [];
    const humanSeats = [];
    for (let p = 0; p < 4; p++) {
      if (!match.players[p].isBot && st.projects.some((pr) => pr.seat === p)) humanSeats.push(p);
    }
    if (!match.autoDeclare && humanSeats.length) {
      st.awaitingDeclare = true;
      st.declareSeats = humanSeats.slice();
      st.declarations = {};
      events.push({ type: "declareProjects", seats: humanSeats.slice() });
    } else {
      finalizeProjects(match, {});
    }
  }
  function applyDouble(match, seat, action) {
    const st = match.state;
    if (!st.awaitingDouble || !st.doubling) throw new Error("مو وقت الدبل");
    const d = st.doubling;
    if (seat !== d.turn) throw new Error("مو دورك بالدبل");
    const events = [];
    if (action && action.type === "double") {
      const level = d.nextLevel;
      st.doubleLevel = level;
      st.doubleTeam = teamOf(seat);
      events.push({ type: "doubled", seat, level });
      if (level >= 4 || st.mode === "sun") {
        st.awaitingDouble = false;
        st.doubling = null;
        events.push({ type: "doublingClosed", level });
      } else {
        d.turn = teamOf(seat) === teamOf(st.buyer) ? (st.buyer + 1) % 4 : st.buyer;
        d.stage = level === 2 ? "redouble" : "recoat";
        d.nextLevel = level + 1;
        events.push({ type: "doubleOpen", turn: d.turn, stage: d.stage });
      }
    } else {
      st.awaitingDouble = false;
      st.doubling = null;
      events.push({ type: "doublingClosed", level: st.doubleLevel });
    }
    return events;
  }

  // js/engine/serialize.js
  function serializeMatch(match) {
    const s = match.state;
    return {
      totals: match.totals,
      dealer: match.dealer,
      handsPlayed: match.handsPlayed,
      matchOver: match.matchOver,
      winnerTeam: match.winnerTeam,
      safeMode: match.safeMode,
      state: s ? {
        phase: s.phase,
        hands: s.hands,
        topCard: s.topCard,
        firstPlayer: s.firstPlayer,
        mode: s.mode,
        trump: s.trump,
        buyer: s.buyer,
        ashkal: s.ashkal || false,
        bidding: s.bidding,
        currentTrick: s.currentTrick,
        trickHistory: s.trickHistory,
        leader: s.leader,
        turn: s.turn,
        countedProjects: s.countedProjects,
        projects: s.projects || [],
        announcedProjects: s.announcedProjects || [],
        balootTeam: s.balootTeam == null ? null : s.balootTeam,
        balootSeat: s.balootSeat == null ? null : s.balootSeat,
        revealedProjects: s.revealedProjects || [],
        violation: s.violation || null,
        playedCards: s.playedCards,
        awaitingDeclare: s.awaitingDeclare || false,
        declareSeats: s.declareSeats || [],
        doubleLevel: s.doubleLevel || 1,
        doubleTeam: s.doubleTeam == null ? null : s.doubleTeam,
        awaitingDouble: s.awaitingDouble || false,
        doubling: s.doubling || null,
        result: s.result || null
      } : null
    };
  }
  function normalizeHands(hands) {
    const out = [[], [], [], []];
    if (!hands) return out;
    for (let s = 0; s < 4; s++) out[s] = hands[s] || [];
    return out;
  }
  function deserializeMatch(obj) {
    const m = {
      totals: obj.totals || [0, 0],
      dealer: obj.dealer || 0,
      handsPlayed: obj.handsPlayed || 0,
      matchOver: !!obj.matchOver,
      winnerTeam: obj.winnerTeam == null ? null : obj.winnerTeam,
      safeMode: !!obj.safeMode,
      state: null,
      metrics: obj.metrics || {
        humanBids: 0,
        humanBidWins: 0,
        teamTricks: 0,
        totalTricks: 0,
        pointMistakes: 0,
        missedWins: 0
      }
    };
    if (obj.state) {
      const s = obj.state;
      m.state = {
        phase: s.phase,
        hands: normalizeHands(s.hands),
        topCard: s.topCard,
        firstPlayer: s.firstPlayer,
        mode: s.mode,
        trump: s.trump,
        buyer: s.buyer,
        ashkal: !!s.ashkal,
        bidding: s.bidding || { round: 1, turn: 0, spoken: 0, best: null },
        currentTrick: s.currentTrick || [],
        trickHistory: s.trickHistory || [],
        leader: s.leader,
        turn: s.turn,
        countedProjects: s.countedProjects || [],
        announcedProjects: s.announcedProjects || [],
        balootTeam: s.balootTeam == null ? null : s.balootTeam,
        balootSeat: s.balootSeat == null ? null : s.balootSeat,
        balootState: null,
        revealedProjects: s.revealedProjects || [],
        violation: s.violation || null,
        droppedProjects: [],
        projects: s.projects || [],
        pendingAnnounce: [],
        pendingReveal: [],
        playedCards: s.playedCards || [],
        awaitingDeclare: !!s.awaitingDeclare,
        declareSeats: s.declareSeats || [],
        doubleLevel: s.doubleLevel || 1,
        doubleTeam: s.doubleTeam == null ? null : s.doubleTeam,
        awaitingDouble: !!s.awaitingDouble,
        doubling: s.doubling || null,
        result: s.result || null,
        voids: [/* @__PURE__ */ new Set(), /* @__PURE__ */ new Set(), /* @__PURE__ */ new Set(), /* @__PURE__ */ new Set()]
      };
    }
    return m;
  }

  // js/online.js
  function net() {
    return window.BalootNet || {};
  }
  function watchSnapshot(code, cb) {
    const n = net();
    if (n.watchSnapshot) return n.watchSnapshot(code, cb);
    return () => {
    };
  }
  function pushAction(code, action) {
    const n = net();
    if (n.pushAction) return n.pushAction(code, action);
    return Promise.resolve();
  }

  // js/ui/dom.js
  var $ = (id) => document.getElementById(id);
  var sleep = (ms) => new Promise((r) => setTimeout(r, ms));
  function el(tag, className, attrs) {
    const e = document.createElement(tag);
    if (className) e.className = className;
    if (attrs) for (const k in attrs) e.setAttribute(k, attrs[k]);
    return e;
  }

  // js/ui/state.js
  var S = {
    match: null,
    players: null,
    mySeat: 0,
    safeMode: true,
    speed: "normal",
    online: null,
    // null = لعب محلي؛ غير null = {code, seat, isHost, actionBuffer, unsubs, started, hostPump, syncSnapshot}
    awaitingServerAck: false,
    // عميل أونلاين: يمنع سبام/دبل-تاب يدفع نفس الحركة مرتين قبل ما توصل لقطة جديدة
    _ackTimeout: null,
    // مهلة إعادة ضبط awaitingServerAck إذا ما وصلت لقطة
    uiStatus: null
    // حالة الواجهة المرسلة من Flutter (playing/trickEnd/roundEnd/...)
  };
  var botDelay = () => (S.speed === "fast" ? 150 : 350) + Math.random() * (S.speed === "fast" ? 100 : 200);

  // js/ui/cards.js
  var SUIT_FILE = { "♠": "S", "♥": "H", "♦": "D", "♣": "C" };
  var RANK_NAME_AR = { "7": "سبعة", "8": "ثمانية", "9": "تسعة", "10": "عشرة", J: "جاك", Q: "بنت", K: "شايب", A: "أص" };
  var SUIT_NAME_AR = { "♠": "سباتي", "♥": "قلب", "♦": "ديناري", "♣": "كلاوب" };
  function cardKey2(card) {
    return card.rank + card.suit;
  }
  function cardFace(card) {
    return "assets/cards/" + card.rank + SUIT_FILE[card.suit] + ".svg";
  }
  function cardLabel(card) {
    return (RANK_NAME_AR[card.rank] || card.rank) + " " + (SUIT_NAME_AR[card.suit] || card.suit);
  }
  var CARD_IMG_CACHE = /* @__PURE__ */ new Map();
  function getCardImg(card) {
    const key = cardKey2(card);
    if (!CARD_IMG_CACHE.has(key)) {
      const img = el("img", "bt-card-face");
      img.src = cardFace(card);
      img.alt = "";
      img.draggable = false;
      CARD_IMG_CACHE.set(key, img);
    }
    return CARD_IMG_CACHE.get(key).cloneNode(true);
  }
  function cardEl(card, extraClass) {
    const d = el("div", "bt-card" + (extraClass ? " " + extraClass : ""), {
      role: "img",
      "aria-label": cardLabel(card)
    });
    d.appendChild(getCardImg(card));
    return d;
  }
  function cardBackEl() {
    return el("div", "bt-card-back");
  }
  function sortHand(hand, trump) {
    const suitOrder = ["♠", "♥", "♦", "♣"];
    const NATURAL2 = ["7", "8", "9", "10", "J", "Q", "K", "A"];
    return hand.slice().sort((a, b) => {
      if (a.suit !== b.suit) {
        if (trump) {
          if (a.suit === trump && b.suit !== trump) return -1;
          if (b.suit === trump && a.suit !== trump) return 1;
        }
        return suitOrder.indexOf(a.suit) - suitOrder.indexOf(b.suit);
      }
      return NATURAL2.indexOf(a.rank) - NATURAL2.indexOf(b.rank);
    });
  }

  // js/ui/render.js
  var vsFor = (mySeat) => (actual) => (actual - mySeat + 4) % 4;
  function renderScores(match, mySeat = 0) {
    const myTeam = mySeat % 2;
    const us = match.totals[myTeam], them = match.totals[1 - myTeam];
    $("score-us").textContent = us;
    $("score-them").textContent = them;
    $("bar-us").style.width = Math.min(100, us / TARGET_QAID * 100) + "%";
    $("bar-them").style.width = Math.min(100, them / TARGET_QAID * 100) + "%";
  }
  function levelBadge(level) {
    return { beginner: "مبتدئ 🐣", amateur: "نص نص", skilled: "شاطر", pro: "وحش 🔥" }[level] || "";
  }
  var AVATAR_FALLBACKS = { 0: "😎", 1: "🤖", 2: "🤝", 3: "🤖" };
  function renderAvatar(avatarEl, player, pos) {
    if (!avatarEl) return;
    const key = player ? `${player.name}|${player.avatarUrl}|${pos}` : `_fallback_${pos}`;
    if (avatarEl._lastAvatarKey === key) return;
    avatarEl._lastAvatarKey = key;
    if (player && player.avatarUrl) {
      const img = document.createElement("img");
      img.src = player.avatarUrl;
      img.alt = player.name || "";
      img.onerror = () => {
        avatarEl.textContent = (player.name ? player.name.charAt(0) : "") || AVATAR_FALLBACKS[pos] || "🃏";
      };
      avatarEl.innerHTML = "";
      avatarEl.appendChild(img);
    } else {
      const initial = player && player.name ? player.name.charAt(0) : "";
      avatarEl.textContent = initial || AVATAR_FALLBACKS[pos] || "🃏";
    }
  }
  function activeSeat(st) {
    if (!st) return null;
    if (st.awaitingDeclare) return (st.declareSeats || [])[0];
    if (st.awaitingDouble) return st.doubling.turn;
    if (st.phase === "bidding") return st.bidding.turn;
    if (st.phase === "playing") return st.turn;
    return null;
  }
  var SEAT_CACHE = /* @__PURE__ */ new Map();
  function getSeatRefs(pos) {
    let refs = SEAT_CACHE.get(pos);
    if (!refs) {
      const seatEl = $("seat-" + pos);
      if (!seatEl) return null;
      refs = {
        seatEl,
        nameEl: seatEl.querySelector(".bt-pname"),
        levelEl: seatEl.querySelector(".bt-plevel"),
        avatarEl: seatEl.querySelector(".bt-avatar"),
        hukumBadge: seatEl.querySelector(".bt-hukum-badge"),
        backs: seatEl.querySelector(".bt-backs"),
        projs: seatEl.querySelector(".bt-projs")
      };
      SEAT_CACHE.set(pos, refs);
    }
    return refs;
  }
  function renderSeats(match, mySeat, players) {
    const st = match.state;
    const vs = vsFor(mySeat);
    const active = activeSeat(st);
    for (let seat = 0; seat < 4; seat++) {
      const pos = vs(seat);
      const refs = getSeatRefs(pos);
      if (!refs) continue;
      const { seatEl, nameEl, levelEl, avatarEl, hukumBadge, backs, projs } = refs;
      seatEl.classList.toggle("is-turn", active === seat);
      seatEl.classList.toggle("is-dealer", match.dealer === seat);
      if (nameEl) nameEl.textContent = players[seat] ? players[seat].name : "";
      if (levelEl) levelEl.textContent = players[seat] && players[seat].isBot ? levelBadge(players[seat].level) : "";
      renderAvatar(avatarEl, players[seat], pos);
      if (hukumBadge) {
        const showTrump = st && st.mode === "hokum" && st.buyer === seat;
        hukumBadge.hidden = !showTrump;
        if (showTrump) hukumBadge.textContent = st.trump;
      }
      if (pos !== 0 && backs) {
        const count = st ? st.hands[seat] ? st.hands[seat].length : 0 : 0;
        const lastCount = backs._lastCount ?? -1;
        if (count !== lastCount) {
          backs._lastCount = count;
          const current = backs.children.length;
          if (current < count) {
            for (let i = current; i < Math.min(count, 8); i++) backs.appendChild(cardBackEl());
          } else if (current > count) {
            for (let i = current - 1; i >= count; i--) backs.removeChild(backs.children[i]);
          }
        }
      }
      if (projs) {
        const mine = (st.announcedProjects || []).filter((p) => p.seat === seat);
        const projsKey = mine.map((p) => p.name).join(",");
        if (projs._lastKey !== projsKey) {
          projs._lastKey = projsKey;
          projs.innerHTML = "";
          for (const p of mine) {
            const chip = document.createElement("span");
            chip.className = "bt-proj-chip";
            chip.textContent = p.name;
            projs.appendChild(chip);
          }
        }
      }
    }
  }
  function renderHand(match, mySeat, onPlay) {
    const st = match.state;
    const handEl = $("hand");
    if (!st || st.phase !== "playing") {
      handEl.innerHTML = "";
      handEl._lastKey = null;
      handEl._onPlay = null;
      return;
    }
    const hand = sortHand(st.hands[mySeat], st.trump);
    const handKey = hand.map((c) => cardKey2(c)).join(",");
    const stateKey = `${handKey}|${st.turn}|${st.currentTrick.length}|${st.doubleLevel || 1}`;
    if (handEl._lastKey === stateKey) return;
    handEl._lastKey = stateKey;
    if (handEl._onPlay !== onPlay) {
      handEl._onPlay = onPlay;
      handEl.onclick = (e) => {
        const cardEl2 = e.target.closest(".bt-card[data-key]");
        if (!cardEl2 || !cardEl2.classList.contains("is-legal")) return;
        const card = handEl._cardsByKey?.[cardEl2.dataset.key];
        if (card) onPlay(card);
      };
    }
    const strict = (st.doubleLevel || 1) >= 2;
    let legal = [];
    if (st.turn === mySeat) {
      legal = legalMoves(hand, st.currentTrick, st.mode, st.trump, mySeat, strict);
    }
    const inputLocked = !!(S.online && S.awaitingServerAck);
    const wantedKeys = /* @__PURE__ */ new Set();
    const cardsByKey = {};
    const existingEls = /* @__PURE__ */ new Map();
    for (const el2 of handEl.children) {
      if (el2.dataset.key) existingEls.set(el2.dataset.key, el2);
    }
    const fragment = document.createDocumentFragment();
    for (const c of hand) {
      const key = cardKey2(c);
      wantedKeys.add(key);
      cardsByKey[key] = c;
      const isLegal = !inputLocked && st.turn === mySeat && legal.some((l) => l.suit === c.suit && l.rank === c.rank);
      let el2 = existingEls.get(key);
      if (el2) {
        el2.classList.toggle("is-legal", isLegal);
      } else {
        el2 = cardEl(c, isLegal ? "is-legal" : "");
        el2.dataset.key = key;
        fragment.appendChild(el2);
      }
    }
    handEl._cardsByKey = cardsByKey;
    for (const [key, el2] of existingEls) {
      if (!wantedKeys.has(key)) el2.remove();
    }
    if (fragment.childNodes.length) handEl.appendChild(fragment);
  }
  var TRICK_ANCHORS = {
    0: { top: "78%", left: "50%" },
    1: { top: "50%", left: "80%" },
    2: { top: "18%", left: "50%" },
    3: { top: "50%", left: "20%" }
  };
  function renderTrickCards(plays, mySeat) {
    const zone = $("trick-zone");
    const trickKey = plays.map((p) => `${p.seat}:${p.card.key}`).join(",");
    if (zone._lastKey === trickKey) return;
    zone._lastKey = trickKey;
    const vs = vsFor(mySeat);
    const wantedKeys = /* @__PURE__ */ new Set();
    const existingEls = /* @__PURE__ */ new Map();
    for (const el2 of zone.children) {
      if (el2.dataset.key) existingEls.set(el2.dataset.key, el2);
    }
    const fragment = document.createDocumentFragment();
    for (const play of plays) {
      const key = `${play.seat}:${cardKey2(play.card)}`;
      wantedKeys.add(key);
      let card = existingEls.get(key);
      if (!card) {
        const pos = vs(play.seat);
        const a = TRICK_ANCHORS[pos];
        card = cardEl(play.card, "bt-played-card");
        card.dataset.key = key;
        card.style.top = a.top;
        card.style.left = a.left;
        card.style.transform = "translate(-50%,-50%)";
        fragment.appendChild(card);
      }
    }
    for (const [key, el2] of existingEls) {
      if (!wantedKeys.has(key)) el2.remove();
    }
    if (fragment.childNodes.length) zone.appendChild(fragment);
  }
  function renderTrick(match, mySeat) {
    if (!match.state) return;
    renderTrickCards(match.state.currentTrick, mySeat);
  }
  function renderBidCenter(match) {
    const st = match.state;
    const center = $("bid-center");
    if (!st || st.phase !== "bidding") {
      center.hidden = true;
      center._lastKey = null;
      return;
    }
    center.hidden = false;
    const bidKey = `${st.topCard.key}|${st.bidding.round}`;
    if (center._lastKey === bidKey) return;
    center._lastKey = bidKey;
    const slot = $("top-card-slot");
    slot.innerHTML = "";
    slot.appendChild(cardEl(st.topCard));
    $("bid-hint").textContent = st.bidding.round === 1 ? "الجولة الأولى" : "الجولة الثانية";
  }
  function setBuyerBadge(match) {
    const st = match.state;
    const badge = $("buyer-badge");
    if (!st || st.buyer == null || st.phase === "bidding") {
      badge.textContent = "";
      return;
    }
    const modeTxt = st.mode === "hokum" ? `حكم ${st.trump}` : "صن";
    badge.textContent = modeTxt;
  }
  function showBanner(text, ms = 1600) {
    const b = $("center-banner");
    b.textContent = text;
    b.classList.add("show");
    clearTimeout(b._t);
    b._t = setTimeout(() => b.classList.remove("show"), ms);
  }
  function updateQaidButton(show) {
    const el2 = $("qaid-btn");
    el2.hidden = !show;
    el2.disabled = !show;
  }
  function updateSawaButton(show) {
    const el2 = $("sawa-btn");
    el2.hidden = !show;
    el2.disabled = !show;
  }
  function renderAll(match, mySeat, players, onPlay) {
    renderScores(match, mySeat);
    renderSeats(match, mySeat, players);
    renderHand(match, mySeat, onPlay);
    renderTrick(match, mySeat);
    renderBidCenter(match);
    setBuyerBadge(match);
  }

  // js/ui/animations.js
  var SEAT_ANCHOR = { 0: [50, 82], 1: [82, 50], 2: [50, 18], 3: [18, 50] };
  function animateDeal(positions) {
    const table = document.querySelector(".bt-table-area");
    if (!table) return;
    for (const pos of positions) {
      const seatEl = $("seat-" + pos);
      if (!seatEl) continue;
      seatEl.animate(
        [
          { transform: "translateY(10px) scale(.9)", opacity: 0.4 },
          { transform: "translateY(0) scale(1)", opacity: 1 }
        ],
        { duration: 260, easing: "cubic-bezier(.34,1.56,.64,1)", delay: pos * 70 }
      );
    }
  }
  function animatePlayedCard(cardEl2) {
    cardEl2.animate(
      [
        { transform: "translate(-50%,-50%) scale(.55)", opacity: 0.2 },
        { transform: "translate(-50%,-50%) scale(1.08)", opacity: 1, offset: 0.7 },
        { transform: "translate(-50%,-50%) scale(1)", opacity: 1 }
      ],
      { duration: 260, easing: "cubic-bezier(0,0,.2,1)" }
    );
  }
  function animateTrickCollect(winnerPos) {
    return new Promise((resolve) => {
      const zone = $("trick-zone");
      const [wx, wy] = SEAT_ANCHOR[winnerPos] || [50, 50];
      const cards = zone.querySelectorAll(".bt-played-card");
      if (!cards.length) return resolve();
      let done = 0;
      cards.forEach((c, i) => {
        const anim = c.animate(
          [
            { transform: c.style.transform, opacity: 1 },
            { transform: `translate(${wx - 50}vw, ${wy - 50}vh) scale(.4)`, opacity: 0 }
          ],
          { duration: 340, easing: "cubic-bezier(.4,0,1,1)", delay: i * 30, fill: "forwards" }
        );
        anim.onfinish = () => {
          done++;
          if (done === cards.length) resolve();
        };
      });
      const seatEl = $("seat-" + winnerPos);
      if (seatEl) {
        seatEl.animate(
          [{ filter: "brightness(1)" }, { filter: "brightness(1.6)" }, { filter: "brightness(1)" }],
          { duration: 420 }
        );
      }
    });
  }
  function spawnConfetti(count = 60) {
    const colors = ["#D9B25C", "#F3D98A", "#5FB6D9", "#E0A94F", "#F5EFE2"];
    for (let i = 0; i < count; i++) {
      const piece = document.createElement("div");
      piece.className = "bt-confetti-piece";
      piece.style.left = Math.random() * 100 + "vw";
      piece.style.background = colors[i % colors.length];
      piece.style.animationDuration = 1.6 + Math.random() * 1.4 + "s";
      piece.style.animationDelay = Math.random() * 0.4 + "s";
      document.body.appendChild(piece);
      setTimeout(() => piece.remove(), 3200);
    }
  }
  function openSheet(id) {
    $(id).classList.add("open");
  }
  function closeSheet(id) {
    $(id).classList.remove("open");
  }
  function showOverlay(id) {
    $(id).classList.add("show");
  }
  function hideOverlay(id) {
    $(id).classList.remove("show");
  }

  // js/bots.js
  function rand(arr) {
    return arr[Math.floor(Math.random() * arr.length)];
  }
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
    for (const s of SUITS) {
      const n = cards.filter((c) => c.suit === s).length;
      if (n >= 3) score += 0.5;
    }
    return score;
  }
  function decideBid(match, seat, level) {
    const st = match.state;
    const hand = st.hands[seat];
    const top = st.topCard;
    const round = st.bidding.round;
    const best = st.bidding.best;
    const th = {
      beginner: { hokum: 6.6, sun: 7.7, noise: 2 },
      amateur: { hokum: 6.1, sun: 7.3, noise: 1 },
      skilled: { hokum: 5.6, sun: 6.9, noise: 0.5 },
      pro: { hokum: 5.2, sun: 6.6, noise: 0.15 }
    }[level];
    let adj = 0;
    if (round === 2) {
      adj -= 0.4;
      if (st.bidding.spoken === 3 && !best) adj -= 0.8;
    }
    th.hokum += adj;
    th.sun += adj;
    const noise = () => (Math.random() * 2 - 1) * th.noise;
    const sunScore = evalSun(hand, top, true) + noise();
    const canSun = !best || best.type !== "sun";
    if (round === 1) {
      const hokumScore = evalHokum(hand, top.suit, top, true) + noise();
      const canHokum = !best;
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
    let bestSuit = null, bestScore = -1;
    for (const s of SUITS) {
      if (s === top.suit) continue;
      const sc = evalHokum(hand, s, top, true);
      if (sc > bestScore) {
        bestScore = sc;
        bestSuit = s;
      }
    }
    bestScore += noise();
    if (canSun && sunScore >= th.sun && sunScore >= bestScore) return { type: "sun" };
    if (!best && bestScore >= th.hokum) return { type: "hokum", suit: bestSuit };
    if (canSun && sunScore >= th.sun) return { type: "sun" };
    return { type: "pass" };
  }
  function isMaster(card, st) {
    const order = st.mode === "hokum" && card.suit === st.trump ? HOKUM_TRUMP_ORDER : SUN_ORDER;
    const myPow = order.indexOf(card.rank);
    for (const r of RANKS) {
      if (order.indexOf(r) <= myPow) continue;
      const played = st.playedCards.some((c) => c.suit === card.suit && c.rank === r);
      if (!played) return false;
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
  function strength(card, led, st) {
    return cardStrength(card, led, st.mode, st.trump);
  }
  function lowestBy(cards, st) {
    return cards.slice().sort((a, b) => {
      const pa = cardPoints(a, st.mode, st.trump), pb = cardPoints(b, st.mode, st.trump);
      if (pa !== pb) return pa - pb;
      return strength(a, a.suit, st) - strength(b, b.suit, st);
    })[0];
  }
  function decidePlay(match, seat, level) {
    const st = match.state;
    const hand = st.hands[seat];
    const strict = (st.doubleLevel || 1) >= 2;
    const legal = legalMoves(hand, st.currentTrick, st.mode, st.trump, seat, strict);
    if (legal.length === 1) return legal[0];
    if (level === "beginner") return rand(legal);
    const trick = st.currentTrick;
    const partner = (seat + 2) % 4;
    const isLast = trick.length === 3;
    if (!trick.length) {
      if (level !== "amateur") {
        const masters = legal.filter((c) => isMaster(c, st));
        if (masters.length) {
          return masters.sort((a, b) => cardPoints(b, st.mode, st.trump) - cardPoints(a, st.mode, st.trump))[0];
        }
      }
      if (level === "pro" && st.mode === "hokum") {
        const trumpsOut = st.playedCards.filter((c) => c.suit === st.trump).length;
        for (const c of legal) {
          if (c.suit !== st.trump && st.voids[partner].has(c.suit) && trumpsOut < 8) {
            const opp1 = (seat + 1) % 4, opp2 = (seat + 3) % 4;
            if (!st.voids[opp1].has(c.suit) || !st.voids[opp2].has(c.suit)) return c;
          }
        }
      }
      if (st.mode === "hokum" && level !== "amateur") {
        const opp1 = (seat + 1) % 4, opp2 = (seat + 3) % 4;
        const safe = legal.filter((c) => c.suit === st.trump || !st.voids[opp1].has(c.suit) && !st.voids[opp2].has(c.suit));
        if (safe.length) return lowestBy(safe, st);
      }
      return lowestBy(legal, st);
    }
    const led = trick[0].card.suit;
    const winSeat = currentWinner(trick, st);
    const partnerWinning = teamOf(winSeat) === teamOf(seat);
    const curBest = Math.max(...trick.map((t) => strength(t.card, led, st)));
    const winners = legal.filter((c) => strength(c, led, st) > curBest);
    const pts = trickPoints(trick, st);
    if (partnerWinning) {
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
    if (winners.length) {
      const cheapWin = winners.sort((a, b) => strength(a, led, st) - strength(b, led, st))[0];
      if (level === "amateur") return cheapWin;
      if (isLast) return cheapWin;
      if (pts >= 10 || cardPoints(cheapWin, st.mode, st.trump) <= 4) return cheapWin;
      const cheap = legal.filter((c) => !winners.includes(c));
      if (cheap.length && Math.random() < 0.6) return lowestBy(cheap, st);
      return cheapWin;
    }
    return lowestBy(legal, st);
  }
  function handStrength(match, seat) {
    const st = match.state;
    return st.mode === "hokum" ? evalHokum(st.hands[seat], st.trump, st.topCard, false) : evalSun(st.hands[seat], st.topCard, false);
  }
  function decideDouble(match, seat, level) {
    const isBuyTeam = teamOf(seat) === teamOf(match.state.buyer);
    const score = handStrength(match, seat);
    const base = { beginner: 0.04, amateur: 0.1, skilled: 0.18, pro: 0.28 }[level] || 0.1;
    const strongThresh = isBuyTeam ? 6.4 : 5.4;
    const chance = score >= strongThresh ? base + 0.35 : base * 0.25;
    return Math.random() < chance;
  }

  // js/ui/grade.js
  function trackHumanCard(match, card, mySeat) {
    const st = match.state;
    const trick = st.currentTrick;
    if (!trick.length) return;
    const m = match.metrics;
    const led = trick[0].card.suit;
    const legal = legalMoves(st.hands[mySeat], trick, st.mode, st.trump, mySeat);
    const curBest = Math.max(...trick.map((t) => cardStrength(t.card, led, st.mode, st.trump)));
    const winSeat = trick[trickWinnerIdx(trick, st.mode, st.trump)].seat;
    if (teamOf(winSeat) === teamOf(mySeat)) return;
    const myStr = cardStrength(card, led, st.mode, st.trump);
    if (myStr > curBest) return;
    const myPts = cardPoints(card, st.mode, st.trump);
    const hasCheap = legal.some((c) => cardPoints(c, st.mode, st.trump) <= 4 && cardStrength(c, led, st.mode, st.trump) <= curBest);
    if (myPts >= 10 && hasCheap) m.pointMistakes++;
    if (trick.length === 3) {
      const trickPts = trick.reduce((s, t) => s + cardPoints(t.card, st.mode, st.trump), 0);
      const couldWin = legal.some((c) => cardStrength(c, led, st.mode, st.trump) > curBest);
      if (couldWin && trickPts >= 10) m.missedWins++;
    }
  }
  function trackTrick(match, winner, mySeat) {
    match.metrics.totalTricks++;
    if (teamOf(winner) === teamOf(mySeat)) match.metrics.teamTricks++;
  }
  function trackHand(match, result, mySeat) {
    if (match.state.buyer === mySeat) {
      match.metrics.humanBids++;
      if (!result.buyerLost) match.metrics.humanBidWins++;
    }
  }
  var GRADE_TABLE = [
    [88, "A+", "يا وحش! لعبك يتدرّس 🏆"],
    [78, "A", "بروفيشنل صدق، ما شاء الله 👑"],
    [68, "B+", "لعب قوي وثابت، عاش 👏"],
    [58, "B", "لعبك زين وباقي لك شوي"],
    [50, "C+", "ماشي الحال — ركّز بالشراء"],
    [42, "C", "راجع حساباتك شوي 🤔"],
    [32, "D", "يومك مو يومك 😅 عيدها"],
    [-1, "F", "خويك بيعتذر عن الصكة الجاية 😂"]
  ];
  function computeGrade(match, mySeat) {
    const m = match.metrics || {
      humanBids: 0,
      humanBidWins: 0,
      teamTricks: 0,
      totalTricks: 0,
      pointMistakes: 0,
      missedWins: 0
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
  function getStats() {
    try {
      return JSON.parse(localStorage.getItem("baloot-stats") || '{"matches":[]}');
    } catch {
      return { matches: [] };
    }
  }
  function saveMatchStats(match, safeMode, mySeat) {
    const g = computeGrade(match, mySeat);
    const myTeam = teamOf(mySeat);
    const s = getStats();
    s.matches.push({
      date: (/* @__PURE__ */ new Date()).toISOString().slice(0, 10),
      win: match.winnerTeam === myTeam,
      my: match.totals[myTeam],
      opp: match.totals[1 - myTeam],
      grade: g.grade,
      mode: safeMode ? "safe" : "normal"
    });
    if (s.matches.length > 100) s.matches = s.matches.slice(-100);
    localStorage.setItem("baloot-stats", JSON.stringify(s));
    return s;
  }

  // js/ui/controller.js
  var BOT_SAWA_CHANCE = { beginner: 0, amateur: 0.25, skilled: 0.6, pro: 0.9 };
  var HUMAN_AFK_MS = 25e3;
  var humanTurnTimer = null;
  function clearHumanTurnTimer() {
    if (humanTurnTimer) {
      clearTimeout(humanTurnTimer);
      humanTurnTimer = null;
    }
  }
  function isStandalone() {
    return !S.online;
  }
  function startHumanTurnTimer() {
    clearHumanTurnTimer();
    if (!isStandalone() || !S.match) return;
    const st = S.match.state;
    const phase = st.phase;
    humanTurnTimer = setTimeout(() => {
      if (!S.match || S.match.matchOver) return;
      const st2 = S.match.state;
      if (st2.phase !== phase) return;
      if (st2.awaitingDeclare && (st2.declareSeats || []).includes(S.mySeat)) {
        const types = st2.projects.filter((p) => p.seat === S.mySeat).map((p) => p.type);
        finishDeclare(types);
        return;
      }
      if (st2.awaitingDouble && st2.doubling && st2.doubling.turn === S.mySeat) {
        humanDouble({ type: "pass" });
        return;
      }
      if (st2.phase === "bidding" && st2.bidding.turn === S.mySeat) {
        const action = decideBid(S.match, S.mySeat, S.players[S.mySeat].level);
        humanBid(action);
        return;
      }
      if (st2.phase === "playing" && st2.turn === S.mySeat) {
        const hand = st2.hands[S.mySeat];
        const strict = (st2.doubleLevel || 1) >= 2;
        const legal = legalMoves(hand, st2.currentTrick, st2.mode, st2.trump, S.mySeat, strict);
        if (legal.length) {
          const card = legal[Math.floor(Math.random() * legal.length)];
          onHumanPlay(card);
        }
        return;
      }
    }, HUMAN_AFK_MS);
  }
  function botQaidChance(level, tricksPlayed) {
    const base = { beginner: 0.25, amateur: 0.5, skilled: 0.75, pro: 0.95 }[level] || 0.5;
    const jitter = 0.85 + Math.random() * 0.3;
    return base * Math.pow(0.85, tricksPlayed) * jitter;
  }
  function renderSetupStats() {
    const s = getStats();
    if (!s.matches.length) return;
    const wins = s.matches.filter((m) => m.win).length;
    const last = s.matches[s.matches.length - 1];
    $("setup-stats").innerHTML = `📊 سجلك: <b>${wins}</b> فوز من <b>${s.matches.length}</b> · آخر تقدير: <b>${last.grade}</b>`;
  }
  function showScreen(id) {
    for (const s of ["setup-screen", "online-screen", "lobby-screen"]) $(s).hidden = s !== id;
  }
  function wireMenu() {
    const menu = $("menu-panel");
    $("menu-btn").onclick = () => menu.classList.toggle("open");
    document.addEventListener("click", (e) => {
      if (!e.target.closest("#topbar")) menu.classList.remove("open");
    });
    $("t-speed").textContent = S.speed === "fast" ? "⚡ سريع" : "🐢 عادي";
    $("t-speed").onclick = () => {
      S.speed = S.speed === "fast" ? "normal" : "fast";
      $("t-speed").textContent = S.speed === "fast" ? "⚡ سريع" : "🐢 عادي";
    };
    $("exit-match").onclick = () => {
      const ok = window.BalootPopup ? Promise.resolve(true) : window.confirm("تبي تطلع من الصكة؟");
      Promise.resolve(window.BalootPopup ? window.BalootPopup.confirm("تبي تطلع من الصكة؟") : ok).then((yes) => {
        if (yes) location.href = "index.html";
      });
    };
  }
  async function safePump(run) {
    try {
      await handleEvents(run());
    } catch (err) {
      console.warn("[baloot] حركة بوت أصبحت غير صالحة (سباق) — تُجوهل:", err && err.message);
    }
    renderAll(S.match, S.mySeat, S.players, onHumanPlay);
    return pump();
  }
  async function pump() {
    if (!S.match || S.match.matchOver) return;
    clearHumanTurnTimer();
    const st = S.match.state;
    if (st.phase === "handEnd" || st.phase === "matchEnd") {
      updateQaidButton(false);
      updateSawaButton(false);
      return;
    }
    if (st.phase !== "playing" || st.awaitingDeclare || st.awaitingDouble) {
      updateQaidButton(false);
      updateSawaButton(false);
    }
    if (st.awaitingDeclare) {
      const seat = st.declareSeats[0];
      if (seat === S.mySeat) {
        showDeclareDialog();
        startHumanTurnTimer();
        return;
      }
      await sleep(botDelay());
      const types = st.projects.filter((p) => p.seat === seat).map((p) => p.type);
      return safePump(() => {
        declareProject(S.match, seat, types);
        return [];
      });
    }
    if (st.awaitingDouble) {
      const seat = st.doubling.turn;
      if (seat === S.mySeat) {
        showDoubleDialog();
        startHumanTurnTimer();
        return;
      }
      await sleep(botDelay());
      const wants = decideDouble(S.match, seat, S.players[seat].level);
      return safePump(() => applyDouble(S.match, seat, wants ? { type: "double" } : { type: "pass" }));
    }
    if (st.phase === "bidding") {
      const seat = st.bidding.turn;
      if (seat === S.mySeat) {
        showBidDialog();
        startHumanTurnTimer();
        return;
      }
      await sleep(botDelay());
      const action = decideBid(S.match, seat, S.players[seat].level);
      return safePump(() => applyBid(S.match, seat, action));
    }
    if (st.phase === "playing") {
      const actionsAllowed = canShowActionButtons();
      updateQaidButton(actionsAllowed && canClaimQaid());
      updateSawaButton(actionsAllowed && canClaimSawa());
      if (await maybeBotClaims()) return;
      const seat = st.turn;
      if (seat === S.mySeat) {
        renderAll(S.match, S.mySeat, S.players, onHumanPlay);
        startHumanTurnTimer();
        return;
      }
      await sleep(botDelay());
      const card = decidePlay(S.match, seat, S.players[seat].level);
      await playCardFlow(seat, card);
      if (!S.match.matchOver && S.match.state.phase === "playing") return pump();
      if (S.match.state.phase === "bidding" || S.match.state.awaitingDouble || S.match.state.awaitingDeclare) return pump();
    }
  }
  function canClaimQaid() {
    const st = S.match.state;
    return !!st.violation && teamOf(st.violation.seat) !== teamOf(S.mySeat);
  }
  function canClaimSawa() {
    const st = S.match.state;
    return st.turn === S.mySeat && st.currentTrick.length === 0 && 8 - st.trickHistory.length <= 4;
  }
  function canShowActionButtons() {
    if (S.online && S.awaitingServerAck) return false;
    if (S.uiStatus === "playing" || S.uiStatus == null) return true;
    if (S.uiStatus === "trickEnd") {
      const st = S.match?.state;
      return st?.phase === "playing" && st.turn === S.mySeat;
    }
    return false;
  }
  async function maybeBotClaims() {
    const st = S.match.state;
    if (st.violation) {
      for (let s = 0; s < 4; s++) {
        if (s === S.mySeat || teamOf(s) === teamOf(st.violation.seat)) continue;
        if (Math.random() < botQaidChance(S.players[s].level, st.trickHistory.length)) {
          await sleep(botDelay());
          try {
            await handleEvents(claimQaid(S.match, s, st.violation.vtype));
          } catch (err) {
            console.warn("[baloot] قيد بوت أصبح غير صالح (سباق) — تُجوهل:", err && err.message);
          }
          renderAll(S.match, S.mySeat, S.players, onHumanPlay);
          return true;
        }
      }
    }
    if (st.currentTrick.length === 0 && 8 - st.trickHistory.length <= 4) {
      const seat = st.turn;
      if (seat !== S.mySeat && Math.random() < (BOT_SAWA_CHANCE[S.players[seat].level] || 0) && sawaGuaranteed(st, seat)) {
        await sleep(botDelay());
        try {
          await handleEvents(claimSawa(S.match, seat));
        } catch (err) {
          console.warn("[baloot] سوا بوت أصبح غير صالح (سباق) — تُجوهل:", err && err.message);
        }
        renderAll(S.match, S.mySeat, S.players, onHumanPlay);
        return true;
      }
    }
    return false;
  }
  async function playCardFlow(seat, card) {
    let events;
    try {
      if (seat === S.mySeat) trackHumanCard(S.match, card, S.mySeat);
      events = playCard(S.match, seat, card);
    } catch (err) {
      console.warn("[baloot] لعب ورقة مرفوض (سباق/تكرار) — تُجوهل:", err && err.message);
      renderAll(S.match, S.mySeat, S.players, onHumanPlay);
      return;
    }
    const trickEndEv = events.find((e) => e.type === "trickEnd");
    if (trickEndEv) renderTrickCards(trickEndEv.plays, S.mySeat);
    else renderTrick(S.match, S.mySeat);
    const zone = $("trick-zone");
    const played = zone.querySelector(".bt-played-card:last-child");
    if (played) animatePlayedCard(played);
    await sleep(120);
    await handleEvents(events);
    renderAll(S.match, S.mySeat, S.players, onHumanPlay);
  }
  async function onHumanPlay(card) {
    clearHumanTurnTimer();
    if (!canShowActionButtons()) {
      console.warn("[baloot] ignoring card tap while UI status is", S.uiStatus);
      renderAll(S.match, S.mySeat, S.players, onHumanPlay);
      return;
    }
    if (S.online && !S.online.isHost) {
      if (S.awaitingServerAck) return;
      setAwaitingAck();
      pushAction(S.online.code, { type: "play", seat: S.mySeat, card });
      return;
    }
    await playCardFlow(S.mySeat, card);
    if (S.online && S.online.isHost) {
      S.online.syncSnapshot();
      S.online.hostPump();
      return;
    }
    if (!S.match.matchOver && S.match.state.phase !== "handEnd") pump();
  }
  async function handleEvents(events) {
    for (const ev of events) {
      if (ev.type === "bid") showBanner(bidSay(ev));
      else if (ev.type === "bidWon") showBanner(ev.ashkal ? "أشكل 🔄" : ev.mode === "sun" ? "صن ☀️" : `حكم ${ev.trump}`, 1400);
      else if (ev.type === "doubled") showBanner({ 2: "دبل ×2 🔺", 3: "تربل ×3 🔺", 4: "كوت ×4 🔺" }[ev.level] || "");
      else if (ev.type === "baloot") showBanner("بلوت! 🃏", 1200);
      else if (ev.type === "projectAnnounce") showBanner(ev.names.join(" + "), 1400);
      else if (ev.type === "violationRevealed") showBanner("⚠️ قطع مكشوف!", 1400);
      else if (ev.type === "qatClaimed") showBanner(ev.failed ? "قيد خايب! 😬" : `قيّده! (${ev.typeName})`, 1600);
      else if (ev.type === "sawaClaimed") showBanner(ev.valid ? "سوا! 🃏" : "سوا خاطئ! 😬", 1600);
      else if (ev.type === "trickEnd") {
        trackTrick(S.match, ev.winner, S.mySeat);
        await animateTrickCollect(vsFor(S.mySeat)(ev.winner));
      } else if (ev.type === "handEnd") {
        trackHand(S.match, ev.result, S.mySeat);
        await sleep(300);
        if (!events.some((e) => e.type === "matchEnd")) showHandOverlay(ev.result);
      } else if (ev.type === "matchEnd") {
        await sleep(400);
        showMatchOverlay();
      }
    }
  }
  function bidSay(ev) {
    return ev.say;
  }
  function showBidDialog() {
    const st = S.match.state;
    const dealer = S.match.dealer;
    const ashkalEligible = S.mySeat === dealer || S.mySeat === (dealer + 3) % 4;
    $("bid-ashkal").hidden = !(st.bidding.round === 1 && ashkalEligible);
    $("bid-title").textContent = st.bidding.round === 1 ? "دورك بالشراء" : "الجولة الثانية";
    $("suit-pick").innerHTML = "";
    $("suit-pick").hidden = true;
    openSheet("bid-dialog");
  }
  function setAwaitingAck() {
    S.awaitingServerAck = true;
    if (S._ackTimeout) clearTimeout(S._ackTimeout);
    S._ackTimeout = setTimeout(() => {
      S.awaitingServerAck = false;
      console.warn("[baloot] server ack timeout — allowing retry");
    }, 3e3);
  }
  function clearAwaitingAck() {
    S.awaitingServerAck = false;
    if (S._ackTimeout) {
      clearTimeout(S._ackTimeout);
      S._ackTimeout = null;
    }
  }
  function resetAck() {
    clearAwaitingAck();
  }
  async function safeAct(run, remoteAction) {
    if (S.online && !S.online.isHost) {
      if (S.awaitingServerAck) return;
      setAwaitingAck();
      pushAction(S.online.code, { seat: S.mySeat, ...remoteAction });
      return;
    }
    try {
      await handleEvents(run());
    } catch (err) {
      console.warn("[baloot] حركة مرفوضة (سباق/تكرار) — تُجوهلت:", err && err.message);
    }
    renderAll(S.match, S.mySeat, S.players, onHumanPlay);
    if (S.online && S.online.isHost) {
      S.online.syncSnapshot();
      S.online.hostPump();
      return;
    }
    pump();
  }
  function humanBid(action) {
    clearHumanTurnTimer();
    closeSheet("bid-dialog");
    safeAct(() => applyBid(S.match, S.mySeat, action), { type: "bid", bid: action });
  }
  function wireDialogs() {
    $("bid-pass").onclick = () => humanBid({ type: "pass" });
    $("bid-sun").onclick = () => humanBid({ type: "sun" });
    $("bid-ashkal").onclick = () => humanBid({ type: "ashkal" });
    $("bid-hokum").onclick = () => {
      const st = S.match.state;
      if (st.bidding.round === 1) {
        humanBid({ type: "hokum" });
        return;
      }
      const suits = ["♠", "♥", "♦", "♣"].filter((s) => s !== st.topCard.suit);
      const pick = $("suit-pick");
      pick.innerHTML = "";
      pick.hidden = false;
      for (const s of suits) {
        const b = document.createElement("button");
        b.textContent = s;
        if (s === "♥" || s === "♦") b.classList.add("red");
        b.onclick = () => humanBid({ type: "hokum", suit: s });
        pick.appendChild(b);
      }
    };
    $("double-yes").onclick = () => humanDouble({ type: "double" });
    $("double-pass").onclick = () => humanDouble({ type: "pass" });
    $("declare-none").onclick = () => finishDeclare([]);
    $("qaid-btn").onclick = () => {
      if (!canShowActionButtons() || !canClaimQaid()) {
        updateQaidButton(false);
        return;
      }
      openSheet("qaid-pick");
    };
    $("qaid-cancel").onclick = () => closeSheet("qaid-pick");
    $("sawa-btn").onclick = () => {
      if (!canShowActionButtons() || !canClaimSawa()) {
        updateSawaButton(false);
        return;
      }
      safeAct(() => claimSawa(S.match, S.mySeat), { type: "sawa" });
    };
    $("continue-btn").onclick = () => {
      hideOverlay("hand-overlay");
      if (window.__BLOOT_BRIDGE_ENABLED && window.BlootBridge) {
        window.BlootBridge.send({ type: "action", action: "nextRound", seat: S.mySeat });
        return;
      }
      if (S.online) {
        if (!S.online.isHost) return;
        if (S.match.matchOver) return;
        nextHand(S.match);
        renderAll(S.match, S.mySeat, S.players, onHumanPlay);
        animateDeal([0, 1, 2, 3]);
        S.online.syncSnapshot();
        S.online.hostPump();
        return;
      }
      if (S.match.matchOver) return;
      nextHand(S.match);
      renderAll(S.match, S.mySeat, S.players, onHumanPlay);
      animateDeal([0, 1, 2, 3]);
      pump();
    };
    $("again-btn").onclick = () => {
      hideOverlay("match-overlay");
      if (S.online) {
        S.online.leaveOnline();
        return;
      }
      S.match = null;
      $("topbar").hidden = true;
      $("table-area").hidden = true;
      $("footer-bar").hidden = true;
      $("setup-screen").hidden = false;
      renderSetupStats();
    };
    const qaidList = $("qaid-pick-list");
    qaidList.innerHTML = "";
    for (const [type, name] of Object.entries(VIOLATION_NAMES)) {
      if (type === "sawa") continue;
      const b = document.createElement("button");
      b.className = "bt-btn bt-btn--danger";
      b.textContent = name;
      b.onclick = () => {
        closeSheet("qaid-pick");
        safeAct(() => claimQaid(S.match, S.mySeat, type), { type: "qaid", claimType: type });
      };
      qaidList.appendChild(b);
    }
  }
  function humanDouble(action) {
    clearHumanTurnTimer();
    closeSheet("double-dialog");
    safeAct(() => applyDouble(S.match, S.mySeat, action), { type: "double", double: action });
  }
  function showDoubleDialog() {
    const stage = S.match.state.doubling.stage;
    $("double-title").textContent = { offer: "تبي تعلن دبل؟", redouble: "تبي ترد بتربل؟", recoat: "تبي توصل كوت؟" }[stage] || "تبي تدبل؟";
    openSheet("double-dialog");
  }
  function showDeclareDialog() {
    const mine = S.match.state.projects.filter((p) => p.seat === S.mySeat);
    const list = $("declare-list");
    list.innerHTML = "";
    const types = [...new Set(mine.map((p) => p.type))];
    for (const type of types) {
      const b = document.createElement("button");
      b.className = "bt-btn bt-btn--gold";
      b.textContent = PROJECT_NAMES[type];
      b.onclick = () => finishDeclare(types);
      list.appendChild(b);
    }
    openSheet("declare-dialog");
  }
  function finishDeclare(types) {
    clearHumanTurnTimer();
    closeSheet("declare-dialog");
    if (S.online && !S.online.isHost) {
      if (S.awaitingServerAck) return;
      setAwaitingAck();
      pushAction(S.online.code, { type: "declare", seat: S.mySeat, claimedTypes: types });
      return;
    }
    try {
      declareProject(S.match, S.mySeat, types);
    } catch (err) {
      console.warn("[baloot] إعلان مرفوض (سباق/تكرار) — تُجوهل:", err && err.message);
    }
    renderAll(S.match, S.mySeat, S.players, onHumanPlay);
    if (S.online && S.online.isHost) {
      S.online.syncSnapshot();
      S.online.hostPump();
      return;
    }
    pump();
  }
  function showHandOverlay(result) {
    const st = S.match.state;
    const label = st.ashkal ? "أشكل 🔄" : st.mode === "sun" ? "صن ☀️" : `حكم ${st.trump}`;
    const dblLabel = { 2: " · دبل ×2", 3: " · تربل ×3", 4: " · كوت ×4" }[st.doubleLevel] || "";
    $("hand-title").textContent = `نتيجة الصكة — ${label}${dblLabel}`;
    const rows = [];
    if (result.qatClaim) {
      rows.push(`<div class="row">${result.qatClaim.failed ? "قيد خايب ⚠️" : `قيّده: ${result.qatClaim.typeName}`}</div>`);
    }
    const myTeam = teamOf(S.mySeat);
    if (result.sawa) rows.push(`<div class="row">سوا! فريق ${teamOf(result.sawa.seat) === myTeam ? "لنا" : "لهم"} أخذ كل الباقي</div>`);
    if (result.capotTeam != null) rows.push(`<div class="row">كبوت! 🎯</div>`);
    rows.push(`<div class="row"><span>قيد الصكة</span><b>لنا ${result.qaid[myTeam]} — لهم ${result.qaid[1 - myTeam]}</b></div>`);
    if (result.buyerLost) rows.push(`<div class="row">المشتري خسر (دخلة) — الخصم ياخذ القيد</div>`);
    if (result.safeSaved) rows.push(`<div class="row">🛡️ الوضع الآمن حماكم من القطع</div>`);
    $("hand-detail").innerHTML = rows.join("");
    renderScores(S.match, S.mySeat);
    showOverlay("hand-overlay");
  }
  function showMatchOverlay() {
    const myTeam = teamOf(S.mySeat);
    const won = S.match.winnerTeam === myTeam;
    const g = computeGrade(S.match, S.mySeat);
    $("match-title").textContent = won ? "🏆 مبروك! كسبتوا الصكة" : "😔 خسرتوها هالمرة";
    $("match-score").innerHTML = `<b style="font-size:1.4rem">${S.match.totals[myTeam]} — ${S.match.totals[1 - myTeam]}</b>`;
    $("grade-circle").textContent = g.grade;
    $("grade-comment").textContent = g.comment;
    const m = S.match.metrics || {
      humanBids: 0,
      humanBidWins: 0,
      teamTricks: 0,
      totalTricks: 0,
      pointMistakes: 0,
      missedWins: 0
    };
    const rows = [
      ["قيدكم من الكل", Math.round(g.qaidShare * 100) + "%"],
      ["الأكلات اللي أخذتوها", Math.round(g.trickShare * 100) + "%"],
      ["شراياتك اللي نجحت", m.humanBids ? `${m.humanBidWins} من ${m.humanBids}` : "ما شريت"],
      ["نقاط فرّطتها للخصم", m.pointMistakes],
      ["أكلات فاتتك", m.missedWins],
      ["عدد الصكات", S.match.handsPlayed]
    ];
    $("analysis").innerHTML = rows.map(([k, v]) => `<div class="row"><span>${k}</span><b>${v}</b></div>`).join("");
    const s = saveMatchStats(S.match, S.safeMode, S.mySeat);
    const wins = s.matches.filter((x) => x.win).length;
    $("save-note").textContent = `✓ انحفظت بسجلك: ${wins} فوز من ${s.matches.length} صكة`;
    if (won) spawnConfetti();
    showOverlay("match-overlay");
  }

  // js/ui_adapter.js
  var previousSnap = null;
  var previousMatch = null;
  var bootstrapped = false;
  function playTransitionSounds(prev, next) {
    const voice = window.BalootVoice;
    if (!voice || !voice.sfx) return;
    if (voice.resumeAudio) voice.resumeAudio();
    const prevSt = prev && prev.state;
    const nextSt = next && next.state;
    if (!nextSt) return;
    if (prevSt && prevSt.bidding && nextSt.bidding) {
      if (nextSt.bidding.spoken > prevSt.bidding.spoken) {
        voice.sfx.turn();
      }
    }
    if (prevSt && nextSt.currentTrick && prevSt.currentTrick) {
      if (nextSt.currentTrick.length > prevSt.currentTrick.length) {
        voice.sfx.card();
      }
    }
    if (prevSt && nextSt.trickHistory && prevSt.trickHistory) {
      if (nextSt.trickHistory.length > prevSt.trickHistory.length) {
        voice.sfx.trick();
      }
    }
    if (prevSt && prevSt.phase !== "handEnd" && nextSt.phase === "handEnd") {
      voice.sfx.deal();
    }
    if (prevSt && !prev.matchOver && next.matchOver) {
      const myTeam = S.mySeat % 2;
      const won = next.winnerTeam === myTeam;
      won ? voice.sfx.win() : voice.sfx.lose();
    }
  }
  function playTransitionAnimations(prev, next) {
    if (!next || !next.state) return;
    const prevSt = prev && prev.state;
    const nextSt = next.state;
    if (!prevSt) return;
    if (prevSt.phase === "handEnd" && nextSt.phase === "bidding") {
      animateDeal([0, 1, 2, 3]);
    }
    if (prevSt.mode == null && nextSt.mode != null) {
      const label = nextSt.ashkal ? "أشكل 🔄" : nextSt.mode === "sun" ? "صن ☀️" : `حكم ${nextSt.trump}`;
      showBanner(label, 1400);
    }
    if ((nextSt.doubleLevel || 1) > (prevSt.doubleLevel || 1)) {
      const label = { 2: "دبل ×2 🔺", 3: "تربل ×3 🔺", 4: "كوت ×4 🔺" }[nextSt.doubleLevel] || "";
      if (label) showBanner(label);
    }
    const prevProj = (prevSt.announcedProjects || []).length;
    const nextProj = (nextSt.announcedProjects || []).length;
    if (nextProj > prevProj) {
      const names = (nextSt.announcedProjects || []).map((p) => p.name);
      if (names.length) showBanner(names.join(" + "), 1400);
    }
    if ((nextSt.currentTrick || []).length > (prevSt.currentTrick || []).length) {
      const zone = $("trick-zone");
      const played = zone && zone.querySelector(".bt-played-card:last-child");
      if (played) animatePlayedCard(played);
    }
    if ((nextSt.trickHistory || []).length > (prevSt.trickHistory || []).length) {
      const last = nextSt.trickHistory[nextSt.trickHistory.length - 1];
      if (last && last.winner != null) {
        renderTrickCards(last.plays, S.mySeat);
        animateTrickCollect(vsFor(S.mySeat)(last.winner));
      }
    }
    if (prev && !prev.matchOver && next.matchOver) {
      const myTeam = S.mySeat % 2;
      if (next.winnerTeam === myTeam) spawnConfetti();
      hideOverlay("hand-overlay");
      setTimeout(() => showMatchOverlay(), 400);
    }
  }
  function renderClient() {
    if (!S.match) return;
    renderAll(S.match, S.mySeat, S.players, onHumanPlay);
    const st = S.match.state;
    const canShowActions = canShowActionButtons() && st.phase === "playing" && !st.awaitingDeclare && !st.awaitingDouble;
    updateQaidButton(canShowActions && !!st.violation && teamOf(st.violation.seat) !== teamOf(S.mySeat));
    updateSawaButton(
      canShowActions && st.turn === S.mySeat && st.currentTrick.length === 0 && 8 - st.trickHistory.length <= 4
    );
    if (!S.awaitingServerAck) {
      if (st.awaitingDeclare && (st.declareSeats || []).includes(S.mySeat)) {
        showDeclareDialog();
      } else if (st.awaitingDouble && st.doubling.turn === S.mySeat) {
        showDoubleDialog();
      } else if (st.phase === "bidding" && st.bidding.turn === S.mySeat) {
        showBidDialog();
      }
    }
  }
  function bootUI() {
    if (window.__BLOOT_BRIDGE_ENABLED) {
      showScreen(null);
    } else {
      wireDialogs();
      wireMenu();
      renderSetupStats();
    }
  }
  function startBlootOnline(cfg) {
    S.online = {
      code: cfg.code,
      seat: cfg.seat,
      isHost: false,
      actionBuffer: [],
      started: true,
      unsubs: []
    };
    S.mySeat = cfg.seat;
    S.players = cfg.players || [];
    S.safeMode = !!cfg.safeMode;
    S.uiStatus = null;
    showScreen(null);
    $("topbar").hidden = false;
    $("footer-bar").hidden = false;
    $("table-area").hidden = false;
    $("buyer-badge").textContent = "🌐 أونلاين";
    const menuBtn = $("menu-btn");
    if (menuBtn) menuBtn.parentElement.hidden = true;
    wireDialogs();
    wireMenu();
    if (window.__BLOOT_BRIDGE_ENABLED) {
      const againBtn = $("again-btn");
      if (againBtn) againBtn.hidden = true;
      const homeBtn = $("match-overlay")?.querySelector(".bt-btn--ghost");
      if (homeBtn) {
        homeBtn.textContent = "🏠 خروج";
        homeBtn.onclick = () => {
          if (window.BlootBridge && window.BlootBridge.send) {
            window.BlootBridge.send({ type: "exit" });
          }
        };
      }
    }
    S.online.unsubs.push(
      watchSnapshot(cfg.code, (snap) => {
        if (!snap) return;
        playTransitionSounds(previousSnap, snap);
        previousSnap = JSON.parse(JSON.stringify(snap));
        S.uiStatus = snap.status || S.uiStatus;
        const nextMatch = deserializeMatch(snap);
        S.match = nextMatch;
        clearAwaitingAck();
        renderClient();
        const nextState = nextMatch.state;
        if (nextState.phase === "handEnd" && nextState.result && !nextMatch.matchOver && S.uiStatus !== "gameEnd") {
          if (!$("hand-overlay").classList.contains("show")) showHandOverlay(nextState.result);
        } else if (nextState.phase !== "handEnd") {
          hideOverlay("hand-overlay");
        }
        playTransitionAnimations(previousMatch, nextMatch);
        previousMatch = nextMatch;
        if (!bootstrapped) {
          bootstrapped = true;
          animateDeal([0, 1, 2, 3]);
        }
      })
    );
  }
  function setPlayers(p) {
    S.players = p || [];
  }
  function setStatus(status) {
    S.uiStatus = status;
    clearAwaitingAck();
    if (S.match) renderClient();
    if (window.BalootVoice && BalootVoice.resumeAudio) BalootVoice.resumeAudio();
  }
  window.__bloot_ui = {
    startBlootOnline,
    setPlayers,
    resetAck,
    setStatus
  };
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", bootUI);
  } else {
    bootUI();
  }

  // js/bundle_entry.js
  window.BalootEngine = engine_exports;
})();
