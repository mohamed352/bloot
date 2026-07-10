// أنيميشن اللعبة — transform/opacity فقط، مبني على rAF/CSS transitions (بدون تخطيط يهتز)
import { $ } from "./dom.js";

const SEAT_ANCHOR = { 0: [50, 82], 1: [82, 50], 2: [50, 18], 3: [18, 50] };

/** توزيع الورق: كل مقعد يشوف أوراقه "تطير" من الوسط لمكانه، بتتابع بسيط */
export function animateDeal(positions) {
  const table = document.querySelector(".bt-table-area");
  if (!table) return;
  for (const pos of positions) {
    const seatEl = $("seat-" + pos);
    if (!seatEl) continue;
    seatEl.animate(
      [
        { transform: "translateY(10px) scale(.9)", opacity: 0.4 },
        { transform: "translateY(0) scale(1)", opacity: 1 },
      ],
      { duration: 260, easing: "cubic-bezier(.34,1.56,.64,1)", delay: pos * 70 },
    );
  }
}

/** ورقة تُلعب: تنبض قليلاً بمكانها بالسوق (مكانها الفعلي محسوب أصلاً بـrender.renderTrick) */
export function animatePlayedCard(cardEl) {
  cardEl.animate(
    [
      { transform: "translate(-50%,-50%) scale(.55)", opacity: 0.2 },
      { transform: "translate(-50%,-50%) scale(1.08)", opacity: 1, offset: .7 },
      { transform: "translate(-50%,-50%) scale(1)", opacity: 1 },
    ],
    { duration: 260, easing: "cubic-bezier(0,0,.2,1)" },
  );
}

/** جمع الأكلة نحو الرابح ثم اختفاء */
export function animateTrickCollect(winnerPos) {
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
          { transform: `translate(${wx - 50}vw, ${wy - 50}vh) scale(.4)`, opacity: 0 },
        ],
        { duration: 340, easing: "cubic-bezier(.4,0,1,1)", delay: i * 30, fill: "forwards" },
      );
      anim.onfinish = () => { done++; if (done === cards.length) resolve(); };
    });
    const seatEl = $("seat-" + winnerPos);
    if (seatEl) {
      seatEl.animate(
        [{ filter: "brightness(1)" }, { filter: "brightness(1.6)" }, { filter: "brightness(1)" }],
        { duration: 420 },
      );
    }
  });
}

/** فقاعة قصف ذهبية للانتصار */
export function spawnConfetti(count = 60) {
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

export function openSheet(id) { $(id).classList.add("open"); }
export function closeSheet(id) { $(id).classList.remove("open"); }

export function showOverlay(id) { $(id).classList.add("show"); }
export function hideOverlay(id) { $(id).classList.remove("show"); }
