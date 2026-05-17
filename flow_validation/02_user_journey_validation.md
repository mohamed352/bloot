# Bloot — User Journey Validation

Detailed journey tables mapping every step a user takes, the expected outcome, and risks.

---

## 1. Casual Player Journey

*First-time user opens Bloot, finds a room, plays a full Baloot game, and leaves.*

| # | Step | Screen | Action | Expected Outcome | Pain Point / Risk |
|---|---|---|---|---|---|
| 1 | App Launch | Splash | Opens app | Splash logo animates, checks version & auth state | Slow cold-start on low-end devices; Firebase init timeout |
| 2 | Welcome | Welcome Onboarding | Swipes through 3 onboarding cards | Sees value proposition: play Baloot, watch streams, join tournaments | Too much text in Arabic RTL may overflow cards |
| 3 | Phone Entry | Auth — Phone Number | Enters Saudi mobile number (+966) | Number validated, OTP sent via Firebase Auth | User enters landline or non-Saudi number; SMS delivery delays |
| 4 | OTP Verify | Auth — OTP Verification | Types 6-digit code | Auth succeeds, Firestore user doc created | Auto-fill may grab wrong code; timer expires before entry |
| 5 | Profile Setup | Profile Setup | Picks avatar, enters nickname (Arabic OK) | Profile saved, redirected to Home | Nickname profanity filter rejects entry; avatar CDN slow |
| 6 | TOS Consent | Terms of Service | Scrolls, taps "Accept" | Consent recorded, onboarding complete | User declines — stuck on TOS, no skip option |
| 7 | Home Arrival | Home | Sees hero banner, quick actions, online friends | Contextual empty-state if no friends yet | Empty state feels cold; need mock data / suggestions |
| 8 | Find Room | Home — Quick Actions | Taps "Join Room" | Room code entry appears | User doesn't know any codes; no "Browse Rooms" option |
| 9 | Enter Code | Join Room — Code Input | Types 6-char room code | Validated, joins lobby if room exists & not full | Typos in code; room already started; room expired |
| 10 | Lobby Wait | Room Lobby | Sees 3 other avatars, taps "Ready" | Ready state saved to Firestore, others see indicator | Long wait if 4th player slow; no AI filler option |
| 11 | All Ready | Room Lobby → Game Play | All 4 players marked ready | Game host triggers deal, transition to game screen | Race condition — player disconnects between ready & deal |
| 12 | Bidding | Game — Bidding Phase | Player sees hand, selects bid | Bid recorded, highest bid wins, trump announced | Baloot-specific: null / doubled bids confuse new players; need tooltip |
| 13 | Trick Play | Game — Trick Phase | Plays card on each trick, 13 tricks per round | Animations for card play, trick winner highlighted | Network lag causes card play ordering issues; voice chat distraction |
| 14 | Round End | Game — Round Score | Sees round points, running total | "Next Round" button or auto-advance | Score math error edge-case: premature declaration wins |
| 15 | Game End | Game — Final Score | Sees winner banner, stats | Options: Rematch, Back to Home | Losing team frustration — no "learn" CTA |
| 16 | Return Home | Home | Taps "Back to Home" | Returns with updated stats reflected | Stats not immediately updated — Firestore cache lag |

---

## 2. Streamer Journey

*Player creates a room, sets up a live stream, and plays while viewers watch and interact.*

