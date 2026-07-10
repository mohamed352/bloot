// الوصل بين المحرك والواجهة أونلاين: لوبي الغرفة، حلقة المضيف (Host-authoritative)، وعرض العميل.
// العميل ما يشغّل المحرك أبداً — يعرض من لقطات المضيف بس ويدفع حركاته كطلبات.
import * as E from "../engine/index.js";
import { decideBid, decidePlay, decideDouble } from "../bots.js";
import * as Net from "../online.js";
import { $, sleep } from "./dom.js";
import { S, botDelay } from "./state.js";
import {
  renderAll, showBanner, updateQaidButton, updateSawaButton, vsFor,
} from "./render.js";
import { animateDeal, animateTrickCollect, spawnConfetti, showOverlay } from "./animations.js";
import {
  wireDialogs, wireMenu, showScreen, showBidDialog, showDoubleDialog, showDeclareDialog,
  handleEvents, renderSetupStats, onHumanPlay,
} from "./controller.js";

const BOT_POOL = ["بوت 🤖", "بوت 🤖", "بوت 🤖"];
const BOT_SAWA_CHANCE = { beginner: 0, amateur: 0.25, skilled: 0.6, pro: 0.9 };
function botQaidChance(level, tricksPlayed) {
  const base = { beginner: 0.25, amateur: 0.5, skilled: 0.75, pro: 0.95 }[level] || 0.5;
  return base * Math.pow(0.85, tricksPlayed) * (0.85 + Math.random() * 0.3);
}

const ACTION_MAX_AGE = 8000; // حركة قعدت بالطابور أكثر من هذا (دورها فات قبل ما توصل) تُشال
const AFK_TIMEOUT = 10000;   // ثوانٍ ينتظرها المضيف قبل ما يلعب بدال لاعب بشري متأخر
const CLAIM_BANNER_DELAY = 1300;

let onlineSafeMode = true;

export function wireOnlineUI() {
  $("open-online").onclick = () => {
    if (!$("player-name").value.trim()) { $("player-name").focus(); return; }
    onlineError("");
    showScreen("online-screen");
  };
  $("online-back").onclick = () => showScreen("setup-screen");
  $("tab-create").onclick = () => {
    $("tab-create").classList.add("sel"); $("tab-join").classList.remove("sel");
    $("pane-create").hidden = false; $("pane-join").hidden = true; onlineError("");
  };
  $("tab-join").onclick = () => {
    $("tab-join").classList.add("sel"); $("tab-create").classList.remove("sel");
    $("pane-join").hidden = false; $("pane-create").hidden = true; onlineError("");
  };

  const updateOnlineModeButtons = () => {
    $("online-mode-safe").classList.toggle("sel", onlineSafeMode);
    $("online-mode-ranked").classList.toggle("sel", !onlineSafeMode);
    $("online-mode-hint").textContent = onlineSafeMode
      ? "🛡️ آمن: لو اشترى أحد وطاح ما ينقطع فريقه"
      : "🔥 عادي: لعب حقيقي، وإذا صار قطع أي فريق يقدر يقيّد الثاني";
  };
  $("online-mode-safe").onclick = () => { onlineSafeMode = true; updateOnlineModeButtons(); };
  $("online-mode-ranked").onclick = () => { onlineSafeMode = false; updateOnlineModeButtons(); };
  updateOnlineModeButtons();

  $("do-create").onclick = async () => {
    onlineError(""); $("do-create").disabled = true;
    try {
      const name = $("player-name").value.trim() || "لاعب";
      const code = await Net.createRoom(name, $("create-pass").value.trim(), onlineSafeMode);
      enterLobby(code, 0, true);
    } catch (e) { onlineError(e.message || "صار خطأ"); }
    $("do-create").disabled = false;
  };
  $("do-join").onclick = async () => {
    onlineError(""); $("do-join").disabled = true;
    try {
      const name = $("player-name").value.trim() || "لاعب";
      const code = $("join-code").value.trim().toUpperCase();
      const res = await Net.joinRoom(code, name, $("join-pass").value.trim());
      enterLobby(code, res.seat, res.isHost);
    } catch (e) { onlineError(e.message || "صار خطأ"); }
    $("do-join").disabled = false;
  };

  if (!Net.available()) $("open-online").style.display = "none";
}

function onlineError(msg) { $("online-error").textContent = msg || ""; }

