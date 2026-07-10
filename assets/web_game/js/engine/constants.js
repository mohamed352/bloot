// ثوابت قواعد البلوت: الألوان، الرتب، ترتيب القوة، قيم النقاط، قيم المشاريع.

export const SUITS = ["♠", "♥", "♦", "♣"];
export const RANKS = ["7", "8", "9", "10", "J", "Q", "K", "A"];

// الترتيب الطبيعي (يُستخدم لاكتشاف تسلسلات المشاريع: سرا/خمسين/مية)
export const NATURAL = ["7", "8", "9", "10", "J", "Q", "K", "A"];

// قوة الأوراق من الأضعف للأقوى
export const SUN_ORDER = ["7", "8", "9", "J", "Q", "K", "10", "A"];
export const HOKUM_TRUMP_ORDER = ["7", "8", "Q", "K", "10", "A", "9", "J"];

export const SUN_PTS = { A: 11, "10": 10, K: 4, Q: 3, J: 2, "9": 0, "8": 0, "7": 0 };
export const HOKUM_TRUMP_PTS = { J: 20, "9": 14, A: 11, "10": 10, K: 4, Q: 3, "8": 0, "7": 0 };
export const HOKUM_PLAIN_PTS = SUN_PTS;

// قيم المشاريع بالقيد — نفس الأنواع بالصن والحكم (بند 50 بـTASKS.md)، فرق وحيد: الأربعمية
// تنزل لقيمة المية (20) بالحكم بدل قيمتها الكاملة (40) بالصن. البلوت مستقل تماماً عن هذا الجدول.
export const PROJECT_QAID = {
  hokum: { sira: 4, fifty: 10, hundred: 20, fourAces: 20 },
  sun: { sira: 4, fifty: 10, hundred: 20, fourAces: 40 },
};
export const PROJECT_NAMES = { sira: "سرا", fifty: "خمسين", hundred: "مية", fourAces: "أربعمية" };
export const BALOOT_QAID = 2;

export const TARGET_QAID = 152;
