# Localization Research

## Overview

Bloot targets the Gulf/MENA market with Arabic as the primary language. This document covers RTL layout, font choices, text expansion, number handling, cultural considerations, and bilingual support.

---

## Language Priority

| Priority | Language | Direction | Region | Notes |
|---|---|---|---|---|
| 1 (Primary) | Arabic (ar-SA) | RTL | Saudi Arabia, Gulf | Khaleeji dialect preference |
| 2 (Secondary) | English (en-US) | LTR | International users | Standard American English |

### Dialect Considerations

- **Standard Arabic (Fusha)** — Used for formal UI text (buttons, labels, system messages)
- **Khaleeji Arabic** — Used for informal text (chat prompts, achievement names, celebrations)
- Avoid Egyptian or Levantine dialects — they feel foreign to Gulf users
- When in doubt, use Fusha — it's universally understood

---

## Font Selection

### Arabic Font: Cairo

| Attribute | Details |
|---|---|
| **Font** | Cairo (Google Fonts) |
| **Style** | Modern sans-serif, optimized for screens |
| **Weight range** | 200-900 (6 weights) |
| **License** | Open Font License (free for commercial use) |
| **Arabic support** | Full, with proper ligatures and joining |
| **Why Cairo?** | Designed by Mohamed Gaber, specifically for modern Arabic UIs. Clean, readable at small sizes. Popular in Gulf-region apps. |

**Font weights used in Bloot:**

| Weight | Usage |
|---|---|
| Cairo 400 (Regular) | Body text, chat messages, card labels |
| Cairo 600 (SemiBold) | Buttons, tabs, player names |
| Cairo 700 (Bold) | Headings, scores, important numbers |
| Cairo 900 (Black) | Hero text, large numbers, logo |

### Latin Font: Inter

| Attribute | Details |
|---|---|
| **Font** | Inter (Google Fonts) |
| **Style** | Modern sans-serif, designed for UI |
| **Weight range** | 100-900 |
| **License** | Open Font License |
| **Why Inter?** | Excellent readability at small sizes, optimized for screens, pairs well with Cairo |

### Font Loading Strategy

```yaml
# pubspec.yaml
flutter:
  fonts:
    - family: Cairo
      fonts:
        - asset: assets/fonts/Cairo-Regular.ttf
          weight: 400
        - asset: assets/fonts/Cairo-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Cairo-Bold.ttf
          weight: 700
        - asset: assets/fonts/Cairo-Black.ttf
          weight: 900
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

```dart
// Theme configuration
TextTheme buildArabicTextTheme() {
  return TextTheme(
    bodyLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w400),
    titleLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
    titleMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
    labelLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900),
    headlineMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
  );
}

