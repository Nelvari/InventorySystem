import 'package:flutter/material.dart';
import 'package:inventory_system/config/db_helper.dart';
import 'package:inventory_system/model/transaksi.dart';
import 'package:inventory_system/pages/riwayat_page.dart';
import 'dart:typed_data';

import '../model/barang.dart';

class DetailPage extends StatefulWidget {
  final ProductModel product;
  const DetailPage({super.key, required this.product});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late final String _name;
  late final int _id;
  late final String _price;
  late final String _kategories;
  late final String _description;
  late final String _stock;
  Uint8List? _imageBase64;

  late Future<List<TransaksiModel>> _transaksi;

  @override
  void initState() {
    _name = widget.product.name;
    _id = widget.product.id!;
    _price = widget.product.price.toString();
    _stock = widget.product.stock.toString();
    _kategories = widget.product.kategories;
    _description = widget.product.description;

    if (widget.product.image != null) {
      _imageBase64 = widget.product.image!;
    }

    setState(() {
      _transaksi = DbHelper().getTransaksi(_id);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Page'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                image: _imageBase64 != null
                    ? DecorationImage(
                        image: MemoryImage(_imageBase64!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _imageBase64 == null
                  ? const Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 50,
                      ),
                    )
                  : null,
            ),
          ),
          Text(
            'Name : $_name',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Price : $_price',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Stock : $_stock',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Kategori : $_kategories',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Description : $_description',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Daftar Riwayat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            height: 1, 
            width: double.infinity,  
            color: Colors.black,  
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<TransaksiModel>>(
            future: _transaksi,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('Tidak ada riwayat transaksi.');
              }

              final transaksiList = snapshot.data!;

              return Column(
                children: transaksiList.map((transaksi) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('Tanggal: ${transaksi.tanggal}'),
                      subtitle: Text('Jumlah: ${transaksi.jumlah} \nJenis: ${transaksi.jenisTransaksi}')
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RiwayatPage(product: widget.product)),
              );
            },
            child: const Text('Tambah Riwayat'),
          )
        ],
      ),
    );
  }
}
