import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/restaurant_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'restaurants.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE restaurants(id INTEGER PRIMARY KEY, address TEXT, averageRating REAL, cuisineType TEXT, imageUrl TEXT, latitude REAL, longitude REAL, menuIds TEXT, name TEXT, price INTEGER, totalReviews INTEGER)",
        );
      },
    );
  }

  Future<void> insertRestaurant(Restaurant restaurant) async {
    final db = await database;
    await db.insert(
      'restaurants',
      restaurant.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Restaurant>> getRestaurants() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('restaurants');
    return List.generate(maps.length, (i) {
      return Restaurant.fromJson(maps[i]);
    });
  }

  Future<void> deleteAllRestaurants() async {
    final db = await database;
    await db.delete('restaurants');
  }
}
