// منسّق اللعبة: يربط المحرك والبوتات بالعرض، ويدير حلقة اللعب (بشري + بوتات) محلياً
import * as E from "../engine/index.js";
import { decideBid, decidePlay, decideDouble, LEVELS } from "../bots.js";
import { $, sleep } from "./dom.js";
import {
  renderAll, renderScores, renderTrick, renderTrickCards,
  showBanner, updateQaidButton, updateSawaButton, vsFor,
} from "./render.js";
import {
  animateDeal, animatePlayedCard, animateTrickCollect, spawnConfetti,
  openSheet, closeSheet, showOverlay, hideOverlay,
} from "./animations.js";
import { trackHumanCard, trackTrick, trackHand, computeGrade, saveMatchStats, getStats } from "./grade.js";
import { S, botDelay } from "./state.js";
import { pushAction } from "../online.js";

const BOT_SAWA_CHANCE = { beginner: 0, amateur: 0.25, skilled: 0.6, pro: 0.9 };
const HUMAN_AFK_MS = 25000;
let humanTurnTimer = null;

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
      const legal = E.legalMoves(hand, st2.currentTrick, st2.mode, st2.trump, S.mySeat, strict);
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

// ===================== شاشة الإعداد =====================
export function initSetup() {
  document.body.classList.add("standalone");
  for (const sel of [$("level-1"), $("level-2"), $("level-3")]) {
    sel.innerHTML = "";
    for (const [level, label] of Object.entries(LEVELS)) {
      const opt = document.createElement("option");
      opt.value = level;
      opt.textContent = label;
      if (level === "skilled") opt.selected = true;
      sel.appendChild(opt);
    }
  }

  $("mode-safe").onclick = () => setMode(true);
  $("mode-ranked").onclick = () => setMode(false);
  setMode(true);

  $("start-match").onclick = startMatch;
  wireDialogs();
  wireMenu();
  renderSetupStats();
}

function setMode(safe) {
  S.safeMode = safe;
  $("mode-safe").classList.toggle("sel", safe);
  $("mode-ranked").classList.toggle("sel", !safe);
  $("mode-hint").textContent = safe
    ? "🛡️ آمن: لو اشتريت وطحت ما ينقطع فريقك — مريح للتعلّم"
    : "🔥 عادي: لعب حقيقي، وإذا قطعت ممكن يقيّدك الخصم";
}

export function renderSetupStats() {
  const s = getStats();
  if (!s.matches.length) return;
  const wins = s.matches.filter((m) => m.win).length;
  const last = s.matches[s.matches.length - 1];
  $("setup-stats").innerHTML = `📊 سجلك: <b>${wins}</b> فوز من <b>${s.matches.length}</b> · آخر تقدير: <b>${last.grade}</b>`;
}

export function showScreen(id) {
  for (const s of ["setup-screen", "online-screen", "lobby-screen"]) $(s).hidden = s !== id;
}

function startMatch() {
  const name = $("player-name").value.trim() || "أنا";
  S.players = [
    { name, isBot: false },
    { name: "بوت (يمين)", isBot: true, level: $("level-1").value },
    { name: "خويك", isBot: true, level: $("level-2").value },
    { name: "بوت (يسار)", isBot: true, level: $("level-3").value },
  ];
  S.match = E.createMatch({ players: S.players, safeMode: S.safeMode, autoDeclare: false });
  E.startHand(S.match);

  $("setup-screen").hidden = true;
  $("topbar").hidden = false;
  $("footer-bar").hidden = false;
  $("table-area").hidden = false;

  animateDeal([0, 1, 2, 3]);
  renderAll(S.match, S.mySeat, S.players, onHumanPlay);
  pump();
}

