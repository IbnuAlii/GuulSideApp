import 'package:flutter/material.dart';
import 'package:guul_side/models/category.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CategoryService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'guul_side.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            icon TEXT,
            color INTEGER
          )
        ''');
      },
    );
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return Category(
        id: maps[i]['id'],
        name: maps[i]['name'],
        icon: maps[i]['icon'],
        color: Color(maps[i]['color']),
      );
    });
  }

  Future<Category> addCategory(Category category) async {
    final db = await database;
    final id = await db.insert('categories', category.toMap());
    return category.copyWith(id: id);
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