function enterLobby(code, seat, isHost) {
  S.online = { code, seat, isHost, actionBuffer: [], unsubs: [], started: false, hostPump, syncSnapshot, leaveOnline };
  S.mySeat = seat;
  $("lobby-code").textContent = code;
  $("lobby-start").hidden = !isHost;
  showScreen("lobby-screen");

  const unRoom = Net.watchRoom(code, (room) => {
    if (!room) { leaveOnline(); return; }
    renderLobbySeats(room);
    if (room.status === "playing" && !S.online.started) startOnlinePlay(room);
  });
  S.online.unsubs.push(unRoom);

  $("copy-code").onclick = () => {
    navigator.clipboard && navigator.clipboard.writeText(code);
    $("copy-code").textContent = "✓";
    setTimeout(() => { $("copy-code").textContent = "📋"; }, 1200);
  };
  $("lobby-leave").onclick = leaveOnline;
  $("lobby-start").onclick = async () => {
    $("lobby-start").disabled = true;
    try { await Net.startRoom(code, BOT_POOL, "skilled"); }
    catch (e) { onlineError(e.message); $("lobby-start").disabled = false; }
  };
}

function renderLobbySeats(room) {
  const seats = room.seats || {};
  const wrap = $("lobby-seats");
  wrap.innerHTML = "";
  let humans = 0;
  for (let s = 0; s < 4; s++) {
    const seat = seats[s];
    const div = document.createElement("div");
    div.className = "bt-lobby-seat" + (seat ? "" : " empty") + (s === S.mySeat ? " me" : "");
    const team = s % 2 === S.mySeat % 2 ? "فريقك" : "الخصم";
    if (seat && !seat.isBot) humans++;
    div.innerHTML = `<span>${seat ? (seat.isBot ? "🤖" : "🙂") : "➕"}</span><b>${seat ? seat.name : "فاضي"}</b><span>${team}</span>`;
    if (!seat && s !== S.mySeat) {
      div.style.cursor = "pointer";
      div.onclick = async () => {
        try {
          await Net.moveSeat(room.code, S.mySeat, s);
          S.mySeat = s; S.online.seat = s;
          Net.attachPresence(room.code, s);
        } catch (e) { onlineError(e.message || "ما قدرت أتحول لهالمقعد"); }
      };
    }
    wrap.appendChild(div);
  }
  $("lobby-mode").textContent = room.safeMode ? "🛡️ آمن" : "🔥 عادي";
  $("lobby-hint").textContent = humans >= 2 ? "جاهزين! مالك الغرفة يقدر يبدأ." : "ننتظر الربع يدخلون... (تقدر تبدأ وتكمّل بوتات)";
}

function buildPlayersFromRoom(room) {
  const seats = room.seats || {};
  const arr = [];
  for (let s = 0; s < 4; s++) {
    const seat = seats[s] || { name: "بوت", isBot: true, level: "skilled" };
    arr.push({ name: seat.name, isBot: !!seat.isBot, level: seat.level || "skilled" });
  }
  return arr;
}

async function startOnlinePlay(room) {
  S.online.started = true;
  S.awaitingServerAck = false;
  S.players = buildPlayersFromRoom(room);
  S.mySeat = S.online.seat;
  S.safeMode = !!room.safeMode;

  showScreen(null);
  $("topbar").hidden = false;
  $("footer-bar").hidden = false;
  $("table-area").hidden = false;
  $("buyer-badge").textContent = "🌐 أونلاين";

  if (S.online.isHost) {
    S.match = E.createMatch({ players: S.players, safeMode: S.safeMode, autoDeclare: false });
    try { await Net.clearActions(S.online.code); } catch (e) {}
    S.online.unsubs.push(Net.watchActions(S.online.code, (key, action) => {
      S.online.actionBuffer.push({ key, action, receivedAt: Date.now() });
      Net.removeAction(S.online.code, key);
      hostPump();
    }));
    E.startHand(S.match);
    animateDeal([0, 1, 2, 3]);
    syncSnapshot();
    hostPump();
  } else {
    S.online.unsubs.push(Net.watchSnapshot(S.online.code, (snap) => {
      S.match = E.deserializeMatch(snap);
      S.awaitingServerAck = false; // أي لقطة جديدة = المضيف عالج شي، نفك قفل منع الدبل-تاب
      renderClient();
    }));
  }
}

