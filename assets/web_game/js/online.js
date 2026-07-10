// Bridge-compatible BalootNet shim for the Bloot Flutter WebView.
// Replaces the Firebase Realtime Database layer; all network calls are forwarded
// to window.BalootNet which is implemented by js/bloot_bridge.js.

function net() {
  return window.BalootNet || {};
}

export async function init() {
  return true;
}

export function available() {
  const n = net();
  return !!(n.available && n.available());
}

export async function createRoom(name, password, safeMode) {
  throw new Error("not used in Bloot");
}

export async function joinRoom(code, name, password) {
  throw new Error("not used in Bloot");
}

export async function moveSeat(code, fromSeat, toSeat) {
  throw new Error("not used in Bloot");
}

export async function startRoom(code, botNames, level) {
  throw new Error("not used in Bloot");
}

export function watchRoom(code, cb) {
  return () => {};
}

export function writeSnapshot(code, snapshot) {
  const n = net();
  if (n.writeSnapshot) n.writeSnapshot(code, snapshot);
  return Promise.resolve();
}

export function watchSnapshot(code, cb) {
  const n = net();
  if (n.watchSnapshot) return n.watchSnapshot(code, cb);
  return () => {};
}

export function pushAction(code, action) {
  const n = net();
  if (n.pushAction) return n.pushAction(code, action);
  return Promise.resolve();
}

export function watchActions(code, cb) {
  return () => {};
}

export async function clearActions(code) {
  return Promise.resolve();
}

export function removeAction(code, key) {
  return Promise.resolve();
}

export function leaveRoom(code, seat) {}

export function attachPresence(code, seat) {}

export async function heartbeatGlobalPresence() {}

export function watchActiveCount(cb) {
  cb(0);
  return () => {};
}
