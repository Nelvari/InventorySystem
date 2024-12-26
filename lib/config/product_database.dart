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

  // Update
  Future updateProduct(Product oldProduct, String name, int price, int stock,
      String kategories, String description) async {
    await database.update({
      'name': name,
      'price': price,
      'stock': stock,
      'kategories': kategories,
      'description': description,
    }).eq('id', oldProduct.id);
  }

  // Delete
  Future deleteProduct(Product product) async {
    await database.delete().eq('id', product.id);
  }
  
}
