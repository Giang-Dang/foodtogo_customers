import 'dart:developer';

import 'package:foodtogo_customers/models/merchant.dart';
import 'package:foodtogo_customers/services/merchant_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as path;

class FavoriteMerchantServices {
  static const favoriteMerchantTbName = 'favorite_merchant';
  static Database? db;

  Future<List<Merchant>> getAllMerchants() async {
    db ??= await _getFavoriteMerchantDatabase();

    final table = await db!.query(
      favoriteMerchantTbName,
      where: 'userId = ?',
      whereArgs: [UserServices.userId],
    );

    List<Merchant> merchantList = [];
    final merchantServices = MerchantServices();

    for (var row in table) {
      var merchantId = row['merchantId'] as int;
      var merchant = await merchantServices.get(merchantId);

      if (merchant == null) {
        log('getAllMerchantItems() merchant == null; Id: $merchantId');
        continue;
      }

      merchantList.add(merchant);
    }

    return merchantList;
  }

  Future<bool> addFavoriteMerchant(int merchantId) async {
    try {
      db ??= await _getFavoriteMerchantDatabase();

      db!.insert(favoriteMerchantTbName, {
        'userId': UserServices.userId,
        'merchantId': merchantId,
      });
    } catch (e) {
      log('addFavoriteMerchant $e');
      return false;
    }

    return true;
  }

  Future<bool> removeFavoriteMerchant(int merchantId) async {
    try {
      db ??= await _getFavoriteMerchantDatabase();
      int rowCount = await db!.delete(
        favoriteMerchantTbName,
        where: 'userId = ? AND merchantId = ?',
        whereArgs: [UserServices.userId, merchantId],
      );

      log('removeFavoriteMerchant affects $rowCount row(s).');
    } catch (e) {
      log('removeFavoriteMerchant $e');
      return false;
    }
    return true;
  }

  Future<bool> containsMerchantId(int merchantId) async {
    db ??= await _getFavoriteMerchantDatabase();
    final result = await db!.query(
      favoriteMerchantTbName,
      where: 'userId = ? AND merchantId = ?',
      whereArgs: [UserServices.userId, merchantId],
    );

    return result.isNotEmpty;
  }

  Future<Database> _getFavoriteMerchantDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      path.join(dbPath, '$favoriteMerchantTbName.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE $favoriteMerchantTbName(userId INTEGER, merchantId INTEGER, PRIMARY KEY(userId, merchantId))');
      },
      version: 1,
    );
    return db;
  }

  closeDb() async {
    await db?.close();
  }
}
