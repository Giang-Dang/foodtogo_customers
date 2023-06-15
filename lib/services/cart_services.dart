import 'dart:developer';

import 'package:foodtogo_customers/models/menu_item.dart';
import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/services/menu_item_services.dart';
import 'package:foodtogo_customers/services/merchant_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as path;

class CartServices {
  static const kCardDbName = 'cart';

  Future<List<Merchant>> getAllMerchants() async {
    final db = await _getCartDatabase();
    final table = await db.query(
      kCardDbName,
      where: 'userId = ?',
      whereArgs: [UserServices.userId],
    );

    List<Merchant> merchantList = [];
    final merchantServices = MerchantServices();

    for (var row in table) {
      var merchantId = row['merchantId'] as int;
      var merchant = await merchantServices.get(merchantId);

      if (merchant == null) {
        log('getAllMerchants() merchant == null; Id: $merchantId');
        continue;
      }

      merchantList.add(merchant);
    }

    return merchantList;
  }

  Future<List<MenuItem>> getAllMenuItemsByMerchantId(int merchantId) async {
    final db = await _getCartDatabase();
    final table = await db.query(
      kCardDbName,
      where: 'userId = ? AND merchantId = ?',
      whereArgs: [UserServices.userId, merchantId],
    );

    List<MenuItem> menuItemList = [];
    final menuItemServices = MenuItemServices();

    for (var row in table) {
      var menuItemId = row['menuItemId'] as int;
      var menuItem = await menuItemServices.get(menuItemId);

      if (menuItem == null) {
        log('getAllMenuItemsByMerchantId() menuItem == null; Id: $menuItemId');
        continue;
      }

      menuItemList.add(menuItem);
    }

    return menuItemList;
  }

  Future<int> getQuantity(int menuItemId) async {
    final db = await _getCartDatabase();
    final table = await db.query(
      kCardDbName,
      where: 'userId = ? AND menuItemId = ?',
      whereArgs: [UserServices.userId, menuItemId],
      limit: 1,
    );

    if (table.isEmpty) {
      log('getQuantity() table.isEmpty');
      return 0;
    }

    final row = table[0];
    final quantity = row['quantity'] as int?;
    if (quantity == null) {
      log('getQuantity() quantity == null');
      return 0;
    }

    return quantity;
  }

  Future<int> getTotalQuantity() async {
    final db = await _getCartDatabase();
    final result = await db.rawQuery(
        'SELECT SUM(quantity) as totalQuantity FROM $kCardDbName WHERE userId = ?',
        [UserServices.userId]);

    int totalQuantity = result[0]['totalQuantity'] as int;

    return totalQuantity;
  }

  Future<bool> addMenuItem(MenuItem menuItem, int quantity) async {
    try {
      final isMenuItemExists = await containsMenuItem(menuItem);
      if (isMenuItemExists) {
        update(menuItem, quantity);
      } else {
        insert(menuItem, quantity);
      }
      return true;
    } catch (e) {
      log('addMenuItem $e');
      return false;
    }
  }

  Future<bool> containsMenuItem(MenuItem menuItem) async {
    final db = await _getCartDatabase();
    final result = await db.query(
      kCardDbName,
      where: 'userId = ? AND menuItemId = ?',
      whereArgs: [UserServices.userId, menuItem.id],
    );

    return result.isNotEmpty;
  }

  Future<bool> insert(MenuItem menuItem, int quantity) async {
    try {
      final db = await _getCartDatabase();

      int id = await db.insert(kCardDbName, {
        'userId': UserServices.userId,
        'menuItemId': menuItem.id,
        'merchantId': menuItem.merchantId,
        'quantity': quantity,
      });
      log('CartServices.insert() affects menuItemId $id.');
    } catch (e) {
      log('CartServices.insert() $e');
      return false;
    }

    return true;
  }

  Future<bool> update(MenuItem menuItem, int newQuantity) async {
    try {
      final db = await _getCartDatabase();

      int rowCount = await db.update(
        kCardDbName,
        {
          'quantity': newQuantity,
        },
        where: 'userId = ? AND menuItemId = ?',
        whereArgs: [UserServices.userId, menuItem.id],
      );
      log('CartServices.update() affects $rowCount row(s).');
    } catch (e) {
      log('CartServices.update() $e');
      return false;
    }

    return true;
  }

  Future<bool> delete(MenuItem menuItem) async {
    try {
      final db = await _getCartDatabase();

      int rowCount = await db.delete(kCardDbName,
          where: 'userId = ? AND menuItemId = ?',
          whereArgs: [UserServices.userId, menuItem.id]);
      log('CartServices.delete() affects $rowCount row(s).');
    } catch (e) {
      log('CartServices.delete() $e');
      return false;
    }

    return true;
  }

  Future<Database> _getCartDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      path.join(dbPath, '$kCardDbName.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE $kCardDbName(userId INTEGER, menuItemId INTEGER, merchantId INTEGER, quantity INTEGER, PRIMARY KEY(userId, menuItemId))');
      },
      version: 1,
    );
    return db;
  }
}
