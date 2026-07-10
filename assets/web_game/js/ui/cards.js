// عرض الأوراق: ملف الصورة، وصف قارئ الشاشة، وبناء عنصر DOM للورقة
import { el } from "./dom.js";

const SUIT_FILE = { "♠": "S", "♥": "H", "♦": "D", "♣": "C" };
const RANK_NAME_AR = { "7": "سبعة", "8": "ثمانية", "9": "تسعة", "10": "عشرة", J: "جاك", Q: "بنت", K: "شايب", A: "أص" };
const SUIT_NAME_AR = { "♠": "سباتي", "♥": "قلب", "♦": "ديناري", "♣": "كلاوب" };

export function cardFace(card) {
  return "assets/cards/" + card.rank + SUIT_FILE[card.suit] + ".svg";
}

export function cardLabel(card) {
  return (RANK_NAME_AR[card.rank] || card.rank) + " " + (SUIT_NAME_AR[card.suit] || card.suit);
}

export function cardEl(card, extraClass) {
  const d = el("div", "bt-card" + (extraClass ? " " + extraClass : ""), {
    role: "img", "aria-label": cardLabel(card),
  });
  const img = el("img", "bt-card-face");
  img.src = cardFace(card);
  img.alt = "";
  img.draggable = false;
  d.appendChild(img);
  return d;
}

export function cardBackEl() {
  return el("div", "bt-card-back");
}

/** ترتيب اليد للعرض: حسب اللون ثم القوة الطبيعية — نفس اليد بنفس الترتيب كل مرة (بدون ترجرج) */
export function sortHand(hand, trump) {
  const suitOrder = ["♠", "♥", "♦", "♣"];
  const NATURAL = ["7", "8", "9", "10", "J", "Q", "K", "A"];
  return hand.slice().sort((a, b) => {
    if (a.suit !== b.suit) {
      if (trump) {
        if (a.suit === trump && b.suit !== trump) return -1;
        if (b.suit === trump && a.suit !== trump) return 1;
      }
      return suitOrder.indexOf(a.suit) - suitOrder.indexOf(b.suit);
    }
    return NATURAL.indexOf(a.rank) - NATURAL.indexOf(b.rank);
  });
}
