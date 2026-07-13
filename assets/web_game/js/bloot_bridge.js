/* Bloot bridge — replaces the standalone Firebase/RTDB layer in the HTML game
   with a two-way channel to Flutter. The HTML UI runs in "online client" mode:
   it renders state pushed by Flutter and sends human actions back. */
(function () {
  "use strict";

  // Tell the HTML UI that it is hosted inside the Bloot Flutter WebView.
  window.__BLOOT_BRIDGE_ENABLED = true;

  const E = window.BalootEngine;
  let snapshotCb = null;
  let currentCode = null;
  let currentSeat = 0;
  let rtdbUnsub = null;
  let rtdbActive = false;
  let lastBridgeState = null;

  function $(id) { return document.getElementById(id); }

  // ── card helpers ─────────────────────────────────────────────────────
  function parseKey(key) {
    if (!key || typeof key !== "string") return null;
    return { rank: key.slice(0, -1), suit: key.slice(-1) };
  }
  function mapCard(c) {
    if (!c) return null;
    if (typeof c === "string") return parseKey(c);
    if (c.rank && c.suit) return c;
    return null;
  }
  function mapCards(arr) { return (arr || []).map(mapCard).filter(Boolean); }

  // ── state mapper: Bloot engineState → HTML engine snapshot ─────────────
  function mapBlootState(bloot) {
    const bs = bloot.state || {};

    // hands: Bloot sends {0:[keys], 1:[keys], ...}
    const hands = [];
    for (let i = 0; i < 4; i++) {
      const h = (bs.hands && bs.hands[String(i)]) || [];
      hands[i] = mapCards(h);
    }

    // voids: Bloot sends {0:["♠",...], ...}
    const voids = [];
    for (let i = 0; i < 4; i++) {
      const v = (bs.voids && bs.voids[String(i)]) || [];
      voids[i] = v;
    }

    function mapProject(p) {
      if (!p) return null;
      const name = E.PROJECT_NAMES[p.type];
      return {
        seat: p.seat,
        type: p.type,
        name: name,
        qaid: E.projectQaid(p, bs.mode),
        cards: mapCards(p.cards),
        revealed: !!p.revealed,
      };
    }
    function mapProjects(arr) { return (arr || []).map(mapProject).filter(Boolean); }

    function mapViolation(v) {
      if (!v) return null;
      return {
        seat: v.seat,
        card: mapCard(v.card),
        trickIndex: v.trickIndex,
        type: v.type,
        escaped: mapCards(v.escaped),
        confirmed: !!v.confirmed,
        provedBy: mapCard(v.provedBy),
      };
    }

    const bidding = bs.bidding || { round: 1, turn: 0, spoken: 0, best: null };
    const mappedBidding = {
      round: bidding.round,
      turn: bidding.turn,
      spoken: bidding.spoken,
      best: bidding.best
        ? {
            type: bidding.best.type,
            seat: bidding.best.seat,
            suit: bidding.best.suit,
          }
        : null,
    };

    const snap = {
      totals: bloot.totals || [0, 0],
      dealer: bloot.dealer || 0,
      handsPlayed: bloot.handsPlayed || 0,
      matchOver: !!bloot.matchOver,
      winnerTeam: bloot.winnerTeam == null ? null : bloot.winnerTeam,
      safeMode: !!bloot.safeMode,
      state: {
        phase: bs.phase || "bidding",
        hands: hands,
        topCard: mapCard(bs.topCard),
        rest: mapCards(bs.rest),
        firstPlayer: bs.firstPlayer || 0,
        mode: bs.mode || null,
        trump: bs.trump || null,
        buyer: bs.buyer == null ? null : bs.buyer,
        ashkal: !!bs.ashkal,
        bidding: mappedBidding,
        currentTrick: (bs.currentTrick || []).map((t) => ({
          seat: t.seat,
          card: mapCard(t.card),
        })),
        trickHistory: (bs.trickHistory || []).map((t) => ({
          plays: (t.plays || []).map((p) => ({ seat: p.seat, card: mapCard(p.card) })),
          winner: t.winner,
          points: t.points,
        })),
        leader: bs.leader == null ? (bs.firstPlayer || 0) : bs.leader,
        turn: bs.turn == null ? 0 : bs.turn,
        projects: mapProjects(bs.projects),
        countedProjects: mapProjects(bs.countedProjects),
        droppedProjects: mapProjects(bs.droppedProjects),
        pendingAnnounce: mapProjects(bs.pendingAnnounce),
        pendingReveal: mapProjects(bs.pendingReveal),
        announcedProjects: mapProjects(bs.announcedProjects),
        revealedProjects: mapProjects(bs.revealedProjects),
        balootTeam: bs.balootTeam == null ? null : bs.balootTeam,
        balootSeat: bs.balootSeat == null ? null : bs.balootSeat,
        awaitingDeclare: !!bs.awaitingDeclare,
        declareSeats: bs.declareSeats || [],
        declarations: bs.declarations || {},
        doubleLevel: bs.doubleLevel || 1,
        doubleTeam: bs.doubleTeam == null ? null : bs.doubleTeam,
        awaitingDouble: !!bs.awaitingDouble,
        doubling: bs.doubling || null,
        violation: mapViolation(bs.violation),
        playedCards: mapCards(bs.playedCards),
        result: mapResult(bs.result),
        voids: voids,
      },
    };
    return snap;

    function mapResult(r) {
      if (!r) return null;
      const mapped = { ...r };
      if (r.sawa && r.sawa.hands) {
        mapped.sawa = {
          seat: r.sawa.seat,
          valid: r.sawa.valid,
          hands: r.sawa.hands.map((h) => mapCards(h)),
        };
      }
      return mapped;
    }
  }

  // ── Realtime Database watcher ────────────────────────────────────────
  async function initRtdb(config) {
    if (!config || !config.gameId || !config.firebaseConfig) return false;
    if (!window.firebase || !firebase.database || !firebase.auth) {
      console.warn('[BlootBridge] Firebase SDK not loaded; using bridge fallback');
      return false;
    }
    try {
      currentCode = config.gameId;
      if (!firebase.apps.length) {
        firebase.initializeApp(config.firebaseConfig);
      }
      if (config.token) {
        await firebase.auth().signInWithCustomToken(config.token);
      }
      const ref = firebase.database().ref('games/' + config.gameId);
      rtdbUnsub = ref.on('value', function (snap) {
        const data = snap.val() || {};
        if (snapshotCb && data.engineState) {
          const wasActive = rtdbActive;
          rtdbActive = true;
          snapshotCb(mapBlootState(data.engineState));
          // Notify Flutter that RTDB is now the active fast path so it can
          // stop pushing the same state over the slower JS bridge.
          if (!wasActive) sendToFlutter({ type: 'rtdbActive' });
        }
      }, function (err) {
        console.error('[BlootBridge] RTDB value error:', err);
        rtdbActive = false;
      });
      console.log('[BlootBridge] RTDB watcher registered for game', config.gameId);
      return true;
    } catch (e) {
      console.error('[BlootBridge] RTDB init failed:', e);
      rtdbActive = false;
      return false;
    }
  }

  function stopRtdb() {
    if (rtdbUnsub && currentCode) {
      try { firebase.database().ref('games/' + currentCode).off('value', rtdbUnsub); } catch (e) {}
      rtdbUnsub = null;
    }
    rtdbActive = false;
  }

  // ── send to Flutter ──────────────────────────────────────────────────
  function sendToFlutter(msg) {
    const payload = JSON.stringify(msg);
    if (window.BlootNative && typeof BlootNative.postMessage === "function") {
      try { BlootNative.postMessage(payload); return; } catch (e) {}
    }
    if (window.flutter_inappwebview && typeof flutter_inappwebview.callHandler === "function") {
      try { flutter_inappwebview.callHandler("BlootNative", payload); return; } catch (e) {}
    }
    // Fallback for browser debugging: log and store last message.
    console.log("[BlootBridge → Flutter]", msg);
    window.__lastBlootMessage = msg;
  }

  // ── fake BalootNet: the HTML UI thinks it is an online client ─────────
  window.BalootNet = {
    available: () => true,
    init: async () => true,
    heartbeatGlobalPresence: async () => {},
    watchActiveCount: () => () => {},
    createRoom: async () => { throw new Error("not used in Bloot"); },
    joinRoom: async () => { throw new Error("not used in Bloot"); },
    moveSeat: async () => { throw new Error("not used in Bloot"); },
    startRoom: async () => { throw new Error("not used in Bloot"); },
    setStatus: async () => {},
    leaveRoom: () => {},
    attachPresence: () => {},
    clearActions: async () => {},
    removeAction: () => {},
    watchRoom: () => () => {},
    writeSnapshot: () => {},
    watchSnapshot: (code, cb) => {
      currentCode = code;
      snapshotCb = cb;
      return () => { snapshotCb = null; };
    },
    pushAction: (code, action) => {
      // Convert HTML action shapes to Bloot action messages.
      let type = action.type;
      let payload = {};
      if (type === "bid") {
        const bid = action.bid;
        let bidStr = bid.type;
        if (bidStr === "hokum") bidStr = "hokm";
        if (bid.suit) bidStr = bidStr + "-" + bid.suit;
        payload = { bid: bidStr };
      } else if (type === "play") {
        payload = { card: typeof action.card === "object" ? (action.card.rank + action.card.suit) : action.card };
      } else if (type === "declare") {
        payload = { claimedTypes: action.claimedTypes || [] };
      } else if (type === "double") {
        payload = { double: action.double.type };
      } else if (type === "qaid") {
        payload = { claimType: action.claimType };
      } else if (type === "sawa") {
        payload = {};
      }
      sendToFlutter({ type: "action", action: type, seat: action.seat, ...payload });
    },
  };

  // ── public API used by Flutter ───────────────────────────────────────
  window.__bloot_bridge = {
    // Receive a message from Flutter.
    receive: function (msg) {
      if (typeof msg === "string") {
        try { msg = JSON.parse(msg); } catch (e) { return; }
      }
      if (!msg) return;
      const ui = window.__bloot_ui;

      if (msg.type === "start") {
        if (window.BalootVoice && BalootVoice.resumeAudio) BalootVoice.resumeAudio();
        currentSeat = msg.seat || 0;
        // Start RTDB watcher if the Flutter host provided config. This runs
        // in parallel with the bridge start so the UI renders quickly even if
        // RTDB auth is slow.
        initRtdb(msg.rtdbConfig).catch(function (e) {
          console.warn('[BlootBridge] RTDB init rejected:', e);
        });
        if (ui && ui.startBlootOnline) {
          ui.startBlootOnline({
            code: msg.gameId || "bloot",
            seat: currentSeat,
            players: msg.players || [],
            safeMode: !!msg.safeMode,
          });
        }
        const exitBtn = $("exit-match");
        if (exitBtn) {
          exitBtn.onclick = () => sendToFlutter({ type: "exit" });
        }
        sendToFlutter({ type: "ready", seat: currentSeat });
        return;
      }

      if (msg.type === "state") {
        lastBridgeState = msg.engineState || msg.state || {};
        if (ui && ui.setStatus) ui.setStatus(msg.status || lastBridgeState.status);
        // When RTDB is active it is the fast path; only use the bridge state
        // if RTDB has not delivered a snapshot yet.
        if (snapshotCb && !rtdbActive) {
          snapshotCb(mapBlootState(lastBridgeState));
        }
        return;
      }

      if (msg.type === "players") {
        if (ui && ui.setPlayers) ui.setPlayers(msg.players || []);
        if (snapshotCb) snapshotCb(mapBlootState(msg.engineState || {}));
        return;
      }

      if (msg.type === "theme") {
        if (msg.css) injectTheme(msg.css);
        return;
      }

      if (msg.type === "error") {
        showError(msg.message || "");
        return;
      }
    },
    stopRtdb: stopRtdb,
  };

  function injectTheme(css) {
    let el = $("bloot-theme-override");
    if (!el) {
      el = document.createElement("style");
      el.id = "bloot-theme-override";
      document.head.appendChild(el);
    }
    el.textContent = css;
  }

  function showError(text) {
    // Reuse the center banner if available; otherwise alert.
    const banner = $("center-banner");
    if (banner) {
      banner.textContent = text;
      banner.classList.add("open");
      setTimeout(() => banner.classList.remove("open"), 4000);
    } else {
      // eslint-disable-next-line no-alert
      alert(text);
    }
  }

  // ── global BlootBridge compatibility object ───────────────────────────
  // The WebView channel is registered as "BlootNative". Keep a legacy alias
  // so future integrations can still call BlootBridge.postMessage to send.
  window.BlootBridge = {
    postMessage: function (payload) {
      // If Flutter sends through this object, dispatch it.
      if (typeof payload === "string") {
        window.__bloot_bridge.receive(payload);
      }
    },
    send: sendToFlutter,
  };

  // Debug helper: in a desktop browser you can call __bloot_bridge.receive({...})
  console.log("Bloot bridge loaded. Channel: BlootNative");
})();
