import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

const _createMembersTable = '''
CREATE TABLE members(
  id TEXT PRIMARY KEY,
  staffId TEXT NOT NULL,
  fullName TEXT NOT NULL,
  email TEXT NOT NULL,
  role INTEGER NOT NULL,
  categoryId TEXT NOT NULL,
  tagId TEXT,
  nfcReference TEXT,
  faceRecognitionReference TEXT,
  fingerprintReference TEXT,
  businessUnitId TEXT,
  billingEntityId TEXT NOT NULL,
  status INTEGER NOT NULL
);
''';

const _createServedMealTable = '''
CREATE TABLE served_meals(
  id TEXT PRIMARY KEY,
  orderId TEXT NOT NULL,
  serverId TEXT NOT NULL,
  servedDateTime TEXT NOT NULL
);
''';

const _createOrderItemTable = '''
CREATE TABLE order_items(
  id TEXT PRIMARY KEY,
  orderId TEXT NOT NULL,
  mealId TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  billingEntityId TEXT NOT NULL,
  periodId TEXT NOT NULL,
  locationId TEXT NOT NULL,
  availableDate TEXT NOT NULL,
  mealRosterId TEXT
);
''';




class AppDb {
  static final AppDb _i = AppDb._internal();
  factory AppDb() => _i;
  AppDb._internal();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'canteen_pro.db');
    _db = await openDatabase(path, version: 1,
      onCreate: _onCreate,
      //onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        // Enable WAL mode — must run on every open, not just onCreate,
        // since journal_mode is a database-level setting that persists
        // in the file itself once set, but we set it defensively each time.
        await db.rawQuery('PRAGMA journal_mode=WAL');
      },
    );
    return _db!;
  }


  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_createMembersTable);
    await db.execute(_createServedMealTable);
    await db.execute(_createOrderItemTable);

    log(name: "SQLITE DB", "DB OPENED SUCCESSFULLY");
  }

  // Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  //   debugPrint('Upgrading database from v$oldVersion to v$newVersion');
  //
  //   if (oldVersion < 2) {
  //     //update transaction logs table
  //     await db.execute(
  //       '''
  //       ALTER TABLE transaction_logs ADD COLUMN speed REAL DEFAULT 0.0;
  //       ''',
  //     );
  //   }
  //
  //   if (oldVersion < 3) {
  //     await db.execute(
  //       '''
  //       ALTER TABLE transaction_logs ADD COLUMN stopReason INTEGER;
  //       ''',
  //     );
  //     await db.execute(
  //       '''
  //       ALTER TABLE transaction_logs ADD COLUMN otherStopReason TEXT;
  //       ''',
  //     );
  //   }
  //
  //   if (oldVersion < 4) {
  //     await db.execute(
  //       '''
  //       ALTER TABLE transaction_logs ADD COLUMN tripStopId TEXT;
  //       ''',
  //     );
  //   }
  //
  // }

  Future<bool> saveRecords(
      String table,
      List<Map<String, dynamic>> records, {
        String? subTable, // Sub-table name
        String? foreignKey, // User-defined foreign key
        String? subListKey, // Key holding the sublist
      })
  async {
    final db = await database;
    try {
      final batch = db.batch();
      for (var record in records) {
        // Ensure foreignKey exists in the main record
        if (foreignKey != null && !record.containsKey(foreignKey)) {
          throw Exception(
              "Foreign key '$foreignKey' is missing in the main record.");
        }

        // Separate main record and sublist
        final cleanedRecord = {...record};
        cleanedRecord
            .remove(subListKey); // Remove sublist before inserting main record

        // Insert main record
        await db.insert(table, cleanedRecord,
            conflictAlgorithm: ConflictAlgorithm.replace);

        // Handle sublist if applicable
        if (subTable != null && foreignKey != null && subListKey != null) {
          final subList = record[subListKey] as List<Map<String, dynamic>>?;
          if (subList != null) {
            for (var subItem in subList) {
              subItem[foreignKey] =
              record[foreignKey]; // Assign user-defined foreign key
              batch.insert(subTable, subItem,
                  conflictAlgorithm: ConflictAlgorithm.replace);
            }
          }
        }
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error saving records: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getRecords(
      String table, {
        String? where,
        List<String>? whereArgs,
        String? subTable, // Name of the sublist table
        String? foreignKey, // Foreign key to link main records with subrecords
        String? subListKey, // Key under which subrecords are stored
        String? orderBy,
      })
  async {
    final db = await database;
    try {
      // Fetch main records
      final List<Map<String, dynamic>> records = await db.query(
        table,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy
      );

      final List<Map<String, dynamic>> newRecordList = [];
      // If subTable and foreignKey are provided, fetch and attach sublist
      if (subTable != null && foreignKey != null && subListKey != null) {
        for (var record in records) {
          // Fetch related sublist items
          final List<Map<String, dynamic>> subRecords = await db.query(
            subTable,
            where: '$foreignKey = ?',
            whereArgs: [record[foreignKey]],
          );
          newRecordList.add({...record, subListKey: subRecords});
        }
      } else {
        newRecordList.addAll(records);
      }

      return newRecordList;
    } catch (e) {
      print('Error fetching records: $e');
      return [];
    }
  }

  Future<bool> updateRecords(
      String table,
      List<Map<String, dynamic>> records,
      String whereColumn,
      List<dynamic> whereColumnValues, {
        String? subTable,
        String? foreignKey, // User-defined foreign key (e.g., invoiceNumber)
        String? subListKey, // Key where sublist data is stored
        bool shouldClearSubList =
        true, // Controls whether to delete old sublist items
      })
  async {
    try {
      final db = await database;
      final batch = db.batch();

      for (var record in records) {
        // Remove the sublist before updating the main table
        final recordWithoutSublist = {...record};
        recordWithoutSublist.remove(subListKey);

        // Update the main table
        batch.update(
          table,
          recordWithoutSublist,
          where: '$whereColumn = ?',
          whereArgs: [record[whereColumn]],
        );

        // Handle the sublist if provided
        if (subTable != null && subListKey != null && foreignKey != null) {
          final subList = record[subListKey] as List<Map<String, dynamic>>?;

          if (subList != null) {
            if (shouldClearSubList) {
              // Delete old sublist entries
              batch.delete(
                subTable,
                where: '$foreignKey = ?',
                whereArgs: [record[foreignKey]],
              );

              // Insert new sublist items
              for (var item in subList) {
                batch.insert(subTable, item);
              }
            } else {
              // Just update existing sublist records
              for (var item in subList) {
                batch.update(
                  subTable,
                  item,
                  where: '$foreignKey = ?',
                  whereArgs: [item[foreignKey]],
                );
              }
            }
          }
        }
      }

      final res = await batch.commit();
      return res.isNotEmpty;
    } catch (e, s) {
      print('Error updating records: $e\n$s');
      return false;
    }
  }

  //check if table is empty
  Future<bool> isTableEmpty(String table) async {
    final db = await database;
    final res = await db.query(table);
    return res.isEmpty;
  }

  Future<bool> doesItemExist(String table, String column, String value) async {
    final db = await database;
    final res = await db.query(table, where: '$column=?', whereArgs: [value]);
    return res.isNotEmpty;
  }

  Future<bool> isItemMoreThanOne(String table, String column, String value) async {
    final db = await database;
    final res = await db.query(table, where: '$column=?', whereArgs: [value]);
    return res.length > 1;
  }

  Future<Map<String, dynamic>?> getMaxRowValue(String table, String column, String? where, List<String>? whereArgs) async {
    final db = await database;
    final res = await db.query(table, where: where, whereArgs: whereArgs);
    if (res.isEmpty) return null;
    return res.first;
  }

  Future<bool> clearDatabase({bool includeLogs = false}) async {
    try {
      await clearTable('drivers');
      await clearTable('trips');
      await clearTable('shifts');
      await clearTable('driver_stats');
      await clearTable('employee_biodata');
      await clearTable('pending_locations');
      if (includeLogs) {
        await clearTable('transaction_logs');
      }
      log(name: "SQLITE DB", "Database cleared successfully");
      return true;
    } catch (e) {
      log(name: "SQLITE DB", 'Error clearing database: $e');
      return false;
    }
  }

  Future<bool> clearTable(String tableName) async {
    final db = await database;
    try {
      await db.delete(tableName);
      return true;
    } catch (e) {
      print('Error clearing table: $e');
      return false;
    }
  }

}
