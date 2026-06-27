// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ShelvesTable extends Shelves with TableInfo<$ShelvesTable, Shelf> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShelvesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lengthCmMeta = const VerificationMeta(
    'lengthCm',
  );
  @override
  late final GeneratedColumn<double> lengthCm = GeneratedColumn<double>(
    'length_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelCountMeta = const VerificationMeta(
    'levelCount',
  );
  @override
  late final GeneratedColumn<int> levelCount = GeneratedColumn<int>(
    'level_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelHeightCmMeta = const VerificationMeta(
    'levelHeightCm',
  );
  @override
  late final GeneratedColumn<double> levelHeightCm = GeneratedColumn<double>(
    'level_height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    label,
    lengthCm,
    levelCount,
    levelHeightCm,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shelves';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shelf> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('length_cm')) {
      context.handle(
        _lengthCmMeta,
        lengthCm.isAcceptableOrUnknown(data['length_cm']!, _lengthCmMeta),
      );
    } else if (isInserting) {
      context.missing(_lengthCmMeta);
    }
    if (data.containsKey('level_count')) {
      context.handle(
        _levelCountMeta,
        levelCount.isAcceptableOrUnknown(data['level_count']!, _levelCountMeta),
      );
    } else if (isInserting) {
      context.missing(_levelCountMeta);
    }
    if (data.containsKey('level_height_cm')) {
      context.handle(
        _levelHeightCmMeta,
        levelHeightCm.isAcceptableOrUnknown(
          data['level_height_cm']!,
          _levelHeightCmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_levelHeightCmMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shelf map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shelf(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      lengthCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}length_cm'],
      )!,
      levelCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level_count'],
      )!,
      levelHeightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}level_height_cm'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ShelvesTable createAlias(String alias) {
    return $ShelvesTable(attachedDatabase, alias);
  }
}

