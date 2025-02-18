import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseServices {
  static Database? _db;
  static final DatabaseServices instance = DatabaseServices._constructor();
  DatabaseServices._constructor();

  Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final databaseDir = await getDatabasesPath();
    final databasePath = join(databaseDir, "TeaBoy.db");

    print("Database Path: $databasePath"); // Debug: Verify path
    return await openDatabase(
      databasePath,
      version: 2, // Increase version if needed
      onCreate: (db, version) async {
        print("Creating the sales table"); // Debug: Verify table creation
        await db.execute('''
          CREATE TABLE sales (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_name TEXT NOT NULL,
            morningTea INTEGER NOT NULL,
            eveningTea INTEGER NOT NULL,
            eveningSnacks INTEGER NOT NULL,
            advance INTEGER NOT NULL,
            billing_date TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          print("Upgrading the database");
          await db.execute('''
            CREATE TABLE IF NOT EXISTS sales (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              customer_name TEXT NOT NULL,
              morningTea INTEGER NOT NULL,
              eveningTea INTEGER NOT NULL,
              eveningSnacks INTEGER NOT NULL,
              advance INTEGER NOT NULL,
              billing_date TEXT
            )
          ''');
        }
      },
    );
  }
}
