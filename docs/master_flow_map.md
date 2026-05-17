# Bloot — Master Flow Map

> **Purpose:** Mermaid diagrams of ALL screens and transitions in the Bloot app. Every flow, every edge case, every state.

---

## 1. App Launch Flow

```mermaid
flowchart TD
    A[App Opened] --> B{Has Auth Token?}
    B -->|No| C[Splash Screen]
    B -->|Yes| D{Token Valid?}
    D -->|Yes| E[Home Screen]
    D -->|No| C
    C --> F[Welcome Screen]
    F --> G[Login Screen]
    G --> H[Phone Input]
    H --> I[Send OTP]
    I --> J[OTP Verification Screen]
    J --> K{OTP Valid?}
    K -->|Yes| L{Profile Complete?}
    K -->|No| M[Error Message]
    M --> J
    L -->|Yes| E
    L -->|No| N[Complete Profile Screen]
    N --> O[Set Display Name + Username + Avatar]
    O --> P{Username Available?}
    P -->|Yes| Q[Create Firestore User Doc]
    P -->|No| R[Show Username Taken]
    R --> O
    Q --> E
```

---

## 2. Authentication Flow

```mermaid
flowchart TD
    A[Login Screen] --> B[Enter Phone Number]
    B --> C[Select Country Code]
    C --> D[Default: +966 KSA]
    D --> E[Enter Phone Number]
    E --> F[Send Code Button]
    F --> G{Valid Phone?}
    G -->|No| H[Show Error: Invalid Phone]
    G -->|Yes| I[Call Firebase Auth]
    I --> J{OTP Sent?}
    J -->|Yes| K[OTP Screen]
    J -->|No| L[Show Error: Failed to Send]
    L --> A

    K --> M[Enter 4-Digit Code]
    M --> N{Code Correct?}
    N -->|Yes| O{New User?}
    N -->|No| P[Shake Animation + Error]
    P --> M
    O -->|Yes| Q[Complete Profile Screen]
    O -->|No| R[Home Screen]

    Q --> S[Choose Avatar]
    S --> T[Enter Display Name]
    T --> U[Enter Username]
    U --> V{Username Available?}
    V -->|Yes| W[Accept Terms]
    V -->|No| X[Show Suggestions]
    X --> U
    W --> Y[Create Account]
    Y --> R

    R --> Z[Home Screen]
    
    subgraph Social Login
        AA[Apple Sign In Button]
        AB[Google Sign In Button]
        AA --> AC[OAuth Flow]
        AB --> AC
        AC --> O
    end
```

---

## 3. Home Flow

```mermaid
flowchart TD
    A[Home Screen] --> B[Hero Banner]
    B --> C[Tap: Discover Streams]

    A --> D[Quick Actions]
    D --> E[Play with Friends]
    D --> F[Voice Tables]
    D --> G[Live Stream]
    D --> H[Tournaments]

    E --> I[Create Room Screen]
    F --> J[Room List: Voice Only Filter]
    G --> C
    H --> K[Tournament List Screen]

    A --> L[Live Now Section]
    L --> M[Stream Card 1]
    L --> N[Stream Card 2]
    L --> O[Stream Card N...]
    M --> P[Watch Stream Screen]
    N --> P
    O --> P

    A --> Q[Upcoming Tournaments Section]
    Q --> R[Tournament Card 1]
    Q --> S[Tournament Card 2]
    R --> K
    S --> K

    A --> T[Bottom Navigation]
    T --> U[Home Tab: Stay]
    T --> V[Discover Tab: Discover Screen]
    T --> W[Play Tab: Create Room]
    T --> X[Chat Tab: Chat List]
    T --> Y[Profile Tab: Profile Screen]

    A --> Z[Pull to Refresh]
    Z --> A

    A --> AA[Empty State: No Streams]
    AA --> AB[Create Room Button]
```

---

## 4. Room Flow

