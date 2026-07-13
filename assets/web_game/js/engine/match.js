import { TARGET_QAID, PROJECT_NAMES, BALOOT_QAID } from "./constants.js";
import { shuffle } from "./rng.js";
import { makeDeck, sameCard } from "./deck.js";
import { teamOf, cardPoints, trickWinnerIdx } from "./cards.js";
import { legalMoves, classifyViolation, VIOLATION_NAMES } from "./rules.js";
import { findProjects, projectQaid, resolveProjects } from "./projects.js";
import { scoreHand } from "./scoring.js";

// ===== إدارة حالة المباراة =====
export function createMatch(opts) {
  return {
    players: opts.players, // [{name, isBot, level}] — 4
    safeMode: !!opts.safeMode, // آمن: فريق اللاعب ما ينقطع
    autoDeclare: !!opts.autoDeclare, // أونلاين: نعلن المشاريع تلقائياً
    totals: [0, 0],
    dealer: opts.dealer != null ? opts.dealer : Math.floor((opts.rng ? opts.rng() : Math.random()) * 4),
    handsPlayed: 0,
    handResults: [],
    metrics: { // لتحليل الأداء
      humanBids: 0, humanBidWins: 0,
      teamTricks: 0, totalTricks: 0,
      pointMistakes: 0, missedWins: 0,
    },
    state: null,
    matchOver: false,
    winnerTeam: null,
  };
}

export function startHand(match, rng) {
  const deck = shuffle(makeDeck(), rng);
  const hands = [[], [], [], []];
  // Bidding starts with the dealer (house rule).
  const firstPlayer = match.dealer;
  // 5 لكل لاعب
  let di = 0;
  for (let round = 0; round < 5; round++) {
    for (let p = 0; p < 4; p++) hands[(firstPlayer + p) % 4].push(deck[di++]);
  }
  const topCard = deck[di++];
  const rest = deck.slice(di); // 11 ورقة

  match.state = {
    phase: "bidding",
    safeMode: match.safeMode,
    hands, topCard, rest,
    firstPlayer,
    mode: null, trump: null, buyer: null, ashkal: false,
    bidding: { round: 1, turn: firstPlayer, spoken: 0, best: null },
    currentTrick: [],
    trickHistory: [],
    leader: firstPlayer,
    turn: firstPlayer,
    projects: [], countedProjects: [], droppedProjects: [],
    // مرحلتان: الإعلان (الاسم فقط) مع لعبة صاحبه بالأكلة الأولى، والكشف (نزول الورق)
    // مع لعبته بالأكلة الثانية. المعلَن يشمل كل المشاريع المصرّح بها (حتى اللي بتخسر
    // المقارنة)، والمكشوف بس مشاريع الفريق الرابح بالمقارنة (countedProjects).
    pendingAnnounce: [], pendingReveal: [],
    announcedProjects: [], revealedProjects: [],
    // البلوت (حكم فقط): يتحقق أثناء اللعب — شايب+بنت الحكم بلعبتي اللاعب المتتاليتين
    balootState: null, // {seat, rank, trickIndex} أول ورقة من الثنائي
    balootTeam: null, balootSeat: null,
    awaitingDeclare: false, declareSeats: [], declarations: {},
    // الدبل: 1=عادي، 2=دبل، 3=تربل، 4=كوت. يُفتح باب المزايدة بعد حسم الشراء (finalizeBid)
    // ويُغلق بأول تمرير أو الوصول للكوت. awaitingDouble يمنع اللعب لحد ما ينحسم (متل awaitingDeclare).
    doubleLevel: 1, doubleTeam: null, awaitingDouble: false, doubling: null,
    violation: null, // قطع مكشوف حالياً وقابل للتقييد (تأكد لعب غير قانوني بدليل علني)
    pendingViolations: [], // قطوع صارت بس ما انكشفت بعد — ما تنكشف إلا لو نفس اللاعب رجع لعب ورقة كانت لازمة
    voids: [new Set(), new Set(), new Set(), new Set()], // ألوان مقطوعة معروفة
    playedCards: [],
  };
  return match.state;
}

