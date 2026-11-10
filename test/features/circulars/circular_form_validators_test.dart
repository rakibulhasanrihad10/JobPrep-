import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/validators/circular_form_validators.dart';

void main() {
  group('CircularFormValidators - Title & URL Validation', () {
    test('validateTitle requires non-blank title', () {
      expect(
        CircularFormValidators.validateTitle(null),
        equals(CircularTitleValidationError.required),
      );
      expect(
        CircularFormValidators.validateTitle(''),
        equals(CircularTitleValidationError.required),
      );
      expect(
        CircularFormValidators.validateTitle('   \t\n '),
        equals(CircularTitleValidationError.required),
      );
      expect(CircularFormValidators.validateTitle('47th BCS'), isNull);
    });

    test('validateOptionalUrl accepts empty and HTTP(S) URLs, rejects invalid',
        () {
      expect(CircularFormValidators.validateOptionalUrl(null), isNull);
      expect(CircularFormValidators.validateOptionalUrl(''), isNull);
      expect(CircularFormValidators.validateOptionalUrl('   '), isNull);
      expect(
        CircularFormValidators.validateOptionalUrl(
          'https://erecruitment.bb.org.bd/career/job?id=42',
        ),
        isNull,
      );
      expect(
        CircularFormValidators.validateOptionalUrl('http://localhost:8080/job'),
        isNull,
      );

      for (final bad in [
        'bpsc.gov.bd',
        'ftp://example.com/file',
        'javascript:alert(1)',
        'https://',
        'https://bad host.com/job',
        'not a url',
      ]) {
        expect(
          CircularFormValidators.validateOptionalUrl(bad),
          equals(CircularUrlValidationError.invalidFormat),
          reason: 'Expected "$bad" to fail URL validation',
        );
      }
    });
  });

  group('CircularFormValidators - Numeric & Salary Range Checks', () {
    test('validateOptionalNonNegativeInt validates whole numbers & Bangla', () {
      expect(
        CircularFormValidators.validateOptionalNonNegativeInt(null),
        isNull,
      );
      expect(
        CircularFormValidators.validateOptionalNonNegativeInt('  '),
        isNull,
      );
      expect(
        CircularFormValidators.validateOptionalNonNegativeInt('0'),
        isNull,
      );
      expect(
        CircularFormValidators.validateOptionalNonNegativeInt('1,250'),
        isNull,
      );
      expect(
        CircularFormValidators.validateOptionalNonNegativeInt('১৫০'),
        isNull,
      );
      expect(CircularFormValidators.parseOptionalInt('১৫০'), equals(150));

      expect(
        CircularFormValidators.validateOptionalNonNegativeInt('-5'),
        equals(CircularNumberValidationError.invalidNonNegativeInt),
      );
      expect(
        CircularFormValidators.validateOptionalNonNegativeInt('12.5'),
        equals(CircularNumberValidationError.invalidNonNegativeInt),
      );
      expect(
        CircularFormValidators.validateOptionalNonNegativeInt('abc'),
        equals(CircularNumberValidationError.invalidNonNegativeInt),
      );
    });

    test('validateOptionalNonNegativeNumber handles decimals & invalid text',
        () {
      expect(
        CircularFormValidators.validateOptionalNonNegativeNumber(''),
        isNull,
      );
      expect(
        CircularFormValidators.validateOptionalNonNegativeNumber('22000.50'),
        isNull,
      );
      expect(
        CircularFormValidators.validateOptionalNonNegativeNumber('২২,০০০'),
        isNull,
      );
      expect(
        CircularFormValidators.parseOptionalDouble('২২,০০০.৫'),
        equals(22000.5),
      );
      expect(
        CircularFormValidators.validateOptionalNonNegativeNumber('-100'),
        equals(CircularNumberValidationError.invalidNonNegativeAmount),
      );
      expect(
        CircularFormValidators.validateOptionalNonNegativeNumber('free'),
        equals(CircularNumberValidationError.invalidNonNegativeAmount),
      );
    });

    test('validateSalaryRange rejects max below min and allows equal/above',
        () {
      expect(
        CircularFormValidators.validateSalaryRange(
          salaryMinText: '50000',
          salaryMaxText: '30000',
        ),
        equals(CircularSalaryRangeValidationError.maxBelowMin),
      );
      expect(
        CircularFormValidators.validateSalaryRange(
          salaryMinText: '22000',
          salaryMaxText: '22000',
        ),
        isNull,
      );
      expect(
        CircularFormValidators.validateSalaryRange(
          salaryMinText: '22000',
          salaryMaxText: '53060',
        ),
        isNull,
      );
      expect(
        CircularFormValidators.validateSalaryRange(
          salaryMinText: '22000',
          salaryMaxText: '',
        ),
        isNull,
      );
      expect(
        CircularFormValidators.validateSalaryRange(
          salaryMinText: '',
          salaryMaxText: '53060',
        ),
        isNull,
      );
    });
  });

  group('CircularFormValidators - Duplicate Circular Link Detection', () {
    final existing = [
      const Circular(
        id: 'c-1',
        title: '47th BCS Circular',
        circularUrl: 'https://BPSC.GOV.BD/Circulars/47/',
      ),
      const Circular(
        id: 'c-2',
        title: 'Bank AD Circular',
        circularUrl: 'https://bb.org.bd/jobs',
      ),
    ];

    test('detects duplicates ignoring host case, trailing slash, and fragment',
        () {
      final match = CircularFormValidators.findDuplicateCircularByLink(
        circularUrl: 'https://bpsc.gov.bd/Circulars/47#top',
        existingCirculars: existing,
      );
      expect(match?.id, equals('c-1'));
    });

    test('ignores current record in edit mode and blank/invalid URLs', () {
      expect(
        CircularFormValidators.findDuplicateCircularByLink(
          circularUrl: 'https://bpsc.gov.bd/Circulars/47',
          existingCirculars: existing,
          editingCircularId: 'c-1',
        ),
        isNull,
      );
      expect(
        CircularFormValidators.findDuplicateCircularByLink(
          circularUrl: '',
          existingCirculars: existing,
        ),
        isNull,
      );
      expect(
        CircularFormValidators.findDuplicateCircularByLink(
          circularUrl: 'not-a-url',
          existingCirculars: existing,
        ),
        isNull,
      );
    });
  });
}
