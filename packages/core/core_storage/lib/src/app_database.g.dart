// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BacktestRunsTable extends BacktestRuns
    with TableInfo<$BacktestRunsTable, BacktestRun> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BacktestRunsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strategyNameMeta = const VerificationMeta(
    'strategyName',
  );
  @override
  late final GeneratedColumn<String> strategyName = GeneratedColumn<String>(
    'strategy_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fastEmaPeriodMeta = const VerificationMeta(
    'fastEmaPeriod',
  );
  @override
  late final GeneratedColumn<int> fastEmaPeriod = GeneratedColumn<int>(
    'fast_ema_period',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slowEmaPeriodMeta = const VerificationMeta(
    'slowEmaPeriod',
  );
  @override
  late final GeneratedColumn<int> slowEmaPeriod = GeneratedColumn<int>(
    'slow_ema_period',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalTradesMeta = const VerificationMeta(
    'totalTrades',
  );
  @override
  late final GeneratedColumn<int> totalTrades = GeneratedColumn<int>(
    'total_trades',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _winRatePercentMeta = const VerificationMeta(
    'winRatePercent',
  );
  @override
  late final GeneratedColumn<double> winRatePercent = GeneratedColumn<double>(
    'win_rate_percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _netProfitPercentMeta = const VerificationMeta(
    'netProfitPercent',
  );
  @override
  late final GeneratedColumn<double> netProfitPercent = GeneratedColumn<double>(
    'net_profit_percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxDrawdownPercentMeta =
      const VerificationMeta('maxDrawdownPercent');
  @override
  late final GeneratedColumn<double> maxDrawdownPercent =
      GeneratedColumn<double>(
        'max_drawdown_percent',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sharpeRatioMeta = const VerificationMeta(
    'sharpeRatio',
  );
  @override
  late final GeneratedColumn<double> sharpeRatio = GeneratedColumn<double>(
    'sharpe_ratio',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equityCurveJsonMeta = const VerificationMeta(
    'equityCurveJson',
  );
  @override
  late final GeneratedColumn<String> equityCurveJson = GeneratedColumn<String>(
    'equity_curve_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    symbol,
    strategyName,
    fastEmaPeriod,
    slowEmaPeriod,
    totalTrades,
    winRatePercent,
    netProfitPercent,
    maxDrawdownPercent,
    sharpeRatio,
    equityCurveJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backtest_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<BacktestRun> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('strategy_name')) {
      context.handle(
        _strategyNameMeta,
        strategyName.isAcceptableOrUnknown(
          data['strategy_name']!,
          _strategyNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_strategyNameMeta);
    }
    if (data.containsKey('fast_ema_period')) {
      context.handle(
        _fastEmaPeriodMeta,
        fastEmaPeriod.isAcceptableOrUnknown(
          data['fast_ema_period']!,
          _fastEmaPeriodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fastEmaPeriodMeta);
    }
    if (data.containsKey('slow_ema_period')) {
      context.handle(
        _slowEmaPeriodMeta,
        slowEmaPeriod.isAcceptableOrUnknown(
          data['slow_ema_period']!,
          _slowEmaPeriodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_slowEmaPeriodMeta);
    }
    if (data.containsKey('total_trades')) {
      context.handle(
        _totalTradesMeta,
        totalTrades.isAcceptableOrUnknown(
          data['total_trades']!,
          _totalTradesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalTradesMeta);
    }
    if (data.containsKey('win_rate_percent')) {
      context.handle(
        _winRatePercentMeta,
        winRatePercent.isAcceptableOrUnknown(
          data['win_rate_percent']!,
          _winRatePercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_winRatePercentMeta);
    }
    if (data.containsKey('net_profit_percent')) {
      context.handle(
        _netProfitPercentMeta,
        netProfitPercent.isAcceptableOrUnknown(
          data['net_profit_percent']!,
          _netProfitPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_netProfitPercentMeta);
    }
    if (data.containsKey('max_drawdown_percent')) {
      context.handle(
        _maxDrawdownPercentMeta,
        maxDrawdownPercent.isAcceptableOrUnknown(
          data['max_drawdown_percent']!,
          _maxDrawdownPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_maxDrawdownPercentMeta);
    }
    if (data.containsKey('sharpe_ratio')) {
      context.handle(
        _sharpeRatioMeta,
        sharpeRatio.isAcceptableOrUnknown(
          data['sharpe_ratio']!,
          _sharpeRatioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sharpeRatioMeta);
    }
    if (data.containsKey('equity_curve_json')) {
      context.handle(
        _equityCurveJsonMeta,
        equityCurveJson.isAcceptableOrUnknown(
          data['equity_curve_json']!,
          _equityCurveJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_equityCurveJsonMeta);
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
  BacktestRun map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BacktestRun(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      strategyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strategy_name'],
      )!,
      fastEmaPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fast_ema_period'],
      )!,
      slowEmaPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slow_ema_period'],
      )!,
      totalTrades: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_trades'],
      )!,
      winRatePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}win_rate_percent'],
      )!,
      netProfitPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}net_profit_percent'],
      )!,
      maxDrawdownPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_drawdown_percent'],
      )!,
      sharpeRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sharpe_ratio'],
      )!,
      equityCurveJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equity_curve_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BacktestRunsTable createAlias(String alias) {
    return $BacktestRunsTable(attachedDatabase, alias);
  }
}

class BacktestRun extends DataClass implements Insertable<BacktestRun> {
  final int id;
  final String symbol;
  final String strategyName;
  final int fastEmaPeriod;
  final int slowEmaPeriod;
  final int totalTrades;
  final double winRatePercent;
  final double netProfitPercent;
  final double maxDrawdownPercent;
  final double sharpeRatio;
  final String equityCurveJson;
  final DateTime createdAt;
  const BacktestRun({
    required this.id,
    required this.symbol,
    required this.strategyName,
    required this.fastEmaPeriod,
    required this.slowEmaPeriod,
    required this.totalTrades,
    required this.winRatePercent,
    required this.netProfitPercent,
    required this.maxDrawdownPercent,
    required this.sharpeRatio,
    required this.equityCurveJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['symbol'] = Variable<String>(symbol);
    map['strategy_name'] = Variable<String>(strategyName);
    map['fast_ema_period'] = Variable<int>(fastEmaPeriod);
    map['slow_ema_period'] = Variable<int>(slowEmaPeriod);
    map['total_trades'] = Variable<int>(totalTrades);
    map['win_rate_percent'] = Variable<double>(winRatePercent);
    map['net_profit_percent'] = Variable<double>(netProfitPercent);
    map['max_drawdown_percent'] = Variable<double>(maxDrawdownPercent);
    map['sharpe_ratio'] = Variable<double>(sharpeRatio);
    map['equity_curve_json'] = Variable<String>(equityCurveJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BacktestRunsCompanion toCompanion(bool nullToAbsent) {
    return BacktestRunsCompanion(
      id: Value(id),
      symbol: Value(symbol),
      strategyName: Value(strategyName),
      fastEmaPeriod: Value(fastEmaPeriod),
      slowEmaPeriod: Value(slowEmaPeriod),
      totalTrades: Value(totalTrades),
      winRatePercent: Value(winRatePercent),
      netProfitPercent: Value(netProfitPercent),
      maxDrawdownPercent: Value(maxDrawdownPercent),
      sharpeRatio: Value(sharpeRatio),
      equityCurveJson: Value(equityCurveJson),
      createdAt: Value(createdAt),
    );
  }

  factory BacktestRun.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BacktestRun(
      id: serializer.fromJson<int>(json['id']),
      symbol: serializer.fromJson<String>(json['symbol']),
      strategyName: serializer.fromJson<String>(json['strategyName']),
      fastEmaPeriod: serializer.fromJson<int>(json['fastEmaPeriod']),
      slowEmaPeriod: serializer.fromJson<int>(json['slowEmaPeriod']),
      totalTrades: serializer.fromJson<int>(json['totalTrades']),
      winRatePercent: serializer.fromJson<double>(json['winRatePercent']),
      netProfitPercent: serializer.fromJson<double>(json['netProfitPercent']),
      maxDrawdownPercent: serializer.fromJson<double>(
        json['maxDrawdownPercent'],
      ),
      sharpeRatio: serializer.fromJson<double>(json['sharpeRatio']),
      equityCurveJson: serializer.fromJson<String>(json['equityCurveJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'symbol': serializer.toJson<String>(symbol),
      'strategyName': serializer.toJson<String>(strategyName),
      'fastEmaPeriod': serializer.toJson<int>(fastEmaPeriod),
      'slowEmaPeriod': serializer.toJson<int>(slowEmaPeriod),
      'totalTrades': serializer.toJson<int>(totalTrades),
      'winRatePercent': serializer.toJson<double>(winRatePercent),
      'netProfitPercent': serializer.toJson<double>(netProfitPercent),
      'maxDrawdownPercent': serializer.toJson<double>(maxDrawdownPercent),
      'sharpeRatio': serializer.toJson<double>(sharpeRatio),
      'equityCurveJson': serializer.toJson<String>(equityCurveJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BacktestRun copyWith({
    int? id,
    String? symbol,
    String? strategyName,
    int? fastEmaPeriod,
    int? slowEmaPeriod,
    int? totalTrades,
    double? winRatePercent,
    double? netProfitPercent,
    double? maxDrawdownPercent,
    double? sharpeRatio,
    String? equityCurveJson,
    DateTime? createdAt,
  }) => BacktestRun(
    id: id ?? this.id,
    symbol: symbol ?? this.symbol,
    strategyName: strategyName ?? this.strategyName,
    fastEmaPeriod: fastEmaPeriod ?? this.fastEmaPeriod,
    slowEmaPeriod: slowEmaPeriod ?? this.slowEmaPeriod,
    totalTrades: totalTrades ?? this.totalTrades,
    winRatePercent: winRatePercent ?? this.winRatePercent,
    netProfitPercent: netProfitPercent ?? this.netProfitPercent,
    maxDrawdownPercent: maxDrawdownPercent ?? this.maxDrawdownPercent,
    sharpeRatio: sharpeRatio ?? this.sharpeRatio,
    equityCurveJson: equityCurveJson ?? this.equityCurveJson,
    createdAt: createdAt ?? this.createdAt,
  );
  BacktestRun copyWithCompanion(BacktestRunsCompanion data) {
    return BacktestRun(
      id: data.id.present ? data.id.value : this.id,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      strategyName: data.strategyName.present
          ? data.strategyName.value
          : this.strategyName,
      fastEmaPeriod: data.fastEmaPeriod.present
          ? data.fastEmaPeriod.value
          : this.fastEmaPeriod,
      slowEmaPeriod: data.slowEmaPeriod.present
          ? data.slowEmaPeriod.value
          : this.slowEmaPeriod,
      totalTrades: data.totalTrades.present
          ? data.totalTrades.value
          : this.totalTrades,
      winRatePercent: data.winRatePercent.present
          ? data.winRatePercent.value
          : this.winRatePercent,
      netProfitPercent: data.netProfitPercent.present
          ? data.netProfitPercent.value
          : this.netProfitPercent,
      maxDrawdownPercent: data.maxDrawdownPercent.present
          ? data.maxDrawdownPercent.value
          : this.maxDrawdownPercent,
      sharpeRatio: data.sharpeRatio.present
          ? data.sharpeRatio.value
          : this.sharpeRatio,
      equityCurveJson: data.equityCurveJson.present
          ? data.equityCurveJson.value
          : this.equityCurveJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BacktestRun(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('strategyName: $strategyName, ')
          ..write('fastEmaPeriod: $fastEmaPeriod, ')
          ..write('slowEmaPeriod: $slowEmaPeriod, ')
          ..write('totalTrades: $totalTrades, ')
          ..write('winRatePercent: $winRatePercent, ')
          ..write('netProfitPercent: $netProfitPercent, ')
          ..write('maxDrawdownPercent: $maxDrawdownPercent, ')
          ..write('sharpeRatio: $sharpeRatio, ')
          ..write('equityCurveJson: $equityCurveJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    symbol,
    strategyName,
    fastEmaPeriod,
    slowEmaPeriod,
    totalTrades,
    winRatePercent,
    netProfitPercent,
    maxDrawdownPercent,
    sharpeRatio,
    equityCurveJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BacktestRun &&
          other.id == this.id &&
          other.symbol == this.symbol &&
          other.strategyName == this.strategyName &&
          other.fastEmaPeriod == this.fastEmaPeriod &&
          other.slowEmaPeriod == this.slowEmaPeriod &&
          other.totalTrades == this.totalTrades &&
          other.winRatePercent == this.winRatePercent &&
          other.netProfitPercent == this.netProfitPercent &&
          other.maxDrawdownPercent == this.maxDrawdownPercent &&
          other.sharpeRatio == this.sharpeRatio &&
          other.equityCurveJson == this.equityCurveJson &&
          other.createdAt == this.createdAt);
}

class BacktestRunsCompanion extends UpdateCompanion<BacktestRun> {
  final Value<int> id;
  final Value<String> symbol;
  final Value<String> strategyName;
  final Value<int> fastEmaPeriod;
  final Value<int> slowEmaPeriod;
  final Value<int> totalTrades;
  final Value<double> winRatePercent;
  final Value<double> netProfitPercent;
  final Value<double> maxDrawdownPercent;
  final Value<double> sharpeRatio;
  final Value<String> equityCurveJson;
  final Value<DateTime> createdAt;
  const BacktestRunsCompanion({
    this.id = const Value.absent(),
    this.symbol = const Value.absent(),
    this.strategyName = const Value.absent(),
    this.fastEmaPeriod = const Value.absent(),
    this.slowEmaPeriod = const Value.absent(),
    this.totalTrades = const Value.absent(),
    this.winRatePercent = const Value.absent(),
    this.netProfitPercent = const Value.absent(),
    this.maxDrawdownPercent = const Value.absent(),
    this.sharpeRatio = const Value.absent(),
    this.equityCurveJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BacktestRunsCompanion.insert({
    this.id = const Value.absent(),
    required String symbol,
    required String strategyName,
    required int fastEmaPeriod,
    required int slowEmaPeriod,
    required int totalTrades,
    required double winRatePercent,
    required double netProfitPercent,
    required double maxDrawdownPercent,
    required double sharpeRatio,
    required String equityCurveJson,
    this.createdAt = const Value.absent(),
  }) : symbol = Value(symbol),
       strategyName = Value(strategyName),
       fastEmaPeriod = Value(fastEmaPeriod),
       slowEmaPeriod = Value(slowEmaPeriod),
       totalTrades = Value(totalTrades),
       winRatePercent = Value(winRatePercent),
       netProfitPercent = Value(netProfitPercent),
       maxDrawdownPercent = Value(maxDrawdownPercent),
       sharpeRatio = Value(sharpeRatio),
       equityCurveJson = Value(equityCurveJson);
  static Insertable<BacktestRun> custom({
    Expression<int>? id,
    Expression<String>? symbol,
    Expression<String>? strategyName,
    Expression<int>? fastEmaPeriod,
    Expression<int>? slowEmaPeriod,
    Expression<int>? totalTrades,
    Expression<double>? winRatePercent,
    Expression<double>? netProfitPercent,
    Expression<double>? maxDrawdownPercent,
    Expression<double>? sharpeRatio,
    Expression<String>? equityCurveJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (symbol != null) 'symbol': symbol,
      if (strategyName != null) 'strategy_name': strategyName,
      if (fastEmaPeriod != null) 'fast_ema_period': fastEmaPeriod,
      if (slowEmaPeriod != null) 'slow_ema_period': slowEmaPeriod,
      if (totalTrades != null) 'total_trades': totalTrades,
      if (winRatePercent != null) 'win_rate_percent': winRatePercent,
      if (netProfitPercent != null) 'net_profit_percent': netProfitPercent,
      if (maxDrawdownPercent != null)
        'max_drawdown_percent': maxDrawdownPercent,
      if (sharpeRatio != null) 'sharpe_ratio': sharpeRatio,
      if (equityCurveJson != null) 'equity_curve_json': equityCurveJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BacktestRunsCompanion copyWith({
    Value<int>? id,
    Value<String>? symbol,
    Value<String>? strategyName,
    Value<int>? fastEmaPeriod,
    Value<int>? slowEmaPeriod,
    Value<int>? totalTrades,
    Value<double>? winRatePercent,
    Value<double>? netProfitPercent,
    Value<double>? maxDrawdownPercent,
    Value<double>? sharpeRatio,
    Value<String>? equityCurveJson,
    Value<DateTime>? createdAt,
  }) {
    return BacktestRunsCompanion(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      strategyName: strategyName ?? this.strategyName,
      fastEmaPeriod: fastEmaPeriod ?? this.fastEmaPeriod,
      slowEmaPeriod: slowEmaPeriod ?? this.slowEmaPeriod,
      totalTrades: totalTrades ?? this.totalTrades,
      winRatePercent: winRatePercent ?? this.winRatePercent,
      netProfitPercent: netProfitPercent ?? this.netProfitPercent,
      maxDrawdownPercent: maxDrawdownPercent ?? this.maxDrawdownPercent,
      sharpeRatio: sharpeRatio ?? this.sharpeRatio,
      equityCurveJson: equityCurveJson ?? this.equityCurveJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (strategyName.present) {
      map['strategy_name'] = Variable<String>(strategyName.value);
    }
    if (fastEmaPeriod.present) {
      map['fast_ema_period'] = Variable<int>(fastEmaPeriod.value);
    }
    if (slowEmaPeriod.present) {
      map['slow_ema_period'] = Variable<int>(slowEmaPeriod.value);
    }
    if (totalTrades.present) {
      map['total_trades'] = Variable<int>(totalTrades.value);
    }
    if (winRatePercent.present) {
      map['win_rate_percent'] = Variable<double>(winRatePercent.value);
    }
    if (netProfitPercent.present) {
      map['net_profit_percent'] = Variable<double>(netProfitPercent.value);
    }
    if (maxDrawdownPercent.present) {
      map['max_drawdown_percent'] = Variable<double>(maxDrawdownPercent.value);
    }
    if (sharpeRatio.present) {
      map['sharpe_ratio'] = Variable<double>(sharpeRatio.value);
    }
    if (equityCurveJson.present) {
      map['equity_curve_json'] = Variable<String>(equityCurveJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BacktestRunsCompanion(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('strategyName: $strategyName, ')
          ..write('fastEmaPeriod: $fastEmaPeriod, ')
          ..write('slowEmaPeriod: $slowEmaPeriod, ')
          ..write('totalTrades: $totalTrades, ')
          ..write('winRatePercent: $winRatePercent, ')
          ..write('netProfitPercent: $netProfitPercent, ')
          ..write('maxDrawdownPercent: $maxDrawdownPercent, ')
          ..write('sharpeRatio: $sharpeRatio, ')
          ..write('equityCurveJson: $equityCurveJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TradeJournalEntriesTable extends TradeJournalEntries
    with TableInfo<$TradeJournalEntriesTable, TradeJournalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TradeJournalEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
    'side',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryPriceMeta = const VerificationMeta(
    'entryPrice',
  );
  @override
  late final GeneratedColumn<double> entryPrice = GeneratedColumn<double>(
    'entry_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exitPriceMeta = const VerificationMeta(
    'exitPrice',
  );
  @override
  late final GeneratedColumn<double> exitPrice = GeneratedColumn<double>(
    'exit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pnlPercentMeta = const VerificationMeta(
    'pnlPercent',
  );
  @override
  late final GeneratedColumn<double> pnlPercent = GeneratedColumn<double>(
    'pnl_percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasoningNoteMeta = const VerificationMeta(
    'reasoningNote',
  );
  @override
  late final GeneratedColumn<String> reasoningNote = GeneratedColumn<String>(
    'reasoning_note',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    symbol,
    side,
    entryPrice,
    exitPrice,
    pnlPercent,
    reasoningNote,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trade_journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TradeJournalEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('side')) {
      context.handle(
        _sideMeta,
        side.isAcceptableOrUnknown(data['side']!, _sideMeta),
      );
    } else if (isInserting) {
      context.missing(_sideMeta);
    }
    if (data.containsKey('entry_price')) {
      context.handle(
        _entryPriceMeta,
        entryPrice.isAcceptableOrUnknown(data['entry_price']!, _entryPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_entryPriceMeta);
    }
    if (data.containsKey('exit_price')) {
      context.handle(
        _exitPriceMeta,
        exitPrice.isAcceptableOrUnknown(data['exit_price']!, _exitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_exitPriceMeta);
    }
    if (data.containsKey('pnl_percent')) {
      context.handle(
        _pnlPercentMeta,
        pnlPercent.isAcceptableOrUnknown(data['pnl_percent']!, _pnlPercentMeta),
      );
    } else if (isInserting) {
      context.missing(_pnlPercentMeta);
    }
    if (data.containsKey('reasoning_note')) {
      context.handle(
        _reasoningNoteMeta,
        reasoningNote.isAcceptableOrUnknown(
          data['reasoning_note']!,
          _reasoningNoteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reasoningNoteMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TradeJournalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TradeJournalEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      side: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side'],
      )!,
      entryPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}entry_price'],
      )!,
      exitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}exit_price'],
      )!,
      pnlPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pnl_percent'],
      )!,
      reasoningNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reasoning_note'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $TradeJournalEntriesTable createAlias(String alias) {
    return $TradeJournalEntriesTable(attachedDatabase, alias);
  }
}

class TradeJournalEntry extends DataClass
    implements Insertable<TradeJournalEntry> {
  final int id;
  final String symbol;
  final String side;
  final double entryPrice;
  final double exitPrice;
  final double pnlPercent;
  final String reasoningNote;
  final DateTime timestamp;
  const TradeJournalEntry({
    required this.id,
    required this.symbol,
    required this.side,
    required this.entryPrice,
    required this.exitPrice,
    required this.pnlPercent,
    required this.reasoningNote,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['symbol'] = Variable<String>(symbol);
    map['side'] = Variable<String>(side);
    map['entry_price'] = Variable<double>(entryPrice);
    map['exit_price'] = Variable<double>(exitPrice);
    map['pnl_percent'] = Variable<double>(pnlPercent);
    map['reasoning_note'] = Variable<String>(reasoningNote);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  TradeJournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return TradeJournalEntriesCompanion(
      id: Value(id),
      symbol: Value(symbol),
      side: Value(side),
      entryPrice: Value(entryPrice),
      exitPrice: Value(exitPrice),
      pnlPercent: Value(pnlPercent),
      reasoningNote: Value(reasoningNote),
      timestamp: Value(timestamp),
    );
  }

  factory TradeJournalEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TradeJournalEntry(
      id: serializer.fromJson<int>(json['id']),
      symbol: serializer.fromJson<String>(json['symbol']),
      side: serializer.fromJson<String>(json['side']),
      entryPrice: serializer.fromJson<double>(json['entryPrice']),
      exitPrice: serializer.fromJson<double>(json['exitPrice']),
      pnlPercent: serializer.fromJson<double>(json['pnlPercent']),
      reasoningNote: serializer.fromJson<String>(json['reasoningNote']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'symbol': serializer.toJson<String>(symbol),
      'side': serializer.toJson<String>(side),
      'entryPrice': serializer.toJson<double>(entryPrice),
      'exitPrice': serializer.toJson<double>(exitPrice),
      'pnlPercent': serializer.toJson<double>(pnlPercent),
      'reasoningNote': serializer.toJson<String>(reasoningNote),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  TradeJournalEntry copyWith({
    int? id,
    String? symbol,
    String? side,
    double? entryPrice,
    double? exitPrice,
    double? pnlPercent,
    String? reasoningNote,
    DateTime? timestamp,
  }) => TradeJournalEntry(
    id: id ?? this.id,
    symbol: symbol ?? this.symbol,
    side: side ?? this.side,
    entryPrice: entryPrice ?? this.entryPrice,
    exitPrice: exitPrice ?? this.exitPrice,
    pnlPercent: pnlPercent ?? this.pnlPercent,
    reasoningNote: reasoningNote ?? this.reasoningNote,
    timestamp: timestamp ?? this.timestamp,
  );
  TradeJournalEntry copyWithCompanion(TradeJournalEntriesCompanion data) {
    return TradeJournalEntry(
      id: data.id.present ? data.id.value : this.id,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      side: data.side.present ? data.side.value : this.side,
      entryPrice: data.entryPrice.present
          ? data.entryPrice.value
          : this.entryPrice,
      exitPrice: data.exitPrice.present ? data.exitPrice.value : this.exitPrice,
      pnlPercent: data.pnlPercent.present
          ? data.pnlPercent.value
          : this.pnlPercent,
      reasoningNote: data.reasoningNote.present
          ? data.reasoningNote.value
          : this.reasoningNote,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TradeJournalEntry(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('side: $side, ')
          ..write('entryPrice: $entryPrice, ')
          ..write('exitPrice: $exitPrice, ')
          ..write('pnlPercent: $pnlPercent, ')
          ..write('reasoningNote: $reasoningNote, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    symbol,
    side,
    entryPrice,
    exitPrice,
    pnlPercent,
    reasoningNote,
    timestamp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TradeJournalEntry &&
          other.id == this.id &&
          other.symbol == this.symbol &&
          other.side == this.side &&
          other.entryPrice == this.entryPrice &&
          other.exitPrice == this.exitPrice &&
          other.pnlPercent == this.pnlPercent &&
          other.reasoningNote == this.reasoningNote &&
          other.timestamp == this.timestamp);
}

class TradeJournalEntriesCompanion extends UpdateCompanion<TradeJournalEntry> {
  final Value<int> id;
  final Value<String> symbol;
  final Value<String> side;
  final Value<double> entryPrice;
  final Value<double> exitPrice;
  final Value<double> pnlPercent;
  final Value<String> reasoningNote;
  final Value<DateTime> timestamp;
  const TradeJournalEntriesCompanion({
    this.id = const Value.absent(),
    this.symbol = const Value.absent(),
    this.side = const Value.absent(),
    this.entryPrice = const Value.absent(),
    this.exitPrice = const Value.absent(),
    this.pnlPercent = const Value.absent(),
    this.reasoningNote = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  TradeJournalEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String symbol,
    required String side,
    required double entryPrice,
    required double exitPrice,
    required double pnlPercent,
    required String reasoningNote,
    this.timestamp = const Value.absent(),
  }) : symbol = Value(symbol),
       side = Value(side),
       entryPrice = Value(entryPrice),
       exitPrice = Value(exitPrice),
       pnlPercent = Value(pnlPercent),
       reasoningNote = Value(reasoningNote);
  static Insertable<TradeJournalEntry> custom({
    Expression<int>? id,
    Expression<String>? symbol,
    Expression<String>? side,
    Expression<double>? entryPrice,
    Expression<double>? exitPrice,
    Expression<double>? pnlPercent,
    Expression<String>? reasoningNote,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (symbol != null) 'symbol': symbol,
      if (side != null) 'side': side,
      if (entryPrice != null) 'entry_price': entryPrice,
      if (exitPrice != null) 'exit_price': exitPrice,
      if (pnlPercent != null) 'pnl_percent': pnlPercent,
      if (reasoningNote != null) 'reasoning_note': reasoningNote,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  TradeJournalEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? symbol,
    Value<String>? side,
    Value<double>? entryPrice,
    Value<double>? exitPrice,
    Value<double>? pnlPercent,
    Value<String>? reasoningNote,
    Value<DateTime>? timestamp,
  }) {
    return TradeJournalEntriesCompanion(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      side: side ?? this.side,
      entryPrice: entryPrice ?? this.entryPrice,
      exitPrice: exitPrice ?? this.exitPrice,
      pnlPercent: pnlPercent ?? this.pnlPercent,
      reasoningNote: reasoningNote ?? this.reasoningNote,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (entryPrice.present) {
      map['entry_price'] = Variable<double>(entryPrice.value);
    }
    if (exitPrice.present) {
      map['exit_price'] = Variable<double>(exitPrice.value);
    }
    if (pnlPercent.present) {
      map['pnl_percent'] = Variable<double>(pnlPercent.value);
    }
    if (reasoningNote.present) {
      map['reasoning_note'] = Variable<String>(reasoningNote.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TradeJournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('side: $side, ')
          ..write('entryPrice: $entryPrice, ')
          ..write('exitPrice: $exitPrice, ')
          ..write('pnlPercent: $pnlPercent, ')
          ..write('reasoningNote: $reasoningNote, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BacktestRunsTable backtestRuns = $BacktestRunsTable(this);
  late final $TradeJournalEntriesTable tradeJournalEntries =
      $TradeJournalEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    backtestRuns,
    tradeJournalEntries,
  ];
}

typedef $$BacktestRunsTableCreateCompanionBuilder =
    BacktestRunsCompanion Function({
      Value<int> id,
      required String symbol,
      required String strategyName,
      required int fastEmaPeriod,
      required int slowEmaPeriod,
      required int totalTrades,
      required double winRatePercent,
      required double netProfitPercent,
      required double maxDrawdownPercent,
      required double sharpeRatio,
      required String equityCurveJson,
      Value<DateTime> createdAt,
    });
typedef $$BacktestRunsTableUpdateCompanionBuilder =
    BacktestRunsCompanion Function({
      Value<int> id,
      Value<String> symbol,
      Value<String> strategyName,
      Value<int> fastEmaPeriod,
      Value<int> slowEmaPeriod,
      Value<int> totalTrades,
      Value<double> winRatePercent,
      Value<double> netProfitPercent,
      Value<double> maxDrawdownPercent,
      Value<double> sharpeRatio,
      Value<String> equityCurveJson,
      Value<DateTime> createdAt,
    });

class $$BacktestRunsTableFilterComposer
    extends Composer<_$AppDatabase, $BacktestRunsTable> {
  $$BacktestRunsTableFilterComposer({
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

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strategyName => $composableBuilder(
    column: $table.strategyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fastEmaPeriod => $composableBuilder(
    column: $table.fastEmaPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slowEmaPeriod => $composableBuilder(
    column: $table.slowEmaPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalTrades => $composableBuilder(
    column: $table.totalTrades,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get winRatePercent => $composableBuilder(
    column: $table.winRatePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get netProfitPercent => $composableBuilder(
    column: $table.netProfitPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxDrawdownPercent => $composableBuilder(
    column: $table.maxDrawdownPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sharpeRatio => $composableBuilder(
    column: $table.sharpeRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equityCurveJson => $composableBuilder(
    column: $table.equityCurveJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BacktestRunsTableOrderingComposer
    extends Composer<_$AppDatabase, $BacktestRunsTable> {
  $$BacktestRunsTableOrderingComposer({
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

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strategyName => $composableBuilder(
    column: $table.strategyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fastEmaPeriod => $composableBuilder(
    column: $table.fastEmaPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slowEmaPeriod => $composableBuilder(
    column: $table.slowEmaPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalTrades => $composableBuilder(
    column: $table.totalTrades,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get winRatePercent => $composableBuilder(
    column: $table.winRatePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get netProfitPercent => $composableBuilder(
    column: $table.netProfitPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxDrawdownPercent => $composableBuilder(
    column: $table.maxDrawdownPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sharpeRatio => $composableBuilder(
    column: $table.sharpeRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equityCurveJson => $composableBuilder(
    column: $table.equityCurveJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BacktestRunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BacktestRunsTable> {
  $$BacktestRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get strategyName => $composableBuilder(
    column: $table.strategyName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fastEmaPeriod => $composableBuilder(
    column: $table.fastEmaPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get slowEmaPeriod => $composableBuilder(
    column: $table.slowEmaPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalTrades => $composableBuilder(
    column: $table.totalTrades,
    builder: (column) => column,
  );

  GeneratedColumn<double> get winRatePercent => $composableBuilder(
    column: $table.winRatePercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get netProfitPercent => $composableBuilder(
    column: $table.netProfitPercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxDrawdownPercent => $composableBuilder(
    column: $table.maxDrawdownPercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sharpeRatio => $composableBuilder(
    column: $table.sharpeRatio,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equityCurveJson => $composableBuilder(
    column: $table.equityCurveJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BacktestRunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BacktestRunsTable,
          BacktestRun,
          $$BacktestRunsTableFilterComposer,
          $$BacktestRunsTableOrderingComposer,
          $$BacktestRunsTableAnnotationComposer,
          $$BacktestRunsTableCreateCompanionBuilder,
          $$BacktestRunsTableUpdateCompanionBuilder,
          (
            BacktestRun,
            BaseReferences<_$AppDatabase, $BacktestRunsTable, BacktestRun>,
          ),
          BacktestRun,
          PrefetchHooks Function()
        > {
  $$BacktestRunsTableTableManager(_$AppDatabase db, $BacktestRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BacktestRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BacktestRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BacktestRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String> strategyName = const Value.absent(),
                Value<int> fastEmaPeriod = const Value.absent(),
                Value<int> slowEmaPeriod = const Value.absent(),
                Value<int> totalTrades = const Value.absent(),
                Value<double> winRatePercent = const Value.absent(),
                Value<double> netProfitPercent = const Value.absent(),
                Value<double> maxDrawdownPercent = const Value.absent(),
                Value<double> sharpeRatio = const Value.absent(),
                Value<String> equityCurveJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BacktestRunsCompanion(
                id: id,
                symbol: symbol,
                strategyName: strategyName,
                fastEmaPeriod: fastEmaPeriod,
                slowEmaPeriod: slowEmaPeriod,
                totalTrades: totalTrades,
                winRatePercent: winRatePercent,
                netProfitPercent: netProfitPercent,
                maxDrawdownPercent: maxDrawdownPercent,
                sharpeRatio: sharpeRatio,
                equityCurveJson: equityCurveJson,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String symbol,
                required String strategyName,
                required int fastEmaPeriod,
                required int slowEmaPeriod,
                required int totalTrades,
                required double winRatePercent,
                required double netProfitPercent,
                required double maxDrawdownPercent,
                required double sharpeRatio,
                required String equityCurveJson,
                Value<DateTime> createdAt = const Value.absent(),
              }) => BacktestRunsCompanion.insert(
                id: id,
                symbol: symbol,
                strategyName: strategyName,
                fastEmaPeriod: fastEmaPeriod,
                slowEmaPeriod: slowEmaPeriod,
                totalTrades: totalTrades,
                winRatePercent: winRatePercent,
                netProfitPercent: netProfitPercent,
                maxDrawdownPercent: maxDrawdownPercent,
                sharpeRatio: sharpeRatio,
                equityCurveJson: equityCurveJson,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BacktestRunsTable, BacktestRun>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BacktestRunsTable,
                    BacktestRun
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BacktestRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BacktestRunsTable,
      BacktestRun,
      $$BacktestRunsTableFilterComposer,
      $$BacktestRunsTableOrderingComposer,
      $$BacktestRunsTableAnnotationComposer,
      $$BacktestRunsTableCreateCompanionBuilder,
      $$BacktestRunsTableUpdateCompanionBuilder,
      (
        BacktestRun,
        BaseReferences<_$AppDatabase, $BacktestRunsTable, BacktestRun>,
      ),
      BacktestRun,
      PrefetchHooks Function()
    >;
typedef $$TradeJournalEntriesTableCreateCompanionBuilder =
    TradeJournalEntriesCompanion Function({
      Value<int> id,
      required String symbol,
      required String side,
      required double entryPrice,
      required double exitPrice,
      required double pnlPercent,
      required String reasoningNote,
      Value<DateTime> timestamp,
    });
typedef $$TradeJournalEntriesTableUpdateCompanionBuilder =
    TradeJournalEntriesCompanion Function({
      Value<int> id,
      Value<String> symbol,
      Value<String> side,
      Value<double> entryPrice,
      Value<double> exitPrice,
      Value<double> pnlPercent,
      Value<String> reasoningNote,
      Value<DateTime> timestamp,
    });

class $$TradeJournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TradeJournalEntriesTable> {
  $$TradeJournalEntriesTableFilterComposer({
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

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get entryPrice => $composableBuilder(
    column: $table.entryPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get exitPrice => $composableBuilder(
    column: $table.exitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pnlPercent => $composableBuilder(
    column: $table.pnlPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reasoningNote => $composableBuilder(
    column: $table.reasoningNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TradeJournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TradeJournalEntriesTable> {
  $$TradeJournalEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get entryPrice => $composableBuilder(
    column: $table.entryPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get exitPrice => $composableBuilder(
    column: $table.exitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pnlPercent => $composableBuilder(
    column: $table.pnlPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasoningNote => $composableBuilder(
    column: $table.reasoningNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TradeJournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TradeJournalEntriesTable> {
  $$TradeJournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<double> get entryPrice => $composableBuilder(
    column: $table.entryPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get exitPrice =>
      $composableBuilder(column: $table.exitPrice, builder: (column) => column);

  GeneratedColumn<double> get pnlPercent => $composableBuilder(
    column: $table.pnlPercent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reasoningNote => $composableBuilder(
    column: $table.reasoningNote,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$TradeJournalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TradeJournalEntriesTable,
          TradeJournalEntry,
          $$TradeJournalEntriesTableFilterComposer,
          $$TradeJournalEntriesTableOrderingComposer,
          $$TradeJournalEntriesTableAnnotationComposer,
          $$TradeJournalEntriesTableCreateCompanionBuilder,
          $$TradeJournalEntriesTableUpdateCompanionBuilder,
          (
            TradeJournalEntry,
            BaseReferences<
              _$AppDatabase,
              $TradeJournalEntriesTable,
              TradeJournalEntry
            >,
          ),
          TradeJournalEntry,
          PrefetchHooks Function()
        > {
  $$TradeJournalEntriesTableTableManager(
    _$AppDatabase db,
    $TradeJournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TradeJournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TradeJournalEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TradeJournalEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String> side = const Value.absent(),
                Value<double> entryPrice = const Value.absent(),
                Value<double> exitPrice = const Value.absent(),
                Value<double> pnlPercent = const Value.absent(),
                Value<String> reasoningNote = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
              }) => TradeJournalEntriesCompanion(
                id: id,
                symbol: symbol,
                side: side,
                entryPrice: entryPrice,
                exitPrice: exitPrice,
                pnlPercent: pnlPercent,
                reasoningNote: reasoningNote,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String symbol,
                required String side,
                required double entryPrice,
                required double exitPrice,
                required double pnlPercent,
                required String reasoningNote,
                Value<DateTime> timestamp = const Value.absent(),
              }) => TradeJournalEntriesCompanion.insert(
                id: id,
                symbol: symbol,
                side: side,
                entryPrice: entryPrice,
                exitPrice: exitPrice,
                pnlPercent: pnlPercent,
                reasoningNote: reasoningNote,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TradeJournalEntriesTable, TradeJournalEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $TradeJournalEntriesTable,
                    TradeJournalEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TradeJournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TradeJournalEntriesTable,
      TradeJournalEntry,
      $$TradeJournalEntriesTableFilterComposer,
      $$TradeJournalEntriesTableOrderingComposer,
      $$TradeJournalEntriesTableAnnotationComposer,
      $$TradeJournalEntriesTableCreateCompanionBuilder,
      $$TradeJournalEntriesTableUpdateCompanionBuilder,
      (
        TradeJournalEntry,
        BaseReferences<
          _$AppDatabase,
          $TradeJournalEntriesTable,
          TradeJournalEntry
        >,
      ),
      TradeJournalEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BacktestRunsTableTableManager get backtestRuns =>
      $$BacktestRunsTableTableManager(_db, _db.backtestRuns);
  $$TradeJournalEntriesTableTableManager get tradeJournalEntries =>
      $$TradeJournalEntriesTableTableManager(_db, _db.tradeJournalEntries);
}
