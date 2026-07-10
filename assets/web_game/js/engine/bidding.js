import { teamOf } from "./cards.js";
import { findProjects } from "./projects.js";
import { startHand, finalizeProjects } from "./match.js";

// تنفيذ مزايدة: action = {type:'pass'|'hokum'|'sun'|'ashkal'}
// القوانين: الجولة 1 = بس/حكم/صن/أشكل، الجولة 2 = ولا/حكم ثاني/صن. الصن تنهي المزايدة فوراً.
export function applyBid(match, seat, action, rng) {
  const st = match.state;
  const b = st.bidding;
  if (seat !== b.turn) throw new Error("مو دورك بعد");
  const events = [];

  // الصن تنهي المزايدة على طول (أعلى شي)
  if (action.type === "sun") {
    b.best = { type: "sun", seat };
    events.push({ type: "bid", seat, say: "صن" });
    finalizeBid(match, events);
    return events;
  }

  // الأشكل: بس للموزع أو آخر واحد قبله بالدور (dealer+3)، وبس بالجولة الأولى.
  // يلعب متل الصن، بس الورقة المكشوفة تروح لخوي المشتري بدل ما تروح له.
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
    if (!b.best) b.best = { type: "hokum", seat, suit }; // أول حكم ياخذها، ما ينلغى بحكم ثاني
    events.push({ type: "bid", seat, say: b.round === 1 ? "حكم" : "حكم ثاني" });
  } else {
    // بس بالجولة الأولى، ولا بالجولة الثانية
    events.push({ type: "bid", seat, say: b.round === 1 ? "بس" : "ولا" });
  }

  b.spoken++;
  if (b.spoken === 4) {
    if (b.best) {
      finalizeBid(match, events);
    } else if (b.round === 1) {
      b.round = 2; b.spoken = 0; b.turn = st.firstPlayer; b.best = null;
      events.push({ type: "round2" }); // ما حد شرا → الجولة الثانية
    } else {
      // الكل بس/ولا → توزيع جديد
      match.dealer = (match.dealer + 1) % 4;
      startHand(match, rng);
      events.push({ type: "redeal" });
    }
  } else {
    b.turn = (b.turn + 1) % 4;
  }
  return events;
}

export function finalizeBid(match, events) {
  const st = match.state;
  const best = st.bidding.best;
  st.buyer = best.seat;
  st.ashkal = best.type === "ashkal";
  st.mode = st.ashkal ? "sun" : best.type; // الأشكل يلعب متل الصن (بدون حكم)
  st.trump = best.type === "hokum" ? best.suit : null;

  // اللي يستلم الورقة المكشوفة ياخذ +2 من الباقي، والبقية 3 لكل واحد — عادي المستلم هو
  // المشتري، وبالأشكل المستلم خوي المشتري (فياخذ الخوي +2 والمشتري نفسه +3، والكل يطلع 8)
  const topRecipient = st.ashkal ? (st.buyer + 2) % 4 : st.buyer;
  let ri = 0;
  st.hands[topRecipient].push(st.rest[ri++], st.rest[ri++]);
  for (let p = 0; p < 4; p++) {
    if (p === topRecipient) continue;
    st.hands[p].push(st.rest[ri++], st.rest[ri++], st.rest[ri++]);
  }
  st.hands[topRecipient].push(st.topCard);

  // كشف المشاريع تلقائياً
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

  // باب الدبل: يفتح مباشرة بعد حسم الشراء. المتكلم الأول فريق الخصم (buyer+1 دايماً بالفريق
  // المقابل لأن المقاعد تتبادل فرق). ما يمنع اللعب بالمحرك (متل الإعلان) — بس شرط UI/pump.
  // بالحكم: الباب مفتوح دايماً ويسمح بتسلسل كامل (دبل→تربل→فور→قهوة).
  // بالصن: يسمح فقط بـ"دبل" (بدون تصعيد)، وفقط لو فريق المشتري تجاوز 100 قيد بالصكة
  // وفريق الخصم (اللي بيدبل) 100 أو أقل — قاعدة رسمية موثّقة، خلاف الحكم اللي يفتح دايماً.
  st.doubleLevel = 1;
  st.doubleTeam = null;
  const buyerTeam = teamOf(st.buyer);
  const oppTeam = 1 - buyerTeam;
  const sunDoubleAllowed = st.mode === "hokum" ||
    (match.totals[buyerTeam] > 100 && match.totals[oppTeam] <= 100);
  if (sunDoubleAllowed) {
    st.awaitingDouble = true;
    st.doubling = { turn: (st.buyer + 1) % 4, stage: "offer", nextLevel: 2 };
    events.push({ type: "doubleOpen", turn: st.doubling.turn, stage: "offer" });
  } else {
    st.awaitingDouble = false;
    st.doubling = null;
  }

  // كل لاعب حقيقي عنده مشاريع فعلية يقرر بنفسه يعلنها أو لا. اللي ما عنده أي مشروع
  // ما يوقف عنده اللعب أبداً (لا شاشة ولا زر). البوتات دايم تعلن مشاريعها تلقائياً.
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

// مزايدة الدبل: action = {type:'double'|'pass'}. الدور يتبادل بين متكلم فريق الخصم (buyer+1)
// ومتكلم فريق المشتري (buyer) بكل مرحلة: عرض (×2) → رد (×3) → كوت (×4). أول تمرير يقفل الباب
// عند آخر مستوى متفق عليه؛ الوصول للكوت (×4) يقفله تلقائياً.
export function applyDouble(match, seat, action) {
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
    // بالصن: دبل بس بدون تصعيد (تربل/فور/قهوة ممنوعة بالصن حسب اللائحة الرسمية)
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
