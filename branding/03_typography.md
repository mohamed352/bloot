# Bloot — Typography System

## Font Stack

### Arabic: Cairo

```
Cairo, Noto Sans Arabic,Segoe UI,Tahoma,sans-serif
```

Cairo is a modern Arabic typeface with excellent legibility at all sizes, designed by Mohamed Gaber. It supports the full Arabic character set including Arabic-specific ligatures and diacritics. Its geometric yet warm personality matches Bloot's premium-yet-approachable brand voice.

### Latin: Inter

```
Inter, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif
```

Inter is a typeface carefully crafted for computer screens. Its tall x-height, open apertures, and consistent spacing make it ideal for UI text at small sizes while remaining beautiful at display sizes.

---

## RTL Implementation

Bloot is an **Arabic-first, RTL-primary** application. This is not an afterthought — it's the default.

### Core RTL Rules

1. **`dir="rtl"` is the default** — The document root is RTL. LTR support is the override.
2. **`text-align: start`** — Never use `text-align: left` or `text-align: right`. Use logical properties.
3. **Logical properties** — Use `margin-inline-start`, `padding-inline-end`, `border-inline-start`, etc. Never physical left/right.
4. **Flex direction** — Use `row` (which flips in RTL automatically), not `row-reverse`.
5. **Number direction** — Arabic numerals (٠١٢٣٤٥٦٧٨٩) are the default. Latin digits only for game scores and rankings when mixed content.
6. **Icon flipping** — All directional icons must flip in RTL context. Use `[dir="rtl"] .icon { transform: scaleX(-1); }`.

### Arabic Type Adjustments

Arabic script has different visual density than Latin. These adjustments are **mandatory** for Arabic text:

| Property | Latin Default | Arabic Override | Reason |
|----------|---------------|-----------------|--------|
| Font Size | base size | +1–2px | Arabic appears smaller at same px size |
| Line Height | 1.4–1.5 | 1.7–1.8 | Arabic needs more vertical space for ascenders/descenders |
| Letter Spacing | normal | **NEVER APPLIED** | Arabic letter-spacing destroys legibility |
| Word Spacing | normal | +0.02em | Slight increase improves readability |
| Font Weight | 400/500/600 | 500/600/700 | Arabic benefits from heavier weights |
| Paragraph Spacing | 16px | 20px | Arabic paragraphs benefit from more spacing |

### Critical Rule: No Letter-Spacing on Arabic

```css
/* CORRECT */
.arabic-text {
  letter-spacing: normal;
  line-height: 1.8;
}

/* WRONG — NEVER DO THIS */
.arabic-text {
  letter-spacing: 0.05em; /* DESTROYS ARABIC LEGIBILITY */
}
```

Arabic is a cursive script. Letter-spacing breaks the natural connections between letters and makes text unreadable. This is a **hard rule** with zero exceptions.

---

## Type Scale

### Display Scale

| Token | Size (px) | Size (rem) | Line Height (Latin) | Line Height (Arabic) | Weight | Letter Spacing | Usage |
|-------|-----------|------------|---------------------|----------------------|--------|----------------|-------|
| --text-display-lg | 48 | 3.0 | 1.1 | 1.3 | 700 | -0.02em | Hero titles, splash screens |
| --text-display | 40 | 2.5 | 1.15 | 1.35 | 700 | -0.01em | Screen titles, major headings |
| --text-display-sm | 36 | 2.25 | 1.2 | 1.4 | 600 | -0.01em | Section titles |

### Heading Scale

| Token | Size (px) | Size (rem) | Line Height (Latin) | Line Height (Arabic) | Weight | Letter Spacing | Usage |
|-------|-----------|------------|---------------------|----------------------|--------|----------------|-------|
| --text-h1 | 32 | 2.0 | 1.2 | 1.4 | 700 | 0 | Page headings |
| --text-h2 | 28 | 1.75 | 1.25 | 1.45 | 600 | 0 | Section headings |
| --text-h3 | 24 | 1.5 | 1.3 | 1.5 | 600 | 0 | Card titles, subsection headings |
| --text-h4 | 20 | 1.25 | 1.35 | 1.55 | 600 | 0 | Small headings, list headers |

### Body Scale

