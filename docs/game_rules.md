# Bloot — Definitive Baloot Game Rules

> **Authority:** This document resolves all contradictions in `research/04_balout_game_mechanics.md` and external sources. It is the single source of truth for the Bloot game engine implementation.
> **Deck:** Standard 52-card deck (not the 32-card variant). This matches the existing project specification, mock data, and Cloud Functions design.

---

## 1. Game Overview

| Attribute | Value |
|---|---|
| Players | 4 (2 teams of 2) |
| Partners | Sit opposite each other |
| Team A | Seats 0 and 2 |
| Team B | Seats 1 and 3 |
| Deck | 52 cards (A, K, Q, J, 10, 9, 8, 7, 6, 5, 4, 3, 2) × 4 suits |
| Cards per player | 13 |
| Tricks per round | 13 |
| Modes | Sun (صن) and Hokm (حكم) |
| Target score | 152 (configurable: 152, 250, 300) |

---

## 2. Dealing

### 2.1 Procedure

1. Dealer shuffles the deck.
2. Player to dealer's right cuts.
3. Dealer distributes counter-clockwise:
   - **First round:** 5 cards to each player
   - **Second round:** 4 cards to each player
   - **Third round:** 4 cards to each player
   - **Total:** 13 cards per player
4. The **last card dealt** (to the dealer) is placed **face-up** on the table.
5. This face-up card determines the **proposed trump suit** for bidding.

### 2.2 Dealer Rotation

- Dealer rotates **clockwise** after each round.
- `dealerIndex` cycles 0 → 1 → 2 → 3 → 0.

---

## 3. Bidding Phase

### 3.1 Bid Options

| Bid | Arabic | Hierarchy | Requirement |
|-----|--------|-----------|-------------|
| Pass | باص | Lowest | Always allowed |
| Sun | صن | Middle | Allowed if no higher bid yet |
| Hokm | حكم | Highest | Bidder must hold **≥1 card** of the face-up card's suit |

### 3.2 Bidding Rules

- Bidding proceeds **clockwise** starting from the player to the dealer's right.
- Each player bids once per round (Pass, Sun, or Hokm).
- Once a player bids **Sun** or **Hokm**, subsequent players can only bid **higher**.
- **Bid hierarchy:** Hokm > Sun > Pass.
- The **first Hokm bidder** wins the bid if Hokm is the final game type.
- The **last Sun bidder** wins the bid if Sun is the final game type.
- **All four Pass → re-deal** by the same dealer.

### 3.3 Bid Winner

- Bid winner's team becomes the **bidding team** (الطالب).
- The opposing team is **الخصم**.
- In Hokm mode, the trump suit is the suit of the face-up card.

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
| 9, 8, 7, 6, 5, 4, 3, 2 | 0 |

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
| ... | 6, 5, 4, 3, 2 | 0 |

**Trump suit total:** 62  
**Non-trump suit total:** 30  
**Total per round (Hokm):** 62 + (30 × 3) = **152**

### 4.3 Card Rank Order

**Non-trump / Sun:**  
`A > 10 > K > Q > J > 9 > 8 > 7 > 6 > 5 > 4 > 3 > 2`

**Trump (Hokm):**  
`J > 9 > A > 10 > K > Q > 8 > 7 > 6 > 5 > 4 > 3 > 2`

---

## 5. Trick Play

### 5.1 Rules

1. **Bid winner leads the first trick.**
2. Players **must follow suit** if they hold any card of the led suit.
3. If a player is **void** in the led suit, they may:
   - Play any **trump** card (to try to win the trick)
   - **Discard** any non-trump card (concede the trick)
4. All 13 tricks are played. There is **no early termination**.

### 5.2 Trick Winner Determination

1. If **any trump** was played → highest trump wins.
2. If **no trump** played → highest card of the **led suit** wins.
3. Winner of the trick **leads the next trick**.

---

## 6. Bonuses (Hokm Only)

> **Bonuses do NOT apply in Sun mode.**

### 6.1 Bnaga (Sequence)

A sequence of 3+ cards of the **same suit** in consecutive rank order.

