import { BalootCard, BalootSuit } from './balootCard';
import {
  BalootHandState,
  BalootMatch,
  BalootPhase,
  BalootPlayerConfig,
  BiddingState,
  CompletedTrick,
  DoublingState,
  HandResult,
  ProjectClaim,
  TrickPlay,
  ViolationRecord,
} from './balootState';
import { BidActionType, ProjectType, ViolationType } from './balootRules';

const SUIT_SYMBOLS: Record<BalootSuit, string> = {
  spades: '♠',
  hearts: '♥',
  diamonds: '♦',
  clubs: '♣',
};

function suitFromSymbol(symbol: string): BalootSuit {
  const entry = Object.entries(SUIT_SYMBOLS).find(([, s]) => s === symbol);
  if (!entry) throw new Error(`Invalid suit symbol: ${symbol}`);
  return entry[0] as BalootSuit;
}

export class BalootSerializer {
  serializeMatch(match: BalootMatch): Record<string, unknown> {
    const state = match.state;
    return {
      totals: match.totals,
      dealer: match.dealer,
      handsPlayed: match.handsPlayed,
      matchOver: match.matchOver,
      winnerTeam: match.winnerTeam ?? null,
      safeMode: match.safeMode,
      autoDeclare: match.autoDeclare,
      players: match.players.map((p) => ({
        name: p.name,
        isBot: p.isBot,
        level: p.level,
        uid: p.uid,
        displayName: p.displayName,
        avatarUrl: p.avatarUrl,
        team: p.team,
        agoraUid: p.agoraUid,
        isMuted: p.isMuted,
        hasCamera: p.hasCamera,
        isConnected: p.isConnected,
      })),
      state: state == null ? null : this.serializeHandState(state),
    };
  }

  deserializeMatch(json: Record<string, unknown>): BalootMatch {
    const players = ((json.players ?? []) as Array<Record<string, unknown>>).map(
      (p): BalootPlayerConfig => ({
        name: (p.name as string) ?? (p.displayName as string) ?? '',
        isBot: (p.isBot as boolean | undefined) ?? false,
        level: (p.level as string | undefined) ?? 'amateur',
        uid: p.uid as string | undefined,
        displayName: p.displayName as string | undefined,
        avatarUrl: p.avatarUrl as string | undefined,
        team: p.team as 'A' | 'B' | undefined,
        agoraUid: p.agoraUid as number | undefined,
        isMuted: p.isMuted as boolean | undefined,
        hasCamera: p.hasCamera as boolean | undefined,
        isConnected: p.isConnected as boolean | undefined,
      }),
    );

    const match = new BalootMatch({
      players,
      safeMode: (json.safeMode as boolean | undefined) ?? false,
      autoDeclare: (json.autoDeclare as boolean | undefined) ?? false,
    });
    match.totals[0] = ((json.totals as [number, number] | undefined) ?? [0, 0])[0];
    match.totals[1] = ((json.totals as [number, number] | undefined) ?? [0, 0])[1];
    match.dealer = json.dealer as number;
    match.handsPlayed = json.handsPlayed as number;
    match.matchOver = (json.matchOver as boolean | undefined) ?? false;
    match.winnerTeam = json.winnerTeam as number | undefined;

    const stateJson = json.state as Record<string, unknown> | undefined;
    if (stateJson) {
      match.state = this.deserializeHandState(stateJson);
    }
    return match;
  }

