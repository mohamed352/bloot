// نقطة الدخول الموحّدة لمحرك البلوت — تجمع كل الوحدات المتخصصة (قواعد/مشاريع/نقاط/مزايدة/حالة)
// بواجهة واحدة (ES module واحد يستورده كل من UI والبوتات والأونلاين).
export * from "./constants.js";
export { seededRng, shuffle } from "./rng.js";
export { makeDeck, cardKey, sameCard } from "./deck.js";
export { teamOf, cardStrength, cardPoints, trickWinnerIdx } from "./cards.js";
export { legalMoves, validateMove, classifyViolation, VIOLATION_NAMES } from "./rules.js";
export { findProjects, projectQaid, projectTypesFor, resolveProjects } from "./projects.js";
export { scoreHand } from "./scoring.js";
export { applyBid, finalizeBid, applyDouble } from "./bidding.js";
export {
  createMatch, startHand, playCard, nextHand, declareProject, claimQaid,
  claimSawa, sawaGuaranteed, finalizeProjects, finishClaimedHand, checkMatchEnd,
} from "./match.js";
export { serializeMatch, deserializeMatch } from "./serialize.js";
