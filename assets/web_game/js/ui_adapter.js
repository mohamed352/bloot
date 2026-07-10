// Bloot Flutter bridge integration for the original Baloot web UI.
// Exposes window.__bloot_ui so js/bloot_bridge.js can drive the UI in online-client mode.
import * as E from "./engine/index.js";
import * as Net from "./online.js";
import { $ } from "./ui/dom.js";
import { S } from "./ui/state.js";
import { renderAll, updateQaidButton, updateSawaButton } from "./ui/render.js";
import {
  wireDialogs,
  wireMenu,
  showScreen,
  renderSetupStats,
  onHumanPlay,
  showBidDialog,
  showDoubleDialog,
  showDeclareDialog,
} from "./ui/controller.js";

let previousSnap = null;

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

function renderClient() {
  if (!S.match) return;
  renderAll(S.match, S.mySeat, S.players, onHumanPlay);
  const st = S.match.state;
  updateQaidButton(!!st.violation && E.teamOf(st.violation.seat) !== E.teamOf(S.mySeat));
  updateSawaButton(
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
      S.match = E.deserializeMatch(snap);
      S.awaitingServerAck = false;
      renderClient();
    })
  );
}

function setPlayers(p) {
  S.players = p || [];
}

window.__bloot_ui = {
  startBlootOnline,
  setPlayers,
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", bootUI);
} else {
  bootUI();
}
