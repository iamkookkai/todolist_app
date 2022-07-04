import 'dart:io';




import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todolist_app/models/todo.dart';


class DBProvider {
  late Database database;

  Future<bool> initDB() async {
    try {
      final String databaseName = "TODO.db";
      final String databasePath = await getDatabasesPath();
      final String path = join(databasePath, databaseName);

      if (!await Directory(dirname(path)).exists()) {
        await Directory(dirname(path)).create(recursive: true);
      }

      database = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          print("Database Create");
          String sql = "CREATE TABLE $TABLE_TODO ("
              "$COLUMN_ID INTEGER PRIMARY KEY,"
            "$COLUMN_TITLE TEXT,"
            "$COLUMN_DESCRIPTION TEXT"
              ")";
          await db.execute(sql);
        },
      
        onOpen: (Database db) async {
          print("Database version: ${await db.getVersion()}");
        },
      );
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future close() async => database.close();

  Future<List<Todo>> getTodolists() async {
    List<Map<String, dynamic>> maps = await database.query(
      TABLE_TODO,
      columns: [COLUMN_ID, COLUMN_TITLE, COLUMN_DESCRIPTION],
    );



    if (maps.length > 0) {
      return maps.map((p) => Todo.fromMap(p)).toList();
    }
    return [];
  }

  Future<Todo?> getTodo(int id) async {
    List<Map<String, dynamic>> maps = await database.query(
      TABLE_TODO,
      columns: [COLUMN_ID, COLUMN_TITLE, COLUMN_DESCRIPTION],
      where: "$COLUMN_ID = ?",
      whereArgs: [id],
    );

    if (maps.length > 0) {
      return Todo.fromMap(maps.first);
    }
    return null;
  }

  Future<Todo> insertTodo(Todo todo) async {
    todo.id = await database.insert(TABLE_TODO, todo.toMap());
   
    return todo;
  }

  Future<int> updateTodo(Todo todo) async {
    print(todo.id);
    return await database.update(
      TABLE_TODO,
      todo.toMap(),
      where: "$COLUMN_ID = ?",
      whereArgs: [todo.id],
    );
  }

  Future<int> deleteTodo(int id) async {
    return await database.delete(
      TABLE_TODO,
      where: "$COLUMN_ID = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    String sql = "Delete from $TABLE_TODO";
    return await database.rawDelete(sql);
  }
}
