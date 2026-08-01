# Bloot — Google Play Store Listing Copy

Everything below is ready to paste into Play Console → Store presence →
**Default store listing**. Character counts are pre-checked against Play limits.

Graphics to upload from this folder:

| Field | File |
|---|---|
| App icon (512×512) | `icon_512.png` |
| Feature graphic (1024×500) | `feature_graphic.png` |
| Phone screenshots (in this order, 1080×1920) | `phone_01_home_screen.png` → `phone_08_user_profile.png` |

Video, tablet, Chromebook, XR, and Play-Games-on-PC sections are optional —
skip them for launch (Play reuses phone screenshots for tablets).

---

## English (default language)

### App name (5/30) — already set
```
bloot
```

### Short description (70/80)
```
Play live Baloot with friends — voice, video, private rooms & streams.
```

### Full description (~1,380/4000)
```
Bloot brings Baloot — the Gulf's favorite card game — online. Create private rooms, invite your friends with a code, and play authentic 4-player Baloot with real-time voice and video. The diwaniya is now online.

🃏 PLAY LIVE BALOOT
Classic 4-player, 2-team Baloot with authentic rules. Create a private room in seconds and invite friends with a simple code or link.

🎙 VOICE & VIDEO AT THE TABLE
Real-time voice and video at the table — talk, laugh, and react just like sitting together in a real diwaniya.

📺 WATCH & STREAM
Watch live Baloot streams from players across the Gulf, or go live and broadcast your own games to the community.

🏆 COMPETE
Track your stats, level up, and climb the leaderboard. Win with class, lose with dignity.

💬 SOCIAL
Friends, direct messages, and chat — with report & block tools to keep the community respectful.

🌍 ARABIC & ENGLISH
A premium dark design, fully localized in Arabic and English.

Whether it's a quick game with friends or a full evening diwaniya, Bloot is where Baloot lives online.

Download now and deal your first hand.
```

---

## العربية (Arabic translation — add via "Select a language to edit")

### اسم التطبيق
```
بلوت
```

### الوصف المختصر (59/80)
```
العب بلوت لايف مع أصدقائك — صوت وصورة، غرف خاصة وبث مباشر.
```

### الوصف الكامل (~750/4000)
```
بلوت يجلب لعبة البلوت — اللعبة المفضلة في الخليج — إلى الإنترنت. أنشئ غرفة خاصة، ادعُ أصدقاءك برمز، والعب بلوت أصلي بأربعة لاعبين مع صوت وصورة مباشرة. الديوانية صارت أونلاين.

🃏 العب بلوت لايف
بلوت كلاسيكي بأربعة لاعبين وفريقين بالقواعد الأصيلة. أنشئ غرفة خاصة في ثوانٍ وادعُ أصدقاءك برمز أو رابط بسيط.

🎙 صوت وصورة على الطاولة
صوت وصورة مباشرة على الطاولة — تكلم واضحك وتفاعل كأنكم جالسين معًا في ديوانية حقيقية.

📺 شاهد وابث
تابع بثوث بلوت مباشرة من لاعبين في كل الخليج، أو ابث ألعابك بنفسك للمجتمع.

🏆 نافس
تتبع إحصائياتك، ارفع مستواك، وتسلق قائمة المتصدرين. اربح بأناقة واخسر بكرامة.

💬 المجتمع
أصدقاء ورسائل مباشرة ودردشة — مع أدوات إبلاغ وحظر تحافظ على احترام المجتمع.

🌍 العربية والإنجليزية
تصميم داكن فاخر، مترجم بالكامل إلى العربية والإنجليزية.

سواء كانت جولة سريعة مع الأصدقاء أو سهرة ديوانية كاملة، بلوت هو بيت البلوت أونلاين.

حمّل التطبيق الآن وابدأ أول يد.
```

---

## Notes

- Screenshots are built from the app's official design renders
  (`stitch_bloot_social_onboarding_platform/*/screen.png`) on the brand dark
  canvas (#0A0A0F). Regenerate with `python store_assets/prepare_play_listing.py`.
  Replace with real device captures later if you prefer — keep 1080×1920 9:16.
- The Arabic listing reuses the same graphics (Play falls back to default
  graphics when no localized ones are uploaded — that is fine for launch).
- Keyword coverage for search: Baloot, بلوت, card game, diwaniya, live
  stream, voice chat — all present in the descriptions above.