// ===================== القائمة =====================
export function wireMenu() {
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

// ===================== حلقة اللعب =====================
// حركة بوت مؤجَّلة (بعد sleep) قد تصير غير صالحة لو حركة بشرية سبقتها بنفس الفترة (سباق
// نادر لكنه ممكن). نتحقق إنها لسا صالحة بدل ما نفترض — ونعيد ضخ الحلقة من الحالة الحقيقية
// دايماً بدل ما نكسرها بخطأ غير ممسوك.
async function safePump(run) {
  try { await handleEvents(run()); }
  catch (err) { console.warn("[baloot] حركة بوت أصبحت غير صالحة (سباق) — تُجوهل:", err && err.message); }
  renderAll(S.match, S.mySeat, S.players, onHumanPlay);
  return pump();
}

async function pump() {
  if (!S.match || S.match.matchOver) return;
  clearHumanTurnTimer();
  const st = S.match.state;
  if (st.phase === "handEnd" || st.phase === "matchEnd") return;

  if (st.awaitingDeclare) {
    const seat = st.declareSeats[0];
    if (seat === S.mySeat) { showDeclareDialog(); startHumanTurnTimer(); return; }
    await sleep(botDelay());
    const types = st.projects.filter((p) => p.seat === seat).map((p) => p.type);
    return safePump(() => { E.declareProject(S.match, seat, types); return []; });
  }

  if (st.awaitingDouble) {
    const seat = st.doubling.turn;
    if (seat === S.mySeat) { showDoubleDialog(); startHumanTurnTimer(); return; }
    await sleep(botDelay());
    const wants = decideDouble(S.match, seat, S.players[seat].level);
    return safePump(() => E.applyDouble(S.match, seat, wants ? { type: "double" } : { type: "pass" }));
  }

  if (st.phase === "bidding") {
    const seat = st.bidding.turn;
    if (seat === S.mySeat) { showBidDialog(); startHumanTurnTimer(); return; }
    await sleep(botDelay());
    const action = decideBid(S.match, seat, S.players[seat].level);
    return safePump(() => E.applyBid(S.match, seat, action));
  }

  if (st.phase === "playing") {
    updateQaidButton(canClaimQaid());
    updateSawaButton(canClaimSawa());
    if (await maybeBotClaims()) return;
    const seat = st.turn;
    if (seat === S.mySeat) { renderAll(S.match, S.mySeat, S.players, onHumanPlay); startHumanTurnTimer(); return; }
    await sleep(botDelay());
    const card = decidePlay(S.match, seat, S.players[seat].level);
    await playCardFlow(seat, card);
    if (!S.match.matchOver && S.match.state.phase === "playing") return pump();
    if (S.match.state.phase === "bidding" || S.match.state.awaitingDouble || S.match.state.awaitingDeclare) return pump();
  }
}

function canClaimQaid() {
  const st = S.match.state;
  return !!st.violation && E.teamOf(st.violation.seat) !== E.teamOf(S.mySeat);
}
function canClaimSawa() {
  const st = S.match.state;
  return st.turn === S.mySeat && st.currentTrick.length === 0 && (8 - st.trickHistory.length) <= 4;
}

async function maybeBotClaims() {
  const st = S.match.state;
  if (st.violation) {
    for (let s = 0; s < 4; s++) {
      if (s === S.mySeat || E.teamOf(s) === E.teamOf(st.violation.seat)) continue;
      if (Math.random() < botQaidChance(S.players[s].level, st.trickHistory.length)) {
        await sleep(botDelay());
        try { await handleEvents(E.claimQaid(S.match, s, st.violation.vtype)); }
        catch (err) { console.warn("[baloot] قيد بوت أصبح غير صالح (سباق) — تُجوهل:", err && err.message); }
        renderAll(S.match, S.mySeat, S.players, onHumanPlay);
        return true;
      }
    }
  }
  if (st.currentTrick.length === 0 && (8 - st.trickHistory.length) <= 4) {
    const seat = st.turn;
    if (seat !== S.mySeat && Math.random() < (BOT_SAWA_CHANCE[S.players[seat].level] || 0) && E.sawaGuaranteed(st, seat)) {
      await sleep(botDelay());
      try { await handleEvents(E.claimSawa(S.match, seat)); }
      catch (err) { console.warn("[baloot] سوا بوت أصبح غير صالح (سباق) — تُجوهل:", err && err.message); }
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
    events = E.playCard(S.match, seat, card);
  } catch (err) {
    // سباق (مثلاً ضغطة بشرية جت وقت دور بوت أصلاً) — نتجاهل ونعيد رسم الحالة الحقيقية
    console.warn("[baloot] لعب ورقة مرفوض (سباق/تكرار) — تُجوهل:", err && err.message);
    renderAll(S.match, S.mySeat, S.players, onHumanPlay);
    return;
  }
  const trickEndEv = events.find((e) => e.type === "trickEnd");
  // بالورقة الرابعة المحرك يفرّغ currentTrick فوراً — لازم نرسم الأكلة المكتملة (ev.plays)
  // وإلا "فوز الأكلة" ما يترسم أبداً ويختفي الورق بدون أنيميشن جمع.
  if (trickEndEv) renderTrickCards(trickEndEv.plays, S.mySeat);
  else renderTrick(S.match, S.mySeat);
  const zone = $("trick-zone");
  const played = zone.querySelector(".bt-played-card:last-child");
  if (played) animatePlayedCard(played);
  await sleep(120);
  await handleEvents(events);
  renderAll(S.match, S.mySeat, S.players, onHumanPlay);
}

export async function onHumanPlay(card) {
  clearHumanTurnTimer();
  if (S.online && !S.online.isHost) {
    // عميل: يدفع الحركة للمضيف بدل ما يشغّل المحرك محلياً (العميل ما يشغّل المحرك أبداً)
    if (S.awaitingServerAck) return;
    S.awaitingServerAck = true;
    pushAction(S.online.code, { type: "play", seat: S.mySeat, card });
    return;
  }
  await playCardFlow(S.mySeat, card);
  if (S.online && S.online.isHost) { S.online.syncSnapshot(); S.online.hostPump(); return; }
  if (!S.match.matchOver && S.match.state.phase !== "handEnd") pump();
}

// ===================== أحداث المحرك -> بانرات وأنيميشن =====================
export async function handleEvents(events) {
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
      // لو نفس هالأحداث فيها matchEnd كمان (آخر صكة بالمباراة)، ما نعرض نتيجة الصكة —
      // نروح مباشرة لنافذة نهاية المباراة، وإلا تضل نافذة الصكة عالقة تحت نافذة المباراة
      // (فوق بعض، ما توصل لزر "كمّل" أبداً — نافذة نهاية المباراة تغطيها بالكامل).
      if (!events.some((e) => e.type === "matchEnd")) showHandOverlay(ev.result);
    } else if (ev.type === "matchEnd") {
      await sleep(400);
      showMatchOverlay();
    }
  }
}

