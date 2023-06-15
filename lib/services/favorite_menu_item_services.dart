import 'dart:developer';

import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/services/menu_item_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as path;

class FavoriteMenuItemServices {
  static const kFavoriteMenuItemTbName = 'favorite_menu_item';
  static Database? db;

  Future<List<MenuItem>> getAllFavoriteMenuItems() async {
    db ??= await _getFavoriteMenuItemDatabase();
    final table = await db!.query(
      kFavoriteMenuItemTbName,
      where: 'userId = ?',
      whereArgs: [UserServices.userId],
    );

    List<MenuItem> menuItemList = [];
    final menuItemServices = MenuItemServices();

    for (var row in table) {
      var menuItemId = row['menuItemId'] as int;
      var menuItem = await menuItemServices.get(menuItemId);

      if (menuItem == null) {
        log('getAllFavoriteMenuItems() menuItem == null; Id: $menuItemId');
        continue;
      }

      menuItemList.add(menuItem);
    }

    return menuItemList;
  }

  Future<bool> addFavoriteMenuItem(int menuItemId) async {
    try {
      db ??= await _getFavoriteMenuItemDatabase();

      db!.insert(kFavoriteMenuItemTbName, {
        'userId': UserServices.userId,
        'menuItemId': menuItemId,
      });
    } catch (e) {
      log('addFavoriteMenuItem $e');
      return false;
    }

    return true;
  }

  Future<bool> removeFavoriteMenuItem(int menuItemId) async {
    try {
      db ??= await _getFavoriteMenuItemDatabase();

      int rowCount = await db!.delete(
        kFavoriteMenuItemTbName,
        where: 'userId = ? AND menuItemId = ?',
        whereArgs: [UserServices.userId, menuItemId],
      );

      log('removeFavoriteMenuItem affects $rowCount row(s).');
    } catch (e) {
      log('removeFavoriteMenuItem $e');
      return false;
    }
    return true;
  }

  Future<bool> containsMenuItemId(int menuItemId) async {
    db ??= await _getFavoriteMenuItemDatabase();
    final result = await db!.query(
      kFavoriteMenuItemTbName,
      where: 'userId = ? AND menuItemId = ?',
      whereArgs: [UserServices.userId, menuItemId],
    );

    return result.isNotEmpty;
  }

  Future<Database> _getFavoriteMenuItemDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      path.join(dbPath, '$kFavoriteMenuItemTbName.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE $kFavoriteMenuItemTbName(userId INTEGER, menuItemId INTEGER, PRIMARY KEY(userId, menuItemId))');
      },
      version: 1,
    );
    return db;
  }

  closeDb() async {
    await db?.close();
  }
}
