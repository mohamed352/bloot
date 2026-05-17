import 'package:easy_localization/easy_localization.dart';
import 'package:bloot/generated/locale_keys.g.dart';

extension DateFormatExtension on DateTime {
  String get toShortDate => DateFormat('yyyy/MM/dd').format(this);

  String toLocalizedDate([String? locale]) =>
      DateFormat.yMMMMd(locale).format(this);

  String toTime([String? locale]) => DateFormat.jm(locale).format(this);

  String toFullDate([String? locale]) =>
      '${toLocalizedDate(locale)} ${toTime(locale)}';

  String get toRelative {
    final Duration diff = DateTime.now().difference(this);
    if (diff.inMinutes < 1) return LocaleKeys.timeNow.tr();
    if (diff.inMinutes < 60) {
      return LocaleKeys.timeMinutesAgo.tr(
        namedArgs: {'minutes': '${diff.inMinutes}'},
      );
    }
    if (diff.inHours < 24) {
      return LocaleKeys.timeHoursAgo.tr(
        namedArgs: {'hours': '${diff.inHours}'},
      );
    }
    if (diff.inDays < 7) {
      return LocaleKeys.timeDaysAgo.tr(namedArgs: {'days': '${diff.inDays}'});
    }
    return toLocalizedDate();
  }
}
