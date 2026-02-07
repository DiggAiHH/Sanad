import 'package:flutter_test/flutter_test.dart';
import 'package:sanad_core/sanad_core.dart';

void main() {
  group('Validators', () {
    group('Email Validation', () {
      test('valid email returns null', () {
        expect(Validators.email('test@example.de'), isNull);
        expect(Validators.email('user.name@domain.com'), isNull);
        expect(Validators.email('user+tag@example.org'), isNull);
      });

      test('invalid email returns error message', () {
        expect(Validators.email(''), isNotNull);
        expect(Validators.email('invalid'), isNotNull);
        expect(Validators.email('missing@domain'), isNotNull);
        expect(Validators.email('@nodomain.com'), isNotNull);
      });
    });

    group('Password Validation', () {
      test('valid password returns null', () {
        expect(Validators.password('SecurePass123!'), isNull);
        expect(Validators.password('MyP@ssw0rd'), isNull);
      });

      test('weak password returns error message', () {
        expect(Validators.password(''), isNotNull);
        expect(Validators.password('short'), isNotNull);
        expect(Validators.password('nouppercase123!'), isNotNull);
        expect(Validators.password('NOLOWERCASE123!'), isNotNull);
        expect(Validators.password('NoNumbers!'), isNotNull);
      });
    });

    group('Phone Validation', () {
      test('valid phone returns null', () {
        expect(Validators.phone('+49 123 456789'), isNull);
        expect(Validators.phone('0123456789'), isNull);
        expect(Validators.phone('+49123456789'), isNull);
      });

      test('invalid phone returns error message', () {
        expect(Validators.phone('abc'), isNotNull);
        expect(Validators.phone('12'), isNotNull);
      });

      test('empty phone is optional', () {
        expect(Validators.phone(''), isNull);
        expect(Validators.phone(null), isNull);
      });
    });

    group('Required Validation', () {
      test('non-empty value returns null', () {
        expect(Validators.required('value'), isNull);
        expect(Validators.required('  trimmed  '), isNull);
      });

      test('empty value returns error message', () {
        expect(Validators.required(''), isNotNull);
        expect(Validators.required('   '), isNotNull);
        expect(Validators.required(null), isNotNull);
      });
    });

    group('Ticket Number Validation', () {
      test('valid ticket number returns null', () {
        expect(Validators.ticketNumber('A-001'), isNull);
        expect(Validators.ticketNumber('B-123'), isNull);
        expect(Validators.ticketNumber('C-999'), isNull);
      });

      test('invalid ticket number returns error message', () {
        expect(Validators.ticketNumber(''), isNotNull);
        expect(Validators.ticketNumber('invalid'), isNotNull);
        expect(Validators.ticketNumber('123'), isNotNull);
      });
    });
  });

  group('Formatters', () {
    group('Date Formatting', () {
      test('formatDate returns correct format', () {
        final date = DateTime(2025, 1, 15);
        expect(Formatters.formatDate(date), '15.01.2025');
      });

      test('formatTime returns correct format', () {
        final time = DateTime(2025, 1, 15, 14, 30);
        expect(Formatters.formatTime(time), '14:30');
      });

      test('formatDateTime returns correct format', () {
        final dateTime = DateTime(2025, 1, 15, 14, 30);
        expect(Formatters.formatDateTime(dateTime), '15.01.2025 14:30');
      });
    });

    group('Wait Time Formatting', () {
      test('formatWaitTime returns minutes', () {
        expect(Formatters.formatWaitTime(5), '5 Minuten');
        expect(Formatters.formatWaitTime(1), '1 Minute');
      });

      test('formatWaitTime returns hours and minutes', () {
        expect(Formatters.formatWaitTime(65), '1 Stunde 5 Minuten');
        expect(Formatters.formatWaitTime(120), '2 Stunden');
      });
    });

    group('Ticket Number Formatting', () {
      test('formatTicketNumber pads correctly', () {
        expect(Formatters.formatTicketNumber('A', 1), 'A-001');
        expect(Formatters.formatTicketNumber('B', 42), 'B-042');
        expect(Formatters.formatTicketNumber('C', 999), 'C-999');
      });
    });
  });
}
