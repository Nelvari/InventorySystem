
import 'package:flutter/material.dart';
import 'package:inventory_system/components/styles.dart';
import 'package:inventory_system/model/supplier.dart';
import 'package:inventory_system/pages/supplier/add_supplier_page.dart';
import 'package:inventory_system/pages/supplier/detail_supplier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {

  late Future<List<Supplier>> _supplier;

  @override
  void initState() {
    super.initState();
    _refreshSupplier();
  }

  void _refreshSupplier() {
    setState(() {
      _supplier = _getSuppliersFromSupabase();
    });
  }

  Future<List<Supplier>> _getSuppliersFromSupabase() async {
    try {
      final response =
      await Supabase.instance.client.from('supplier').select();
      return response.map((json) => Supplier.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengambil data: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> _deleteSupplier(int supplierId) async {
    try {
      final products = await Supabase.instance.client
          .from('product')
          .select('id,image')
          .eq('idSupplier', supplierId);
      final productData = products as List;
      final productIds = (products as List).map((product) => product['id']).toList();
      if (productIds.isNotEmpty) {
        await Supabase.instance.client
            .from('transaksi')
            .delete()
            .inFilter('idProduct', productIds);
      }
      for (final product in productData) {
        final imagePath = product['image'] as String?;
        if (imagePath != null && imagePath.isNotEmpty) {
          final relativePath = imagePath.split('/').last;
          await Supabase.instance.client.storage
              .from('image')
              .remove([relativePath]);
        }
      }
      await Supabase.instance.client
          .from('product')
          .delete()
          .eq('idSupplier', supplierId);
      await Supabase.instance.client
          .from('supplier')
          .delete()
          .eq('id', supplierId);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Supplier berhasil dihapus!')));
      Navigator.pushNamedAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context, '/dashboard', (Route<dynamic> route) => false);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus supplier: $e')));
    }
  }

  Future<void> _updateSupplier(Supplier supplier) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSupplierPage(supplier: supplier),
      ),
    );
    if (result == true) {
      _refreshSupplier();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier'),
      ),
      body: FutureBuilder<List<Supplier>>(
        future: _supplier,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data barang.'));
          }
          final suppliers = snapshot.data!;

          return ListView.builder(
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    supplier.nama,
                    style: headerStyle(level: 3),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alamat: ${supplier.alamat}',
                          style: headerStyle(level: 4)),
                      Text('Kontak: ${supplier.kontak}',
                          style: headerStyle(level: 4)),
                    ],
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailSupplierPage(supplier: supplier),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () =>
                            _updateSupplier(
                                supplier), // Navigate to update page
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          final confirmDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) =>
                                AlertDialog(
                                  title: const Text('Hapus Supplier'),
                                  content: const Text(
                                      'Apakah Anda yakin ingin menghapus supplier ini?\nSemua data barang dan history yang memiliki supplier sama akan terhapus'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                          );

                          if (confirmDelete == true) {
                            _deleteSupplier(supplier.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSupplierPage()),
          );
          if (result == true) {
            _refreshSupplier();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}