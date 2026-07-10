// عرض حالة المباراة على DOM — دوال قراءة فقط (state -> DOM)، بدون أي منطق لعبة
import { $ } from "./dom.js";
import { cardEl, cardBackEl, sortHand } from "./cards.js";
import { TARGET_QAID, legalMoves } from "../engine/index.js";

export const vsFor = (mySeat) => (actual) => (actual - mySeat + 4) % 4;

export function renderScores(match, mySeat = 0) {
  const myTeam = mySeat % 2;
  const us = match.totals[myTeam], them = match.totals[1 - myTeam];
  $("score-us").textContent = us;
  $("score-them").textContent = them;
  $("bar-us").style.width = Math.min(100, (us / TARGET_QAID) * 100) + "%";
  $("bar-them").style.width = Math.min(100, (them / TARGET_QAID) * 100) + "%";
}

function levelBadge(level) {
  return { beginner: "مبتدئ 🐣", amateur: "نص نص", skilled: "شاطر", pro: "وحش 🔥" }[level] || "";
}

function activeSeat(st) {
  if (!st) return null;
  if (st.awaitingDeclare) return (st.declareSeats || [])[0];
  if (st.awaitingDouble) return st.doubling.turn;
  if (st.phase === "bidding") return st.bidding.turn;
  if (st.phase === "playing") return st.turn;
  return null;
}

export function renderSeats(match, mySeat, players) {
  const st = match.state;
  const vs = vsFor(mySeat);
  const active = activeSeat(st);
  for (let seat = 0; seat < 4; seat++) {
    const pos = vs(seat);
    const seatEl = $("seat-" + pos);
    if (!seatEl) continue;
    seatEl.classList.toggle("is-turn", active === seat);
    seatEl.classList.toggle("is-dealer", match.dealer === seat);

    const nameEl = seatEl.querySelector(".bt-pname");
    const levelEl = seatEl.querySelector(".bt-plevel");
    if (nameEl) nameEl.textContent = players[seat] ? players[seat].name : "";
    if (levelEl) levelEl.textContent = players[seat] && players[seat].isBot ? levelBadge(players[seat].level) : "";

    const hukumBadge = seatEl.querySelector(".bt-hukum-badge");
    if (hukumBadge) {
      const showTrump = st && st.mode === "hokum" && st.buyer === seat;
      hukumBadge.hidden = !showTrump;
      if (showTrump) hukumBadge.textContent = st.trump;
    }

    if (pos !== 0) {
      const backs = seatEl.querySelector(".bt-backs");
      if (backs) {
        const count = st ? (st.hands[seat] ? st.hands[seat].length : 0) : 0;
        backs.innerHTML = "";
        for (let i = 0; i < Math.min(count, 8); i++) backs.appendChild(cardBackEl());
      }
    }

    const projs = seatEl.querySelector(".bt-projs");
    if (projs) {
      projs.innerHTML = "";
      const mine = (st.announcedProjects || []).filter((p) => p.seat === seat);
      for (const p of mine) {
        const chip = document.createElement("span");
        chip.className = "bt-proj-chip";
        chip.textContent = p.name;
        projs.appendChild(chip);
      }
    }
  }
}

export function renderHand(match, mySeat, onPlay) {
  const st = match.state;
  const handEl = $("hand");
  handEl.innerHTML = "";
  if (!st || st.phase !== "playing") return;
  const hand = sortHand(st.hands[mySeat], st.trump);
  const strict = (st.doubleLevel || 1) >= 2;
  let legal = [];
  if (st.turn === mySeat) {
    // نفس بوابة legalMoves بالمحرك بالضبط — العرض والتفعيل يعتمدان عليها حصراً
    legal = legalMoves(hand, st.currentTrick, st.mode, st.trump, mySeat, strict);
  }
  for (const c of hand) {
    const isLegal = st.turn === mySeat && legal.some((l) => l.suit === c.suit && l.rank === c.rank);
    const card = cardEl(c, isLegal ? "is-legal" : "");
    if (isLegal) card.addEventListener("click", () => onPlay(c));
    handEl.appendChild(card);
  }
}

const TRICK_ANCHORS = {
  0: { top: "78%", left: "50%" },
  1: { top: "50%", left: "80%" },
  2: { top: "18%", left: "50%" },
  3: { top: "50%", left: "20%" },
};

/** يرسم مجموعة لعبات (plays: [{seat,card}]) بالوسط — تُستخدم للأكلة الحيّة ولعرض أكلة
    اكتملت لتوّها (trickEnd) بعد ما المحرك يكون فرّغ currentTrick أصلاً */
export function renderTrickCards(plays, mySeat) {
  const zone = $("trick-zone");
  zone.innerHTML = "";
  const vs = vsFor(mySeat);
  for (const play of plays) {
    const pos = vs(play.seat);
    const a = TRICK_ANCHORS[pos];
    const card = cardEl(play.card, "bt-played-card");
    card.style.top = a.top;
    card.style.left = a.left;
    card.style.transform = "translate(-50%,-50%)";
    zone.appendChild(card);
  }
}

export function renderTrick(match, mySeat) {
  if (!match.state) return;
  renderTrickCards(match.state.currentTrick, mySeat);
}

export function renderBidCenter(match) {
  const st = match.state;
  const center = $("bid-center");
  if (!st || st.phase !== "bidding") { center.hidden = true; return; }
  center.hidden = false;
  const slot = $("top-card-slot");
  slot.innerHTML = "";
  slot.appendChild(cardEl(st.topCard));
  $("bid-hint").textContent = st.bidding.round === 1 ? "الجولة الأولى" : "الجولة الثانية";
}

export function setBuyerBadge(match) {
  const st = match.state;
  const badge = $("buyer-badge");
  if (!st || st.buyer == null || st.phase === "bidding") { badge.textContent = ""; return; }
  const modeTxt = st.mode === "hokum" ? `حكم ${st.trump}` : "صن";
  badge.textContent = modeTxt;
}

export function showBanner(text, ms = 1600) {
  const b = $("center-banner");
  b.textContent = text;
  b.classList.add("show");
  clearTimeout(b._t);
  b._t = setTimeout(() => b.classList.remove("show"), ms);
}

export function updateQaidButton(show) { $("qaid-btn").hidden = !show; }
export function updateSawaButton(show) { $("sawa-btn").hidden = !show; }

export function renderAll(match, mySeat, players, onPlay) {
  renderScores(match, mySeat);
  renderSeats(match, mySeat, players);
  renderHand(match, mySeat, onPlay);
  renderTrick(match, mySeat);
  renderBidCenter(match);
  setBuyerBadge(match);
}
