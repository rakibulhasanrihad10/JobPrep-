import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/utils/quick_capture_helpers.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_form_state.dart';

void main() {
  group('Quick Capture Helpers', () {
    test('validateRequiredCircularLink requires valid HTTP(S) URL', () {
      expect(
        validateRequiredCircularLink(null),
        equals(QuickCaptureLinkValidationError.required),
      );
      expect(
        validateRequiredCircularLink(''),
        equals(QuickCaptureLinkValidationError.required),
      );
      expect(
        validateRequiredCircularLink('   '),
        equals(QuickCaptureLinkValidationError.required),
      );

      for (final bad in [
        'bpsc.gov.bd',
        'ftp://example.com/notice.pdf',
        'javascript:alert(1)',
        'https://bad host.com/job',
      ]) {
        expect(
          validateRequiredCircularLink(bad),
          equals(QuickCaptureLinkValidationError.invalidFormat),
          reason: 'Expected "$bad" to fail required link validation',
        );
      }

      expect(
        validateRequiredCircularLink('https://bpsc.gov.bd/notices/47'),
        isNull,
      );
      expect(
        validateRequiredCircularLink('http://localhost:8080/circular'),
        isNull,
      );
    });

    test('deriveTitleFromCircularUrl extracts clean hostname fallback', () {
      expect(
        deriveTitleFromCircularUrl('https://www.BPSC.GOV.BD/notices/47'),
        equals('bpsc.gov.bd'),
      );
      expect(
        deriveTitleFromCircularUrl('https://erecruitment.bb.org.bd/career/1'),
        equals('erecruitment.bb.org.bd'),
      );
      expect(
        deriveTitleFromCircularUrl('  '),
        equals(''),
      );
    });

    test('extractCaptureLinkFromUri reads ?capture= and /capture?url=', () {
      expect(
        extractCaptureLinkFromUri(
          Uri.parse('/?capture=https%3A%2F%2Fbpsc.gov.bd%2F47'),
        ),
        equals('https://bpsc.gov.bd/47'),
      );
      expect(
        extractCaptureLinkFromUri(
          Uri.parse('/dashboard?capture=https://bb.org.bd/jobs'),
        ),
        equals('https://bb.org.bd/jobs'),
      );
      expect(
        extractCaptureLinkFromUri(
          Uri.parse('/capture?url=https%3A%2F%2Fexample.com%2Fnotice'),
        ),
        equals('https://example.com/notice'),
      );
      expect(
        extractCaptureLinkFromUri(Uri.parse('/dashboard?capture=   ')),
        isNull,
      );
      expect(
        extractCaptureLinkFromUri(Uri.parse('/circulars')),
        isNull,
      );
    });

    test('stripCaptureQueryParams removes capture param cleanly', () {
      expect(
        stripCaptureQueryParams(
          Uri.parse('/dashboard?capture=https%3A%2F%2Fbpsc.gov.bd'),
        ).toString(),
        equals('/dashboard'),
      );
      expect(
        stripCaptureQueryParams(
          Uri.parse('/circulars?tab=active&capture=https%3A%2F%2Fbb.org.bd'),
        ).toString(),
        equals('/circulars?tab=active'),
      );
      expect(
        stripCaptureQueryParams(
          Uri.parse('/capture?url=https%3A%2F%2Fexample.com'),
        ).toString(),
        equals('/capture'),
      );
    });

    test('buildLocationWithCapture preserves capture query across redirects',
        () {
      expect(
        buildLocationWithCapture(
          '/dashboard',
          sourceUri: Uri.parse('/?capture=https%3A%2F%2Fbpsc.gov.bd%2F47'),
        ),
        equals('/dashboard?capture=https%3A%2F%2Fbpsc.gov.bd%2F47'),
      );
      expect(
        buildLocationWithCapture(
          '/dashboard',
          sourceUri: Uri.parse('/'),
        ),
        equals('/dashboard'),
      );
    });

    test('extractUrlFromSharedText extracts URLs from Facebook and social text',
        () {
      // 1. Direct standalone URLs
      expect(
        extractUrlFromSharedText('https://www.facebook.com/bpsc/posts/12345'),
        equals('https://www.facebook.com/bpsc/posts/12345'),
      );
      expect(
        extractUrlFromSharedText('http://bpsc.teletalk.com.bd/apply'),
        equals('http://bpsc.teletalk.com.bd/apply'),
      );

      // 2. URLs embedded in text with surrounding description
      expect(
        extractUrlFromSharedText(
          '47th BCS Circular published! Apply here: '
          'https://bpsc.gov.bd/notices/47.pdf Best of luck!',
        ),
        equals('https://bpsc.gov.bd/notices/47.pdf'),
      );

      // 3. URLs with trailing punctuation stripped
      expect(
        extractUrlFromSharedText(
          'Check circular: https://erecruitment.bb.org.bd/jobs.',
        ),
        equals('https://erecruitment.bb.org.bd/jobs'),
      );
      expect(
        extractUrlFromSharedText(
          '(Apply at https://bpsc.gov.bd/apply)',
        ),
        equals('https://bpsc.gov.bd/apply'),
      );
      expect(
        extractUrlFromSharedText(
          'Important link: https://jobprep.app/notice; deadline soon!',
        ),
        equals('https://jobprep.app/notice'),
      );

      // 4. Whitespace, empty, null, or text without URL
      expect(extractUrlFromSharedText(null), isNull);
      expect(extractUrlFromSharedText(''), isNull);
      expect(extractUrlFromSharedText('   '), isNull);
      expect(
        extractUrlFromSharedText('Just regular text with no links attached'),
        isNull,
      );
    });
  });

  group('Inbox Enum & Form Promotion', () {
    test('CircularWorkflowStatus parses inbox cleanly', () {
      expect(
        CircularWorkflowStatus.tryParse('inbox'),
        equals(CircularWorkflowStatus.inbox),
      );
      expect(
        CircularWorkflowStatus.fromValue('inbox'),
        equals(CircularWorkflowStatus.inbox),
      );
    });

    test(
        'CircularFormState defaults inbox items to saved without marking dirty',
        () {
      const inboxCircular = Circular(
        id: 'in-1',
        title: 'bpsc.gov.bd',
        circularUrl: 'https://bpsc.gov.bd/47',
        workflowStatus: CircularWorkflowStatus.inbox,
        isQuickCapture: true,
      );

      final formState = CircularFormState.fromCircular(inboxCircular);
      expect(formState.workflowStatus, equals(CircularWorkflowStatus.saved));
      expect(formState.isDirty, isFalse);

      final savedPayload = formState.toCircular();
      expect(savedPayload.workflowStatus, equals(CircularWorkflowStatus.saved));
      expect(savedPayload.isQuickCapture, isTrue);
    });
  });
}
