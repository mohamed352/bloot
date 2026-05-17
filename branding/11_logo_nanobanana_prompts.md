# Bloot — Nano Banana Logo Generation Prompts

## Overview

This document contains structured prompts for generating Bloot logo assets using **Nano Banana** (AI image generator powered by Google Gemini). Each prompt is crafted from the design system tokens defined in `10_logo_creation_guide.md` and `02_visual_language.md`.

---

## Prompt Engineering Framework

### The Logo Prompt Formula

```
[LOGO TYPE] logo for a [INDUSTRY] [ENTITY TYPE] called "[BRAND NAME]",
[SYMBOL CONCEPT — one concrete idea],
[COLOR PALETTE — 2-3 colors with hex codes or descriptors],
[STYLE MODIFIERS — 3-5 from the approved list],
[OUTPUT CONSTRAINTS]
```

### Rules for Nano Banana Prompts

1. **One symbol concept per prompt** — every extra concept halves quality
2. **2-3 colors maximum** — purple (#8B5CF6) and gold (#F59E0B) are the anchors
3. **Always specify** `flat vector logo, white background, centered` for icon marks
4. **Never use** photorealistic terms: "realistic," "detailed," "3D render," "textured"
5. **Always specify** `no gradients, no shadows, no photography`
6. **Always include** `dark background version` as a separate prompt (inverted colors)
7. **Evaluate at 50px** — if the silhouette doesn't read small, the prompt needs simplifying
8. **Iterate one variable at a time** — change color OR style OR symbol, never all three

### Approved Modifier Glossary

| Category | Approved Terms |
|----------|---------------|
| **Style** | minimalist, geometric, monoline, flat vector, clean, modern, premium, angular, symmetric |
| **Composition** | centered icon, circular badge, horizontal lockup, stacked lockup, emblem |
| **Color** | deep purple and gold, monochrome white, monochrome gold, purple gradient |
| **Exclusion** | no gradients, no shadows, no text, no photography, no 3D effects |
| **Background** | white background, dark background #0A0A0F, transparent feel |

---

## Design System Reference (Quick)

| Token | Value | Usage |
|-------|-------|-------|
| Purple 500 | #8B5CF6 | Primary brand color, interactive elements |
| Purple 600 | #7C3AED | Pressed states, deep accents |
| Purple 700 | #6D28D9 | Extreme contrast |
| Gold 500 | #F59E0B | Achievement, premium, VIP |
| Gold 600 | #D97706 | Gold pressed states |
| Canvas Black | #0A0A0F | Background (never pure #000) |
| White | #FFFFFF | Primary text on dark |
| English Font | Inter Bold 700, ALL CAPS, 0.08em letter-spacing | Wordmark |
| Arabic Font | Cairo Bold 700, zero letter-spacing | بلوت wordmark |

---

## Logo Prompts

### 1. Icon Mark (Card + B Letterform) — Primary Variant

**Purpose:** App icon, favicon, avatar, watermark

```
Flat vector logo, minimalist geometric icon mark for a social card game app called "Bloot", a stylized playing card shape with an abstract letter B integrated into the card design, deep purple #8B5CF6 as the primary color with a subtle gold #F59E0B accent on one corner of the card, clean geometric shapes, simple angular lines, no gradients, no shadows, no text, white background, centered composition, professional logo design, recognizable at small sizes
```

**Dark background version:**

```
Flat vector logo, minimalist geometric icon mark for a social card game app called "Bloot", a stylized playing card shape with an abstract letter B integrated into the card design, white #FFFFFF as the primary color with a gold #F59E0B accent on one corner, clean geometric shapes, simple angular lines, no gradients, no shadows, dark background #0A0A0F, centered composition, professional logo design, recognizable at small sizes
```

**Monochrome white version:**

```
Flat vector logo, minimalist geometric icon mark for a social card game app, a stylized playing card shape with an abstract letter B integrated, pure white #FFFFFF on dark background #0A0A0F, no gradients, no shadows, no colors, monochrome, clean geometric shapes, no text, centered, recognizable at small sizes
```

**Monochrome gold version:**

```
Flat vector logo, minimalist geometric icon mark for a social card game app, a stylized playing card shape with an abstract letter B integrated, pure gold #F59E0B on dark background #0A0A0F, no gradients, no shadows, no other colors, monochrome, clean geometric shapes, no text, centered, premium feel, recognizable at small sizes
```

---

### 2. Primary Logo — Icon + Wordmark (Horizontal, Dark Background)

**Purpose:** Splash screen, website header, marketing materials

```
Flat vector logo for a premium social card game platform called "BLOOT", a minimalist geometric playing card icon with abstract B letterform on the left side, bold uppercase wordmark "BLOOT" on the right side, icon in purple #8B5CF6 with gold #F59E0B accent, wordmark in white #FFFFFF using clean modern sans-serif typography, dark background #0A0A0F, no gradients, no shadows, horizontal layout, professional logo design, centered composition
```

---

### 3. Primary Logo — Icon + Arabic Wordmark (Horizontal, Dark Background)

**Purpose:** Arabic-language contexts, Arabic social media, Arabic marketing

```
Flat vector logo for a premium social card game platform, a minimalist geometric playing card icon with abstract B letterform, bold Arabic wordmark "بلوت" next to the icon, icon in purple #8B5CF6 with gold #F59E0B accent, Arabic text in white #FFFFFF using modern bold Arabic typography, dark background #0A0A0F, no gradients, no shadows, horizontal layout, right-to-left orientation, professional logo design, centered composition
```

---

### 4. Stacked Logo — Icon Over Wordmark (Dark Background)

**Purpose:** Social media square posts, app store graphics, event signage, merchandise

```
Flat vector logo for "BLOOT", a minimalist geometric playing card icon on top, bold uppercase wordmark "BLOOT" below, stacked vertical layout, icon in purple #8B5CF6 with gold #F59E0B accent, wordmark in white #FFFFFF clean modern sans-serif, dark background #0A0A0F, no gradients, no shadows, centered composition, professional logo, premium feel
```

**Arabic stacked version:**

```
Flat vector logo, a minimalist geometric playing card icon on top, bold Arabic wordmark "بلوت" below, stacked vertical layout, icon in purple #8B5CF6 with gold #F59E0B accent, Arabic text in white #FFFFFF using modern bold Arabic typography, dark background #0A0A0F, no gradients, no shadows, centered composition, professional logo, premium feel
```

---

### 5. App Icon (iOS/Android)

**Purpose:** 1024x1024 app store icon

```
App icon design for a card game app called "Bloot", rounded square shape, gradient background from purple #8B5CF6 to deep purple #6D28D9 diagonally, centered minimalist geometric playing card icon in white #FFFFFF with a small gold #F59E0B accent on one corner, clean flat design, no text, no lettering, no gradients on the icon itself, professional modern app icon, simple shapes recognizable at 29px, premium dark gaming aesthetic
```

---

### 6. Splash Screen Layout

**Purpose:** App launch screen — icon centered on dark background with wordmarks

```
Splash screen design for a premium card game app, completely dark background #0A0A0F, centered minimalist geometric playing card icon in purple #8B5CF6 with gold #F59E0B accent, bold text "BLOOT" below in white #FFFFFF modern sans-serif, Arabic text "بلوت" below in white #FFFFFF, clean minimal layout, no gradients, no decorations, premium feel, mobile app splash screen, vertically centered composition
```

---

### 7. Alternate Icon Concepts

If the primary card + B concept doesn't resonate, try these alternative symbol ideas — **one per prompt only**:

#### 7a. Crown + Card

```
Flat vector logo, minimalist geometric icon mark for a premium card game app, a simplified playing card shape with a small crown detail at the top, deep purple #8B5CF6 with gold #F59E0B on the crown, clean geometric lines, no gradients, no shadows, no text, white background, centered, professional logo, recognizable at small sizes
```

#### 7b. Four Cards Fan

```
Flat vector logo, minimalist geometric icon mark for a social card game app, four playing cards arranged in a subtle fan pattern seen from above, deep purple #8B5CF6 with gold #F59E0B accent on one card edge, clean geometric flat shapes, no gradients, no shadows, no text, white background, centered composition, professional design
```

#### 7c. Arabic Letter ب Stylized

```
Flat vector logo, minimalist geometric icon mark for a card game app, an abstract geometric shape inspired by the Arabic letter ب (ba) combined with a card silhouette, deep purple #8B5CF6 with small gold #F59E0B accent, clean flat design, no gradients, no shadows, no text, white background, centered, professional logo, recognizable at small sizes
```

---

## Generation Workflow

### Step 1: Generate Concepts (8-12 variations)

Use prompts 1, 7a, 7b, 7c to generate multiple icon concepts. Generate 2-3 variations per concept by adjusting:

- **Vary 1:** Symbol complexity (simpler ↔ more detail)
- **Vary 2:** Color balance (more purple ↔ more gold)
- **Vary 3:** Shape language (angular ↔ rounded)

### Step 2: Evaluate Silhouettes

For each output:
1. Scale to 50px wide
2. Convert to grayscale
3. If the shape is not instantly recognizable at 50px — discard
4. If multiple elements blur together — simplify the prompt

### Step 3: Select and Refine

Pick the strongest 1-2 concepts. Refine by:
- Adjusting the prompt to remove unnecessary detail
- Generating dark background and monochrome variants
- Generating wordmark lockups (horizontal and stacked)

### Step 4: Vectorize and Clean

AI output is a **concept, not a final asset**. Always:
1. Import the best output into Figma or Illustrator
2. Recreate using vector shapes with exact geometry
3. Apply precise brand colors (#8B5CF6, #F59E0B, #0A0A0F, #FFFFFF)
4. Export as SVG (primary), PNG at 2x (secondary)
5. Test at 16px, 24px, 48px, and 1024px
6. Verify on both #0A0A0F and #FFFFFF backgrounds
7. Check Arabic wordmark has zero letter-spacing

---

## Prompt Tuning Tips

| Problem | Fix |
|---------|-----|
| Too many details | Add "minimalist, simple shapes, reduced detail" |
| Looks like a photo/illustration | Add "flat vector logo, icon only, no realistic effects" |
| AI adds unwanted text | Add "no text, no lettering, no words" |
| Colors look wrong | Use hex codes directly: "purple #8B5CF6, gold #F59E0B" |
| Not centered | Add "centered composition, symmetrical" |
| Too many colors | Add "limited to 2 colors only" |
| Looks generic | Add "inspired by Middle Eastern card game culture, Khaleeji aesthetic" |
| Background not clean | Add "solid white background, no background texture" |
| Shape too complex for small sizes | Add "must be recognizable at 16px, simple silhouette" |
| Gold overpowers purple | Add "purple dominant, gold accent only on corner detail" |

---

## Quality Checklist

Before accepting any Nano Banana output, verify:

- [ ] Silhouette is recognizable at 50px
- [ ] No more than 2-3 colors used
- [ ] Purple (#8B5CF6) is dominant, gold (#F59E0B) is accent only
- [ ] No gradients, shadows, or 3D effects
- [ ] Works on both dark (#0A0A0F) and light (#FFFFFF) backgrounds
- [ ] Card shape is identifiable
- [ ] No photorealistic elements
- [ ] Clean vector-appropriate geometry
- [ ] Consistent with "premium dark social gaming" feel
- [ ] Culturally appropriate for Gulf/MENA audience
- [ ] No religious or politically sensitive symbols

---

## File Mapping

After vectorizing Nano Banana outputs, save final assets using this naming convention:

| Concept Prompt | Final File |
|---------------|------------|
| Section 1 (Icon) | `bloot-icon.svg`, `bloot-icon-mono-white.svg`, `bloot-icon-mono-gold.svg` |
| Section 2 (Horizontal) | `bloot-logo-horizontal-dark.svg`, `bloot-logo-horizontal-light.svg` |
| Section 3 (Arabic Horizontal) | `bloot-logo-arabic-dark.svg` |
| Section 4 (Stacked) | `bloot-logo-stacked-dark.svg`, `bloot-logo-arabic-stacked-dark.svg` |
| Section 5 (App Icon) | `bloot-appicon-1024.png` |
| Section 6 (Splash) | `bloot-splash.svg`, `bloot-splash.png` |

---

*Nano Banana generates concepts. The design system makes them Bloot.*