| # | Step | Screen | Action | Expected Outcome | Pain Point / Risk |
|---|---|---|---|---|---|
| 1 | Create Room | Home — Quick Actions | Taps "Create Room" | Room creation screen with settings | Overwhelming settings for first-time host; smart defaults needed |
| 2 | Configure Room | Create Room | Sets room name, privacy (public/private), speed mode | Room doc created in Firestore, unique 6-char code generated | Arabic room name encoding issues; code collision rare but possible |
| 3 | Invite Friends | Create Room → Lobby | Invites online friends via friend list or shares code | Friends receive push notification / in-app badge | Push notification not delivered if user disabled notifications |
| 4 | Enable Stream | Room Lobby — Stream Toggle | Toggles "Go Live" switch | Agora RTC token generated, stream published to CDN | Mic/camera permission denied on first use; unclear explanation |
| 5 | Permission Grant | System Permission Dialog | Grants mic & camera access | Audio/video streams initialized, preview shown | User denies permission — need graceful fallback to audio-only |
| 6 | Stream Preview | Room Lobby — Preview | Sees self in preview tile | Ready to start streaming with viewers | Preview adds CPU load on low-end devices |
| 7 | Start Waiting | Room Lobby | Waits for 4 players; viewers already watching stream | Viewer count badge updates in real-time | Viewers arrive before game starts — boring lobby content |
| 8 | All Players Ready | Room Lobby → Game | All 4 players tap Ready | Game begins; stream continues with game audio & face cam | Game audio bleeds into stream audio — need echo cancellation |
| 9 | Play & Narrate | Game — Trick Phase | Plays cards, narrates via mic | Viewers see card plays and hear commentary | Streamer accidentally reveals hand if face cam angle is wrong |
| 10 | Chat with Viewers | Stream — Chat Panel | Reads viewer chat sidebar | Chat messages scroll in RTL, emotes supported | Toxic chat — need real-time moderation / word filter for Arabic |
| 11 | Receive Gift | Stream — Gift Overlay | Viewer sends virtual gift | Gift animation plays, streamer's coin balance updated | Gift animation lags game on low-end device; coin fraud |
| 12 | Round Break | Game — Round Score | Quick intermission, engages with chat | Viewers stay engaged during break | Long breaks cause viewer drop-off; need "resume soon" indicator |
| 13 | Game End | Game — Final Score | Wraps up, thanks viewers | End-game overlay with stats, follow CTA | Abrupt stream ending — need "stream ending in 10s" countdown |
| 14 | End Stream | Stream Host Controls | Taps "End Stream" | Agora stream destroyed, VOD saved to storage, stats posted | Accidental tap — need confirmation dialog |
| 15 | Post-Stream | Home / Profile | Sees updated stream stats & coins earned | Stream replay available on profile | VOD processing takes time — "processing" state needed |

---

## 3. Viewer Journey

*User discovers a live stream, watches, interacts via chat and gifts, and follows the streamer.*

| # | Step | Screen | Action | Expected Outcome | Pain Point / Risk |
|---|---|---|---|---|---|
| 1 | Open Discover | Home → Discover Tab | Taps "Discover" bottom nav | Browse grid of live streams with thumbnails | Thumbnail CDN slow on mobile data; blank placeholders |
| 2 | Filter Streams | Discover | Filters by "Baloot" category or "Following" | Filtered stream list updates | Few streams = empty state; mixing categories confusing |
| 3 | Select Stream | Discover → Stream Watch | Taps stream card | Stream viewer opens, Agora subscriber token fetched | Stream takes >5s to load; spinner too long on 3G |
| 4 | Watch Gameplay | Stream Viewer | Watches live game, sees cards & faces | Low-latency video feed, synced audio | A/V sync drift over long sessions; audio too quiet |
| 5 | Open Chat | Stream — Chat Panel | Taps chat icon | Chat input bar appears, RTL Arabic supported | Keyboard pushes stream off-screen; need PiP mode |
| 6 | Send Message | Stream — Chat | Types message, taps send | Message appears in chat feed with timestamp | Message rate-limiting needed; spam filtering for Arabic |
| 7 | React | Stream — Reactions | Taps heart / fire emoji | Reaction animation overlays stream | Too many reactions = visual clutter; need throttling |
| 8 | Send Gift | Stream — Gift Overlay | Taps gift icon, selects gift | Gift animation plays, coins deducted from viewer | Insufficient coins — need "buy coins" flow inline |
| 9 | Buy Coins | Stream — Coin Purchase | Taps "Buy", selects package, processes payment | Coins added, gift sent successfully | Payment failure; Apple/Google IAP sandbox vs production |
| 10 | Follow Streamer | Stream — Follow Button | Taps "Follow" | Streamer added to following list, bell icon for notifications | Followed but no notification later — stale follower state |
| 11 | Share Stream | Stream — Share | Taps share icon | System share sheet opens with deep link | Deep link broken on some Android intents |
| 12 | Stream Ends | Stream — Ended Screen | Stream concludes automatically | "Follow [Name]" CTA + replay link | No replay available immediately; user leaves app |
| 13 | View Profile | Profile View | Taps streamer's avatar | Streamer profile with stats, past streams | Private profile blocks some info |
| 14 | Return Home | Home | Swipes back | Home feed updated with "recently watched" section | No persistent "continue watching" — hard to find stream again |

