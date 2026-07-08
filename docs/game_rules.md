# Bloot — Definitive Baloot Game Rules

> **Authority:** This document resolves all contradictions in `research/04_balout_game_mechanics.md` and external sources. It is the single source of truth for the Bloot game engine implementation.
> **Variant:** 32-card Saudi Baloot (ranks 7‑8‑9‑10‑J‑Q‑K‑A).

---

## 1. Game Overview

| Attribute | Value |
|---|---|
| Players | 4 (2 teams of 2) |
| Partners | Sit opposite each other |
| Team A | Seats 0 and 2 |
| Team B | Seats 1 and 3 |
| Deck | 32 cards (7, 8, 9, 10, J, Q, K, A) × 4 suits |
| Cards per player | 8 |
| Tricks per round | 8 |
| Modes | Sun (صن), Hokm (حكم), Ashkal (أشكل) |
| Target score | 152 qaid (configurable) |

---

## 2. Dealing

### 2.1 Procedure

1. Dealer shuffles the 32-card deck.
2. Player to dealer's right cuts.
3. Dealer distributes counter-clockwise:
   - **First round:** 5 cards to each player.
   - The **next card** is placed **face-up** on the table; this is the proposed trump suit.
4. After bidding resolves, the remaining 11 cards are distributed:
   - The bid winner (or the bid winner's partner in Ashkal) receives 2 cards plus the face-up card.
   - Each other player receives 3 cards.
   - **Total:** 8 cards per player.

### 2.2 Dealer Rotation

- Dealer rotates **clockwise** after each round.
- `dealerIndex` cycles 0 → 1 → 2 → 3 → 0.

---

## 3. Bidding Phase

### 3.1 Bid Options

| Bid | Arabic | Hierarchy | Notes |
|-----|--------|-----------|-------|
| Pass | باص | Lowest | Always allowed |
| Sun | صن | Middle | Played with no trump; buyer must score > 60 card points |
| Hokm | حكم | High | Trump suit is the face-up card's suit (round 1) or a chosen different suit (round 2) |
| Ashkal | أشكل | Special Sun bid | Only the dealer or the player before the dealer may call Ashkal; the face-up card is given to the bidder's partner |

### 3.2 Bidding Rules

- Bidding proceeds **clockwise** starting from the player to the dealer's right.
- **Sun**, **Ashkal**, or a first-round **Hokm** immediately ends the bidding.
- In a second round (after all players passed in round 1), **Hokm** must be in a suit different from the face-up card; **Sun** may also be called.
- **All four Pass in both rounds → re-deal** by the next dealer.

### 3.3 Bid Winner

- Bid winner's team becomes the **bidding team** (الطالب).
- The opposing team is **الخصم**.
- In Hokm mode, the trump suit is fixed as described above.

---

## 4. Card Point Values

### 4.1 Non-Trump / Sun Mode

| Card | Points |
|------|--------|
| A | 11 |
| 10 | 10 |
| K | 4 |
| Q | 3 |
| J | 2 |
| 9, 8, 7 | 0 |

**Total per suit:** 30  
**Total per round (4 suits):** 120

### 4.2 Trump Suit (Hokm Only)

In Hokm mode, the trump suit has different point values and ranking:

| Rank | Card | Points |
|------|------|--------|
| 1st | J | 20 |
| 2nd | 9 | 14 |
| 3rd | A | 11 |
| 4th | 10 | 10 |
| 5th | K | 4 |
| 6th | Q | 3 |
| 7th | 8 | 0 |
| 8th | 7 | 0 |

**Trump suit total:** 62  
**Non-trump suit total:** 30  
**Total per round (Hokm):** 62 + (30 × 3) = **152**

### 4.3 Card Rank Order

**Non-trump / Sun:**  
`A > 10 > K > Q > J > 9 > 8 > 7`

**Trump (Hokm):**  
`J > 9 > A > 10 > K > Q > 8 > 7`

---

## 5. Trick Play

### 5.1 Rules

1. **Bid winner leads the first trick.**
2. Players **must follow suit** if they hold any card of the led suit.
3. If a player is **void** in the led suit, they may play any card.
4. All 8 tricks are played. There is **no early termination**.

### 5.2 Trick Winner Determination

1. If **any trump** was played → highest trump wins.
2. If **no trump** played → highest card of the **led suit** wins.
3. Winner of the trick **leads the next trick**.

### 5.3 Baloot (Hokm Only)

In Hokm, holding the **K and Q of the trump suit** is a **Baloot**. It scores an extra 2 qaid for the team that wins the trick containing the second Baloot card.

---

## 6. Projects (Sun / Ashkal Only)

> **Projects do NOT apply in Hokm mode.**

Before the first trick, players may reveal projects. The online engine uses **auto-declare** (all detected projects are revealed automatically).

### 6.1 Sira (Sequence)

A sequence of 3+ cards of the **same suit** in consecutive rank order.

| Length | Arabic Name | Qaid |
|--------|-------------|------|
| 3 | سرا (Sira) | 4 |
| 4 | خمسين (Khamsin) | 10 |
| 5+ | مية (Meya) | 20 |

**Ranking for sequences:** A > K > Q > J > 10 > 9 > 8 > 7

**Rules:**
- Only the **longest sequence per suit** counts.
- If both teams have projects, the team with the **highest-ranking project** wins all project rights; the losing team's projects score 0.

### 6.2 Four of a Kind

Four cards of the same rank.

| Rank | Arabic Name | Qaid |
|------|-------------|------|
| Four Aces | أربعمئة (Arba'meya) | 40 |
| Four 10s / Kings / Queens / Jacks | مية (Meya) | 20 |

### 6.3 Project Resolution

When both teams declare projects:

1. Compare the **highest project** using qaid value, then highest card, then turn order.
2. The **winning team's projects score.** The losing team's projects are **nullified** (0 qaid).

---

## 7. Scoring per Round

Scores are tracked in **qaid**, not raw card points.

### 7.1 Sun / Ashkal Mode

| Condition | Result |
|-----------|--------|
| Bidding team scores > 60 card points | Both teams keep their earned qaid |
| Bidding team scores ≤ 60 card points (Fall / سقوط) | Bidding team gets **0**. Opponents get the full round qaid. |

### 7.2 Hokm Mode

| Condition | Result |
|-----------|--------|
| Bidding team qaid > opponent qaid | Both teams keep earned qaid (including valid Baloot/projects) |
| Bidding team qaid ≤ opponent qaid (Fall / سقوط) | Bidding team gets **0**. Opponents get the round qaid plus all project/Baloot bonuses. |

### 7.3 Capot (Sweep)

If a team wins all 8 tricks, it receives a large capot qaid bonus in addition to any projects/Baloot.

### 7.4 Game End

- Teams accumulate qaid across multiple rounds.
- First team to reach or exceed the **target score** wins the game.
- Default target: **152**.

---

## 8. Doubling (Hokm Only)

After projects are resolved, the opposing team may **double** the round's stakes. The bidding team may then **redouble**, and so on, up to a maximum level. Sun/Ashkal rounds may be doubled once before play begins.

---

## 9. State Machine

```
WAITING (room lobby)
  └─ host starts ──▶ DEALING
                      └─ deal complete ──▶ BIDDING
                                            └─ bid resolved ──▶ PROJECTS (Sun/Ashkal only; skip for Hokm)
                                                                  └─ projects resolved ──▶ PLAYING
                                                                                          └─ 8 tricks done ──▶ SCORING
                                                                                                                  └─ scores applied ──▶ CHECK_WIN
                                                                                                                                     ├─ target reached ──▶ GAME_END
                                                                                                                                     └─ no winner ──▶ NEW_DEAL ──▶ DEALING
```

| State | Player Actions | Duration |
|-------|---------------|----------|
| WAITING | Chat, ready toggle, leave | Variable |
| DEALING | Watch animation | ~2 seconds |
| BIDDING | Pass, Sun, Hokm, Ashkal | ~10-30s per player |
| PROJECTS | Declare sequences/four-of-a-kind (auto-declared online) | ~5s |
| PLAYING | Play card | Variable (~5-15 min) |
| TRICK_END | Watch winner highlight | ~1.5 seconds |
| ROUND_END | View score breakdown | ~5 seconds |
| GAME_END | Rematch, leave room | Variable |

---

## 10. Edge Cases & House Rules

| Scenario | Rule |
|----------|------|
| All-pass bidding | Re-deal by next dealer |
| Disconnection | 60s reconnect window, then auto-play lowest legal card |
| Turn timeout | Auto-play lowest legal card after `turnTimeLimit` seconds |
| Spectators | See table but hands are hidden; read-only game doc view |
| Cheating | All card plays validated server-side; client cannot write to `games/{id}` |
| Misdeal | Handled by server-side card count validation |
| Qaid / Sawa claims | Players may claim rule violations (e.g., not following suit). Resolved by the server based on the actual hand history. |
