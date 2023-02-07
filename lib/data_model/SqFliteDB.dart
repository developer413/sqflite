import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'dog.dart';

class SqliteDB {
  Future<Database> getDataBase() async {
    return openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'dog_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  Future<void> insertDog(Dog dog) async {
    final db = await getDataBase();

    await db.insert(
      'dogs',
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Dog>> getDogs() async {
    final db = await getDataBase();

    final List<Map<String, dynamic>> maps = await db.query('dogs');

    return List.generate(maps.length, (index) {
      return Dog(
        id: maps[index]['id'],
        name: maps[index]['name'],
        age: maps[index]['age'],
      );
    });
  }

  Future<void> updateDog(Dog dog) async {
    final db = await getDataBase();
    await db.update('dogs', dog.toMap(), where: 'id=?', whereArgs: [dog.id]);
  }

  Future<void> deleteDog(int id) async {
    final db = await getDataBase();
    await db.delete('dogs', where: 'id=?', whereArgs: [id]);
  }
}
