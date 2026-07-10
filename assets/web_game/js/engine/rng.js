// مولّد أرقام عشوائية بذور قابل للتكرار (mulberry32) — يسمح بإعادة إنتاج نفس التوزيع
// بنفس البذرة، وهو أساس حتمية الاختبارات (نفس البذرة = نفس الصكة دايماً).

/** @returns {() => number} دالة عشوائية بذور (0..1)، بديل حتمي عن Math.random */
export function seededRng(seed) {
  let a = seed >>> 0 || 1;
  return function rng() {
    a |= 0;
    a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

/** خلط Fisher-Yates؛ rng اختياري — لو ما تحدد وحدة يستخدم Math.random (غير حتمي) */
export function shuffle(arr, rng) {
  const a = arr.slice();
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor((rng ? rng() : Math.random()) * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}
