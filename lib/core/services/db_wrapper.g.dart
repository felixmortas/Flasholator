// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_wrapper.dart';

// ignore_for_file: type=lint
class $FlashcardsTable extends Flashcards
    with TableInfo<$FlashcardsTable, FlashcardData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashcardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _frontMeta = const VerificationMeta('front');
  @override
  late final GeneratedColumn<String> front = GeneratedColumn<String>(
      'front', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _backMeta = const VerificationMeta('back');
  @override
  late final GeneratedColumn<String> back = GeneratedColumn<String>(
      'back', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceLangMeta =
      const VerificationMeta('sourceLang');
  @override
  late final GeneratedColumn<String> sourceLang = GeneratedColumn<String>(
      'source_lang', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetLangMeta =
      const VerificationMeta('targetLang');
  @override
  late final GeneratedColumn<String> targetLang = GeneratedColumn<String>(
      'target_lang', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addedDateMeta =
      const VerificationMeta('addedDate');
  @override
  late final GeneratedColumn<DateTime> addedDate = GeneratedColumn<DateTime>(
      'added_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _qualityMeta =
      const VerificationMeta('quality');
  @override
  late final GeneratedColumn<int> quality = GeneratedColumn<int>(
      'quality', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _easinessMeta =
      const VerificationMeta('easiness');
  @override
  late final GeneratedColumn<double> easiness = GeneratedColumn<double>(
      'easiness', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _intervalMeta =
      const VerificationMeta('interval');
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
      'interval', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _repetitionsMeta =
      const VerificationMeta('repetitions');
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
      'repetitions', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _timesReviewedMeta =
      const VerificationMeta('timesReviewed');
  @override
  late final GeneratedColumn<int> timesReviewed = GeneratedColumn<int>(
      'times_reviewed', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastReviewDateMeta =
      const VerificationMeta('lastReviewDate');
  @override
  late final GeneratedColumn<DateTime> lastReviewDate =
      GeneratedColumn<DateTime>('last_review_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nextReviewDateMeta =
      const VerificationMeta('nextReviewDate');
  @override
  late final GeneratedColumn<DateTime> nextReviewDate =
      GeneratedColumn<DateTime>('next_review_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        front,
        back,
        sourceLang,
        targetLang,
        addedDate,
        quality,
        easiness,
        interval,
        repetitions,
        timesReviewed,
        lastReviewDate,
        nextReviewDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcards';
  @override
  VerificationContext validateIntegrity(Insertable<FlashcardData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('front')) {
      context.handle(
          _frontMeta, front.isAcceptableOrUnknown(data['front']!, _frontMeta));
    } else if (isInserting) {
      context.missing(_frontMeta);
    }
    if (data.containsKey('back')) {
      context.handle(
          _backMeta, back.isAcceptableOrUnknown(data['back']!, _backMeta));
    } else if (isInserting) {
      context.missing(_backMeta);
    }
    if (data.containsKey('source_lang')) {
      context.handle(
          _sourceLangMeta,
          sourceLang.isAcceptableOrUnknown(
              data['source_lang']!, _sourceLangMeta));
    } else if (isInserting) {
      context.missing(_sourceLangMeta);
    }
    if (data.containsKey('target_lang')) {
      context.handle(
          _targetLangMeta,
          targetLang.isAcceptableOrUnknown(
              data['target_lang']!, _targetLangMeta));
    } else if (isInserting) {
      context.missing(_targetLangMeta);
    }
    if (data.containsKey('added_date')) {
      context.handle(_addedDateMeta,
          addedDate.isAcceptableOrUnknown(data['added_date']!, _addedDateMeta));
    } else if (isInserting) {
      context.missing(_addedDateMeta);
    }
    if (data.containsKey('quality')) {
      context.handle(_qualityMeta,
          quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta));
    }
    if (data.containsKey('easiness')) {
      context.handle(_easinessMeta,
          easiness.isAcceptableOrUnknown(data['easiness']!, _easinessMeta));
    } else if (isInserting) {
      context.missing(_easinessMeta);
    }
    if (data.containsKey('interval')) {
      context.handle(_intervalMeta,
          interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta));
    } else if (isInserting) {
      context.missing(_intervalMeta);
    }
    if (data.containsKey('repetitions')) {
      context.handle(
          _repetitionsMeta,
          repetitions.isAcceptableOrUnknown(
              data['repetitions']!, _repetitionsMeta));
    } else if (isInserting) {
      context.missing(_repetitionsMeta);
    }
    if (data.containsKey('times_reviewed')) {
      context.handle(
          _timesReviewedMeta,
          timesReviewed.isAcceptableOrUnknown(
              data['times_reviewed']!, _timesReviewedMeta));
    } else if (isInserting) {
      context.missing(_timesReviewedMeta);
    }
    if (data.containsKey('last_review_date')) {
      context.handle(
          _lastReviewDateMeta,
          lastReviewDate.isAcceptableOrUnknown(
              data['last_review_date']!, _lastReviewDateMeta));
    }
    if (data.containsKey('next_review_date')) {
      context.handle(
          _nextReviewDateMeta,
          nextReviewDate.isAcceptableOrUnknown(
              data['next_review_date']!, _nextReviewDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FlashcardData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlashcardData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      front: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}front'])!,
      back: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}back'])!,
      sourceLang: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_lang'])!,
      targetLang: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_lang'])!,
      addedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_date'])!,
      quality: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quality']),
      easiness: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}easiness'])!,
      interval: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval'])!,
      repetitions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}repetitions'])!,
      timesReviewed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}times_reviewed'])!,
      lastReviewDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_review_date']),
      nextReviewDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_review_date']),
    );
  }

  @override
  $FlashcardsTable createAlias(String alias) {
    return $FlashcardsTable(attachedDatabase, alias);
  }
}

class FlashcardData extends DataClass implements Insertable<FlashcardData> {
  final int id;
  final String front;
  final String back;
  final String sourceLang;
  final String targetLang;
  final DateTime addedDate;
  final int? quality;
  final double easiness;
  final int interval;
  final int repetitions;
  final int timesReviewed;
  final DateTime? lastReviewDate;
  final DateTime? nextReviewDate;
  const FlashcardData(
      {required this.id,
      required this.front,
      required this.back,
      required this.sourceLang,
      required this.targetLang,
      required this.addedDate,
      this.quality,
      required this.easiness,
      required this.interval,
      required this.repetitions,
      required this.timesReviewed,
      this.lastReviewDate,
      this.nextReviewDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['front'] = Variable<String>(front);
    map['back'] = Variable<String>(back);
    map['source_lang'] = Variable<String>(sourceLang);
    map['target_lang'] = Variable<String>(targetLang);
    map['added_date'] = Variable<DateTime>(addedDate);
    if (!nullToAbsent || quality != null) {
      map['quality'] = Variable<int>(quality);
    }
    map['easiness'] = Variable<double>(easiness);
    map['interval'] = Variable<int>(interval);
    map['repetitions'] = Variable<int>(repetitions);
    map['times_reviewed'] = Variable<int>(timesReviewed);
    if (!nullToAbsent || lastReviewDate != null) {
      map['last_review_date'] = Variable<DateTime>(lastReviewDate);
    }
    if (!nullToAbsent || nextReviewDate != null) {
      map['next_review_date'] = Variable<DateTime>(nextReviewDate);
    }
    return map;
  }

  FlashcardsCompanion toCompanion(bool nullToAbsent) {
    return FlashcardsCompanion(
      id: Value(id),
      front: Value(front),
      back: Value(back),
      sourceLang: Value(sourceLang),
      targetLang: Value(targetLang),
      addedDate: Value(addedDate),
      quality: quality == null && nullToAbsent
          ? const Value.absent()
          : Value(quality),
      easiness: Value(easiness),
      interval: Value(interval),
      repetitions: Value(repetitions),
      timesReviewed: Value(timesReviewed),
      lastReviewDate: lastReviewDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewDate),
      nextReviewDate: nextReviewDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReviewDate),
    );
  }

  factory FlashcardData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlashcardData(
      id: serializer.fromJson<int>(json['id']),
      front: serializer.fromJson<String>(json['front']),
      back: serializer.fromJson<String>(json['back']),
      sourceLang: serializer.fromJson<String>(json['sourceLang']),
      targetLang: serializer.fromJson<String>(json['targetLang']),
      addedDate: serializer.fromJson<DateTime>(json['addedDate']),
      quality: serializer.fromJson<int?>(json['quality']),
      easiness: serializer.fromJson<double>(json['easiness']),
      interval: serializer.fromJson<int>(json['interval']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      timesReviewed: serializer.fromJson<int>(json['timesReviewed']),
      lastReviewDate: serializer.fromJson<DateTime?>(json['lastReviewDate']),
      nextReviewDate: serializer.fromJson<DateTime?>(json['nextReviewDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'front': serializer.toJson<String>(front),
      'back': serializer.toJson<String>(back),
      'sourceLang': serializer.toJson<String>(sourceLang),
      'targetLang': serializer.toJson<String>(targetLang),
      'addedDate': serializer.toJson<DateTime>(addedDate),
      'quality': serializer.toJson<int?>(quality),
      'easiness': serializer.toJson<double>(easiness),
      'interval': serializer.toJson<int>(interval),
      'repetitions': serializer.toJson<int>(repetitions),
      'timesReviewed': serializer.toJson<int>(timesReviewed),
      'lastReviewDate': serializer.toJson<DateTime?>(lastReviewDate),
      'nextReviewDate': serializer.toJson<DateTime?>(nextReviewDate),
    };
  }

  FlashcardData copyWith(
          {int? id,
          String? front,
          String? back,
          String? sourceLang,
          String? targetLang,
          DateTime? addedDate,
          Value<int?> quality = const Value.absent(),
          double? easiness,
          int? interval,
          int? repetitions,
          int? timesReviewed,
          Value<DateTime?> lastReviewDate = const Value.absent(),
          Value<DateTime?> nextReviewDate = const Value.absent()}) =>
      FlashcardData(
        id: id ?? this.id,
        front: front ?? this.front,
        back: back ?? this.back,
        sourceLang: sourceLang ?? this.sourceLang,
        targetLang: targetLang ?? this.targetLang,
        addedDate: addedDate ?? this.addedDate,
        quality: quality.present ? quality.value : this.quality,
        easiness: easiness ?? this.easiness,
        interval: interval ?? this.interval,
        repetitions: repetitions ?? this.repetitions,
        timesReviewed: timesReviewed ?? this.timesReviewed,
        lastReviewDate:
            lastReviewDate.present ? lastReviewDate.value : this.lastReviewDate,
        nextReviewDate:
            nextReviewDate.present ? nextReviewDate.value : this.nextReviewDate,
      );
  FlashcardData copyWithCompanion(FlashcardsCompanion data) {
    return FlashcardData(
      id: data.id.present ? data.id.value : this.id,
      front: data.front.present ? data.front.value : this.front,
      back: data.back.present ? data.back.value : this.back,
      sourceLang:
          data.sourceLang.present ? data.sourceLang.value : this.sourceLang,
      targetLang:
          data.targetLang.present ? data.targetLang.value : this.targetLang,
      addedDate: data.addedDate.present ? data.addedDate.value : this.addedDate,
      quality: data.quality.present ? data.quality.value : this.quality,
      easiness: data.easiness.present ? data.easiness.value : this.easiness,
      interval: data.interval.present ? data.interval.value : this.interval,
      repetitions:
          data.repetitions.present ? data.repetitions.value : this.repetitions,
      timesReviewed: data.timesReviewed.present
          ? data.timesReviewed.value
          : this.timesReviewed,
      lastReviewDate: data.lastReviewDate.present
          ? data.lastReviewDate.value
          : this.lastReviewDate,
      nextReviewDate: data.nextReviewDate.present
          ? data.nextReviewDate.value
          : this.nextReviewDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardData(')
          ..write('id: $id, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('sourceLang: $sourceLang, ')
          ..write('targetLang: $targetLang, ')
          ..write('addedDate: $addedDate, ')
          ..write('quality: $quality, ')
          ..write('easiness: $easiness, ')
          ..write('interval: $interval, ')
          ..write('repetitions: $repetitions, ')
          ..write('timesReviewed: $timesReviewed, ')
          ..write('lastReviewDate: $lastReviewDate, ')
          ..write('nextReviewDate: $nextReviewDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      front,
      back,
      sourceLang,
      targetLang,
      addedDate,
      quality,
      easiness,
      interval,
      repetitions,
      timesReviewed,
      lastReviewDate,
      nextReviewDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlashcardData &&
          other.id == this.id &&
          other.front == this.front &&
          other.back == this.back &&
          other.sourceLang == this.sourceLang &&
          other.targetLang == this.targetLang &&
          other.addedDate == this.addedDate &&
          other.quality == this.quality &&
          other.easiness == this.easiness &&
          other.interval == this.interval &&
          other.repetitions == this.repetitions &&
          other.timesReviewed == this.timesReviewed &&
          other.lastReviewDate == this.lastReviewDate &&
          other.nextReviewDate == this.nextReviewDate);
}

class FlashcardsCompanion extends UpdateCompanion<FlashcardData> {
  final Value<int> id;
  final Value<String> front;
  final Value<String> back;
  final Value<String> sourceLang;
  final Value<String> targetLang;
  final Value<DateTime> addedDate;
  final Value<int?> quality;
  final Value<double> easiness;
  final Value<int> interval;
  final Value<int> repetitions;
  final Value<int> timesReviewed;
  final Value<DateTime?> lastReviewDate;
  final Value<DateTime?> nextReviewDate;
  const FlashcardsCompanion({
    this.id = const Value.absent(),
    this.front = const Value.absent(),
    this.back = const Value.absent(),
    this.sourceLang = const Value.absent(),
    this.targetLang = const Value.absent(),
    this.addedDate = const Value.absent(),
    this.quality = const Value.absent(),
    this.easiness = const Value.absent(),
    this.interval = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.timesReviewed = const Value.absent(),
    this.lastReviewDate = const Value.absent(),
    this.nextReviewDate = const Value.absent(),
  });
  FlashcardsCompanion.insert({
    this.id = const Value.absent(),
    required String front,
    required String back,
    required String sourceLang,
    required String targetLang,
    required DateTime addedDate,
    this.quality = const Value.absent(),
    required double easiness,
    required int interval,
    required int repetitions,
    required int timesReviewed,
    this.lastReviewDate = const Value.absent(),
    this.nextReviewDate = const Value.absent(),
  })  : front = Value(front),
        back = Value(back),
        sourceLang = Value(sourceLang),
        targetLang = Value(targetLang),
        addedDate = Value(addedDate),
        easiness = Value(easiness),
        interval = Value(interval),
        repetitions = Value(repetitions),
        timesReviewed = Value(timesReviewed);
  static Insertable<FlashcardData> custom({
    Expression<int>? id,
    Expression<String>? front,
    Expression<String>? back,
    Expression<String>? sourceLang,
    Expression<String>? targetLang,
    Expression<DateTime>? addedDate,
    Expression<int>? quality,
    Expression<double>? easiness,
    Expression<int>? interval,
    Expression<int>? repetitions,
    Expression<int>? timesReviewed,
    Expression<DateTime>? lastReviewDate,
    Expression<DateTime>? nextReviewDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (front != null) 'front': front,
      if (back != null) 'back': back,
      if (sourceLang != null) 'source_lang': sourceLang,
      if (targetLang != null) 'target_lang': targetLang,
      if (addedDate != null) 'added_date': addedDate,
      if (quality != null) 'quality': quality,
      if (easiness != null) 'easiness': easiness,
      if (interval != null) 'interval': interval,
      if (repetitions != null) 'repetitions': repetitions,
      if (timesReviewed != null) 'times_reviewed': timesReviewed,
      if (lastReviewDate != null) 'last_review_date': lastReviewDate,
      if (nextReviewDate != null) 'next_review_date': nextReviewDate,
    });
  }

  FlashcardsCompanion copyWith(
      {Value<int>? id,
      Value<String>? front,
      Value<String>? back,
      Value<String>? sourceLang,
      Value<String>? targetLang,
      Value<DateTime>? addedDate,
      Value<int?>? quality,
      Value<double>? easiness,
      Value<int>? interval,
      Value<int>? repetitions,
      Value<int>? timesReviewed,
      Value<DateTime?>? lastReviewDate,
      Value<DateTime?>? nextReviewDate}) {
    return FlashcardsCompanion(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      addedDate: addedDate ?? this.addedDate,
      quality: quality ?? this.quality,
      easiness: easiness ?? this.easiness,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      timesReviewed: timesReviewed ?? this.timesReviewed,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (front.present) {
      map['front'] = Variable<String>(front.value);
    }
    if (back.present) {
      map['back'] = Variable<String>(back.value);
    }
    if (sourceLang.present) {
      map['source_lang'] = Variable<String>(sourceLang.value);
    }
    if (targetLang.present) {
      map['target_lang'] = Variable<String>(targetLang.value);
    }
    if (addedDate.present) {
      map['added_date'] = Variable<DateTime>(addedDate.value);
    }
    if (quality.present) {
      map['quality'] = Variable<int>(quality.value);
    }
    if (easiness.present) {
      map['easiness'] = Variable<double>(easiness.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (timesReviewed.present) {
      map['times_reviewed'] = Variable<int>(timesReviewed.value);
    }
    if (lastReviewDate.present) {
      map['last_review_date'] = Variable<DateTime>(lastReviewDate.value);
    }
    if (nextReviewDate.present) {
      map['next_review_date'] = Variable<DateTime>(nextReviewDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardsCompanion(')
          ..write('id: $id, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('sourceLang: $sourceLang, ')
          ..write('targetLang: $targetLang, ')
          ..write('addedDate: $addedDate, ')
          ..write('quality: $quality, ')
          ..write('easiness: $easiness, ')
          ..write('interval: $interval, ')
          ..write('repetitions: $repetitions, ')
          ..write('timesReviewed: $timesReviewed, ')
          ..write('lastReviewDate: $lastReviewDate, ')
          ..write('nextReviewDate: $nextReviewDate')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FlashcardsTable flashcards = $FlashcardsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [flashcards];
}

typedef $$FlashcardsTableCreateCompanionBuilder = FlashcardsCompanion Function({
  Value<int> id,
  required String front,
  required String back,
  required String sourceLang,
  required String targetLang,
  required DateTime addedDate,
  Value<int?> quality,
  required double easiness,
  required int interval,
  required int repetitions,
  required int timesReviewed,
  Value<DateTime?> lastReviewDate,
  Value<DateTime?> nextReviewDate,
});
typedef $$FlashcardsTableUpdateCompanionBuilder = FlashcardsCompanion Function({
  Value<int> id,
  Value<String> front,
  Value<String> back,
  Value<String> sourceLang,
  Value<String> targetLang,
  Value<DateTime> addedDate,
  Value<int?> quality,
  Value<double> easiness,
  Value<int> interval,
  Value<int> repetitions,
  Value<int> timesReviewed,
  Value<DateTime?> lastReviewDate,
  Value<DateTime?> nextReviewDate,
});

class $$FlashcardsTableFilterComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get front => $composableBuilder(
      column: $table.front, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get back => $composableBuilder(
      column: $table.back, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceLang => $composableBuilder(
      column: $table.sourceLang, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetLang => $composableBuilder(
      column: $table.targetLang, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedDate => $composableBuilder(
      column: $table.addedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quality => $composableBuilder(
      column: $table.quality, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get easiness => $composableBuilder(
      column: $table.easiness, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timesReviewed => $composableBuilder(
      column: $table.timesReviewed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastReviewDate => $composableBuilder(
      column: $table.lastReviewDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextReviewDate => $composableBuilder(
      column: $table.nextReviewDate,
      builder: (column) => ColumnFilters(column));
}

class $$FlashcardsTableOrderingComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get front => $composableBuilder(
      column: $table.front, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get back => $composableBuilder(
      column: $table.back, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceLang => $composableBuilder(
      column: $table.sourceLang, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetLang => $composableBuilder(
      column: $table.targetLang, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedDate => $composableBuilder(
      column: $table.addedDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quality => $composableBuilder(
      column: $table.quality, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get easiness => $composableBuilder(
      column: $table.easiness, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timesReviewed => $composableBuilder(
      column: $table.timesReviewed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastReviewDate => $composableBuilder(
      column: $table.lastReviewDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextReviewDate => $composableBuilder(
      column: $table.nextReviewDate,
      builder: (column) => ColumnOrderings(column));
}

class $$FlashcardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get front =>
      $composableBuilder(column: $table.front, builder: (column) => column);

  GeneratedColumn<String> get back =>
      $composableBuilder(column: $table.back, builder: (column) => column);

  GeneratedColumn<String> get sourceLang => $composableBuilder(
      column: $table.sourceLang, builder: (column) => column);

  GeneratedColumn<String> get targetLang => $composableBuilder(
      column: $table.targetLang, builder: (column) => column);

  GeneratedColumn<DateTime> get addedDate =>
      $composableBuilder(column: $table.addedDate, builder: (column) => column);

  GeneratedColumn<int> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<double> get easiness =>
      $composableBuilder(column: $table.easiness, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => column);

  GeneratedColumn<int> get timesReviewed => $composableBuilder(
      column: $table.timesReviewed, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewDate => $composableBuilder(
      column: $table.lastReviewDate, builder: (column) => column);

  GeneratedColumn<DateTime> get nextReviewDate => $composableBuilder(
      column: $table.nextReviewDate, builder: (column) => column);
}

class $$FlashcardsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FlashcardsTable,
    FlashcardData,
    $$FlashcardsTableFilterComposer,
    $$FlashcardsTableOrderingComposer,
    $$FlashcardsTableAnnotationComposer,
    $$FlashcardsTableCreateCompanionBuilder,
    $$FlashcardsTableUpdateCompanionBuilder,
    (
      FlashcardData,
      BaseReferences<_$AppDatabase, $FlashcardsTable, FlashcardData>
    ),
    FlashcardData,
    PrefetchHooks Function()> {
  $$FlashcardsTableTableManager(_$AppDatabase db, $FlashcardsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashcardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashcardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashcardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> front = const Value.absent(),
            Value<String> back = const Value.absent(),
            Value<String> sourceLang = const Value.absent(),
            Value<String> targetLang = const Value.absent(),
            Value<DateTime> addedDate = const Value.absent(),
            Value<int?> quality = const Value.absent(),
            Value<double> easiness = const Value.absent(),
            Value<int> interval = const Value.absent(),
            Value<int> repetitions = const Value.absent(),
            Value<int> timesReviewed = const Value.absent(),
            Value<DateTime?> lastReviewDate = const Value.absent(),
            Value<DateTime?> nextReviewDate = const Value.absent(),
          }) =>
              FlashcardsCompanion(
            id: id,
            front: front,
            back: back,
            sourceLang: sourceLang,
            targetLang: targetLang,
            addedDate: addedDate,
            quality: quality,
            easiness: easiness,
            interval: interval,
            repetitions: repetitions,
            timesReviewed: timesReviewed,
            lastReviewDate: lastReviewDate,
            nextReviewDate: nextReviewDate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String front,
            required String back,
            required String sourceLang,
            required String targetLang,
            required DateTime addedDate,
            Value<int?> quality = const Value.absent(),
            required double easiness,
            required int interval,
            required int repetitions,
            required int timesReviewed,
            Value<DateTime?> lastReviewDate = const Value.absent(),
            Value<DateTime?> nextReviewDate = const Value.absent(),
          }) =>
              FlashcardsCompanion.insert(
            id: id,
            front: front,
            back: back,
            sourceLang: sourceLang,
            targetLang: targetLang,
            addedDate: addedDate,
            quality: quality,
            easiness: easiness,
            interval: interval,
            repetitions: repetitions,
            timesReviewed: timesReviewed,
            lastReviewDate: lastReviewDate,
            nextReviewDate: nextReviewDate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FlashcardsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FlashcardsTable,
    FlashcardData,
    $$FlashcardsTableFilterComposer,
    $$FlashcardsTableOrderingComposer,
    $$FlashcardsTableAnnotationComposer,
    $$FlashcardsTableCreateCompanionBuilder,
    $$FlashcardsTableUpdateCompanionBuilder,
    (
      FlashcardData,
      BaseReferences<_$AppDatabase, $FlashcardsTable, FlashcardData>
    ),
    FlashcardData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FlashcardsTableTableManager get flashcards =>
      $$FlashcardsTableTableManager(_db, _db.flashcards);
}
