import 'package:inventory_system/model/transaksi.dart';
import 'package:sqflite/sqflite.dart';

import '../model/barang.dart';

class DbHelper {
  Database? _database;

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE product(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      price INTEGER,
      stock INTEGER,
      kategories TEXT,
      description TEXT,
      image BLOB 
    )
  ''');

    await db.execute('''
    CREATE TABLE transaksi(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      idProduct INTEGER,
      jumlah INTEGER,
      jenisTransaksi TEXT,
      tanggal TEXT,
      FOREIGN KEY (idProduct) REFERENCES product (id)
    )
  ''');
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = dbPath + filePath;
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<Database> get getDB async {
    _database ??= await _initDB('product.db');
    return _database!;
  }

  Future<List<TransaksiModel>> getTransaksi(int id) async {
    final db = await getDB;
    try {
      final List<Map<String, dynamic>> results = await db.query(
        'transaksi',
        where: 'idProduct = ?',
        whereArgs: [id],
        orderBy: 'id DESC',
      );
      return results.map((res) => TransaksiModel.fromMap(res)).toList();
    } catch (e) {
      throw Exception('Gagal mendapatkan data: $e');
    }
  }

  Future<int> insertTransaksi(TransaksiModel transaksi) async {
    final db = await getDB;
    try {
      // Memulai transaksi database
      return await db.transaction((txn) async {
        // Insert ke tabel transaksi
        final int transaksiId = await txn.insert('transaksi', transaksi.toMap());

        // Mendapatkan stok produk saat ini
        final List<Map<String, dynamic>> productData = await txn.query(
          'product',
          where: 'id = ?',
          whereArgs: [transaksi.idProduct],
        );

        if (productData.isEmpty) {
          throw Exception('Produk dengan ID ${transaksi.idProduct} tidak ditemukan.');
        }

        // Hitung stok baru berdasarkan jenis transaksi
        final int currentStock = productData.first['stock'];
        int updatedStock = currentStock;

        if (transaksi.jenisTransaksi == 'keluar') {
          updatedStock -= transaksi.jumlah;
          if (updatedStock < 0) {
            throw Exception('Stok tidak mencukupi untuk penjualan.');
          }
        } else if (transaksi.jenisTransaksi == 'masuk') {
          updatedStock += transaksi.jumlah;
        } else {
          throw Exception('Jenis transaksi tidak valid.');
        }

        // Update stok produk di tabel product
        await txn.update(
          'product',
          {'stock': updatedStock},
          where: 'id = ?',
          whereArgs: [transaksi.idProduct],
        );

        return transaksiId; // Kembalikan ID transaksi yang baru ditambahkan
      });
    } catch (e) {
      throw Exception('Gagal menambahkan transaksi: $e');
    }
  }

  Future<int> insert(ProductModel product) async {
    final db = await getDB;
    try {
      return await db.insert('product', product.toMap());
    } catch (e) {
      throw Exception('Gagal menambahkan data: $e');
    }
  }

  Future<List<ProductModel>> getProducts() async {
    final db = await getDB;
    try {
      final List<Map<String, dynamic>> results = await db.query(
        'product',
        orderBy: 'id DESC',
      );
      return results.map((res) => ProductModel.fromMap(res)).toList();
    } catch (e) {
      throw Exception('Gagal mendapatkan data: $e');
    }
  }

  Future<int> update(ProductModel product) async {
    final db = await getDB;
    try {
      return await db.update(
        'product',
        product.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
    } catch (e) {
      throw Exception('Gagal memperbarui data: $e');
    }
  }

  Future<int> delete(ProductModel product) async {
    final db = await getDB;
    try {
      return await db.delete(
        'product',
        where: 'id = ?',
        whereArgs: [product.id],
      );
    } catch (e) {
      throw Exception('Gagal menghapus data: $e');
    }
  }
}