  serializeHandState(state: BalootHandState): Record<string, unknown> {
    return {
      phase: state.phase,
      hands: Object.fromEntries(state.hands.map((h, i) => [String(i), h.map((c) => c.key)])),
      topCard: state.topCard.key,
      rest: state.rest.map((c) => c.key),
      firstPlayer: state.firstPlayer,
      mode: state.mode ?? null,
      trump: state.trump == null ? null : SUIT_SYMBOLS[state.trump],
      buyer: state.buyer ?? null,
      ashkal: state.ashkal,
      bidding: {
        round: state.bidding.round,
        turn: state.bidding.turn,
        spoken: state.bidding.spoken,
        best:
          state.bidding.best == null
            ? null
            : {
                type: state.bidding.best!.type,
                seat: state.bidding.best!.seat,
                suit: state.bidding.best!.suit == null ? null : SUIT_SYMBOLS[state.bidding.best!.suit!],
              },
      },
      currentTrick: state.currentTrick.map((t) => ({ seat: t.seat, card: t.card.key })),
      trickHistory: state.trickHistory.map((t) => ({
        plays: t.plays.map((p) => ({ seat: p.seat, card: p.card.key })),
        winner: t.winner,
        points: t.points,
      })),
      leader: state.leader,
      turn: state.turn,
      projects: this.serializeProjects(state.projects),
      countedProjects: this.serializeProjects(state.countedProjects),
      droppedProjects: this.serializeProjects(state.droppedProjects),
      pendingAnnounce: this.serializeProjects(state.pendingAnnounce),
      pendingReveal: this.serializeProjects(state.pendingReveal),
      announcedProjects: this.serializeProjects(state.announcedProjects),
      revealedProjects: this.serializeProjects(state.revealedProjects),
      balootTeam: state.balootTeam ?? null,
      balootSeat: state.balootSeat ?? null,
      awaitingDeclare: state.awaitingDeclare,
      declareSeats: state.declareSeats,
      declarations: Object.fromEntries(
        Object.entries(state.declarations).map(([k, v]) => [k, v]),
      ),
      doubleLevel: state.doubleLevel,
      doubleTeam: state.doubleTeam ?? null,
      awaitingDouble: state.awaitingDouble,
      doubling:
        state.doubling == null
          ? null
          : {
              turn: state.doubling.turn,
              stage: state.doubling.stage,
              nextLevel: state.doubling.nextLevel,
            },
      violation:
        state.violation == null
          ? null
          : {
              seat: state.violation.seat,
              card: state.violation.card.key,
              trickIndex: state.violation.trickIndex,
              type: state.violation.type,
              escaped: state.violation.escaped.map((c) => c.key),
              confirmed: state.violation.confirmed,
            },
      pendingViolations: state.pendingViolations.map((v) => ({
        seat: v.seat,
        card: v.card.key,
        trickIndex: v.trickIndex,
        type: v.type,
        escaped: v.escaped.map((c) => c.key),
        confirmed: v.confirmed,
      })),
      voids: Object.fromEntries(state.voids.map((s, i) => [String(i), [...s].map((e) => SUIT_SYMBOLS[e])])),
      playedCards: state.playedCards.map((c) => c.key),
      result: state.result == null ? null : this.serializeHandResult(state.result),
    };
  }

