// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BusinessesTable extends Businesses
    with TableInfo<$BusinessesTable, Business> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BusinessesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _businessIdMeta =
      const VerificationMeta('businessId');
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
      'business_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
      'gstin', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stateCodeMeta =
      const VerificationMeta('stateCode');
  @override
  late final GeneratedColumn<String> stateCode = GeneratedColumn<String>(
      'state_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _upiIdMeta = const VerificationMeta('upiId');
  @override
  late final GeneratedColumn<String> upiId = GeneratedColumn<String>(
      'upi_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _invoiceTermsMeta =
      const VerificationMeta('invoiceTerms');
  @override
  late final GeneratedColumn<String> invoiceTerms = GeneratedColumn<String>(
      'invoice_terms', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  static const VerificationMeta _serverSeqMeta =
      const VerificationMeta('serverSeq');
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
      'server_seq', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        businessId,
        name,
        gstin,
        stateCode,
        address,
        upiId,
        invoiceTerms,
        createdAt,
        updatedAt,
        serverSeq
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'businesses';
  @override
  VerificationContext validateIntegrity(Insertable<Business> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
          _businessIdMeta,
          businessId.isAcceptableOrUnknown(
              data['business_id']!, _businessIdMeta));
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('gstin')) {
      context.handle(
          _gstinMeta, gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta));
    }
    if (data.containsKey('state_code')) {
      context.handle(_stateCodeMeta,
          stateCode.isAcceptableOrUnknown(data['state_code']!, _stateCodeMeta));
    } else if (isInserting) {
      context.missing(_stateCodeMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('upi_id')) {
      context.handle(
          _upiIdMeta, upiId.isAcceptableOrUnknown(data['upi_id']!, _upiIdMeta));
    }
    if (data.containsKey('invoice_terms')) {
      context.handle(
          _invoiceTermsMeta,
          invoiceTerms.isAcceptableOrUnknown(
              data['invoice_terms']!, _invoiceTermsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('server_seq')) {
      context.handle(_serverSeqMeta,
          serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Business map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Business(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      businessId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      gstin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gstin']),
      stateCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state_code'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      upiId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}upi_id']),
      invoiceTerms: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_terms']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      serverSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_seq']),
    );
  }

  @override
  $BusinessesTable createAlias(String alias) {
    return $BusinessesTable(attachedDatabase, alias);
  }
}