function syncSnapshot() {
  if (S.online && S.online.isHost && S.match) Net.writeSnapshot(S.online.code, E.serializeMatch(S.match));
}

function takeAction(seat, kind) {
  const buf = S.online.actionBuffer;
  const i = buf.findIndex((a) => a.action.seat === seat && a.action.type === kind);
  if (i < 0) return null;
  const taken = buf.splice(i, 1)[0].action;
  // ضغطة مكررة (سبام/دبل-تاب) من نفس المقعد قبل ما يوصلها رد — قرار واحد بس لكل دور،
  // نمسح أي حركة ثانية من نفس المقعد بدل ما تظل معلّقة لدور مستقبلي غلط.
  S.online.actionBuffer = buf.filter((a) => a.action.seat !== seat);
  return taken;
}

// رفض متوقّع من المحرك (سباق حركة صارت غير صالحة قبل ما تُستهلك — مثلاً بوت قرر يلعب وقت
// انتظاره، وبينها لاعب بشري لعب فغيّر الدور): الحركة الفاشلة أصلاً انشالت من الطابور، فحالة
// المباراة تبقى سليمة تماماً — نتجاهل بهدوء ونكمل الحلقة فوراً بدل بانر مخيف وتأخير المستخدم.
const EXPECTED_REJECTIONS = ["مو دورك", "مو وقت", "الورقة مو عندك", "حركة غير قانونية", "بس بآخر", "بس لما تكون قائد"];
function isExpectedRejection(err) {
  const msg = (err && err.message) || "";
  return EXPECTED_REJECTIONS.some((s) => msg.includes(s));
}

let afkKey = null, afkDeadline = 0, afkHandle = null;
function checkAfkTimeout(key) {
  if (afkKey !== key) {
    afkKey = key;
    afkDeadline = Date.now() + AFK_TIMEOUT;
    if (afkHandle) clearTimeout(afkHandle);
    afkHandle = setTimeout(() => { if (afkKey === key) hostPump(); }, AFK_TIMEOUT + 300);
    return false;
  }
  return Date.now() >= afkDeadline;
}

