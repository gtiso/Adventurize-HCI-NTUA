import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:path_provider/path_provider.dart';
import 'db_tables.dart';
import 'package:adventurize/models/user_model.dart';
import 'package:adventurize/models/challenge_model.dart';
import 'package:adventurize/database/demo_data.dart';

class DatabaseHelper {
  final dbName = 'adventurize.db';
  Database? db;

  Future<bool> dbExists(String path) async {
    return await File(path).exists();
  }

  Future<Database> getDB() async {
    if (db != null) {
      return db!;
    }
    db = await initDB();
    return db!;
  }

  Future<void> deleteExistingDB(String path) async {
    if (await databaseExists(path)) {
      await deleteDatabase(path);
    }
  }

  Future<Database> initDB() async {
    String? path;
    if (Platform.isAndroid || Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      // ignore: unused_local_variable
      path = join(directory.path, dbName);
    } else if (Platform.isLinux || Platform.isWindows) {
      // Only in Linux and Windows
      sqfliteFfiInit(); // Initialize the database factory
      databaseFactory = databaseFactoryFfi; //Set the database factory to useFFI
      final databasePath = await getDatabasesPath();
      // ignore: unused_local_variable
      path = join(databasePath, dbName);
    }
    // Βοηθητική συνάρτηση για να διαγράψουμε την βάση
    //await deleteExistingDatabase(path!);

    return openDatabase(path!, version: 1, onCreate: (db, version) async {
      await db.execute(users);
      await db.execute(challenges);
    });
  }

  Future<bool> auth(Users usr) async {
    final Database db = await getDB();
    var result = await db.rawQuery(
      "SELECT * FROM users WHERE email = ? AND password = ?",
      [usr.email, usr.password],
    );
    print(result);
    return result.isNotEmpty;
  }

  Future<Users?> getUsr(String email) async {
    final Database db = await getDB();
    var res = await db.query("users", where: "email = ?", whereArgs: [email]);
    return res.isNotEmpty ? Users.fromMap(res.first) : null;
  }

  Future<int> createUsr(Users usr) async {
    final Database db = await getDB();
    int userId = await db.insert("users", usr.toMap());
    return userId;
  }

  Future<void> insChall(Challenge chall) async {
    final Database db = await getDB();
    List<Map<String, dynamic>> existingChallenges = await db.query(
      'challenges',
      where: 'title = ? AND desc = ?',
      whereArgs: [chall.title, chall.desc],
    );

    if (existingChallenges.isEmpty) {
      await db.insert('challenges', chall.toMap());
    }
  }

  Future<List<Challenge>> getChalls() async {
    final Database db = await getDB();
    final List<Map<String, dynamic>> maps = await db.query('challenges');
    return List.generate(maps.length, (i) {
      return Challenge(
        challengeID: maps[i]['challengeId'],
        title: maps[i]['title'],
        desc: maps[i]['desc'],
        photoPath: maps[i]['photoPath'],
        points: maps[i]['points'],
        shared: maps[i]['shared'],
      );
    });
  }

  Future<void> insDemoData() async {
    await insData();
  }
}