  deserializeHandState(json: Record<string, unknown>): BalootHandState {
    const state = new BalootHandState();
    state.phase = json.phase as BalootPhase;
    const handsJson = (json.hands as Record<string, string[]> | undefined) ?? {};
    state.hands = [0, 1, 2, 3].map((i) =>
      (handsJson[String(i)] ?? []).map((c) => BalootCard.fromString(c)),
    );
    state.topCard = BalootCard.fromString(json.topCard as string);
    state.rest = ((json.rest as string[]) ?? []).map((c) => BalootCard.fromString(c));
    state.firstPlayer = json.firstPlayer as number;
    state.mode = json.mode ? (json.mode as 'sun' | 'hokum') : undefined;
    state.trump = json.trump == null ? undefined : suitFromSymbol(json.trump as string);
    state.buyer = json.buyer == null ? undefined : (json.buyer as number);
    state.ashkal = (json.ashkal as boolean | undefined) ?? false;
    state.bidding = this.deserializeBidding(json.bidding as Record<string, unknown>);
    state.leader = json.leader as number;
    state.turn = json.turn as number;
    state.balootTeam = json.balootTeam == null ? undefined : (json.balootTeam as number);
    state.balootSeat = json.balootSeat == null ? undefined : (json.balootSeat as number);
    state.awaitingDeclare = (json.awaitingDeclare as boolean | undefined) ?? false;
    state.declareSeats = ((json.declareSeats as number[]) ?? []).map((s) => s);
    state.declarations = Object.fromEntries(
      Object.entries((json.declarations as Record<string, ProjectType[]>) ?? {}).map(([k, v]) => [
        Number.parseInt(k, 10),
        v,
      ]),
    );
    state.doubleLevel = (json.doubleLevel as number | undefined) ?? 1;
    state.doubleTeam = json.doubleTeam == null ? undefined : (json.doubleTeam as number);
    state.awaitingDouble = (json.awaitingDouble as boolean | undefined) ?? false;
    state.doubling = json.doubling == null ? undefined : this.deserializeDoubling(json.doubling as Record<string, unknown>);
    state.result = json.result == null ? undefined : this.deserializeHandResult(json.result as Record<string, unknown>);

    state.currentTrick.push(...
      ((json.currentTrick as Array<{ seat: number; card: string }>) ?? []).map(
        (t): TrickPlay => ({ seat: t.seat, card: BalootCard.fromString(t.card) }),
      )
    );

    state.trickHistory.push(...
      ((json.trickHistory as Array<Record<string, unknown>>) ?? []).map(
        (t): CompletedTrick => ({
          plays: ((t.plays as Array<{ seat: number; card: string }>) ?? []).map(
            (p): TrickPlay => ({ seat: p.seat, card: BalootCard.fromString(p.card) }),
          ),
          winner: t.winner as number,
          points: t.points as number,
        }),
      )
    );

    state.projects.push(...this.deserializeProjects(json.projects as Array<Record<string, unknown>>));
    state.countedProjects.push(...this.deserializeProjects(json.countedProjects as Array<Record<string, unknown>>));
    state.droppedProjects.push(...this.deserializeProjects(json.droppedProjects as Array<Record<string, unknown>>));
    state.pendingAnnounce.push(...this.deserializeProjects(json.pendingAnnounce as Array<Record<string, unknown>>));
    state.pendingReveal.push(...this.deserializeProjects(json.pendingReveal as Array<Record<string, unknown>>));
    state.announcedProjects.push(...this.deserializeProjects(json.announcedProjects as Array<Record<string, unknown>>));
    state.revealedProjects.push(...this.deserializeProjects(json.revealedProjects as Array<Record<string, unknown>>));

    if (json.violation != null) {
      state.violation = this.deserializeViolation(json.violation as Record<string, unknown>);
    }
    state.pendingViolations.push(...
      ((json.pendingViolations as Array<Record<string, unknown>>) ?? []).map((v) => this.deserializeViolation(v))
    );

    const voidsJson = (json.voids as Record<string, string[]> | undefined) ?? {};
    state.voids = [0, 1, 2, 3].map(
      (i) => new Set((voidsJson[String(i)] ?? []).map((e) => suitFromSymbol(e))),
    );
    state.playedCards.push(...((json.playedCards as string[]) ?? []).map((c) => BalootCard.fromString(c)));

    return state;
  }

  private serializeProjects(projects: ProjectClaim[]): Array<Record<string, unknown>> {
    return projects.map((p) => ({
      seat: p.seat,
      type: p.type,
      cards: p.cards.map((c) => c.key),
      revealed: p.revealed,
    }));
  }

  private deserializeProjects(json: Array<Record<string, unknown>>): ProjectClaim[] {
    return (json ?? []).map(
      (p): ProjectClaim => ({
        seat: p.seat as number,
        type: p.type as ProjectType,
        cards: ((p.cards as string[]) ?? []).map((c) => BalootCard.fromString(c)),
        revealed: (p.revealed as boolean | undefined) ?? false,
      }),
    );
  }

  private deserializeBidding(json: Record<string, unknown>): BiddingState {
    const best = json.best as Record<string, unknown> | undefined | null;
    return {
      round: json.round as number,
      turn: json.turn as number,
      spoken: json.spoken as number,
      best: best
        ? {
            type: best.type as BidActionType,
            seat: best.seat as number,
            suit: best.suit == null ? undefined : suitFromSymbol(best.suit as string),
          }
        : undefined,
    };
  }

