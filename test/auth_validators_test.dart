import 'package:flutter_test/flutter_test.dart';
import 'package:bloot/features/auth/domain/utils/auth_validators.dart';

void main() {
  group('AuthValidators', () {
    group('validateDisplayName', () {
      test('returns name_required for null or empty input', () {
        expect(AuthValidators.validateDisplayName(null), 'name_required');
        expect(AuthValidators.validateDisplayName(''), 'name_required');
      });

      test('returns name_too_short for single character', () {
        expect(AuthValidators.validateDisplayName('A'), 'name_too_short');
      });

      test('returns name_too_long for overly long names', () {
        expect(
          AuthValidators.validateDisplayName('A' * 31),
          'name_too_long',
        );
      });

      test('returns null for valid names', () {
        expect(AuthValidators.validateDisplayName('Ali'), isNull);
        expect(AuthValidators.validateDisplayName('  Sara  '), isNull);
        expect(AuthValidators.validateDisplayName('A' * 30), isNull);
      });
    });

    group('validateUsername', () {
      test('returns username_required for null or empty input', () {
        expect(AuthValidators.validateUsername(null), 'username_required');
        expect(AuthValidators.validateUsername(''), 'username_required');
      });

      test('returns username_too_short for short usernames', () {
        expect(AuthValidators.validateUsername('ab'), 'username_too_short');
      });

      test('returns username_too_long for long usernames', () {
        expect(
          AuthValidators.validateUsername('a' * 21),
          'username_too_long',
        );
      });

      test('returns username_invalid for invalid characters', () {
        expect(AuthValidators.validateUsername('ali-ahmed'), 'username_invalid');
        expect(AuthValidators.validateUsername('ali ahmed'), 'username_invalid');
        expect(AuthValidators.validateUsername('ali@ahmed'), 'username_invalid');
      });

      test('returns null for valid usernames', () {
        expect(AuthValidators.validateUsername('ali_ahmed'), isNull);
        expect(AuthValidators.validateUsername('@ali123'), isNull);
        expect(AuthValidators.validateUsername('a_b_c'), isNull);
      });
    });

    group('normalizeUsername', () {
      test('trims, removes leading @, and lowercases', () {
        expect(AuthValidators.normalizeUsername('  @Ali_Ahmed  '), 'ali_ahmed');
        expect(AuthValidators.normalizeUsername('USER123'), 'user123');
      });
    });

    group('validateEmail', () {
      test('returns email_required for null or empty input', () {
        expect(AuthValidators.validateEmail(null), 'email_required');
        expect(AuthValidators.validateEmail('   '), 'email_required');
      });

      test('returns email_invalid for malformed addresses', () {
        expect(AuthValidators.validateEmail('not-an-email'), 'email_invalid');
        expect(AuthValidators.validateEmail('a@b'), 'email_invalid');
        expect(AuthValidators.validateEmail('a@.com'), 'email_invalid');
        expect(AuthValidators.validateEmail('@bloot.app'), 'email_invalid');
      });

      test('returns null for valid addresses', () {
        expect(AuthValidators.validateEmail('reviewer@bloot.app'), isNull);
        expect(AuthValidators.validateEmail('  a.b+tag@example.co  '), isNull);
      });
    });

    group('validatePassword', () {
      test('returns password_required for null or empty input', () {
        expect(AuthValidators.validatePassword(null), 'password_required');
        expect(AuthValidators.validatePassword(''), 'password_required');
      });

      test('returns password_too_short for short passwords', () {
        expect(AuthValidators.validatePassword('12345'), 'password_too_short');
      });

      test('returns null for valid passwords', () {
        expect(AuthValidators.validatePassword('123456'), isNull);
        expect(AuthValidators.validatePassword('BlootReview2026!'), isNull);
      });
    });
  });
}
