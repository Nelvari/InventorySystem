
class Product {
  final int id;
  final String name;
  final int price;
  final int stock;
  final String kategories;
  final String description;
  final String image;
  final int? idSupplier;

  Product(
      {required this.id,
      required this.name,
      required this.price,
      required this.stock,
      required this.kategories,
      required this.description,
      required this.image,
      required this.idSupplier});

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
        id: map['id'] as int,
        name: map['name'] as String,
        price: map['price'] as int,
        stock: map['stock'] as int,
        kategories: map['kategories'] as String,
        description: map['description'] as String,
        image: map['image'] as String,
        idSupplier: map['idSupplier'] as int
      );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'price': price,
      'stock': stock,
      'kategories': kategories,
      'description': description,
      'image': image,
      'idSupplier': idSupplier
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      kategories: json['kategories'],
      price: json['price'],
      stock: json['stock'],
      image: json['image'],
      idSupplier: json['idSupplier'],
    );
  }

}