---

## 4. Tournament Player Journey

*Competitive player finds a tournament, registers, plays through bracket rounds, and either wins or gets eliminated.*

| # | Step | Screen | Action | Expected Outcome | Pain Point / Risk |
|---|---|---|---|---|---|
| 1 | Find Tournament | Home → Tournaments Tab | Taps "Tournaments" | List of upcoming & active tournaments with entry fees/prizes | Empty state if no tournaments available; confusing filters |
| 2 | Select Tournament | Tournament Detail | Taps tournament card | Detail page: rules, bracket preview, prize breakdown, timer | Too much text — Arabic RTL layout breaks if not carefully designed |
| 3 | Register | Tournament — Registration Modal | Taps "Join Tournament", confirms entry fee | Player added to bracket; confirmation notification sent | Payment required but wallet empty — need inline top-up |
| 4 | Wait for Start | Tournament — Bracket View | Watches countdown timer | Bracket populates as players register | Last-minute registrants cause bracket reshuffling |
| 5 | Match Assigned | Notification → Match Screen | Receives "Your match starts in 5 min" push | Player navigates to match room with opponent info | Notification not delivered; player misses match window |
| 6 | Enter Match Room | Tournament Match → Room Lobby | Taps "Enter Room" from bracket | Joins tournament room, ready state required | Opponent no-show — need auto-win rule & timeout |
| 7 | Play Round 1 | Game — Full Play | Plays Baloot game per tournament rules | Score verified, result sent to bracket | Dispute: player claims opponent cheated; need replay log |
| 8 | Advance | Tournament — Bracket View | Sees "Winner" badge on match | Advances to next round in bracket | Delay between rounds — player unsure if they proceed |
| 9 | Play Semi-Final | Game — Full Play | Repeats game play | Win/lose recorded | Higher stakes = more tilt / rage quits; need sportsmanship UI |
| 10 | Lose / Eliminated | Tournament — Round Score | Loses match | "Better Luck Next Time" screen, stats summary | Frustration — need encouragement, "enter another" CTA |
| 11 | Win / Champion | Tournament — Results | Wins final match | Trophy animation, prize coins deposited, leaderboard update | Prize coins not immediately visible — Firestore write lag |
| 12 | View Leaderboard | Tournament — Results → Profile | Checks global & tournament leaderboard | Ranking updated with ELO-style score | Leaderboard gaming / smurfing; need anti-abuse detection |
| 13 | Share Result | Tournament — Results | Taps "Share" | System share sheet with trophy card image | Card generation slow; share link broken on some platforms |
| 14 | Return Home | Home | Navigates back | Home shows "recently competed" tournament cards | Old tournament card lingers; need archive / dismiss option |

---

## Cross-Journey Edge Cases

| Edge Case | Affected Journeys | Expected Behaviour | Risk if Not Handled |
|---|---|---|---|
| Network loss mid-game | Casual, Streamer, Tournament | Reconnect overlay, auto-retry for 30s, game pauses | Game state corrupted; players lose progress |
| App backgrounded during bidding | Casual, Tournament | Paused state, resume when foregrounded | Bid timer expires unfairly; auto-fold penalty |
| Low battery / power save mode | All | Reduce animations, disable video, keep audio | App killed by OS; no graceful save |
| Simultaneous room invite + match | Casual | Priority queue: tournament > room invite | User confused by stacked modals |
| Duplicate login on another device | Streamer, Casual | Force logout current session with toast | Session conflict causes data corruption |
| Push notification disabled | All | In-app notification badge + red dot | User misses critical game start |
| Arabic text rendering in game cards | Casual, Tournament | Cards use symbols/numbers (Baloot standard) | Suit symbols render incorrectly in RTL |
| Viewer sends gift at game end | Viewer, Streamer | Gift queued and processed after score screen | Race condition in coin transaction |
| Tournament round timeout (opponent AFK) | Tournament | Auto-win after configurable timeout (default 2 min) | Bracket stalls; other players blocked |
| Cloud Firestore rate limit | All | Exponential backoff, local queue, retry | Write failures; score not recorded |