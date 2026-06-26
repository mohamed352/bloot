# Onboarding Prompt

## Context

Include `00_master_rules.md` before using this prompt.

## CRITICAL: English Only with RTL Notes

All UI screens MUST be generated in **English only**. Add RTL implementation notes as HTML comments. Do NOT include Arabic text. The app will handle localization programmatically.

## Screen: Splash + Welcome

### 01 Splash Screen

**Requirements:**
- Full screen, dark background (`#0A0A0F`)
- Center: Bloot logo (card-themed icon + wordmark)
- Below logo: "BLOOT" in white, bold (`text-[28px]`, tracking wide)
- Subtle tagline: "Live Baloot" in `b-on-surface-muted` (`text-[14px]`)
- Animated card suit symbols floating subtly in background (spade, heart, diamond, club — purple/gold tones, low opacity)
- Duration: 2-3 seconds
- No buttons, no interactions
- Clean, minimal, premium feel
- Subtle purple glow behind logo
- Loading bar at bottom with purple progress animation

**Output:** HTML splash screen

### 02 Welcome Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Subtle gradient mesh (purple to dark, low opacity) behind content
- Headline: "Play Baloot. Go Live. Build Your Audience."
<!-- RTL: "العب بلوت. ابث مباشر. ابنِ جمهورك." -->
- Subtitle: "The premium Baloot platform for players, streamers, and fans"
- Illustration: Premium styled Baloot scene — 4 phone screens with video squares around a card table, showing social gaming concept (NOT primitive rectangles — use detailed SVG with gradients, shadows, proper proportions)
- Feature highlights (2 horizontal cards below illustration):
  1. Live Voice & Video — "Play with friends face-to-face"
  2. Rankings & Stats — "Compete and track your progress"
- Pagination dots (3 screens, currently on 1)
- Primary CTA: "Get Started" (primary-btn, full width, purple gradient)
- Secondary link: "Already have an account? Sign In" (b-purple text link)

**Output:** HTML welcome screen

---

## Design Notes

- Dark mode only for onboarding
- Smooth slide transitions between screens
- Status bar should match background (dark)
- Max headline size: `text-[26px]` (do NOT use `text-3xl` or larger)
- Body text: `text-[13px]` to `text-[15px]`
- Buttons: `h-[52px]`, `text-[15px]`
- Use purple (`#8B5CF6`) as primary action color
- Use gold (`#F59E0B`) sparingly for highlights only
- The welcome illustration should convey: social gaming + video + card game + live
- Background should have subtle animated gradient or floating card suits