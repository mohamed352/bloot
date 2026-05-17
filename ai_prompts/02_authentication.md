# Authentication Prompt

## Context

Include `00_master_rules.md` before using this prompt.

## CRITICAL: English Only with RTL Notes

All UI screens MUST be generated in **English only**. Add RTL implementation notes as HTML comments.

## Screens: Login, OTP, Complete Profile

### 01 Login Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Top: Bloot logo (small, centered)
- Headline: "Welcome Back"
<!-- RTL: "مرحباً بعودتك" -->
- Subtitle: "Sign in to continue playing"
- Form:
  - Phone number input (with country code selector, default +966 for KSA)
  - Input styled with dark surface (`bg-b-surface-muted`) and purple focus ring
- Primary CTA: "Send Code" (primary-btn, full width)
- Divider: "or continue with"
- Social login options:
  - Apple Sign In button (dark style, per Apple HIG)
  - Google Sign In button (outlined style)
- Bottom link: "Don't have an account? Sign Up" (b-purple text link)

**States:**
- Loading: Button shows spinner, disabled
- Error: Red text below input, shake animation
- Success: Navigate to OTP

**Output:** HTML login screen

### 02 OTP Verification Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Headline: "Verify Your Phone"
<!-- RTL: "تحقق من هاتفك" -->
- Subtitle: "Enter the 4-digit code sent to +966 5X XXX XXXX"
- OTP Input:
  - 4 separate boxes, each 56x56px
  - Dark surface background (`bg-b-surface-muted`)
  - Purple border on active box
  - Auto-focus next box after entry
  - Numeric keyboard only
- Timer: "Resend code in 00:59"
- Link: "Didn't receive it? Resend" (disabled until timer expires, b-purple when active)
- Primary CTA: "Verify" (primary-btn, full width)

**States:**
- Invalid OTP: Red border on boxes, error message
- Resend: Reset timer, send new code

**Output:** HTML OTP screen

### 03 Complete Profile Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Headline: "Set Up Your Profile"
<!-- RTL: "إعداد ملفك الشخصي" -->
- Subtitle: "Choose a display name and profile picture"
- Profile photo upload:
  - Large circle (120px)
  - Camera icon overlay
  - Default avatar: Purple gradient circle with user icon
  - Tap to upload from gallery or take photo
- Display name input:
  - Placeholder: "Your display name"
  - Max 20 characters
  - Character counter
- Username input:
  - Placeholder: "Choose a username"
  - Prefix: "@"
  - Availability check (real-time)
  - Green checkmark if available, red X if taken
- Terms checkbox:
  - "I agree to the Terms of Service and Privacy Policy"
  - Links to legal pages
- Primary CTA: "Start Playing" (primary-btn, full width, gold gradient to emphasize excitement)
- Skip option: "Set up later" (text link, b-on-surface-muted)

**Output:** HTML complete profile screen

---

## Design Notes

- All forms use `text-input` component pattern from master rules
- Phone inputs should format automatically
- Dark surfaces with purple accents throughout
- No light mode — this app is dark-only
- Keyboard should not obscure inputs (scroll on focus)
- Gold gradient button on "Start Playing" to create excitement
- All screens support RTL implementation