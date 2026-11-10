/// Sector categories matching `public.circulars.sector` check constraints.
enum CircularSector {
  government('government'),
  bcs('bcs'),
  bank('bank'),
  autonomous('autonomous'),
  private('private'),
  ngo('ngo'),
  defense('defense'),
  other('other');

  const CircularSector(this.value);

  /// Database string value persisted in PostgreSQL.
  final String value;

  /// Parses [raw] into a [CircularSector], or returns `null` when unknown.
  static CircularSector? tryParse(String? raw) {
    if (raw == null) return null;
    for (final item in CircularSector.values) {
      if (item.value == raw) return item;
    }
    return null;
  }

  /// Parses [raw] into a [CircularSector], falling back to [fallback].
  static CircularSector fromValue(
    String? raw, {
    CircularSector fallback = CircularSector.government,
  }) {
    return tryParse(raw) ?? fallback;
  }
}

/// Application status values matching `public.circulars.application_status`.
enum ApplicationStatus {
  notApplied('not_applied'),
  inProgress('in_progress'),
  applied('applied'),
  feePaid('fee_paid'),
  exempt('exempt'),
  missed('missed'),
  notApplicable('not_applicable');

  const ApplicationStatus(this.value);

  /// Database string value persisted in PostgreSQL.
  final String value;

  /// Parses [raw] into an [ApplicationStatus], or returns `null` when unknown.
  static ApplicationStatus? tryParse(String? raw) {
    if (raw == null) return null;
    for (final item in ApplicationStatus.values) {
      if (item.value == raw) return item;
    }
    return null;
  }

  /// Parses [raw] into an [ApplicationStatus], falling back to [fallback].
  static ApplicationStatus fromValue(
    String? raw, {
    ApplicationStatus fallback = ApplicationStatus.notApplied,
  }) {
    return tryParse(raw) ?? fallback;
  }
}

/// Admit card states matching `public.circulars.admit_card_status`.
enum AdmitCardStatus {
  notAvailable('not_available'),
  available('available'),
  downloaded('downloaded'),
  notApplicable('not_applicable');

  const AdmitCardStatus(this.value);

  /// Database string value persisted in PostgreSQL.
  final String value;

  /// Parses [raw] into an [AdmitCardStatus], or returns `null` when unknown.
  static AdmitCardStatus? tryParse(String? raw) {
    if (raw == null) return null;
    for (final item in AdmitCardStatus.values) {
      if (item.value == raw) return item;
    }
    return null;
  }

  /// Parses [raw] into an [AdmitCardStatus], falling back to [fallback].
  static AdmitCardStatus fromValue(
    String? raw, {
    AdmitCardStatus fallback = AdmitCardStatus.notAvailable,
  }) {
    return tryParse(raw) ?? fallback;
  }
}

/// Priority levels matching `public.circulars.priority`.
enum CircularPriority {
  low('low', 0),
  medium('medium', 1),
  high('high', 2),
  urgent('urgent', 3);

  const CircularPriority(this.value, this.weight);

  /// Database string value persisted in PostgreSQL.
  final String value;

  /// Numeric weight used when sorting circulars by priority.
  final int weight;

  /// Parses [raw] into a [CircularPriority], or returns `null` when unknown.
  static CircularPriority? tryParse(String? raw) {
    if (raw == null) return null;
    for (final item in CircularPriority.values) {
      if (item.value == raw) return item;
    }
    return null;
  }

  /// Parses [raw] into a [CircularPriority], falling back to [fallback].
  static CircularPriority fromValue(
    String? raw, {
    CircularPriority fallback = CircularPriority.medium,
  }) {
    return tryParse(raw) ?? fallback;
  }
}

/// Workflow lifecycle statuses matching `public.circulars.workflow_status`.
enum CircularWorkflowStatus {
  saved('saved'),
  preparing('preparing'),
  applied('applied'),
  examUpcoming('exam_upcoming'),
  resultAwaited('result_awaited'),
  archived('archived');

  const CircularWorkflowStatus(this.value);

  /// Database string value persisted in PostgreSQL.
  final String value;

  /// Parses [raw] into a [CircularWorkflowStatus], or returns `null`.
  static CircularWorkflowStatus? tryParse(String? raw) {
    if (raw == null) return null;
    for (final item in CircularWorkflowStatus.values) {
      if (item.value == raw) return item;
    }
    return null;
  }

  /// Parses [raw] into a [CircularWorkflowStatus], falling back to [fallback].
  static CircularWorkflowStatus fromValue(
    String? raw, {
    CircularWorkflowStatus fallback = CircularWorkflowStatus.saved,
  }) {
    return tryParse(raw) ?? fallback;
  }
}

/// Sorting options supported by circular list views and filters.
enum CircularSortOption {
  deadlineAsc,
  updatedDesc,
  priorityDesc,
  titleAsc,
}
