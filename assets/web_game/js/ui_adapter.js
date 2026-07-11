// Bloot Flutter bridge integration for the original Baloot web UI.
// Exposes window.__bloot_ui so js/bloot_bridge.js can drive the UI in online-client mode.
import * as E from "./engine/index.js";
import * as Net from "./online.js";
import { $ } from "./ui/dom.js";
import { S } from "./ui/state.js";
import {
  renderAll, renderTrickCards, updateQaidButton, updateSawaButton,
  showBanner, vsFor,
} from "./ui/render.js";
import {
  animateDeal, animatePlayedCard, animateTrickCollect, spawnConfetti,
  hideOverlay,
} from "./ui/animations.js";
import {
  wireDialogs,
  wireMenu,
  showScreen,
  renderSetupStats,
  onHumanPlay,
  showBidDialog,
  showDoubleDialog,
  showDeclareDialog,
  clearAwaitingAck,
  resetAck,
  canShowActionButtons,
  showHandOverlay,
} from "./ui/controller.js";

let previousSnap = null;
let previousMatch = null;
let bootstrapped = false;

function playTransitionSounds(prev, next) {
  const voice = window.BalootVoice;
  if (!voice || !voice.sfx) return;
  if (voice.resumeAudio) voice.resumeAudio();
  const prevSt = prev && prev.state;
  const nextSt = next && next.state;
  if (!nextSt) return;

  // Bid announced
  if (prevSt && prevSt.bidding && nextSt.bidding) {
    if (nextSt.bidding.spoken > prevSt.bidding.spoken) {
      voice.sfx.turn();
    }
  }

  // Card played (new card in currentTrick)
  if (prevSt && nextSt.currentTrick && prevSt.currentTrick) {
    if (nextSt.currentTrick.length > prevSt.currentTrick.length) {
      voice.sfx.card();
    }
  }

  // Trick completed (trickHistory grew)
  if (prevSt && nextSt.trickHistory && prevSt.trickHistory) {
    if (nextSt.trickHistory.length > prevSt.trickHistory.length) {
      voice.sfx.trick();
    }
  }

  // Round / match ended
  if (prevSt && prevSt.phase !== "handEnd" && nextSt.phase === "handEnd") {
    voice.sfx.deal();
  }
  if (prevSt && !prev.matchOver && next.matchOver) {
    const myTeam = S.mySeat % 2;
    const won = next.winnerTeam === myTeam;
    won ? voice.sfx.win() : voice.sfx.lose();
  }
}

/**
 * Diffs consecutive server snapshots and fires the same visual animations the
 * standalone engine triggers via handleEvents (center action banners, trick
 * collection, confetti). The server only ships state — not an event log — so we
 * infer what happened from state transitions.
 */
function playTransitionAnimations(prev, next) {
  if (!next || !next.state) return;
  const prevSt = prev && prev.state;
  const nextSt = next.state;
  if (!prevSt) return;

  // New hand dealt: phase went handEnd -> bidding.
  if (prevSt.phase === "handEnd" && nextSt.phase === "bidding") {
    animateDeal([0, 1, 2, 3]);
  }

  // Bid won: mode just got set (sun / hokum / ashkal).
  if (prevSt.mode == null && nextSt.mode != null) {
    const label = nextSt.ashkal
      ? "أشكل 🔄"
      : nextSt.mode === "sun"
        ? "صن ☀️"
        : `حكم ${nextSt.trump}`;
    showBanner(label, 1400);
  }

  // Double / triple / quadruple applied.
  if ((nextSt.doubleLevel || 1) > (prevSt.doubleLevel || 1)) {
    const label =
      { 2: "دبل ×2 🔺", 3: "تربل ×3 🔺", 4: "كوت ×4 🔺" }[nextSt.doubleLevel] || "";
    if (label) showBanner(label);
  }

  // Project(s) announced.
  const prevProj = (prevSt.announcedProjects || []).length;
  const nextProj = (nextSt.announcedProjects || []).length;
  if (nextProj > prevProj) {
    const names = (nextSt.announcedProjects || []).map((p) => p.name);
    if (names.length) showBanner(names.join(" + "), 1400);
  }

  // A card was played: pop the newest card in the trick zone.
  if ((nextSt.currentTrick || []).length > (prevSt.currentTrick || []).length) {
    const zone = $("trick-zone");
    const played = zone && zone.querySelector(".bt-played-card:last-child");
    if (played) animatePlayedCard(played);
  }

  // A trick was won: re-render the completed trick then fly it to the winner.
  if ((nextSt.trickHistory || []).length > (prevSt.trickHistory || []).length) {
    const last = nextSt.trickHistory[nextSt.trickHistory.length - 1];
    if (last && last.winner != null) {
      renderTrickCards(last.plays, S.mySeat);
      animateTrickCollect(vsFor(S.mySeat)(last.winner));
    }
  }

  // Match ended: celebrate a win.
  if (prev && !prev.matchOver && next.matchOver) {
    const myTeam = S.mySeat % 2;
    if (next.winnerTeam === myTeam) spawnConfetti();
  }
}