// يحسم كل المشاريع بعد ما كل اللاعبين الحقيقيين يعلنون (declarations = {seat: claimedTypes[]}).
// البوتات والمقاعد اللي ما أعلنت (autoDeclare) تحتسب مشاريعها الحقيقية كاملة تلقائياً.
export function finalizeProjects(match, declarations) {
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
  // الإعلان (بالأكلة الأولى): كل المشاريع المصرّح بها من الفريقين — بالاسم فقط، متل الطاولة الحقيقية
  st.pendingAnnounce = kept.map((p) => ({ seat: p.seat, name: PROJECT_NAMES[p.type], type: p.type }));
  // الكشف (بالأكلة الثانية): بس مشاريع الفريق اللي كسب المقارنة (اللي بتنحسب فعلاً)
  st.pendingReveal = st.countedProjects.map((p) => ({
    seat: p.seat, name: PROJECT_NAMES[p.type], qaid: projectQaid(p, st.mode), cards: p.cards,
  }));
}

// مقعد واحد يعلن أنواع مشاريعه المخمّنة (claimedTypes = مصفوفة أسماء أنواع، أو [] = ما يعلن شي).
// لما آخر واحد ينتظره الإعلان يخلّص، تنحسم كل المشاريع دفعة وحدة (finalizeProjects).
export function declareProject(match, seat, claimedTypes) {
  const st = match.state;
  if (!st.awaitingDeclare || !(st.declareSeats || []).includes(seat)) throw new Error("مو وقت الإعلان");
  st.declarations[seat] = claimedTypes || [];
  st.declareSeats = st.declareSeats.filter((s) => s !== seat);
  if (st.declareSeats.length === 0) finalizeProjects(match, st.declarations);
  return [];
}

// ===== السوا: ادعاء إن فريق المدّعي بياخذ كل الأكلات المتبقية =====
// فحص دقيق (minimax): المدّعي وخويه يتعاونان، والخصمان يلعبان أسوأ شي للمدّعي.
// يرجع true فقط لو الفريق يضمن كل الأكلات المتبقية مهما لعب الخصوم. عدد الأكلات ≤4
// فالشجرة صغيرة جداً. المحرك يعرف كل الأيادي فالفحص قطعي مو تخميني.
export function sawaGuaranteed(state, claimSeat) {
  const mode = state.mode, trump = state.trump;
  const team = teamOf(claimSeat);
  const hands = state.hands.map((h) => h.slice());

  // هل الفريق ياخذ كل الأكلات من هالوضعية؟ leader يبدأ أكلة جديدة
  function teamWinsAll(hands, leader) {
    if (hands.every((h) => h.length === 0)) return true;
    return trickOutcome(hands, leader, []);
  }
  // يبني الأكلة ورقة-ورقة: فريق المدّعي يختار الأفضل (يوجد خيار ينجح)،
  // الخصم يختار الأسوأ (كل خياراته لازم تنجح)
  function trickOutcome(hands, leader, trick) {
    if (trick.length === 4) {
      const w = trick[trickWinnerIdx(trick, mode, trump)].seat;
      if (teamOf(w) !== team) return false;
      return teamWinsAll(hands, w);
    }
    const seat = trick.length ? (trick[trick.length - 1].seat + 1) % 4 : leader;
    const legal = legalMoves(hands[seat], trick, mode, trump, seat);
    const mine = teamOf(seat) === team;
    for (const c of legal) {
      const nh = hands.map((h, i) => (i === seat ? h.filter((x) => !sameCard(x, c)) : h));
      const ok = trickOutcome(nh, leader, trick.concat([{ seat, card: c }]));
      if (mine && ok) return true;       // يكفي خيار واحد ناجح لفريقنا
      if (!mine && !ok) return false;    // خيار واحد يكسر الادعاء يكفي للخصم
    }
    return !mine; // فريقنا: ما فيه خيار ناجح → فشل. الخصم: كل خياراته فشلت بكسرنا → نجاح
  }
  return teamWinsAll(hands, claimSeat);
}

// إعلان سوا: مسموح فقط والدور عند المدّعي كقائد أكلة ويتبقى ≤ 4 أكلات.
// صحيح → فريقه ياخذ كل الأكلات المتبقية تلقائياً وتُحسب الصكة.
// خاطئ → "سوا خاطئ": فريقه يخسر الجولة كاملة فوراً (متل القيد الخايب).
export function claimSawa(match, seat) {
  const st = match.state;
  if (st.phase !== "playing") throw new Error("مو وقت السوا");
  if (st.turn !== seat || st.currentTrick.length) throw new Error("السوا بس لما تكون قائد الأكلة");
  const remaining = 8 - st.trickHistory.length;
  if (remaining > 4) throw new Error("السوا بس بآخر 4 أكلات");

  const valid = sawaGuaranteed(st, seat);
  // سوا صحيح: نلقط صورة الأيادي المتبقية لكل اللاعبين قبل ما تُستهلك — عشان تنكشف على
  // الطاولة للجميع (بند 29)، لأن الأكلات المتبقية تُبنى دفعة وحدة بدون أحداث "played" منفصلة
  const revealHands = valid ? st.hands.map((h) => h.slice()) : null;
  const events = [{ type: "sawaClaimed", seat, valid, remaining, hands: revealHands }];
  if (valid) {
    // فريق المدّعي ياخذ كل الأكلات المتبقية: نبنيها كأكلات محسومة له
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
    // سوا خاطئ: خسارة فورية للجولة لفريق المدّعي
    finishClaimedHand(match, events, {
      winTeam: 1 - teamOf(seat), loseTeam: teamOf(seat),
      qatClaim: { type: "sawa", typeName: VIOLATION_NAMES.sawa, failed: true, claimSeat: seat, violSeat: seat },
    });
  }
  checkMatchEnd(match, events);
  return events;
}