```mermaid
flowchart TD
    A[Home: Play with Friends] --> B[Create Room Screen]
    A2[Home: Play Tab] --> B

    B --> C[Enter Room Name]
    C --> D[Select Room Type]
    D --> D1[Private Room]
    D --> D2[Public Room]
    D --> D3[Live Stream]

    D1 --> E[Toggle: Voice On]
    D2 --> E
    D3 --> E

    E --> F[Toggle: Camera Off]
    F --> G[Toggle: Spectators Off]

    G --> H[Advanced Settings]
    H --> I[Min Level]
    H --> J[Game Speed]
    H --> K[Room Password - Private Only]

    I --> L[Room Preview Card]
    J --> L
    K --> L

    L --> M[Create Room Button]
    M --> N[Firestore: Create Room Document]
    N --> O[Room Lobby Screen]

    O --> P[4 Player Seats]
    P --> P1[Seat 1: You - Always Filled]
    P --> P2[Seat 2: Partner - May Be Empty]
    P --> P3[Seat 3: Opponent 1 - May Be Empty]
    P --> P4[Seat 4: Opponent 2 - May Be Empty]

    O --> Q[Room Code Display]
    Q --> R[Copy Code Button]
    Q --> S[Share Link Button]

    O --> T[Joining Players Appear]
    T --> T1[Player Video Square Shows]
    T1 --> T2[Mic/Camera Status Shows]
    T2 --> T3[Ready/Not Ready Toggle]

    O --> U[Chat Drawer]
    U --> V[Quick Messages]
    U --> W[Text Input]

    O --> X{All 4 Players Ready?}
    X -->|No| Y[Start Game Button: Disabled]
    X -->|Yes| Z{Is Room Creator?}
    Z -->|Yes| AA[Start Game Button: Enabled]
    Z -->|No| Y
    AA --> AB[Start Game]
    AB --> AC[Game Play Screen]

    O --> AD[Leave Room Button]
    AD --> AE[Confirmation Dialog]
    AE -->|Confirm| AF[Home Screen]
    AE -->|Cancel| O

    subgraph Join Room
        AG[Receive Invite Link/Code]
        AG --> AH[Enter Room Code]
        AH --> AI{Room Exists?}
        AI -->|Yes| AJ{Room Full?}
        AI -->|No| AK[Error: Room Not Found]
        AJ -->|No| AL{Correct Password? - Private}
        AJ -->|Yes| AM[Error: Room Full]
        AL -->|Yes| O
        AL -->|No| AN[Error: Wrong Password]
    end

    subgraph Player States
        AO[Player Joins]
        AP[Player Ready]
        AQ[Player Not Ready]
        AR[Player Disconnects]
        AS[Player Kicked - Creator Only]
        AO --> AT[Seat Fills]
        AP --> AU[Green Ready Badge]
        AQ --> AV[Gray Not Ready Badge]
        AR --> AW[Seat Shows Disconnected]
        AS --> AX[Seat Empties, Player Notified]
    end
```

---

## 5. Game Flow

```mermaid
flowchart TD
    A[Start Game] --> B[Game Play Screen: Landscape]
    B --> C[Lock Orientation to Landscape]
    C --> D[Hide Status Bar]

    D --> E[Deal Animation]
    E --> F[13 Cards Per Player]
    F --> G{Game Type?}

    G -->|Sun| H[Sun Mode: No Trump]
    G -->|Hokm| I[Hokm Mode: Declare Trump]

    I --> J[Bid Phase]
    J --> K[Player with First Bid Selects Trump Suit]
    K --> L[Trump Suit Displayed]

    H --> M[Start Play Phase]
    L --> M

    M --> N[Your Turn: Cards Highlighted]
    N --> O[Select Card from Hand]
    O --> P[Valid Cards Bright, Invalid Dimmed]
    P --> Q[Tap Card to Play]
    Q --> R[Card Animates to Table Center]

    R --> S{All 4 Cards Played?}
    S -->|No| T[Next Player's Turn]
    T --> M
    S -->|Yes| U[Trick Winner Determined]
    U --> V[Trick Won Animation]
    V --> W[Score Update]
    W --> X{Round Over?}

    X -->|No| Y[Clear Trick Cards]
    Y --> M

    X -->|Yes| Z[Round End Overlay]
    Z --> AA[Score Summary: Team A: X - Team B: Y]
    AA --> BB{Game Over?}
    BB -->|No| CC[Next Round: Deal Again]
    CC --> E
    BB -->|Yes| DD[Game End Celebration]
    DD --> EE[Winner Announcement]
    EE --> FF[Stats Updated in Firestore]
    FF --> GG[Return to Room Lobby or Home]

    B --> HH[Controls Bar]
    HH --> II[Mic Toggle]
    HH --> JJ[Camera Toggle]
    HH --> KK[Voice Settings]
    HH --> LL[Chat Button]
    HH --> MM[Leave Game]
    MM --> NN[Confirmation: Leave Game?]
    NN -->|Confirm| OO[Home Screen]
    NN -->|Cancel| B

    B --> PP[Auto-Hide UI After 3s]
    PP --> QQ[Tap Anywhere to Reveal]

    subgraph Edge Cases
        RR[Player Disconnects]
        SS[Player Reconnects - Resume]
        TT[Player Never Returns - AI Takes Over]
        UU[Network Lost - Reconnecting Overlay]
        VV[Turn Timer Expires - Auto-Play]
        WW[All Opponents Leave - Win By Default]
        
        RR --> SS
        RR --> TT
        UU --> XX[Reconnecting...]
        VV --> YY[Auto-Play Lowest Card]
        WW --> DD
    end
```

