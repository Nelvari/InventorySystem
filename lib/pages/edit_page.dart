import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

import '../config/db_helper.dart';
import '../model/barang.dart';
import 'package:image_picker/image_picker.dart';

import 'home_page.dart';

class EditPage extends StatefulWidget {
  final ProductModel product;
  const EditPage({super.key, required this.product});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _kategoriesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();
  Uint8List? _imageBase64;

  @override
  void initState() {
    _nameController.text = widget.product.name;
    _priceController.text = widget.product.price.toString();
    _stockController.text = widget.product.stock.toString();
    _kategoriesController.text = widget.product.kategories;
    _descriptionController.text = widget.product.description;

    if (widget.product.image != null) {
      _imageBase64 = widget.product.image!;
    }

    super.initState();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      setState(() {
        _imageBase64 = bytes;
      });
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('Take a Photo'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Page'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _showImageSourceActionSheet,
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
          const Text(
            'Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Product Name',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Price',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _priceController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Product Price',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Stock',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _stockController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Product Stock',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Kategori',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _kategoriesController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Product Kategories',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Product Description',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final product = ProductModel(
                id: widget.product.id,
                name: _nameController.text,
                price: int.parse(_priceController.text),
                stock: int.parse(_stockController.text),
                kategories: _kategoriesController.text,
                description: _descriptionController.text,
                image: _imageBase64,
              );

              final response = await DbHelper().update(product);

              if (response > 0) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.green,
                  content: Text('Product ${product.id} updated successfully '),
                ));

                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const HomePage()));
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.red,
                  content: Text('Failed to update product ${product.id}'),
                ));
              }
            },
            child: const Text('Update Product'),
          ),
        ],
      ),
    );
  }
}