function bidSay(ev) { return ev.say; }

// ===================== حوار المزايدة =====================
export function showBidDialog() {
  const st = S.match.state;
  const dealer = S.match.dealer;
  const ashkalEligible = S.mySeat === dealer || S.mySeat === (dealer + 3) % 4;
  $("bid-ashkal").hidden = !(st.bidding.round === 1 && ashkalEligible);
  $("bid-title").textContent = st.bidding.round === 1 ? "دورك بالشراء" : "الجولة الثانية";
  $("suit-pick").innerHTML = "";
  $("suit-pick").hidden = true;
  openSheet("bid-dialog");
}

// حركة بشرية قد تتصادم مع دورة بوت شغّالة أصلاً (سباق) أو تُضغط مرتين بسرعة (تكرار) —
// المحرك يرفضها بخطأ (مو دورك/مو وقت...) وهذا صحيح ومتوقع؛ نتجاهلها بأمان بدل ما نكسر
// الواجهة، ونعيد رسم الحالة الحقيقية دايماً حتى لو الحركة انرفضت.
async function safeAct(run, remoteAction) {
  if (S.online && !S.online.isHost) {
    // عميل: يدفع الحركة للمضيف — العميل ما يشغّل المحرك أبداً، وما يعيد الدفع لو رد المضيف
    // (لقطة جديدة) لسا ما وصل، يمنع سبام/دبل-تاب يرسل نفس القرار مرتين.
    if (S.awaitingServerAck) return;
    S.awaitingServerAck = true;
    pushAction(S.online.code, { seat: S.mySeat, ...remoteAction });
    return;
  }
  try {
    await handleEvents(run());
  } catch (err) {
    console.warn("[baloot] حركة مرفوضة (سباق/تكرار) — تُجوهلت:", err && err.message);
  }
  renderAll(S.match, S.mySeat, S.players, onHumanPlay);
  if (S.online && S.online.isHost) { S.online.syncSnapshot(); S.online.hostPump(); return; }
  pump();
}