// إنهاء الصكة بحكم قيد/سوا: الفريق الرابح ياخذ قيد الجولة كاملاً والخاسر يحتفظ ببلوته فقط
export function finishClaimedHand(match, events, info) {
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
    qaid, pts: [0, 0], trickWins: [0, 0], capotTeam: null,
    buyerLost: true, safeSaved: false, projQaid: [0, 0], balootQaid,
    qatClaim: info.qatClaim, doubleLevel: mult,
  };
  st.phase = "handEnd";
  st.result = result;
  st.violation = null;
  events.push({ type: "handEnd", result });
}

export function checkMatchEnd(match, events) {
  if (match.totals[0] >= TARGET_QAID || match.totals[1] >= TARGET_QAID) {
    if (match.totals[0] !== match.totals[1]) {
      match.matchOver = true;
      match.winnerTeam = match.totals[0] > match.totals[1] ? 0 : 1;
      match.state.phase = "matchEnd";
      events.push({ type: "matchEnd", winnerTeam: match.winnerTeam });
    }
  }
}

// لعب ورقة
export function playCard(match, seat, card) {
  const st = match.state;
  if (st.phase !== "playing" || st.turn !== seat) throw new Error("مو دورك");
  const hand = st.hands[seat];
  const idx = hand.findIndex((c) => sameCard(c, card));
  if (idx === -1) throw new Error("الورقة مو عندك");
  const strict = (st.doubleLevel || 1) >= 2;
  const legal = legalMoves(hand, st.currentTrick, st.mode, st.trump, seat, strict);
  const isLegal = legal.some((c) => sameCard(c, card));
  if (!isLegal) {
    // الوضع الآمن: القطع ممنوع تماماً (زي القديم). الوضع العادي: نسمح فيه، بس يصير "قطع كامن" —
    // ما ينكشف وما يصير قابل للتقييد إلا لو نفس اللاعب رجع ولعب ورقة كانت لازم يلعبها هنا (دليل
    // علني إنه كان يقدر). ما حد، لا بوت ولا لاعب، يشوف يد غيره — كله مبني على اللي انلعب فعلاً.
    if (match.safeMode) throw new Error("حركة غير قانونية");
    st.pendingViolations.push({
      seat,
      card: { suit: card.suit, rank: card.rank },
      trickIndex: st.trickHistory.length,
      vtype: classifyViolation(hand, st.currentTrick, st.mode, st.trump, card, seat, st.doubleLevel),
      escaped: legal.map((c) => ({ suit: c.suit, rank: c.rank })),
    });
  }

  // تتبع الهروب (ما عنده اللون)
  if (st.currentTrick.length) {
    const led = st.currentTrick[0].card.suit;
    if (card.suit !== led) st.voids[seat].add(led);
  }

  hand.splice(idx, 1);
  st.currentTrick.push({ seat, card });
  st.playedCards.push(card);

  // lead = هل هذي أول ورقة في الأكلة؟
  const events = [{ type: "played", seat, card, lead: st.currentTrick.length === 1 }];

  // البلوت: شايب+بنت لون الحكم من نفس اللاعب بلعبتيه المتتاليتين (أكلة ثم اللي بعدها مباشرة).
  // يُنادى تلقائياً مع الورقة الثانية ويُحسب نقطتين لفريقه (مستقل عن المشاريع، حكم فقط).
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

  // هل هالورقة تكشف قطع كامن لنفس اللاعب؟ (لعب حق ورقة كانت "هاربة" بقطع سابق بنفس الصكة)
  for (const pv of st.pendingViolations) {
    if (pv.confirmed || pv.seat !== seat) continue;
    if (pv.escaped.some((e) => sameCard(e, card))) {
      pv.confirmed = true;
      st.violation = { seat: pv.seat, card: pv.card, trickIndex: pv.trickIndex, vtype: pv.vtype || "qatee", provedBy: { suit: card.suit, rank: card.rank } };
      events.push({ type: "violationRevealed", seat: pv.seat, card: pv.card, trickIndex: pv.trickIndex, provedBy: card });
    }
  }

  // المرحلة 1 — الأكلة الأولى: اللاعب "يذكر" مشاريعه بالاسم فقط وهو يلعب ورقته (بدون كشف ورق)
  if (st.trickHistory.length === 0 && st.pendingAnnounce.length) {
    const mine = st.pendingAnnounce.filter((p) => p.seat === seat);
    if (mine.length) {
      st.pendingAnnounce = st.pendingAnnounce.filter((p) => p.seat !== seat);
      const stamped = mine.map((m) => ({ seat: m.seat, name: m.name, type: m.type, at: Date.now() }));
      st.announcedProjects.push(...stamped);
      events.push({ type: "projectAnnounce", seat, names: mine.map((m) => m.name) });
    }
  }

  // المرحلة 2 — الأكلة الثانية: مشاريع الفريق الرابح بالمقارنة تنزل عالطاولة مع لعبة صاحبها
  if (st.trickHistory.length === 1 && st.pendingReveal.length) {
    const mine = st.pendingReveal.filter((p) => p.seat === seat);
    if (mine.length) {
      st.pendingReveal = st.pendingReveal.filter((p) => p.seat !== seat);
      const stamped = mine.map((m) => Object.assign({ at: Date.now() }, m));
      st.revealedProjects.push(...stamped);
      for (const p of mine) {
        // لو الورقة اللي لعبها الحين من نفس المشروع، ما نكررها بالعرض — هي أصلاً بايّنة بالأكلة
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
    st.violation = null; // ذابت فرصة التقييد بنهاية الأكلة
    events.push({ type: "trickEnd", winner, pts: trickPts, plays: finishedPlays });

    if (st.trickHistory.length === 8) {
      const result = scoreHand(match.state);
      match.totals[0] += result.qaid[0];
      match.totals[1] += result.qaid[1];
      match.handResults.push({
        mode: st.mode, trump: st.trump, buyer: st.buyer,
        qaid: result.qaid, buyerLost: result.buyerLost, capotTeam: result.capotTeam,
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

// مطالبة بالقيد (بنوعها): لو فيه قطع مكشوف من الفريق الثاني ونوع الادعاء مطابق للمخالفة
// الفعلية → المدّعي يكسب الجولة. غير كذا الادعاء "خايب" وفريق المدّعي يخسر الجولة كاملة فوراً.
// claimType اختياري للتوافق الخلفي (البوتات تدّعي بالنوع الصحيح تلقائياً).
export function claimQaid(match, claimingSeat, claimType) {
  const st = match.state;
  if (st.phase !== "playing") throw new Error("مو وقت القيد");
  const claimTeam = teamOf(claimingSeat);
  const v = st.violation;
  const correct = !!v && teamOf(v.seat) !== claimTeam && (!claimType || claimType === v.vtype);

  const events = [];
  if (correct) {
    finishClaimedHand(match, events, {
      winTeam: claimTeam, loseTeam: teamOf(v.seat),
      qatClaim: {
        type: v.vtype, typeName: VIOLATION_NAMES[v.vtype] || "قيد",
        failed: false, claimSeat: claimingSeat,
        violSeat: v.seat, winTeam: claimTeam,
        violCard: v.card, trickIndex: v.trickIndex, provedBy: v.provedBy,
      },
    });
  } else {
    // قيد خايب: ما فيه مخالفة مكشوفة، أو النوع غلط، أو يقيّد على فريقه
    finishClaimedHand(match, events, {
      winTeam: 1 - claimTeam, loseTeam: claimTeam,
      qatClaim: {
        type: claimType || "qatee", typeName: VIOLATION_NAMES[claimType] || "قيد",
        failed: true, claimSeat: claimingSeat,
        violSeat: claimingSeat, winTeam: 1 - claimTeam,
      },
    });
  }

  const qc = st.result.qatClaim;
  events.unshift({ type: "qatClaimed", seat: claimingSeat, violSeat: qc.violSeat, failed: qc.failed, typeName: qc.typeName });
  checkMatchEnd(match, events);
  return events;
}

export function nextHand(match, rng) {
  match.dealer = (match.dealer + 1) % 4;
  return startHand(match, rng);
}
