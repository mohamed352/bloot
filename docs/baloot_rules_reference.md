# Baloot (Bloot) — Saudi Arabian Rules Reference

> **Document purpose:** Consolidated reference for the traditional Saudi four-player partnership trick-taking card game Baloot (بلوت), also spelled *Bloot* in the app. Use this document when implementing, testing, or explaining game logic.
>
> **Sources:** Jawaker rules blog, Pagat card-game archive, CoolOldGames, LifeInSaudiArabia, plus widely accepted Saudi tournament conventions.

---

## 1. Overview

| Attribute | Value |
|-----------|-------|
| Players | 4 (fixed partnerships, partners sit opposite each other) |
| Deck | 32 cards (A, K, Q, J, 10, 9, 8, 7 of each suit) |
| Deal rotation | Anticlockwise; dealer rotates to the right after each hand |
| Objective | Be the first partnership to reach **152 game points** (match / صكة) |
| Game modes | **Sun** (no trumps) and **Hokum** (trump suit) |

Baloot is derived from the French game Belote but has important differences: the no-trump *Sun* contract scores double, opponents can double a *Hokum* contract and "lock" the trump leads, and the first trick is always led by the player to dealer's right, **not** by the declarer.

---

## 2. Card Rankings & Values

### 2.1 Trick-taking rank (highest → lowest)

**In a Hokum (trump) suit:**

```
J → 9 → A → 10 → K → Q → 8 → 7
```

**In a non-trump suit (and in Sun):**

```
A → 10 → K → Q → J → 9 → 8 → 7
```

### 2.2 Card point values

| Card | Hokum trump value | Non-trump / Sun value |
|------|-------------------|-----------------------|
| J    | 20                | 2                     |
| 9    | 14                | 0                     |
| A    | 11                | 11                    |
| 10   | 10                | 10                    |
| K    | 4                 | 4                     |
| Q    | 3                 | 3                     |
| 8    | 0                 | 0                     |
| 7    | 0                 | 0                     |

- Total card points available in a Hokum hand: **162** (including 10 for the last trick).
- Total card points available in a Sun hand: **130** (including 10 for the last trick).

### 2.3 Sequence rank for projects/melds

For forming sequences only, the rank is:

```
A → K → Q → J → 10 → 9 → 8 → 7
```

So `A-K-Q` is a valid sequence, but `A-10-K` is not.

---

## 3. Deal & Bidding

### 3.1 First deal

