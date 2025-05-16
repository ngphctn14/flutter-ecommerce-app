import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class VietnameseProvincesDatabaseHelper {
  static final VietnameseProvincesDatabaseHelper _instance =
      VietnameseProvincesDatabaseHelper._internal();
  static Database? _database;

  factory VietnameseProvincesDatabaseHelper() => _instance;

  VietnameseProvincesDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'vietnamese-provinces.sqlite');

    if (!File(path).existsSync()) {
      ByteData data = await rootBundle.load(
        'assets/db/vietnamese-provinces.sqlite',
      );
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(path, readOnly: true);
  }

  Future<List<Map<String, dynamic>>> getProvinces() async {
    final db = await database;
    return await db.query('provinces');
  }

  Future<List<Map<String, dynamic>>> getDistrictsByProvince(
    String provinceCode,
  ) async {
    final db = await database;
    return await db.query(
      'districts',
      where: 'province_code = ?',
      whereArgs: [provinceCode],
    );
  }

  Future<List<Map<String, dynamic>>> getWardsByDistrict(
    String districtCode,
  ) async {
    final db = await database;
    return await db.query(
      'wards',
      where: 'district_code = ?',
      whereArgs: [districtCode],
    );
  }
}
