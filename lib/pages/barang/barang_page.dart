import 'package:flutter/material.dart';
import 'package:inventory_system/config/product_database.dart';
import 'package:inventory_system/pages/barang/detail_page.dart';
import 'package:inventory_system/pages/barang/add_page.dart';
import 'package:inventory_system/pages/barang/update_page.dart';


class BarangPage extends StatefulWidget {
  const BarangPage({super.key});

  @override
  State<BarangPage> createState() => _BarangPageState();
}

class _BarangPageState extends State<BarangPage> {
  // Product database
  final productDatabase = ProductDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barang'),
      ),
      body: StreamBuilder(
          stream: productDatabase.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No products found'));
            }

            final products = snapshot.data!;

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                mainAxisExtent: 285,
              ),
              itemBuilder: (context, index) {
                final product = products[index];

                return Card(
                  elevation: 2,
                  color: Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        product.image != null && product.image.isNotEmpty
                          ? Image.network(
                              product.image,
                              width: double.infinity,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image,
                                    size: 100, color: Colors.grey);
                              },
                            )
                          : const Icon(Icons.image, size: 200, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(product.name),
                        Text('Kategori: ${product.kategories}'),
                        Text('Price: ${product.price}'),
                        Text('Stock: ${product.stock}'),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 40,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return DetailPage(
                                      product: product,
                                    );
                                  }));
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.info,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return UpdatePage(
                                      product: product,
                                    );
                                  }));
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const AddPage();
          }));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
