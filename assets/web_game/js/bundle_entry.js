// Entry point for esbuild: bundles the original engine, bridge-compatible
// online shim, original UI modules, and Bloot adapter into a single classic
// script that exposes the globals js/bloot_bridge.js expects.
import * as E from "./engine/index.js";
import "./ui_adapter.js";

window.BalootEngine = E;