class Business extends DataClass implements Insertable<Business> {
  final String id;
  final String businessId;
  final String name;
  final String? gstin;
  final String stateCode;
  final String address;
  final String? upiId;
  final String? invoiceTerms;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? serverSeq;
  const Business(
      {required this.id,
      required this.businessId,
      required this.name,
      this.gstin,
      required this.stateCode,
      required this.address,
      this.upiId,
      this.invoiceTerms,
      required this.createdAt,
      required this.updatedAt,
      this.serverSeq});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || gstin != null) {
      map['gstin'] = Variable<String>(gstin);
    }
    map['state_code'] = Variable<String>(stateCode);
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || upiId != null) {
      map['upi_id'] = Variable<String>(upiId);
    }
    if (!nullToAbsent || invoiceTerms != null) {
      map['invoice_terms'] = Variable<String>(invoiceTerms);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    return map;
  }

  BusinessesCompanion toCompanion(bool nullToAbsent) {
    return BusinessesCompanion(
      id: Value(id),
      businessId: Value(businessId),
      name: Value(name),
      gstin:
          gstin == null && nullToAbsent ? const Value.absent() : Value(gstin),
      stateCode: Value(stateCode),
      address: Value(address),
      upiId:
          upiId == null && nullToAbsent ? const Value.absent() : Value(upiId),
      invoiceTerms: invoiceTerms == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceTerms),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
    );
  }

  factory Business.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Business(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      name: serializer.fromJson<String>(json['name']),
      gstin: serializer.fromJson<String?>(json['gstin']),
      stateCode: serializer.fromJson<String>(json['stateCode']),
      address: serializer.fromJson<String>(json['address']),
      upiId: serializer.fromJson<String?>(json['upiId']),
      invoiceTerms: serializer.fromJson<String?>(json['invoiceTerms']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'name': serializer.toJson<String>(name),
      'gstin': serializer.toJson<String?>(gstin),
      'stateCode': serializer.toJson<String>(stateCode),
      'address': serializer.toJson<String>(address),
      'upiId': serializer.toJson<String?>(upiId),
      'invoiceTerms': serializer.toJson<String?>(invoiceTerms),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'serverSeq': serializer.toJson<int?>(serverSeq),
    };
  }

  Business copyWith(
          {String? id,
          String? businessId,
          String? name,
          Value<String?> gstin = const Value.absent(),
          String? stateCode,
          String? address,
          Value<String?> upiId = const Value.absent(),
          Value<String?> invoiceTerms = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<int?> serverSeq = const Value.absent()}) =>
      Business(
        id: id ?? this.id,
        businessId: businessId ?? this.businessId,
        name: name ?? this.name,
        gstin: gstin.present ? gstin.value : this.gstin,
        stateCode: stateCode ?? this.stateCode,
        address: address ?? this.address,
        upiId: upiId.present ? upiId.value : this.upiId,
        invoiceTerms:
            invoiceTerms.present ? invoiceTerms.value : this.invoiceTerms,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
      );
  Business copyWithCompanion(BusinessesCompanion data) {
    return Business(
      id: data.id.present ? data.id.value : this.id,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
      name: data.name.present ? data.name.value : this.name,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      stateCode: data.stateCode.present ? data.stateCode.value : this.stateCode,
      address: data.address.present ? data.address.value : this.address,
      upiId: data.upiId.present ? data.upiId.value : this.upiId,
      invoiceTerms: data.invoiceTerms.present
          ? data.invoiceTerms.value
          : this.invoiceTerms,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Business(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('gstin: $gstin, ')
          ..write('stateCode: $stateCode, ')
          ..write('address: $address, ')
          ..write('upiId: $upiId, ')
          ..write('invoiceTerms: $invoiceTerms, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverSeq: $serverSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, businessId, name, gstin, stateCode,
      address, upiId, invoiceTerms, createdAt, updatedAt, serverSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Business &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.name == this.name &&
          other.gstin == this.gstin &&
          other.stateCode == this.stateCode &&
          other.address == this.address &&
          other.upiId == this.upiId &&
          other.invoiceTerms == this.invoiceTerms &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverSeq == this.serverSeq);
}

class BusinessesCompanion extends UpdateCompanion<Business> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> name;
  final Value<String?> gstin;
  final Value<String> stateCode;
  final Value<String> address;
  final Value<String?> upiId;
  final Value<String?> invoiceTerms;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int?> serverSeq;
  final Value<int> rowid;
  const BusinessesCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.name = const Value.absent(),
    this.gstin = const Value.absent(),
    this.stateCode = const Value.absent(),
    this.address = const Value.absent(),
    this.upiId = const Value.absent(),
    this.invoiceTerms = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BusinessesCompanion.insert({
    required String id,
    required String businessId,
    required String name,
    this.gstin = const Value.absent(),
    required String stateCode,
    required String address,
    this.upiId = const Value.absent(),
    this.invoiceTerms = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        businessId = Value(businessId),
        name = Value(name),
        stateCode = Value(stateCode),
        address = Value(address),
        createdAt = Value(createdAt);
  static Insertable<Business> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? name,
    Expression<String>? gstin,
    Expression<String>? stateCode,
    Expression<String>? address,
    Expression<String>? upiId,
    Expression<String>? invoiceTerms,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? serverSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (name != null) 'name': name,
      if (gstin != null) 'gstin': gstin,
      if (stateCode != null) 'state_code': stateCode,
      if (address != null) 'address': address,
      if (upiId != null) 'upi_id': upiId,
      if (invoiceTerms != null) 'invoice_terms': invoiceTerms,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BusinessesCompanion copyWith(
      {Value<String>? id,
      Value<String>? businessId,
      Value<String>? name,
      Value<String?>? gstin,
      Value<String>? stateCode,
      Value<String>? address,
      Value<String?>? upiId,
      Value<String?>? invoiceTerms,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int?>? serverSeq,
      Value<int>? rowid}) {
    return BusinessesCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      gstin: gstin ?? this.gstin,
      stateCode: stateCode ?? this.stateCode,
      address: address ?? this.address,
      upiId: upiId ?? this.upiId,
      invoiceTerms: invoiceTerms ?? this.invoiceTerms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverSeq: serverSeq ?? this.serverSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (stateCode.present) {
      map['state_code'] = Variable<String>(stateCode.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (upiId.present) {
      map['upi_id'] = Variable<String>(upiId.value);
    }
    if (invoiceTerms.present) {
      map['invoice_terms'] = Variable<String>(invoiceTerms.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BusinessesCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('gstin: $gstin, ')
          ..write('stateCode: $stateCode, ')
          ..write('address: $address, ')
          ..write('upiId: $upiId, ')
          ..write('invoiceTerms: $invoiceTerms, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _businessIdMeta =
      const VerificationMeta('businessId');
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
      'business_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _seriesPrefixMeta =
      const VerificationMeta('seriesPrefix');
  @override
  late final GeneratedColumn<String> seriesPrefix = GeneratedColumn<String>(
      'series_prefix', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  static const VerificationMeta _serverSeqMeta =
      const VerificationMeta('serverSeq');
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
      'server_seq', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, businessId, name, seriesPrefix, createdAt, updatedAt, serverSeq];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(Insertable<Device> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
          _businessIdMeta,
          businessId.isAcceptableOrUnknown(
              data['business_id']!, _businessIdMeta));
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('series_prefix')) {
      context.handle(
          _seriesPrefixMeta,
          seriesPrefix.isAcceptableOrUnknown(
              data['series_prefix']!, _seriesPrefixMeta));
    } else if (isInserting) {
      context.missing(_seriesPrefixMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('server_seq')) {
      context.handle(_serverSeqMeta,
          serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      businessId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      seriesPrefix: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}series_prefix'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      serverSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_seq']),
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final String id;
  final String businessId;
  final String name;
  final String seriesPrefix;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? serverSeq;
  const Device(
      {required this.id,
      required this.businessId,
      required this.name,
      required this.seriesPrefix,
      required this.createdAt,
      required this.updatedAt,
      this.serverSeq});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['name'] = Variable<String>(name);
    map['series_prefix'] = Variable<String>(seriesPrefix);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      businessId: Value(businessId),
      name: Value(name),
      seriesPrefix: Value(seriesPrefix),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
    );
  }

  factory Device.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      name: serializer.fromJson<String>(json['name']),
      seriesPrefix: serializer.fromJson<String>(json['seriesPrefix']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'name': serializer.toJson<String>(name),
      'seriesPrefix': serializer.toJson<String>(seriesPrefix),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'serverSeq': serializer.toJson<int?>(serverSeq),
    };
  }

  Device copyWith(
          {String? id,
          String? businessId,
          String? name,
          String? seriesPrefix,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<int?> serverSeq = const Value.absent()}) =>
      Device(
        id: id ?? this.id,
        businessId: businessId ?? this.businessId,
        name: name ?? this.name,
        seriesPrefix: seriesPrefix ?? this.seriesPrefix,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
      );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
      name: data.name.present ? data.name.value : this.name,
      seriesPrefix: data.seriesPrefix.present
          ? data.seriesPrefix.value
          : this.seriesPrefix,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('seriesPrefix: $seriesPrefix, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverSeq: $serverSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, businessId, name, seriesPrefix, createdAt, updatedAt, serverSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.name == this.name &&
          other.seriesPrefix == this.seriesPrefix &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverSeq == this.serverSeq);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> name;
  final Value<String> seriesPrefix;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int?> serverSeq;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.name = const Value.absent(),
    this.seriesPrefix = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    required String businessId,
    required String name,
    required String seriesPrefix,
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        businessId = Value(businessId),
        name = Value(name),
        seriesPrefix = Value(seriesPrefix),
        createdAt = Value(createdAt);
  static Insertable<Device> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? name,
    Expression<String>? seriesPrefix,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? serverSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (name != null) 'name': name,
      if (seriesPrefix != null) 'series_prefix': seriesPrefix,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith(
      {Value<String>? id,
      Value<String>? businessId,
      Value<String>? name,
      Value<String>? seriesPrefix,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int?>? serverSeq,
      Value<int>? rowid}) {
    return DevicesCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      seriesPrefix: seriesPrefix ?? this.seriesPrefix,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverSeq: serverSeq ?? this.serverSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (seriesPrefix.present) {
      map['series_prefix'] = Variable<String>(seriesPrefix.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('seriesPrefix: $seriesPrefix, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartiesTable extends Parties with TableInfo<$PartiesTable, Party> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _businessIdMeta =
      const VerificationMeta('businessId');
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
      'business_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
      'gstin', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stateCodeMeta =
      const VerificationMeta('stateCode');
  @override
  late final GeneratedColumn<String> stateCode = GeneratedColumn<String>(
      'state_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _creditLimitPaiseMeta =
      const VerificationMeta('creditLimitPaise');
  @override
  late final GeneratedColumn<int> creditLimitPaise = GeneratedColumn<int>(
      'credit_limit_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  static const VerificationMeta _archivedAtMeta =
      const VerificationMeta('archivedAt');
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
      'archived_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _serverSeqMeta =
      const VerificationMeta('serverSeq');
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
      'server_seq', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        businessId,
        name,
        phone,
        gstin,
        stateCode,
        creditLimitPaise,
        createdAt,
        updatedAt,
        archivedAt,
        serverSeq
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parties';
  @override
  VerificationContext validateIntegrity(Insertable<Party> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
          _businessIdMeta,
          businessId.isAcceptableOrUnknown(
              data['business_id']!, _businessIdMeta));
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('gstin')) {
      context.handle(
          _gstinMeta, gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta));
    }
    if (data.containsKey('state_code')) {
      context.handle(_stateCodeMeta,
          stateCode.isAcceptableOrUnknown(data['state_code']!, _stateCodeMeta));
    } else if (isInserting) {
      context.missing(_stateCodeMeta);
    }
    if (data.containsKey('credit_limit_paise')) {
      context.handle(
          _creditLimitPaiseMeta,
          creditLimitPaise.isAcceptableOrUnknown(
              data['credit_limit_paise']!, _creditLimitPaiseMeta));
    } else if (isInserting) {
      context.missing(_creditLimitPaiseMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('archived_at')) {
      context.handle(
          _archivedAtMeta,
          archivedAt.isAcceptableOrUnknown(
              data['archived_at']!, _archivedAtMeta));
    }
    if (data.containsKey('server_seq')) {
      context.handle(_serverSeqMeta,
          serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Party map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Party(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      businessId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      gstin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gstin']),
      stateCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state_code'])!,
      creditLimitPaise: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}credit_limit_paise'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      archivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}archived_at']),
      serverSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_seq']),
    );
  }

  @override
  $PartiesTable createAlias(String alias) {
    return $PartiesTable(attachedDatabase, alias);
  }
}

class Party extends DataClass implements Insertable<Party> {
  final String id;
  final String businessId;
  final String name;
  final String phone;
  final String? gstin;
  final String stateCode;
  final int creditLimitPaise;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  final int? serverSeq;
  const Party(
      {required this.id,
      required this.businessId,
      required this.name,
      required this.phone,
      this.gstin,
      required this.stateCode,
      required this.creditLimitPaise,
      required this.createdAt,
      required this.updatedAt,
      this.archivedAt,
      this.serverSeq});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || gstin != null) {
      map['gstin'] = Variable<String>(gstin);
    }
    map['state_code'] = Variable<String>(stateCode);
    map['credit_limit_paise'] = Variable<int>(creditLimitPaise);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    return map;
  }

  PartiesCompanion toCompanion(bool nullToAbsent) {
    return PartiesCompanion(
      id: Value(id),
      businessId: Value(businessId),
      name: Value(name),
      phone: Value(phone),
      gstin:
          gstin == null && nullToAbsent ? const Value.absent() : Value(gstin),
      stateCode: Value(stateCode),
      creditLimitPaise: Value(creditLimitPaise),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
    );
  }

  factory Party.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Party(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      gstin: serializer.fromJson<String?>(json['gstin']),
      stateCode: serializer.fromJson<String>(json['stateCode']),
      creditLimitPaise: serializer.fromJson<int>(json['creditLimitPaise']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'gstin': serializer.toJson<String?>(gstin),
      'stateCode': serializer.toJson<String>(stateCode),
      'creditLimitPaise': serializer.toJson<int>(creditLimitPaise),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'serverSeq': serializer.toJson<int?>(serverSeq),
    };
  }

  Party copyWith(
          {String? id,
          String? businessId,
          String? name,
          String? phone,
          Value<String?> gstin = const Value.absent(),
          String? stateCode,
          int? creditLimitPaise,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> archivedAt = const Value.absent(),
          Value<int?> serverSeq = const Value.absent()}) =>
      Party(
        id: id ?? this.id,
        businessId: businessId ?? this.businessId,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        gstin: gstin.present ? gstin.value : this.gstin,
        stateCode: stateCode ?? this.stateCode,
        creditLimitPaise: creditLimitPaise ?? this.creditLimitPaise,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
        serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
      );
  Party copyWithCompanion(PartiesCompanion data) {
    return Party(
      id: data.id.present ? data.id.value : this.id,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      stateCode: data.stateCode.present ? data.stateCode.value : this.stateCode,
      creditLimitPaise: data.creditLimitPaise.present
          ? data.creditLimitPaise.value
          : this.creditLimitPaise,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt:
          data.archivedAt.present ? data.archivedAt.value : this.archivedAt,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Party(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('gstin: $gstin, ')
          ..write('stateCode: $stateCode, ')
          ..write('creditLimitPaise: $creditLimitPaise, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('serverSeq: $serverSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, businessId, name, phone, gstin, stateCode,
      creditLimitPaise, createdAt, updatedAt, archivedAt, serverSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Party &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.gstin == this.gstin &&
          other.stateCode == this.stateCode &&
          other.creditLimitPaise == this.creditLimitPaise &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt &&
          other.serverSeq == this.serverSeq);
}

class PartiesCompanion extends UpdateCompanion<Party> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> name;
  final Value<String> phone;
  final Value<String?> gstin;
  final Value<String> stateCode;
  final Value<int> creditLimitPaise;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<int?> serverSeq;
  final Value<int> rowid;
  const PartiesCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.gstin = const Value.absent(),
    this.stateCode = const Value.absent(),
    this.creditLimitPaise = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartiesCompanion.insert({
    required String id,
    required String businessId,
    required String name,
    required String phone,
    this.gstin = const Value.absent(),
    required String stateCode,
    required int creditLimitPaise,
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        businessId = Value(businessId),
        name = Value(name),
        phone = Value(phone),
        stateCode = Value(stateCode),
        creditLimitPaise = Value(creditLimitPaise),
        createdAt = Value(createdAt);
  static Insertable<Party> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? gstin,
    Expression<String>? stateCode,
    Expression<int>? creditLimitPaise,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? serverSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (gstin != null) 'gstin': gstin,
      if (stateCode != null) 'state_code': stateCode,
      if (creditLimitPaise != null) 'credit_limit_paise': creditLimitPaise,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartiesCompanion copyWith(
      {Value<String>? id,
      Value<String>? businessId,
      Value<String>? name,
      Value<String>? phone,
      Value<String?>? gstin,
      Value<String>? stateCode,
      Value<int>? creditLimitPaise,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? archivedAt,
      Value<int?>? serverSeq,
      Value<int>? rowid}) {
    return PartiesCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      gstin: gstin ?? this.gstin,
      stateCode: stateCode ?? this.stateCode,
      creditLimitPaise: creditLimitPaise ?? this.creditLimitPaise,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      serverSeq: serverSeq ?? this.serverSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (stateCode.present) {
      map['state_code'] = Variable<String>(stateCode.value);
    }
    if (creditLimitPaise.present) {
      map['credit_limit_paise'] = Variable<int>(creditLimitPaise.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartiesCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('gstin: $gstin, ')
          ..write('stateCode: $stateCode, ')
          ..write('creditLimitPaise: $creditLimitPaise, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _businessIdMeta =
      const VerificationMeta('businessId');
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
      'business_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _hsnMeta = const VerificationMeta('hsn');
  @override
  late final GeneratedColumn<String> hsn = GeneratedColumn<String>(
      'hsn', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gstRateBpMeta =
      const VerificationMeta('gstRateBp');
  @override
  late final GeneratedColumn<int> gstRateBp = GeneratedColumn<int>(
      'gst_rate_bp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pricePaiseMeta =
      const VerificationMeta('pricePaise');
  @override
  late final GeneratedColumn<int> pricePaise = GeneratedColumn<int>(
      'price_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _costPaiseMeta =
      const VerificationMeta('costPaise');
  @override
  late final GeneratedColumn<int> costPaise = GeneratedColumn<int>(
      'cost_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _trackStockMeta =
      const VerificationMeta('trackStock');
  @override
  late final GeneratedColumn<bool> trackStock = GeneratedColumn<bool>(
      'track_stock', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("track_stock" IN (0, 1))'));
  static const VerificationMeta _reorderLevelMeta =
      const VerificationMeta('reorderLevel');
  @override
  late final GeneratedColumn<int> reorderLevel = GeneratedColumn<int>(
      'reorder_level', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  static const VerificationMeta _serverSeqMeta =
      const VerificationMeta('serverSeq');
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
      'server_seq', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        businessId,
        name,
        barcode,
        hsn,
        gstRateBp,
        pricePaise,
        costPaise,
        trackStock,
        reorderLevel,
        createdAt,
        updatedAt,
        serverSeq
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<Product> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
          _businessIdMeta,
          businessId.isAcceptableOrUnknown(
              data['business_id']!, _businessIdMeta));
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    }
    if (data.containsKey('hsn')) {
      context.handle(
          _hsnMeta, hsn.isAcceptableOrUnknown(data['hsn']!, _hsnMeta));
    } else if (isInserting) {
      context.missing(_hsnMeta);
    }
    if (data.containsKey('gst_rate_bp')) {
      context.handle(
          _gstRateBpMeta,
          gstRateBp.isAcceptableOrUnknown(
              data['gst_rate_bp']!, _gstRateBpMeta));
    } else if (isInserting) {
      context.missing(_gstRateBpMeta);
    }
    if (data.containsKey('price_paise')) {
      context.handle(
          _pricePaiseMeta,
          pricePaise.isAcceptableOrUnknown(
              data['price_paise']!, _pricePaiseMeta));
    } else if (isInserting) {
      context.missing(_pricePaiseMeta);
    }
    if (data.containsKey('cost_paise')) {
      context.handle(_costPaiseMeta,
          costPaise.isAcceptableOrUnknown(data['cost_paise']!, _costPaiseMeta));
    } else if (isInserting) {
      context.missing(_costPaiseMeta);
    }
    if (data.containsKey('track_stock')) {
      context.handle(
          _trackStockMeta,
          trackStock.isAcceptableOrUnknown(
              data['track_stock']!, _trackStockMeta));
    } else if (isInserting) {
      context.missing(_trackStockMeta);
    }
    if (data.containsKey('reorder_level')) {
      context.handle(
          _reorderLevelMeta,
          reorderLevel.isAcceptableOrUnknown(
              data['reorder_level']!, _reorderLevelMeta));
    } else if (isInserting) {
      context.missing(_reorderLevelMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('server_seq')) {
      context.handle(_serverSeqMeta,
          serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      businessId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode']),
      hsn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hsn'])!,
      gstRateBp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gst_rate_bp'])!,
      pricePaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}price_paise'])!,
      costPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cost_paise'])!,
      trackStock: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}track_stock'])!,
      reorderLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reorder_level'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      serverSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_seq']),
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final String id;
  final String businessId;
  final String name;
  final String? barcode;
  final String hsn;
  final int gstRateBp;
  final int pricePaise;
  final int costPaise;
  final bool trackStock;
  final int reorderLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? serverSeq;
  const Product(
      {required this.id,
      required this.businessId,
      required this.name,
      this.barcode,
      required this.hsn,
      required this.gstRateBp,
      required this.pricePaise,
      required this.costPaise,
      required this.trackStock,
      required this.reorderLevel,
      required this.createdAt,
      required this.updatedAt,
      this.serverSeq});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['hsn'] = Variable<String>(hsn);
    map['gst_rate_bp'] = Variable<int>(gstRateBp);
    map['price_paise'] = Variable<int>(pricePaise);
    map['cost_paise'] = Variable<int>(costPaise);
    map['track_stock'] = Variable<bool>(trackStock);
    map['reorder_level'] = Variable<int>(reorderLevel);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      businessId: Value(businessId),
      name: Value(name),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      hsn: Value(hsn),
      gstRateBp: Value(gstRateBp),
      pricePaise: Value(pricePaise),
      costPaise: Value(costPaise),
      trackStock: Value(trackStock),
      reorderLevel: Value(reorderLevel),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      name: serializer.fromJson<String>(json['name']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      hsn: serializer.fromJson<String>(json['hsn']),
      gstRateBp: serializer.fromJson<int>(json['gstRateBp']),
      pricePaise: serializer.fromJson<int>(json['pricePaise']),
      costPaise: serializer.fromJson<int>(json['costPaise']),
      trackStock: serializer.fromJson<bool>(json['trackStock']),
      reorderLevel: serializer.fromJson<int>(json['reorderLevel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'name': serializer.toJson<String>(name),
      'barcode': serializer.toJson<String?>(barcode),
      'hsn': serializer.toJson<String>(hsn),
      'gstRateBp': serializer.toJson<int>(gstRateBp),
      'pricePaise': serializer.toJson<int>(pricePaise),
      'costPaise': serializer.toJson<int>(costPaise),
      'trackStock': serializer.toJson<bool>(trackStock),
      'reorderLevel': serializer.toJson<int>(reorderLevel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'serverSeq': serializer.toJson<int?>(serverSeq),
    };
  }

  Product copyWith(
          {String? id,
          String? businessId,
          String? name,
          Value<String?> barcode = const Value.absent(),
          String? hsn,
          int? gstRateBp,
          int? pricePaise,
          int? costPaise,
          bool? trackStock,
          int? reorderLevel,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<int?> serverSeq = const Value.absent()}) =>
      Product(
        id: id ?? this.id,
        businessId: businessId ?? this.businessId,
        name: name ?? this.name,
        barcode: barcode.present ? barcode.value : this.barcode,
        hsn: hsn ?? this.hsn,
        gstRateBp: gstRateBp ?? this.gstRateBp,
        pricePaise: pricePaise ?? this.pricePaise,
        costPaise: costPaise ?? this.costPaise,
        trackStock: trackStock ?? this.trackStock,
        reorderLevel: reorderLevel ?? this.reorderLevel,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
      );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
      name: data.name.present ? data.name.value : this.name,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      hsn: data.hsn.present ? data.hsn.value : this.hsn,
      gstRateBp: data.gstRateBp.present ? data.gstRateBp.value : this.gstRateBp,
      pricePaise:
          data.pricePaise.present ? data.pricePaise.value : this.pricePaise,
      costPaise: data.costPaise.present ? data.costPaise.value : this.costPaise,
      trackStock:
          data.trackStock.present ? data.trackStock.value : this.trackStock,
      reorderLevel: data.reorderLevel.present
          ? data.reorderLevel.value
          : this.reorderLevel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('barcode: $barcode, ')
          ..write('hsn: $hsn, ')
          ..write('gstRateBp: $gstRateBp, ')
          ..write('pricePaise: $pricePaise, ')
          ..write('costPaise: $costPaise, ')
          ..write('trackStock: $trackStock, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverSeq: $serverSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      businessId,
      name,
      barcode,
      hsn,
      gstRateBp,
      pricePaise,
      costPaise,
      trackStock,
      reorderLevel,
      createdAt,
      updatedAt,
      serverSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.name == this.name &&
          other.barcode == this.barcode &&
          other.hsn == this.hsn &&
          other.gstRateBp == this.gstRateBp &&
          other.pricePaise == this.pricePaise &&
          other.costPaise == this.costPaise &&
          other.trackStock == this.trackStock &&
          other.reorderLevel == this.reorderLevel &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverSeq == this.serverSeq);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> name;
  final Value<String?> barcode;
  final Value<String> hsn;
  final Value<int> gstRateBp;
  final Value<int> pricePaise;
  final Value<int> costPaise;
  final Value<bool> trackStock;
  final Value<int> reorderLevel;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int?> serverSeq;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.name = const Value.absent(),
    this.barcode = const Value.absent(),
    this.hsn = const Value.absent(),
    this.gstRateBp = const Value.absent(),
    this.pricePaise = const Value.absent(),
    this.costPaise = const Value.absent(),
    this.trackStock = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String businessId,
    required String name,
    this.barcode = const Value.absent(),
    required String hsn,
    required int gstRateBp,
    required int pricePaise,
    required int costPaise,
    required bool trackStock,
    required int reorderLevel,
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        businessId = Value(businessId),
        name = Value(name),
        hsn = Value(hsn),
        gstRateBp = Value(gstRateBp),
        pricePaise = Value(pricePaise),
        costPaise = Value(costPaise),
        trackStock = Value(trackStock),
        reorderLevel = Value(reorderLevel),
        createdAt = Value(createdAt);
  static Insertable<Product> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? name,
    Expression<String>? barcode,
    Expression<String>? hsn,
    Expression<int>? gstRateBp,
    Expression<int>? pricePaise,
    Expression<int>? costPaise,
    Expression<bool>? trackStock,
    Expression<int>? reorderLevel,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? serverSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (name != null) 'name': name,
      if (barcode != null) 'barcode': barcode,
      if (hsn != null) 'hsn': hsn,
      if (gstRateBp != null) 'gst_rate_bp': gstRateBp,
      if (pricePaise != null) 'price_paise': pricePaise,
      if (costPaise != null) 'cost_paise': costPaise,
      if (trackStock != null) 'track_stock': trackStock,
      if (reorderLevel != null) 'reorder_level': reorderLevel,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith(
      {Value<String>? id,
      Value<String>? businessId,
      Value<String>? name,
      Value<String?>? barcode,
      Value<String>? hsn,
      Value<int>? gstRateBp,
      Value<int>? pricePaise,
      Value<int>? costPaise,
      Value<bool>? trackStock,
      Value<int>? reorderLevel,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int?>? serverSeq,
      Value<int>? rowid}) {
    return ProductsCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      hsn: hsn ?? this.hsn,
      gstRateBp: gstRateBp ?? this.gstRateBp,
      pricePaise: pricePaise ?? this.pricePaise,
      costPaise: costPaise ?? this.costPaise,
      trackStock: trackStock ?? this.trackStock,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverSeq: serverSeq ?? this.serverSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (hsn.present) {
      map['hsn'] = Variable<String>(hsn.value);
    }
    if (gstRateBp.present) {
      map['gst_rate_bp'] = Variable<int>(gstRateBp.value);
    }
    if (pricePaise.present) {
      map['price_paise'] = Variable<int>(pricePaise.value);
    }
    if (costPaise.present) {
      map['cost_paise'] = Variable<int>(costPaise.value);
    }
    if (trackStock.present) {
      map['track_stock'] = Variable<bool>(trackStock.value);
    }
    if (reorderLevel.present) {
      map['reorder_level'] = Variable<int>(reorderLevel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('barcode: $barcode, ')
          ..write('hsn: $hsn, ')
          ..write('gstRateBp: $gstRateBp, ')
          ..write('pricePaise: $pricePaise, ')
          ..write('costPaise: $costPaise, ')
          ..write('trackStock: $trackStock, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentSeriesTable extends DocumentSeries
    with TableInfo<$DocumentSeriesTable, DocumentSeriesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentSeriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _businessIdMeta =
      const VerificationMeta('businessId');
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
      'business_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _docTypeMeta =
      const VerificationMeta('docType');
  @override
  late final GeneratedColumn<String> docType = GeneratedColumn<String>(
      'doc_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _financialYearMeta =
      const VerificationMeta('financialYear');
  @override
  late final GeneratedColumn<String> financialYear = GeneratedColumn<String>(
      'financial_year', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nextNumberMeta =
      const VerificationMeta('nextNumber');
  @override
  late final GeneratedColumn<int> nextNumber = GeneratedColumn<int>(
      'next_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, businessId, deviceId, docType, financialYear, nextNumber, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_series';
  @override
  VerificationContext validateIntegrity(Insertable<DocumentSeriesData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
          _businessIdMeta,
          businessId.isAcceptableOrUnknown(
              data['business_id']!, _businessIdMeta));
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('doc_type')) {
      context.handle(_docTypeMeta,
          docType.isAcceptableOrUnknown(data['doc_type']!, _docTypeMeta));
    } else if (isInserting) {
      context.missing(_docTypeMeta);
    }
    if (data.containsKey('financial_year')) {
      context.handle(
          _financialYearMeta,
          financialYear.isAcceptableOrUnknown(
              data['financial_year']!, _financialYearMeta));
    } else if (isInserting) {
      context.missing(_financialYearMeta);
    }
    if (data.containsKey('next_number')) {
      context.handle(
          _nextNumberMeta,
          nextNumber.isAcceptableOrUnknown(
              data['next_number']!, _nextNumberMeta));
    } else if (isInserting) {
      context.missing(_nextNumberMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentSeriesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentSeriesData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      businessId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      docType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}doc_type'])!,
      financialYear: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}financial_year'])!,
      nextNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}next_number'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DocumentSeriesTable createAlias(String alias) {
    return $DocumentSeriesTable(attachedDatabase, alias);
  }
}

class DocumentSeriesData extends DataClass
    implements Insertable<DocumentSeriesData> {
  final String id;
  final String businessId;
  final String deviceId;
  final String docType;
  final String financialYear;
  final int nextNumber;
  final DateTime createdAt;
  const DocumentSeriesData(
      {required this.id,
      required this.businessId,
      required this.deviceId,
      required this.docType,
      required this.financialYear,
      required this.nextNumber,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['device_id'] = Variable<String>(deviceId);
    map['doc_type'] = Variable<String>(docType);
    map['financial_year'] = Variable<String>(financialYear);
    map['next_number'] = Variable<int>(nextNumber);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DocumentSeriesCompanion toCompanion(bool nullToAbsent) {
    return DocumentSeriesCompanion(
      id: Value(id),
      businessId: Value(businessId),
      deviceId: Value(deviceId),
      docType: Value(docType),
      financialYear: Value(financialYear),
      nextNumber: Value(nextNumber),
      createdAt: Value(createdAt),
    );
  }

  factory DocumentSeriesData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentSeriesData(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      docType: serializer.fromJson<String>(json['docType']),
      financialYear: serializer.fromJson<String>(json['financialYear']),
      nextNumber: serializer.fromJson<int>(json['nextNumber']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'deviceId': serializer.toJson<String>(deviceId),
      'docType': serializer.toJson<String>(docType),
      'financialYear': serializer.toJson<String>(financialYear),
      'nextNumber': serializer.toJson<int>(nextNumber),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DocumentSeriesData copyWith(
          {String? id,
          String? businessId,
          String? deviceId,
          String? docType,
          String? financialYear,
          int? nextNumber,
          DateTime? createdAt}) =>
      DocumentSeriesData(
        id: id ?? this.id,
        businessId: businessId ?? this.businessId,
        deviceId: deviceId ?? this.deviceId,
        docType: docType ?? this.docType,
        financialYear: financialYear ?? this.financialYear,
        nextNumber: nextNumber ?? this.nextNumber,
        createdAt: createdAt ?? this.createdAt,
      );
  DocumentSeriesData copyWithCompanion(DocumentSeriesCompanion data) {
    return DocumentSeriesData(
      id: data.id.present ? data.id.value : this.id,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      docType: data.docType.present ? data.docType.value : this.docType,
      financialYear: data.financialYear.present
          ? data.financialYear.value
          : this.financialYear,
      nextNumber:
          data.nextNumber.present ? data.nextNumber.value : this.nextNumber,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentSeriesData(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('deviceId: $deviceId, ')
          ..write('docType: $docType, ')
          ..write('financialYear: $financialYear, ')
          ..write('nextNumber: $nextNumber, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, businessId, deviceId, docType, financialYear, nextNumber, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentSeriesData &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.deviceId == this.deviceId &&
          other.docType == this.docType &&
          other.financialYear == this.financialYear &&
          other.nextNumber == this.nextNumber &&
          other.createdAt == this.createdAt);
}

class DocumentSeriesCompanion extends UpdateCompanion<DocumentSeriesData> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> deviceId;
  final Value<String> docType;
  final Value<String> financialYear;
  final Value<int> nextNumber;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DocumentSeriesCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.docType = const Value.absent(),
    this.financialYear = const Value.absent(),
    this.nextNumber = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentSeriesCompanion.insert({
    required String id,
    required String businessId,
    required String deviceId,
    required String docType,
    required String financialYear,
    required int nextNumber,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        businessId = Value(businessId),
        deviceId = Value(deviceId),
        docType = Value(docType),
        financialYear = Value(financialYear),
        nextNumber = Value(nextNumber),
        createdAt = Value(createdAt);
  static Insertable<DocumentSeriesData> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? deviceId,
    Expression<String>? docType,
    Expression<String>? financialYear,
    Expression<int>? nextNumber,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (deviceId != null) 'device_id': deviceId,
      if (docType != null) 'doc_type': docType,
      if (financialYear != null) 'financial_year': financialYear,
      if (nextNumber != null) 'next_number': nextNumber,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentSeriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? businessId,
      Value<String>? deviceId,
      Value<String>? docType,
      Value<String>? financialYear,
      Value<int>? nextNumber,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return DocumentSeriesCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      deviceId: deviceId ?? this.deviceId,
      docType: docType ?? this.docType,
      financialYear: financialYear ?? this.financialYear,
      nextNumber: nextNumber ?? this.nextNumber,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (docType.present) {
      map['doc_type'] = Variable<String>(docType.value);
    }
    if (financialYear.present) {
      map['financial_year'] = Variable<String>(financialYear.value);
    }
    if (nextNumber.present) {
      map['next_number'] = Variable<int>(nextNumber.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentSeriesCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('deviceId: $deviceId, ')
          ..write('docType: $docType, ')
          ..write('financialYear: $financialYear, ')
          ..write('nextNumber: $nextNumber, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentsTable extends Documents
    with TableInfo<$DocumentsTable, Document> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _businessIdMeta =
      const VerificationMeta('businessId');
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
      'business_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _docTypeMeta =
      const VerificationMeta('docType');
  @override
  late final GeneratedColumn<String> docType = GeneratedColumn<String>(
      'doc_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
      'number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _partyIdMeta =
      const VerificationMeta('partyId');
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
      'party_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _issuedAtMeta =
      const VerificationMeta('issuedAt');
  @override
  late final GeneratedColumn<DateTime> issuedAt = GeneratedColumn<DateTime>(
      'issued_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taxablePaiseMeta =
      const VerificationMeta('taxablePaise');
  @override
  late final GeneratedColumn<int> taxablePaise = GeneratedColumn<int>(
      'taxable_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cgstPaiseMeta =
      const VerificationMeta('cgstPaise');
  @override
  late final GeneratedColumn<int> cgstPaise = GeneratedColumn<int>(
      'cgst_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sgstPaiseMeta =
      const VerificationMeta('sgstPaise');
  @override
  late final GeneratedColumn<int> sgstPaise = GeneratedColumn<int>(
      'sgst_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _igstPaiseMeta =
      const VerificationMeta('igstPaise');
  @override
  late final GeneratedColumn<int> igstPaise = GeneratedColumn<int>(
      'igst_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _roundOffPaiseMeta =
      const VerificationMeta('roundOffPaise');
  @override
  late final GeneratedColumn<int> roundOffPaise = GeneratedColumn<int>(
      'round_off_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalPaiseMeta =
      const VerificationMeta('totalPaise');
  @override
  late final GeneratedColumn<int> totalPaise = GeneratedColumn<int>(
      'total_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _snapshotJsonMeta =
      const VerificationMeta('snapshotJson');
  @override
  late final GeneratedColumn<String> snapshotJson = GeneratedColumn<String>(
      'snapshot_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _refDocumentIdMeta =
      const VerificationMeta('refDocumentId');
  @override
  late final GeneratedColumn<String> refDocumentId = GeneratedColumn<String>(
      'ref_document_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _serverSeqMeta =
      const VerificationMeta('serverSeq');
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
      'server_seq', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        businessId,
        deviceId,
        docType,
        number,
        partyId,
        issuedAt,
        status,
        taxablePaise,
        cgstPaise,
        sgstPaise,
        igstPaise,
        roundOffPaise,
        totalPaise,
        snapshotJson,
        refDocumentId,
        createdAt,
        serverSeq
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  VerificationContext validateIntegrity(Insertable<Document> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
          _businessIdMeta,
          businessId.isAcceptableOrUnknown(
              data['business_id']!, _businessIdMeta));
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('doc_type')) {
      context.handle(_docTypeMeta,
          docType.isAcceptableOrUnknown(data['doc_type']!, _docTypeMeta));
    } else if (isInserting) {
      context.missing(_docTypeMeta);
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(_partyIdMeta,
          partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta));
    }
    if (data.containsKey('issued_at')) {
      context.handle(_issuedAtMeta,
          issuedAt.isAcceptableOrUnknown(data['issued_at']!, _issuedAtMeta));
    } else if (isInserting) {
      context.missing(_issuedAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('taxable_paise')) {
      context.handle(
          _taxablePaiseMeta,
          taxablePaise.isAcceptableOrUnknown(
              data['taxable_paise']!, _taxablePaiseMeta));
    } else if (isInserting) {
      context.missing(_taxablePaiseMeta);
    }
    if (data.containsKey('cgst_paise')) {
      context.handle(_cgstPaiseMeta,
          cgstPaise.isAcceptableOrUnknown(data['cgst_paise']!, _cgstPaiseMeta));
    } else if (isInserting) {
      context.missing(_cgstPaiseMeta);
    }
    if (data.containsKey('sgst_paise')) {
      context.handle(_sgstPaiseMeta,
          sgstPaise.isAcceptableOrUnknown(data['sgst_paise']!, _sgstPaiseMeta));
    } else if (isInserting) {
      context.missing(_sgstPaiseMeta);
    }
    if (data.containsKey('igst_paise')) {
      context.handle(_igstPaiseMeta,
          igstPaise.isAcceptableOrUnknown(data['igst_paise']!, _igstPaiseMeta));
    } else if (isInserting) {
      context.missing(_igstPaiseMeta);
    }
    if (data.containsKey('round_off_paise')) {
      context.handle(
          _roundOffPaiseMeta,
          roundOffPaise.isAcceptableOrUnknown(
              data['round_off_paise']!, _roundOffPaiseMeta));
    } else if (isInserting) {
      context.missing(_roundOffPaiseMeta);
    }
    if (data.containsKey('total_paise')) {
      context.handle(
          _totalPaiseMeta,
          totalPaise.isAcceptableOrUnknown(
              data['total_paise']!, _totalPaiseMeta));
    } else if (isInserting) {
      context.missing(_totalPaiseMeta);
    }
    if (data.containsKey('snapshot_json')) {
      context.handle(
          _snapshotJsonMeta,
          snapshotJson.isAcceptableOrUnknown(
              data['snapshot_json']!, _snapshotJsonMeta));
    } else if (isInserting) {
      context.missing(_snapshotJsonMeta);
    }
    if (data.containsKey('ref_document_id')) {
      context.handle(
          _refDocumentIdMeta,
          refDocumentId.isAcceptableOrUnknown(
              data['ref_document_id']!, _refDocumentIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('server_seq')) {
      context.handle(_serverSeqMeta,
          serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Document map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Document(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      businessId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      docType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}doc_type'])!,
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}number'])!,
      partyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}party_id']),
      issuedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}issued_at'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      taxablePaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}taxable_paise'])!,
      cgstPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cgst_paise'])!,
      sgstPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sgst_paise'])!,
      igstPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}igst_paise'])!,
      roundOffPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}round_off_paise'])!,
      totalPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_paise'])!,
      snapshotJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}snapshot_json'])!,
      refDocumentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ref_document_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      serverSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_seq']),
    );
  }

  @override
  $DocumentsTable createAlias(String alias) {
    return $DocumentsTable(attachedDatabase, alias);
  }
}

class Document extends DataClass implements Insertable<Document> {
  final String id;
  final String businessId;
  final String deviceId;
  final String docType;
  final String number;
  final String? partyId;
  final DateTime issuedAt;
  final String status;
  final int taxablePaise;
  final int cgstPaise;
  final int sgstPaise;
  final int igstPaise;
  final int roundOffPaise;
  final int totalPaise;
  final String snapshotJson;
  final String? refDocumentId;
  final DateTime createdAt;
  final int? serverSeq;
  const Document(
      {required this.id,
      required this.businessId,
      required this.deviceId,
      required this.docType,
      required this.number,
      this.partyId,
      required this.issuedAt,
      required this.status,
      required this.taxablePaise,
      required this.cgstPaise,
      required this.sgstPaise,
      required this.igstPaise,
      required this.roundOffPaise,
      required this.totalPaise,
      required this.snapshotJson,
      this.refDocumentId,
      required this.createdAt,
      this.serverSeq});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['device_id'] = Variable<String>(deviceId);
    map['doc_type'] = Variable<String>(docType);
    map['number'] = Variable<String>(number);
    if (!nullToAbsent || partyId != null) {
      map['party_id'] = Variable<String>(partyId);
    }
    map['issued_at'] = Variable<DateTime>(issuedAt);
    map['status'] = Variable<String>(status);
    map['taxable_paise'] = Variable<int>(taxablePaise);
    map['cgst_paise'] = Variable<int>(cgstPaise);
    map['sgst_paise'] = Variable<int>(sgstPaise);
    map['igst_paise'] = Variable<int>(igstPaise);
    map['round_off_paise'] = Variable<int>(roundOffPaise);
    map['total_paise'] = Variable<int>(totalPaise);
    map['snapshot_json'] = Variable<String>(snapshotJson);
    if (!nullToAbsent || refDocumentId != null) {
      map['ref_document_id'] = Variable<String>(refDocumentId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      id: Value(id),
      businessId: Value(businessId),
      deviceId: Value(deviceId),
      docType: Value(docType),
      number: Value(number),
      partyId: partyId == null && nullToAbsent
          ? const Value.absent()
          : Value(partyId),
      issuedAt: Value(issuedAt),
      status: Value(status),
      taxablePaise: Value(taxablePaise),
      cgstPaise: Value(cgstPaise),
      sgstPaise: Value(sgstPaise),
      igstPaise: Value(igstPaise),
      roundOffPaise: Value(roundOffPaise),
      totalPaise: Value(totalPaise),
      snapshotJson: Value(snapshotJson),
      refDocumentId: refDocumentId == null && nullToAbsent
          ? const Value.absent()
          : Value(refDocumentId),
      createdAt: Value(createdAt),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
    );
  }

  factory Document.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Document(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      docType: serializer.fromJson<String>(json['docType']),
      number: serializer.fromJson<String>(json['number']),
      partyId: serializer.fromJson<String?>(json['partyId']),
      issuedAt: serializer.fromJson<DateTime>(json['issuedAt']),
      status: serializer.fromJson<String>(json['status']),
      taxablePaise: serializer.fromJson<int>(json['taxablePaise']),
      cgstPaise: serializer.fromJson<int>(json['cgstPaise']),
      sgstPaise: serializer.fromJson<int>(json['sgstPaise']),
      igstPaise: serializer.fromJson<int>(json['igstPaise']),
      roundOffPaise: serializer.fromJson<int>(json['roundOffPaise']),
      totalPaise: serializer.fromJson<int>(json['totalPaise']),
      snapshotJson: serializer.fromJson<String>(json['snapshotJson']),
      refDocumentId: serializer.fromJson<String?>(json['refDocumentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'deviceId': serializer.toJson<String>(deviceId),
      'docType': serializer.toJson<String>(docType),
      'number': serializer.toJson<String>(number),
      'partyId': serializer.toJson<String?>(partyId),
      'issuedAt': serializer.toJson<DateTime>(issuedAt),
      'status': serializer.toJson<String>(status),
      'taxablePaise': serializer.toJson<int>(taxablePaise),
      'cgstPaise': serializer.toJson<int>(cgstPaise),
      'sgstPaise': serializer.toJson<int>(sgstPaise),
      'igstPaise': serializer.toJson<int>(igstPaise),
      'roundOffPaise': serializer.toJson<int>(roundOffPaise),
      'totalPaise': serializer.toJson<int>(totalPaise),
      'snapshotJson': serializer.toJson<String>(snapshotJson),
      'refDocumentId': serializer.toJson<String?>(refDocumentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'serverSeq': serializer.toJson<int?>(serverSeq),
    };
  }

  Document copyWith(
          {String? id,
          String? businessId,
          String? deviceId,
          String? docType,
          String? number,
          Value<String?> partyId = const Value.absent(),
          DateTime? issuedAt,
          String? status,
          int? taxablePaise,
          int? cgstPaise,
          int? sgstPaise,
          int? igstPaise,
          int? roundOffPaise,
          int? totalPaise,
          String? snapshotJson,
          Value<String?> refDocumentId = const Value.absent(),
          DateTime? createdAt,
          Value<int?> serverSeq = const Value.absent()}) =>
      Document(
        id: id ?? this.id,
        businessId: businessId ?? this.businessId,
        deviceId: deviceId ?? this.deviceId,
        docType: docType ?? this.docType,
        number: number ?? this.number,
        partyId: partyId.present ? partyId.value : this.partyId,
        issuedAt: issuedAt ?? this.issuedAt,
        status: status ?? this.status,
        taxablePaise: taxablePaise ?? this.taxablePaise,
        cgstPaise: cgstPaise ?? this.cgstPaise,
        sgstPaise: sgstPaise ?? this.sgstPaise,
        igstPaise: igstPaise ?? this.igstPaise,
        roundOffPaise: roundOffPaise ?? this.roundOffPaise,
        totalPaise: totalPaise ?? this.totalPaise,
        snapshotJson: snapshotJson ?? this.snapshotJson,
        refDocumentId:
            refDocumentId.present ? refDocumentId.value : this.refDocumentId,
        createdAt: createdAt ?? this.createdAt,
        serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
      );
  Document copyWithCompanion(DocumentsCompanion data) {
    return Document(
      id: data.id.present ? data.id.value : this.id,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      docType: data.docType.present ? data.docType.value : this.docType,
      number: data.number.present ? data.number.value : this.number,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      issuedAt: data.issuedAt.present ? data.issuedAt.value : this.issuedAt,
      status: data.status.present ? data.status.value : this.status,
      taxablePaise: data.taxablePaise.present
          ? data.taxablePaise.value
          : this.taxablePaise,
      cgstPaise: data.cgstPaise.present ? data.cgstPaise.value : this.cgstPaise,
      sgstPaise: data.sgstPaise.present ? data.sgstPaise.value : this.sgstPaise,
      igstPaise: data.igstPaise.present ? data.igstPaise.value : this.igstPaise,
      roundOffPaise: data.roundOffPaise.present
          ? data.roundOffPaise.value
          : this.roundOffPaise,
      totalPaise:
          data.totalPaise.present ? data.totalPaise.value : this.totalPaise,
      snapshotJson: data.snapshotJson.present
          ? data.snapshotJson.value
          : this.snapshotJson,
      refDocumentId: data.refDocumentId.present
          ? data.refDocumentId.value
          : this.refDocumentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Document(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('deviceId: $deviceId, ')
          ..write('docType: $docType, ')
          ..write('number: $number, ')
          ..write('partyId: $partyId, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('status: $status, ')
          ..write('taxablePaise: $taxablePaise, ')
          ..write('cgstPaise: $cgstPaise, ')
          ..write('sgstPaise: $sgstPaise, ')
          ..write('igstPaise: $igstPaise, ')
          ..write('roundOffPaise: $roundOffPaise, ')
          ..write('totalPaise: $totalPaise, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('refDocumentId: $refDocumentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverSeq: $serverSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      businessId,
      deviceId,
      docType,
      number,
      partyId,
      issuedAt,
      status,
      taxablePaise,
      cgstPaise,
      sgstPaise,
      igstPaise,
      roundOffPaise,
      totalPaise,
      snapshotJson,
      refDocumentId,
      createdAt,
      serverSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Document &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.deviceId == this.deviceId &&
          other.docType == this.docType &&
          other.number == this.number &&
          other.partyId == this.partyId &&
          other.issuedAt == this.issuedAt &&
          other.status == this.status &&
          other.taxablePaise == this.taxablePaise &&
          other.cgstPaise == this.cgstPaise &&
          other.sgstPaise == this.sgstPaise &&
          other.igstPaise == this.igstPaise &&
          other.roundOffPaise == this.roundOffPaise &&
          other.totalPaise == this.totalPaise &&
          other.snapshotJson == this.snapshotJson &&
          other.refDocumentId == this.refDocumentId &&
          other.createdAt == this.createdAt &&
          other.serverSeq == this.serverSeq);
}

class DocumentsCompanion extends UpdateCompanion<Document> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> deviceId;
  final Value<String> docType;
  final Value<String> number;
  final Value<String?> partyId;
  final Value<DateTime> issuedAt;
  final Value<String> status;
  final Value<int> taxablePaise;
  final Value<int> cgstPaise;
  final Value<int> sgstPaise;
  final Value<int> igstPaise;
  final Value<int> roundOffPaise;
  final Value<int> totalPaise;
  final Value<String> snapshotJson;
  final Value<String?> refDocumentId;
  final Value<DateTime> createdAt;
  final Value<int?> serverSeq;
  final Value<int> rowid;
  const DocumentsCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.docType = const Value.absent(),
    this.number = const Value.absent(),
    this.partyId = const Value.absent(),
    this.issuedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.taxablePaise = const Value.absent(),
    this.cgstPaise = const Value.absent(),
    this.sgstPaise = const Value.absent(),
    this.igstPaise = const Value.absent(),
    this.roundOffPaise = const Value.absent(),
    this.totalPaise = const Value.absent(),
    this.snapshotJson = const Value.absent(),
    this.refDocumentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsCompanion.insert({
    required String id,
    required String businessId,
    required String deviceId,
    required String docType,
    required String number,
    this.partyId = const Value.absent(),
    required DateTime issuedAt,
    required String status,
    required int taxablePaise,
    required int cgstPaise,
    required int sgstPaise,
    required int igstPaise,
    required int roundOffPaise,
    required int totalPaise,
    required String snapshotJson,
    this.refDocumentId = const Value.absent(),
    required DateTime createdAt,
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        businessId = Value(businessId),
        deviceId = Value(deviceId),
        docType = Value(docType),
        number = Value(number),
        issuedAt = Value(issuedAt),
        status = Value(status),
        taxablePaise = Value(taxablePaise),
        cgstPaise = Value(cgstPaise),
        sgstPaise = Value(sgstPaise),
        igstPaise = Value(igstPaise),
        roundOffPaise = Value(roundOffPaise),
        totalPaise = Value(totalPaise),
        snapshotJson = Value(snapshotJson),
        createdAt = Value(createdAt);
  static Insertable<Document> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? deviceId,
    Expression<String>? docType,
    Expression<String>? number,
    Expression<String>? partyId,
    Expression<DateTime>? issuedAt,
    Expression<String>? status,
    Expression<int>? taxablePaise,
    Expression<int>? cgstPaise,
    Expression<int>? sgstPaise,
    Expression<int>? igstPaise,
    Expression<int>? roundOffPaise,
    Expression<int>? totalPaise,
    Expression<String>? snapshotJson,
    Expression<String>? refDocumentId,
    Expression<DateTime>? createdAt,
    Expression<int>? serverSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (deviceId != null) 'device_id': deviceId,
      if (docType != null) 'doc_type': docType,
      if (number != null) 'number': number,
      if (partyId != null) 'party_id': partyId,
      if (issuedAt != null) 'issued_at': issuedAt,
      if (status != null) 'status': status,
      if (taxablePaise != null) 'taxable_paise': taxablePaise,
      if (cgstPaise != null) 'cgst_paise': cgstPaise,
      if (sgstPaise != null) 'sgst_paise': sgstPaise,
      if (igstPaise != null) 'igst_paise': igstPaise,
      if (roundOffPaise != null) 'round_off_paise': roundOffPaise,
      if (totalPaise != null) 'total_paise': totalPaise,
      if (snapshotJson != null) 'snapshot_json': snapshotJson,
      if (refDocumentId != null) 'ref_document_id': refDocumentId,
      if (createdAt != null) 'created_at': createdAt,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? businessId,
      Value<String>? deviceId,
      Value<String>? docType,
      Value<String>? number,
      Value<String?>? partyId,
      Value<DateTime>? issuedAt,
      Value<String>? status,
      Value<int>? taxablePaise,
      Value<int>? cgstPaise,
      Value<int>? sgstPaise,
      Value<int>? igstPaise,
      Value<int>? roundOffPaise,
      Value<int>? totalPaise,
      Value<String>? snapshotJson,
      Value<String?>? refDocumentId,
      Value<DateTime>? createdAt,
      Value<int?>? serverSeq,
      Value<int>? rowid}) {
    return DocumentsCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      deviceId: deviceId ?? this.deviceId,
      docType: docType ?? this.docType,
      number: number ?? this.number,
      partyId: partyId ?? this.partyId,
      issuedAt: issuedAt ?? this.issuedAt,
      status: status ?? this.status,
      taxablePaise: taxablePaise ?? this.taxablePaise,
      cgstPaise: cgstPaise ?? this.cgstPaise,
      sgstPaise: sgstPaise ?? this.sgstPaise,
      igstPaise: igstPaise ?? this.igstPaise,
      roundOffPaise: roundOffPaise ?? this.roundOffPaise,
      totalPaise: totalPaise ?? this.totalPaise,
      snapshotJson: snapshotJson ?? this.snapshotJson,
      refDocumentId: refDocumentId ?? this.refDocumentId,
      createdAt: createdAt ?? this.createdAt,
      serverSeq: serverSeq ?? this.serverSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (docType.present) {
      map['doc_type'] = Variable<String>(docType.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (issuedAt.present) {
      map['issued_at'] = Variable<DateTime>(issuedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (taxablePaise.present) {
      map['taxable_paise'] = Variable<int>(taxablePaise.value);
    }
    if (cgstPaise.present) {
      map['cgst_paise'] = Variable<int>(cgstPaise.value);
    }
    if (sgstPaise.present) {
      map['sgst_paise'] = Variable<int>(sgstPaise.value);
    }
    if (igstPaise.present) {
      map['igst_paise'] = Variable<int>(igstPaise.value);
    }
    if (roundOffPaise.present) {
      map['round_off_paise'] = Variable<int>(roundOffPaise.value);
    }
    if (totalPaise.present) {
      map['total_paise'] = Variable<int>(totalPaise.value);
    }
    if (snapshotJson.present) {
      map['snapshot_json'] = Variable<String>(snapshotJson.value);
    }
    if (refDocumentId.present) {
      map['ref_document_id'] = Variable<String>(refDocumentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('deviceId: $deviceId, ')
          ..write('docType: $docType, ')
          ..write('number: $number, ')
          ..write('partyId: $partyId, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('status: $status, ')
          ..write('taxablePaise: $taxablePaise, ')
          ..write('cgstPaise: $cgstPaise, ')
          ..write('sgstPaise: $sgstPaise, ')
          ..write('igstPaise: $igstPaise, ')
          ..write('roundOffPaise: $roundOffPaise, ')
          ..write('totalPaise: $totalPaise, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('refDocumentId: $refDocumentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentLinesTable extends DocumentLines
    with TableInfo<$DocumentLinesTable, DocumentLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _documentIdMeta =
      const VerificationMeta('documentId');
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
      'document_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _businessIdMeta =
      const VerificationMeta('businessId');
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
      'business_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hsnMeta = const VerificationMeta('hsn');
  @override
  late final GeneratedColumn<String> hsn = GeneratedColumn<String>(
      'hsn', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _qtyMilliMeta =
      const VerificationMeta('qtyMilli');
  @override
  late final GeneratedColumn<int> qtyMilli = GeneratedColumn<int>(
      'qty_milli', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ratePaiseMeta =
      const VerificationMeta('ratePaise');
  @override
  late final GeneratedColumn<int> ratePaise = GeneratedColumn<int>(
      'rate_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _discountPaiseMeta =
      const VerificationMeta('discountPaise');
  @override
  late final GeneratedColumn<int> discountPaise = GeneratedColumn<int>(
      'discount_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _gstRateBpMeta =
      const VerificationMeta('gstRateBp');
  @override
  late final GeneratedColumn<int> gstRateBp = GeneratedColumn<int>(
      'gst_rate_bp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _taxablePaiseMeta =
      const VerificationMeta('taxablePaise');
  @override
  late final GeneratedColumn<int> taxablePaise = GeneratedColumn<int>(
      'taxable_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cgstPaiseMeta =
      const VerificationMeta('cgstPaise');
  @override
  late final GeneratedColumn<int> cgstPaise = GeneratedColumn<int>(
      'cgst_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sgstPaiseMeta =
      const VerificationMeta('sgstPaise');
  @override
  late final GeneratedColumn<int> sgstPaise = GeneratedColumn<int>(
      'sgst_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _igstPaiseMeta =
      const VerificationMeta('igstPaise');
  @override
  late final GeneratedColumn<int> igstPaise = GeneratedColumn<int>(
      'igst_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lineTotalPaiseMeta =
      const VerificationMeta('lineTotalPaise');
  @override
  late final GeneratedColumn<int> lineTotalPaise = GeneratedColumn<int>(
      'line_total_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _serverSeqMeta =
      const VerificationMeta('serverSeq');
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
      'server_seq', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        documentId,
        businessId,
        productId,
        name,
        hsn,
        qtyMilli,
        ratePaise,
        discountPaise,
        gstRateBp,
        taxablePaise,
        cgstPaise,
        sgstPaise,
        igstPaise,
        lineTotalPaise,
        createdAt,
        serverSeq
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_lines';
  @override
  VerificationContext validateIntegrity(Insertable<DocumentLine> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
          _documentIdMeta,
          documentId.isAcceptableOrUnknown(
              data['document_id']!, _documentIdMeta));
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
          _businessIdMeta,
          businessId.isAcceptableOrUnknown(
              data['business_id']!, _businessIdMeta));
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('hsn')) {
      context.handle(
          _hsnMeta, hsn.isAcceptableOrUnknown(data['hsn']!, _hsnMeta));
    } else if (isInserting) {
      context.missing(_hsnMeta);
    }
    if (data.containsKey('qty_milli')) {
      context.handle(_qtyMilliMeta,
          qtyMilli.isAcceptableOrUnknown(data['qty_milli']!, _qtyMilliMeta));
    } else if (isInserting) {
      context.missing(_qtyMilliMeta);
    }
    if (data.containsKey('rate_paise')) {
      context.handle(_ratePaiseMeta,
          ratePaise.isAcceptableOrUnknown(data['rate_paise']!, _ratePaiseMeta));
    } else if (isInserting) {
      context.missing(_ratePaiseMeta);
    }
    if (data.containsKey('discount_paise')) {
      context.handle(
          _discountPaiseMeta,
          discountPaise.isAcceptableOrUnknown(
              data['discount_paise']!, _discountPaiseMeta));
    } else if (isInserting) {
      context.missing(_discountPaiseMeta);
    }
    if (data.containsKey('gst_rate_bp')) {
      context.handle(
          _gstRateBpMeta,
          gstRateBp.isAcceptableOrUnknown(
              data['gst_rate_bp']!, _gstRateBpMeta));
    } else if (isInserting) {
      context.missing(_gstRateBpMeta);
    }
    if (data.containsKey('taxable_paise')) {
      context.handle(
          _taxablePaiseMeta,
          taxablePaise.isAcceptableOrUnknown(
              data['taxable_paise']!, _taxablePaiseMeta));
    } else if (isInserting) {
      context.missing(_taxablePaiseMeta);
    }
    if (data.containsKey('cgst_paise')) {
      context.handle(_cgstPaiseMeta,
          cgstPaise.isAcceptableOrUnknown(data['cgst_paise']!, _cgstPaiseMeta));
    } else if (isInserting) {
      context.missing(_cgstPaiseMeta);
    }
    if (data.containsKey('sgst_paise')) {
      context.handle(_sgstPaiseMeta,
          sgstPaise.isAcceptableOrUnknown(data['sgst_paise']!, _sgstPaiseMeta));
    } else if (isInserting) {
      context.missing(_sgstPaiseMeta);
    }
    if (data.containsKey('igst_paise')) {
      context.handle(_igstPaiseMeta,
          igstPaise.isAcceptableOrUnknown(data['igst_paise']!, _igstPaiseMeta));
    } else if (isInserting) {
      context.missing(_igstPaiseMeta);
    }
    if (data.containsKey('line_total_paise')) {
      context.handle(
          _lineTotalPaiseMeta,
          lineTotalPaise.isAcceptableOrUnknown(
              data['line_total_paise']!, _lineTotalPaiseMeta));
    } else if (isInserting) {
      context.missing(_lineTotalPaiseMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('server_seq')) {
      context.handle(_serverSeqMeta,
          serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentLine(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      documentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}document_id'])!,
      businessId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      hsn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hsn'])!,
      qtyMilli: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qty_milli'])!,
      ratePaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rate_paise'])!,
      discountPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}discount_paise'])!,
      gstRateBp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gst_rate_bp'])!,
      taxablePaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}taxable_paise'])!,
      cgstPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cgst_paise'])!,
      sgstPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sgst_paise'])!,
      igstPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}igst_paise'])!,
      lineTotalPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}line_total_paise'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      serverSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_seq']),
    );
  }

  @override
  $DocumentLinesTable createAlias(String alias) {
    return $DocumentLinesTable(attachedDatabase, alias);
  }
}

class DocumentLine extends DataClass implements Insertable<DocumentLine> {
  final String id;
  final String documentId;
  final String businessId;
  final String productId;
  final String name;
  final String hsn;
  final int qtyMilli;
  final int ratePaise;
  final int discountPaise;
  final int gstRateBp;
  final int taxablePaise;
  final int cgstPaise;
  final int sgstPaise;
  final int igstPaise;
  final int lineTotalPaise;
  final DateTime createdAt;
  final int? serverSeq;
  const DocumentLine(
      {required this.id,
      required this.documentId,
      required this.businessId,
      required this.productId,
      required this.name,
      required this.hsn,
      required this.qtyMilli,
      required this.ratePaise,
      required this.discountPaise,
      required this.gstRateBp,
      required this.taxablePaise,
      required this.cgstPaise,
      required this.sgstPaise,
      required this.igstPaise,
      required this.lineTotalPaise,
      required this.createdAt,
      this.serverSeq});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['document_id'] = Variable<String>(documentId);
    map['business_id'] = Variable<String>(businessId);
    map['product_id'] = Variable<String>(productId);
    map['name'] = Variable<String>(name);
    map['hsn'] = Variable<String>(hsn);
    map['qty_milli'] = Variable<int>(qtyMilli);
    map['rate_paise'] = Variable<int>(ratePaise);
    map['discount_paise'] = Variable<int>(discountPaise);
    map['gst_rate_bp'] = Variable<int>(gstRateBp);
    map['taxable_paise'] = Variable<int>(taxablePaise);
    map['cgst_paise'] = Variable<int>(cgstPaise);
    map['sgst_paise'] = Variable<int>(sgstPaise);
    map['igst_paise'] = Variable<int>(igstPaise);
    map['line_total_paise'] = Variable<int>(lineTotalPaise);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    return map;
  }

  DocumentLinesCompanion toCompanion(bool nullToAbsent) {
    return DocumentLinesCompanion(
      id: Value(id),
      documentId: Value(documentId),
      businessId: Value(businessId),
      productId: Value(productId),
      name: Value(name),
      hsn: Value(hsn),
      qtyMilli: Value(qtyMilli),
      ratePaise: Value(ratePaise),
      discountPaise: Value(discountPaise),
      gstRateBp: Value(gstRateBp),
      taxablePaise: Value(taxablePaise),
      cgstPaise: Value(cgstPaise),
      sgstPaise: Value(sgstPaise),
      igstPaise: Value(igstPaise),
      lineTotalPaise: Value(lineTotalPaise),
      createdAt: Value(createdAt),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
    );
  }

  factory DocumentLine.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentLine(
      id: serializer.fromJson<String>(json['id']),
      documentId: serializer.fromJson<String>(json['documentId']),
      businessId: serializer.fromJson<String>(json['businessId']),
      productId: serializer.fromJson<String>(json['productId']),
      name: serializer.fromJson<String>(json['name']),
      hsn: serializer.fromJson<String>(json['hsn']),
      qtyMilli: serializer.fromJson<int>(json['qtyMilli']),
      ratePaise: serializer.fromJson<int>(json['ratePaise']),
      discountPaise: serializer.fromJson<int>(json['discountPaise']),
      gstRateBp: serializer.fromJson<int>(json['gstRateBp']),
      taxablePaise: serializer.fromJson<int>(json['taxablePaise']),
      cgstPaise: serializer.fromJson<int>(json['cgstPaise']),
      sgstPaise: serializer.fromJson<int>(json['sgstPaise']),
      igstPaise: serializer.fromJson<int>(json['igstPaise']),
      lineTotalPaise: serializer.fromJson<int>(json['lineTotalPaise']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'documentId': serializer.toJson<String>(documentId),
      'businessId': serializer.toJson<String>(businessId),
      'productId': serializer.toJson<String>(productId),
      'name': serializer.toJson<String>(name),
      'hsn': serializer.toJson<String>(hsn),
      'qtyMilli': serializer.toJson<int>(qtyMilli),
      'ratePaise': serializer.toJson<int>(ratePaise),
      'discountPaise': serializer.toJson<int>(discountPaise),
      'gstRateBp': serializer.toJson<int>(gstRateBp),
      'taxablePaise': serializer.toJson<int>(taxablePaise),
      'cgstPaise': serializer.toJson<int>(cgstPaise),
      'sgstPaise': serializer.toJson<int>(sgstPaise),
      'igstPaise': serializer.toJson<int>(igstPaise),
      'lineTotalPaise': serializer.toJson<int>(lineTotalPaise),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'serverSeq': serializer.toJson<int?>(serverSeq),
    };
  }

  DocumentLine copyWith(
          {String? id,
          String? documentId,
          String? businessId,
          String? productId,
          String? name,
          String? hsn,
          int? qtyMilli,
          int? ratePaise,
          int? discountPaise,
          int? gstRateBp,
          int? taxablePaise,
          int? cgstPaise,
          int? sgstPaise,
          int? igstPaise,
          int? lineTotalPaise,
          DateTime? createdAt,
          Value<int?> serverSeq = const Value.absent()}) =>
      DocumentLine(
        id: id ?? this.id,
        documentId: documentId ?? this.documentId,
        businessId: businessId ?? this.businessId,
        productId: productId ?? this.productId,
        name: name ?? this.name,
        hsn: hsn ?? this.hsn,
        qtyMilli: qtyMilli ?? this.qtyMilli,
        ratePaise: ratePaise ?? this.ratePaise,
        discountPaise: discountPaise ?? this.discountPaise,
        gstRateBp: gstRateBp ?? this.gstRateBp,
        taxablePaise: taxablePaise ?? this.taxablePaise,
        cgstPaise: cgstPaise ?? this.cgstPaise,
        sgstPaise: sgstPaise ?? this.sgstPaise,
        igstPaise: igstPaise ?? this.igstPaise,
        lineTotalPaise: lineTotalPaise ?? this.lineTotalPaise,
        createdAt: createdAt ?? this.createdAt,
        serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
      );
  DocumentLine copyWithCompanion(DocumentLinesCompanion data) {
    return DocumentLine(
      id: data.id.present ? data.id.value : this.id,
      documentId:
          data.documentId.present ? data.documentId.value : this.documentId,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
      productId: data.productId.present ? data.productId.value : this.productId,
      name: data.name.present ? data.name.value : this.name,
      hsn: data.hsn.present ? data.hsn.value : this.hsn,
      qtyMilli: data.qtyMilli.present ? data.qtyMilli.value : this.qtyMilli,
      ratePaise: data.ratePaise.present ? data.ratePaise.value : this.ratePaise,
      discountPaise: data.discountPaise.present
          ? data.discountPaise.value
          : this.discountPaise,
      gstRateBp: data.gstRateBp.present ? data.gstRateBp.value : this.gstRateBp,
      taxablePaise: data.taxablePaise.present
          ? data.taxablePaise.value
          : this.taxablePaise,
      cgstPaise: data.cgstPaise.present ? data.cgstPaise.value : this.cgstPaise,
      sgstPaise: data.sgstPaise.present ? data.sgstPaise.value : this.sgstPaise,
      igstPaise: data.igstPaise.present ? data.igstPaise.value : this.igstPaise,
      lineTotalPaise: data.lineTotalPaise.present
          ? data.lineTotalPaise.value
          : this.lineTotalPaise,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentLine(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('businessId: $businessId, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('hsn: $hsn, ')
          ..write('qtyMilli: $qtyMilli, ')
          ..write('ratePaise: $ratePaise, ')
          ..write('discountPaise: $discountPaise, ')
          ..write('gstRateBp: $gstRateBp, ')
          ..write('taxablePaise: $taxablePaise, ')
          ..write('cgstPaise: $cgstPaise, ')
          ..write('sgstPaise: $sgstPaise, ')
          ..write('igstPaise: $igstPaise, ')
          ..write('lineTotalPaise: $lineTotalPaise, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverSeq: $serverSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      documentId,
      businessId,
      productId,
      name,
      hsn,
      qtyMilli,
      ratePaise,
      discountPaise,
      gstRateBp,
      taxablePaise,
      cgstPaise,
      sgstPaise,
      igstPaise,
      lineTotalPaise,
      createdAt,
      serverSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentLine &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.businessId == this.businessId &&
          other.productId == this.productId &&
          other.name == this.name &&
          other.hsn == this.hsn &&
          other.qtyMilli == this.qtyMilli &&
          other.ratePaise == this.ratePaise &&
          other.discountPaise == this.discountPaise &&
          other.gstRateBp == this.gstRateBp &&
          other.taxablePaise == this.taxablePaise &&
          other.cgstPaise == this.cgstPaise &&
          other.sgstPaise == this.sgstPaise &&
          other.igstPaise == this.igstPaise &&
          other.lineTotalPaise == this.lineTotalPaise &&
          other.createdAt == this.createdAt &&
          other.serverSeq == this.serverSeq);
}

class DocumentLinesCompanion extends UpdateCompanion<DocumentLine> {
  final Value<String> id;
  final Value<String> documentId;
  final Value<String> businessId;
  final Value<String> productId;
  final Value<String> name;
  final Value<String> hsn;
  final Value<int> qtyMilli;
  final Value<int> ratePaise;
  final Value<int> discountPaise;
  final Value<int> gstRateBp;
  final Value<int> taxablePaise;
  final Value<int> cgstPaise;
  final Value<int> sgstPaise;
  final Value<int> igstPaise;
  final Value<int> lineTotalPaise;
  final Value<DateTime> createdAt;
  final Value<int?> serverSeq;
  final Value<int> rowid;
  const DocumentLinesCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.businessId = const Value.absent(),
    this.productId = const Value.absent(),
    this.name = const Value.absent(),
    this.hsn = const Value.absent(),
    this.qtyMilli = const Value.absent(),
    this.ratePaise = const Value.absent(),
    this.discountPaise = const Value.absent(),
    this.gstRateBp = const Value.absent(),
    this.taxablePaise = const Value.absent(),
    this.cgstPaise = const Value.absent(),
    this.sgstPaise = const Value.absent(),
    this.igstPaise = const Value.absent(),
    this.lineTotalPaise = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentLinesCompanion.insert({
    required String id,
    required String documentId,
    required String businessId,
    required String productId,
    required String name,
    required String hsn,
    required int qtyMilli,
    required int ratePaise,
    required int discountPaise,
    required int gstRateBp,
    required int taxablePaise,
    required int cgstPaise,
    required int sgstPaise,
    required int igstPaise,
    required int lineTotalPaise,
    required DateTime createdAt,
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        documentId = Value(documentId),
        businessId = Value(businessId),
        productId = Value(productId),
        name = Value(name),
        hsn = Value(hsn),
        qtyMilli = Value(qtyMilli),
        ratePaise = Value(ratePaise),
        discountPaise = Value(discountPaise),
        gstRateBp = Value(gstRateBp),
        taxablePaise = Value(taxablePaise),
        cgstPaise = Value(cgstPaise),
        sgstPaise = Value(sgstPaise),
        igstPaise = Value(igstPaise),
        lineTotalPaise = Value(lineTotalPaise),
        createdAt = Value(createdAt);
  static Insertable<DocumentLine> custom({
    Expression<String>? id,
    Expression<String>? documentId,
    Expression<String>? businessId,
    Expression<String>? productId,
    Expression<String>? name,
    Expression<String>? hsn,
    Expression<int>? qtyMilli,
    Expression<int>? ratePaise,
    Expression<int>? discountPaise,
    Expression<int>? gstRateBp,
    Expression<int>? taxablePaise,
    Expression<int>? cgstPaise,
    Expression<int>? sgstPaise,
    Expression<int>? igstPaise,
    Expression<int>? lineTotalPaise,
    Expression<DateTime>? createdAt,
    Expression<int>? serverSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (businessId != null) 'business_id': businessId,
      if (productId != null) 'product_id': productId,
      if (name != null) 'name': name,
      if (hsn != null) 'hsn': hsn,
      if (qtyMilli != null) 'qty_milli': qtyMilli,
      if (ratePaise != null) 'rate_paise': ratePaise,
      if (discountPaise != null) 'discount_paise': discountPaise,
      if (gstRateBp != null) 'gst_rate_bp': gstRateBp,
      if (taxablePaise != null) 'taxable_paise': taxablePaise,
      if (cgstPaise != null) 'cgst_paise': cgstPaise,
      if (sgstPaise != null) 'sgst_paise': sgstPaise,
      if (igstPaise != null) 'igst_paise': igstPaise,
      if (lineTotalPaise != null) 'line_total_paise': lineTotalPaise,
      if (createdAt != null) 'created_at': createdAt,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentLinesCompanion copyWith(
      {Value<String>? id,
      Value<String>? documentId,
      Value<String>? businessId,
      Value<String>? productId,
      Value<String>? name,
      Value<String>? hsn,
      Value<int>? qtyMilli,
      Value<int>? ratePaise,
      Value<int>? discountPaise,
      Value<int>? gstRateBp,
      Value<int>? taxablePaise,
      Value<int>? cgstPaise,
      Value<int>? sgstPaise,
      Value<int>? igstPaise,
      Value<int>? lineTotalPaise,
      Value<DateTime>? createdAt,
      Value<int?>? serverSeq,
      Value<int>? rowid}) {
    return DocumentLinesCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      businessId: businessId ?? this.businessId,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      hsn: hsn ?? this.hsn,
      qtyMilli: qtyMilli ?? this.qtyMilli,
      ratePaise: ratePaise ?? this.ratePaise,
      discountPaise: discountPaise ?? this.discountPaise,
      gstRateBp: gstRateBp ?? this.gstRateBp,
      taxablePaise: taxablePaise ?? this.taxablePaise,
      cgstPaise: cgstPaise ?? this.cgstPaise,
      sgstPaise: sgstPaise ?? this.sgstPaise,
      igstPaise: igstPaise ?? this.igstPaise,
      lineTotalPaise: lineTotalPaise ?? this.lineTotalPaise,
      createdAt: createdAt ?? this.createdAt,
      serverSeq: serverSeq ?? this.serverSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (hsn.present) {
      map['hsn'] = Variable<String>(hsn.value);
    }
    if (qtyMilli.present) {
      map['qty_milli'] = Variable<int>(qtyMilli.value);
    }
    if (ratePaise.present) {
      map['rate_paise'] = Variable<int>(ratePaise.value);
    }
    if (discountPaise.present) {
      map['discount_paise'] = Variable<int>(discountPaise.value);
    }
    if (gstRateBp.present) {
      map['gst_rate_bp'] = Variable<int>(gstRateBp.value);
    }
    if (taxablePaise.present) {
      map['taxable_paise'] = Variable<int>(taxablePaise.value);
    }
    if (cgstPaise.present) {
      map['cgst_paise'] = Variable<int>(cgstPaise.value);
    }
    if (sgstPaise.present) {
      map['sgst_paise'] = Variable<int>(sgstPaise.value);
    }
    if (igstPaise.present) {
      map['igst_paise'] = Variable<int>(igstPaise.value);
    }
    if (lineTotalPaise.present) {
      map['line_total_paise'] = Variable<int>(lineTotalPaise.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentLinesCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('businessId: $businessId, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('hsn: $hsn, ')
          ..write('qtyMilli: $qtyMilli, ')
          ..write('ratePaise: $ratePaise, ')
          ..write('discountPaise: $discountPaise, ')
          ..write('gstRateBp: $gstRateBp, ')
          ..write('taxablePaise: $taxablePaise, ')
          ..write('cgstPaise: $cgstPaise, ')
          ..write('sgstPaise: $sgstPaise, ')
          ..write('igstPaise: $igstPaise, ')
          ..write('lineTotalPaise: $lineTotalPaise, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _businessIdMeta =
      const VerificationMeta('businessId');
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
      'business_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _documentIdMeta =
      const VerificationMeta('documentId');
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
      'document_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _partyIdMeta =
      const VerificationMeta('partyId');
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
      'party_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountPaiseMeta =
      const VerificationMeta('amountPaise');
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
      'amount_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
      'paid_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _serverSeqMeta =
      const VerificationMeta('serverSeq');
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
      'server_seq', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        businessId,
        documentId,
        partyId,
        method,
        amountPaise,
        note,
        paidAt,
        createdAt,
        serverSeq
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<Payment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
          _businessIdMeta,
          businessId.isAcceptableOrUnknown(
              data['business_id']!, _businessIdMeta));
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
          _documentIdMeta,
          documentId.isAcceptableOrUnknown(
              data['document_id']!, _documentIdMeta));
    }
    if (data.containsKey('party_id')) {
      context.handle(_partyIdMeta,
          partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta));
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
          _amountPaiseMeta,
          amountPaise.isAcceptableOrUnknown(
              data['amount_paise']!, _amountPaiseMeta));
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('paid_at')) {
      context.handle(_paidAtMeta,
          paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta));
    } else if (isInserting) {
      context.missing(_paidAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('server_seq')) {
      context.handle(_serverSeqMeta,
          serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      businessId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_id'])!,
      documentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}document_id']),
      partyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}party_id']),
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      amountPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_paise'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      paidAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}paid_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      serverSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_seq']),
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final String id;
  final String businessId;
  final String? documentId;
  final String? partyId;
  final String method;
  final int amountPaise;
  final String? note;
  final DateTime paidAt;
  final DateTime createdAt;
  final int? serverSeq;
  const Payment(
      {required this.id,
      required this.businessId,
      this.documentId,
      this.partyId,
      required this.method,
      required this.amountPaise,
      this.note,
      required this.paidAt,
      required this.createdAt,
      this.serverSeq});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    if (!nullToAbsent || documentId != null) {
      map['document_id'] = Variable<String>(documentId);
    }
    if (!nullToAbsent || partyId != null) {
      map['party_id'] = Variable<String>(partyId);
    }
    map['method'] = Variable<String>(method);
    map['amount_paise'] = Variable<int>(amountPaise);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['paid_at'] = Variable<DateTime>(paidAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      businessId: Value(businessId),
      documentId: documentId == null && nullToAbsent
          ? const Value.absent()
          : Value(documentId),
      partyId: partyId == null && nullToAbsent
          ? const Value.absent()
          : Value(partyId),
      method: Value(method),
      amountPaise: Value(amountPaise),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      paidAt: Value(paidAt),
      createdAt: Value(createdAt),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      documentId: serializer.fromJson<String?>(json['documentId']),
      partyId: serializer.fromJson<String?>(json['partyId']),
      method: serializer.fromJson<String>(json['method']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      note: serializer.fromJson<String?>(json['note']),
      paidAt: serializer.fromJson<DateTime>(json['paidAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'documentId': serializer.toJson<String?>(documentId),
      'partyId': serializer.toJson<String?>(partyId),
      'method': serializer.toJson<String>(method),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'note': serializer.toJson<String?>(note),
      'paidAt': serializer.toJson<DateTime>(paidAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'serverSeq': serializer.toJson<int?>(serverSeq),
    };
  }

  Payment copyWith(
          {String? id,
          String? businessId,
          Value<String?> documentId = const Value.absent(),
          Value<String?> partyId = const Value.absent(),
          String? method,
          int? amountPaise,
          Value<String?> note = const Value.absent(),
          DateTime? paidAt,
          DateTime? createdAt,
          Value<int?> serverSeq = const Value.absent()}) =>
      Payment(
        id: id ?? this.id,
        businessId: businessId ?? this.businessId,
        documentId: documentId.present ? documentId.value : this.documentId,
        partyId: partyId.present ? partyId.value : this.partyId,
        method: method ?? this.method,
        amountPaise: amountPaise ?? this.amountPaise,
        note: note.present ? note.value : this.note,
        paidAt: paidAt ?? this.paidAt,
        createdAt: createdAt ?? this.createdAt,
        serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
      );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
      documentId:
          data.documentId.present ? data.documentId.value : this.documentId,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      method: data.method.present ? data.method.value : this.method,
      amountPaise:
          data.amountPaise.present ? data.amountPaise.value : this.amountPaise,
      note: data.note.present ? data.note.value : this.note,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('documentId: $documentId, ')
          ..write('partyId: $partyId, ')
          ..write('method: $method, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('note: $note, ')
          ..write('paidAt: $paidAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverSeq: $serverSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, businessId, documentId, partyId, method,
      amountPaise, note, paidAt, createdAt, serverSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.documentId == this.documentId &&
          other.partyId == this.partyId &&
          other.method == this.method &&
          other.amountPaise == this.amountPaise &&
          other.note == this.note &&
          other.paidAt == this.paidAt &&
          other.createdAt == this.createdAt &&
          other.serverSeq == this.serverSeq);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String?> documentId;
  final Value<String?> partyId;
  final Value<String> method;
  final Value<int> amountPaise;
  final Value<String?> note;
  final Value<DateTime> paidAt;
  final Value<DateTime> createdAt;
  final Value<int?> serverSeq;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.documentId = const Value.absent(),
    this.partyId = const Value.absent(),
    this.method = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.note = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String businessId,
    this.documentId = const Value.absent(),
    this.partyId = const Value.absent(),
    required String method,
    required int amountPaise,
    this.note = const Value.absent(),
    required DateTime paidAt,
    required DateTime createdAt,
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        businessId = Value(businessId),
        method = Value(method),
        amountPaise = Value(amountPaise),
        paidAt = Value(paidAt),
        createdAt = Value(createdAt);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? documentId,
    Expression<String>? partyId,
    Expression<String>? method,
    Expression<int>? amountPaise,
    Expression<String>? note,
    Expression<DateTime>? paidAt,
    Expression<DateTime>? createdAt,
    Expression<int>? serverSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (documentId != null) 'document_id': documentId,
      if (partyId != null) 'party_id': partyId,
      if (method != null) 'method': method,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (note != null) 'note': note,
      if (paidAt != null) 'paid_at': paidAt,
      if (createdAt != null) 'created_at': createdAt,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? businessId,
      Value<String?>? documentId,
      Value<String?>? partyId,
      Value<String>? method,
      Value<int>? amountPaise,
      Value<String?>? note,
      Value<DateTime>? paidAt,
      Value<DateTime>? createdAt,
      Value<int?>? serverSeq,
      Value<int>? rowid}) {
    return PaymentsCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      documentId: documentId ?? this.documentId,
      partyId: partyId ?? this.partyId,
      method: method ?? this.method,
      amountPaise: amountPaise ?? this.amountPaise,
      note: note ?? this.note,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
      serverSeq: serverSeq ?? this.serverSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('documentId: $documentId, ')
          ..write('partyId: $partyId, ')
          ..write('method: $method, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('note: $note, ')
          ..write('paidAt: $paidAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _businessIdMeta =
      const VerificationMeta('businessId');
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
      'business_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _qtyMilliMeta =
      const VerificationMeta('qtyMilli');
  @override
  late final GeneratedColumn<int> qtyMilli = GeneratedColumn<int>(
      'qty_milli', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _documentIdMeta =
      const VerificationMeta('documentId');
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
      'document_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _serverSeqMeta =
      const VerificationMeta('serverSeq');
  @override
  late final GeneratedColumn<int> serverSeq = GeneratedColumn<int>(
      'server_seq', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        businessId,
        productId,
        qtyMilli,
        reason,
        documentId,
        createdAt,
        serverSeq
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(Insertable<StockMovement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
          _businessIdMeta,
          businessId.isAcceptableOrUnknown(
              data['business_id']!, _businessIdMeta));
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('qty_milli')) {
      context.handle(_qtyMilliMeta,
          qtyMilli.isAcceptableOrUnknown(data['qty_milli']!, _qtyMilliMeta));
    } else if (isInserting) {
      context.missing(_qtyMilliMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
          _documentIdMeta,
          documentId.isAcceptableOrUnknown(
              data['document_id']!, _documentIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('server_seq')) {
      context.handle(_serverSeqMeta,
          serverSeq.isAcceptableOrUnknown(data['server_seq']!, _serverSeqMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      businessId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      qtyMilli: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qty_milli'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      documentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}document_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      serverSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_seq']),
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }
}

class StockMovement extends DataClass implements Insertable<StockMovement> {
  final String id;
  final String businessId;
  final String productId;
  final int qtyMilli;
  final String reason;
  final String? documentId;
  final DateTime createdAt;
  final int? serverSeq;
  const StockMovement(
      {required this.id,
      required this.businessId,
      required this.productId,
      required this.qtyMilli,
      required this.reason,
      this.documentId,
      required this.createdAt,
      this.serverSeq});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['product_id'] = Variable<String>(productId);
    map['qty_milli'] = Variable<int>(qtyMilli);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || documentId != null) {
      map['document_id'] = Variable<String>(documentId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || serverSeq != null) {
      map['server_seq'] = Variable<int>(serverSeq);
    }
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      id: Value(id),
      businessId: Value(businessId),
      productId: Value(productId),
      qtyMilli: Value(qtyMilli),
      reason: Value(reason),
      documentId: documentId == null && nullToAbsent
          ? const Value.absent()
          : Value(documentId),
      createdAt: Value(createdAt),
      serverSeq: serverSeq == null && nullToAbsent
          ? const Value.absent()
          : Value(serverSeq),
    );
  }

  factory StockMovement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovement(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      productId: serializer.fromJson<String>(json['productId']),
      qtyMilli: serializer.fromJson<int>(json['qtyMilli']),
      reason: serializer.fromJson<String>(json['reason']),
      documentId: serializer.fromJson<String?>(json['documentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      serverSeq: serializer.fromJson<int?>(json['serverSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'productId': serializer.toJson<String>(productId),
      'qtyMilli': serializer.toJson<int>(qtyMilli),
      'reason': serializer.toJson<String>(reason),
      'documentId': serializer.toJson<String?>(documentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'serverSeq': serializer.toJson<int?>(serverSeq),
    };
  }

  StockMovement copyWith(
          {String? id,
          String? businessId,
          String? productId,
          int? qtyMilli,
          String? reason,
          Value<String?> documentId = const Value.absent(),
          DateTime? createdAt,
          Value<int?> serverSeq = const Value.absent()}) =>
      StockMovement(
        id: id ?? this.id,
        businessId: businessId ?? this.businessId,
        productId: productId ?? this.productId,
        qtyMilli: qtyMilli ?? this.qtyMilli,
        reason: reason ?? this.reason,
        documentId: documentId.present ? documentId.value : this.documentId,
        createdAt: createdAt ?? this.createdAt,
        serverSeq: serverSeq.present ? serverSeq.value : this.serverSeq,
      );
  StockMovement copyWithCompanion(StockMovementsCompanion data) {
    return StockMovement(
      id: data.id.present ? data.id.value : this.id,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
      productId: data.productId.present ? data.productId.value : this.productId,
      qtyMilli: data.qtyMilli.present ? data.qtyMilli.value : this.qtyMilli,
      reason: data.reason.present ? data.reason.value : this.reason,
      documentId:
          data.documentId.present ? data.documentId.value : this.documentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverSeq: data.serverSeq.present ? data.serverSeq.value : this.serverSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovement(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('productId: $productId, ')
          ..write('qtyMilli: $qtyMilli, ')
          ..write('reason: $reason, ')
          ..write('documentId: $documentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverSeq: $serverSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, businessId, productId, qtyMilli, reason,
      documentId, createdAt, serverSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovement &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.productId == this.productId &&
          other.qtyMilli == this.qtyMilli &&
          other.reason == this.reason &&
          other.documentId == this.documentId &&
          other.createdAt == this.createdAt &&
          other.serverSeq == this.serverSeq);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovement> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> productId;
  final Value<int> qtyMilli;
  final Value<String> reason;
  final Value<String?> documentId;
  final Value<DateTime> createdAt;
  final Value<int?> serverSeq;
  final Value<int> rowid;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.productId = const Value.absent(),
    this.qtyMilli = const Value.absent(),
    this.reason = const Value.absent(),
    this.documentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    required String id,
    required String businessId,
    required String productId,
    required int qtyMilli,
    required String reason,
    this.documentId = const Value.absent(),
    required DateTime createdAt,
    this.serverSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        businessId = Value(businessId),
        productId = Value(productId),
        qtyMilli = Value(qtyMilli),
        reason = Value(reason),
        createdAt = Value(createdAt);
  static Insertable<StockMovement> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? productId,
    Expression<int>? qtyMilli,
    Expression<String>? reason,
    Expression<String>? documentId,
    Expression<DateTime>? createdAt,
    Expression<int>? serverSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (productId != null) 'product_id': productId,
      if (qtyMilli != null) 'qty_milli': qtyMilli,
      if (reason != null) 'reason': reason,
      if (documentId != null) 'document_id': documentId,
      if (createdAt != null) 'created_at': createdAt,
      if (serverSeq != null) 'server_seq': serverSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockMovementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? businessId,
      Value<String>? productId,
      Value<int>? qtyMilli,
      Value<String>? reason,
      Value<String?>? documentId,
      Value<DateTime>? createdAt,
      Value<int?>? serverSeq,
      Value<int>? rowid}) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      productId: productId ?? this.productId,
      qtyMilli: qtyMilli ?? this.qtyMilli,
      reason: reason ?? this.reason,
      documentId: documentId ?? this.documentId,
      createdAt: createdAt ?? this.createdAt,
      serverSeq: serverSeq ?? this.serverSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (qtyMilli.present) {
      map['qty_milli'] = Variable<int>(qtyMilli.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (serverSeq.present) {
      map['server_seq'] = Variable<int>(serverSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('productId: $productId, ')
          ..write('qtyMilli: $qtyMilli, ')
          ..write('reason: $reason, ')
          ..write('documentId: $documentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverSeq: $serverSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxCommandsTable extends OutboxCommands
    with TableInfo<$OutboxCommandsTable, OutboxCommand> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxCommandsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _businessIdMeta =
      const VerificationMeta('businessId');
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
      'business_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _commandTypeMeta =
      const VerificationMeta('commandType');
  @override
  late final GeneratedColumn<String> commandType = GeneratedColumn<String>(
      'command_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        businessId,
        deviceId,
        commandType,
        payloadJson,
        status,
        createdAt,
        lastError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_commands';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxCommand> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
          _businessIdMeta,
          businessId.isAcceptableOrUnknown(
              data['business_id']!, _businessIdMeta));
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('command_type')) {
      context.handle(
          _commandTypeMeta,
          commandType.isAcceptableOrUnknown(
              data['command_type']!, _commandTypeMeta));
    } else if (isInserting) {
      context.missing(_commandTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxCommand map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxCommand(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      businessId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      commandType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}command_type'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $OutboxCommandsTable createAlias(String alias) {
    return $OutboxCommandsTable(attachedDatabase, alias);
  }
}

class OutboxCommand extends DataClass implements Insertable<OutboxCommand> {
  final String id;
  final String businessId;
  final String deviceId;
  final String commandType;
  final String payloadJson;
  final String status;
  final DateTime createdAt;
  final String? lastError;
  const OutboxCommand(
      {required this.id,
      required this.businessId,
      required this.deviceId,
      required this.commandType,
      required this.payloadJson,
      required this.status,
      required this.createdAt,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    map['device_id'] = Variable<String>(deviceId);
    map['command_type'] = Variable<String>(commandType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  OutboxCommandsCompanion toCompanion(bool nullToAbsent) {
    return OutboxCommandsCompanion(
      id: Value(id),
      businessId: Value(businessId),
      deviceId: Value(deviceId),
      commandType: Value(commandType),
      payloadJson: Value(payloadJson),
      status: Value(status),
      createdAt: Value(createdAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory OutboxCommand.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxCommand(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      commandType: serializer.fromJson<String>(json['commandType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'deviceId': serializer.toJson<String>(deviceId),
      'commandType': serializer.toJson<String>(commandType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  OutboxCommand copyWith(
          {String? id,
          String? businessId,
          String? deviceId,
          String? commandType,
          String? payloadJson,
          String? status,
          DateTime? createdAt,
          Value<String?> lastError = const Value.absent()}) =>
      OutboxCommand(
        id: id ?? this.id,
        businessId: businessId ?? this.businessId,
        deviceId: deviceId ?? this.deviceId,
        commandType: commandType ?? this.commandType,
        payloadJson: payloadJson ?? this.payloadJson,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  OutboxCommand copyWithCompanion(OutboxCommandsCompanion data) {
    return OutboxCommand(
      id: data.id.present ? data.id.value : this.id,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      commandType:
          data.commandType.present ? data.commandType.value : this.commandType,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCommand(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('deviceId: $deviceId, ')
          ..write('commandType: $commandType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, businessId, deviceId, commandType,
      payloadJson, status, createdAt, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxCommand &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.deviceId == this.deviceId &&
          other.commandType == this.commandType &&
          other.payloadJson == this.payloadJson &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.lastError == this.lastError);
}

class OutboxCommandsCompanion extends UpdateCompanion<OutboxCommand> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String> deviceId;
  final Value<String> commandType;
  final Value<String> payloadJson;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const OutboxCommandsCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.commandType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxCommandsCompanion.insert({
    required String id,
    required String businessId,
    required String deviceId,
    required String commandType,
    required String payloadJson,
    required String status,
    required DateTime createdAt,
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        businessId = Value(businessId),
        deviceId = Value(deviceId),
        commandType = Value(commandType),
        payloadJson = Value(payloadJson),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<OutboxCommand> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? deviceId,
    Expression<String>? commandType,
    Expression<String>? payloadJson,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (deviceId != null) 'device_id': deviceId,
      if (commandType != null) 'command_type': commandType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxCommandsCompanion copyWith(
      {Value<String>? id,
      Value<String>? businessId,
      Value<String>? deviceId,
      Value<String>? commandType,
      Value<String>? payloadJson,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<String?>? lastError,
      Value<int>? rowid}) {
    return OutboxCommandsCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      deviceId: deviceId ?? this.deviceId,
      commandType: commandType ?? this.commandType,
      payloadJson: payloadJson ?? this.payloadJson,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (commandType.present) {
      map['command_type'] = Variable<String>(commandType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCommandsCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('deviceId: $deviceId, ')
          ..write('commandType: $commandType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DraftCartsTable extends DraftCarts
    with TableInfo<$DraftCartsTable, DraftCart> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftCartsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _businessIdMeta =
      const VerificationMeta('businessId');
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
      'business_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _partyIdMeta =
      const VerificationMeta('partyId');
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
      'party_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cartJsonMeta =
      const VerificationMeta('cartJson');
  @override
  late final GeneratedColumn<String> cartJson = GeneratedColumn<String>(
      'cart_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, businessId, partyId, cartJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'draft_carts';
  @override
  VerificationContext validateIntegrity(Insertable<DraftCart> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
          _businessIdMeta,
          businessId.isAcceptableOrUnknown(
              data['business_id']!, _businessIdMeta));
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(_partyIdMeta,
          partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta));
    }
    if (data.containsKey('cart_json')) {
      context.handle(_cartJsonMeta,
          cartJson.isAcceptableOrUnknown(data['cart_json']!, _cartJsonMeta));
    } else if (isInserting) {
      context.missing(_cartJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DraftCart map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DraftCart(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      businessId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_id'])!,
      partyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}party_id']),
      cartJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cart_json'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DraftCartsTable createAlias(String alias) {
    return $DraftCartsTable(attachedDatabase, alias);
  }
}

class DraftCart extends DataClass implements Insertable<DraftCart> {
  final String id;
  final String businessId;
  final String? partyId;
  final String cartJson;
  final DateTime updatedAt;
  const DraftCart(
      {required this.id,
      required this.businessId,
      this.partyId,
      required this.cartJson,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_id'] = Variable<String>(businessId);
    if (!nullToAbsent || partyId != null) {
      map['party_id'] = Variable<String>(partyId);
    }
    map['cart_json'] = Variable<String>(cartJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DraftCartsCompanion toCompanion(bool nullToAbsent) {
    return DraftCartsCompanion(
      id: Value(id),
      businessId: Value(businessId),
      partyId: partyId == null && nullToAbsent
          ? const Value.absent()
          : Value(partyId),
      cartJson: Value(cartJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory DraftCart.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DraftCart(
      id: serializer.fromJson<String>(json['id']),
      businessId: serializer.fromJson<String>(json['businessId']),
      partyId: serializer.fromJson<String?>(json['partyId']),
      cartJson: serializer.fromJson<String>(json['cartJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessId': serializer.toJson<String>(businessId),
      'partyId': serializer.toJson<String?>(partyId),
      'cartJson': serializer.toJson<String>(cartJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DraftCart copyWith(
          {String? id,
          String? businessId,
          Value<String?> partyId = const Value.absent(),
          String? cartJson,
          DateTime? updatedAt}) =>
      DraftCart(
        id: id ?? this.id,
        businessId: businessId ?? this.businessId,
        partyId: partyId.present ? partyId.value : this.partyId,
        cartJson: cartJson ?? this.cartJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DraftCart copyWithCompanion(DraftCartsCompanion data) {
    return DraftCart(
      id: data.id.present ? data.id.value : this.id,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      cartJson: data.cartJson.present ? data.cartJson.value : this.cartJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DraftCart(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('partyId: $partyId, ')
          ..write('cartJson: $cartJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, businessId, partyId, cartJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DraftCart &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.partyId == this.partyId &&
          other.cartJson == this.cartJson &&
          other.updatedAt == this.updatedAt);
}

class DraftCartsCompanion extends UpdateCompanion<DraftCart> {
  final Value<String> id;
  final Value<String> businessId;
  final Value<String?> partyId;
  final Value<String> cartJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DraftCartsCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.partyId = const Value.absent(),
    this.cartJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DraftCartsCompanion.insert({
    required String id,
    required String businessId,
    this.partyId = const Value.absent(),
    required String cartJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        businessId = Value(businessId),
        cartJson = Value(cartJson),
        updatedAt = Value(updatedAt);
  static Insertable<DraftCart> custom({
    Expression<String>? id,
    Expression<String>? businessId,
    Expression<String>? partyId,
    Expression<String>? cartJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (partyId != null) 'party_id': partyId,
      if (cartJson != null) 'cart_json': cartJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DraftCartsCompanion copyWith(
      {Value<String>? id,
      Value<String>? businessId,
      Value<String?>? partyId,
      Value<String>? cartJson,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return DraftCartsCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      partyId: partyId ?? this.partyId,
      cartJson: cartJson ?? this.cartJson,
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
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (cartJson.present) {
      map['cart_json'] = Variable<String>(cartJson.value);
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
    return (StringBuffer('DraftCartsCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('partyId: $partyId, ')
          ..write('cartJson: $cartJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTableTable extends SyncStateTable
    with TableInfo<$SyncStateTableTable, SyncState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tableNameColMeta =
      const VerificationMeta('tableNameCol');
  @override
  late final GeneratedColumn<String> tableNameCol = GeneratedColumn<String>(
      'table_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastSeqMeta =
      const VerificationMeta('lastSeq');
  @override
  late final GeneratedColumn<int> lastSeq = GeneratedColumn<int>(
      'last_seq', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [tableNameCol, lastSeq];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(Insertable<SyncState> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('table_name')) {
      context.handle(
          _tableNameColMeta,
          tableNameCol.isAcceptableOrUnknown(
              data['table_name']!, _tableNameColMeta));
    } else if (isInserting) {
      context.missing(_tableNameColMeta);
    }
    if (data.containsKey('last_seq')) {
      context.handle(_lastSeqMeta,
          lastSeq.isAcceptableOrUnknown(data['last_seq']!, _lastSeqMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tableNameCol};
  @override
  SyncState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncState(
      tableNameCol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}table_name'])!,
      lastSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_seq'])!,
    );
  }

  @override
  $SyncStateTableTable createAlias(String alias) {
    return $SyncStateTableTable(attachedDatabase, alias);
  }
}

class SyncState extends DataClass implements Insertable<SyncState> {
  final String tableNameCol;
  final int lastSeq;
  const SyncState({required this.tableNameCol, required this.lastSeq});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['table_name'] = Variable<String>(tableNameCol);
    map['last_seq'] = Variable<int>(lastSeq);
    return map;
  }

  SyncStateTableCompanion toCompanion(bool nullToAbsent) {
    return SyncStateTableCompanion(
      tableNameCol: Value(tableNameCol),
      lastSeq: Value(lastSeq),
    );
  }

  factory SyncState.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncState(
      tableNameCol: serializer.fromJson<String>(json['tableNameCol']),
      lastSeq: serializer.fromJson<int>(json['lastSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tableNameCol': serializer.toJson<String>(tableNameCol),
      'lastSeq': serializer.toJson<int>(lastSeq),
    };
  }

  SyncState copyWith({String? tableNameCol, int? lastSeq}) => SyncState(
        tableNameCol: tableNameCol ?? this.tableNameCol,
        lastSeq: lastSeq ?? this.lastSeq,
      );
  SyncState copyWithCompanion(SyncStateTableCompanion data) {
    return SyncState(
      tableNameCol: data.tableNameCol.present
          ? data.tableNameCol.value
          : this.tableNameCol,
      lastSeq: data.lastSeq.present ? data.lastSeq.value : this.lastSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncState(')
          ..write('tableNameCol: $tableNameCol, ')
          ..write('lastSeq: $lastSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tableNameCol, lastSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncState &&
          other.tableNameCol == this.tableNameCol &&
          other.lastSeq == this.lastSeq);
}

class SyncStateTableCompanion extends UpdateCompanion<SyncState> {
  final Value<String> tableNameCol;
  final Value<int> lastSeq;
  final Value<int> rowid;
  const SyncStateTableCompanion({
    this.tableNameCol = const Value.absent(),
    this.lastSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateTableCompanion.insert({
    required String tableNameCol,
    this.lastSeq = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tableNameCol = Value(tableNameCol);
  static Insertable<SyncState> custom({
    Expression<String>? tableNameCol,
    Expression<int>? lastSeq,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tableNameCol != null) 'table_name': tableNameCol,
      if (lastSeq != null) 'last_seq': lastSeq,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateTableCompanion copyWith(
      {Value<String>? tableNameCol, Value<int>? lastSeq, Value<int>? rowid}) {
    return SyncStateTableCompanion(
      tableNameCol: tableNameCol ?? this.tableNameCol,
      lastSeq: lastSeq ?? this.lastSeq,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tableNameCol.present) {
      map['table_name'] = Variable<String>(tableNameCol.value);
    }
    if (lastSeq.present) {
      map['last_seq'] = Variable<int>(lastSeq.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateTableCompanion(')
          ..write('tableNameCol: $tableNameCol, ')
          ..write('lastSeq: $lastSeq, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) => AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppSetting copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsTableCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppSettingsTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BusinessesTable businesses = $BusinessesTable(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $PartiesTable parties = $PartiesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $DocumentSeriesTable documentSeries = $DocumentSeriesTable(this);
  late final $DocumentsTable documents = $DocumentsTable(this);
  late final $DocumentLinesTable documentLines = $DocumentLinesTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  late final $OutboxCommandsTable outboxCommands = $OutboxCommandsTable(this);
  late final $DraftCartsTable draftCarts = $DraftCartsTable(this);
  late final $SyncStateTableTable syncStateTable = $SyncStateTableTable(this);
  late final $AppSettingsTableTable appSettingsTable =
      $AppSettingsTableTable(this);
  late final Index idxProductsBusinessBarcode = Index(
      'idx_products_business_barcode',
      'CREATE INDEX idx_products_business_barcode ON products (business_id, barcode)');
  late final Index idxProductsBusinessName = Index('idx_products_business_name',
      'CREATE INDEX idx_products_business_name ON products (business_id, name)');
  late final Index idxDocumentSeriesUnique = Index('idx_document_series_unique',
      'CREATE UNIQUE INDEX idx_document_series_unique ON document_series (business_id, device_id, doc_type, financial_year)');
  late final Index idxDocumentsBusinessIssuedAt = Index(
      'idx_documents_business_issued_at',
      'CREATE INDEX idx_documents_business_issued_at ON documents (business_id, issued_at)');
  late final Index idxDocumentsBusinessParty = Index(
      'idx_documents_business_party',
      'CREATE INDEX idx_documents_business_party ON documents (business_id, party_id)');
  late final Index idxPaymentsBusinessParty = Index(
      'idx_payments_business_party',
      'CREATE INDEX idx_payments_business_party ON payments (business_id, party_id)');
  late final Index idxStockMovementsBusinessProduct = Index(
      'idx_stock_movements_business_product',
      'CREATE INDEX idx_stock_movements_business_product ON stock_movements (business_id, product_id)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        businesses,
        devices,
        parties,
        products,
        documentSeries,
        documents,
        documentLines,
        payments,
        stockMovements,
        outboxCommands,
        draftCarts,
        syncStateTable,
        appSettingsTable,
        idxProductsBusinessBarcode,
        idxProductsBusinessName,
        idxDocumentSeriesUnique,
        idxDocumentsBusinessIssuedAt,
        idxDocumentsBusinessParty,
        idxPaymentsBusinessParty,
        idxStockMovementsBusinessProduct
      ];
}

typedef $$BusinessesTableCreateCompanionBuilder = BusinessesCompanion Function({
  required String id,
  required String businessId,
  required String name,
  Value<String?> gstin,
  required String stateCode,
  required String address,
  Value<String?> upiId,
  Value<String?> invoiceTerms,
  required DateTime createdAt,
  Value<DateTime> updatedAt,
  Value<int?> serverSeq,
  Value<int> rowid,
});
typedef $$BusinessesTableUpdateCompanionBuilder = BusinessesCompanion Function({
  Value<String> id,
  Value<String> businessId,
  Value<String> name,
  Value<String?> gstin,
  Value<String> stateCode,
  Value<String> address,
  Value<String?> upiId,
  Value<String?> invoiceTerms,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int?> serverSeq,
  Value<int> rowid,
});

class $$BusinessesTableFilterComposer
    extends Composer<_$AppDatabase, $BusinessesTable> {
  $$BusinessesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gstin => $composableBuilder(
      column: $table.gstin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stateCode => $composableBuilder(
      column: $table.stateCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get upiId => $composableBuilder(
      column: $table.upiId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceTerms => $composableBuilder(
      column: $table.invoiceTerms, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnFilters(column));
}

class $$BusinessesTableOrderingComposer
    extends Composer<_$AppDatabase, $BusinessesTable> {
  $$BusinessesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gstin => $composableBuilder(
      column: $table.gstin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stateCode => $composableBuilder(
      column: $table.stateCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get upiId => $composableBuilder(
      column: $table.upiId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceTerms => $composableBuilder(
      column: $table.invoiceTerms,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnOrderings(column));
}

class $$BusinessesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BusinessesTable> {
  $$BusinessesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<String> get stateCode =>
      $composableBuilder(column: $table.stateCode, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get upiId =>
      $composableBuilder(column: $table.upiId, builder: (column) => column);

  GeneratedColumn<String> get invoiceTerms => $composableBuilder(
      column: $table.invoiceTerms, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);
}

class $$BusinessesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BusinessesTable,
    Business,
    $$BusinessesTableFilterComposer,
    $$BusinessesTableOrderingComposer,
    $$BusinessesTableAnnotationComposer,
    $$BusinessesTableCreateCompanionBuilder,
    $$BusinessesTableUpdateCompanionBuilder,
    (Business, BaseReferences<_$AppDatabase, $BusinessesTable, Business>),
    Business,
    PrefetchHooks Function()> {
  $$BusinessesTableTableManager(_$AppDatabase db, $BusinessesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BusinessesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BusinessesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BusinessesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> businessId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> gstin = const Value.absent(),
            Value<String> stateCode = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String?> upiId = const Value.absent(),
            Value<String?> invoiceTerms = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int?> serverSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BusinessesCompanion(
            id: id,
            businessId: businessId,
            name: name,
            gstin: gstin,
            stateCode: stateCode,
            address: address,
            upiId: upiId,
            invoiceTerms: invoiceTerms,
            createdAt: createdAt,
            updatedAt: updatedAt,
            serverSeq: serverSeq,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String businessId,
            required String name,
            Value<String?> gstin = const Value.absent(),
            required String stateCode,
            required String address,
            Value<String?> upiId = const Value.absent(),
            Value<String?> invoiceTerms = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int?> serverSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BusinessesCompanion.insert(
            id: id,
            businessId: businessId,
            name: name,
            gstin: gstin,
            stateCode: stateCode,
            address: address,
            upiId: upiId,
            invoiceTerms: invoiceTerms,
            createdAt: createdAt,
            updatedAt: updatedAt,
            serverSeq: serverSeq,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BusinessesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BusinessesTable,
    Business,
    $$BusinessesTableFilterComposer,
    $$BusinessesTableOrderingComposer,
    $$BusinessesTableAnnotationComposer,
    $$BusinessesTableCreateCompanionBuilder,
    $$BusinessesTableUpdateCompanionBuilder,
    (Business, BaseReferences<_$AppDatabase, $BusinessesTable, Business>),
    Business,
    PrefetchHooks Function()>;
typedef $$DevicesTableCreateCompanionBuilder = DevicesCompanion Function({
  required String id,
  required String businessId,
  required String name,
  required String seriesPrefix,
  required DateTime createdAt,
  Value<DateTime> updatedAt,
  Value<int?> serverSeq,
  Value<int> rowid,
});
typedef $$DevicesTableUpdateCompanionBuilder = DevicesCompanion Function({
  Value<String> id,
  Value<String> businessId,
  Value<String> name,
  Value<String> seriesPrefix,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int?> serverSeq,
  Value<int> rowid,
});

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seriesPrefix => $composableBuilder(
      column: $table.seriesPrefix, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnFilters(column));
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seriesPrefix => $composableBuilder(
      column: $table.seriesPrefix,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnOrderings(column));
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get seriesPrefix => $composableBuilder(
      column: $table.seriesPrefix, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);
}

class $$DevicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DevicesTable,
    Device,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
    Device,
    PrefetchHooks Function()> {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> businessId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> seriesPrefix = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int?> serverSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion(
            id: id,
            businessId: businessId,
            name: name,
            seriesPrefix: seriesPrefix,
            createdAt: createdAt,
            updatedAt: updatedAt,
            serverSeq: serverSeq,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String businessId,
            required String name,
            required String seriesPrefix,
            required DateTime createdAt,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int?> serverSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DevicesCompanion.insert(
            id: id,
            businessId: businessId,
            name: name,
            seriesPrefix: seriesPrefix,
            createdAt: createdAt,
            updatedAt: updatedAt,
            serverSeq: serverSeq,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DevicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DevicesTable,
    Device,
    $$DevicesTableFilterComposer,
    $$DevicesTableOrderingComposer,
    $$DevicesTableAnnotationComposer,
    $$DevicesTableCreateCompanionBuilder,
    $$DevicesTableUpdateCompanionBuilder,
    (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
    Device,
    PrefetchHooks Function()>;
typedef $$PartiesTableCreateCompanionBuilder = PartiesCompanion Function({
  required String id,
  required String businessId,
  required String name,
  required String phone,
  Value<String?> gstin,
  required String stateCode,
  required int creditLimitPaise,
  required DateTime createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> archivedAt,
  Value<int?> serverSeq,
  Value<int> rowid,
});
typedef $$PartiesTableUpdateCompanionBuilder = PartiesCompanion Function({
  Value<String> id,
  Value<String> businessId,
  Value<String> name,
  Value<String> phone,
  Value<String?> gstin,
  Value<String> stateCode,
  Value<int> creditLimitPaise,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> archivedAt,
  Value<int?> serverSeq,
  Value<int> rowid,
});

class $$PartiesTableFilterComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gstin => $composableBuilder(
      column: $table.gstin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stateCode => $composableBuilder(
      column: $table.stateCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get creditLimitPaise => $composableBuilder(
      column: $table.creditLimitPaise,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnFilters(column));
}

class $$PartiesTableOrderingComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gstin => $composableBuilder(
      column: $table.gstin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stateCode => $composableBuilder(
      column: $table.stateCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get creditLimitPaise => $composableBuilder(
      column: $table.creditLimitPaise,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnOrderings(column));
}

class $$PartiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<String> get stateCode =>
      $composableBuilder(column: $table.stateCode, builder: (column) => column);

  GeneratedColumn<int> get creditLimitPaise => $composableBuilder(
      column: $table.creditLimitPaise, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);
}

class $$PartiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PartiesTable,
    Party,
    $$PartiesTableFilterComposer,
    $$PartiesTableOrderingComposer,
    $$PartiesTableAnnotationComposer,
    $$PartiesTableCreateCompanionBuilder,
    $$PartiesTableUpdateCompanionBuilder,
    (Party, BaseReferences<_$AppDatabase, $PartiesTable, Party>),
    Party,
    PrefetchHooks Function()> {
  $$PartiesTableTableManager(_$AppDatabase db, $PartiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> businessId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String?> gstin = const Value.absent(),
            Value<String> stateCode = const Value.absent(),
            Value<int> creditLimitPaise = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> archivedAt = const Value.absent(),
            Value<int?> serverSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PartiesCompanion(
            id: id,
            businessId: businessId,
            name: name,
            phone: phone,
            gstin: gstin,
            stateCode: stateCode,
            creditLimitPaise: creditLimitPaise,
            createdAt: createdAt,
            updatedAt: updatedAt,
            archivedAt: archivedAt,
            serverSeq: serverSeq,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String businessId,
            required String name,
            required String phone,
            Value<String?> gstin = const Value.absent(),
            required String stateCode,
            required int creditLimitPaise,
            required DateTime createdAt,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> archivedAt = const Value.absent(),
            Value<int?> serverSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PartiesCompanion.insert(
            id: id,
            businessId: businessId,
            name: name,
            phone: phone,
            gstin: gstin,
            stateCode: stateCode,
            creditLimitPaise: creditLimitPaise,
            createdAt: createdAt,
            updatedAt: updatedAt,
            archivedAt: archivedAt,
            serverSeq: serverSeq,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PartiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PartiesTable,
    Party,
    $$PartiesTableFilterComposer,
    $$PartiesTableOrderingComposer,
    $$PartiesTableAnnotationComposer,
    $$PartiesTableCreateCompanionBuilder,
    $$PartiesTableUpdateCompanionBuilder,
    (Party, BaseReferences<_$AppDatabase, $PartiesTable, Party>),
    Party,
    PrefetchHooks Function()>;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String id,
  required String businessId,
  required String name,
  Value<String?> barcode,
  required String hsn,
  required int gstRateBp,
  required int pricePaise,
  required int costPaise,
  required bool trackStock,
  required int reorderLevel,
  required DateTime createdAt,
  Value<DateTime> updatedAt,
  Value<int?> serverSeq,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<String> businessId,
  Value<String> name,
  Value<String?> barcode,
  Value<String> hsn,
  Value<int> gstRateBp,
  Value<int> pricePaise,
  Value<int> costPaise,
  Value<bool> trackStock,
  Value<int> reorderLevel,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int?> serverSeq,
  Value<int> rowid,
});

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hsn => $composableBuilder(
      column: $table.hsn, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gstRateBp => $composableBuilder(
      column: $table.gstRateBp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pricePaise => $composableBuilder(
      column: $table.pricePaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get costPaise => $composableBuilder(
      column: $table.costPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get trackStock => $composableBuilder(
      column: $table.trackStock, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reorderLevel => $composableBuilder(
      column: $table.reorderLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnFilters(column));
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hsn => $composableBuilder(
      column: $table.hsn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gstRateBp => $composableBuilder(
      column: $table.gstRateBp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pricePaise => $composableBuilder(
      column: $table.pricePaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get costPaise => $composableBuilder(
      column: $table.costPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get trackStock => $composableBuilder(
      column: $table.trackStock, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reorderLevel => $composableBuilder(
      column: $table.reorderLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnOrderings(column));
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get hsn =>
      $composableBuilder(column: $table.hsn, builder: (column) => column);

  GeneratedColumn<int> get gstRateBp =>
      $composableBuilder(column: $table.gstRateBp, builder: (column) => column);

  GeneratedColumn<int> get pricePaise => $composableBuilder(
      column: $table.pricePaise, builder: (column) => column);

  GeneratedColumn<int> get costPaise =>
      $composableBuilder(column: $table.costPaise, builder: (column) => column);

  GeneratedColumn<bool> get trackStock => $composableBuilder(
      column: $table.trackStock, builder: (column) => column);

  GeneratedColumn<int> get reorderLevel => $composableBuilder(
      column: $table.reorderLevel, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);
}

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
    Product,
    PrefetchHooks Function()> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> businessId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<String> hsn = const Value.absent(),
            Value<int> gstRateBp = const Value.absent(),
            Value<int> pricePaise = const Value.absent(),
            Value<int> costPaise = const Value.absent(),
            Value<bool> trackStock = const Value.absent(),
            Value<int> reorderLevel = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int?> serverSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            businessId: businessId,
            name: name,
            barcode: barcode,
            hsn: hsn,
            gstRateBp: gstRateBp,
            pricePaise: pricePaise,
            costPaise: costPaise,
            trackStock: trackStock,
            reorderLevel: reorderLevel,
            createdAt: createdAt,
            updatedAt: updatedAt,
            serverSeq: serverSeq,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String businessId,
            required String name,
            Value<String?> barcode = const Value.absent(),
            required String hsn,
            required int gstRateBp,
            required int pricePaise,
            required int costPaise,
            required bool trackStock,
            required int reorderLevel,
            required DateTime createdAt,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int?> serverSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            id: id,
            businessId: businessId,
            name: name,
            barcode: barcode,
            hsn: hsn,
            gstRateBp: gstRateBp,
            pricePaise: pricePaise,
            costPaise: costPaise,
            trackStock: trackStock,
            reorderLevel: reorderLevel,
            createdAt: createdAt,
            updatedAt: updatedAt,
            serverSeq: serverSeq,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
    Product,
    PrefetchHooks Function()>;
typedef $$DocumentSeriesTableCreateCompanionBuilder = DocumentSeriesCompanion
    Function({
  required String id,
  required String businessId,
  required String deviceId,
  required String docType,
  required String financialYear,
  required int nextNumber,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$DocumentSeriesTableUpdateCompanionBuilder = DocumentSeriesCompanion
    Function({
  Value<String> id,
  Value<String> businessId,
  Value<String> deviceId,
  Value<String> docType,
  Value<String> financialYear,
  Value<int> nextNumber,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$DocumentSeriesTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentSeriesTable> {
  $$DocumentSeriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get docType => $composableBuilder(
      column: $table.docType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get financialYear => $composableBuilder(
      column: $table.financialYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nextNumber => $composableBuilder(
      column: $table.nextNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$DocumentSeriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentSeriesTable> {
  $$DocumentSeriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get docType => $composableBuilder(
      column: $table.docType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get financialYear => $composableBuilder(
      column: $table.financialYear,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nextNumber => $composableBuilder(
      column: $table.nextNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$DocumentSeriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentSeriesTable> {
  $$DocumentSeriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get docType =>
      $composableBuilder(column: $table.docType, builder: (column) => column);

  GeneratedColumn<String> get financialYear => $composableBuilder(
      column: $table.financialYear, builder: (column) => column);

  GeneratedColumn<int> get nextNumber => $composableBuilder(
      column: $table.nextNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DocumentSeriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DocumentSeriesTable,
    DocumentSeriesData,
    $$DocumentSeriesTableFilterComposer,
    $$DocumentSeriesTableOrderingComposer,
    $$DocumentSeriesTableAnnotationComposer,
    $$DocumentSeriesTableCreateCompanionBuilder,
    $$DocumentSeriesTableUpdateCompanionBuilder,
    (
      DocumentSeriesData,
      BaseReferences<_$AppDatabase, $DocumentSeriesTable, DocumentSeriesData>
    ),
    DocumentSeriesData,
    PrefetchHooks Function()> {
  $$DocumentSeriesTableTableManager(
      _$AppDatabase db, $DocumentSeriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentSeriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentSeriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentSeriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> businessId = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String> docType = const Value.absent(),
            Value<String> financialYear = const Value.absent(),
            Value<int> nextNumber = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentSeriesCompanion(
            id: id,
            businessId: businessId,
            deviceId: deviceId,
            docType: docType,
            financialYear: financialYear,
            nextNumber: nextNumber,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String businessId,
            required String deviceId,
            required String docType,
            required String financialYear,
            required int nextNumber,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentSeriesCompanion.insert(
            id: id,
            businessId: businessId,
            deviceId: deviceId,
            docType: docType,
            financialYear: financialYear,
            nextNumber: nextNumber,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DocumentSeriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DocumentSeriesTable,
    DocumentSeriesData,
    $$DocumentSeriesTableFilterComposer,
    $$DocumentSeriesTableOrderingComposer,
    $$DocumentSeriesTableAnnotationComposer,
    $$DocumentSeriesTableCreateCompanionBuilder,
    $$DocumentSeriesTableUpdateCompanionBuilder,
    (
      DocumentSeriesData,
      BaseReferences<_$AppDatabase, $DocumentSeriesTable, DocumentSeriesData>
    ),
    DocumentSeriesData,
    PrefetchHooks Function()>;
typedef $$DocumentsTableCreateCompanionBuilder = DocumentsCompanion Function({
  required String id,
  required String businessId,
  required String deviceId,
  required String docType,
  required String number,
  Value<String?> partyId,
  required DateTime issuedAt,
  required String status,
  required int taxablePaise,
  required int cgstPaise,
  required int sgstPaise,
  required int igstPaise,
  required int roundOffPaise,
  required int totalPaise,
  required String snapshotJson,
  Value<String?> refDocumentId,
  required DateTime createdAt,
  Value<int?> serverSeq,
  Value<int> rowid,
});
typedef $$DocumentsTableUpdateCompanionBuilder = DocumentsCompanion Function({
  Value<String> id,
  Value<String> businessId,
  Value<String> deviceId,
  Value<String> docType,
  Value<String> number,
  Value<String?> partyId,
  Value<DateTime> issuedAt,
  Value<String> status,
  Value<int> taxablePaise,
  Value<int> cgstPaise,
  Value<int> sgstPaise,
  Value<int> igstPaise,
  Value<int> roundOffPaise,
  Value<int> totalPaise,
  Value<String> snapshotJson,
  Value<String?> refDocumentId,
  Value<DateTime> createdAt,
  Value<int?> serverSeq,
  Value<int> rowid,
});

class $$DocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get docType => $composableBuilder(
      column: $table.docType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partyId => $composableBuilder(
      column: $table.partyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get issuedAt => $composableBuilder(
      column: $table.issuedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get taxablePaise => $composableBuilder(
      column: $table.taxablePaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cgstPaise => $composableBuilder(
      column: $table.cgstPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sgstPaise => $composableBuilder(
      column: $table.sgstPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get igstPaise => $composableBuilder(
      column: $table.igstPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get roundOffPaise => $composableBuilder(
      column: $table.roundOffPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalPaise => $composableBuilder(
      column: $table.totalPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get snapshotJson => $composableBuilder(
      column: $table.snapshotJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get refDocumentId => $composableBuilder(
      column: $table.refDocumentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnFilters(column));
}

class $$DocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get docType => $composableBuilder(
      column: $table.docType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partyId => $composableBuilder(
      column: $table.partyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get issuedAt => $composableBuilder(
      column: $table.issuedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get taxablePaise => $composableBuilder(
      column: $table.taxablePaise,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cgstPaise => $composableBuilder(
      column: $table.cgstPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sgstPaise => $composableBuilder(
      column: $table.sgstPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get igstPaise => $composableBuilder(
      column: $table.igstPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get roundOffPaise => $composableBuilder(
      column: $table.roundOffPaise,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalPaise => $composableBuilder(
      column: $table.totalPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get snapshotJson => $composableBuilder(
      column: $table.snapshotJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get refDocumentId => $composableBuilder(
      column: $table.refDocumentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnOrderings(column));
}

class $$DocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get docType =>
      $composableBuilder(column: $table.docType, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<DateTime> get issuedAt =>
      $composableBuilder(column: $table.issuedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get taxablePaise => $composableBuilder(
      column: $table.taxablePaise, builder: (column) => column);

  GeneratedColumn<int> get cgstPaise =>
      $composableBuilder(column: $table.cgstPaise, builder: (column) => column);

  GeneratedColumn<int> get sgstPaise =>
      $composableBuilder(column: $table.sgstPaise, builder: (column) => column);

  GeneratedColumn<int> get igstPaise =>
      $composableBuilder(column: $table.igstPaise, builder: (column) => column);

  GeneratedColumn<int> get roundOffPaise => $composableBuilder(
      column: $table.roundOffPaise, builder: (column) => column);

  GeneratedColumn<int> get totalPaise => $composableBuilder(
      column: $table.totalPaise, builder: (column) => column);

  GeneratedColumn<String> get snapshotJson => $composableBuilder(
      column: $table.snapshotJson, builder: (column) => column);

  GeneratedColumn<String> get refDocumentId => $composableBuilder(
      column: $table.refDocumentId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);
}

class $$DocumentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DocumentsTable,
    Document,
    $$DocumentsTableFilterComposer,
    $$DocumentsTableOrderingComposer,
    $$DocumentsTableAnnotationComposer,
    $$DocumentsTableCreateCompanionBuilder,
    $$DocumentsTableUpdateCompanionBuilder,
    (Document, BaseReferences<_$AppDatabase, $DocumentsTable, Document>),
    Document,
    PrefetchHooks Function()> {
  $$DocumentsTableTableManager(_$AppDatabase db, $DocumentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> businessId = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String> docType = const Value.absent(),
            Value<String> number = const Value.absent(),
            Value<String?> partyId = const Value.absent(),
            Value<DateTime> issuedAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> taxablePaise = const Value.absent(),
            Value<int> cgstPaise = const Value.absent(),
            Value<int> sgstPaise = const Value.absent(),
            Value<int> igstPaise = const Value.absent(),
            Value<int> roundOffPaise = const Value.absent(),
            Value<int> totalPaise = const Value.absent(),
            Value<String> snapshotJson = const Value.absent(),
            Value<String?> refDocumentId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int?> serverSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentsCompanion(
            id: id,
            businessId: businessId,
            deviceId: deviceId,
            docType: docType,
            number: number,
            partyId: partyId,
            issuedAt: issuedAt,
            status: status,
            taxablePaise: taxablePaise,
            cgstPaise: cgstPaise,
            sgstPaise: sgstPaise,
            igstPaise: igstPaise,
            roundOffPaise: roundOffPaise,
            totalPaise: totalPaise,
            snapshotJson: snapshotJson,
            refDocumentId: refDocumentId,
            createdAt: createdAt,
            serverSeq: serverSeq,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String businessId,
            required String deviceId,
            required String docType,
            required String number,
            Value<String?> partyId = const Value.absent(),
            required DateTime issuedAt,
            required String status,
            required int taxablePaise,
            required int cgstPaise,
            required int sgstPaise,
            required int igstPaise,
            required int roundOffPaise,
            required int totalPaise,
            required String snapshotJson,
            Value<String?> refDocumentId = const Value.absent(),
            required DateTime createdAt,
            Value<int?> serverSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentsCompanion.insert(
            id: id,
            businessId: businessId,
            deviceId: deviceId,
            docType: docType,
            number: number,
            partyId: partyId,
            issuedAt: issuedAt,
            status: status,
            taxablePaise: taxablePaise,
            cgstPaise: cgstPaise,
            sgstPaise: sgstPaise,
            igstPaise: igstPaise,
            roundOffPaise: roundOffPaise,
            totalPaise: totalPaise,
            snapshotJson: snapshotJson,
            refDocumentId: refDocumentId,
            createdAt: createdAt,
            serverSeq: serverSeq,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DocumentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DocumentsTable,
    Document,
    $$DocumentsTableFilterComposer,
    $$DocumentsTableOrderingComposer,
    $$DocumentsTableAnnotationComposer,
    $$DocumentsTableCreateCompanionBuilder,
    $$DocumentsTableUpdateCompanionBuilder,
    (Document, BaseReferences<_$AppDatabase, $DocumentsTable, Document>),
    Document,
    PrefetchHooks Function()>;
typedef $$DocumentLinesTableCreateCompanionBuilder = DocumentLinesCompanion
    Function({
  required String id,
  required String documentId,
  required String businessId,
  required String productId,
  required String name,
  required String hsn,
  required int qtyMilli,
  required int ratePaise,
  required int discountPaise,
  required int gstRateBp,
  required int taxablePaise,
  required int cgstPaise,
  required int sgstPaise,
  required int igstPaise,
  required int lineTotalPaise,
  required DateTime createdAt,
  Value<int?> serverSeq,
  Value<int> rowid,
});
typedef $$DocumentLinesTableUpdateCompanionBuilder = DocumentLinesCompanion
    Function({
  Value<String> id,
  Value<String> documentId,
  Value<String> businessId,
  Value<String> productId,
  Value<String> name,
  Value<String> hsn,
  Value<int> qtyMilli,
  Value<int> ratePaise,
  Value<int> discountPaise,
  Value<int> gstRateBp,
  Value<int> taxablePaise,
  Value<int> cgstPaise,
  Value<int> sgstPaise,
  Value<int> igstPaise,
  Value<int> lineTotalPaise,
  Value<DateTime> createdAt,
  Value<int?> serverSeq,
  Value<int> rowid,
});

class $$DocumentLinesTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentLinesTable> {
  $$DocumentLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hsn => $composableBuilder(
      column: $table.hsn, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qtyMilli => $composableBuilder(
      column: $table.qtyMilli, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ratePaise => $composableBuilder(
      column: $table.ratePaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get discountPaise => $composableBuilder(
      column: $table.discountPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gstRateBp => $composableBuilder(
      column: $table.gstRateBp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get taxablePaise => $composableBuilder(
      column: $table.taxablePaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cgstPaise => $composableBuilder(
      column: $table.cgstPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sgstPaise => $composableBuilder(
      column: $table.sgstPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get igstPaise => $composableBuilder(
      column: $table.igstPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lineTotalPaise => $composableBuilder(
      column: $table.lineTotalPaise,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnFilters(column));
}

class $$DocumentLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentLinesTable> {
  $$DocumentLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hsn => $composableBuilder(
      column: $table.hsn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qtyMilli => $composableBuilder(
      column: $table.qtyMilli, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ratePaise => $composableBuilder(
      column: $table.ratePaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get discountPaise => $composableBuilder(
      column: $table.discountPaise,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gstRateBp => $composableBuilder(
      column: $table.gstRateBp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get taxablePaise => $composableBuilder(
      column: $table.taxablePaise,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cgstPaise => $composableBuilder(
      column: $table.cgstPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sgstPaise => $composableBuilder(
      column: $table.sgstPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get igstPaise => $composableBuilder(
      column: $table.igstPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lineTotalPaise => $composableBuilder(
      column: $table.lineTotalPaise,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnOrderings(column));
}

class $$DocumentLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentLinesTable> {
  $$DocumentLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get hsn =>
      $composableBuilder(column: $table.hsn, builder: (column) => column);

  GeneratedColumn<int> get qtyMilli =>
      $composableBuilder(column: $table.qtyMilli, builder: (column) => column);

  GeneratedColumn<int> get ratePaise =>
      $composableBuilder(column: $table.ratePaise, builder: (column) => column);

  GeneratedColumn<int> get discountPaise => $composableBuilder(
      column: $table.discountPaise, builder: (column) => column);

  GeneratedColumn<int> get gstRateBp =>
      $composableBuilder(column: $table.gstRateBp, builder: (column) => column);

  GeneratedColumn<int> get taxablePaise => $composableBuilder(
      column: $table.taxablePaise, builder: (column) => column);

  GeneratedColumn<int> get cgstPaise =>
      $composableBuilder(column: $table.cgstPaise, builder: (column) => column);

  GeneratedColumn<int> get sgstPaise =>
      $composableBuilder(column: $table.sgstPaise, builder: (column) => column);

  GeneratedColumn<int> get igstPaise =>
      $composableBuilder(column: $table.igstPaise, builder: (column) => column);

  GeneratedColumn<int> get lineTotalPaise => $composableBuilder(
      column: $table.lineTotalPaise, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);
}

class $$DocumentLinesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DocumentLinesTable,
    DocumentLine,
    $$DocumentLinesTableFilterComposer,
    $$DocumentLinesTableOrderingComposer,
    $$DocumentLinesTableAnnotationComposer,
    $$DocumentLinesTableCreateCompanionBuilder,
    $$DocumentLinesTableUpdateCompanionBuilder,
    (
      DocumentLine,
      BaseReferences<_$AppDatabase, $DocumentLinesTable, DocumentLine>
    ),
    DocumentLine,
    PrefetchHooks Function()> {
  $$DocumentLinesTableTableManager(_$AppDatabase db, $DocumentLinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> documentId = const Value.absent(),
            Value<String> businessId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> hsn = const Value.absent(),
            Value<int> qtyMilli = const Value.absent(),
            Value<int> ratePaise = const Value.absent(),
            Value<int> discountPaise = const Value.absent(),
            Value<int> gstRateBp = const Value.absent(),
            Value<int> taxablePaise = const Value.absent(),
            Value<int> cgstPaise = const Value.absent(),
            Value<int> sgstPaise = const Value.absent(),
            Value<int> igstPaise = const Value.absent(),
            Value<int> lineTotalPaise = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int?> serverSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentLinesCompanion(
            id: id,
            documentId: documentId,
            businessId: businessId,
            productId: productId,
            name: name,
            hsn: hsn,
            qtyMilli: qtyMilli,
            ratePaise: ratePaise,
            discountPaise: discountPaise,
            gstRateBp: gstRateBp,
            taxablePaise: taxablePaise,
            cgstPaise: cgstPaise,
            sgstPaise: sgstPaise,
            igstPaise: igstPaise,
            lineTotalPaise: lineTotalPaise,
            createdAt: createdAt,
            serverSeq: serverSeq,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String documentId,
            required String businessId,
            required String productId,
            required String name,
            required String hsn,
            required int qtyMilli,
            required int ratePaise,
            required int discountPaise,
            required int gstRateBp,
            required int taxablePaise,
            required int cgstPaise,
            required int sgstPaise,
            required int igstPaise,
            required int lineTotalPaise,
            required DateTime createdAt,
            Value<int?> serverSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentLinesCompanion.insert(
            id: id,
            documentId: documentId,
            businessId: businessId,
            productId: productId,
            name: name,
            hsn: hsn,
            qtyMilli: qtyMilli,
            ratePaise: ratePaise,
            discountPaise: discountPaise,
            gstRateBp: gstRateBp,
            taxablePaise: taxablePaise,
            cgstPaise: cgstPaise,
            sgstPaise: sgstPaise,
            igstPaise: igstPaise,
            lineTotalPaise: lineTotalPaise,
            createdAt: createdAt,
            serverSeq: serverSeq,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DocumentLinesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DocumentLinesTable,
    DocumentLine,
    $$DocumentLinesTableFilterComposer,
    $$DocumentLinesTableOrderingComposer,
    $$DocumentLinesTableAnnotationComposer,
    $$DocumentLinesTableCreateCompanionBuilder,
    $$DocumentLinesTableUpdateCompanionBuilder,
    (
      DocumentLine,
      BaseReferences<_$AppDatabase, $DocumentLinesTable, DocumentLine>
    ),
    DocumentLine,
    PrefetchHooks Function()>;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  required String id,
  required String businessId,
  Value<String?> documentId,
  Value<String?> partyId,
  required String method,
  required int amountPaise,
  Value<String?> note,
  required DateTime paidAt,
  required DateTime createdAt,
  Value<int?> serverSeq,
  Value<int> rowid,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<String> id,
  Value<String> businessId,
  Value<String?> documentId,
  Value<String?> partyId,
  Value<String> method,
  Value<int> amountPaise,
  Value<String?> note,
  Value<DateTime> paidAt,
  Value<DateTime> createdAt,
  Value<int?> serverSeq,
  Value<int> rowid,
});

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partyId => $composableBuilder(
      column: $table.partyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountPaise => $composableBuilder(
      column: $table.amountPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get paidAt => $composableBuilder(
      column: $table.paidAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnFilters(column));
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partyId => $composableBuilder(
      column: $table.partyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountPaise => $composableBuilder(
      column: $table.amountPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
      column: $table.paidAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnOrderings(column));
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => column);

  GeneratedColumn<String> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => column);

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
      column: $table.amountPaise, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);
}

class $$PaymentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
    Payment,
    PrefetchHooks Function()> {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> businessId = const Value.absent(),
            Value<String?> documentId = const Value.absent(),
            Value<String?> partyId = const Value.absent(),
            Value<String> method = const Value.absent(),
            Value<int> amountPaise = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<DateTime> paidAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int?> serverSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion(
            id: id,
            businessId: businessId,
            documentId: documentId,
            partyId: partyId,
            method: method,
            amountPaise: amountPaise,
            note: note,
            paidAt: paidAt,
            createdAt: createdAt,
            serverSeq: serverSeq,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String businessId,
            Value<String?> documentId = const Value.absent(),
            Value<String?> partyId = const Value.absent(),
            required String method,
            required int amountPaise,
            Value<String?> note = const Value.absent(),
            required DateTime paidAt,
            required DateTime createdAt,
            Value<int?> serverSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion.insert(
            id: id,
            businessId: businessId,
            documentId: documentId,
            partyId: partyId,
            method: method,
            amountPaise: amountPaise,
            note: note,
            paidAt: paidAt,
            createdAt: createdAt,
            serverSeq: serverSeq,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PaymentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
    Payment,
    PrefetchHooks Function()>;
typedef $$StockMovementsTableCreateCompanionBuilder = StockMovementsCompanion
    Function({
  required String id,
  required String businessId,
  required String productId,
  required int qtyMilli,
  required String reason,
  Value<String?> documentId,
  required DateTime createdAt,
  Value<int?> serverSeq,
  Value<int> rowid,
});
typedef $$StockMovementsTableUpdateCompanionBuilder = StockMovementsCompanion
    Function({
  Value<String> id,
  Value<String> businessId,
  Value<String> productId,
  Value<int> qtyMilli,
  Value<String> reason,
  Value<String?> documentId,
  Value<DateTime> createdAt,
  Value<int?> serverSeq,
  Value<int> rowid,
});

class $$StockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qtyMilli => $composableBuilder(
      column: $table.qtyMilli, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnFilters(column));
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qtyMilli => $composableBuilder(
      column: $table.qtyMilli, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverSeq => $composableBuilder(
      column: $table.serverSeq, builder: (column) => ColumnOrderings(column));
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get qtyMilli =>
      $composableBuilder(column: $table.qtyMilli, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get serverSeq =>
      $composableBuilder(column: $table.serverSeq, builder: (column) => column);
}

class $$StockMovementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StockMovementsTable,
    StockMovement,
    $$StockMovementsTableFilterComposer,
    $$StockMovementsTableOrderingComposer,
    $$StockMovementsTableAnnotationComposer,
    $$StockMovementsTableCreateCompanionBuilder,
    $$StockMovementsTableUpdateCompanionBuilder,
    (
      StockMovement,
      BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement>
    ),
    StockMovement,
    PrefetchHooks Function()> {
  $$StockMovementsTableTableManager(
      _$AppDatabase db, $StockMovementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> businessId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<int> qtyMilli = const Value.absent(),
            Value<String> reason = const Value.absent(),
            Value<String?> documentId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int?> serverSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StockMovementsCompanion(
            id: id,
            businessId: businessId,
            productId: productId,
            qtyMilli: qtyMilli,
            reason: reason,
            documentId: documentId,
            createdAt: createdAt,
            serverSeq: serverSeq,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String businessId,
            required String productId,
            required int qtyMilli,
            required String reason,
            Value<String?> documentId = const Value.absent(),
            required DateTime createdAt,
            Value<int?> serverSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StockMovementsCompanion.insert(
            id: id,
            businessId: businessId,
            productId: productId,
            qtyMilli: qtyMilli,
            reason: reason,
            documentId: documentId,
            createdAt: createdAt,
            serverSeq: serverSeq,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StockMovementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StockMovementsTable,
    StockMovement,
    $$StockMovementsTableFilterComposer,
    $$StockMovementsTableOrderingComposer,
    $$StockMovementsTableAnnotationComposer,
    $$StockMovementsTableCreateCompanionBuilder,
    $$StockMovementsTableUpdateCompanionBuilder,
    (
      StockMovement,
      BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement>
    ),
    StockMovement,
    PrefetchHooks Function()>;
typedef $$OutboxCommandsTableCreateCompanionBuilder = OutboxCommandsCompanion
    Function({
  required String id,
  required String businessId,
  required String deviceId,
  required String commandType,
  required String payloadJson,
  required String status,
  required DateTime createdAt,
  Value<String?> lastError,
  Value<int> rowid,
});
typedef $$OutboxCommandsTableUpdateCompanionBuilder = OutboxCommandsCompanion
    Function({
  Value<String> id,
  Value<String> businessId,
  Value<String> deviceId,
  Value<String> commandType,
  Value<String> payloadJson,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<String?> lastError,
  Value<int> rowid,
});

class $$OutboxCommandsTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxCommandsTable> {
  $$OutboxCommandsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commandType => $composableBuilder(
      column: $table.commandType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));
}

class $$OutboxCommandsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxCommandsTable> {
  $$OutboxCommandsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commandType => $composableBuilder(
      column: $table.commandType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));
}

class $$OutboxCommandsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxCommandsTable> {
  $$OutboxCommandsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get commandType => $composableBuilder(
      column: $table.commandType, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$OutboxCommandsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutboxCommandsTable,
    OutboxCommand,
    $$OutboxCommandsTableFilterComposer,
    $$OutboxCommandsTableOrderingComposer,
    $$OutboxCommandsTableAnnotationComposer,
    $$OutboxCommandsTableCreateCompanionBuilder,
    $$OutboxCommandsTableUpdateCompanionBuilder,
    (
      OutboxCommand,
      BaseReferences<_$AppDatabase, $OutboxCommandsTable, OutboxCommand>
    ),
    OutboxCommand,
    PrefetchHooks Function()> {
  $$OutboxCommandsTableTableManager(
      _$AppDatabase db, $OutboxCommandsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxCommandsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxCommandsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxCommandsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> businessId = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String> commandType = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxCommandsCompanion(
            id: id,
            businessId: businessId,
            deviceId: deviceId,
            commandType: commandType,
            payloadJson: payloadJson,
            status: status,
            createdAt: createdAt,
            lastError: lastError,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String businessId,
            required String deviceId,
            required String commandType,
            required String payloadJson,
            required String status,
            required DateTime createdAt,
            Value<String?> lastError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxCommandsCompanion.insert(
            id: id,
            businessId: businessId,
            deviceId: deviceId,
            commandType: commandType,
            payloadJson: payloadJson,
            status: status,
            createdAt: createdAt,
            lastError: lastError,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxCommandsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutboxCommandsTable,
    OutboxCommand,
    $$OutboxCommandsTableFilterComposer,
    $$OutboxCommandsTableOrderingComposer,
    $$OutboxCommandsTableAnnotationComposer,
    $$OutboxCommandsTableCreateCompanionBuilder,
    $$OutboxCommandsTableUpdateCompanionBuilder,
    (
      OutboxCommand,
      BaseReferences<_$AppDatabase, $OutboxCommandsTable, OutboxCommand>
    ),
    OutboxCommand,
    PrefetchHooks Function()>;
typedef $$DraftCartsTableCreateCompanionBuilder = DraftCartsCompanion Function({
  required String id,
  required String businessId,
  Value<String?> partyId,
  required String cartJson,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$DraftCartsTableUpdateCompanionBuilder = DraftCartsCompanion Function({
  Value<String> id,
  Value<String> businessId,
  Value<String?> partyId,
  Value<String> cartJson,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$DraftCartsTableFilterComposer
    extends Composer<_$AppDatabase, $DraftCartsTable> {
  $$DraftCartsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partyId => $composableBuilder(
      column: $table.partyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cartJson => $composableBuilder(
      column: $table.cartJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DraftCartsTableOrderingComposer
    extends Composer<_$AppDatabase, $DraftCartsTable> {
  $$DraftCartsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partyId => $composableBuilder(
      column: $table.partyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cartJson => $composableBuilder(
      column: $table.cartJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DraftCartsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DraftCartsTable> {
  $$DraftCartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => column);

  GeneratedColumn<String> get partyId =>
      $composableBuilder(column: $table.partyId, builder: (column) => column);

  GeneratedColumn<String> get cartJson =>
      $composableBuilder(column: $table.cartJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DraftCartsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DraftCartsTable,
    DraftCart,
    $$DraftCartsTableFilterComposer,
    $$DraftCartsTableOrderingComposer,
    $$DraftCartsTableAnnotationComposer,
    $$DraftCartsTableCreateCompanionBuilder,
    $$DraftCartsTableUpdateCompanionBuilder,
    (DraftCart, BaseReferences<_$AppDatabase, $DraftCartsTable, DraftCart>),
    DraftCart,
    PrefetchHooks Function()> {
  $$DraftCartsTableTableManager(_$AppDatabase db, $DraftCartsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DraftCartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DraftCartsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DraftCartsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> businessId = const Value.absent(),
            Value<String?> partyId = const Value.absent(),
            Value<String> cartJson = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DraftCartsCompanion(
            id: id,
            businessId: businessId,
            partyId: partyId,
            cartJson: cartJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String businessId,
            Value<String?> partyId = const Value.absent(),
            required String cartJson,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DraftCartsCompanion.insert(
            id: id,
            businessId: businessId,
            partyId: partyId,
            cartJson: cartJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DraftCartsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DraftCartsTable,
    DraftCart,
    $$DraftCartsTableFilterComposer,
    $$DraftCartsTableOrderingComposer,
    $$DraftCartsTableAnnotationComposer,
    $$DraftCartsTableCreateCompanionBuilder,
    $$DraftCartsTableUpdateCompanionBuilder,
    (DraftCart, BaseReferences<_$AppDatabase, $DraftCartsTable, DraftCart>),
    DraftCart,
    PrefetchHooks Function()>;
typedef $$SyncStateTableTableCreateCompanionBuilder = SyncStateTableCompanion
    Function({
  required String tableNameCol,
  Value<int> lastSeq,
  Value<int> rowid,
});
typedef $$SyncStateTableTableUpdateCompanionBuilder = SyncStateTableCompanion
    Function({
  Value<String> tableNameCol,
  Value<int> lastSeq,
  Value<int> rowid,
});

class $$SyncStateTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTableTable> {
  $$SyncStateTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tableNameCol => $composableBuilder(
      column: $table.tableNameCol, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastSeq => $composableBuilder(
      column: $table.lastSeq, builder: (column) => ColumnFilters(column));
}

class $$SyncStateTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTableTable> {
  $$SyncStateTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tableNameCol => $composableBuilder(
      column: $table.tableNameCol,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastSeq => $composableBuilder(
      column: $table.lastSeq, builder: (column) => ColumnOrderings(column));
}

class $$SyncStateTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTableTable> {
  $$SyncStateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tableNameCol => $composableBuilder(
      column: $table.tableNameCol, builder: (column) => column);

  GeneratedColumn<int> get lastSeq =>
      $composableBuilder(column: $table.lastSeq, builder: (column) => column);
}

class $$SyncStateTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncStateTableTable,
    SyncState,
    $$SyncStateTableTableFilterComposer,
    $$SyncStateTableTableOrderingComposer,
    $$SyncStateTableTableAnnotationComposer,
    $$SyncStateTableTableCreateCompanionBuilder,
    $$SyncStateTableTableUpdateCompanionBuilder,
    (SyncState, BaseReferences<_$AppDatabase, $SyncStateTableTable, SyncState>),
    SyncState,
    PrefetchHooks Function()> {
  $$SyncStateTableTableTableManager(
      _$AppDatabase db, $SyncStateTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> tableNameCol = const Value.absent(),
            Value<int> lastSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStateTableCompanion(
            tableNameCol: tableNameCol,
            lastSeq: lastSeq,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String tableNameCol,
            Value<int> lastSeq = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStateTableCompanion.insert(
            tableNameCol: tableNameCol,
            lastSeq: lastSeq,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncStateTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncStateTableTable,
    SyncState,
    $$SyncStateTableTableFilterComposer,
    $$SyncStateTableTableOrderingComposer,
    $$SyncStateTableTableAnnotationComposer,
    $$SyncStateTableTableCreateCompanionBuilder,
    $$SyncStateTableTableUpdateCompanionBuilder,
    (SyncState, BaseReferences<_$AppDatabase, $SyncStateTableTable, SyncState>),
    SyncState,
    PrefetchHooks Function()>;
typedef $$AppSettingsTableTableCreateCompanionBuilder
    = AppSettingsTableCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppSettingsTableTableUpdateCompanionBuilder
    = AppSettingsTableCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTableTable,
    AppSetting,
    $$AppSettingsTableTableFilterComposer,
    $$AppSettingsTableTableOrderingComposer,
    $$AppSettingsTableTableAnnotationComposer,
    $$AppSettingsTableTableCreateCompanionBuilder,
    $$AppSettingsTableTableUpdateCompanionBuilder,
    (
      AppSetting,
      BaseReferences<_$AppDatabase, $AppSettingsTableTable, AppSetting>
    ),
    AppSetting,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableTableManager(
      _$AppDatabase db, $AppSettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsTableCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsTableCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTableTable,
    AppSetting,
    $$AppSettingsTableTableFilterComposer,
    $$AppSettingsTableTableOrderingComposer,
    $$AppSettingsTableTableAnnotationComposer,
    $$AppSettingsTableTableCreateCompanionBuilder,
    $$AppSettingsTableTableUpdateCompanionBuilder,
    (
      AppSetting,
      BaseReferences<_$AppDatabase, $AppSettingsTableTable, AppSetting>
    ),
    AppSetting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BusinessesTableTableManager get businesses =>
      $$BusinessesTableTableManager(_db, _db.businesses);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$PartiesTableTableManager get parties =>
      $$PartiesTableTableManager(_db, _db.parties);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$DocumentSeriesTableTableManager get documentSeries =>
      $$DocumentSeriesTableTableManager(_db, _db.documentSeries);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db, _db.documents);
  $$DocumentLinesTableTableManager get documentLines =>
      $$DocumentLinesTableTableManager(_db, _db.documentLines);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
  $$OutboxCommandsTableTableManager get outboxCommands =>
      $$OutboxCommandsTableTableManager(_db, _db.outboxCommands);
  $$DraftCartsTableTableManager get draftCarts =>
      $$DraftCartsTableTableManager(_db, _db.draftCarts);
  $$SyncStateTableTableTableManager get syncStateTable =>
      $$SyncStateTableTableTableManager(_db, _db.syncStateTable);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
}
