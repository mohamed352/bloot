import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloot/features/chat/presentation/pages/direct_message_page.dart';

void main() {
  group('formatLastSeen (Saudi Arabia time, UTC+3)', () {
    // "now" in Riyadh: 2026-07-20 15:30 → UTC 12:30.
    final now = DateTime.utc(2026, 7, 20, 12, 30);

    test('returns placeholder for null or unknown values', () {
      expect(formatLastSeen(null, now: now), '—');
      expect(formatLastSeen('not-a-date', now: now), '—');
    });

    test('returns Riyadh HH:mm for timestamps from today', () {
      // UTC 09:05 → Riyadh 12:05 (same Saudi day as now).
      final ts = Timestamp.fromDate(DateTime.utc(2026, 7, 20, 9, 5));
      expect(formatLastSeen(ts, now: now), '12:05');
    });

    test('returns dd/MM HH:mm for older timestamps in Riyadh time', () {
      // UTC 2026-07-18 19:07 → Riyadh 22:07.
      final ts = Timestamp.fromDate(DateTime.utc(2026, 7, 18, 19, 7));
      expect(formatLastSeen(ts, now: now), '18/07 22:07');
    });

    test('accepts millis-since-epoch ints', () {
      // UTC 2026-07-20 00:30 → Riyadh 03:30.
      final millis = DateTime.utc(2026, 7, 20, 0, 30).millisecondsSinceEpoch;
      expect(formatLastSeen(millis, now: now), '03:30');
    });

    test('day boundary follows Riyadh, not UTC', () {
      // UTC 2026-07-19 22:30 → Riyadh 2026-07-20 01:30 (same Saudi day).
      final ts = Timestamp.fromDate(DateTime.utc(2026, 7, 19, 22, 30));
      expect(formatLastSeen(ts, now: now), '01:30');
    });
  });
}
