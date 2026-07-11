/* الأصوات: نطق عربي مولّد (Web Speech API) + مؤثرات (WebAudio) */
(function () {
  "use strict";

  const settings = (() => {
    try {
      return {
        voice: localStorage.getItem("baloot-voice") !== "off",
        sfx: localStorage.getItem("baloot-sfx") !== "off",
      };
    } catch (e) {
      return { voice: true, sfx: true };
    }
  })();

  let arVoice = null;
  function pickVoice() {
    if (!("speechSynthesis" in window)) return;
    const vs = speechSynthesis.getVoices();
    if (!vs.length) return;
    // نفضّل أصوات ويندوز/أندرويد العربية الجيدة بالاسم، وإلا أي صوت عربي
    const byName = vs.find((v) => /naayf|hamed|hoda|salim|arabic|عربي/i.test(v.name || ""));
    arVoice =
      byName ||
      vs.find((v) => v.lang === "ar-SA") ||
      vs.find((v) => v.lang && v.lang.toLowerCase().startsWith("ar")) ||
      null;
  }
  if ("speechSynthesis" in window) {
    pickVoice();
    speechSynthesis.onvoiceschanged = pickVoice;
    // بعض المتصفحات تحمّل الأصوات متأخرة
    setTimeout(pickVoice, 400);
    setTimeout(pickVoice, 1500);
  }

  // نبرة خفيفة الاختلاف لكل مقعد (مدى ضيّق عشان ما يطلع صوت مشوّه)
  const seatTone = [
    { pitch: 1.05, rate: 0.92 },
    { pitch: 0.92, rate: 0.95 },
    { pitch: 1.12, rate: 0.9 },
    { pitch: 0.98, rate: 0.96 },
  ];

  // نطق لاتيني تقريبي — نستخدمه لو ما فيه صوت عربي بالجهاز (بدل ما يطلع صوت مكسّر)
  const PHONETIC = {
    "بس": "bass", "ولا": "wala",
    "صن": "soon", "حكم": "hokum", "حكم ثاني": "hokum thaani",
    "سرا": "sira", "خمسين": "khamseen", "مية": "meyya", "أربعمية": "arbamiyya",
    "بلوت": "baloot", "كبوت": "kaboot",
    "مبروك الفوز": "mabrook", "حظ أوفر": "hazz awfar",
  };

  function speak(text, seat) {
    if (!settings.voice || !("speechSynthesis" in window)) return;
    try {
      let toSay = text, lang = "ar-SA", voice = arVoice;
      if (!arVoice) {
        // ما فيه صوت عربي — نستخدم النطق اللاتيني للكلمات المعروفة فقط
        const p = PHONETIC[text.trim()];
        if (!p) return; // لا نطق مكسّر للجُمل الطويلة
        toSay = p; lang = "en-US"; voice = null;
      }
      if (speechSynthesis.pending || speechSynthesis.speaking) speechSynthesis.cancel();
      const u = new SpeechSynthesisUtterance(toSay);
      u.lang = lang;
      if (voice) u.voice = voice;
      const tone = seatTone[(seat ?? 0) % 4];
      u.pitch = tone.pitch;
      u.rate = tone.rate;
      u.volume = 1;
      speechSynthesis.speak(u);
    } catch (e) { /* تجاهل */ }
  }

  // ===== مؤثرات صوتية مولدة (بدون ملفات) =====
  let ctx = null;
  function ac() {
    if (!ctx) {
      const AC = window.AudioContext || window.webkitAudioContext;
      if (!AC) return null;
      ctx = new AC();
    }
    if (ctx.state === "suspended") ctx.resume();
    return ctx;
  }

  // على الجوال/WebView يحتاج AudioContext لمسة/نقرة أولى حتى يشتغل.
  // نستمع لأول تفاعل ونستأنف السياق حتى الأصوات تطلع مباشرة.
  function unlockAudio() {
    const c = ac();
    if (c && c.state === "suspended") {
      c.resume().catch(() => {});
    }
  }
  function forceResume() {
    unlockAudio();
    setTimeout(unlockAudio, 50);
    setTimeout(unlockAudio, 200);
    setTimeout(unlockAudio, 500);
  }
  // Resume on every interaction, not just the first one, and also on focus.
  ["touchstart", "touchend", "click", "pointerdown"].forEach((evt) => {
    document.addEventListener(evt, forceResume, { passive: true });
  });
  window.addEventListener("focus", forceResume);
  document.addEventListener("visibilitychange", () => {
    if (!document.hidden) forceResume();
  });
  // Try an immediate resume; on WebView with media-playback-without-gesture
  // this may succeed, otherwise the interaction handlers above will catch it.
  forceResume();

  function tone(freq, dur, type, vol, when) {
    const c = ac();
    if (!c || !settings.sfx) return;
    const o = c.createOscillator();
    const g = c.createGain();
    o.type = type || "sine";
    o.frequency.value = freq;
    g.gain.setValueAtTime(0, c.currentTime + (when || 0));
    g.gain.linearRampToValueAtTime(vol || 0.15, c.currentTime + (when || 0) + 0.01);
    g.gain.exponentialRampToValueAtTime(0.001, c.currentTime + (when || 0) + dur);
    o.connect(g).connect(c.destination);
    o.start(c.currentTime + (when || 0));
    o.stop(c.currentTime + (when || 0) + dur + 0.05);
  }

  const sfx = {
    card() { tone(1800, 0.06, "triangle", 0.18); tone(900, 0.08, "sine", 0.12, 0.02); },
    trick() { tone(523, 0.12, "sine", 0.22); tone(784, 0.18, "sine", 0.22, 0.08); },
    deal() { for (let i = 0; i < 4; i++) tone(1200 + i * 150, 0.05, "triangle", 0.14, i * 0.06); },
    win() { [523, 659, 784, 1047].forEach((f, i) => tone(f, 0.28, "sine", 0.22, i * 0.13)); },
    lose() { [400, 350, 300].forEach((f, i) => tone(f, 0.35, "sine", 0.18, i * 0.15)); },
    turn() { tone(880, 0.1, "sine", 0.18); },
    project() { tone(659, 0.14, "sine", 0.2); tone(988, 0.2, "sine", 0.2, 0.1); },
    eeka() { tone(1046, 0.11, "triangle", 0.2); tone(1568, 0.16, "triangle", 0.2, 0.07); },
  };

  function setVoice(on) {
    settings.voice = on;
    try { localStorage.setItem("baloot-voice", on ? "on" : "off"); } catch (e) {}
    if (!on && "speechSynthesis" in window) speechSynthesis.cancel();
  }
  function setSfx(on) {
    settings.sfx = on;
    try { localStorage.setItem("baloot-sfx", on ? "on" : "off"); } catch (e) {}
  }

  window.BalootVoice = { speak, sfx, settings, setVoice, setSfx, resumeAudio: forceResume };
})();
