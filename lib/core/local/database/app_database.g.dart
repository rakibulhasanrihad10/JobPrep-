// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalCircularsTable extends LocalCirculars
    with TableInfo<$LocalCircularsTable, LocalCircular> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCircularsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sectorMeta = const VerificationMeta('sector');
  @override
  late final GeneratedColumn<String> sector = GeneratedColumn<String>(
      'sector', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('government'));
  static const VerificationMeta _organizationNameMeta =
      const VerificationMeta('organizationName');
  @override
  late final GeneratedColumn<String> organizationName = GeneratedColumn<String>(
      'organization_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _organizationWebsiteMeta =
      const VerificationMeta('organizationWebsite');
  @override
  late final GeneratedColumn<String> organizationWebsite =
      GeneratedColumn<String>('organization_website', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _circularUrlMeta =
      const VerificationMeta('circularUrl');
  @override
  late final GeneratedColumn<String> circularUrl = GeneratedColumn<String>(
      'circular_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _applicationUrlMeta =
      const VerificationMeta('applicationUrl');
  @override
  late final GeneratedColumn<String> applicationUrl = GeneratedColumn<String>(
      'application_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deadlineMeta =
      const VerificationMeta('deadline');
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
      'deadline', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _vacanciesMeta =
      const VerificationMeta('vacancies');
  @override
  late final GeneratedColumn<int> vacancies = GeneratedColumn<int>(
      'vacancies', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _salaryMinMeta =
      const VerificationMeta('salaryMin');
  @override
  late final GeneratedColumn<double> salaryMin = GeneratedColumn<double>(
      'salary_min', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _salaryMaxMeta =
      const VerificationMeta('salaryMax');
  @override
  late final GeneratedColumn<double> salaryMax = GeneratedColumn<double>(
      'salary_max', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _salaryNoteMeta =
      const VerificationMeta('salaryNote');
  @override
  late final GeneratedColumn<String> salaryNote = GeneratedColumn<String>(
      'salary_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _applicationFeeMeta =
      const VerificationMeta('applicationFee');
  @override
  late final GeneratedColumn<double> applicationFee = GeneratedColumn<double>(
      'application_fee', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _feeNoteMeta =
      const VerificationMeta('feeNote');
  @override
  late final GeneratedColumn<String> feeNote = GeneratedColumn<String>(
      'fee_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _applicationStatusMeta =
      const VerificationMeta('applicationStatus');
  @override
  late final GeneratedColumn<String> applicationStatus =
      GeneratedColumn<String>('application_status', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('not_applied'));
  static const VerificationMeta _admitCardStatusMeta =
      const VerificationMeta('admitCardStatus');
  @override
  late final GeneratedColumn<String> admitCardStatus = GeneratedColumn<String>(
      'admit_card_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('not_available'));
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('medium'));
  static const VerificationMeta _workflowStatusMeta =
      const VerificationMeta('workflowStatus');
  @override
  late final GeneratedColumn<String> workflowStatus = GeneratedColumn<String>(
      'workflow_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('saved'));
  static const VerificationMeta _instructionsMeta =
      const VerificationMeta('instructions');
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
      'instructions', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syllabusMeta =
      const VerificationMeta('syllabus');
  @override
  late final GeneratedColumn<String> syllabus = GeneratedColumn<String>(
      'syllabus', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isQuickCaptureMeta =
      const VerificationMeta('isQuickCapture');
  @override
  late final GeneratedColumn<bool> isQuickCapture = GeneratedColumn<bool>(
      'is_quick_capture', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_quick_capture" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _checklistPhotoMeta =
      const VerificationMeta('checklistPhoto');
  @override
  late final GeneratedColumn<bool> checklistPhoto = GeneratedColumn<bool>(
      'checklist_photo', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("checklist_photo" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _checklistCertificatesMeta =
      const VerificationMeta('checklistCertificates');
  @override
  late final GeneratedColumn<bool> checklistCertificates =
      GeneratedColumn<bool>('checklist_certificates', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("checklist_certificates" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _checklistFeePaidMeta =
      const VerificationMeta('checklistFeePaid');
  @override
  late final GeneratedColumn<bool> checklistFeePaid = GeneratedColumn<bool>(
      'checklist_fee_paid', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("checklist_fee_paid" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _checklistSubmittedMeta =
      const VerificationMeta('checklistSubmitted');
  @override
  late final GeneratedColumn<bool> checklistSubmitted = GeneratedColumn<bool>(
      'checklist_submitted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("checklist_submitted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _checklistAdmitCardDownloadedMeta =
      const VerificationMeta('checklistAdmitCardDownloaded');
  @override
  late final GeneratedColumn<bool> checklistAdmitCardDownloaded =
      GeneratedColumn<bool>(
          'checklist_admit_card_downloaded', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("checklist_admit_card_downloaded" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        sector,
        organizationName,
        organizationWebsite,
        circularUrl,
        applicationUrl,
        deadline,
        vacancies,
        salaryMin,
        salaryMax,
        salaryNote,
        applicationFee,
        feeNote,
        applicationStatus,
        admitCardStatus,
        priority,
        workflowStatus,
        instructions,
        notes,
        syllabus,
        isQuickCapture,
        checklistPhoto,
        checklistCertificates,
        checklistFeePaid,
        checklistSubmitted,
        checklistAdmitCardDownloaded,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'circulars';
  @override
  VerificationContext validateIntegrity(Insertable<LocalCircular> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('sector')) {
      context.handle(_sectorMeta,
          sector.isAcceptableOrUnknown(data['sector']!, _sectorMeta));
    }
    if (data.containsKey('organization_name')) {
      context.handle(
          _organizationNameMeta,
          organizationName.isAcceptableOrUnknown(
              data['organization_name']!, _organizationNameMeta));
    }
    if (data.containsKey('organization_website')) {
      context.handle(
          _organizationWebsiteMeta,
          organizationWebsite.isAcceptableOrUnknown(
              data['organization_website']!, _organizationWebsiteMeta));
    }
    if (data.containsKey('circular_url')) {
      context.handle(
          _circularUrlMeta,
          circularUrl.isAcceptableOrUnknown(
              data['circular_url']!, _circularUrlMeta));
    }
    if (data.containsKey('application_url')) {
      context.handle(
          _applicationUrlMeta,
          applicationUrl.isAcceptableOrUnknown(
              data['application_url']!, _applicationUrlMeta));
    }
    if (data.containsKey('deadline')) {
      context.handle(_deadlineMeta,
          deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta));
    }
    if (data.containsKey('vacancies')) {
      context.handle(_vacanciesMeta,
          vacancies.isAcceptableOrUnknown(data['vacancies']!, _vacanciesMeta));
    }
    if (data.containsKey('salary_min')) {
      context.handle(_salaryMinMeta,
          salaryMin.isAcceptableOrUnknown(data['salary_min']!, _salaryMinMeta));
    }
    if (data.containsKey('salary_max')) {
      context.handle(_salaryMaxMeta,
          salaryMax.isAcceptableOrUnknown(data['salary_max']!, _salaryMaxMeta));
    }
    if (data.containsKey('salary_note')) {
      context.handle(
          _salaryNoteMeta,
          salaryNote.isAcceptableOrUnknown(
              data['salary_note']!, _salaryNoteMeta));
    }
    if (data.containsKey('application_fee')) {
      context.handle(
          _applicationFeeMeta,
          applicationFee.isAcceptableOrUnknown(
              data['application_fee']!, _applicationFeeMeta));
    }
    if (data.containsKey('fee_note')) {
      context.handle(_feeNoteMeta,
          feeNote.isAcceptableOrUnknown(data['fee_note']!, _feeNoteMeta));
    }
    if (data.containsKey('application_status')) {
      context.handle(
          _applicationStatusMeta,
          applicationStatus.isAcceptableOrUnknown(
              data['application_status']!, _applicationStatusMeta));
    }
    if (data.containsKey('admit_card_status')) {
      context.handle(
          _admitCardStatusMeta,
          admitCardStatus.isAcceptableOrUnknown(
              data['admit_card_status']!, _admitCardStatusMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('workflow_status')) {
      context.handle(
          _workflowStatusMeta,
          workflowStatus.isAcceptableOrUnknown(
              data['workflow_status']!, _workflowStatusMeta));
    }
    if (data.containsKey('instructions')) {
      context.handle(
          _instructionsMeta,
          instructions.isAcceptableOrUnknown(
              data['instructions']!, _instructionsMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('syllabus')) {
      context.handle(_syllabusMeta,
          syllabus.isAcceptableOrUnknown(data['syllabus']!, _syllabusMeta));
    }
    if (data.containsKey('is_quick_capture')) {
      context.handle(
          _isQuickCaptureMeta,
          isQuickCapture.isAcceptableOrUnknown(
              data['is_quick_capture']!, _isQuickCaptureMeta));
    }
    if (data.containsKey('checklist_photo')) {
      context.handle(
          _checklistPhotoMeta,
          checklistPhoto.isAcceptableOrUnknown(
              data['checklist_photo']!, _checklistPhotoMeta));
    }
    if (data.containsKey('checklist_certificates')) {
      context.handle(
          _checklistCertificatesMeta,
          checklistCertificates.isAcceptableOrUnknown(
              data['checklist_certificates']!, _checklistCertificatesMeta));
    }
    if (data.containsKey('checklist_fee_paid')) {
      context.handle(
          _checklistFeePaidMeta,
          checklistFeePaid.isAcceptableOrUnknown(
              data['checklist_fee_paid']!, _checklistFeePaidMeta));
    }
    if (data.containsKey('checklist_submitted')) {
      context.handle(
          _checklistSubmittedMeta,
          checklistSubmitted.isAcceptableOrUnknown(
              data['checklist_submitted']!, _checklistSubmittedMeta));
    }
    if (data.containsKey('checklist_admit_card_downloaded')) {
      context.handle(
          _checklistAdmitCardDownloadedMeta,
          checklistAdmitCardDownloaded.isAcceptableOrUnknown(
              data['checklist_admit_card_downloaded']!,
              _checklistAdmitCardDownloadedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCircular map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCircular(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      sector: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sector'])!,
      organizationName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}organization_name']),
      organizationWebsite: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}organization_website']),
      circularUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}circular_url']),
      applicationUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}application_url']),
      deadline: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deadline']),
      vacancies: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vacancies']),
      salaryMin: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}salary_min']),
      salaryMax: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}salary_max']),
      salaryNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}salary_note']),
      applicationFee: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}application_fee']),
      feeNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fee_note']),
      applicationStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}application_status'])!,
      admitCardStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}admit_card_status'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      workflowStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}workflow_status'])!,
      instructions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instructions']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      syllabus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}syllabus']),
      isQuickCapture: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_quick_capture'])!,
      checklistPhoto: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}checklist_photo'])!,
      checklistCertificates: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}checklist_certificates'])!,
      checklistFeePaid: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}checklist_fee_paid'])!,
      checklistSubmitted: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}checklist_submitted'])!,
      checklistAdmitCardDownloaded: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}checklist_admit_card_downloaded'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $LocalCircularsTable createAlias(String alias) {
    return $LocalCircularsTable(attachedDatabase, alias);
  }
}

class LocalCircular extends DataClass implements Insertable<LocalCircular> {
  /// Primary key UUID.
  final String id;

  /// Job circular title or designation name.
  final String title;

  /// Employment sector category (`government`, `bank`, `private`, etc.).
  final String sector;

  /// Hiring organization or department.
  final String? organizationName;

  /// Official website of the recruiting entity.
  final String? organizationWebsite;

  /// Original circular notice URL.
  final String? circularUrl;

  /// Online application submission URL.
  final String? applicationUrl;

  /// Application deadline timestamp.
  final DateTime? deadline;

  /// Number of published vacancies.
  final int? vacancies;

  /// Minimum monthly salary or grade.
  final double? salaryMin;

  /// Maximum monthly salary or grade.
  final double? salaryMax;

  /// Additional salary scale notes.
  final String? salaryNote;

  /// Required application fee.
  final double? applicationFee;

  /// Fee payment instructions or notes.
  final String? feeNote;

  /// Current application progression stage.
  final String applicationStatus;

  /// Admit card availability status.
  final String admitCardStatus;

  /// User priority level (`low`, `medium`, `high`, `urgent`).
  final String priority;

  /// Workflow queue status (`inbox`, `saved`, `applied`, `archived`).
  final String workflowStatus;

  /// Application instructions or requirements.
  final String? instructions;

  /// User personal notes.
  final String? notes;

  /// Syllabus outline.
  final String? syllabus;

  /// Whether created via one-tap Quick Capture.
  final bool isQuickCapture;

  /// Checklist: photo prepared.
  final bool checklistPhoto;

  /// Checklist: certificates gathered.
  final bool checklistCertificates;

  /// Checklist: application fee paid.
  final bool checklistFeePaid;

  /// Checklist: application submitted.
  final bool checklistSubmitted;

  /// Checklist: admit card downloaded.
  final bool checklistAdmitCardDownloaded;

  /// Creation timestamp.
  final DateTime? createdAt;

  /// Last modification timestamp.
  final DateTime? updatedAt;
  const LocalCircular(
      {required this.id,
      required this.title,
      required this.sector,
      this.organizationName,
      this.organizationWebsite,
      this.circularUrl,
      this.applicationUrl,
      this.deadline,
      this.vacancies,
      this.salaryMin,
      this.salaryMax,
      this.salaryNote,
      this.applicationFee,
      this.feeNote,
      required this.applicationStatus,
      required this.admitCardStatus,
      required this.priority,
      required this.workflowStatus,
      this.instructions,
      this.notes,
      this.syllabus,
      required this.isQuickCapture,
      required this.checklistPhoto,
      required this.checklistCertificates,
      required this.checklistFeePaid,
      required this.checklistSubmitted,
      required this.checklistAdmitCardDownloaded,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['sector'] = Variable<String>(sector);
    if (!nullToAbsent || organizationName != null) {
      map['organization_name'] = Variable<String>(organizationName);
    }
    if (!nullToAbsent || organizationWebsite != null) {
      map['organization_website'] = Variable<String>(organizationWebsite);
    }
    if (!nullToAbsent || circularUrl != null) {
      map['circular_url'] = Variable<String>(circularUrl);
    }
    if (!nullToAbsent || applicationUrl != null) {
      map['application_url'] = Variable<String>(applicationUrl);
    }
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    if (!nullToAbsent || vacancies != null) {
      map['vacancies'] = Variable<int>(vacancies);
    }
    if (!nullToAbsent || salaryMin != null) {
      map['salary_min'] = Variable<double>(salaryMin);
    }
    if (!nullToAbsent || salaryMax != null) {
      map['salary_max'] = Variable<double>(salaryMax);
    }
    if (!nullToAbsent || salaryNote != null) {
      map['salary_note'] = Variable<String>(salaryNote);
    }
    if (!nullToAbsent || applicationFee != null) {
      map['application_fee'] = Variable<double>(applicationFee);
    }
    if (!nullToAbsent || feeNote != null) {
      map['fee_note'] = Variable<String>(feeNote);
    }
    map['application_status'] = Variable<String>(applicationStatus);
    map['admit_card_status'] = Variable<String>(admitCardStatus);
    map['priority'] = Variable<String>(priority);
    map['workflow_status'] = Variable<String>(workflowStatus);
    if (!nullToAbsent || instructions != null) {
      map['instructions'] = Variable<String>(instructions);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || syllabus != null) {
      map['syllabus'] = Variable<String>(syllabus);
    }
    map['is_quick_capture'] = Variable<bool>(isQuickCapture);
    map['checklist_photo'] = Variable<bool>(checklistPhoto);
    map['checklist_certificates'] = Variable<bool>(checklistCertificates);
    map['checklist_fee_paid'] = Variable<bool>(checklistFeePaid);
    map['checklist_submitted'] = Variable<bool>(checklistSubmitted);
    map['checklist_admit_card_downloaded'] =
        Variable<bool>(checklistAdmitCardDownloaded);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  LocalCircularsCompanion toCompanion(bool nullToAbsent) {
    return LocalCircularsCompanion(
      id: Value(id),
      title: Value(title),
      sector: Value(sector),
      organizationName: organizationName == null && nullToAbsent
          ? const Value.absent()
          : Value(organizationName),
      organizationWebsite: organizationWebsite == null && nullToAbsent
          ? const Value.absent()
          : Value(organizationWebsite),
      circularUrl: circularUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(circularUrl),
      applicationUrl: applicationUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(applicationUrl),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      vacancies: vacancies == null && nullToAbsent
          ? const Value.absent()
          : Value(vacancies),
      salaryMin: salaryMin == null && nullToAbsent
          ? const Value.absent()
          : Value(salaryMin),
      salaryMax: salaryMax == null && nullToAbsent
          ? const Value.absent()
          : Value(salaryMax),
      salaryNote: salaryNote == null && nullToAbsent
          ? const Value.absent()
          : Value(salaryNote),
      applicationFee: applicationFee == null && nullToAbsent
          ? const Value.absent()
          : Value(applicationFee),
      feeNote: feeNote == null && nullToAbsent
          ? const Value.absent()
          : Value(feeNote),
      applicationStatus: Value(applicationStatus),
      admitCardStatus: Value(admitCardStatus),
      priority: Value(priority),
      workflowStatus: Value(workflowStatus),
      instructions: instructions == null && nullToAbsent
          ? const Value.absent()
          : Value(instructions),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      syllabus: syllabus == null && nullToAbsent
          ? const Value.absent()
          : Value(syllabus),
      isQuickCapture: Value(isQuickCapture),
      checklistPhoto: Value(checklistPhoto),
      checklistCertificates: Value(checklistCertificates),
      checklistFeePaid: Value(checklistFeePaid),
      checklistSubmitted: Value(checklistSubmitted),
      checklistAdmitCardDownloaded: Value(checklistAdmitCardDownloaded),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalCircular.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCircular(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      sector: serializer.fromJson<String>(json['sector']),
      organizationName: serializer.fromJson<String?>(json['organizationName']),
      organizationWebsite:
          serializer.fromJson<String?>(json['organizationWebsite']),
      circularUrl: serializer.fromJson<String?>(json['circularUrl']),
      applicationUrl: serializer.fromJson<String?>(json['applicationUrl']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      vacancies: serializer.fromJson<int?>(json['vacancies']),
      salaryMin: serializer.fromJson<double?>(json['salaryMin']),
      salaryMax: serializer.fromJson<double?>(json['salaryMax']),
      salaryNote: serializer.fromJson<String?>(json['salaryNote']),
      applicationFee: serializer.fromJson<double?>(json['applicationFee']),
      feeNote: serializer.fromJson<String?>(json['feeNote']),
      applicationStatus: serializer.fromJson<String>(json['applicationStatus']),
      admitCardStatus: serializer.fromJson<String>(json['admitCardStatus']),
      priority: serializer.fromJson<String>(json['priority']),
      workflowStatus: serializer.fromJson<String>(json['workflowStatus']),
      instructions: serializer.fromJson<String?>(json['instructions']),
      notes: serializer.fromJson<String?>(json['notes']),
      syllabus: serializer.fromJson<String?>(json['syllabus']),
      isQuickCapture: serializer.fromJson<bool>(json['isQuickCapture']),
      checklistPhoto: serializer.fromJson<bool>(json['checklistPhoto']),
      checklistCertificates:
          serializer.fromJson<bool>(json['checklistCertificates']),
      checklistFeePaid: serializer.fromJson<bool>(json['checklistFeePaid']),
      checklistSubmitted: serializer.fromJson<bool>(json['checklistSubmitted']),
      checklistAdmitCardDownloaded:
          serializer.fromJson<bool>(json['checklistAdmitCardDownloaded']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'sector': serializer.toJson<String>(sector),
      'organizationName': serializer.toJson<String?>(organizationName),
      'organizationWebsite': serializer.toJson<String?>(organizationWebsite),
      'circularUrl': serializer.toJson<String?>(circularUrl),
      'applicationUrl': serializer.toJson<String?>(applicationUrl),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'vacancies': serializer.toJson<int?>(vacancies),
      'salaryMin': serializer.toJson<double?>(salaryMin),
      'salaryMax': serializer.toJson<double?>(salaryMax),
      'salaryNote': serializer.toJson<String?>(salaryNote),
      'applicationFee': serializer.toJson<double?>(applicationFee),
      'feeNote': serializer.toJson<String?>(feeNote),
      'applicationStatus': serializer.toJson<String>(applicationStatus),
      'admitCardStatus': serializer.toJson<String>(admitCardStatus),
      'priority': serializer.toJson<String>(priority),
      'workflowStatus': serializer.toJson<String>(workflowStatus),
      'instructions': serializer.toJson<String?>(instructions),
      'notes': serializer.toJson<String?>(notes),
      'syllabus': serializer.toJson<String?>(syllabus),
      'isQuickCapture': serializer.toJson<bool>(isQuickCapture),
      'checklistPhoto': serializer.toJson<bool>(checklistPhoto),
      'checklistCertificates': serializer.toJson<bool>(checklistCertificates),
      'checklistFeePaid': serializer.toJson<bool>(checklistFeePaid),
      'checklistSubmitted': serializer.toJson<bool>(checklistSubmitted),
      'checklistAdmitCardDownloaded':
          serializer.toJson<bool>(checklistAdmitCardDownloaded),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  LocalCircular copyWith(
          {String? id,
          String? title,
          String? sector,
          Value<String?> organizationName = const Value.absent(),
          Value<String?> organizationWebsite = const Value.absent(),
          Value<String?> circularUrl = const Value.absent(),
          Value<String?> applicationUrl = const Value.absent(),
          Value<DateTime?> deadline = const Value.absent(),
          Value<int?> vacancies = const Value.absent(),
          Value<double?> salaryMin = const Value.absent(),
          Value<double?> salaryMax = const Value.absent(),
          Value<String?> salaryNote = const Value.absent(),
          Value<double?> applicationFee = const Value.absent(),
          Value<String?> feeNote = const Value.absent(),
          String? applicationStatus,
          String? admitCardStatus,
          String? priority,
          String? workflowStatus,
          Value<String?> instructions = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<String?> syllabus = const Value.absent(),
          bool? isQuickCapture,
          bool? checklistPhoto,
          bool? checklistCertificates,
          bool? checklistFeePaid,
          bool? checklistSubmitted,
          bool? checklistAdmitCardDownloaded,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      LocalCircular(
        id: id ?? this.id,
        title: title ?? this.title,
        sector: sector ?? this.sector,
        organizationName: organizationName.present
            ? organizationName.value
            : this.organizationName,
        organizationWebsite: organizationWebsite.present
            ? organizationWebsite.value
            : this.organizationWebsite,
        circularUrl: circularUrl.present ? circularUrl.value : this.circularUrl,
        applicationUrl:
            applicationUrl.present ? applicationUrl.value : this.applicationUrl,
        deadline: deadline.present ? deadline.value : this.deadline,
        vacancies: vacancies.present ? vacancies.value : this.vacancies,
        salaryMin: salaryMin.present ? salaryMin.value : this.salaryMin,
        salaryMax: salaryMax.present ? salaryMax.value : this.salaryMax,
        salaryNote: salaryNote.present ? salaryNote.value : this.salaryNote,
        applicationFee:
            applicationFee.present ? applicationFee.value : this.applicationFee,
        feeNote: feeNote.present ? feeNote.value : this.feeNote,
        applicationStatus: applicationStatus ?? this.applicationStatus,
        admitCardStatus: admitCardStatus ?? this.admitCardStatus,
        priority: priority ?? this.priority,
        workflowStatus: workflowStatus ?? this.workflowStatus,
        instructions:
            instructions.present ? instructions.value : this.instructions,
        notes: notes.present ? notes.value : this.notes,
        syllabus: syllabus.present ? syllabus.value : this.syllabus,
        isQuickCapture: isQuickCapture ?? this.isQuickCapture,
        checklistPhoto: checklistPhoto ?? this.checklistPhoto,
        checklistCertificates:
            checklistCertificates ?? this.checklistCertificates,
        checklistFeePaid: checklistFeePaid ?? this.checklistFeePaid,
        checklistSubmitted: checklistSubmitted ?? this.checklistSubmitted,
        checklistAdmitCardDownloaded:
            checklistAdmitCardDownloaded ?? this.checklistAdmitCardDownloaded,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  LocalCircular copyWithCompanion(LocalCircularsCompanion data) {
    return LocalCircular(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      sector: data.sector.present ? data.sector.value : this.sector,
      organizationName: data.organizationName.present
          ? data.organizationName.value
          : this.organizationName,
      organizationWebsite: data.organizationWebsite.present
          ? data.organizationWebsite.value
          : this.organizationWebsite,
      circularUrl:
          data.circularUrl.present ? data.circularUrl.value : this.circularUrl,
      applicationUrl: data.applicationUrl.present
          ? data.applicationUrl.value
          : this.applicationUrl,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      vacancies: data.vacancies.present ? data.vacancies.value : this.vacancies,
      salaryMin: data.salaryMin.present ? data.salaryMin.value : this.salaryMin,
      salaryMax: data.salaryMax.present ? data.salaryMax.value : this.salaryMax,
      salaryNote:
          data.salaryNote.present ? data.salaryNote.value : this.salaryNote,
      applicationFee: data.applicationFee.present
          ? data.applicationFee.value
          : this.applicationFee,
      feeNote: data.feeNote.present ? data.feeNote.value : this.feeNote,
      applicationStatus: data.applicationStatus.present
          ? data.applicationStatus.value
          : this.applicationStatus,
      admitCardStatus: data.admitCardStatus.present
          ? data.admitCardStatus.value
          : this.admitCardStatus,
      priority: data.priority.present ? data.priority.value : this.priority,
      workflowStatus: data.workflowStatus.present
          ? data.workflowStatus.value
          : this.workflowStatus,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
      notes: data.notes.present ? data.notes.value : this.notes,
      syllabus: data.syllabus.present ? data.syllabus.value : this.syllabus,
      isQuickCapture: data.isQuickCapture.present
          ? data.isQuickCapture.value
          : this.isQuickCapture,
      checklistPhoto: data.checklistPhoto.present
          ? data.checklistPhoto.value
          : this.checklistPhoto,
      checklistCertificates: data.checklistCertificates.present
          ? data.checklistCertificates.value
          : this.checklistCertificates,
      checklistFeePaid: data.checklistFeePaid.present
          ? data.checklistFeePaid.value
          : this.checklistFeePaid,
      checklistSubmitted: data.checklistSubmitted.present
          ? data.checklistSubmitted.value
          : this.checklistSubmitted,
      checklistAdmitCardDownloaded: data.checklistAdmitCardDownloaded.present
          ? data.checklistAdmitCardDownloaded.value
          : this.checklistAdmitCardDownloaded,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCircular(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sector: $sector, ')
          ..write('organizationName: $organizationName, ')
          ..write('organizationWebsite: $organizationWebsite, ')
          ..write('circularUrl: $circularUrl, ')
          ..write('applicationUrl: $applicationUrl, ')
          ..write('deadline: $deadline, ')
          ..write('vacancies: $vacancies, ')
          ..write('salaryMin: $salaryMin, ')
          ..write('salaryMax: $salaryMax, ')
          ..write('salaryNote: $salaryNote, ')
          ..write('applicationFee: $applicationFee, ')
          ..write('feeNote: $feeNote, ')
          ..write('applicationStatus: $applicationStatus, ')
          ..write('admitCardStatus: $admitCardStatus, ')
          ..write('priority: $priority, ')
          ..write('workflowStatus: $workflowStatus, ')
          ..write('instructions: $instructions, ')
          ..write('notes: $notes, ')
          ..write('syllabus: $syllabus, ')
          ..write('isQuickCapture: $isQuickCapture, ')
          ..write('checklistPhoto: $checklistPhoto, ')
          ..write('checklistCertificates: $checklistCertificates, ')
          ..write('checklistFeePaid: $checklistFeePaid, ')
          ..write('checklistSubmitted: $checklistSubmitted, ')
          ..write(
              'checklistAdmitCardDownloaded: $checklistAdmitCardDownloaded, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        title,
        sector,
        organizationName,
        organizationWebsite,
        circularUrl,
        applicationUrl,
        deadline,
        vacancies,
        salaryMin,
        salaryMax,
        salaryNote,
        applicationFee,
        feeNote,
        applicationStatus,
        admitCardStatus,
        priority,
        workflowStatus,
        instructions,
        notes,
        syllabus,
        isQuickCapture,
        checklistPhoto,
        checklistCertificates,
        checklistFeePaid,
        checklistSubmitted,
        checklistAdmitCardDownloaded,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCircular &&
          other.id == this.id &&
          other.title == this.title &&
          other.sector == this.sector &&
          other.organizationName == this.organizationName &&
          other.organizationWebsite == this.organizationWebsite &&
          other.circularUrl == this.circularUrl &&
          other.applicationUrl == this.applicationUrl &&
          other.deadline == this.deadline &&
          other.vacancies == this.vacancies &&
          other.salaryMin == this.salaryMin &&
          other.salaryMax == this.salaryMax &&
          other.salaryNote == this.salaryNote &&
          other.applicationFee == this.applicationFee &&
          other.feeNote == this.feeNote &&
          other.applicationStatus == this.applicationStatus &&
          other.admitCardStatus == this.admitCardStatus &&
          other.priority == this.priority &&
          other.workflowStatus == this.workflowStatus &&
          other.instructions == this.instructions &&
          other.notes == this.notes &&
          other.syllabus == this.syllabus &&
          other.isQuickCapture == this.isQuickCapture &&
          other.checklistPhoto == this.checklistPhoto &&
          other.checklistCertificates == this.checklistCertificates &&
          other.checklistFeePaid == this.checklistFeePaid &&
          other.checklistSubmitted == this.checklistSubmitted &&
          other.checklistAdmitCardDownloaded ==
              this.checklistAdmitCardDownloaded &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalCircularsCompanion extends UpdateCompanion<LocalCircular> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> sector;
  final Value<String?> organizationName;
  final Value<String?> organizationWebsite;
  final Value<String?> circularUrl;
  final Value<String?> applicationUrl;
  final Value<DateTime?> deadline;
  final Value<int?> vacancies;
  final Value<double?> salaryMin;
  final Value<double?> salaryMax;
  final Value<String?> salaryNote;
  final Value<double?> applicationFee;
  final Value<String?> feeNote;
  final Value<String> applicationStatus;
  final Value<String> admitCardStatus;
  final Value<String> priority;
  final Value<String> workflowStatus;
  final Value<String?> instructions;
  final Value<String?> notes;
  final Value<String?> syllabus;
  final Value<bool> isQuickCapture;
  final Value<bool> checklistPhoto;
  final Value<bool> checklistCertificates;
  final Value<bool> checklistFeePaid;
  final Value<bool> checklistSubmitted;
  final Value<bool> checklistAdmitCardDownloaded;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const LocalCircularsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.sector = const Value.absent(),
    this.organizationName = const Value.absent(),
    this.organizationWebsite = const Value.absent(),
    this.circularUrl = const Value.absent(),
    this.applicationUrl = const Value.absent(),
    this.deadline = const Value.absent(),
    this.vacancies = const Value.absent(),
    this.salaryMin = const Value.absent(),
    this.salaryMax = const Value.absent(),
    this.salaryNote = const Value.absent(),
    this.applicationFee = const Value.absent(),
    this.feeNote = const Value.absent(),
    this.applicationStatus = const Value.absent(),
    this.admitCardStatus = const Value.absent(),
    this.priority = const Value.absent(),
    this.workflowStatus = const Value.absent(),
    this.instructions = const Value.absent(),
    this.notes = const Value.absent(),
    this.syllabus = const Value.absent(),
    this.isQuickCapture = const Value.absent(),
    this.checklistPhoto = const Value.absent(),
    this.checklistCertificates = const Value.absent(),
    this.checklistFeePaid = const Value.absent(),
    this.checklistSubmitted = const Value.absent(),
    this.checklistAdmitCardDownloaded = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCircularsCompanion.insert({
    required String id,
    required String title,
    this.sector = const Value.absent(),
    this.organizationName = const Value.absent(),
    this.organizationWebsite = const Value.absent(),
    this.circularUrl = const Value.absent(),
    this.applicationUrl = const Value.absent(),
    this.deadline = const Value.absent(),
    this.vacancies = const Value.absent(),
    this.salaryMin = const Value.absent(),
    this.salaryMax = const Value.absent(),
    this.salaryNote = const Value.absent(),
    this.applicationFee = const Value.absent(),
    this.feeNote = const Value.absent(),
    this.applicationStatus = const Value.absent(),
    this.admitCardStatus = const Value.absent(),
    this.priority = const Value.absent(),
    this.workflowStatus = const Value.absent(),
    this.instructions = const Value.absent(),
    this.notes = const Value.absent(),
    this.syllabus = const Value.absent(),
    this.isQuickCapture = const Value.absent(),
    this.checklistPhoto = const Value.absent(),
    this.checklistCertificates = const Value.absent(),
    this.checklistFeePaid = const Value.absent(),
    this.checklistSubmitted = const Value.absent(),
    this.checklistAdmitCardDownloaded = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title);
  static Insertable<LocalCircular> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? sector,
    Expression<String>? organizationName,
    Expression<String>? organizationWebsite,
    Expression<String>? circularUrl,
    Expression<String>? applicationUrl,
    Expression<DateTime>? deadline,
    Expression<int>? vacancies,
    Expression<double>? salaryMin,
    Expression<double>? salaryMax,
    Expression<String>? salaryNote,
    Expression<double>? applicationFee,
    Expression<String>? feeNote,
    Expression<String>? applicationStatus,
    Expression<String>? admitCardStatus,
    Expression<String>? priority,
    Expression<String>? workflowStatus,
    Expression<String>? instructions,
    Expression<String>? notes,
    Expression<String>? syllabus,
    Expression<bool>? isQuickCapture,
    Expression<bool>? checklistPhoto,
    Expression<bool>? checklistCertificates,
    Expression<bool>? checklistFeePaid,
    Expression<bool>? checklistSubmitted,
    Expression<bool>? checklistAdmitCardDownloaded,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (sector != null) 'sector': sector,
      if (organizationName != null) 'organization_name': organizationName,
      if (organizationWebsite != null)
        'organization_website': organizationWebsite,
      if (circularUrl != null) 'circular_url': circularUrl,
      if (applicationUrl != null) 'application_url': applicationUrl,
      if (deadline != null) 'deadline': deadline,
      if (vacancies != null) 'vacancies': vacancies,
      if (salaryMin != null) 'salary_min': salaryMin,
      if (salaryMax != null) 'salary_max': salaryMax,
      if (salaryNote != null) 'salary_note': salaryNote,
      if (applicationFee != null) 'application_fee': applicationFee,
      if (feeNote != null) 'fee_note': feeNote,
      if (applicationStatus != null) 'application_status': applicationStatus,
      if (admitCardStatus != null) 'admit_card_status': admitCardStatus,
      if (priority != null) 'priority': priority,
      if (workflowStatus != null) 'workflow_status': workflowStatus,
      if (instructions != null) 'instructions': instructions,
      if (notes != null) 'notes': notes,
      if (syllabus != null) 'syllabus': syllabus,
      if (isQuickCapture != null) 'is_quick_capture': isQuickCapture,
      if (checklistPhoto != null) 'checklist_photo': checklistPhoto,
      if (checklistCertificates != null)
        'checklist_certificates': checklistCertificates,
      if (checklistFeePaid != null) 'checklist_fee_paid': checklistFeePaid,
      if (checklistSubmitted != null) 'checklist_submitted': checklistSubmitted,
      if (checklistAdmitCardDownloaded != null)
        'checklist_admit_card_downloaded': checklistAdmitCardDownloaded,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCircularsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? sector,
      Value<String?>? organizationName,
      Value<String?>? organizationWebsite,
      Value<String?>? circularUrl,
      Value<String?>? applicationUrl,
      Value<DateTime?>? deadline,
      Value<int?>? vacancies,
      Value<double?>? salaryMin,
      Value<double?>? salaryMax,
      Value<String?>? salaryNote,
      Value<double?>? applicationFee,
      Value<String?>? feeNote,
      Value<String>? applicationStatus,
      Value<String>? admitCardStatus,
      Value<String>? priority,
      Value<String>? workflowStatus,
      Value<String?>? instructions,
      Value<String?>? notes,
      Value<String?>? syllabus,
      Value<bool>? isQuickCapture,
      Value<bool>? checklistPhoto,
      Value<bool>? checklistCertificates,
      Value<bool>? checklistFeePaid,
      Value<bool>? checklistSubmitted,
      Value<bool>? checklistAdmitCardDownloaded,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return LocalCircularsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      sector: sector ?? this.sector,
      organizationName: organizationName ?? this.organizationName,
      organizationWebsite: organizationWebsite ?? this.organizationWebsite,
      circularUrl: circularUrl ?? this.circularUrl,
      applicationUrl: applicationUrl ?? this.applicationUrl,
      deadline: deadline ?? this.deadline,
      vacancies: vacancies ?? this.vacancies,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      salaryNote: salaryNote ?? this.salaryNote,
      applicationFee: applicationFee ?? this.applicationFee,
      feeNote: feeNote ?? this.feeNote,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      admitCardStatus: admitCardStatus ?? this.admitCardStatus,
      priority: priority ?? this.priority,
      workflowStatus: workflowStatus ?? this.workflowStatus,
      instructions: instructions ?? this.instructions,
      notes: notes ?? this.notes,
      syllabus: syllabus ?? this.syllabus,
      isQuickCapture: isQuickCapture ?? this.isQuickCapture,
      checklistPhoto: checklistPhoto ?? this.checklistPhoto,
      checklistCertificates:
          checklistCertificates ?? this.checklistCertificates,
      checklistFeePaid: checklistFeePaid ?? this.checklistFeePaid,
      checklistSubmitted: checklistSubmitted ?? this.checklistSubmitted,
      checklistAdmitCardDownloaded:
          checklistAdmitCardDownloaded ?? this.checklistAdmitCardDownloaded,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sector.present) {
      map['sector'] = Variable<String>(sector.value);
    }
    if (organizationName.present) {
      map['organization_name'] = Variable<String>(organizationName.value);
    }
    if (organizationWebsite.present) {
      map['organization_website'] = Variable<String>(organizationWebsite.value);
    }
    if (circularUrl.present) {
      map['circular_url'] = Variable<String>(circularUrl.value);
    }
    if (applicationUrl.present) {
      map['application_url'] = Variable<String>(applicationUrl.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (vacancies.present) {
      map['vacancies'] = Variable<int>(vacancies.value);
    }
    if (salaryMin.present) {
      map['salary_min'] = Variable<double>(salaryMin.value);
    }
    if (salaryMax.present) {
      map['salary_max'] = Variable<double>(salaryMax.value);
    }
    if (salaryNote.present) {
      map['salary_note'] = Variable<String>(salaryNote.value);
    }
    if (applicationFee.present) {
      map['application_fee'] = Variable<double>(applicationFee.value);
    }
    if (feeNote.present) {
      map['fee_note'] = Variable<String>(feeNote.value);
    }
    if (applicationStatus.present) {
      map['application_status'] = Variable<String>(applicationStatus.value);
    }
    if (admitCardStatus.present) {
      map['admit_card_status'] = Variable<String>(admitCardStatus.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (workflowStatus.present) {
      map['workflow_status'] = Variable<String>(workflowStatus.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syllabus.present) {
      map['syllabus'] = Variable<String>(syllabus.value);
    }
    if (isQuickCapture.present) {
      map['is_quick_capture'] = Variable<bool>(isQuickCapture.value);
    }
    if (checklistPhoto.present) {
      map['checklist_photo'] = Variable<bool>(checklistPhoto.value);
    }
    if (checklistCertificates.present) {
      map['checklist_certificates'] =
          Variable<bool>(checklistCertificates.value);
    }
    if (checklistFeePaid.present) {
      map['checklist_fee_paid'] = Variable<bool>(checklistFeePaid.value);
    }
    if (checklistSubmitted.present) {
      map['checklist_submitted'] = Variable<bool>(checklistSubmitted.value);
    }
    if (checklistAdmitCardDownloaded.present) {
      map['checklist_admit_card_downloaded'] =
          Variable<bool>(checklistAdmitCardDownloaded.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCircularsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sector: $sector, ')
          ..write('organizationName: $organizationName, ')
          ..write('organizationWebsite: $organizationWebsite, ')
          ..write('circularUrl: $circularUrl, ')
          ..write('applicationUrl: $applicationUrl, ')
          ..write('deadline: $deadline, ')
          ..write('vacancies: $vacancies, ')
          ..write('salaryMin: $salaryMin, ')
          ..write('salaryMax: $salaryMax, ')
          ..write('salaryNote: $salaryNote, ')
          ..write('applicationFee: $applicationFee, ')
          ..write('feeNote: $feeNote, ')
          ..write('applicationStatus: $applicationStatus, ')
          ..write('admitCardStatus: $admitCardStatus, ')
          ..write('priority: $priority, ')
          ..write('workflowStatus: $workflowStatus, ')
          ..write('instructions: $instructions, ')
          ..write('notes: $notes, ')
          ..write('syllabus: $syllabus, ')
          ..write('isQuickCapture: $isQuickCapture, ')
          ..write('checklistPhoto: $checklistPhoto, ')
          ..write('checklistCertificates: $checklistCertificates, ')
          ..write('checklistFeePaid: $checklistFeePaid, ')
          ..write('checklistSubmitted: $checklistSubmitted, ')
          ..write(
              'checklistAdmitCardDownloaded: $checklistAdmitCardDownloaded, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCircularExamDatesTable extends LocalCircularExamDates
    with TableInfo<$LocalCircularExamDatesTable, LocalCircularExamDate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCircularExamDatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _circularIdMeta =
      const VerificationMeta('circularId');
  @override
  late final GeneratedColumn<String> circularId = GeneratedColumn<String>(
      'circular_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
      'stage', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _examDateMeta =
      const VerificationMeta('examDate');
  @override
  late final GeneratedColumn<DateTime> examDate = GeneratedColumn<DateTime>(
      'exam_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _venueMeta = const VerificationMeta('venue');
  @override
  late final GeneratedColumn<String> venue = GeneratedColumn<String>(
      'venue', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, circularId, stage, examDate, venue, notes, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'circular_exam_dates';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalCircularExamDate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('circular_id')) {
      context.handle(
          _circularIdMeta,
          circularId.isAcceptableOrUnknown(
              data['circular_id']!, _circularIdMeta));
    } else if (isInserting) {
      context.missing(_circularIdMeta);
    }
    if (data.containsKey('stage')) {
      context.handle(
          _stageMeta, stage.isAcceptableOrUnknown(data['stage']!, _stageMeta));
    } else if (isInserting) {
      context.missing(_stageMeta);
    }
    if (data.containsKey('exam_date')) {
      context.handle(_examDateMeta,
          examDate.isAcceptableOrUnknown(data['exam_date']!, _examDateMeta));
    } else if (isInserting) {
      context.missing(_examDateMeta);
    }
    if (data.containsKey('venue')) {
      context.handle(
          _venueMeta, venue.isAcceptableOrUnknown(data['venue']!, _venueMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCircularExamDate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCircularExamDate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      circularId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}circular_id'])!,
      stage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stage'])!,
      examDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}exam_date'])!,
      venue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}venue']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $LocalCircularExamDatesTable createAlias(String alias) {
    return $LocalCircularExamDatesTable(attachedDatabase, alias);
  }
}

class LocalCircularExamDate extends DataClass
    implements Insertable<LocalCircularExamDate> {
  /// Primary key UUID.
  final String id;

  /// Parent circular foreign key.
  final String circularId;

  /// Exam stage name (e.g., Preliminary, Written, Viva).
  final String stage;

  /// Scheduled date of the exam.
  final DateTime examDate;

  /// Exam center or venue description.
  final String? venue;

  /// Notes or instructions for this exam stage.
  final String? notes;

  /// Creation timestamp.
  final DateTime? createdAt;

  /// Last update timestamp.
  final DateTime? updatedAt;
  const LocalCircularExamDate(
      {required this.id,
      required this.circularId,
      required this.stage,
      required this.examDate,
      this.venue,
      this.notes,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['circular_id'] = Variable<String>(circularId);
    map['stage'] = Variable<String>(stage);
    map['exam_date'] = Variable<DateTime>(examDate);
    if (!nullToAbsent || venue != null) {
      map['venue'] = Variable<String>(venue);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  LocalCircularExamDatesCompanion toCompanion(bool nullToAbsent) {
    return LocalCircularExamDatesCompanion(
      id: Value(id),
      circularId: Value(circularId),
      stage: Value(stage),
      examDate: Value(examDate),
      venue:
          venue == null && nullToAbsent ? const Value.absent() : Value(venue),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalCircularExamDate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCircularExamDate(
      id: serializer.fromJson<String>(json['id']),
      circularId: serializer.fromJson<String>(json['circularId']),
      stage: serializer.fromJson<String>(json['stage']),
      examDate: serializer.fromJson<DateTime>(json['examDate']),
      venue: serializer.fromJson<String?>(json['venue']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'circularId': serializer.toJson<String>(circularId),
      'stage': serializer.toJson<String>(stage),
      'examDate': serializer.toJson<DateTime>(examDate),
      'venue': serializer.toJson<String?>(venue),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  LocalCircularExamDate copyWith(
          {String? id,
          String? circularId,
          String? stage,
          DateTime? examDate,
          Value<String?> venue = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      LocalCircularExamDate(
        id: id ?? this.id,
        circularId: circularId ?? this.circularId,
        stage: stage ?? this.stage,
        examDate: examDate ?? this.examDate,
        venue: venue.present ? venue.value : this.venue,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  LocalCircularExamDate copyWithCompanion(
      LocalCircularExamDatesCompanion data) {
    return LocalCircularExamDate(
      id: data.id.present ? data.id.value : this.id,
      circularId:
          data.circularId.present ? data.circularId.value : this.circularId,
      stage: data.stage.present ? data.stage.value : this.stage,
      examDate: data.examDate.present ? data.examDate.value : this.examDate,
      venue: data.venue.present ? data.venue.value : this.venue,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCircularExamDate(')
          ..write('id: $id, ')
          ..write('circularId: $circularId, ')
          ..write('stage: $stage, ')
          ..write('examDate: $examDate, ')
          ..write('venue: $venue, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, circularId, stage, examDate, venue, notes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCircularExamDate &&
          other.id == this.id &&
          other.circularId == this.circularId &&
          other.stage == this.stage &&
          other.examDate == this.examDate &&
          other.venue == this.venue &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalCircularExamDatesCompanion
    extends UpdateCompanion<LocalCircularExamDate> {
  final Value<String> id;
  final Value<String> circularId;
  final Value<String> stage;
  final Value<DateTime> examDate;
  final Value<String?> venue;
  final Value<String?> notes;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const LocalCircularExamDatesCompanion({
    this.id = const Value.absent(),
    this.circularId = const Value.absent(),
    this.stage = const Value.absent(),
    this.examDate = const Value.absent(),
    this.venue = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCircularExamDatesCompanion.insert({
    required String id,
    required String circularId,
    required String stage,
    required DateTime examDate,
    this.venue = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        circularId = Value(circularId),
        stage = Value(stage),
        examDate = Value(examDate);
  static Insertable<LocalCircularExamDate> custom({
    Expression<String>? id,
    Expression<String>? circularId,
    Expression<String>? stage,
    Expression<DateTime>? examDate,
    Expression<String>? venue,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (circularId != null) 'circular_id': circularId,
      if (stage != null) 'stage': stage,
      if (examDate != null) 'exam_date': examDate,
      if (venue != null) 'venue': venue,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCircularExamDatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? circularId,
      Value<String>? stage,
      Value<DateTime>? examDate,
      Value<String?>? venue,
      Value<String?>? notes,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return LocalCircularExamDatesCompanion(
      id: id ?? this.id,
      circularId: circularId ?? this.circularId,
      stage: stage ?? this.stage,
      examDate: examDate ?? this.examDate,
      venue: venue ?? this.venue,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (circularId.present) {
      map['circular_id'] = Variable<String>(circularId.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (examDate.present) {
      map['exam_date'] = Variable<DateTime>(examDate.value);
    }
    if (venue.present) {
      map['venue'] = Variable<String>(venue.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCircularExamDatesCompanion(')
          ..write('id: $id, ')
          ..write('circularId: $circularId, ')
          ..write('stage: $stage, ')
          ..write('examDate: $examDate, ')
          ..write('venue: $venue, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSubjectsTable extends LocalSubjects
    with TableInfo<$LocalSubjectsTable, LocalSubject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('gold'));
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('menu_book'));
  static const VerificationMeta _examTypeMeta =
      const VerificationMeta('examType');
  @override
  late final GeneratedColumn<String> examType = GeneratedColumn<String>(
      'exam_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('general'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, color, icon, examType, sortOrder, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(Insertable<LocalSubject> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('exam_type')) {
      context.handle(_examTypeMeta,
          examType.isAcceptableOrUnknown(data['exam_type']!, _examTypeMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSubject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSubject(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      examType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exam_type'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $LocalSubjectsTable createAlias(String alias) {
    return $LocalSubjectsTable(attachedDatabase, alias);
  }
}

class LocalSubject extends DataClass implements Insertable<LocalSubject> {
  final String id;
  final String name;
  final String color;
  final String icon;
  final String examType;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const LocalSubject(
      {required this.id,
      required this.name,
      required this.color,
      required this.icon,
      required this.examType,
      required this.sortOrder,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    map['icon'] = Variable<String>(icon);
    map['exam_type'] = Variable<String>(examType);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  LocalSubjectsCompanion toCompanion(bool nullToAbsent) {
    return LocalSubjectsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      icon: Value(icon),
      examType: Value(examType),
      sortOrder: Value(sortOrder),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalSubject.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSubject(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      icon: serializer.fromJson<String>(json['icon']),
      examType: serializer.fromJson<String>(json['examType']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'icon': serializer.toJson<String>(icon),
      'examType': serializer.toJson<String>(examType),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  LocalSubject copyWith(
          {String? id,
          String? name,
          String? color,
          String? icon,
          String? examType,
          int? sortOrder,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      LocalSubject(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
        icon: icon ?? this.icon,
        examType: examType ?? this.examType,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  LocalSubject copyWithCompanion(LocalSubjectsCompanion data) {
    return LocalSubject(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      examType: data.examType.present ? data.examType.value : this.examType,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSubject(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('examType: $examType, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, color, icon, examType, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSubject &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.examType == this.examType &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalSubjectsCompanion extends UpdateCompanion<LocalSubject> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> color;
  final Value<String> icon;
  final Value<String> examType;
  final Value<int> sortOrder;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const LocalSubjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.examType = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSubjectsCompanion.insert({
    required String id,
    required String name,
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.examType = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<LocalSubject> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<String>? icon,
    Expression<String>? examType,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (examType != null) 'exam_type': examType,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSubjectsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? color,
      Value<String>? icon,
      Value<String>? examType,
      Value<int>? sortOrder,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return LocalSubjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      examType: examType ?? this.examType,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (examType.present) {
      map['exam_type'] = Variable<String>(examType.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSubjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('examType: $examType, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMaterialsTable extends LocalMaterials
    with TableInfo<$LocalMaterialsTable, LocalMaterial> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMaterialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('book'));
  static const VerificationMeta _unitLabelMeta =
      const VerificationMeta('unitLabel');
  @override
  late final GeneratedColumn<String> unitLabel = GeneratedColumn<String>(
      'unit_label', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pages'));
  static const VerificationMeta _totalUnitsMeta =
      const VerificationMeta('totalUnits');
  @override
  late final GeneratedColumn<int> totalUnits = GeneratedColumn<int>(
      'total_units', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _completedUnitsMeta =
      const VerificationMeta('completedUnits');
  @override
  late final GeneratedColumn<int> completedUnits = GeneratedColumn<int>(
      'completed_units', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _coverImagePathMeta =
      const VerificationMeta('coverImagePath');
  @override
  late final GeneratedColumn<String> coverImagePath = GeneratedColumn<String>(
      'cover_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverImageUrlMeta =
      const VerificationMeta('coverImageUrl');
  @override
  late final GeneratedColumn<String> coverImageUrl = GeneratedColumn<String>(
      'cover_image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        subjectId,
        title,
        kind,
        unitLabel,
        totalUnits,
        completedUnits,
        coverImagePath,
        coverImageUrl,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'materials';
  @override
  VerificationContext validateIntegrity(Insertable<LocalMaterial> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    }
    if (data.containsKey('unit_label')) {
      context.handle(_unitLabelMeta,
          unitLabel.isAcceptableOrUnknown(data['unit_label']!, _unitLabelMeta));
    }
    if (data.containsKey('total_units')) {
      context.handle(
          _totalUnitsMeta,
          totalUnits.isAcceptableOrUnknown(
              data['total_units']!, _totalUnitsMeta));
    }
    if (data.containsKey('completed_units')) {
      context.handle(
          _completedUnitsMeta,
          completedUnits.isAcceptableOrUnknown(
              data['completed_units']!, _completedUnitsMeta));
    }
    if (data.containsKey('cover_image_path')) {
      context.handle(
          _coverImagePathMeta,
          coverImagePath.isAcceptableOrUnknown(
              data['cover_image_path']!, _coverImagePathMeta));
    }
    if (data.containsKey('cover_image_url')) {
      context.handle(
          _coverImageUrlMeta,
          coverImageUrl.isAcceptableOrUnknown(
              data['cover_image_url']!, _coverImageUrlMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMaterial map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMaterial(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      unitLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit_label'])!,
      totalUnits: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_units'])!,
      completedUnits: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completed_units'])!,
      coverImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}cover_image_path']),
      coverImageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_image_url']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $LocalMaterialsTable createAlias(String alias) {
    return $LocalMaterialsTable(attachedDatabase, alias);
  }
}

class LocalMaterial extends DataClass implements Insertable<LocalMaterial> {
  final String id;
  final String subjectId;
  final String title;
  final String kind;
  final String unitLabel;
  final int totalUnits;
  final int completedUnits;
  final String? coverImagePath;
  final String? coverImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const LocalMaterial(
      {required this.id,
      required this.subjectId,
      required this.title,
      required this.kind,
      required this.unitLabel,
      required this.totalUnits,
      required this.completedUnits,
      this.coverImagePath,
      this.coverImageUrl,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_id'] = Variable<String>(subjectId);
    map['title'] = Variable<String>(title);
    map['kind'] = Variable<String>(kind);
    map['unit_label'] = Variable<String>(unitLabel);
    map['total_units'] = Variable<int>(totalUnits);
    map['completed_units'] = Variable<int>(completedUnits);
    if (!nullToAbsent || coverImagePath != null) {
      map['cover_image_path'] = Variable<String>(coverImagePath);
    }
    if (!nullToAbsent || coverImageUrl != null) {
      map['cover_image_url'] = Variable<String>(coverImageUrl);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  LocalMaterialsCompanion toCompanion(bool nullToAbsent) {
    return LocalMaterialsCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      title: Value(title),
      kind: Value(kind),
      unitLabel: Value(unitLabel),
      totalUnits: Value(totalUnits),
      completedUnits: Value(completedUnits),
      coverImagePath: coverImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImagePath),
      coverImageUrl: coverImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImageUrl),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalMaterial.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMaterial(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      title: serializer.fromJson<String>(json['title']),
      kind: serializer.fromJson<String>(json['kind']),
      unitLabel: serializer.fromJson<String>(json['unitLabel']),
      totalUnits: serializer.fromJson<int>(json['totalUnits']),
      completedUnits: serializer.fromJson<int>(json['completedUnits']),
      coverImagePath: serializer.fromJson<String?>(json['coverImagePath']),
      coverImageUrl: serializer.fromJson<String?>(json['coverImageUrl']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'title': serializer.toJson<String>(title),
      'kind': serializer.toJson<String>(kind),
      'unitLabel': serializer.toJson<String>(unitLabel),
      'totalUnits': serializer.toJson<int>(totalUnits),
      'completedUnits': serializer.toJson<int>(completedUnits),
      'coverImagePath': serializer.toJson<String?>(coverImagePath),
      'coverImageUrl': serializer.toJson<String?>(coverImageUrl),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  LocalMaterial copyWith(
          {String? id,
          String? subjectId,
          String? title,
          String? kind,
          String? unitLabel,
          int? totalUnits,
          int? completedUnits,
          Value<String?> coverImagePath = const Value.absent(),
          Value<String?> coverImageUrl = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      LocalMaterial(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        title: title ?? this.title,
        kind: kind ?? this.kind,
        unitLabel: unitLabel ?? this.unitLabel,
        totalUnits: totalUnits ?? this.totalUnits,
        completedUnits: completedUnits ?? this.completedUnits,
        coverImagePath:
            coverImagePath.present ? coverImagePath.value : this.coverImagePath,
        coverImageUrl:
            coverImageUrl.present ? coverImageUrl.value : this.coverImageUrl,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  LocalMaterial copyWithCompanion(LocalMaterialsCompanion data) {
    return LocalMaterial(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      title: data.title.present ? data.title.value : this.title,
      kind: data.kind.present ? data.kind.value : this.kind,
      unitLabel: data.unitLabel.present ? data.unitLabel.value : this.unitLabel,
      totalUnits:
          data.totalUnits.present ? data.totalUnits.value : this.totalUnits,
      completedUnits: data.completedUnits.present
          ? data.completedUnits.value
          : this.completedUnits,
      coverImagePath: data.coverImagePath.present
          ? data.coverImagePath.value
          : this.coverImagePath,
      coverImageUrl: data.coverImageUrl.present
          ? data.coverImageUrl.value
          : this.coverImageUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMaterial(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('kind: $kind, ')
          ..write('unitLabel: $unitLabel, ')
          ..write('totalUnits: $totalUnits, ')
          ..write('completedUnits: $completedUnits, ')
          ..write('coverImagePath: $coverImagePath, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      subjectId,
      title,
      kind,
      unitLabel,
      totalUnits,
      completedUnits,
      coverImagePath,
      coverImageUrl,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMaterial &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.title == this.title &&
          other.kind == this.kind &&
          other.unitLabel == this.unitLabel &&
          other.totalUnits == this.totalUnits &&
          other.completedUnits == this.completedUnits &&
          other.coverImagePath == this.coverImagePath &&
          other.coverImageUrl == this.coverImageUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalMaterialsCompanion extends UpdateCompanion<LocalMaterial> {
  final Value<String> id;
  final Value<String> subjectId;
  final Value<String> title;
  final Value<String> kind;
  final Value<String> unitLabel;
  final Value<int> totalUnits;
  final Value<int> completedUnits;
  final Value<String?> coverImagePath;
  final Value<String?> coverImageUrl;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const LocalMaterialsCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.title = const Value.absent(),
    this.kind = const Value.absent(),
    this.unitLabel = const Value.absent(),
    this.totalUnits = const Value.absent(),
    this.completedUnits = const Value.absent(),
    this.coverImagePath = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMaterialsCompanion.insert({
    required String id,
    required String subjectId,
    required String title,
    this.kind = const Value.absent(),
    this.unitLabel = const Value.absent(),
    this.totalUnits = const Value.absent(),
    this.completedUnits = const Value.absent(),
    this.coverImagePath = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        subjectId = Value(subjectId),
        title = Value(title);
  static Insertable<LocalMaterial> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<String>? title,
    Expression<String>? kind,
    Expression<String>? unitLabel,
    Expression<int>? totalUnits,
    Expression<int>? completedUnits,
    Expression<String>? coverImagePath,
    Expression<String>? coverImageUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (title != null) 'title': title,
      if (kind != null) 'kind': kind,
      if (unitLabel != null) 'unit_label': unitLabel,
      if (totalUnits != null) 'total_units': totalUnits,
      if (completedUnits != null) 'completed_units': completedUnits,
      if (coverImagePath != null) 'cover_image_path': coverImagePath,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMaterialsCompanion copyWith(
      {Value<String>? id,
      Value<String>? subjectId,
      Value<String>? title,
      Value<String>? kind,
      Value<String>? unitLabel,
      Value<int>? totalUnits,
      Value<int>? completedUnits,
      Value<String?>? coverImagePath,
      Value<String?>? coverImageUrl,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return LocalMaterialsCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      unitLabel: unitLabel ?? this.unitLabel,
      totalUnits: totalUnits ?? this.totalUnits,
      completedUnits: completedUnits ?? this.completedUnits,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (unitLabel.present) {
      map['unit_label'] = Variable<String>(unitLabel.value);
    }
    if (totalUnits.present) {
      map['total_units'] = Variable<int>(totalUnits.value);
    }
    if (completedUnits.present) {
      map['completed_units'] = Variable<int>(completedUnits.value);
    }
    if (coverImagePath.present) {
      map['cover_image_path'] = Variable<String>(coverImagePath.value);
    }
    if (coverImageUrl.present) {
      map['cover_image_url'] = Variable<String>(coverImageUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMaterialsCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('kind: $kind, ')
          ..write('unitLabel: $unitLabel, ')
          ..write('totalUnits: $totalUnits, ')
          ..write('completedUnits: $completedUnits, ')
          ..write('coverImagePath: $coverImagePath, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalProgressLogsTable extends LocalProgressLogs
    with TableInfo<$LocalProgressLogsTable, LocalProgressLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProgressLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _materialIdMeta =
      const VerificationMeta('materialId');
  @override
  late final GeneratedColumn<String> materialId = GeneratedColumn<String>(
      'material_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitsDoneMeta =
      const VerificationMeta('unitsDone');
  @override
  late final GeneratedColumn<int> unitsDone = GeneratedColumn<int>(
      'units_done', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _entryTypeMeta =
      const VerificationMeta('entryType');
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
      'entry_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('study'));
  static const VerificationMeta _loggedOnMeta =
      const VerificationMeta('loggedOn');
  @override
  late final GeneratedColumn<DateTime> loggedOn = GeneratedColumn<DateTime>(
      'logged_on', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        materialId,
        unitsDone,
        entryType,
        loggedOn,
        note,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progress_logs';
  @override
  VerificationContext validateIntegrity(Insertable<LocalProgressLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('material_id')) {
      context.handle(
          _materialIdMeta,
          materialId.isAcceptableOrUnknown(
              data['material_id']!, _materialIdMeta));
    } else if (isInserting) {
      context.missing(_materialIdMeta);
    }
    if (data.containsKey('units_done')) {
      context.handle(_unitsDoneMeta,
          unitsDone.isAcceptableOrUnknown(data['units_done']!, _unitsDoneMeta));
    }
    if (data.containsKey('entry_type')) {
      context.handle(_entryTypeMeta,
          entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta));
    }
    if (data.containsKey('logged_on')) {
      context.handle(_loggedOnMeta,
          loggedOn.isAcceptableOrUnknown(data['logged_on']!, _loggedOnMeta));
    } else if (isInserting) {
      context.missing(_loggedOnMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalProgressLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProgressLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      materialId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}material_id'])!,
      unitsDone: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}units_done'])!,
      entryType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_type'])!,
      loggedOn: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}logged_on'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $LocalProgressLogsTable createAlias(String alias) {
    return $LocalProgressLogsTable(attachedDatabase, alias);
  }
}

class LocalProgressLog extends DataClass
    implements Insertable<LocalProgressLog> {
  final String id;
  final String materialId;
  final int unitsDone;
  final String entryType;
  final DateTime loggedOn;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const LocalProgressLog(
      {required this.id,
      required this.materialId,
      required this.unitsDone,
      required this.entryType,
      required this.loggedOn,
      this.note,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['material_id'] = Variable<String>(materialId);
    map['units_done'] = Variable<int>(unitsDone);
    map['entry_type'] = Variable<String>(entryType);
    map['logged_on'] = Variable<DateTime>(loggedOn);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  LocalProgressLogsCompanion toCompanion(bool nullToAbsent) {
    return LocalProgressLogsCompanion(
      id: Value(id),
      materialId: Value(materialId),
      unitsDone: Value(unitsDone),
      entryType: Value(entryType),
      loggedOn: Value(loggedOn),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalProgressLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProgressLog(
      id: serializer.fromJson<String>(json['id']),
      materialId: serializer.fromJson<String>(json['materialId']),
      unitsDone: serializer.fromJson<int>(json['unitsDone']),
      entryType: serializer.fromJson<String>(json['entryType']),
      loggedOn: serializer.fromJson<DateTime>(json['loggedOn']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'materialId': serializer.toJson<String>(materialId),
      'unitsDone': serializer.toJson<int>(unitsDone),
      'entryType': serializer.toJson<String>(entryType),
      'loggedOn': serializer.toJson<DateTime>(loggedOn),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  LocalProgressLog copyWith(
          {String? id,
          String? materialId,
          int? unitsDone,
          String? entryType,
          DateTime? loggedOn,
          Value<String?> note = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      LocalProgressLog(
        id: id ?? this.id,
        materialId: materialId ?? this.materialId,
        unitsDone: unitsDone ?? this.unitsDone,
        entryType: entryType ?? this.entryType,
        loggedOn: loggedOn ?? this.loggedOn,
        note: note.present ? note.value : this.note,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  LocalProgressLog copyWithCompanion(LocalProgressLogsCompanion data) {
    return LocalProgressLog(
      id: data.id.present ? data.id.value : this.id,
      materialId:
          data.materialId.present ? data.materialId.value : this.materialId,
      unitsDone: data.unitsDone.present ? data.unitsDone.value : this.unitsDone,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      loggedOn: data.loggedOn.present ? data.loggedOn.value : this.loggedOn,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProgressLog(')
          ..write('id: $id, ')
          ..write('materialId: $materialId, ')
          ..write('unitsDone: $unitsDone, ')
          ..write('entryType: $entryType, ')
          ..write('loggedOn: $loggedOn, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, materialId, unitsDone, entryType,
      loggedOn, note, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProgressLog &&
          other.id == this.id &&
          other.materialId == this.materialId &&
          other.unitsDone == this.unitsDone &&
          other.entryType == this.entryType &&
          other.loggedOn == this.loggedOn &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalProgressLogsCompanion extends UpdateCompanion<LocalProgressLog> {
  final Value<String> id;
  final Value<String> materialId;
  final Value<int> unitsDone;
  final Value<String> entryType;
  final Value<DateTime> loggedOn;
  final Value<String?> note;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const LocalProgressLogsCompanion({
    this.id = const Value.absent(),
    this.materialId = const Value.absent(),
    this.unitsDone = const Value.absent(),
    this.entryType = const Value.absent(),
    this.loggedOn = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalProgressLogsCompanion.insert({
    required String id,
    required String materialId,
    this.unitsDone = const Value.absent(),
    this.entryType = const Value.absent(),
    required DateTime loggedOn,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        materialId = Value(materialId),
        loggedOn = Value(loggedOn);
  static Insertable<LocalProgressLog> custom({
    Expression<String>? id,
    Expression<String>? materialId,
    Expression<int>? unitsDone,
    Expression<String>? entryType,
    Expression<DateTime>? loggedOn,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (materialId != null) 'material_id': materialId,
      if (unitsDone != null) 'units_done': unitsDone,
      if (entryType != null) 'entry_type': entryType,
      if (loggedOn != null) 'logged_on': loggedOn,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalProgressLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? materialId,
      Value<int>? unitsDone,
      Value<String>? entryType,
      Value<DateTime>? loggedOn,
      Value<String?>? note,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return LocalProgressLogsCompanion(
      id: id ?? this.id,
      materialId: materialId ?? this.materialId,
      unitsDone: unitsDone ?? this.unitsDone,
      entryType: entryType ?? this.entryType,
      loggedOn: loggedOn ?? this.loggedOn,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (materialId.present) {
      map['material_id'] = Variable<String>(materialId.value);
    }
    if (unitsDone.present) {
      map['units_done'] = Variable<int>(unitsDone.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (loggedOn.present) {
      map['logged_on'] = Variable<DateTime>(loggedOn.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProgressLogsCompanion(')
          ..write('id: $id, ')
          ..write('materialId: $materialId, ')
          ..write('unitsDone: $unitsDone, ')
          ..write('entryType: $entryType, ')
          ..write('loggedOn: $loggedOn, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTopicsTable extends LocalTopics
    with TableInfo<$LocalTopicsTable, LocalTopic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTopicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, subjectId, name, sortOrder, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'topics';
  @override
  VerificationContext validateIntegrity(Insertable<LocalTopic> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTopic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTopic(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $LocalTopicsTable createAlias(String alias) {
    return $LocalTopicsTable(attachedDatabase, alias);
  }
}

class LocalTopic extends DataClass implements Insertable<LocalTopic> {
  final String id;
  final String subjectId;
  final String name;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const LocalTopic(
      {required this.id,
      required this.subjectId,
      required this.name,
      required this.sortOrder,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_id'] = Variable<String>(subjectId);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  LocalTopicsCompanion toCompanion(bool nullToAbsent) {
    return LocalTopicsCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      name: Value(name),
      sortOrder: Value(sortOrder),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalTopic.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTopic(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  LocalTopic copyWith(
          {String? id,
          String? subjectId,
          String? name,
          int? sortOrder,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      LocalTopic(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        name: name ?? this.name,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  LocalTopic copyWithCompanion(LocalTopicsCompanion data) {
    return LocalTopic(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTopic(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, subjectId, name, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTopic &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalTopicsCompanion extends UpdateCompanion<LocalTopic> {
  final Value<String> id;
  final Value<String> subjectId;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const LocalTopicsCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTopicsCompanion.insert({
    required String id,
    required String subjectId,
    required String name,
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        subjectId = Value(subjectId),
        name = Value(name);
  static Insertable<LocalTopic> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTopicsCompanion copyWith(
      {Value<String>? id,
      Value<String>? subjectId,
      Value<String>? name,
      Value<int>? sortOrder,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return LocalTopicsCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTopicsCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCircularSubjectsTable extends LocalCircularSubjects
    with TableInfo<$LocalCircularSubjectsTable, LocalCircularSubject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCircularSubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _circularIdMeta =
      const VerificationMeta('circularId');
  @override
  late final GeneratedColumn<String> circularId = GeneratedColumn<String>(
      'circular_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, circularId, subjectId, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'circular_subjects';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalCircularSubject> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('circular_id')) {
      context.handle(
          _circularIdMeta,
          circularId.isAcceptableOrUnknown(
              data['circular_id']!, _circularIdMeta));
    } else if (isInserting) {
      context.missing(_circularIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCircularSubject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCircularSubject(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      circularId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}circular_id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $LocalCircularSubjectsTable createAlias(String alias) {
    return $LocalCircularSubjectsTable(attachedDatabase, alias);
  }
}

class LocalCircularSubject extends DataClass
    implements Insertable<LocalCircularSubject> {
  final String id;
  final String circularId;
  final String subjectId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const LocalCircularSubject(
      {required this.id,
      required this.circularId,
      required this.subjectId,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['circular_id'] = Variable<String>(circularId);
    map['subject_id'] = Variable<String>(subjectId);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  LocalCircularSubjectsCompanion toCompanion(bool nullToAbsent) {
    return LocalCircularSubjectsCompanion(
      id: Value(id),
      circularId: Value(circularId),
      subjectId: Value(subjectId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalCircularSubject.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCircularSubject(
      id: serializer.fromJson<String>(json['id']),
      circularId: serializer.fromJson<String>(json['circularId']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'circularId': serializer.toJson<String>(circularId),
      'subjectId': serializer.toJson<String>(subjectId),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  LocalCircularSubject copyWith(
          {String? id,
          String? circularId,
          String? subjectId,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      LocalCircularSubject(
        id: id ?? this.id,
        circularId: circularId ?? this.circularId,
        subjectId: subjectId ?? this.subjectId,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  LocalCircularSubject copyWithCompanion(LocalCircularSubjectsCompanion data) {
    return LocalCircularSubject(
      id: data.id.present ? data.id.value : this.id,
      circularId:
          data.circularId.present ? data.circularId.value : this.circularId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCircularSubject(')
          ..write('id: $id, ')
          ..write('circularId: $circularId, ')
          ..write('subjectId: $subjectId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, circularId, subjectId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCircularSubject &&
          other.id == this.id &&
          other.circularId == this.circularId &&
          other.subjectId == this.subjectId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalCircularSubjectsCompanion
    extends UpdateCompanion<LocalCircularSubject> {
  final Value<String> id;
  final Value<String> circularId;
  final Value<String> subjectId;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const LocalCircularSubjectsCompanion({
    this.id = const Value.absent(),
    this.circularId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCircularSubjectsCompanion.insert({
    required String id,
    required String circularId,
    required String subjectId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        circularId = Value(circularId),
        subjectId = Value(subjectId);
  static Insertable<LocalCircularSubject> custom({
    Expression<String>? id,
    Expression<String>? circularId,
    Expression<String>? subjectId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (circularId != null) 'circular_id': circularId,
      if (subjectId != null) 'subject_id': subjectId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCircularSubjectsCompanion copyWith(
      {Value<String>? id,
      Value<String>? circularId,
      Value<String>? subjectId,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return LocalCircularSubjectsCompanion(
      id: id ?? this.id,
      circularId: circularId ?? this.circularId,
      subjectId: subjectId ?? this.subjectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (circularId.present) {
      map['circular_id'] = Variable<String>(circularId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCircularSubjectsCompanion(')
          ..write('id: $id, ')
          ..write('circularId: $circularId, ')
          ..write('subjectId: $subjectId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalStudyPlansTable extends LocalStudyPlans
    with TableInfo<$LocalStudyPlansTable, LocalStudyPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalStudyPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
      'subject_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _circularIdMeta =
      const VerificationMeta('circularId');
  @override
  late final GeneratedColumn<String> circularId = GeneratedColumn<String>(
      'circular_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _examDateIdMeta =
      const VerificationMeta('examDateId');
  @override
  late final GeneratedColumn<String> examDateId = GeneratedColumn<String>(
      'exam_date_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _targetDateMeta =
      const VerificationMeta('targetDate');
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
      'target_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _finishBufferDaysMeta =
      const VerificationMeta('finishBufferDays');
  @override
  late final GeneratedColumn<int> finishBufferDays = GeneratedColumn<int>(
      'finish_buffer_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(7));
  static const VerificationMeta _restDaysPerWeekMeta =
      const VerificationMeta('restDaysPerWeek');
  @override
  late final GeneratedColumn<int> restDaysPerWeek = GeneratedColumn<int>(
      'rest_days_per_week', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _extraStudyDaysMeta =
      const VerificationMeta('extraStudyDays');
  @override
  late final GeneratedColumn<int> extraStudyDays = GeneratedColumn<int>(
      'extra_study_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _maxDailyPaceMeta =
      const VerificationMeta('maxDailyPace');
  @override
  late final GeneratedColumn<int> maxDailyPace = GeneratedColumn<int>(
      'max_daily_pace', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _initialCompletedUnitsMeta =
      const VerificationMeta('initialCompletedUnits');
  @override
  late final GeneratedColumn<int> initialCompletedUnits = GeneratedColumn<int>(
      'initial_completed_units', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _postponedMaterialIdsMeta =
      const VerificationMeta('postponedMaterialIds');
  @override
  late final GeneratedColumn<String> postponedMaterialIds =
      GeneratedColumn<String>('postponed_material_ids', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        subjectId,
        circularId,
        examDateId,
        startDate,
        targetDate,
        finishBufferDays,
        restDaysPerWeek,
        extraStudyDays,
        maxDailyPace,
        initialCompletedUnits,
        postponedMaterialIds,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_plans';
  @override
  VerificationContext validateIntegrity(Insertable<LocalStudyPlan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    }
    if (data.containsKey('circular_id')) {
      context.handle(
          _circularIdMeta,
          circularId.isAcceptableOrUnknown(
              data['circular_id']!, _circularIdMeta));
    }
    if (data.containsKey('exam_date_id')) {
      context.handle(
          _examDateIdMeta,
          examDateId.isAcceptableOrUnknown(
              data['exam_date_id']!, _examDateIdMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('target_date')) {
      context.handle(
          _targetDateMeta,
          targetDate.isAcceptableOrUnknown(
              data['target_date']!, _targetDateMeta));
    } else if (isInserting) {
      context.missing(_targetDateMeta);
    }
    if (data.containsKey('finish_buffer_days')) {
      context.handle(
          _finishBufferDaysMeta,
          finishBufferDays.isAcceptableOrUnknown(
              data['finish_buffer_days']!, _finishBufferDaysMeta));
    }
    if (data.containsKey('rest_days_per_week')) {
      context.handle(
          _restDaysPerWeekMeta,
          restDaysPerWeek.isAcceptableOrUnknown(
              data['rest_days_per_week']!, _restDaysPerWeekMeta));
    }
    if (data.containsKey('extra_study_days')) {
      context.handle(
          _extraStudyDaysMeta,
          extraStudyDays.isAcceptableOrUnknown(
              data['extra_study_days']!, _extraStudyDaysMeta));
    }
    if (data.containsKey('max_daily_pace')) {
      context.handle(
          _maxDailyPaceMeta,
          maxDailyPace.isAcceptableOrUnknown(
              data['max_daily_pace']!, _maxDailyPaceMeta));
    }
    if (data.containsKey('initial_completed_units')) {
      context.handle(
          _initialCompletedUnitsMeta,
          initialCompletedUnits.isAcceptableOrUnknown(
              data['initial_completed_units']!, _initialCompletedUnitsMeta));
    }
    if (data.containsKey('postponed_material_ids')) {
      context.handle(
          _postponedMaterialIdsMeta,
          postponedMaterialIds.isAcceptableOrUnknown(
              data['postponed_material_ids']!, _postponedMaterialIdsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalStudyPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalStudyPlan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_id']),
      circularId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}circular_id']),
      examDateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exam_date_id']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      targetDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}target_date'])!,
      finishBufferDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}finish_buffer_days'])!,
      restDaysPerWeek: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}rest_days_per_week'])!,
      extraStudyDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}extra_study_days'])!,
      maxDailyPace: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_daily_pace']),
      initialCompletedUnits: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}initial_completed_units'])!,
      postponedMaterialIds: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}postponed_material_ids'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $LocalStudyPlansTable createAlias(String alias) {
    return $LocalStudyPlansTable(attachedDatabase, alias);
  }
}

class LocalStudyPlan extends DataClass implements Insertable<LocalStudyPlan> {
  final String id;
  final String? subjectId;
  final String? circularId;
  final String? examDateId;
  final DateTime startDate;
  final DateTime targetDate;
  final int finishBufferDays;
  final int restDaysPerWeek;
  final int extraStudyDays;
  final int? maxDailyPace;
  final int initialCompletedUnits;
  final String postponedMaterialIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const LocalStudyPlan(
      {required this.id,
      this.subjectId,
      this.circularId,
      this.examDateId,
      required this.startDate,
      required this.targetDate,
      required this.finishBufferDays,
      required this.restDaysPerWeek,
      required this.extraStudyDays,
      this.maxDailyPace,
      required this.initialCompletedUnits,
      required this.postponedMaterialIds,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || subjectId != null) {
      map['subject_id'] = Variable<String>(subjectId);
    }
    if (!nullToAbsent || circularId != null) {
      map['circular_id'] = Variable<String>(circularId);
    }
    if (!nullToAbsent || examDateId != null) {
      map['exam_date_id'] = Variable<String>(examDateId);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    map['target_date'] = Variable<DateTime>(targetDate);
    map['finish_buffer_days'] = Variable<int>(finishBufferDays);
    map['rest_days_per_week'] = Variable<int>(restDaysPerWeek);
    map['extra_study_days'] = Variable<int>(extraStudyDays);
    if (!nullToAbsent || maxDailyPace != null) {
      map['max_daily_pace'] = Variable<int>(maxDailyPace);
    }
    map['initial_completed_units'] = Variable<int>(initialCompletedUnits);
    map['postponed_material_ids'] = Variable<String>(postponedMaterialIds);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  LocalStudyPlansCompanion toCompanion(bool nullToAbsent) {
    return LocalStudyPlansCompanion(
      id: Value(id),
      subjectId: subjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectId),
      circularId: circularId == null && nullToAbsent
          ? const Value.absent()
          : Value(circularId),
      examDateId: examDateId == null && nullToAbsent
          ? const Value.absent()
          : Value(examDateId),
      startDate: Value(startDate),
      targetDate: Value(targetDate),
      finishBufferDays: Value(finishBufferDays),
      restDaysPerWeek: Value(restDaysPerWeek),
      extraStudyDays: Value(extraStudyDays),
      maxDailyPace: maxDailyPace == null && nullToAbsent
          ? const Value.absent()
          : Value(maxDailyPace),
      initialCompletedUnits: Value(initialCompletedUnits),
      postponedMaterialIds: Value(postponedMaterialIds),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalStudyPlan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalStudyPlan(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String?>(json['subjectId']),
      circularId: serializer.fromJson<String?>(json['circularId']),
      examDateId: serializer.fromJson<String?>(json['examDateId']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      targetDate: serializer.fromJson<DateTime>(json['targetDate']),
      finishBufferDays: serializer.fromJson<int>(json['finishBufferDays']),
      restDaysPerWeek: serializer.fromJson<int>(json['restDaysPerWeek']),
      extraStudyDays: serializer.fromJson<int>(json['extraStudyDays']),
      maxDailyPace: serializer.fromJson<int?>(json['maxDailyPace']),
      initialCompletedUnits:
          serializer.fromJson<int>(json['initialCompletedUnits']),
      postponedMaterialIds:
          serializer.fromJson<String>(json['postponedMaterialIds']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String?>(subjectId),
      'circularId': serializer.toJson<String?>(circularId),
      'examDateId': serializer.toJson<String?>(examDateId),
      'startDate': serializer.toJson<DateTime>(startDate),
      'targetDate': serializer.toJson<DateTime>(targetDate),
      'finishBufferDays': serializer.toJson<int>(finishBufferDays),
      'restDaysPerWeek': serializer.toJson<int>(restDaysPerWeek),
      'extraStudyDays': serializer.toJson<int>(extraStudyDays),
      'maxDailyPace': serializer.toJson<int?>(maxDailyPace),
      'initialCompletedUnits': serializer.toJson<int>(initialCompletedUnits),
      'postponedMaterialIds': serializer.toJson<String>(postponedMaterialIds),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  LocalStudyPlan copyWith(
          {String? id,
          Value<String?> subjectId = const Value.absent(),
          Value<String?> circularId = const Value.absent(),
          Value<String?> examDateId = const Value.absent(),
          DateTime? startDate,
          DateTime? targetDate,
          int? finishBufferDays,
          int? restDaysPerWeek,
          int? extraStudyDays,
          Value<int?> maxDailyPace = const Value.absent(),
          int? initialCompletedUnits,
          String? postponedMaterialIds,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      LocalStudyPlan(
        id: id ?? this.id,
        subjectId: subjectId.present ? subjectId.value : this.subjectId,
        circularId: circularId.present ? circularId.value : this.circularId,
        examDateId: examDateId.present ? examDateId.value : this.examDateId,
        startDate: startDate ?? this.startDate,
        targetDate: targetDate ?? this.targetDate,
        finishBufferDays: finishBufferDays ?? this.finishBufferDays,
        restDaysPerWeek: restDaysPerWeek ?? this.restDaysPerWeek,
        extraStudyDays: extraStudyDays ?? this.extraStudyDays,
        maxDailyPace:
            maxDailyPace.present ? maxDailyPace.value : this.maxDailyPace,
        initialCompletedUnits:
            initialCompletedUnits ?? this.initialCompletedUnits,
        postponedMaterialIds: postponedMaterialIds ?? this.postponedMaterialIds,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  LocalStudyPlan copyWithCompanion(LocalStudyPlansCompanion data) {
    return LocalStudyPlan(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      circularId:
          data.circularId.present ? data.circularId.value : this.circularId,
      examDateId:
          data.examDateId.present ? data.examDateId.value : this.examDateId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      targetDate:
          data.targetDate.present ? data.targetDate.value : this.targetDate,
      finishBufferDays: data.finishBufferDays.present
          ? data.finishBufferDays.value
          : this.finishBufferDays,
      restDaysPerWeek: data.restDaysPerWeek.present
          ? data.restDaysPerWeek.value
          : this.restDaysPerWeek,
      extraStudyDays: data.extraStudyDays.present
          ? data.extraStudyDays.value
          : this.extraStudyDays,
      maxDailyPace: data.maxDailyPace.present
          ? data.maxDailyPace.value
          : this.maxDailyPace,
      initialCompletedUnits: data.initialCompletedUnits.present
          ? data.initialCompletedUnits.value
          : this.initialCompletedUnits,
      postponedMaterialIds: data.postponedMaterialIds.present
          ? data.postponedMaterialIds.value
          : this.postponedMaterialIds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalStudyPlan(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('circularId: $circularId, ')
          ..write('examDateId: $examDateId, ')
          ..write('startDate: $startDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('finishBufferDays: $finishBufferDays, ')
          ..write('restDaysPerWeek: $restDaysPerWeek, ')
          ..write('extraStudyDays: $extraStudyDays, ')
          ..write('maxDailyPace: $maxDailyPace, ')
          ..write('initialCompletedUnits: $initialCompletedUnits, ')
          ..write('postponedMaterialIds: $postponedMaterialIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      subjectId,
      circularId,
      examDateId,
      startDate,
      targetDate,
      finishBufferDays,
      restDaysPerWeek,
      extraStudyDays,
      maxDailyPace,
      initialCompletedUnits,
      postponedMaterialIds,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalStudyPlan &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.circularId == this.circularId &&
          other.examDateId == this.examDateId &&
          other.startDate == this.startDate &&
          other.targetDate == this.targetDate &&
          other.finishBufferDays == this.finishBufferDays &&
          other.restDaysPerWeek == this.restDaysPerWeek &&
          other.extraStudyDays == this.extraStudyDays &&
          other.maxDailyPace == this.maxDailyPace &&
          other.initialCompletedUnits == this.initialCompletedUnits &&
          other.postponedMaterialIds == this.postponedMaterialIds &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalStudyPlansCompanion extends UpdateCompanion<LocalStudyPlan> {
  final Value<String> id;
  final Value<String?> subjectId;
  final Value<String?> circularId;
  final Value<String?> examDateId;
  final Value<DateTime> startDate;
  final Value<DateTime> targetDate;
  final Value<int> finishBufferDays;
  final Value<int> restDaysPerWeek;
  final Value<int> extraStudyDays;
  final Value<int?> maxDailyPace;
  final Value<int> initialCompletedUnits;
  final Value<String> postponedMaterialIds;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const LocalStudyPlansCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.circularId = const Value.absent(),
    this.examDateId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.finishBufferDays = const Value.absent(),
    this.restDaysPerWeek = const Value.absent(),
    this.extraStudyDays = const Value.absent(),
    this.maxDailyPace = const Value.absent(),
    this.initialCompletedUnits = const Value.absent(),
    this.postponedMaterialIds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalStudyPlansCompanion.insert({
    required String id,
    this.subjectId = const Value.absent(),
    this.circularId = const Value.absent(),
    this.examDateId = const Value.absent(),
    required DateTime startDate,
    required DateTime targetDate,
    this.finishBufferDays = const Value.absent(),
    this.restDaysPerWeek = const Value.absent(),
    this.extraStudyDays = const Value.absent(),
    this.maxDailyPace = const Value.absent(),
    this.initialCompletedUnits = const Value.absent(),
    this.postponedMaterialIds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        startDate = Value(startDate),
        targetDate = Value(targetDate);
  static Insertable<LocalStudyPlan> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<String>? circularId,
    Expression<String>? examDateId,
    Expression<DateTime>? startDate,
    Expression<DateTime>? targetDate,
    Expression<int>? finishBufferDays,
    Expression<int>? restDaysPerWeek,
    Expression<int>? extraStudyDays,
    Expression<int>? maxDailyPace,
    Expression<int>? initialCompletedUnits,
    Expression<String>? postponedMaterialIds,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (circularId != null) 'circular_id': circularId,
      if (examDateId != null) 'exam_date_id': examDateId,
      if (startDate != null) 'start_date': startDate,
      if (targetDate != null) 'target_date': targetDate,
      if (finishBufferDays != null) 'finish_buffer_days': finishBufferDays,
      if (restDaysPerWeek != null) 'rest_days_per_week': restDaysPerWeek,
      if (extraStudyDays != null) 'extra_study_days': extraStudyDays,
      if (maxDailyPace != null) 'max_daily_pace': maxDailyPace,
      if (initialCompletedUnits != null)
        'initial_completed_units': initialCompletedUnits,
      if (postponedMaterialIds != null)
        'postponed_material_ids': postponedMaterialIds,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalStudyPlansCompanion copyWith(
      {Value<String>? id,
      Value<String?>? subjectId,
      Value<String?>? circularId,
      Value<String?>? examDateId,
      Value<DateTime>? startDate,
      Value<DateTime>? targetDate,
      Value<int>? finishBufferDays,
      Value<int>? restDaysPerWeek,
      Value<int>? extraStudyDays,
      Value<int?>? maxDailyPace,
      Value<int>? initialCompletedUnits,
      Value<String>? postponedMaterialIds,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return LocalStudyPlansCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      circularId: circularId ?? this.circularId,
      examDateId: examDateId ?? this.examDateId,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      finishBufferDays: finishBufferDays ?? this.finishBufferDays,
      restDaysPerWeek: restDaysPerWeek ?? this.restDaysPerWeek,
      extraStudyDays: extraStudyDays ?? this.extraStudyDays,
      maxDailyPace: maxDailyPace ?? this.maxDailyPace,
      initialCompletedUnits:
          initialCompletedUnits ?? this.initialCompletedUnits,
      postponedMaterialIds: postponedMaterialIds ?? this.postponedMaterialIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (circularId.present) {
      map['circular_id'] = Variable<String>(circularId.value);
    }
    if (examDateId.present) {
      map['exam_date_id'] = Variable<String>(examDateId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (finishBufferDays.present) {
      map['finish_buffer_days'] = Variable<int>(finishBufferDays.value);
    }
    if (restDaysPerWeek.present) {
      map['rest_days_per_week'] = Variable<int>(restDaysPerWeek.value);
    }
    if (extraStudyDays.present) {
      map['extra_study_days'] = Variable<int>(extraStudyDays.value);
    }
    if (maxDailyPace.present) {
      map['max_daily_pace'] = Variable<int>(maxDailyPace.value);
    }
    if (initialCompletedUnits.present) {
      map['initial_completed_units'] =
          Variable<int>(initialCompletedUnits.value);
    }
    if (postponedMaterialIds.present) {
      map['postponed_material_ids'] =
          Variable<String>(postponedMaterialIds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalStudyPlansCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('circularId: $circularId, ')
          ..write('examDateId: $examDateId, ')
          ..write('startDate: $startDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('finishBufferDays: $finishBufferDays, ')
          ..write('restDaysPerWeek: $restDaysPerWeek, ')
          ..write('extraStudyDays: $extraStudyDays, ')
          ..write('maxDailyPace: $maxDailyPace, ')
          ..write('initialCompletedUnits: $initialCompletedUnits, ')
          ..write('postponedMaterialIds: $postponedMaterialIds, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMockTestsTable extends LocalMockTests
    with TableInfo<$LocalMockTestsTable, LocalMockTest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMockTestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _circularIdMeta =
      const VerificationMeta('circularId');
  @override
  late final GeneratedColumn<String> circularId = GeneratedColumn<String>(
      'circular_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _materialIdMeta =
      const VerificationMeta('materialId');
  @override
  late final GeneratedColumn<String> materialId = GeneratedColumn<String>(
      'material_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _topicIdMeta =
      const VerificationMeta('topicId');
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
      'topic_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _takenOnMeta =
      const VerificationMeta('takenOn');
  @override
  late final GeneratedColumn<DateTime> takenOn = GeneratedColumn<DateTime>(
      'taken_on', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _marksObtainedMeta =
      const VerificationMeta('marksObtained');
  @override
  late final GeneratedColumn<double> marksObtained = GeneratedColumn<double>(
      'marks_obtained', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalMarksMeta =
      const VerificationMeta('totalMarks');
  @override
  late final GeneratedColumn<double> totalMarks = GeneratedColumn<double>(
      'total_marks', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _negativeMarksMeta =
      const VerificationMeta('negativeMarks');
  @override
  late final GeneratedColumn<double> negativeMarks = GeneratedColumn<double>(
      'negative_marks', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _timeTakenMinutesMeta =
      const VerificationMeta('timeTakenMinutes');
  @override
  late final GeneratedColumn<int> timeTakenMinutes = GeneratedColumn<int>(
      'time_taken_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _timeLimitMinutesMeta =
      const VerificationMeta('timeLimitMinutes');
  @override
  late final GeneratedColumn<int> timeLimitMinutes = GeneratedColumn<int>(
      'time_limit_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _weakTopicsMeta =
      const VerificationMeta('weakTopics');
  @override
  late final GeneratedColumn<String> weakTopics = GeneratedColumn<String>(
      'weak_topics', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        subjectId,
        circularId,
        materialId,
        topicId,
        title,
        source,
        takenOn,
        marksObtained,
        totalMarks,
        negativeMarks,
        timeTakenMinutes,
        timeLimitMinutes,
        weakTopics,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mock_tests';
  @override
  VerificationContext validateIntegrity(Insertable<LocalMockTest> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('circular_id')) {
      context.handle(
          _circularIdMeta,
          circularId.isAcceptableOrUnknown(
              data['circular_id']!, _circularIdMeta));
    }
    if (data.containsKey('material_id')) {
      context.handle(
          _materialIdMeta,
          materialId.isAcceptableOrUnknown(
              data['material_id']!, _materialIdMeta));
    }
    if (data.containsKey('topic_id')) {
      context.handle(_topicIdMeta,
          topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('taken_on')) {
      context.handle(_takenOnMeta,
          takenOn.isAcceptableOrUnknown(data['taken_on']!, _takenOnMeta));
    } else if (isInserting) {
      context.missing(_takenOnMeta);
    }
    if (data.containsKey('marks_obtained')) {
      context.handle(
          _marksObtainedMeta,
          marksObtained.isAcceptableOrUnknown(
              data['marks_obtained']!, _marksObtainedMeta));
    } else if (isInserting) {
      context.missing(_marksObtainedMeta);
    }
    if (data.containsKey('total_marks')) {
      context.handle(
          _totalMarksMeta,
          totalMarks.isAcceptableOrUnknown(
              data['total_marks']!, _totalMarksMeta));
    } else if (isInserting) {
      context.missing(_totalMarksMeta);
    }
    if (data.containsKey('negative_marks')) {
      context.handle(
          _negativeMarksMeta,
          negativeMarks.isAcceptableOrUnknown(
              data['negative_marks']!, _negativeMarksMeta));
    }
    if (data.containsKey('time_taken_minutes')) {
      context.handle(
          _timeTakenMinutesMeta,
          timeTakenMinutes.isAcceptableOrUnknown(
              data['time_taken_minutes']!, _timeTakenMinutesMeta));
    }
    if (data.containsKey('time_limit_minutes')) {
      context.handle(
          _timeLimitMinutesMeta,
          timeLimitMinutes.isAcceptableOrUnknown(
              data['time_limit_minutes']!, _timeLimitMinutesMeta));
    }
    if (data.containsKey('weak_topics')) {
      context.handle(
          _weakTopicsMeta,
          weakTopics.isAcceptableOrUnknown(
              data['weak_topics']!, _weakTopicsMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMockTest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMockTest(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_id'])!,
      circularId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}circular_id']),
      materialId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}material_id']),
      topicId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source']),
      takenOn: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}taken_on'])!,
      marksObtained: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}marks_obtained'])!,
      totalMarks: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_marks'])!,
      negativeMarks: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}negative_marks']),
      timeTakenMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}time_taken_minutes']),
      timeLimitMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}time_limit_minutes']),
      weakTopics: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}weak_topics']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $LocalMockTestsTable createAlias(String alias) {
    return $LocalMockTestsTable(attachedDatabase, alias);
  }
}

class LocalMockTest extends DataClass implements Insertable<LocalMockTest> {
  final String id;
  final String subjectId;
  final String? circularId;
  final String? materialId;
  final String? topicId;
  final String title;
  final String? source;
  final DateTime takenOn;
  final double marksObtained;
  final double totalMarks;
  final double? negativeMarks;
  final int? timeTakenMinutes;
  final int? timeLimitMinutes;
  final String? weakTopics;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const LocalMockTest(
      {required this.id,
      required this.subjectId,
      this.circularId,
      this.materialId,
      this.topicId,
      required this.title,
      this.source,
      required this.takenOn,
      required this.marksObtained,
      required this.totalMarks,
      this.negativeMarks,
      this.timeTakenMinutes,
      this.timeLimitMinutes,
      this.weakTopics,
      this.notes,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_id'] = Variable<String>(subjectId);
    if (!nullToAbsent || circularId != null) {
      map['circular_id'] = Variable<String>(circularId);
    }
    if (!nullToAbsent || materialId != null) {
      map['material_id'] = Variable<String>(materialId);
    }
    if (!nullToAbsent || topicId != null) {
      map['topic_id'] = Variable<String>(topicId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    map['taken_on'] = Variable<DateTime>(takenOn);
    map['marks_obtained'] = Variable<double>(marksObtained);
    map['total_marks'] = Variable<double>(totalMarks);
    if (!nullToAbsent || negativeMarks != null) {
      map['negative_marks'] = Variable<double>(negativeMarks);
    }
    if (!nullToAbsent || timeTakenMinutes != null) {
      map['time_taken_minutes'] = Variable<int>(timeTakenMinutes);
    }
    if (!nullToAbsent || timeLimitMinutes != null) {
      map['time_limit_minutes'] = Variable<int>(timeLimitMinutes);
    }
    if (!nullToAbsent || weakTopics != null) {
      map['weak_topics'] = Variable<String>(weakTopics);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  LocalMockTestsCompanion toCompanion(bool nullToAbsent) {
    return LocalMockTestsCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      circularId: circularId == null && nullToAbsent
          ? const Value.absent()
          : Value(circularId),
      materialId: materialId == null && nullToAbsent
          ? const Value.absent()
          : Value(materialId),
      topicId: topicId == null && nullToAbsent
          ? const Value.absent()
          : Value(topicId),
      title: Value(title),
      source:
          source == null && nullToAbsent ? const Value.absent() : Value(source),
      takenOn: Value(takenOn),
      marksObtained: Value(marksObtained),
      totalMarks: Value(totalMarks),
      negativeMarks: negativeMarks == null && nullToAbsent
          ? const Value.absent()
          : Value(negativeMarks),
      timeTakenMinutes: timeTakenMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(timeTakenMinutes),
      timeLimitMinutes: timeLimitMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(timeLimitMinutes),
      weakTopics: weakTopics == null && nullToAbsent
          ? const Value.absent()
          : Value(weakTopics),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalMockTest.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMockTest(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      circularId: serializer.fromJson<String?>(json['circularId']),
      materialId: serializer.fromJson<String?>(json['materialId']),
      topicId: serializer.fromJson<String?>(json['topicId']),
      title: serializer.fromJson<String>(json['title']),
      source: serializer.fromJson<String?>(json['source']),
      takenOn: serializer.fromJson<DateTime>(json['takenOn']),
      marksObtained: serializer.fromJson<double>(json['marksObtained']),
      totalMarks: serializer.fromJson<double>(json['totalMarks']),
      negativeMarks: serializer.fromJson<double?>(json['negativeMarks']),
      timeTakenMinutes: serializer.fromJson<int?>(json['timeTakenMinutes']),
      timeLimitMinutes: serializer.fromJson<int?>(json['timeLimitMinutes']),
      weakTopics: serializer.fromJson<String?>(json['weakTopics']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'circularId': serializer.toJson<String?>(circularId),
      'materialId': serializer.toJson<String?>(materialId),
      'topicId': serializer.toJson<String?>(topicId),
      'title': serializer.toJson<String>(title),
      'source': serializer.toJson<String?>(source),
      'takenOn': serializer.toJson<DateTime>(takenOn),
      'marksObtained': serializer.toJson<double>(marksObtained),
      'totalMarks': serializer.toJson<double>(totalMarks),
      'negativeMarks': serializer.toJson<double?>(negativeMarks),
      'timeTakenMinutes': serializer.toJson<int?>(timeTakenMinutes),
      'timeLimitMinutes': serializer.toJson<int?>(timeLimitMinutes),
      'weakTopics': serializer.toJson<String?>(weakTopics),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  LocalMockTest copyWith(
          {String? id,
          String? subjectId,
          Value<String?> circularId = const Value.absent(),
          Value<String?> materialId = const Value.absent(),
          Value<String?> topicId = const Value.absent(),
          String? title,
          Value<String?> source = const Value.absent(),
          DateTime? takenOn,
          double? marksObtained,
          double? totalMarks,
          Value<double?> negativeMarks = const Value.absent(),
          Value<int?> timeTakenMinutes = const Value.absent(),
          Value<int?> timeLimitMinutes = const Value.absent(),
          Value<String?> weakTopics = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      LocalMockTest(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        circularId: circularId.present ? circularId.value : this.circularId,
        materialId: materialId.present ? materialId.value : this.materialId,
        topicId: topicId.present ? topicId.value : this.topicId,
        title: title ?? this.title,
        source: source.present ? source.value : this.source,
        takenOn: takenOn ?? this.takenOn,
        marksObtained: marksObtained ?? this.marksObtained,
        totalMarks: totalMarks ?? this.totalMarks,
        negativeMarks:
            negativeMarks.present ? negativeMarks.value : this.negativeMarks,
        timeTakenMinutes: timeTakenMinutes.present
            ? timeTakenMinutes.value
            : this.timeTakenMinutes,
        timeLimitMinutes: timeLimitMinutes.present
            ? timeLimitMinutes.value
            : this.timeLimitMinutes,
        weakTopics: weakTopics.present ? weakTopics.value : this.weakTopics,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  LocalMockTest copyWithCompanion(LocalMockTestsCompanion data) {
    return LocalMockTest(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      circularId:
          data.circularId.present ? data.circularId.value : this.circularId,
      materialId:
          data.materialId.present ? data.materialId.value : this.materialId,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      title: data.title.present ? data.title.value : this.title,
      source: data.source.present ? data.source.value : this.source,
      takenOn: data.takenOn.present ? data.takenOn.value : this.takenOn,
      marksObtained: data.marksObtained.present
          ? data.marksObtained.value
          : this.marksObtained,
      totalMarks:
          data.totalMarks.present ? data.totalMarks.value : this.totalMarks,
      negativeMarks: data.negativeMarks.present
          ? data.negativeMarks.value
          : this.negativeMarks,
      timeTakenMinutes: data.timeTakenMinutes.present
          ? data.timeTakenMinutes.value
          : this.timeTakenMinutes,
      timeLimitMinutes: data.timeLimitMinutes.present
          ? data.timeLimitMinutes.value
          : this.timeLimitMinutes,
      weakTopics:
          data.weakTopics.present ? data.weakTopics.value : this.weakTopics,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMockTest(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('circularId: $circularId, ')
          ..write('materialId: $materialId, ')
          ..write('topicId: $topicId, ')
          ..write('title: $title, ')
          ..write('source: $source, ')
          ..write('takenOn: $takenOn, ')
          ..write('marksObtained: $marksObtained, ')
          ..write('totalMarks: $totalMarks, ')
          ..write('negativeMarks: $negativeMarks, ')
          ..write('timeTakenMinutes: $timeTakenMinutes, ')
          ..write('timeLimitMinutes: $timeLimitMinutes, ')
          ..write('weakTopics: $weakTopics, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      subjectId,
      circularId,
      materialId,
      topicId,
      title,
      source,
      takenOn,
      marksObtained,
      totalMarks,
      negativeMarks,
      timeTakenMinutes,
      timeLimitMinutes,
      weakTopics,
      notes,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMockTest &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.circularId == this.circularId &&
          other.materialId == this.materialId &&
          other.topicId == this.topicId &&
          other.title == this.title &&
          other.source == this.source &&
          other.takenOn == this.takenOn &&
          other.marksObtained == this.marksObtained &&
          other.totalMarks == this.totalMarks &&
          other.negativeMarks == this.negativeMarks &&
          other.timeTakenMinutes == this.timeTakenMinutes &&
          other.timeLimitMinutes == this.timeLimitMinutes &&
          other.weakTopics == this.weakTopics &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalMockTestsCompanion extends UpdateCompanion<LocalMockTest> {
  final Value<String> id;
  final Value<String> subjectId;
  final Value<String?> circularId;
  final Value<String?> materialId;
  final Value<String?> topicId;
  final Value<String> title;
  final Value<String?> source;
  final Value<DateTime> takenOn;
  final Value<double> marksObtained;
  final Value<double> totalMarks;
  final Value<double?> negativeMarks;
  final Value<int?> timeTakenMinutes;
  final Value<int?> timeLimitMinutes;
  final Value<String?> weakTopics;
  final Value<String?> notes;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const LocalMockTestsCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.circularId = const Value.absent(),
    this.materialId = const Value.absent(),
    this.topicId = const Value.absent(),
    this.title = const Value.absent(),
    this.source = const Value.absent(),
    this.takenOn = const Value.absent(),
    this.marksObtained = const Value.absent(),
    this.totalMarks = const Value.absent(),
    this.negativeMarks = const Value.absent(),
    this.timeTakenMinutes = const Value.absent(),
    this.timeLimitMinutes = const Value.absent(),
    this.weakTopics = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMockTestsCompanion.insert({
    required String id,
    required String subjectId,
    this.circularId = const Value.absent(),
    this.materialId = const Value.absent(),
    this.topicId = const Value.absent(),
    required String title,
    this.source = const Value.absent(),
    required DateTime takenOn,
    required double marksObtained,
    required double totalMarks,
    this.negativeMarks = const Value.absent(),
    this.timeTakenMinutes = const Value.absent(),
    this.timeLimitMinutes = const Value.absent(),
    this.weakTopics = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        subjectId = Value(subjectId),
        title = Value(title),
        takenOn = Value(takenOn),
        marksObtained = Value(marksObtained),
        totalMarks = Value(totalMarks);
  static Insertable<LocalMockTest> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<String>? circularId,
    Expression<String>? materialId,
    Expression<String>? topicId,
    Expression<String>? title,
    Expression<String>? source,
    Expression<DateTime>? takenOn,
    Expression<double>? marksObtained,
    Expression<double>? totalMarks,
    Expression<double>? negativeMarks,
    Expression<int>? timeTakenMinutes,
    Expression<int>? timeLimitMinutes,
    Expression<String>? weakTopics,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (circularId != null) 'circular_id': circularId,
      if (materialId != null) 'material_id': materialId,
      if (topicId != null) 'topic_id': topicId,
      if (title != null) 'title': title,
      if (source != null) 'source': source,
      if (takenOn != null) 'taken_on': takenOn,
      if (marksObtained != null) 'marks_obtained': marksObtained,
      if (totalMarks != null) 'total_marks': totalMarks,
      if (negativeMarks != null) 'negative_marks': negativeMarks,
      if (timeTakenMinutes != null) 'time_taken_minutes': timeTakenMinutes,
      if (timeLimitMinutes != null) 'time_limit_minutes': timeLimitMinutes,
      if (weakTopics != null) 'weak_topics': weakTopics,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMockTestsCompanion copyWith(
      {Value<String>? id,
      Value<String>? subjectId,
      Value<String?>? circularId,
      Value<String?>? materialId,
      Value<String?>? topicId,
      Value<String>? title,
      Value<String?>? source,
      Value<DateTime>? takenOn,
      Value<double>? marksObtained,
      Value<double>? totalMarks,
      Value<double?>? negativeMarks,
      Value<int?>? timeTakenMinutes,
      Value<int?>? timeLimitMinutes,
      Value<String?>? weakTopics,
      Value<String?>? notes,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return LocalMockTestsCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      circularId: circularId ?? this.circularId,
      materialId: materialId ?? this.materialId,
      topicId: topicId ?? this.topicId,
      title: title ?? this.title,
      source: source ?? this.source,
      takenOn: takenOn ?? this.takenOn,
      marksObtained: marksObtained ?? this.marksObtained,
      totalMarks: totalMarks ?? this.totalMarks,
      negativeMarks: negativeMarks ?? this.negativeMarks,
      timeTakenMinutes: timeTakenMinutes ?? this.timeTakenMinutes,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      weakTopics: weakTopics ?? this.weakTopics,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (circularId.present) {
      map['circular_id'] = Variable<String>(circularId.value);
    }
    if (materialId.present) {
      map['material_id'] = Variable<String>(materialId.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (takenOn.present) {
      map['taken_on'] = Variable<DateTime>(takenOn.value);
    }
    if (marksObtained.present) {
      map['marks_obtained'] = Variable<double>(marksObtained.value);
    }
    if (totalMarks.present) {
      map['total_marks'] = Variable<double>(totalMarks.value);
    }
    if (negativeMarks.present) {
      map['negative_marks'] = Variable<double>(negativeMarks.value);
    }
    if (timeTakenMinutes.present) {
      map['time_taken_minutes'] = Variable<int>(timeTakenMinutes.value);
    }
    if (timeLimitMinutes.present) {
      map['time_limit_minutes'] = Variable<int>(timeLimitMinutes.value);
    }
    if (weakTopics.present) {
      map['weak_topics'] = Variable<String>(weakTopics.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMockTestsCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('circularId: $circularId, ')
          ..write('materialId: $materialId, ')
          ..write('topicId: $topicId, ')
          ..write('title: $title, ')
          ..write('source: $source, ')
          ..write('takenOn: $takenOn, ')
          ..write('marksObtained: $marksObtained, ')
          ..write('totalMarks: $totalMarks, ')
          ..write('negativeMarks: $negativeMarks, ')
          ..write('timeTakenMinutes: $timeTakenMinutes, ')
          ..write('timeLimitMinutes: $timeLimitMinutes, ')
          ..write('weakTopics: $weakTopics, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalRevisionItemsTable extends LocalRevisionItems
    with TableInfo<$LocalRevisionItemsTable, LocalRevisionItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRevisionItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _materialIdMeta =
      const VerificationMeta('materialId');
  @override
  late final GeneratedColumn<String> materialId = GeneratedColumn<String>(
      'material_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _topicIdMeta =
      const VerificationMeta('topicId');
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
      'topic_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceLabelMeta =
      const VerificationMeta('referenceLabel');
  @override
  late final GeneratedColumn<String> referenceLabel = GeneratedColumn<String>(
      'reference_label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pageNumberMeta =
      const VerificationMeta('pageNumber');
  @override
  late final GeneratedColumn<int> pageNumber = GeneratedColumn<int>(
      'page_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('tricky'));
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('manual'));
  static const VerificationMeta _progressLogIdMeta =
      const VerificationMeta('progressLogId');
  @override
  late final GeneratedColumn<String> progressLogId = GeneratedColumn<String>(
      'progress_log_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mockTestIdMeta =
      const VerificationMeta('mockTestId');
  @override
  late final GeneratedColumn<String> mockTestId = GeneratedColumn<String>(
      'mock_test_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _dueOnMeta = const VerificationMeta('dueOn');
  @override
  late final GeneratedColumn<DateTime> dueOn = GeneratedColumn<DateTime>(
      'due_on', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _reviewCountMeta =
      const VerificationMeta('reviewCount');
  @override
  late final GeneratedColumn<int> reviewCount = GeneratedColumn<int>(
      'review_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastReviewedOnMeta =
      const VerificationMeta('lastReviewedOn');
  @override
  late final GeneratedColumn<DateTime> lastReviewedOn =
      GeneratedColumn<DateTime>('last_reviewed_on', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        subjectId,
        materialId,
        topicId,
        referenceLabel,
        pageNumber,
        note,
        reason,
        source,
        progressLogId,
        mockTestId,
        status,
        dueOn,
        reviewCount,
        lastReviewedOn,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'revision_items';
  @override
  VerificationContext validateIntegrity(Insertable<LocalRevisionItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('material_id')) {
      context.handle(
          _materialIdMeta,
          materialId.isAcceptableOrUnknown(
              data['material_id']!, _materialIdMeta));
    }
    if (data.containsKey('topic_id')) {
      context.handle(_topicIdMeta,
          topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta));
    }
    if (data.containsKey('reference_label')) {
      context.handle(
          _referenceLabelMeta,
          referenceLabel.isAcceptableOrUnknown(
              data['reference_label']!, _referenceLabelMeta));
    } else if (isInserting) {
      context.missing(_referenceLabelMeta);
    }
    if (data.containsKey('page_number')) {
      context.handle(
          _pageNumberMeta,
          pageNumber.isAcceptableOrUnknown(
              data['page_number']!, _pageNumberMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('progress_log_id')) {
      context.handle(
          _progressLogIdMeta,
          progressLogId.isAcceptableOrUnknown(
              data['progress_log_id']!, _progressLogIdMeta));
    }
    if (data.containsKey('mock_test_id')) {
      context.handle(
          _mockTestIdMeta,
          mockTestId.isAcceptableOrUnknown(
              data['mock_test_id']!, _mockTestIdMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('due_on')) {
      context.handle(
          _dueOnMeta, dueOn.isAcceptableOrUnknown(data['due_on']!, _dueOnMeta));
    } else if (isInserting) {
      context.missing(_dueOnMeta);
    }
    if (data.containsKey('review_count')) {
      context.handle(
          _reviewCountMeta,
          reviewCount.isAcceptableOrUnknown(
              data['review_count']!, _reviewCountMeta));
    }
    if (data.containsKey('last_reviewed_on')) {
      context.handle(
          _lastReviewedOnMeta,
          lastReviewedOn.isAcceptableOrUnknown(
              data['last_reviewed_on']!, _lastReviewedOnMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalRevisionItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRevisionItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_id'])!,
      materialId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}material_id']),
      topicId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_id']),
      referenceLabel: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reference_label'])!,
      pageNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_number']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      progressLogId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}progress_log_id']),
      mockTestId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mock_test_id']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      dueOn: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_on'])!,
      reviewCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}review_count'])!,
      lastReviewedOn: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_reviewed_on']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $LocalRevisionItemsTable createAlias(String alias) {
    return $LocalRevisionItemsTable(attachedDatabase, alias);
  }
}

class LocalRevisionItem extends DataClass
    implements Insertable<LocalRevisionItem> {
  final String id;
  final String subjectId;
  final String? materialId;
  final String? topicId;
  final String referenceLabel;
  final int? pageNumber;
  final String? note;
  final String reason;
  final String source;
  final String? progressLogId;
  final String? mockTestId;
  final String status;
  final DateTime dueOn;
  final int reviewCount;
  final DateTime? lastReviewedOn;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const LocalRevisionItem(
      {required this.id,
      required this.subjectId,
      this.materialId,
      this.topicId,
      required this.referenceLabel,
      this.pageNumber,
      this.note,
      required this.reason,
      required this.source,
      this.progressLogId,
      this.mockTestId,
      required this.status,
      required this.dueOn,
      required this.reviewCount,
      this.lastReviewedOn,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_id'] = Variable<String>(subjectId);
    if (!nullToAbsent || materialId != null) {
      map['material_id'] = Variable<String>(materialId);
    }
    if (!nullToAbsent || topicId != null) {
      map['topic_id'] = Variable<String>(topicId);
    }
    map['reference_label'] = Variable<String>(referenceLabel);
    if (!nullToAbsent || pageNumber != null) {
      map['page_number'] = Variable<int>(pageNumber);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['reason'] = Variable<String>(reason);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || progressLogId != null) {
      map['progress_log_id'] = Variable<String>(progressLogId);
    }
    if (!nullToAbsent || mockTestId != null) {
      map['mock_test_id'] = Variable<String>(mockTestId);
    }
    map['status'] = Variable<String>(status);
    map['due_on'] = Variable<DateTime>(dueOn);
    map['review_count'] = Variable<int>(reviewCount);
    if (!nullToAbsent || lastReviewedOn != null) {
      map['last_reviewed_on'] = Variable<DateTime>(lastReviewedOn);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  LocalRevisionItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalRevisionItemsCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      materialId: materialId == null && nullToAbsent
          ? const Value.absent()
          : Value(materialId),
      topicId: topicId == null && nullToAbsent
          ? const Value.absent()
          : Value(topicId),
      referenceLabel: Value(referenceLabel),
      pageNumber: pageNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(pageNumber),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      reason: Value(reason),
      source: Value(source),
      progressLogId: progressLogId == null && nullToAbsent
          ? const Value.absent()
          : Value(progressLogId),
      mockTestId: mockTestId == null && nullToAbsent
          ? const Value.absent()
          : Value(mockTestId),
      status: Value(status),
      dueOn: Value(dueOn),
      reviewCount: Value(reviewCount),
      lastReviewedOn: lastReviewedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedOn),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalRevisionItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRevisionItem(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      materialId: serializer.fromJson<String?>(json['materialId']),
      topicId: serializer.fromJson<String?>(json['topicId']),
      referenceLabel: serializer.fromJson<String>(json['referenceLabel']),
      pageNumber: serializer.fromJson<int?>(json['pageNumber']),
      note: serializer.fromJson<String?>(json['note']),
      reason: serializer.fromJson<String>(json['reason']),
      source: serializer.fromJson<String>(json['source']),
      progressLogId: serializer.fromJson<String?>(json['progressLogId']),
      mockTestId: serializer.fromJson<String?>(json['mockTestId']),
      status: serializer.fromJson<String>(json['status']),
      dueOn: serializer.fromJson<DateTime>(json['dueOn']),
      reviewCount: serializer.fromJson<int>(json['reviewCount']),
      lastReviewedOn: serializer.fromJson<DateTime?>(json['lastReviewedOn']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'materialId': serializer.toJson<String?>(materialId),
      'topicId': serializer.toJson<String?>(topicId),
      'referenceLabel': serializer.toJson<String>(referenceLabel),
      'pageNumber': serializer.toJson<int?>(pageNumber),
      'note': serializer.toJson<String?>(note),
      'reason': serializer.toJson<String>(reason),
      'source': serializer.toJson<String>(source),
      'progressLogId': serializer.toJson<String?>(progressLogId),
      'mockTestId': serializer.toJson<String?>(mockTestId),
      'status': serializer.toJson<String>(status),
      'dueOn': serializer.toJson<DateTime>(dueOn),
      'reviewCount': serializer.toJson<int>(reviewCount),
      'lastReviewedOn': serializer.toJson<DateTime?>(lastReviewedOn),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  LocalRevisionItem copyWith(
          {String? id,
          String? subjectId,
          Value<String?> materialId = const Value.absent(),
          Value<String?> topicId = const Value.absent(),
          String? referenceLabel,
          Value<int?> pageNumber = const Value.absent(),
          Value<String?> note = const Value.absent(),
          String? reason,
          String? source,
          Value<String?> progressLogId = const Value.absent(),
          Value<String?> mockTestId = const Value.absent(),
          String? status,
          DateTime? dueOn,
          int? reviewCount,
          Value<DateTime?> lastReviewedOn = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      LocalRevisionItem(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        materialId: materialId.present ? materialId.value : this.materialId,
        topicId: topicId.present ? topicId.value : this.topicId,
        referenceLabel: referenceLabel ?? this.referenceLabel,
        pageNumber: pageNumber.present ? pageNumber.value : this.pageNumber,
        note: note.present ? note.value : this.note,
        reason: reason ?? this.reason,
        source: source ?? this.source,
        progressLogId:
            progressLogId.present ? progressLogId.value : this.progressLogId,
        mockTestId: mockTestId.present ? mockTestId.value : this.mockTestId,
        status: status ?? this.status,
        dueOn: dueOn ?? this.dueOn,
        reviewCount: reviewCount ?? this.reviewCount,
        lastReviewedOn:
            lastReviewedOn.present ? lastReviewedOn.value : this.lastReviewedOn,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  LocalRevisionItem copyWithCompanion(LocalRevisionItemsCompanion data) {
    return LocalRevisionItem(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      materialId:
          data.materialId.present ? data.materialId.value : this.materialId,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      referenceLabel: data.referenceLabel.present
          ? data.referenceLabel.value
          : this.referenceLabel,
      pageNumber:
          data.pageNumber.present ? data.pageNumber.value : this.pageNumber,
      note: data.note.present ? data.note.value : this.note,
      reason: data.reason.present ? data.reason.value : this.reason,
      source: data.source.present ? data.source.value : this.source,
      progressLogId: data.progressLogId.present
          ? data.progressLogId.value
          : this.progressLogId,
      mockTestId:
          data.mockTestId.present ? data.mockTestId.value : this.mockTestId,
      status: data.status.present ? data.status.value : this.status,
      dueOn: data.dueOn.present ? data.dueOn.value : this.dueOn,
      reviewCount:
          data.reviewCount.present ? data.reviewCount.value : this.reviewCount,
      lastReviewedOn: data.lastReviewedOn.present
          ? data.lastReviewedOn.value
          : this.lastReviewedOn,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRevisionItem(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('materialId: $materialId, ')
          ..write('topicId: $topicId, ')
          ..write('referenceLabel: $referenceLabel, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('note: $note, ')
          ..write('reason: $reason, ')
          ..write('source: $source, ')
          ..write('progressLogId: $progressLogId, ')
          ..write('mockTestId: $mockTestId, ')
          ..write('status: $status, ')
          ..write('dueOn: $dueOn, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('lastReviewedOn: $lastReviewedOn, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      subjectId,
      materialId,
      topicId,
      referenceLabel,
      pageNumber,
      note,
      reason,
      source,
      progressLogId,
      mockTestId,
      status,
      dueOn,
      reviewCount,
      lastReviewedOn,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRevisionItem &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.materialId == this.materialId &&
          other.topicId == this.topicId &&
          other.referenceLabel == this.referenceLabel &&
          other.pageNumber == this.pageNumber &&
          other.note == this.note &&
          other.reason == this.reason &&
          other.source == this.source &&
          other.progressLogId == this.progressLogId &&
          other.mockTestId == this.mockTestId &&
          other.status == this.status &&
          other.dueOn == this.dueOn &&
          other.reviewCount == this.reviewCount &&
          other.lastReviewedOn == this.lastReviewedOn &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalRevisionItemsCompanion extends UpdateCompanion<LocalRevisionItem> {
  final Value<String> id;
  final Value<String> subjectId;
  final Value<String?> materialId;
  final Value<String?> topicId;
  final Value<String> referenceLabel;
  final Value<int?> pageNumber;
  final Value<String?> note;
  final Value<String> reason;
  final Value<String> source;
  final Value<String?> progressLogId;
  final Value<String?> mockTestId;
  final Value<String> status;
  final Value<DateTime> dueOn;
  final Value<int> reviewCount;
  final Value<DateTime?> lastReviewedOn;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const LocalRevisionItemsCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.materialId = const Value.absent(),
    this.topicId = const Value.absent(),
    this.referenceLabel = const Value.absent(),
    this.pageNumber = const Value.absent(),
    this.note = const Value.absent(),
    this.reason = const Value.absent(),
    this.source = const Value.absent(),
    this.progressLogId = const Value.absent(),
    this.mockTestId = const Value.absent(),
    this.status = const Value.absent(),
    this.dueOn = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.lastReviewedOn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalRevisionItemsCompanion.insert({
    required String id,
    required String subjectId,
    this.materialId = const Value.absent(),
    this.topicId = const Value.absent(),
    required String referenceLabel,
    this.pageNumber = const Value.absent(),
    this.note = const Value.absent(),
    this.reason = const Value.absent(),
    this.source = const Value.absent(),
    this.progressLogId = const Value.absent(),
    this.mockTestId = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime dueOn,
    this.reviewCount = const Value.absent(),
    this.lastReviewedOn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        subjectId = Value(subjectId),
        referenceLabel = Value(referenceLabel),
        dueOn = Value(dueOn);
  static Insertable<LocalRevisionItem> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<String>? materialId,
    Expression<String>? topicId,
    Expression<String>? referenceLabel,
    Expression<int>? pageNumber,
    Expression<String>? note,
    Expression<String>? reason,
    Expression<String>? source,
    Expression<String>? progressLogId,
    Expression<String>? mockTestId,
    Expression<String>? status,
    Expression<DateTime>? dueOn,
    Expression<int>? reviewCount,
    Expression<DateTime>? lastReviewedOn,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (materialId != null) 'material_id': materialId,
      if (topicId != null) 'topic_id': topicId,
      if (referenceLabel != null) 'reference_label': referenceLabel,
      if (pageNumber != null) 'page_number': pageNumber,
      if (note != null) 'note': note,
      if (reason != null) 'reason': reason,
      if (source != null) 'source': source,
      if (progressLogId != null) 'progress_log_id': progressLogId,
      if (mockTestId != null) 'mock_test_id': mockTestId,
      if (status != null) 'status': status,
      if (dueOn != null) 'due_on': dueOn,
      if (reviewCount != null) 'review_count': reviewCount,
      if (lastReviewedOn != null) 'last_reviewed_on': lastReviewedOn,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalRevisionItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? subjectId,
      Value<String?>? materialId,
      Value<String?>? topicId,
      Value<String>? referenceLabel,
      Value<int?>? pageNumber,
      Value<String?>? note,
      Value<String>? reason,
      Value<String>? source,
      Value<String?>? progressLogId,
      Value<String?>? mockTestId,
      Value<String>? status,
      Value<DateTime>? dueOn,
      Value<int>? reviewCount,
      Value<DateTime?>? lastReviewedOn,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return LocalRevisionItemsCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      materialId: materialId ?? this.materialId,
      topicId: topicId ?? this.topicId,
      referenceLabel: referenceLabel ?? this.referenceLabel,
      pageNumber: pageNumber ?? this.pageNumber,
      note: note ?? this.note,
      reason: reason ?? this.reason,
      source: source ?? this.source,
      progressLogId: progressLogId ?? this.progressLogId,
      mockTestId: mockTestId ?? this.mockTestId,
      status: status ?? this.status,
      dueOn: dueOn ?? this.dueOn,
      reviewCount: reviewCount ?? this.reviewCount,
      lastReviewedOn: lastReviewedOn ?? this.lastReviewedOn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (materialId.present) {
      map['material_id'] = Variable<String>(materialId.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (referenceLabel.present) {
      map['reference_label'] = Variable<String>(referenceLabel.value);
    }
    if (pageNumber.present) {
      map['page_number'] = Variable<int>(pageNumber.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (progressLogId.present) {
      map['progress_log_id'] = Variable<String>(progressLogId.value);
    }
    if (mockTestId.present) {
      map['mock_test_id'] = Variable<String>(mockTestId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (dueOn.present) {
      map['due_on'] = Variable<DateTime>(dueOn.value);
    }
    if (reviewCount.present) {
      map['review_count'] = Variable<int>(reviewCount.value);
    }
    if (lastReviewedOn.present) {
      map['last_reviewed_on'] = Variable<DateTime>(lastReviewedOn.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRevisionItemsCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('materialId: $materialId, ')
          ..write('topicId: $topicId, ')
          ..write('referenceLabel: $referenceLabel, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('note: $note, ')
          ..write('reason: $reason, ')
          ..write('source: $source, ')
          ..write('progressLogId: $progressLogId, ')
          ..write('mockTestId: $mockTestId, ')
          ..write('status: $status, ')
          ..write('dueOn: $dueOn, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('lastReviewedOn: $lastReviewedOn, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalStudySessionsTable extends LocalStudySessions
    with TableInfo<$LocalStudySessionsTable, LocalStudySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalStudySessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _materialIdMeta =
      const VerificationMeta('materialId');
  @override
  late final GeneratedColumn<String> materialId = GeneratedColumn<String>(
      'material_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
      'mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('focus'));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pauseIntervalsMeta =
      const VerificationMeta('pauseIntervals');
  @override
  late final GeneratedColumn<String> pauseIntervals = GeneratedColumn<String>(
      'pause_intervals', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _phaseStartedAtMeta =
      const VerificationMeta('phaseStartedAt');
  @override
  late final GeneratedColumn<DateTime> phaseStartedAt =
      GeneratedColumn<DateTime>('phase_started_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _targetDurationSecondsMeta =
      const VerificationMeta('targetDurationSeconds');
  @override
  late final GeneratedColumn<int> targetDurationSeconds = GeneratedColumn<int>(
      'target_duration_seconds', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _pomodoroRoundMeta =
      const VerificationMeta('pomodoroRound');
  @override
  late final GeneratedColumn<int> pomodoroRound = GeneratedColumn<int>(
      'pomodoro_round', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _pomodoroPhaseMeta =
      const VerificationMeta('pomodoroPhase');
  @override
  late final GeneratedColumn<String> pomodoroPhase = GeneratedColumn<String>(
      'pomodoro_phase', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _focusMinutesMeta =
      const VerificationMeta('focusMinutes');
  @override
  late final GeneratedColumn<int> focusMinutes = GeneratedColumn<int>(
      'focus_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(25));
  static const VerificationMeta _shortBreakMinutesMeta =
      const VerificationMeta('shortBreakMinutes');
  @override
  late final GeneratedColumn<int> shortBreakMinutes = GeneratedColumn<int>(
      'short_break_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  static const VerificationMeta _longBreakMinutesMeta =
      const VerificationMeta('longBreakMinutes');
  @override
  late final GeneratedColumn<int> longBreakMinutes = GeneratedColumn<int>(
      'long_break_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(15));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        subjectId,
        materialId,
        startedAt,
        endedAt,
        durationSeconds,
        mode,
        note,
        pauseIntervals,
        phaseStartedAt,
        targetDurationSeconds,
        pomodoroRound,
        pomodoroPhase,
        focusMinutes,
        shortBreakMinutes,
        longBreakMinutes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<LocalStudySession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('material_id')) {
      context.handle(
          _materialIdMeta,
          materialId.isAcceptableOrUnknown(
              data['material_id']!, _materialIdMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    }
    if (data.containsKey('mode')) {
      context.handle(
          _modeMeta, mode.isAcceptableOrUnknown(data['mode']!, _modeMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('pause_intervals')) {
      context.handle(
          _pauseIntervalsMeta,
          pauseIntervals.isAcceptableOrUnknown(
              data['pause_intervals']!, _pauseIntervalsMeta));
    }
    if (data.containsKey('phase_started_at')) {
      context.handle(
          _phaseStartedAtMeta,
          phaseStartedAt.isAcceptableOrUnknown(
              data['phase_started_at']!, _phaseStartedAtMeta));
    }
    if (data.containsKey('target_duration_seconds')) {
      context.handle(
          _targetDurationSecondsMeta,
          targetDurationSeconds.isAcceptableOrUnknown(
              data['target_duration_seconds']!, _targetDurationSecondsMeta));
    }
    if (data.containsKey('pomodoro_round')) {
      context.handle(
          _pomodoroRoundMeta,
          pomodoroRound.isAcceptableOrUnknown(
              data['pomodoro_round']!, _pomodoroRoundMeta));
    }
    if (data.containsKey('pomodoro_phase')) {
      context.handle(
          _pomodoroPhaseMeta,
          pomodoroPhase.isAcceptableOrUnknown(
              data['pomodoro_phase']!, _pomodoroPhaseMeta));
    }
    if (data.containsKey('focus_minutes')) {
      context.handle(
          _focusMinutesMeta,
          focusMinutes.isAcceptableOrUnknown(
              data['focus_minutes']!, _focusMinutesMeta));
    }
    if (data.containsKey('short_break_minutes')) {
      context.handle(
          _shortBreakMinutesMeta,
          shortBreakMinutes.isAcceptableOrUnknown(
              data['short_break_minutes']!, _shortBreakMinutesMeta));
    }
    if (data.containsKey('long_break_minutes')) {
      context.handle(
          _longBreakMinutesMeta,
          longBreakMinutes.isAcceptableOrUnknown(
              data['long_break_minutes']!, _longBreakMinutesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalStudySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalStudySession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_id'])!,
      materialId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}material_id']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ended_at']),
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      mode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mode'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      pauseIntervals: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}pause_intervals'])!,
      phaseStartedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}phase_started_at']),
      targetDurationSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}target_duration_seconds']),
      pomodoroRound: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pomodoro_round']),
      pomodoroPhase: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pomodoro_phase']),
      focusMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}focus_minutes'])!,
      shortBreakMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}short_break_minutes'])!,
      longBreakMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}long_break_minutes'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $LocalStudySessionsTable createAlias(String alias) {
    return $LocalStudySessionsTable(attachedDatabase, alias);
  }
}

class LocalStudySession extends DataClass
    implements Insertable<LocalStudySession> {
  final String id;
  final String subjectId;
  final String? materialId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final String mode;
  final String? note;
  final String pauseIntervals;
  final DateTime? phaseStartedAt;
  final int? targetDurationSeconds;
  final int? pomodoroRound;
  final String? pomodoroPhase;
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const LocalStudySession(
      {required this.id,
      required this.subjectId,
      this.materialId,
      required this.startedAt,
      this.endedAt,
      required this.durationSeconds,
      required this.mode,
      this.note,
      required this.pauseIntervals,
      this.phaseStartedAt,
      this.targetDurationSeconds,
      this.pomodoroRound,
      this.pomodoroPhase,
      required this.focusMinutes,
      required this.shortBreakMinutes,
      required this.longBreakMinutes,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_id'] = Variable<String>(subjectId);
    if (!nullToAbsent || materialId != null) {
      map['material_id'] = Variable<String>(materialId);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['mode'] = Variable<String>(mode);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['pause_intervals'] = Variable<String>(pauseIntervals);
    if (!nullToAbsent || phaseStartedAt != null) {
      map['phase_started_at'] = Variable<DateTime>(phaseStartedAt);
    }
    if (!nullToAbsent || targetDurationSeconds != null) {
      map['target_duration_seconds'] = Variable<int>(targetDurationSeconds);
    }
    if (!nullToAbsent || pomodoroRound != null) {
      map['pomodoro_round'] = Variable<int>(pomodoroRound);
    }
    if (!nullToAbsent || pomodoroPhase != null) {
      map['pomodoro_phase'] = Variable<String>(pomodoroPhase);
    }
    map['focus_minutes'] = Variable<int>(focusMinutes);
    map['short_break_minutes'] = Variable<int>(shortBreakMinutes);
    map['long_break_minutes'] = Variable<int>(longBreakMinutes);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  LocalStudySessionsCompanion toCompanion(bool nullToAbsent) {
    return LocalStudySessionsCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      materialId: materialId == null && nullToAbsent
          ? const Value.absent()
          : Value(materialId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationSeconds: Value(durationSeconds),
      mode: Value(mode),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      pauseIntervals: Value(pauseIntervals),
      phaseStartedAt: phaseStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(phaseStartedAt),
      targetDurationSeconds: targetDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDurationSeconds),
      pomodoroRound: pomodoroRound == null && nullToAbsent
          ? const Value.absent()
          : Value(pomodoroRound),
      pomodoroPhase: pomodoroPhase == null && nullToAbsent
          ? const Value.absent()
          : Value(pomodoroPhase),
      focusMinutes: Value(focusMinutes),
      shortBreakMinutes: Value(shortBreakMinutes),
      longBreakMinutes: Value(longBreakMinutes),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalStudySession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalStudySession(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      materialId: serializer.fromJson<String?>(json['materialId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      mode: serializer.fromJson<String>(json['mode']),
      note: serializer.fromJson<String?>(json['note']),
      pauseIntervals: serializer.fromJson<String>(json['pauseIntervals']),
      phaseStartedAt: serializer.fromJson<DateTime?>(json['phaseStartedAt']),
      targetDurationSeconds:
          serializer.fromJson<int?>(json['targetDurationSeconds']),
      pomodoroRound: serializer.fromJson<int?>(json['pomodoroRound']),
      pomodoroPhase: serializer.fromJson<String?>(json['pomodoroPhase']),
      focusMinutes: serializer.fromJson<int>(json['focusMinutes']),
      shortBreakMinutes: serializer.fromJson<int>(json['shortBreakMinutes']),
      longBreakMinutes: serializer.fromJson<int>(json['longBreakMinutes']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'materialId': serializer.toJson<String?>(materialId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'mode': serializer.toJson<String>(mode),
      'note': serializer.toJson<String?>(note),
      'pauseIntervals': serializer.toJson<String>(pauseIntervals),
      'phaseStartedAt': serializer.toJson<DateTime?>(phaseStartedAt),
      'targetDurationSeconds': serializer.toJson<int?>(targetDurationSeconds),
      'pomodoroRound': serializer.toJson<int?>(pomodoroRound),
      'pomodoroPhase': serializer.toJson<String?>(pomodoroPhase),
      'focusMinutes': serializer.toJson<int>(focusMinutes),
      'shortBreakMinutes': serializer.toJson<int>(shortBreakMinutes),
      'longBreakMinutes': serializer.toJson<int>(longBreakMinutes),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  LocalStudySession copyWith(
          {String? id,
          String? subjectId,
          Value<String?> materialId = const Value.absent(),
          DateTime? startedAt,
          Value<DateTime?> endedAt = const Value.absent(),
          int? durationSeconds,
          String? mode,
          Value<String?> note = const Value.absent(),
          String? pauseIntervals,
          Value<DateTime?> phaseStartedAt = const Value.absent(),
          Value<int?> targetDurationSeconds = const Value.absent(),
          Value<int?> pomodoroRound = const Value.absent(),
          Value<String?> pomodoroPhase = const Value.absent(),
          int? focusMinutes,
          int? shortBreakMinutes,
          int? longBreakMinutes,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      LocalStudySession(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        materialId: materialId.present ? materialId.value : this.materialId,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        mode: mode ?? this.mode,
        note: note.present ? note.value : this.note,
        pauseIntervals: pauseIntervals ?? this.pauseIntervals,
        phaseStartedAt:
            phaseStartedAt.present ? phaseStartedAt.value : this.phaseStartedAt,
        targetDurationSeconds: targetDurationSeconds.present
            ? targetDurationSeconds.value
            : this.targetDurationSeconds,
        pomodoroRound:
            pomodoroRound.present ? pomodoroRound.value : this.pomodoroRound,
        pomodoroPhase:
            pomodoroPhase.present ? pomodoroPhase.value : this.pomodoroPhase,
        focusMinutes: focusMinutes ?? this.focusMinutes,
        shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
        longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  LocalStudySession copyWithCompanion(LocalStudySessionsCompanion data) {
    return LocalStudySession(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      materialId:
          data.materialId.present ? data.materialId.value : this.materialId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      mode: data.mode.present ? data.mode.value : this.mode,
      note: data.note.present ? data.note.value : this.note,
      pauseIntervals: data.pauseIntervals.present
          ? data.pauseIntervals.value
          : this.pauseIntervals,
      phaseStartedAt: data.phaseStartedAt.present
          ? data.phaseStartedAt.value
          : this.phaseStartedAt,
      targetDurationSeconds: data.targetDurationSeconds.present
          ? data.targetDurationSeconds.value
          : this.targetDurationSeconds,
      pomodoroRound: data.pomodoroRound.present
          ? data.pomodoroRound.value
          : this.pomodoroRound,
      pomodoroPhase: data.pomodoroPhase.present
          ? data.pomodoroPhase.value
          : this.pomodoroPhase,
      focusMinutes: data.focusMinutes.present
          ? data.focusMinutes.value
          : this.focusMinutes,
      shortBreakMinutes: data.shortBreakMinutes.present
          ? data.shortBreakMinutes.value
          : this.shortBreakMinutes,
      longBreakMinutes: data.longBreakMinutes.present
          ? data.longBreakMinutes.value
          : this.longBreakMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalStudySession(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('materialId: $materialId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('mode: $mode, ')
          ..write('note: $note, ')
          ..write('pauseIntervals: $pauseIntervals, ')
          ..write('phaseStartedAt: $phaseStartedAt, ')
          ..write('targetDurationSeconds: $targetDurationSeconds, ')
          ..write('pomodoroRound: $pomodoroRound, ')
          ..write('pomodoroPhase: $pomodoroPhase, ')
          ..write('focusMinutes: $focusMinutes, ')
          ..write('shortBreakMinutes: $shortBreakMinutes, ')
          ..write('longBreakMinutes: $longBreakMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      subjectId,
      materialId,
      startedAt,
      endedAt,
      durationSeconds,
      mode,
      note,
      pauseIntervals,
      phaseStartedAt,
      targetDurationSeconds,
      pomodoroRound,
      pomodoroPhase,
      focusMinutes,
      shortBreakMinutes,
      longBreakMinutes,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalStudySession &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.materialId == this.materialId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.mode == this.mode &&
          other.note == this.note &&
          other.pauseIntervals == this.pauseIntervals &&
          other.phaseStartedAt == this.phaseStartedAt &&
          other.targetDurationSeconds == this.targetDurationSeconds &&
          other.pomodoroRound == this.pomodoroRound &&
          other.pomodoroPhase == this.pomodoroPhase &&
          other.focusMinutes == this.focusMinutes &&
          other.shortBreakMinutes == this.shortBreakMinutes &&
          other.longBreakMinutes == this.longBreakMinutes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalStudySessionsCompanion extends UpdateCompanion<LocalStudySession> {
  final Value<String> id;
  final Value<String> subjectId;
  final Value<String?> materialId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> durationSeconds;
  final Value<String> mode;
  final Value<String?> note;
  final Value<String> pauseIntervals;
  final Value<DateTime?> phaseStartedAt;
  final Value<int?> targetDurationSeconds;
  final Value<int?> pomodoroRound;
  final Value<String?> pomodoroPhase;
  final Value<int> focusMinutes;
  final Value<int> shortBreakMinutes;
  final Value<int> longBreakMinutes;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const LocalStudySessionsCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.materialId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.mode = const Value.absent(),
    this.note = const Value.absent(),
    this.pauseIntervals = const Value.absent(),
    this.phaseStartedAt = const Value.absent(),
    this.targetDurationSeconds = const Value.absent(),
    this.pomodoroRound = const Value.absent(),
    this.pomodoroPhase = const Value.absent(),
    this.focusMinutes = const Value.absent(),
    this.shortBreakMinutes = const Value.absent(),
    this.longBreakMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalStudySessionsCompanion.insert({
    required String id,
    required String subjectId,
    this.materialId = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.mode = const Value.absent(),
    this.note = const Value.absent(),
    this.pauseIntervals = const Value.absent(),
    this.phaseStartedAt = const Value.absent(),
    this.targetDurationSeconds = const Value.absent(),
    this.pomodoroRound = const Value.absent(),
    this.pomodoroPhase = const Value.absent(),
    this.focusMinutes = const Value.absent(),
    this.shortBreakMinutes = const Value.absent(),
    this.longBreakMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        subjectId = Value(subjectId),
        startedAt = Value(startedAt);
  static Insertable<LocalStudySession> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<String>? materialId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? durationSeconds,
    Expression<String>? mode,
    Expression<String>? note,
    Expression<String>? pauseIntervals,
    Expression<DateTime>? phaseStartedAt,
    Expression<int>? targetDurationSeconds,
    Expression<int>? pomodoroRound,
    Expression<String>? pomodoroPhase,
    Expression<int>? focusMinutes,
    Expression<int>? shortBreakMinutes,
    Expression<int>? longBreakMinutes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (materialId != null) 'material_id': materialId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (mode != null) 'mode': mode,
      if (note != null) 'note': note,
      if (pauseIntervals != null) 'pause_intervals': pauseIntervals,
      if (phaseStartedAt != null) 'phase_started_at': phaseStartedAt,
      if (targetDurationSeconds != null)
        'target_duration_seconds': targetDurationSeconds,
      if (pomodoroRound != null) 'pomodoro_round': pomodoroRound,
      if (pomodoroPhase != null) 'pomodoro_phase': pomodoroPhase,
      if (focusMinutes != null) 'focus_minutes': focusMinutes,
      if (shortBreakMinutes != null) 'short_break_minutes': shortBreakMinutes,
      if (longBreakMinutes != null) 'long_break_minutes': longBreakMinutes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalStudySessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? subjectId,
      Value<String?>? materialId,
      Value<DateTime>? startedAt,
      Value<DateTime?>? endedAt,
      Value<int>? durationSeconds,
      Value<String>? mode,
      Value<String?>? note,
      Value<String>? pauseIntervals,
      Value<DateTime?>? phaseStartedAt,
      Value<int?>? targetDurationSeconds,
      Value<int?>? pomodoroRound,
      Value<String?>? pomodoroPhase,
      Value<int>? focusMinutes,
      Value<int>? shortBreakMinutes,
      Value<int>? longBreakMinutes,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return LocalStudySessionsCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      materialId: materialId ?? this.materialId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      mode: mode ?? this.mode,
      note: note ?? this.note,
      pauseIntervals: pauseIntervals ?? this.pauseIntervals,
      phaseStartedAt: phaseStartedAt ?? this.phaseStartedAt,
      targetDurationSeconds:
          targetDurationSeconds ?? this.targetDurationSeconds,
      pomodoroRound: pomodoroRound ?? this.pomodoroRound,
      pomodoroPhase: pomodoroPhase ?? this.pomodoroPhase,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (materialId.present) {
      map['material_id'] = Variable<String>(materialId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (pauseIntervals.present) {
      map['pause_intervals'] = Variable<String>(pauseIntervals.value);
    }
    if (phaseStartedAt.present) {
      map['phase_started_at'] = Variable<DateTime>(phaseStartedAt.value);
    }
    if (targetDurationSeconds.present) {
      map['target_duration_seconds'] =
          Variable<int>(targetDurationSeconds.value);
    }
    if (pomodoroRound.present) {
      map['pomodoro_round'] = Variable<int>(pomodoroRound.value);
    }
    if (pomodoroPhase.present) {
      map['pomodoro_phase'] = Variable<String>(pomodoroPhase.value);
    }
    if (focusMinutes.present) {
      map['focus_minutes'] = Variable<int>(focusMinutes.value);
    }
    if (shortBreakMinutes.present) {
      map['short_break_minutes'] = Variable<int>(shortBreakMinutes.value);
    }
    if (longBreakMinutes.present) {
      map['long_break_minutes'] = Variable<int>(longBreakMinutes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalStudySessionsCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('materialId: $materialId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('mode: $mode, ')
          ..write('note: $note, ')
          ..write('pauseIntervals: $pauseIntervals, ')
          ..write('phaseStartedAt: $phaseStartedAt, ')
          ..write('targetDurationSeconds: $targetDurationSeconds, ')
          ..write('pomodoroRound: $pomodoroRound, ')
          ..write('pomodoroPhase: $pomodoroPhase, ')
          ..write('focusMinutes: $focusMinutes, ')
          ..write('shortBreakMinutes: $shortBreakMinutes, ')
          ..write('longBreakMinutes: $longBreakMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalNotificationsTable extends LocalNotifications
    with TableInfo<$LocalNotificationsTable, LocalNotification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalNotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageKeyMeta =
      const VerificationMeta('messageKey');
  @override
  late final GeneratedColumn<String> messageKey = GeneratedColumn<String>(
      'message_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _paramsMeta = const VerificationMeta('params');
  @override
  late final GeneratedColumn<String> params = GeneratedColumn<String>(
      'params', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _routeMeta = const VerificationMeta('route');
  @override
  late final GeneratedColumn<String> route = GeneratedColumn<String>(
      'route', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dedupeKeyMeta =
      const VerificationMeta('dedupeKey');
  @override
  late final GeneratedColumn<String> dedupeKey = GeneratedColumn<String>(
      'dedupe_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
      'read_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, messageKey, params, route, dedupeKey, createdAt, readAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(Insertable<LocalNotification> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('message_key')) {
      context.handle(
          _messageKeyMeta,
          messageKey.isAcceptableOrUnknown(
              data['message_key']!, _messageKeyMeta));
    } else if (isInserting) {
      context.missing(_messageKeyMeta);
    }
    if (data.containsKey('params')) {
      context.handle(_paramsMeta,
          params.isAcceptableOrUnknown(data['params']!, _paramsMeta));
    }
    if (data.containsKey('route')) {
      context.handle(
          _routeMeta, route.isAcceptableOrUnknown(data['route']!, _routeMeta));
    } else if (isInserting) {
      context.missing(_routeMeta);
    }
    if (data.containsKey('dedupe_key')) {
      context.handle(_dedupeKeyMeta,
          dedupeKey.isAcceptableOrUnknown(data['dedupe_key']!, _dedupeKeyMeta));
    } else if (isInserting) {
      context.missing(_dedupeKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(_readAtMeta,
          readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalNotification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalNotification(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      messageKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_key'])!,
      params: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}params'])!,
      route: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}route'])!,
      dedupeKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dedupe_key'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      readAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}read_at']),
    );
  }

  @override
  $LocalNotificationsTable createAlias(String alias) {
    return $LocalNotificationsTable(attachedDatabase, alias);
  }
}

class LocalNotification extends DataClass
    implements Insertable<LocalNotification> {
  final String id;
  final String type;
  final String messageKey;
  final String params;
  final String route;
  final String dedupeKey;
  final DateTime createdAt;
  final DateTime? readAt;
  const LocalNotification(
      {required this.id,
      required this.type,
      required this.messageKey,
      required this.params,
      required this.route,
      required this.dedupeKey,
      required this.createdAt,
      this.readAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['message_key'] = Variable<String>(messageKey);
    map['params'] = Variable<String>(params);
    map['route'] = Variable<String>(route);
    map['dedupe_key'] = Variable<String>(dedupeKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    return map;
  }

  LocalNotificationsCompanion toCompanion(bool nullToAbsent) {
    return LocalNotificationsCompanion(
      id: Value(id),
      type: Value(type),
      messageKey: Value(messageKey),
      params: Value(params),
      route: Value(route),
      dedupeKey: Value(dedupeKey),
      createdAt: Value(createdAt),
      readAt:
          readAt == null && nullToAbsent ? const Value.absent() : Value(readAt),
    );
  }

  factory LocalNotification.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalNotification(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      messageKey: serializer.fromJson<String>(json['messageKey']),
      params: serializer.fromJson<String>(json['params']),
      route: serializer.fromJson<String>(json['route']),
      dedupeKey: serializer.fromJson<String>(json['dedupeKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'messageKey': serializer.toJson<String>(messageKey),
      'params': serializer.toJson<String>(params),
      'route': serializer.toJson<String>(route),
      'dedupeKey': serializer.toJson<String>(dedupeKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'readAt': serializer.toJson<DateTime?>(readAt),
    };
  }

  LocalNotification copyWith(
          {String? id,
          String? type,
          String? messageKey,
          String? params,
          String? route,
          String? dedupeKey,
          DateTime? createdAt,
          Value<DateTime?> readAt = const Value.absent()}) =>
      LocalNotification(
        id: id ?? this.id,
        type: type ?? this.type,
        messageKey: messageKey ?? this.messageKey,
        params: params ?? this.params,
        route: route ?? this.route,
        dedupeKey: dedupeKey ?? this.dedupeKey,
        createdAt: createdAt ?? this.createdAt,
        readAt: readAt.present ? readAt.value : this.readAt,
      );
  LocalNotification copyWithCompanion(LocalNotificationsCompanion data) {
    return LocalNotification(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      messageKey:
          data.messageKey.present ? data.messageKey.value : this.messageKey,
      params: data.params.present ? data.params.value : this.params,
      route: data.route.present ? data.route.value : this.route,
      dedupeKey: data.dedupeKey.present ? data.dedupeKey.value : this.dedupeKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalNotification(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('messageKey: $messageKey, ')
          ..write('params: $params, ')
          ..write('route: $route, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, type, messageKey, params, route, dedupeKey, createdAt, readAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalNotification &&
          other.id == this.id &&
          other.type == this.type &&
          other.messageKey == this.messageKey &&
          other.params == this.params &&
          other.route == this.route &&
          other.dedupeKey == this.dedupeKey &&
          other.createdAt == this.createdAt &&
          other.readAt == this.readAt);
}

class LocalNotificationsCompanion extends UpdateCompanion<LocalNotification> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> messageKey;
  final Value<String> params;
  final Value<String> route;
  final Value<String> dedupeKey;
  final Value<DateTime> createdAt;
  final Value<DateTime?> readAt;
  final Value<int> rowid;
  const LocalNotificationsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.messageKey = const Value.absent(),
    this.params = const Value.absent(),
    this.route = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalNotificationsCompanion.insert({
    required String id,
    required String type,
    required String messageKey,
    this.params = const Value.absent(),
    required String route,
    required String dedupeKey,
    required DateTime createdAt,
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        messageKey = Value(messageKey),
        route = Value(route),
        dedupeKey = Value(dedupeKey),
        createdAt = Value(createdAt);
  static Insertable<LocalNotification> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? messageKey,
    Expression<String>? params,
    Expression<String>? route,
    Expression<String>? dedupeKey,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? readAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (messageKey != null) 'message_key': messageKey,
      if (params != null) 'params': params,
      if (route != null) 'route': route,
      if (dedupeKey != null) 'dedupe_key': dedupeKey,
      if (createdAt != null) 'created_at': createdAt,
      if (readAt != null) 'read_at': readAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalNotificationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? messageKey,
      Value<String>? params,
      Value<String>? route,
      Value<String>? dedupeKey,
      Value<DateTime>? createdAt,
      Value<DateTime?>? readAt,
      Value<int>? rowid}) {
    return LocalNotificationsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      messageKey: messageKey ?? this.messageKey,
      params: params ?? this.params,
      route: route ?? this.route,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (messageKey.present) {
      map['message_key'] = Variable<String>(messageKey.value);
    }
    if (params.present) {
      map['params'] = Variable<String>(params.value);
    }
    if (route.present) {
      map['route'] = Variable<String>(route.value);
    }
    if (dedupeKey.present) {
      map['dedupe_key'] = Variable<String>(dedupeKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalNotificationsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('messageKey: $messageKey, ')
          ..write('params: $params, ')
          ..write('route: $route, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('readAt: $readAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPortalAccountsTable extends LocalPortalAccounts
    with TableInfo<$LocalPortalAccountsTable, LocalPortalAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPortalAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _circularIdMeta =
      const VerificationMeta('circularId');
  @override
  late final GeneratedColumn<String> circularId = GeneratedColumn<String>(
      'circular_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _portalUrlMeta =
      const VerificationMeta('portalUrl');
  @override
  late final GeneratedColumn<String> portalUrl = GeneratedColumn<String>(
      'portal_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _encryptedPasswordMeta =
      const VerificationMeta('encryptedPassword');
  @override
  late final GeneratedColumn<String> encryptedPassword =
      GeneratedColumn<String>('encrypted_password', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<String> salt = GeneratedColumn<String>(
      'salt', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nonceMeta = const VerificationMeta('nonce');
  @override
  late final GeneratedColumn<String> nonce = GeneratedColumn<String>(
      'nonce', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iterationsMeta =
      const VerificationMeta('iterations');
  @override
  late final GeneratedColumn<int> iterations = GeneratedColumn<int>(
      'iterations', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(210000));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        circularId,
        portalUrl,
        username,
        encryptedPassword,
        salt,
        nonce,
        iterations,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'portal_accounts';
  @override
  VerificationContext validateIntegrity(Insertable<LocalPortalAccount> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('circular_id')) {
      context.handle(
          _circularIdMeta,
          circularId.isAcceptableOrUnknown(
              data['circular_id']!, _circularIdMeta));
    } else if (isInserting) {
      context.missing(_circularIdMeta);
    }
    if (data.containsKey('portal_url')) {
      context.handle(_portalUrlMeta,
          portalUrl.isAcceptableOrUnknown(data['portal_url']!, _portalUrlMeta));
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('encrypted_password')) {
      context.handle(
          _encryptedPasswordMeta,
          encryptedPassword.isAcceptableOrUnknown(
              data['encrypted_password']!, _encryptedPasswordMeta));
    } else if (isInserting) {
      context.missing(_encryptedPasswordMeta);
    }
    if (data.containsKey('salt')) {
      context.handle(
          _saltMeta, salt.isAcceptableOrUnknown(data['salt']!, _saltMeta));
    } else if (isInserting) {
      context.missing(_saltMeta);
    }
    if (data.containsKey('nonce')) {
      context.handle(
          _nonceMeta, nonce.isAcceptableOrUnknown(data['nonce']!, _nonceMeta));
    } else if (isInserting) {
      context.missing(_nonceMeta);
    }
    if (data.containsKey('iterations')) {
      context.handle(
          _iterationsMeta,
          iterations.isAcceptableOrUnknown(
              data['iterations']!, _iterationsMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPortalAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPortalAccount(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      circularId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}circular_id'])!,
      portalUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}portal_url']),
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      encryptedPassword: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}encrypted_password'])!,
      salt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}salt'])!,
      nonce: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nonce'])!,
      iterations: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}iterations'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $LocalPortalAccountsTable createAlias(String alias) {
    return $LocalPortalAccountsTable(attachedDatabase, alias);
  }
}

class LocalPortalAccount extends DataClass
    implements Insertable<LocalPortalAccount> {
  final String id;
  final String circularId;
  final String? portalUrl;
  final String username;
  final String encryptedPassword;
  final String salt;
  final String nonce;
  final int iterations;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const LocalPortalAccount(
      {required this.id,
      required this.circularId,
      this.portalUrl,
      required this.username,
      required this.encryptedPassword,
      required this.salt,
      required this.nonce,
      required this.iterations,
      this.notes,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['circular_id'] = Variable<String>(circularId);
    if (!nullToAbsent || portalUrl != null) {
      map['portal_url'] = Variable<String>(portalUrl);
    }
    map['username'] = Variable<String>(username);
    map['encrypted_password'] = Variable<String>(encryptedPassword);
    map['salt'] = Variable<String>(salt);
    map['nonce'] = Variable<String>(nonce);
    map['iterations'] = Variable<int>(iterations);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  LocalPortalAccountsCompanion toCompanion(bool nullToAbsent) {
    return LocalPortalAccountsCompanion(
      id: Value(id),
      circularId: Value(circularId),
      portalUrl: portalUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(portalUrl),
      username: Value(username),
      encryptedPassword: Value(encryptedPassword),
      salt: Value(salt),
      nonce: Value(nonce),
      iterations: Value(iterations),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalPortalAccount.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPortalAccount(
      id: serializer.fromJson<String>(json['id']),
      circularId: serializer.fromJson<String>(json['circularId']),
      portalUrl: serializer.fromJson<String?>(json['portalUrl']),
      username: serializer.fromJson<String>(json['username']),
      encryptedPassword: serializer.fromJson<String>(json['encryptedPassword']),
      salt: serializer.fromJson<String>(json['salt']),
      nonce: serializer.fromJson<String>(json['nonce']),
      iterations: serializer.fromJson<int>(json['iterations']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'circularId': serializer.toJson<String>(circularId),
      'portalUrl': serializer.toJson<String?>(portalUrl),
      'username': serializer.toJson<String>(username),
      'encryptedPassword': serializer.toJson<String>(encryptedPassword),
      'salt': serializer.toJson<String>(salt),
      'nonce': serializer.toJson<String>(nonce),
      'iterations': serializer.toJson<int>(iterations),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  LocalPortalAccount copyWith(
          {String? id,
          String? circularId,
          Value<String?> portalUrl = const Value.absent(),
          String? username,
          String? encryptedPassword,
          String? salt,
          String? nonce,
          int? iterations,
          Value<String?> notes = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      LocalPortalAccount(
        id: id ?? this.id,
        circularId: circularId ?? this.circularId,
        portalUrl: portalUrl.present ? portalUrl.value : this.portalUrl,
        username: username ?? this.username,
        encryptedPassword: encryptedPassword ?? this.encryptedPassword,
        salt: salt ?? this.salt,
        nonce: nonce ?? this.nonce,
        iterations: iterations ?? this.iterations,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  LocalPortalAccount copyWithCompanion(LocalPortalAccountsCompanion data) {
    return LocalPortalAccount(
      id: data.id.present ? data.id.value : this.id,
      circularId:
          data.circularId.present ? data.circularId.value : this.circularId,
      portalUrl: data.portalUrl.present ? data.portalUrl.value : this.portalUrl,
      username: data.username.present ? data.username.value : this.username,
      encryptedPassword: data.encryptedPassword.present
          ? data.encryptedPassword.value
          : this.encryptedPassword,
      salt: data.salt.present ? data.salt.value : this.salt,
      nonce: data.nonce.present ? data.nonce.value : this.nonce,
      iterations:
          data.iterations.present ? data.iterations.value : this.iterations,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPortalAccount(')
          ..write('id: $id, ')
          ..write('circularId: $circularId, ')
          ..write('portalUrl: $portalUrl, ')
          ..write('username: $username, ')
          ..write('encryptedPassword: $encryptedPassword, ')
          ..write('salt: $salt, ')
          ..write('nonce: $nonce, ')
          ..write('iterations: $iterations, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, circularId, portalUrl, username,
      encryptedPassword, salt, nonce, iterations, notes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPortalAccount &&
          other.id == this.id &&
          other.circularId == this.circularId &&
          other.portalUrl == this.portalUrl &&
          other.username == this.username &&
          other.encryptedPassword == this.encryptedPassword &&
          other.salt == this.salt &&
          other.nonce == this.nonce &&
          other.iterations == this.iterations &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalPortalAccountsCompanion extends UpdateCompanion<LocalPortalAccount> {
  final Value<String> id;
  final Value<String> circularId;
  final Value<String?> portalUrl;
  final Value<String> username;
  final Value<String> encryptedPassword;
  final Value<String> salt;
  final Value<String> nonce;
  final Value<int> iterations;
  final Value<String?> notes;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const LocalPortalAccountsCompanion({
    this.id = const Value.absent(),
    this.circularId = const Value.absent(),
    this.portalUrl = const Value.absent(),
    this.username = const Value.absent(),
    this.encryptedPassword = const Value.absent(),
    this.salt = const Value.absent(),
    this.nonce = const Value.absent(),
    this.iterations = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPortalAccountsCompanion.insert({
    required String id,
    required String circularId,
    this.portalUrl = const Value.absent(),
    required String username,
    required String encryptedPassword,
    required String salt,
    required String nonce,
    this.iterations = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        circularId = Value(circularId),
        username = Value(username),
        encryptedPassword = Value(encryptedPassword),
        salt = Value(salt),
        nonce = Value(nonce);
  static Insertable<LocalPortalAccount> custom({
    Expression<String>? id,
    Expression<String>? circularId,
    Expression<String>? portalUrl,
    Expression<String>? username,
    Expression<String>? encryptedPassword,
    Expression<String>? salt,
    Expression<String>? nonce,
    Expression<int>? iterations,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (circularId != null) 'circular_id': circularId,
      if (portalUrl != null) 'portal_url': portalUrl,
      if (username != null) 'username': username,
      if (encryptedPassword != null) 'encrypted_password': encryptedPassword,
      if (salt != null) 'salt': salt,
      if (nonce != null) 'nonce': nonce,
      if (iterations != null) 'iterations': iterations,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPortalAccountsCompanion copyWith(
      {Value<String>? id,
      Value<String>? circularId,
      Value<String?>? portalUrl,
      Value<String>? username,
      Value<String>? encryptedPassword,
      Value<String>? salt,
      Value<String>? nonce,
      Value<int>? iterations,
      Value<String?>? notes,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return LocalPortalAccountsCompanion(
      id: id ?? this.id,
      circularId: circularId ?? this.circularId,
      portalUrl: portalUrl ?? this.portalUrl,
      username: username ?? this.username,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      salt: salt ?? this.salt,
      nonce: nonce ?? this.nonce,
      iterations: iterations ?? this.iterations,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (circularId.present) {
      map['circular_id'] = Variable<String>(circularId.value);
    }
    if (portalUrl.present) {
      map['portal_url'] = Variable<String>(portalUrl.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (encryptedPassword.present) {
      map['encrypted_password'] = Variable<String>(encryptedPassword.value);
    }
    if (salt.present) {
      map['salt'] = Variable<String>(salt.value);
    }
    if (nonce.present) {
      map['nonce'] = Variable<String>(nonce.value);
    }
    if (iterations.present) {
      map['iterations'] = Variable<int>(iterations.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPortalAccountsCompanion(')
          ..write('id: $id, ')
          ..write('circularId: $circularId, ')
          ..write('portalUrl: $portalUrl, ')
          ..write('username: $username, ')
          ..write('encryptedPassword: $encryptedPassword, ')
          ..write('salt: $salt, ')
          ..write('nonce: $nonce, ')
          ..write('iterations: $iterations, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalUserSettingsTable extends LocalUserSettings
    with TableInfo<$LocalUserSettingsTable, LocalUserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _onboardingCompletedAtMeta =
      const VerificationMeta('onboardingCompletedAt');
  @override
  late final GeneratedColumn<DateTime> onboardingCompletedAt =
      GeneratedColumn<DateTime>('onboarding_completed_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _onboardingStepMeta =
      const VerificationMeta('onboardingStep');
  @override
  late final GeneratedColumn<int> onboardingStep = GeneratedColumn<int>(
      'onboarding_step', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _onboardingDraftMeta =
      const VerificationMeta('onboardingDraft');
  @override
  late final GeneratedColumn<String> onboardingDraft = GeneratedColumn<String>(
      'onboarding_draft', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _todayTipsDismissedMeta =
      const VerificationMeta('todayTipsDismissed');
  @override
  late final GeneratedColumn<bool> todayTipsDismissed = GeneratedColumn<bool>(
      'today_tips_dismissed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("today_tips_dismissed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _themeModeMeta =
      const VerificationMeta('themeMode');
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
      'theme_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('system'));
  static const VerificationMeta _reduceEffectsMeta =
      const VerificationMeta('reduceEffects');
  @override
  late final GeneratedColumn<bool> reduceEffects = GeneratedColumn<bool>(
      'reduce_effects', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("reduce_effects" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _localeCodeMeta =
      const VerificationMeta('localeCode');
  @override
  late final GeneratedColumn<String> localeCode = GeneratedColumn<String>(
      'locale_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en'));
  static const VerificationMeta _banglaDigitsMeta =
      const VerificationMeta('banglaDigits');
  @override
  late final GeneratedColumn<bool> banglaDigits = GeneratedColumn<bool>(
      'bangla_digits', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("bangla_digits" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _focusMinutesMeta =
      const VerificationMeta('focusMinutes');
  @override
  late final GeneratedColumn<int> focusMinutes = GeneratedColumn<int>(
      'focus_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(25));
  static const VerificationMeta _shortBreakMinutesMeta =
      const VerificationMeta('shortBreakMinutes');
  @override
  late final GeneratedColumn<int> shortBreakMinutes = GeneratedColumn<int>(
      'short_break_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  static const VerificationMeta _longBreakMinutesMeta =
      const VerificationMeta('longBreakMinutes');
  @override
  late final GeneratedColumn<int> longBreakMinutes = GeneratedColumn<int>(
      'long_break_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(15));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        onboardingCompletedAt,
        onboardingStep,
        onboardingDraft,
        todayTipsDismissed,
        displayName,
        themeMode,
        reduceEffects,
        localeCode,
        banglaDigits,
        focusMinutes,
        shortBreakMinutes,
        longBreakMinutes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(Insertable<LocalUserSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('onboarding_completed_at')) {
      context.handle(
          _onboardingCompletedAtMeta,
          onboardingCompletedAt.isAcceptableOrUnknown(
              data['onboarding_completed_at']!, _onboardingCompletedAtMeta));
    }
    if (data.containsKey('onboarding_step')) {
      context.handle(
          _onboardingStepMeta,
          onboardingStep.isAcceptableOrUnknown(
              data['onboarding_step']!, _onboardingStepMeta));
    }
    if (data.containsKey('onboarding_draft')) {
      context.handle(
          _onboardingDraftMeta,
          onboardingDraft.isAcceptableOrUnknown(
              data['onboarding_draft']!, _onboardingDraftMeta));
    }
    if (data.containsKey('today_tips_dismissed')) {
      context.handle(
          _todayTipsDismissedMeta,
          todayTipsDismissed.isAcceptableOrUnknown(
              data['today_tips_dismissed']!, _todayTipsDismissedMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    }
    if (data.containsKey('theme_mode')) {
      context.handle(_themeModeMeta,
          themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta));
    }
    if (data.containsKey('reduce_effects')) {
      context.handle(
          _reduceEffectsMeta,
          reduceEffects.isAcceptableOrUnknown(
              data['reduce_effects']!, _reduceEffectsMeta));
    }
    if (data.containsKey('locale_code')) {
      context.handle(
          _localeCodeMeta,
          localeCode.isAcceptableOrUnknown(
              data['locale_code']!, _localeCodeMeta));
    }
    if (data.containsKey('bangla_digits')) {
      context.handle(
          _banglaDigitsMeta,
          banglaDigits.isAcceptableOrUnknown(
              data['bangla_digits']!, _banglaDigitsMeta));
    }
    if (data.containsKey('focus_minutes')) {
      context.handle(
          _focusMinutesMeta,
          focusMinutes.isAcceptableOrUnknown(
              data['focus_minutes']!, _focusMinutesMeta));
    }
    if (data.containsKey('short_break_minutes')) {
      context.handle(
          _shortBreakMinutesMeta,
          shortBreakMinutes.isAcceptableOrUnknown(
              data['short_break_minutes']!, _shortBreakMinutesMeta));
    }
    if (data.containsKey('long_break_minutes')) {
      context.handle(
          _longBreakMinutesMeta,
          longBreakMinutes.isAcceptableOrUnknown(
              data['long_break_minutes']!, _longBreakMinutesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalUserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUserSetting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      onboardingCompletedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}onboarding_completed_at']),
      onboardingStep: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}onboarding_step'])!,
      onboardingDraft: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}onboarding_draft'])!,
      todayTipsDismissed: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}today_tips_dismissed'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name']),
      themeMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme_mode'])!,
      reduceEffects: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}reduce_effects'])!,
      localeCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}locale_code'])!,
      banglaDigits: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}bangla_digits'])!,
      focusMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}focus_minutes'])!,
      shortBreakMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}short_break_minutes'])!,
      longBreakMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}long_break_minutes'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $LocalUserSettingsTable createAlias(String alias) {
    return $LocalUserSettingsTable(attachedDatabase, alias);
  }
}

class LocalUserSetting extends DataClass
    implements Insertable<LocalUserSetting> {
  final String id;
  final DateTime? onboardingCompletedAt;
  final int onboardingStep;
  final String onboardingDraft;
  final bool todayTipsDismissed;
  final String? displayName;
  final String themeMode;
  final bool reduceEffects;
  final String localeCode;
  final bool banglaDigits;
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const LocalUserSetting(
      {required this.id,
      this.onboardingCompletedAt,
      required this.onboardingStep,
      required this.onboardingDraft,
      required this.todayTipsDismissed,
      this.displayName,
      required this.themeMode,
      required this.reduceEffects,
      required this.localeCode,
      required this.banglaDigits,
      required this.focusMinutes,
      required this.shortBreakMinutes,
      required this.longBreakMinutes,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || onboardingCompletedAt != null) {
      map['onboarding_completed_at'] =
          Variable<DateTime>(onboardingCompletedAt);
    }
    map['onboarding_step'] = Variable<int>(onboardingStep);
    map['onboarding_draft'] = Variable<String>(onboardingDraft);
    map['today_tips_dismissed'] = Variable<bool>(todayTipsDismissed);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['theme_mode'] = Variable<String>(themeMode);
    map['reduce_effects'] = Variable<bool>(reduceEffects);
    map['locale_code'] = Variable<String>(localeCode);
    map['bangla_digits'] = Variable<bool>(banglaDigits);
    map['focus_minutes'] = Variable<int>(focusMinutes);
    map['short_break_minutes'] = Variable<int>(shortBreakMinutes);
    map['long_break_minutes'] = Variable<int>(longBreakMinutes);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  LocalUserSettingsCompanion toCompanion(bool nullToAbsent) {
    return LocalUserSettingsCompanion(
      id: Value(id),
      onboardingCompletedAt: onboardingCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(onboardingCompletedAt),
      onboardingStep: Value(onboardingStep),
      onboardingDraft: Value(onboardingDraft),
      todayTipsDismissed: Value(todayTipsDismissed),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      themeMode: Value(themeMode),
      reduceEffects: Value(reduceEffects),
      localeCode: Value(localeCode),
      banglaDigits: Value(banglaDigits),
      focusMinutes: Value(focusMinutes),
      shortBreakMinutes: Value(shortBreakMinutes),
      longBreakMinutes: Value(longBreakMinutes),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalUserSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUserSetting(
      id: serializer.fromJson<String>(json['id']),
      onboardingCompletedAt:
          serializer.fromJson<DateTime?>(json['onboardingCompletedAt']),
      onboardingStep: serializer.fromJson<int>(json['onboardingStep']),
      onboardingDraft: serializer.fromJson<String>(json['onboardingDraft']),
      todayTipsDismissed: serializer.fromJson<bool>(json['todayTipsDismissed']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      reduceEffects: serializer.fromJson<bool>(json['reduceEffects']),
      localeCode: serializer.fromJson<String>(json['localeCode']),
      banglaDigits: serializer.fromJson<bool>(json['banglaDigits']),
      focusMinutes: serializer.fromJson<int>(json['focusMinutes']),
      shortBreakMinutes: serializer.fromJson<int>(json['shortBreakMinutes']),
      longBreakMinutes: serializer.fromJson<int>(json['longBreakMinutes']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'onboardingCompletedAt':
          serializer.toJson<DateTime?>(onboardingCompletedAt),
      'onboardingStep': serializer.toJson<int>(onboardingStep),
      'onboardingDraft': serializer.toJson<String>(onboardingDraft),
      'todayTipsDismissed': serializer.toJson<bool>(todayTipsDismissed),
      'displayName': serializer.toJson<String?>(displayName),
      'themeMode': serializer.toJson<String>(themeMode),
      'reduceEffects': serializer.toJson<bool>(reduceEffects),
      'localeCode': serializer.toJson<String>(localeCode),
      'banglaDigits': serializer.toJson<bool>(banglaDigits),
      'focusMinutes': serializer.toJson<int>(focusMinutes),
      'shortBreakMinutes': serializer.toJson<int>(shortBreakMinutes),
      'longBreakMinutes': serializer.toJson<int>(longBreakMinutes),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  LocalUserSetting copyWith(
          {String? id,
          Value<DateTime?> onboardingCompletedAt = const Value.absent(),
          int? onboardingStep,
          String? onboardingDraft,
          bool? todayTipsDismissed,
          Value<String?> displayName = const Value.absent(),
          String? themeMode,
          bool? reduceEffects,
          String? localeCode,
          bool? banglaDigits,
          int? focusMinutes,
          int? shortBreakMinutes,
          int? longBreakMinutes,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      LocalUserSetting(
        id: id ?? this.id,
        onboardingCompletedAt: onboardingCompletedAt.present
            ? onboardingCompletedAt.value
            : this.onboardingCompletedAt,
        onboardingStep: onboardingStep ?? this.onboardingStep,
        onboardingDraft: onboardingDraft ?? this.onboardingDraft,
        todayTipsDismissed: todayTipsDismissed ?? this.todayTipsDismissed,
        displayName: displayName.present ? displayName.value : this.displayName,
        themeMode: themeMode ?? this.themeMode,
        reduceEffects: reduceEffects ?? this.reduceEffects,
        localeCode: localeCode ?? this.localeCode,
        banglaDigits: banglaDigits ?? this.banglaDigits,
        focusMinutes: focusMinutes ?? this.focusMinutes,
        shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
        longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  LocalUserSetting copyWithCompanion(LocalUserSettingsCompanion data) {
    return LocalUserSetting(
      id: data.id.present ? data.id.value : this.id,
      onboardingCompletedAt: data.onboardingCompletedAt.present
          ? data.onboardingCompletedAt.value
          : this.onboardingCompletedAt,
      onboardingStep: data.onboardingStep.present
          ? data.onboardingStep.value
          : this.onboardingStep,
      onboardingDraft: data.onboardingDraft.present
          ? data.onboardingDraft.value
          : this.onboardingDraft,
      todayTipsDismissed: data.todayTipsDismissed.present
          ? data.todayTipsDismissed.value
          : this.todayTipsDismissed,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      reduceEffects: data.reduceEffects.present
          ? data.reduceEffects.value
          : this.reduceEffects,
      localeCode:
          data.localeCode.present ? data.localeCode.value : this.localeCode,
      banglaDigits: data.banglaDigits.present
          ? data.banglaDigits.value
          : this.banglaDigits,
      focusMinutes: data.focusMinutes.present
          ? data.focusMinutes.value
          : this.focusMinutes,
      shortBreakMinutes: data.shortBreakMinutes.present
          ? data.shortBreakMinutes.value
          : this.shortBreakMinutes,
      longBreakMinutes: data.longBreakMinutes.present
          ? data.longBreakMinutes.value
          : this.longBreakMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserSetting(')
          ..write('id: $id, ')
          ..write('onboardingCompletedAt: $onboardingCompletedAt, ')
          ..write('onboardingStep: $onboardingStep, ')
          ..write('onboardingDraft: $onboardingDraft, ')
          ..write('todayTipsDismissed: $todayTipsDismissed, ')
          ..write('displayName: $displayName, ')
          ..write('themeMode: $themeMode, ')
          ..write('reduceEffects: $reduceEffects, ')
          ..write('localeCode: $localeCode, ')
          ..write('banglaDigits: $banglaDigits, ')
          ..write('focusMinutes: $focusMinutes, ')
          ..write('shortBreakMinutes: $shortBreakMinutes, ')
          ..write('longBreakMinutes: $longBreakMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      onboardingCompletedAt,
      onboardingStep,
      onboardingDraft,
      todayTipsDismissed,
      displayName,
      themeMode,
      reduceEffects,
      localeCode,
      banglaDigits,
      focusMinutes,
      shortBreakMinutes,
      longBreakMinutes,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUserSetting &&
          other.id == this.id &&
          other.onboardingCompletedAt == this.onboardingCompletedAt &&
          other.onboardingStep == this.onboardingStep &&
          other.onboardingDraft == this.onboardingDraft &&
          other.todayTipsDismissed == this.todayTipsDismissed &&
          other.displayName == this.displayName &&
          other.themeMode == this.themeMode &&
          other.reduceEffects == this.reduceEffects &&
          other.localeCode == this.localeCode &&
          other.banglaDigits == this.banglaDigits &&
          other.focusMinutes == this.focusMinutes &&
          other.shortBreakMinutes == this.shortBreakMinutes &&
          other.longBreakMinutes == this.longBreakMinutes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalUserSettingsCompanion extends UpdateCompanion<LocalUserSetting> {
  final Value<String> id;
  final Value<DateTime?> onboardingCompletedAt;
  final Value<int> onboardingStep;
  final Value<String> onboardingDraft;
  final Value<bool> todayTipsDismissed;
  final Value<String?> displayName;
  final Value<String> themeMode;
  final Value<bool> reduceEffects;
  final Value<String> localeCode;
  final Value<bool> banglaDigits;
  final Value<int> focusMinutes;
  final Value<int> shortBreakMinutes;
  final Value<int> longBreakMinutes;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const LocalUserSettingsCompanion({
    this.id = const Value.absent(),
    this.onboardingCompletedAt = const Value.absent(),
    this.onboardingStep = const Value.absent(),
    this.onboardingDraft = const Value.absent(),
    this.todayTipsDismissed = const Value.absent(),
    this.displayName = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.reduceEffects = const Value.absent(),
    this.localeCode = const Value.absent(),
    this.banglaDigits = const Value.absent(),
    this.focusMinutes = const Value.absent(),
    this.shortBreakMinutes = const Value.absent(),
    this.longBreakMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUserSettingsCompanion.insert({
    required String id,
    this.onboardingCompletedAt = const Value.absent(),
    this.onboardingStep = const Value.absent(),
    this.onboardingDraft = const Value.absent(),
    this.todayTipsDismissed = const Value.absent(),
    this.displayName = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.reduceEffects = const Value.absent(),
    this.localeCode = const Value.absent(),
    this.banglaDigits = const Value.absent(),
    this.focusMinutes = const Value.absent(),
    this.shortBreakMinutes = const Value.absent(),
    this.longBreakMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<LocalUserSetting> custom({
    Expression<String>? id,
    Expression<DateTime>? onboardingCompletedAt,
    Expression<int>? onboardingStep,
    Expression<String>? onboardingDraft,
    Expression<bool>? todayTipsDismissed,
    Expression<String>? displayName,
    Expression<String>? themeMode,
    Expression<bool>? reduceEffects,
    Expression<String>? localeCode,
    Expression<bool>? banglaDigits,
    Expression<int>? focusMinutes,
    Expression<int>? shortBreakMinutes,
    Expression<int>? longBreakMinutes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (onboardingCompletedAt != null)
        'onboarding_completed_at': onboardingCompletedAt,
      if (onboardingStep != null) 'onboarding_step': onboardingStep,
      if (onboardingDraft != null) 'onboarding_draft': onboardingDraft,
      if (todayTipsDismissed != null)
        'today_tips_dismissed': todayTipsDismissed,
      if (displayName != null) 'display_name': displayName,
      if (themeMode != null) 'theme_mode': themeMode,
      if (reduceEffects != null) 'reduce_effects': reduceEffects,
      if (localeCode != null) 'locale_code': localeCode,
      if (banglaDigits != null) 'bangla_digits': banglaDigits,
      if (focusMinutes != null) 'focus_minutes': focusMinutes,
      if (shortBreakMinutes != null) 'short_break_minutes': shortBreakMinutes,
      if (longBreakMinutes != null) 'long_break_minutes': longBreakMinutes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUserSettingsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime?>? onboardingCompletedAt,
      Value<int>? onboardingStep,
      Value<String>? onboardingDraft,
      Value<bool>? todayTipsDismissed,
      Value<String?>? displayName,
      Value<String>? themeMode,
      Value<bool>? reduceEffects,
      Value<String>? localeCode,
      Value<bool>? banglaDigits,
      Value<int>? focusMinutes,
      Value<int>? shortBreakMinutes,
      Value<int>? longBreakMinutes,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return LocalUserSettingsCompanion(
      id: id ?? this.id,
      onboardingCompletedAt:
          onboardingCompletedAt ?? this.onboardingCompletedAt,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      onboardingDraft: onboardingDraft ?? this.onboardingDraft,
      todayTipsDismissed: todayTipsDismissed ?? this.todayTipsDismissed,
      displayName: displayName ?? this.displayName,
      themeMode: themeMode ?? this.themeMode,
      reduceEffects: reduceEffects ?? this.reduceEffects,
      localeCode: localeCode ?? this.localeCode,
      banglaDigits: banglaDigits ?? this.banglaDigits,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (onboardingCompletedAt.present) {
      map['onboarding_completed_at'] =
          Variable<DateTime>(onboardingCompletedAt.value);
    }
    if (onboardingStep.present) {
      map['onboarding_step'] = Variable<int>(onboardingStep.value);
    }
    if (onboardingDraft.present) {
      map['onboarding_draft'] = Variable<String>(onboardingDraft.value);
    }
    if (todayTipsDismissed.present) {
      map['today_tips_dismissed'] = Variable<bool>(todayTipsDismissed.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (reduceEffects.present) {
      map['reduce_effects'] = Variable<bool>(reduceEffects.value);
    }
    if (localeCode.present) {
      map['locale_code'] = Variable<String>(localeCode.value);
    }
    if (banglaDigits.present) {
      map['bangla_digits'] = Variable<bool>(banglaDigits.value);
    }
    if (focusMinutes.present) {
      map['focus_minutes'] = Variable<int>(focusMinutes.value);
    }
    if (shortBreakMinutes.present) {
      map['short_break_minutes'] = Variable<int>(shortBreakMinutes.value);
    }
    if (longBreakMinutes.present) {
      map['long_break_minutes'] = Variable<int>(longBreakMinutes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserSettingsCompanion(')
          ..write('id: $id, ')
          ..write('onboardingCompletedAt: $onboardingCompletedAt, ')
          ..write('onboardingStep: $onboardingStep, ')
          ..write('onboardingDraft: $onboardingDraft, ')
          ..write('todayTipsDismissed: $todayTipsDismissed, ')
          ..write('displayName: $displayName, ')
          ..write('themeMode: $themeMode, ')
          ..write('reduceEffects: $reduceEffects, ')
          ..write('localeCode: $localeCode, ')
          ..write('banglaDigits: $banglaDigits, ')
          ..write('focusMinutes: $focusMinutes, ')
          ..write('shortBreakMinutes: $shortBreakMinutes, ')
          ..write('longBreakMinutes: $longBreakMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalUserReminderSettingsTable extends LocalUserReminderSettings
    with TableInfo<$LocalUserReminderSettingsTable, LocalUserReminderSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUserReminderSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remindersEnabledMeta =
      const VerificationMeta('remindersEnabled');
  @override
  late final GeneratedColumn<bool> remindersEnabled = GeneratedColumn<bool>(
      'reminders_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("reminders_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _leadDaysMeta =
      const VerificationMeta('leadDays');
  @override
  late final GeneratedColumn<String> leadDays = GeneratedColumn<String>(
      'lead_days', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[7, 3, 1]'));
  static const VerificationMeta _reminderLanguageMeta =
      const VerificationMeta('reminderLanguage');
  @override
  late final GeneratedColumn<String> reminderLanguage = GeneratedColumn<String>(
      'reminder_language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en'));
  static const VerificationMeta _deadlineSoonMeta =
      const VerificationMeta('deadlineSoon');
  @override
  late final GeneratedColumn<bool> deadlineSoon = GeneratedColumn<bool>(
      'deadline_soon', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("deadline_soon" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _examSoonMeta =
      const VerificationMeta('examSoon');
  @override
  late final GeneratedColumn<bool> examSoon = GeneratedColumn<bool>(
      'exam_soon', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("exam_soon" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _revisionDueMeta =
      const VerificationMeta('revisionDue');
  @override
  late final GeneratedColumn<bool> revisionDue = GeneratedColumn<bool>(
      'revision_due', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("revision_due" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _behindScheduleMeta =
      const VerificationMeta('behindSchedule');
  @override
  late final GeneratedColumn<bool> behindSchedule = GeneratedColumn<bool>(
      'behind_schedule', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("behind_schedule" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _weeklyReviewMeta =
      const VerificationMeta('weeklyReview');
  @override
  late final GeneratedColumn<bool> weeklyReview = GeneratedColumn<bool>(
      'weekly_review', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("weekly_review" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _weeklyReviewDayMeta =
      const VerificationMeta('weeklyReviewDay');
  @override
  late final GeneratedColumn<int> weeklyReviewDay = GeneratedColumn<int>(
      'weekly_review_day', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        remindersEnabled,
        leadDays,
        reminderLanguage,
        deadlineSoon,
        examSoon,
        revisionDue,
        behindSchedule,
        weeklyReview,
        weeklyReviewDay,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_reminder_settings';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalUserReminderSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('reminders_enabled')) {
      context.handle(
          _remindersEnabledMeta,
          remindersEnabled.isAcceptableOrUnknown(
              data['reminders_enabled']!, _remindersEnabledMeta));
    }
    if (data.containsKey('lead_days')) {
      context.handle(_leadDaysMeta,
          leadDays.isAcceptableOrUnknown(data['lead_days']!, _leadDaysMeta));
    }
    if (data.containsKey('reminder_language')) {
      context.handle(
          _reminderLanguageMeta,
          reminderLanguage.isAcceptableOrUnknown(
              data['reminder_language']!, _reminderLanguageMeta));
    }
    if (data.containsKey('deadline_soon')) {
      context.handle(
          _deadlineSoonMeta,
          deadlineSoon.isAcceptableOrUnknown(
              data['deadline_soon']!, _deadlineSoonMeta));
    }
    if (data.containsKey('exam_soon')) {
      context.handle(_examSoonMeta,
          examSoon.isAcceptableOrUnknown(data['exam_soon']!, _examSoonMeta));
    }
    if (data.containsKey('revision_due')) {
      context.handle(
          _revisionDueMeta,
          revisionDue.isAcceptableOrUnknown(
              data['revision_due']!, _revisionDueMeta));
    }
    if (data.containsKey('behind_schedule')) {
      context.handle(
          _behindScheduleMeta,
          behindSchedule.isAcceptableOrUnknown(
              data['behind_schedule']!, _behindScheduleMeta));
    }
    if (data.containsKey('weekly_review')) {
      context.handle(
          _weeklyReviewMeta,
          weeklyReview.isAcceptableOrUnknown(
              data['weekly_review']!, _weeklyReviewMeta));
    }
    if (data.containsKey('weekly_review_day')) {
      context.handle(
          _weeklyReviewDayMeta,
          weeklyReviewDay.isAcceptableOrUnknown(
              data['weekly_review_day']!, _weeklyReviewDayMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalUserReminderSetting map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUserReminderSetting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      remindersEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}reminders_enabled'])!,
      leadDays: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lead_days'])!,
      reminderLanguage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reminder_language'])!,
      deadlineSoon: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deadline_soon'])!,
      examSoon: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}exam_soon'])!,
      revisionDue: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}revision_due'])!,
      behindSchedule: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}behind_schedule'])!,
      weeklyReview: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}weekly_review'])!,
      weeklyReviewDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}weekly_review_day'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $LocalUserReminderSettingsTable createAlias(String alias) {
    return $LocalUserReminderSettingsTable(attachedDatabase, alias);
  }
}

class LocalUserReminderSetting extends DataClass
    implements Insertable<LocalUserReminderSetting> {
  final String id;
  final bool remindersEnabled;
  final String leadDays;
  final String reminderLanguage;
  final bool deadlineSoon;
  final bool examSoon;
  final bool revisionDue;
  final bool behindSchedule;
  final bool weeklyReview;
  final int weeklyReviewDay;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const LocalUserReminderSetting(
      {required this.id,
      required this.remindersEnabled,
      required this.leadDays,
      required this.reminderLanguage,
      required this.deadlineSoon,
      required this.examSoon,
      required this.revisionDue,
      required this.behindSchedule,
      required this.weeklyReview,
      required this.weeklyReviewDay,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['reminders_enabled'] = Variable<bool>(remindersEnabled);
    map['lead_days'] = Variable<String>(leadDays);
    map['reminder_language'] = Variable<String>(reminderLanguage);
    map['deadline_soon'] = Variable<bool>(deadlineSoon);
    map['exam_soon'] = Variable<bool>(examSoon);
    map['revision_due'] = Variable<bool>(revisionDue);
    map['behind_schedule'] = Variable<bool>(behindSchedule);
    map['weekly_review'] = Variable<bool>(weeklyReview);
    map['weekly_review_day'] = Variable<int>(weeklyReviewDay);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  LocalUserReminderSettingsCompanion toCompanion(bool nullToAbsent) {
    return LocalUserReminderSettingsCompanion(
      id: Value(id),
      remindersEnabled: Value(remindersEnabled),
      leadDays: Value(leadDays),
      reminderLanguage: Value(reminderLanguage),
      deadlineSoon: Value(deadlineSoon),
      examSoon: Value(examSoon),
      revisionDue: Value(revisionDue),
      behindSchedule: Value(behindSchedule),
      weeklyReview: Value(weeklyReview),
      weeklyReviewDay: Value(weeklyReviewDay),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LocalUserReminderSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUserReminderSetting(
      id: serializer.fromJson<String>(json['id']),
      remindersEnabled: serializer.fromJson<bool>(json['remindersEnabled']),
      leadDays: serializer.fromJson<String>(json['leadDays']),
      reminderLanguage: serializer.fromJson<String>(json['reminderLanguage']),
      deadlineSoon: serializer.fromJson<bool>(json['deadlineSoon']),
      examSoon: serializer.fromJson<bool>(json['examSoon']),
      revisionDue: serializer.fromJson<bool>(json['revisionDue']),
      behindSchedule: serializer.fromJson<bool>(json['behindSchedule']),
      weeklyReview: serializer.fromJson<bool>(json['weeklyReview']),
      weeklyReviewDay: serializer.fromJson<int>(json['weeklyReviewDay']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remindersEnabled': serializer.toJson<bool>(remindersEnabled),
      'leadDays': serializer.toJson<String>(leadDays),
      'reminderLanguage': serializer.toJson<String>(reminderLanguage),
      'deadlineSoon': serializer.toJson<bool>(deadlineSoon),
      'examSoon': serializer.toJson<bool>(examSoon),
      'revisionDue': serializer.toJson<bool>(revisionDue),
      'behindSchedule': serializer.toJson<bool>(behindSchedule),
      'weeklyReview': serializer.toJson<bool>(weeklyReview),
      'weeklyReviewDay': serializer.toJson<int>(weeklyReviewDay),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  LocalUserReminderSetting copyWith(
          {String? id,
          bool? remindersEnabled,
          String? leadDays,
          String? reminderLanguage,
          bool? deadlineSoon,
          bool? examSoon,
          bool? revisionDue,
          bool? behindSchedule,
          bool? weeklyReview,
          int? weeklyReviewDay,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      LocalUserReminderSetting(
        id: id ?? this.id,
        remindersEnabled: remindersEnabled ?? this.remindersEnabled,
        leadDays: leadDays ?? this.leadDays,
        reminderLanguage: reminderLanguage ?? this.reminderLanguage,
        deadlineSoon: deadlineSoon ?? this.deadlineSoon,
        examSoon: examSoon ?? this.examSoon,
        revisionDue: revisionDue ?? this.revisionDue,
        behindSchedule: behindSchedule ?? this.behindSchedule,
        weeklyReview: weeklyReview ?? this.weeklyReview,
        weeklyReviewDay: weeklyReviewDay ?? this.weeklyReviewDay,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  LocalUserReminderSetting copyWithCompanion(
      LocalUserReminderSettingsCompanion data) {
    return LocalUserReminderSetting(
      id: data.id.present ? data.id.value : this.id,
      remindersEnabled: data.remindersEnabled.present
          ? data.remindersEnabled.value
          : this.remindersEnabled,
      leadDays: data.leadDays.present ? data.leadDays.value : this.leadDays,
      reminderLanguage: data.reminderLanguage.present
          ? data.reminderLanguage.value
          : this.reminderLanguage,
      deadlineSoon: data.deadlineSoon.present
          ? data.deadlineSoon.value
          : this.deadlineSoon,
      examSoon: data.examSoon.present ? data.examSoon.value : this.examSoon,
      revisionDue:
          data.revisionDue.present ? data.revisionDue.value : this.revisionDue,
      behindSchedule: data.behindSchedule.present
          ? data.behindSchedule.value
          : this.behindSchedule,
      weeklyReview: data.weeklyReview.present
          ? data.weeklyReview.value
          : this.weeklyReview,
      weeklyReviewDay: data.weeklyReviewDay.present
          ? data.weeklyReviewDay.value
          : this.weeklyReviewDay,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserReminderSetting(')
          ..write('id: $id, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('leadDays: $leadDays, ')
          ..write('reminderLanguage: $reminderLanguage, ')
          ..write('deadlineSoon: $deadlineSoon, ')
          ..write('examSoon: $examSoon, ')
          ..write('revisionDue: $revisionDue, ')
          ..write('behindSchedule: $behindSchedule, ')
          ..write('weeklyReview: $weeklyReview, ')
          ..write('weeklyReviewDay: $weeklyReviewDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      remindersEnabled,
      leadDays,
      reminderLanguage,
      deadlineSoon,
      examSoon,
      revisionDue,
      behindSchedule,
      weeklyReview,
      weeklyReviewDay,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUserReminderSetting &&
          other.id == this.id &&
          other.remindersEnabled == this.remindersEnabled &&
          other.leadDays == this.leadDays &&
          other.reminderLanguage == this.reminderLanguage &&
          other.deadlineSoon == this.deadlineSoon &&
          other.examSoon == this.examSoon &&
          other.revisionDue == this.revisionDue &&
          other.behindSchedule == this.behindSchedule &&
          other.weeklyReview == this.weeklyReview &&
          other.weeklyReviewDay == this.weeklyReviewDay &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalUserReminderSettingsCompanion
    extends UpdateCompanion<LocalUserReminderSetting> {
  final Value<String> id;
  final Value<bool> remindersEnabled;
  final Value<String> leadDays;
  final Value<String> reminderLanguage;
  final Value<bool> deadlineSoon;
  final Value<bool> examSoon;
  final Value<bool> revisionDue;
  final Value<bool> behindSchedule;
  final Value<bool> weeklyReview;
  final Value<int> weeklyReviewDay;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const LocalUserReminderSettingsCompanion({
    this.id = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.leadDays = const Value.absent(),
    this.reminderLanguage = const Value.absent(),
    this.deadlineSoon = const Value.absent(),
    this.examSoon = const Value.absent(),
    this.revisionDue = const Value.absent(),
    this.behindSchedule = const Value.absent(),
    this.weeklyReview = const Value.absent(),
    this.weeklyReviewDay = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUserReminderSettingsCompanion.insert({
    required String id,
    this.remindersEnabled = const Value.absent(),
    this.leadDays = const Value.absent(),
    this.reminderLanguage = const Value.absent(),
    this.deadlineSoon = const Value.absent(),
    this.examSoon = const Value.absent(),
    this.revisionDue = const Value.absent(),
    this.behindSchedule = const Value.absent(),
    this.weeklyReview = const Value.absent(),
    this.weeklyReviewDay = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<LocalUserReminderSetting> custom({
    Expression<String>? id,
    Expression<bool>? remindersEnabled,
    Expression<String>? leadDays,
    Expression<String>? reminderLanguage,
    Expression<bool>? deadlineSoon,
    Expression<bool>? examSoon,
    Expression<bool>? revisionDue,
    Expression<bool>? behindSchedule,
    Expression<bool>? weeklyReview,
    Expression<int>? weeklyReviewDay,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remindersEnabled != null) 'reminders_enabled': remindersEnabled,
      if (leadDays != null) 'lead_days': leadDays,
      if (reminderLanguage != null) 'reminder_language': reminderLanguage,
      if (deadlineSoon != null) 'deadline_soon': deadlineSoon,
      if (examSoon != null) 'exam_soon': examSoon,
      if (revisionDue != null) 'revision_due': revisionDue,
      if (behindSchedule != null) 'behind_schedule': behindSchedule,
      if (weeklyReview != null) 'weekly_review': weeklyReview,
      if (weeklyReviewDay != null) 'weekly_review_day': weeklyReviewDay,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUserReminderSettingsCompanion copyWith(
      {Value<String>? id,
      Value<bool>? remindersEnabled,
      Value<String>? leadDays,
      Value<String>? reminderLanguage,
      Value<bool>? deadlineSoon,
      Value<bool>? examSoon,
      Value<bool>? revisionDue,
      Value<bool>? behindSchedule,
      Value<bool>? weeklyReview,
      Value<int>? weeklyReviewDay,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return LocalUserReminderSettingsCompanion(
      id: id ?? this.id,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      leadDays: leadDays ?? this.leadDays,
      reminderLanguage: reminderLanguage ?? this.reminderLanguage,
      deadlineSoon: deadlineSoon ?? this.deadlineSoon,
      examSoon: examSoon ?? this.examSoon,
      revisionDue: revisionDue ?? this.revisionDue,
      behindSchedule: behindSchedule ?? this.behindSchedule,
      weeklyReview: weeklyReview ?? this.weeklyReview,
      weeklyReviewDay: weeklyReviewDay ?? this.weeklyReviewDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remindersEnabled.present) {
      map['reminders_enabled'] = Variable<bool>(remindersEnabled.value);
    }
    if (leadDays.present) {
      map['lead_days'] = Variable<String>(leadDays.value);
    }
    if (reminderLanguage.present) {
      map['reminder_language'] = Variable<String>(reminderLanguage.value);
    }
    if (deadlineSoon.present) {
      map['deadline_soon'] = Variable<bool>(deadlineSoon.value);
    }
    if (examSoon.present) {
      map['exam_soon'] = Variable<bool>(examSoon.value);
    }
    if (revisionDue.present) {
      map['revision_due'] = Variable<bool>(revisionDue.value);
    }
    if (behindSchedule.present) {
      map['behind_schedule'] = Variable<bool>(behindSchedule.value);
    }
    if (weeklyReview.present) {
      map['weekly_review'] = Variable<bool>(weeklyReview.value);
    }
    if (weeklyReviewDay.present) {
      map['weekly_review_day'] = Variable<int>(weeklyReviewDay.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserReminderSettingsCompanion(')
          ..write('id: $id, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('leadDays: $leadDays, ')
          ..write('reminderLanguage: $reminderLanguage, ')
          ..write('deadlineSoon: $deadlineSoon, ')
          ..write('examSoon: $examSoon, ')
          ..write('revisionDue: $revisionDue, ')
          ..write('behindSchedule: $behindSchedule, ')
          ..write('weeklyReview: $weeklyReview, ')
          ..write('weeklyReviewDay: $weeklyReviewDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalCircularsTable localCirculars = $LocalCircularsTable(this);
  late final $LocalCircularExamDatesTable localCircularExamDates =
      $LocalCircularExamDatesTable(this);
  late final $LocalSubjectsTable localSubjects = $LocalSubjectsTable(this);
  late final $LocalMaterialsTable localMaterials = $LocalMaterialsTable(this);
  late final $LocalProgressLogsTable localProgressLogs =
      $LocalProgressLogsTable(this);
  late final $LocalTopicsTable localTopics = $LocalTopicsTable(this);
  late final $LocalCircularSubjectsTable localCircularSubjects =
      $LocalCircularSubjectsTable(this);
  late final $LocalStudyPlansTable localStudyPlans =
      $LocalStudyPlansTable(this);
  late final $LocalMockTestsTable localMockTests = $LocalMockTestsTable(this);
  late final $LocalRevisionItemsTable localRevisionItems =
      $LocalRevisionItemsTable(this);
  late final $LocalStudySessionsTable localStudySessions =
      $LocalStudySessionsTable(this);
  late final $LocalNotificationsTable localNotifications =
      $LocalNotificationsTable(this);
  late final $LocalPortalAccountsTable localPortalAccounts =
      $LocalPortalAccountsTable(this);
  late final $LocalUserSettingsTable localUserSettings =
      $LocalUserSettingsTable(this);
  late final $LocalUserReminderSettingsTable localUserReminderSettings =
      $LocalUserReminderSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        localCirculars,
        localCircularExamDates,
        localSubjects,
        localMaterials,
        localProgressLogs,
        localTopics,
        localCircularSubjects,
        localStudyPlans,
        localMockTests,
        localRevisionItems,
        localStudySessions,
        localNotifications,
        localPortalAccounts,
        localUserSettings,
        localUserReminderSettings
      ];
}

typedef $$LocalCircularsTableCreateCompanionBuilder = LocalCircularsCompanion
    Function({
  required String id,
  required String title,
  Value<String> sector,
  Value<String?> organizationName,
  Value<String?> organizationWebsite,
  Value<String?> circularUrl,
  Value<String?> applicationUrl,
  Value<DateTime?> deadline,
  Value<int?> vacancies,
  Value<double?> salaryMin,
  Value<double?> salaryMax,
  Value<String?> salaryNote,
  Value<double?> applicationFee,
  Value<String?> feeNote,
  Value<String> applicationStatus,
  Value<String> admitCardStatus,
  Value<String> priority,
  Value<String> workflowStatus,
  Value<String?> instructions,
  Value<String?> notes,
  Value<String?> syllabus,
  Value<bool> isQuickCapture,
  Value<bool> checklistPhoto,
  Value<bool> checklistCertificates,
  Value<bool> checklistFeePaid,
  Value<bool> checklistSubmitted,
  Value<bool> checklistAdmitCardDownloaded,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$LocalCircularsTableUpdateCompanionBuilder = LocalCircularsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> sector,
  Value<String?> organizationName,
  Value<String?> organizationWebsite,
  Value<String?> circularUrl,
  Value<String?> applicationUrl,
  Value<DateTime?> deadline,
  Value<int?> vacancies,
  Value<double?> salaryMin,
  Value<double?> salaryMax,
  Value<String?> salaryNote,
  Value<double?> applicationFee,
  Value<String?> feeNote,
  Value<String> applicationStatus,
  Value<String> admitCardStatus,
  Value<String> priority,
  Value<String> workflowStatus,
  Value<String?> instructions,
  Value<String?> notes,
  Value<String?> syllabus,
  Value<bool> isQuickCapture,
  Value<bool> checklistPhoto,
  Value<bool> checklistCertificates,
  Value<bool> checklistFeePaid,
  Value<bool> checklistSubmitted,
  Value<bool> checklistAdmitCardDownloaded,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$LocalCircularsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCircularsTable> {
  $$LocalCircularsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sector => $composableBuilder(
      column: $table.sector, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get organizationName => $composableBuilder(
      column: $table.organizationName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get organizationWebsite => $composableBuilder(
      column: $table.organizationWebsite,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get circularUrl => $composableBuilder(
      column: $table.circularUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get applicationUrl => $composableBuilder(
      column: $table.applicationUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get vacancies => $composableBuilder(
      column: $table.vacancies, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get salaryMin => $composableBuilder(
      column: $table.salaryMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get salaryMax => $composableBuilder(
      column: $table.salaryMax, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get salaryNote => $composableBuilder(
      column: $table.salaryNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get applicationFee => $composableBuilder(
      column: $table.applicationFee,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get feeNote => $composableBuilder(
      column: $table.feeNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get applicationStatus => $composableBuilder(
      column: $table.applicationStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get admitCardStatus => $composableBuilder(
      column: $table.admitCardStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get workflowStatus => $composableBuilder(
      column: $table.workflowStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get instructions => $composableBuilder(
      column: $table.instructions, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syllabus => $composableBuilder(
      column: $table.syllabus, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isQuickCapture => $composableBuilder(
      column: $table.isQuickCapture,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get checklistPhoto => $composableBuilder(
      column: $table.checklistPhoto,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get checklistCertificates => $composableBuilder(
      column: $table.checklistCertificates,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get checklistFeePaid => $composableBuilder(
      column: $table.checklistFeePaid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get checklistSubmitted => $composableBuilder(
      column: $table.checklistSubmitted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get checklistAdmitCardDownloaded => $composableBuilder(
      column: $table.checklistAdmitCardDownloaded,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalCircularsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCircularsTable> {
  $$LocalCircularsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sector => $composableBuilder(
      column: $table.sector, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get organizationName => $composableBuilder(
      column: $table.organizationName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get organizationWebsite => $composableBuilder(
      column: $table.organizationWebsite,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get circularUrl => $composableBuilder(
      column: $table.circularUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get applicationUrl => $composableBuilder(
      column: $table.applicationUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get vacancies => $composableBuilder(
      column: $table.vacancies, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get salaryMin => $composableBuilder(
      column: $table.salaryMin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get salaryMax => $composableBuilder(
      column: $table.salaryMax, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get salaryNote => $composableBuilder(
      column: $table.salaryNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get applicationFee => $composableBuilder(
      column: $table.applicationFee,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get feeNote => $composableBuilder(
      column: $table.feeNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get applicationStatus => $composableBuilder(
      column: $table.applicationStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get admitCardStatus => $composableBuilder(
      column: $table.admitCardStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get workflowStatus => $composableBuilder(
      column: $table.workflowStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get instructions => $composableBuilder(
      column: $table.instructions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syllabus => $composableBuilder(
      column: $table.syllabus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isQuickCapture => $composableBuilder(
      column: $table.isQuickCapture,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get checklistPhoto => $composableBuilder(
      column: $table.checklistPhoto,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get checklistCertificates => $composableBuilder(
      column: $table.checklistCertificates,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get checklistFeePaid => $composableBuilder(
      column: $table.checklistFeePaid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get checklistSubmitted => $composableBuilder(
      column: $table.checklistSubmitted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get checklistAdmitCardDownloaded => $composableBuilder(
      column: $table.checklistAdmitCardDownloaded,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalCircularsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCircularsTable> {
  $$LocalCircularsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get sector =>
      $composableBuilder(column: $table.sector, builder: (column) => column);

  GeneratedColumn<String> get organizationName => $composableBuilder(
      column: $table.organizationName, builder: (column) => column);

  GeneratedColumn<String> get organizationWebsite => $composableBuilder(
      column: $table.organizationWebsite, builder: (column) => column);

  GeneratedColumn<String> get circularUrl => $composableBuilder(
      column: $table.circularUrl, builder: (column) => column);

  GeneratedColumn<String> get applicationUrl => $composableBuilder(
      column: $table.applicationUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<int> get vacancies =>
      $composableBuilder(column: $table.vacancies, builder: (column) => column);

  GeneratedColumn<double> get salaryMin =>
      $composableBuilder(column: $table.salaryMin, builder: (column) => column);

  GeneratedColumn<double> get salaryMax =>
      $composableBuilder(column: $table.salaryMax, builder: (column) => column);

  GeneratedColumn<String> get salaryNote => $composableBuilder(
      column: $table.salaryNote, builder: (column) => column);

  GeneratedColumn<double> get applicationFee => $composableBuilder(
      column: $table.applicationFee, builder: (column) => column);

  GeneratedColumn<String> get feeNote =>
      $composableBuilder(column: $table.feeNote, builder: (column) => column);

  GeneratedColumn<String> get applicationStatus => $composableBuilder(
      column: $table.applicationStatus, builder: (column) => column);

  GeneratedColumn<String> get admitCardStatus => $composableBuilder(
      column: $table.admitCardStatus, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get workflowStatus => $composableBuilder(
      column: $table.workflowStatus, builder: (column) => column);

  GeneratedColumn<String> get instructions => $composableBuilder(
      column: $table.instructions, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get syllabus =>
      $composableBuilder(column: $table.syllabus, builder: (column) => column);

  GeneratedColumn<bool> get isQuickCapture => $composableBuilder(
      column: $table.isQuickCapture, builder: (column) => column);

  GeneratedColumn<bool> get checklistPhoto => $composableBuilder(
      column: $table.checklistPhoto, builder: (column) => column);

  GeneratedColumn<bool> get checklistCertificates => $composableBuilder(
      column: $table.checklistCertificates, builder: (column) => column);

  GeneratedColumn<bool> get checklistFeePaid => $composableBuilder(
      column: $table.checklistFeePaid, builder: (column) => column);

  GeneratedColumn<bool> get checklistSubmitted => $composableBuilder(
      column: $table.checklistSubmitted, builder: (column) => column);

  GeneratedColumn<bool> get checklistAdmitCardDownloaded => $composableBuilder(
      column: $table.checklistAdmitCardDownloaded, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalCircularsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalCircularsTable,
    LocalCircular,
    $$LocalCircularsTableFilterComposer,
    $$LocalCircularsTableOrderingComposer,
    $$LocalCircularsTableAnnotationComposer,
    $$LocalCircularsTableCreateCompanionBuilder,
    $$LocalCircularsTableUpdateCompanionBuilder,
    (
      LocalCircular,
      BaseReferences<_$AppDatabase, $LocalCircularsTable, LocalCircular>
    ),
    LocalCircular,
    PrefetchHooks Function()> {
  $$LocalCircularsTableTableManager(
      _$AppDatabase db, $LocalCircularsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCircularsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCircularsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCircularsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> sector = const Value.absent(),
            Value<String?> organizationName = const Value.absent(),
            Value<String?> organizationWebsite = const Value.absent(),
            Value<String?> circularUrl = const Value.absent(),
            Value<String?> applicationUrl = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<int?> vacancies = const Value.absent(),
            Value<double?> salaryMin = const Value.absent(),
            Value<double?> salaryMax = const Value.absent(),
            Value<String?> salaryNote = const Value.absent(),
            Value<double?> applicationFee = const Value.absent(),
            Value<String?> feeNote = const Value.absent(),
            Value<String> applicationStatus = const Value.absent(),
            Value<String> admitCardStatus = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String> workflowStatus = const Value.absent(),
            Value<String?> instructions = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> syllabus = const Value.absent(),
            Value<bool> isQuickCapture = const Value.absent(),
            Value<bool> checklistPhoto = const Value.absent(),
            Value<bool> checklistCertificates = const Value.absent(),
            Value<bool> checklistFeePaid = const Value.absent(),
            Value<bool> checklistSubmitted = const Value.absent(),
            Value<bool> checklistAdmitCardDownloaded = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalCircularsCompanion(
            id: id,
            title: title,
            sector: sector,
            organizationName: organizationName,
            organizationWebsite: organizationWebsite,
            circularUrl: circularUrl,
            applicationUrl: applicationUrl,
            deadline: deadline,
            vacancies: vacancies,
            salaryMin: salaryMin,
            salaryMax: salaryMax,
            salaryNote: salaryNote,
            applicationFee: applicationFee,
            feeNote: feeNote,
            applicationStatus: applicationStatus,
            admitCardStatus: admitCardStatus,
            priority: priority,
            workflowStatus: workflowStatus,
            instructions: instructions,
            notes: notes,
            syllabus: syllabus,
            isQuickCapture: isQuickCapture,
            checklistPhoto: checklistPhoto,
            checklistCertificates: checklistCertificates,
            checklistFeePaid: checklistFeePaid,
            checklistSubmitted: checklistSubmitted,
            checklistAdmitCardDownloaded: checklistAdmitCardDownloaded,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String> sector = const Value.absent(),
            Value<String?> organizationName = const Value.absent(),
            Value<String?> organizationWebsite = const Value.absent(),
            Value<String?> circularUrl = const Value.absent(),
            Value<String?> applicationUrl = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<int?> vacancies = const Value.absent(),
            Value<double?> salaryMin = const Value.absent(),
            Value<double?> salaryMax = const Value.absent(),
            Value<String?> salaryNote = const Value.absent(),
            Value<double?> applicationFee = const Value.absent(),
            Value<String?> feeNote = const Value.absent(),
            Value<String> applicationStatus = const Value.absent(),
            Value<String> admitCardStatus = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String> workflowStatus = const Value.absent(),
            Value<String?> instructions = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> syllabus = const Value.absent(),
            Value<bool> isQuickCapture = const Value.absent(),
            Value<bool> checklistPhoto = const Value.absent(),
            Value<bool> checklistCertificates = const Value.absent(),
            Value<bool> checklistFeePaid = const Value.absent(),
            Value<bool> checklistSubmitted = const Value.absent(),
            Value<bool> checklistAdmitCardDownloaded = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalCircularsCompanion.insert(
            id: id,
            title: title,
            sector: sector,
            organizationName: organizationName,
            organizationWebsite: organizationWebsite,
            circularUrl: circularUrl,
            applicationUrl: applicationUrl,
            deadline: deadline,
            vacancies: vacancies,
            salaryMin: salaryMin,
            salaryMax: salaryMax,
            salaryNote: salaryNote,
            applicationFee: applicationFee,
            feeNote: feeNote,
            applicationStatus: applicationStatus,
            admitCardStatus: admitCardStatus,
            priority: priority,
            workflowStatus: workflowStatus,
            instructions: instructions,
            notes: notes,
            syllabus: syllabus,
            isQuickCapture: isQuickCapture,
            checklistPhoto: checklistPhoto,
            checklistCertificates: checklistCertificates,
            checklistFeePaid: checklistFeePaid,
            checklistSubmitted: checklistSubmitted,
            checklistAdmitCardDownloaded: checklistAdmitCardDownloaded,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalCircularsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalCircularsTable,
    LocalCircular,
    $$LocalCircularsTableFilterComposer,
    $$LocalCircularsTableOrderingComposer,
    $$LocalCircularsTableAnnotationComposer,
    $$LocalCircularsTableCreateCompanionBuilder,
    $$LocalCircularsTableUpdateCompanionBuilder,
    (
      LocalCircular,
      BaseReferences<_$AppDatabase, $LocalCircularsTable, LocalCircular>
    ),
    LocalCircular,
    PrefetchHooks Function()>;
typedef $$LocalCircularExamDatesTableCreateCompanionBuilder
    = LocalCircularExamDatesCompanion Function({
  required String id,
  required String circularId,
  required String stage,
  required DateTime examDate,
  Value<String?> venue,
  Value<String?> notes,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$LocalCircularExamDatesTableUpdateCompanionBuilder
    = LocalCircularExamDatesCompanion Function({
  Value<String> id,
  Value<String> circularId,
  Value<String> stage,
  Value<DateTime> examDate,
  Value<String?> venue,
  Value<String?> notes,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$LocalCircularExamDatesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCircularExamDatesTable> {
  $$LocalCircularExamDatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get circularId => $composableBuilder(
      column: $table.circularId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stage => $composableBuilder(
      column: $table.stage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get examDate => $composableBuilder(
      column: $table.examDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get venue => $composableBuilder(
      column: $table.venue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalCircularExamDatesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCircularExamDatesTable> {
  $$LocalCircularExamDatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get circularId => $composableBuilder(
      column: $table.circularId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stage => $composableBuilder(
      column: $table.stage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get examDate => $composableBuilder(
      column: $table.examDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get venue => $composableBuilder(
      column: $table.venue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalCircularExamDatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCircularExamDatesTable> {
  $$LocalCircularExamDatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get circularId => $composableBuilder(
      column: $table.circularId, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<DateTime> get examDate =>
      $composableBuilder(column: $table.examDate, builder: (column) => column);

  GeneratedColumn<String> get venue =>
      $composableBuilder(column: $table.venue, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalCircularExamDatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalCircularExamDatesTable,
    LocalCircularExamDate,
    $$LocalCircularExamDatesTableFilterComposer,
    $$LocalCircularExamDatesTableOrderingComposer,
    $$LocalCircularExamDatesTableAnnotationComposer,
    $$LocalCircularExamDatesTableCreateCompanionBuilder,
    $$LocalCircularExamDatesTableUpdateCompanionBuilder,
    (
      LocalCircularExamDate,
      BaseReferences<_$AppDatabase, $LocalCircularExamDatesTable,
          LocalCircularExamDate>
    ),
    LocalCircularExamDate,
    PrefetchHooks Function()> {
  $$LocalCircularExamDatesTableTableManager(
      _$AppDatabase db, $LocalCircularExamDatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCircularExamDatesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCircularExamDatesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCircularExamDatesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> circularId = const Value.absent(),
            Value<String> stage = const Value.absent(),
            Value<DateTime> examDate = const Value.absent(),
            Value<String?> venue = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalCircularExamDatesCompanion(
            id: id,
            circularId: circularId,
            stage: stage,
            examDate: examDate,
            venue: venue,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String circularId,
            required String stage,
            required DateTime examDate,
            Value<String?> venue = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalCircularExamDatesCompanion.insert(
            id: id,
            circularId: circularId,
            stage: stage,
            examDate: examDate,
            venue: venue,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalCircularExamDatesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalCircularExamDatesTable,
        LocalCircularExamDate,
        $$LocalCircularExamDatesTableFilterComposer,
        $$LocalCircularExamDatesTableOrderingComposer,
        $$LocalCircularExamDatesTableAnnotationComposer,
        $$LocalCircularExamDatesTableCreateCompanionBuilder,
        $$LocalCircularExamDatesTableUpdateCompanionBuilder,
        (
          LocalCircularExamDate,
          BaseReferences<_$AppDatabase, $LocalCircularExamDatesTable,
              LocalCircularExamDate>
        ),
        LocalCircularExamDate,
        PrefetchHooks Function()>;
typedef $$LocalSubjectsTableCreateCompanionBuilder = LocalSubjectsCompanion
    Function({
  required String id,
  required String name,
  Value<String> color,
  Value<String> icon,
  Value<String> examType,
  Value<int> sortOrder,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$LocalSubjectsTableUpdateCompanionBuilder = LocalSubjectsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> color,
  Value<String> icon,
  Value<String> examType,
  Value<int> sortOrder,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$LocalSubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSubjectsTable> {
  $$LocalSubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get examType => $composableBuilder(
      column: $table.examType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalSubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSubjectsTable> {
  $$LocalSubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get examType => $composableBuilder(
      column: $table.examType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalSubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSubjectsTable> {
  $$LocalSubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get examType =>
      $composableBuilder(column: $table.examType, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalSubjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalSubjectsTable,
    LocalSubject,
    $$LocalSubjectsTableFilterComposer,
    $$LocalSubjectsTableOrderingComposer,
    $$LocalSubjectsTableAnnotationComposer,
    $$LocalSubjectsTableCreateCompanionBuilder,
    $$LocalSubjectsTableUpdateCompanionBuilder,
    (
      LocalSubject,
      BaseReferences<_$AppDatabase, $LocalSubjectsTable, LocalSubject>
    ),
    LocalSubject,
    PrefetchHooks Function()> {
  $$LocalSubjectsTableTableManager(_$AppDatabase db, $LocalSubjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<String> examType = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalSubjectsCompanion(
            id: id,
            name: name,
            color: color,
            icon: icon,
            examType: examType,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> color = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<String> examType = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalSubjectsCompanion.insert(
            id: id,
            name: name,
            color: color,
            icon: icon,
            examType: examType,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalSubjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalSubjectsTable,
    LocalSubject,
    $$LocalSubjectsTableFilterComposer,
    $$LocalSubjectsTableOrderingComposer,
    $$LocalSubjectsTableAnnotationComposer,
    $$LocalSubjectsTableCreateCompanionBuilder,
    $$LocalSubjectsTableUpdateCompanionBuilder,
    (
      LocalSubject,
      BaseReferences<_$AppDatabase, $LocalSubjectsTable, LocalSubject>
    ),
    LocalSubject,
    PrefetchHooks Function()>;
typedef $$LocalMaterialsTableCreateCompanionBuilder = LocalMaterialsCompanion
    Function({
  required String id,
  required String subjectId,
  required String title,
  Value<String> kind,
  Value<String> unitLabel,
  Value<int> totalUnits,
  Value<int> completedUnits,
  Value<String?> coverImagePath,
  Value<String?> coverImageUrl,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$LocalMaterialsTableUpdateCompanionBuilder = LocalMaterialsCompanion
    Function({
  Value<String> id,
  Value<String> subjectId,
  Value<String> title,
  Value<String> kind,
  Value<String> unitLabel,
  Value<int> totalUnits,
  Value<int> completedUnits,
  Value<String?> coverImagePath,
  Value<String?> coverImageUrl,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$LocalMaterialsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMaterialsTable> {
  $$LocalMaterialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unitLabel => $composableBuilder(
      column: $table.unitLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalUnits => $composableBuilder(
      column: $table.totalUnits, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedUnits => $composableBuilder(
      column: $table.completedUnits,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverImagePath => $composableBuilder(
      column: $table.coverImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalMaterialsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMaterialsTable> {
  $$LocalMaterialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unitLabel => $composableBuilder(
      column: $table.unitLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalUnits => $composableBuilder(
      column: $table.totalUnits, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedUnits => $composableBuilder(
      column: $table.completedUnits,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverImagePath => $composableBuilder(
      column: $table.coverImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalMaterialsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMaterialsTable> {
  $$LocalMaterialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get unitLabel =>
      $composableBuilder(column: $table.unitLabel, builder: (column) => column);

  GeneratedColumn<int> get totalUnits => $composableBuilder(
      column: $table.totalUnits, builder: (column) => column);

  GeneratedColumn<int> get completedUnits => $composableBuilder(
      column: $table.completedUnits, builder: (column) => column);

  GeneratedColumn<String> get coverImagePath => $composableBuilder(
      column: $table.coverImagePath, builder: (column) => column);

  GeneratedColumn<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalMaterialsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalMaterialsTable,
    LocalMaterial,
    $$LocalMaterialsTableFilterComposer,
    $$LocalMaterialsTableOrderingComposer,
    $$LocalMaterialsTableAnnotationComposer,
    $$LocalMaterialsTableCreateCompanionBuilder,
    $$LocalMaterialsTableUpdateCompanionBuilder,
    (
      LocalMaterial,
      BaseReferences<_$AppDatabase, $LocalMaterialsTable, LocalMaterial>
    ),
    LocalMaterial,
    PrefetchHooks Function()> {
  $$LocalMaterialsTableTableManager(
      _$AppDatabase db, $LocalMaterialsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMaterialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMaterialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMaterialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> subjectId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> unitLabel = const Value.absent(),
            Value<int> totalUnits = const Value.absent(),
            Value<int> completedUnits = const Value.absent(),
            Value<String?> coverImagePath = const Value.absent(),
            Value<String?> coverImageUrl = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMaterialsCompanion(
            id: id,
            subjectId: subjectId,
            title: title,
            kind: kind,
            unitLabel: unitLabel,
            totalUnits: totalUnits,
            completedUnits: completedUnits,
            coverImagePath: coverImagePath,
            coverImageUrl: coverImageUrl,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String subjectId,
            required String title,
            Value<String> kind = const Value.absent(),
            Value<String> unitLabel = const Value.absent(),
            Value<int> totalUnits = const Value.absent(),
            Value<int> completedUnits = const Value.absent(),
            Value<String?> coverImagePath = const Value.absent(),
            Value<String?> coverImageUrl = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMaterialsCompanion.insert(
            id: id,
            subjectId: subjectId,
            title: title,
            kind: kind,
            unitLabel: unitLabel,
            totalUnits: totalUnits,
            completedUnits: completedUnits,
            coverImagePath: coverImagePath,
            coverImageUrl: coverImageUrl,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalMaterialsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalMaterialsTable,
    LocalMaterial,
    $$LocalMaterialsTableFilterComposer,
    $$LocalMaterialsTableOrderingComposer,
    $$LocalMaterialsTableAnnotationComposer,
    $$LocalMaterialsTableCreateCompanionBuilder,
    $$LocalMaterialsTableUpdateCompanionBuilder,
    (
      LocalMaterial,
      BaseReferences<_$AppDatabase, $LocalMaterialsTable, LocalMaterial>
    ),
    LocalMaterial,
    PrefetchHooks Function()>;
typedef $$LocalProgressLogsTableCreateCompanionBuilder
    = LocalProgressLogsCompanion Function({
  required String id,
  required String materialId,
  Value<int> unitsDone,
  Value<String> entryType,
  required DateTime loggedOn,
  Value<String?> note,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$LocalProgressLogsTableUpdateCompanionBuilder
    = LocalProgressLogsCompanion Function({
  Value<String> id,
  Value<String> materialId,
  Value<int> unitsDone,
  Value<String> entryType,
  Value<DateTime> loggedOn,
  Value<String?> note,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$LocalProgressLogsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalProgressLogsTable> {
  $$LocalProgressLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unitsDone => $composableBuilder(
      column: $table.unitsDone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryType => $composableBuilder(
      column: $table.entryType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get loggedOn => $composableBuilder(
      column: $table.loggedOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalProgressLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalProgressLogsTable> {
  $$LocalProgressLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unitsDone => $composableBuilder(
      column: $table.unitsDone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryType => $composableBuilder(
      column: $table.entryType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get loggedOn => $composableBuilder(
      column: $table.loggedOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalProgressLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalProgressLogsTable> {
  $$LocalProgressLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => column);

  GeneratedColumn<int> get unitsDone =>
      $composableBuilder(column: $table.unitsDone, builder: (column) => column);

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedOn =>
      $composableBuilder(column: $table.loggedOn, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalProgressLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalProgressLogsTable,
    LocalProgressLog,
    $$LocalProgressLogsTableFilterComposer,
    $$LocalProgressLogsTableOrderingComposer,
    $$LocalProgressLogsTableAnnotationComposer,
    $$LocalProgressLogsTableCreateCompanionBuilder,
    $$LocalProgressLogsTableUpdateCompanionBuilder,
    (
      LocalProgressLog,
      BaseReferences<_$AppDatabase, $LocalProgressLogsTable, LocalProgressLog>
    ),
    LocalProgressLog,
    PrefetchHooks Function()> {
  $$LocalProgressLogsTableTableManager(
      _$AppDatabase db, $LocalProgressLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProgressLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalProgressLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalProgressLogsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> materialId = const Value.absent(),
            Value<int> unitsDone = const Value.absent(),
            Value<String> entryType = const Value.absent(),
            Value<DateTime> loggedOn = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalProgressLogsCompanion(
            id: id,
            materialId: materialId,
            unitsDone: unitsDone,
            entryType: entryType,
            loggedOn: loggedOn,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String materialId,
            Value<int> unitsDone = const Value.absent(),
            Value<String> entryType = const Value.absent(),
            required DateTime loggedOn,
            Value<String?> note = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalProgressLogsCompanion.insert(
            id: id,
            materialId: materialId,
            unitsDone: unitsDone,
            entryType: entryType,
            loggedOn: loggedOn,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalProgressLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalProgressLogsTable,
    LocalProgressLog,
    $$LocalProgressLogsTableFilterComposer,
    $$LocalProgressLogsTableOrderingComposer,
    $$LocalProgressLogsTableAnnotationComposer,
    $$LocalProgressLogsTableCreateCompanionBuilder,
    $$LocalProgressLogsTableUpdateCompanionBuilder,
    (
      LocalProgressLog,
      BaseReferences<_$AppDatabase, $LocalProgressLogsTable, LocalProgressLog>
    ),
    LocalProgressLog,
    PrefetchHooks Function()>;
typedef $$LocalTopicsTableCreateCompanionBuilder = LocalTopicsCompanion
    Function({
  required String id,
  required String subjectId,
  required String name,
  Value<int> sortOrder,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$LocalTopicsTableUpdateCompanionBuilder = LocalTopicsCompanion
    Function({
  Value<String> id,
  Value<String> subjectId,
  Value<String> name,
  Value<int> sortOrder,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$LocalTopicsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTopicsTable> {
  $$LocalTopicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalTopicsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTopicsTable> {
  $$LocalTopicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalTopicsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTopicsTable> {
  $$LocalTopicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalTopicsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalTopicsTable,
    LocalTopic,
    $$LocalTopicsTableFilterComposer,
    $$LocalTopicsTableOrderingComposer,
    $$LocalTopicsTableAnnotationComposer,
    $$LocalTopicsTableCreateCompanionBuilder,
    $$LocalTopicsTableUpdateCompanionBuilder,
    (LocalTopic, BaseReferences<_$AppDatabase, $LocalTopicsTable, LocalTopic>),
    LocalTopic,
    PrefetchHooks Function()> {
  $$LocalTopicsTableTableManager(_$AppDatabase db, $LocalTopicsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTopicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTopicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTopicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> subjectId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalTopicsCompanion(
            id: id,
            subjectId: subjectId,
            name: name,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String subjectId,
            required String name,
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalTopicsCompanion.insert(
            id: id,
            subjectId: subjectId,
            name: name,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalTopicsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalTopicsTable,
    LocalTopic,
    $$LocalTopicsTableFilterComposer,
    $$LocalTopicsTableOrderingComposer,
    $$LocalTopicsTableAnnotationComposer,
    $$LocalTopicsTableCreateCompanionBuilder,
    $$LocalTopicsTableUpdateCompanionBuilder,
    (LocalTopic, BaseReferences<_$AppDatabase, $LocalTopicsTable, LocalTopic>),
    LocalTopic,
    PrefetchHooks Function()>;
typedef $$LocalCircularSubjectsTableCreateCompanionBuilder
    = LocalCircularSubjectsCompanion Function({
  required String id,
  required String circularId,
  required String subjectId,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$LocalCircularSubjectsTableUpdateCompanionBuilder
    = LocalCircularSubjectsCompanion Function({
  Value<String> id,
  Value<String> circularId,
  Value<String> subjectId,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$LocalCircularSubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCircularSubjectsTable> {
  $$LocalCircularSubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get circularId => $composableBuilder(
      column: $table.circularId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalCircularSubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCircularSubjectsTable> {
  $$LocalCircularSubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get circularId => $composableBuilder(
      column: $table.circularId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalCircularSubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCircularSubjectsTable> {
  $$LocalCircularSubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get circularId => $composableBuilder(
      column: $table.circularId, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalCircularSubjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalCircularSubjectsTable,
    LocalCircularSubject,
    $$LocalCircularSubjectsTableFilterComposer,
    $$LocalCircularSubjectsTableOrderingComposer,
    $$LocalCircularSubjectsTableAnnotationComposer,
    $$LocalCircularSubjectsTableCreateCompanionBuilder,
    $$LocalCircularSubjectsTableUpdateCompanionBuilder,
    (
      LocalCircularSubject,
      BaseReferences<_$AppDatabase, $LocalCircularSubjectsTable,
          LocalCircularSubject>
    ),
    LocalCircularSubject,
    PrefetchHooks Function()> {
  $$LocalCircularSubjectsTableTableManager(
      _$AppDatabase db, $LocalCircularSubjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCircularSubjectsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCircularSubjectsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCircularSubjectsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> circularId = const Value.absent(),
            Value<String> subjectId = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalCircularSubjectsCompanion(
            id: id,
            circularId: circularId,
            subjectId: subjectId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String circularId,
            required String subjectId,
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalCircularSubjectsCompanion.insert(
            id: id,
            circularId: circularId,
            subjectId: subjectId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalCircularSubjectsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalCircularSubjectsTable,
        LocalCircularSubject,
        $$LocalCircularSubjectsTableFilterComposer,
        $$LocalCircularSubjectsTableOrderingComposer,
        $$LocalCircularSubjectsTableAnnotationComposer,
        $$LocalCircularSubjectsTableCreateCompanionBuilder,
        $$LocalCircularSubjectsTableUpdateCompanionBuilder,
        (
          LocalCircularSubject,
          BaseReferences<_$AppDatabase, $LocalCircularSubjectsTable,
              LocalCircularSubject>
        ),
        LocalCircularSubject,
        PrefetchHooks Function()>;
typedef $$LocalStudyPlansTableCreateCompanionBuilder = LocalStudyPlansCompanion
    Function({
  required String id,
  Value<String?> subjectId,
  Value<String?> circularId,
  Value<String?> examDateId,
  required DateTime startDate,
  required DateTime targetDate,
  Value<int> finishBufferDays,
  Value<int> restDaysPerWeek,
  Value<int> extraStudyDays,
  Value<int?> maxDailyPace,
  Value<int> initialCompletedUnits,
  Value<String> postponedMaterialIds,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$LocalStudyPlansTableUpdateCompanionBuilder = LocalStudyPlansCompanion
    Function({
  Value<String> id,
  Value<String?> subjectId,
  Value<String?> circularId,
  Value<String?> examDateId,
  Value<DateTime> startDate,
  Value<DateTime> targetDate,
  Value<int> finishBufferDays,
  Value<int> restDaysPerWeek,
  Value<int> extraStudyDays,
  Value<int?> maxDailyPace,
  Value<int> initialCompletedUnits,
  Value<String> postponedMaterialIds,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$LocalStudyPlansTableFilterComposer
    extends Composer<_$AppDatabase, $LocalStudyPlansTable> {
  $$LocalStudyPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get circularId => $composableBuilder(
      column: $table.circularId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get examDateId => $composableBuilder(
      column: $table.examDateId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get finishBufferDays => $composableBuilder(
      column: $table.finishBufferDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get restDaysPerWeek => $composableBuilder(
      column: $table.restDaysPerWeek,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get extraStudyDays => $composableBuilder(
      column: $table.extraStudyDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxDailyPace => $composableBuilder(
      column: $table.maxDailyPace, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get initialCompletedUnits => $composableBuilder(
      column: $table.initialCompletedUnits,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get postponedMaterialIds => $composableBuilder(
      column: $table.postponedMaterialIds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalStudyPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalStudyPlansTable> {
  $$LocalStudyPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get circularId => $composableBuilder(
      column: $table.circularId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get examDateId => $composableBuilder(
      column: $table.examDateId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get finishBufferDays => $composableBuilder(
      column: $table.finishBufferDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get restDaysPerWeek => $composableBuilder(
      column: $table.restDaysPerWeek,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get extraStudyDays => $composableBuilder(
      column: $table.extraStudyDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxDailyPace => $composableBuilder(
      column: $table.maxDailyPace,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get initialCompletedUnits => $composableBuilder(
      column: $table.initialCompletedUnits,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get postponedMaterialIds => $composableBuilder(
      column: $table.postponedMaterialIds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalStudyPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalStudyPlansTable> {
  $$LocalStudyPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get circularId => $composableBuilder(
      column: $table.circularId, builder: (column) => column);

  GeneratedColumn<String> get examDateId => $composableBuilder(
      column: $table.examDateId, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => column);

  GeneratedColumn<int> get finishBufferDays => $composableBuilder(
      column: $table.finishBufferDays, builder: (column) => column);

  GeneratedColumn<int> get restDaysPerWeek => $composableBuilder(
      column: $table.restDaysPerWeek, builder: (column) => column);

  GeneratedColumn<int> get extraStudyDays => $composableBuilder(
      column: $table.extraStudyDays, builder: (column) => column);

  GeneratedColumn<int> get maxDailyPace => $composableBuilder(
      column: $table.maxDailyPace, builder: (column) => column);

  GeneratedColumn<int> get initialCompletedUnits => $composableBuilder(
      column: $table.initialCompletedUnits, builder: (column) => column);

  GeneratedColumn<String> get postponedMaterialIds => $composableBuilder(
      column: $table.postponedMaterialIds, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalStudyPlansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalStudyPlansTable,
    LocalStudyPlan,
    $$LocalStudyPlansTableFilterComposer,
    $$LocalStudyPlansTableOrderingComposer,
    $$LocalStudyPlansTableAnnotationComposer,
    $$LocalStudyPlansTableCreateCompanionBuilder,
    $$LocalStudyPlansTableUpdateCompanionBuilder,
    (
      LocalStudyPlan,
      BaseReferences<_$AppDatabase, $LocalStudyPlansTable, LocalStudyPlan>
    ),
    LocalStudyPlan,
    PrefetchHooks Function()> {
  $$LocalStudyPlansTableTableManager(
      _$AppDatabase db, $LocalStudyPlansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalStudyPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalStudyPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalStudyPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> subjectId = const Value.absent(),
            Value<String?> circularId = const Value.absent(),
            Value<String?> examDateId = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime> targetDate = const Value.absent(),
            Value<int> finishBufferDays = const Value.absent(),
            Value<int> restDaysPerWeek = const Value.absent(),
            Value<int> extraStudyDays = const Value.absent(),
            Value<int?> maxDailyPace = const Value.absent(),
            Value<int> initialCompletedUnits = const Value.absent(),
            Value<String> postponedMaterialIds = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalStudyPlansCompanion(
            id: id,
            subjectId: subjectId,
            circularId: circularId,
            examDateId: examDateId,
            startDate: startDate,
            targetDate: targetDate,
            finishBufferDays: finishBufferDays,
            restDaysPerWeek: restDaysPerWeek,
            extraStudyDays: extraStudyDays,
            maxDailyPace: maxDailyPace,
            initialCompletedUnits: initialCompletedUnits,
            postponedMaterialIds: postponedMaterialIds,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> subjectId = const Value.absent(),
            Value<String?> circularId = const Value.absent(),
            Value<String?> examDateId = const Value.absent(),
            required DateTime startDate,
            required DateTime targetDate,
            Value<int> finishBufferDays = const Value.absent(),
            Value<int> restDaysPerWeek = const Value.absent(),
            Value<int> extraStudyDays = const Value.absent(),
            Value<int?> maxDailyPace = const Value.absent(),
            Value<int> initialCompletedUnits = const Value.absent(),
            Value<String> postponedMaterialIds = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalStudyPlansCompanion.insert(
            id: id,
            subjectId: subjectId,
            circularId: circularId,
            examDateId: examDateId,
            startDate: startDate,
            targetDate: targetDate,
            finishBufferDays: finishBufferDays,
            restDaysPerWeek: restDaysPerWeek,
            extraStudyDays: extraStudyDays,
            maxDailyPace: maxDailyPace,
            initialCompletedUnits: initialCompletedUnits,
            postponedMaterialIds: postponedMaterialIds,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalStudyPlansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalStudyPlansTable,
    LocalStudyPlan,
    $$LocalStudyPlansTableFilterComposer,
    $$LocalStudyPlansTableOrderingComposer,
    $$LocalStudyPlansTableAnnotationComposer,
    $$LocalStudyPlansTableCreateCompanionBuilder,
    $$LocalStudyPlansTableUpdateCompanionBuilder,
    (
      LocalStudyPlan,
      BaseReferences<_$AppDatabase, $LocalStudyPlansTable, LocalStudyPlan>
    ),
    LocalStudyPlan,
    PrefetchHooks Function()>;
typedef $$LocalMockTestsTableCreateCompanionBuilder = LocalMockTestsCompanion
    Function({
  required String id,
  required String subjectId,
  Value<String?> circularId,
  Value<String?> materialId,
  Value<String?> topicId,
  required String title,
  Value<String?> source,
  required DateTime takenOn,
  required double marksObtained,
  required double totalMarks,
  Value<double?> negativeMarks,
  Value<int?> timeTakenMinutes,
  Value<int?> timeLimitMinutes,
  Value<String?> weakTopics,
  Value<String?> notes,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$LocalMockTestsTableUpdateCompanionBuilder = LocalMockTestsCompanion
    Function({
  Value<String> id,
  Value<String> subjectId,
  Value<String?> circularId,
  Value<String?> materialId,
  Value<String?> topicId,
  Value<String> title,
  Value<String?> source,
  Value<DateTime> takenOn,
  Value<double> marksObtained,
  Value<double> totalMarks,
  Value<double?> negativeMarks,
  Value<int?> timeTakenMinutes,
  Value<int?> timeLimitMinutes,
  Value<String?> weakTopics,
  Value<String?> notes,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$LocalMockTestsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMockTestsTable> {
  $$LocalMockTestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get circularId => $composableBuilder(
      column: $table.circularId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get takenOn => $composableBuilder(
      column: $table.takenOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get marksObtained => $composableBuilder(
      column: $table.marksObtained, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalMarks => $composableBuilder(
      column: $table.totalMarks, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get negativeMarks => $composableBuilder(
      column: $table.negativeMarks, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timeTakenMinutes => $composableBuilder(
      column: $table.timeTakenMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timeLimitMinutes => $composableBuilder(
      column: $table.timeLimitMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weakTopics => $composableBuilder(
      column: $table.weakTopics, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalMockTestsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMockTestsTable> {
  $$LocalMockTestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get circularId => $composableBuilder(
      column: $table.circularId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get takenOn => $composableBuilder(
      column: $table.takenOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get marksObtained => $composableBuilder(
      column: $table.marksObtained,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalMarks => $composableBuilder(
      column: $table.totalMarks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get negativeMarks => $composableBuilder(
      column: $table.negativeMarks,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeTakenMinutes => $composableBuilder(
      column: $table.timeTakenMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeLimitMinutes => $composableBuilder(
      column: $table.timeLimitMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weakTopics => $composableBuilder(
      column: $table.weakTopics, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalMockTestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMockTestsTable> {
  $$LocalMockTestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get circularId => $composableBuilder(
      column: $table.circularId, builder: (column) => column);

  GeneratedColumn<String> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => column);

  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get takenOn =>
      $composableBuilder(column: $table.takenOn, builder: (column) => column);

  GeneratedColumn<double> get marksObtained => $composableBuilder(
      column: $table.marksObtained, builder: (column) => column);

  GeneratedColumn<double> get totalMarks => $composableBuilder(
      column: $table.totalMarks, builder: (column) => column);

  GeneratedColumn<double> get negativeMarks => $composableBuilder(
      column: $table.negativeMarks, builder: (column) => column);

  GeneratedColumn<int> get timeTakenMinutes => $composableBuilder(
      column: $table.timeTakenMinutes, builder: (column) => column);

  GeneratedColumn<int> get timeLimitMinutes => $composableBuilder(
      column: $table.timeLimitMinutes, builder: (column) => column);

  GeneratedColumn<String> get weakTopics => $composableBuilder(
      column: $table.weakTopics, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalMockTestsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalMockTestsTable,
    LocalMockTest,
    $$LocalMockTestsTableFilterComposer,
    $$LocalMockTestsTableOrderingComposer,
    $$LocalMockTestsTableAnnotationComposer,
    $$LocalMockTestsTableCreateCompanionBuilder,
    $$LocalMockTestsTableUpdateCompanionBuilder,
    (
      LocalMockTest,
      BaseReferences<_$AppDatabase, $LocalMockTestsTable, LocalMockTest>
    ),
    LocalMockTest,
    PrefetchHooks Function()> {
  $$LocalMockTestsTableTableManager(
      _$AppDatabase db, $LocalMockTestsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMockTestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMockTestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMockTestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> subjectId = const Value.absent(),
            Value<String?> circularId = const Value.absent(),
            Value<String?> materialId = const Value.absent(),
            Value<String?> topicId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<DateTime> takenOn = const Value.absent(),
            Value<double> marksObtained = const Value.absent(),
            Value<double> totalMarks = const Value.absent(),
            Value<double?> negativeMarks = const Value.absent(),
            Value<int?> timeTakenMinutes = const Value.absent(),
            Value<int?> timeLimitMinutes = const Value.absent(),
            Value<String?> weakTopics = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMockTestsCompanion(
            id: id,
            subjectId: subjectId,
            circularId: circularId,
            materialId: materialId,
            topicId: topicId,
            title: title,
            source: source,
            takenOn: takenOn,
            marksObtained: marksObtained,
            totalMarks: totalMarks,
            negativeMarks: negativeMarks,
            timeTakenMinutes: timeTakenMinutes,
            timeLimitMinutes: timeLimitMinutes,
            weakTopics: weakTopics,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String subjectId,
            Value<String?> circularId = const Value.absent(),
            Value<String?> materialId = const Value.absent(),
            Value<String?> topicId = const Value.absent(),
            required String title,
            Value<String?> source = const Value.absent(),
            required DateTime takenOn,
            required double marksObtained,
            required double totalMarks,
            Value<double?> negativeMarks = const Value.absent(),
            Value<int?> timeTakenMinutes = const Value.absent(),
            Value<int?> timeLimitMinutes = const Value.absent(),
            Value<String?> weakTopics = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMockTestsCompanion.insert(
            id: id,
            subjectId: subjectId,
            circularId: circularId,
            materialId: materialId,
            topicId: topicId,
            title: title,
            source: source,
            takenOn: takenOn,
            marksObtained: marksObtained,
            totalMarks: totalMarks,
            negativeMarks: negativeMarks,
            timeTakenMinutes: timeTakenMinutes,
            timeLimitMinutes: timeLimitMinutes,
            weakTopics: weakTopics,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalMockTestsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalMockTestsTable,
    LocalMockTest,
    $$LocalMockTestsTableFilterComposer,
    $$LocalMockTestsTableOrderingComposer,
    $$LocalMockTestsTableAnnotationComposer,
    $$LocalMockTestsTableCreateCompanionBuilder,
    $$LocalMockTestsTableUpdateCompanionBuilder,
    (
      LocalMockTest,
      BaseReferences<_$AppDatabase, $LocalMockTestsTable, LocalMockTest>
    ),
    LocalMockTest,
    PrefetchHooks Function()>;
typedef $$LocalRevisionItemsTableCreateCompanionBuilder
    = LocalRevisionItemsCompanion Function({
  required String id,
  required String subjectId,
  Value<String?> materialId,
  Value<String?> topicId,
  required String referenceLabel,
  Value<int?> pageNumber,
  Value<String?> note,
  Value<String> reason,
  Value<String> source,
  Value<String?> progressLogId,
  Value<String?> mockTestId,
  Value<String> status,
  required DateTime dueOn,
  Value<int> reviewCount,
  Value<DateTime?> lastReviewedOn,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$LocalRevisionItemsTableUpdateCompanionBuilder
    = LocalRevisionItemsCompanion Function({
  Value<String> id,
  Value<String> subjectId,
  Value<String?> materialId,
  Value<String?> topicId,
  Value<String> referenceLabel,
  Value<int?> pageNumber,
  Value<String?> note,
  Value<String> reason,
  Value<String> source,
  Value<String?> progressLogId,
  Value<String?> mockTestId,
  Value<String> status,
  Value<DateTime> dueOn,
  Value<int> reviewCount,
  Value<DateTime?> lastReviewedOn,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$LocalRevisionItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalRevisionItemsTable> {
  $$LocalRevisionItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceLabel => $composableBuilder(
      column: $table.referenceLabel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get progressLogId => $composableBuilder(
      column: $table.progressLogId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mockTestId => $composableBuilder(
      column: $table.mockTestId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueOn => $composableBuilder(
      column: $table.dueOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reviewCount => $composableBuilder(
      column: $table.reviewCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastReviewedOn => $composableBuilder(
      column: $table.lastReviewedOn,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalRevisionItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalRevisionItemsTable> {
  $$LocalRevisionItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceLabel => $composableBuilder(
      column: $table.referenceLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get progressLogId => $composableBuilder(
      column: $table.progressLogId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mockTestId => $composableBuilder(
      column: $table.mockTestId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueOn => $composableBuilder(
      column: $table.dueOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reviewCount => $composableBuilder(
      column: $table.reviewCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastReviewedOn => $composableBuilder(
      column: $table.lastReviewedOn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalRevisionItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalRevisionItemsTable> {
  $$LocalRevisionItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => column);

  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<String> get referenceLabel => $composableBuilder(
      column: $table.referenceLabel, builder: (column) => column);

  GeneratedColumn<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get progressLogId => $composableBuilder(
      column: $table.progressLogId, builder: (column) => column);

  GeneratedColumn<String> get mockTestId => $composableBuilder(
      column: $table.mockTestId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get dueOn =>
      $composableBuilder(column: $table.dueOn, builder: (column) => column);

  GeneratedColumn<int> get reviewCount => $composableBuilder(
      column: $table.reviewCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewedOn => $composableBuilder(
      column: $table.lastReviewedOn, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalRevisionItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalRevisionItemsTable,
    LocalRevisionItem,
    $$LocalRevisionItemsTableFilterComposer,
    $$LocalRevisionItemsTableOrderingComposer,
    $$LocalRevisionItemsTableAnnotationComposer,
    $$LocalRevisionItemsTableCreateCompanionBuilder,
    $$LocalRevisionItemsTableUpdateCompanionBuilder,
    (
      LocalRevisionItem,
      BaseReferences<_$AppDatabase, $LocalRevisionItemsTable, LocalRevisionItem>
    ),
    LocalRevisionItem,
    PrefetchHooks Function()> {
  $$LocalRevisionItemsTableTableManager(
      _$AppDatabase db, $LocalRevisionItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalRevisionItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalRevisionItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalRevisionItemsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> subjectId = const Value.absent(),
            Value<String?> materialId = const Value.absent(),
            Value<String?> topicId = const Value.absent(),
            Value<String> referenceLabel = const Value.absent(),
            Value<int?> pageNumber = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String> reason = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> progressLogId = const Value.absent(),
            Value<String?> mockTestId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> dueOn = const Value.absent(),
            Value<int> reviewCount = const Value.absent(),
            Value<DateTime?> lastReviewedOn = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalRevisionItemsCompanion(
            id: id,
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
            status: status,
            dueOn: dueOn,
            reviewCount: reviewCount,
            lastReviewedOn: lastReviewedOn,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String subjectId,
            Value<String?> materialId = const Value.absent(),
            Value<String?> topicId = const Value.absent(),
            required String referenceLabel,
            Value<int?> pageNumber = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String> reason = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> progressLogId = const Value.absent(),
            Value<String?> mockTestId = const Value.absent(),
            Value<String> status = const Value.absent(),
            required DateTime dueOn,
            Value<int> reviewCount = const Value.absent(),
            Value<DateTime?> lastReviewedOn = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalRevisionItemsCompanion.insert(
            id: id,
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
            status: status,
            dueOn: dueOn,
            reviewCount: reviewCount,
            lastReviewedOn: lastReviewedOn,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalRevisionItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalRevisionItemsTable,
    LocalRevisionItem,
    $$LocalRevisionItemsTableFilterComposer,
    $$LocalRevisionItemsTableOrderingComposer,
    $$LocalRevisionItemsTableAnnotationComposer,
    $$LocalRevisionItemsTableCreateCompanionBuilder,
    $$LocalRevisionItemsTableUpdateCompanionBuilder,
    (
      LocalRevisionItem,
      BaseReferences<_$AppDatabase, $LocalRevisionItemsTable, LocalRevisionItem>
    ),
    LocalRevisionItem,
    PrefetchHooks Function()>;
typedef $$LocalStudySessionsTableCreateCompanionBuilder
    = LocalStudySessionsCompanion Function({
  required String id,
  required String subjectId,
  Value<String?> materialId,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  Value<int> durationSeconds,
  Value<String> mode,
  Value<String?> note,
  Value<String> pauseIntervals,
  Value<DateTime?> phaseStartedAt,
  Value<int?> targetDurationSeconds,
  Value<int?> pomodoroRound,
  Value<String?> pomodoroPhase,
  Value<int> focusMinutes,
  Value<int> shortBreakMinutes,
  Value<int> longBreakMinutes,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$LocalStudySessionsTableUpdateCompanionBuilder
    = LocalStudySessionsCompanion Function({
  Value<String> id,
  Value<String> subjectId,
  Value<String?> materialId,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<int> durationSeconds,
  Value<String> mode,
  Value<String?> note,
  Value<String> pauseIntervals,
  Value<DateTime?> phaseStartedAt,
  Value<int?> targetDurationSeconds,
  Value<int?> pomodoroRound,
  Value<String?> pomodoroPhase,
  Value<int> focusMinutes,
  Value<int> shortBreakMinutes,
  Value<int> longBreakMinutes,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$LocalStudySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalStudySessionsTable> {
  $$LocalStudySessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pauseIntervals => $composableBuilder(
      column: $table.pauseIntervals,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get phaseStartedAt => $composableBuilder(
      column: $table.phaseStartedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetDurationSeconds => $composableBuilder(
      column: $table.targetDurationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pomodoroRound => $composableBuilder(
      column: $table.pomodoroRound, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pomodoroPhase => $composableBuilder(
      column: $table.pomodoroPhase, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get focusMinutes => $composableBuilder(
      column: $table.focusMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get shortBreakMinutes => $composableBuilder(
      column: $table.shortBreakMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get longBreakMinutes => $composableBuilder(
      column: $table.longBreakMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalStudySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalStudySessionsTable> {
  $$LocalStudySessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pauseIntervals => $composableBuilder(
      column: $table.pauseIntervals,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get phaseStartedAt => $composableBuilder(
      column: $table.phaseStartedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetDurationSeconds => $composableBuilder(
      column: $table.targetDurationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pomodoroRound => $composableBuilder(
      column: $table.pomodoroRound,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pomodoroPhase => $composableBuilder(
      column: $table.pomodoroPhase,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get focusMinutes => $composableBuilder(
      column: $table.focusMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get shortBreakMinutes => $composableBuilder(
      column: $table.shortBreakMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get longBreakMinutes => $composableBuilder(
      column: $table.longBreakMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalStudySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalStudySessionsTable> {
  $$LocalStudySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get pauseIntervals => $composableBuilder(
      column: $table.pauseIntervals, builder: (column) => column);

  GeneratedColumn<DateTime> get phaseStartedAt => $composableBuilder(
      column: $table.phaseStartedAt, builder: (column) => column);

  GeneratedColumn<int> get targetDurationSeconds => $composableBuilder(
      column: $table.targetDurationSeconds, builder: (column) => column);

  GeneratedColumn<int> get pomodoroRound => $composableBuilder(
      column: $table.pomodoroRound, builder: (column) => column);

  GeneratedColumn<String> get pomodoroPhase => $composableBuilder(
      column: $table.pomodoroPhase, builder: (column) => column);

  GeneratedColumn<int> get focusMinutes => $composableBuilder(
      column: $table.focusMinutes, builder: (column) => column);

  GeneratedColumn<int> get shortBreakMinutes => $composableBuilder(
      column: $table.shortBreakMinutes, builder: (column) => column);

  GeneratedColumn<int> get longBreakMinutes => $composableBuilder(
      column: $table.longBreakMinutes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalStudySessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalStudySessionsTable,
    LocalStudySession,
    $$LocalStudySessionsTableFilterComposer,
    $$LocalStudySessionsTableOrderingComposer,
    $$LocalStudySessionsTableAnnotationComposer,
    $$LocalStudySessionsTableCreateCompanionBuilder,
    $$LocalStudySessionsTableUpdateCompanionBuilder,
    (
      LocalStudySession,
      BaseReferences<_$AppDatabase, $LocalStudySessionsTable, LocalStudySession>
    ),
    LocalStudySession,
    PrefetchHooks Function()> {
  $$LocalStudySessionsTableTableManager(
      _$AppDatabase db, $LocalStudySessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalStudySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalStudySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalStudySessionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> subjectId = const Value.absent(),
            Value<String?> materialId = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<String> mode = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String> pauseIntervals = const Value.absent(),
            Value<DateTime?> phaseStartedAt = const Value.absent(),
            Value<int?> targetDurationSeconds = const Value.absent(),
            Value<int?> pomodoroRound = const Value.absent(),
            Value<String?> pomodoroPhase = const Value.absent(),
            Value<int> focusMinutes = const Value.absent(),
            Value<int> shortBreakMinutes = const Value.absent(),
            Value<int> longBreakMinutes = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalStudySessionsCompanion(
            id: id,
            subjectId: subjectId,
            materialId: materialId,
            startedAt: startedAt,
            endedAt: endedAt,
            durationSeconds: durationSeconds,
            mode: mode,
            note: note,
            pauseIntervals: pauseIntervals,
            phaseStartedAt: phaseStartedAt,
            targetDurationSeconds: targetDurationSeconds,
            pomodoroRound: pomodoroRound,
            pomodoroPhase: pomodoroPhase,
            focusMinutes: focusMinutes,
            shortBreakMinutes: shortBreakMinutes,
            longBreakMinutes: longBreakMinutes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String subjectId,
            Value<String?> materialId = const Value.absent(),
            required DateTime startedAt,
            Value<DateTime?> endedAt = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<String> mode = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String> pauseIntervals = const Value.absent(),
            Value<DateTime?> phaseStartedAt = const Value.absent(),
            Value<int?> targetDurationSeconds = const Value.absent(),
            Value<int?> pomodoroRound = const Value.absent(),
            Value<String?> pomodoroPhase = const Value.absent(),
            Value<int> focusMinutes = const Value.absent(),
            Value<int> shortBreakMinutes = const Value.absent(),
            Value<int> longBreakMinutes = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalStudySessionsCompanion.insert(
            id: id,
            subjectId: subjectId,
            materialId: materialId,
            startedAt: startedAt,
            endedAt: endedAt,
            durationSeconds: durationSeconds,
            mode: mode,
            note: note,
            pauseIntervals: pauseIntervals,
            phaseStartedAt: phaseStartedAt,
            targetDurationSeconds: targetDurationSeconds,
            pomodoroRound: pomodoroRound,
            pomodoroPhase: pomodoroPhase,
            focusMinutes: focusMinutes,
            shortBreakMinutes: shortBreakMinutes,
            longBreakMinutes: longBreakMinutes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalStudySessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalStudySessionsTable,
    LocalStudySession,
    $$LocalStudySessionsTableFilterComposer,
    $$LocalStudySessionsTableOrderingComposer,
    $$LocalStudySessionsTableAnnotationComposer,
    $$LocalStudySessionsTableCreateCompanionBuilder,
    $$LocalStudySessionsTableUpdateCompanionBuilder,
    (
      LocalStudySession,
      BaseReferences<_$AppDatabase, $LocalStudySessionsTable, LocalStudySession>
    ),
    LocalStudySession,
    PrefetchHooks Function()>;
typedef $$LocalNotificationsTableCreateCompanionBuilder
    = LocalNotificationsCompanion Function({
  required String id,
  required String type,
  required String messageKey,
  Value<String> params,
  required String route,
  required String dedupeKey,
  required DateTime createdAt,
  Value<DateTime?> readAt,
  Value<int> rowid,
});
typedef $$LocalNotificationsTableUpdateCompanionBuilder
    = LocalNotificationsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> messageKey,
  Value<String> params,
  Value<String> route,
  Value<String> dedupeKey,
  Value<DateTime> createdAt,
  Value<DateTime?> readAt,
  Value<int> rowid,
});

class $$LocalNotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalNotificationsTable> {
  $$LocalNotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageKey => $composableBuilder(
      column: $table.messageKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get params => $composableBuilder(
      column: $table.params, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get route => $composableBuilder(
      column: $table.route, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dedupeKey => $composableBuilder(
      column: $table.dedupeKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get readAt => $composableBuilder(
      column: $table.readAt, builder: (column) => ColumnFilters(column));
}

class $$LocalNotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalNotificationsTable> {
  $$LocalNotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageKey => $composableBuilder(
      column: $table.messageKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get params => $composableBuilder(
      column: $table.params, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get route => $composableBuilder(
      column: $table.route, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dedupeKey => $composableBuilder(
      column: $table.dedupeKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
      column: $table.readAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalNotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalNotificationsTable> {
  $$LocalNotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get messageKey => $composableBuilder(
      column: $table.messageKey, builder: (column) => column);

  GeneratedColumn<String> get params =>
      $composableBuilder(column: $table.params, builder: (column) => column);

  GeneratedColumn<String> get route =>
      $composableBuilder(column: $table.route, builder: (column) => column);

  GeneratedColumn<String> get dedupeKey =>
      $composableBuilder(column: $table.dedupeKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);
}

class $$LocalNotificationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalNotificationsTable,
    LocalNotification,
    $$LocalNotificationsTableFilterComposer,
    $$LocalNotificationsTableOrderingComposer,
    $$LocalNotificationsTableAnnotationComposer,
    $$LocalNotificationsTableCreateCompanionBuilder,
    $$LocalNotificationsTableUpdateCompanionBuilder,
    (
      LocalNotification,
      BaseReferences<_$AppDatabase, $LocalNotificationsTable, LocalNotification>
    ),
    LocalNotification,
    PrefetchHooks Function()> {
  $$LocalNotificationsTableTableManager(
      _$AppDatabase db, $LocalNotificationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalNotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalNotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalNotificationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> messageKey = const Value.absent(),
            Value<String> params = const Value.absent(),
            Value<String> route = const Value.absent(),
            Value<String> dedupeKey = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> readAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalNotificationsCompanion(
            id: id,
            type: type,
            messageKey: messageKey,
            params: params,
            route: route,
            dedupeKey: dedupeKey,
            createdAt: createdAt,
            readAt: readAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required String messageKey,
            Value<String> params = const Value.absent(),
            required String route,
            required String dedupeKey,
            required DateTime createdAt,
            Value<DateTime?> readAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalNotificationsCompanion.insert(
            id: id,
            type: type,
            messageKey: messageKey,
            params: params,
            route: route,
            dedupeKey: dedupeKey,
            createdAt: createdAt,
            readAt: readAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalNotificationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalNotificationsTable,
    LocalNotification,
    $$LocalNotificationsTableFilterComposer,
    $$LocalNotificationsTableOrderingComposer,
    $$LocalNotificationsTableAnnotationComposer,
    $$LocalNotificationsTableCreateCompanionBuilder,
    $$LocalNotificationsTableUpdateCompanionBuilder,
    (
      LocalNotification,
      BaseReferences<_$AppDatabase, $LocalNotificationsTable, LocalNotification>
    ),
    LocalNotification,
    PrefetchHooks Function()>;
typedef $$LocalPortalAccountsTableCreateCompanionBuilder
    = LocalPortalAccountsCompanion Function({
  required String id,
  required String circularId,
  Value<String?> portalUrl,
  required String username,
  required String encryptedPassword,
  required String salt,
  required String nonce,
  Value<int> iterations,
  Value<String?> notes,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$LocalPortalAccountsTableUpdateCompanionBuilder
    = LocalPortalAccountsCompanion Function({
  Value<String> id,
  Value<String> circularId,
  Value<String?> portalUrl,
  Value<String> username,
  Value<String> encryptedPassword,
  Value<String> salt,
  Value<String> nonce,
  Value<int> iterations,
  Value<String?> notes,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$LocalPortalAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPortalAccountsTable> {
  $$LocalPortalAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get circularId => $composableBuilder(
      column: $table.circularId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get portalUrl => $composableBuilder(
      column: $table.portalUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get encryptedPassword => $composableBuilder(
      column: $table.encryptedPassword,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get salt => $composableBuilder(
      column: $table.salt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nonce => $composableBuilder(
      column: $table.nonce, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get iterations => $composableBuilder(
      column: $table.iterations, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalPortalAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPortalAccountsTable> {
  $$LocalPortalAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get circularId => $composableBuilder(
      column: $table.circularId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get portalUrl => $composableBuilder(
      column: $table.portalUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get encryptedPassword => $composableBuilder(
      column: $table.encryptedPassword,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get salt => $composableBuilder(
      column: $table.salt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nonce => $composableBuilder(
      column: $table.nonce, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get iterations => $composableBuilder(
      column: $table.iterations, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalPortalAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPortalAccountsTable> {
  $$LocalPortalAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get circularId => $composableBuilder(
      column: $table.circularId, builder: (column) => column);

  GeneratedColumn<String> get portalUrl =>
      $composableBuilder(column: $table.portalUrl, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get encryptedPassword => $composableBuilder(
      column: $table.encryptedPassword, builder: (column) => column);

  GeneratedColumn<String> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<String> get nonce =>
      $composableBuilder(column: $table.nonce, builder: (column) => column);

  GeneratedColumn<int> get iterations => $composableBuilder(
      column: $table.iterations, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalPortalAccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalPortalAccountsTable,
    LocalPortalAccount,
    $$LocalPortalAccountsTableFilterComposer,
    $$LocalPortalAccountsTableOrderingComposer,
    $$LocalPortalAccountsTableAnnotationComposer,
    $$LocalPortalAccountsTableCreateCompanionBuilder,
    $$LocalPortalAccountsTableUpdateCompanionBuilder,
    (
      LocalPortalAccount,
      BaseReferences<_$AppDatabase, $LocalPortalAccountsTable,
          LocalPortalAccount>
    ),
    LocalPortalAccount,
    PrefetchHooks Function()> {
  $$LocalPortalAccountsTableTableManager(
      _$AppDatabase db, $LocalPortalAccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPortalAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPortalAccountsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalPortalAccountsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> circularId = const Value.absent(),
            Value<String?> portalUrl = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> encryptedPassword = const Value.absent(),
            Value<String> salt = const Value.absent(),
            Value<String> nonce = const Value.absent(),
            Value<int> iterations = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalPortalAccountsCompanion(
            id: id,
            circularId: circularId,
            portalUrl: portalUrl,
            username: username,
            encryptedPassword: encryptedPassword,
            salt: salt,
            nonce: nonce,
            iterations: iterations,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String circularId,
            Value<String?> portalUrl = const Value.absent(),
            required String username,
            required String encryptedPassword,
            required String salt,
            required String nonce,
            Value<int> iterations = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalPortalAccountsCompanion.insert(
            id: id,
            circularId: circularId,
            portalUrl: portalUrl,
            username: username,
            encryptedPassword: encryptedPassword,
            salt: salt,
            nonce: nonce,
            iterations: iterations,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalPortalAccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalPortalAccountsTable,
    LocalPortalAccount,
    $$LocalPortalAccountsTableFilterComposer,
    $$LocalPortalAccountsTableOrderingComposer,
    $$LocalPortalAccountsTableAnnotationComposer,
    $$LocalPortalAccountsTableCreateCompanionBuilder,
    $$LocalPortalAccountsTableUpdateCompanionBuilder,
    (
      LocalPortalAccount,
      BaseReferences<_$AppDatabase, $LocalPortalAccountsTable,
          LocalPortalAccount>
    ),
    LocalPortalAccount,
    PrefetchHooks Function()>;
typedef $$LocalUserSettingsTableCreateCompanionBuilder
    = LocalUserSettingsCompanion Function({
  required String id,
  Value<DateTime?> onboardingCompletedAt,
  Value<int> onboardingStep,
  Value<String> onboardingDraft,
  Value<bool> todayTipsDismissed,
  Value<String?> displayName,
  Value<String> themeMode,
  Value<bool> reduceEffects,
  Value<String> localeCode,
  Value<bool> banglaDigits,
  Value<int> focusMinutes,
  Value<int> shortBreakMinutes,
  Value<int> longBreakMinutes,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$LocalUserSettingsTableUpdateCompanionBuilder
    = LocalUserSettingsCompanion Function({
  Value<String> id,
  Value<DateTime?> onboardingCompletedAt,
  Value<int> onboardingStep,
  Value<String> onboardingDraft,
  Value<bool> todayTipsDismissed,
  Value<String?> displayName,
  Value<String> themeMode,
  Value<bool> reduceEffects,
  Value<String> localeCode,
  Value<bool> banglaDigits,
  Value<int> focusMinutes,
  Value<int> shortBreakMinutes,
  Value<int> longBreakMinutes,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$LocalUserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUserSettingsTable> {
  $$LocalUserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get onboardingCompletedAt => $composableBuilder(
      column: $table.onboardingCompletedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get onboardingStep => $composableBuilder(
      column: $table.onboardingStep,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get onboardingDraft => $composableBuilder(
      column: $table.onboardingDraft,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get todayTipsDismissed => $composableBuilder(
      column: $table.todayTipsDismissed,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get reduceEffects => $composableBuilder(
      column: $table.reduceEffects, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localeCode => $composableBuilder(
      column: $table.localeCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get banglaDigits => $composableBuilder(
      column: $table.banglaDigits, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get focusMinutes => $composableBuilder(
      column: $table.focusMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get shortBreakMinutes => $composableBuilder(
      column: $table.shortBreakMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get longBreakMinutes => $composableBuilder(
      column: $table.longBreakMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalUserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUserSettingsTable> {
  $$LocalUserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get onboardingCompletedAt => $composableBuilder(
      column: $table.onboardingCompletedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get onboardingStep => $composableBuilder(
      column: $table.onboardingStep,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get onboardingDraft => $composableBuilder(
      column: $table.onboardingDraft,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get todayTipsDismissed => $composableBuilder(
      column: $table.todayTipsDismissed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get reduceEffects => $composableBuilder(
      column: $table.reduceEffects,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localeCode => $composableBuilder(
      column: $table.localeCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get banglaDigits => $composableBuilder(
      column: $table.banglaDigits,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get focusMinutes => $composableBuilder(
      column: $table.focusMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get shortBreakMinutes => $composableBuilder(
      column: $table.shortBreakMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get longBreakMinutes => $composableBuilder(
      column: $table.longBreakMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalUserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUserSettingsTable> {
  $$LocalUserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get onboardingCompletedAt => $composableBuilder(
      column: $table.onboardingCompletedAt, builder: (column) => column);

  GeneratedColumn<int> get onboardingStep => $composableBuilder(
      column: $table.onboardingStep, builder: (column) => column);

  GeneratedColumn<String> get onboardingDraft => $composableBuilder(
      column: $table.onboardingDraft, builder: (column) => column);

  GeneratedColumn<bool> get todayTipsDismissed => $composableBuilder(
      column: $table.todayTipsDismissed, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get reduceEffects => $composableBuilder(
      column: $table.reduceEffects, builder: (column) => column);

  GeneratedColumn<String> get localeCode => $composableBuilder(
      column: $table.localeCode, builder: (column) => column);

  GeneratedColumn<bool> get banglaDigits => $composableBuilder(
      column: $table.banglaDigits, builder: (column) => column);

  GeneratedColumn<int> get focusMinutes => $composableBuilder(
      column: $table.focusMinutes, builder: (column) => column);

  GeneratedColumn<int> get shortBreakMinutes => $composableBuilder(
      column: $table.shortBreakMinutes, builder: (column) => column);

  GeneratedColumn<int> get longBreakMinutes => $composableBuilder(
      column: $table.longBreakMinutes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalUserSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalUserSettingsTable,
    LocalUserSetting,
    $$LocalUserSettingsTableFilterComposer,
    $$LocalUserSettingsTableOrderingComposer,
    $$LocalUserSettingsTableAnnotationComposer,
    $$LocalUserSettingsTableCreateCompanionBuilder,
    $$LocalUserSettingsTableUpdateCompanionBuilder,
    (
      LocalUserSetting,
      BaseReferences<_$AppDatabase, $LocalUserSettingsTable, LocalUserSetting>
    ),
    LocalUserSetting,
    PrefetchHooks Function()> {
  $$LocalUserSettingsTableTableManager(
      _$AppDatabase db, $LocalUserSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUserSettingsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime?> onboardingCompletedAt = const Value.absent(),
            Value<int> onboardingStep = const Value.absent(),
            Value<String> onboardingDraft = const Value.absent(),
            Value<bool> todayTipsDismissed = const Value.absent(),
            Value<String?> displayName = const Value.absent(),
            Value<String> themeMode = const Value.absent(),
            Value<bool> reduceEffects = const Value.absent(),
            Value<String> localeCode = const Value.absent(),
            Value<bool> banglaDigits = const Value.absent(),
            Value<int> focusMinutes = const Value.absent(),
            Value<int> shortBreakMinutes = const Value.absent(),
            Value<int> longBreakMinutes = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalUserSettingsCompanion(
            id: id,
            onboardingCompletedAt: onboardingCompletedAt,
            onboardingStep: onboardingStep,
            onboardingDraft: onboardingDraft,
            todayTipsDismissed: todayTipsDismissed,
            displayName: displayName,
            themeMode: themeMode,
            reduceEffects: reduceEffects,
            localeCode: localeCode,
            banglaDigits: banglaDigits,
            focusMinutes: focusMinutes,
            shortBreakMinutes: shortBreakMinutes,
            longBreakMinutes: longBreakMinutes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime?> onboardingCompletedAt = const Value.absent(),
            Value<int> onboardingStep = const Value.absent(),
            Value<String> onboardingDraft = const Value.absent(),
            Value<bool> todayTipsDismissed = const Value.absent(),
            Value<String?> displayName = const Value.absent(),
            Value<String> themeMode = const Value.absent(),
            Value<bool> reduceEffects = const Value.absent(),
            Value<String> localeCode = const Value.absent(),
            Value<bool> banglaDigits = const Value.absent(),
            Value<int> focusMinutes = const Value.absent(),
            Value<int> shortBreakMinutes = const Value.absent(),
            Value<int> longBreakMinutes = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalUserSettingsCompanion.insert(
            id: id,
            onboardingCompletedAt: onboardingCompletedAt,
            onboardingStep: onboardingStep,
            onboardingDraft: onboardingDraft,
            todayTipsDismissed: todayTipsDismissed,
            displayName: displayName,
            themeMode: themeMode,
            reduceEffects: reduceEffects,
            localeCode: localeCode,
            banglaDigits: banglaDigits,
            focusMinutes: focusMinutes,
            shortBreakMinutes: shortBreakMinutes,
            longBreakMinutes: longBreakMinutes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalUserSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalUserSettingsTable,
    LocalUserSetting,
    $$LocalUserSettingsTableFilterComposer,
    $$LocalUserSettingsTableOrderingComposer,
    $$LocalUserSettingsTableAnnotationComposer,
    $$LocalUserSettingsTableCreateCompanionBuilder,
    $$LocalUserSettingsTableUpdateCompanionBuilder,
    (
      LocalUserSetting,
      BaseReferences<_$AppDatabase, $LocalUserSettingsTable, LocalUserSetting>
    ),
    LocalUserSetting,
    PrefetchHooks Function()>;
typedef $$LocalUserReminderSettingsTableCreateCompanionBuilder
    = LocalUserReminderSettingsCompanion Function({
  required String id,
  Value<bool> remindersEnabled,
  Value<String> leadDays,
  Value<String> reminderLanguage,
  Value<bool> deadlineSoon,
  Value<bool> examSoon,
  Value<bool> revisionDue,
  Value<bool> behindSchedule,
  Value<bool> weeklyReview,
  Value<int> weeklyReviewDay,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$LocalUserReminderSettingsTableUpdateCompanionBuilder
    = LocalUserReminderSettingsCompanion Function({
  Value<String> id,
  Value<bool> remindersEnabled,
  Value<String> leadDays,
  Value<String> reminderLanguage,
  Value<bool> deadlineSoon,
  Value<bool> examSoon,
  Value<bool> revisionDue,
  Value<bool> behindSchedule,
  Value<bool> weeklyReview,
  Value<int> weeklyReviewDay,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$LocalUserReminderSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUserReminderSettingsTable> {
  $$LocalUserReminderSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get remindersEnabled => $composableBuilder(
      column: $table.remindersEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get leadDays => $composableBuilder(
      column: $table.leadDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderLanguage => $composableBuilder(
      column: $table.reminderLanguage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deadlineSoon => $composableBuilder(
      column: $table.deadlineSoon, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get examSoon => $composableBuilder(
      column: $table.examSoon, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get revisionDue => $composableBuilder(
      column: $table.revisionDue, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get behindSchedule => $composableBuilder(
      column: $table.behindSchedule,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get weeklyReview => $composableBuilder(
      column: $table.weeklyReview, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weeklyReviewDay => $composableBuilder(
      column: $table.weeklyReviewDay,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalUserReminderSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUserReminderSettingsTable> {
  $$LocalUserReminderSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get remindersEnabled => $composableBuilder(
      column: $table.remindersEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get leadDays => $composableBuilder(
      column: $table.leadDays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderLanguage => $composableBuilder(
      column: $table.reminderLanguage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deadlineSoon => $composableBuilder(
      column: $table.deadlineSoon,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get examSoon => $composableBuilder(
      column: $table.examSoon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get revisionDue => $composableBuilder(
      column: $table.revisionDue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get behindSchedule => $composableBuilder(
      column: $table.behindSchedule,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get weeklyReview => $composableBuilder(
      column: $table.weeklyReview,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weeklyReviewDay => $composableBuilder(
      column: $table.weeklyReviewDay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalUserReminderSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUserReminderSettingsTable> {
  $$LocalUserReminderSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get remindersEnabled => $composableBuilder(
      column: $table.remindersEnabled, builder: (column) => column);

  GeneratedColumn<String> get leadDays =>
      $composableBuilder(column: $table.leadDays, builder: (column) => column);

  GeneratedColumn<String> get reminderLanguage => $composableBuilder(
      column: $table.reminderLanguage, builder: (column) => column);

  GeneratedColumn<bool> get deadlineSoon => $composableBuilder(
      column: $table.deadlineSoon, builder: (column) => column);

  GeneratedColumn<bool> get examSoon =>
      $composableBuilder(column: $table.examSoon, builder: (column) => column);

  GeneratedColumn<bool> get revisionDue => $composableBuilder(
      column: $table.revisionDue, builder: (column) => column);

  GeneratedColumn<bool> get behindSchedule => $composableBuilder(
      column: $table.behindSchedule, builder: (column) => column);

  GeneratedColumn<bool> get weeklyReview => $composableBuilder(
      column: $table.weeklyReview, builder: (column) => column);

  GeneratedColumn<int> get weeklyReviewDay => $composableBuilder(
      column: $table.weeklyReviewDay, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalUserReminderSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalUserReminderSettingsTable,
    LocalUserReminderSetting,
    $$LocalUserReminderSettingsTableFilterComposer,
    $$LocalUserReminderSettingsTableOrderingComposer,
    $$LocalUserReminderSettingsTableAnnotationComposer,
    $$LocalUserReminderSettingsTableCreateCompanionBuilder,
    $$LocalUserReminderSettingsTableUpdateCompanionBuilder,
    (
      LocalUserReminderSetting,
      BaseReferences<_$AppDatabase, $LocalUserReminderSettingsTable,
          LocalUserReminderSetting>
    ),
    LocalUserReminderSetting,
    PrefetchHooks Function()> {
  $$LocalUserReminderSettingsTableTableManager(
      _$AppDatabase db, $LocalUserReminderSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUserReminderSettingsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUserReminderSettingsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUserReminderSettingsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<bool> remindersEnabled = const Value.absent(),
            Value<String> leadDays = const Value.absent(),
            Value<String> reminderLanguage = const Value.absent(),
            Value<bool> deadlineSoon = const Value.absent(),
            Value<bool> examSoon = const Value.absent(),
            Value<bool> revisionDue = const Value.absent(),
            Value<bool> behindSchedule = const Value.absent(),
            Value<bool> weeklyReview = const Value.absent(),
            Value<int> weeklyReviewDay = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalUserReminderSettingsCompanion(
            id: id,
            remindersEnabled: remindersEnabled,
            leadDays: leadDays,
            reminderLanguage: reminderLanguage,
            deadlineSoon: deadlineSoon,
            examSoon: examSoon,
            revisionDue: revisionDue,
            behindSchedule: behindSchedule,
            weeklyReview: weeklyReview,
            weeklyReviewDay: weeklyReviewDay,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<bool> remindersEnabled = const Value.absent(),
            Value<String> leadDays = const Value.absent(),
            Value<String> reminderLanguage = const Value.absent(),
            Value<bool> deadlineSoon = const Value.absent(),
            Value<bool> examSoon = const Value.absent(),
            Value<bool> revisionDue = const Value.absent(),
            Value<bool> behindSchedule = const Value.absent(),
            Value<bool> weeklyReview = const Value.absent(),
            Value<int> weeklyReviewDay = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalUserReminderSettingsCompanion.insert(
            id: id,
            remindersEnabled: remindersEnabled,
            leadDays: leadDays,
            reminderLanguage: reminderLanguage,
            deadlineSoon: deadlineSoon,
            examSoon: examSoon,
            revisionDue: revisionDue,
            behindSchedule: behindSchedule,
            weeklyReview: weeklyReview,
            weeklyReviewDay: weeklyReviewDay,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalUserReminderSettingsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalUserReminderSettingsTable,
        LocalUserReminderSetting,
        $$LocalUserReminderSettingsTableFilterComposer,
        $$LocalUserReminderSettingsTableOrderingComposer,
        $$LocalUserReminderSettingsTableAnnotationComposer,
        $$LocalUserReminderSettingsTableCreateCompanionBuilder,
        $$LocalUserReminderSettingsTableUpdateCompanionBuilder,
        (
          LocalUserReminderSetting,
          BaseReferences<_$AppDatabase, $LocalUserReminderSettingsTable,
              LocalUserReminderSetting>
        ),
        LocalUserReminderSetting,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalCircularsTableTableManager get localCirculars =>
      $$LocalCircularsTableTableManager(_db, _db.localCirculars);
  $$LocalCircularExamDatesTableTableManager get localCircularExamDates =>
      $$LocalCircularExamDatesTableTableManager(
          _db, _db.localCircularExamDates);
  $$LocalSubjectsTableTableManager get localSubjects =>
      $$LocalSubjectsTableTableManager(_db, _db.localSubjects);
  $$LocalMaterialsTableTableManager get localMaterials =>
      $$LocalMaterialsTableTableManager(_db, _db.localMaterials);
  $$LocalProgressLogsTableTableManager get localProgressLogs =>
      $$LocalProgressLogsTableTableManager(_db, _db.localProgressLogs);
  $$LocalTopicsTableTableManager get localTopics =>
      $$LocalTopicsTableTableManager(_db, _db.localTopics);
  $$LocalCircularSubjectsTableTableManager get localCircularSubjects =>
      $$LocalCircularSubjectsTableTableManager(_db, _db.localCircularSubjects);
  $$LocalStudyPlansTableTableManager get localStudyPlans =>
      $$LocalStudyPlansTableTableManager(_db, _db.localStudyPlans);
  $$LocalMockTestsTableTableManager get localMockTests =>
      $$LocalMockTestsTableTableManager(_db, _db.localMockTests);
  $$LocalRevisionItemsTableTableManager get localRevisionItems =>
      $$LocalRevisionItemsTableTableManager(_db, _db.localRevisionItems);
  $$LocalStudySessionsTableTableManager get localStudySessions =>
      $$LocalStudySessionsTableTableManager(_db, _db.localStudySessions);
  $$LocalNotificationsTableTableManager get localNotifications =>
      $$LocalNotificationsTableTableManager(_db, _db.localNotifications);
  $$LocalPortalAccountsTableTableManager get localPortalAccounts =>
      $$LocalPortalAccountsTableTableManager(_db, _db.localPortalAccounts);
  $$LocalUserSettingsTableTableManager get localUserSettings =>
      $$LocalUserSettingsTableTableManager(_db, _db.localUserSettings);
  $$LocalUserReminderSettingsTableTableManager get localUserReminderSettings =>
      $$LocalUserReminderSettingsTableTableManager(
          _db, _db.localUserReminderSettings);
}
