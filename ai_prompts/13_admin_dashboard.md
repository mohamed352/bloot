# Admin Dashboard Prompt

## Context

Include `00_master_rules.md` before using this prompt.

## CRITICAL: English Only — Dark Theme Admin Dashboard

All admin screens MUST be generated in **English only**. The admin dashboard uses a **dark theme** matching the mobile app. This is NOT a light-themed admin panel.

## Screen: Admin Dashboard (13 screens)

The admin dashboard is a web application for platform operations staff. It uses the same dark theme, purple/gold color palette, and design language as the Bloot mobile app, adapted for a data-dense desktop interface.

### Shared Layout

Every admin screen shares this layout:
- **Left sidebar** (w-64): Dark elevated surface (`#161622`), Bloot logo + "Admin" label in gold, 13 navigation items with material symbols icons, user info at bottom
- **Main content** (flex-1): Dark surface (`#0A0A0F`), sticky header with page title and action buttons, scrollable content area with p-8 padding
- **Active nav state**: `bg-purple-500/10 text-purple-400 border-r-2 border-purple-400`

### 01 Home Stats

**Requirements:**
- Dark background (`#0A0A0F`)
- KPI cards (4-column grid):
  - Active Players Now: number + green pulse + "+12% vs yesterday"
  - Live Streams: number + red LIVE badge + total viewers
  - Games in Progress: number
  - Pending Reports: number + red badge if >0
- Charts (2x2 grid, Chart.js):
  - Daily Active Users (line, 30d)
  - Games Played Per Day (bar, 7d)
  - Coin Economy (doughnut)
  - Stream Viewers (line, 7d)
- Recent Activity feed (10 items)
- Alert cards: Pending Reports, Unresolved Disputes, Large Transactions, Stream Complaints

**Output:** HTML admin dashboard home

### 02 User Management

**Requirements:**
- Search + filter (Status, Level range, Date)
- Stats row: Total / Active / Suspended / Banned
- Table: Avatar+Name+Username | Phone | Level | Games | Win Rate | Coins | Status | Actions
- Status badges: Active (green), Suspended (yellow), Banned (red)
- User detail drawer (right side): Profile, Game stats, Coin history, Reports
- Actions: View, Suspend, Ban

**Output:** HTML user management

### 03 Report Review

**Requirements:**
- Tabs: Pending / In Review / Resolved / Dismissed
- Filter: Type, Severity, Date range
- Table: ID | Reporter | Reported | Type | Reason | Severity | Date | Status | Actions
- Type badges: User (blue), Room (purple), Stream (red), Message (gray)
- Severity badges: Low (green), Medium (yellow), High (orange), Critical (red)
- Review modal: Full report details, context, resolution notes
- Actions: Resolve, Dismiss, Escalate, Ban User

**Output:** HTML report review

### 04 Tournament Management

**Requirements:**
- Gold "Create Tournament" button
- Tabs: Upcoming / Active / Completed / All
- Stats: Total / Active / Upcoming / Completed
- Table: Name (EN+AR) | Type | Status | Start Date | Players | Prize | Fee | Actions
- Create/Edit modal: Name EN/AR, Description EN/AR, Type, Game mode, Max players, Entry fee, Prize distribution, Rules config, Banner image, Status
- Bracket view for active tournaments

**Output:** HTML tournament management

### 05 Game Monitor

**Requirements:**
- Filters: Mode, Status, Date, Player
- Stats: Total / Completed / Disputed / Abandoned
- Table: Game ID | Players (4 avatars) | Mode | Score | Duration | Status | Actions
- Mode badges: Sun (blue), Hokm (gold)
- Game detail modal: Play-by-play log, chat log, dispute handling
- Actions: Override Result, Issue Penalty

**Output:** HTML game monitor

### 06 Room Monitor

**Requirements:**
- Tabs: Active / Waiting / All
- Filter: Room type
- Stats: Total / Active / Waiting / Avg Duration
- Table: Code | Name | Type | Players | Host | Duration | Status | Actions
- Type badges: Private, Public, Stream, Voice Only
- Room detail drawer: Settings, 4 player slots, chat log, game history
- Actions: Force Close, Remove Player, Mute Chat