| Token | Size (px) | Size (rem) | Line Height (Latin) | Line Height (Arabic) | Weight | Letter Spacing | Usage |
|-------|-----------|------------|---------------------|----------------------|--------|----------------|-------|
| --text-body-lg | 18 | 1.125 | 1.5 | 1.7 | 400 | 0 | Prominent body text, descriptions |
| --text-body | 16 | 1.0 | 1.5 | 1.7 | 400 | 0 | Default body text |
| --text-body-sm | 14 | 0.875 | 1.45 | 1.65 | 400 | 0 | Secondary text, captions |
| --text-caption | 12 | 0.75 | 1.4 | 1.6 | 500 | 0.01em | Labels, timestamps, tags |
| --text-overline | 11 | 0.6875 | 1.4 | 1.6 | 600 | 0.08em | Overlines, category tags |

### Game-Specific Scale

| Token | Size (px) | Size (rem) | Line Height | Weight | Usage |
|-------|-----------|------------|-------------|--------|-------|
| --text-score | 24 | 1.5 | 1.0 | 700 | Score displays |
| --text-score-lg | 36 | 2.25 | 1.0 | 800 | Final score, winner |
| --text-card-rank | 14 | 0.875 | 1.0 | 700 | Card rank labels |
| --text-badge | 10 | 0.625 | 1.0 | 700 | LIVE badges, player counts |
| --text-username | 13 | 0.8125 | 1.2 | 500 | Player names under video |
| --text-chat | 14 | 0.875 | 1.5 | 400 | Chat messages |
| --text-chat-name | 13 | 0.8125 | 1.2 | 600 | Sender name in chat |

---

## Weight Scale

| Weight | Name | Usage |
|--------|------|-------|
| 400 | Regular | Body text, descriptions, chat messages |
| 500 | Medium | Navigation, buttons, secondary headings |
| 600 | Semi-Bold | Headings, button text, labels |
| 700 | Bold | Page titles, scores, emphasis |
| 800 | Extra-Bold | Display scores, winner announcements |

### Arabic Weight Note

Arabic text at weight 400 appears lighter than Latin at the same weight. The recommended minimum for Arabic body text is **500 (Medium)**. Headlines should use **600–700**.

| Context | Latin Weight | Arabic Weight |
|---------|-------------|---------------|
| Body text | 400 | 500 |
| Medium emphasis | 500 | 600 |
| Headings | 600 | 700 |
| Display | 700 | 800 |

---

## Mixed Content Rules

Bloot frequently mixes Arabic and Latin text (e.g., "مستوى 5", "فوز +100"). Rules:

1. **Base direction is RTL** — The paragraph direction is always RTL.
2. **Numbers follow context** — Use Arabic-Indic numerals (٠١٢٣) in pure Arabic context. Use Latin digits (0123) in game scores and mixed content.
3. **Unicode bidi control** — Use `dir="auto"` on user-generated content.
4. **Spacing** — Add a thin space (2006px or `&thinsp;`) between Arabic and Latin number sequences.
5. **Font per character** — The font stack should automatically apply Cairo for Arabic characters and Inter for Latin characters. Use CSS `unicode-range` in @font-face declarations.

```css
@font-face {
  font-family: 'BlootStack';
  src: url('/fonts/Cairo-Variable.woff2') format('woff2');
  unicode-range: U+0600-06FF, U+200C-200F, U+FE70-FEFF;
  font-weight: 200 900;
}

@font-face {
  font-family: 'BlootStack';
  src: url('/fonts/Inter-Variable.woff2') format('woff2');
  unicode-range: U+0020-007E, U+00A0-00FF;
  font-weight: 100 900;
}
```

---

## Accessibility Notes

### Minimum Contrast Ratios

| Text Type | Minimum Ratio | On Background | Recommended |
|-----------|---------------|---------------|-------------|
| Body text | 4.5:1 | #0A0A0F | #F5F5F5 (Secondary text) |
| Large text (18px+ bold) | 3:1 | #0A0A0F | #A3A3A3 (Gray 400) |
| Interactive elements | 4.5:1 | #0A0A0F | #8B5CF6 (Purple 500) |
| Gold accent | 3:1 minimum | #0A0A0F | #F59E0B passes at 5.4:1 |
| Disabled text | 2:1 | #0A0A0F | #525252 (Gray 600) |

### Font Scaling

