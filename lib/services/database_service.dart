import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contacts.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts (
        id TEXT PRIMARY KEY,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        email TEXT,
        company TEXT,
        jobTitle TEXT,
        address TEXT,
        notes TEXT,
        avatarPath TEXT,
        isFavorite INTEGER DEFAULT 0,
        secondaryPhone TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<List<Contact>> getAllContacts() async {
    final db = await database;
    final maps = await db.query('contacts', orderBy: 'firstName ASC, lastName ASC');
    return maps.map((m) => Contact.fromMap(m)).toList();
  }

  Future<List<Contact>> getFavoriteContacts() async {
    final db = await database;
    final maps = await db.query(
      'contacts',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'firstName ASC',
    );
    return maps.map((m) => Contact.fromMap(m)).toList();
  }

  Future<void> insertContact(Contact contact) async {
    final db = await database;
    await db.insert('contacts', contact.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateContact(Contact contact) async {
    final db = await database;
    await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<void> deleteContact(String id) async {
    final db = await database;
    await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Contact>> searchContacts(String query) async {
    final db = await database;
    final maps = await db.query(
      'contacts',
      where: 'firstName LIKE ? OR lastName LIKE ? OR phoneNumber LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: 'firstName ASC',
    );
    return maps.map((m) => Contact.fromMap(m)).toList();
  }
}