**Output:** HTML room monitor

### 07 Stream Moderation

**Requirements:**
- Tabs: Live Now / Recently Ended / Reported / All
- Table: Stream ID | Streamer | Viewers | Duration | Reports | Status | Actions
- Stream review modal: Thumbnail, streamer profile, chat log (flagged messages highlighted), gift history, report summary
- Actions: End Stream, Mute Streamer, Issue Warning, Ban from Streaming

**Output:** HTML stream moderation

### 08 Coin Transactions

**Requirements:**
- Summary cards: Total in Circulation, Purchased (SAR), Spent, Net Flow
- Filters: Type, User, Amount threshold, Date
- Table: ID | User | Type | Amount (+/-) | Balance | Reference | Date | Actions
- Type badges: Earn (green), Spend (red), Gift (purple), Purchase (gold), Tournament (blue)
- Flagged transactions section (orange border)
- Transaction detail: Full details, balance history

**Output:** HTML coin transactions

### 09 Achievement Management

**Requirements:**
- Tabs: All / Games / Social / Streaming / Milestones
- Table: Icon+Name (EN) | Name (AR) | Category | Rarity | Condition | XP | Coins | Active | Actions
- Rarity badges: Common (gray), Uncommon (green), Rare (blue), Epic (purple), Legendary (gold)
- Create/Edit modal: Name/description EN/AR, Icon selector (12 icons), Category, Rarity, Condition type+threshold, XP, Coins, Secret toggle, Display order

**Output:** HTML achievement management

### 10 Leaderboard Management

**Requirements:**
- Tabs: Weekly / Monthly / All Time / Custom
- Stats: Total Ranked, Weekly Participants
- Table: Rank (gold/silver/bronze for top 3) | Player | Score | Games | Win Rate | Trend
- Actions: Force Recalculate, Finalize Period, Archive
- Manual Override modal: Player, current rank/score, new rank/score, reason
- Audit log of manual overrides

**Output:** HTML leaderboard management

### 11 Notification Broadcast

**Requirements:**
- Tabs: Compose / History / Templates
- Compose: Title EN/AR, Body EN/AR, Image URL, Target Audience (radio: All/Specific/Region/Level/Segment), Priority, Deep Link action, Preview mockup
- History: Table of past notifications with delivery stats
- Templates: Saved template cards with Use/Edit/Delete

**Output:** HTML notification broadcast

### 12 Analytics

**Requirements:**
- Date range picker (7d/30d/90d/custom) + Export button
- Report cards: Total Users, MAU, Avg Games/Week, Avg Session Duration
- Charts (2x2): User Growth, DAU/MAU, Game Mode Distribution, Revenue Trend
- Popular Times heatmap
- Regional breakdown (2 bar charts)
- Export buttons: CSV, PDF

**Output:** HTML analytics dashboard

### 13 System Settings

**Requirements:**
- Expandable section cards:
  - Game Rules: Sun target, Hokm rounds, Turn time, Mode toggles
  - Feature Flags: Tournaments, Streaming, Voice, Camera, Gifting, Coins, Guest mode
  - Economy: Daily bonus, Coin packages table, Gift amounts, Tournament fees, Commission %
  - Moderation: Auto-ban threshold, Escalation rules, Profanity filter (AR+EN), Stream retention
  - Maintenance: Mode toggle, Force update version, Announcement banner (EN+AR)
  - Admin Users: Table with Role badges (Super Admin purple, Moderator blue, Support gray), Add Admin button
- "Save Changes" button (gold, sticky bottom)

**Output:** HTML system settings

---

## Design Notes

- Admin dashboard uses the SAME dark theme as the mobile app
- Purple is primary accent, Gold for highlights and VIP actions
- Data tables use dark elevated surface (`#161622`) with subtle borders
- Charts use purple and gold as primary data colors
- All screens share the sidebar navigation (identical HTML in each file)
- Interactive elements (modals, drawers) use smooth transitions
- Status badges use consistent colors across all screens
- Gold accents used sparingly for tournament prizes, VIP, and premium elements
- Tables should support sorting, filtering, and pagination (visual only in prototypes)
- Mobile responsiveness is NOT required for admin (desktop only for MVP)