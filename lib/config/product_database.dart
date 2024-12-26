import 'package:inventory_system/model/barang.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDatabase {
  final database = Supabase.instance.client.from('product');

  // create
  Future createProduct(Product newProduct) async {
    await database.insert(newProduct.toMap());
  }

  // Read
  final stream = Supabase.instance.client.from('product').stream(
    primaryKey: ['id'],
  ).map(
      (data) => data.map((productMap) => Product.fromMap(productMap)).toList());

}
