import 'dart:convert';
import 'dart:typed_data';

class ProductModel {
  final int? id;
  final String name;
  final int price;
  final int stock;
  final String kategories;
  final String description;
  final Uint8List? image;

  ProductModel(
      {this.id,
      required this.name,
      required this.price,
      required this.stock,
      required this.kategories,
      required this.description,
      this.image});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'kategories': kategories,
      'description': description,
      'image': image,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: map['price'] as int,
      stock: map['stock'] as int,
      kategories: map['kategories'] as String,
      description: map['description'] as String,
      image: map['image'] as Uint8List?,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductModel.fromJson(String source) =>
      ProductModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