function renderClient() {
  if (!S.match) return;
  renderAll(S.match, S.mySeat, S.players, onHumanPlay);
  const st = S.match.state;
  // The engine phase may stay "playing" during UI-only statuses like trickEnd/roundEnd,
  // so we also guard by the UI status sent from Flutter/RTDB.
  const canShowActions =
    canShowActionButtons() &&
    st.phase === "playing" &&
    !st.awaitingDeclare &&
    !st.awaitingDouble;
  updateQaidButton(canShowActions && !!st.violation && E.teamOf(st.violation.seat) !== E.teamOf(S.mySeat));
  updateSawaButton(
    canShowActions &&
      st.turn === S.mySeat &&
      st.currentTrick.length === 0 &&
      8 - st.trickHistory.length <= 4
  );

  if (st.awaitingDeclare && (st.declareSeats || []).includes(S.mySeat)) {
    showDeclareDialog();
  } else if (st.awaitingDouble && st.doubling.turn === S.mySeat) {
    showDoubleDialog();
  } else if (st.phase === "bidding" && st.bidding.turn === S.mySeat) {
    showBidDialog();
  }
}

function bootUI() {
  // Keep the setup screen wiring available for browser debugging, but in Bloot
  // the Flutter bridge calls startBlootOnline() directly.
  if (window.__BLOOT_BRIDGE_ENABLED) {
    // Hide the standalone setup/lobby screens immediately so they never flash
    // while the Flutter host prepares the game.
    showScreen(null);
  } else {
    wireDialogs();
    wireMenu();
    renderSetupStats();
  }
}

function startBlootOnline(cfg) {
  S.online = {
    code: cfg.code,
    seat: cfg.seat,
    isHost: false,
    actionBuffer: [],
    started: true,
    unsubs: [],
  };
  S.mySeat = cfg.seat;
  S.players = cfg.players || [];
  S.safeMode = !!cfg.safeMode;
  S.uiStatus = null;

  showScreen(null);
  $("topbar").hidden = false;
  $("footer-bar").hidden = false;
  $("table-area").hidden = false;
  $("buyer-badge").textContent = "🌐 أونلاين";

  // In Bloot mode the menu is handled by the Flutter host (back gesture), so
  // hide the standalone menu button to avoid duplicate/confusing UI.
  const menuBtn = $("menu-btn");
  if (menuBtn) menuBtn.parentElement.hidden = true;

  wireDialogs();
  wireMenu();

  S.online.unsubs.push(
    Net.watchSnapshot(cfg.code, (snap) => {
      if (!snap) return;
      playTransitionSounds(previousSnap, snap);
      previousSnap = JSON.parse(JSON.stringify(snap));
      S.uiStatus = snap.status || S.uiStatus;
      const nextMatch = E.deserializeMatch(snap);
      S.match = nextMatch;
      clearAwaitingAck();
      renderClient();
      const nextState = nextMatch.state;
      if (nextState.phase === "handEnd" && nextState.result && !nextMatch.matchOver && S.uiStatus !== "gameEnd") {
        if (!$("hand-overlay").classList.contains("show")) showHandOverlay(nextState.result);
      } else if (nextState.phase !== "handEnd") {
        hideOverlay("hand-overlay");
      }
      playTransitionAnimations(previousMatch, nextMatch);
      previousMatch = nextMatch;
      if (!bootstrapped) {
        bootstrapped = true;
        animateDeal([0, 1, 2, 3]);
      }
    })
  );
}

function setPlayers(p) {
  S.players = p || [];
}

function setStatus(status) {
  S.uiStatus = status;
  // A status push from Flutter is a new server state, so release the UI lock
  // and re-render button visibility immediately (e.g. hide سوا during trickEnd).
  clearAwaitingAck();
  if (S.match) renderClient();
  if (window.BalootVoice && BalootVoice.resumeAudio) BalootVoice.resumeAudio();
}

window.__bloot_ui = {
  startBlootOnline,
  setPlayers,
  resetAck,
  setStatus,
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", bootUI);
} else {
  bootUI();
}
