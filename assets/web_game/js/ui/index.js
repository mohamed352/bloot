import { initSetup } from "./controller.js";
import { wireOnlineUI } from "./multiplayer.js";

function boot() {
  initSetup();
  wireOnlineUI();
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", boot);
} else {
  boot();
}
