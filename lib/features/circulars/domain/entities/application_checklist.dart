import 'package:flutter/foundation.dart' show immutable;

/// Individual steps tracked inside a circular's application checklist.
enum ApplicationChecklistItem {
  photo,
  certificates,
  feePaid,
  submitted,
  admitCardDownloaded,
}

/// Immutable checklist state tracking completion of key application tasks.
@immutable
class ApplicationChecklist {
  /// Creates an [ApplicationChecklist].
  const ApplicationChecklist({
    this.photo = false,
    this.certificates = false,
    this.feePaid = false,
    this.submitted = false,
    this.admitCardDownloaded = false,
  });

  /// Total number of tracked application checklist steps.
  static const int totalSteps = 5;

  /// Required passport-size photo / scanned signature prepared.
  final bool photo;

  /// Educational & quota/experience certificates ready.
  final bool certificates;

  /// Application fee payment completed.
  final bool feePaid;

  /// Online/offline application submitted.
  final bool submitted;

  /// Admit card downloaded and stored.
  final bool admitCardDownloaded;

  /// Number of completed checklist steps (0 to 5).
  int get completedCount {
    var count = 0;
    if (photo) count += 1;
    if (certificates) count += 1;
    if (feePaid) count += 1;
    if (submitted) count += 1;
    if (admitCardDownloaded) count += 1;
    return count;
  }

  /// Normalized completion fraction from `0.0` to `1.0`.
  double get progress => completedCount / totalSteps;

  /// Returns whether [item] is currently ticked.
  bool isChecked(ApplicationChecklistItem item) {
    return switch (item) {
      ApplicationChecklistItem.photo => photo,
      ApplicationChecklistItem.certificates => certificates,
      ApplicationChecklistItem.feePaid => feePaid,
      ApplicationChecklistItem.submitted => submitted,
      ApplicationChecklistItem.admitCardDownloaded => admitCardDownloaded,
    };
  }

  /// Returns a copy with [item] toggled to `!isChecked(item)`.
  ApplicationChecklist toggle(ApplicationChecklistItem item) {
    return setItem(item, checked: !isChecked(item));
  }

  /// Returns a copy with [item] explicitly updated to [checked].
  ApplicationChecklist setItem(
    ApplicationChecklistItem item, {
    required bool checked,
  }) {
    return switch (item) {
      ApplicationChecklistItem.photo => copyWith(photo: checked),
      ApplicationChecklistItem.certificates => copyWith(certificates: checked),
      ApplicationChecklistItem.feePaid => copyWith(feePaid: checked),
      ApplicationChecklistItem.submitted => copyWith(submitted: checked),
      ApplicationChecklistItem.admitCardDownloaded =>
        copyWith(admitCardDownloaded: checked),
    };
  }

  /// Returns a modified copy of this [ApplicationChecklist].
  ApplicationChecklist copyWith({
    bool? photo,
    bool? certificates,
    bool? feePaid,
    bool? submitted,
    bool? admitCardDownloaded,
  }) {
    return ApplicationChecklist(
      photo: photo ?? this.photo,
      certificates: certificates ?? this.certificates,
      feePaid: feePaid ?? this.feePaid,
      submitted: submitted ?? this.submitted,
      admitCardDownloaded: admitCardDownloaded ?? this.admitCardDownloaded,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApplicationChecklist &&
        other.photo == photo &&
        other.certificates == certificates &&
        other.feePaid == feePaid &&
        other.submitted == submitted &&
        other.admitCardDownloaded == admitCardDownloaded;
  }

  @override
  int get hashCode => Object.hash(
        photo,
        certificates,
        feePaid,
        submitted,
        admitCardDownloaded,
      );
}
