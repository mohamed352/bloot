# Bloot User Stories

## Priority Definitions

- **P0**: Must-have for MVP launch. App is non-functional without these.
- **P1**: Should-have for competitive launch. App feels incomplete without these.
- **P2**: Nice-to-have for post-MVP. Enhances experience but not critical for launch.

---

## Room & Game

### P0

**US-RG01: Join a Baloot Room**
As a player, I want to join a Baloot room using a room code so that I can play with my friends.

Acceptance Criteria:
- Player can enter a 6-digit room code
- Invalid codes show clear error message
- Player is placed in room lobby upon successful join
- Player sees other players already in room
- Player can leave the room before game starts without penalty

---

**US-RG02: Play a Standard Baloot Game**
As a player, I want to play a complete Baloot game with correct rules so that I can enjoy the authentic experience.

Acceptance Criteria:
- Game follows Khaleeji Baloot rules (documented in 04_balout_game_mechanics.md)
- 4 players, 2 teams, 52-card deck
- Both Sun (صن) and Hokm (حكم) modes supported
- Scoring is accurate per Baloot rules
- Game state persists through rotation (device rotation, app backgrounding)
- Cards are rendered with Arabic-friendly design

---

**US-RG03: Voice Chat During Game**
As a player, I want to talk to other players in my room via voice chat so that I can communicate naturally like playing in person.

Acceptance Criteria:
- Voice chat activates when player unmutes mic
- Mute/unmute toggle is accessible during gameplay without obscuring cards
- Audio quality is clear with minimal latency (< 300ms)
- Echo cancellation is active by default
- Player who is speaking has visual indicator (avatar glow/border)
- Background noise suppression is enabled

---

**US-RG04: Camera Feed During Game**
As a player, I want to enable my camera so that other players can see me while we play.

Acceptance Criteria:
- Camera toggle is available in room lobby and during game
- Camera feed appears as small overlay in corner for self, and as tile for others
- Camera can be turned on/off at any time
- Camera preview shows before enabling (confirm appearance)
- Front camera is default; back camera available via toggle
- Video quality adapts to network conditions
- Camera overlay does not obstruct game cards

---

**US-RG05: Create a Room**
As a player, I want to create a Baloot room so that I can invite my friends to play.

Acceptance Criteria:
- Player can set room name, privacy (public/private), voice/camera defaults
- System generates shareable room code upon creation
- Creator is automatically the room host
- Creator can share room code via system share sheet
- Creator can kick players from room
- Creator can start game when 4 players are present

---

### P1

**US-RG06: Quick Matchmaking**
As a player, I want to quickly find and join a public room so that I can play even when my friends aren't online.

Acceptance Criteria:
- "Quick Play" button on Home screen
- System matches player with available room needing players
- Matching considers player skill level (basic ELO)
- Wait time indicator shows estimated time to find game
- Player can cancel matchmaking at any time

---

**US-RG07: Room Customization**
As a room host, I want to customize my room settings so that it matches my group's preferences.

Acceptance Criteria:
- Set target score (120 for Sun, variable for Hokm)
- Enable/disable camera requirement
- Set room description
- Choose table theme/skin (from unlocked options)

---

**US-RG08: Spectate a Game**
As a player, I want to watch an ongoing Baloot game in a room so that I can learn or enjoy without participating.

Acceptance Criteria:
- Spectate option available for full rooms
- Spectator sees all 4 hands (with player permission) or only played cards
- Spectator has separate text chat channel
- Spectator count visible to players
- Spectator can leave at any time

---

### P2

**US-RG09: Game History**
As a player, I want to review my past games so that I can track my performance over time.

Acceptance Criteria:
- List of recent games with result, date, players
- Basic stats per game (score, tricks won)
- Filter by date range and result (win/loss)

---

**US-RG10: AI Opponents**
As a player, I want to play against AI when I can't find 3 other players so that I can practice and enjoy solo.

Acceptance Criteria:
- AI fills empty seats in room
- AI plays at reasonable skill level (not too easy, not perfect)
- AI responds to game state logically
- AI doesn't replace human players who join mid-wait

---

## Streaming

### P0

**US-ST01: Watch a Live Stream**
As a viewer, I want to watch a live Baloot stream so that I can enjoy high-level gameplay and entertainment.

Acceptance Criteria:
- Live streams appear on Home screen in "Live Now" section
- Tapping a stream opens full stream view
- Stream shows game state, player camera feeds, and chat
- Viewer can read and send chat messages (if logged in)
- Stream latency is under 5 seconds for video
- Viewer can follow streamer from stream view

---

### P1

**US-ST02: Start a Live Stream**
As a player, I want to start a live stream of my game so that I can share my gameplay with an audience.

Acceptance Criteria:
- "Go Live" button accessible from Home screen
- Streamer sets title before going live
- Streamer's followers receive push notification
- Streamer can see viewer count during stream
- Streamer can end stream at any time
- Stream summary provided at end (duration, peak viewers, gifts)

---

**US-ST03: Stream Chat**
As a viewer, I want to chat during a live stream so that I can interact with the streamer and other viewers.