  private deserializeDoubling(json: Record<string, unknown>): DoublingState {
    return {
      turn: json.turn as number,
      stage: json.stage as string,
      nextLevel: json.nextLevel as number,
    };
  }

  private deserializeViolation(json: Record<string, unknown>): ViolationRecord {
    return {
      seat: json.seat as number,
      card: BalootCard.fromString(json.card as string),
      trickIndex: json.trickIndex as number,
      type: json.type as ViolationType,
      escaped: ((json.escaped as string[]) ?? []).map((c) => BalootCard.fromString(c)),
      confirmed: (json.confirmed as boolean | undefined) ?? false,
    };
  }

  private serializeHandResult(r: HandResult): Record<string, unknown> {
    return {
      qaid: r.qaid,
      pts: r.pts,
      trickWins: r.trickWins,
      capotTeam: r.capotTeam ?? null,
      buyerLost: r.buyerLost,
      safeSaved: r.safeSaved,
      projQaid: r.projQaid,
      balootQaid: r.balootQaid,
      doubleLevel: r.doubleLevel,
      qatClaim: r.qatClaim
        ? {
            type: r.qatClaim.type,
            typeName: r.qatClaim.typeName,
            failed: r.qatClaim.failed,
            claimSeat: r.qatClaim.claimSeat,
            violSeat: r.qatClaim.violSeat ?? null,
            winTeam: r.qatClaim.winTeam ?? null,
            violCard: r.qatClaim.violCard?.key ?? null,
            trickIndex: r.qatClaim.trickIndex ?? null,
            provedBy: r.qatClaim.provedBy?.key ?? null,
          }
        : null,
      sawa: r.sawa
        ? {
            seat: r.sawa.seat,
            valid: r.sawa.valid,
            hands: r.sawa.hands
              ? Object.fromEntries(r.sawa.hands.map((h, i) => [i.toString(), h.map((c) => c.key)]))
              : null,
          }
        : null,
    };
  }

  private deserializeHandResult(json: Record<string, unknown>): HandResult {
    const qc = json.qatClaim as Record<string, unknown> | undefined | null;
    return {
      qaid: (json.qaid as [number, number]) ?? [0, 0],
      pts: (json.pts as [number, number]) ?? [0, 0],
      trickWins: (json.trickWins as [number, number]) ?? [0, 0],
      capotTeam: json.capotTeam == null ? undefined : (json.capotTeam as number),
      buyerLost: json.buyerLost as boolean,
      safeSaved: (json.safeSaved as boolean | undefined) ?? false,
      projQaid: (json.projQaid as [number, number]) ?? [0, 0],
      balootQaid: (json.balootQaid as [number, number]) ?? [0, 0],
      doubleLevel: json.doubleLevel as number,
      qatClaim: qc
        ? {
            type: qc.type as ViolationType,
            typeName: qc.typeName as string,
            failed: qc.failed as boolean,
            claimSeat: qc.claimSeat as number,
            violSeat: qc.violSeat == null ? undefined : (qc.violSeat as number),
            winTeam: qc.winTeam == null ? undefined : (qc.winTeam as number),
            violCard: qc.violCard == null ? undefined : BalootCard.fromString(qc.violCard as string),
            trickIndex: qc.trickIndex == null ? undefined : (qc.trickIndex as number),
            provedBy: qc.provedBy == null ? undefined : BalootCard.fromString(qc.provedBy as string),
          }
        : undefined,
      sawa: json.sawa
        ? {
            seat: (json.sawa as Record<string, unknown>).seat as number,
            valid: (json.sawa as Record<string, unknown>).valid as boolean,
            hands: (() => {
              const handsMap = (json.sawa as Record<string, unknown>).hands as
                | Record<string, string[]>
                | undefined
                | null;
              if (!handsMap) return undefined;
              return Array.from({ length: 4 }, (_, i) =>
                (handsMap[i.toString()] ?? []).map((c) => BalootCard.fromString(c)),
              );
            })(),
          }
        : undefined,
    };
  }
}