let hostPumping = false;
async function hostPump() {
  if (!S.online || !S.online.isHost || hostPumping || !S.match) return;
  hostPumping = true;
  try {
    while (S.match && S.match.state && S.online && S.online.isHost) {
      const st = S.match.state;
      let didWork = false;

      S.online.actionBuffer = S.online.actionBuffer.filter((a) => Date.now() - (a.receivedAt || 0) <= ACTION_MAX_AGE);

      try {
        const qc = S.online.actionBuffer.find((a) => a.action.type === "qaid");
        if (qc) {
          S.online.actionBuffer.splice(S.online.actionBuffer.indexOf(qc), 1);
          try {
            await handleEvents(E.claimQaid(S.match, qc.action.seat, qc.action.claimType));
            renderAll(S.match, S.mySeat, S.players, null); syncSnapshot();
            await sleep(CLAIM_BANNER_DELAY); didWork = true; continue;
          } catch (e) {}
        }
        const sw = S.online.actionBuffer.find((a) => a.action.type === "sawa");
        if (sw) {
          S.online.actionBuffer.splice(S.online.actionBuffer.indexOf(sw), 1);
          try {
            await handleEvents(E.claimSawa(S.match, sw.action.seat));
            renderAll(S.match, S.mySeat, S.players, null); syncSnapshot();
            await sleep(CLAIM_BANNER_DELAY); didWork = true; continue;
          } catch (e) {}
        }

        // بوت خصم ينتبه لقطع مكشوف — فرصة وحدة لكل قطع
        if (st.phase === "playing" && st.violation && !st.violation.botChecked) {
          st.violation.botChecked = true;
          const violTeam = E.teamOf(st.violation.seat);
          const oppBots = [0, 1, 2, 3].filter((s) => E.teamOf(s) !== violTeam && S.players[s].isBot);
          let claimed = false;
          for (const b of oppBots) {
            if (Math.random() < botQaidChance(S.players[b].level, st.trickHistory.length)) {
              await sleep(600 + Math.random() * 800);
              if (!S.online || !S.match || !S.match.state.violation) break;
              await handleEvents(E.claimQaid(S.match, b, S.match.state.violation.vtype));
              renderAll(S.match, S.mySeat, S.players, null); syncSnapshot();
              await sleep(CLAIM_BANNER_DELAY); claimed = true;
              break;
            }
          }
          if (claimed) { didWork = true; continue; }
        }

        if (st.awaitingDeclare) {
          const seat = st.declareSeats[0];
          const p = S.players[seat];
          if (!p.isBot) {
            const dc = takeAction(seat, "declare");
            if (dc) {
              afkKey = null;
              E.declareProject(S.match, seat, dc.claimedTypes);
              renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); syncSnapshot(); didWork = true; continue;
            }
            if (seat === S.mySeat) { renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); showDeclareDialog(); break; }
            if (checkAfkTimeout("declare:" + seat)) {
              const types = st.projects.filter((pr) => pr.seat === seat).map((pr) => pr.type);
              E.declareProject(S.match, seat, types);
              renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); syncSnapshot(); didWork = true; continue;
            }
            renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); syncSnapshot(); break;
          }
          await sleep(botDelay());
          if (!S.online || !S.match) break;
          const types = st.projects.filter((pr) => pr.seat === seat).map((pr) => pr.type);
          E.declareProject(S.match, seat, types);
          renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); syncSnapshot(); didWork = true; continue;
        }

        if (st.awaitingDouble) {
          const seat = st.doubling.turn;
          const p = S.players[seat];
          if (!p.isBot) {
            const dbl = takeAction(seat, "double");
            if (dbl) {
              afkKey = null;
              await handleEvents(E.applyDouble(S.match, seat, dbl.double));
              renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); syncSnapshot(); didWork = true; continue;
            }
            if (seat === S.mySeat) { renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); showDoubleDialog(); break; }
            if (checkAfkTimeout("double:" + seat)) {
              await handleEvents(E.applyDouble(S.match, seat, { type: "pass" }));
              renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); syncSnapshot(); didWork = true; continue;
            }
            renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); syncSnapshot(); break;
          }
          await sleep(botDelay());
          if (!S.online || !S.match) break;
          const wants = decideDouble(S.match, seat, p.level);
          await handleEvents(E.applyDouble(S.match, seat, wants ? { type: "double" } : { type: "pass" }));
          renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); syncSnapshot(); didWork = true; continue;
        }

        if (st.phase === "bidding") {
          const seat = st.bidding.turn;
          const p = S.players[seat];
          if (!p.isBot) {
            const a = takeAction(seat, "bid");
            if (a) {
              afkKey = null;
              await handleEvents(E.applyBid(S.match, seat, a.bid));
              renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); syncSnapshot(); didWork = true; continue;
            }
            if (seat === S.mySeat) { renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); showBidDialog(); break; }
            if (checkAfkTimeout("bid:" + seat)) {
              await handleEvents(E.applyBid(S.match, seat, decideBid(S.match, seat, "skilled")));
              renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); syncSnapshot(); didWork = true; continue;
            }
            renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); syncSnapshot(); break;
          }
          await sleep(botDelay());
          if (!S.online || !S.match) break;
          await handleEvents(E.applyBid(S.match, seat, decideBid(S.match, seat, p.level)));
          renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); syncSnapshot(); didWork = true; continue;
        } else if (st.phase === "playing") {
          const seat = st.turn;
          const p = S.players[seat];
          // الأكلة الأخيرة تنلعب تلقائياً عن الجميع — ما فيه خيار أصلاً
          if (st.hands[seat].length === 1) {
            await sleep(400);
            if (!S.online || !S.match) break;
            await playOnline(seat, st.hands[seat][0]);
            didWork = true; continue;
          }
          if (!p.isBot) {
            const a = takeAction(seat, "play");
            if (a) { afkKey = null; await playOnline(seat, a.card); didWork = true; continue; }
            if (seat === S.mySeat) { renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); break; }
            if (checkAfkTimeout("play:" + seat)) {
              await playOnline(seat, decidePlay(S.match, seat, "skilled")); didWork = true; continue;
            }
            renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); syncSnapshot(); break;
          }
          await sleep(botDelay());
          if (!S.online || !S.match) break;
          if (st.currentTrick.length === 0 && st.trickHistory.length >= 4 &&
              Math.random() < (BOT_SAWA_CHANCE[p.level] || 0) && E.sawaGuaranteed(st, seat)) {
            await handleEvents(E.claimSawa(S.match, seat));
            renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); syncSnapshot(); didWork = true; continue;
          }
          await playOnline(seat, decidePlay(S.match, seat, p.level));
          didWork = true; continue;
        } else if (st.phase === "handEnd") {
          renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); syncSnapshot();
          break; // ينتظر ضغطة "كمّل" من المضيف (continue-btn بـcontroller.js)
        } else if (st.phase === "matchEnd") {
          renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay); syncSnapshot();
          break;
        } else break;
      } catch (err) {
        if (isExpectedRejection(err)) {
          // سباق متوقّع — الحركة اللي سببته أصلاً اتشالت من الطابور قبل الاستدعاء، فالحالة
          // سليمة. نتجاهل بهدوء ونعيد المحاولة فوراً بدون بانر يخوّف اللاعبين.
          console.warn("[baloot] حركة مضيف أصبحت غير صالحة (سباق) — تُجوهل وتُعاد المحاولة:", err.message);
          continue;
        }
        console.error("[baloot] خطأ غير متوقّع بحلقة المضيف:", err, "phase=", st.phase);
        showBanner("⚠️ صار خلل مؤقت — نحاول نصلحها");
        setTimeout(() => hostPump(), 1200);
        break;
      }
      if (!didWork) break;
    }
  } finally { hostPumping = false; }
}

