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
  if (!window.__BLOOT_BRIDGE_ENABLED) {
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

  wireDialogs();
  wireMenu();

  S.online.unsubs.push(
    Net.watchSnapshot(cfg.code, (snap) => {
      if (!snap) return;
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
