import '../services/database.service.dart';
import 'package:sqflite/sqlite_api.dart';

class UserModel {
  String id;
  String role;
  String email;
  String name;
  String firstName;
  String lastName;
  String authProvider;
  String token;

  UserModel._();
  static final UserModel t = UserModel._();

  UserModel({
    this.id, 
    this.role, 
    this.email, 
    this.name, 
    this.firstName,
    this.lastName,
    this.authProvider,
    this.token
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      role: json['role'],
      id: json['_id'],
      email: json['email'],
      name: json['name'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      authProvider: json['authProvider'],
      token: json['authToken'] != null ? json['authToken']['token'] : json['token']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "role": role,
      "_id": id,
      "email": email,
      "authProvider": authProvider,
      "first_name": firstName,
      "last_name": lastName,
      "name": name,
      "token": token
    };
  }

  Future<void> dropTable() async {
    Database db = await DBProvider.db.database;
    await db.execute('DROP TABLE IF EXISTS Users;');
  }

  Future<void> createTable() async {
    Database db = await DBProvider.db.database;
    await db.execute(
      'CREATE TABLE IF NOT EXISTS Users( ' +
        '_id TEXT PRIMARY KEY, ' +
        'role TEXT, ' +
        'email TEXT, ' +
        'first_name TEXT, ' +
        'last_name TEXT, ' +
        'name TEXT, ' +
        'token TEXT, ' +
        'authProvider TEXT, ' +
        'UNIQUE (email, name) ' +
      ');'
    );
  }

  Future<void> insertUser(UserModel user) async {
    Database db = await DBProvider.db.database;
    await dropTable();
    await createTable();
    await db.insert(
      'Users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserModel>> fetchCurrentUser() async {
    Database db = await DBProvider.db.database;
    await createTable();
    final List<Map<String, dynamic>> userListMaps = await db.query('Users');
    return List.generate(userListMaps.length, (i) {
      return UserModel.fromJson(userListMaps[i]);
    });
  }
}