---

## 6. Stream Viewing Flow

```mermaid
flowchart TD
    A[Discover Streams Screen] --> B[Tap Stream Card]
    B --> C[Stream Viewer Screen]

    A --> D[Home: Live Now Section]
    D --> B

    C --> E[Top Bar: LIVE Badge + Viewer Count + Stream Title + Report]
    E --> F[4 Video Squares: 2x2 portrait / 1x4 landscape]
    F --> G[Game Table: Read-Only View]
    G --> H[Played Cards Visible]
    G --> I[Current Scores Shown]
    G --> J[Trump Suit Shown if Hokm]
    G --> K[Player Cards NOT Shown]

    C --> L[Chat Panel]
    L --> M[Chat Messages Scroll]
    M --> N[Text Input]
    N --> O[Send Message]

    C --> P[Interaction Buttons]
    P --> Q[Like Button + Count]
    P --> R[Gift Button - Requires Coins]
    P --> S[Share Button]
    P --> T[Follow Host Button]

    C --> U[Orientation Toggle]
    U --> V[Portrait: Video Grid 2x2 + Table + Chat Below]
    U --> W[Landscape: Videos Row + Table Full + Chat Side Panel]

    C --> X{Stream Status}
    X -->|Live| Y[Continue Watching]
    X -->|Paused| Z[Paused Overlay]
    X -->|Ended| AA[Stream Ended Overlay]
    AA --> BB[View Results / Go Home]

    F --> CC[Mic Status: Green = On, Red = Muted]
    F --> DD[Camera Status: On/Off Icon]
    F --> EE[Team Borders: Purple Team A / Gold Team B]

    subgraph Viewer Rules
        FF[Cannot Play Cards]
        GG[Can Chat]
        HH[Can Like / Gift]
        II[Can Follow Host]
        JJ[Can Share Stream]
        KK[Cannot Control Game]
    end
```

---

## 7. Tournament Flow

```mermaid
flowchart TD
    A[Home: Tournaments] --> B[Tournament List Screen]
    B --> C[Filter Tabs: All / Active / Upcoming / Completed / My Tournaments]
    C --> D[Tournament Cards]
    D --> E[Tap Card: Tournament Detail Screen]

    E --> F[Hero Section: Banner + Status + Name + Prize Pool]
    F --> G[Details Card: Date, Type, Format, Rounds, Entry]
    G --> H[Rules Card: Khaleeji Rules Summary]
    H --> I[Participants Card: Count + Avatar Scroll]
    I --> J[Bracket Card: If Active]

    E --> K{Join Status}
    K -->|Not Joined| L{Entry Fee?}
    L -->|Free| M[Join Tournament Button: Purple]
    L -->|Paid| N[Join Tournament Button: Gold + Coin Amount]
    K -->|Joined| O[Withdraw Button: Ghost, Red Text]
    K -->|Full| P[Tournament Full: Gray, Disabled]

    M --> Q[Deduct Coins if Paid]
    Q --> R[Add to Participants]
    R --> S[Show in My Tournaments]

    E --> T[Prize Distribution Section]
    T --> U[1st: Gold + Amount]
    T --> V[2nd: Silver + Amount]
    T --> W[3rd: Bronze + Amount]
    T --> X[4th: Amount]

    subgraph Tournament Progression
        Y[Registration Opens]
        Z[Registration Closes]
        AA[Check-In Phase]
        BB[Bracket Generation]
        CC[Match 1: Team Pair vs Team Pair]
        DD[Winner Advances]
        EE[Repeat Until Final]
        FF[Winner Declared]
        GG[Prize Distribution]
        
        Y --> Z --> AA --> BB --> CC --> DD --> EE --> FF --> GG
    end

    E --> HH[Tournament Ended: View Results]
```

---

## 8. Profile Flow

```mermaid
flowchart TD
    A[Profile Tab] --> B[Profile Screen]
    B --> C[Avatar + Name + @username]
    C --> D[Level Badge + XP Progress Bar]
    D --> E[Stats Row: Wins / Games / Followers]
    E --> F[Quick Actions: Edit Profile / Share / Settings]

    B --> G[Tab Bar]
    G --> H[Stats Tab]
    G --> I[History Tab]
    G --> J[About Tab]

    H --> K[Win Rate Card: Circular Progress + Percentage]
    K --> L[Game Type Breakdown]
    L --> M[Sun Games: X played, Y% win rate]
    L --> N[Hokm Games: X played, Y% win rate]
    M --> O[Level Progress: X/Y XP to Next]
    O --> P[Achievements: Horizontal Scroll]
    P --> Q[Earned: Gold Badge]
    P --> R[Locked: Gray Badge]

    I --> S[Game History List]
    S --> T[Each Item: Won/Lost, Score, Type, Duration, Players, Date]
    T --> U[Filter: All / Won / Lost]

    J --> V[Bio Text]
    V --> W[Member Since Date]
    W --> X[Favorite Mode]
    X --> Y[Region]

    B --> Z[Edit Profile Screen]
    Z --> AA[Change Avatar]
    Z --> AB[Edit Display Name]
    Z --> AC[Edit Username]
    Z --> AD[Edit Bio]
    Z --> AE[Select Region]
    Z --> AF[Select Favorite Mode]
    Z --> AG[Save Button]
    AG --> AH[Validation: Username Available?]
    AH -->|Yes| AI[Update Firestore]
    AH -->|No| AJ[Show Error: Username Taken]
    AI --> B
```

