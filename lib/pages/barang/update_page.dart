
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_system/components/styles.dart';
import 'package:inventory_system/model/barang.dart';
import 'package:inventory_system/model/supplier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdatePage extends StatefulWidget {
  final Product product;

  const UpdatePage({required this.product, Key? key}) : super(key: key);

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _hargaController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _imageController = TextEditingController();
  List<Supplier> _supplierList = [];
  int? _selectedSupplierId;
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _namaController.text = widget.product.name;
      _deskripsiController.text = widget.product.description;
      _hargaController.text = widget.product.price.toString();
      _kategoriController.text = widget.product.kategories;
      _selectedSupplierId = widget.product.idSupplier;
      _imageController.text = widget.product.image;
    }
    _fetchSuppliers();
  }

  Future<void> _fetchSuppliers() async {
    try {
      final response =
          await Supabase.instance.client.from('supplier').select();
      setState(() {
        _supplierList = (response as List<dynamic>)
            .map((supplier) => Supplier.fromJson(supplier))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data supplier: $e')),
      );
    }
  }

  Future<void> _pickGalleryImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickCameraImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProduct() async {
    final nama = _namaController.text;
    final deskripsi = _deskripsiController.text;
    final harga = int.tryParse(_hargaController.text) ?? 0;
    final kategori = _kategoriController.text;

    if (nama.isEmpty ||
        deskripsi.isEmpty ||
        kategori.isEmpty ||
        _selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua data harus diisi!')),
      );
      return;
    }

    try {
      if (_selectedImage != null) {
        final relativePath = widget.product.image.split('/').last;
        if (relativePath.isNotEmpty) {
          await Supabase.instance.client.storage
              .from('image')
              .remove([relativePath]);
        }
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        await Supabase.instance.client.storage
            .from('image')
            .upload(fileName, _selectedImage!);
        final imageUrl = Supabase.instance.client.storage
            .from('image')
            .getPublicUrl(fileName);
        await Supabase.instance.client.from('product').update({
          'name': nama,
          'description': deskripsi,
          'kategories': kategori,
          'price': harga,
          'image': imageUrl,
          'idSupplier': _selectedSupplierId,
        }).eq('id', widget.product.id);
      } else {
        await Supabase.instance.client.from('products').update({
          'name': nama,
          'description': deskripsi,
          'kategories': kategori,
          'price': harga,
          'idSupplier': _selectedSupplierId,
        }).eq('id', widget.product.id);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil disimpan!')),
      );
      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', (Route<dynamic> route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Barang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _selectedImage == null
                  ? Image.network(
                      _imageController.text,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image,
                            size: 200, color: Colors.grey);
                      },
                    )
                  : Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: _selectedImage != null
                          ? Image.file(_selectedImage!, fit: BoxFit.cover)
                          : const Icon(Icons.camera_alt,
                              size: 50, color: Colors.grey),
                    ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _pickCameraImage,
                    style: buttonStyle,
                    child: Row(
                      children: [
                        const Icon(Icons.camera, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Kamera',
                            style: headerStyle(level: 4, dark: false)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickGalleryImage,
                    style: buttonStyle,
                    child: Row(
                      children: [
                        const Icon(Icons.photo_library, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Galeri',
                            style: headerStyle(level: 4, dark: false)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nama wajib diisi' : null,
              ),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Deskripsi wajib diisi'
                    : null,
              ),
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Harga wajib diisi' : null,
              ),
              TextFormField(
                controller: _kategoriController,
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Kategori wajib diisi'
                    : null,
              ),
              const SizedBox(height: 20),
              if (_supplierList.isNotEmpty)
                DropdownButton<int>(
                  isExpanded: true,
                  value: _selectedSupplierId,
                  hint: const Text('Pilih Supplier'),
                  items: _supplierList.map((supplier) {
                    return DropdownMenuItem<int>(
                      value: supplier.id,
                      child: Text(supplier.nama),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSupplierId = value;
                    });
                  },
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateProduct,
                style: buttonStyle,
                child:
                    const Text('Simpan', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}