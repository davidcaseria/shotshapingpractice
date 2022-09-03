import 'dart:io';
import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseProvider {
  static DatabaseProvider? _instance;
  final Database db;

  static const _name = "shots.db";
  static const _version = 1;

  static Future<DatabaseProvider> getInstance() async {
    if (_instance == null) {
      final database = await _initDatabase();
      _instance = DatabaseProvider._(database);
    }
    return _instance!;
  }

  DatabaseProvider._(Database database) : db = database;

  static _initDatabase() async {
    if (Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    return await openDatabase(_name, version: _version, onCreate: _onCreate);
  }

  static Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE ${WarmUpShotModel.table} (
            ${WarmUpShotModel.idColumn} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${WarmUpShotModel.sessionColumn} INTEGER NOT NULL,
            ${WarmUpShotModel.expectedStartColumn} VARCHAR NOT NULL,
            ${WarmUpShotModel.actualStartColumn} VARCHAR NOT NULL,
            ${WarmUpShotModel.pointsColumn} INTEGER NOT NULL
          );
          
          CREATE TABLE ${PracticeShotModel.table} (
            ${PracticeShotModel.idColumn} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${PracticeShotModel.sessionColumn} INTEGER NOT NULL,
            ${PracticeShotModel.expectedStartColumn} VARCHAR NOT NULL,
            ${PracticeShotModel.actualStartColumn} VARCHAR NOT NULL,
            ${PracticeShotModel.expectedCurveColumn} VARCHAR NOT NULL,
            ${PracticeShotModel.actualCurveColumn} VARCHAR NOT NULL,
            ${PracticeShotModel.pointsColumn} INTEGER NOT NULL
          );
          ''');
  }
}

enum Direction { left, right }

extension DirectionExt on Direction {
  static Direction fromString(String str) {
    return Direction.values.firstWhere((e) => e.toString() == 'Direction.$str');
  }

  static Direction random() {
    var rnd = Random();
    return Direction.values[rnd.nextInt(Direction.values.length)];
  }

  String label() =>
      '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}';

  Direction opposite() =>
      (this == Direction.left) ? Direction.right : Direction.left;
}

class WarmUpShot {
  late int session;
  late Direction expectedStart;
  late Direction actualStart;
  late int points = (expectedStart == actualStart) ? 1 : 0;

  WarmUpShot(this.session, this.expectedStart, this.actualStart);

  WarmUpShot.fromMap(Map<String, dynamic> map) {
    session = map[WarmUpShotModel.sessionColumn];
    expectedStart =
        DirectionExt.fromString(map[WarmUpShotModel.expectedStartColumn]);
    actualStart =
        DirectionExt.fromString(map[WarmUpShotModel.actualStartColumn]);
    points = map[WarmUpShotModel.pointsColumn];
  }

  Map<String, dynamic> toMap() {
    return {
      WarmUpShotModel.sessionColumn: session,
      WarmUpShotModel.expectedStartColumn: expectedStart.name,
      WarmUpShotModel.actualStartColumn: actualStart.name,
      WarmUpShotModel.pointsColumn: points,
    };
  }

  Future<int> save(Database db) {
    return db.insert(WarmUpShotModel.table, toMap());
  }
}

class WarmUpShotModel {
  static const table = 'warm_up_shots';
  static const idColumn = 'id';
  static const sessionColumn = 'session';
  static const expectedStartColumn = 'expected_start';
  static const actualStartColumn = 'actual_start';
  static const pointsColumn = 'points';
}

class PracticeShot {
  late int session;
  late Direction expectedStart;
  late Direction actualStart;
  late Direction expectedCurve;
  late Direction actualCurve;
  late int points = ((expectedStart == actualStart) ? 1 : 0) +
      ((expectedCurve == actualCurve) ? 1 : 0);

  PracticeShot(this.session, this.expectedStart, this.actualStart,
      this.expectedCurve, this.actualCurve);

  PracticeShot.fromMap(Map<String, dynamic> map) {
    session = map[WarmUpShotModel.sessionColumn];
    expectedStart =
        DirectionExt.fromString(map[PracticeShotModel.expectedStartColumn]);
    actualStart =
        DirectionExt.fromString(map[PracticeShotModel.actualStartColumn]);
    expectedCurve =
        DirectionExt.fromString(map[PracticeShotModel.expectedCurveColumn]);
    actualCurve =
        DirectionExt.fromString(map[PracticeShotModel.actualCurveColumn]);
  }

  Map<String, dynamic> toMap() {
    return {
      PracticeShotModel.sessionColumn: session,
      PracticeShotModel.expectedStartColumn: expectedStart.name,
      PracticeShotModel.actualStartColumn: actualStart.name,
      PracticeShotModel.expectedCurveColumn: expectedCurve.name,
      PracticeShotModel.actualCurveColumn: actualCurve.name,
      PracticeShotModel.pointsColumn: points,
    };
  }

  Future<int> save(Database db) {
    return db.insert(PracticeShotModel.table, toMap());
  }
}

class PracticeShotModel {
  static const table = 'practice_shots';
  static const idColumn = 'id';
  static const sessionColumn = 'session';
  static const expectedStartColumn = 'expected_start';
  static const actualStartColumn = 'actual_start';
  static const expectedCurveColumn = 'expected_curve';
  static const actualCurveColumn = 'actual_curve';
  static const pointsColumn = 'points';
}

class ShotStatsModel {
  static Future<num?> getWarmUpPct(Direction direction) async {
    final provider = await DatabaseProvider.getInstance();
    final res = await provider.db.rawQuery('''
      SELECT sum(${WarmUpShotModel.pointsColumn}) / (1.0 * count(${WarmUpShotModel.idColumn})) AS pct
      FROM ${WarmUpShotModel.table}
      WHERE ${WarmUpShotModel.expectedStartColumn} = '${direction.name}'
    ''');
    if (res.isEmpty || res[0]['pct'] == null) {
      return null;
    } else {
      return res[0]['pct'] as num;
    }
  }

  static Future<num?> getPracticePct(Direction direction) async {
    final provider = await DatabaseProvider.getInstance();
    final res = await provider.db.rawQuery('''
      SELECT sum(${PracticeShotModel.pointsColumn}) / (2.0 * count(${PracticeShotModel.idColumn})) AS pct
      FROM ${PracticeShotModel.table}
      WHERE ${PracticeShotModel.expectedStartColumn} = '${direction.name}'
    ''');
    if (res.isEmpty || res[0]['pct'] == null) {
      return null;
    } else {
      return res[0]['pct'] as num;
    }
  }
}