TextTheme buildEnglishTextTheme() {
  return TextTheme(
    bodyLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400),
    // ... same pattern
  );
}
```

---

## Text Expansion Considerations

### Arabic Text Expansion

Arabic text is typically **20-30% longer** than English for the same content. This affects:

| UI Element | English Length | Arabic Length | Expansion |
|---|---|---|---|
| "Join Room" | 9 chars | "انضم للغرفة" | 11 chars (~22%) |
| "Create Room" | 11 chars | "إنشاء غرفة" | 10 chars (~-9%) |
| "Start Game" | 10 chars | "ابدأ اللعبة" | 11 chars (~10%) |
| "Settings" | 8 chars | "الإعدادات" | 9 chars (~12%) |
| "Live Now" | 8 chars | "مباشر الآن" | 10 chars (~25%) |
| "Send Gift" | 9 chars | "أرسل هدية" | 9 chars (~0%) |
| "Followers" | 9 chars | "المتابعون" | 9 chars (~0%) |
| "Tournament" | 10 chars | "البطولة" | 7 chars (~-30%) |

### Design Implications

1. **Buttons:** Use full-width or flexible-width buttons; never fixed-width with short English text
2. **Navigation bars:** Allow text truncation with ellipsis ( RTL-aware)
3. **Cards:** Use flexible text containers, not fixed heights
4. **Dialogs:** Scrollable content area for longer Arabic text
5. **Labels:** Place labels above inputs (not beside) to avoid width issues
6. **Icons with text:** Ensure text doesn't overlap icons when expanded

### Flutter Layout Strategies

```dart
// Use Flexible/Expanded for text containers
Row(
  children: [
    Icon(Icons.videocam),
    SizedBox(width: 8),
    Flexible(  // Not Container with fixed width
      child: Text(
        'ابدأ البث المباشر', // Could be longer than English
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    ),
  ],
)

// Use FittedBox for score displays (numbers should scale)
FittedBox(
  child: Text(
    '120',
    style: TextStyle(
      fontFamily: 'Cairo',
      fontWeight: FontWeight.w900,
      fontSize: 48,
    ),
  ),
)
```

---

## Number Handling

### Arabic Numerals vs Eastern Arabic Numerals

| Western (0-9) | Eastern Arabic (٠-٩) |
|---|---|
| 0 | ٠ |
| 1 | ١ |
| 2 | ٢ |
| 3 | ٣ |
| 4 | ٤ |
| 5 | ٥ |
| 6 | ٦ |
| 7 | ٧ |
| 8 | ٨ |
| 9 | ٩ |

### Recommendation: Use Western Numerals (0-9)

**Rationale:**
- Most Gulf-region apps use Western numerals
- Saudi Arabia and UAE predominantly use Western numerals in digital contexts
- Card games universally use Western numerals on cards
- Score displays and timers are more readable in Western numerals
- Younger users (primary demographic) strongly prefer Western numerals

### Exception: Cultural Content

Eastern Arabic numerals may be used for:
- Achievement names (artistic choice)
- Decorative elements
- Calendar dates (optional, user preference)

### Number Localization in Flutter

```dart
// Force Western numerals regardless of locale
String formatNumber(int number) {
  return number.toString(); // Western numerals by default in Dart
}

// Format with commas for large numbers
String formatLargeNumber(int number) {
  return NumberFormat.compact(locale: 'ar_SA').format(number);
  // "1.2K" format — uses Western K suffix
}

// Coin display
String formatCoins(int coins) {
  if (coins >= 1000000) return '${(coins / 1000000).toStringAsFixed(1)}M';
  if (coins >= 1000) return '${(coins / 1000).toStringAsFixed(1)}K';
  return coins.toString();
}
```

---

## Card Suit Localization

### Arabic Suit Names

| English | Arabic | Dialect Note |
|---|---|---|
| Hearts | قلوب (Qulub) | Universal |
| Diamonds | ديناري (Dinari) | Khaleeji specific |
| Clubs | سان (San) | Khaleeji specific (from French "sans") |
| Spades | باستوني (Bastuni) | Khaleeji specific (from Italian "bastoni") |

### Card Face Localization

| English | Arabic | Used In |
|---|---|---|
| Ace | آص | All suits |
| King | ملك | All suits |
| Queen | ملكة | All suits |
| Jack | جوج | All suits (from French "jaque") |

### Card Design Notes

- Card faces use standard international symbols (♠ ♥ ♦ ♣)
- Arabic names shown on cards in a subtle label, not replacing the symbol
- In game view, cards are small — rely on symbols, not text
- Trump suit indicator uses both symbol and Arabic name

---

## RTL Layout Flipping Rules

### What Flips in RTL

| Element | LTR | RTL | Notes |
|---|---|---|---|
| Text alignment | Left | Right | Body text, labels, chat |
| Icon + Text row | 🔵 Label | Label 🔵 | Icon on opposite side |
| Back navigation | ← Left arrow | → Right arrow | Points to "back" direction |
| Progress indicators | Left → Right | Right → Left | Fills from start side |
| List items | [Icon] [Text] [Chevron>] | [<Chevron] [Text] [Icon] | Order reversed |
| Breadcrumbs | Home > Page > Item | Item < Page < Home | Arrow direction flipped |
| Sliders | Left=min, Right=max | Right=min, Left=max | — |
| Timeline | Left=oldest, Right=newest | Right=oldest, Left=newest | — |
| Swipe gestures | Swipe right=next | Swipe left=next | — |

### What Does NOT Flip in RTL

| Element | Why Not |
|---|---|
| Numbers (scores, timers) | Universal left-to-right |
| Card game table layout | Game logic is position-based, not directional |
| Video feeds | Position is by player seat, not reading direction |
| Phone number input | Always LTR |
| Email/URL fields | Always LTR |
| Music/video playback controls | Universal (play ▶ always right) |
| Mathematical operators | Universal |

### Flutter RTL Support

```dart
// MaterialApp with RTL support
MaterialApp(
  localizationsDelegates: [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('ar', 'SA'), // Arabic - Saudi Arabia (primary)
    Locale('en', 'US'), // English - United States (secondary)
  ],
  locale: Locale('ar', 'SA'), // Default to Arabic
  // Flutter automatically handles RTL layout when locale is 'ar'
);

// Force text direction for mixed content
Directionality(
  textDirection: TextDirection.rtl,
  child: Text('مرحبا بك في بلوت'),
)

// Mixed RTL/LTR content (e.g., "المستوى 5")
RichText(
  text: TextSpan(
    children: [
      TextSpan(text: 'المستوى ', style: arabicStyle),
      TextSpan(text: '5', style: numberStyle), // LTR embedded
    ],
  ),
)
```

### Direction-Aware Widgets

```dart
// Use Directionality-aware padding/margin
EdgeInsetsDirectional.only(start: 16, end: 8) // 'start' is left in LTR, right in RTL

// Use Directionality-aware alignment
AlignmentDirectional.centerStart // Aligns to start side (left in LTR, right in RTL)

// Use Directionality-aware positioning
PositionedDirectional(start: 0, end: 0, top: 0) // Works in both directions
```

---

## Cultural Considerations

### Language Sensitivity

| Term | Avoid | Use Instead | Rationale |
|---|---|---|---|
| Money/Cash | مال / نقد | عملات (Coins) | Avoid gambling connotation |
| Bet/Gamble | رهان / مقامرة | تحدي (Challenge) | Religious/cultural sensitivity |
| Prize money | جائزة مالية | جائزة (Prize) | Remove money reference |
| Pay | ادفع | اشترِ (Buy/Purchase) | Less transactional feel |
| Win money | اكسب مال | اكسب عملات (Earn coins) | Virtual currency framing |
| Deposit | إيداع | شحن (Recharge/Top-up) | Less financial language |

### Prayer Time Considerations

- Consider muting non-essential notifications during prayer times
- Show a subtle "Prayer time" indicator in the UI (optional, opt-in)
- No game mechanic impact — purely a notification feature
- Use Aladhan API for prayer time calculation

### Gender Considerations

- Allow gender-neutral avatars and usernames
- Some users prefer gender-segregated rooms (optional room setting)
- Camera is always opt-in (cultural sensitivity around appearance)
- No forced gender selection during registration (make it optional)

### Color Cultural Meaning

| Color | Western Meaning | Arabic/Gulf Meaning | Bloot Usage |
|---|---|---|---|
| Purple (#8B5CF6) | Royalty, luxury | Royalty, prestige | Primary brand — conveys premium |
| Gold (#F59E0B) | Wealth, success | Wealth, celebration | Accent — highlights, rewards, gifts |
| Black/Dark | Elegance, mystery | Elegance, modernity | Background — dark theme |
| Green | Nature, go | Islam, paradise | Achievement/success indicators |
| Red | Danger, stop | Danger, but also celebration | Live indicator, important alerts |
| White | Purity, simplicity | Purity, peace | Text on dark backgrounds |

### Holiday/Seasonal Considerations

| Event | Timing | Bloot Adaptation |
|---|---|---|
| Ramadan | Varies (lunar calendar) | Special Ramadan theme, iftar timing, reduced notifications during fasting hours |
| Eid Al-Fitr | After Ramadan | Celebration theme, special gifts, tournament |
| Eid Al-Adha | ~70 days after Eid Al-Fitr | Celebration theme, special achievements |
| Saudi National Day | Sept 23 | Green theme variant, special card backs |
| Kuwait National Day | Feb 25 | Kuwaiti flag colors in decorations |

---

## Date and Time Formatting

### Date Formatting

| Context | Arabic Format | English Format | Example (AR) | Example (EN) |
|---|---|---|---|---|
| Short date | dd/MM/yyyy | MM/dd/yyyy | ١٥/٠٣/٢٠٢٦ | 03/15/2026 |
| Long date | dd MMMM yyyy | MMMM dd, yyyy | ١٥ مارس ٢٠٢٦ | March 15, 2026 |
| Relative time | منذ ٥ دقائق | 5 min ago | — | — |

### Arabic Month Names

| Month | Arabic |
|---|---|
| January | يناير |
| February | فبراير |
| March | مارس |
| April | أبريل |
| May | مايو |
| June | يونيو |
| July | يوليو |
| August | أغسطس |
| September | سبتمبر |
| October | أكتوبر |
| November | نوفمبر |
| December | ديسمبر |

### Time Formatting

- **12-hour format preferred** in Gulf region (with AM/PM)
- Arabic: ص (صباحاً) for AM, م (مساءً) for PM
- Example: "٩:٣٠ م" (9:30 PM)
- Game timers always use Western numerals: "0:30" not "٠:٣٠"

### Time Zone

- Primary: Arabia Standard Time (AST, UTC+3)
- No daylight saving time in Saudi Arabia, Kuwait, Bahrain, Qatar, UAE
- All times in app displayed in AST by default
- User can switch to local time zone in settings

---

## String Management

### Flutter Localization Setup

```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_ar.arb
output-localization-file: app_localizations.dart
```

### Arabic ARB File (Primary)

```json
// lib/l10n/app_ar.arb
{
  "@@locale": "ar_SA",
  "appName": "بلوت",
  "joinRoom": "انضم لغرفة",
  "@joinRoom": { "description": "Button to join a game room" },
  "createRoom": "إنشاء غرفة",
  "startGame": "ابدأ اللعبة",
  "goLive": "ابدأ البث",
  "liveNow": "مباشر الآن",
  "sendGift": "أرسل هدية",
  "follow": "متابعة",
  "unfollow": "إلغاء المتابعة",
  "followers": "{count} متابع",
  "@followers": {
    "placeholders": { "count": { "type": "int" } }
  },
  "viewersWatching": "{count} يشاهدون",
  "coinsBalance": "{count} عملة",
  "tournamentStartsIn": "تبدأ البطولة خلال {time}",
  "achievementUnlocked": "فتحت إنجاز جديد!",
  "playerJoined": "انضم {name} للغرفة",
  "@playerJoined": {
    "placeholders": { "name": { "type": "String" } }
  },
  "gameModeSun": "صن",
  "gameModeHokm": "حكم",
  "bidPass": "مرر",
  "yourTurn": "دورك",
  "trickWon": "فزت بالشلة",
  "gameOver": "انتهت اللعبة",
  "teamWon": "فاز الفريق {team}",
  "sunMode": "وضع صن",
  "hokmMode": "وضع الحكم",
  "trumpSuit": "الحكم: {suit}",
  "scoreBoard": "النتيجة",
  "chatPlaceholder": "اكتب رسالة...",
  "searchPlayers": "ابحث عن لاعبين",
  "settings": "الإعدادات",
  "profile": "الملف الشخصي",
  "editProfile": "تعديل الملف",
  "level": "المستوى {number}",
  "dailyBonus": "مكافأتك اليومية",
  "claimBonus": "استلم المكافأة"
}
```

### English ARB File (Secondary)

```json
// lib/l10n/app_en.arb
{
  "@@locale": "en_US",
  "appName": "Bloot",
  "joinRoom": "Join Room",
  "createRoom": "Create Room",
  "startGame": "Start Game",
  "goLive": "Go Live",
  "liveNow": "Live Now",
  "sendGift": "Send Gift",
  "follow": "Follow",
  "unfollow": "Unfollow",
  "followers": "{count} followers",
  "viewersWatching": "{count} watching",
  "coinsBalance": "{count} coins",
  "tournamentStartsIn": "Tournament starts in {time}",
  "achievementUnlocked": "Achievement Unlocked!",
  "playerJoined": "{name} joined the room",
  "gameModeSun": "Sun",
  "gameModeHokm": "Hokm",
  "bidPass": "Pass",
  "yourTurn": "Your Turn",
  "trickWon": "You won the trick",
  "gameOver": "Game Over",
  "teamWon": "Team {team} Won",
  "sunMode": "Sun Mode",
  "hokmMode": "Hokm Mode",
  "trumpSuit": "Trump: {suit}",
  "scoreBoard": "Score",
  "chatPlaceholder": "Type a message...",
  "searchPlayers": "Search Players",
  "settings": "Settings",
  "profile": "Profile",
  "editProfile": "Edit Profile",
  "level": "Level {number}",
  "dailyBonus": "Daily Bonus",
  "claimBonus": "Claim Bonus"
}
```

---

## QA Testing Checklist

- [ ] All text displays correctly in Arabic (no missing translations)
- [ ] RTL layout is correct (no LTR bleed in Arabic mode)
- [ ] Mixed Arabic/English text renders correctly (e.g., "المستوى 5 Player")
- [ ] Numbers display in Western numerals (0-9)
- [ ] Text truncation works in RTL (ellipsis on left side)
- [ ] Back navigation points right in RTL
- [ ] Swipe gestures work in correct direction for RTL
- [ ] Chat messages align right for Arabic, left for English
- [ ] Date/time displays correctly in Arabic locale
- [ ] Card suit names display in Arabic
- [ ] Gift names display in Arabic with correct font
- [ ] Push notifications display in correct language
- [ ] Font rendering is smooth (no broken ligatures)
- [ ] Dark theme contrast is sufficient for Arabic text
- [ ] Gold accent (#F59E0B) is readable on dark background with Arabic text