async function playOnline(seat, card) {
  const events = E.playCard(S.match, seat, card);
  renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay);
  syncSnapshot();
  const te = events.find((e) => e.type === "trickEnd");
  if (te) await animateTrickCollect(vsFor(S.mySeat)(te.winner));
  await handleEvents(events.filter((e) => e.type !== "trickEnd"));
  renderAll(S.match, S.mySeat, S.players, onOnlineHumanPlay);
  syncSnapshot();
}

// يُستدعى من render.js/renderHand لما ألعب أنا (المضيف) ورقتي بنفس الأسلوب — أونلاين نطبّق
// مباشرة (المضيف موثوق) بدل استدعاء controller.js's onHumanPlay المحلي
async function onOnlineHumanPlay(card) {
  await playOnline(S.mySeat, card);
  hostPump();
}

function renderClient() {
  // onHumanPlay بـcontroller.js يتحقق S.online.isHost بنفسه ويدفع الحركة للمضيف بدل ما
  // يشغّل المحرك — العميل هنا يستخدم نفس المسار المحلي بدون تكرار منطق
  renderAll(S.match, S.mySeat, S.players, onHumanPlay);
  const st = S.match.state;
  updateQaidButton(!!st.violation && E.teamOf(st.violation.seat) !== E.teamOf(S.mySeat));
  updateSawaButton(st.turn === S.mySeat && st.currentTrick.length === 0 && (8 - st.trickHistory.length) <= 4);
  if (st.awaitingDeclare && (st.declareSeats || []).includes(S.mySeat)) showDeclareDialog();
  else if (st.awaitingDouble && st.doubling.turn === S.mySeat) showDoubleDialog();
  else if (st.phase === "bidding" && st.bidding.turn === S.mySeat) showBidDialog();
  else if (st.phase === "handEnd") { /* نافذة نهاية الصكة تظهر عبر handleEvents بمسار المضيف؛ العميل يكتفي بعرض النتيجة بالـHUD */ }
  else if (st.phase === "matchEnd" && !$("match-overlay").classList.contains("show")) showOnlineMatchEnd();
}

function showOnlineMatchEnd() {
  const myTeam = E.teamOf(S.mySeat);
  const won = S.match.winnerTeam === myTeam;
  $("match-title").textContent = won ? "🏆 مبروك! كسبتوا الصكة" : "😔 خسرتوها هالمرة";
  $("match-score").innerHTML = `<b style="font-size:1.4rem">${S.match.totals[myTeam]} — ${S.match.totals[1 - myTeam]}</b>`;
  $("grade-circle").textContent = won ? "🏆" : "🙂";
  $("grade-comment").textContent = "";
  $("analysis").innerHTML = "";
  $("save-note").textContent = "";
  if (won) spawnConfetti();
  showOverlay("match-overlay");
}

function leaveOnline() {
  if (S.online) {
    for (const u of S.online.unsubs) { try { u(); } catch (e) {} }
    Net.leaveRoom(S.online.code, S.online.seat);
  }
  S.online = null;
  S.match = null;
  $("topbar").hidden = true;
  $("table-area").hidden = true;
  $("footer-bar").hidden = true;
  showScreen("setup-screen");
  renderSetupStats();
}