---

## 9. Chat Flow

```mermaid
flowchart TD
    A[Chat Tab] --> B[Chat List Screen]
    B --> C[Filter Tabs: All / Rooms / Direct / Tournaments]
    C --> D[Chat Items]
    D --> E[Tap Conversation]

    E --> F{Conversation Type}
    F -->|Direct| G[DM Screen]
    F -->|Room Invite| H[Room Invitation Modal]

    G --> I[Top Bar: Avatar + Name + Online Status + Call Icons]
    I --> J[Messages: Purple Right / Dark Surface Left]
    J --> K[Your Messages: Aligned End]
    J --> L[Their Messages: Aligned Start]
    L --> M[System Messages: Centered, Muted Text]
    J --> N[Timestamps Between Groups]
    N --> O[Input Area]
    O --> P[Text Input]
    O --> Q[Attachment Icon]
    O --> R[Emoji Icon]
    O --> S[Send Button - Purple, Disabled if Empty]
    O --> T[Quick Action Chips]
    T --> U[Good game! / Nice move! / Let's play again / GG]

    H --> V[Invitation Card]
    V --> W[Host Avatar + Name]
    W --> X[Room Name + Type + Players]
    X --> Y[Join Room Button: Gold]
    X --> Z[Decline Button: Ghost]
    Y --> AA[Join Room Flow]
    Z --> AB[Dismiss, Mark as Read]

    B --> AC[Compose Button]
    AC --> AD[Search Users]
    AD --> AE[Select User]
    AE --> G

    subgraph Edge Cases
        AF[Offline Messages: Queue and Send on Reconnect]
        AG[Image Messages: Thumbnail + Tap to View Full]
        AH[Room Invite Expired: Show "Expired" Badge]
        AI[User Blocked: Hide Messages, Show "Blocked"]
        AJ[Chat Deleted: Remove from List]
    end
```

---

## 10. Settings Flow

```mermaid
flowchart TD
    A[Settings Screen] --> B[Account Section]
    A --> C[Game Section]
    A --> D[Privacy Section]
    A --> E[Support Section]
    A --> F[Danger Section]

    B --> B1[Edit Profile]
    B1 --> G[Edit Profile Screen]
    B --> B2[Change Username]
    B2 --> H[Username Change Screen]
    B --> B3[Linked Accounts]
    B --> B4[Block List]

    C --> C1[Voice Chat Toggle]
    C --> C2[Camera Toggle]
    C --> C3[Speaker Mode: Speaker / Earpiece]
    C --> C4[Auto-Rotate for Game Toggle]
    C --> C5[Game Speed Default: Normal / Fast / Relaxed]
    C --> C6[Sound Effects Toggle]
    C --> C7[Background Music Toggle]

    D --> D1[Online Status Toggle]
    D --> D2[Profile Visibility: Everyone / Followers / Private]
    D --> D3[Notifications]
    D3 --> D3a[Room Invitations Toggle]
    D3 --> D3b[Tournament Alerts Toggle]
    D3 --> D3c[New Followers Toggle]
    D3 --> D3d[Game Results Toggle]
    D --> D4[Muted Users List]

    E --> E1[Help Center]
    E --> E2[Contact Support]
    E --> E3[Report a Problem]
    E --> E4[Terms of Service]
    E4 --> I[Terms Screen]
    E --> E5[Privacy Policy]
    E5 --> J[Privacy Screen]
    E --> E6[About Bloot]

    F --> F1[Log Out]
    F1 --> K[Confirmation Dialog]
    K -->|Confirm| L[Login Screen]
    F --> F2[Delete Account]
    F2 --> M[Confirmation Dialog: Type DELETE]
    M -->|Confirm| N[Account Deleted]
    N --> L

    A --> O[Version: Bloot v1.0.0]

    subgraph Error States
        P[Error Screen: Something went wrong + Try Again]
        Q[Offline Screen: No connection + Retry]
        R[Loading Overlay: Context-specific message]
        S[Success State: Gold checkmark + Message]
    end
```