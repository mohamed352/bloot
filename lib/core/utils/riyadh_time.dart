/// Saudi Arabia (Asia/Riyadh) time formatting helpers.
///
/// Saudi Arabia is UTC+3 year-round (no daylight saving), so conversion is
/// a fixed offset from UTC — safe to compute without a timezone database.
library;

const Duration riyadhOffset = Duration(hours: 3);

/// Converts [dateTime] to Saudi Arabia wall-clock time.
DateTime toRiyadh(DateTime dateTime) =>
    dateTime.toUtc().add(riyadhOffset);

String _two(int v) => v.toString().padLeft(2, '0');

/// HH:mm clock time in Saudi Arabia, e.g. `14:05`.
String formatRiyadhClock(DateTime dateTime) {
  final t = toRiyadh(dateTime);
  return '${_two(t.hour)}:${_two(t.minute)}';
}

/// HH:mm when [dateTime] falls on the same Saudi day as [now] (default:
/// current time), otherwise `dd/MM HH:mm`.
String formatRiyadhDateClock(DateTime dateTime, {DateTime? now}) {
  final t = toRiyadh(dateTime);
  final reference = toRiyadh(now ?? DateTime.now());
  final clock = '${_two(t.hour)}:${_two(t.minute)}';
  final sameDay =
      t.year == reference.year &&
      t.month == reference.month &&
      t.day == reference.day;
  if (sameDay) return clock;
  return '${_two(t.day)}/${_two(t.month)} $clock';
}