1. Dealer shuffles; player to dealer's left may cut or ask to proceed without cutting.
2. Dealer deals **5 cards** to each player: first a packet of 3 each (starting with player to dealer's right, ending with dealer), then a packet of 2 each.
3. The 21st card is placed **face up** on the table — the *public card* / *buyer*.
4. The remaining cards are set aside until after bidding.

### 3.2 First round of bidding

Dealer announces "First". Players speak in turn starting with the player to dealer's right.

| Bid | Meaning |
|-----|---------|
| **Pass** | No commitment this round. |
| **Hokum** | Offer to play with the **suit of the face-up card** as trumps. If it stands, the bidder becomes declarer and takes the face-up card. |
| **Sun** | Offer to play with **no trumps**. Supersedes Hokum. The final Sun bidder becomes declarer and takes the face-up card. |
| **Ashkal** | Only available to the 3rd or 4th player if all previous players passed. Same as Sun, but the bidder's **partner** takes the face-up card and becomes declarer. |

- If multiple players want to bid Sun, the one **earliest in rotation** (starting from dealer's right) has priority.
- If a player bids Hokum, any later player may overcall with Sun.

### 3.3 Second round of bidding

If all four players pass in the first round, the dealer announces "Second". Players may now bid:

| Bid | Meaning |
|-----|---------|
| **Pass** | No commitment. |
| **Hokum** | Offer to play with a trump suit **different** from the face-up card. If it stands, the bidder takes the face-up card and must name the trump suit before the rest of the deal. |
| **Sun** | Offer to play no trumps. Ends bidding immediately. |

- No Ashkal in the second round.
- A player who passed in the second round cannot later bid Sun.

If all players pass in the **second** round, the hand is thrown in, there is no score, and the deal passes to the right.

### 3.4 Completing the deal

After a successful bid, the dealer deals the remaining cards so each player has 8:

- The player who took the face-up card receives **2 cards**.
- Each of the other three players receives **3 cards**.

---

## 4. Doubling, Locking & Gahwa

These options apply only after a **Hokum** bid is finalized.

| Announcement | Effect |
|--------------|--------|
| **Double** | An opponent doubles the hand score. The doubler must also specify **locked** or **open**. |
| **Triple** | The declarer's team responds to a Double, tripling the score. Play is always open. |
| **Quadruple** | The original doubler responds to Triple, quadrupling the score. Must specify locked/open. |
| **Gahwa** | The declarer's team responds to Quadruple. If they win the hand, they win the **entire match** immediately. |

### Locked vs Open

- **Locked (closed):** No player may lead a trump to a trick unless their hand consists **entirely** of trumps.
- **Open:** Any card may be led freely.

### Sun doubling

- A Sun hand may only be doubled if one team has **>100 points** and the other has **<100 points**.
- Only a single Double is allowed in Sun — no Triple, Quadruple, or Gahwa.
- There is no locking because there is no trump suit.

---

## 5. Play of the Hand

### 5.1 Leading

Irrespective of who is declarer, the **player to dealer's right** leads to the first trick. The winner of each trick leads to the next.

### 5.2 Following suit

- Players must **follow suit** if able.
- In **Sun**, if a player cannot follow suit, any card may be played (but it cannot win the trick).
- In **Hokum**, the rules are more detailed (see below).

### 5.3 Hokum play rules

- **Trump beats any non-trump.** A higher trump beats a lower trump.
- If a player cannot follow a non-trump lead, they must play a trump if they have one (subject to winning obligations below).
- If a trump is led, a player with a higher trump must play a higher trump if an opponent is currently winning the trick.

#### Ekka (Ace declaration)

When leading a non-trump card that is the **highest remaining card of its suit**, the leader may say "Ekka". This informs partner that it is safe to discard. It is illegal to say Ekka if a higher card of that suit is still in play; unnecessary but not illegal when leading an Ace.

#### Third-player rule summary

If the third player cannot follow suit:

- If the **second player is winning** the trick, the third player must beat it with a trump if possible.
- If the **first player is winning** and led an Ace **or** said Ekka, the third player may play any card.
- If the first player is winning but did **not** lead an Ace or say Ekka, the third player must play a trump if possible (even if the first player's card is certain to win).

### 5.4 Trick winner

Each trick is won by:

1. The highest trump in the trick, **or**
2. If no trumps are played, the highest card of the suit that was led.

The team that wins the **last trick** receives a **+10 card-point bonus**.

---

## 6. Projects (Melds / Bonuses)

Projects are card combinations held in a player's hand. They are declared at the first trick and scored at the end of the round.

### 6.1 Valid projects

| Project | Cards required | Hokum score | Sun score |
|---------|----------------|-------------|-----------|
| **Sira** | 3 consecutive cards of the same suit | 2 | 4 |
| **50 (Khamsin)** | 4 consecutive cards of the same suit | 5 | 10 |
| **100** | 5 consecutive cards of the same suit, OR four Jacks/Queens/Kings/Tens, OR four Aces | 10 | 20 |
| **400 (Arba'miya)** | Four Aces | — | 40 |

Notes:

- Sequences use the **sequence ranking**: A-K-Q-J-10-9-8-7.
- A card may **not** be used in two projects simultaneously.
- Four 9s, 8s, or 7s have no value as a project.

### 6.2 Declaring and comparing projects

- Each player may declare **one** project at their turn to play to the **first trick**, provided no higher project has already been declared.
- Only the team with the **best single project** scores **all** of its projects; the opposing team's projects score nothing.
- Projects are compared by:
  1. Point value (higher is better).
  2. Type: four-of-a-kind beats a 5-card sequence.
  3. Highest card in the sequence (sequence rank).
  4. If still tied, the project belonging to the player **nearest dealer's right** (declared earlier) wins.

At the **second trick**, the player with the best project shows the cards face up. Their partner may also show and score any projects they hold. The opposing team may not show or score projects.

### 6.3 Baloot (special meld)

- **Baloot** = King and Queen of trumps held in one hand.
- Exists **only in Hokum**.
- Worth **2 game points**.
- Normally declared when the **second** of the two cards is played.
- Can be scored by either team, even the opponents of the team that scored projects.
- If a Sira or 50-project contains a Baloot, the Baloot is scored automatically.
- If a 100-project contains a Baloot, no extra Baloot points are awarded.

---

## 7. Scoring

### 7.1 Counting card points

After all 8 tricks are played:

1. One team counts the value of cards in the tricks they took.
2. Add **10** if they won the last trick.
3. Convert card points to game points (see below).

#### Hokum conversion

- Round the counting team's card points to the nearest 10 (5 rounds **down**).
- Divide by 10.
- The other team gets the remainder from **16** game points.

Examples:

| Counting team card points | Game points for counting team | Game points for other team |
|---------------------------|-------------------------------|----------------------------|
| 77 | 8 | 8 |
| 66 | 7 | 9 |
| 91 | 9 | 7 |

#### Sun conversion

- Round the counting team's card points to the nearest 10.
- If the units digit is **5**, do **not** round.
- Divide by 5.
- The other team gets the remainder from **26** game points.

Examples:

| Counting team card points | Game points for counting team | Game points for other team |
|---------------------------|-------------------------------|----------------------------|
| 63 | 12 | 14 |
| 65 | 13 | 13 |
| 55 | 11 | 15 |

### 7.2 Which team counts?

- **No double:** The declarer's **opponents** count.
- **Double / Quadruple:** The declarer's **team** counts (they were last to increase).
- **Triple / Gahwa:** The declarer's **opponents** count (they were last to increase).

### 7.3 Adding projects & Baloot

- Add project and Baloot points to the team that showed/declared them.
- If the winning team cannot achieve the required points in Sun, they lose the round.

### 7.4 Determining the winner of the hand

- The team with more game points (cards + projects + Baloot) wins.
- If game points are **tied**, the tie is broken by who lost more points in rounding. If rounding was equal, the **declarer's team** wins.

Detailed tie-break (Hokum):

| Counting team card-point units digit | Winner |
|--------------------------------------|--------|
| 2, 3, 4, 5 | Counting team |
| 6, 7, 8, 9, 0 | Counting team loses (declarer's team wins) |
| 1 | Exact tie → declarer's team wins |

Detailed tie-break (Sun):

| Counting team card-point units digit | Winner |
|--------------------------------------|--------|
| 1, 2, 3, 4 | Counting team |
| 6, 7, 8, 9 | Counting team loses |
| 0 or 5 | No rounding → declarer's team wins |

### 7.5 Recording the score

| Scenario | Scoring rule |
|----------|--------------|
| No double, declarer's team wins | Each team adds their own game points to their cumulative score. |
| No double, declarer's team loses | The counting team scores **all** game points for cards, projects, and Baloot. The declarer's team scores nothing. |
| Doubled/Tripled/Quadrupled | The winning team scores **all** game points; the losing team scores nothing. Card points are multiplied by the bid multiplier. Project points are doubled (not tripled/quadrupled). Baloot always scores 2. |
| Gahwa | The winners of the hand win the entire match immediately. |
| Al-kaboot (one team wins all 8 tricks) | Hokum: 25 game points + own projects. Sun: 44 game points + own projects. Opponents score nothing. In a doubled hand these values double. |

### 7.6 Match end

- The match ends when one partnership reaches **152 or more game points**.
- If both teams reach 152 or more on the same hand, the team that scored more in that hand wins; otherwise another hand is played to break the tie.

---

## 8. Variations & Edge Cases

| Situation | Common rule |
|-----------|-------------|
| All pass in both bidding rounds | Hand is thrown in; no score; deal passes right. |
| Hand with only 7/8/9 cards (Kawesh / Saneen) | Some groups allow annulling the deal and re-dealing. |
| Cutting player takes public card | Some house rules let the cutter take the top or bottom three cards. |
| Trump-sequence priority | In some regions, a trump sequence beats an equal non-trump sequence. |
| Baloot within project | Some groups score Baloot automatically with a Sira/50; others require separate declaration. |

---

## 9. How This Maps to the Bloot App

The app engine (`functions/src/engine/` and `lib/features/game/`) currently implements:

- 32-card deck, 5+4+4 deal, face-up buyer card.
- Sun and Hokum bidding with Pass / Sun / Hokm.
- Trick-taking with Hokum trump rules.
- Card-point counting, rounding, and cumulative scoring toward 152.
- Projects (Sira, 50, 100, 400) and Baloot detection.
- Bot players for single-device simulator mode.

Items that are **not** currently part of the app engine and may be added later:

- Ashkal bidding.
- Ekka declarations.
- Full locked/open doubling semantics and Gahwa match-ending rule.
- Detailed third/fourth-player Hokum obligation rules (some shortcuts are used for bot play).

---

## 10. References

1. Jawaker — *Baloot Rules* (2024): https://blog.jawaker.com/en/baloot-rules-en/
2. Pagat — *Baloot card game rules* (archive): https://www.pagat.com/jass/baloot.html
3. CoolOldGames — *Baloot | Rules & How to Play*: https://www.coololdgames.com/card-games/trick-taking/jass/baloot/
4. LifeInSaudiArabia — *Rules to play Baloot game*: https://lifeinsaudiarabia.net/rules-to-play-baloot-game/
5. AGBI — *Investors go all-in as Saudi card game Baloot moves online* (2025): https://www.agbi.com/gaming/2025/09/investors-go-all-in-as-saudi-card-game-baloot-moves-online/