Acceptance Criteria:
- Chat messages appear in real-time
- Messages support Arabic text (RTL)
- Chat has rate limiting (max 5 messages per 10 seconds)
- Offensive words are filtered (basic profanity filter)
- Viewer can report inappropriate messages
- Chat is collapsible to focus on game view

---

**US-ST04: Stream Discovery**
As a viewer, I want to discover new streams so that I can find entertaining Baloot content.

Acceptance Criteria:
- "Live Now" section on Home screen
- Streams sorted by viewer count (default) or most recent
- Search by streamer name
- Category tags (beginner, competitive, casual)

---

### P2

**US-ST05: Send Gifts to Streamer**
As a viewer, I want to send virtual gifts to a streamer so that I can show appreciation and support.

Acceptance Criteria:
- Gift tray accessible from stream view
- Multiple gift tiers (5, 10, 50, 200 coins)
- Gift animation plays on stream
- Gift sender visible in chat
- Coins deducted immediately

---

**US-ST06: Stream Replay**
As a viewer, I want to watch past stream recordings so that I can enjoy content I missed live.

Acceptance Criteria:
- Past streams available on streamer's profile
- Replays are recorded automatically
- Replay includes chat replay (optional)
- Seek and pause controls available

---

## Social

### P1

**US-SO01: Follow a Player**
As a player, I want to follow other players so that I can see their activity and get notified when they stream.

Acceptance Criteria:
- Follow button on player profile and stream view
- Follower count visible on profile
- Following list and followers list on profile
- Push notification when followed player goes live
- Unfollow option with no confirmation needed

---

**US-SO02: Player Profile**
As a player, I want to have a profile that shows my stats and identity so that others can recognize me.

Acceptance Criteria:
- Profile displays: avatar, username, level, bio
- Game stats: games played, win rate, favorite mode
- Follower and following counts
- Recent activity (games, streams)
- Profile is public by default; can be set to private

---

**US-SO03: Online Status**
As a player, I want to see which of my friends are online so that I can invite them to play.

Acceptance Criteria:
- Online/offline/in-game indicators on friend list
- Status visible on profile
- "In Game" status shows which room (if public)
- Offline timestamp shown (last seen)

---

### P2

**US-SO04: Direct Messages**
As a player, I want to send private messages to my friends so that I can coordinate games or chat privately.

Acceptance Criteria:
- Chat list shows recent conversations
- Messages support text and images
- Real-time message delivery
- Push notification for new messages when offline
- Block and report options available

---

**US-SO05: Friend Suggestions**
As a player, I want to see suggested friends so that I can grow my Bloot social network.

Acceptance Criteria:
- Suggestions based on: contacts import, mutual friends, recent opponents
- "Add Friend" button on suggestion card
- Dismiss option for unwanted suggestions

---

**US-SO06: Activity Feed**
As a player, I want to see a feed of my friends' activity so that I stay engaged with the community.

Acceptance Criteria:
- Shows: game results, stream starts, achievements, level ups
- Chronological feed on Home or dedicated tab
- Like and comment on activity items

---

## Profile

### P0

**US-PR01: Create a Profile**
As a new user, I want to create a profile so that I can use Bloot with a persistent identity.

Acceptance Criteria:
- Sign up with phone number (primary) or Apple/Google sign-in
- Choose username (unique, 3-20 characters, Arabic or Latin)
- Select avatar (from preset gallery in MVP)
- Skip optional fields (bio, etc.) for quick onboarding
- Phone number verification via SMS OTP
- Profile is created and accessible immediately

---

**US-PR02: Edit Profile**
As a player, I want to edit my profile so that I can update my information and appearance.

Acceptance Criteria:
- Edit username (once per 30 days)
- Change avatar
- Update bio (max 150 characters)
- Change privacy settings

---

### P1

**US-PR03: View Player Stats**
As a player, I want to see my game statistics so that I can understand my performance.

Acceptance Criteria:
- Total games played
- Win/loss record
- Win percentage
- Favorite game mode (Sun vs Hokm)
- Current ELO rating
- Level and XP progress

---

**US-PR04: Achievement Badges**
As a player, I want to earn achievement badges so that I feel rewarded for milestones.

Acceptance Criteria:
- Badges displayed on profile
- Unlock conditions (e.g., "Win 10 games," "Play 100 games")
- Notification when new badge earned
- Badge rarity indicator (common, rare, epic, legendary)

---

### P2

**US-PR05: Detailed Match History**
As a player, I want to see detailed history of my matches so that I can analyze my gameplay.

Acceptance Criteria:
- Per-game breakdown: score, tricks, teammates, opponents
- Filtering by date, mode, result
- Export data (future consideration)

---

## Priority Summary

| Category | P0 | P1 | P2 | Total |
|---|---|---|---|---|
| Room & Game | 5 | 3 | 2 | 10 |
| Streaming | 1 | 3 | 2 | 6 |
| Social | 0 | 3 | 3 | 6 |
| Profile | 2 | 2 | 1 | 5 |
| **Total** | **8** | **11** | **8** | **27** |

### MVP (P0) Story Count: 8 stories
### V1.0 (P0 + P1) Story Count: 19 stories
### V2.0 (All) Story Count: 27 stories