- The type scale uses `rem` units tied to a 16px root.
- Support system font scaling up to 1.5x (24px root).
- At 1.5x, game text should not overflow card boundaries.
- Game card dimensions are fixed (not scaled) — only UI text scales.
- Maximum font scale: 1.5x. Beyond this, layout breaks for the game board.
- Provide an in-app font size setting: Small (0.875x), Default (1x), Large (1.25x), XL (1.5x).

### Touch & Readability

- Minimum touch target for text buttons: 44px × 44px
- Minimum font size in game UI: 12px (even at 0.875x scale)
- Chat messages must maintain 14px minimum even at smallest scale
- Always provide sufficient line-height for Arabic text (minimum 1.6)

---

## Fallback Stack

If Cairo or Inter fail to load, the system must still render readable text:

```css
--font-arabic: 'Cairo', 'Noto Sans Arabic', 'Segoe UI', 'Tahoma', sans-serif;
--font-latin: 'Inter', -apple-system, 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'Helvetica Neue', sans-serif;
--font-mono: 'JetBrains Mono', 'Fira Code', 'Consolas', monospace;
```

| Font | Role | Critical Level |
|------|------|----------------|
| Cairo | Primary Arabic | Must load — block rendering |
| Inter | Primary Latin | Must load — block rendering |
| Noto Sans Arabic | Arabic fallback | Acceptable alternative |
| System font | Final fallback | Degraded but functional |

---

## Typography Tokens (CSS Custom Properties)

```css
:root {
  --font-arabic: 'Cairo', 'Noto Sans Arabic', 'Segoe UI', 'Tahoma', sans-serif;
  --font-latin: 'Inter', -apple-system, 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', sans-serif;
  --font-mono: 'JetBrains Mono', 'Fira Code', 'Consolas', mon-serif;

  --text-display-lg: 3rem;
  --text-display: 2.5rem;
  --text-display-sm: 2.25rem;
  --text-h1: 2rem;
  --text-h2: 1.75rem;
  --text-h3: 1.5rem;
  --text-h4: 1.25rem;
  --text-body-lg: 1.125rem;
  --text-body: 1rem;
  --text-body-sm: 0.875rem;
  --text-caption: 0.75rem;
  --text-overline: 0.6875rem;

  --lh-latin: 1.5;
  --lh-arabic: 1.7;

  --weight-regular: 400;
  --weight-medium: 500;
  --weight-semibold: 600;
  --weight-bold: 700;
  --weight-extrabold: 800;
}
```

---

## Mobile-to-Web Scale Mapping

The mobile app (375px base, Flutter) uses a condensed type scale optimized for small screens. When adapting to web/desktop, use the following mapping to maintain visual hierarchy while leveraging the larger canvas.

| Mobile Role | Mobile Size | Web Token | Web Size (px) | Web Size (rem) | Notes |
|-------------|-------------|-----------|---------------|----------------|-------|
| Display (splash brand) | 28px | `--text-h2` | 28 | 1.75 | Direct match; use `--text-display` (40px) for hero web sections |
| Headline (screen title) | 22px | `--text-h3` | 24 | 1.5 | Closest web match; 2px larger preserves hierarchy on desktop |
| Title (card title, player name) | 15px | `--text-body` | 16 | 1.0 | Round up to 16px on web for sharper rasterization |
| Body (descriptions, content) | 14px | `--text-body-sm` | 14 | 0.875 | Direct match |
| Caption (timestamps, helpers) | 12px | `--text-caption` | 12 | 0.75 | Direct match |
| Label (buttons, tags) | 13px | `--text-body-sm` | 14 | 0.875 | Round up to 14px; 13px doesn't exist in web scale |

### Scaling Guidelines

- **Mobile display (28px) → Web:** For splash/brand moments, step up to `--text-display` (40px) or `--text-display-sm` (36px). The 28px mobile display maps to `--text-h2` for secondary screen titles on web.
- **Mobile headline (22px) → Web:** Maps to `--text-h3` (24px). On web, use `--text-h1` (32px) or `--text-h2` (28px) for primary page headings to fill the larger viewport.
- **Mobile label (13px) → Web:** No exact 13px token on web. Use `--text-body-sm` (14px) for general labels, or `--text-username` (13px) from the game-specific scale for player name labels.
- **Always round up** when no exact match exists — slightly larger text is preferred over slightly smaller on desktop.
- **Arabic adjustments still apply** — add +1–2px and increase line-height per the Arabic Type Adjustments table above, regardless of platform.

---

*Type is the voice of the interface. In Bloot, that voice speaks Arabic first.*