function humanBid(action) {
  clearHumanTurnTimer();
  closeSheet("bid-dialog");
  safeAct(() => E.applyBid(S.match, S.mySeat, action), { type: "bid", bid: action });
}

export function wireDialogs() {
  $("bid-pass").onclick = () => humanBid({ type: "pass" });
  $("bid-sun").onclick = () => humanBid({ type: "sun" });
  $("bid-ashkal").onclick = () => humanBid({ type: "ashkal" });
  $("bid-hokum").onclick = () => {
    const st = S.match.state;
    if (st.bidding.round === 1) { humanBid({ type: "hokum" }); return; }
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

  $("qaid-btn").onclick = () => openSheet("qaid-pick");
  $("qaid-cancel").onclick = () => closeSheet("qaid-pick");
  $("sawa-btn").onclick = () => safeAct(() => E.claimSawa(S.match, S.mySeat), { type: "sawa" });

  $("continue-btn").onclick = () => {
    hideOverlay("hand-overlay");
    if (S.online) {
      if (!S.online.isHost) return; // العميل بس يسكّر نافذته — المضيف هو اللي يتقدّم فعلياً للجميع
      if (S.match.matchOver) return;
      E.nextHand(S.match);
      renderAll(S.match, S.mySeat, S.players, onHumanPlay);
      animateDeal([0, 1, 2, 3]);
      S.online.syncSnapshot();
      S.online.hostPump();
      return;
    }
    if (S.match.matchOver) return;
    E.nextHand(S.match);
    renderAll(S.match, S.mySeat, S.players, onHumanPlay);
    animateDeal([0, 1, 2, 3]);
    pump();
  };

  $("again-btn").onclick = () => {
    hideOverlay("match-overlay");
    if (S.online) { S.online.leaveOnline(); return; }
    S.match = null;
    $("topbar").hidden = true;
    $("table-area").hidden = true;
    $("footer-bar").hidden = true;
    $("setup-screen").hidden = false;
    renderSetupStats();
  };

  const qaidList = $("qaid-pick-list");
  qaidList.innerHTML = "";
  for (const [type, name] of Object.entries(E.VIOLATION_NAMES)) {
    if (type === "sawa") continue;
    const b = document.createElement("button");
    b.className = "bt-btn bt-btn--danger";
    b.textContent = name;
    b.onclick = () => {
      closeSheet("qaid-pick");
      safeAct(() => E.claimQaid(S.match, S.mySeat, type), { type: "qaid", claimType: type });
    };
    qaidList.appendChild(b);
  }
}

function humanDouble(action) {
  clearHumanTurnTimer();
  closeSheet("double-dialog");
  safeAct(() => E.applyDouble(S.match, S.mySeat, action), { type: "double", double: action });
}

export function showDoubleDialog() {
  const stage = S.match.state.doubling.stage;
  $("double-title").textContent = { offer: "تبي تعلن دبل؟", redouble: "تبي ترد بتربل؟", recoat: "تبي توصل كوت؟" }[stage] || "تبي تدبل؟";
  openSheet("double-dialog");
}

export function showDeclareDialog() {
  const mine = S.match.state.projects.filter((p) => p.seat === S.mySeat);
  const list = $("declare-list");
  list.innerHTML = "";
  const types = [...new Set(mine.map((p) => p.type))];
  for (const type of types) {
    const b = document.createElement("button");
    b.className = "bt-btn bt-btn--gold";
    b.textContent = E.PROJECT_NAMES[type];
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
    S.awaitingServerAck = true;
    pushAction(S.online.code, { type: "declare", seat: S.mySeat, claimedTypes: types });
    return;
  }
  try { E.declareProject(S.match, S.mySeat, types); }
  catch (err) { console.warn("[baloot] إعلان مرفوض (سباق/تكرار) — تُجوهل:", err && err.message); }
  renderAll(S.match, S.mySeat, S.players, onHumanPlay);
  if (S.online && S.online.isHost) { S.online.syncSnapshot(); S.online.hostPump(); return; }
  pump();
}

// ===================== نهاية الصكة / المباراة =====================
function showHandOverlay(result) {
  const st = S.match.state;
  const label = st.ashkal ? "أشكل 🔄" : st.mode === "sun" ? "صن ☀️" : `حكم ${st.trump}`;
  const dblLabel = { 2: " · دبل ×2", 3: " · تربل ×3", 4: " · كوت ×4" }[st.doubleLevel] || "";
  $("hand-title").textContent = `نتيجة الصكة — ${label}${dblLabel}`;
  const rows = [];
  if (result.qatClaim) {
    rows.push(`<div class="row">${result.qatClaim.failed ? "قيد خايب ⚠️" : `قيّده: ${result.qatClaim.typeName}`}</div>`);
  }
  const myTeam = E.teamOf(S.mySeat);
  if (result.sawa) rows.push(`<div class="row">سوا! فريق ${E.teamOf(result.sawa.seat) === myTeam ? "لنا" : "لهم"} أخذ كل الباقي</div>`);
  if (result.capotTeam != null) rows.push(`<div class="row">كبوت! 🎯</div>`);
  rows.push(`<div class="row"><span>قيد الصكة</span><b>لنا ${result.qaid[myTeam]} — لهم ${result.qaid[1 - myTeam]}</b></div>`);
  if (result.buyerLost) rows.push(`<div class="row">المشتري خسر (دخلة) — الخصم ياخذ القيد</div>`);
  if (result.safeSaved) rows.push(`<div class="row">🛡️ الوضع الآمن حماكم من القطع</div>`);
  $("hand-detail").innerHTML = rows.join("");
  renderScores(S.match, S.mySeat);
  showOverlay("hand-overlay");
}

function showMatchOverlay() {
  const myTeam = E.teamOf(S.mySeat);
  const won = S.match.winnerTeam === myTeam;
  const g = computeGrade(S.match, S.mySeat);
  $("match-title").textContent = won ? "🏆 مبروك! كسبتوا الصكة" : "😔 خسرتوها هالمرة";
  $("match-score").innerHTML = `<b style="font-size:1.4rem">${S.match.totals[myTeam]} — ${S.match.totals[1 - myTeam]}</b>`;
  $("grade-circle").textContent = g.grade;
  $("grade-comment").textContent = g.comment;

  const m = S.match.metrics;
  const rows = [
    ["قيدكم من الكل", Math.round(g.qaidShare * 100) + "%"],
    ["الأكلات اللي أخذتوها", Math.round(g.trickShare * 100) + "%"],
    ["شراياتك اللي نجحت", m.humanBids ? `${m.humanBidWins} من ${m.humanBids}` : "ما شريت"],
    ["نقاط فرّطتها للخصم", m.pointMistakes],
    ["أكلات فاتتك", m.missedWins],
    ["عدد الصكات", S.match.handsPlayed],
  ];
  $("analysis").innerHTML = rows.map(([k, v]) => `<div class="row"><span>${k}</span><b>${v}</b></div>`).join("");

  const s = saveMatchStats(S.match, S.safeMode, S.mySeat);
  const wins = s.matches.filter((x) => x.win).length;
  $("save-note").textContent = `✓ انحفظت بسجلك: ${wins} فوز من ${s.matches.length} صكة`;

  if (won) spawnConfetti();
  showOverlay("match-overlay");
}
