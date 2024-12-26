import 'package:flutter/material.dart';
import 'package:inventory_system/components/styles.dart';
import 'package:inventory_system/model/transaksi.dart';
import 'package:inventory_system/pages/barang/riwayat_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../model/barang.dart';

class DetailPage extends StatefulWidget {
  final Product product;
  const DetailPage({super.key, required this.product});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  late Future<List<Transaksi>> _transaksi;
  late Product _product;
  String? _supplierName;

  @override
  void initState() {
    _product = widget.product;
    _transaksi = _getHistoriesFromSupabase();
    _fetchSupplierName();
  }

  Future<void> _fetchSupplierName() async {
    try {
      final response = await Supabase.instance.client
          .from('supplier')
          .select('nama')
          .eq('id', _product.idSupplier as int)
          .single();
      setState(() {
        _supplierName = response['nama'] as String?;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil nama supplier: $e')),
      );
    }
  }

  Future<Product> _getProductFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('product')
          .select()
          .eq('id', _product.id);
      return response.map((json) => Product.fromJson(json)).toList().first;
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengambil product: ${e.message}');
    }
  }

  Future<List<Transaksi>> _getHistoriesFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('transaksi')
          .select()
          .eq('idProduct', _product.id);
      return (response as List)
          .map((json) => Transaksi.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to fetch histories: $e');
    }
  }

  Future<void> _refreshProduct() async {
    try {
      final results = await Future.wait([
        _getProductFromSupabase(),
        _getHistoriesFromSupabase(),
        _fetchSupplierName(),
      ]);
      setState(() {
        _product = results[0] as Product;
        _transaksi = Future.value(results[1] as List<Transaksi>);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui produk: $e')),
      );
    }
  }

  Future<void> _deleteProduct(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Barang'),
        content: Text('Apakah Anda yakin ingin menghapus barang ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final relativePath = _product.image.split('/').last;
        if (relativePath.isNotEmpty) {
          await Supabase.instance.client.storage
              .from('image')
              .remove([relativePath]);
        }
        await Future.wait([
          Supabase.instance.client
              .from('product')
              .delete()
              .eq('id', _product.id),
          Supabase.instance.client
              .from('transaksi')
              .delete()
              .eq('idProduct', _product.id),
        ]);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Barang dan histori berhasil dihapus.')));
        Navigator.pushNamedAndRemoveUntil(
            context, '/dashboard', (Route<dynamic> route) => false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus barang: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Barang'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _product.image != null && _product.image.isNotEmpty
                  ? Image.network(
                      _product.image,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.broken_image,
                            size: 200, color: Colors.grey);
                      },
                    )
                  : Icon(Icons.image, size: 200, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                _product.name,
                style: headerStyle(level: 2),
              ),
              SizedBox(height: 8),
              Text(
                'Supplier: ${_supplierName ?? 'Loading...'}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 8),
              Text(
                'Kategori: ${_product.kategories}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 8),
              Text(
                'Harga: Rp${_product.price}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 8),
              Text(
                'Stok: ${_product.stock}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 8),
              Text(
                'Deskripsi:',
                style: textStyle(level: 2),
              ),
              SizedBox(height: 4),
              Text(
                _product.description,
                style: textStyle(level: 4),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   ElevatedButton(
                    onPressed: () => _deleteProduct(context),
                    style: buttonStyle.copyWith(
                      backgroundColor: MaterialStateProperty.all(dangerColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Hapus',
                            style: headerStyle(level: 4, dark: false)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RiwayatPage(product: _product),
                        ),
                      );
                      if (result == true) {
                        await _refreshProduct();
                      }
                    },
                    style: buttonStyle,
                    child: Row(
                      children: [
                        Icon(Icons.update, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Update Stok',
                            style: headerStyle(level: 4, dark: false)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<Transaksi>>(
                future: _transaksi,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Tidak ada data histori.'));
                  }

                  final histories = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: histories.length,
                    itemBuilder: (context, index) {
                      final history = histories[index];
                      return Card(
                        key: Key(history.id.toString()),
                        margin:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanggal : ${DateFormat('dd-MM-yyyy')
                                        .format(history.tanggal)}',
                                style: headerStyle(level: 4),
                              ),
                              Text(
                                'Jenis Transaksi: ${history.jenisTransaksi}',
                                style: headerStyle(level: 4),
                              ),
                              Text(
                                'Jumlah: ${history.jumlah}',
                                style: headerStyle(level: 4),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
