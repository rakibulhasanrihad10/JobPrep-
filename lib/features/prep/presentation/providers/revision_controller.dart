import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/utils/revision_scheduler.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';

/// Draft input value object passed to [RevisionController.addMultipleFlags].
class RevisionFlagDraft {
  /// Creates a [RevisionFlagDraft].
  const RevisionFlagDraft({
    required this.subjectId,
    required this.referenceLabel,
    this.materialId,
    this.topicId,
    this.pageNumber,
    this.note,
    this.reason = RevisionReason.tricky,
    this.source = RevisionSource.manual,
    this.progressLogId,
    this.mockTestId,
  });

  /// Owning subject identifier.
  final String subjectId;

  /// Optional linked material identifier.
  final String? materialId;

  /// Optional linked syllabus topic identifier.
  final String? topicId;

  /// Concise reference text (`p. 128`, `Problem 14`, or topic).
  final String referenceLabel;

  /// Optional numeric page reference.
  final int? pageNumber;

  /// Optional short revision note.
  final String? note;

  /// Flag reason classification.
  final RevisionReason reason;

  /// Entry point source classification.
  final RevisionSource source;

  /// Optional triggering progress log ID.
  final String? progressLogId;

  /// Optional triggering mock test ID.
  final String? mockTestId;
}

/// Controller handling creating revision flags, spaced repetition reviews,
/// dismissal, and undo operations without ever modifying `progress_logs`.
class RevisionController extends Notifier<RevisionMutationState> {
  @override
  RevisionMutationState build() => const RevisionMutationState();

  /// Clears transient mutation error state.
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Hides the latest undo prompt cleanly.
  void clearUndo() {
    state = state.copyWith(lastUndo: null);
  }

  /// Persists a single newly flagged revision mark due 1 day after today.
  Future<RevisionItem?> addFlag({
    required String subjectId,
    required String referenceLabel,
    String? materialId,
    String? topicId,
    int? pageNumber,
    String? note,
    RevisionReason reason = RevisionReason.tricky,
    RevisionSource source = RevisionSource.manual,
    String? progressLogId,
    String? mockTestId,
  }) async {
    final created = await addMultipleFlags([
      RevisionFlagDraft(
        subjectId: subjectId,
        materialId: materialId,
        topicId: topicId,
        referenceLabel: referenceLabel,
        pageNumber: pageNumber,
        note: note,
        reason: reason,
        source: source,
        progressLogId: progressLogId,
        mockTestId: mockTestId,
      ),
    ]);
    return created.isEmpty ? null : created.first;
  }

  /// Batch-creates one or more revision flags due 1 day after today.
  Future<List<RevisionItem>> addMultipleFlags(
    List<RevisionFlagDraft> drafts,
  ) async {
    if (drafts.isEmpty) return const <RevisionItem>[];
    state = state.copyWith(isSaving: true, activeItemId: null, error: null);

    try {
      final today = ref.read(revisionNowProvider)();
      final initialDue = RevisionScheduler.initialDueDate(today);
      final toCreate = drafts
          .map(
            (d) => RevisionItem(
              subjectId: d.subjectId,
              materialId: d.materialId,
              topicId: d.topicId,
              referenceLabel: d.referenceLabel.trim(),
              pageNumber: d.pageNumber ??
                  RevisionScheduler.extractPageNumber(d.referenceLabel),
              note: d.note?.trim().isEmpty ?? true ? null : d.note!.trim(),
              reason: d.reason,
              source: d.source,
              progressLogId: d.progressLogId,
              mockTestId: d.mockTestId,
              dueOn: initialDue,
            ),
          )
          .toList(growable: false);

      final repo = ref.read(revisionItemRepositoryProvider);
      final created = toCreate.length == 1
          ? <RevisionItem>[await repo.createRevisionItem(toCreate.first)]
          : await repo.createRevisionItems(toCreate);

      await ref.read(revisionItemsProvider.notifier).refresh();
      state = state.copyWith(isSaving: false, activeItemId: null);
      return created;
    } on Object catch (error) {
      state = state.copyWith(
        isSaving: false,
        activeItemId: null,
        error: error,
      );
      return const <RevisionItem>[];
    }
  }

  /// Applies [action] on [item] using [RevisionScheduler] and records an
  /// immediate undo snapshot.
  Future<RevisionItem?> applyAction({
    required RevisionItem item,
    required RevisionReviewAction action,
  }) async {
    state = state.copyWith(isSaving: true, activeItemId: item.id, error: null);
    try {
      final today = ref.read(revisionNowProvider)();
      final nextItem =
          RevisionScheduler.applyAction(item, action, today: today);
      final saved =
          await ref.read(revisionItemRepositoryProvider).updateRevisionItem(
                nextItem,
              );
      await ref.read(revisionItemsProvider.notifier).refresh();
      state = state.copyWith(
        isSaving: false,
        activeItemId: null,
        lastUndo: RevisionUndoRecord(
          previousItem: item,
          updatedItem: saved,
          action: action,
        ),
      );
      return saved;
    } on Object catch (error) {
      state = state.copyWith(
        isSaving: false,
        activeItemId: null,
        error: error,
      );
      return null;
    }
  }

  /// Reverts [RevisionMutationState.lastUndo] by restoring `previousItem`.
  Future<bool> undoLastAction() async {
    final record = state.lastUndo;
    if (record == null) return false;
    state = state.copyWith(
      isSaving: true,
      activeItemId: record.previousItem.id,
      error: null,
    );
    try {
      await ref.read(revisionItemRepositoryProvider).updateRevisionItem(
            record.previousItem,
          );
      await ref.read(revisionItemsProvider.notifier).refresh();
      state = state.copyWith(
        isSaving: false,
        activeItemId: null,
        lastUndo: null,
      );
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        isSaving: false,
        activeItemId: null,
        error: error,
      );
      return false;
    }
  }

  /// Deletes a revision item permanently.
  Future<bool> deleteItem(String id) async {
    state = state.copyWith(isSaving: true, activeItemId: id, error: null);
    try {
      await ref.read(revisionItemRepositoryProvider).deleteRevisionItem(id);
      await ref.read(revisionItemsProvider.notifier).refresh();
      state = state.copyWith(
        isSaving: false,
        activeItemId: null,
        lastUndo: state.lastUndo?.previousItem.id == id ? null : state.lastUndo,
      );
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        isSaving: false,
        activeItemId: null,
        error: error,
      );
      return false;
    }
  }
}

/// Provides [RevisionController] for revision flagging and queue reviews.
final NotifierProvider<RevisionController, RevisionMutationState>
    revisionControllerProvider =
    NotifierProvider<RevisionController, RevisionMutationState>(
  RevisionController.new,
);