| Length | Name | Points |
|--------|------|--------|
| 3 | Bnaga Thalatha (بنقة ثلاثة) | 20 |
| 4 | Bnaga Arba'a (بنقة أربعة) | 50 |
| 5+ | Bnaga Khamsa (بنقة خمسة) | 100 |

**Ranking for sequences:** A > K > Q > J > 10 > 9 > 8 > 7 > 6 > 5 > 4 > 3 > 2

**Rules:**
- Only the **longest sequence per suit** counts.
- If both teams have sequences of the same length, the team with the **higher-ranking sequence** wins.
- Sequences are declared during the **bonus claim phase** (before the first trick).

### 6.2 Mosal (Four of a Kind)

Four cards of the same rank.

| Rank | Name | Points |
|------|------|--------|
| Four Jacks | Mosal Jawj (مصل جوج) | 200 |
| Four Nines | Mosal Tisa (مصل تسعة) | 150 |
| Four Aces | Mosal Ace | 100 |
| Four Tens | Mosal 'Ashra | 100 |
| Four Kings | Mosal Malik | 100 |
| Four Queens | Mosal Malika | 100 |

**Rules:**
- Only the **highest-value mosal** per team counts.
- Mosal is declared during the **bonus claim phase**.

### 6.3 Bonus Resolution

When both teams declare bonuses:

1. **Compare mosal first.** Higher mosal wins. The losing team loses **ALL** their bonuses (mosal + sequences).
2. If no mosal or tied mosal, compare **longest sequence.** Longer wins.
3. If sequences are equal length, compare **highest card in the sequence.**
4. The **winning team's bonuses score.** The losing team's bonuses are **nullified** (0 points).

---

## 7. Scoring per Round

### 7.1 Sun Mode

| Condition | Result |
|-----------|--------|
| Bidding team scores > 60 | Both teams keep their earned points |
| Bidding team scores ≤ 60 (Fall / سقوط) | Bidding team gets **0**. Opponents get **120**. |

### 7.2 Hokm Mode

| Condition | Result |
|-----------|--------|
| Bidding team score > opponent score | Both teams keep earned points (including their valid bonuses) |
| Bidding team score ≤ opponent score (Fall / سقوط) | Bidding team gets **0**. Opponents get **152 + all bonuses from BOTH teams**. |

### 7.3 Game End

- Teams accumulate points across multiple rounds.
- First team to reach or exceed the **target score** wins the game.
- Default target: **152**.

---

## 8. State Machine

```
WAITING (room lobby)
  └─ host starts ──▶ DEALING
                      └─ deal complete ──▶ BIDDING
                                            └─ bid resolved ──▶ BONUS_CLAIM (Hokm only; skip for Sun)
                                                                  └─ bonuses resolved ──▶ PLAYING
                                                                                          └─ 13 tricks done ──▶ SCORING
                                                                                                                  └─ scores applied ──▶ CHECK_WIN
                                                                                                                                         ├─ target reached ──▶ GAME_END
                                                                                                                                         └─ no winner ──▶ NEW_DEAL ──▶ DEALING
```

| State | Player Actions | Duration |
|-------|---------------|----------|
| WAITING | Chat, ready toggle, leave | Variable |
| DEALING | Watch animation | ~2 seconds |
| BIDDING | Sun, Hokm, Pass | ~10-30s per player |
| BONUS_CLAIM | Declare sequences/mosal | ~15-30s |
| PLAYING | Play card | Variable (~5-15 min) |
| TRICK_END | Watch winner highlight | ~1.5 seconds |
| ROUND_END | View score breakdown | ~5 seconds |
| GAME_END | Rematch, leave room | Variable |

---

## 9. Edge Cases & House Rules

| Scenario | Rule |
|----------|------|
| All-pass bidding | Re-deal by same dealer |
| Disconnection | 60s reconnect window, then auto-play lowest legal card |
| Turn timeout | Auto-play lowest legal card after `turnTimeLimit` seconds |
| Spectators | See table but hands are hidden; read-only game doc view |
| Cheating | All card plays validated server-side; client cannot write to `games/{id}` |
| Misdeal | Handled by server-side card count validation |