class Shelf extends DataClass implements Insertable<Shelf> {
  final int id;
  final String name;
  final String label;
  final double lengthCm;
  final int levelCount;
  final double levelHeightCm;
  final DateTime createdAt;
  const Shelf({
    required this.id,
    required this.name,
    required this.label,
    required this.lengthCm,
    required this.levelCount,
    required this.levelHeightCm,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['label'] = Variable<String>(label);
    map['length_cm'] = Variable<double>(lengthCm);
    map['level_count'] = Variable<int>(levelCount);
    map['level_height_cm'] = Variable<double>(levelHeightCm);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ShelvesCompanion toCompanion(bool nullToAbsent) {
    return ShelvesCompanion(
      id: Value(id),
      name: Value(name),
      label: Value(label),
      lengthCm: Value(lengthCm),
      levelCount: Value(levelCount),
      levelHeightCm: Value(levelHeightCm),
      createdAt: Value(createdAt),
    );
  }

  factory Shelf.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shelf(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      label: serializer.fromJson<String>(json['label']),
      lengthCm: serializer.fromJson<double>(json['lengthCm']),
      levelCount: serializer.fromJson<int>(json['levelCount']),
      levelHeightCm: serializer.fromJson<double>(json['levelHeightCm']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'label': serializer.toJson<String>(label),
      'lengthCm': serializer.toJson<double>(lengthCm),
      'levelCount': serializer.toJson<int>(levelCount),
      'levelHeightCm': serializer.toJson<double>(levelHeightCm),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Shelf copyWith({
    int? id,
    String? name,
    String? label,
    double? lengthCm,
    int? levelCount,
    double? levelHeightCm,
    DateTime? createdAt,
  }) => Shelf(
    id: id ?? this.id,
    name: name ?? this.name,
    label: label ?? this.label,
    lengthCm: lengthCm ?? this.lengthCm,
    levelCount: levelCount ?? this.levelCount,
    levelHeightCm: levelHeightCm ?? this.levelHeightCm,
    createdAt: createdAt ?? this.createdAt,
  );
  Shelf copyWithCompanion(ShelvesCompanion data) {
    return Shelf(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      label: data.label.present ? data.label.value : this.label,
      lengthCm: data.lengthCm.present ? data.lengthCm.value : this.lengthCm,
      levelCount: data.levelCount.present
          ? data.levelCount.value
          : this.levelCount,
      levelHeightCm: data.levelHeightCm.present
          ? data.levelHeightCm.value
          : this.levelHeightCm,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shelf(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('label: $label, ')
          ..write('lengthCm: $lengthCm, ')
          ..write('levelCount: $levelCount, ')
          ..write('levelHeightCm: $levelHeightCm, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    label,
    lengthCm,
    levelCount,
    levelHeightCm,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shelf &&
          other.id == this.id &&
          other.name == this.name &&
          other.label == this.label &&
          other.lengthCm == this.lengthCm &&
          other.levelCount == this.levelCount &&
          other.levelHeightCm == this.levelHeightCm &&
          other.createdAt == this.createdAt);
}

class ShelvesCompanion extends UpdateCompanion<Shelf> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> label;
  final Value<double> lengthCm;
  final Value<int> levelCount;
  final Value<double> levelHeightCm;
  final Value<DateTime> createdAt;
  const ShelvesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.label = const Value.absent(),
    this.lengthCm = const Value.absent(),
    this.levelCount = const Value.absent(),
    this.levelHeightCm = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ShelvesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String label,
    required double lengthCm,
    required int levelCount,
    required double levelHeightCm,
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       label = Value(label),
       lengthCm = Value(lengthCm),
       levelCount = Value(levelCount),
       levelHeightCm = Value(levelHeightCm);
  static Insertable<Shelf> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? label,
    Expression<double>? lengthCm,
    Expression<int>? levelCount,
    Expression<double>? levelHeightCm,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (label != null) 'label': label,
      if (lengthCm != null) 'length_cm': lengthCm,
      if (levelCount != null) 'level_count': levelCount,
      if (levelHeightCm != null) 'level_height_cm': levelHeightCm,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ShelvesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? label,
    Value<double>? lengthCm,
    Value<int>? levelCount,
    Value<double>? levelHeightCm,
    Value<DateTime>? createdAt,
  }) {
    return ShelvesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      label: label ?? this.label,
      lengthCm: lengthCm ?? this.lengthCm,
      levelCount: levelCount ?? this.levelCount,
      levelHeightCm: levelHeightCm ?? this.levelHeightCm,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (lengthCm.present) {
      map['length_cm'] = Variable<double>(lengthCm.value);
    }
    if (levelCount.present) {
      map['level_count'] = Variable<int>(levelCount.value);
    }
    if (levelHeightCm.present) {
      map['level_height_cm'] = Variable<double>(levelHeightCm.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShelvesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('label: $label, ')
          ..write('lengthCm: $lengthCm, ')
          ..write('levelCount: $levelCount, ')
          ..write('levelHeightCm: $levelHeightCm, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TerrariumsTable extends Terrariums
    with TableInfo<$TerrariumsTable, Terrarium> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TerrariumsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _shapeMeta = const VerificationMeta('shape');
  @override
  late final GeneratedColumn<String> shape = GeneratedColumn<String>(
    'shape',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lengthCmMeta = const VerificationMeta(
    'lengthCm',
  );
  @override
  late final GeneratedColumn<double> lengthCm = GeneratedColumn<double>(
    'length_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthCmMeta = const VerificationMeta(
    'widthCm',
  );
  @override
  late final GeneratedColumn<double> widthCm = GeneratedColumn<double>(
    'width_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diameterCmMeta = const VerificationMeta(
    'diameterCm',
  );
  @override
  late final GeneratedColumn<double> diameterCm = GeneratedColumn<double>(
    'diameter_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volumeLitresMeta = const VerificationMeta(
    'volumeLitres',
  );
  @override
  late final GeneratedColumn<double> volumeLitres = GeneratedColumn<double>(
    'volume_litres',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shelfIdMeta = const VerificationMeta(
    'shelfId',
  );
  @override
  late final GeneratedColumn<int> shelfId = GeneratedColumn<int>(
    'shelf_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shelves (id)',
    ),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionInLevelMeta = const VerificationMeta(
    'positionInLevel',
  );
  @override
  late final GeneratedColumn<int> positionInLevel = GeneratedColumn<int>(
    'position_in_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionXCmMeta = const VerificationMeta(
    'positionXCm',
  );
  @override
  late final GeneratedColumn<double> positionXCm = GeneratedColumn<double>(
    'position_x_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stackOrderMeta = const VerificationMeta(
    'stackOrder',
  );
  @override
  late final GeneratedColumn<int> stackOrder = GeneratedColumn<int>(
    'stack_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supportIdMeta = const VerificationMeta(
    'supportId',
  );
  @override
  late final GeneratedColumn<int> supportId = GeneratedColumn<int>(
    'support_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supportKindMeta = const VerificationMeta(
    'supportKind',
  );
  @override
  late final GeneratedColumn<String> supportKind = GeneratedColumn<String>(
    'support_kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _individualSequenceMeta =
      const VerificationMeta('individualSequence');
  @override
  late final GeneratedColumn<int> individualSequence = GeneratedColumn<int>(
    'individual_sequence',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('general'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shape,
    lengthCm,
    widthCm,
    diameterCm,
    heightCm,
    volumeLitres,
    shelfId,
    level,
    positionInLevel,
    positionXCm,
    stackOrder,
    supportId,
    supportKind,
    location,
    individualSequence,
    purpose,
    createdAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'terrariums';
  @override
  VerificationContext validateIntegrity(
    Insertable<Terrarium> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('shape')) {
      context.handle(
        _shapeMeta,
        shape.isAcceptableOrUnknown(data['shape']!, _shapeMeta),
      );
    } else if (isInserting) {
      context.missing(_shapeMeta);
    }
    if (data.containsKey('length_cm')) {
      context.handle(
        _lengthCmMeta,
        lengthCm.isAcceptableOrUnknown(data['length_cm']!, _lengthCmMeta),
      );
    }
    if (data.containsKey('width_cm')) {
      context.handle(
        _widthCmMeta,
        widthCm.isAcceptableOrUnknown(data['width_cm']!, _widthCmMeta),
      );
    }
    if (data.containsKey('diameter_cm')) {
      context.handle(
        _diameterCmMeta,
        diameterCm.isAcceptableOrUnknown(data['diameter_cm']!, _diameterCmMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('volume_litres')) {
      context.handle(
        _volumeLitresMeta,
        volumeLitres.isAcceptableOrUnknown(
          data['volume_litres']!,
          _volumeLitresMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_volumeLitresMeta);
    }
    if (data.containsKey('shelf_id')) {
      context.handle(
        _shelfIdMeta,
        shelfId.isAcceptableOrUnknown(data['shelf_id']!, _shelfIdMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('position_in_level')) {
      context.handle(
        _positionInLevelMeta,
        positionInLevel.isAcceptableOrUnknown(
          data['position_in_level']!,
          _positionInLevelMeta,
        ),
      );
    }
    if (data.containsKey('position_x_cm')) {
      context.handle(
        _positionXCmMeta,
        positionXCm.isAcceptableOrUnknown(
          data['position_x_cm']!,
          _positionXCmMeta,
        ),
      );
    }
    if (data.containsKey('stack_order')) {
      context.handle(
        _stackOrderMeta,
        stackOrder.isAcceptableOrUnknown(data['stack_order']!, _stackOrderMeta),
      );
    }
    if (data.containsKey('support_id')) {
      context.handle(
        _supportIdMeta,
        supportId.isAcceptableOrUnknown(data['support_id']!, _supportIdMeta),
      );
    }
    if (data.containsKey('support_kind')) {
      context.handle(
        _supportKindMeta,
        supportKind.isAcceptableOrUnknown(
          data['support_kind']!,
          _supportKindMeta,
        ),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('individual_sequence')) {
      context.handle(
        _individualSequenceMeta,
        individualSequence.isAcceptableOrUnknown(
          data['individual_sequence']!,
          _individualSequenceMeta,
        ),
      );
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Terrarium map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Terrarium(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      shape: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shape'],
      )!,
      lengthCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}length_cm'],
      ),
      widthCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width_cm'],
      ),
      diameterCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}diameter_cm'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
      volumeLitres: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}volume_litres'],
      )!,
      shelfId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shelf_id'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      ),
      positionInLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_in_level'],
      ),
      positionXCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position_x_cm'],
      ),
      stackOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stack_order'],
      ),
      supportId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}support_id'],
      ),
      supportKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}support_kind'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      individualSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}individual_sequence'],
      ),
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TerrariumsTable createAlias(String alias) {
    return $TerrariumsTable(attachedDatabase, alias);
  }
}

class Terrarium extends DataClass implements Insertable<Terrarium> {
  final int id;
  final String shape;
  final double? lengthCm;
  final double? widthCm;
  final double? diameterCm;
  final double heightCm;
  final double volumeLitres;
  final int? shelfId;
  final int? level;
  final int? positionInLevel;
  final double? positionXCm;
  final int? stackOrder;
  final int? supportId;
  final String? supportKind;
  final String? location;
  final int? individualSequence;
  final String purpose;
  final DateTime createdAt;
  final DateTime? deletedAt;
  const Terrarium({
    required this.id,
    required this.shape,
    this.lengthCm,
    this.widthCm,
    this.diameterCm,
    required this.heightCm,
    required this.volumeLitres,
    this.shelfId,
    this.level,
    this.positionInLevel,
    this.positionXCm,
    this.stackOrder,
    this.supportId,
    this.supportKind,
    this.location,
    this.individualSequence,
    required this.purpose,
    required this.createdAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['shape'] = Variable<String>(shape);
    if (!nullToAbsent || lengthCm != null) {
      map['length_cm'] = Variable<double>(lengthCm);
    }
    if (!nullToAbsent || widthCm != null) {
      map['width_cm'] = Variable<double>(widthCm);
    }
    if (!nullToAbsent || diameterCm != null) {
      map['diameter_cm'] = Variable<double>(diameterCm);
    }
    map['height_cm'] = Variable<double>(heightCm);
    map['volume_litres'] = Variable<double>(volumeLitres);
    if (!nullToAbsent || shelfId != null) {
      map['shelf_id'] = Variable<int>(shelfId);
    }
    if (!nullToAbsent || level != null) {
      map['level'] = Variable<int>(level);
    }
    if (!nullToAbsent || positionInLevel != null) {
      map['position_in_level'] = Variable<int>(positionInLevel);
    }
    if (!nullToAbsent || positionXCm != null) {
      map['position_x_cm'] = Variable<double>(positionXCm);
    }
    if (!nullToAbsent || stackOrder != null) {
      map['stack_order'] = Variable<int>(stackOrder);
    }
    if (!nullToAbsent || supportId != null) {
      map['support_id'] = Variable<int>(supportId);
    }
    if (!nullToAbsent || supportKind != null) {
      map['support_kind'] = Variable<String>(supportKind);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || individualSequence != null) {
      map['individual_sequence'] = Variable<int>(individualSequence);
    }
    map['purpose'] = Variable<String>(purpose);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TerrariumsCompanion toCompanion(bool nullToAbsent) {
    return TerrariumsCompanion(
      id: Value(id),
      shape: Value(shape),
      lengthCm: lengthCm == null && nullToAbsent
          ? const Value.absent()
          : Value(lengthCm),
      widthCm: widthCm == null && nullToAbsent
          ? const Value.absent()
          : Value(widthCm),
      diameterCm: diameterCm == null && nullToAbsent
          ? const Value.absent()
          : Value(diameterCm),
      heightCm: Value(heightCm),
      volumeLitres: Value(volumeLitres),
      shelfId: shelfId == null && nullToAbsent
          ? const Value.absent()
          : Value(shelfId),
      level: level == null && nullToAbsent
          ? const Value.absent()
          : Value(level),
      positionInLevel: positionInLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(positionInLevel),
      positionXCm: positionXCm == null && nullToAbsent
          ? const Value.absent()
          : Value(positionXCm),
      stackOrder: stackOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(stackOrder),
      supportId: supportId == null && nullToAbsent
          ? const Value.absent()
          : Value(supportId),
      supportKind: supportKind == null && nullToAbsent
          ? const Value.absent()
          : Value(supportKind),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      individualSequence: individualSequence == null && nullToAbsent
          ? const Value.absent()
          : Value(individualSequence),
      purpose: Value(purpose),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Terrarium.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Terrarium(
      id: serializer.fromJson<int>(json['id']),
      shape: serializer.fromJson<String>(json['shape']),
      lengthCm: serializer.fromJson<double?>(json['lengthCm']),
      widthCm: serializer.fromJson<double?>(json['widthCm']),
      diameterCm: serializer.fromJson<double?>(json['diameterCm']),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      volumeLitres: serializer.fromJson<double>(json['volumeLitres']),
      shelfId: serializer.fromJson<int?>(json['shelfId']),
      level: serializer.fromJson<int?>(json['level']),
      positionInLevel: serializer.fromJson<int?>(json['positionInLevel']),
      positionXCm: serializer.fromJson<double?>(json['positionXCm']),
      stackOrder: serializer.fromJson<int?>(json['stackOrder']),
      supportId: serializer.fromJson<int?>(json['supportId']),
      supportKind: serializer.fromJson<String?>(json['supportKind']),
      location: serializer.fromJson<String?>(json['location']),
      individualSequence: serializer.fromJson<int?>(json['individualSequence']),
      purpose: serializer.fromJson<String>(json['purpose']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'shape': serializer.toJson<String>(shape),
      'lengthCm': serializer.toJson<double?>(lengthCm),
      'widthCm': serializer.toJson<double?>(widthCm),
      'diameterCm': serializer.toJson<double?>(diameterCm),
      'heightCm': serializer.toJson<double>(heightCm),
      'volumeLitres': serializer.toJson<double>(volumeLitres),
      'shelfId': serializer.toJson<int?>(shelfId),
      'level': serializer.toJson<int?>(level),
      'positionInLevel': serializer.toJson<int?>(positionInLevel),
      'positionXCm': serializer.toJson<double?>(positionXCm),
      'stackOrder': serializer.toJson<int?>(stackOrder),
      'supportId': serializer.toJson<int?>(supportId),
      'supportKind': serializer.toJson<String?>(supportKind),
      'location': serializer.toJson<String?>(location),
      'individualSequence': serializer.toJson<int?>(individualSequence),
      'purpose': serializer.toJson<String>(purpose),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Terrarium copyWith({
    int? id,
    String? shape,
    Value<double?> lengthCm = const Value.absent(),
    Value<double?> widthCm = const Value.absent(),
    Value<double?> diameterCm = const Value.absent(),
    double? heightCm,
    double? volumeLitres,
    Value<int?> shelfId = const Value.absent(),
    Value<int?> level = const Value.absent(),
    Value<int?> positionInLevel = const Value.absent(),
    Value<double?> positionXCm = const Value.absent(),
    Value<int?> stackOrder = const Value.absent(),
    Value<int?> supportId = const Value.absent(),
    Value<String?> supportKind = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<int?> individualSequence = const Value.absent(),
    String? purpose,
    DateTime? createdAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Terrarium(
    id: id ?? this.id,
    shape: shape ?? this.shape,
    lengthCm: lengthCm.present ? lengthCm.value : this.lengthCm,
    widthCm: widthCm.present ? widthCm.value : this.widthCm,
    diameterCm: diameterCm.present ? diameterCm.value : this.diameterCm,
    heightCm: heightCm ?? this.heightCm,
    volumeLitres: volumeLitres ?? this.volumeLitres,
    shelfId: shelfId.present ? shelfId.value : this.shelfId,
    level: level.present ? level.value : this.level,
    positionInLevel: positionInLevel.present
        ? positionInLevel.value
        : this.positionInLevel,
    positionXCm: positionXCm.present ? positionXCm.value : this.positionXCm,
    stackOrder: stackOrder.present ? stackOrder.value : this.stackOrder,
    supportId: supportId.present ? supportId.value : this.supportId,
    supportKind: supportKind.present ? supportKind.value : this.supportKind,
    location: location.present ? location.value : this.location,
    individualSequence: individualSequence.present
        ? individualSequence.value
        : this.individualSequence,
    purpose: purpose ?? this.purpose,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Terrarium copyWithCompanion(TerrariumsCompanion data) {
    return Terrarium(
      id: data.id.present ? data.id.value : this.id,
      shape: data.shape.present ? data.shape.value : this.shape,
      lengthCm: data.lengthCm.present ? data.lengthCm.value : this.lengthCm,
      widthCm: data.widthCm.present ? data.widthCm.value : this.widthCm,
      diameterCm: data.diameterCm.present
          ? data.diameterCm.value
          : this.diameterCm,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      volumeLitres: data.volumeLitres.present
          ? data.volumeLitres.value
          : this.volumeLitres,
      shelfId: data.shelfId.present ? data.shelfId.value : this.shelfId,
      level: data.level.present ? data.level.value : this.level,
      positionInLevel: data.positionInLevel.present
          ? data.positionInLevel.value
          : this.positionInLevel,
      positionXCm: data.positionXCm.present
          ? data.positionXCm.value
          : this.positionXCm,
      stackOrder: data.stackOrder.present
          ? data.stackOrder.value
          : this.stackOrder,
      supportId: data.supportId.present ? data.supportId.value : this.supportId,
      supportKind: data.supportKind.present
          ? data.supportKind.value
          : this.supportKind,
      location: data.location.present ? data.location.value : this.location,
      individualSequence: data.individualSequence.present
          ? data.individualSequence.value
          : this.individualSequence,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Terrarium(')
          ..write('id: $id, ')
          ..write('shape: $shape, ')
          ..write('lengthCm: $lengthCm, ')
          ..write('widthCm: $widthCm, ')
          ..write('diameterCm: $diameterCm, ')
          ..write('heightCm: $heightCm, ')
          ..write('volumeLitres: $volumeLitres, ')
          ..write('shelfId: $shelfId, ')
          ..write('level: $level, ')
          ..write('positionInLevel: $positionInLevel, ')
          ..write('positionXCm: $positionXCm, ')
          ..write('stackOrder: $stackOrder, ')
          ..write('supportId: $supportId, ')
          ..write('supportKind: $supportKind, ')
          ..write('location: $location, ')
          ..write('individualSequence: $individualSequence, ')
          ..write('purpose: $purpose, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shape,
    lengthCm,
    widthCm,
    diameterCm,
    heightCm,
    volumeLitres,
    shelfId,
    level,
    positionInLevel,
    positionXCm,
    stackOrder,
    supportId,
    supportKind,
    location,
    individualSequence,
    purpose,
    createdAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Terrarium &&
          other.id == this.id &&
          other.shape == this.shape &&
          other.lengthCm == this.lengthCm &&
          other.widthCm == this.widthCm &&
          other.diameterCm == this.diameterCm &&
          other.heightCm == this.heightCm &&
          other.volumeLitres == this.volumeLitres &&
          other.shelfId == this.shelfId &&
          other.level == this.level &&
          other.positionInLevel == this.positionInLevel &&
          other.positionXCm == this.positionXCm &&
          other.stackOrder == this.stackOrder &&
          other.supportId == this.supportId &&
          other.supportKind == this.supportKind &&
          other.location == this.location &&
          other.individualSequence == this.individualSequence &&
          other.purpose == this.purpose &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class TerrariumsCompanion extends UpdateCompanion<Terrarium> {
  final Value<int> id;
  final Value<String> shape;
  final Value<double?> lengthCm;
  final Value<double?> widthCm;
  final Value<double?> diameterCm;
  final Value<double> heightCm;
  final Value<double> volumeLitres;
  final Value<int?> shelfId;
  final Value<int?> level;
  final Value<int?> positionInLevel;
  final Value<double?> positionXCm;
  final Value<int?> stackOrder;
  final Value<int?> supportId;
  final Value<String?> supportKind;
  final Value<String?> location;
  final Value<int?> individualSequence;
  final Value<String> purpose;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  const TerrariumsCompanion({
    this.id = const Value.absent(),
    this.shape = const Value.absent(),
    this.lengthCm = const Value.absent(),
    this.widthCm = const Value.absent(),
    this.diameterCm = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.volumeLitres = const Value.absent(),
    this.shelfId = const Value.absent(),
    this.level = const Value.absent(),
    this.positionInLevel = const Value.absent(),
    this.positionXCm = const Value.absent(),
    this.stackOrder = const Value.absent(),
    this.supportId = const Value.absent(),
    this.supportKind = const Value.absent(),
    this.location = const Value.absent(),
    this.individualSequence = const Value.absent(),
    this.purpose = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  TerrariumsCompanion.insert({
    this.id = const Value.absent(),
    required String shape,
    this.lengthCm = const Value.absent(),
    this.widthCm = const Value.absent(),
    this.diameterCm = const Value.absent(),
    required double heightCm,
    required double volumeLitres,
    this.shelfId = const Value.absent(),
    this.level = const Value.absent(),
    this.positionInLevel = const Value.absent(),
    this.positionXCm = const Value.absent(),
    this.stackOrder = const Value.absent(),
    this.supportId = const Value.absent(),
    this.supportKind = const Value.absent(),
    this.location = const Value.absent(),
    this.individualSequence = const Value.absent(),
    this.purpose = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : shape = Value(shape),
       heightCm = Value(heightCm),
       volumeLitres = Value(volumeLitres);
  static Insertable<Terrarium> custom({
    Expression<int>? id,
    Expression<String>? shape,
    Expression<double>? lengthCm,
    Expression<double>? widthCm,
    Expression<double>? diameterCm,
    Expression<double>? heightCm,
    Expression<double>? volumeLitres,
    Expression<int>? shelfId,
    Expression<int>? level,
    Expression<int>? positionInLevel,
    Expression<double>? positionXCm,
    Expression<int>? stackOrder,
    Expression<int>? supportId,
    Expression<String>? supportKind,
    Expression<String>? location,
    Expression<int>? individualSequence,
    Expression<String>? purpose,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shape != null) 'shape': shape,
      if (lengthCm != null) 'length_cm': lengthCm,
      if (widthCm != null) 'width_cm': widthCm,
      if (diameterCm != null) 'diameter_cm': diameterCm,
      if (heightCm != null) 'height_cm': heightCm,
      if (volumeLitres != null) 'volume_litres': volumeLitres,
      if (shelfId != null) 'shelf_id': shelfId,
      if (level != null) 'level': level,
      if (positionInLevel != null) 'position_in_level': positionInLevel,
      if (positionXCm != null) 'position_x_cm': positionXCm,
      if (stackOrder != null) 'stack_order': stackOrder,
      if (supportId != null) 'support_id': supportId,
      if (supportKind != null) 'support_kind': supportKind,
      if (location != null) 'location': location,
      if (individualSequence != null) 'individual_sequence': individualSequence,
      if (purpose != null) 'purpose': purpose,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  TerrariumsCompanion copyWith({
    Value<int>? id,
    Value<String>? shape,
    Value<double?>? lengthCm,
    Value<double?>? widthCm,
    Value<double?>? diameterCm,
    Value<double>? heightCm,
    Value<double>? volumeLitres,
    Value<int?>? shelfId,
    Value<int?>? level,
    Value<int?>? positionInLevel,
    Value<double?>? positionXCm,
    Value<int?>? stackOrder,
    Value<int?>? supportId,
    Value<String?>? supportKind,
    Value<String?>? location,
    Value<int?>? individualSequence,
    Value<String>? purpose,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deletedAt,
  }) {
    return TerrariumsCompanion(
      id: id ?? this.id,
      shape: shape ?? this.shape,
      lengthCm: lengthCm ?? this.lengthCm,
      widthCm: widthCm ?? this.widthCm,
      diameterCm: diameterCm ?? this.diameterCm,
      heightCm: heightCm ?? this.heightCm,
      volumeLitres: volumeLitres ?? this.volumeLitres,
      shelfId: shelfId ?? this.shelfId,
      level: level ?? this.level,
      positionInLevel: positionInLevel ?? this.positionInLevel,
      positionXCm: positionXCm ?? this.positionXCm,
      stackOrder: stackOrder ?? this.stackOrder,
      supportId: supportId ?? this.supportId,
      supportKind: supportKind ?? this.supportKind,
      location: location ?? this.location,
      individualSequence: individualSequence ?? this.individualSequence,
      purpose: purpose ?? this.purpose,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (shape.present) {
      map['shape'] = Variable<String>(shape.value);
    }
    if (lengthCm.present) {
      map['length_cm'] = Variable<double>(lengthCm.value);
    }
    if (widthCm.present) {
      map['width_cm'] = Variable<double>(widthCm.value);
    }
    if (diameterCm.present) {
      map['diameter_cm'] = Variable<double>(diameterCm.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (volumeLitres.present) {
      map['volume_litres'] = Variable<double>(volumeLitres.value);
    }
    if (shelfId.present) {
      map['shelf_id'] = Variable<int>(shelfId.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (positionInLevel.present) {
      map['position_in_level'] = Variable<int>(positionInLevel.value);
    }
    if (positionXCm.present) {
      map['position_x_cm'] = Variable<double>(positionXCm.value);
    }
    if (stackOrder.present) {
      map['stack_order'] = Variable<int>(stackOrder.value);
    }
    if (supportId.present) {
      map['support_id'] = Variable<int>(supportId.value);
    }
    if (supportKind.present) {
      map['support_kind'] = Variable<String>(supportKind.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (individualSequence.present) {
      map['individual_sequence'] = Variable<int>(individualSequence.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TerrariumsCompanion(')
          ..write('id: $id, ')
          ..write('shape: $shape, ')
          ..write('lengthCm: $lengthCm, ')
          ..write('widthCm: $widthCm, ')
          ..write('diameterCm: $diameterCm, ')
          ..write('heightCm: $heightCm, ')
          ..write('volumeLitres: $volumeLitres, ')
          ..write('shelfId: $shelfId, ')
          ..write('level: $level, ')
          ..write('positionInLevel: $positionInLevel, ')
          ..write('positionXCm: $positionXCm, ')
          ..write('stackOrder: $stackOrder, ')
          ..write('supportId: $supportId, ')
          ..write('supportKind: $supportKind, ')
          ..write('location: $location, ')
          ..write('individualSequence: $individualSequence, ')
          ..write('purpose: $purpose, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $SpecimensTable extends Specimens
    with TableInfo<$SpecimensTable, Specimen> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpecimensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speciesMeta = const VerificationMeta(
    'species',
  );
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
    'species',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesIconKeyMeta = const VerificationMeta(
    'speciesIconKey',
  );
  @override
  late final GeneratedColumn<String> speciesIconKey = GeneratedColumn<String>(
    'species_icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  static const VerificationMeta _dateAcquiredMeta = const VerificationMeta(
    'dateAcquired',
  );
  @override
  late final GeneratedColumn<DateTime> dateAcquired = GeneratedColumn<DateTime>(
    'date_acquired',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
    'date_of_birth',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightGramsMeta = const VerificationMeta(
    'weightGrams',
  );
  @override
  late final GeneratedColumn<double> weightGrams = GeneratedColumn<double>(
    'weight_grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeCmMeta = const VerificationMeta('sizeCm');
  @override
  late final GeneratedColumn<double> sizeCm = GeneratedColumn<double>(
    'size_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lifeStageMeta = const VerificationMeta(
    'lifeStage',
  );
  @override
  late final GeneratedColumn<String> lifeStage = GeneratedColumn<String>(
    'life_stage',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _beetleFamilyMeta = const VerificationMeta(
    'beetleFamily',
  );
  @override
  late final GeneratedColumn<String> beetleFamily = GeneratedColumn<String>(
    'beetle_family',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _replenishIntervalDaysMeta =
      const VerificationMeta('replenishIntervalDays');
  @override
  late final GeneratedColumn<int> replenishIntervalDays = GeneratedColumn<int>(
    'replenish_interval_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReplenishedAtMeta = const VerificationMeta(
    'lastReplenishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReplenishedAt =
      GeneratedColumn<DateTime>(
        'last_replenished_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _replenishNoteMeta = const VerificationMeta(
    'replenishNote',
  );
  @override
  late final GeneratedColumn<String> replenishNote = GeneratedColumn<String>(
    'replenish_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('alive'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _motherIdMeta = const VerificationMeta(
    'motherId',
  );
  @override
  late final GeneratedColumn<int> motherId = GeneratedColumn<int>(
    'mother_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES specimens (id)',
    ),
  );
  static const VerificationMeta _fatherIdMeta = const VerificationMeta(
    'fatherId',
  );
  @override
  late final GeneratedColumn<int> fatherId = GeneratedColumn<int>(
    'father_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES specimens (id)',
    ),
  );
  static const VerificationMeta _terrariumIdMeta = const VerificationMeta(
    'terrariumId',
  );
  @override
  late final GeneratedColumn<int> terrariumId = GeneratedColumn<int>(
    'terrarium_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES terrariums (id)',
    ),
  );
  static const VerificationMeta _sourceBreedingEventIdMeta =
      const VerificationMeta('sourceBreedingEventId');
  @override
  late final GeneratedColumn<int> sourceBreedingEventId = GeneratedColumn<int>(
    'source_breeding_event_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    species,
    speciesIconKey,
    sex,
    dateAcquired,
    dateOfBirth,
    weightGrams,
    sizeCm,
    lifeStage,
    beetleFamily,
    replenishIntervalDays,
    lastReplenishedAt,
    replenishNote,
    status,
    notes,
    photoPath,
    motherId,
    fatherId,
    terrariumId,
    sourceBreedingEventId,
    createdAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'specimens';
  @override
  VerificationContext validateIntegrity(
    Insertable<Specimen> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('species')) {
      context.handle(
        _speciesMeta,
        species.isAcceptableOrUnknown(data['species']!, _speciesMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('species_icon_key')) {
      context.handle(
        _speciesIconKeyMeta,
        speciesIconKey.isAcceptableOrUnknown(
          data['species_icon_key']!,
          _speciesIconKeyMeta,
        ),
      );
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    }
    if (data.containsKey('date_acquired')) {
      context.handle(
        _dateAcquiredMeta,
        dateAcquired.isAcceptableOrUnknown(
          data['date_acquired']!,
          _dateAcquiredMeta,
        ),
      );
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    }
    if (data.containsKey('weight_grams')) {
      context.handle(
        _weightGramsMeta,
        weightGrams.isAcceptableOrUnknown(
          data['weight_grams']!,
          _weightGramsMeta,
        ),
      );
    }
    if (data.containsKey('size_cm')) {
      context.handle(
        _sizeCmMeta,
        sizeCm.isAcceptableOrUnknown(data['size_cm']!, _sizeCmMeta),
      );
    }
    if (data.containsKey('life_stage')) {
      context.handle(
        _lifeStageMeta,
        lifeStage.isAcceptableOrUnknown(data['life_stage']!, _lifeStageMeta),
      );
    }
    if (data.containsKey('beetle_family')) {
      context.handle(
        _beetleFamilyMeta,
        beetleFamily.isAcceptableOrUnknown(
          data['beetle_family']!,
          _beetleFamilyMeta,
        ),
      );
    }
    if (data.containsKey('replenish_interval_days')) {
      context.handle(
        _replenishIntervalDaysMeta,
        replenishIntervalDays.isAcceptableOrUnknown(
          data['replenish_interval_days']!,
          _replenishIntervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('last_replenished_at')) {
      context.handle(
        _lastReplenishedAtMeta,
        lastReplenishedAt.isAcceptableOrUnknown(
          data['last_replenished_at']!,
          _lastReplenishedAtMeta,
        ),
      );
    }
    if (data.containsKey('replenish_note')) {
      context.handle(
        _replenishNoteMeta,
        replenishNote.isAcceptableOrUnknown(
          data['replenish_note']!,
          _replenishNoteMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('mother_id')) {
      context.handle(
        _motherIdMeta,
        motherId.isAcceptableOrUnknown(data['mother_id']!, _motherIdMeta),
      );
    }
    if (data.containsKey('father_id')) {
      context.handle(
        _fatherIdMeta,
        fatherId.isAcceptableOrUnknown(data['father_id']!, _fatherIdMeta),
      );
    }
    if (data.containsKey('terrarium_id')) {
      context.handle(
        _terrariumIdMeta,
        terrariumId.isAcceptableOrUnknown(
          data['terrarium_id']!,
          _terrariumIdMeta,
        ),
      );
    }
    if (data.containsKey('source_breeding_event_id')) {
      context.handle(
        _sourceBreedingEventIdMeta,
        sourceBreedingEventId.isAcceptableOrUnknown(
          data['source_breeding_event_id']!,
          _sourceBreedingEventIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Specimen map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Specimen(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      species: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species'],
      )!,
      speciesIconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species_icon_key'],
      )!,
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      )!,
      dateAcquired: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_acquired'],
      ),
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_of_birth'],
      ),
      weightGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_grams'],
      ),
      sizeCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}size_cm'],
      ),
      lifeStage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}life_stage'],
      ),
      beetleFamily: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}beetle_family'],
      ),
      replenishIntervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}replenish_interval_days'],
      ),
      lastReplenishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_replenished_at'],
      ),
      replenishNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}replenish_note'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      motherId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mother_id'],
      ),
      fatherId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}father_id'],
      ),
      terrariumId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}terrarium_id'],
      ),
      sourceBreedingEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_breeding_event_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SpecimensTable createAlias(String alias) {
    return $SpecimensTable(attachedDatabase, alias);
  }
}

class Specimen extends DataClass implements Insertable<Specimen> {
  final int id;
  final String? name;
  final String species;
  final String speciesIconKey;
  final String sex;
  final DateTime? dateAcquired;
  final DateTime? dateOfBirth;
  final double? weightGrams;
  final double? sizeCm;
  final String? lifeStage;
  final String? beetleFamily;
  final int? replenishIntervalDays;
  final DateTime? lastReplenishedAt;
  final String? replenishNote;
  final String status;
  final String? notes;
  final String? photoPath;
  final int? motherId;
  final int? fatherId;
  final int? terrariumId;
  final int? sourceBreedingEventId;
  final DateTime createdAt;
  final DateTime? deletedAt;
  const Specimen({
    required this.id,
    this.name,
    required this.species,
    required this.speciesIconKey,
    required this.sex,
    this.dateAcquired,
    this.dateOfBirth,
    this.weightGrams,
    this.sizeCm,
    this.lifeStage,
    this.beetleFamily,
    this.replenishIntervalDays,
    this.lastReplenishedAt,
    this.replenishNote,
    required this.status,
    this.notes,
    this.photoPath,
    this.motherId,
    this.fatherId,
    this.terrariumId,
    this.sourceBreedingEventId,
    required this.createdAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['species'] = Variable<String>(species);
    map['species_icon_key'] = Variable<String>(speciesIconKey);
    map['sex'] = Variable<String>(sex);
    if (!nullToAbsent || dateAcquired != null) {
      map['date_acquired'] = Variable<DateTime>(dateAcquired);
    }
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    if (!nullToAbsent || weightGrams != null) {
      map['weight_grams'] = Variable<double>(weightGrams);
    }
    if (!nullToAbsent || sizeCm != null) {
      map['size_cm'] = Variable<double>(sizeCm);
    }
    if (!nullToAbsent || lifeStage != null) {
      map['life_stage'] = Variable<String>(lifeStage);
    }
    if (!nullToAbsent || beetleFamily != null) {
      map['beetle_family'] = Variable<String>(beetleFamily);
    }
    if (!nullToAbsent || replenishIntervalDays != null) {
      map['replenish_interval_days'] = Variable<int>(replenishIntervalDays);
    }
    if (!nullToAbsent || lastReplenishedAt != null) {
      map['last_replenished_at'] = Variable<DateTime>(lastReplenishedAt);
    }
    if (!nullToAbsent || replenishNote != null) {
      map['replenish_note'] = Variable<String>(replenishNote);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || motherId != null) {
      map['mother_id'] = Variable<int>(motherId);
    }
    if (!nullToAbsent || fatherId != null) {
      map['father_id'] = Variable<int>(fatherId);
    }
    if (!nullToAbsent || terrariumId != null) {
      map['terrarium_id'] = Variable<int>(terrariumId);
    }
    if (!nullToAbsent || sourceBreedingEventId != null) {
      map['source_breeding_event_id'] = Variable<int>(sourceBreedingEventId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  SpecimensCompanion toCompanion(bool nullToAbsent) {
    return SpecimensCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      species: Value(species),
      speciesIconKey: Value(speciesIconKey),
      sex: Value(sex),
      dateAcquired: dateAcquired == null && nullToAbsent
          ? const Value.absent()
          : Value(dateAcquired),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      weightGrams: weightGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(weightGrams),
      sizeCm: sizeCm == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeCm),
      lifeStage: lifeStage == null && nullToAbsent
          ? const Value.absent()
          : Value(lifeStage),
      beetleFamily: beetleFamily == null && nullToAbsent
          ? const Value.absent()
          : Value(beetleFamily),
      replenishIntervalDays: replenishIntervalDays == null && nullToAbsent
          ? const Value.absent()
          : Value(replenishIntervalDays),
      lastReplenishedAt: lastReplenishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReplenishedAt),
      replenishNote: replenishNote == null && nullToAbsent
          ? const Value.absent()
          : Value(replenishNote),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      motherId: motherId == null && nullToAbsent
          ? const Value.absent()
          : Value(motherId),
      fatherId: fatherId == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherId),
      terrariumId: terrariumId == null && nullToAbsent
          ? const Value.absent()
          : Value(terrariumId),
      sourceBreedingEventId: sourceBreedingEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceBreedingEventId),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Specimen.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Specimen(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      species: serializer.fromJson<String>(json['species']),
      speciesIconKey: serializer.fromJson<String>(json['speciesIconKey']),
      sex: serializer.fromJson<String>(json['sex']),
      dateAcquired: serializer.fromJson<DateTime?>(json['dateAcquired']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
      weightGrams: serializer.fromJson<double?>(json['weightGrams']),
      sizeCm: serializer.fromJson<double?>(json['sizeCm']),
      lifeStage: serializer.fromJson<String?>(json['lifeStage']),
      beetleFamily: serializer.fromJson<String?>(json['beetleFamily']),
      replenishIntervalDays: serializer.fromJson<int?>(
        json['replenishIntervalDays'],
      ),
      lastReplenishedAt: serializer.fromJson<DateTime?>(
        json['lastReplenishedAt'],
      ),
      replenishNote: serializer.fromJson<String?>(json['replenishNote']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      motherId: serializer.fromJson<int?>(json['motherId']),
      fatherId: serializer.fromJson<int?>(json['fatherId']),
      terrariumId: serializer.fromJson<int?>(json['terrariumId']),
      sourceBreedingEventId: serializer.fromJson<int?>(
        json['sourceBreedingEventId'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String?>(name),
      'species': serializer.toJson<String>(species),
      'speciesIconKey': serializer.toJson<String>(speciesIconKey),
      'sex': serializer.toJson<String>(sex),
      'dateAcquired': serializer.toJson<DateTime?>(dateAcquired),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
      'weightGrams': serializer.toJson<double?>(weightGrams),
      'sizeCm': serializer.toJson<double?>(sizeCm),
      'lifeStage': serializer.toJson<String?>(lifeStage),
      'beetleFamily': serializer.toJson<String?>(beetleFamily),
      'replenishIntervalDays': serializer.toJson<int?>(replenishIntervalDays),
      'lastReplenishedAt': serializer.toJson<DateTime?>(lastReplenishedAt),
      'replenishNote': serializer.toJson<String?>(replenishNote),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'photoPath': serializer.toJson<String?>(photoPath),
      'motherId': serializer.toJson<int?>(motherId),
      'fatherId': serializer.toJson<int?>(fatherId),
      'terrariumId': serializer.toJson<int?>(terrariumId),
      'sourceBreedingEventId': serializer.toJson<int?>(sourceBreedingEventId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Specimen copyWith({
    int? id,
    Value<String?> name = const Value.absent(),
    String? species,
    String? speciesIconKey,
    String? sex,
    Value<DateTime?> dateAcquired = const Value.absent(),
    Value<DateTime?> dateOfBirth = const Value.absent(),
    Value<double?> weightGrams = const Value.absent(),
    Value<double?> sizeCm = const Value.absent(),
    Value<String?> lifeStage = const Value.absent(),
    Value<String?> beetleFamily = const Value.absent(),
    Value<int?> replenishIntervalDays = const Value.absent(),
    Value<DateTime?> lastReplenishedAt = const Value.absent(),
    Value<String?> replenishNote = const Value.absent(),
    String? status,
    Value<String?> notes = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    Value<int?> motherId = const Value.absent(),
    Value<int?> fatherId = const Value.absent(),
    Value<int?> terrariumId = const Value.absent(),
    Value<int?> sourceBreedingEventId = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Specimen(
    id: id ?? this.id,
    name: name.present ? name.value : this.name,
    species: species ?? this.species,
    speciesIconKey: speciesIconKey ?? this.speciesIconKey,
    sex: sex ?? this.sex,
    dateAcquired: dateAcquired.present ? dateAcquired.value : this.dateAcquired,
    dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
    weightGrams: weightGrams.present ? weightGrams.value : this.weightGrams,
    sizeCm: sizeCm.present ? sizeCm.value : this.sizeCm,
    lifeStage: lifeStage.present ? lifeStage.value : this.lifeStage,
    beetleFamily: beetleFamily.present ? beetleFamily.value : this.beetleFamily,
    replenishIntervalDays: replenishIntervalDays.present
        ? replenishIntervalDays.value
        : this.replenishIntervalDays,
    lastReplenishedAt: lastReplenishedAt.present
        ? lastReplenishedAt.value
        : this.lastReplenishedAt,
    replenishNote: replenishNote.present
        ? replenishNote.value
        : this.replenishNote,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    motherId: motherId.present ? motherId.value : this.motherId,
    fatherId: fatherId.present ? fatherId.value : this.fatherId,
    terrariumId: terrariumId.present ? terrariumId.value : this.terrariumId,
    sourceBreedingEventId: sourceBreedingEventId.present
        ? sourceBreedingEventId.value
        : this.sourceBreedingEventId,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Specimen copyWithCompanion(SpecimensCompanion data) {
    return Specimen(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      species: data.species.present ? data.species.value : this.species,
      speciesIconKey: data.speciesIconKey.present
          ? data.speciesIconKey.value
          : this.speciesIconKey,
      sex: data.sex.present ? data.sex.value : this.sex,
      dateAcquired: data.dateAcquired.present
          ? data.dateAcquired.value
          : this.dateAcquired,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      weightGrams: data.weightGrams.present
          ? data.weightGrams.value
          : this.weightGrams,
      sizeCm: data.sizeCm.present ? data.sizeCm.value : this.sizeCm,
      lifeStage: data.lifeStage.present ? data.lifeStage.value : this.lifeStage,
      beetleFamily: data.beetleFamily.present
          ? data.beetleFamily.value
          : this.beetleFamily,
      replenishIntervalDays: data.replenishIntervalDays.present
          ? data.replenishIntervalDays.value
          : this.replenishIntervalDays,
      lastReplenishedAt: data.lastReplenishedAt.present
          ? data.lastReplenishedAt.value
          : this.lastReplenishedAt,
      replenishNote: data.replenishNote.present
          ? data.replenishNote.value
          : this.replenishNote,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      motherId: data.motherId.present ? data.motherId.value : this.motherId,
      fatherId: data.fatherId.present ? data.fatherId.value : this.fatherId,
      terrariumId: data.terrariumId.present
          ? data.terrariumId.value
          : this.terrariumId,
      sourceBreedingEventId: data.sourceBreedingEventId.present
          ? data.sourceBreedingEventId.value
          : this.sourceBreedingEventId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Specimen(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('speciesIconKey: $speciesIconKey, ')
          ..write('sex: $sex, ')
          ..write('dateAcquired: $dateAcquired, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('weightGrams: $weightGrams, ')
          ..write('sizeCm: $sizeCm, ')
          ..write('lifeStage: $lifeStage, ')
          ..write('beetleFamily: $beetleFamily, ')
          ..write('replenishIntervalDays: $replenishIntervalDays, ')
          ..write('lastReplenishedAt: $lastReplenishedAt, ')
          ..write('replenishNote: $replenishNote, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath, ')
          ..write('motherId: $motherId, ')
          ..write('fatherId: $fatherId, ')
          ..write('terrariumId: $terrariumId, ')
          ..write('sourceBreedingEventId: $sourceBreedingEventId, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    species,
    speciesIconKey,
    sex,
    dateAcquired,
    dateOfBirth,
    weightGrams,
    sizeCm,
    lifeStage,
    beetleFamily,
    replenishIntervalDays,
    lastReplenishedAt,
    replenishNote,
    status,
    notes,
    photoPath,
    motherId,
    fatherId,
    terrariumId,
    sourceBreedingEventId,
    createdAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Specimen &&
          other.id == this.id &&
          other.name == this.name &&
          other.species == this.species &&
          other.speciesIconKey == this.speciesIconKey &&
          other.sex == this.sex &&
          other.dateAcquired == this.dateAcquired &&
          other.dateOfBirth == this.dateOfBirth &&
          other.weightGrams == this.weightGrams &&
          other.sizeCm == this.sizeCm &&
          other.lifeStage == this.lifeStage &&
          other.beetleFamily == this.beetleFamily &&
          other.replenishIntervalDays == this.replenishIntervalDays &&
          other.lastReplenishedAt == this.lastReplenishedAt &&
          other.replenishNote == this.replenishNote &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.photoPath == this.photoPath &&
          other.motherId == this.motherId &&
          other.fatherId == this.fatherId &&
          other.terrariumId == this.terrariumId &&
          other.sourceBreedingEventId == this.sourceBreedingEventId &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class SpecimensCompanion extends UpdateCompanion<Specimen> {
  final Value<int> id;
  final Value<String?> name;
  final Value<String> species;
  final Value<String> speciesIconKey;
  final Value<String> sex;
  final Value<DateTime?> dateAcquired;
  final Value<DateTime?> dateOfBirth;
  final Value<double?> weightGrams;
  final Value<double?> sizeCm;
  final Value<String?> lifeStage;
  final Value<String?> beetleFamily;
  final Value<int?> replenishIntervalDays;
  final Value<DateTime?> lastReplenishedAt;
  final Value<String?> replenishNote;
  final Value<String> status;
  final Value<String?> notes;
  final Value<String?> photoPath;
  final Value<int?> motherId;
  final Value<int?> fatherId;
  final Value<int?> terrariumId;
  final Value<int?> sourceBreedingEventId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  const SpecimensCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.species = const Value.absent(),
    this.speciesIconKey = const Value.absent(),
    this.sex = const Value.absent(),
    this.dateAcquired = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.weightGrams = const Value.absent(),
    this.sizeCm = const Value.absent(),
    this.lifeStage = const Value.absent(),
    this.beetleFamily = const Value.absent(),
    this.replenishIntervalDays = const Value.absent(),
    this.lastReplenishedAt = const Value.absent(),
    this.replenishNote = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.motherId = const Value.absent(),
    this.fatherId = const Value.absent(),
    this.terrariumId = const Value.absent(),
    this.sourceBreedingEventId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  SpecimensCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    required String species,
    this.speciesIconKey = const Value.absent(),
    this.sex = const Value.absent(),
    this.dateAcquired = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.weightGrams = const Value.absent(),
    this.sizeCm = const Value.absent(),
    this.lifeStage = const Value.absent(),
    this.beetleFamily = const Value.absent(),
    this.replenishIntervalDays = const Value.absent(),
    this.lastReplenishedAt = const Value.absent(),
    this.replenishNote = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.motherId = const Value.absent(),
    this.fatherId = const Value.absent(),
    this.terrariumId = const Value.absent(),
    this.sourceBreedingEventId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : species = Value(species);
  static Insertable<Specimen> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? species,
    Expression<String>? speciesIconKey,
    Expression<String>? sex,
    Expression<DateTime>? dateAcquired,
    Expression<DateTime>? dateOfBirth,
    Expression<double>? weightGrams,
    Expression<double>? sizeCm,
    Expression<String>? lifeStage,
    Expression<String>? beetleFamily,
    Expression<int>? replenishIntervalDays,
    Expression<DateTime>? lastReplenishedAt,
    Expression<String>? replenishNote,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? photoPath,
    Expression<int>? motherId,
    Expression<int>? fatherId,
    Expression<int>? terrariumId,
    Expression<int>? sourceBreedingEventId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (species != null) 'species': species,
      if (speciesIconKey != null) 'species_icon_key': speciesIconKey,
      if (sex != null) 'sex': sex,
      if (dateAcquired != null) 'date_acquired': dateAcquired,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (weightGrams != null) 'weight_grams': weightGrams,
      if (sizeCm != null) 'size_cm': sizeCm,
      if (lifeStage != null) 'life_stage': lifeStage,
      if (beetleFamily != null) 'beetle_family': beetleFamily,
      if (replenishIntervalDays != null)
        'replenish_interval_days': replenishIntervalDays,
      if (lastReplenishedAt != null) 'last_replenished_at': lastReplenishedAt,
      if (replenishNote != null) 'replenish_note': replenishNote,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (photoPath != null) 'photo_path': photoPath,
      if (motherId != null) 'mother_id': motherId,
      if (fatherId != null) 'father_id': fatherId,
      if (terrariumId != null) 'terrarium_id': terrariumId,
      if (sourceBreedingEventId != null)
        'source_breeding_event_id': sourceBreedingEventId,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  SpecimensCompanion copyWith({
    Value<int>? id,
    Value<String?>? name,
    Value<String>? species,
    Value<String>? speciesIconKey,
    Value<String>? sex,
    Value<DateTime?>? dateAcquired,
    Value<DateTime?>? dateOfBirth,
    Value<double?>? weightGrams,
    Value<double?>? sizeCm,
    Value<String?>? lifeStage,
    Value<String?>? beetleFamily,
    Value<int?>? replenishIntervalDays,
    Value<DateTime?>? lastReplenishedAt,
    Value<String?>? replenishNote,
    Value<String>? status,
    Value<String?>? notes,
    Value<String?>? photoPath,
    Value<int?>? motherId,
    Value<int?>? fatherId,
    Value<int?>? terrariumId,
    Value<int?>? sourceBreedingEventId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deletedAt,
  }) {
    return SpecimensCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      speciesIconKey: speciesIconKey ?? this.speciesIconKey,
      sex: sex ?? this.sex,
      dateAcquired: dateAcquired ?? this.dateAcquired,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weightGrams: weightGrams ?? this.weightGrams,
      sizeCm: sizeCm ?? this.sizeCm,
      lifeStage: lifeStage ?? this.lifeStage,
      beetleFamily: beetleFamily ?? this.beetleFamily,
      replenishIntervalDays:
          replenishIntervalDays ?? this.replenishIntervalDays,
      lastReplenishedAt: lastReplenishedAt ?? this.lastReplenishedAt,
      replenishNote: replenishNote ?? this.replenishNote,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      motherId: motherId ?? this.motherId,
      fatherId: fatherId ?? this.fatherId,
      terrariumId: terrariumId ?? this.terrariumId,
      sourceBreedingEventId:
          sourceBreedingEventId ?? this.sourceBreedingEventId,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (speciesIconKey.present) {
      map['species_icon_key'] = Variable<String>(speciesIconKey.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (dateAcquired.present) {
      map['date_acquired'] = Variable<DateTime>(dateAcquired.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (weightGrams.present) {
      map['weight_grams'] = Variable<double>(weightGrams.value);
    }
    if (sizeCm.present) {
      map['size_cm'] = Variable<double>(sizeCm.value);
    }
    if (lifeStage.present) {
      map['life_stage'] = Variable<String>(lifeStage.value);
    }
    if (beetleFamily.present) {
      map['beetle_family'] = Variable<String>(beetleFamily.value);
    }
    if (replenishIntervalDays.present) {
      map['replenish_interval_days'] = Variable<int>(
        replenishIntervalDays.value,
      );
    }
    if (lastReplenishedAt.present) {
      map['last_replenished_at'] = Variable<DateTime>(lastReplenishedAt.value);
    }
    if (replenishNote.present) {
      map['replenish_note'] = Variable<String>(replenishNote.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (motherId.present) {
      map['mother_id'] = Variable<int>(motherId.value);
    }
    if (fatherId.present) {
      map['father_id'] = Variable<int>(fatherId.value);
    }
    if (terrariumId.present) {
      map['terrarium_id'] = Variable<int>(terrariumId.value);
    }
    if (sourceBreedingEventId.present) {
      map['source_breeding_event_id'] = Variable<int>(
        sourceBreedingEventId.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpecimensCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('speciesIconKey: $speciesIconKey, ')
          ..write('sex: $sex, ')
          ..write('dateAcquired: $dateAcquired, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('weightGrams: $weightGrams, ')
          ..write('sizeCm: $sizeCm, ')
          ..write('lifeStage: $lifeStage, ')
          ..write('beetleFamily: $beetleFamily, ')
          ..write('replenishIntervalDays: $replenishIntervalDays, ')
          ..write('lastReplenishedAt: $lastReplenishedAt, ')
          ..write('replenishNote: $replenishNote, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath, ')
          ..write('motherId: $motherId, ')
          ..write('fatherId: $fatherId, ')
          ..write('terrariumId: $terrariumId, ')
          ..write('sourceBreedingEventId: $sourceBreedingEventId, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $BreedingEventsTable extends BreedingEvents
    with TableInfo<$BreedingEventsTable, BreedingEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BreedingEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _motherIdMeta = const VerificationMeta(
    'motherId',
  );
  @override
  late final GeneratedColumn<int> motherId = GeneratedColumn<int>(
    'mother_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES specimens (id)',
    ),
  );
  static const VerificationMeta _fatherIdMeta = const VerificationMeta(
    'fatherId',
  );
  @override
  late final GeneratedColumn<int> fatherId = GeneratedColumn<int>(
    'father_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES specimens (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clutchSizeMeta = const VerificationMeta(
    'clutchSize',
  );
  @override
  late final GeneratedColumn<int> clutchSize = GeneratedColumn<int>(
    'clutch_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('mating'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _terrariumIdMeta = const VerificationMeta(
    'terrariumId',
  );
  @override
  late final GeneratedColumn<int> terrariumId = GeneratedColumn<int>(
    'terrarium_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES terrariums (id)',
    ),
  );
  static const VerificationMeta _motherPreviousTerrariumIdMeta =
      const VerificationMeta('motherPreviousTerrariumId');
  @override
  late final GeneratedColumn<int> motherPreviousTerrariumId =
      GeneratedColumn<int>(
        'mother_previous_terrarium_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fatherPreviousTerrariumIdMeta =
      const VerificationMeta('fatherPreviousTerrariumId');
  @override
  late final GeneratedColumn<int> fatherPreviousTerrariumId =
      GeneratedColumn<int>(
        'father_previous_terrarium_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _failedAtMeta = const VerificationMeta(
    'failedAt',
  );
  @override
  late final GeneratedColumn<DateTime> failedAt = GeneratedColumn<DateTime>(
    'failed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    motherId,
    fatherId,
    date,
    clutchSize,
    stage,
    notes,
    terrariumId,
    motherPreviousTerrariumId,
    fatherPreviousTerrariumId,
    failedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'breeding_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<BreedingEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mother_id')) {
      context.handle(
        _motherIdMeta,
        motherId.isAcceptableOrUnknown(data['mother_id']!, _motherIdMeta),
      );
    } else if (isInserting) {
      context.missing(_motherIdMeta);
    }
    if (data.containsKey('father_id')) {
      context.handle(
        _fatherIdMeta,
        fatherId.isAcceptableOrUnknown(data['father_id']!, _fatherIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fatherIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('clutch_size')) {
      context.handle(
        _clutchSizeMeta,
        clutchSize.isAcceptableOrUnknown(data['clutch_size']!, _clutchSizeMeta),
      );
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('terrarium_id')) {
      context.handle(
        _terrariumIdMeta,
        terrariumId.isAcceptableOrUnknown(
          data['terrarium_id']!,
          _terrariumIdMeta,
        ),
      );
    }
    if (data.containsKey('mother_previous_terrarium_id')) {
      context.handle(
        _motherPreviousTerrariumIdMeta,
        motherPreviousTerrariumId.isAcceptableOrUnknown(
          data['mother_previous_terrarium_id']!,
          _motherPreviousTerrariumIdMeta,
        ),
      );
    }
    if (data.containsKey('father_previous_terrarium_id')) {
      context.handle(
        _fatherPreviousTerrariumIdMeta,
        fatherPreviousTerrariumId.isAcceptableOrUnknown(
          data['father_previous_terrarium_id']!,
          _fatherPreviousTerrariumIdMeta,
        ),
      );
    }
    if (data.containsKey('failed_at')) {
      context.handle(
        _failedAtMeta,
        failedAt.isAcceptableOrUnknown(data['failed_at']!, _failedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BreedingEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BreedingEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      motherId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mother_id'],
      )!,
      fatherId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}father_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      clutchSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}clutch_size'],
      ),
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      terrariumId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}terrarium_id'],
      ),
      motherPreviousTerrariumId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mother_previous_terrarium_id'],
      ),
      fatherPreviousTerrariumId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}father_previous_terrarium_id'],
      ),
      failedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}failed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BreedingEventsTable createAlias(String alias) {
    return $BreedingEventsTable(attachedDatabase, alias);
  }
}

class BreedingEvent extends DataClass implements Insertable<BreedingEvent> {
  final int id;
  final int motherId;
  final int fatherId;
  final DateTime date;
  final int? clutchSize;
  final String stage;
  final String? notes;
  final int? terrariumId;
  final int? motherPreviousTerrariumId;
  final int? fatherPreviousTerrariumId;
  final DateTime? failedAt;
  final DateTime createdAt;
  const BreedingEvent({
    required this.id,
    required this.motherId,
    required this.fatherId,
    required this.date,
    this.clutchSize,
    required this.stage,
    this.notes,
    this.terrariumId,
    this.motherPreviousTerrariumId,
    this.fatherPreviousTerrariumId,
    this.failedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['mother_id'] = Variable<int>(motherId);
    map['father_id'] = Variable<int>(fatherId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || clutchSize != null) {
      map['clutch_size'] = Variable<int>(clutchSize);
    }
    map['stage'] = Variable<String>(stage);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || terrariumId != null) {
      map['terrarium_id'] = Variable<int>(terrariumId);
    }
    if (!nullToAbsent || motherPreviousTerrariumId != null) {
      map['mother_previous_terrarium_id'] = Variable<int>(
        motherPreviousTerrariumId,
      );
    }
    if (!nullToAbsent || fatherPreviousTerrariumId != null) {
      map['father_previous_terrarium_id'] = Variable<int>(
        fatherPreviousTerrariumId,
      );
    }
    if (!nullToAbsent || failedAt != null) {
      map['failed_at'] = Variable<DateTime>(failedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BreedingEventsCompanion toCompanion(bool nullToAbsent) {
    return BreedingEventsCompanion(
      id: Value(id),
      motherId: Value(motherId),
      fatherId: Value(fatherId),
      date: Value(date),
      clutchSize: clutchSize == null && nullToAbsent
          ? const Value.absent()
          : Value(clutchSize),
      stage: Value(stage),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      terrariumId: terrariumId == null && nullToAbsent
          ? const Value.absent()
          : Value(terrariumId),
      motherPreviousTerrariumId:
          motherPreviousTerrariumId == null && nullToAbsent
          ? const Value.absent()
          : Value(motherPreviousTerrariumId),
      fatherPreviousTerrariumId:
          fatherPreviousTerrariumId == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherPreviousTerrariumId),
      failedAt: failedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(failedAt),
      createdAt: Value(createdAt),
    );
  }

  factory BreedingEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BreedingEvent(
      id: serializer.fromJson<int>(json['id']),
      motherId: serializer.fromJson<int>(json['motherId']),
      fatherId: serializer.fromJson<int>(json['fatherId']),
      date: serializer.fromJson<DateTime>(json['date']),
      clutchSize: serializer.fromJson<int?>(json['clutchSize']),
      stage: serializer.fromJson<String>(json['stage']),
      notes: serializer.fromJson<String?>(json['notes']),
      terrariumId: serializer.fromJson<int?>(json['terrariumId']),
      motherPreviousTerrariumId: serializer.fromJson<int?>(
        json['motherPreviousTerrariumId'],
      ),
      fatherPreviousTerrariumId: serializer.fromJson<int?>(
        json['fatherPreviousTerrariumId'],
      ),
      failedAt: serializer.fromJson<DateTime?>(json['failedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'motherId': serializer.toJson<int>(motherId),
      'fatherId': serializer.toJson<int>(fatherId),
      'date': serializer.toJson<DateTime>(date),
      'clutchSize': serializer.toJson<int?>(clutchSize),
      'stage': serializer.toJson<String>(stage),
      'notes': serializer.toJson<String?>(notes),
      'terrariumId': serializer.toJson<int?>(terrariumId),
      'motherPreviousTerrariumId': serializer.toJson<int?>(
        motherPreviousTerrariumId,
      ),
      'fatherPreviousTerrariumId': serializer.toJson<int?>(
        fatherPreviousTerrariumId,
      ),
      'failedAt': serializer.toJson<DateTime?>(failedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BreedingEvent copyWith({
    int? id,
    int? motherId,
    int? fatherId,
    DateTime? date,
    Value<int?> clutchSize = const Value.absent(),
    String? stage,
    Value<String?> notes = const Value.absent(),
    Value<int?> terrariumId = const Value.absent(),
    Value<int?> motherPreviousTerrariumId = const Value.absent(),
    Value<int?> fatherPreviousTerrariumId = const Value.absent(),
    Value<DateTime?> failedAt = const Value.absent(),
    DateTime? createdAt,
  }) => BreedingEvent(
    id: id ?? this.id,
    motherId: motherId ?? this.motherId,
    fatherId: fatherId ?? this.fatherId,
    date: date ?? this.date,
    clutchSize: clutchSize.present ? clutchSize.value : this.clutchSize,
    stage: stage ?? this.stage,
    notes: notes.present ? notes.value : this.notes,
    terrariumId: terrariumId.present ? terrariumId.value : this.terrariumId,
    motherPreviousTerrariumId: motherPreviousTerrariumId.present
        ? motherPreviousTerrariumId.value
        : this.motherPreviousTerrariumId,
    fatherPreviousTerrariumId: fatherPreviousTerrariumId.present
        ? fatherPreviousTerrariumId.value
        : this.fatherPreviousTerrariumId,
    failedAt: failedAt.present ? failedAt.value : this.failedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  BreedingEvent copyWithCompanion(BreedingEventsCompanion data) {
    return BreedingEvent(
      id: data.id.present ? data.id.value : this.id,
      motherId: data.motherId.present ? data.motherId.value : this.motherId,
      fatherId: data.fatherId.present ? data.fatherId.value : this.fatherId,
      date: data.date.present ? data.date.value : this.date,
      clutchSize: data.clutchSize.present
          ? data.clutchSize.value
          : this.clutchSize,
      stage: data.stage.present ? data.stage.value : this.stage,
      notes: data.notes.present ? data.notes.value : this.notes,
      terrariumId: data.terrariumId.present
          ? data.terrariumId.value
          : this.terrariumId,
      motherPreviousTerrariumId: data.motherPreviousTerrariumId.present
          ? data.motherPreviousTerrariumId.value
          : this.motherPreviousTerrariumId,
      fatherPreviousTerrariumId: data.fatherPreviousTerrariumId.present
          ? data.fatherPreviousTerrariumId.value
          : this.fatherPreviousTerrariumId,
      failedAt: data.failedAt.present ? data.failedAt.value : this.failedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BreedingEvent(')
          ..write('id: $id, ')
          ..write('motherId: $motherId, ')
          ..write('fatherId: $fatherId, ')
          ..write('date: $date, ')
          ..write('clutchSize: $clutchSize, ')
          ..write('stage: $stage, ')
          ..write('notes: $notes, ')
          ..write('terrariumId: $terrariumId, ')
          ..write('motherPreviousTerrariumId: $motherPreviousTerrariumId, ')
          ..write('fatherPreviousTerrariumId: $fatherPreviousTerrariumId, ')
          ..write('failedAt: $failedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    motherId,
    fatherId,
    date,
    clutchSize,
    stage,
    notes,
    terrariumId,
    motherPreviousTerrariumId,
    fatherPreviousTerrariumId,
    failedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BreedingEvent &&
          other.id == this.id &&
          other.motherId == this.motherId &&
          other.fatherId == this.fatherId &&
          other.date == this.date &&
          other.clutchSize == this.clutchSize &&
          other.stage == this.stage &&
          other.notes == this.notes &&
          other.terrariumId == this.terrariumId &&
          other.motherPreviousTerrariumId == this.motherPreviousTerrariumId &&
          other.fatherPreviousTerrariumId == this.fatherPreviousTerrariumId &&
          other.failedAt == this.failedAt &&
          other.createdAt == this.createdAt);
}

class BreedingEventsCompanion extends UpdateCompanion<BreedingEvent> {
  final Value<int> id;
  final Value<int> motherId;
  final Value<int> fatherId;
  final Value<DateTime> date;
  final Value<int?> clutchSize;
  final Value<String> stage;
  final Value<String?> notes;
  final Value<int?> terrariumId;
  final Value<int?> motherPreviousTerrariumId;
  final Value<int?> fatherPreviousTerrariumId;
  final Value<DateTime?> failedAt;
  final Value<DateTime> createdAt;
  const BreedingEventsCompanion({
    this.id = const Value.absent(),
    this.motherId = const Value.absent(),
    this.fatherId = const Value.absent(),
    this.date = const Value.absent(),
    this.clutchSize = const Value.absent(),
    this.stage = const Value.absent(),
    this.notes = const Value.absent(),
    this.terrariumId = const Value.absent(),
    this.motherPreviousTerrariumId = const Value.absent(),
    this.fatherPreviousTerrariumId = const Value.absent(),
    this.failedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BreedingEventsCompanion.insert({
    this.id = const Value.absent(),
    required int motherId,
    required int fatherId,
    required DateTime date,
    this.clutchSize = const Value.absent(),
    this.stage = const Value.absent(),
    this.notes = const Value.absent(),
    this.terrariumId = const Value.absent(),
    this.motherPreviousTerrariumId = const Value.absent(),
    this.fatherPreviousTerrariumId = const Value.absent(),
    this.failedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : motherId = Value(motherId),
       fatherId = Value(fatherId),
       date = Value(date);
  static Insertable<BreedingEvent> custom({
    Expression<int>? id,
    Expression<int>? motherId,
    Expression<int>? fatherId,
    Expression<DateTime>? date,
    Expression<int>? clutchSize,
    Expression<String>? stage,
    Expression<String>? notes,
    Expression<int>? terrariumId,
    Expression<int>? motherPreviousTerrariumId,
    Expression<int>? fatherPreviousTerrariumId,
    Expression<DateTime>? failedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (motherId != null) 'mother_id': motherId,
      if (fatherId != null) 'father_id': fatherId,
      if (date != null) 'date': date,
      if (clutchSize != null) 'clutch_size': clutchSize,
      if (stage != null) 'stage': stage,
      if (notes != null) 'notes': notes,
      if (terrariumId != null) 'terrarium_id': terrariumId,
      if (motherPreviousTerrariumId != null)
        'mother_previous_terrarium_id': motherPreviousTerrariumId,
      if (fatherPreviousTerrariumId != null)
        'father_previous_terrarium_id': fatherPreviousTerrariumId,
      if (failedAt != null) 'failed_at': failedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BreedingEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? motherId,
    Value<int>? fatherId,
    Value<DateTime>? date,
    Value<int?>? clutchSize,
    Value<String>? stage,
    Value<String?>? notes,
    Value<int?>? terrariumId,
    Value<int?>? motherPreviousTerrariumId,
    Value<int?>? fatherPreviousTerrariumId,
    Value<DateTime?>? failedAt,
    Value<DateTime>? createdAt,
  }) {
    return BreedingEventsCompanion(
      id: id ?? this.id,
      motherId: motherId ?? this.motherId,
      fatherId: fatherId ?? this.fatherId,
      date: date ?? this.date,
      clutchSize: clutchSize ?? this.clutchSize,
      stage: stage ?? this.stage,
      notes: notes ?? this.notes,
      terrariumId: terrariumId ?? this.terrariumId,
      motherPreviousTerrariumId:
          motherPreviousTerrariumId ?? this.motherPreviousTerrariumId,
      fatherPreviousTerrariumId:
          fatherPreviousTerrariumId ?? this.fatherPreviousTerrariumId,
      failedAt: failedAt ?? this.failedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (motherId.present) {
      map['mother_id'] = Variable<int>(motherId.value);
    }
    if (fatherId.present) {
      map['father_id'] = Variable<int>(fatherId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (clutchSize.present) {
      map['clutch_size'] = Variable<int>(clutchSize.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (terrariumId.present) {
      map['terrarium_id'] = Variable<int>(terrariumId.value);
    }
    if (motherPreviousTerrariumId.present) {
      map['mother_previous_terrarium_id'] = Variable<int>(
        motherPreviousTerrariumId.value,
      );
    }
    if (fatherPreviousTerrariumId.present) {
      map['father_previous_terrarium_id'] = Variable<int>(
        fatherPreviousTerrariumId.value,
      );
    }
    if (failedAt.present) {
      map['failed_at'] = Variable<DateTime>(failedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BreedingEventsCompanion(')
          ..write('id: $id, ')
          ..write('motherId: $motherId, ')
          ..write('fatherId: $fatherId, ')
          ..write('date: $date, ')
          ..write('clutchSize: $clutchSize, ')
          ..write('stage: $stage, ')
          ..write('notes: $notes, ')
          ..write('terrariumId: $terrariumId, ')
          ..write('motherPreviousTerrariumId: $motherPreviousTerrariumId, ')
          ..write('fatherPreviousTerrariumId: $fatherPreviousTerrariumId, ')
          ..write('failedAt: $failedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BreedingLogEntriesTable extends BreedingLogEntries
    with TableInfo<$BreedingLogEntriesTable, BreedingLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BreedingLogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _breedingEventIdMeta = const VerificationMeta(
    'breedingEventId',
  );
  @override
  late final GeneratedColumn<int> breedingEventId = GeneratedColumn<int>(
    'breeding_event_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES breeding_events (id)',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stageAtEntryMeta = const VerificationMeta(
    'stageAtEntry',
  );
  @override
  late final GeneratedColumn<String> stageAtEntry = GeneratedColumn<String>(
    'stage_at_entry',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    breedingEventId,
    timestamp,
    note,
    stageAtEntry,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'breeding_log_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<BreedingLogEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('breeding_event_id')) {
      context.handle(
        _breedingEventIdMeta,
        breedingEventId.isAcceptableOrUnknown(
          data['breeding_event_id']!,
          _breedingEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_breedingEventIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('stage_at_entry')) {
      context.handle(
        _stageAtEntryMeta,
        stageAtEntry.isAcceptableOrUnknown(
          data['stage_at_entry']!,
          _stageAtEntryMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BreedingLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BreedingLogEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      breedingEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}breeding_event_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      stageAtEntry: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage_at_entry'],
      ),
    );
  }

  @override
  $BreedingLogEntriesTable createAlias(String alias) {
    return $BreedingLogEntriesTable(attachedDatabase, alias);
  }
}

class BreedingLogEntry extends DataClass
    implements Insertable<BreedingLogEntry> {
  final int id;
  final int breedingEventId;
  final DateTime timestamp;
  final String? note;
  final String? stageAtEntry;
  const BreedingLogEntry({
    required this.id,
    required this.breedingEventId,
    required this.timestamp,
    this.note,
    this.stageAtEntry,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['breeding_event_id'] = Variable<int>(breedingEventId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || stageAtEntry != null) {
      map['stage_at_entry'] = Variable<String>(stageAtEntry);
    }
    return map;
  }

  BreedingLogEntriesCompanion toCompanion(bool nullToAbsent) {
    return BreedingLogEntriesCompanion(
      id: Value(id),
      breedingEventId: Value(breedingEventId),
      timestamp: Value(timestamp),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      stageAtEntry: stageAtEntry == null && nullToAbsent
          ? const Value.absent()
          : Value(stageAtEntry),
    );
  }

  factory BreedingLogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BreedingLogEntry(
      id: serializer.fromJson<int>(json['id']),
      breedingEventId: serializer.fromJson<int>(json['breedingEventId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      note: serializer.fromJson<String?>(json['note']),
      stageAtEntry: serializer.fromJson<String?>(json['stageAtEntry']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'breedingEventId': serializer.toJson<int>(breedingEventId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'note': serializer.toJson<String?>(note),
      'stageAtEntry': serializer.toJson<String?>(stageAtEntry),
    };
  }

  BreedingLogEntry copyWith({
    int? id,
    int? breedingEventId,
    DateTime? timestamp,
    Value<String?> note = const Value.absent(),
    Value<String?> stageAtEntry = const Value.absent(),
  }) => BreedingLogEntry(
    id: id ?? this.id,
    breedingEventId: breedingEventId ?? this.breedingEventId,
    timestamp: timestamp ?? this.timestamp,
    note: note.present ? note.value : this.note,
    stageAtEntry: stageAtEntry.present ? stageAtEntry.value : this.stageAtEntry,
  );
  BreedingLogEntry copyWithCompanion(BreedingLogEntriesCompanion data) {
    return BreedingLogEntry(
      id: data.id.present ? data.id.value : this.id,
      breedingEventId: data.breedingEventId.present
          ? data.breedingEventId.value
          : this.breedingEventId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      note: data.note.present ? data.note.value : this.note,
      stageAtEntry: data.stageAtEntry.present
          ? data.stageAtEntry.value
          : this.stageAtEntry,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BreedingLogEntry(')
          ..write('id: $id, ')
          ..write('breedingEventId: $breedingEventId, ')
          ..write('timestamp: $timestamp, ')
          ..write('note: $note, ')
          ..write('stageAtEntry: $stageAtEntry')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, breedingEventId, timestamp, note, stageAtEntry);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BreedingLogEntry &&
          other.id == this.id &&
          other.breedingEventId == this.breedingEventId &&
          other.timestamp == this.timestamp &&
          other.note == this.note &&
          other.stageAtEntry == this.stageAtEntry);
}

class BreedingLogEntriesCompanion extends UpdateCompanion<BreedingLogEntry> {
  final Value<int> id;
  final Value<int> breedingEventId;
  final Value<DateTime> timestamp;
  final Value<String?> note;
  final Value<String?> stageAtEntry;
  const BreedingLogEntriesCompanion({
    this.id = const Value.absent(),
    this.breedingEventId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.note = const Value.absent(),
    this.stageAtEntry = const Value.absent(),
  });
  BreedingLogEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int breedingEventId,
    this.timestamp = const Value.absent(),
    this.note = const Value.absent(),
    this.stageAtEntry = const Value.absent(),
  }) : breedingEventId = Value(breedingEventId);
  static Insertable<BreedingLogEntry> custom({
    Expression<int>? id,
    Expression<int>? breedingEventId,
    Expression<DateTime>? timestamp,
    Expression<String>? note,
    Expression<String>? stageAtEntry,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (breedingEventId != null) 'breeding_event_id': breedingEventId,
      if (timestamp != null) 'timestamp': timestamp,
      if (note != null) 'note': note,
      if (stageAtEntry != null) 'stage_at_entry': stageAtEntry,
    });
  }

  BreedingLogEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? breedingEventId,
    Value<DateTime>? timestamp,
    Value<String?>? note,
    Value<String?>? stageAtEntry,
  }) {
    return BreedingLogEntriesCompanion(
      id: id ?? this.id,
      breedingEventId: breedingEventId ?? this.breedingEventId,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      stageAtEntry: stageAtEntry ?? this.stageAtEntry,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (breedingEventId.present) {
      map['breeding_event_id'] = Variable<int>(breedingEventId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (stageAtEntry.present) {
      map['stage_at_entry'] = Variable<String>(stageAtEntry.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BreedingLogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('breedingEventId: $breedingEventId, ')
          ..write('timestamp: $timestamp, ')
          ..write('note: $note, ')
          ..write('stageAtEntry: $stageAtEntry')
          ..write(')'))
        .toString();
  }
}

class $ToolsTable extends Tools with TableInfo<$ToolsTable, Tool> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ToolsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lengthCmMeta = const VerificationMeta(
    'lengthCm',
  );
  @override
  late final GeneratedColumn<double> lengthCm = GeneratedColumn<double>(
    'length_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorArgbMeta = const VerificationMeta(
    'colorArgb',
  );
  @override
  late final GeneratedColumn<int> colorArgb = GeneratedColumn<int>(
    'color_argb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shelfIdMeta = const VerificationMeta(
    'shelfId',
  );
  @override
  late final GeneratedColumn<int> shelfId = GeneratedColumn<int>(
    'shelf_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shelves (id)',
    ),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionXCmMeta = const VerificationMeta(
    'positionXCm',
  );
  @override
  late final GeneratedColumn<double> positionXCm = GeneratedColumn<double>(
    'position_x_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stackOrderMeta = const VerificationMeta(
    'stackOrder',
  );
  @override
  late final GeneratedColumn<int> stackOrder = GeneratedColumn<int>(
    'stack_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supportIdMeta = const VerificationMeta(
    'supportId',
  );
  @override
  late final GeneratedColumn<int> supportId = GeneratedColumn<int>(
    'support_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supportKindMeta = const VerificationMeta(
    'supportKind',
  );
  @override
  late final GeneratedColumn<String> supportKind = GeneratedColumn<String>(
    'support_kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    lengthCm,
    heightCm,
    colorArgb,
    shelfId,
    level,
    positionXCm,
    stackOrder,
    supportId,
    supportKind,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tools';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tool> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('length_cm')) {
      context.handle(
        _lengthCmMeta,
        lengthCm.isAcceptableOrUnknown(data['length_cm']!, _lengthCmMeta),
      );
    } else if (isInserting) {
      context.missing(_lengthCmMeta);
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('color_argb')) {
      context.handle(
        _colorArgbMeta,
        colorArgb.isAcceptableOrUnknown(data['color_argb']!, _colorArgbMeta),
      );
    } else if (isInserting) {
      context.missing(_colorArgbMeta);
    }
    if (data.containsKey('shelf_id')) {
      context.handle(
        _shelfIdMeta,
        shelfId.isAcceptableOrUnknown(data['shelf_id']!, _shelfIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shelfIdMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('position_x_cm')) {
      context.handle(
        _positionXCmMeta,
        positionXCm.isAcceptableOrUnknown(
          data['position_x_cm']!,
          _positionXCmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_positionXCmMeta);
    }
    if (data.containsKey('stack_order')) {
      context.handle(
        _stackOrderMeta,
        stackOrder.isAcceptableOrUnknown(data['stack_order']!, _stackOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_stackOrderMeta);
    }
    if (data.containsKey('support_id')) {
      context.handle(
        _supportIdMeta,
        supportId.isAcceptableOrUnknown(data['support_id']!, _supportIdMeta),
      );
    }
    if (data.containsKey('support_kind')) {
      context.handle(
        _supportKindMeta,
        supportKind.isAcceptableOrUnknown(
          data['support_kind']!,
          _supportKindMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tool map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tool(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      lengthCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}length_cm'],
      )!,
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
      colorArgb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_argb'],
      )!,
      shelfId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shelf_id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      positionXCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position_x_cm'],
      )!,
      stackOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stack_order'],
      )!,
      supportId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}support_id'],
      ),
      supportKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}support_kind'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ToolsTable createAlias(String alias) {
    return $ToolsTable(attachedDatabase, alias);
  }
}

class Tool extends DataClass implements Insertable<Tool> {
  final int id;
  final String name;
  final double lengthCm;
  final double heightCm;
  final int colorArgb;
  final int shelfId;
  final int level;
  final double positionXCm;
  final int stackOrder;
  final int? supportId;
  final String? supportKind;
  final DateTime createdAt;
  const Tool({
    required this.id,
    required this.name,
    required this.lengthCm,
    required this.heightCm,
    required this.colorArgb,
    required this.shelfId,
    required this.level,
    required this.positionXCm,
    required this.stackOrder,
    this.supportId,
    this.supportKind,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['length_cm'] = Variable<double>(lengthCm);
    map['height_cm'] = Variable<double>(heightCm);
    map['color_argb'] = Variable<int>(colorArgb);
    map['shelf_id'] = Variable<int>(shelfId);
    map['level'] = Variable<int>(level);
    map['position_x_cm'] = Variable<double>(positionXCm);
    map['stack_order'] = Variable<int>(stackOrder);
    if (!nullToAbsent || supportId != null) {
      map['support_id'] = Variable<int>(supportId);
    }
    if (!nullToAbsent || supportKind != null) {
      map['support_kind'] = Variable<String>(supportKind);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ToolsCompanion toCompanion(bool nullToAbsent) {
    return ToolsCompanion(
      id: Value(id),
      name: Value(name),
      lengthCm: Value(lengthCm),
      heightCm: Value(heightCm),
      colorArgb: Value(colorArgb),
      shelfId: Value(shelfId),
      level: Value(level),
      positionXCm: Value(positionXCm),
      stackOrder: Value(stackOrder),
      supportId: supportId == null && nullToAbsent
          ? const Value.absent()
          : Value(supportId),
      supportKind: supportKind == null && nullToAbsent
          ? const Value.absent()
          : Value(supportKind),
      createdAt: Value(createdAt),
    );
  }

  factory Tool.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tool(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      lengthCm: serializer.fromJson<double>(json['lengthCm']),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      colorArgb: serializer.fromJson<int>(json['colorArgb']),
      shelfId: serializer.fromJson<int>(json['shelfId']),
      level: serializer.fromJson<int>(json['level']),
      positionXCm: serializer.fromJson<double>(json['positionXCm']),
      stackOrder: serializer.fromJson<int>(json['stackOrder']),
      supportId: serializer.fromJson<int?>(json['supportId']),
      supportKind: serializer.fromJson<String?>(json['supportKind']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'lengthCm': serializer.toJson<double>(lengthCm),
      'heightCm': serializer.toJson<double>(heightCm),
      'colorArgb': serializer.toJson<int>(colorArgb),
      'shelfId': serializer.toJson<int>(shelfId),
      'level': serializer.toJson<int>(level),
      'positionXCm': serializer.toJson<double>(positionXCm),
      'stackOrder': serializer.toJson<int>(stackOrder),
      'supportId': serializer.toJson<int?>(supportId),
      'supportKind': serializer.toJson<String?>(supportKind),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Tool copyWith({
    int? id,
    String? name,
    double? lengthCm,
    double? heightCm,
    int? colorArgb,
    int? shelfId,
    int? level,
    double? positionXCm,
    int? stackOrder,
    Value<int?> supportId = const Value.absent(),
    Value<String?> supportKind = const Value.absent(),
    DateTime? createdAt,
  }) => Tool(
    id: id ?? this.id,
    name: name ?? this.name,
    lengthCm: lengthCm ?? this.lengthCm,
    heightCm: heightCm ?? this.heightCm,
    colorArgb: colorArgb ?? this.colorArgb,
    shelfId: shelfId ?? this.shelfId,
    level: level ?? this.level,
    positionXCm: positionXCm ?? this.positionXCm,
    stackOrder: stackOrder ?? this.stackOrder,
    supportId: supportId.present ? supportId.value : this.supportId,
    supportKind: supportKind.present ? supportKind.value : this.supportKind,
    createdAt: createdAt ?? this.createdAt,
  );
  Tool copyWithCompanion(ToolsCompanion data) {
    return Tool(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      lengthCm: data.lengthCm.present ? data.lengthCm.value : this.lengthCm,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      colorArgb: data.colorArgb.present ? data.colorArgb.value : this.colorArgb,
      shelfId: data.shelfId.present ? data.shelfId.value : this.shelfId,
      level: data.level.present ? data.level.value : this.level,
      positionXCm: data.positionXCm.present
          ? data.positionXCm.value
          : this.positionXCm,
      stackOrder: data.stackOrder.present
          ? data.stackOrder.value
          : this.stackOrder,
      supportId: data.supportId.present ? data.supportId.value : this.supportId,
      supportKind: data.supportKind.present
          ? data.supportKind.value
          : this.supportKind,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tool(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lengthCm: $lengthCm, ')
          ..write('heightCm: $heightCm, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('shelfId: $shelfId, ')
          ..write('level: $level, ')
          ..write('positionXCm: $positionXCm, ')
          ..write('stackOrder: $stackOrder, ')
          ..write('supportId: $supportId, ')
          ..write('supportKind: $supportKind, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    lengthCm,
    heightCm,
    colorArgb,
    shelfId,
    level,
    positionXCm,
    stackOrder,
    supportId,
    supportKind,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tool &&
          other.id == this.id &&
          other.name == this.name &&
          other.lengthCm == this.lengthCm &&
          other.heightCm == this.heightCm &&
          other.colorArgb == this.colorArgb &&
          other.shelfId == this.shelfId &&
          other.level == this.level &&
          other.positionXCm == this.positionXCm &&
          other.stackOrder == this.stackOrder &&
          other.supportId == this.supportId &&
          other.supportKind == this.supportKind &&
          other.createdAt == this.createdAt);
}

class ToolsCompanion extends UpdateCompanion<Tool> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> lengthCm;
  final Value<double> heightCm;
  final Value<int> colorArgb;
  final Value<int> shelfId;
  final Value<int> level;
  final Value<double> positionXCm;
  final Value<int> stackOrder;
  final Value<int?> supportId;
  final Value<String?> supportKind;
  final Value<DateTime> createdAt;
  const ToolsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.lengthCm = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.colorArgb = const Value.absent(),
    this.shelfId = const Value.absent(),
    this.level = const Value.absent(),
    this.positionXCm = const Value.absent(),
    this.stackOrder = const Value.absent(),
    this.supportId = const Value.absent(),
    this.supportKind = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ToolsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double lengthCm,
    required double heightCm,
    required int colorArgb,
    required int shelfId,
    required int level,
    required double positionXCm,
    required int stackOrder,
    this.supportId = const Value.absent(),
    this.supportKind = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       lengthCm = Value(lengthCm),
       heightCm = Value(heightCm),
       colorArgb = Value(colorArgb),
       shelfId = Value(shelfId),
       level = Value(level),
       positionXCm = Value(positionXCm),
       stackOrder = Value(stackOrder);
  static Insertable<Tool> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? lengthCm,
    Expression<double>? heightCm,
    Expression<int>? colorArgb,
    Expression<int>? shelfId,
    Expression<int>? level,
    Expression<double>? positionXCm,
    Expression<int>? stackOrder,
    Expression<int>? supportId,
    Expression<String>? supportKind,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (lengthCm != null) 'length_cm': lengthCm,
      if (heightCm != null) 'height_cm': heightCm,
      if (colorArgb != null) 'color_argb': colorArgb,
      if (shelfId != null) 'shelf_id': shelfId,
      if (level != null) 'level': level,
      if (positionXCm != null) 'position_x_cm': positionXCm,
      if (stackOrder != null) 'stack_order': stackOrder,
      if (supportId != null) 'support_id': supportId,
      if (supportKind != null) 'support_kind': supportKind,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ToolsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? lengthCm,
    Value<double>? heightCm,
    Value<int>? colorArgb,
    Value<int>? shelfId,
    Value<int>? level,
    Value<double>? positionXCm,
    Value<int>? stackOrder,
    Value<int?>? supportId,
    Value<String?>? supportKind,
    Value<DateTime>? createdAt,
  }) {
    return ToolsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      lengthCm: lengthCm ?? this.lengthCm,
      heightCm: heightCm ?? this.heightCm,
      colorArgb: colorArgb ?? this.colorArgb,
      shelfId: shelfId ?? this.shelfId,
      level: level ?? this.level,
      positionXCm: positionXCm ?? this.positionXCm,
      stackOrder: stackOrder ?? this.stackOrder,
      supportId: supportId ?? this.supportId,
      supportKind: supportKind ?? this.supportKind,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lengthCm.present) {
      map['length_cm'] = Variable<double>(lengthCm.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (colorArgb.present) {
      map['color_argb'] = Variable<int>(colorArgb.value);
    }
    if (shelfId.present) {
      map['shelf_id'] = Variable<int>(shelfId.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (positionXCm.present) {
      map['position_x_cm'] = Variable<double>(positionXCm.value);
    }
    if (stackOrder.present) {
      map['stack_order'] = Variable<int>(stackOrder.value);
    }
    if (supportId.present) {
      map['support_id'] = Variable<int>(supportId.value);
    }
    if (supportKind.present) {
      map['support_kind'] = Variable<String>(supportKind.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ToolsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lengthCm: $lengthCm, ')
          ..write('heightCm: $heightCm, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('shelfId: $shelfId, ')
          ..write('level: $level, ')
          ..write('positionXCm: $positionXCm, ')
          ..write('stackOrder: $stackOrder, ')
          ..write('supportId: $supportId, ')
          ..write('supportKind: $supportKind, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SpecimenLogEntriesTable extends SpecimenLogEntries
    with TableInfo<$SpecimenLogEntriesTable, SpecimenLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpecimenLogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _specimenIdMeta = const VerificationMeta(
    'specimenId',
  );
  @override
  late final GeneratedColumn<int> specimenId = GeneratedColumn<int>(
    'specimen_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES specimens (id)',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, specimenId, timestamp, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'specimen_log_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpecimenLogEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('specimen_id')) {
      context.handle(
        _specimenIdMeta,
        specimenId.isAcceptableOrUnknown(data['specimen_id']!, _specimenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_specimenIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpecimenLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpecimenLogEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      specimenId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}specimen_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $SpecimenLogEntriesTable createAlias(String alias) {
    return $SpecimenLogEntriesTable(attachedDatabase, alias);
  }
}

class SpecimenLogEntry extends DataClass
    implements Insertable<SpecimenLogEntry> {
  final int id;
  final int specimenId;
  final DateTime timestamp;
  final String note;
  const SpecimenLogEntry({
    required this.id,
    required this.specimenId,
    required this.timestamp,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['specimen_id'] = Variable<int>(specimenId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['note'] = Variable<String>(note);
    return map;
  }

  SpecimenLogEntriesCompanion toCompanion(bool nullToAbsent) {
    return SpecimenLogEntriesCompanion(
      id: Value(id),
      specimenId: Value(specimenId),
      timestamp: Value(timestamp),
      note: Value(note),
    );
  }

  factory SpecimenLogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpecimenLogEntry(
      id: serializer.fromJson<int>(json['id']),
      specimenId: serializer.fromJson<int>(json['specimenId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'specimenId': serializer.toJson<int>(specimenId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'note': serializer.toJson<String>(note),
    };
  }

  SpecimenLogEntry copyWith({
    int? id,
    int? specimenId,
    DateTime? timestamp,
    String? note,
  }) => SpecimenLogEntry(
    id: id ?? this.id,
    specimenId: specimenId ?? this.specimenId,
    timestamp: timestamp ?? this.timestamp,
    note: note ?? this.note,
  );
  SpecimenLogEntry copyWithCompanion(SpecimenLogEntriesCompanion data) {
    return SpecimenLogEntry(
      id: data.id.present ? data.id.value : this.id,
      specimenId: data.specimenId.present
          ? data.specimenId.value
          : this.specimenId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpecimenLogEntry(')
          ..write('id: $id, ')
          ..write('specimenId: $specimenId, ')
          ..write('timestamp: $timestamp, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, specimenId, timestamp, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpecimenLogEntry &&
          other.id == this.id &&
          other.specimenId == this.specimenId &&
          other.timestamp == this.timestamp &&
          other.note == this.note);
}

class SpecimenLogEntriesCompanion extends UpdateCompanion<SpecimenLogEntry> {
  final Value<int> id;
  final Value<int> specimenId;
  final Value<DateTime> timestamp;
  final Value<String> note;
  const SpecimenLogEntriesCompanion({
    this.id = const Value.absent(),
    this.specimenId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.note = const Value.absent(),
  });
  SpecimenLogEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int specimenId,
    this.timestamp = const Value.absent(),
    required String note,
  }) : specimenId = Value(specimenId),
       note = Value(note);
  static Insertable<SpecimenLogEntry> custom({
    Expression<int>? id,
    Expression<int>? specimenId,
    Expression<DateTime>? timestamp,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (specimenId != null) 'specimen_id': specimenId,
      if (timestamp != null) 'timestamp': timestamp,
      if (note != null) 'note': note,
    });
  }

  SpecimenLogEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? specimenId,
    Value<DateTime>? timestamp,
    Value<String>? note,
  }) {
    return SpecimenLogEntriesCompanion(
      id: id ?? this.id,
      specimenId: specimenId ?? this.specimenId,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (specimenId.present) {
      map['specimen_id'] = Variable<int>(specimenId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpecimenLogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('specimenId: $specimenId, ')
          ..write('timestamp: $timestamp, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $ActivityLogEntriesTable extends ActivityLogEntries
    with TableInfo<$ActivityLogEntriesTable, ActivityLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityLogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<int> entityId = GeneratedColumn<int>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relatedIdsMeta = const VerificationMeta(
    'relatedIds',
  );
  @override
  late final GeneratedColumn<String> relatedIds = GeneratedColumn<String>(
    'related_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    timestamp,
    title,
    entityId,
    relatedIds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_log_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityLogEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('related_ids')) {
      context.handle(
        _relatedIdsMeta,
        relatedIds.isAcceptableOrUnknown(data['related_ids']!, _relatedIdsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityLogEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_id'],
      ),
      relatedIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_ids'],
      ),
    );
  }

  @override
  $ActivityLogEntriesTable createAlias(String alias) {
    return $ActivityLogEntriesTable(attachedDatabase, alias);
  }
}

class ActivityLogEntry extends DataClass
    implements Insertable<ActivityLogEntry> {
  final int id;
  final String type;
  final DateTime timestamp;
  final String title;
  final int? entityId;
  final String? relatedIds;
  const ActivityLogEntry({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.title,
    this.entityId,
    this.relatedIds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<int>(entityId);
    }
    if (!nullToAbsent || relatedIds != null) {
      map['related_ids'] = Variable<String>(relatedIds);
    }
    return map;
  }

  ActivityLogEntriesCompanion toCompanion(bool nullToAbsent) {
    return ActivityLogEntriesCompanion(
      id: Value(id),
      type: Value(type),
      timestamp: Value(timestamp),
      title: Value(title),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      relatedIds: relatedIds == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedIds),
    );
  }

  factory ActivityLogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityLogEntry(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      title: serializer.fromJson<String>(json['title']),
      entityId: serializer.fromJson<int?>(json['entityId']),
      relatedIds: serializer.fromJson<String?>(json['relatedIds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'title': serializer.toJson<String>(title),
      'entityId': serializer.toJson<int?>(entityId),
      'relatedIds': serializer.toJson<String?>(relatedIds),
    };
  }

  ActivityLogEntry copyWith({
    int? id,
    String? type,
    DateTime? timestamp,
    String? title,
    Value<int?> entityId = const Value.absent(),
    Value<String?> relatedIds = const Value.absent(),
  }) => ActivityLogEntry(
    id: id ?? this.id,
    type: type ?? this.type,
    timestamp: timestamp ?? this.timestamp,
    title: title ?? this.title,
    entityId: entityId.present ? entityId.value : this.entityId,
    relatedIds: relatedIds.present ? relatedIds.value : this.relatedIds,
  );
  ActivityLogEntry copyWithCompanion(ActivityLogEntriesCompanion data) {
    return ActivityLogEntry(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      title: data.title.present ? data.title.value : this.title,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      relatedIds: data.relatedIds.present
          ? data.relatedIds.value
          : this.relatedIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogEntry(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('timestamp: $timestamp, ')
          ..write('title: $title, ')
          ..write('entityId: $entityId, ')
          ..write('relatedIds: $relatedIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, timestamp, title, entityId, relatedIds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityLogEntry &&
          other.id == this.id &&
          other.type == this.type &&
          other.timestamp == this.timestamp &&
          other.title == this.title &&
          other.entityId == this.entityId &&
          other.relatedIds == this.relatedIds);
}

class ActivityLogEntriesCompanion extends UpdateCompanion<ActivityLogEntry> {
  final Value<int> id;
  final Value<String> type;
  final Value<DateTime> timestamp;
  final Value<String> title;
  final Value<int?> entityId;
  final Value<String?> relatedIds;
  const ActivityLogEntriesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.title = const Value.absent(),
    this.entityId = const Value.absent(),
    this.relatedIds = const Value.absent(),
  });
  ActivityLogEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    this.timestamp = const Value.absent(),
    required String title,
    this.entityId = const Value.absent(),
    this.relatedIds = const Value.absent(),
  }) : type = Value(type),
       title = Value(title);
  static Insertable<ActivityLogEntry> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<DateTime>? timestamp,
    Expression<String>? title,
    Expression<int>? entityId,
    Expression<String>? relatedIds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (timestamp != null) 'timestamp': timestamp,
      if (title != null) 'title': title,
      if (entityId != null) 'entity_id': entityId,
      if (relatedIds != null) 'related_ids': relatedIds,
    });
  }

  ActivityLogEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<DateTime>? timestamp,
    Value<String>? title,
    Value<int?>? entityId,
    Value<String?>? relatedIds,
  }) {
    return ActivityLogEntriesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      entityId: entityId ?? this.entityId,
      relatedIds: relatedIds ?? this.relatedIds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (relatedIds.present) {
      map['related_ids'] = Variable<String>(relatedIds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('timestamp: $timestamp, ')
          ..write('title: $title, ')
          ..write('entityId: $entityId, ')
          ..write('relatedIds: $relatedIds')
          ..write(')'))
        .toString();
  }
}

class $BreedingRemindersTable extends BreedingReminders
    with TableInfo<$BreedingRemindersTable, BreedingReminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BreedingRemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _breedingEventIdMeta = const VerificationMeta(
    'breedingEventId',
  );
  @override
  late final GeneratedColumn<int> breedingEventId = GeneratedColumn<int>(
    'breeding_event_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES breeding_events (id)',
    ),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    breedingEventId,
    dueDate,
    note,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'breeding_reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<BreedingReminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('breeding_event_id')) {
      context.handle(
        _breedingEventIdMeta,
        breedingEventId.isAcceptableOrUnknown(
          data['breeding_event_id']!,
          _breedingEventIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_breedingEventIdMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BreedingReminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BreedingReminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      breedingEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}breeding_event_id'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $BreedingRemindersTable createAlias(String alias) {
    return $BreedingRemindersTable(attachedDatabase, alias);
  }
}

class BreedingReminder extends DataClass
    implements Insertable<BreedingReminder> {
  final int id;
  final int breedingEventId;
  final DateTime dueDate;
  final String? note;
  final DateTime createdAt;
  final DateTime? completedAt;
  const BreedingReminder({
    required this.id,
    required this.breedingEventId,
    required this.dueDate,
    this.note,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['breeding_event_id'] = Variable<int>(breedingEventId);
    map['due_date'] = Variable<DateTime>(dueDate);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  BreedingRemindersCompanion toCompanion(bool nullToAbsent) {
    return BreedingRemindersCompanion(
      id: Value(id),
      breedingEventId: Value(breedingEventId),
      dueDate: Value(dueDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory BreedingReminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BreedingReminder(
      id: serializer.fromJson<int>(json['id']),
      breedingEventId: serializer.fromJson<int>(json['breedingEventId']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'breedingEventId': serializer.toJson<int>(breedingEventId),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  BreedingReminder copyWith({
    int? id,
    int? breedingEventId,
    DateTime? dueDate,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => BreedingReminder(
    id: id ?? this.id,
    breedingEventId: breedingEventId ?? this.breedingEventId,
    dueDate: dueDate ?? this.dueDate,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  BreedingReminder copyWithCompanion(BreedingRemindersCompanion data) {
    return BreedingReminder(
      id: data.id.present ? data.id.value : this.id,
      breedingEventId: data.breedingEventId.present
          ? data.breedingEventId.value
          : this.breedingEventId,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BreedingReminder(')
          ..write('id: $id, ')
          ..write('breedingEventId: $breedingEventId, ')
          ..write('dueDate: $dueDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, breedingEventId, dueDate, note, createdAt, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BreedingReminder &&
          other.id == this.id &&
          other.breedingEventId == this.breedingEventId &&
          other.dueDate == this.dueDate &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class BreedingRemindersCompanion extends UpdateCompanion<BreedingReminder> {
  final Value<int> id;
  final Value<int> breedingEventId;
  final Value<DateTime> dueDate;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  const BreedingRemindersCompanion({
    this.id = const Value.absent(),
    this.breedingEventId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  BreedingRemindersCompanion.insert({
    this.id = const Value.absent(),
    required int breedingEventId,
    required DateTime dueDate,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  }) : breedingEventId = Value(breedingEventId),
       dueDate = Value(dueDate);
  static Insertable<BreedingReminder> custom({
    Expression<int>? id,
    Expression<int>? breedingEventId,
    Expression<DateTime>? dueDate,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (breedingEventId != null) 'breeding_event_id': breedingEventId,
      if (dueDate != null) 'due_date': dueDate,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  BreedingRemindersCompanion copyWith({
    Value<int>? id,
    Value<int>? breedingEventId,
    Value<DateTime>? dueDate,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
  }) {
    return BreedingRemindersCompanion(
      id: id ?? this.id,
      breedingEventId: breedingEventId ?? this.breedingEventId,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (breedingEventId.present) {
      map['breeding_event_id'] = Variable<int>(breedingEventId.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BreedingRemindersCompanion(')
          ..write('id: $id, ')
          ..write('breedingEventId: $breedingEventId, ')
          ..write('dueDate: $dueDate, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $SpeciesInfosTable extends SpeciesInfos
    with TableInfo<$SpeciesInfosTable, SpeciesInfo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeciesInfosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _speciesNameMeta = const VerificationMeta(
    'speciesName',
  );
  @override
  late final GeneratedColumn<String> speciesName = GeneratedColumn<String>(
    'species_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _specialNotesMeta = const VerificationMeta(
    'specialNotes',
  );
  @override
  late final GeneratedColumn<String> specialNotes = GeneratedColumn<String>(
    'special_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lengthRangeTextMeta = const VerificationMeta(
    'lengthRangeText',
  );
  @override
  late final GeneratedColumn<String> lengthRangeText = GeneratedColumn<String>(
    'length_range_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temperatureRangeTextMeta =
      const VerificationMeta('temperatureRangeText');
  @override
  late final GeneratedColumn<String> temperatureRangeText =
      GeneratedColumn<String>(
        'temperature_range_text',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    speciesName,
    description,
    specialNotes,
    region,
    lengthRangeText,
    temperatureRangeText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'species_infos';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpeciesInfo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('species_name')) {
      context.handle(
        _speciesNameMeta,
        speciesName.isAcceptableOrUnknown(
          data['species_name']!,
          _speciesNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_speciesNameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('special_notes')) {
      context.handle(
        _specialNotesMeta,
        specialNotes.isAcceptableOrUnknown(
          data['special_notes']!,
          _specialNotesMeta,
        ),
      );
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    if (data.containsKey('length_range_text')) {
      context.handle(
        _lengthRangeTextMeta,
        lengthRangeText.isAcceptableOrUnknown(
          data['length_range_text']!,
          _lengthRangeTextMeta,
        ),
      );
    }
    if (data.containsKey('temperature_range_text')) {
      context.handle(
        _temperatureRangeTextMeta,
        temperatureRangeText.isAcceptableOrUnknown(
          data['temperature_range_text']!,
          _temperatureRangeTextMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpeciesInfo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeciesInfo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      speciesName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species_name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      specialNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}special_notes'],
      ),
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      ),
      lengthRangeText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}length_range_text'],
      ),
      temperatureRangeText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}temperature_range_text'],
      ),
    );
  }

  @override
  $SpeciesInfosTable createAlias(String alias) {
    return $SpeciesInfosTable(attachedDatabase, alias);
  }
}

class SpeciesInfo extends DataClass implements Insertable<SpeciesInfo> {
  final int id;
  final String speciesName;
  final String? description;
  final String? specialNotes;
  final String? region;
  final String? lengthRangeText;
  final String? temperatureRangeText;
  const SpeciesInfo({
    required this.id,
    required this.speciesName,
    this.description,
    this.specialNotes,
    this.region,
    this.lengthRangeText,
    this.temperatureRangeText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['species_name'] = Variable<String>(speciesName);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || specialNotes != null) {
      map['special_notes'] = Variable<String>(specialNotes);
    }
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    if (!nullToAbsent || lengthRangeText != null) {
      map['length_range_text'] = Variable<String>(lengthRangeText);
    }
    if (!nullToAbsent || temperatureRangeText != null) {
      map['temperature_range_text'] = Variable<String>(temperatureRangeText);
    }
    return map;
  }

  SpeciesInfosCompanion toCompanion(bool nullToAbsent) {
    return SpeciesInfosCompanion(
      id: Value(id),
      speciesName: Value(speciesName),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      specialNotes: specialNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(specialNotes),
      region: region == null && nullToAbsent
          ? const Value.absent()
          : Value(region),
      lengthRangeText: lengthRangeText == null && nullToAbsent
          ? const Value.absent()
          : Value(lengthRangeText),
      temperatureRangeText: temperatureRangeText == null && nullToAbsent
          ? const Value.absent()
          : Value(temperatureRangeText),
    );
  }

  factory SpeciesInfo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeciesInfo(
      id: serializer.fromJson<int>(json['id']),
      speciesName: serializer.fromJson<String>(json['speciesName']),
      description: serializer.fromJson<String?>(json['description']),
      specialNotes: serializer.fromJson<String?>(json['specialNotes']),
      region: serializer.fromJson<String?>(json['region']),
      lengthRangeText: serializer.fromJson<String?>(json['lengthRangeText']),
      temperatureRangeText: serializer.fromJson<String?>(
        json['temperatureRangeText'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'speciesName': serializer.toJson<String>(speciesName),
      'description': serializer.toJson<String?>(description),
      'specialNotes': serializer.toJson<String?>(specialNotes),
      'region': serializer.toJson<String?>(region),
      'lengthRangeText': serializer.toJson<String?>(lengthRangeText),
      'temperatureRangeText': serializer.toJson<String?>(temperatureRangeText),
    };
  }

  SpeciesInfo copyWith({
    int? id,
    String? speciesName,
    Value<String?> description = const Value.absent(),
    Value<String?> specialNotes = const Value.absent(),
    Value<String?> region = const Value.absent(),
    Value<String?> lengthRangeText = const Value.absent(),
    Value<String?> temperatureRangeText = const Value.absent(),
  }) => SpeciesInfo(
    id: id ?? this.id,
    speciesName: speciesName ?? this.speciesName,
    description: description.present ? description.value : this.description,
    specialNotes: specialNotes.present ? specialNotes.value : this.specialNotes,
    region: region.present ? region.value : this.region,
    lengthRangeText: lengthRangeText.present
        ? lengthRangeText.value
        : this.lengthRangeText,
    temperatureRangeText: temperatureRangeText.present
        ? temperatureRangeText.value
        : this.temperatureRangeText,
  );
  SpeciesInfo copyWithCompanion(SpeciesInfosCompanion data) {
    return SpeciesInfo(
      id: data.id.present ? data.id.value : this.id,
      speciesName: data.speciesName.present
          ? data.speciesName.value
          : this.speciesName,
      description: data.description.present
          ? data.description.value
          : this.description,
      specialNotes: data.specialNotes.present
          ? data.specialNotes.value
          : this.specialNotes,
      region: data.region.present ? data.region.value : this.region,
      lengthRangeText: data.lengthRangeText.present
          ? data.lengthRangeText.value
          : this.lengthRangeText,
      temperatureRangeText: data.temperatureRangeText.present
          ? data.temperatureRangeText.value
          : this.temperatureRangeText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesInfo(')
          ..write('id: $id, ')
          ..write('speciesName: $speciesName, ')
          ..write('description: $description, ')
          ..write('specialNotes: $specialNotes, ')
          ..write('region: $region, ')
          ..write('lengthRangeText: $lengthRangeText, ')
          ..write('temperatureRangeText: $temperatureRangeText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    speciesName,
    description,
    specialNotes,
    region,
    lengthRangeText,
    temperatureRangeText,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeciesInfo &&
          other.id == this.id &&
          other.speciesName == this.speciesName &&
          other.description == this.description &&
          other.specialNotes == this.specialNotes &&
          other.region == this.region &&
          other.lengthRangeText == this.lengthRangeText &&
          other.temperatureRangeText == this.temperatureRangeText);
}

class SpeciesInfosCompanion extends UpdateCompanion<SpeciesInfo> {
  final Value<int> id;
  final Value<String> speciesName;
  final Value<String?> description;
  final Value<String?> specialNotes;
  final Value<String?> region;
  final Value<String?> lengthRangeText;
  final Value<String?> temperatureRangeText;
  const SpeciesInfosCompanion({
    this.id = const Value.absent(),
    this.speciesName = const Value.absent(),
    this.description = const Value.absent(),
    this.specialNotes = const Value.absent(),
    this.region = const Value.absent(),
    this.lengthRangeText = const Value.absent(),
    this.temperatureRangeText = const Value.absent(),
  });
  SpeciesInfosCompanion.insert({
    this.id = const Value.absent(),
    required String speciesName,
    this.description = const Value.absent(),
    this.specialNotes = const Value.absent(),
    this.region = const Value.absent(),
    this.lengthRangeText = const Value.absent(),
    this.temperatureRangeText = const Value.absent(),
  }) : speciesName = Value(speciesName);
  static Insertable<SpeciesInfo> custom({
    Expression<int>? id,
    Expression<String>? speciesName,
    Expression<String>? description,
    Expression<String>? specialNotes,
    Expression<String>? region,
    Expression<String>? lengthRangeText,
    Expression<String>? temperatureRangeText,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (speciesName != null) 'species_name': speciesName,
      if (description != null) 'description': description,
      if (specialNotes != null) 'special_notes': specialNotes,
      if (region != null) 'region': region,
      if (lengthRangeText != null) 'length_range_text': lengthRangeText,
      if (temperatureRangeText != null)
        'temperature_range_text': temperatureRangeText,
    });
  }

  SpeciesInfosCompanion copyWith({
    Value<int>? id,
    Value<String>? speciesName,
    Value<String?>? description,
    Value<String?>? specialNotes,
    Value<String?>? region,
    Value<String?>? lengthRangeText,
    Value<String?>? temperatureRangeText,
  }) {
    return SpeciesInfosCompanion(
      id: id ?? this.id,
      speciesName: speciesName ?? this.speciesName,
      description: description ?? this.description,
      specialNotes: specialNotes ?? this.specialNotes,
      region: region ?? this.region,
      lengthRangeText: lengthRangeText ?? this.lengthRangeText,
      temperatureRangeText: temperatureRangeText ?? this.temperatureRangeText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (speciesName.present) {
      map['species_name'] = Variable<String>(speciesName.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (specialNotes.present) {
      map['special_notes'] = Variable<String>(specialNotes.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (lengthRangeText.present) {
      map['length_range_text'] = Variable<String>(lengthRangeText.value);
    }
    if (temperatureRangeText.present) {
      map['temperature_range_text'] = Variable<String>(
        temperatureRangeText.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesInfosCompanion(')
          ..write('id: $id, ')
          ..write('speciesName: $speciesName, ')
          ..write('description: $description, ')
          ..write('specialNotes: $specialNotes, ')
          ..write('region: $region, ')
          ..write('lengthRangeText: $lengthRangeText, ')
          ..write('temperatureRangeText: $temperatureRangeText')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ShelvesTable shelves = $ShelvesTable(this);
  late final $TerrariumsTable terrariums = $TerrariumsTable(this);
  late final $SpecimensTable specimens = $SpecimensTable(this);
  late final $BreedingEventsTable breedingEvents = $BreedingEventsTable(this);
  late final $BreedingLogEntriesTable breedingLogEntries =
      $BreedingLogEntriesTable(this);
  late final $ToolsTable tools = $ToolsTable(this);
  late final $SpecimenLogEntriesTable specimenLogEntries =
      $SpecimenLogEntriesTable(this);
  late final $ActivityLogEntriesTable activityLogEntries =
      $ActivityLogEntriesTable(this);
  late final $BreedingRemindersTable breedingReminders =
      $BreedingRemindersTable(this);
  late final $SpeciesInfosTable speciesInfos = $SpeciesInfosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    shelves,
    terrariums,
    specimens,
    breedingEvents,
    breedingLogEntries,
    tools,
    specimenLogEntries,
    activityLogEntries,
    breedingReminders,
    speciesInfos,
  ];
}

typedef $$ShelvesTableCreateCompanionBuilder =
    ShelvesCompanion Function({
      Value<int> id,
      required String name,
      required String label,
      required double lengthCm,
      required int levelCount,
      required double levelHeightCm,
      Value<DateTime> createdAt,
    });
typedef $$ShelvesTableUpdateCompanionBuilder =
    ShelvesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> label,
      Value<double> lengthCm,
      Value<int> levelCount,
      Value<double> levelHeightCm,
      Value<DateTime> createdAt,
    });

final class $$ShelvesTableReferences
    extends BaseReferences<_$AppDatabase, $ShelvesTable, Shelf> {
  $$ShelvesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TerrariumsTable, List<Terrarium>>
  _terrariumsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.terrariums,
    aliasName: 'shelves__id__terrariums__shelf_id',
  );

  $$TerrariumsTableProcessedTableManager get terrariumsRefs {
    final manager = $$TerrariumsTableTableManager(
      $_db,
      $_db.terrariums,
    ).filter((f) => f.shelfId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_terrariumsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ToolsTable, List<Tool>> _toolsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tools,
    aliasName: 'shelves__id__tools__shelf_id',
  );

  $$ToolsTableProcessedTableManager get toolsRefs {
    final manager = $$ToolsTableTableManager(
      $_db,
      $_db.tools,
    ).filter((f) => f.shelfId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_toolsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ShelvesTableFilterComposer
    extends Composer<_$AppDatabase, $ShelvesTable> {
  $$ShelvesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lengthCm => $composableBuilder(
    column: $table.lengthCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get levelCount => $composableBuilder(
    column: $table.levelCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get levelHeightCm => $composableBuilder(
    column: $table.levelHeightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> terrariumsRefs(
    Expression<bool> Function($$TerrariumsTableFilterComposer f) f,
  ) {
    final $$TerrariumsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.terrariums,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TerrariumsTableFilterComposer(
            $db: $db,
            $table: $db.terrariums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> toolsRefs(
    Expression<bool> Function($$ToolsTableFilterComposer f) f,
  ) {
    final $$ToolsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tools,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ToolsTableFilterComposer(
            $db: $db,
            $table: $db.tools,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShelvesTableOrderingComposer
    extends Composer<_$AppDatabase, $ShelvesTable> {
  $$ShelvesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lengthCm => $composableBuilder(
    column: $table.lengthCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get levelCount => $composableBuilder(
    column: $table.levelCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get levelHeightCm => $composableBuilder(
    column: $table.levelHeightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShelvesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShelvesTable> {
  $$ShelvesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get lengthCm =>
      $composableBuilder(column: $table.lengthCm, builder: (column) => column);

  GeneratedColumn<int> get levelCount => $composableBuilder(
    column: $table.levelCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get levelHeightCm => $composableBuilder(
    column: $table.levelHeightCm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> terrariumsRefs<T extends Object>(
    Expression<T> Function($$TerrariumsTableAnnotationComposer a) f,
  ) {
    final $$TerrariumsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.terrariums,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TerrariumsTableAnnotationComposer(
            $db: $db,
            $table: $db.terrariums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> toolsRefs<T extends Object>(
    Expression<T> Function($$ToolsTableAnnotationComposer a) f,
  ) {
    final $$ToolsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tools,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ToolsTableAnnotationComposer(
            $db: $db,
            $table: $db.tools,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShelvesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShelvesTable,
          Shelf,
          $$ShelvesTableFilterComposer,
          $$ShelvesTableOrderingComposer,
          $$ShelvesTableAnnotationComposer,
          $$ShelvesTableCreateCompanionBuilder,
          $$ShelvesTableUpdateCompanionBuilder,
          (Shelf, $$ShelvesTableReferences),
          Shelf,
          PrefetchHooks Function({bool terrariumsRefs, bool toolsRefs})
        > {
  $$ShelvesTableTableManager(_$AppDatabase db, $ShelvesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShelvesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShelvesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShelvesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<double> lengthCm = const Value.absent(),
                Value<int> levelCount = const Value.absent(),
                Value<double> levelHeightCm = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ShelvesCompanion(
                id: id,
                name: name,
                label: label,
                lengthCm: lengthCm,
                levelCount: levelCount,
                levelHeightCm: levelHeightCm,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String label,
                required double lengthCm,
                required int levelCount,
                required double levelHeightCm,
                Value<DateTime> createdAt = const Value.absent(),
              }) => ShelvesCompanion.insert(
                id: id,
                name: name,
                label: label,
                lengthCm: lengthCm,
                levelCount: levelCount,
                levelHeightCm: levelHeightCm,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShelvesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({terrariumsRefs = false, toolsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (terrariumsRefs) db.terrariums,
                if (toolsRefs) db.tools,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (terrariumsRefs)
                    await $_getPrefetchedData<Shelf, $ShelvesTable, Terrarium>(
                      currentTable: table,
                      referencedTable: $$ShelvesTableReferences
                          ._terrariumsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ShelvesTableReferences(
                        db,
                        table,
                        p0,
                      ).terrariumsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.shelfId == item.id),
                      typedResults: items,
                    ),
                  if (toolsRefs)
                    await $_getPrefetchedData<Shelf, $ShelvesTable, Tool>(
                      currentTable: table,
                      referencedTable: $$ShelvesTableReferences._toolsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$ShelvesTableReferences(db, table, p0).toolsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.shelfId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ShelvesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShelvesTable,
      Shelf,
      $$ShelvesTableFilterComposer,
      $$ShelvesTableOrderingComposer,
      $$ShelvesTableAnnotationComposer,
      $$ShelvesTableCreateCompanionBuilder,
      $$ShelvesTableUpdateCompanionBuilder,
      (Shelf, $$ShelvesTableReferences),
      Shelf,
      PrefetchHooks Function({bool terrariumsRefs, bool toolsRefs})
    >;
typedef $$TerrariumsTableCreateCompanionBuilder =
    TerrariumsCompanion Function({
      Value<int> id,
      required String shape,
      Value<double?> lengthCm,
      Value<double?> widthCm,
      Value<double?> diameterCm,
      required double heightCm,
      required double volumeLitres,
      Value<int?> shelfId,
      Value<int?> level,
      Value<int?> positionInLevel,
      Value<double?> positionXCm,
      Value<int?> stackOrder,
      Value<int?> supportId,
      Value<String?> supportKind,
      Value<String?> location,
      Value<int?> individualSequence,
      Value<String> purpose,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
    });
typedef $$TerrariumsTableUpdateCompanionBuilder =
    TerrariumsCompanion Function({
      Value<int> id,
      Value<String> shape,
      Value<double?> lengthCm,
      Value<double?> widthCm,
      Value<double?> diameterCm,
      Value<double> heightCm,
      Value<double> volumeLitres,
      Value<int?> shelfId,
      Value<int?> level,
      Value<int?> positionInLevel,
      Value<double?> positionXCm,
      Value<int?> stackOrder,
      Value<int?> supportId,
      Value<String?> supportKind,
      Value<String?> location,
      Value<int?> individualSequence,
      Value<String> purpose,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
    });

final class $$TerrariumsTableReferences
    extends BaseReferences<_$AppDatabase, $TerrariumsTable, Terrarium> {
  $$TerrariumsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ShelvesTable _shelfIdTable(_$AppDatabase db) =>
      db.shelves.createAlias('terrariums__shelf_id__shelves__id');

  $$ShelvesTableProcessedTableManager? get shelfId {
    final $_column = $_itemColumn<int>('shelf_id');
    if ($_column == null) return null;
    final manager = $$ShelvesTableTableManager(
      $_db,
      $_db.shelves,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shelfIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SpecimensTable, List<Specimen>>
  _specimensRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.specimens,
    aliasName: 'terrariums__id__specimens__terrarium_id',
  );

  $$SpecimensTableProcessedTableManager get specimensRefs {
    final manager = $$SpecimensTableTableManager(
      $_db,
      $_db.specimens,
    ).filter((f) => f.terrariumId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_specimensRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BreedingEventsTable, List<BreedingEvent>>
  _breedingEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.breedingEvents,
    aliasName: 'terrariums__id__breeding_events__terrarium_id',
  );

  $$BreedingEventsTableProcessedTableManager get breedingEventsRefs {
    final manager = $$BreedingEventsTableTableManager(
      $_db,
      $_db.breedingEvents,
    ).filter((f) => f.terrariumId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_breedingEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TerrariumsTableFilterComposer
    extends Composer<_$AppDatabase, $TerrariumsTable> {
  $$TerrariumsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shape => $composableBuilder(
    column: $table.shape,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lengthCm => $composableBuilder(
    column: $table.lengthCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get widthCm => $composableBuilder(
    column: $table.widthCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get diameterCm => $composableBuilder(
    column: $table.diameterCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get volumeLitres => $composableBuilder(
    column: $table.volumeLitres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionInLevel => $composableBuilder(
    column: $table.positionInLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get positionXCm => $composableBuilder(
    column: $table.positionXCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stackOrder => $composableBuilder(
    column: $table.stackOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get supportId => $composableBuilder(
    column: $table.supportId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supportKind => $composableBuilder(
    column: $table.supportKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get individualSequence => $composableBuilder(
    column: $table.individualSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ShelvesTableFilterComposer get shelfId {
    final $$ShelvesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableFilterComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> specimensRefs(
    Expression<bool> Function($$SpecimensTableFilterComposer f) f,
  ) {
    final $$SpecimensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.specimens,
      getReferencedColumn: (t) => t.terrariumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpecimensTableFilterComposer(
            $db: $db,
            $table: $db.specimens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> breedingEventsRefs(
    Expression<bool> Function($$BreedingEventsTableFilterComposer f) f,
  ) {
    final $$BreedingEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.breedingEvents,
      getReferencedColumn: (t) => t.terrariumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BreedingEventsTableFilterComposer(
            $db: $db,
            $table: $db.breedingEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TerrariumsTableOrderingComposer
    extends Composer<_$AppDatabase, $TerrariumsTable> {
  $$TerrariumsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shape => $composableBuilder(
    column: $table.shape,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lengthCm => $composableBuilder(
    column: $table.lengthCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get widthCm => $composableBuilder(
    column: $table.widthCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get diameterCm => $composableBuilder(
    column: $table.diameterCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get volumeLitres => $composableBuilder(
    column: $table.volumeLitres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionInLevel => $composableBuilder(
    column: $table.positionInLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get positionXCm => $composableBuilder(
    column: $table.positionXCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stackOrder => $composableBuilder(
    column: $table.stackOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get supportId => $composableBuilder(
    column: $table.supportId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supportKind => $composableBuilder(
    column: $table.supportKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get individualSequence => $composableBuilder(
    column: $table.individualSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ShelvesTableOrderingComposer get shelfId {
    final $$ShelvesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableOrderingComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TerrariumsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TerrariumsTable> {
  $$TerrariumsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shape =>
      $composableBuilder(column: $table.shape, builder: (column) => column);

  GeneratedColumn<double> get lengthCm =>
      $composableBuilder(column: $table.lengthCm, builder: (column) => column);

  GeneratedColumn<double> get widthCm =>
      $composableBuilder(column: $table.widthCm, builder: (column) => column);

  GeneratedColumn<double> get diameterCm => $composableBuilder(
    column: $table.diameterCm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get volumeLitres => $composableBuilder(
    column: $table.volumeLitres,
    builder: (column) => column,
  );

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get positionInLevel => $composableBuilder(
    column: $table.positionInLevel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get positionXCm => $composableBuilder(
    column: $table.positionXCm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stackOrder => $composableBuilder(
    column: $table.stackOrder,
    builder: (column) => column,
  );

  GeneratedColumn<int> get supportId =>
      $composableBuilder(column: $table.supportId, builder: (column) => column);

  GeneratedColumn<String> get supportKind => $composableBuilder(
    column: $table.supportKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<int> get individualSequence => $composableBuilder(
    column: $table.individualSequence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$ShelvesTableAnnotationComposer get shelfId {
    final $$ShelvesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableAnnotationComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> specimensRefs<T extends Object>(
    Expression<T> Function($$SpecimensTableAnnotationComposer a) f,
  ) {
    final $$SpecimensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.specimens,
      getReferencedColumn: (t) => t.terrariumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpecimensTableAnnotationComposer(
            $db: $db,
            $table: $db.specimens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> breedingEventsRefs<T extends Object>(
    Expression<T> Function($$BreedingEventsTableAnnotationComposer a) f,
  ) {
    final $$BreedingEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.breedingEvents,
      getReferencedColumn: (t) => t.terrariumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BreedingEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.breedingEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TerrariumsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TerrariumsTable,
          Terrarium,
          $$TerrariumsTableFilterComposer,
          $$TerrariumsTableOrderingComposer,
          $$TerrariumsTableAnnotationComposer,
          $$TerrariumsTableCreateCompanionBuilder,
          $$TerrariumsTableUpdateCompanionBuilder,
          (Terrarium, $$TerrariumsTableReferences),
          Terrarium,
          PrefetchHooks Function({
            bool shelfId,
            bool specimensRefs,
            bool breedingEventsRefs,
          })
        > {
  $$TerrariumsTableTableManager(_$AppDatabase db, $TerrariumsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TerrariumsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TerrariumsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TerrariumsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> shape = const Value.absent(),
                Value<double?> lengthCm = const Value.absent(),
                Value<double?> widthCm = const Value.absent(),
                Value<double?> diameterCm = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<double> volumeLitres = const Value.absent(),
                Value<int?> shelfId = const Value.absent(),
                Value<int?> level = const Value.absent(),
                Value<int?> positionInLevel = const Value.absent(),
                Value<double?> positionXCm = const Value.absent(),
                Value<int?> stackOrder = const Value.absent(),
                Value<int?> supportId = const Value.absent(),
                Value<String?> supportKind = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<int?> individualSequence = const Value.absent(),
                Value<String> purpose = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => TerrariumsCompanion(
                id: id,
                shape: shape,
                lengthCm: lengthCm,
                widthCm: widthCm,
                diameterCm: diameterCm,
                heightCm: heightCm,
                volumeLitres: volumeLitres,
                shelfId: shelfId,
                level: level,
                positionInLevel: positionInLevel,
                positionXCm: positionXCm,
                stackOrder: stackOrder,
                supportId: supportId,
                supportKind: supportKind,
                location: location,
                individualSequence: individualSequence,
                purpose: purpose,
                createdAt: createdAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String shape,
                Value<double?> lengthCm = const Value.absent(),
                Value<double?> widthCm = const Value.absent(),
                Value<double?> diameterCm = const Value.absent(),
                required double heightCm,
                required double volumeLitres,
                Value<int?> shelfId = const Value.absent(),
                Value<int?> level = const Value.absent(),
                Value<int?> positionInLevel = const Value.absent(),
                Value<double?> positionXCm = const Value.absent(),
                Value<int?> stackOrder = const Value.absent(),
                Value<int?> supportId = const Value.absent(),
                Value<String?> supportKind = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<int?> individualSequence = const Value.absent(),
                Value<String> purpose = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => TerrariumsCompanion.insert(
                id: id,
                shape: shape,
                lengthCm: lengthCm,
                widthCm: widthCm,
                diameterCm: diameterCm,
                heightCm: heightCm,
                volumeLitres: volumeLitres,
                shelfId: shelfId,
                level: level,
                positionInLevel: positionInLevel,
                positionXCm: positionXCm,
                stackOrder: stackOrder,
                supportId: supportId,
                supportKind: supportKind,
                location: location,
                individualSequence: individualSequence,
                purpose: purpose,
                createdAt: createdAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TerrariumsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                shelfId = false,
                specimensRefs = false,
                breedingEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (specimensRefs) db.specimens,
                    if (breedingEventsRefs) db.breedingEvents,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (shelfId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.shelfId,
                                    referencedTable: $$TerrariumsTableReferences
                                        ._shelfIdTable(db),
                                    referencedColumn:
                                        $$TerrariumsTableReferences
                                            ._shelfIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (specimensRefs)
                        await $_getPrefetchedData<
                          Terrarium,
                          $TerrariumsTable,
                          Specimen
                        >(
                          currentTable: table,
                          referencedTable: $$TerrariumsTableReferences
                              ._specimensRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TerrariumsTableReferences(
                                db,
                                table,
                                p0,
                              ).specimensRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.terrariumId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (breedingEventsRefs)
                        await $_getPrefetchedData<
                          Terrarium,
                          $TerrariumsTable,
                          BreedingEvent
                        >(
                          currentTable: table,
                          referencedTable: $$TerrariumsTableReferences
                              ._breedingEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TerrariumsTableReferences(
                                db,
                                table,
                                p0,
                              ).breedingEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.terrariumId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TerrariumsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TerrariumsTable,
      Terrarium,
      $$TerrariumsTableFilterComposer,
      $$TerrariumsTableOrderingComposer,
      $$TerrariumsTableAnnotationComposer,
      $$TerrariumsTableCreateCompanionBuilder,
      $$TerrariumsTableUpdateCompanionBuilder,
      (Terrarium, $$TerrariumsTableReferences),
      Terrarium,
      PrefetchHooks Function({
        bool shelfId,
        bool specimensRefs,
        bool breedingEventsRefs,
      })
    >;
typedef $$SpecimensTableCreateCompanionBuilder =
    SpecimensCompanion Function({
      Value<int> id,
      Value<String?> name,
      required String species,
      Value<String> speciesIconKey,
      Value<String> sex,
      Value<DateTime?> dateAcquired,
      Value<DateTime?> dateOfBirth,
      Value<double?> weightGrams,
      Value<double?> sizeCm,
      Value<String?> lifeStage,
      Value<String?> beetleFamily,
      Value<int?> replenishIntervalDays,
      Value<DateTime?> lastReplenishedAt,
      Value<String?> replenishNote,
      Value<String> status,
      Value<String?> notes,
      Value<String?> photoPath,
      Value<int?> motherId,
      Value<int?> fatherId,
      Value<int?> terrariumId,
      Value<int?> sourceBreedingEventId,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
    });
typedef $$SpecimensTableUpdateCompanionBuilder =
    SpecimensCompanion Function({
      Value<int> id,
      Value<String?> name,
      Value<String> species,
      Value<String> speciesIconKey,
      Value<String> sex,
      Value<DateTime?> dateAcquired,
      Value<DateTime?> dateOfBirth,
      Value<double?> weightGrams,
      Value<double?> sizeCm,
      Value<String?> lifeStage,
      Value<String?> beetleFamily,
      Value<int?> replenishIntervalDays,
      Value<DateTime?> lastReplenishedAt,
      Value<String?> replenishNote,
      Value<String> status,
      Value<String?> notes,
      Value<String?> photoPath,
      Value<int?> motherId,
      Value<int?> fatherId,
      Value<int?> terrariumId,
      Value<int?> sourceBreedingEventId,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
    });

final class $$SpecimensTableReferences
    extends BaseReferences<_$AppDatabase, $SpecimensTable, Specimen> {
  $$SpecimensTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SpecimensTable _motherIdTable(_$AppDatabase db) =>
      db.specimens.createAlias('specimens__mother_id__specimens__id');

  $$SpecimensTableProcessedTableManager? get motherId {
    final $_column = $_itemColumn<int>('mother_id');
    if ($_column == null) return null;
    final manager = $$SpecimensTableTableManager(
      $_db,
      $_db.specimens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_motherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SpecimensTable _fatherIdTable(_$AppDatabase db) =>
      db.specimens.createAlias('specimens__father_id__specimens__id');

  $$SpecimensTableProcessedTableManager? get fatherId {
    final $_column = $_itemColumn<int>('father_id');
    if ($_column == null) return null;
    final manager = $$SpecimensTableTableManager(
      $_db,
      $_db.specimens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fatherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TerrariumsTable _terrariumIdTable(_$AppDatabase db) =>
      db.terrariums.createAlias('specimens__terrarium_id__terrariums__id');

  $$TerrariumsTableProcessedTableManager? get terrariumId {
    final $_column = $_itemColumn<int>('terrarium_id');
    if ($_column == null) return null;
    final manager = $$TerrariumsTableTableManager(
      $_db,
      $_db.terrariums,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_terrariumIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SpecimenLogEntriesTable, List<SpecimenLogEntry>>
  _specimenLogEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.specimenLogEntries,
        aliasName: 'specimens__id__specimen_log_entries__specimen_id',
      );

  $$SpecimenLogEntriesTableProcessedTableManager get specimenLogEntriesRefs {
    final manager = $$SpecimenLogEntriesTableTableManager(
      $_db,
      $_db.specimenLogEntries,
    ).filter((f) => f.specimenId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _specimenLogEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SpecimensTableFilterComposer
    extends Composer<_$AppDatabase, $SpecimensTable> {
  $$SpecimensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speciesIconKey => $composableBuilder(
    column: $table.speciesIconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAcquired => $composableBuilder(
    column: $table.dateAcquired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sizeCm => $composableBuilder(
    column: $table.sizeCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lifeStage => $composableBuilder(
    column: $table.lifeStage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beetleFamily => $composableBuilder(
    column: $table.beetleFamily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get replenishIntervalDays => $composableBuilder(
    column: $table.replenishIntervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReplenishedAt => $composableBuilder(
    column: $table.lastReplenishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replenishNote => $composableBuilder(
    column: $table.replenishNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceBreedingEventId => $composableBuilder(
    column: $table.sourceBreedingEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SpecimensTableFilterComposer get motherId {
    final $$SpecimensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motherId,
      referencedTable: $db.specimens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpecimensTableFilterComposer(
            $db: $db,
            $table: $db.specimens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SpecimensTableFilterComposer get fatherId {
    final $$SpecimensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fatherId,
      referencedTable: $db.specimens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpecimensTableFilterComposer(
            $db: $db,
            $table: $db.specimens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TerrariumsTableFilterComposer get terrariumId {
    final $$TerrariumsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.terrariumId,
      referencedTable: $db.terrariums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TerrariumsTableFilterComposer(
            $db: $db,
            $table: $db.terrariums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> specimenLogEntriesRefs(
    Expression<bool> Function($$SpecimenLogEntriesTableFilterComposer f) f,
  ) {
    final $$SpecimenLogEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.specimenLogEntries,
      getReferencedColumn: (t) => t.specimenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpecimenLogEntriesTableFilterComposer(
            $db: $db,
            $table: $db.specimenLogEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SpecimensTableOrderingComposer
    extends Composer<_$AppDatabase, $SpecimensTable> {
  $$SpecimensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speciesIconKey => $composableBuilder(
    column: $table.speciesIconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAcquired => $composableBuilder(
    column: $table.dateAcquired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sizeCm => $composableBuilder(
    column: $table.sizeCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifeStage => $composableBuilder(
    column: $table.lifeStage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beetleFamily => $composableBuilder(
    column: $table.beetleFamily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get replenishIntervalDays => $composableBuilder(
    column: $table.replenishIntervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReplenishedAt => $composableBuilder(
    column: $table.lastReplenishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replenishNote => $composableBuilder(
    column: $table.replenishNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceBreedingEventId => $composableBuilder(
    column: $table.sourceBreedingEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SpecimensTableOrderingComposer get motherId {
    final $$SpecimensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motherId,
      referencedTable: $db.specimens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpecimensTableOrderingComposer(
            $db: $db,
            $table: $db.specimens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SpecimensTableOrderingComposer get fatherId {
    final $$SpecimensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fatherId,
      referencedTable: $db.specimens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpecimensTableOrderingComposer(
            $db: $db,
            $table: $db.specimens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TerrariumsTableOrderingComposer get terrariumId {
    final $$TerrariumsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.terrariumId,
      referencedTable: $db.terrariums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TerrariumsTableOrderingComposer(
            $db: $db,
            $table: $db.terrariums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpecimensTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpecimensTable> {
  $$SpecimensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<String> get speciesIconKey => $composableBuilder(
    column: $table.speciesIconKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAcquired => $composableBuilder(
    column: $table.dateAcquired,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightGrams => $composableBuilder(
    column: $table.weightGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sizeCm =>
      $composableBuilder(column: $table.sizeCm, builder: (column) => column);

  GeneratedColumn<String> get lifeStage =>
      $composableBuilder(column: $table.lifeStage, builder: (column) => column);

  GeneratedColumn<String> get beetleFamily => $composableBuilder(
    column: $table.beetleFamily,
    builder: (column) => column,
  );

  GeneratedColumn<int> get replenishIntervalDays => $composableBuilder(
    column: $table.replenishIntervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReplenishedAt => $composableBuilder(
    column: $table.lastReplenishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get replenishNote => $composableBuilder(
    column: $table.replenishNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<int> get sourceBreedingEventId => $composableBuilder(
    column: $table.sourceBreedingEventId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$SpecimensTableAnnotationComposer get motherId {
    final $$SpecimensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motherId,
      referencedTable: $db.specimens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpecimensTableAnnotationComposer(
            $db: $db,
            $table: $db.specimens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SpecimensTableAnnotationComposer get fatherId {
    final $$SpecimensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fatherId,
      referencedTable: $db.specimens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpecimensTableAnnotationComposer(
            $db: $db,
            $table: $db.specimens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TerrariumsTableAnnotationComposer get terrariumId {
    final $$TerrariumsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.terrariumId,
      referencedTable: $db.terrariums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TerrariumsTableAnnotationComposer(
            $db: $db,
            $table: $db.terrariums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> specimenLogEntriesRefs<T extends Object>(
    Expression<T> Function($$SpecimenLogEntriesTableAnnotationComposer a) f,
  ) {
    final $$SpecimenLogEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.specimenLogEntries,
          getReferencedColumn: (t) => t.specimenId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SpecimenLogEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.specimenLogEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SpecimensTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpecimensTable,
          Specimen,
          $$SpecimensTableFilterComposer,
          $$SpecimensTableOrderingComposer,
          $$SpecimensTableAnnotationComposer,
          $$SpecimensTableCreateCompanionBuilder,
          $$SpecimensTableUpdateCompanionBuilder,
          (Specimen, $$SpecimensTableReferences),
          Specimen,
          PrefetchHooks Function({
            bool motherId,
            bool fatherId,
            bool terrariumId,
            bool specimenLogEntriesRefs,
          })
        > {
  $$SpecimensTableTableManager(_$AppDatabase db, $SpecimensTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpecimensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpecimensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpecimensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String> species = const Value.absent(),
                Value<String> speciesIconKey = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<DateTime?> dateAcquired = const Value.absent(),
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<double?> weightGrams = const Value.absent(),
                Value<double?> sizeCm = const Value.absent(),
                Value<String?> lifeStage = const Value.absent(),
                Value<String?> beetleFamily = const Value.absent(),
                Value<int?> replenishIntervalDays = const Value.absent(),
                Value<DateTime?> lastReplenishedAt = const Value.absent(),
                Value<String?> replenishNote = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int?> motherId = const Value.absent(),
                Value<int?> fatherId = const Value.absent(),
                Value<int?> terrariumId = const Value.absent(),
                Value<int?> sourceBreedingEventId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => SpecimensCompanion(
                id: id,
                name: name,
                species: species,
                speciesIconKey: speciesIconKey,
                sex: sex,
                dateAcquired: dateAcquired,
                dateOfBirth: dateOfBirth,
                weightGrams: weightGrams,
                sizeCm: sizeCm,
                lifeStage: lifeStage,
                beetleFamily: beetleFamily,
                replenishIntervalDays: replenishIntervalDays,
                lastReplenishedAt: lastReplenishedAt,
                replenishNote: replenishNote,
                status: status,
                notes: notes,
                photoPath: photoPath,
                motherId: motherId,
                fatherId: fatherId,
                terrariumId: terrariumId,
                sourceBreedingEventId: sourceBreedingEventId,
                createdAt: createdAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                required String species,
                Value<String> speciesIconKey = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<DateTime?> dateAcquired = const Value.absent(),
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<double?> weightGrams = const Value.absent(),
                Value<double?> sizeCm = const Value.absent(),
                Value<String?> lifeStage = const Value.absent(),
                Value<String?> beetleFamily = const Value.absent(),
                Value<int?> replenishIntervalDays = const Value.absent(),
                Value<DateTime?> lastReplenishedAt = const Value.absent(),
                Value<String?> replenishNote = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int?> motherId = const Value.absent(),
                Value<int?> fatherId = const Value.absent(),
                Value<int?> terrariumId = const Value.absent(),
                Value<int?> sourceBreedingEventId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => SpecimensCompanion.insert(
                id: id,
                name: name,
                species: species,
                speciesIconKey: speciesIconKey,
                sex: sex,
                dateAcquired: dateAcquired,
                dateOfBirth: dateOfBirth,
                weightGrams: weightGrams,
                sizeCm: sizeCm,
                lifeStage: lifeStage,
                beetleFamily: beetleFamily,
                replenishIntervalDays: replenishIntervalDays,
                lastReplenishedAt: lastReplenishedAt,
                replenishNote: replenishNote,
                status: status,
                notes: notes,
                photoPath: photoPath,
                motherId: motherId,
                fatherId: fatherId,
                terrariumId: terrariumId,
                sourceBreedingEventId: sourceBreedingEventId,
                createdAt: createdAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SpecimensTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                motherId = false,
                fatherId = false,
                terrariumId = false,
                specimenLogEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (specimenLogEntriesRefs) db.specimenLogEntries,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (motherId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.motherId,
                                    referencedTable: $$SpecimensTableReferences
                                        ._motherIdTable(db),
                                    referencedColumn: $$SpecimensTableReferences
                                        ._motherIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (fatherId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.fatherId,
                                    referencedTable: $$SpecimensTableReferences
                                        ._fatherIdTable(db),
                                    referencedColumn: $$SpecimensTableReferences
                                        ._fatherIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (terrariumId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.terrariumId,
                                    referencedTable: $$SpecimensTableReferences
                                        ._terrariumIdTable(db),
                                    referencedColumn: $$SpecimensTableReferences
                                        ._terrariumIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (specimenLogEntriesRefs)
                        await $_getPrefetchedData<
                          Specimen,
                          $SpecimensTable,
                          SpecimenLogEntry
                        >(
                          currentTable: table,
                          referencedTable: $$SpecimensTableReferences
                              ._specimenLogEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SpecimensTableReferences(
                                db,
                                table,
                                p0,
                              ).specimenLogEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.specimenId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SpecimensTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpecimensTable,
      Specimen,
      $$SpecimensTableFilterComposer,
      $$SpecimensTableOrderingComposer,
      $$SpecimensTableAnnotationComposer,
      $$SpecimensTableCreateCompanionBuilder,
      $$SpecimensTableUpdateCompanionBuilder,
      (Specimen, $$SpecimensTableReferences),
      Specimen,
      PrefetchHooks Function({
        bool motherId,
        bool fatherId,
        bool terrariumId,
        bool specimenLogEntriesRefs,
      })
    >;
typedef $$BreedingEventsTableCreateCompanionBuilder =
    BreedingEventsCompanion Function({
      Value<int> id,
      required int motherId,
      required int fatherId,
      required DateTime date,
      Value<int?> clutchSize,
      Value<String> stage,
      Value<String?> notes,
      Value<int?> terrariumId,
      Value<int?> motherPreviousTerrariumId,
      Value<int?> fatherPreviousTerrariumId,
      Value<DateTime?> failedAt,
      Value<DateTime> createdAt,
    });
typedef $$BreedingEventsTableUpdateCompanionBuilder =
    BreedingEventsCompanion Function({
      Value<int> id,
      Value<int> motherId,
      Value<int> fatherId,
      Value<DateTime> date,
      Value<int?> clutchSize,
      Value<String> stage,
      Value<String?> notes,
      Value<int?> terrariumId,
      Value<int?> motherPreviousTerrariumId,
      Value<int?> fatherPreviousTerrariumId,
      Value<DateTime?> failedAt,
      Value<DateTime> createdAt,
    });

final class $$BreedingEventsTableReferences
    extends BaseReferences<_$AppDatabase, $BreedingEventsTable, BreedingEvent> {
  $$BreedingEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SpecimensTable _motherIdTable(_$AppDatabase db) =>
      db.specimens.createAlias('breeding_events__mother_id__specimens__id');

  $$SpecimensTableProcessedTableManager get motherId {
    final $_column = $_itemColumn<int>('mother_id')!;

    final manager = $$SpecimensTableTableManager(
      $_db,
      $_db.specimens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_motherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SpecimensTable _fatherIdTable(_$AppDatabase db) =>
      db.specimens.createAlias('breeding_events__father_id__specimens__id');

  $$SpecimensTableProcessedTableManager get fatherId {
    final $_column = $_itemColumn<int>('father_id')!;

    final manager = $$SpecimensTableTableManager(
      $_db,
      $_db.specimens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fatherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TerrariumsTable _terrariumIdTable(_$AppDatabase db) => db.terrariums
      .createAlias('breeding_events__terrarium_id__terrariums__id');

  $$TerrariumsTableProcessedTableManager? get terrariumId {
    final $_column = $_itemColumn<int>('terrarium_id');
    if ($_column == null) return null;
    final manager = $$TerrariumsTableTableManager(
      $_db,
      $_db.terrariums,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_terrariumIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BreedingLogEntriesTable, List<BreedingLogEntry>>
  _breedingLogEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.breedingLogEntries,
        aliasName:
            'breeding_events__id__breeding_log_entries__breeding_event_id',
      );

  $$BreedingLogEntriesTableProcessedTableManager get breedingLogEntriesRefs {
    final manager = $$BreedingLogEntriesTableTableManager(
      $_db,
      $_db.breedingLogEntries,
    ).filter((f) => f.breedingEventId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _breedingLogEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BreedingRemindersTable, List<BreedingReminder>>
  _breedingRemindersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.breedingReminders,
        aliasName: 'breeding_events__id__breeding_reminders__breeding_event_id',
      );

  $$BreedingRemindersTableProcessedTableManager get breedingRemindersRefs {
    final manager = $$BreedingRemindersTableTableManager(
      $_db,
      $_db.breedingReminders,
    ).filter((f) => f.breedingEventId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _breedingRemindersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BreedingEventsTableFilterComposer
    extends Composer<_$AppDatabase, $BreedingEventsTable> {
  $$BreedingEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clutchSize => $composableBuilder(
    column: $table.clutchSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get motherPreviousTerrariumId => $composableBuilder(
    column: $table.motherPreviousTerrariumId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fatherPreviousTerrariumId => $composableBuilder(
    column: $table.fatherPreviousTerrariumId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get failedAt => $composableBuilder(
    column: $table.failedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SpecimensTableFilterComposer get motherId {
    final $$SpecimensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motherId,
      referencedTable: $db.specimens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpecimensTableFilterComposer(
            $db: $db,
            $table: $db.specimens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SpecimensTableFilterComposer get fatherId {
    final $$SpecimensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fatherId,
      referencedTable: $db.specimens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpecimensTableFilterComposer(
            $db: $db,
            $table: $db.specimens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TerrariumsTableFilterComposer get terrariumId {
    final $$TerrariumsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.terrariumId,
      referencedTable: $db.terrariums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TerrariumsTableFilterComposer(
            $db: $db,
            $table: $db.terrariums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> breedingLogEntriesRefs(
    Expression<bool> Function($$BreedingLogEntriesTableFilterComposer f) f,
  ) {
    final $$BreedingLogEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.breedingLogEntries,
      getReferencedColumn: (t) => t.breedingEventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BreedingLogEntriesTableFilterComposer(
            $db: $db,
            $table: $db.breedingLogEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> breedingRemindersRefs(
    Expression<bool> Function($$BreedingRemindersTableFilterComposer f) f,
  ) {
    final $$BreedingRemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.breedingReminders,
      getReferencedColumn: (t) => t.breedingEventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BreedingRemindersTableFilterComposer(
            $db: $db,
            $table: $db.breedingReminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BreedingEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $BreedingEventsTable> {
  $$BreedingEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clutchSize => $composableBuilder(
    column: $table.clutchSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get motherPreviousTerrariumId => $composableBuilder(
    column: $table.motherPreviousTerrariumId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fatherPreviousTerrariumId => $composableBuilder(
    column: $table.fatherPreviousTerrariumId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get failedAt => $composableBuilder(
    column: $table.failedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SpecimensTableOrderingComposer get motherId {
    final $$SpecimensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motherId,
      referencedTable: $db.specimens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpecimensTableOrderingComposer(
            $db: $db,
            $table: $db.specimens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SpecimensTableOrderingComposer get fatherId {
    final $$SpecimensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fatherId,
      referencedTable: $db.specimens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpecimensTableOrderingComposer(
            $db: $db,
            $table: $db.specimens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TerrariumsTableOrderingComposer get terrariumId {
    final $$TerrariumsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.terrariumId,
      referencedTable: $db.terrariums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TerrariumsTableOrderingComposer(
            $db: $db,
            $table: $db.terrariums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BreedingEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BreedingEventsTable> {
  $$BreedingEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get clutchSize => $composableBuilder(
    column: $table.clutchSize,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get motherPreviousTerrariumId => $composableBuilder(
    column: $table.motherPreviousTerrariumId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fatherPreviousTerrariumId => $composableBuilder(
    column: $table.fatherPreviousTerrariumId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get failedAt =>
      $composableBuilder(column: $table.failedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SpecimensTableAnnotationComposer get motherId {
    final $$SpecimensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.motherId,
      referencedTable: $db.specimens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpecimensTableAnnotationComposer(
            $db: $db,
            $table: $db.specimens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SpecimensTableAnnotationComposer get fatherId {
    final $$SpecimensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fatherId,
      referencedTable: $db.specimens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpecimensTableAnnotationComposer(
            $db: $db,
            $table: $db.specimens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TerrariumsTableAnnotationComposer get terrariumId {
    final $$TerrariumsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.terrariumId,
      referencedTable: $db.terrariums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TerrariumsTableAnnotationComposer(
            $db: $db,
            $table: $db.terrariums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> breedingLogEntriesRefs<T extends Object>(
    Expression<T> Function($$BreedingLogEntriesTableAnnotationComposer a) f,
  ) {
    final $$BreedingLogEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.breedingLogEntries,
          getReferencedColumn: (t) => t.breedingEventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BreedingLogEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.breedingLogEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> breedingRemindersRefs<T extends Object>(
    Expression<T> Function($$BreedingRemindersTableAnnotationComposer a) f,
  ) {
    final $$BreedingRemindersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.breedingReminders,
          getReferencedColumn: (t) => t.breedingEventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BreedingRemindersTableAnnotationComposer(
                $db: $db,
                $table: $db.breedingReminders,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$BreedingEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BreedingEventsTable,
          BreedingEvent,
          $$BreedingEventsTableFilterComposer,
          $$BreedingEventsTableOrderingComposer,
          $$BreedingEventsTableAnnotationComposer,
          $$BreedingEventsTableCreateCompanionBuilder,
          $$BreedingEventsTableUpdateCompanionBuilder,
          (BreedingEvent, $$BreedingEventsTableReferences),
          BreedingEvent,
          PrefetchHooks Function({
            bool motherId,
            bool fatherId,
            bool terrariumId,
            bool breedingLogEntriesRefs,
            bool breedingRemindersRefs,
          })
        > {
  $$BreedingEventsTableTableManager(
    _$AppDatabase db,
    $BreedingEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BreedingEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BreedingEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BreedingEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> motherId = const Value.absent(),
                Value<int> fatherId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int?> clutchSize = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> terrariumId = const Value.absent(),
                Value<int?> motherPreviousTerrariumId = const Value.absent(),
                Value<int?> fatherPreviousTerrariumId = const Value.absent(),
                Value<DateTime?> failedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BreedingEventsCompanion(
                id: id,
                motherId: motherId,
                fatherId: fatherId,
                date: date,
                clutchSize: clutchSize,
                stage: stage,
                notes: notes,
                terrariumId: terrariumId,
                motherPreviousTerrariumId: motherPreviousTerrariumId,
                fatherPreviousTerrariumId: fatherPreviousTerrariumId,
                failedAt: failedAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int motherId,
                required int fatherId,
                required DateTime date,
                Value<int?> clutchSize = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> terrariumId = const Value.absent(),
                Value<int?> motherPreviousTerrariumId = const Value.absent(),
                Value<int?> fatherPreviousTerrariumId = const Value.absent(),
                Value<DateTime?> failedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BreedingEventsCompanion.insert(
                id: id,
                motherId: motherId,
                fatherId: fatherId,
                date: date,
                clutchSize: clutchSize,
                stage: stage,
                notes: notes,
                terrariumId: terrariumId,
                motherPreviousTerrariumId: motherPreviousTerrariumId,
                fatherPreviousTerrariumId: fatherPreviousTerrariumId,
                failedAt: failedAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BreedingEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                motherId = false,
                fatherId = false,
                terrariumId = false,
                breedingLogEntriesRefs = false,
                breedingRemindersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (breedingLogEntriesRefs) db.breedingLogEntries,
                    if (breedingRemindersRefs) db.breedingReminders,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (motherId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.motherId,
                                    referencedTable:
                                        $$BreedingEventsTableReferences
                                            ._motherIdTable(db),
                                    referencedColumn:
                                        $$BreedingEventsTableReferences
                                            ._motherIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (fatherId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.fatherId,
                                    referencedTable:
                                        $$BreedingEventsTableReferences
                                            ._fatherIdTable(db),
                                    referencedColumn:
                                        $$BreedingEventsTableReferences
                                            ._fatherIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (terrariumId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.terrariumId,
                                    referencedTable:
                                        $$BreedingEventsTableReferences
                                            ._terrariumIdTable(db),
                                    referencedColumn:
                                        $$BreedingEventsTableReferences
                                            ._terrariumIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (breedingLogEntriesRefs)
                        await $_getPrefetchedData<
                          BreedingEvent,
                          $BreedingEventsTable,
                          BreedingLogEntry
                        >(
                          currentTable: table,
                          referencedTable: $$BreedingEventsTableReferences
                              ._breedingLogEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BreedingEventsTableReferences(
                                db,
                                table,
                                p0,
                              ).breedingLogEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.breedingEventId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (breedingRemindersRefs)
                        await $_getPrefetchedData<
                          BreedingEvent,
                          $BreedingEventsTable,
                          BreedingReminder
                        >(
                          currentTable: table,
                          referencedTable: $$BreedingEventsTableReferences
                              ._breedingRemindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BreedingEventsTableReferences(
                                db,
                                table,
                                p0,
                              ).breedingRemindersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.breedingEventId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BreedingEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BreedingEventsTable,
      BreedingEvent,
      $$BreedingEventsTableFilterComposer,
      $$BreedingEventsTableOrderingComposer,
      $$BreedingEventsTableAnnotationComposer,
      $$BreedingEventsTableCreateCompanionBuilder,
      $$BreedingEventsTableUpdateCompanionBuilder,
      (BreedingEvent, $$BreedingEventsTableReferences),
      BreedingEvent,
      PrefetchHooks Function({
        bool motherId,
        bool fatherId,
        bool terrariumId,
        bool breedingLogEntriesRefs,
        bool breedingRemindersRefs,
      })
    >;
typedef $$BreedingLogEntriesTableCreateCompanionBuilder =
    BreedingLogEntriesCompanion Function({
      Value<int> id,
      required int breedingEventId,
      Value<DateTime> timestamp,
      Value<String?> note,
      Value<String?> stageAtEntry,
    });
typedef $$BreedingLogEntriesTableUpdateCompanionBuilder =
    BreedingLogEntriesCompanion Function({
      Value<int> id,
      Value<int> breedingEventId,
      Value<DateTime> timestamp,
      Value<String?> note,
      Value<String?> stageAtEntry,
    });

final class $$BreedingLogEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BreedingLogEntriesTable,
          BreedingLogEntry
        > {
  $$BreedingLogEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BreedingEventsTable _breedingEventIdTable(_$AppDatabase db) =>
      db.breedingEvents.createAlias(
        'breeding_log_entries__breeding_event_id__breeding_events__id',
      );

  $$BreedingEventsTableProcessedTableManager get breedingEventId {
    final $_column = $_itemColumn<int>('breeding_event_id')!;

    final manager = $$BreedingEventsTableTableManager(
      $_db,
      $_db.breedingEvents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_breedingEventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BreedingLogEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $BreedingLogEntriesTable> {
  $$BreedingLogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stageAtEntry => $composableBuilder(
    column: $table.stageAtEntry,
    builder: (column) => ColumnFilters(column),
  );

  $$BreedingEventsTableFilterComposer get breedingEventId {
    final $$BreedingEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.breedingEventId,
      referencedTable: $db.breedingEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BreedingEventsTableFilterComposer(
            $db: $db,
            $table: $db.breedingEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BreedingLogEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $BreedingLogEntriesTable> {
  $$BreedingLogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stageAtEntry => $composableBuilder(
    column: $table.stageAtEntry,
    builder: (column) => ColumnOrderings(column),
  );

  $$BreedingEventsTableOrderingComposer get breedingEventId {
    final $$BreedingEventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.breedingEventId,
      referencedTable: $db.breedingEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BreedingEventsTableOrderingComposer(
            $db: $db,
            $table: $db.breedingEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BreedingLogEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BreedingLogEntriesTable> {
  $$BreedingLogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get stageAtEntry => $composableBuilder(
    column: $table.stageAtEntry,
    builder: (column) => column,
  );

  $$BreedingEventsTableAnnotationComposer get breedingEventId {
    final $$BreedingEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.breedingEventId,
      referencedTable: $db.breedingEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BreedingEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.breedingEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BreedingLogEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BreedingLogEntriesTable,
          BreedingLogEntry,
          $$BreedingLogEntriesTableFilterComposer,
          $$BreedingLogEntriesTableOrderingComposer,
          $$BreedingLogEntriesTableAnnotationComposer,
          $$BreedingLogEntriesTableCreateCompanionBuilder,
          $$BreedingLogEntriesTableUpdateCompanionBuilder,
          (BreedingLogEntry, $$BreedingLogEntriesTableReferences),
          BreedingLogEntry,
          PrefetchHooks Function({bool breedingEventId})
        > {
  $$BreedingLogEntriesTableTableManager(
    _$AppDatabase db,
    $BreedingLogEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BreedingLogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BreedingLogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BreedingLogEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> breedingEventId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> stageAtEntry = const Value.absent(),
              }) => BreedingLogEntriesCompanion(
                id: id,
                breedingEventId: breedingEventId,
                timestamp: timestamp,
                note: note,
                stageAtEntry: stageAtEntry,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int breedingEventId,
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> stageAtEntry = const Value.absent(),
              }) => BreedingLogEntriesCompanion.insert(
                id: id,
                breedingEventId: breedingEventId,
                timestamp: timestamp,
                note: note,
                stageAtEntry: stageAtEntry,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BreedingLogEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({breedingEventId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (breedingEventId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.breedingEventId,
                                referencedTable:
                                    $$BreedingLogEntriesTableReferences
                                        ._breedingEventIdTable(db),
                                referencedColumn:
                                    $$BreedingLogEntriesTableReferences
                                        ._breedingEventIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BreedingLogEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BreedingLogEntriesTable,
      BreedingLogEntry,
      $$BreedingLogEntriesTableFilterComposer,
      $$BreedingLogEntriesTableOrderingComposer,
      $$BreedingLogEntriesTableAnnotationComposer,
      $$BreedingLogEntriesTableCreateCompanionBuilder,
      $$BreedingLogEntriesTableUpdateCompanionBuilder,
      (BreedingLogEntry, $$BreedingLogEntriesTableReferences),
      BreedingLogEntry,
      PrefetchHooks Function({bool breedingEventId})
    >;
typedef $$ToolsTableCreateCompanionBuilder =
    ToolsCompanion Function({
      Value<int> id,
      required String name,
      required double lengthCm,
      required double heightCm,
      required int colorArgb,
      required int shelfId,
      required int level,
      required double positionXCm,
      required int stackOrder,
      Value<int?> supportId,
      Value<String?> supportKind,
      Value<DateTime> createdAt,
    });
typedef $$ToolsTableUpdateCompanionBuilder =
    ToolsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> lengthCm,
      Value<double> heightCm,
      Value<int> colorArgb,
      Value<int> shelfId,
      Value<int> level,
      Value<double> positionXCm,
      Value<int> stackOrder,
      Value<int?> supportId,
      Value<String?> supportKind,
      Value<DateTime> createdAt,
    });

final class $$ToolsTableReferences
    extends BaseReferences<_$AppDatabase, $ToolsTable, Tool> {
  $$ToolsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ShelvesTable _shelfIdTable(_$AppDatabase db) =>
      db.shelves.createAlias('tools__shelf_id__shelves__id');

  $$ShelvesTableProcessedTableManager get shelfId {
    final $_column = $_itemColumn<int>('shelf_id')!;

    final manager = $$ShelvesTableTableManager(
      $_db,
      $_db.shelves,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shelfIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ToolsTableFilterComposer extends Composer<_$AppDatabase, $ToolsTable> {
  $$ToolsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lengthCm => $composableBuilder(
    column: $table.lengthCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorArgb => $composableBuilder(
    column: $table.colorArgb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get positionXCm => $composableBuilder(
    column: $table.positionXCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stackOrder => $composableBuilder(
    column: $table.stackOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get supportId => $composableBuilder(
    column: $table.supportId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supportKind => $composableBuilder(
    column: $table.supportKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ShelvesTableFilterComposer get shelfId {
    final $$ShelvesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableFilterComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ToolsTableOrderingComposer
    extends Composer<_$AppDatabase, $ToolsTable> {
  $$ToolsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lengthCm => $composableBuilder(
    column: $table.lengthCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorArgb => $composableBuilder(
    column: $table.colorArgb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get positionXCm => $composableBuilder(
    column: $table.positionXCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stackOrder => $composableBuilder(
    column: $table.stackOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get supportId => $composableBuilder(
    column: $table.supportId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supportKind => $composableBuilder(
    column: $table.supportKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ShelvesTableOrderingComposer get shelfId {
    final $$ShelvesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableOrderingComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ToolsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ToolsTable> {
  $$ToolsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get lengthCm =>
      $composableBuilder(column: $table.lengthCm, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<int> get colorArgb =>
      $composableBuilder(column: $table.colorArgb, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<double> get positionXCm => $composableBuilder(
    column: $table.positionXCm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stackOrder => $composableBuilder(
    column: $table.stackOrder,
    builder: (column) => column,
  );

  GeneratedColumn<int> get supportId =>
      $composableBuilder(column: $table.supportId, builder: (column) => column);

  GeneratedColumn<String> get supportKind => $composableBuilder(
    column: $table.supportKind,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ShelvesTableAnnotationComposer get shelfId {
    final $$ShelvesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableAnnotationComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ToolsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ToolsTable,
          Tool,
          $$ToolsTableFilterComposer,
          $$ToolsTableOrderingComposer,
          $$ToolsTableAnnotationComposer,
          $$ToolsTableCreateCompanionBuilder,
          $$ToolsTableUpdateCompanionBuilder,
          (Tool, $$ToolsTableReferences),
          Tool,
          PrefetchHooks Function({bool shelfId})
        > {
  $$ToolsTableTableManager(_$AppDatabase db, $ToolsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ToolsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ToolsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ToolsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> lengthCm = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<int> colorArgb = const Value.absent(),
                Value<int> shelfId = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<double> positionXCm = const Value.absent(),
                Value<int> stackOrder = const Value.absent(),
                Value<int?> supportId = const Value.absent(),
                Value<String?> supportKind = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ToolsCompanion(
                id: id,
                name: name,
                lengthCm: lengthCm,
                heightCm: heightCm,
                colorArgb: colorArgb,
                shelfId: shelfId,
                level: level,
                positionXCm: positionXCm,
                stackOrder: stackOrder,
                supportId: supportId,
                supportKind: supportKind,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double lengthCm,
                required double heightCm,
                required int colorArgb,
                required int shelfId,
                required int level,
                required double positionXCm,
                required int stackOrder,
                Value<int?> supportId = const Value.absent(),
                Value<String?> supportKind = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ToolsCompanion.insert(
                id: id,
                name: name,
                lengthCm: lengthCm,
                heightCm: heightCm,
                colorArgb: colorArgb,
                shelfId: shelfId,
                level: level,
                positionXCm: positionXCm,
                stackOrder: stackOrder,
                supportId: supportId,
                supportKind: supportKind,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ToolsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({shelfId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (shelfId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.shelfId,
                                referencedTable: $$ToolsTableReferences
                                    ._shelfIdTable(db),
                                referencedColumn: $$ToolsTableReferences
                                    ._shelfIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ToolsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ToolsTable,
      Tool,
      $$ToolsTableFilterComposer,
      $$ToolsTableOrderingComposer,
      $$ToolsTableAnnotationComposer,
      $$ToolsTableCreateCompanionBuilder,
      $$ToolsTableUpdateCompanionBuilder,
      (Tool, $$ToolsTableReferences),
      Tool,
      PrefetchHooks Function({bool shelfId})
    >;
typedef $$SpecimenLogEntriesTableCreateCompanionBuilder =
    SpecimenLogEntriesCompanion Function({
      Value<int> id,
      required int specimenId,
      Value<DateTime> timestamp,
      required String note,
    });
typedef $$SpecimenLogEntriesTableUpdateCompanionBuilder =
    SpecimenLogEntriesCompanion Function({
      Value<int> id,
      Value<int> specimenId,
      Value<DateTime> timestamp,
      Value<String> note,
    });

final class $$SpecimenLogEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SpecimenLogEntriesTable,
          SpecimenLogEntry
        > {
  $$SpecimenLogEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SpecimensTable _specimenIdTable(_$AppDatabase db) => db.specimens
      .createAlias('specimen_log_entries__specimen_id__specimens__id');

  $$SpecimensTableProcessedTableManager get specimenId {
    final $_column = $_itemColumn<int>('specimen_id')!;

    final manager = $$SpecimensTableTableManager(
      $_db,
      $_db.specimens,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_specimenIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SpecimenLogEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SpecimenLogEntriesTable> {
  $$SpecimenLogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$SpecimensTableFilterComposer get specimenId {
    final $$SpecimensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.specimenId,
      referencedTable: $db.specimens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpecimensTableFilterComposer(
            $db: $db,
            $table: $db.specimens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpecimenLogEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SpecimenLogEntriesTable> {
  $$SpecimenLogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$SpecimensTableOrderingComposer get specimenId {
    final $$SpecimensTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.specimenId,
      referencedTable: $db.specimens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpecimensTableOrderingComposer(
            $db: $db,
            $table: $db.specimens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpecimenLogEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpecimenLogEntriesTable> {
  $$SpecimenLogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$SpecimensTableAnnotationComposer get specimenId {
    final $$SpecimensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.specimenId,
      referencedTable: $db.specimens,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SpecimensTableAnnotationComposer(
            $db: $db,
            $table: $db.specimens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpecimenLogEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpecimenLogEntriesTable,
          SpecimenLogEntry,
          $$SpecimenLogEntriesTableFilterComposer,
          $$SpecimenLogEntriesTableOrderingComposer,
          $$SpecimenLogEntriesTableAnnotationComposer,
          $$SpecimenLogEntriesTableCreateCompanionBuilder,
          $$SpecimenLogEntriesTableUpdateCompanionBuilder,
          (SpecimenLogEntry, $$SpecimenLogEntriesTableReferences),
          SpecimenLogEntry,
          PrefetchHooks Function({bool specimenId})
        > {
  $$SpecimenLogEntriesTableTableManager(
    _$AppDatabase db,
    $SpecimenLogEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpecimenLogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpecimenLogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpecimenLogEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> specimenId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> note = const Value.absent(),
              }) => SpecimenLogEntriesCompanion(
                id: id,
                specimenId: specimenId,
                timestamp: timestamp,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int specimenId,
                Value<DateTime> timestamp = const Value.absent(),
                required String note,
              }) => SpecimenLogEntriesCompanion.insert(
                id: id,
                specimenId: specimenId,
                timestamp: timestamp,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SpecimenLogEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({specimenId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (specimenId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.specimenId,
                                referencedTable:
                                    $$SpecimenLogEntriesTableReferences
                                        ._specimenIdTable(db),
                                referencedColumn:
                                    $$SpecimenLogEntriesTableReferences
                                        ._specimenIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SpecimenLogEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpecimenLogEntriesTable,
      SpecimenLogEntry,
      $$SpecimenLogEntriesTableFilterComposer,
      $$SpecimenLogEntriesTableOrderingComposer,
      $$SpecimenLogEntriesTableAnnotationComposer,
      $$SpecimenLogEntriesTableCreateCompanionBuilder,
      $$SpecimenLogEntriesTableUpdateCompanionBuilder,
      (SpecimenLogEntry, $$SpecimenLogEntriesTableReferences),
      SpecimenLogEntry,
      PrefetchHooks Function({bool specimenId})
    >;
typedef $$ActivityLogEntriesTableCreateCompanionBuilder =
    ActivityLogEntriesCompanion Function({
      Value<int> id,
      required String type,
      Value<DateTime> timestamp,
      required String title,
      Value<int?> entityId,
      Value<String?> relatedIds,
    });
typedef $$ActivityLogEntriesTableUpdateCompanionBuilder =
    ActivityLogEntriesCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<DateTime> timestamp,
      Value<String> title,
      Value<int?> entityId,
      Value<String?> relatedIds,
    });

class $$ActivityLogEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityLogEntriesTable> {
  $$ActivityLogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatedIds => $composableBuilder(
    column: $table.relatedIds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivityLogEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityLogEntriesTable> {
  $$ActivityLogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedIds => $composableBuilder(
    column: $table.relatedIds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivityLogEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityLogEntriesTable> {
  $$ActivityLogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get relatedIds => $composableBuilder(
    column: $table.relatedIds,
    builder: (column) => column,
  );
}

class $$ActivityLogEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityLogEntriesTable,
          ActivityLogEntry,
          $$ActivityLogEntriesTableFilterComposer,
          $$ActivityLogEntriesTableOrderingComposer,
          $$ActivityLogEntriesTableAnnotationComposer,
          $$ActivityLogEntriesTableCreateCompanionBuilder,
          $$ActivityLogEntriesTableUpdateCompanionBuilder,
          (
            ActivityLogEntry,
            BaseReferences<
              _$AppDatabase,
              $ActivityLogEntriesTable,
              ActivityLogEntry
            >,
          ),
          ActivityLogEntry,
          PrefetchHooks Function()
        > {
  $$ActivityLogEntriesTableTableManager(
    _$AppDatabase db,
    $ActivityLogEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityLogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityLogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityLogEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int?> entityId = const Value.absent(),
                Value<String?> relatedIds = const Value.absent(),
              }) => ActivityLogEntriesCompanion(
                id: id,
                type: type,
                timestamp: timestamp,
                title: title,
                entityId: entityId,
                relatedIds: relatedIds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                Value<DateTime> timestamp = const Value.absent(),
                required String title,
                Value<int?> entityId = const Value.absent(),
                Value<String?> relatedIds = const Value.absent(),
              }) => ActivityLogEntriesCompanion.insert(
                id: id,
                type: type,
                timestamp: timestamp,
                title: title,
                entityId: entityId,
                relatedIds: relatedIds,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivityLogEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityLogEntriesTable,
      ActivityLogEntry,
      $$ActivityLogEntriesTableFilterComposer,
      $$ActivityLogEntriesTableOrderingComposer,
      $$ActivityLogEntriesTableAnnotationComposer,
      $$ActivityLogEntriesTableCreateCompanionBuilder,
      $$ActivityLogEntriesTableUpdateCompanionBuilder,
      (
        ActivityLogEntry,
        BaseReferences<
          _$AppDatabase,
          $ActivityLogEntriesTable,
          ActivityLogEntry
        >,
      ),
      ActivityLogEntry,
      PrefetchHooks Function()
    >;
typedef $$BreedingRemindersTableCreateCompanionBuilder =
    BreedingRemindersCompanion Function({
      Value<int> id,
      required int breedingEventId,
      required DateTime dueDate,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
    });
typedef $$BreedingRemindersTableUpdateCompanionBuilder =
    BreedingRemindersCompanion Function({
      Value<int> id,
      Value<int> breedingEventId,
      Value<DateTime> dueDate,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
    });

final class $$BreedingRemindersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BreedingRemindersTable,
          BreedingReminder
        > {
  $$BreedingRemindersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BreedingEventsTable _breedingEventIdTable(_$AppDatabase db) =>
      db.breedingEvents.createAlias(
        'breeding_reminders__breeding_event_id__breeding_events__id',
      );

  $$BreedingEventsTableProcessedTableManager get breedingEventId {
    final $_column = $_itemColumn<int>('breeding_event_id')!;

    final manager = $$BreedingEventsTableTableManager(
      $_db,
      $_db.breedingEvents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_breedingEventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BreedingRemindersTableFilterComposer
    extends Composer<_$AppDatabase, $BreedingRemindersTable> {
  $$BreedingRemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BreedingEventsTableFilterComposer get breedingEventId {
    final $$BreedingEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.breedingEventId,
      referencedTable: $db.breedingEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BreedingEventsTableFilterComposer(
            $db: $db,
            $table: $db.breedingEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BreedingRemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $BreedingRemindersTable> {
  $$BreedingRemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BreedingEventsTableOrderingComposer get breedingEventId {
    final $$BreedingEventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.breedingEventId,
      referencedTable: $db.breedingEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BreedingEventsTableOrderingComposer(
            $db: $db,
            $table: $db.breedingEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BreedingRemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $BreedingRemindersTable> {
  $$BreedingRemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$BreedingEventsTableAnnotationComposer get breedingEventId {
    final $$BreedingEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.breedingEventId,
      referencedTable: $db.breedingEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BreedingEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.breedingEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BreedingRemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BreedingRemindersTable,
          BreedingReminder,
          $$BreedingRemindersTableFilterComposer,
          $$BreedingRemindersTableOrderingComposer,
          $$BreedingRemindersTableAnnotationComposer,
          $$BreedingRemindersTableCreateCompanionBuilder,
          $$BreedingRemindersTableUpdateCompanionBuilder,
          (BreedingReminder, $$BreedingRemindersTableReferences),
          BreedingReminder,
          PrefetchHooks Function({bool breedingEventId})
        > {
  $$BreedingRemindersTableTableManager(
    _$AppDatabase db,
    $BreedingRemindersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BreedingRemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BreedingRemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BreedingRemindersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> breedingEventId = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => BreedingRemindersCompanion(
                id: id,
                breedingEventId: breedingEventId,
                dueDate: dueDate,
                note: note,
                createdAt: createdAt,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int breedingEventId,
                required DateTime dueDate,
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => BreedingRemindersCompanion.insert(
                id: id,
                breedingEventId: breedingEventId,
                dueDate: dueDate,
                note: note,
                createdAt: createdAt,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BreedingRemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({breedingEventId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (breedingEventId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.breedingEventId,
                                referencedTable:
                                    $$BreedingRemindersTableReferences
                                        ._breedingEventIdTable(db),
                                referencedColumn:
                                    $$BreedingRemindersTableReferences
                                        ._breedingEventIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BreedingRemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BreedingRemindersTable,
      BreedingReminder,
      $$BreedingRemindersTableFilterComposer,
      $$BreedingRemindersTableOrderingComposer,
      $$BreedingRemindersTableAnnotationComposer,
      $$BreedingRemindersTableCreateCompanionBuilder,
      $$BreedingRemindersTableUpdateCompanionBuilder,
      (BreedingReminder, $$BreedingRemindersTableReferences),
      BreedingReminder,
      PrefetchHooks Function({bool breedingEventId})
    >;
typedef $$SpeciesInfosTableCreateCompanionBuilder =
    SpeciesInfosCompanion Function({
      Value<int> id,
      required String speciesName,
      Value<String?> description,
      Value<String?> specialNotes,
      Value<String?> region,
      Value<String?> lengthRangeText,
      Value<String?> temperatureRangeText,
    });
typedef $$SpeciesInfosTableUpdateCompanionBuilder =
    SpeciesInfosCompanion Function({
      Value<int> id,
      Value<String> speciesName,
      Value<String?> description,
      Value<String?> specialNotes,
      Value<String?> region,
      Value<String?> lengthRangeText,
      Value<String?> temperatureRangeText,
    });

class $$SpeciesInfosTableFilterComposer
    extends Composer<_$AppDatabase, $SpeciesInfosTable> {
  $$SpeciesInfosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speciesName => $composableBuilder(
    column: $table.speciesName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialNotes => $composableBuilder(
    column: $table.specialNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lengthRangeText => $composableBuilder(
    column: $table.lengthRangeText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get temperatureRangeText => $composableBuilder(
    column: $table.temperatureRangeText,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SpeciesInfosTableOrderingComposer
    extends Composer<_$AppDatabase, $SpeciesInfosTable> {
  $$SpeciesInfosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speciesName => $composableBuilder(
    column: $table.speciesName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialNotes => $composableBuilder(
    column: $table.specialNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lengthRangeText => $composableBuilder(
    column: $table.lengthRangeText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get temperatureRangeText => $composableBuilder(
    column: $table.temperatureRangeText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpeciesInfosTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpeciesInfosTable> {
  $$SpeciesInfosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get speciesName => $composableBuilder(
    column: $table.speciesName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get specialNotes => $composableBuilder(
    column: $table.specialNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get lengthRangeText => $composableBuilder(
    column: $table.lengthRangeText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get temperatureRangeText => $composableBuilder(
    column: $table.temperatureRangeText,
    builder: (column) => column,
  );
}

class $$SpeciesInfosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpeciesInfosTable,
          SpeciesInfo,
          $$SpeciesInfosTableFilterComposer,
          $$SpeciesInfosTableOrderingComposer,
          $$SpeciesInfosTableAnnotationComposer,
          $$SpeciesInfosTableCreateCompanionBuilder,
          $$SpeciesInfosTableUpdateCompanionBuilder,
          (
            SpeciesInfo,
            BaseReferences<_$AppDatabase, $SpeciesInfosTable, SpeciesInfo>,
          ),
          SpeciesInfo,
          PrefetchHooks Function()
        > {
  $$SpeciesInfosTableTableManager(_$AppDatabase db, $SpeciesInfosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpeciesInfosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpeciesInfosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpeciesInfosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> speciesName = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> specialNotes = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<String?> lengthRangeText = const Value.absent(),
                Value<String?> temperatureRangeText = const Value.absent(),
              }) => SpeciesInfosCompanion(
                id: id,
                speciesName: speciesName,
                description: description,
                specialNotes: specialNotes,
                region: region,
                lengthRangeText: lengthRangeText,
                temperatureRangeText: temperatureRangeText,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String speciesName,
                Value<String?> description = const Value.absent(),
                Value<String?> specialNotes = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<String?> lengthRangeText = const Value.absent(),
                Value<String?> temperatureRangeText = const Value.absent(),
              }) => SpeciesInfosCompanion.insert(
                id: id,
                speciesName: speciesName,
                description: description,
                specialNotes: specialNotes,
                region: region,
                lengthRangeText: lengthRangeText,
                temperatureRangeText: temperatureRangeText,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SpeciesInfosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpeciesInfosTable,
      SpeciesInfo,
      $$SpeciesInfosTableFilterComposer,
      $$SpeciesInfosTableOrderingComposer,
      $$SpeciesInfosTableAnnotationComposer,
      $$SpeciesInfosTableCreateCompanionBuilder,
      $$SpeciesInfosTableUpdateCompanionBuilder,
      (
        SpeciesInfo,
        BaseReferences<_$AppDatabase, $SpeciesInfosTable, SpeciesInfo>,
      ),
      SpeciesInfo,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShelvesTableTableManager get shelves =>
      $$ShelvesTableTableManager(_db, _db.shelves);
  $$TerrariumsTableTableManager get terrariums =>
      $$TerrariumsTableTableManager(_db, _db.terrariums);
  $$SpecimensTableTableManager get specimens =>
      $$SpecimensTableTableManager(_db, _db.specimens);
  $$BreedingEventsTableTableManager get breedingEvents =>
      $$BreedingEventsTableTableManager(_db, _db.breedingEvents);
  $$BreedingLogEntriesTableTableManager get breedingLogEntries =>
      $$BreedingLogEntriesTableTableManager(_db, _db.breedingLogEntries);
  $$ToolsTableTableManager get tools =>
      $$ToolsTableTableManager(_db, _db.tools);
  $$SpecimenLogEntriesTableTableManager get specimenLogEntries =>
      $$SpecimenLogEntriesTableTableManager(_db, _db.specimenLogEntries);
  $$ActivityLogEntriesTableTableManager get activityLogEntries =>
      $$ActivityLogEntriesTableTableManager(_db, _db.activityLogEntries);
  $$BreedingRemindersTableTableManager get breedingReminders =>
      $$BreedingRemindersTableTableManager(_db, _db.breedingReminders);
  $$SpeciesInfosTableTableManager get speciesInfos =>
      $$SpeciesInfosTableTableManager(_db, _db.speciesInfos);
}
