//lib/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'relationship_model.dart';
import 'user_model.dart';
import 'user_info_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
  CREATE TABLE users(
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    contact_no TEXT NOT NULL,
    email TEXT NOT NULL,
    password TEXT NOT NULL,
    pic BLOB,
    theme TEXT NOT NULL
  );
  ''');

    await db.execute('''
  CREATE TABLE relationship(
    id1 TEXT NOT NULL,
    id2 TEXT NOT NULL,
    nickname TEXT,
    FOREIGN KEY (id1) REFERENCES users (id),
    FOREIGN KEY (id2) REFERENCES users (id)
  );
  ''');

    await db.execute('''
  CREATE TABLE user_info(
    id TEXT PRIMARY KEY,
    username TEXT,
    phone TEXT,
    contact TEXT,
    instagram TEXT,
    wechat TEXT,
    facebook TEXT,
    accountId TEXT,
    FOREIGN KEY (id) REFERENCES users (id)
  );
  ''');
  }


  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
    CREATE TABLE user_info(
      id TEXT PRIMARY KEY,
      username TEXT,
      phone TEXT,
      contact TEXT,
      instagram TEXT,
      wechat TEXT,
      facebook TEXT,
      accountId TEXT,
      FOREIGN KEY (id) REFERENCES users (id)
    );
    ''');
    }
  }


  Future<void> addUser(user_model user) async{
    final db = await instance.database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateUser(user_model user) async {
    final db = await instance.database;

    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<String?> getUserTheme(String id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['theme'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first['theme'] as String?;
    } else {
      return null;
    }
  }

  Future<int> updateUserTheme(String id ,String theme) async {
    final db = await instance.database;

    return db.update(
      'users',
      {'theme': theme},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> checkUserExistance(String id)async{
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  Future<user_model?> getUser(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      columns: ['id', 'name', 'contact_no', 'email', 'password', 'pic', 'theme'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if(maps.isNotEmpty){
      return user_model.fromMap(maps.first);
    }else{
      return null;
    }
  }

  Future<user_model?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      columns: ['id', 'name', 'contact_no', 'email', 'password', 'pic', 'theme'],
      where: 'email = ?',
      whereArgs: [email],
    );

    if(maps.isNotEmpty){
      return user_model.fromMap(maps.first);
    }else{
      return null;
    }
  }

  Future<List<user_model>> getUsers(String id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> relationshipResult = await db.query(
      'relationship',
      where: 'id1 = ?',
      whereArgs: [id],
    );

    final List<String> uid2List = relationshipResult.map((row) => row['id2'] as String).toList();

    List<user_model> users = [];

    for (String uid2 in uid2List) {
      final List<Map<String, dynamic>> userResult = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [uid2],
      );

      users.addAll(userResult.map((json) => user_model.fromMap(json)).toList());
    }

    return users;
  }

  Future<void> addRelationship(relationship_model relationship) async {
    final db = await instance.database;
    await db.insert(
      'relationship',
      relationship.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteRelationship(relationship_model relationship) async {
    final db = await instance.database;

    return await db.delete(
      'relationship',
      where: 'id1 = ? AND id2 = ?',
      whereArgs: [relationship.id1, relationship.id2],
    );
  }

  Future<String?> getNickname(String id1,String id2) async{
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      'relationship',
      columns: ['nickname'],
      where: 'id1 = ? AND id2 = ?',
      whereArgs: [id1, id2],
    );

    if (result.isNotEmpty) {
      return result.first['nickname'] as String?;
    } else {
      return null;
    }
  }

  Future<bool> checkDuplication(String id1,String id2)async{
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      'relationship',
      columns: ['nickname'],
      where: 'id1 = ? AND id2 = ?',
      whereArgs: [id1, id2],
    );
    return result.isNotEmpty;
  }

  Future<int> updateNickname(relationship_model relationship) async{
    final db = await instance.database;

    return db.update(
      'relationship',
      relationship.toMap(),
      where: 'id1 = ? AND id2 = ?',
      whereArgs: [relationship.id1, relationship.id2],
    );
  }

  Future<user_info_model?> getUserInfo(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'user_info',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return user_info_model.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<user_info_model> addUserInfo(user_info_model userInfo) async {
    final db = await instance.database;

    // Check for existing record with the same accountId and phone
    final maps = await db.query(
      'user_info',
      where: 'accountId = ? AND phone = ?',
      whereArgs: [userInfo.accountId, userInfo.phone],
    );

    if (maps.isNotEmpty) {
      throw Exception('A user with this phone number already exists.');
    }

    await db.insert(
      'user_info',
      userInfo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return userInfo;
  }

  Future<int> updateUserInfo(user_info_model userInfo) async {
    final db = await instance.database;

    return db.update(
      'user_info',
      userInfo.toMap(),
      where: 'id = ?',
      whereArgs: [userInfo.id],
    );
  }

  Future<List<user_info_model>> getAllUserInfo(String accountId) async {
    final db = await instance.database;
    final maps = await db.query(
      'user_info',
      where: 'accountId = ?',
      whereArgs: [accountId],
    );

    if (maps.isNotEmpty) {
      return maps.map((map) => user_info_model.fromMap(map)).toList();
    } else {
      return [];
    }
  }



  Future close() async {
    final db = await instance.database;
    db.close();
  }
}


